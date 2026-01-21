# Implementação Pendente - Import Session API

Este documento detalha todas as funcionalidades que precisam ser implementadas ou corrigidas no backend para atender aos requisitos da documentação.

---

## Sumário

1. [Create Session](#1-create-session)
2. [Create Staged Transactions](#2-create-staged-transactions)
3. [Get Session](#3-get-session)
4. [List Sessions](#4-list-sessions)
5. [Commit Session](#5-commit-session)
6. [Close Session](#6-close-session)
7. [Bind Recurring](#7-bind-recurring)
8. [Enum de Status](#8-enum-de-status)

---

## 1. Create Session

**Endpoint:** `POST /import-sessions`

### 1.1 Nome da Sessão (description)

| Item | Atual | Esperado |
|------|-------|----------|
| Formato | `"Account: {name}"` ou `"Card:{name}"` | `"{name} \| {billing_month}"` |

**Arquivo:** `backend/internal/usecase/import.go`

**Código atual:**
```go
description = "Account: " + account.Name
// ou
description = "Card:" + card.Name
```

**Código esperado:**
```go
description = account.Name + " | " + session.BillingMonth
// ou
description = card.Name + " | " + session.BillingMonth
```

---

### 1.2 Target Value Default (Contexto de Cartão)

| Item | Atual | Esperado |
|------|-------|----------|
| Default | `0` | Soma dos `card_payments` para o `card_id` e `billing_month` |

**Implementar:**
```go
// Em CreateImportSession, quando isCardContext:
if isCardContext && session.TargetValue == 0 {
    sum, err := uc.repo.GetCardPaymentsSum(ctx, *session.CardID, session.BillingMonth)
    if err != nil {
        return err
    }
    session.TargetValue = sum
}
```

**Novo método no repositório:**
```go
func (r *ImportRepo) GetCardPaymentsSum(ctx context.Context, cardID uuid.UUID, billingMonth string) (float64, error) {
    var sum float64
    err := r.DB.Table("card_payments").
        Select("COALESCE(SUM(amount), 0)").
        Where("card_id = ? AND billing_month = ?", cardID, billingMonth).
        Scan(&sum).Error
    return sum, err
}
```

---

### 1.3 Validação/Criação de Fatura (Contexto de Cartão)

| Item | Atual | Esperado |
|------|-------|----------|
| Validação na criação | Não existe | Validar status da fatura |
| Criação automática | Não existe | Criar fatura se não existir |

**Implementar em `CreateImportSession`:**
```go
if isCardContext {
    invoice, err := uc.repo.GetInvoice(ctx, *session.CardID, session.BillingMonth)
    if err != nil {
        // Fatura não existe, criar com status OPEN
        invoice = &entity.Invoice{
            CardID:       *session.CardID,
            BillingMonth: session.BillingMonth,
            Status:       entity.InvoiceStatusOpen,
        }
        if err := uc.repo.CreateInvoice(ctx, invoice); err != nil {
            return err
        }
    } else if invoice.Status != entity.InvoiceStatusOpen {
        return fmt.Errorf("%w: invoice status must be OPEN, current: %s", ErrValidation, invoice.Status)
    }
}
```

---

## 2. Create Staged Transactions

**Endpoint:** `POST /import-sessions/:id/staged-transactions`

### 2.1 Auto-detecção de Tipo pelo Sinal do Valor

| Item | Atual | Esperado |
|------|-------|----------|
| Detecção automática | Não implementado | Detectar tipo pelo sinal do `amount` |

**Implementar em `CreateStagedTransactions`:**
```go
for i := range transactions {
    // Determinar tipo pelo sinal do valor
    if session.AccountID != nil {
        // Contexto de Conta
        if transactions[i].Amount >= 0 {
            transactions[i].Type = entity.StagedTransactionTypeIncome
        } else {
            transactions[i].Type = entity.StagedTransactionTypeExpense
        }
    } else if session.CardID != nil {
        // Contexto de Cartão
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

### 3.1 Campos Faltantes na Resposta

| Campo | Atual | Esperado |
|-------|-------|----------|
| `type` | Não existe | `"account"` ou `"card"` |
| `initial_balance` | Não existe | Saldo calculado |
| `context_value` | Não existe | Saldo + staged |
| `transactions` | Não existe | Lista de staged transactions |
| `stats` | Não existe no GET individual | `{ ready: N, total: M }` |
| `status` | Não existe | `"ok"` ou `"pending"` |

**Criar struct de resposta enriquecida:**
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

type SessionStats struct {
    Ready int64 `json:"ready"`
    Total int64 `json:"total"`
}
```

---

### 3.2 Cálculo do `initial_balance` (Contexto de Conta)

**Novo método no repositório:**
```go
func (r *ImportRepo) GetAccountInitialBalance(ctx context.Context, accountID uuid.UUID, billingMonth string) (float64, error) {
    firstDay := billingMonth + "-01"

    var balance float64

    // Incomes (+)
    var incomes float64
    r.DB.Table("incomes").
        Select("COALESCE(SUM(amount), 0)").
        Where("account_id = ? AND transaction_date < ?", accountID, firstDay).
        Scan(&incomes)

    // Expenses (-)
    var expenses float64
    r.DB.Table("expenses").
        Select("COALESCE(SUM(amount), 0)").
        Where("account_id = ? AND transaction_date < ?", accountID, firstDay).
        Scan(&expenses)

    // Transfers source (-)
    var transfersOut float64
    r.DB.Table("transfers").
        Select("COALESCE(SUM(amount), 0)").
        Where("source_account_id = ? AND transaction_date < ?", accountID, firstDay).
        Scan(&transfersOut)

    // Transfers destination (+)
    var transfersIn float64
    r.DB.Table("transfers").
        Select("COALESCE(SUM(amount), 0)").
        Where("destination_account_id = ? AND transaction_date < ?", accountID, firstDay).
        Scan(&transfersIn)

    // Card Payments (-)
    var cardPayments float64
    r.DB.Table("card_payments").
        Select("COALESCE(SUM(amount), 0)").
        Where("account_id = ? AND transaction_date < ?", accountID, firstDay).
        Scan(&cardPayments)

    // Investment Deposits (-)
    var investmentDeposits float64
    r.DB.Table("investment_deposits").
        Select("COALESCE(SUM(amount), 0)").
        Where("account_id = ? AND transaction_date < ?", accountID, firstDay).
        Scan(&investmentDeposits)

    // Investment Withdrawals (+)
    var investmentWithdrawals float64
    r.DB.Table("investment_withdrawals").
        Select("COALESCE(SUM(amount), 0)").
        Where("account_id = ? AND transaction_date < ?", accountID, firstDay).
        Scan(&investmentWithdrawals)

    balance = incomes - expenses - transfersOut + transfersIn - cardPayments - investmentDeposits + investmentWithdrawals

    return balance, nil
}
```

---

### 3.3 Cálculo do `initial_balance` (Contexto de Cartão)

**Novo método no repositório:**
```go
func (r *ImportRepo) GetCardInitialBalance(ctx context.Context, cardID uuid.UUID, billingMonth string) (float64, error) {
    // card_expenses - card_chargebacks (sem staged_transactions)

    var cardExpenses float64
    r.DB.Table("card_expenses").
        Select("COALESCE(SUM(amount), 0)").
        Where("card_id = ? AND billing_month = ?", cardID, billingMonth).
        Scan(&cardExpenses)

    var cardChargebacks float64
    r.DB.Table("card_chargebacks").
        Select("COALESCE(SUM(amount), 0)").
        Where("card_id = ? AND billing_month = ?", cardID, billingMonth).
        Scan(&cardChargebacks)

    return cardExpenses - cardChargebacks, nil
}
```

---

### 3.4 Cálculo do `context_value`

**Contexto de Conta:**
```go
func (uc *ImportUseCaseImpl) CalculateContextValue(ctx context.Context, session *entity.ImportSession, initialBalance float64) (float64, error) {
    // Transações do mês nas tabelas principais
    monthTransactions, err := uc.repo.GetAccountMonthTransactions(ctx, *session.AccountID, session.BillingMonth)
    if err != nil {
        return 0, err
    }

    // Staged transactions
    stagedSum, err := uc.repo.GetStagedTransactionsSum(ctx, session.ID)
    if err != nil {
        return 0, err
    }

    return initialBalance + monthTransactions + stagedSum, nil
}
```

**Contexto de Cartão:**
```go
// context_value = initial_balance + staged_transactions
contextValue = initialBalance + stagedSum
```

---

### 3.5 Cálculo do `status`

```go
func (uc *ImportUseCaseImpl) CalculateSessionStatus(stats SessionStats, targetValue, contextValue float64) string {
    if stats.Ready == stats.Total && targetValue == contextValue {
        return "ok"
    }
    return "pending"
}
```

---

## 4. List Sessions

**Endpoint:** `GET /import-sessions`

### 4.1 Campos Faltantes

| Campo | Atual | Esperado |
|-------|-------|----------|
| `type` | Não existe | `"account"` ou `"card"` |
| `stats` | Contagem por tipo | `{ ready: N, total: M }` |

**Corrigir stats para contar por status:**
```go
// Atual: agrupa por type
// Esperado: contar ready vs total

type StatResult struct {
    SessionID uuid.UUID
    Ready     int64
    Total     int64
}

err = r.DB.Table("staged_transactions").
    Select("session_id, COUNT(*) as total, SUM(CASE WHEN status = 'READY' THEN 1 ELSE 0 END) as ready").
    Where("session_id IN ?", sessionIDs).
    Group("session_id").
    Scan(&stats).Error
```

---

## 5. Commit Session

**Endpoint:** `POST /import-sessions/:id/commit`

### 5.1 Status VALIDATING

| Item | Atual | Esperado |
|------|-------|----------|
| Status ao salvar | Default da tabela | `VALIDATING` |

**Implementar:**
```go
// Ao criar cada transação nas tabelas principais
income := entity.Income{
    // ... outros campos
    TransactionStatus: entity.TransactionStatusValidating,
}
```

---

### 5.2 Tratamento de `ignore: true`

| Item | Atual | Esperado |
|------|-------|----------|
| Flag ignore | Não tratado | Salvar com status `IGNORE` |

**Implementar:**
```go
// Verificar flag ignore no JSON data
var dataMap map[string]interface{}
json.Unmarshal(staged.Data, &dataMap)

status := entity.TransactionStatusValidating
if ignore, ok := dataMap["ignore"].(bool); ok && ignore {
    status = entity.TransactionStatusIgnore
}

income := entity.Income{
    // ... outros campos
    TransactionStatus: status,
}
```

---

## 6. Close Session

**Endpoint:** `POST /import-sessions/:id/close`

### 6.1 Filtro por Status VALIDATING

| Item | Atual | Esperado |
|------|-------|----------|
| Filtro | Atualiza todas exceto IGNORE | Atualizar apenas VALIDATING |

**Código atual:**
```go
Where("account_id = ? AND transaction_status != ?", accountID, entity.TransactionStatusIgnore)
```

**Código esperado:**
```go
Where("account_id = ? AND transaction_status = ?", accountID, entity.TransactionStatusValidating)
```

---

### 6.2 Atualizar Status da Fatura (Contexto de Cartão)

| Item | Atual | Esperado |
|------|-------|----------|
| Atualização da fatura | Não implementado | Alterar para `PAID` |

**Implementar:**
```go
if session.CardID != nil && session.BillingMonth != "" {
    // ... atualizar transações

    // Atualizar status da fatura
    if err := tx.Table("invoices").
        Where("card_id = ? AND billing_month = ?", cardID, billingMonth).
        Update("status", entity.InvoiceStatusPaid).Error; err != nil {
        return fmt.Errorf("failed to update invoice status: %w", err)
    }
}
```

---

## 7. Bind Recurring

**Endpoint:** `POST /import-sessions/:id/bind`

### 7.1 Alterar Tipo da Staged Transaction

| Item | Atual | Esperado |
|------|-------|----------|
| Tipo | Não altera | Herdar tipo da recurring |

**Implementar:**
```go
// Mapear tipo da recurring para staged transaction type
switch recurringType {
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

---

### 7.2 Busca Automática do Tipo de Recurring

| Item | Atual | Esperado |
|------|-------|----------|
| Identificação | Recebe `recurring_type` no request | Buscar automaticamente nas tabelas |

**Request atual:**
```json
{
  "staged_transaction_id": "uuid",
  "recurring_transaction_id": "uuid",
  "recurring_type": "expense"  // <- remover
}
```

**Request esperado:**
```json
{
  "staged_transaction_id": "uuid",
  "recurring_transaction_id": "uuid"
}
```

**Implementar busca automática:**
```go
func (uc *ImportUseCaseImpl) FindRecurringType(ctx context.Context, recurringID uuid.UUID) (entity.RecurringType, error) {
    // Buscar em ordem nas tabelas

    if _, err := uc.recurringIncomeRepo.Get(ctx, recurringID); err == nil {
        return entity.RecurringTypeIncome, nil
    }

    if _, err := uc.recurringExpenseRepo.Get(ctx, recurringID); err == nil {
        return entity.RecurringTypeExpense, nil
    }

    if _, err := uc.recurringTransferRepo.Get(ctx, recurringID); err == nil {
        return entity.RecurringTypeTransfer, nil
    }

    if _, err := uc.recurringCardTransactionRepo.Get(ctx, recurringID); err == nil {
        return entity.RecurringTypeCardTransaction, nil
    }

    return "", fmt.Errorf("recurring transaction not found")
}
```

---

## 8. Enum de Status

### 8.1 Renomear QUEUED para PROCESSING

| Item | Atual | Esperado |
|------|-------|----------|
| Status | `QUEUED` | `PROCESSING` |

**Arquivo:** `backend/internal/entity/import.go`

**Código atual:**
```go
StagedTransactionStatusQueued StagedTransactionStatus = "QUEUED"
```

**Código esperado:**
```go
StagedTransactionStatusProcessing StagedTransactionStatus = "PROCESSING"
```

**Nota:** Requer migration no banco de dados para renomear o valor do enum.

---

## Resumo de Prioridades

### Alta Prioridade
1. [ ] Get Session - campos enriched (initial_balance, context_value, stats, status, transactions)
2. [ ] Commit Session - status VALIDATING
3. [ ] Commit Session - tratamento ignore: true
4. [ ] Close Session - atualizar status da fatura

### Média Prioridade
5. [ ] Create Session - formato do nome
6. [ ] Create Session - validar/criar fatura
7. [ ] Create Session - target_value default (soma pagamentos)
8. [ ] Create Staged Transactions - auto-detecção de tipo
9. [ ] Close Session - filtrar apenas VALIDATING

### Baixa Prioridade
10. [ ] List Sessions - stats por status (ready/total)
11. [ ] List Sessions - campo type
12. [ ] Bind - alterar tipo da staged
13. [ ] Bind - busca automática do tipo de recurring
14. [ ] Renomear QUEUED para PROCESSING (requer migration)

---

## Arquivos Afetados

| Arquivo | Modificações |
|---------|--------------|
| `internal/entity/import.go` | Renomear QUEUED → PROCESSING |
| `internal/usecase/import.go` | Lógica de criação, bind, cálculos |
| `internal/usecase/interfaces.go` | Novos métodos de repositório |
| `internal/usecase/repo/import_postgres.go` | Queries de cálculo de saldo |
| `internal/controller/http/v1/import.go` | Ajustar request/response |
| `database/migrations/` | Migration para enum status |
