# Transactions

Endpoints para gerenciar despesas (`expenses`), receitas (`incomes`) e transferências (`transfers`).

**Header Obrigatório**: `X-Workspace-ID: <uuid>`

## Despesas (Expenses)

### `GET /expenses`

Lista despesas com filtros opcionais.

**Query Params:**
- `account_id`: Filtra por conta.
- `start_date`: Início do período (YYYY-MM-DD).
- `end_date`: Fim do período (YYYY-MM-DD).

### `POST /expenses`

Registra uma nova despesa.

**Request Body:**

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `description` | string | Descrição da transação |
| `amount` | number | Valor (positivo) |
| `transaction_date` | string | Data (YYYY-MM-DD) |
| `account_id` | uuid | Conta de origem dos fundos |
| `category_id` | uuid | Categoria da despesa |
| `subcategory_id` | uuid | Subcategoria (opcional) |
| `tags` | uuid[] | Lista de IDs de tags (opcional) |

```json
{
  "description": "Almoço Domingo",
  "amount": 89.90,
  "transaction_date": "2023-11-15",
  "account_id": "...",
  "category_id": "...",
  "tags": ["..."]
}
```

## Receitas (Incomes)

### `GET /incomes`
Similar a Expenses.

### `POST /incomes`
Registra uma entrada de dinheiro. Mesma estrutura de payload de Expenses.

## Transferências (Transfers)

Movimentação entre duas contas do mesmo workspace.

### `POST /transfers`

**Request Body:**

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `description` | string | Descrição |
| `amount` | number | Valor transferido |
| `transaction_date` | string | Data |
| `source_account_id` | uuid | Conta de onde sai o dinheiro |
| `destination_account_id` | uuid | Conta para onde vai o dinheiro |

```json
{
  "description": "Reserva Financeira",
  "amount": 500.00,
  "source_account_id": "uuid-itau",
  "destination_account_id": "uuid-poupanca",
  "transaction_date": "2023-11-01"
}
```

## Modelos

### TransactionStatus (Enum)
- `VALIDATING`: Em validação (usado na importação).
- `PAID`: Efetivado.
- `PENDING`: Agendado/Pendente.
- `IGNORE`: Ignorar em somatórios.
