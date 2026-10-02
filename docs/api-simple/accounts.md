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
| assigned_user_id | query | string | não | Filter by assigned workspace user ID |
| unassigned | query | boolean | não | Only accounts without an assigned user (true) |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;v1.AccountResponse&gt; |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |
| 503 | Service Unavailable | object |

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
| 503 | Service Unavailable | object |

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
| 503 | Service Unavailable | object |

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
| 503 | Service Unavailable | object |

## POST `/accounts/images/upload-url`

**Resumo:** Create an image PUT URL

Sign a PUT for a relative image key under the configured prefix and authenticated workspace ID. Upload with the returned Content-Type, then save key as image_key.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| request | body | v1.imageUploadRequest | sim | Image key and content type |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.imageUploadResponse |
| 400 | Bad Request | object |
| 503 | Service Unavailable | object |

## POST `/cards/images/upload-url`

**Resumo:** Create an image PUT URL

Sign a PUT for a relative image key under the configured prefix and authenticated workspace ID. Upload with the returned Content-Type, then save key as image_key.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| request | body | v1.imageUploadRequest | sim | Image key and content type |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.imageUploadResponse |
| 400 | Bad Request | object |
| 503 | Service Unavailable | object |

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
| assigned_user_id | string | não |  |
| currency_code | string | não |  |
| image_key | string | não |  |
| initial_balance | number | não |  |
| name | string | sim |  |
| type | entity.AccountType | sim |  |

#### v1.AccountResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| assigned_user_id | string | não |  |
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
| assigned_user_id | string | não |  |
| currency_code | string | não |  |
| image_key | string | não |  |
| initial_balance | number | não |  |
| is_active | boolean | não |  |
| name | string | não |  |
| type | entity.AccountType | não |  |

#### v1.imageUploadRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| content_type | string | sim |  |
| key | string | sim |  |

#### v1.imageUploadResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| expires_in | integer | não |  |
| headers | object | não |  |
| key | string | não |  |
| method | string | não |  |
| url | string | não |  |
