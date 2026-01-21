# Análise de Gaps - Import Session API

Este documento apresenta uma análise completa comparando a documentação de requisitos (`CONTEXT.md` e `IMPLEMENTATION_PENDING.md`) com a implementação atual da API.

---

## Resumo Executivo

| Status | Quantidade |
|--------|------------|
| Implementado | 12 |
| Pendente | 3 |
| **Total de Requisitos** | **15** |

---

## Legenda

- [x] **Implementado** - Funcionalidade já existe no código
- [ ] **Pendente** - Funcionalidade precisa ser implementada

---

## 1. Create Session

**Endpoint:** `POST /import-sessions`

### 1.1 Nome da Sessão (description)

| Requisito | Status |
|-----------|--------|
| Formato: `"{name} \| {billing_month}"` | [x] Implementado |

**Implementação atual:** `backend/internal/usecase/import.go:106,114`

```go
description = account.Name + " | " + session.BillingMonth
// ou
description = card.Name + " | " + session.BillingMonth
```

---

### 1.2 Target Value Default (Contexto de Cartão)

| Requisito | Status |
|-----------|--------|
| Default = Soma dos `card_payments` para o `card_id` e `billing_month` | [x] Implementado |

**Implementação atual:** `backend/internal/usecase/import.go:132-139`

```go
if session.TargetValue == 0 {
    sum, err := uc.repo.GetCardPaymentsSum(ctx, *session.CardID, session.BillingMonth)
    if err != nil {
        return fmt.Errorf("failed to calculate target value: %w", err)
    }
    session.TargetValue = sum
}
```

**Método no repositório:** `backend/internal/usecase/repo/import_postgres.go:675-688`

---

### 1.3 Validação/Criação de Fatura (Contexto de Cartão)

| Requisito | Status |
|-----------|--------|
| Validar status da fatura (deve ser OPEN) | [x] Implementado |
| Criar fatura automaticamente se não existir | [x] Implementado |

**Implementação atual:** `backend/internal/usecase/import.go:117-130`

```go
invoice, err := uc.repo.GetInvoice(ctx, *session.CardID, session.BillingMonth)
if err != nil {
    // Invoice doesn't exist, create with OPEN status
    invoice = &entity.Invoice{
        CardID:       *session.CardID,
        BillingMonth: session.BillingMonth,
        Status:       entity.InvoiceStatusOpen,
    }
    if err := uc.repo.CreateInvoice(ctx, invoice); err != nil {
        return fmt.Errorf("failed to create invoice: %w", err)
    }
} else if invoice.Status != entity.InvoiceStatusOpen {
    return fmt.Errorf("%w: invoice status must be OPEN, current: %s", ErrValidation, invoice.Status)
}
```

---

## 2. Create Staged Transactions

**Endpoint:** `POST /import-sessions/:id/staged-transactions`

### 2.1 Auto-detecção de Tipo pelo Sinal do Valor

| Requisito | Status |
|-----------|--------|
| Detectar tipo pelo sinal do `amount` | [x] Implementado |

**Regras:**
- **Contexto de Conta:** Positivo = INCOME, Negativo = EXPENSE
- **Contexto de Cartão:** Positivo = CARD_EXPENSE, Negativo = CARD_CHARGEBACK

**Implementação atual:** `backend/internal/usecase/import.go:269-291`

```go
if transactions[i].Type == "" {
    if session.AccountID != nil {
        if transactions[i].Amount >= 0 {
            transactions[i].Type = entity.StagedTransactionTypeIncome
        } else {
            transactions[i].Type = entity.StagedTransactionTypeExpense
        }
    } else if session.CardID != nil {
        if transactions[i].Amount >= 0 {
            transactions[i].Type = entity.StagedTransactionTypeCardExpense
        } else {
            transactions[i].Type = entity.StagedTransactionTypeCardChargeback
        }
    }
}
```

---

## 3. Get Session

**Endpoint:** `GET /import-sessions/:id`

### 3.1 Campos Enriched na Resposta

| Campo | Status |
|-------|--------|
| `type` ("account" ou "card") | [x] Implementado |
| `initial_balance` | [x] Implementado |
| `context_value` | [x] Implementado |
| `transactions` | [x] Implementado |
| `stats` (`{ ready: N, total: M }`) | [x] Implementado |
| `status` ("ok" ou "pending") | [x] Implementado |

**Implementação atual:** `backend/internal/usecase/import.go:156-243`

**Struct de resposta:**
```go
type ImportSessionResponse struct {
    entity.ImportSession
    Type           string                     `json:"type"`
    InitialBalance float64                    `json:"initial_balance"`
    ContextValue   float64                    `json:"context_value"`
    Transactions   []entity.StagedTransaction `json:"transactions"`
    Stats          SessionStats               `json:"stats"`
    Status         string                     `json:"status"`
}
```

### 3.2 Cálculo do initial_balance

**Contexto de Conta:** `backend/internal/usecase/repo/import_postgres.go:691-761`
- Incomes (+)
- Expenses (-)
- Transfers Source (-)
- Transfers Destination (+)
- Card Payments (-)
- Investment Deposits (-)
- Investment Withdrawals (+)

**Contexto de Cartão:** `backend/internal/usecase/repo/import_postgres.go:764-793`
- Card Expenses - Card Chargebacks

### 3.3 Cálculo do context_value

**Contexto de Conta:** `initial_balance + month_transactions + staged_sum`
**Contexto de Cartão:** `initial_balance + staged_sum`

### 3.4 Cálculo do status

```go
if stats.Ready == stats.Total && session.TargetValue == contextValue {
    status = "ok"
} else {
    status = "pending"
}
```

---

## 4. List Sessions

**Endpoint:** `GET /import-sessions`

### 4.1 Campo type na Listagem

| Requisito | Status |
|-----------|--------|
| Retornar campo `type` ("account" ou "card") | [ ] **PENDENTE** |

**Problema:** O endpoint `ListImportSessions` retorna apenas o `entity.ImportSession` que não possui o campo `type` calculado.

**Arquivo:** `backend/internal/usecase/repo/import_postgres.go:205-272`

**Solução proposta:** Criar uma struct de resposta para listagem que inclua o campo `type`:

```go
type ImportSessionListItem struct {
    entity.ImportSession
    Type  string         `json:"type"`
    Stats SessionStats   `json:"stats"`
}

// No repositório ou use case, calcular:
for i := range sessions {
    if sessions[i].CardID != nil && *sessions[i].CardID != uuid.Nil {
        listItems[i].Type = "card"
    } else {
        listItems[i].Type = "account"
    }
}
```

### 4.2 Stats por Status (ready/total)

| Requisito | Status |
|-----------|--------|
| Stats no formato `{ ready: N, total: M }` | [x] Implementado |

**Implementação atual:** `backend/internal/usecase/repo/import_postgres.go:247-269`

---

## 5. Commit Session

**Endpoint:** `POST /import-sessions/:id/commit`

### 5.1 Status VALIDATING

| Requisito | Status |
|-----------|--------|
| Salvar transações com status `VALIDATING` | [x] Implementado |

**Implementação atual:** `backend/internal/usecase/repo/import_postgres.go:388`

```go
transactionStatus := entity.TransactionStatusValidating
```

### 5.2 Tratamento de ignore: true

| Requisito | Status |
|-----------|--------|
| Salvar com status `IGNORE` quando `ignore: true` no JSON | [x] Implementado |

**Implementação atual:** `backend/internal/usecase/repo/import_postgres.go:388-391`

```go
transactionStatus := entity.TransactionStatusValidating
if d.Ignore {
    transactionStatus = entity.TransactionStatusIgnore
}
```

---

## 6. Close Session

**Endpoint:** `POST /import-sessions/:id/close`

### 6.1 Filtro por Status VALIDATING

| Requisito | Status |
|-----------|--------|
| Atualizar apenas transações com status `VALIDATING` | [x] Implementado |

**Implementação atual:** `backend/internal/usecase/repo/import_postgres.go:296,301,313`

```go
Where("account_id = ? AND transaction_status = ?", accountID, entity.TransactionStatusValidating)
```

### 6.2 Atualizar Status da Fatura (Contexto de Cartão)

| Requisito | Status |
|-----------|--------|
| Alterar status da fatura para `PAID` | [x] Implementado |

**Implementação atual:** `backend/internal/usecase/repo/import_postgres.go:319-323`

```go
if err := tx.Table("invoices").
    Where("card_id = ? AND billing_month = ?", cardID, billingMonth).
    Update("status", entity.InvoiceStatusPaid).Error; err != nil {
    return fmt.Errorf("failed to update invoice status: %w", err)
}
```

---

## 7. Bind Recurring

**Endpoint:** `POST /import-sessions/:id/bind`

### 7.1 Alterar Tipo da Staged Transaction

| Requisito | Status |
|-----------|--------|
| Herdar tipo da recurring transaction | [x] Implementado |

**Implementação atual:** `backend/internal/usecase/import.go:546-558`

```go
switch finalRecurringType {
case entity.RecurringTypeIncome:
    tx.Type = entity.StagedTransactionTypeIncome
case entity.RecurringTypeExpense:
    tx.Type = entity.StagedTransactionTypeExpense
case entity.RecurringTypeTransfer:
    tx.Type = entity.StagedTransactionTypeTransfer
case entity.RecurringTypeCardTransaction:
    tx.Type = entity.StagedTransactionTypeCardExpense
}
```

### 7.2 Busca Automática do Tipo de Recurring

| Requisito | Status |
|-----------|--------|
| Buscar tipo automaticamente nas tabelas | [x] Implementado |

**Implementação atual:** `backend/internal/usecase/import.go:473-495`

```go
func (uc *ImportUseCaseImpl) FindRecurringType(ctx context.Context, recurringID uuid.UUID) (entity.RecurringType, error) {
    // Busca em ordem nas tabelas de recurring
}
```

### 7.3 Remover recurring_type do Request

| Requisito | Status |
|-----------|--------|
| `recurring_type` não deve ser obrigatório no request | [ ] **PENDENTE** |

**Problema:** O campo `recurring_type` ainda está marcado como `binding:"required"` no DTO.

**Arquivo:** `backend/internal/controller/http/v1/import.go:224`

```go
type bindRecurringRequest struct {
    StagedTransactionID    uuid.UUID            `json:"staged_transaction_id" binding:"required"`
    RecurringTransactionID uuid.UUID            `json:"recurring_transaction_id" binding:"required"`
    RecurringType          entity.RecurringType `json:"recurring_type" binding:"required"` // <- REMOVER required
    SlotDate               string               `json:"slot_date" binding:"required"`
}
```

**Solução:** Alterar para:
```go
RecurringType entity.RecurringType `json:"recurring_type,omitempty"` // Opcional
```

---

## 8. Enum de Status

### 8.1 Renomear QUEUED para PROCESSING

| Requisito | Status |
|-----------|--------|
| Status `PROCESSING` em vez de `QUEUED` | [x] Implementado |

**Implementação atual:** `backend/internal/entity/import.go:31`

```go
StagedTransactionStatusProcessing StagedTransactionStatus = "PROCESSING"
```

---

## Itens Pendentes - Resumo de Ações

### Alta Prioridade

| # | Item | Arquivo | Ação |
|---|------|---------|------|
| 1 | List Sessions - Campo `type` | `usecase/import.go` e `repo/import_postgres.go` | Adicionar campo `type` na resposta de listagem |

### Média Prioridade

| # | Item | Arquivo | Ação |
|---|------|---------|------|
| 2 | Bind - `recurring_type` opcional | `controller/http/v1/import.go:224` | Remover `binding:"required"` do campo |

---

## Alterações Necessárias

### 1. List Sessions - Adicionar campo `type`

**Arquivo:** `backend/internal/usecase/repo/import_postgres.go`

Modificar a função `ListImportSessions` para calcular e retornar o campo `type`:

```go
// Após buscar as sessions, calcular o tipo
for i := range sessions {
    if sessions[i].CardID != nil && *sessions[i].CardID != uuid.Nil {
        // Adicionar campo Type ao retorno (precisa ajustar a struct ou criar response)
    }
}
```

**Opção 1:** Adicionar campo `Type` transient na entity `ImportSession`:
```go
type ImportSession struct {
    // ... campos existentes
    Type string `gorm:"-" json:"type,omitempty"` // Transient
}
```

**Opção 2:** Criar struct de resposta específica para listagem.

---

### 2. Bind - Tornar recurring_type opcional

**Arquivo:** `backend/internal/controller/http/v1/import.go`

**Antes:**
```go
type bindRecurringRequest struct {
    StagedTransactionID    uuid.UUID            `json:"staged_transaction_id" binding:"required"`
    RecurringTransactionID uuid.UUID            `json:"recurring_transaction_id" binding:"required"`
    RecurringType          entity.RecurringType `json:"recurring_type" binding:"required"`
    SlotDate               string               `json:"slot_date" binding:"required"`
}
```

**Depois:**
```go
type bindRecurringRequest struct {
    StagedTransactionID    uuid.UUID            `json:"staged_transaction_id" binding:"required"`
    RecurringTransactionID uuid.UUID            `json:"recurring_transaction_id" binding:"required"`
    RecurringType          entity.RecurringType `json:"recurring_type,omitempty"`
    SlotDate               string               `json:"slot_date" binding:"required"`
}
```

---

## Validação de Completude por Endpoint

| Endpoint | Método | Requisitos Atendidos | Pendências |
|----------|--------|---------------------|------------|
| `/import-sessions` | POST | 3/3 | - |
| `/import-sessions` | GET | 1/2 | Campo `type` |
| `/import-sessions/:id` | GET | 6/6 | - |
| `/import-sessions/:id` | DELETE | 1/1 | - |
| `/import-sessions/:id/staged-transactions` | POST | 1/1 | - |
| `/import-sessions/:id/staged-transactions` | GET | 1/1 | - |
| `/import-sessions/:id/staged-transactions` | DELETE | 1/1 | - |
| `/import-sessions/:id/commit` | POST | 2/2 | - |
| `/import-sessions/:id/close` | POST | 2/2 | - |
| `/import-sessions/:id/bind` | POST | 2/3 | `recurring_type` ainda required |
| `/staged-transactions/:id` | GET | 1/1 | - |
| `/staged-transactions/:id` | PUT | 1/1 | - |
| `/staged-transactions/:id` | DELETE | 1/1 | - |

---

## Conclusão

A implementação está **80% completa** em relação aos requisitos documentados. Os dois itens pendentes são de baixa complexidade e podem ser implementados rapidamente:

1. **Campo `type` na listagem** - Impacto baixo, apenas adicionar um campo calculado
2. **`recurring_type` opcional** - Impacto mínimo, apenas remover a validação required

A lógica de busca automática do tipo de recurring já está implementada (`FindRecurringType`), faltando apenas tornar o campo opcional no request.
