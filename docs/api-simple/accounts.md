---
title: Accounts
description: "Endpoints de contas"
---
Endpoints de contas

## DELETE `/accounts/{id}`

**Resumo:** Delete an account

Delete an account and all its related data (Cascade)

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Account ID |

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

## GET `/accounts/{id}`

**Resumo:** Get a single account

Get a single account by its ID

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Account ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.AccountResponse |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## PATCH `/accounts/{id}`

**Resumo:** Update an existing account

Update an existing account by its ID

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Account ID |
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

#### v1.AccountRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| currency_code | string | não |  |
| initial_balance | number | não |  |
| name | string | sim |  |
| type | entity.AccountType | sim |  |

#### v1.AccountResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| currency_code | string | não |  |
| id | string | não |  |
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
| initial_balance | number | não |  |
| is_active | boolean | não |  |
| name | string | não |  |
| type | entity.AccountType | não |  |
