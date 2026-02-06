---
title: User
---
## PATCH `/user/profile`

**Resumo:** Update user profile

Update the user name and email. If email changes, OAuth identities are unlinked.

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
| 200 | OK | object |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |
| 500 | Internal Server Error | object |

### Schemas

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
| has_password | boolean | não |  |
| id | string | não |  |
| name | string | não |  |
