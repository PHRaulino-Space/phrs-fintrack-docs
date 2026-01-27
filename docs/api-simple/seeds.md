---
title: Seeds
---
## POST `/workspaces/{workspace_id}/seeds/categories-default`

**Resumo:** Apply default category template

Seeds the workspace with the default category/subcategory taxonomy

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| workspace_id | path | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## POST `/workspaces/{workspace_id}/seeds/training-synthetic`

**Resumo:** Generate synthetic training data

Create a synthetic dataset of transactions backed by default categories

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| workspace_id | path | string | sim | Workspace ID |
| count | query | integer | não | Number of examples (default 2000) |
| model | query | string | não | Embedding model name (default \ |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |
