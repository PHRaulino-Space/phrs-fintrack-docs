---
title: Budgets
---
## DELETE `/budgets/{budget_id}`

**Resumo:** Delete a budget

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| budget_id | path | string | sim | Budget ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

## GET `/budgets`

**Resumo:** List budgets

List all budgets for a given workspace and month/year

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
| 200 | OK | array&lt;entity.Budget&gt; |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## GET `/budgets/{budget_id}`

**Resumo:** Get a single budget

Get a single budget by its ID

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| budget_id | path | string | sim | Budget ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.Budget |
| 400 | Bad Request | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

## GET `/budgets/summary`

**Resumo:** Get budgets summary

Get budgets summary for a given workspace and month/year

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
| 200 | OK | usecase.BudgetSummary |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## PATCH `/budgets/{budget_id}`

**Resumo:** Update a budget

Update an existing budget

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| budget_id | path | string | sim | Budget ID |
| budget | body | v1.updateBudgetRequest | sim | Budget update object |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.Budget |
| 400 | Bad Request | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

## POST `/budgets`

**Resumo:** Create a new budget

Create a new budget for a category (expense only)

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| budget | body | v1.createBudgetRequest | sim | Budget object |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.Budget |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## POST `/budgets/duplicate`

**Resumo:** Duplicate budgets

Duplicate budgets from a source month/year to a target month/year, keeping existing target budgets

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| payload | body | v1.duplicateBudgetRequest | sim | Duplicate budgets payload |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.BudgetDuplicateResult |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## POST `/budgets/generate/apply`

**Resumo:** Apply recurring expense budget proposal

Create absent category budgets and replace only explicitly selected existing budget IDs

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| payload | body | v1.generateBudgetRequest | sim | Month, margin and optional replacement IDs |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.BudgetGenerationResult |
| 409 | Conflict | object |

## POST `/budgets/generate/preview`

**Resumo:** Preview monthly budgets from registered recurring expenses

Group expected recurring expense slots by category and apply a percentage margin; existing budgets are preserved

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| payload | body | v1.generateBudgetRequest | sim | Month and margin |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.BudgetGenerationPreview |

### Schemas

#### entity.Budget

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| alert_threshold | number | não |  |
| budget_health | entity.BudgetHealth | não |  |
| category_id | string | não |  |
| category_name | string | não | Computed fields |
| color | string | não |  |
| created_at | string | não |  |
| currency_code | string | não |  |
| id | string | não |  |
| is_active | boolean | não |  |
| month | integer | não |  |
| percentage_used | number | não |  |
| planned_amount | number | não |  |
| projected_amount | number | não |  |
| remaining_amount | number | não |  |
| spent_amount | number | não |  |
| updated_at | string | não |  |
| workspace_id | string | não |  |
| year | integer | não |  |

#### entity.BudgetHealth

Sem propriedades.

#### usecase.BudgetDuplicateResult

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created | integer | não |  |
| skipped | integer | não |  |

#### usecase.BudgetGenerationExpectation

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| category_id | string | não |  |
| existing_amount | number | não |  |
| existing_budget_id | string | não |  |
| existing_is_active | boolean | não |  |
| proposed_amount | number | não |  |

#### usecase.BudgetGenerationItem

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| action | string | não |  |
| category_id | string | não |  |
| category_name | string | não |  |
| existing_amount | number | não |  |
| existing_budget_id | string | não |  |
| existing_is_active | boolean | não |  |
| proposed_amount | number | não |  |
| recurring_total | number | não |  |

#### usecase.BudgetGenerationPreview

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| currency_code | string | não |  |
| items | array&lt;usecase.BudgetGenerationItem&gt; | não |  |
| margin_percent | number | não |  |
| month | integer | não |  |
| year | integer | não |  |

#### usecase.BudgetGenerationResult

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created | integer | não |  |
| preserved | integer | não |  |
| updated | integer | não |  |

#### usecase.BudgetSummary

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| budget_health | entity.BudgetHealth | não |  |
| categories_on_track | integer | não |  |
| categories_over_budget | integer | não |  |
| total_planned | number | não |  |
| total_remaining | number | não |  |
| total_spent | number | não |  |

#### v1.createBudgetRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| alert_threshold | number | não |  |
| category_id | string | sim |  |
| color | string | sim |  |
| is_active | boolean | não |  |
| month | integer | sim |  |
| planned_amount | number | sim |  |
| year | integer | sim |  |

#### v1.duplicateBudgetRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| source_month | integer | sim |  |
| source_year | integer | sim |  |
| target_month | integer | sim |  |
| target_year | integer | sim |  |

#### v1.generateBudgetRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| expected_items | array&lt;usecase.BudgetGenerationExpectation&gt; | não |  |
| margin_percent | number | não |  |
| month | integer | sim |  |
| replace_budget_ids | array&lt;string&gt; | não |  |
| year | integer | sim |  |

#### v1.updateBudgetRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| alert_threshold | number | não |  |
| category_id | string | não |  |
| color | string | não |  |
| is_active | boolean | não |  |
| month | integer | não |  |
| planned_amount | number | não |  |
| year | integer | não |  |
