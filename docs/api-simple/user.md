---
title: User
---
## DELETE `/user`

**Resumo:** Confirm account deletion

Confirm account deletion using the provided token

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| token | query | string | sim | Account deletion token |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |
| 403 | Forbidden | object |
| 500 | Internal Server Error | object |

## PATCH `/user/profile`

**Resumo:** Update user profile

Update the user name and request an email change (requires verification).

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| request | body | v1.updateProfileRequest | sim | Profile update payload |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.UserResponse |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |
| 500 | Internal Server Error | object |

## POST `/user/delete-request`

**Resumo:** Request account deletion

Create an account deletion request and return a confirmation token

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.accountDeletionRequestResponse |
| 401 | Unauthorized | object |
| 403 | Forbidden | object |
| 500 | Internal Server Error | object |

## POST `/user/password`

**Resumo:** Update password

Update the user password using the current password

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| request | body | v1.updatePasswordRequest | sim | Password update payload |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 202 | Accepted | object |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |
| 500 | Internal Server Error | object |

### Schemas

#### v1.accountDeletionRequestResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| expires_at | string | não |  |
| token | string | não |  |

#### v1.updatePasswordRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| current_password | string | sim |  |
| new_password | string | sim |  |

#### v1.updateProfileRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| email | string | sim |  |
| name | string | sim |  |

#### v1.UserResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| email | string | não |  |
| email_verified | boolean | não |  |
| has_password | boolean | não |  |
| id | string | não |  |
| name | string | não |  |
| pending_email | string | não |  |
