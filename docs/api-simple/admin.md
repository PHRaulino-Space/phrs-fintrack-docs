---
title: Admin
---
## DELETE `/admin/currencies/{code}`

**Resumo:** Delete unused fiat currency

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| code | path | string | sim | Currency code |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |

## DELETE `/admin/users/{user_id}`

**Resumo:** Logically delete a user as global administrator

Requires a user session, fresh MFA when enabled and exact preview confirmation_name (current name, or user ID for unnamed users). Revokes access and removes memberships, retaining historical identity and workspace data. Protected users and workspace ownership blockers are rejected.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| user_id | path | string | sim | User ID |
| body | body | v1.AdminDeleteUserRequest | sim | Current user name confirmation |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |
| 403 | Forbidden | object |
| 404 | Not Found | object |
| 409 | Conflict | object |

## DELETE `/admin/workspaces/{workspace_id}`

**Resumo:** Permanently delete a workspace as global administrator

Requires a user session, fresh MFA when enabled and exact current workspace name confirmation. Deletes workspace data, preserving users and global catalogs. Refuses to remove any member's last workspace.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| workspace_id | path | string | sim | Workspace ID |
| body | body | v1.AdminDeleteWorkspaceRequest | sim | Current workspace name confirmation |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |
| 403 | Forbidden | object |
| 404 | Not Found | object |
| 409 | Conflict | object |

## DELETE `/admin/workspaces/{workspace_id}/members/{user_id}`

**Resumo:** Remove membership, preserving last admin and last workspace

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| workspace_id | path | string | sim | Workspace ID |
| user_id | path | string | sim | User ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |

## GET `/admin/currencies`

**Resumo:** List fiat currencies for administration

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;entity.Currency&gt; |

## GET `/admin/dashboard`

**Resumo:** Application administrator operational overview

Read-only consistent snapshot of users/workspaces and non-deleted accounts/cards counts. Recent login data is prospective only, never inferred from refresh, activity or creation timestamps. No balances, transaction data, credentials or financial values are returned. No workspace header is required.

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AdminDashboard |
| 401 | Unauthorized | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |

## GET `/admin/users`

**Resumo:** List application users without credentials or financial data

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;usecase.AdminUserSummary&gt; |

## GET `/admin/users/{user_id}/deletion-preview`

**Resumo:** Preview global user deletion

Lists blockers and affected workspace counts, without deleting anything. Requires a global administrator's user session.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| user_id | path | string | sim | User ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AdminUserDeletionPreview |
| 400 | Bad Request | object |
| 403 | Forbidden | object |
| 404 | Not Found | object |

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

## GET `/admin/workspace-defaults`

**Resumo:** Get effective template for future workspaces

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.WorkspaceDefaultsDocument |

## GET `/admin/workspaces`

**Resumo:** List workspace metadata, not balances

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;usecase.AdminWorkspaceSummary&gt; |

## GET `/admin/workspaces/{workspace_id}/members`

**Resumo:** List workspace members and permissions

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| workspace_id | path | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;usecase.AdminMemberSummary&gt; |

## PATCH `/admin/currencies/{code}`

**Resumo:** Update fiat currency (code immutable)

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| code | path | string | sim | Currency code |
| body | body | v1.AdminCurrencyRequest | sim | Currency fields |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.Currency |

## PATCH `/admin/users/{user_id}`

**Resumo:** Change application role (last global administrator protected)

**Consumes:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| user_id | path | string | sim | User ID |
| body | body | object | sim | role: admin or user |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |

## PATCH `/admin/workspaces/{workspace_id}`

**Resumo:** Rename workspace without changing financial settings

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| workspace_id | path | string | sim | Workspace ID |
| body | body | object | sim | name |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |

## POST `/admin/currencies`

**Resumo:** Create fiat currency

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| body | body | v1.AdminCurrencyRequest | sim | Currency |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.Currency |

## POST `/admin/train-embeddings`

**Resumo:** Train category embeddings

Starts category embedding training in the background (admin only).

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 202 | Accepted | object |
| 401 | Unauthorized | object |
| 403 | Forbidden | object |

## PUT `/admin/workspace-defaults`

**Resumo:** Replace template using expected revision; existing workspaces unchanged

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| body | body | entity.WorkspaceDefaultsDocument | sim | Template with expected revision |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.WorkspaceDefaultsDocument |

## PUT `/admin/workspaces/{workspace_id}/members/{user_id}`

**Resumo:** Add an existing active user or update workspace membership

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| workspace_id | path | string | sim | Workspace ID |
| user_id | path | string | sim | User ID |
| body | body | object | sim | role: admin or member |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |

### Schemas

#### entity.CategoryType

Sem propriedades.

#### entity.Currency

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| admin_validated_at | string | não |  |
| admin_validated_by | string | não |  |
| admin_validation_source | string | não |  |
| admin_validation_version | integer | não |  |
| code | string | não |  |
| content_version | integer | não |  |
| created_at | string | não |  |
| creator_user_id | string | não |  |
| is_active | boolean | não |  |
| is_verified | boolean | não |  |
| name | string | não |  |
| owner_workspace_id | string | não |  |
| symbol | string | não |  |
| updated_at | string | não |  |
| user_validated_at | string | não |  |
| user_validated_by | string | não |  |
| user_validation_version | integer | não |  |

#### entity.Role

Sem propriedades.

#### entity.WorkspaceDefaultCategory

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| color | string | não |  |
| group_name | string | não |  |
| icon | string | não |  |
| name | string | não |  |
| sub_categories | array&lt;string&gt; | não |  |
| type | entity.CategoryType | não |  |

#### entity.WorkspaceDefaultGroup

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| basis_points | integer | não |  |
| kind | string | não |  |
| name | string | não |  |

#### entity.WorkspaceDefaultsDocument

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| categories | array&lt;entity.WorkspaceDefaultCategory&gt; | não |  |
| groups | array&lt;entity.WorkspaceDefaultGroup&gt; | não |  |
| onboarding_workspace_name_template | string | não |  |
| revision | integer | não |  |

#### entity.WorkspaceMemberRole

Sem propriedades.

#### usecase.AdminDashboard

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| active_users | integer | não |  |
| deleted_users | integer | não |  |
| generated_at | string | não |  |
| global_admins | integer | não |  |
| recent_logins | usecase.AdminRecentLogins | não |  |
| total_accounts | integer | não |  |
| total_cards | integer | não |  |
| total_users | integer | não |  |
| total_workspaces | integer | não |  |
| workspaces | array&lt;usecase.AdminWorkspaceMetrics&gt; | não |  |

#### usecase.AdminMemberSummary

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| email | string | não |  |
| name | string | não |  |
| role | entity.WorkspaceMemberRole | não |  |
| user_id | string | não |  |

#### usecase.AdminRecentLogins

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| available | boolean | não |  |
| coverage | string | não |  |
| earliest_recorded_login_at | string | não |  |
| reason | string | não |  |
| user_count | integer | não |  |
| users | array&lt;usecase.AdminRecentLoginUser&gt; | não |  |
| users_without_recorded_login | integer | não |  |
| window_days | integer | não |  |

#### usecase.AdminRecentLoginUser

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| email | string | não |  |
| id | string | não |  |
| last_login_at | string | não |  |
| name | string | não |  |

#### usecase.AdminUserDeletionPreview

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| blocking_catalog_references | boolean | não |  |
| blocking_shared_workspaces | integer | não |  |
| can_delete | boolean | não |  |
| confirmation_name | string | não |  |
| exclusive_workspaces | integer | não |  |
| name | string | não |  |
| shared_workspaces | integer | não |  |
| user_id | string | não |  |

#### usecase.AdminUserSummary

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| deleted | boolean | não |  |
| email | string | não |  |
| id | string | não |  |
| name | string | não |  |
| role | entity.Role | não |  |
| username | string | não |  |

#### usecase.AdminWorkspaceAdmin

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| id | string | não |  |
| name | string | não |  |

#### usecase.AdminWorkspaceMetrics

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_count | integer | não |  |
| active_account_count | integer | não |  |
| active_card_count | integer | não |  |
| admins | array&lt;usecase.AdminWorkspaceAdmin&gt; | não |  |
| card_count | integer | não |  |
| id | string | não |  |
| member_count | integer | não |  |
| name | string | não |  |

#### usecase.AdminWorkspaceSummary

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| admins | array&lt;usecase.AdminWorkspaceAdmin&gt; | não |  |
| created_at | string | não |  |
| default_currency_code | string | não |  |
| id | string | não |  |
| name | string | não |  |

#### v1.AdminCurrencyRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| code | string | não |  |
| is_active | boolean | não |  |
| is_verified | boolean | não |  |
| name | string | não |  |
| symbol | string | não |  |
| validate_globally | boolean | não |  |

#### v1.AdminDeleteUserRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| confirmation_name | string | sim |  |

#### v1.AdminDeleteWorkspaceRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| confirmation_name | string | sim |  |

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

#### v1.ErrorResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| error | string | não |  |
