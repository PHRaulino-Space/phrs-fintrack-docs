---
title: Cache
---
## GET `/cache/revision`

**Resumo:** Financial data freshness revision

Poll on focus/reconnect to invalidate financial query caches across devices. No-store. Includes the current Brazilian civil day.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.cacheRevisionResponse |
| 499 | Request canceled | string |
| 503 | Service Unavailable | object |
| 504 | Gateway Timeout | object |

### Schemas

#### v1.cacheRevisionResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| revision | string | não |  |
