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

### Schemas

#### v1.cloudflareResolvedStatus

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| connected | boolean | não |  |
