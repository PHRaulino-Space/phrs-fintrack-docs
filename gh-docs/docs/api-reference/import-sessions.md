---
sidebar_position: 7
title: Import Sessions API
description: Referência completa da API de Import Sessions
---

# Import Sessions API

API para gerenciamento do ciclo de vida de importação de transações.

## Endpoints da Sessão

### Criar Sessão

Cria uma nova sessão de importação vinculada ao workspace.

```http
POST /import-sessions
```

**Headers:**
- `x-workspace-id`: UUID do workspace (obrigatório)
- `Authorization`: Bearer token

**Request Body:**

```json
{
  "account_id": "uuid-da-conta",       // Contexto de conta
  "card_id": "uuid-do-cartao",         // Contexto de cartão
  "billing_month": "2024-01",          // Mês de referência (YYYY-MM)
  "target_value": 1500.00              // Opcional, default: 0
}
```

:::info Regras de Criação
- Deve informar `account_id` **OU** `card_id` (não ambos)
- O `billing_month` é obrigatório
- Para contexto de cartão, o `target_value` padrão é a soma dos pagamentos do cartão para aquele mês
- A fatura do cartão deve estar com status `OPEN` ou será criada automaticamente
- Se a fatura existir em status diferente de `OPEN`, retorna erro 400
:::

**Response (201 Created):**

```json
{
  "id": "uuid-da-sessao",
  "workspace_id": "uuid-workspace",
  "user_id": "uuid-usuario",
  "description": "Nubank | 2024-01",
  "account_id": null,
  "card_id": "uuid-cartao",
  "billing_month": "2024-01",
  "target_value": 1500.00,
  "created_at": "2024-01-15T10:30:00Z"
}
```

---

### Listar Sessões

Lista todas as sessões de importação do workspace.

```http
GET /import-sessions
```

**Response (200 OK):**

```json
[
  {
    "id": "uuid-sessao-1",
    "description": "Nubank | 2024-01",
    "type": "card",
    "target_value": 1500.00,
    "stats": {
      "ready": 40,
      "total": 45
    }
  }
]
```

---

### Obter Sessão

Retorna detalhes completos de uma sessão com contexto para ajudar o usuário.

```http
GET /import-sessions/:id
```

**Response (200 OK):**

```json
{
  "id": "uuid-sessao",
  "description": "Nubank | 2024-01",
  "type": "card",
  "target_value": 1500.00,
  "initial_balance": 0,
  "context_value": 1450.00,
  "stats": {
    "ready": 40,
    "total": 45
  },
  "status": "pending",
  "transactions": [...]
}
```

| Campo | Descrição |
|-------|-----------|
| `name` | Nome da sessão |
| `type` | Tipo (conta ou cartão) |
| `target_value` | Valor alvo para conciliação |
| `initial_balance` | Saldo no início do mês (ver cálculo abaixo) |
| `context_value` | Saldo atual calculado (ver cálculo abaixo) |
| `transactions` | Lista de todas as transações da sessão |
| `stats` | Contagem de transações `ready` vs `total` |
| `status` | `ok` se todas `READY` e `target_value == context_value` (não impeditivo) |

**Cálculo do `initial_balance` (Contexto de Conta):**
```
initial_balance = Soma de todas as transações da conta com data < primeiro dia do billing_month
```

Tabelas e operações:
- `incomes`: `+ amount`
- `expenses`: `- amount`
- `transfers`: `- amount` (source) / `+ amount` (destination)
- `card_payments`: `- amount`
- `investment_deposits`: `- amount`
- `investment_withdrawals`: `+ amount`

**Cálculo do `initial_balance` (Contexto de Cartão):**
```
initial_balance = card_expenses - card_chargebacks (sem staged_transactions)
```

**Cálculo do `context_value` (Contexto de Conta):**
```
context_value = initial_balance + transações do mês + staged_transactions
```

**Cálculo do `context_value` (Contexto de Cartão):**
```
context_value = initial_balance + staged_transactions
             = (card_expenses - card_chargebacks) + staged_transactions
```

**Conciliação:** `status = ok` quando `target_value == context_value`

---

### Excluir Sessão

Remove a sessão e todas as suas staged transactions.

```http
DELETE /import-sessions/:id
```

**Response:** `204 No Content`

---

### Commit Session

Efetiva todas as transações com status `READY` nas tabelas principais do banco.

```http
POST /import-sessions/:id/commit
```

**Comportamento:**
- Transações `READY` são salvas com status `VALIDATING`
- Transações com `ignore: true` no JSON são salvas com status `IGNORE`

**Response (200 OK):**

```json
{
  "message": "Session committed successfully"
}
```

---

### Close Session

Concilia a sessão e encerra o processo de importação.

```http
POST /import-sessions/:id/close
```

**Comportamento para Contexto de Conta:**
- Altera status das transações de `VALIDATING` para `PAID`
- Exclui a sessão

**Comportamento para Contexto de Cartão:**
- Altera status das transações de `VALIDATING` para `PAID`
- Altera status da fatura para `PAID`
- Exclui a sessão

**Response (200 OK):**

```json
{
  "message": "Session closed and reconciled successfully"
}
```

---

### Vincular Transação Recorrente

Vincula uma staged transaction a uma transação recorrente, herdando suas configurações.

```http
POST /import-sessions/:id/bind
```

**Request Body:**

```json
{
  "staged_transaction_id": "uuid-staged-transaction",
  "recurring_transaction_id": "uuid-recurring-transaction"
}
```

**Identificação do tipo de recurring:**

O sistema busca o `recurring_transaction_id` nas tabelas na seguinte ordem:

| Tabela | Tipo resultante |
|--------|-----------------|
| `recurring_incomes` | `INCOME` |
| `recurring_expenses` | `EXPENSE` |
| `recurring_transfers` | `TRANSFER` |
| `recurring_card_transactions` | `CARD_EXPENSE` |

**Campos herdados pela staged transaction:**

| Campo | Origem |
|-------|--------|
| `type` | Tipo da recurring |
| `data.description` | `recurring.description` |
| `data.category_id` | `recurring.category_id` |
| `data.subcategory_id` | `recurring.subcategory_id` (se existir) |
| `data.recurring_*_id` | ID da recurring vinculada |

**Campos adicionados ao JSON `data`:**

| Tipo de Recurring | Campo |
|-------------------|-------|
| Recurring Income | `recurring_income_id` |
| Recurring Expense | `recurring_expense_id` |
| Recurring Transfer | `recurring_transfer_id` |
| Recurring Card Transaction | `recurring_card_transaction_id` |

**Exemplo de resposta da staged transaction após bind:**

```json
{
  "id": "uuid-staged",
  "type": "EXPENSE",
  "status": "READY",
  "amount": 49.90,
  "data": {
    "description": "Netflix - Assinatura Mensal",
    "category_id": "uuid-categoria-streaming",
    "subcategory_id": "uuid-subcategoria-video",
    "recurring_expense_id": "uuid-recurring-netflix"
  }
}
```

:::info Status após bind
Se a staged transaction passar a ter todos os campos obrigatórios após o bind, seu status é atualizado para `READY`.
:::

**Response (200 OK):**

```json
{
  "message": "Transaction bound successfully"
}
```

---

## Endpoints de Staged Transactions

### Criar Transações

Cria múltiplas staged transactions em uma sessão.

```http
POST /import-sessions/:id/staged-transactions
```

**Request Body:**

```json
[
  {
    "transaction_date": "2024-01-05",
    "description": "UBER *VIAGEM",
    "amount": 50.00
  },
  {
    "transaction_date": "2024-01-06",
    "description": "PIX RECEBIDO",
    "amount": -150.00
  }
]
```

:::tip Regra de Sinais
**Contexto de Conta:**
- Positivo → `INCOME` (receita)
- Negativo → `EXPENSE` (despesa)

**Contexto de Cartão:**
- Positivo → `CARD_EXPENSE` (despesa)
- Negativo → `CARD_CHARGEBACK` (estorno)
:::

**Response (201 Created):** Array das transações criadas

---

### Excluir Todas as Transações

Remove todas as staged transactions de uma sessão.

```http
DELETE /import-sessions/:id/staged-transactions
```

**Response:** `204 No Content`

---

### Obter Transação

Retorna o objeto completo de uma staged transaction junto com o JSON de atributos.

```http
GET /staged-transactions/:id
```

**Response (200 OK):**

```json
{
  "id": "uuid-transaction",
  "session_id": "uuid-session",
  "type": "EXPENSE",
  "status": "READY",
  "transaction_date": "2024-01-05",
  "amount": 50.00,
  "data": {
    "description": "UBER *VIAGEM",
    "category_id": "uuid-categoria",
    "subcategory_id": "uuid-subcategoria"
  },
  "line_number": 1
}
```

---

### Atualizar Transação

Atualiza uma staged transaction substituindo os dados no banco.

```http
PUT /staged-transactions/:id
```

**Request Body:**

```json
{
  "type": "EXPENSE",
  "status": "READY",
  "transaction_date": "2024-01-05",
  "amount": 55.00,
  "data": {
    "description": "UBER *VIAGEM CORRIGIDO",
    "category_id": "uuid-nova-categoria"
  }
}
```

:::warning Validações
- Os campos principais (`transaction_date`, `amount`) não podem ser nulos ou inválidos
- O `type` deve respeitar as constantes válidas
- O campo `data` (JSON) não passa por validação de schema
:::

**Response (200 OK):** Transação atualizada

---

## Tipos e Enums

### StagedTransactionType

**Contexto de Conta:**
| Valor | Descrição |
|-------|-----------|
| `INCOME` | Receita |
| `EXPENSE` | Despesa |
| `TRANSFER` | Transferência entre contas |
| `CARD_PAYMENT` | Pagamento de fatura de cartão |
| `INVESTMENT_DEPOSIT` | Depósito em investimentos |
| `INVESTMENT_WITHDRAWAL` | Saque de investimentos |

**Contexto de Cartão:**
| Valor | Descrição |
|-------|-----------|
| `CARD_EXPENSE` | Despesa de cartão |
| `CARD_CHARGEBACK` | Estorno de cartão |

### StagedTransactionStatus

| Valor | Descrição |
|-------|-----------|
| `PENDING` | Faltam informações para salvar na base |
| `READY` | Pronta para ser efetivada |
| `PROCESSING` | Sendo processada pela IA |

---

## Códigos de Erro

| Código | Descrição |
|--------|-----------|
| `400` | Request inválido (falta account_id ou card_id, fatura não está OPEN, etc.) |
| `401` | Não autorizado |
| `403` | Permissão insuficiente |
| `404` | Sessão ou transação não encontrada |
| `500` | Erro interno do servidor |
