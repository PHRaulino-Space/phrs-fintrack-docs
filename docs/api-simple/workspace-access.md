---
title: Workspace Access
---
## DELETE `/workspaces/{workspace_id}/invitations/{invite_id}`

**Resumo:** Revoke a workspace invitation

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| workspace_id | path | string | sim | Workspace ID |
| invite_id | path | string | sim | Invitation ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 400 | Bad Request | v1.ErrorResponse |
| 401 | Unauthorized | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |
| 404 | Not Found | v1.ErrorResponse |
| 500 | Internal Server Error | v1.ErrorResponse |

## DELETE `/workspaces/{workspace_id}/members/{user_id}`

**Resumo:** Remove a workspace member

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| workspace_id | path | string | sim | Workspace ID |
| user_id | path | string | sim | User ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 400 | Bad Request | v1.ErrorResponse |
| 401 | Unauthorized | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |
| 404 | Not Found | v1.ErrorResponse |
| 500 | Internal Server Error | v1.ErrorResponse |

## GET `/workspaces/{workspace_id}/invitations`

**Resumo:** List workspace invitations

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| workspace_id | path | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;entity.WorkspaceInvite&gt; |
| 401 | Unauthorized | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |
| 500 | Internal Server Error | v1.ErrorResponse |

## GET `/workspaces/{workspace_id}/members`

**Resumo:** List workspace members

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| workspace_id | path | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;entity.WorkspaceMemberDetails&gt; |
| 401 | Unauthorized | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |
| 500 | Internal Server Error | v1.ErrorResponse |

## PATCH `/workspaces/{workspace_id}/members/{user_id}`

**Resumo:** Change a workspace member role

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| workspace_id | path | string | sim | Workspace ID |
| user_id | path | string | sim | User ID |
| membership | body | v1.updateWorkspaceMemberRoleRequest | sim | New role |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.WorkspaceMember |
| 400 | Bad Request | v1.ErrorResponse |
| 401 | Unauthorized | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |
| 404 | Not Found | v1.ErrorResponse |
| 500 | Internal Server Error | v1.ErrorResponse |

## POST `/workspace-invitations/accept`

**Resumo:** Accept a workspace invitation

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| invitation | body | v1.acceptWorkspaceInviteRequest | sim | Invitation token |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.WorkspaceMember |
| 400 | Bad Request | v1.ErrorResponse |
| 401 | Unauthorized | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |
| 404 | Not Found | v1.ErrorResponse |
| 409 | Conflict | v1.ErrorResponse |

## POST `/workspaces/{workspace_id}/invitations`

**Resumo:** Invite a workspace member

Create or resend a workspace invitation. Only workspace administrators may invite members.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| workspace_id | path | string | sim | Workspace ID |
| invitation | body | v1.inviteWorkspaceMemberRequest | sim | Invitation |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | usecase.WorkspaceInviteResult |
| 400 | Bad Request | v1.ErrorResponse |
| 401 | Unauthorized | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |
| 409 | Conflict | v1.ErrorResponse |
| 500 | Internal Server Error | v1.ErrorResponse |

### Schemas

#### entity.WorkspaceInvite

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| accepted_at | string | não |  |
| accepted_by_user_id | string | não |  |
| created_at | string | não |  |
| email | string | não |  |
| expires_at | string | não |  |
| id | string | não |  |
| invited_by | string | não |  |
| role | entity.WorkspaceMemberRole | não |  |
| updated_at | string | não |  |
| workspace_id | string | não |  |

#### entity.WorkspaceMember

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| role | entity.WorkspaceMemberRole | não |  |
| user_id | string | não |  |
| workspace_id | string | não |  |

#### entity.WorkspaceMemberDetails

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| email | string | não |  |
| name | string | não |  |
| role | entity.WorkspaceMemberRole | não |  |
| user_id | string | não |  |
| workspace_id | string | não |  |

#### entity.WorkspaceMemberRole

Sem propriedades.

#### usecase.WorkspaceInviteResult

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| invite | entity.WorkspaceInvite | não |  |
| token | string | não |  |

#### v1.acceptWorkspaceInviteRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| token | string | sim |  |

#### v1.ErrorResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| error | string | não |  |

#### v1.inviteWorkspaceMemberRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| email | string | sim |  |
| role | entity.WorkspaceMemberRole | sim |  |

#### v1.updateWorkspaceMemberRoleRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| role | entity.WorkspaceMemberRole | sim |  |
