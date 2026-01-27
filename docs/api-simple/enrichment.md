---
title: Enrichment
---
## POST `/enrichment/transactions`

**Resumo:** Enrich a batch of transactions

Enrich a batch of transactions with category information

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| transactions | body | array&lt;usecase.EnrichmentInputTransaction&gt; | sim | Transactions to enrich |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;usecase.EnrichedTransaction&gt; |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

### Schemas

#### entity.CategoryType

Sem propriedades.

#### usecase.EnrichedTransaction

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| category_id | string | não |  |
| category_name | string | não |  |
| description | string | não |  |
| sub_category_id | string | não |  |
| sub_category_name | string | não |  |
| type | entity.CategoryType | não |  |

#### usecase.EnrichmentInputTransaction

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| description | string | não |  |
| type | entity.CategoryType | não |  |
