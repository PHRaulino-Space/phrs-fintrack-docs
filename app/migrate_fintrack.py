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
    from psycopg2.extras import RealDictCursor
    from datetime import datetime
    from typing import Dict

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


    secrets = SecretsManager()
    creds = secrets.get_postgres_credentials("25dxs7wjovqfbxzzbbuw7ptsc4")

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


    class FintrackMigrator:
        """Main migration class"""

        def __init__(self):
            self.source_config = DatabaseConfig("SOURCE")
            self.target_config = DatabaseConfig("TARGET")
            self.source_conn = None
            self.target_conn = None

            # Set default database names if not provided
            if not os.getenv("SOURCE_DB_NAME"):
                self.source_config.database = "fintrack"
            if not os.getenv("TARGET_DB_NAME"):
                self.target_config.database = "phrspace"

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

        def migrate_lookup_tables(self):
            """Migrate lookup tables (users, categories, tags, etc.)"""
            logger.info("🔄 Migrating lookup tables...")

            try:
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

                # Migrate categories
                logger.info("Migrating categories...")
                with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                    src_cursor.execute("SELECT * FROM public.categories")
                    categories = src_cursor.fetchall()

                    if categories:
                        for cat in categories:
                            # Validate color format
                            color = cat["color"]
                            if not (
                                color and len(color) == 7 and color.startswith("#")
                            ):
                                color = "#000000"

                            tgt_cursor.execute(
                                """
                                INSERT INTO fintrack.categories (id, name, color, icon, is_active, created_at, updated_at)
                                VALUES (%s, %s, %s, %s, %s, %s, %s)
                                ON CONFLICT (id) DO NOTHING
                            """,
                                (
                                    cat["id"],
                                    cat["name"],
                                    color,
                                    cat["icon"],
                                    True,
                                    cat["created_at"],
                                    cat["updated_at"],
                                ),
                            )

                        logger.info(f"✓ Migrated {len(categories)} categories")

                # Migrate sub_categories
                logger.info("Migrating sub_categories...")
                with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                    src_cursor.execute("SELECT * FROM public.sub_categories")
                    subcats = src_cursor.fetchall()

                    if subcats:
                        for subcat in subcats:
                            tgt_cursor.execute(
                                """
                                INSERT INTO fintrack.sub_categories (id, name, category_id, is_active, created_at, updated_at)
                                VALUES (%s, %s, %s, %s, %s, %s)
                                ON CONFLICT (id) DO NOTHING
                            """,
                                (
                                    subcat["id"],
                                    subcat["name"],
                                    subcat["category_id"],
                                    True,
                                    subcat["created_at"],
                                    subcat["updated_at"],
                                ),
                            )

                        logger.info(f"✓ Migrated {len(subcats)} sub_categories")

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

        def migrate_transactions(self):
            """Migrate transaction tables with new status"""
            logger.info("🔄 Migrating transaction tables...")

            try:
                # Migrate transfers
                logger.info("Migrating transfers...")
                with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                    src_cursor.execute("SELECT * FROM public.transfers")
                    transfers = src_cursor.fetchall()

                    if transfers:
                        for transfer in transfers:
                            # Convert status
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

                # Migrate incomes
                logger.info("Migrating incomes...")
                with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                    src_cursor.execute("SELECT * FROM public.incomes")
                    incomes = src_cursor.fetchall()

                    if incomes:
                        for income in incomes:
                            # Convert status
                            status = (
                                "validating"
                                if income["transaction_status"] == "pending"
                                else income["transaction_status"]
                            )

                            tgt_cursor.execute(
                                """
                                INSERT INTO fintrack.incomes (id, transaction_date, description, amount, account_id, category_id, subcategory_id, recurring_transaction_id, transaction_status, deleted_at, created_at, updated_at)
                                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                                ON CONFLICT (id) DO NOTHING
                            """,
                                (
                                    income["id"],
                                    income["transaction_date"],
                                    income["description"],
                                    income["amount"],
                                    income["account_id"],
                                    income["category_id"],
                                    income["subcategory_id"],
                                    income["recurring_transaction_id"],
                                    status,
                                    None,
                                    income["created_at"],
                                    income["updated_at"],
                                ),
                            )

                        logger.info(f"✓ Migrated {len(incomes)} incomes")

                # Migrate expenses
                logger.info("Migrating expenses...")
                with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                    src_cursor.execute("SELECT * FROM public.expenses")
                    expenses = src_cursor.fetchall()

                    if expenses:
                        for expense in expenses:
                            # Convert status
                            status = (
                                "validating"
                                if expense["transaction_status"] == "pending"
                                else expense["transaction_status"]
                            )

                            tgt_cursor.execute(
                                """
                                INSERT INTO fintrack.expenses (id, transaction_date, description, amount, account_id, category_id, subcategory_id, recurring_transaction_id, transaction_status, deleted_at, created_at, updated_at)
                                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                                ON CONFLICT (id) DO NOTHING
                            """,
                                (
                                    expense["id"],
                                    expense["transaction_date"],
                                    expense["description"],
                                    expense["amount"],
                                    expense["account_id"],
                                    expense["category_id"],
                                    expense["subcategory_id"],
                                    expense["recurring_transaction_id"],
                                    status,
                                    None,
                                    expense["created_at"],
                                    expense["updated_at"],
                                ),
                            )

                        logger.info(f"✓ Migrated {len(expenses)} expenses")

                self.target_conn.commit()
                logger.info("✅ Transaction tables migration completed")

            except psycopg2.Error as e:
                self.target_conn.rollback()
                logger.error(f"Transaction tables migration failed: {e}")
                raise

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
                            # Convert billing_month to VARCHAR
                            billing_month = expense["billing_month"].strftime(
                                "%Y-%m"
                            )

                            tgt_cursor.execute(
                                """
                                INSERT INTO fintrack.card_expenses (id, transaction_date, description, amount, subcategory_id, category_id, recurring_transaction_id, card_id, billing_month, installments, current_installment, transaction_status, deleted_at, created_at, updated_at)
                                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                                ON CONFLICT (id) DO NOTHING
                            """,
                                (
                                    expense["id"],
                                    expense["transaction_date"],
                                    expense["description"],
                                    expense["amount"],
                                    expense["subcategory_id"],
                                    expense["category_id"],
                                    expense["recurring_transaction_id"],
                                    expense["card_id"],
                                    billing_month,
                                    1,
                                    1,
                                    "validating",
                                    None,
                                    expense["created_at"],
                                    expense["updated_at"],
                                ),
                            )

                        logger.info(
                            f"✓ Migrated {len(card_expenses)} card_expenses"
                        )

                self.target_conn.commit()
                logger.info("✅ Card transaction tables migration completed")

            except psycopg2.Error as e:
                self.target_conn.rollback()
                logger.error(f"Card transaction tables migration failed: {e}")
                raise

        def migrate_recurring_tables(self):
            """Migrate recurring tables"""
            logger.info("🔄 Migrating recurring tables...")
            
            try:
                # Migrate recurring_transfers
                logger.info("Migrating recurring_transfers...")
                with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                    src_cursor.execute("SELECT * FROM public.recurring_transfers")
                    recurring_transfers = src_cursor.fetchall()
                    
                    if recurring_transfers:
                        for rt in recurring_transfers:
                            tgt_cursor.execute("""
                                INSERT INTO fintrack.recurring_transfers (id, amount, source_account_id, destination_account_id, frequency, start_date, end_date, is_active, created_at, updated_at)
                                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                                ON CONFLICT (id) DO NOTHING
                            """, (
                                rt['id'], rt['amount'], rt['source_account_id'], rt['destination_account_id'],
                                rt['frequency'], rt['start_date'], rt['end_date'], True,
                                rt['created_at'], rt['updated_at']
                            ))
                        
                        logger.info(f"✓ Migrated {len(recurring_transfers)} recurring_transfers")
                
                # Migrate recurring_transactions
                logger.info("Migrating recurring_transactions...")
                with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                    src_cursor.execute("SELECT * FROM public.recurring_transactions")
                    recurring_transactions = src_cursor.fetchall()
                    
                    if recurring_transactions:
                        for rt in recurring_transactions:
                            tgt_cursor.execute("""
                                INSERT INTO fintrack.recurring_transactions (id, amount, description, frequency, start_date, end_date, account_id, category_id, subcategory_id, is_active, created_at, updated_at)
                                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                                ON CONFLICT (id) DO NOTHING
                            """, (
                                rt['id'], rt['amount'], rt['description'], rt['frequency'],
                                rt['start_date'], rt['end_date'], rt['account_id'], rt['category_id'],
                                rt['subcategory_id'], True, rt['created_at'], rt['updated_at']
                            ))
                        
                        logger.info(f"✓ Migrated {len(recurring_transactions)} recurring_transactions")
                
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
                            tgt_cursor.execute("""
                                INSERT INTO fintrack.investments (id, asset_name, type, account_id, index_type, index_value, liquidity, is_rescued, validity, current_value, created_at, updated_at)
                                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                                ON CONFLICT (id) DO NOTHING
                            """, (
                                inv['id'], inv['asset_name'], inv['type'], inv['account_id'],
                                inv['index_type'], inv['index_value'], 
                                inv['liquidity'] or 'daily',
                                inv['is_rescued'] or False,
                                inv['validity'], inv.get('current_value'),
                                inv['created_at'], inv['updated_at']
                            ))
                        
                        logger.info(f"✓ Migrated {len(investments)} investments")
                
                # Migrate investment_deposits
                logger.info("Migrating investment_deposits...")
                with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                    src_cursor.execute("SELECT * FROM public.investment_deposit")
                    deposits = src_cursor.fetchall()
                    
                    if deposits:
                        for dep in deposits:
                            status = 'validating' if dep['transaction_status'] == 'pending' else dep['transaction_status']
                            
                            tgt_cursor.execute("""
                                INSERT INTO fintrack.investment_deposits (id, transaction_date, description, amount, recurring_transaction_id, investment_id, account_id, transaction_status, deleted_at, created_at, updated_at)
                                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                                ON CONFLICT (id) DO NOTHING
                            """, (
                                dep['id'], dep['transaction_date'], dep['description'], dep['amount'],
                                dep['recurring_transaction_id'], dep['investment_id'], dep['account_id'],
                                status, None, dep['created_at'], dep['updated_at']
                            ))
                        
                        logger.info(f"✓ Migrated {len(deposits)} investment_deposits")
                
                # Migrate investment_withdrawals
                logger.info("Migrating investment_withdrawals...")
                with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                    src_cursor.execute("SELECT * FROM public.investment_withdrawal")
                    withdrawals = src_cursor.fetchall()
                    
                    if withdrawals:
                        for wd in withdrawals:
                            status = 'validating' if wd['transaction_status'] == 'pending' else wd['transaction_status']
                            
                            tgt_cursor.execute("""
                                INSERT INTO fintrack.investment_withdrawals (id, transaction_date, description, amount, recurring_transaction_id, investment_id, account_id, transaction_status, deleted_at, created_at, updated_at)
                                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                                ON CONFLICT (id) DO NOTHING
                            """, (
                                wd['id'], wd['transaction_date'], wd['description'], wd['amount'],
                                wd['recurring_transaction_id'], wd['investment_id'], wd['account_id'],
                                status, None, wd['created_at'], wd['updated_at']
                            ))
                        
                        logger.info(f"✓ Migrated {len(withdrawals)} investment_withdrawals")
                
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
                    src_cursor.execute("SELECT * FROM public.recurring_transactions_tags")
                    rt_tags = src_cursor.fetchall()
                    
                    if rt_tags:
                        for tag in rt_tags:
                            tgt_cursor.execute("""
                                INSERT INTO fintrack.recurring_transactions_tags (recurring_transaction_id, tag_id, created_at, updated_at)
                                VALUES (%s, %s, %s, %s)
                                ON CONFLICT (recurring_transaction_id, tag_id) DO NOTHING
                            """, (
                                tag['recurring_transaction_id'], tag['tag_id'],
                                tag['created_at'], tag['updated_at']
                            ))
                        
                        logger.info(f"✓ Migrated {len(rt_tags)} recurring_transactions_tags")
                
                # Migrate incomes_tags
                logger.info("Migrating incomes_tags...")
                with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                    src_cursor.execute("SELECT * FROM public.incomes_tags")
                    income_tags = src_cursor.fetchall()
                    
                    if income_tags:
                        for tag in income_tags:
                            tgt_cursor.execute("""
                                INSERT INTO fintrack.incomes_tags (income_id, tag_id, created_at, updated_at)
                                VALUES (%s, %s, %s, %s)
                                ON CONFLICT (income_id, tag_id) DO NOTHING
                            """, (
                                tag['income_id'], tag['tag_id'],
                                tag['created_at'], tag['updated_at']
                            ))
                        
                        logger.info(f"✓ Migrated {len(income_tags)} incomes_tags")
                
                # Migrate expenses_tags
                logger.info("Migrating expenses_tags...")
                with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                    src_cursor.execute("SELECT * FROM public.expenses_tags")
                    expense_tags = src_cursor.fetchall()
                    
                    if expense_tags:
                        for tag in expense_tags:
                            tgt_cursor.execute("""
                                INSERT INTO fintrack.expenses_tags (expense_id, tag_id, created_at, updated_at)
                                VALUES (%s, %s, %s, %s)
                                ON CONFLICT (expense_id, tag_id) DO NOTHING
                            """, (
                                tag['expense_id'], tag['tag_id'],
                                tag['created_at'], tag['updated_at']
                            ))
                        
                        logger.info(f"✓ Migrated {len(expense_tags)} expenses_tags")
                
                # Migrate investments_tags
                logger.info("Migrating investments_tags...")
                with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                    src_cursor.execute("SELECT * FROM public.investments_tags")
                    inv_tags = src_cursor.fetchall()
                    
                    if inv_tags:
                        for tag in inv_tags:
                            tgt_cursor.execute("""
                                INSERT INTO fintrack.investments_tags (investment_id, tag_id, created_at, updated_at)
                                VALUES (%s, %s, %s, %s)
                                ON CONFLICT (investment_id, tag_id) DO NOTHING
                            """, (
                                tag['investment_id'], tag['tag_id'],
                                tag['created_at'], tag['updated_at']
                            ))
                        
                        logger.info(f"✓ Migrated {len(inv_tags)} investments_tags")
                
                # Migrate card_expenses_tags (card_expense_tags in source)
                logger.info("Migrating card_expenses_tags...")
                with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                    src_cursor.execute("SELECT * FROM public.card_expense_tags")
                    card_tags = src_cursor.fetchall()
                    
                    if card_tags:
                        for tag in card_tags:
                            tgt_cursor.execute("""
                                INSERT INTO fintrack.card_expenses_tags (card_expense_id, tag_id, created_at, updated_at)
                                VALUES (%s, %s, %s, %s)
                                ON CONFLICT (card_expense_id, tag_id) DO NOTHING
                            """, (
                                tag['card_expense_id'], tag['tag_id'],
                                tag['created_at'], tag['updated_at']
                            ))
                        
                        logger.info(f"✓ Migrated {len(card_tags)} card_expenses_tags")
                
                self.target_conn.commit()
                logger.info("✅ Tag relationships migration completed")
                
            except psycopg2.Error as e:
                self.target_conn.rollback()
                logger.error(f"Tag relationships migration failed: {e}")
                raise

        def migrate_card_transactions(self):
            """Migrate card transaction tables with new structure"""
            logger.info("🔄 Migrating card transaction tables...")
            
            try:
                # Check if card_expenses table exists in source
                with self.source_conn.cursor() as cursor:
                    cursor.execute("""
                        SELECT EXISTS (
                            SELECT FROM information_schema.tables 
                            WHERE table_schema = 'public' 
                            AND table_name = 'card_expenses'
                        )
                    """)
                    result = cursor.fetchone()
                    table_exists = result[0] if isinstance(result, (list, tuple)) else result["exists"]
                    
                    if not table_exists:
                        logger.info("⚠️  card_expenses table not found in source, skipping card transactions")
                        return

                # Migrate card_expenses
                logger.info("Migrating card_expenses...")
                with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                    src_cursor.execute("""
                        SELECT ce.*, i.card_id, i.billing_month
                        FROM public.card_expenses ce
                        JOIN public.invoices i ON ce.invoice_id = i.id
                    """)
                    card_expenses = src_cursor.fetchall()
                    
                    if card_expenses:
                        for expense in card_expenses:
                            billing_month = expense["billing_month"].strftime("%Y-%m")
                            
                            tgt_cursor.execute("""
                                INSERT INTO fintrack.card_expenses (id, transaction_date, description, amount, subcategory_id, category_id, card_id, billing_month, recurring_card_transaction_id, transaction_status, deleted_at, created_at, updated_at)
                                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                                ON CONFLICT (id) DO NOTHING
                            """, (
                                expense["id"], expense["transaction_date"], expense["description"], expense["amount"],
                                expense["subcategory_id"], expense["category_id"],
                                expense["card_id"], billing_month, None, "validating", None,
                                expense["created_at"], expense["updated_at"]
                            ))
                        
                        logger.info(f"✓ Migrated {len(card_expenses)} card_expenses")
                
                # Migrate card_chargebacks
                logger.info("Migrating card_chargebacks...")
                with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                    src_cursor.execute("""
                        SELECT cb.*, i.card_id, i.billing_month
                        FROM public.card_chargebacks cb
                        JOIN public.invoices i ON cb.invoice_id = i.id
                    """)
                    chargebacks = src_cursor.fetchall()
                    
                    if chargebacks:
                        for cb in chargebacks:
                            billing_month = cb["billing_month"].strftime("%Y-%m")
                            
                            tgt_cursor.execute("""
                                INSERT INTO fintrack.card_chargebacks (id, transaction_date, description, amount, card_id, billing_month, transaction_status, created_at, updated_at)
                                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                                ON CONFLICT (id) DO NOTHING
                            """, (
                                cb["id"], cb["transaction_date"], cb["description"], cb["amount"],
                                cb["card_id"], billing_month, "validating",
                                cb["created_at"], cb["updated_at"]
                            ))
                        
                        logger.info(f"✓ Migrated {len(chargebacks)} card_chargebacks")
                
                # Migrate card_payments
                logger.info("Migrating card_payments...")
                with self.source_conn.cursor() as src_cursor, self.target_conn.cursor() as tgt_cursor:
                    src_cursor.execute("""
                        SELECT cp.*, i.card_id, i.billing_month
                        FROM public.card_payments cp
                        JOIN public.invoices i ON cp.invoice_id = i.id
                    """)
                    payments = src_cursor.fetchall()
                    
                    if payments:
                        for cp in payments:
                            billing_month = cp["billing_month"].strftime("%Y-%m")
                            
                            tgt_cursor.execute("""
                                INSERT INTO fintrack.card_payments (id, transaction_date, amount, account_id, card_id, billing_month, is_final_payment, transaction_status, created_at, updated_at)
                                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                                ON CONFLICT (id) DO NOTHING
                            """, (
                                cp["id"], cp["transaction_date"], cp["amount"], cp["account_id"],
                                cp["card_id"], billing_month, cp["is_final_payment"], "validating",
                                cp["created_at"], cp["updated_at"]
                            ))
                        
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
                "recurring_transactions", 
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

                # Run migrations
                self.migrate_lookup_tables()
                self.migrate_currencies_and_accounts()
                self.migrate_cards_and_invoices()
                self.migrate_recurring_tables()
                self.migrate_transactions()
                self.migrate_card_transactions()
                self.migrate_investments()
                self.migrate_tag_relationships()

                # Generate summary
                summary = self.generate_migration_summary()

                logger.info("✅ Migration completed successfully!")
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

            except Exception as e:
                logger.error(f"❌ Migration failed: {e}")
                raise

            finally:
                self.close_connections()


    def main():
        """Main function"""
        try:
            # Display configuration info
            logger.info("🔧 Migration Configuration:")
            logger.info(f"  Source DB: {os.getenv('SOURCE_DB_NAME', 'fintrack')}")
            logger.info(f"  Target DB: {os.getenv('TARGET_DB_NAME', 'phrspace')}")
            logger.info(f"  Host: {os.getenv('SOURCE_DB_HOST', 'localhost')}")

            # Run migration
            migrator = FintrackMigrator()
            migrator.run_migration()

        except KeyboardInterrupt:
            logger.info("❌ Migration cancelled by user")
            sys.exit(1)
        except Exception as e:
            logger.error(f"❌ Migration failed: {e}")
            sys.exit(1)
