---
title: Dashboard
---
## GET `/dashboard/summary/metas`

**Resumo:** Goals dashboard summary

Returns summary metrics for goals

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.goalsSummaryResponse |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

### Schemas

#### v1.goalsSummaryResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| active_count | integer | não |  |
| completed_count | integer | não |  |
| progress_pct | number | não |  |
| remaining | number | não |  |
| total_accumulated | number | não |  |
