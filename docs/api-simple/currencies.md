---
title: Currencies
---
## GET `/currencies`

**Resumo:** List all currencies

List all available currencies in the system

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;v1.currencyResponse&gt; |
| 500 | Internal Server Error | object |

## GET `/currencies/{code}`

**Resumo:** Get a single currency

Get a single currency by its code

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| code | path | string | sim | Currency Code (e.g., BRL, USD) |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.currencyResponse |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## POST `/currencies`

**Resumo:** Propose a private workspace currency

Creates an unverified currency visible only in this workspace and to global administrators. Only global administrators can edit or verify it.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| body | body | v1.currencyCreateRequest | sim | Currency identity |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.Currency |
| 400 | Bad Request | object |
| 403 | Forbidden | object |
| 409 | Conflict | object |

### Schemas

#### entity.Currency

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| admin_validated_at | string | não |  |
| admin_validated_by | string | não |  |
| admin_validation_source | string | não |  |
| admin_validation_version | integer | não |  |
| code | string | não |  |
| content_version | integer | não |  |
| created_at | string | não |  |
| creator_user_id | string | não |  |
| is_active | boolean | não |  |
| is_verified | boolean | não |  |
| name | string | não |  |
| owner_workspace_id | string | não |  |
| symbol | string | não |  |
| updated_at | string | não |  |
| user_validated_at | string | não |  |
| user_validated_by | string | não |  |
| user_validation_version | integer | não |  |

#### v1.currencyCreateRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| code | string | não |  |
| is_active | boolean | não |  |
| name | string | não |  |
| symbol | string | não |  |

#### v1.currencyResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| code | string | não |  |
| is_active | boolean | não |  |
| is_verified | boolean | não |  |
| name | string | não |  |
| owner_workspace_id | string | não |  |
| symbol | string | não |  |
