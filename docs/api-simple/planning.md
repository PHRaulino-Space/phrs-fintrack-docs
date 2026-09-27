---
title: Planning
---
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

#### entity.PlanningAllocation

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| essential_percent | integer | não |  |
| growth_percent | integer | não |  |
| personal_percent | integer | não |  |
| workspace_id | string | não |  |

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

#### v1.categoryBucketRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| bucket | string | sim |  |
