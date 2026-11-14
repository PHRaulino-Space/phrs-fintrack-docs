---
title: Companies
---
## DELETE `/companies/{id}`

**Resumo:** Delete unused company

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Company ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |

## DELETE `/company-links/{id}`

**Resumo:** Delete shared link and its company associations

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Link ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |

## GET `/catalog/capabilities`

**Resumo:** Permissions for editing shared global catalogs

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |

## GET `/companies`

**Resumo:** List visible companies

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| type | query | string | não | BANK, COMPANY or GOVERNMENT |
| q | query | string | não | Name or CNPJ |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;entity.Company&gt; |

## GET `/companies/{id}`

**Resumo:** Get global company

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Company ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.Company |

## GET `/company-links`

**Resumo:** List reusable global links

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;entity.CompanyLink&gt; |

## PATCH `/companies/{id}`

**Resumo:** Update company

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Company ID |
| body | body | v1.CompanyRequest | sim | Company |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.Company |

## PATCH `/companies/{id}/verification`

**Resumo:** Review company verification

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Catalog ID |
| body | body | v1.CatalogVerificationRequest | sim | Verification |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 400 | Bad Request | object |
| 403 | Forbidden | object |
| 404 | Not Found | object |
| 409 | Conflict | object |

## PATCH `/company-links/{id}`

**Resumo:** Update shared link (affects all associated companies)

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Link ID |
| body | body | v1.CompanyLinkRequest | sim | Link |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.CompanyLink |

## PATCH `/company-links/{id}/verification`

**Resumo:** Review company verification

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Catalog ID |
| body | body | v1.CatalogVerificationRequest | sim | Verification |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 400 | Bad Request | object |
| 403 | Forbidden | object |
| 404 | Not Found | object |
| 409 | Conflict | object |

## PATCH `/crypto-assets/{id}/verification`

**Resumo:** Review company verification

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Catalog ID |
| body | body | v1.CatalogVerificationRequest | sim | Verification |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 400 | Bad Request | object |
| 403 | Forbidden | object |
| 404 | Not Found | object |
| 409 | Conflict | object |

## PATCH `/funds/{id}/verification`

**Resumo:** Review company verification

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Catalog ID |
| body | body | v1.CatalogVerificationRequest | sim | Verification |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 400 | Bad Request | object |
| 403 | Forbidden | object |
| 404 | Not Found | object |
| 409 | Conflict | object |

## POST `/companies`

**Resumo:** Create company with optional shared links

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| body | body | v1.CompanyRequest | sim | Company |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.Company |

## POST `/companies/lookup`

**Resumo:** Consult public company registration by CNPJ for human review

Read-only deterministic BrasilAPI lookup, not agentic inference. Numeric and alphanumeric CNPJs are supported. Names return guidance for the existing AI public-research journey. No company is saved, no type/site/logo is invented, and no account or investment data is sent.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| body | body | v1.CompanyLookupRequest | sim | Public company name or CNPJ |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.CompanyLookupResult |
| 400 | Bad Request | v1.ErrorResponse |

## POST `/company-links`

**Resumo:** Create reusable company link

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| body | body | v1.CompanyLinkRequest | sim | Link |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.CompanyLink |

### Schemas

#### entity.Company

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| admin_validated_at | string | não |  |
| admin_validated_by | string | não |  |
| admin_validation_source | string | não |  |
| admin_validation_version | integer | não |  |
| cnpj | string | não |  |
| content_version | integer | não |  |
| created_at | string | não |  |
| creator_user_id | string | não |  |
| id | string | não |  |
| is_verified | boolean | não |  |
| links | array&lt;entity.CompanyLink&gt; | não |  |
| logo_url | string | não |  |
| name | string | não |  |
| owner_workspace_id | string | não |  |
| type | string | não |  |
| updated_at | string | não |  |
| user_validated_at | string | não |  |
| user_validated_by | string | não |  |
| user_validation_version | integer | não |  |
| website | string | não |  |

#### entity.CompanyLink

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| admin_validated_at | string | não |  |
| admin_validated_by | string | não |  |
| admin_validation_source | string | não |  |
| admin_validation_version | integer | não |  |
| content_version | integer | não |  |
| created_at | string | não |  |
| creator_user_id | string | não |  |
| id | string | não |  |
| is_verified | boolean | não |  |
| label | string | não |  |
| owner_workspace_id | string | não |  |
| updated_at | string | não |  |
| url | string | não |  |
| user_validated_at | string | não |  |
| user_validated_by | string | não |  |
| user_validation_version | integer | não |  |

#### usecase.CompanyLookupCandidate

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| cnpj | string | não |  |
| name | string | não |  |

#### usecase.CompanyLookupResult

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| company | usecase.CompanyLookupCandidate | não |  |
| message | string | não |  |
| requires_review | boolean | não |  |
| research_prompt | string | não |  |
| sources | array&lt;usecase.CompanyLookupSource&gt; | não |  |
| status | string | não |  |

#### usecase.CompanyLookupSource

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| label | string | não |  |
| url | string | não |  |

#### v1.CatalogVerificationRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| is_verified | boolean | não |  |

#### v1.CompanyLinkRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| label | string | não |  |
| url | string | não |  |
| validate_globally | boolean | não |  |

#### v1.CompanyLookupRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| query | string | não |  |

#### v1.CompanyRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| cnpj | string | não |  |
| link_ids | array&lt;string&gt; | não |  |
| logo_url | string | não |  |
| name | string | não |  |
| type | string | não |  |
| validate_globally | boolean | não |  |
| website | string | não |  |

#### v1.ErrorResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| error | string | não |  |
