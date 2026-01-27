---
title: Auth
---
## GET `/auth/{provider}/callback`

**Resumo:** OAuth callback

Handle OAuth callback from provider and set authentication cookie

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| provider | path | string | sim | OAuth provider (github) |
| code | query | string | sim | Authorization code from provider |
| state | query | string | sim | State parameter for CSRF protection |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 302 | Redirect to frontend with auth cookie set |  |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |

## GET `/auth/{provider}/login`

**Resumo:** OAuth login initiation

Initiate OAuth login flow with the specified provider (e.g., github)

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| provider | path | string | sim | OAuth provider (github) |
| redirect_to | query | string | não | Path to redirect after login |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 307 | Redirect to OAuth provider |  |
| 400 | Bad Request | object |

## GET `/auth/validate`

**Resumo:** Validate token

Validate authentication token and return user information with workspaces

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.ValidateResponse |
| 401 | Unauthorized |  |
| 500 | Internal Server Error |  |

## POST `/auth/login`

**Resumo:** Native login

Login with email and password, returns authentication cookie

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| request | body | v1.loginRequest | sim | Login credentials |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |

## POST `/auth/logout`

**Resumo:** Logout

Clear authentication cookie and logout user

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | Logout successful |  |

## POST `/auth/register`

**Resumo:** Register new user

Register a new user with email and password (native authentication)

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| request | body | v1.registerRequest | sim | User registration data |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | User created successfully |  |
| 400 | Bad Request | object |

### Schemas

#### v1.loginRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| email | string | sim |  |
| password | string | sim |  |

#### v1.registerRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| email | string | sim |  |
| name | string | sim |  |
| password | string | sim |  |

#### v1.UserResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| email | string | não |  |
| id | string | não |  |
| name | string | não |  |

#### v1.ValidateResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| status | string | não |  |
| user | v1.UserResponse | não |  |
| workspaces | array&lt;v1.WorkspaceResponse&gt; | não |  |

#### v1.WorkspaceResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| id | string | não |  |
| name | string | não |  |
| role | string | não |  |
| updated_at | string | não |  |
