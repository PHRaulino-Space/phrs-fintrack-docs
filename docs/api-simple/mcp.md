---
title: Mcp
---
## GET `/mcp/cloudflare-link/status`

**Resumo:** Check whether a Cloudflare MCP identity is linked

Validates the Access assertion and checks for an explicit Fintrack user link.

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.cloudflareResolvedStatus |
| 401 | Unauthorized | object |

## GET `/mcp/cloudflare/workspaces`

**Resumo:** List MCP-enabled workspaces for the Cloudflare-linked user

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;usecase.MCPWorkspaceOption&gt; |

## GET `/mcp/cloudflare/workspaces/credential`

**Resumo:** Get current MCP workspace credential for the internal MCP service

Requires both a signed Cloudflare assertion and the internal MCP service token.

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |

## GET `/workspaces/{workspace_id}/mcp`

**Resumo:** Get workspace MCP integration

Only workspace administrators can see the MCP integration policy.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| workspace_id | path | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.MCPWorkspaceIntegration |
| 403 | Forbidden | v1.ErrorResponse |

## GET `/workspaces/{workspace_id}/mcp/member`

**Resumo:** Get the current member's MCP access status

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| workspace_id | path | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.MCPMemberStatus |

## POST `/mcp/cloudflare/workspaces/current`

**Resumo:** Select the current MCP workspace

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| request | body | v1.mcpSelectRequest | sim | Workspace selection |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 403 | Forbidden | v1.ErrorResponse |

## PUT `/workspaces/{workspace_id}/mcp`

**Resumo:** Configure workspace MCP integration

Enables or disables the workspace MCP policy; disabling deletes all members' MCP-managed keys.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| workspace_id | path | string | sim | Workspace ID |
| request | body | v1.mcpPolicyRequest | sim | MCP policy |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.MCPWorkspaceIntegration |
| 400 | Bad Request | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |

## PUT `/workspaces/{workspace_id}/mcp/member`

**Resumo:** Enable or disable the current member's own MCP key

Enabling requires the workspace administrator to have enabled MCP. Disabling deletes this member's managed key.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| workspace_id | path | string | sim | Workspace ID |
| request | body | v1.mcpMemberRequest | sim | Member MCP access |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 403 | Forbidden | v1.ErrorResponse |

### Schemas

#### entity.MCPWorkspaceIntegration

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| enabled | boolean | não |  |
| scopes | array&lt;string&gt; | não |  |
| updated_at | string | não |  |
| workspace_id | string | não |  |

#### usecase.MCPMemberStatus

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| access_level | string | não |  |
| cloudflare_linked | boolean | não |  |
| enabled | boolean | não |  |
| policy_enabled | boolean | não |  |

#### usecase.MCPWorkspaceOption

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| access_level | string | não |  |
| current | boolean | não |  |
| id | string | não |  |
| name | string | não |  |

#### v1.cloudflareResolvedStatus

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| connected | boolean | não |  |

#### v1.ErrorResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| error | string | não |  |

#### v1.mcpMemberRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| enabled | boolean | não |  |

#### v1.mcpPolicyRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| enabled | boolean | não |  |
| scope_preset | string | não |  |
| scopes | array&lt;string&gt; | não |  |

#### v1.mcpSelectRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| workspace_id | string | sim |  |
