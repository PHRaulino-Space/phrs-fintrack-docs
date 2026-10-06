---
title: Sub Categories
---
## DELETE `/categories/{category_id}/sub-categories/{id}`

**Resumo:** Delete sub-category

Legacy route is disabled; use deletion preview and explicit confirmation.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| category_id | path | string | sim | Category ID |
| id | path | string | sim | Sub-category ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 400 | Bad Request | object |
| 404 | Not Found | object |
| 409 | Conflict | object |
| 500 | Internal Server Error | object |

## GET `/categories/{category_id}/sub-categories`

**Resumo:** List sub-categories

List all sub-categories for a given category

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| category_id | path | string | sim | Category ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;entity.SubCategory&gt; |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## GET `/categories/{category_id}/sub-categories/{id}`

**Resumo:** Get a single sub-category

Get a single sub-category by its ID

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| category_id | path | string | sim | Category ID |
| id | path | string | sim | Sub-category ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.SubCategory |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## GET `/categories/{category_id}/sub-categories/{id}/deletion-preview`

**Resumo:** Preview sub-category deletion impact

Count persisted sub-category references by type. Informational only; a future confirmation must revalidate counts transactionally.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| category_id | path | string | sim | Parent category ID |
| id | path | string | sim | Sub-category ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.ImpactPreview |
| 400 | Bad Request | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

## PATCH `/categories/{category_id}/sub-categories/{id}`

**Resumo:** Update sub-category

Update a sub-category

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| category_id | path | string | sim | Category ID |
| id | path | string | sim | Sub-category ID |
| subCategory | body | v1.updateSubCategoryRequest | sim | Sub-category update object |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.SubCategory |
| 400 | Bad Request | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

## POST `/categories/{category_id}/sub-categories`

**Resumo:** Create a new sub-category

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| category_id | path | string | sim | Category ID |
| subCategory | body | v1.createSubCategoryRequest | sim | Sub-category object |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.SubCategory |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## POST `/categories/{category_id}/sub-categories/{id}/deletion-confirmation`

**Resumo:** Confirm subcategory deletion or move

Revalidate the preview and atomically move subcategory references or soft-delete supported associated records; unsupported links return conflict.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| category_id | path | string | sim | Category ID |
| id | path | string | sim | Subcategory ID |
| confirmation | body | usecase.ImpactConfirmation | sim | Confirmation |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 409 | Conflict | object |

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

#### usecase.ImpactConfirmation

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| action | string | não |  |
| child_destinations | object | não |  |
| confirm_name | string | não |  |
| destination_id | string | não |  |
| version | string | não |  |

#### usecase.ImpactKind

Sem propriedades.

#### usecase.ImpactPreview

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| confirmation | string | não |  |
| count_scope | string | não |  |
| counts | object | não |  |
| generated_at | string | não |  |
| id | string | não |  |
| kind | usecase.ImpactKind | não |  |
| version | string | não |  |
| workspace_id | string | não |  |

#### v1.createSubCategoryRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| is_active | boolean | não |  |
| name | string | sim |  |

#### v1.updateSubCategoryRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| is_active | boolean | não |  |
| name | string | não |  |
