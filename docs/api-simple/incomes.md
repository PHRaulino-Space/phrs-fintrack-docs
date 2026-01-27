---
title: Incomes
---
## DELETE `/incomes/{id}`

**Resumo:** Delete an income

Delete an existing income

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Income ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## GET `/incomes`

**Resumo:** List incomes

List all incomes for a given account

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| account_id | query | string | sim | Account ID |
| start_date | query | string | não | Start Date (YYYY-MM-DD) |
| end_date | query | string | não | End Date (YYYY-MM-DD) |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;v1.incomeResponse&gt; |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## GET `/incomes/{id}`

**Resumo:** Get a single income

Get a single income by its ID

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Income ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.incomeResponse |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## POST `/incomes`

**Resumo:** Create a new income

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| income | body | v1.createIncomeRequest | sim | Income object |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | v1.incomeResponse |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## PUT `/incomes/{id}`

**Resumo:** Update an income

Update an existing income

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Income ID |
| income | body | v1.updateIncomeRequest | sim | Income object |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.incomeResponse |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

### Schemas

#### entity.TransactionStatus

Sem propriedades.

#### v1.createIncomeRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_id | string | sim |  |
| amount | number | sim |  |
| category_id | string | sim |  |
| description | string | sim |  |
| recurring_income_id | string | não |  |
| sub_category_id | string | não |  |
| transaction_date | string | sim |  |

#### v1.incomeResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_id | string | não |  |
| amount | number | não |  |
| category_id | string | não |  |
| created_at | string | não |  |
| description | string | não |  |
| id | string | não |  |
| recurring_income_id | string | não |  |
| sub_category_id | string | não |  |
| transaction_date | string | não |  |
| transaction_status | entity.TransactionStatus | não |  |
| updated_at | string | não |  |

#### v1.updateIncomeRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| category_id | string | não |  |
| description | string | não |  |
| sub_category_id | string | não |  |
| transaction_date | string | não |  |
| transaction_status | entity.TransactionStatus | não |  |
