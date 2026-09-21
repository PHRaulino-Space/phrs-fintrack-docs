---
title: Accounts
---
## DELETE `/accounts/{account_id}`

**Resumo:** Delete an account

Delete an account and all its related data (Cascade)

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| account_id | path | string | sim | Account ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 400 | Bad Request | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

## GET `/accounts`

**Resumo:** List accounts

List all accounts for a given workspace

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;v1.AccountResponse&gt; |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## GET `/accounts/{account_id}`

**Resumo:** Get a single account

Get a single account by its ID

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| account_id | path | string | sim | Account ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.AccountResponse |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## GET `/accounts/images`

**Resumo:** List account images

List image objects available under the configured S3-compatible storage prefix

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;objectstorage.Image&gt; |
| 503 | Service Unavailable | object |

## PATCH `/accounts/{account_id}`

**Resumo:** Update an existing account

Update an existing account by its ID

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| account_id | path | string | sim | Account ID |
| account | body | v1.AccountUpdateRequest | sim | Account object for update |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.AccountResponse |
| 400 | Bad Request | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

## POST `/accounts`

**Resumo:** Create a new account

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| account | body | v1.AccountRequest | sim | Account object |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | v1.AccountResponse |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

### Schemas

#### entity.AccountType

Sem propriedades.

#### objectstorage.Image

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| key | string | não |  |
| url | string | não |  |

#### v1.AccountRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| currency_code | string | não |  |
| image_key | string | não |  |
| initial_balance | number | não |  |
| name | string | sim |  |
| type | entity.AccountType | sim |  |

#### v1.AccountResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| currency_code | string | não |  |
| id | string | não |  |
| image_key | string | não |  |
| image_url | string | não |  |
| initial_balance | number | não |  |
| is_active | boolean | não |  |
| name | string | não |  |
| type | entity.AccountType | não |  |
| updated_at | string | não |  |
| workspace_id | string | não |  |

#### v1.AccountUpdateRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| currency_code | string | não |  |
| image_key | string | não |  |
| initial_balance | number | não |  |
| is_active | boolean | não |  |
| name | string | não |  |
| type | entity.AccountType | não |  |
