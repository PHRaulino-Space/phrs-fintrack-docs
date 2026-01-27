---
title: Api Keys
---
## DELETE `/api-keys/{id}`

**Resumo:** Revoke API Key

Revoke an API key

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | API Key ID |
| X-Workspace-ID | header | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 400 | Bad Request | v1.ErrorResponse |
| 401 | Unauthorized | v1.ErrorResponse |

## GET `/api-keys`

**Resumo:** List API Keys

List all API keys for the current user in the current workspace

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;entity.ApiKey&gt; |
| 401 | Unauthorized | v1.ErrorResponse |

## POST `/api-keys`

**Resumo:** Create API Key

Create a new API key for programmatic access

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| request | body | v1.createApiKeyRequest | sim | API Key details |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | usecase.ApiKeyCreated |
| 400 | Bad Request | v1.ErrorResponse |
| 401 | Unauthorized | v1.ErrorResponse |

### Schemas

#### entity.ApiKey

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| expires_at | string | não |  |
| id | string | não |  |
| key_prefix | string | não | Adjusted length to fit prefix + partial hash |
| last_used_at | string | não |  |
| name | string | não |  |
| revoked_at | string | não |  |
| scopes | array&lt;string&gt; | não |  |
| updated_at | string | não |  |
| user_id | string | não |  |
| workspace_id | string | não |  |

#### usecase.ApiKeyCreated

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| createdAt | string | não |  |
| expiresAt | string | não |  |
| id | string | não |  |
| keyPrefix | string | não |  |
| name | string | não |  |
| rawKey | string | não | Mostrar apenas uma vez! |

#### v1.createApiKeyRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| expires_at | string | não |  |
| name | string | sim |  |

#### v1.ErrorResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| error | string | não |  |
