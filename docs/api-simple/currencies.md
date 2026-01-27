---
title: Currencies
---
## GET `/currencies`

**Resumo:** List all currencies

List all available currencies in the system

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;v1.currencyResponse&gt; |
| 500 | Internal Server Error | object |

## GET `/currencies/{code}`

**Resumo:** Get a single currency

Get a single currency by its code

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| code | path | string | sim | Currency Code (e.g., BRL, USD) |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.currencyResponse |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

### Schemas

#### v1.currencyResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| code | string | não |  |
| name | string | não |  |
| symbol | string | não |  |
