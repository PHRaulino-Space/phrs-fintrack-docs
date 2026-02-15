---
title: Dashboard
---
## GET `/dashboard/cards-summary`

**Resumo:** Dashboard cards summary

Returns cards summary data for dashboard

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| year | query | integer | sim | Year |
| month | query | integer | sim | Month (1-12) |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.CardsSummary |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## GET `/dashboard/financial-summary`

**Resumo:** Dashboard financial summary

Returns financial summary data for dashboard

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| year | query | integer | sim | Year |
| month | query | integer | sim | Month (1-12) |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.FinancialSummary |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## GET `/dashboard/summary/metas`

**Resumo:** Goals dashboard summary

Returns summary metrics for goals

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.goalsSummaryResponse |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

### Schemas

#### usecase.BudgetSummaryItem

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| actual | number | não |  |
| category | string | não |  |
| color | string | não |  |
| planned | number | não |  |

#### usecase.CardCategoryExpense

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| category | string | não |  |
| color | string | não |  |
| percentage | number | não |  |

#### usecase.CardOverviewSummary

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| available | number | não |  |
| closingDate | integer | não |  |
| dueDate | integer | não |  |
| id | string | não |  |
| isActive | boolean | não |  |
| limit | number | não |  |
| name | string | não |  |
| used | number | não |  |

#### usecase.CardsSummary

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| cardsOverview | array&lt;usecase.CardOverviewSummary&gt; | não |  |
| expensesByCategory | array&lt;usecase.CardCategoryExpense&gt; | não |  |
| invoiceHistory | array&lt;usecase.InvoiceHistoryItem&gt; | não |  |
| month | integer | não |  |
| openInvoiceValue | number | não |  |
| recurringExpenses | array&lt;usecase.RecurringCardExpenseSummary&gt; | não |  |
| totalAvailable | number | não |  |
| totalLimit | number | não |  |
| totalUsed | number | não |  |
| year | integer | não |  |

#### usecase.CategoryComparison

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| category | string | não |  |
| color | string | não |  |
| expense | number | não |  |
| income | number | não |  |

#### usecase.ExpenseByCategory

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| color | string | não |  |
| name | string | não |  |

#### usecase.FinancialSummary

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| budgets | array&lt;usecase.BudgetSummaryItem&gt; | não |  |
| cardExpenses | number | não |  |
| categoryComparison | array&lt;usecase.CategoryComparison&gt; | não |  |
| currentBalance | number | não |  |
| expensesByCategory | array&lt;usecase.ExpenseByCategory&gt; | não |  |
| goalsContribution | number | não |  |
| incomeByCategory | array&lt;usecase.IncomeByCategory&gt; | não |  |
| investedThisMonth | number | não |  |
| month | integer | não |  |
| monthlyTrend | array&lt;usecase.MonthlyTrend&gt; | não |  |
| monthlyVariation | number | não |  |
| pendingBills | array&lt;usecase.PendingBill&gt; | não |  |
| plannedExpenses | number | não |  |
| savingsRate | number | não |  |
| totalExpenses | number | não |  |
| totalIncome | number | não |  |
| totalInvested | number | não |  |
| unplannedExpenses | number | não |  |
| unusedAmount | number | não |  |
| year | integer | não |  |

#### usecase.IncomeByCategory

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| color | string | não |  |
| name | string | não |  |

#### usecase.InvoiceHistoryItem

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| cardName | string | não |  |
| month | string | não |  |
| status | string | não |  |

#### usecase.MonthlyTrend

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| expenses | number | não |  |
| income | number | não |  |
| month | string | não |  |
| net | number | não |  |

#### usecase.PendingBill

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| category | string | não |  |
| description | string | não |  |
| dueDate | string | não |  |
| id | string | não |  |
| status | string | não |  |
| type | string | não |  |

#### usecase.RecurringCardExpenseSummary

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| cardName | string | não |  |
| category | string | não |  |
| description | string | não |  |
| id | string | não |  |
| nextDate | string | não |  |
| status | string | não |  |

#### v1.goalsSummaryResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| active_count | integer | não |  |
| completed_count | integer | não |  |
| progress_pct | number | não |  |
| remaining | number | não |  |
| total_accumulated | number | não |  |
