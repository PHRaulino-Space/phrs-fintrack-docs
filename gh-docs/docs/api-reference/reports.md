---
sidebar_position: 8
---

# Reports (Relatorios e Reconciliacao)

Endpoints para consultas analiticas e reconciliacao de transacoes.

## Endpoints

| Metodo | Endpoint | Descricao |
|--------|----------|-----------|
| GET | `/reconciliation/pending` | Transacoes pendentes |
| GET | `/reconciliation/projection/:id` | Projecao de recorrente |
| GET | `/reconciliation/recurring` | Listar recorrentes |
| GET | `/reconciliation/recurring/:id` | Detalhe de recorrente |

---

## Transacoes Pendentes

Lista todas as transacoes que precisam de atencao (status PENDING ou VALIDATING).

```http
GET /api/v1/reconciliation/pending
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
```

**Query Parameters:**

| Parametro | Tipo | Descricao |
|-----------|------|-----------|
| `account_id` | UUID | Filtrar por conta |
| `card_id` | UUID | Filtrar por cartao |

**Response (200 OK):**

```json
{
  "pending_transactions": [
    {
      "type": "EXPENSE",
      "id": "exp-123",
      "transaction_date": "2024-01-15",
      "description": "Compra pendente",
      "amount": 150.00,
      "status": "PENDING",
      "account_id": "acc-123",
      "category": { "name": "Alimentacao" }
    },
    {
      "type": "INCOME",
      "id": "inc-456",
      "transaction_date": "2024-01-20",
      "description": "Pagamento aguardando",
      "amount": 500.00,
      "status": "VALIDATING",
      "account_id": "acc-123",
      "category": { "name": "Freelance" }
    }
  ],
  "total_pending": 2,
  "total_amount": 650.00
}
```

---

## Projecao de Recorrente

Calcula as proximas ocorrencias de uma transacao recorrente.

```http
GET /api/v1/reconciliation/projection/:id?type=income
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
```

**Query Parameters:**

| Parametro | Tipo | Obrigatorio | Descricao |
|-----------|------|-------------|-----------|
| `type` | string | Sim | `income`, `expense`, `transfer`, `card` |

**Response (200 OK):**

```json
{
  "recurring": {
    "id": "rec-123",
    "description": "Salario",
    "amount": 5000.00,
    "frequency": "MONTHLY",
    "start_date": "2024-01-05",
    "end_date": null,
    "is_active": true
  },
  "projections": [
    {
      "date": "2024-02-05",
      "amount": 5000.00,
      "status": "PROJECTED"
    },
    {
      "date": "2024-03-05",
      "amount": 5000.00,
      "status": "PROJECTED"
    },
    {
      "date": "2024-04-05",
      "amount": 5000.00,
      "status": "PROJECTED"
    }
  ],
  "next_occurrence": "2024-02-05",
  "total_projected_12_months": 60000.00
}
```

---

## Listar Transacoes Recorrentes

```http
GET /api/v1/reconciliation/recurring
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
```

**Response (200 OK):**

```json
{
  "recurring_incomes": [
    {
      "id": "ri-001",
      "description": "Salario",
      "amount": 5000.00,
      "frequency": "MONTHLY",
      "account": { "name": "Nubank" },
      "category": { "name": "Salario" },
      "is_active": true,
      "next_occurrence": "2024-02-05"
    }
  ],
  "recurring_expenses": [
    {
      "id": "re-001",
      "description": "Netflix",
      "amount": 39.90,
      "frequency": "MONTHLY",
      "account": { "name": "Nubank" },
      "category": { "name": "Lazer" },
      "is_active": true,
      "next_occurrence": "2024-02-15"
    },
    {
      "id": "re-002",
      "description": "Academia",
      "amount": 99.00,
      "frequency": "MONTHLY",
      "account": { "name": "Nubank" },
      "category": { "name": "Saude" },
      "is_active": true,
      "next_occurrence": "2024-02-10"
    }
  ],
  "recurring_transfers": [],
  "recurring_card_transactions": [
    {
      "id": "rct-001",
      "description": "Spotify",
      "amount": 21.90,
      "frequency": "MONTHLY",
      "card": { "name": "Nubank Mastercard" },
      "category": { "name": "Assinaturas" },
      "is_active": true
    }
  ],
  "summary": {
    "total_recurring_income": 5000.00,
    "total_recurring_expense": 160.80,
    "net_recurring": 4839.20
  }
}
```

---

## Detalhe de Recorrente

```http
GET /api/v1/reconciliation/recurring/:id?type=expense
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
```

**Response (200 OK):**

```json
{
  "recurring": {
    "id": "re-001",
    "description": "Netflix",
    "amount": 39.90,
    "frequency": "MONTHLY",
    "start_date": "2023-06-15",
    "end_date": null,
    "is_active": true,
    "account": { ... },
    "category": { ... }
  },
  "generated_transactions": [
    {
      "id": "exp-100",
      "transaction_date": "2024-01-15",
      "amount": 39.90,
      "status": "PAID"
    },
    {
      "id": "exp-099",
      "transaction_date": "2023-12-15",
      "amount": 39.90,
      "status": "PAID"
    }
  ],
  "statistics": {
    "total_generated": 8,
    "total_amount": 319.20,
    "average_amount": 39.90,
    "first_occurrence": "2023-06-15",
    "last_occurrence": "2024-01-15"
  }
}
```

---

## Modelo de Dados

### RecurringIncome/Expense/Transfer

```typescript
interface RecurringTransaction {
  id: string;
  description: string;
  amount: number;
  account_id?: string;
  card_id?: string;
  category_id: string;
  subcategory_id?: string;
  frequency: TransactionFrequency;
  start_date: string;           // YYYY-MM-DD
  end_date?: string;            // YYYY-MM-DD
  is_active: boolean;
  account?: Account;
  card?: Card;
  category?: Category;
  subcategory?: Subcategory;
  tags?: Tag[];
  created_at: string;
  updated_at: string;
}

type TransactionFrequency =
  | 'DAILY'
  | 'WEEKLY'
  | 'BIWEEKLY'
  | 'MONTHLY'
  | 'BIMONTHLY'
  | 'QUARTERLY'
  | 'YEARLY';
```

---

## Endpoints de Recorrentes

### Criar Receita Recorrente

```http
POST /api/v1/recurring-incomes
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
Content-Type: application/json
```

```json
{
  "description": "Salario",
  "amount": 5000.00,
  "account_id": "acc-123",
  "category_id": "cat-salario",
  "frequency": "MONTHLY",
  "start_date": "2024-01-05",
  "is_active": true
}
```

### Criar Despesa Recorrente

```http
POST /api/v1/recurring-expenses
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
Content-Type: application/json
```

```json
{
  "description": "Aluguel",
  "amount": 2000.00,
  "account_id": "acc-123",
  "category_id": "cat-moradia",
  "subcategory_id": "subcat-aluguel",
  "frequency": "MONTHLY",
  "start_date": "2024-01-10",
  "is_active": true
}
```

### Criar Transferencia Recorrente

```http
POST /api/v1/recurring-transfers
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
Content-Type: application/json
```

```json
{
  "description": "Reserva mensal",
  "amount": 500.00,
  "source_account_id": "acc-corrente",
  "destination_account_id": "acc-poupanca",
  "frequency": "MONTHLY",
  "start_date": "2024-01-01",
  "is_active": true
}
```

---

## Exemplos

### cURL - Listar Pendentes

```bash
curl -X GET "http://localhost:8080/api/v1/reconciliation/pending?account_id=$ACCOUNT" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Workspace-ID: $WORKSPACE"
```

### JavaScript

```javascript
// Listar transacoes pendentes
const { data: pending } = await api.get('/reconciliation/pending');

// Listar todas recorrentes
const { data: recurring } = await api.get('/reconciliation/recurring');

// Calcular projecao
const { data: projection } = await api.get(
  `/reconciliation/projection/${recurringId}`,
  { params: { type: 'expense' } }
);

// Criar despesa recorrente
const { data: newRecurring } = await api.post('/recurring-expenses', {
  description: 'Streaming',
  amount: 55.90,
  account_id: accountId,
  category_id: categoryId,
  frequency: 'MONTHLY',
  start_date: '2024-02-01'
});
```

---

## Calculo de Frequencias

| Frequencia | Calculo |
|------------|---------|
| DAILY | +1 dia |
| WEEKLY | +7 dias |
| BIWEEKLY | +14 dias |
| MONTHLY | +1 mes (mesmo dia) |
| BIMONTHLY | +2 meses |
| QUARTERLY | +3 meses |
| YEARLY | +1 ano |

:::info Tratamento de Datas
Para frequencias mensais, se o dia nao existe no mes destino (ex: 31 em fevereiro), usa o ultimo dia do mes.
:::
