---
sidebar_position: 6
---

# Transactions (Transacoes)

Endpoints para gerenciar transacoes financeiras: receitas, despesas e transferencias.

## Endpoints - Receitas (Incomes)

| Metodo | Endpoint | Descricao |
|--------|----------|-----------|
| GET | `/incomes?account_id=` | Listar receitas |
| POST | `/incomes` | Criar receita |
| GET | `/incomes/:id` | Obter receita |
| PUT | `/incomes/:id` | Atualizar receita |
| DELETE | `/incomes/:id` | Deletar receita |

## Endpoints - Despesas (Expenses)

| Metodo | Endpoint | Descricao |
|--------|----------|-----------|
| GET | `/expenses?account_id=` | Listar despesas |
| POST | `/expenses` | Criar despesa |
| GET | `/expenses/:id` | Obter despesa |
| PUT | `/expenses/:id` | Atualizar despesa |
| DELETE | `/expenses/:id` | Deletar despesa |

## Endpoints - Transferencias

| Metodo | Endpoint | Descricao |
|--------|----------|-----------|
| GET | `/transfers` | Listar transferencias |
| POST | `/transfers` | Criar transferencia |
| GET | `/transfers/:id` | Obter transferencia |
| PUT | `/transfers/:id` | Atualizar transferencia |
| DELETE | `/transfers/:id` | Deletar transferencia |

---

## Criar Receita

```http
POST /api/v1/incomes
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
Content-Type: application/json
```

**Request Body:**

```json
{
  "transaction_date": "2024-01-15",
  "description": "Salario Janeiro",
  "amount": 5000.00,
  "account_id": "acc-123-456",
  "category_id": "cat-salario",
  "subcategory_id": "subcat-clt",
  "transaction_status": "PAID"
}
```

**Campos:**

| Campo | Tipo | Obrigatorio | Descricao |
|-------|------|-------------|-----------|
| `transaction_date` | string | Sim | Data (YYYY-MM-DD) |
| `description` | string | Sim | Descricao |
| `amount` | number | Sim | Valor (> 0) |
| `account_id` | string | Sim | UUID da conta |
| `category_id` | string | Sim | UUID da categoria |
| `subcategory_id` | string | Nao | UUID da subcategoria |
| `recurring_income_id` | string | Nao | UUID da recorrencia |
| `transaction_status` | string | Nao | Status (default: VALIDATING) |

**Response (201 Created):**

```json
{
  "id": "inc-123-456",
  "transaction_date": "2024-01-15",
  "description": "Salario Janeiro",
  "amount": 5000.00,
  "account_id": "acc-123-456",
  "category_id": "cat-salario",
  "subcategory_id": "subcat-clt",
  "transaction_status": "PAID",
  "account": { ... },
  "category": { ... },
  "subcategory": { ... },
  "tags": [],
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

---

## Criar Despesa

```http
POST /api/v1/expenses
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
Content-Type: application/json
```

**Request Body:**

```json
{
  "transaction_date": "2024-01-16",
  "description": "Supermercado Extra",
  "amount": 250.50,
  "account_id": "acc-123-456",
  "category_id": "cat-alimentacao",
  "subcategory_id": "subcat-supermercado",
  "transaction_status": "PAID"
}
```

**Response (201 Created):**

```json
{
  "id": "exp-123-456",
  "transaction_date": "2024-01-16",
  "description": "Supermercado Extra",
  "amount": 250.50,
  "account_id": "acc-123-456",
  "category_id": "cat-alimentacao",
  "subcategory_id": "subcat-supermercado",
  "transaction_status": "PAID",
  "account": { ... },
  "category": { ... },
  "subcategory": { ... },
  "tags": [],
  "created_at": "2024-01-16T14:00:00Z",
  "updated_at": "2024-01-16T14:00:00Z"
}
```

---

## Criar Transferencia

```http
POST /api/v1/transfers
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
Content-Type: application/json
```

**Request Body:**

```json
{
  "transaction_date": "2024-01-17",
  "amount": 1000.00,
  "source_account_id": "acc-corrente",
  "destination_account_id": "acc-poupanca",
  "description": "Reserva mensal",
  "transaction_status": "PAID"
}
```

**Response (201 Created):**

```json
{
  "id": "trf-123-456",
  "transaction_date": "2024-01-17",
  "amount": 1000.00,
  "source_account_id": "acc-corrente",
  "destination_account_id": "acc-poupanca",
  "description": "Reserva mensal",
  "transaction_status": "PAID",
  "source_account": { ... },
  "destination_account": { ... },
  "created_at": "2024-01-17T09:00:00Z",
  "updated_at": "2024-01-17T09:00:00Z"
}
```

:::warning Validacao
`source_account_id` e `destination_account_id` devem ser diferentes.
:::

---

## Listar Transacoes

### Listar Receitas

```http
GET /api/v1/incomes?account_id={account_id}
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
```

**Query Parameters:**

| Parametro | Tipo | Obrigatorio | Descricao |
|-----------|------|-------------|-----------|
| `account_id` | UUID | Sim | ID da conta |

### Listar Despesas

```http
GET /api/v1/expenses?account_id={account_id}
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
```

### Listar Transferencias

```http
GET /api/v1/transfers
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
```

---

## Atualizar Transacao

```http
PUT /api/v1/incomes/:id
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
Content-Type: application/json
```

**Request Body:**

```json
{
  "transaction_date": "2024-01-15",
  "description": "Salario Janeiro - Ajustado",
  "amount": 5100.00,
  "account_id": "acc-123-456",
  "category_id": "cat-salario",
  "transaction_status": "PAID"
}
```

---

## Deletar Transacao

```http
DELETE /api/v1/expenses/:id
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
```

**Response (200 OK):**

```json
{
  "message": "Expense deleted successfully"
}
```

:::info Soft Delete
Transacoes nao sao removidas fisicamente, apenas marcadas com `deleted_at`.
:::

---

## Status de Transacao

| Status | Descricao |
|--------|-----------|
| `VALIDATING` | Em validacao (default) |
| `PAID` | Paga/Confirmada |
| `PENDING` | Pendente |
| `IGNORE` | Ignorar (nao afeta saldo) |

---

## Modelo de Dados

### Income

```typescript
interface Income {
  id: string;
  transaction_date: string;        // YYYY-MM-DD
  description: string;
  amount: number;                  // Decimal > 0
  account_id: string;
  category_id: string;
  subcategory_id?: string;
  recurring_income_id?: string;
  transaction_status: TransactionStatus;
  account?: Account;
  category?: Category;
  subcategory?: Subcategory;
  tags?: Tag[];
  deleted_at?: string;
  created_at: string;
  updated_at: string;
}
```

### Expense

```typescript
interface Expense {
  id: string;
  transaction_date: string;
  description: string;
  amount: number;
  account_id: string;
  category_id: string;
  subcategory_id?: string;
  recurring_expense_id?: string;
  transaction_status: TransactionStatus;
  account?: Account;
  category?: Category;
  subcategory?: Subcategory;
  tags?: Tag[];
  deleted_at?: string;
  created_at: string;
  updated_at: string;
}
```

### Transfer

```typescript
interface Transfer {
  id: string;
  transaction_date: string;
  amount: number;
  source_account_id: string;
  destination_account_id: string;
  description?: string;
  recurring_transfer_id?: string;
  transaction_status: TransactionStatus;
  source_account?: Account;
  destination_account?: Account;
  deleted_at?: string;
  created_at: string;
  updated_at: string;
}
```

---

## Exemplos

### cURL - Criar Receita

```bash
curl -X POST http://localhost:8080/api/v1/incomes \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..." \
  -H "X-Workspace-ID: ws-123-456" \
  -H "Content-Type: application/json" \
  -d '{
    "transaction_date": "2024-01-15",
    "description": "Freelance Projeto X",
    "amount": 2500.00,
    "account_id": "acc-123-456",
    "category_id": "cat-freelance",
    "transaction_status": "PAID"
  }'
```

### JavaScript

```javascript
// Criar despesa
const expense = await api.post('/expenses', {
  transaction_date: '2024-01-16',
  description: 'Uber',
  amount: 35.90,
  account_id: accountId,
  category_id: categoryId,
  transaction_status: 'PAID'
});

// Listar despesas de uma conta
const { data: expenses } = await api.get('/expenses', {
  params: { account_id: accountId }
});

// Criar transferencia
const transfer = await api.post('/transfers', {
  transaction_date: '2024-01-17',
  amount: 500,
  source_account_id: contaCorrente,
  destination_account_id: poupanca,
  description: 'Reserva'
});
```

## Fluxo de Transacao

```mermaid
sequenceDiagram
    participant C as Cliente
    participant A as API
    participant UC as UseCase
    participant DB as Database

    C->>A: POST /expenses
    A->>A: Validar autenticacao
    A->>A: Validar workspace
    A->>A: Validar body
    A->>UC: CreateExpense(ctx, expense)
    UC->>UC: Validar account pertence ao workspace
    UC->>UC: Validar category pertence ao workspace
    UC->>DB: INSERT INTO expenses
    DB-->>UC: expense
    UC-->>A: expense
    A-->>C: 201 Created + JSON
```
