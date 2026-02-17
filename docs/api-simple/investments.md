---
title: Investments
---
## DELETE `/investments/{id}`

**Resumo:** Delete investment

Delete an investment and its related data

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Investment ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 400 | Bad Request | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

## DELETE `/investments/{id}/deposits/{deposit_id}`

**Resumo:** Delete investment deposit

Delete an investment deposit

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Investment ID |
| deposit_id | path | string | sim | Deposit ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 400 | Bad Request | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

## DELETE `/investments/{id}/value-history/{history_id}`

**Resumo:** Delete investment value history

Delete a value history entry for an investment

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Investment ID |
| history_id | path | string | sim | History ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content | object |
| 400 | Bad Request | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

## DELETE `/investments/{id}/withdrawals/{withdrawal_id}`

**Resumo:** Delete investment withdrawal

Delete an investment withdrawal

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Investment ID |
| withdrawal_id | path | string | sim | Withdrawal ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 400 | Bad Request | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

## GET `/investments`

**Resumo:** List investments

List all investments for the workspace (filtered by accounts in the workspace)

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;v1.investmentListResponse&gt; |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## GET `/investments/{id}`

**Resumo:** Get investment details with summary

Get an investment and its summary for a given year and month

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Investment ID |
| year | query | integer | sim | Year |
| month | query | integer | sim | Month (1-12) |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.investmentDetailResponse |
| 400 | Bad Request | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

## GET `/investments/{id}/value-history`

**Resumo:** List investment value history

List value history for an investment

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| investment_id | path | string | sim | Investment ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;v1.investmentValueHistoryResponse&gt; |
| 400 | Bad Request | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

## GET `/investments/performance`

**Resumo:** List investments performance

List performance for each investment in the workspace

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;v1.investmentPerformanceResponse&gt; |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## GET `/investments/portfolio`

**Resumo:** Get investments portfolio summary

Get portfolio summary and distributions for the workspace

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.investmentPortfolioResponse |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## PATCH `/investments/{id}`

**Resumo:** Update investment

Update an existing investment

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Investment ID |
| investment | body | v1.updateInvestmentRequest | sim | Investment object for update |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.Investment |
| 400 | Bad Request | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

## PATCH `/investments/{id}/deposits/{deposit_id}`

**Resumo:** Update investment deposit

Update an investment deposit

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Investment ID |
| deposit_id | path | string | sim | Deposit ID |
| deposit | body | v1.updateInvestmentDepositRequest | sim | Investment Deposit update object |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.InvestmentDeposit |
| 400 | Bad Request | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

## PATCH `/investments/{id}/withdrawals/{withdrawal_id}`

**Resumo:** Update investment withdrawal

Update an investment withdrawal

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Investment ID |
| withdrawal_id | path | string | sim | Withdrawal ID |
| withdrawal | body | v1.updateInvestmentWithdrawalRequest | sim | Investment Withdrawal update object |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.InvestmentWithdrawal |
| 400 | Bad Request | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

## POST `/investments`

**Resumo:** Create investment

Create a new investment

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| investment | body | v1.createInvestmentRequest | sim | Investment object |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.Investment |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## POST `/investments/{id}/value-history`

**Resumo:** Create investment value history

Create a value history entry for an investment

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Investment ID |
| history | body | v1.createInvestmentValueHistoryRequest | sim | Investment value history object |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | v1.investmentValueHistoryResponse |
| 400 | Bad Request | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

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

#### entity.IndexType

Sem propriedades.

#### entity.Investment

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account | object | não | Relationships |
| account_id | string | não |  |
| asset_name | string | não |  |
| created_at | string | não |  |
| current_value | number | não |  |
| id | string | não |  |
| index_type | entity.IndexType | não |  |
| index_value | string | não |  |
| investment_deposits | array&lt;entity.InvestmentDeposit&gt; | não |  |
| investment_withdrawals | array&lt;entity.InvestmentWithdrawal&gt; | não |  |
| is_rescued | boolean | não |  |
| liquidity | entity.LiquidityType | não |  |
| tags | array&lt;entity.InvestmentTag&gt; | não |  |
| type | entity.InvestmentType | não |  |
| updated_at | string | não |  |
| validity | string | não |  |
| value_history | array&lt;entity.InvestmentValueHistory&gt; | não |  |

#### entity.InvestmentDeposit

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account | entity.Account | não |  |
| account_id | string | não |  |
| amount | number | não |  |
| created_at | string | não |  |
| deleted_at | string | não |  |
| description | string | não |  |
| id | string | não |  |
| investment | object | não | Relationships |
| investment_id | string | não |  |
| recurring_transaction_id | string | não |  |
| transaction_date | string | não |  |
| transaction_status | entity.TransactionStatus | não |  |
| updated_at | string | não |  |

#### entity.InvestmentTag

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| investment | entity.Investment | não |  |
| investment_id | string | não |  |
| tag | entity.Tag | não |  |
| tag_id | string | não |  |

#### entity.InvestmentType

Sem propriedades.

#### entity.InvestmentValueHistory

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| id | string | não |  |
| investment | object | não | Relationships |
| investment_id | string | não |  |
| updated_at | string | não |  |
| updated_at_value | string | não |  |
| value | number | não |  |

#### entity.InvestmentWithdrawal

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account | entity.Account | não |  |
| account_id | string | não |  |
| amount | number | não |  |
| created_at | string | não |  |
| deleted_at | string | não |  |
| description | string | não |  |
| id | string | não |  |
| investment | object | não | Relationships |
| investment_id | string | não |  |
| recurring_transaction_id | string | não |  |
| transaction_date | string | não |  |
| transaction_status | entity.TransactionStatus | não |  |
| updated_at | string | não |  |

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

#### entity.LiquidityType

Sem propriedades.

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
| type | entity.RecurringType | não |  |
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
| type | entity.RecurringType | não |  |
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
| type | entity.RecurringType | não |  |
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

#### v1.createInvestmentRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_id | string | sim |  |
| asset_name | string | sim |  |
| index_type | entity.IndexType | não |  |
| index_value | string | não |  |
| liquidity | entity.LiquidityType | sim |  |
| type | entity.InvestmentType | sim |  |
| validity | string | não | Date YYYY-MM-DD |

#### v1.createInvestmentValueHistoryRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| updated_at_date | string | sim |  |
| value | number | sim |  |

#### v1.investmentAccountSummary

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| id | string | não |  |
| name | string | não |  |

#### v1.investmentDetailResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| investment | v1.investmentListResponse | não |  |
| summary | v1.investmentSummaryResponse | não |  |

#### v1.investmentListResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account | v1.investmentAccountSummary | não |  |
| account_id | string | não |  |
| asset_name | string | não |  |
| created_at | string | não |  |
| current_value | number | não |  |
| id | string | não |  |
| index_type | entity.IndexType | não |  |
| index_value | string | não |  |
| is_rescued | boolean | não |  |
| liquidity | entity.LiquidityType | não |  |
| type | entity.InvestmentType | não |  |
| updated_at | string | não |  |
| validity | string | não |  |

#### v1.investmentPerformanceResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| asset_name | string | não |  |
| current_value | number | não |  |
| id | string | não |  |
| index_type | entity.IndexType | não |  |
| index_value | string | não |  |
| initial_value | number | não |  |
| liquidity | entity.LiquidityType | não |  |
| profit_loss | number | não |  |
| profit_loss_percentage | number | não |  |
| type | entity.InvestmentType | não |  |
| validity | string | não |  |

#### v1.investmentPortfolioDistributionResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| color | string | não |  |
| count | integer | não |  |
| percentage | number | não |  |
| total | number | não |  |
| type | entity.InvestmentType | não |  |

#### v1.investmentPortfolioLiquidityResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| liquidity | entity.LiquidityType | não |  |
| percentage | number | não |  |
| total | number | não |  |

#### v1.investmentPortfolioPerformanceHistoryResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| month | string | não |  |
| value | number | não |  |
| variation | number | não |  |

#### v1.investmentPortfolioResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| active_investments | integer | não |  |
| avg_yield_rate | number | não |  |
| distribution | array&lt;v1.investmentPortfolioDistributionResponse&gt; | não |  |
| estimated_monthly_yield | number | não |  |
| liquidity_distribution | array&lt;v1.investmentPortfolioLiquidityResponse&gt; | não |  |
| performance_history | array&lt;v1.investmentPortfolioPerformanceHistoryResponse&gt; | não |  |
| rescued_investments | integer | não |  |
| total_assets | integer | não |  |
| total_invested | number | não |  |

#### v1.investmentSummaryResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| accumulated_return | number | não |  |
| current_value | number | não |  |
| monthly_return | number | não |  |
| net_balance | number | não |  |
| portfolio_percentage | number | não |  |
| return_rate | number | não |  |

#### v1.investmentValueHistoryResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| id | string | não |  |
| investment_id | string | não |  |
| updated_at | string | não |  |
| updated_at_value | string | não |  |
| value | number | não |  |

#### v1.updateInvestmentDepositRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_id | string | não |  |
| amount | number | não |  |
| description | string | não |  |
| transaction_date | string | não |  |

#### v1.updateInvestmentRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| asset_name | string | não |  |
| index_type | entity.IndexType | não |  |
| index_value | string | não |  |
| is_rescued | boolean | não |  |
| liquidity | entity.LiquidityType | não |  |
| type | entity.InvestmentType | não |  |
| validity | string | não |  |

#### v1.updateInvestmentWithdrawalRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_id | string | não |  |
| amount | number | não |  |
| description | string | não |  |
| transaction_date | string | não |  |
