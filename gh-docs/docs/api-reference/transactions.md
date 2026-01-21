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

## Despesas de Cartão (Card Expenses)

Transações de despesa realizadas em cartão de crédito.

### `POST /card-expenses`

**Request Body:**

```json
{
  "description": "Uber Viagem",
  "amount": 45.90,
  "transaction_date": "2024-03-10",
  "card_id": "uuid-cartao",
  "category_id": "uuid-transporte",
  "billing_month": "2024-03"
}
```

## Estornos de Cartão (Card Chargebacks)

Créditos na fatura do cartão (ex: estorno de compra).

### `POST /card-chargebacks`

**Request Body:**

```json
{
  "description": "Estorno Uber",
  "amount": 45.90,
  "transaction_date": "2024-03-11",
  "card_id": "uuid-cartao",
  "billing_month": "2024-03"
}
```

## Pagamentos de Fatura (Card Payments)

Pagamento da fatura do cartão usando saldo de uma conta.

### `POST /card-payments`

**Request Body:**

```json
{
  "amount": 1500.00,
  "transaction_date": "2024-03-15",
  "card_id": "uuid-cartao",
  "account_id": "uuid-conta-corrente",
  "billing_month": "2024-02"
}
```

## Investimentos (Deposits & Withdrawals)

### `POST /investment-deposits`

Aporte de dinheiro em um investimento.

**Request Body:**

```json
{
  "description": "Aporte Mensal",
  "amount": 1000.00,
  "transaction_date": "2024-03-05",
  "investment_id": "uuid-tesouro",
  "account_id": "uuid-conta-origem"
}
```

### `POST /investment-withdrawals`

Resgate de dinheiro de um investimento.

**Request Body:**

```json
{
  "description": "Resgate Emergência",
  "amount": 500.00,
  "transaction_date": "2024-06-20",
  "investment_id": "uuid-tesouro",
  "account_id": "uuid-conta-destino"
}
```

## Modelos

### TransactionStatus (Enum)
- `VALIDATING`: Em validação (usado na importação).
- `PAID`: Efetivado.
- `PENDING`: Agendado/Pendente.
- `IGNORE`: Ignorar em somatórios.
