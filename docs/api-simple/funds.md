---
title: Funds
---
## DELETE `/funds/{id}`

**Resumo:** Delete unreferenced global fund (global admin)

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Fund ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |

## GET `/funds`

**Resumo:** List visible funds

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;entity.Fund&gt; |

## GET `/funds/{id}`

**Resumo:** Get global fund

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Fund ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.Fund |

## PATCH `/funds/{id}`

**Resumo:** Update global fund (global admin)

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Fund ID |
| body | body | v1.FundRequest | sim | Fund |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.Fund |

## POST `/funds`

**Resumo:** Create private workspace or verified global fund

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| body | body | v1.FundRequest | sim | Fund |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.Fund |

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

#### entity.Fund

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| admin_validated_at | string | não |  |
| admin_validated_by | string | não |  |
| admin_validation_source | string | não |  |
| admin_validation_version | integer | não |  |
| class_cnpj | string | não |  |
| class_name | string | não |  |
| cnpj | string | não |  |
| content_version | integer | não |  |
| created_at | string | não |  |
| creator_user_id | string | não |  |
| id | string | não |  |
| is_verified | boolean | não |  |
| manager_company | entity.Company | não |  |
| manager_company_id | string | não |  |
| name | string | não |  |
| owner_workspace_id | string | não |  |
| updated_at | string | não |  |
| user_validated_at | string | não |  |
| user_validated_by | string | não |  |
| user_validation_version | integer | não |  |

#### v1.FundRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| class_cnpj | string | não |  |
| class_name | string | não |  |
| cnpj | string | não |  |
| manager_company_id | string | não |  |
| name | string | não |  |
| validate_globally | boolean | não |  |
