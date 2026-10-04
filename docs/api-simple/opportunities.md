---
title: Opportunities
---
## GET `/opportunities`

**Resumo:** List investment opportunities

List only quoted opportunities in the selected workspace. account_id identifies an existing account where the offer was seen; unlinked older offers remain visible with missing_fields. No portfolio, transaction or goal records are read.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.opportunityListResponse |

## GET `/opportunities/{id}`

**Resumo:** Get investment opportunity

Get a quoted opportunity scoped to the selected workspace, including missing_fields for incomplete drafts.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Opportunity UUID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.opportunityResponse |
| 404 | Not Found | object |

## PATCH `/opportunities/{id}`

**Resumo:** Edit quoted opportunity

Partially update offer fields in the selected workspace; null clears optional fields. New account_id values must reference an active BRL CHECKING or INVESTMENT account in the workspace. Legacy unlinked or incompatible offers remain editable for manual correction. external_ref is immutable. No financial account records are changed.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Opportunity UUID |
| opportunity | body | entity.OpportunityTerms | sim | Partial offer fields |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.opportunityResponse |
| 400 | Bad Request | object |
| 404 | Not Found | object |

## POST `/opportunities`

**Resumo:** Save a quoted investment opportunity

Save a draft or complete offer without buying, moving cash or creating an investment. account_id must reference an active BRL CHECKING or INVESTMENT account in the selected workspace for a new available offer; unlinked drafts are allowed. Institution and issuer may differ from the linked account. Omit unreadable terms; never infer values from an image. An optional Idempotency-Key or external_ref safely deduplicates retries within a workspace.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| Idempotency-Key | header | string | não | Stable caller retry key, up to 200 characters |
| opportunity | body | entity.OpportunityTerms | sim | Offer terms; rate_percent is annual percent for prefix/IPCA+ or contracted percent of CDI |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | v1.opportunityResponse |
| 400 | Bad Request | object |
| 409 | Conflict | object |

## POST `/opportunities/{id}/unavailable`

**Resumo:** Mark opportunity unavailable

Mark a quoted offer unavailable. Existing simulations, investments, transactions and balances are not altered.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Opportunity UUID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.opportunityResponse |
| 404 | Not Found | object |

## POST `/opportunities/compare`

**Resumo:** Compare quoted opportunities

Simulate two to twenty offers in request order under identical user supplied assumptions. No ranking or buy recommendation is produced.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| comparison | body | v1.opportunityCompareRequest | sim | Opportunity IDs and shared scenario |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.opportunityCompareResponse |
| 400 | Bad Request | object |

## POST `/opportunities/simulate`

**Resumo:** Simulate one quoted opportunity

Provide exactly one of opportunity_id or unsaved opportunity. Assumptions are user supplied scenarios, not forecasts. Returns missing_fields and warnings where a reliable output is unavailable.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| simulation | body | v1.opportunitySimulationRequest | sim | Opportunity and common scenario |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.opportunitySimulationResponse |
| 400 | Bad Request | object |

### Schemas

#### entity.OpportunityTerms

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_id | string | não |  |
| costs_known | boolean | não |  |
| external_ref | string | não |  |
| institution | string | não |  |
| issuer | string | não |  |
| liquidity_date | string | não |  |
| maturity_date | string | não |  |
| minimum_amount | number | não |  |
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
| upfront_cost | number | não |  |
| valid_until | string | não |  |

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

#### v1.opportunityCompareRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| assumptions | usecase.SimulationAssumptions | não |  |
| opportunity_ids | array&lt;string&gt; | não |  |

#### v1.opportunityCompareResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| simulations | array&lt;usecase.SimulationResult&gt; | não |  |

#### v1.opportunityListResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| opportunities | array&lt;usecase.OpportunityView&gt; | não |  |

#### v1.opportunityResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| opportunity | usecase.OpportunityView | não |  |

#### v1.opportunitySimulationRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| assumptions | usecase.SimulationAssumptions | não |  |
| opportunity | entity.OpportunityTerms | não |  |
| opportunity_id | string | não |  |

#### v1.opportunitySimulationResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| simulation | usecase.SimulationResult | não |  |
