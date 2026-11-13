---
title: Knowledge
---
## DELETE `/knowledge/{knowledge_id}`

**Resumo:** Delete a workspace knowledge entry and remove its linked guidance

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| knowledge_id | path | string | sim | Knowledge ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |

## GET `/knowledge`

**Resumo:** List reusable knowledge for the current workspace

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| tag_id | query | string | não | Filter by workspace tag ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;entity.Knowledge&gt; |

## GET `/knowledge/{knowledge_id}`

**Resumo:** Read one workspace knowledge entry

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| knowledge_id | path | string | sim | Knowledge ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.Knowledge |

## GET `/knowledge/contexts/{kind}/{context_id}`

**Resumo:** Get workspace memory matched by account, card or import context tags

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| kind | path | string | sim | account, card, import_session or staged_transaction |
| context_id | path | string | sim | Resource ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.KnowledgeContext |

## GET `/monthly-closing`

**Resumo:** List the current user's configured monthly closing items with tags and resolved knowledge

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| kind | query | string | não | Filter by item kind: account, card or task. Requires item_id. |
| item_id | query | string | não | Filter by closing item ID. Requires kind. |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;entity.MonthlyClosingItem&gt; |

## POST `/knowledge`

**Resumo:** Create reusable workspace knowledge

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| body | body | v1.workspaceKnowledgeBody | sim | Knowledge |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.Knowledge |

## PUT `/knowledge/{knowledge_id}`

**Resumo:** Update reusable workspace knowledge and its linked guidance

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| knowledge_id | path | string | sim | Knowledge ID |
| body | body | v1.workspaceKnowledgeBody | sim | Knowledge |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.Knowledge |

## PUT `/knowledge/contexts/{kind}/{context_id}`

**Resumo:** Replace the workspace tags assigned to an account or card

**Consumes:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| kind | path | string | sim | account or card |
| context_id | path | string | sim | Account or card ID |
| body | body | v1.contextTagBody | sim | Tag IDs, empty to clear all |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |

## PUT `/monthly-closing/{kind}/{item_id}/knowledge`

**Resumo:** Replace direct knowledge links or personal tags for a monthly closing item

**Consumes:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| kind | path | string | sim | account, card or task |
| item_id | path | string | sim | Closing item ID |
| body | body | v1.closingKnowledgeBody | sim | Knowledge IDs or tag IDs. Omitted fields are preserved. An empty list clears that field. |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |

### Schemas

#### entity.Knowledge

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| content_html | string | não |  |
| created_at | string | não |  |
| id | string | não |  |
| tag_ids | array&lt;string&gt; | não |  |
| title | string | não |  |
| updated_at | string | não |  |
| workspace_id | string | não |  |

#### entity.KnowledgeContext

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| id | string | não |  |
| kind | string | não |  |
| knowledge | array&lt;entity.Knowledge&gt; | não |  |
| resource_id | string | não |  |
| resource_kind | string | não |  |
| tag_ids | array&lt;string&gt; | não |  |

#### entity.MonthlyClosingItem

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| id | string | não |  |
| inherited_tag_ids | array&lt;string&gt; | não |  |
| kind | string | não |  |
| knowledge | array&lt;entity.Knowledge&gt; | não |  |
| name | string | não |  |
| tag_ids | array&lt;string&gt; | não |  |

#### v1.closingKnowledgeBody

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| knowledge_ids | array&lt;string&gt; | não |  |
| tag_ids | array&lt;string&gt; | não |  |

#### v1.contextTagBody

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| tag_ids | array&lt;string&gt; | sim |  |

#### v1.workspaceKnowledgeBody

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| content_html | string | não |  |
| tag_ids | array&lt;string&gt; | não |  |
| title | string | sim |  |
