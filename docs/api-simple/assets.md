---
title: Assets
---
## DELETE `/assets/{id}`

**Resumo:** Delete an asset and its non-financial metadata

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Asset ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |

## GET `/assets`

**Resumo:** List assets with tagged expenses and valuations

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;usecase.AssetDetail&gt; |

## GET `/assets/{id}`

**Resumo:** Get an asset's expenses and valuation history

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Asset ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AssetDetail |

## GET `/assets/{id}/financing/events`

**Resumo:** List dated bank statement rows and calculated financing differences

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Asset ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;usecase.AssetFinancingEventView&gt; |

## PATCH `/assets/{id}`

**Resumo:** Edit an asset, its initial valuation and financing choice atomically

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Asset ID |
| asset | body | v1.assetUpdateBody | sim | Asset update |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AssetDetail |
| 409 | Conflict | object |

## POST `/assets`

**Resumo:** Create an asset and its dedicated workspace tag atomically

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| asset | body | v1.assetBody | sim | Asset |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | usecase.AssetDetail |

## POST `/assets/{id}/valuations`

**Resumo:** Record a dated sale-value estimate without a financial transaction

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Asset ID |
| valuation | body | v1.assetValuationBody | sim | Valuation |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | usecase.AssetDetail |

## PUT `/assets/{id}/expenses/{kind}/{source_id}/payment`

**Resumo:** Inform or clear principal and known charges of one classified installment

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Asset ID |
| kind | path | string | sim | expense or card_expense |
| source_id | path | string | sim | Tagged expense ID |
| payment | body | v1.assetPaymentBody | sim | Nullable informed principal and known charges |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AssetDetail |

## PUT `/assets/{id}/expenses/{kind}/{source_id}/purpose`

**Resumo:** Classify a tagged expense in the asset's local acquisition or costs group

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Asset ID |
| kind | path | string | sim | expense or card_expense |
| source_id | path | string | sim | Expense ID |
| purpose | body | v1.assetPurposeBody | sim | Purpose |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AssetDetail |

## PUT `/assets/{id}/financing`

**Resumo:** Save optional financing tracking metadata without creating financial transactions

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Asset ID |
| financing | body | v1.assetFinancingBody | sim | Full financing configuration; omitted optional fields are cleared |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AssetDetail |

## PUT `/assets/{id}/financing/events/{external_key}`

**Resumo:** Upsert one dated external financing statement row without changing transactions

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Asset ID |
| external_key | path | string | sim | Stable statement row key |
| event | body | v1.assetFinancingEventBody | sim | Known bank amounts; omitted values stay unknown; expense_refs must be tagged to this asset |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AssetDetail |

## PUT `/assets/{id}/sale`

**Resumo:** Record or clear an actual asset sale without posting financial transactions

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Asset ID |
| sale | body | v1.assetSaleBody | sim | Sale date and price, optional confirmed acquisition cost; all null to clear |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AssetDetail |

### Schemas

#### entity.AssetFinancing

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| asset_id | string | não |  |
| default_principal | number | não |  |
| enabled | boolean | não |  |
| original_principal | number | não |  |
| rate_percent | number | não |  |
| rate_period | string | não |  |
| rate_type | string | não |  |
| reference_date | string | não |  |

#### entity.AssetFinancingExpenseRef

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| source_id | string | não |  |
| source_kind | string | não |  |

#### entity.AssetValuation

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| asset_id | string | não |  |
| created_at | string | não |  |
| id | string | não |  |
| source | string | não |  |
| valuation_date | string | não |  |
| value | number | não |  |

#### usecase.AssetDetail

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| acquisition | number | não |  |
| acquisition_cost | number | não |  |
| created_at | string | não |  |
| expenses | array&lt;usecase.AssetExpense&gt; | não |  |
| financing | entity.AssetFinancing | não |  |
| financing_events | array&lt;usecase.AssetFinancingEventView&gt; | não |  |
| financing_summary | usecase.AssetFinancingSummary | não |  |
| id | string | não |  |
| kind | string | não |  |
| maintenance | number | não |  |
| mixed_currency | boolean | não |  |
| name | string | não |  |
| purpose_totals | object | não |  |
| sale_price | number | não |  |
| sold_at | string | não |  |
| tag_id | string | não |  |
| total | number | não |  |
| updated_at | string | não |  |
| valuations | array&lt;entity.AssetValuation&gt; | não |  |
| workspace_id | string | não |  |

#### usecase.AssetExpense

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| breakdown | usecase.AssetPaymentBreakdown | não |  |
| currency_code | string | não |  |
| date | string | não |  |
| description | string | não |  |
| fees_amount | number | não |  |
| principal_amount | number | não |  |
| purpose | string | não |  |
| source_id | string | não |  |
| source_kind | string | não |  |
| transaction_status | string | não |  |

#### usecase.AssetFinancingEventView

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| actual_paid_amount | number | não |  |
| allocation_difference | number | não |  |
| asset_id | string | não |  |
| bank_paid_amount | number | não |  |
| charges_amount | number | não |  |
| components_total | number | não |  |
| correction_amount | number | não |  |
| correction_factor | number | não |  |
| created_at | string | não |  |
| dfi_amount | number | não |  |
| due_amount | number | não |  |
| due_difference | number | não |  |
| event_date | string | não |  |
| expense_refs | array&lt;entity.AssetFinancingExpenseRef&gt; | não |  |
| external_key | string | não |  |
| financial_adjustment | number | não |  |
| id | string | não |  |
| installment_number | integer | não |  |
| interest_amount | number | não |  |
| kind | string | não |  |
| mip_amount | number | não |  |
| note | string | não |  |
| opening_balance | number | não |  |
| origin | string | não |  |
| other_charges_amount | number | não |  |
| outlay_minus_principal | number | não |  |
| payment_difference | number | não |  |
| payment_status | string | não |  |
| principal_amount | number | não |  |
| raw_payment_difference | number | não |  |
| reference_date | string | não |  |
| running_balance | number | não |  |
| running_balance_status | string | não |  |
| source_type | string | não |  |
| tca_amount | number | não |  |
| updated_at | string | não |  |

#### usecase.AssetFinancingSummary

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| balance_issues | array&lt;string&gt; | não |  |
| balance_status | string | não | COMPLETE, PARTIAL, UNAVAILABLE |
| bank_adjustments | number | não |  |
| bank_charges | number | não |  |
| bank_correction | number | não |  |
| bank_interest | number | não |  |
| calculated_balance | number | não |  |
| estimated_principal | number | não |  |
| estimated_remaining | number | não |  |
| excess_principal | number | não |  |
| excluded_before_reference | integer | não |  |
| extra_non_principal_paid | number | não |  |
| extra_principal | number | não |  |
| identified_remaining | number | não |  |
| informed_principal | number | não |  |
| invalid_allocations | integer | não |  |
| paid | number | não |  |
| pending_amount | number | não |  |
| unallocated_extra_paid | number | não |  |
| unspecified_installments | integer | não |  |

#### usecase.AssetPaymentBreakdown

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| fees | number | não |  |
| interest | number | não | difference after fees; estimated when principal uses the default |
| paid | number | não |  |
| principal | number | não |  |
| principal_source | string | não | INFORMED, DEFAULT_ESTIMATE, UNSPECIFIED, INVALID |
| residual | number | não | interest plus unspecified insurance/fees |

#### v1.assetBody

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| acquisition_date | string | sim |  |
| kind | string | sim |  |
| name | string | sim |  |

#### v1.assetFinancingBody

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| default_principal | number | não |  |
| enabled | boolean | não |  |
| original_principal | number | não |  |
| rate_percent | number | não |  |
| rate_period | string | não |  |
| rate_type | string | não |  |
| reference_date | string | não |  |

#### v1.assetFinancingEditBody

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| enabled | boolean | não |  |
| original_principal | number | não |  |
| reference_date | string | não |  |

#### v1.assetFinancingEventBody

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| bank_paid_amount | number | não |  |
| charges_amount | number | não |  |
| correction_amount | number | não |  |
| correction_factor | number | não |  |
| dfi_amount | number | não |  |
| due_amount | number | não |  |
| event_date | string | não |  |
| expense_refs | array&lt;entity.AssetFinancingExpenseRef&gt; | não |  |
| external_key | string | não |  |
| financial_adjustment | number | não |  |
| installment_number | integer | não |  |
| interest_amount | number | não |  |
| kind | string | não |  |
| mip_amount | number | não |  |
| note | string | não |  |
| opening_balance | number | não |  |
| origin | string | não |  |
| other_charges_amount | number | não |  |
| principal_amount | number | não |  |
| reference_date | string | não |  |
| source_type | string | não |  |
| tca_amount | number | não |  |

#### v1.assetPaymentBody

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| fees_amount | number | não |  |
| principal_amount | number | não |  |

#### v1.assetPurposeBody

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| purpose | string | sim |  |

#### v1.assetSaleBody

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| acquisition_cost | number | não |  |
| date | string | não |  |
| price | number | não |  |

#### v1.assetUpdateBody

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| acquisition_date | string | não |  |
| financing | v1.assetFinancingEditBody | não |  |
| initial_value | number | não |  |
| kind | string | sim |  |
| name | string | sim |  |

#### v1.assetValuationBody

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| date | string | sim |  |
| value | number | não |  |
