---
title: Notifications
---
## DELETE `/notifications/{id}`

**Resumo:** Delete notification

Delete a notification

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Notification ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |
| 500 | Internal Server Error | object |

## GET `/notifications`

**Resumo:** List notifications

List notifications for the authenticated user

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| workspace_id | query | string | não | Filter by workspace ID |
| unread_only | query | boolean | não | Only unread notifications |
| limit | query | integer | não | Limit |
| offset | query | integer | não | Offset |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.notificationListResponse |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |
| 500 | Internal Server Error | object |

## PATCH `/notifications/{id}/read`

**Resumo:** Mark notification as read

Mark a notification as read

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Notification ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |
| 500 | Internal Server Error | object |

### Schemas

#### v1.notificationListResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| items | array&lt;v1.NotificationResponse&gt; | não |  |

#### v1.NotificationResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| id | string | não |  |
| message | string | não |  |
| payload | object | não |  |
| read_at | string | não |  |
| title | string | não |  |
| type | string | não |  |
| user_id | string | não |  |
| workspace_id | string | não |  |
