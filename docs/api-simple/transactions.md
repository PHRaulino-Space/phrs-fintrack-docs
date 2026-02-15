---
title: Transactions
---
## GET `/transactions`

**Resumo:** List transactions

List all transactions for the workspace with optional filters

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| type | query | string | não | Filter by type (comma-separated): expense,income,transfer,investment_deposit,investment_withdraw |
| account_id | query | string | não | Account ID |
| card_id | query | string | não | Card ID (not supported yet) |
| investment_id | query | string | não | Investment ID |
| date_from | query | string | não | Start Date (YYYY-MM-DD) |
| date_to | query | string | não | End Date (YYYY-MM-DD) |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;v1.transactionResponse&gt; |
| 400 | Bad Request | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

## GET `/transactions/summary`

**Resumo:** Transactions summary

Returns total in, total out, balance for the filtered transactions, and current account balance (up to date_to or now). Current balance is always for the account_id and ignores type filters.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| type | query | string | não | Filter by type (comma-separated): expense,income,transfer,investment_deposit,investment_withdraw |
| account_id | query | string | não | Account ID |
| card_id | query | string | não | Card ID (not supported yet) |
| investment_id | query | string | não | Investment ID |
| date_from | query | string | não | Start Date (YYYY-MM-DD) |
| date_to | query | string | não | End Date (YYYY-MM-DD) |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.transactionSummaryResponse |
| 400 | Bad Request | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

## POST `/card-chargebacks`

**Resumo:** Create card chargeback

Create a new card chargeback transaction

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| chargeback | body | v1.createCardChargebackRequest | sim | Card Chargeback object |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.CardChargeback |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## POST `/card-expenses`

**Resumo:** Create card expense

Create a new card expense transaction

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| expense | body | v1.createCardExpenseRequest | sim | Card Expense object |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.CardExpense |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## POST `/card-payments`

**Resumo:** Create card payment

Create a new card payment transaction

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| payment | body | v1.createCardPaymentRequest | sim | Card Payment object |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.CardPayment |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## POST `/investments/{id}/deposits`

**Resumo:** Create investment deposit

Create a new investment deposit

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Investment ID |
| deposit | body | v1.createInvestmentDepositRequest | sim | Investment Deposit object |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.InvestmentDeposit |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## POST `/investments/{id}/withdrawals`

**Resumo:** Create investment withdrawal

Create a new investment withdrawal

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Investment ID |
| withdrawal | body | v1.createInvestmentWithdrawalRequest | sim | Investment Withdrawal object |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.InvestmentWithdrawal |
| 400 | Bad Request | object |
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

#### v1.createCardChargebackRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | sim |  |
| billing_month | string | sim |  |
| card_id | string | sim |  |
| description | string | sim |  |
| transaction_date | string | sim |  |

#### v1.createCardExpenseRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | sim |  |
| billing_month | string | sim |  |
| card_id | string | sim |  |
| category_id | string | sim |  |
| description | string | sim |  |
| sub_category_id | string | não |  |
| transaction_date | string | sim |  |

#### v1.createCardPaymentRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_id | string | sim |  |
| amount | number | sim |  |
| billing_month | string | sim |  |
| card_id | string | sim |  |
| is_final_payment | boolean | não |  |
| transaction_date | string | sim |  |

#### v1.createInvestmentDepositRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_id | string | sim |  |
| amount | number | sim |  |
| description | string | não |  |
| transaction_date | string | sim |  |

#### v1.createInvestmentWithdrawalRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_id | string | sim |  |
| amount | number | sim |  |
| description | string | não |  |
| rescued | boolean | não |  |
| transaction_date | string | sim |  |

#### v1.transactionResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_id | string | não |  |
| amount | number | não |  |
| category_id | string | não |  |
| description | string | não |  |
| destination_account_id | string | não |  |
| id | string | não |  |
| investment_id | string | não |  |
| source_account_id | string | não |  |
| sub_category_id | string | não |  |
| transaction_date | string | não |  |
| transaction_status | entity.TransactionStatus | não |  |
| type | string | não |  |

#### v1.transactionSummaryResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| balance | number | não |  |
| current_balance | number | não |  |
| total_in | number | não |  |
| total_out | number | não |  |
