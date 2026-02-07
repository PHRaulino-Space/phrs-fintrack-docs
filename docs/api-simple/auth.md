---
title: Auth
---
## DELETE `/auth/passkeys/{passkey_id}`

**Resumo:** Delete passkey

Remove a registered passkey

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| passkey_id | path | string | sim | Passkey ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |
| 500 | Internal Server Error | object |

## DELETE `/auth/providers/{provider}`

**Resumo:** Unlink provider

Remove a connected OAuth provider from the user account

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| provider | path | string | sim | Provider (github, google) |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |
| 500 | Internal Server Error | object |

## GET `/auth/{provider}/callback`

**Resumo:** OAuth callback

Handle OAuth callback from provider and set authentication cookie or link provider

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

## GET `/auth/{provider}/link`

**Resumo:** OAuth link initiation

Initiate OAuth link flow with the specified provider

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| provider | path | string | sim | OAuth provider (github) |
| redirect_to | query | string | não | Path to redirect after linking |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 307 | Redirect to OAuth provider |  |
| 400 | Bad Request | object |

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

## POST `/auth/forgot-password`

**Resumo:** Request password reset

Request a password reset email

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| request | body | v1.forgotPasswordRequest | sim | Password reset request |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 202 | Accepted | object |
| 400 | Bad Request | object |

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

## POST `/auth/mfa/confirm`

**Resumo:** Confirm MFA

Confirm MFA enrollment and return recovery codes

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| request | body | v1.mfaVerifyRequest | sim | MFA verification payload |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.mfaRecoveryCodesResponse |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |
| 500 | Internal Server Error | object |

## POST `/auth/mfa/disable`

**Resumo:** Disable MFA

Disable MFA using a valid code

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| request | body | v1.mfaVerifyRequest | sim | MFA verification payload |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |
| 500 | Internal Server Error | object |

## POST `/auth/mfa/recovery-codes`

**Resumo:** Generate MFA recovery codes

Generate a new set of recovery codes for the authenticated user

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.mfaRecoveryCodesResponse |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |
| 500 | Internal Server Error | object |

## POST `/auth/mfa/recovery-codes/regenerate`

**Resumo:** Generate MFA recovery codes

Generate a new set of recovery codes for the authenticated user

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.mfaRecoveryCodesResponse |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |
| 500 | Internal Server Error | object |

## POST `/auth/mfa/recovery-verify`

**Resumo:** Verify MFA recovery code

Verify a recovery code and issue MFA-verified tokens

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| request | body | v1.mfaRecoveryVerifyRequest | sim | Recovery code payload |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |
| 500 | Internal Server Error | object |

## POST `/auth/mfa/setup`

**Resumo:** Setup MFA

Initialize MFA enrollment and return secret/QR

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.mfaSetupResponse |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |

## POST `/auth/mfa/verify`

**Resumo:** Verify MFA

Verify MFA code and issue MFA-verified tokens

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| request | body | v1.mfaVerifyRequest | sim | MFA verification payload |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |
| 500 | Internal Server Error | object |

## POST `/auth/passkeys/login`

**Resumo:** Passkey login

Finish passkey login using WebAuthn response

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 401 | Unauthorized | object |

## POST `/auth/passkeys/login-challenge`

**Resumo:** Passkey login challenge

Begin passkey login and return WebAuthn options

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| request | body | v1.passkeyLoginChallengeRequest | sim | Passkey login challenge payload |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |

## POST `/auth/passkeys/register`

**Resumo:** Passkey registration

Finish passkey registration using WebAuthn response (optionally include passkey name)

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| request | body | v1.passkeyRegisterRequest | não | Optional passkey metadata |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |

## POST `/auth/passkeys/register-challenge`

**Resumo:** Passkey registration challenge

Begin passkey registration and return WebAuthn options

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |

## POST `/auth/refresh`

**Resumo:** Refresh tokens

Refresh access and refresh tokens using cookie or request body

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| request | body | v1.refreshRequest | não | Refresh token payload |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 401 | Unauthorized | object |

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

## POST `/auth/reset-password`

**Resumo:** Reset password

Reset password using a valid reset token

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| request | body | v1.resetPasswordRequest | sim | Password reset payload |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |

### Schemas

#### v1.forgotPasswordRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| email | string | sim |  |

#### v1.loginRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| email | string | sim |  |
| password | string | sim |  |

#### v1.mfaRecoveryCodesResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| recovery_codes | array&lt;string&gt; | não |  |
| recovery_codes_generated_at | string | não |  |

#### v1.mfaRecoveryVerifyRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| code | string | sim |  |

#### v1.mfaSetupResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| otpauth_url | string | não |  |
| qr_code_base64 | string | não |  |
| secret | string | não |  |

#### v1.mfaVerifyRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| code | string | sim |  |

#### v1.passkeyLoginChallengeRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| email | string | não |  |

#### v1.passkeyRegisterRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| name | string | não |  |

#### v1.refreshRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| refresh_token | string | não |  |

#### v1.registerRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| email | string | sim |  |
| name | string | sim |  |
| password | string | sim |  |

#### v1.resetPasswordRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| new_password | string | sim |  |
| token | string | sim |  |

#### v1.UserResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| email | string | não |  |
| has_password | boolean | não |  |
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
