# Schema do Banco de Dados

Esta seção detalha a estrutura das tabelas do PostgreSQL.

## Diagrama Visual

Consulte o [Diagrama ER](../architecture/database.md) na seção de Arquitetura.

## Tabelas Principais

### `accounts`
Armazena as contas financeiras.
- `id` (UUID, PK)
- `workspace_id` (UUID, FK -> workspaces)
- `name` (VARCHAR)
- `type` (ENUM: CHECKING, SAVINGS, WALLET, INVESTMENT)
- `initial_balance` (NUMERIC)
- `currency_code` (VARCHAR, FK -> currencies)

### `transactions` (Conceitual)
Na prática, dividido em `expenses`, `incomes`, `transfers`.

#### `expenses`
- `id` (UUID, PK)
- `account_id` (UUID, FK -> accounts)
- `category_id` (UUID, FK -> categories)
- `amount` (NUMERIC) - Sempre positivo.
- `transaction_date` (DATE)
- `description` (TEXT)

### `categories`
- `id` (UUID, PK)
- `workspace_id` (UUID, FK)
- `name` (VARCHAR)
- `type` (ENUM: INCOME, EXPENSE)
- `icon` (VARCHAR)
- `color` (VARCHAR)

### `import_sessions`
Gerencia o estado das importações.
- `id` (UUID, PK)
- `account_id` (UUID, FK)
- `status` (VARCHAR) - ex: PROCESSING, READY, COMMITTED.
- `created_at` (TIMESTAMP)

### `category_embeddings`
Tabela especial para o serviço de IA (pgvector).
- `id` (UUID, PK)
- `category_id` (UUID, FK)
- `description_text` (TEXT) - A descrição original da transação.
- `embedding` (VECTOR) - Representação vetorial do texto.
