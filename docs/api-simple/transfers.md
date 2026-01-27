---
title: Transfers
description: "Endpoints de transferências"
---
Endpoints de transferências

## DELETE `/transfers/{id}`

**Resumo:** Delete a transfer

Delete an existing transfer

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Transfer ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## GET `/transfers`

**Resumo:** List transfers

List all transfers for a given account (as either source or destination)

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| account_id | query | string | sim | Account ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;entity.Transfer&gt; |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## GET `/transfers/{id}`

**Resumo:** Get a single transfer

Get a single transfer by its ID

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Transfer ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.Transfer |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## POST `/transfers`

**Resumo:** Create a new transfer

Create a new transfer between accounts

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| transfer | body | v1.createTransferRequest | sim | Transfer object |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.Transfer |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## PUT `/transfers/{id}`

**Resumo:** Update a transfer

Update an existing transfer

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Transfer ID |
| transfer | body | v1.updateTransferRequest | sim | Transfer object |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.Transfer |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

### Schemas

#### entity.Account

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| currency | string | não | Relationships |
| currency_code | string | não |  |
| deleted_at | string | não |  |
| id | string | não |  |
| initial_balance | number | não |  |
| is_active | boolean | não |  |
| name | string | não |  |
| type | entity.AccountType | não |  |
| updated_at | string | não |  |
| workspace_id | string | não |  |

#### entity.AccountType

Sem propriedades.

#### entity.TransactionStatus

Sem propriedades.

#### entity.Transfer

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| created_at | string | não |  |
| deleted_at | string | não |  |
| description | string | não |  |
| destination_account | entity.Account | não |  |
| destination_account_id | string | não |  |
| id | string | não |  |
| recurring_transfer_id | string | não |  |
| source_account | object | não | Relationships |
| source_account_id | string | não |  |
| transaction_date | string | não |  |
| transaction_status | entity.TransactionStatus | não |  |
| updated_at | string | não |  |

#### v1.createTransferRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | sim |  |
| description | string | não |  |
| destination_account_id | string | sim |  |
| source_account_id | string | sim |  |
| transaction_date | string | sim |  |

#### v1.updateTransferRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| description | string | não |  |
| destination_account_id | string | não |  |
| source_account_id | string | não |  |
| transaction_date | string | não |  |
| transaction_status | entity.TransactionStatus | não |  |
