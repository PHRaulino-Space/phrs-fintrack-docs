---
title: Recurring
---
## GET `/recurring`

**Resumo:** List recurring transactions

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| account_id | query | string | não | Account ID |
| card_id | query | string | não | Card ID |
| type | query | string | não | Type (income, expense...) |
| is_active | query | boolean | não | Return only active recurrings |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;object&gt; |

## GET `/recurring/{id}/projection`

**Resumo:** Get projection for a recurring item

Get timeline of slots with status

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Recurring ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;entity.ProjectionSlot&gt; |

## GET `/recurring/pending`

**Resumo:** List pending recurring transactions

Identify empty slots for recurring transactions up to end of month

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| account_id | query | string | não | Account ID |
| card_id | query | string | não | Card ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;entity.PendingSlot&gt; |

## PATCH `/recurring/{id}`

**Resumo:** Update recurring transaction (Patch)

Update recurring transaction fields

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Recurring ID |
| input | body | v1.updateRecurringRequest | sim | Input |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |

## POST `/recurring`

**Resumo:** Create recurring transaction

Create a new recurring transaction

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| input | body | usecase.RecurringInput | sim | Input |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | object |

### Schemas

#### entity.Account

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| currency | string | não | Relationships |
| currency_code | string | não |  |
| deleted_at | string | não |  |
| id | string | não |  |
| initial_balance | number | não |  |
| is_active | boolean | não |  |
| name | string | não |  |
| type | entity.AccountType | não |  |
| updated_at | string | não |  |
| workspace_id | string | não |  |

#### entity.AccountType

Sem propriedades.

#### entity.Card

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| closing_date | integer | não |  |
| created_at | string | não |  |
| credit_limit | number | não |  |
| deleted_at | string | não |  |
| due_date | integer | não |  |
| id | string | não |  |
| import_sessions | array&lt;entity.ImportSession&gt; | não |  |
| invoices | array&lt;entity.Invoice&gt; | não | Relationships |
| is_active | boolean | não |  |
| name | string | não |  |
| recurring_card_transactions | array&lt;entity.RecurringCardTransaction&gt; | não |  |
| updated_at | string | não |  |
| workspace_id | string | não |  |

#### entity.CardChargeback

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| billing_month | string | não |  |
| card_id | string | não |  |
| created_at | string | não |  |
| description | string | não |  |
| id | string | não |  |
| transaction_date | string | não |  |
| transaction_status | entity.TransactionStatus | não |  |
| updated_at | string | não |  |

#### entity.CardExpense

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| billing_month | string | não |  |
| card_id | string | não |  |
| category | object | não | Relationships |
| category_id | string | não |  |
| created_at | string | não |  |
| deleted_at | string | não |  |
| description | string | não |  |
| id | string | não |  |
| recurring_card_transaction_id | string | não |  |
| sub_category_id | string | não |  |
| subcategory | entity.SubCategory | não |  |
| tags | array&lt;entity.CardExpenseTag&gt; | não |  |
| transaction_date | string | não |  |
| transaction_status | entity.TransactionStatus | não |  |
| updated_at | string | não |  |

#### entity.CardExpenseTag

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| card_expense | entity.CardExpense | não |  |
| card_expense_id | string | não |  |
| tag | entity.Tag | não |  |
| tag_id | string | não |  |

#### entity.CardPayment

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account | object | não | Relationships |
| account_id | string | não |  |
| amount | number | não |  |
| billing_month | string | não |  |
| card_id | string | não |  |
| created_at | string | não |  |
| id | string | não |  |
| is_final_payment | boolean | não |  |
| transaction_date | string | não |  |
| transaction_status | entity.TransactionStatus | não |  |
| updated_at | string | não |  |

#### entity.Category

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| card_expenses | array&lt;entity.CardExpense&gt; | não |  |
| color | string | não |  |
| created_at | string | não |  |
| expenses | array&lt;entity.Expense&gt; | não |  |
| icon | string | não |  |
| id | string | não |  |
| incomes | array&lt;entity.Income&gt; | não |  |
| is_active | boolean | não |  |
| name | string | não |  |
| recurring_card_transactions | array&lt;entity.RecurringCardTransaction&gt; | não |  |
| recurring_expenses | array&lt;entity.RecurringExpense&gt; | não |  |
| recurring_incomes | array&lt;entity.RecurringIncome&gt; | não |  |
| sub_categories | array&lt;entity.SubCategory&gt; | não | Relationships |
| sub_category_count | integer | não |  |
| type | entity.CategoryType | não |  |
| updated_at | string | não |  |
| workspace_id | string | não |  |

#### entity.CategoryType

Sem propriedades.

#### entity.Expense

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account | object | não | Relationships |
| account_id | string | não |  |
| amount | number | não |  |
| category | entity.Category | não |  |
| category_id | string | não |  |
| created_at | string | não |  |
| deleted_at | string | não |  |
| description | string | não |  |
| id | string | não |  |
| recurring_expense_id | string | não |  |
| sub_category_id | string | não |  |
| subcategory | entity.SubCategory | não |  |
| tags | array&lt;entity.ExpenseTag&gt; | não |  |
| transaction_date | string | não |  |
| transaction_status | entity.TransactionStatus | não |  |
| updated_at | string | não |  |

#### entity.ExpenseTag

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| expense | entity.Expense | não |  |
| expense_id | string | não |  |
| tag | entity.Tag | não |  |
| tag_id | string | não |  |

#### entity.ImportSession

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_id | string | não |  |
| billing_month | string | não | YYYY-MM |
| card_id | string | não |  |
| created_at | string | não |  |
| description | string | não |  |
| id | string | não |  |
| staged_transactions | array&lt;entity.StagedTransaction&gt; | não | Relationships |
| stats | object | não | Transient |
| target_value | number | não |  |
| type | string | não |  |
| user_id | string | não |  |
| workspace_id | string | não |  |

#### entity.Income

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account | object | não | Relationships |
| account_id | string | não |  |
| amount | number | não |  |
| category | entity.Category | não |  |
| category_id | string | não |  |
| created_at | string | não |  |
| deleted_at | string | não |  |
| description | string | não |  |
| id | string | não |  |
| recurring_income_id | string | não |  |
| sub_category_id | string | não |  |
| subcategory | entity.SubCategory | não |  |
| tags | array&lt;entity.IncomeTag&gt; | não |  |
| transaction_date | string | não |  |
| transaction_status | entity.TransactionStatus | não |  |
| updated_at | string | não |  |

#### entity.IncomeTag

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| income | entity.Income | não |  |
| income_id | string | não |  |
| tag | entity.Tag | não |  |
| tag_id | string | não |  |

#### entity.Invoice

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| billing_month | string | não | YYYY-MM |
| card | object | não | Relationships |
| card_chargebacks | array&lt;entity.CardChargeback&gt; | não |  |
| card_expenses | array&lt;entity.CardExpense&gt; | não |  |
| card_id | string | não |  |
| card_payments | array&lt;entity.CardPayment&gt; | não |  |
| created_at | string | não |  |
| status | entity.InvoiceStatus | não |  |
| updated_at | string | não |  |

#### entity.InvoiceStatus

Sem propriedades.

#### entity.PendingSlot

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| category_id | string | não |  |
| description | string | não |  |
| recurring_id | string | não |  |
| recurring_status | string | não | Active/Inactive |
| reference_date | string | não |  |
| sub_category_id | string | não |  |
| tags | array&lt;entity.Tag&gt; | não |  |
| type | entity.RecurringType | não |  |

#### entity.ProjectionSlot

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| date | string | não |  |
| status | object | não | PAID, IGNORE, PENDING |
| transaction_id | string | não |  |

#### entity.RecurringCardTransaction

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| card | object | não | Relationships |
| card_expenses | array&lt;entity.CardExpense&gt; | não |  |
| card_id | string | não |  |
| category | entity.Category | não |  |
| category_id | string | não |  |
| created_at | string | não |  |
| description | string | não |  |
| end_date | string | não |  |
| frequency | entity.TransactionFrequency | não |  |
| id | string | não |  |
| is_active | boolean | não |  |
| start_date | string | não |  |
| sub_category_id | string | não |  |
| subcategory | entity.SubCategory | não |  |
| tags | array&lt;entity.RecurringCardTransactionTag&gt; | não |  |
| updated_at | string | não |  |

#### entity.RecurringCardTransactionTag

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| recurring_card_transaction | entity.RecurringCardTransaction | não |  |
| recurring_card_transaction_id | string | não |  |
| tag | entity.Tag | não |  |
| tag_id | string | não |  |

#### entity.RecurringExpense

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account | object | não | Relationships |
| account_id | string | não |  |
| amount | number | não |  |
| category | entity.Category | não |  |
| category_id | string | não |  |
| created_at | string | não |  |
| description | string | não |  |
| end_date | string | não |  |
| expenses | array&lt;entity.Expense&gt; | não |  |
| frequency | entity.TransactionFrequency | não |  |
| id | string | não |  |
| is_active | boolean | não |  |
| start_date | string | não |  |
| sub_category_id | string | não |  |
| subcategory | entity.SubCategory | não |  |
| tags | array&lt;entity.RecurringExpenseTag&gt; | não |  |
| updated_at | string | não |  |

#### entity.RecurringExpenseTag

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| recurring_expense | entity.RecurringExpense | não |  |
| recurring_expense_id | string | não |  |
| tag | entity.Tag | não |  |
| tag_id | string | não |  |

#### entity.RecurringIncome

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account | object | não | Relationships |
| account_id | string | não |  |
| amount | number | não |  |
| category | entity.Category | não |  |
| category_id | string | não |  |
| created_at | string | não |  |
| description | string | não |  |
| end_date | string | não |  |
| frequency | entity.TransactionFrequency | não |  |
| id | string | não |  |
| incomes | array&lt;entity.Income&gt; | não |  |
| is_active | boolean | não |  |
| start_date | string | não |  |
| sub_category_id | string | não |  |
| subcategory | entity.SubCategory | não |  |
| tags | array&lt;entity.RecurringIncomeTag&gt; | não |  |
| updated_at | string | não |  |

#### entity.RecurringIncomeTag

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| recurring_income | entity.RecurringIncome | não |  |
| recurring_income_id | string | não |  |
| tag | entity.Tag | não |  |
| tag_id | string | não |  |

#### entity.RecurringType

Sem propriedades.

#### entity.StagedTransaction

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| created_at | string | não |  |
| data | object | não |  |
| description | string | não |  |
| id | string | não |  |
| processing_enrichment | boolean | não |  |
| session_id | string | não |  |
| status | entity.StagedTransactionStatus | não |  |
| transaction_date | string | não |  |
| type | entity.StagedTransactionType | não |  |
| updated_at | string | não |  |

#### entity.StagedTransactionStatus

Sem propriedades.

#### entity.StagedTransactionType

Sem propriedades.

#### entity.SubCategory

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| card_expenses | array&lt;entity.CardExpense&gt; | não |  |
| category | object | não | Relationships |
| category_id | string | não |  |
| created_at | string | não |  |
| expenses | array&lt;entity.Expense&gt; | não |  |
| id | string | não |  |
| incomes | array&lt;entity.Income&gt; | não |  |
| is_active | boolean | não |  |
| name | string | não |  |
| recurring_card_transactions | array&lt;entity.RecurringCardTransaction&gt; | não |  |
| recurring_expenses | array&lt;entity.RecurringExpense&gt; | não |  |
| recurring_incomes | array&lt;entity.RecurringIncome&gt; | não |  |
| updated_at | string | não |  |
| workspace_id | string | não |  |

#### entity.Tag

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| color | string | não |  |
| created_at | string | não |  |
| expenses_tags | array&lt;entity.ExpenseTag&gt; | não |  |
| id | string | não |  |
| incomes_tags | array&lt;entity.IncomeTag&gt; | não | Relationships |
| is_active | boolean | não |  |
| name | string | não |  |
| updated_at | string | não |  |
| workspace_id | string | não |  |

#### entity.TransactionFrequency

Sem propriedades.

#### entity.TransactionStatus

Sem propriedades.

#### usecase.RecurringInput

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_id | string | não |  |
| amount | number | não |  |
| card_id | string | não |  |
| category_id | string | não |  |
| description | string | não |  |
| destination_account_id | string | não |  |
| end_date | string | não |  |
| frequency | string | não | "MONTHLY", etc. |
| is_active | boolean | não |  |
| source_account_id | string | não |  |
| start_date | string | não |  |
| sub_category_id | string | não |  |
| tag_ids | array&lt;string&gt; | não |  |
| type | entity.RecurringType | não |  |

#### v1.updateRecurringRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_id | string | não |  |
| amount | number | não |  |
| card_id | string | não |  |
| category_id | string | não |  |
| description | string | não |  |
| destination_account_id | string | não |  |
| end_date | string | não |  |
| frequency | string | não |  |
| is_active | boolean | não |  |
| source_account_id | string | não |  |
| start_date | string | não |  |
| sub_category_id | string | não |  |
| type | entity.RecurringType | não |  |
