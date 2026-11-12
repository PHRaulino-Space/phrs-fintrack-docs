---
title: Planning
---
## GET `/planning/actions`

**Resumo:** Get current month's planning actions and goal forecast

Available today is eligible cash less remaining expense group budgets. For goal projections, the combined deposit group percentage applies to future recurring income up to the goal deadline. The amount already saved and each dated contribution compound at 8% annually. No payment is executed.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.PlanningActions |

## GET `/planning/budget-groups`

**Resumo:** Get the monthly budget groups and their usage

The workspace distribution and transaction rules apply to every month. Limits use paid income selected by the rules. previous_income holds that total and income_month is the budget month used by the default rule. category_activity breaks down the same budget movements by category, including expenses linked to assets through tags.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| month | query | string | sim | Budget month (YYYY-MM) |
| include_expenses | query | boolean | não | Include the expense transactions counted by the budget rules |
| include_deposits | query | boolean | não | Include the deposit transactions counted by the budget rules |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.BudgetGroupsSummary |

## GET `/planning/month`

**Resumo:** Get monthly financial plan and result

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| year | query | integer | sim | Year |
| month | query | integer | sim | Month |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.PlanningMonth |

## GET `/planning/settings`

**Resumo:** Get planning settings

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.PlanningSettings |

## GET `/planning/year`

**Resumo:** Get annual financial plan and report

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| year | query | integer | sim | Year |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.PlanningYear |

## PUT `/planning/budget-groups`

**Resumo:** Replace the workspace budget distribution

Percentages are in basis points and must sum to 10000. Each category may be linked to only one group. EXPENSE uses expense categories; DEPOSIT uses goal categories.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| payload | body | v1.budgetGroupsRequest | sim | Complete distribution for the workspace |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 400 | Bad Request |  |

## PUT `/planning/budget-groups/transaction-rules`

**Resumo:** Replace the workspace budget transaction rules

Configure the income and activity periods by account type and choose how card spending is counted. Omitted account types use income and activity from the budget month.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| payload | body | entity.BudgetTransactionRules | sim | Budget transaction rules |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 400 | Bad Request |  |

## PUT `/planning/categories/{id}`

**Resumo:** Assign an expense category to a planning bucket

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Category ID |
| payload | body | v1.categoryBucketRequest | sim | Bucket |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |

## PUT `/planning/settings`

**Resumo:** Update planning distribution

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| payload | body | v1.allocationRequest | sim | Percentages summing to 100 |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.PlanningAllocation |

### Schemas

#### entity.AccountType

Sem propriedades.

#### entity.BudgetAccountRule

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| activity | object | não |  |
| income | object | não |  |

#### entity.BudgetCardMode

Sem propriedades.

#### entity.BudgetGroup

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| basis_points | integer | não |  |
| category_ids | array&lt;string&gt; | não |  |
| kind | string | não |  |
| name | string | não |  |

#### entity.BudgetPeriod

Sem propriedades.

#### entity.BudgetTransactionRules

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| accounts | object | sim |  |
| cards | object | sim |  |

#### entity.GoalPurpose

Sem propriedades.

#### entity.PlanningAllocation

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| essential_percent | integer | não |  |
| growth_percent | integer | não |  |
| personal_percent | integer | não |  |
| workspace_id | string | não |  |

#### entity.TransactionStatus

Sem propriedades.

#### usecase.BudgetCategoryActivity

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| asset_expenses | number | não |  |
| deposits | number | não |  |
| expenses | number | não |  |

#### usecase.BudgetDepositTransaction

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_id | string | não |  |
| amount | number | não |  |
| category_id | string | não |  |
| date | string | não |  |
| description | string | não |  |
| id | string | não |  |
| investment_id | string | não |  |
| status | object | não |  |

#### usecase.BudgetExpenseTransaction

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| category_id | string | não |  |
| date | string | não |  |
| description | string | não |  |
| id | string | não |  |
| type | string | não |  |

#### usecase.BudgetGroupsSummary

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| category_activity | object | não |  |
| currency_code | string | não |  |
| deposit_transactions | array&lt;usecase.BudgetDepositTransaction&gt; | não |  |
| expense_transactions | array&lt;usecase.BudgetExpenseTransaction&gt; | não |  |
| groups | array&lt;usecase.BudgetGroupSummary&gt; | não |  |
| income_month | string | não |  |
| income_sources | array&lt;usecase.BudgetIncomeSource&gt; | não |  |
| month | string | não |  |
| previous_income | number | não |  |
| transaction_rules | entity.BudgetTransactionRules | não |  |
| unassigned_deposits | number | não |  |
| unassigned_expenses | number | não |  |

#### usecase.BudgetGroupSummary

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| basis_points | integer | não |  |
| category_ids | array&lt;string&gt; | não |  |
| kind | string | não |  |
| limit | number | não |  |
| name | string | não |  |
| remaining | number | não |  |
| used | number | não |  |

#### usecase.BudgetIncomeSource

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_type | entity.AccountType | não |  |
| amount | number | não |  |
| period | entity.BudgetPeriod | não |  |

#### usecase.PlanningActions

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| currency_code | string | não |  |
| forecast | usecase.PlanningForecast | não |  |
| manual_invoices | array&lt;usecase.PlanningManualInvoice&gt; | não |  |
| manual_unpaid | array&lt;usecase.PlanningManualUnpaid&gt; | não |  |

#### usecase.PlanningBucketSummary

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| limit | number | não |  |
| percent | integer | não |  |
| remaining | number | não |  |
| spent | number | não |  |

#### usecase.PlanningCategory

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| bucket | string | não |  |
| id | string | não |  |
| name | string | não |  |

#### usecase.PlanningCommitment

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| date | string | não |  |
| description | string | não |  |
| id | string | não |  |
| kind | string | não |  |
| status | string | não |  |

#### usecase.PlanningForecast

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| assumptions | array&lt;string&gt; | não |  |
| available_today | number | não |  |
| budget_total | number | não |  |
| cash_balance | number | não |  |
| committed | number | não |  |
| currency_code | string | não |  |
| current_deficit | number | não |  |
| expense_budget_remaining | number | não |  |
| goal_annual_return_percent | number | não |  |
| goals | array&lt;usecase.PlanningForecastGoal&gt; | não |  |
| legacy_budget_total | number | não |  |
| lowest_cash_before_income | number | não |  |
| month | string | não |  |
| months | array&lt;usecase.PlanningForecastMonth&gt; | não |  |
| pending_income | number | não |  |
| review_reason | string | não |  |
| review_required | boolean | não |  |

#### usecase.PlanningForecastGoal

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| current_value | number | não |  |
| due_date | string | não |  |
| id | string | não |  |
| monthly | array&lt;usecase.PlanningGoalMonth&gt; | não |  |
| name | string | não |  |
| priority_rank | integer | não |  |
| projected_at_deadline | number | não |  |
| purpose | entity.GoalPurpose | não |  |
| reserve_kind | string | não |  |
| status | usecase.PlanningGoalForecastStatus | não |  |
| status_reason | string | não |  |
| suggested_today | number | não |  |
| target_value | number | não |  |

#### usecase.PlanningForecastMonth

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| available | number | não |  |
| budget | number | não |  |
| deficit | number | não |  |
| expenses | number | não |  |
| income | number | não |  |
| month | string | não |  |
| unallocated | number | não |  |

#### usecase.PlanningGoal

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| current_value | number | não |  |
| due_date | string | não |  |
| estimated_months | integer | não |  |
| id | string | não |  |
| investment_guidance | string | não |  |
| name | string | não |  |
| on_track | boolean | não |  |
| priority_rank | integer | não |  |
| suggested_amount | number | não |  |
| target_value | number | não |  |

#### usecase.PlanningGoalForecastStatus

Sem propriedades.

#### usecase.PlanningGoalMonth

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| accumulated | number | não |  |
| contribution | number | não |  |
| month | string | não |  |

#### usecase.PlanningManualInvoice

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| billing_month | string | não |  |
| card_id | string | não |  |
| card_name | string | não |  |
| currency_code | string | não |  |
| due_date | string | não |  |

#### usecase.PlanningManualUnpaid

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| category_id | string | não |  |
| category_name | string | não |  |
| currency_code | string | não |  |
| description | string | não |  |
| due_date | string | não |  |
| recurring_id | string | não |  |

#### usecase.PlanningMonth

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| available_to_invest | number | não |  |
| cash_balance | number | não |  |
| commitments | array&lt;usecase.PlanningCommitment&gt; | não |  |
| current | boolean | não |  |
| essential | usecase.PlanningBucketSummary | não |  |
| goals | array&lt;usecase.PlanningGoal&gt; | não |  |
| growth | usecase.PlanningBucketSummary | não |  |
| income_expected | number | não |  |
| income_received | number | não |  |
| invested | number | não |  |
| month | integer | não |  |
| pending_payments | number | não |  |
| personal | usecase.PlanningBucketSummary | não |  |
| personal_available | number | não |  |
| projected_contribution | number | não |  |
| year | integer | não |  |

#### usecase.PlanningSettings

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| allocation | entity.PlanningAllocation | não |  |
| categories | array&lt;usecase.PlanningCategory&gt; | não |  |

#### usecase.PlanningYear

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| expenses | number | não |  |
| expenses_expected | number | não |  |
| goals | array&lt;usecase.PlanningGoal&gt; | não |  |
| income_expected | number | não |  |
| income_received | number | não |  |
| invested | number | não |  |
| months | array&lt;usecase.PlanningMonth&gt; | não |  |
| year | integer | não |  |

#### v1.allocationRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| essential_percent | integer | não |  |
| growth_percent | integer | não |  |
| personal_percent | integer | não |  |

#### v1.budgetGroupsRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| groups | array&lt;entity.BudgetGroup&gt; | sim |  |

#### v1.categoryBucketRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| bucket | string | sim |  |
