---
title: Settings
---
## GET `/settings/security`

**Resumo:** Get security settings

Retrieve current security settings for the authenticated user

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.securitySettingsResponse |
| 401 | Unauthorized | object |
| 500 | Internal Server Error | object |

### Schemas

#### v1.connectedProviderResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| email | string | não |  |
| name | string | não |  |

#### v1.securitySettingsPasskeyResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| id | string | não |  |
| last_used_at | string | não |  |
| name | string | não |  |

#### v1.securitySettingsResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| connected_providers | array&lt;v1.connectedProviderResponse&gt; | não |  |
| mfa_enabled | boolean | não |  |
| mfa_method | string | não |  |
| mfa_verified_at | string | não |  |
| passkey_enabled | boolean | não |  |
| passkeys | array&lt;v1.securitySettingsPasskeyResponse&gt; | não |  |
| recovery_codes_generated_at | string | não |  |
