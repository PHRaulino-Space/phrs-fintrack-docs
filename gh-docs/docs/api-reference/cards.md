---
sidebar_position: 4
---

# Cards (Cartoes de Credito)

Endpoints para gerenciar cartoes de credito e suas faturas.

## Endpoints

| Metodo | Endpoint | Descricao |
|--------|----------|-----------|
| GET | `/cards` | Listar cartoes do workspace |
| GET | `/cards/:id` | Obter cartao por ID |

## Listar Cartoes

```http
GET /api/v1/cards
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
```

**Response (200 OK):**

```json
[
  {
    "id": "card-123-456-789",
    "name": "Nubank Mastercard",
    "credit_limit": 5000.00,
    "workspace_id": "ws-123-456",
    "closing_date": 25,
    "due_date": 10,
    "is_active": true,
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  },
  {
    "id": "card-789-012-345",
    "name": "Inter Black",
    "credit_limit": 10000.00,
    "workspace_id": "ws-123-456",
    "closing_date": 15,
    "due_date": 5,
    "is_active": true,
    "created_at": "2024-01-20T14:00:00Z",
    "updated_at": "2024-01-20T14:00:00Z"
  }
]
```

## Obter Cartao

```http
GET /api/v1/cards/:id
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
```

**Response (200 OK):**

```json
{
  "id": "card-123-456-789",
  "name": "Nubank Mastercard",
  "credit_limit": 5000.00,
  "workspace_id": "ws-123-456",
  "closing_date": 25,
  "due_date": 10,
  "is_active": true,
  "invoices": [
    {
      "card_id": "card-123-456-789",
      "billing_month": "2024-01",
      "status": "PAID"
    },
    {
      "card_id": "card-123-456-789",
      "billing_month": "2024-02",
      "status": "OPEN"
    }
  ],
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

## Modelo de Dados

### Card

```typescript
interface Card {
  id: string;           // UUID
  name: string;         // 1-100 caracteres
  credit_limit: number; // Decimal 15,2 (>= 0)
  workspace_id: string; // UUID
  closing_date: number; // Dia do fechamento (1-31)
  due_date: number;     // Dia do vencimento (1-31)
  is_active: boolean;
  invoices?: Invoice[]; // Relacionamento
  deleted_at?: string;  // Soft delete
  created_at: string;   // ISO 8601
  updated_at: string;   // ISO 8601
}
```

### Invoice (Fatura)

```typescript
interface Invoice {
  card_id: string;         // UUID (PK)
  billing_month: string;   // YYYY-MM (PK)
  status: InvoiceStatus;
  card_expenses?: CardExpense[];
  card_payments?: CardPayment[];
  created_at: string;
  updated_at: string;
}

type InvoiceStatus = 'OPEN' | 'PAID' | 'OVERDUE';
```

### CardExpense (Despesa no Cartao)

```typescript
interface CardExpense {
  id: string;
  transaction_date: string;    // YYYY-MM-DD
  description: string;
  amount: number;              // Decimal > 0
  category_id: string;
  subcategory_id?: string;
  card_id: string;
  billing_month: string;       // YYYY-MM
  recurring_card_transaction_id?: string;
  transaction_status: TransactionStatus;
  created_at: string;
  updated_at: string;
}
```

### CardPayment (Pagamento de Fatura)

```typescript
interface CardPayment {
  id: string;
  transaction_date: string;    // YYYY-MM-DD
  amount: number;              // Decimal > 0
  account_id: string;          // Conta de onde sai o pagamento
  card_id: string;
  billing_month: string;       // YYYY-MM
  is_final_payment: boolean;   // Se quita a fatura
  transaction_status: TransactionStatus;
  created_at: string;
  updated_at: string;
}
```

## Ciclo da Fatura

```mermaid
graph LR
    subgraph "Periodo de Compras"
        C1[Compra 1] --> F[Fatura]
        C2[Compra 2] --> F
        C3[Compra N] --> F
    end

    F --> |Fechamento| FC[Fatura Fechada]
    FC --> |Vencimento| V{Pagamento?}
    V --> |Sim| PAID[PAID]
    V --> |Nao| OVERDUE[OVERDUE]
```

### Exemplo de Ciclo

| Data | Evento |
|------|--------|
| 01/01 - 25/01 | Compras vao para fatura Janeiro |
| 25/01 | **Fechamento** - Fatura Janeiro fecha |
| 26/01 - 25/02 | Compras vao para fatura Fevereiro |
| 10/02 | **Vencimento** - Pagamento fatura Janeiro |

## Calculos

### Valor Total da Fatura

```sql
SELECT SUM(amount) as total
FROM card_expenses
WHERE card_id = ? AND billing_month = ?
AND transaction_status != 'IGNORE';
```

### Valor Pago

```sql
SELECT SUM(amount) as paid
FROM card_payments
WHERE card_id = ? AND billing_month = ?
AND transaction_status = 'PAID';
```

### Saldo Devedor

```
Saldo = Total da Fatura - Valor Pago
```

## Exemplos

### cURL - Listar Cartoes

```bash
curl -X GET http://localhost:8080/api/v1/cards \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..." \
  -H "X-Workspace-ID: ws-123-456"
```

### JavaScript

```javascript
// Listar cartoes
const { data: cards } = await api.get('/cards');

// Obter cartao com faturas
const { data: card } = await api.get(`/cards/${cardId}`);

// Acessar faturas
card.invoices.forEach(invoice => {
  console.log(`${invoice.billing_month}: ${invoice.status}`);
});
```

## Status da Fatura

| Status | Descricao | Condicao |
|--------|-----------|----------|
| `OPEN` | Aberta | Antes do vencimento, aceita despesas |
| `PAID` | Paga | `is_final_payment = true` registrado |
| `OVERDUE` | Vencida | Apos vencimento sem pagamento total |

:::warning Atencao
Despesas so podem ser adicionadas a faturas com status `OPEN`.
:::
