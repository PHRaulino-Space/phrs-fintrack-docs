---
title: Goal Strategies
---
## GET `/goal-strategies/context/{goal_id}`

**Resumo:** Get goal strategy context

Read one goal, its saved value and linked investments, the current planning suggestion and observed offers. No write occurs.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| goal_id | path | string | sim | Goal ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.GoalStrategyContext |

## POST `/goal-strategies/compare`

**Resumo:** Compare hypothetical distributions for one goal

V1 models one new contribution in simple fixed income only. Explicit choices and rate scenarios are required when used. Does not save a simulation, change a goal or buy an investment.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| payload | body | usecase.GoalStrategyRequest | sim | Explicit goal scenario and up to three editable distributions |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.GoalStrategyResponse |

### Schemas

#### entity.Account

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| assigned_user_id | string | não |  |
| created_at | string | não |  |
| currency | string | não | Relationships |
| currency_code | string | não |  |
| deleted_at | string | não |  |
| id | string | não |  |
| image_key | string | não |  |
| include_in_available_balance | boolean | não |  |
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
| assigned_user_id | string | não |  |
| automatic_debit | boolean | não |  |
| closing_date | integer | não |  |
| created_at | string | não |  |
| credit_limit | number | não |  |
| deleted_at | string | não |  |
| due_date | integer | não |  |
| id | string | não |  |
| image_key | string | não |  |
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
| tag_ids | array&lt;string&gt; | não |  |
| tags | array&lt;entity.CardChargebackTag&gt; | não |  |
| transaction_date | string | não |  |
| transaction_status | entity.TransactionStatus | não |  |
| updated_at | string | não |  |

#### entity.CardChargebackTag

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| card_chargeback_id | string | não |  |
| tag_id | string | não |  |

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
| tag_ids | array&lt;string&gt; | não |  |
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

#### entity.CardInvoiceBalanceAdjustment

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| billing_month | string | não |  |
| card_id | string | não |  |
| created_at | string | não |  |
| description | string | não |  |
| id | string | não |  |
| source_billing_month | string | não |  |
| transaction_date | string | não |  |
| transaction_status | entity.TransactionStatus | não |  |
| updated_at | string | não |  |

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
| tag_ids | array&lt;string&gt; | não |  |
| tags | array&lt;entity.CardPaymentTag&gt; | não |  |
| transaction_date | string | não |  |
| transaction_status | entity.TransactionStatus | não |  |
| updated_at | string | não |  |

#### entity.CardPaymentTag

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| card_payment_id | string | não |  |
| tag_id | string | não |  |

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
| planning_bucket | string | não |  |
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
| tag_ids | array&lt;string&gt; | não |  |
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

#### entity.Goal

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| category | string | não |  |
| color | string | não |  |
| completed_at | string | não |  |
| completed_value | number | não | CompletedValue is written only when a goal is completed. Legacy completions remain nil. |
| created_at | string | não |  |
| current_value | number | não |  |
| due_date | string | não |  |
| id | string | não |  |
| investments | array&lt;entity.GoalInvestment&gt; | não | Relationships |
| is_completed | boolean | não |  |
| name | string | não |  |
| priority | entity.GoalPriority | não |  |
| priority_rank | integer | não | PriorityRank allows more than three levels; nil preserves legacy priority semantics. |
| purpose | entity.GoalPurpose | não |  |
| remaining_value | number | não |  |
| reserve_kind | string | não |  |
| tag_id | string | não |  |
| target_value | number | não |  |
| type | entity.GoalType | não |  |
| updated_at | string | não |  |
| used_value | number | não |  |
| workspace_id | string | não |  |

#### entity.GoalInvestment

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| goal | entity.Goal | não |  |
| goal_id | string | não |  |
| investment | entity.Investment | não |  |
| investment_id | string | não |  |

#### entity.GoalPriority

Sem propriedades.

#### entity.GoalPurpose

Sem propriedades.

#### entity.GoalType

Sem propriedades.

#### entity.ImportSession

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_id | string | não |  |
| billing_month | string | não | YYYY-MM |
| card_id | string | não |  |
| created_at | string | não |  |
| description | string | não |  |
| id | string | não |  |
| is_active | boolean | não |  |
| kind | entity.ImportSessionKind | não |  |
| last_activity_at | string | não |  |
| recurring_transaction_bindings | array&lt;entity.RecurringTransactionBinding&gt; | não |  |
| staged_transactions | array&lt;entity.StagedTransaction&gt; | não | Relationships |
| stats | object | não | Transient |
| target_value | number | não |  |
| type | string | não |  |
| updated_at | string | não |  |
| user_id | string | não |  |
| workspace_id | string | não |  |

#### entity.ImportSessionKind

Sem propriedades.

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
| tag_ids | array&lt;string&gt; | não |  |
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
| tag_ids | array&lt;string&gt; | não |  |
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
| tag_ids | array&lt;string&gt; | não |  |
| tags | array&lt;entity.InvestmentDepositTag&gt; | não |  |
| transaction_date | string | não |  |
| transaction_status | entity.TransactionStatus | não |  |
| updated_at | string | não |  |

#### entity.InvestmentDepositTag

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| investment_deposit_id | string | não |  |
| tag | entity.Tag | não |  |
| tag_id | string | não |  |

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
| tag_ids | array&lt;string&gt; | não |  |
| tags | array&lt;entity.InvestmentWithdrawalTag&gt; | não |  |
| transaction_date | string | não |  |
| transaction_status | entity.TransactionStatus | não |  |
| updated_at | string | não |  |

#### entity.InvestmentWithdrawalTag

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| investment_withdrawal_id | string | não |  |
| tag | entity.Tag | não |  |
| tag_id | string | não |  |

#### entity.Invoice

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| balance_adjustments | array&lt;entity.CardInvoiceBalanceAdjustment&gt; | não |  |
| billing_month | string | não | YYYY-MM |
| card | object | não | Relationships |
| card_chargebacks | array&lt;entity.CardChargeback&gt; | não |  |
| card_expenses | array&lt;entity.CardExpense&gt; | não |  |
| card_id | string | não |  |
| card_payments | array&lt;entity.CardPayment&gt; | não |  |
| created_at | string | não |  |
| payment_type | entity.PaymentType | não |  |
| status | entity.InvoiceStatus | não |  |
| updated_at | string | não |  |

#### entity.InvoiceStatus

Sem propriedades.

#### entity.LiquidityType

Sem propriedades.

#### entity.PaymentType

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
| has_transaction_in_month | boolean | não |  |
| id | string | não |  |
| include_in_summary | boolean | não |  |
| is_active | boolean | não |  |
| payment_status | string | não |  |
| payment_type | entity.PaymentType | não |  |
| pending_amount | number | não |  |
| start_date | string | não |  |
| sub_category_id | string | não |  |
| subcategory | entity.SubCategory | não |  |
| tag_ids | array&lt;string&gt; | não |  |
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
| has_transaction_in_month | boolean | não |  |
| id | string | não |  |
| include_in_summary | boolean | não |  |
| is_active | boolean | não |  |
| payment_status | string | não |  |
| payment_type | entity.PaymentType | não |  |
| pending_amount | number | não |  |
| start_date | string | não |  |
| sub_category_id | string | não |  |
| subcategory | entity.SubCategory | não |  |
| tag_ids | array&lt;string&gt; | não |  |
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
| has_transaction_in_month | boolean | não |  |
| id | string | não |  |
| include_in_summary | boolean | não |  |
| incomes | array&lt;entity.Income&gt; | não |  |
| is_active | boolean | não |  |
| payment_status | string | não |  |
| payment_type | entity.PaymentType | não |  |
| pending_amount | number | não |  |
| start_date | string | não |  |
| sub_category_id | string | não |  |
| subcategory | entity.SubCategory | não |  |
| tag_ids | array&lt;string&gt; | não |  |
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

#### entity.RecurringTransactionBinding

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| confirmed_at | string | não |  |
| created_at | string | não |  |
| id | string | não |  |
| recurring_amount | number | não |  |
| recurring_description | string | não |  |
| recurring_transaction_id | string | não |  |
| recurring_type | entity.RecurringType | não |  |
| session_id | string | não |  |
| source | entity.RecurringTransactionBindingSource | não |  |
| staged_transaction_id | string | não |  |
| status | entity.RecurringTransactionBindingStatus | não |  |
| updated_at | string | não |  |
| workspace_id | string | não |  |

#### entity.RecurringTransactionBindingSource

Sem propriedades.

#### entity.RecurringTransactionBindingStatus

Sem propriedades.

#### entity.RecurringType

Sem propriedades.

#### entity.StagedTransaction

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| created_at | string | não |  |
| data | object | não |  |
| description | string | não |  |
| final_transaction_id | string | não |  |
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

#### usecase.GoalStrategyAllocation

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| opportunity_id | string | não |  |

#### usecase.GoalStrategyChoices

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| deadline | string | não | rigid \| flexible |
| early_liquidity | string | não | required \| not_required |
| focus | string | não | preserve \| purchasing_power \| income |
| loss_tolerance | string | não | none \| accepts_fluctuation |
| value_basis | string | não | nominal \| purchasing_power |

#### usecase.GoalStrategyContext

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| available_today | number | não |  |
| currency_code | string | não |  |
| goal | entity.Goal | não |  |
| offers | array&lt;usecase.OpportunityView&gt; | não |  |
| remaining | number | não |  |
| suggested_today | number | não |  |
| version | string | não |  |

#### usecase.GoalStrategyLeg

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| allocation | usecase.GoalStrategyAllocation | não |  |
| simulation | usecase.SimulationResult | não |  |

#### usecase.GoalStrategyOffer

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| can_illustrate | boolean | não |  |
| opportunity | usecase.OpportunityView | não |  |
| reasons | array&lt;string&gt; | não |  |
| risk_warnings | array&lt;string&gt; | não |  |

#### usecase.GoalStrategyPlan

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| allocations | array&lt;usecase.GoalStrategyAllocation&gt; | não |  |
| name | string | não |  |

#### usecase.GoalStrategyRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| annual_cdi_percent | number | não |  |
| annual_ipca_percent | number | não |  |
| choices | usecase.GoalStrategyChoices | não |  |
| goal_id | string | não |  |
| horizon_date | string | não |  |
| principal | number | não |  |
| start_date | string | não |  |
| strategies | array&lt;usecase.GoalStrategyPlan&gt; | não |  |
| version | string | não |  |

#### usecase.GoalStrategyResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| context | usecase.GoalStrategyContext | não |  |
| missing_fields | array&lt;string&gt; | não |  |
| offers | array&lt;usecase.GoalStrategyOffer&gt; | não |  |
| strategies | array&lt;usecase.GoalStrategyResult&gt; | não |  |
| version | string | não |  |
| warnings | array&lt;string&gt; | não |  |

#### usecase.GoalStrategyResult

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| allocated | number | não |  |
| allocations | array&lt;usecase.GoalStrategyLeg&gt; | não |  |
| comparable | boolean | não |  |
| effective_end_date | string | não |  |
| name | string | não |  |
| net_value | number | não |  |
| real_net_value | number | não |  |
| reasons | array&lt;string&gt; | não |  |
| risk_warnings | array&lt;string&gt; | não |  |
| unallocated | number | não |  |

#### usecase.OpportunityView

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_id | string | não |  |
| costs_known | boolean | não |  |
| created_at | string | não |  |
| external_ref | string | não |  |
| id | string | não |  |
| institution | string | não |  |
| issuer | string | não |  |
| liquidity_date | string | não |  |
| maturity_date | string | não |  |
| minimum_amount | number | não |  |
| missing_fields | array&lt;string&gt; | não |  |
| name | string | não |  |
| no_intermediate_cashflows | boolean | não |  |
| notes | string | não |  |
| offer_date | string | não |  |
| product_type | string | não |  |
| rate_percent | number | não | RatePercent is annual nominal percent for prefix, contracted percent of daily DI for cdi (110 = 110% CDI), or annual real percent for ipca. |
| rate_type | string | não |  |
| redemption_cost | number | não |  |
| status | string | não |  |
| tax_regime | string | não |  |
| updated_at | string | não |  |
| upfront_cost | number | não |  |
| valid_until | string | não |  |
| workspace_id | string | não |  |

#### usecase.SimulationAssumptions

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| annual_cdi_percent | number | não |  |
| annual_ipca_percent | number | não |  |
| horizon_date | string | não |  |
| principal | number | não |  |
| start_date | string | não |  |

#### usecase.SimulationResult

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| as_of_date | string | não |  |
| assumptions | usecase.SimulationAssumptions | não |  |
| end_date | string | não |  |
| estimated_costs | number | não |  |
| estimated_tax | number | não |  |
| gross_gain | number | não |  |
| gross_value | number | não |  |
| invested | number | não |  |
| missing_fields | array&lt;string&gt; | não |  |
| net_value | number | não |  |
| opportunity_id | string | não |  |
| real_net_value | number | não |  |
| warnings | array&lt;string&gt; | não |  |
