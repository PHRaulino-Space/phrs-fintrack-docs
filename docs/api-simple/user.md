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

## DELETE `/user/cloudflare-link`

**Resumo:** Remove Cloudflare MCP account link

Disconnects the Cloudflare identity from the authenticated Fintrack account.

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 401 | Unauthorized | object |

## GET `/user/cloudflare-link`

**Resumo:** Get Cloudflare MCP link status

Shows whether the authenticated Fintrack account is linked to Cloudflare Access.

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.cloudflareLinkStatus |
| 401 | Unauthorized | object |

## GET `/user/preferences`

**Resumo:** Get user preferences

Get preferences for the authenticated user

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.preferencesResponse |
| 401 | Unauthorized | object |
| 500 | Internal Server Error | object |

## PATCH `/user/preferences`

**Resumo:** Update user preferences

Update preferences for the authenticated user

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| request | body | v1.preferencesRequest | sim | Preferences payload |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.preferencesResponse |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |
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

## POST `/user/cloudflare-link/begin`

**Resumo:** Begin Cloudflare MCP account link

Creates a short-lived one-time state and returns the Access-protected URL.

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.cloudflareLinkStart |
| 401 | Unauthorized | object |
| 409 | Conflict | object |

## POST `/user/cloudflare-link/complete`

**Resumo:** Complete Cloudflare MCP account link

Verifies a signed Access assertion and a one-time state for the Fintrack session.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| request | body | v1.cloudflareLinkCompleteRequest | sim | One-time link state |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |
| 409 | Conflict | object |

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

## POST `/user/email/cancel`

**Resumo:** Cancel pending email change

Cancel a pending email change for the authenticated user

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.UserResponse |
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

#### v1.cloudflareLinkCompleteRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| state | string | sim |  |

#### v1.cloudflareLinkStart

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| expires_at | string | não |  |
| url | string | não |  |

#### v1.cloudflareLinkStatus

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| available | boolean | não |  |
| connected | boolean | não |  |
| email | string | não |  |
| linked_at | string | não |  |

#### v1.preferencesRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| settings | object | sim |  |

#### v1.preferencesResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| settings | object | não |  |

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
