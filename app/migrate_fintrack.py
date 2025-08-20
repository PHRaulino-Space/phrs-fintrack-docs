"""
FINTRACK DATABASE MIGRATION SCRIPT
==================================

This script migrates data from fintrack database (public schema)
to phrspace database (fintrack schema).

Requirements:
- psycopg2-binary (pip install psycopg2-binary)
- python-dotenv (pip install python-dotenv)
- Source database: fintrack with public schema
- Target database: phrspace with fintrack schema (must be created first)

Usage:
    python migrate_fintrack.py

Configuration:
    Copy .env.example to .env and fill in your database credentials
"""

import os
import sys
import logging
import psycopg2
from pydantic import BaseModel
from psycopg2.extras import RealDictCursor
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple
import json
from openai import OpenAI
import time
from collections import deque
import threading
import uuid

from onepasswordconnectsdk.client import new_client_from_environment


class SecretsManager:
    def __init__(self, vault_id: str = None):
        self.client = new_client_from_environment()
        self.vault_id = vault_id or os.getenv("OP_VAULT")

    def get_postgres_credentials(self, item_id: str) -> dict:
        """Obtém credenciais do PostgreSQL do 1Password"""
        item = self.client.get_item(item_id, self.vault_id)
        return {
            "username": next(
                f.value for f in item.fields if f.id == "username"
            ),
            "password": next(
                f.value for f in item.fields if f.id == "password"
            ),
        }

    def get_openai_credentials(self, item_id: str) -> dict:
        """Obtém credenciais do OpenAI do 1Password"""
        item = self.client.get_item(item_id, self.vault_id)
        return {
            "name": next(f.value for f in item.fields if f.label == "name"),
            "api_key": next(
                f.value for f in item.fields if f.label == "API_KEY"
            ),
        }


# Initialize secrets manager
secrets = SecretsManager()
creds = secrets.get_postgres_credentials("25dxs7wjovqfbxzzbbuw7ptsc4")
openai_creds = secrets.get_openai_credentials(
    "exfmktk5tdvnr7qpzfvinkpxe4"
)  # Replace with actual item ID

# Load environment variables from .env file
os.environ["SOURCE_DB_HOST"] = "phrspace-db-service.phrspace-db"
os.environ["SOURCE_DB_PORT"] = "5432"
os.environ["SOURCE_DB_NAME"] = "fintrack"
os.environ["SOURCE_DB_USER"] = creds["username"]
os.environ["SOURCE_DB_PASSWORD"] = creds["password"]

os.environ["TARGET_DB_HOST"] = "phrspace-db-service.phrspace-db"
os.environ["TARGET_DB_PORT"] = "5432"
os.environ["TARGET_DB_NAME"] = "phrspace"
os.environ["TARGET_DB_USER"] = creds["username"]
os.environ["TARGET_DB_PASSWORD"] = creds["password"]


os.environ["OPENAI_API_KEY"] = openai_creds["api_key"]

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler(
            f'migration_{datetime.now().strftime("%Y%m%d_%H%M%S")}.log'
        ),
        logging.StreamHandler(sys.stdout),
    ],
)
logger = logging.getLogger(__name__)


class TransactionInput(BaseModel):
    id: str
    description: str
    amount: float


class TransactionResult(BaseModel):
    id: str
    improved_description: str
    category_id: str
    subcategory_id: Optional[str]
    confidence: float
    reasoning: str


class BatchCategorizerResponse(BaseModel):
    transactions: List[TransactionResult]


class DatabaseConfig:
    """Database configuration class"""

    def __init__(self, prefix: str):
        self.host = os.getenv(f"{prefix}_DB_HOST", "localhost")
        self.port = int(os.getenv(f"{prefix}_DB_PORT", "5432"))
        self.database = os.getenv(f"{prefix}_DB_NAME")
        self.user = os.getenv(f"{prefix}_DB_USER", "postgres")
        self.password = os.getenv(f"{prefix}_DB_PASSWORD")

        if not self.database:
            raise ValueError(
                f"Database name is required. Set {prefix}_DB_NAME in .env file."
            )

    def get_connection_string(self) -> str:
        """Get PostgreSQL connection string"""
        conn_params = {
            "host": self.host,
            "port": self.port,
            "dbname": self.database,
            "user": self.user,
        }

        if self.password:
            conn_params["password"] = self.password

        return " ".join([f"{k}={v}" for k, v in conn_params.items()])


class RateLimiter:
    """Rate limiter to enforce 400 RPM (requests per minute) limit"""

    def __init__(self, max_requests_per_minute: int = 400):
        self.max_requests = max_requests_per_minute
        self.requests = deque()
        self.lock = threading.Lock()

    def wait_if_needed(self):
        """Wait if necessary to respect rate limit"""
        with self.lock:
            now = datetime.now()

            # Remove requests older than 1 minute
            while self.requests and self.requests[0] <= now - timedelta(
                minutes=1
            ):
                self.requests.popleft()

            # If we're at the limit, wait until we can make another request
            if len(self.requests) >= self.max_requests:
                # Wait until the oldest request is more than 1 minute old
                sleep_time = (
                    self.requests[0] + timedelta(minutes=1) - now
                ).total_seconds()
                if sleep_time > 0:
                    logger.info(
                        f"Rate limit reached, waiting {sleep_time:.1f} seconds..."
                    )
                    time.sleep(sleep_time)
                    # Clean up expired requests after waiting
                    while self.requests and self.requests[
                        0
                    ] <= datetime.now() - timedelta(minutes=1):
                        self.requests.popleft()

            # Record this request
            self.requests.append(now)

    def get_current_rate(self) -> int:
        """Get current requests in the last minute"""
        with self.lock:
            now = datetime.now()
            # Remove requests older than 1 minute
            while self.requests and self.requests[0] <= now - timedelta(
                minutes=1
            ):
                self.requests.popleft()
            return len(self.requests)


class OpenAITransactionProcessor:
    """Handles OpenAI GPT-5 Nano integration for transaction processing with rate limiting and batch processing"""

    def __init__(self, api_key: str, max_rpm: int = 400, batch_size: int = 25):
        self.client = OpenAI()
        self.model = "gpt-5-nano"  # Using GPT-5 Nano
        self.rate_limiter = RateLimiter(max_rpm)
        self.batch_size = batch_size  # Process transactions in batches
        self.total_requests = 0
        self.successful_requests = 0
        self.failed_requests = 0
        self.total_transactions_processed = 0
        self.total_transactions_enhanced = 0
        self.response_cache = None
        self.prompt_cache = None

    def get_categories_and_subcategories(
        self, conn
    ) -> Tuple[List[Dict], Dict[str, List[Dict]]]:
        """Fetch all categories and subcategories from the database"""
        with conn.cursor() as cursor:
            # Get categories
            cursor.execute(
                "SELECT id, name FROM fintrack.categories WHERE is_active = true"
            )
            categories = cursor.fetchall()

            # Get subcategories grouped by category
            cursor.execute(
                """
                SELECT sc.id, sc.name, sc.category_id, c.name as category_name
                FROM fintrack.sub_categories sc
                JOIN fintrack.categories c ON sc.category_id = c.id
                WHERE sc.is_active = true AND c.is_active = true
                ORDER BY c.name, sc.name
            """
            )
            subcategories_data = cursor.fetchall()

            # Group subcategories by category ID
            subcategories_by_category = {}
            for subcat in subcategories_data:
                cat_id = str(subcat["category_id"])
                if cat_id not in subcategories_by_category:
                    subcategories_by_category[cat_id] = []
                subcategories_by_category[cat_id].append(
                    {"id": str(subcat["id"]), "name": subcat["name"]}
                )

            return categories, subcategories_by_category

    def format_categories(self, categories, subcategories_by_category):
        """
        Formata categorias e subcategorias em texto estruturado (apenas nomes)

        Args:
            categories: Lista de dicionários com categorias
            subcategories_by_category: Dict mapeando category_id para lista de subcategorias

        Returns:
            String formatada com categorias e subcategorias
        """
        lines = []

        for cat in categories:
            # Adiciona a categoria principal (apenas nome)
            cat_line = f"- {cat['name']}"

            # Verifica se há subcategorias
            cat_id_str = str(cat["id"])
            if cat_id_str in subcategories_by_category:
                subcats = subcategories_by_category[cat_id_str]
                if subcats:  # Se a lista não estiver vazia
                    subcat_names = [sub["name"] for sub in subcats]
                    cat_line += f"\n  Subcategorias: {', '.join(subcat_names)}"

            lines.append(cat_line)

        return "\n".join(lines)

    def create_new_category(
        self, conn, category_name: str, category_type: str = "expense"
    ) -> str:
        """
        Cria uma nova categoria no banco de dados

        Args:
            conn: Conexão com o banco de dados
            category_name: Nome da categoria
            category_type: Tipo da categoria ('expense' ou 'income')

        Returns:
            ID da nova categoria criada
        """
        new_category_id = str(uuid.uuid4())

        with conn.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO fintrack.categories (id, name, type, color, icon, is_active, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s, now(), now())
                ON CONFLICT (name, type) DO UPDATE SET updated_at = now()
                RETURNING id
                """,
                (
                    new_category_id,
                    category_name,
                    category_type,
                    "#808080",  # Cor padrão cinza
                    "default",  # Ícone padrão
                    True,
                ),
            )
            result = cursor.fetchone()
            if result:
                actual_id = str(result["id"])
                logger.info(
                    f"✓ Created new {category_type} category: '{category_name}' (ID: {actual_id})"
                )
                return actual_id
            else:
                # Se ON CONFLICT foi acionado, buscar o ID existente
                cursor.execute(
                    "SELECT id FROM fintrack.categories WHERE name = %s AND type = %s",
                    (category_name, category_type),
                )
                existing = cursor.fetchone()
                if existing:
                    existing_id = str(existing["id"])
                    logger.debug(
                        f"Category '{category_name}' already exists with ID: {existing_id}"
                    )
                    return existing_id
                else:
                    logger.error(
                        f"Failed to create or find category: {category_name}"
                    )
                    return None

    def create_new_subcategory(
        self, conn, subcategory_name: str, category_id: str
    ) -> str:
        """
        Cria uma nova subcategoria no banco de dados

        Args:
            conn: Conexão com o banco de dados
            subcategory_name: Nome da subcategoria
            category_id: ID da categoria pai

        Returns:
            ID da nova subcategoria criada
        """
        new_subcategory_id = str(uuid.uuid4())

        with conn.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO fintrack.sub_categories (id, name, category_id, is_active, created_at, updated_at)
                VALUES (%s, %s, %s, %s, now(), now())
                ON CONFLICT (name, category_id) DO UPDATE SET updated_at = now()
                RETURNING id
                """,
                (new_subcategory_id, subcategory_name, category_id, True),
            )
            result = cursor.fetchone()
            if result:
                actual_id = str(result["id"])
                logger.info(
                    f"✓ Created new subcategory: '{subcategory_name}' under category {category_id} (ID: {actual_id})"
                )
                return actual_id
            else:
                # Se ON CONFLICT foi acionado, buscar o ID existente
                cursor.execute(
                    "SELECT id FROM fintrack.sub_categories WHERE name = %s AND category_id = %s",
                    (subcategory_name, category_id),
                )
                existing = cursor.fetchone()
                if existing:
                    existing_id = str(existing["id"])
                    logger.debug(
                        f"Subcategory '{subcategory_name}' already exists with ID: {existing_id}"
                    )
                    return existing_id
                else:
                    logger.error(
                        f"Failed to create or find subcategory: {subcategory_name}"
                    )
                    return None

    def improve_and_categorize_transactions_batch(
        self,
        transactions: List[Dict],
        categories: List[Dict],
        subcategories_by_category: Dict,
        conn,
    ) -> List[Dict]:
        """Process multiple transactions in a single OpenAI API call for better token efficiency"""

        if not transactions:
            return []

        # Apply rate limiting before making the request
        self.rate_limiter.wait_if_needed()
        self.total_requests += 1

        # Log current rate every 10 requests (less frequent since we're processing batches)
        if self.total_requests % 10 == 0:
            current_rate = self.rate_limiter.get_current_rate()
            logger.info(
                f"API Usage: {current_rate}/400 RPM | Batch Requests: {self.total_requests} | Total Transactions: {self.total_transactions_processed} | Enhanced: {self.total_transactions_enhanced}"
            )

        # Format categories and subcategories for the prompt
        categories_text = self.format_categories(
            categories, subcategories_by_category
        )

        # Format transactions for batch processing
        transaction_list = "\n".join(
            [
                f"ID: {tx['id']} | Description: \"{tx['description']}\" | Amount: ${tx['amount']:.2f}"
                for tx in transactions
            ]
        )

        prompt = f"""
Você é um especialista em categorização de transações financeiras. Processe o seguinte lote de despesas:

Transações para processar:
{transaction_list}

Categorias e Subcategorias disponíveis:
{categories_text}

REGRAS DE CATEGORIZAÇÃO:
1. DÊ PREFERÊNCIA para categorias e subcategorias da lista fornecida acima
2. Se não encontrar uma categoria adequada, você PODE criar uma nova categoria mais específica
3. EVITE criar categorias muito similares às existentes
4. Use apenas NOMES de categorias e subcategorias (não IDs)

Para cada transação:
1. Melhore a descrição para ser clara e concisa EM PORTUGUÊS
2. Encontre a categoria EXISTENTE mais adequada da lista acima, OU
3. Crie uma nova categoria específica se necessário (evite duplicatas)
4. Forneça confiança de 0.0 a 1.0

IMPORTANTE - Sobre category_id e subcategory_id:
- Use apenas NOMES das categorias, não IDs
- Para category_id, use o nome da categoria (ex: "Alimentação")
- Para subcategory_id, use o nome da subcategoria ou null se não aplicar
- Se criar nova categoria, use nomes descritivos e específicos
- EVITE categorias genéricas demais (ex: "Outros", "Diversos")

Diretrizes para novas categorias:
- Seja específico: "Streaming de Vídeo" ao invés de "Entretenimento"
- Evite duplicatas: verifique se já existe categoria similar
- Use português brasileiro claro
- Mantenha consistência com categorias existentes

Regras para descrições melhoradas:
- Use português brasileiro
- Seja conciso e direto
- NÃO inclua palavras redundantes como "transação", "despesa", "gasto"
- NÃO inclua valores monetários 
- NÃO inclua códigos ou referências técnicas desnecessárias
- Foque no essencial: ONDE ou O QUE foi comprado

Exemplos de melhorias:
❌ Ruim: "Transação de compra no supermercado no valor de R$ 45,60"
✅ Bom: "Supermercado"

❌ Ruim: "Despesa com combustível posto de gasolina BR"
✅ Bom: "Combustível Posto BR"

❌ Ruim: "Pagamento de conta de energia elétrica residencial"
✅ Bom: "Energia elétrica"

❌ Ruim: "Compra de medicamento na farmácia Drogaria São Paulo"
✅ Bom: "Farmácia Drogaria São Paulo"

Exemplo de resposta correta:
{{
  "id": "transaction_123",
  "improved_description": "Supermercado Extra",
  "category_id": "Alimentação",
  "subcategory_id": "Supermercado",
  "confidence": 0.95,
  "reasoning": "Compra em supermercado"
}}

Processe TODAS as transações na mesma ordem da entrada."""
        self.prompt_cache = prompt
        try:
            self.response_cache = self.client.responses.parse(
                model=self.model,
                input=[
                    {
                        "role": "system",
                        "content": "Você é um assistente especializado em categorização financeira focado em despesas. Dê preferência para categorias existentes, mas pode criar novas quando necessário para melhor precisão. Evite categorias similares às existentes. Use apenas nomes de categorias (não IDs). Sempre responda com JSON estruturado válido contendo todas as transações solicitadas. Use descrições concisas em português brasileiro.",
                    },
                    {"role": "user", "content": prompt},
                ],
                text_format=BatchCategorizerResponse,
            )

            self.successful_requests += 1
            result = self.response_cache.output_parsed.model_dump()

            # Validate response structure
            if "transactions" not in result or not isinstance(
                result["transactions"], list
            ):
                logger.warning("Invalid batch response structure from OpenAI")
                return [
                    self._get_fallback_result(tx["description"], tx["id"])
                    for tx in transactions
                ]

            processed_results = []

            # Create lookup maps for existing categories and subcategories
            category_name_to_id = {
                cat["name"].lower(): str(cat["id"]) for cat in categories
            }
            subcategory_name_to_id = {}
            for cat_id, subcats in subcategories_by_category.items():
                for sub in subcats:
                    subcategory_name_to_id[sub["name"].lower()] = sub["id"]

            # Process each transaction result
            for i, tx_result in enumerate(result["transactions"]):
                if i >= len(transactions):  # Safety check
                    break

                original_tx = transactions[i]

                # Validate required fields
                required_fields = [
                    "id",
                    "improved_description",
                    "category_id",
                    "confidence",
                ]
                if not all(field in tx_result for field in required_fields):
                    logger.warning(
                        f"Missing fields in transaction {original_tx['id']} result"
                    )
                    processed_results.append(
                        self._get_fallback_result(
                            original_tx["description"], original_tx["id"]
                        )
                    )
                    continue

                # Process category_id (now working with names)
                if (
                    tx_result["category_id"]
                    and tx_result["category_id"] != "null"
                ):
                    category_name = tx_result["category_id"].strip()
                    category_name_lower = category_name.lower()

                    # Check if category already exists
                    if category_name_lower in category_name_to_id:
                        # Use existing category
                        tx_result["category_id"] = category_name_to_id[
                            category_name_lower
                        ]
                        logger.debug(
                            f"Using existing category '{category_name}' for transaction {tx_result['id']}"
                        )
                    else:
                        # Create new category
                        new_category_id = self.create_new_category(
                            conn, category_name, "expense"
                        )
                        if new_category_id:
                            tx_result["category_id"] = new_category_id
                            # Update lookup map for future transactions in this batch
                            category_name_to_id[category_name_lower] = (
                                new_category_id
                            )
                            # Add to categories list for subcategory creation
                            categories.append(
                                {"id": new_category_id, "name": category_name}
                            )
                            subcategories_by_category[new_category_id] = []
                            logger.info(
                                f"Created and using new category '{category_name}' for transaction {tx_result['id']}"
                            )
                        else:
                            logger.error(
                                f"Failed to create category '{category_name}' for transaction {tx_result['id']}"
                            )
                            tx_result["category_id"] = None
                else:
                    tx_result["category_id"] = None

                # Process subcategory_id (now working with names)
                if (
                    tx_result.get("subcategory_id")
                    and tx_result["subcategory_id"] != "null"
                    and tx_result["category_id"]
                ):
                    subcategory_name = tx_result["subcategory_id"].strip()
                    subcategory_name_lower = subcategory_name.lower()

                    # Check if subcategory already exists
                    if subcategory_name_lower in subcategory_name_to_id:
                        # Use existing subcategory
                        tx_result["subcategory_id"] = subcategory_name_to_id[
                            subcategory_name_lower
                        ]
                        logger.debug(
                            f"Using existing subcategory '{subcategory_name}' for transaction {tx_result['id']}"
                        )
                    else:
                        # Create new subcategory under the current category
                        new_subcategory_id = self.create_new_subcategory(
                            conn, subcategory_name, tx_result["category_id"]
                        )
                        if new_subcategory_id:
                            tx_result["subcategory_id"] = new_subcategory_id
                            # Update lookup map for future transactions in this batch
                            subcategory_name_to_id[subcategory_name_lower] = (
                                new_subcategory_id
                            )
                            # Add to subcategories list
                            if (
                                tx_result["category_id"]
                                in subcategories_by_category
                            ):
                                subcategories_by_category[
                                    tx_result["category_id"]
                                ].append(
                                    {
                                        "id": new_subcategory_id,
                                        "name": subcategory_name,
                                    }
                                )
                            logger.info(
                                f"Created and using new subcategory '{subcategory_name}' for transaction {tx_result['id']}"
                            )
                        else:
                            logger.error(
                                f"Failed to create subcategory '{subcategory_name}' for transaction {tx_result['id']}"
                            )
                            tx_result["subcategory_id"] = None
                else:
                    tx_result["subcategory_id"] = None

                # Ensure ID matches
                tx_result["id"] = original_tx["id"]
                processed_results.append(tx_result)

                # Count successful enhancements
                if tx_result["confidence"] > 0.7:
                    self.total_transactions_enhanced += 1

            # Fill missing results with fallbacks
            while len(processed_results) < len(transactions):
                missing_tx = transactions[len(processed_results)]
                processed_results.append(
                    self._get_fallback_result(
                        missing_tx["description"], missing_tx["id"]
                    )
                )

            self.total_transactions_processed += len(transactions)
            return processed_results

        except Exception as e:
            self.failed_requests += 1
            logger.error(f"OpenAI batch API error: {e}")
            # Return fallback results for all transactions
            return [
                self._get_fallback_result(tx["description"], tx["id"])
                for tx in transactions
            ]

    def _get_fallback_result(
        self, description: str, transaction_id: str = None
    ) -> Dict:
        """Return a fallback result when OpenAI fails"""
        result = {
            "improved_description": description,
            "category_id": None,
            "subcategory_id": None,
            "confidence": 0.0,
            "reasoning": "OpenAI processing failed, using original description",
        }
        if transaction_id:
            result["id"] = transaction_id
        return result

    def get_usage_stats(self) -> Dict:
        """Get comprehensive API usage statistics"""
        return {
            "total_requests": self.total_requests,
            "successful_requests": self.successful_requests,
            "failed_requests": self.failed_requests,
            "success_rate": (
                (self.successful_requests / self.total_requests * 100)
                if self.total_requests > 0
                else 0
            ),
            "current_rpm": self.rate_limiter.get_current_rate(),
            "total_transactions_processed": self.total_transactions_processed,
            "total_transactions_enhanced": self.total_transactions_enhanced,
            "enhancement_rate": (
                (
                    self.total_transactions_enhanced
                    / self.total_transactions_processed
                    * 100
                )
                if self.total_transactions_processed > 0
                else 0
            ),
            "avg_transactions_per_request": (
                (self.total_transactions_processed / self.total_requests)
                if self.total_requests > 0
                else 0
            ),
        }


class FintrackMigrator:
    """Main migration class with enhanced transaction processing"""

    def __init__(self, use_ai: bool = True):
        self.source_config = DatabaseConfig("SOURCE")
        self.target_config = DatabaseConfig("TARGET")
        self.source_conn = None
        self.target_conn = None
        self.ai_processor = None
        self.use_ai = use_ai  # Toggle para usar ou não a IA
        self.category_id_mapping = (
            {}
        )  # Mapeamento old_id -> {income_id, expense_id}
        self.subcategory_id_mapping = (
            {}
        )  # Mapeamento old_id -> {income_id, expense_id}

        # Set default database names if not provided
        if not os.getenv("SOURCE_DB_NAME"):
            self.source_config.database = "fintrack"
        if not os.getenv("TARGET_DB_NAME"):
            self.target_config.database = "phrspace"

        # Initialize OpenAI processor if credentials are available and AI is enabled
        if self.use_ai:
            try:
                self.ai_processor = OpenAITransactionProcessor(
                    openai_creds["api_key"], max_rpm=400, batch_size=25
                )
                logger.info(
                    "✓ OpenAI GPT-5 Nano processor initialized with 400 RPM rate limit and batch processing (25 transactions/request)"
                )
            except Exception as e:
                logger.warning(f"OpenAI processor initialization failed: {e}")
                self.ai_processor = None
        else:
            logger.info(
                "🔄 AI processing disabled - running migration without OpenAI enhancement"
            )
            self.ai_processor = None

    def connect_databases(self):
        """Establish connections to source and target databases"""
        try:
            logger.info("Connecting to source database...")
            self.source_conn = psycopg2.connect(
                self.source_config.get_connection_string(),
                cursor_factory=RealDictCursor,
            )
            self.source_conn.autocommit = False
            logger.info(
                f"✓ Connected to source: {self.source_config.database}"
            )

            logger.info("Connecting to target database...")
            self.target_conn = psycopg2.connect(
                self.target_config.get_connection_string(),
                cursor_factory=RealDictCursor,
            )
            self.target_conn.autocommit = False
            logger.info(
                f"✓ Connected to target: {self.target_config.database}"
            )

        except psycopg2.Error as e:
            logger.error(f"Database connection failed: {e}")
            raise

    def verify_source_schema(self) -> bool:
        """Verify source database has expected schema"""
        try:
            with self.source_conn.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT table_name 
                    FROM information_schema.tables 
                    WHERE table_schema = 'public' 
                    AND table_name IN ('users', 'accounts', 'categories', 'expenses', 'incomes')
                """
                )
                tables = [row["table_name"] for row in cursor.fetchall()]

                expected_tables = [
                    "users",
                    "accounts",
                    "categories",
                    "expenses",
                    "incomes",
                ]
                missing_tables = set(expected_tables) - set(tables)

                if missing_tables:
                    logger.error(
                        f"Missing tables in source database: {missing_tables}"
                    )
                    return False

                logger.info("✓ Source schema verification passed")
                return True

        except psycopg2.Error as e:
            logger.error(f"Source schema verification failed: {e}")
            return False

    def verify_target_schema(self) -> bool:
        """Verify target database has fintrack schema"""
        try:
            with self.target_conn.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT schema_name 
                    FROM information_schema.schemata 
                    WHERE schema_name = 'fintrack'
                """
                )

                if not cursor.fetchone():
                    logger.error(
                        "Target database missing 'fintrack' schema. Run DLL script first."
                    )
                    return False

                cursor.execute(
                    """
                    SELECT table_name 
                    FROM information_schema.tables 
                    WHERE table_schema = 'fintrack' 
                    AND table_name IN ('users', 'accounts', 'categories', 'currencies')
                """
                )
                tables = [row["table_name"] for row in cursor.fetchall()]

                expected_tables = [
                    "users",
                    "accounts",
                    "categories",
                    "currencies",
                ]
                missing_tables = set(expected_tables) - set(tables)

                if missing_tables:
                    logger.error(
                        f"Missing tables in target schema: {missing_tables}"
                    )
                    return False

                logger.info("✓ Target schema verification passed")
                return True

        except psycopg2.Error as e:
            logger.error(f"Target schema verification failed: {e}")
            return False

    def get_table_count(self, conn, schema: str, table: str) -> int:
        """Get record count for a table"""
        try:
            with conn.cursor() as cursor:
                cursor.execute(
                    f"SELECT COUNT(*) as count FROM {schema}.{table}"
                )
                return cursor.fetchone()["count"]
        except psycopg2.Error:
            return 0

    def analyze_category_usage(self):
        """Analyze category usage across income and expense tables to determine types"""
        logger.info("🔍 Analyzing category usage patterns...")

        category_usage = {}  # category_id -> {income: bool, expense: bool}
        subcategory_usage = (
            {}
        )  # subcategory_id -> {category_id: str, income: bool, expense: bool}

        with self.source_conn.cursor() as cursor:
            # Check categories used in incomes
            cursor.execute(
                """
                SELECT DISTINCT category_id, subcategory_id 
                FROM public.incomes 
                WHERE category_id IS NOT NULL
            """
            )
            for row in cursor.fetchall():
                cat_id = str(row["category_id"])
                subcat_id = (
                    str(row["subcategory_id"])
                    if row["subcategory_id"]
                    else None
                )

                if cat_id not in category_usage:
                    category_usage[cat_id] = {
                        "income": False,
                        "expense": False,
                    }
                category_usage[cat_id]["income"] = True

                if subcat_id:
                    if subcat_id not in subcategory_usage:
                        subcategory_usage[subcat_id] = {
                            "category_id": cat_id,
                            "income": False,
                            "expense": False,
                        }
                    subcategory_usage[subcat_id]["income"] = True

            # Check categories used in expenses
            cursor.execute(
                """
                SELECT DISTINCT category_id, subcategory_id 
                FROM public.expenses 
                WHERE category_id IS NOT NULL
            """
            )
            for row in cursor.fetchall():
                cat_id = str(row["category_id"])
                subcat_id = (
                    str(row["subcategory_id"])
                    if row["subcategory_id"]
                    else None
                )

                if cat_id not in category_usage:
                    category_usage[cat_id] = {
                        "income": False,
                        "expense": False,
                    }
                category_usage[cat_id]["expense"] = True

                if subcat_id:
                    if subcat_id not in subcategory_usage:
                        subcategory_usage[subcat_id] = {
                            "category_id": cat_id,
                            "income": False,
                            "expense": False,
                        }
                    subcategory_usage[subcat_id]["expense"] = True

            # Check categories used in card_expenses (via invoices)
            cursor.execute(
                """
                SELECT DISTINCT ce.category_id, ce.subcategory_id
                FROM public.card_expenses ce
                JOIN public.invoices i ON ce.invoice_id = i.id
                WHERE ce.category_id IS NOT NULL
            """
            )
            for row in cursor.fetchall():
                cat_id = str(row["category_id"])
                subcat_id = (
                    str(row["subcategory_id"])
                    if row["subcategory_id"]
                    else None
                )

                if cat_id not in category_usage:
                    category_usage[cat_id] = {
                        "income": False,
                        "expense": False,
                    }
                category_usage[cat_id]["expense"] = True

                if subcat_id:
                    if subcat_id not in subcategory_usage:
                        subcategory_usage[subcat_id] = {
                            "category_id": cat_id,
                            "income": False,
                            "expense": False,
                        }
                    subcategory_usage[subcat_id]["expense"] = True

        # Verify integrity: check if all subcategory parent categories are covered
        with self.source_conn.cursor() as cursor:
            cursor.execute(
                "SELECT DISTINCT category_id FROM public.sub_categories"
            )
            subcategory_parents = [
                str(row["category_id"]) for row in cursor.fetchall()
            ]

            missing_parents = set(subcategory_parents) - set(
                category_usage.keys()
            )
            if missing_parents:
                logger.warning(
                    f"⚠️  Found {len(missing_parents)} categories referenced by subcategories but not used in transactions:"
                )
                for parent_id in missing_parents:
                    cursor.execute(
                        "SELECT name FROM public.categories WHERE id = %s",
                        (parent_id,),
                    )
                    parent_name = cursor.fetchone()
                    if parent_name:
                        logger.warning(
                            f"    - {parent_name['name']} (ID: {parent_id})"
                        )
                        # Add them as expense categories by default since subcategories exist
                        category_usage[parent_id] = {
                            "income": False,
                            "expense": True,
                        }

        # Log analysis results
        income_only = sum(
            1
            for usage in category_usage.values()
            if usage["income"] and not usage["expense"]
        )
        expense_only = sum(
            1
            for usage in category_usage.values()
            if not usage["income"] and usage["expense"]
        )
        both_types = sum(
            1
            for usage in category_usage.values()
            if usage["income"] and usage["expense"]
        )

        logger.info(f"✓ Category analysis complete:")
        logger.info(f"  - Income only: {income_only} categories")
        logger.info(f"  - Expense only: {expense_only} categories")
        logger.info(
            f"  - Used in both: {both_types} categories (will be duplicated)"
        )
        logger.info(f"  - Subcategories analyzed: {len(subcategory_usage)}")

        return category_usage, subcategory_usage

    def migrate_lookup_tables(self):
        """Migrate lookup tables (users, categories, tags, etc.) with proper type separation"""
        logger.info("🔄 Migrating lookup tables...")

        try:
            # Analyze category usage first
            category_usage, subcategory_usage = self.analyze_category_usage()

            # Migrate users
            logger.info("Migrating users...")
            with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                src_cursor.execute("SELECT * FROM public.users")
                users = src_cursor.fetchall()

                if users:
                    tgt_cursor.executemany(
                        """
                        INSERT INTO fintrack.users (id, name, username, email, is_active, created_at, updated_at)
                        VALUES (%(id)s, %(name)s, %(username)s, %(email)s, %(is_active)s, %(created_at)s, %(updated_at)s)
                        ON CONFLICT (id) DO NOTHING
                    """,
                        users,
                    )
                    logger.info(f"✓ Migrated {len(users)} users")

            # Migrate categories with type separation
            logger.info("Migrating categories with type separation...")
            self._migrate_categories_with_types(category_usage)

            # Commit categories before migrating subcategories
            self.target_conn.commit()
            logger.debug("✓ Categories committed to database")

            # Migrate sub_categories with type separation
            logger.info("Migrating sub_categories with type separation...")
            self._migrate_subcategories_with_types(subcategory_usage)

            # Migrate tags
            logger.info("Migrating tags...")
            with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                src_cursor.execute("SELECT * FROM public.tags")
                tags = src_cursor.fetchall()

                if tags:
                    for tag in tags:
                        # Validate color format (optional for tags)
                        color = tag["color"]
                        if color and not (
                            len(color) == 7 and color.startswith("#")
                        ):
                            color = None

                        tgt_cursor.execute(
                            """
                            INSERT INTO fintrack.tags (id, name, color, is_active, created_at, updated_at)
                            VALUES (%s, %s, %s, %s, %s, %s)
                            ON CONFLICT (id) DO NOTHING
                        """,
                            (
                                tag["id"],
                                tag["name"],
                                color,
                                True,
                                tag["created_at"],
                                tag["updated_at"],
                            ),
                        )

                    logger.info(f"✓ Migrated {len(tags)} tags")

            self.target_conn.commit()
            logger.info("✅ Lookup tables migration completed")

        except psycopg2.Error as e:
            self.target_conn.rollback()
            logger.error(f"Lookup tables migration failed: {e}")
            raise

    def _migrate_categories_with_types(self, category_usage):
        """Migrate categories creating separate records for income and expense types"""

        with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
            src_cursor.execute("SELECT * FROM public.categories")
            categories = src_cursor.fetchall()

            categories_created = 0
            categories_skipped = 0

            for cat in categories:
                cat_id = str(cat["id"])
                usage = category_usage.get(
                    cat_id, {"income": False, "expense": False}
                )

                # Skip categories that are not used
                if not usage["income"] and not usage["expense"]:
                    logger.debug(
                        f"Skipping unused category '{cat['name']}' (ID: {cat_id})"
                    )
                    categories_skipped += 1
                    continue

                # Validate color format
                color = cat["color"]
                if not (color and len(color) == 7 and color.startswith("#")):
                    color = "#000000"

                # Create income version if used in incomes
                if usage["income"]:
                    income_id = str(uuid.uuid4())
                    tgt_cursor.execute(
                        """
                        INSERT INTO fintrack.categories (id, name, type, color, icon, is_active, created_at, updated_at)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                        ON CONFLICT (name, type) DO UPDATE SET updated_at = EXCLUDED.updated_at
                        RETURNING id
                    """,
                        (
                            income_id,
                            cat["name"],
                            "income",
                            color,
                            cat["icon"],
                            True,
                            cat["created_at"],
                            cat["updated_at"],
                        ),
                    )

                    # Get the actual ID returned (in case of conflict)
                    result = tgt_cursor.fetchone()
                    actual_income_id = (
                        str(result["id"]) if result else income_id
                    )

                    # Store mapping
                    if cat_id not in self.category_id_mapping:
                        self.category_id_mapping[cat_id] = {}
                    self.category_id_mapping[cat_id][
                        "income"
                    ] = actual_income_id
                    categories_created += 1
                    logger.debug(
                        f"Created income category '{cat['name']}' (ID: {actual_income_id}) for original {cat_id}"
                    )

                # Create expense version if used in expenses or card_expenses
                if usage["expense"]:
                    expense_id = str(uuid.uuid4())
                    tgt_cursor.execute(
                        """
                        INSERT INTO fintrack.categories (id, name, type, color, icon, is_active, created_at, updated_at)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                        ON CONFLICT (name, type) DO UPDATE SET updated_at = EXCLUDED.updated_at
                        RETURNING id
                    """,
                        (
                            expense_id,
                            cat["name"],
                            "expense",
                            color,
                            cat["icon"],
                            True,
                            cat["created_at"],
                            cat["updated_at"],
                        ),
                    )

                    # Get the actual ID returned (in case of conflict)
                    result = tgt_cursor.fetchone()
                    actual_expense_id = (
                        str(result["id"]) if result else expense_id
                    )

                    # Store mapping
                    if cat_id not in self.category_id_mapping:
                        self.category_id_mapping[cat_id] = {}
                    self.category_id_mapping[cat_id][
                        "expense"
                    ] = actual_expense_id
                    categories_created += 1
                    logger.debug(
                        f"Created expense category '{cat['name']}' (ID: {actual_expense_id}) for original {cat_id}"
                    )

        logger.info(
            f"✓ Created {categories_created} typed category records ({categories_skipped} unused categories skipped)"
        )

    def _migrate_subcategories_with_types(self, subcategory_usage):
        """Migrate subcategories creating separate records for each category type"""

        with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
            src_cursor.execute("SELECT * FROM public.sub_categories")
            subcategories = src_cursor.fetchall()

            subcategories_created = 0
            orphaned_subcategories = 0

            for subcat in subcategories:
                subcat_id = str(subcat["id"])
                original_cat_id = str(subcat["category_id"])

                # Check if parent category exists in mapping
                if original_cat_id not in self.category_id_mapping:
                    logger.warning(
                        f"Orphaned subcategory '{subcat['name']}' (ID: {subcat_id}) - parent category {original_cat_id} not found in mapping"
                    )
                    orphaned_subcategories += 1
                    continue

                # Get usage info for this subcategory
                usage = subcategory_usage.get(
                    subcat_id, {"income": False, "expense": False}
                )

                # Create income version if used with income transactions
                if (
                    usage["income"]
                    and "income" in self.category_id_mapping[original_cat_id]
                ):
                    income_subcat_id = str(uuid.uuid4())
                    new_category_id = self.category_id_mapping[
                        original_cat_id
                    ]["income"]

                    # Verify that the target category exists
                    tgt_cursor.execute(
                        "SELECT id FROM fintrack.categories WHERE id = %s",
                        (new_category_id,),
                    )
                    if not tgt_cursor.fetchone():
                        logger.error(
                            f"Target income category {new_category_id} does not exist for subcategory '{subcat['name']}'"
                        )
                        continue

                    tgt_cursor.execute(
                        """
                        INSERT INTO fintrack.sub_categories (id, name, category_id, is_active, created_at, updated_at)
                        VALUES (%s, %s, %s, %s, %s, %s)
                        ON CONFLICT (name, category_id) DO UPDATE SET updated_at = EXCLUDED.updated_at
                        RETURNING id
                    """,
                        (
                            income_subcat_id,
                            subcat["name"],
                            new_category_id,
                            True,
                            subcat["created_at"],
                            subcat["updated_at"],
                        ),
                    )

                    # Get the actual ID returned (in case of conflict)
                    result = tgt_cursor.fetchone()
                    actual_income_subcat_id = (
                        str(result["id"]) if result else income_subcat_id
                    )

                    # Store mapping
                    if subcat_id not in self.subcategory_id_mapping:
                        self.subcategory_id_mapping[subcat_id] = {}
                    self.subcategory_id_mapping[subcat_id][
                        "income"
                    ] = actual_income_subcat_id
                    subcategories_created += 1

                # Create expense version if used with expense transactions
                if (
                    usage["expense"]
                    and "expense" in self.category_id_mapping[original_cat_id]
                ):
                    expense_subcat_id = str(uuid.uuid4())
                    new_category_id = self.category_id_mapping[
                        original_cat_id
                    ]["expense"]

                    # Verify that the target category exists
                    tgt_cursor.execute(
                        "SELECT id FROM fintrack.categories WHERE id = %s",
                        (new_category_id,),
                    )
                    if not tgt_cursor.fetchone():
                        logger.error(
                            f"Target expense category {new_category_id} does not exist for subcategory '{subcat['name']}'"
                        )
                        continue

                    tgt_cursor.execute(
                        """
                        INSERT INTO fintrack.sub_categories (id, name, category_id, is_active, created_at, updated_at)
                        VALUES (%s, %s, %s, %s, %s, %s)
                        ON CONFLICT (name, category_id) DO UPDATE SET updated_at = EXCLUDED.updated_at
                        RETURNING id
                    """,
                        (
                            expense_subcat_id,
                            subcat["name"],
                            new_category_id,
                            True,
                            subcat["created_at"],
                            subcat["updated_at"],
                        ),
                    )

                    # Get the actual ID returned (in case of conflict)
                    result = tgt_cursor.fetchone()
                    actual_expense_subcat_id = (
                        str(result["id"]) if result else expense_subcat_id
                    )

                    # Store mapping
                    if subcat_id not in self.subcategory_id_mapping:
                        self.subcategory_id_mapping[subcat_id] = {}
                    self.subcategory_id_mapping[subcat_id][
                        "expense"
                    ] = actual_expense_subcat_id
                    subcategories_created += 1

        if orphaned_subcategories > 0:
            logger.warning(
                f"⚠️  Found {orphaned_subcategories} orphaned subcategories (parent categories not migrated)"
            )
        logger.info(
            f"✓ Created {subcategories_created} typed subcategory records"
        )

    def migrate_currencies_and_accounts(self):
        """Migrate currencies and accounts with currency conversion"""
        logger.info("🔄 Migrating currencies and accounts...")

        try:
            # Insert currencies (they should already exist from DLL)
            logger.info("Ensuring currencies exist...")
            with self.target_conn.cursor() as cursor:
                cursor.execute(
                    """
                    INSERT INTO fintrack.currencies (code, name, symbol, is_active, created_at, updated_at)
                    VALUES 
                        ('BRL', 'Real Brasileiro', 'R$', true, now(), now()),
                        ('USD', 'US Dollar', '$', true, now(), now()),
                        ('EUR', 'Euro', '€', true, now(), now())
                    ON CONFLICT (code) DO NOTHING
                """
                )

            # Migrate accounts
            logger.info("Migrating accounts...")
            with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                src_cursor.execute("SELECT * FROM public.accounts")
                accounts = src_cursor.fetchall()

                if accounts:
                    for account in accounts:
                        # Convert enum currency to string
                        currency_code = (
                            str(account["currency"])
                            if account["currency"]
                            else "BRL"
                        )

                        tgt_cursor.execute(
                            """
                            INSERT INTO fintrack.accounts (id, user_id, name, type, initial_balance, currency_code, is_active, deleted_at, created_at, updated_at)
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                            ON CONFLICT (id) DO NOTHING
                        """,
                            (
                                account["id"],
                                account["user_id"],
                                account["name"],
                                account["type"],
                                account["initial_balance"],
                                currency_code,
                                account["is_active"],
                                None,
                                account["created_at"],
                                account["updated_at"],
                            ),
                        )

                    logger.info(f"✓ Migrated {len(accounts)} accounts")

            self.target_conn.commit()
            logger.info("✅ Currencies and accounts migration completed")

        except psycopg2.Error as e:
            self.target_conn.rollback()
            logger.error(f"Currencies and accounts migration failed: {e}")
            raise

    def migrate_cards_and_invoices(self):
        """Migrate cards and invoices with new structure"""
        logger.info("🔄 Migrating cards and invoices...")

        try:
            # Migrate cards
            logger.info("Migrating cards...")
            with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                src_cursor.execute("SELECT * FROM public.cards")
                cards = src_cursor.fetchall()

                if cards:
                    for card in cards:
                        tgt_cursor.execute(
                            """
                            INSERT INTO fintrack.cards (id, name, credit_limit, account_id, closing_date, due_date, is_active, deleted_at, created_at, updated_at)
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                            ON CONFLICT (id) DO NOTHING
                        """,
                            (
                                card["id"],
                                card["name"],
                                card["credit_limit"],
                                card["account_id"],
                                card["closing_date"],
                                card["due_date"],
                                card["is_active"],
                                None,
                                card["created_at"],
                                card["updated_at"],
                            ),
                        )

                    logger.info(f"✓ Migrated {len(cards)} cards")

            # Migrate invoices with new structure
            logger.info("Migrating invoices...")
            with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                src_cursor.execute(
                    """
                    SELECT DISTINCT card_id, billing_month, status, created_at, updated_at
                    FROM public.invoices
                """
                )
                invoices = src_cursor.fetchall()

                if invoices:
                    for invoice in invoices:
                        # Convert DATE to VARCHAR(7)
                        billing_month = invoice["billing_month"].strftime(
                            "%Y-%m"
                        )

                        tgt_cursor.execute(
                            """
                            INSERT INTO fintrack.invoices (card_id, billing_month, status, created_at, updated_at)
                            VALUES (%s, %s, %s, %s, %s)
                            ON CONFLICT (card_id, billing_month) DO NOTHING
                        """,
                            (
                                invoice["card_id"],
                                billing_month,
                                invoice["status"],
                                invoice["created_at"],
                                invoice["updated_at"],
                            ),
                        )

                    logger.info(f"✓ Migrated {len(invoices)} invoices")

            self.target_conn.commit()
            logger.info("✅ Cards and invoices migration completed")

        except psycopg2.Error as e:
            self.target_conn.rollback()
            logger.error(f"Cards and invoices migration failed: {e}")
            raise

    def migrate_transactions_with_ai_enhancement(self):
        """Migrate transaction tables with OpenAI-enhanced descriptions and categorization"""
        logger.info("🔄 Migrating transaction tables with AI enhancement...")

        try:
            # Get categories and subcategories for AI processing
            categories = None
            subcategories_by_category = None
            if self.ai_processor:
                categories, subcategories_by_category = (
                    self.ai_processor.get_categories_and_subcategories(
                        self.target_conn
                    )
                )
                logger.info(
                    f"✓ Loaded {len(categories)} categories and subcategories for AI processing"
                )

            # Migrate transfers (no AI enhancement needed for transfers)
            self._migrate_transfers()

            # Migrate incomes without AI enhancement (per user request - AI only for expenses)
            self._migrate_incomes_simple()

            # Migrate expenses with AI enhancement in batches
            self._migrate_expenses_with_ai_batch(
                categories, subcategories_by_category
            )

            self.target_conn.commit()
            logger.info(
                "✅ Transaction tables migration with AI enhancement completed"
            )

        except psycopg2.Error as e:
            self.target_conn.rollback()
            logger.error(f"Transaction tables migration failed: {e}")
            raise

    def _migrate_transfers(self):
        """Migrate transfers without AI enhancement"""
        logger.info("Migrating transfers...")
        with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
            src_cursor.execute("SELECT * FROM public.transfers")
            transfers = src_cursor.fetchall()

            if transfers:
                for transfer in transfers:
                    status = (
                        "validating"
                        if transfer["transaction_status"] == "pending"
                        else transfer["transaction_status"]
                    )

                    tgt_cursor.execute(
                        """
                        INSERT INTO fintrack.transfers (id, recurring_transfer_id, transaction_date, amount, source_account_id, destination_account_id, transaction_status, description, deleted_at, created_at, updated_at)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                        ON CONFLICT (id) DO NOTHING
                    """,
                        (
                            transfer["id"],
                            transfer["recurring_transfer_id"],
                            transfer["transaction_date"],
                            transfer["amount"],
                            transfer["source_account_id"],
                            transfer["destination_account_id"],
                            status,
                            None,
                            None,
                            transfer["created_at"],
                            transfer["updated_at"],
                        ),
                    )

                logger.info(f"✓ Migrated {len(transfers)} transfers")

    def _migrate_incomes_simple(self):
        """Migrate incomes without AI enhancement (simple migration)"""
        logger.info("Migrating incomes (no AI enhancement)...")
        with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
            src_cursor.execute("SELECT * FROM public.incomes")
            incomes = src_cursor.fetchall()

            if incomes:
                for income in incomes:
                    status = (
                        "validating"
                        if income["transaction_status"] == "pending"
                        else income["transaction_status"]
                    )

                    # Map to income categories
                    original_cat_id = (
                        str(income["category_id"])
                        if income["category_id"]
                        else None
                    )
                    original_subcat_id = (
                        str(income["subcategory_id"])
                        if income["subcategory_id"]
                        else None
                    )

                    # Use mapped categories
                    category_id = None
                    subcategory_id = None

                    # Map to income category
                    if (
                        original_cat_id
                        and original_cat_id in self.category_id_mapping
                        and "income"
                        in self.category_id_mapping[original_cat_id]
                    ):
                        category_id = self.category_id_mapping[
                            original_cat_id
                        ]["income"]

                        # Map subcategory if exists
                        if (
                            original_subcat_id
                            and original_subcat_id
                            in self.subcategory_id_mapping
                            and "income"
                            in self.subcategory_id_mapping[original_subcat_id]
                        ):
                            subcategory_id = self.subcategory_id_mapping[
                                original_subcat_id
                            ]["income"]
                        elif original_subcat_id:
                            pass
                    else:
                        if original_cat_id:
                            pass

                    tgt_cursor.execute(
                        """
                        INSERT INTO fintrack.incomes (id, transaction_date, description, amount, account_id, category_id, subcategory_id, recurring_income_id, transaction_status, deleted_at, created_at, updated_at)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                        ON CONFLICT (id) DO NOTHING
                    """,
                        (
                            income["id"],
                            income["transaction_date"],
                            income["description"],
                            income["amount"],
                            income["account_id"],
                            category_id,
                            subcategory_id,
                            income.get("recurring_transaction_id"),
                            status,
                            None,
                            income["created_at"],
                            income["updated_at"],
                        ),
                    )

                logger.info(
                    f"✓ Migrated {len(incomes)} incomes (no AI processing)"
                )

    def _migrate_expenses_with_ai_batch(
        self, categories, subcategories_by_category
    ):
        """Migrate expenses with AI-enhanced descriptions and categorization using batch processing"""
        logger.info("Migrating expenses with AI batch enhancement...")
        with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
            src_cursor.execute("SELECT * FROM public.expenses")
            expenses = src_cursor.fetchall()

            if expenses:
                total_enhanced = 0

                # Process expenses in batches
                for i in range(
                    0,
                    len(expenses),
                    self.ai_processor.batch_size if self.ai_processor else 1,
                ):
                    batch = expenses[
                        i : i
                        + (
                            self.ai_processor.batch_size
                            if self.ai_processor
                            else 1
                        )
                    ]

                    # Prepare batch for AI processing if available
                    ai_results = {}
                    if self.ai_processor and categories:
                        try:
                            # Prepare batch data for AI
                            batch_transactions = [
                                {
                                    "id": exp["id"],
                                    "description": exp["description"],
                                    "amount": float(exp["amount"]),
                                }
                                for exp in batch
                                if exp["description"]
                            ]

                            if batch_transactions:
                                ai_batch_results = self.ai_processor.improve_and_categorize_transactions_batch(
                                    batch_transactions,
                                    categories,
                                    subcategories_by_category,
                                    self.target_conn,
                                )

                                # Index results by transaction ID
                                for result in ai_batch_results:
                                    if result["confidence"] > 0.7:
                                        ai_results[result["id"]] = result
                                        total_enhanced += 1

                        except Exception as e:
                            logger.warning(
                                f"AI batch processing failed for expenses batch {i//self.ai_processor.batch_size}: {e}"
                            )

                    # Insert batch into database
                    for expense in batch:
                        status = (
                            "validating"
                            if expense["transaction_status"] == "pending"
                            else expense["transaction_status"]
                        )

                        # Map to expense categories first
                        original_cat_id = (
                            str(expense["category_id"])
                            if expense["category_id"]
                            else None
                        )
                        original_subcat_id = (
                            str(expense["subcategory_id"])
                            if expense["subcategory_id"]
                            else None
                        )

                        # Use mapped categories
                        description = expense["description"]
                        category_id = None
                        subcategory_id = None

                        # Map to expense category
                        if (
                            original_cat_id
                            and original_cat_id in self.category_id_mapping
                            and "expense"
                            in self.category_id_mapping[original_cat_id]
                        ):
                            category_id = self.category_id_mapping[
                                original_cat_id
                            ]["expense"]

                            # Map subcategory if exists
                            if (
                                original_subcat_id
                                and original_subcat_id
                                in self.subcategory_id_mapping
                                and "expense"
                                in self.subcategory_id_mapping[
                                    original_subcat_id
                                ]
                            ):
                                subcategory_id = self.subcategory_id_mapping[
                                    original_subcat_id
                                ]["expense"]

                        # Apply AI enhancement to description only
                        if expense["id"] in ai_results:
                            ai_result = ai_results[expense["id"]]
                            description = ai_result["improved_description"]
                            # Note: AI category suggestions are ignored as we use mapped categories

                        tgt_cursor.execute(
                            """
                            INSERT INTO fintrack.expenses (id, transaction_date, description, amount, account_id, category_id, subcategory_id, recurring_expense_id, transaction_status, deleted_at, created_at, updated_at)
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                            ON CONFLICT (id) DO NOTHING
                        """,
                            (
                                expense["id"],
                                expense["transaction_date"],
                                description,
                                expense["amount"],
                                expense["account_id"],
                                category_id,
                                subcategory_id,
                                expense.get("recurring_transaction_id"),
                                status,
                                None,
                                expense["created_at"],
                                expense["updated_at"],
                            ),
                        )

                logger.info(
                    f"✓ Migrated {len(expenses)} expenses ({total_enhanced} AI-enhanced)"
                )

                # Log AI usage stats for expenses
                if self.ai_processor and total_enhanced > 0:
                    stats = self.ai_processor.get_usage_stats()
                    logger.info(
                        f"AI Batch Stats - Requests: {stats['total_requests']} | Transactions: {stats['total_transactions_processed']} | Enhanced: {stats['total_transactions_enhanced']} ({stats['enhancement_rate']:.1f}%) | Avg per request: {stats['avg_transactions_per_request']:.1f}"
                    )

    def migrate_card_transactions_with_ai_enhancement(self):
        """Migrate card transaction tables with AI-enhanced descriptions and categorization"""
        logger.info(
            "🔄 Migrating card transaction tables with AI enhancement..."
        )

        try:
            # Check if card_expenses table exists in source
            with self.source_conn.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT EXISTS (
                        SELECT FROM information_schema.tables 
                        WHERE table_schema = 'public' 
                        AND table_name = 'card_expenses'
                    )
                """
                )
                result = cursor.fetchone()
                table_exists = (
                    result[0]
                    if isinstance(result, (list, tuple))
                    else result["exists"]
                )

                if not table_exists:
                    logger.info(
                        "⚠️  card_expenses table not found in source, skipping card transactions"
                    )
                    return

            # Get categories and subcategories for AI processing
            categories = None
            subcategories_by_category = None
            if self.ai_processor:
                categories, subcategories_by_category = (
                    self.ai_processor.get_categories_and_subcategories(
                        self.target_conn
                    )
                )

            # Migrate card_expenses with AI batch enhancement
            self._migrate_card_expenses_with_ai_batch(
                categories, subcategories_by_category
            )

            # Migrate card_chargebacks and card_payments (no AI needed for these)
            self._migrate_card_chargebacks()
            self._migrate_card_payments()

            self.target_conn.commit()
            logger.info(
                "✅ Card transaction tables migration with AI enhancement completed"
            )

        except psycopg2.Error as e:
            self.target_conn.rollback()
            logger.error(f"Card transaction tables migration failed: {e}")
            raise

    def _migrate_card_expenses_with_ai_batch(
        self, categories, subcategories_by_category
    ):
        """Migrate card expenses with AI batch enhancement"""
        logger.info("Migrating card_expenses with AI batch enhancement...")
        with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
            src_cursor.execute(
                """
                SELECT ce.*, i.card_id, i.billing_month
                FROM public.card_expenses ce
                JOIN public.invoices i ON ce.invoice_id = i.id
            """
            )
            card_expenses = src_cursor.fetchall()

            if card_expenses:
                total_enhanced = 0

                # Process card expenses in batches
                for i in range(
                    0,
                    len(card_expenses),
                    self.ai_processor.batch_size if self.ai_processor else 1,
                ):
                    batch = card_expenses[
                        i : i
                        + (
                            self.ai_processor.batch_size
                            if self.ai_processor
                            else 1
                        )
                    ]

                    # Prepare batch for AI processing if available
                    ai_results = {}
                    if self.ai_processor and categories:
                        try:
                            # Prepare batch data for AI
                            batch_transactions = [
                                {
                                    "id": exp["id"],
                                    "description": exp["description"],
                                    "amount": float(exp["amount"]),
                                }
                                for exp in batch
                                if exp["description"]
                            ]

                            if batch_transactions:
                                ai_batch_results = self.ai_processor.improve_and_categorize_transactions_batch(
                                    batch_transactions,
                                    categories,
                                    subcategories_by_category,
                                    self.target_conn,
                                )

                                # Index results by transaction ID
                                for result in ai_batch_results:
                                    if result["confidence"] > 0.7:
                                        ai_results[result["id"]] = result
                                        total_enhanced += 1

                        except Exception as e:
                            logger.warning(
                                f"AI batch processing failed for card expenses batch {i//self.ai_processor.batch_size}: {e}"
                            )

                    # Insert batch into database
                    for expense in batch:
                        billing_month = expense["billing_month"].strftime(
                            "%Y-%m"
                        )

                        # Map to expense categories first
                        original_cat_id = (
                            str(expense["category_id"])
                            if expense["category_id"]
                            else None
                        )
                        original_subcat_id = (
                            str(expense["subcategory_id"])
                            if expense["subcategory_id"]
                            else None
                        )

                        # Use mapped categories
                        description = expense["description"]
                        category_id = None
                        subcategory_id = None

                        # Map to expense category
                        if (
                            original_cat_id
                            and original_cat_id in self.category_id_mapping
                            and "expense"
                            in self.category_id_mapping[original_cat_id]
                        ):
                            category_id = self.category_id_mapping[
                                original_cat_id
                            ]["expense"]

                            # Map subcategory if exists
                            if (
                                original_subcat_id
                                and original_subcat_id
                                in self.subcategory_id_mapping
                                and "expense"
                                in self.subcategory_id_mapping[
                                    original_subcat_id
                                ]
                            ):
                                subcategory_id = self.subcategory_id_mapping[
                                    original_subcat_id
                                ]["expense"]

                        # Apply AI enhancement to description only
                        if expense["id"] in ai_results:
                            ai_result = ai_results[expense["id"]]
                            description = ai_result["improved_description"]
                            # Note: AI category suggestions are ignored as we use mapped categories

                        tgt_cursor.execute(
                            """
                            INSERT INTO fintrack.card_expenses (id, transaction_date, description, amount, subcategory_id, category_id, card_id, billing_month, recurring_card_transaction_id, transaction_status, deleted_at, created_at, updated_at)
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                            ON CONFLICT (id) DO NOTHING
                        """,
                            (
                                expense["id"],
                                expense["transaction_date"],
                                description,
                                expense["amount"],
                                subcategory_id,
                                category_id,
                                expense["card_id"],
                                billing_month,
                                None,
                                "validating",
                                None,
                                expense["created_at"],
                                expense["updated_at"],
                            ),
                        )

                logger.info(
                    f"✓ Migrated {len(card_expenses)} card_expenses ({total_enhanced} AI-enhanced)"
                )

                # Log AI usage stats for card expenses
                if self.ai_processor and total_enhanced > 0:
                    stats = self.ai_processor.get_usage_stats()
                    logger.info(
                        f"AI Batch Stats - Requests: {stats['total_requests']} | Transactions: {stats['total_transactions_processed']} | Enhanced: {stats['total_transactions_enhanced']} ({stats['enhancement_rate']:.1f}%) | Avg per request: {stats['avg_transactions_per_request']:.1f}"
                    )

    def migrate_recurring_tables(self):
        """Skip recurring tables migration - no data in source database"""
        logger.info(
            "🔄 Skipping recurring tables (no data in source database)..."
        )
        logger.info("⏭️  Skipping recurring_transfers (no data)")
        logger.info("⏭️  Skipping recurring_incomes (no data)")
        logger.info("⏭️  Skipping recurring_expenses (no data)")
        logger.info("⏭️  Skipping recurring_card_transactions (no data)")
        logger.info("✅ Recurring tables migration completed (skipped)")
        return

        try:
            # Migrate recurring_transfers
            logger.info("Migrating recurring_transfers...")
            with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                src_cursor.execute("SELECT * FROM public.recurring_transfers")
                recurring_transfers = src_cursor.fetchall()

                if recurring_transfers:
                    for rt in recurring_transfers:
                        tgt_cursor.execute(
                            """
                            INSERT INTO fintrack.recurring_transfers (id, amount, source_account_id, destination_account_id, frequency, start_date, end_date, is_active, created_at, updated_at)
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                            ON CONFLICT (id) DO NOTHING
                        """,
                            (
                                rt["id"],
                                rt["amount"],
                                rt["source_account_id"],
                                rt["destination_account_id"],
                                rt["frequency"],
                                rt["start_date"],
                                rt["end_date"],
                                True,
                                rt["created_at"],
                                rt["updated_at"],
                            ),
                        )

                    logger.info(
                        f"✓ Migrated {len(recurring_transfers)} recurring_transfers"
                    )

            # Migrate recurring_transactions
            logger.info("Migrating recurring_transactions...")
            with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                src_cursor.execute(
                    "SELECT * FROM public.recurring_transactions"
                )
                recurring_transactions = src_cursor.fetchall()

                if recurring_transactions:
                    for rt in recurring_transactions:
                        # Map to appropriate categories (could be income or expense)
                        original_cat_id = (
                            str(rt["category_id"])
                            if rt["category_id"]
                            else None
                        )
                        original_subcat_id = (
                            str(rt["subcategory_id"])
                            if rt["subcategory_id"]
                            else None
                        )

                        # Use mapped categories - prefer expense, fallback to income
                        category_id = None
                        subcategory_id = None

                        if (
                            original_cat_id
                            and original_cat_id in self.category_id_mapping
                        ):
                            # Try expense first (most recurring transactions are expenses)
                            if (
                                "expense"
                                in self.category_id_mapping[original_cat_id]
                            ):
                                category_id = self.category_id_mapping[
                                    original_cat_id
                                ]["expense"]
                                if (
                                    original_subcat_id
                                    and original_subcat_id
                                    in self.subcategory_id_mapping
                                    and "expense"
                                    in self.subcategory_id_mapping[
                                        original_subcat_id
                                    ]
                                ):
                                    subcategory_id = (
                                        self.subcategory_id_mapping[
                                            original_subcat_id
                                        ]["expense"]
                                    )
                            # Fallback to income
                            elif (
                                "income"
                                in self.category_id_mapping[original_cat_id]
                            ):
                                category_id = self.category_id_mapping[
                                    original_cat_id
                                ]["income"]
                                if (
                                    original_subcat_id
                                    and original_subcat_id
                                    in self.subcategory_id_mapping
                                    and "income"
                                    in self.subcategory_id_mapping[
                                        original_subcat_id
                                    ]
                                ):
                                    subcategory_id = (
                                        self.subcategory_id_mapping[
                                            original_subcat_id
                                        ]["income"]
                                    )

                        tgt_cursor.execute(
                            """
                            INSERT INTO fintrack.recurring_transactions (id, amount, description, frequency, start_date, end_date, account_id, category_id, subcategory_id, is_active, created_at, updated_at)
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                            ON CONFLICT (id) DO NOTHING
                        """,
                            (
                                rt["id"],
                                rt["amount"],
                                rt["description"],
                                rt["frequency"],
                                rt["start_date"],
                                rt["end_date"],
                                rt["account_id"],
                                category_id,
                                subcategory_id,
                                True,
                                rt["created_at"],
                                rt["updated_at"],
                            ),
                        )

                    logger.info(
                        f"✓ Migrated {len(recurring_transactions)} recurring_transactions"
                    )

            self.target_conn.commit()
            logger.info("✅ Recurring tables migration completed")

        except psycopg2.Error as e:
            self.target_conn.rollback()
            logger.error(f"Recurring tables migration failed: {e}")
            raise

    def migrate_investments(self):
        """Migrate investment tables"""
        logger.info("🔄 Migrating investment tables...")

        try:
            # Migrate investments
            logger.info("Migrating investments...")
            with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                src_cursor.execute("SELECT * FROM public.investments")
                investments = src_cursor.fetchall()

                if investments:
                    for inv in investments:
                        tgt_cursor.execute(
                            """
                            INSERT INTO fintrack.investments (id, asset_name, type, account_id, index_type, index_value, liquidity, is_rescued, validity, current_value, created_at, updated_at)
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                            ON CONFLICT (id) DO NOTHING
                        """,
                            (
                                inv["id"],
                                inv["asset_name"],
                                inv["type"],
                                inv["account_id"],
                                inv["index_type"],
                                inv["index_value"],
                                inv["liquidity"] or "daily",
                                inv["is_rescued"] or False,
                                inv["validity"],
                                inv.get("current_value"),
                                inv["created_at"],
                                inv["updated_at"],
                            ),
                        )

                    logger.info(f"✓ Migrated {len(investments)} investments")

            # Migrate investment_deposits
            logger.info("Migrating investment_deposits...")
            with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                src_cursor.execute("SELECT * FROM public.investment_deposit")
                deposits = src_cursor.fetchall()

                if deposits:
                    for dep in deposits:
                        status = (
                            "validating"
                            if dep["transaction_status"] == "pending"
                            else dep["transaction_status"]
                        )

                        tgt_cursor.execute(
                            """
                            INSERT INTO fintrack.investment_deposits (id, transaction_date, description, amount, recurring_transaction_id, investment_id, account_id, transaction_status, deleted_at, created_at, updated_at)
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                            ON CONFLICT (id) DO NOTHING
                        """,
                            (
                                dep["id"],
                                dep["transaction_date"],
                                dep["description"],
                                dep["amount"],
                                dep["recurring_transaction_id"],
                                dep["investment_id"],
                                dep["account_id"],
                                status,
                                None,
                                dep["created_at"],
                                dep["updated_at"],
                            ),
                        )

                    logger.info(
                        f"✓ Migrated {len(deposits)} investment_deposits"
                    )

            # Migrate investment_withdrawals
            logger.info("Migrating investment_withdrawals...")
            with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                src_cursor.execute(
                    "SELECT * FROM public.investment_withdrawal"
                )
                withdrawals = src_cursor.fetchall()

                if withdrawals:
                    for wd in withdrawals:
                        status = (
                            "validating"
                            if wd["transaction_status"] == "pending"
                            else wd["transaction_status"]
                        )

                        tgt_cursor.execute(
                            """
                            INSERT INTO fintrack.investment_withdrawals (id, transaction_date, description, amount, recurring_transaction_id, investment_id, account_id, transaction_status, deleted_at, created_at, updated_at)
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                            ON CONFLICT (id) DO NOTHING
                        """,
                            (
                                wd["id"],
                                wd["transaction_date"],
                                wd["description"],
                                wd["amount"],
                                wd["recurring_transaction_id"],
                                wd["investment_id"],
                                wd["account_id"],
                                status,
                                None,
                                wd["created_at"],
                                wd["updated_at"],
                            ),
                        )

                    logger.info(
                        f"✓ Migrated {len(withdrawals)} investment_withdrawals"
                    )

            self.target_conn.commit()
            logger.info("✅ Investment tables migration completed")

        except psycopg2.Error as e:
            self.target_conn.rollback()
            logger.error(f"Investment tables migration failed: {e}")
            raise

    def migrate_tag_relationships(self):
        """Migrate tag relationship tables"""
        logger.info("🔄 Migrating tag relationships...")

        try:
            # Migrate recurring_transactions_tags
            logger.info("Migrating recurring_transactions_tags...")
            with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                src_cursor.execute(
                    "SELECT * FROM public.recurring_transactions_tags"
                )
                rt_tags = src_cursor.fetchall()

                if rt_tags:
                    for tag in rt_tags:
                        tgt_cursor.execute(
                            """
                            INSERT INTO fintrack.recurring_transactions_tags (recurring_transaction_id, tag_id, created_at, updated_at)
                            VALUES (%s, %s, %s, %s)
                            ON CONFLICT (recurring_transaction_id, tag_id) DO NOTHING
                        """,
                            (
                                tag["recurring_transaction_id"],
                                tag["tag_id"],
                                tag["created_at"],
                                tag["updated_at"],
                            ),
                        )

                    logger.info(
                        f"✓ Migrated {len(rt_tags)} recurring_transactions_tags"
                    )

            # Migrate incomes_tags
            logger.info("Migrating incomes_tags...")
            with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                src_cursor.execute("SELECT * FROM public.incomes_tags")
                income_tags = src_cursor.fetchall()

                if income_tags:
                    for tag in income_tags:
                        tgt_cursor.execute(
                            """
                            INSERT INTO fintrack.incomes_tags (income_id, tag_id, created_at, updated_at)
                            VALUES (%s, %s, %s, %s)
                            ON CONFLICT (income_id, tag_id) DO NOTHING
                        """,
                            (
                                tag["income_id"],
                                tag["tag_id"],
                                tag["created_at"],
                                tag["updated_at"],
                            ),
                        )

                    logger.info(f"✓ Migrated {len(income_tags)} incomes_tags")

            # Migrate expenses_tags
            logger.info("Migrating expenses_tags...")
            with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                src_cursor.execute("SELECT * FROM public.expenses_tags")
                expense_tags = src_cursor.fetchall()

                if expense_tags:
                    for tag in expense_tags:
                        tgt_cursor.execute(
                            """
                            INSERT INTO fintrack.expenses_tags (expense_id, tag_id, created_at, updated_at)
                            VALUES (%s, %s, %s, %s)
                            ON CONFLICT (expense_id, tag_id) DO NOTHING
                        """,
                            (
                                tag["expense_id"],
                                tag["tag_id"],
                                tag["created_at"],
                                tag["updated_at"],
                            ),
                        )

                    logger.info(
                        f"✓ Migrated {len(expense_tags)} expenses_tags"
                    )

            # Migrate investments_tags
            logger.info("Migrating investments_tags...")
            with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                src_cursor.execute("SELECT * FROM public.investments_tags")
                inv_tags = src_cursor.fetchall()

                if inv_tags:
                    for tag in inv_tags:
                        tgt_cursor.execute(
                            """
                            INSERT INTO fintrack.investments_tags (investment_id, tag_id, created_at, updated_at)
                            VALUES (%s, %s, %s, %s)
                            ON CONFLICT (investment_id, tag_id) DO NOTHING
                        """,
                            (
                                tag["investment_id"],
                                tag["tag_id"],
                                tag["created_at"],
                                tag["updated_at"],
                            ),
                        )

                    logger.info(f"✓ Migrated {len(inv_tags)} investments_tags")

            # Migrate card_expenses_tags (card_expense_tags in source)
            logger.info("Migrating card_expenses_tags...")
            with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                src_cursor.execute("SELECT * FROM public.card_expense_tags")
                card_tags = src_cursor.fetchall()

                if card_tags:
                    for tag in card_tags:
                        tgt_cursor.execute(
                            """
                            INSERT INTO fintrack.card_expenses_tags (card_expense_id, tag_id, created_at, updated_at)
                            VALUES (%s, %s, %s, %s)
                            ON CONFLICT (card_expense_id, tag_id) DO NOTHING
                        """,
                            (
                                tag["card_expense_id"],
                                tag["tag_id"],
                                tag["created_at"],
                                tag["updated_at"],
                            ),
                        )

                    logger.info(
                        f"✓ Migrated {len(card_tags)} card_expenses_tags"
                    )

            self.target_conn.commit()
            logger.info("✅ Tag relationships migration completed")

        except psycopg2.Error as e:
            self.target_conn.rollback()
            logger.error(f"Tag relationships migration failed: {e}")
            raise

    def _migrate_card_chargebacks(self):
        """Migrate card_chargebacks table"""
        logger.info("Migrating card_chargebacks...")
        with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
            src_cursor.execute(
                """
                SELECT cb.*, i.card_id, i.billing_month
                FROM public.card_chargebacks cb
                JOIN public.invoices i ON cb.invoice_id = i.id
            """
            )
            chargebacks = src_cursor.fetchall()

            if chargebacks:
                for cb in chargebacks:
                    billing_month = cb["billing_month"].strftime("%Y-%m")

                    tgt_cursor.execute(
                        """
                        INSERT INTO fintrack.card_chargebacks (id, transaction_date, description, amount, card_id, billing_month, transaction_status, created_at, updated_at)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                        ON CONFLICT (id) DO NOTHING
                    """,
                        (
                            cb["id"],
                            cb["transaction_date"],
                            cb["description"],
                            cb["amount"],
                            cb["card_id"],
                            billing_month,
                            "validating",
                            cb["created_at"],
                            cb["updated_at"],
                        ),
                    )

                logger.info(f"✓ Migrated {len(chargebacks)} card_chargebacks")

    def _migrate_card_payments(self):
        """Migrate card_payments table"""
        logger.info("Migrating card_payments...")
        with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
            src_cursor.execute(
                """
                SELECT cp.*, i.card_id, i.billing_month
                FROM public.card_payments cp
                JOIN public.invoices i ON cp.invoice_id = i.id
            """
            )
            payments = src_cursor.fetchall()

            if payments:
                for cp in payments:
                    billing_month = cp["billing_month"].strftime("%Y-%m")

                    tgt_cursor.execute(
                        """
                        INSERT INTO fintrack.card_payments (id, transaction_date, amount, account_id, card_id, billing_month, is_final_payment, transaction_status, created_at, updated_at)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                        ON CONFLICT (id) DO NOTHING
                    """,
                        (
                            cp["id"],
                            cp["transaction_date"],
                            cp["amount"],
                            cp["account_id"],
                            cp["card_id"],
                            billing_month,
                            cp["is_final_payment"],
                            "validating",
                            cp["created_at"],
                            cp["updated_at"],
                        ),
                    )

                logger.info(f"✓ Migrated {len(payments)} card_payments")

    def migrate_card_transactions(self):
        """Migrate card transaction tables with new structure"""
        logger.info("🔄 Migrating card transaction tables...")

        try:
            # Check if card_expenses table exists in source
            with self.source_conn.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT EXISTS (
                        SELECT FROM information_schema.tables 
                        WHERE table_schema = 'public' 
                        AND table_name = 'card_expenses'
                    )
                """
                )
                result = cursor.fetchone()
                table_exists = (
                    result[0]
                    if isinstance(result, (list, tuple))
                    else result["exists"]
                )

                if not table_exists:
                    logger.info(
                        "⚠️  card_expenses table not found in source, skipping card transactions"
                    )
                    return

            # Migrate card_expenses
            logger.info("Migrating card_expenses...")
            with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                src_cursor.execute(
                    """
                    SELECT ce.*, i.card_id, i.billing_month
                    FROM public.card_expenses ce
                    JOIN public.invoices i ON ce.invoice_id = i.id
                """
                )
                card_expenses = src_cursor.fetchall()

                if card_expenses:
                    for expense in card_expenses:
                        billing_month = expense["billing_month"].strftime(
                            "%Y-%m"
                        )

                        tgt_cursor.execute(
                            """
                            INSERT INTO fintrack.card_expenses (id, transaction_date, description, amount, subcategory_id, category_id, card_id, billing_month, recurring_card_transaction_id, transaction_status, deleted_at, created_at, updated_at)
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                            ON CONFLICT (id) DO NOTHING
                        """,
                            (
                                expense["id"],
                                expense["transaction_date"],
                                expense["description"],
                                expense["amount"],
                                expense["subcategory_id"],
                                expense["category_id"],
                                expense["card_id"],
                                billing_month,
                                None,
                                "validating",
                                None,
                                expense["created_at"],
                                expense["updated_at"],
                            ),
                        )

                    logger.info(
                        f"✓ Migrated {len(card_expenses)} card_expenses"
                    )

            # Migrate card_chargebacks
            logger.info("Migrating card_chargebacks...")
            with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                src_cursor.execute(
                    """
                    SELECT cb.*, i.card_id, i.billing_month
                    FROM public.card_chargebacks cb
                    JOIN public.invoices i ON cb.invoice_id = i.id
                """
                )
                chargebacks = src_cursor.fetchall()

                if chargebacks:
                    for cb in chargebacks:
                        billing_month = cb["billing_month"].strftime("%Y-%m")

                        tgt_cursor.execute(
                            """
                            INSERT INTO fintrack.card_chargebacks (id, transaction_date, description, amount, card_id, billing_month, transaction_status, created_at, updated_at)
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                            ON CONFLICT (id) DO NOTHING
                        """,
                            (
                                cb["id"],
                                cb["transaction_date"],
                                cb["description"],
                                cb["amount"],
                                cb["card_id"],
                                billing_month,
                                "validating",
                                cb["created_at"],
                                cb["updated_at"],
                            ),
                        )

                    logger.info(
                        f"✓ Migrated {len(chargebacks)} card_chargebacks"
                    )

            # Migrate card_payments
            logger.info("Migrating card_payments...")
            with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                src_cursor.execute(
                    """
                    SELECT cp.*, i.card_id, i.billing_month
                    FROM public.card_payments cp
                    JOIN public.invoices i ON cp.invoice_id = i.id
                """
                )
                payments = src_cursor.fetchall()

                if payments:
                    for cp in payments:
                        billing_month = cp["billing_month"].strftime("%Y-%m")

                        tgt_cursor.execute(
                            """
                            INSERT INTO fintrack.card_payments (id, transaction_date, amount, account_id, card_id, billing_month, is_final_payment, transaction_status, created_at, updated_at)
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                            ON CONFLICT (id) DO NOTHING
                        """,
                            (
                                cp["id"],
                                cp["transaction_date"],
                                cp["amount"],
                                cp["account_id"],
                                cp["card_id"],
                                billing_month,
                                cp["is_final_payment"],
                                "validating",
                                cp["created_at"],
                                cp["updated_at"],
                            ),
                        )

                    logger.info(f"✓ Migrated {len(payments)} card_payments")

            self.target_conn.commit()
            logger.info("✅ Card transaction tables migration completed")

        except psycopg2.Error as e:
            self.target_conn.rollback()
            logger.error(f"Card transaction tables migration failed: {e}")
            raise

    def generate_migration_summary(self) -> Dict[str, int]:
        """Generate migration summary with record counts"""
        logger.info("📊 Generating migration summary...")

        summary = {}
        tables = [
            "users",
            "accounts",
            "categories",
            "sub_categories",
            "tags",
            "cards",
            "invoices",
            "recurring_transfers",
            "recurring_incomes",
            "recurring_expenses",
            "recurring_card_transactions",
            "transfers",
            "incomes",
            "expenses",
            "card_expenses",
            "card_chargebacks",
            "card_payments",
            "investments",
            "investment_deposits",
            "investment_withdrawals",
        ]

        try:
            for table in tables:
                source_count = self.get_table_count(
                    self.source_conn, "public", table
                )
                target_count = self.get_table_count(
                    self.target_conn, "fintrack", table
                )
                summary[table] = {
                    "source": source_count,
                    "target": target_count,
                    "migrated": target_count >= source_count,
                }

            return summary

        except psycopg2.Error as e:
            logger.error(f"Failed to generate summary: {e}")
            return {}

    def close_connections(self):
        """Close database connections"""
        if self.source_conn:
            self.source_conn.close()
            logger.info("✓ Source connection closed")

        if self.target_conn:
            self.target_conn.close()
            logger.info("✓ Target connection closed")

    def run_migration(self):
        """Run the complete migration process"""
        logger.info("🚀 Starting Fintrack database migration...")

        try:
            # Connect to databases
            self.connect_databases()

            # Verify schemas
            if not self.verify_source_schema():
                raise Exception("Source schema verification failed")

            if not self.verify_target_schema():
                raise Exception("Target schema verification failed")

            # Run migrations with AI enhancement
            self.migrate_lookup_tables()
            self.migrate_currencies_and_accounts()
            self.migrate_cards_and_invoices()
            self.migrate_recurring_tables()
            self.migrate_transactions_with_ai_enhancement()
            self.migrate_card_transactions_with_ai_enhancement()
            self.migrate_investments()
            self.migrate_tag_relationships()

            # Generate summary
            summary = self.generate_migration_summary()

            logger.info("✅ Migration completed successfully!")

            # Log final AI usage statistics
            if self.ai_processor:
                final_stats = self.ai_processor.get_usage_stats()
                logger.info("🤖 AI Batch Processing Summary:")
                logger.info(
                    f"  Total API Requests: {final_stats['total_requests']} (batches)"
                )
                logger.info(
                    f"  Total Transactions Processed: {final_stats['total_transactions_processed']}"
                )
                logger.info(
                    f"  Transactions Enhanced: {final_stats['total_transactions_enhanced']} ({final_stats['enhancement_rate']:.1f}%)"
                )
                logger.info(
                    f"  Avg Transactions per Request: {final_stats['avg_transactions_per_request']:.1f}"
                )
                logger.info(
                    f"  API Success Rate: {final_stats['success_rate']:.1f}%"
                )
                logger.info(f"  Rate Limit Compliance: ✅ (Max 400 RPM)")

                # Calculate token savings
                estimated_single_requests = final_stats[
                    "total_transactions_processed"
                ]
                actual_requests = final_stats["total_requests"]
                token_savings = (
                    (
                        (estimated_single_requests - actual_requests)
                        / estimated_single_requests
                        * 100
                    )
                    if estimated_single_requests > 0
                    else 0
                )
                logger.info(
                    f"  Token Efficiency: {token_savings:.1f}% savings vs individual requests"
                )

            logger.info("📋 Migration Summary:")
            for table, data in summary.items():
                status = "✅" if data["migrated"] else "❌"
                logger.info(
                    f"  {status} {table}: {data['source']} → {data['target']}"
                )

            logger.info("🔄 Next steps:")
            logger.info(
                "  1. Run: SELECT * FROM fintrack.approve_all_validating_transactions();"
            )
            logger.info("  2. Verify data integrity")
            logger.info("  3. Test application functionality")
            if self.ai_processor and final_stats["total_requests"] > 0:
                logger.info(
                    f"  4. Review AI-enhanced transactions (improved {final_stats['total_transactions_enhanced']} expense descriptions)"
                )

        except Exception as e:
            logger.error(f"❌ Migration failed: {e}")
            raise

        finally:
            self.close_connections()


def main():
    """Main function"""
    import argparse

    # Parse command line arguments
    parser = argparse.ArgumentParser(
        description="Fintrack Database Migration Script"
    )
    parser.add_argument(
        "--no-ai",
        action="store_true",
        help="Disable AI processing for transaction enhancement (faster for testing)",
    )
    args = parser.parse_args()

    try:
        # Display configuration info
        logger.info("🔧 Migration Configuration:")
        logger.info(f"  Source DB: {os.getenv('SOURCE_DB_NAME', 'fintrack')}")
        logger.info(f"  Target DB: {os.getenv('TARGET_DB_NAME', 'phrspace')}")
        logger.info(f"  Host: {os.getenv('SOURCE_DB_HOST', 'localhost')}")
        logger.info(
            f"  AI Processing: {'Disabled' if args.no_ai else 'Enabled'}"
        )

        # Run migration
        migrator = FintrackMigrator(use_ai=not args.no_ai)
        migrator.run_migration()

    except KeyboardInterrupt:
        logger.info("❌ Migration cancelled by user")
        sys.exit(1)
    except Exception as e:
        logger.error(f"❌ Migration failed: {e}")
        sys.exit(1)


def main(use_ai=False):

    try:
        # Display configuration info
        logger.info("🔧 Migration Configuration:")
        logger.info(f"  Source DB: {os.getenv('SOURCE_DB_NAME', 'fintrack')}")
        logger.info(f"  Target DB: {os.getenv('TARGET_DB_NAME', 'phrspace')}")
        logger.info(f"  Host: {os.getenv('SOURCE_DB_HOST', 'localhost')}")
        logger.info(f"  AI Processing: {'Enabled' if use_ai else 'Disabled'}")

        # Run migration
        migrator = FintrackMigrator(use_ai=use_ai)
        migrator.run_migration()

    except KeyboardInterrupt:
        logger.info("❌ Migration cancelled by user")
        sys.exit(1)
    except Exception as e:
        logger.error(f"❌ Migration failed: {e}")
        sys.exit(1)
