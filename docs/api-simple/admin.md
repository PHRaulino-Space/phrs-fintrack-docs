---
title: Admin
---
## DELETE `/admin/users/{user_id}`

**Resumo:** Delete user account (admin)

Deletes a user account directly. Admin accounts cannot be deleted.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| user_id | path | string | sim | User ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 202 | Accepted | object |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |
| 403 | Forbidden | object |
| 500 | Internal Server Error | object |

## GET `/admin/users/deleted`

**Resumo:** List deleted users (admin)

List users flagged for deletion

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;v1.deletedUserResponse&gt; |
| 401 | Unauthorized | object |
| 403 | Forbidden | object |
| 500 | Internal Server Error | object |

### Schemas

#### v1.deletedUserResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| deleted | boolean | não |  |
| deleted_at | string | não |  |
| email | string | não |  |
| id | string | não |  |
| name | string | não |  |
| role | string | não |  |
| updated_at | string | não |  |
