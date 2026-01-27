---
title: Staged Transactions
---
## DELETE `/staged-transactions/{id}`

**Resumo:** Delete staged transaction

Delete a staged transaction by ID

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Transaction ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## GET `/staged-transactions/{id}`

**Resumo:** Get staged transaction

Get a single staged transaction by ID

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Transaction ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.StagedTransaction |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## PUT `/staged-transactions/{id}`

**Resumo:** Update staged transaction

Update a staged transaction by ID

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Transaction ID |
| transaction | body | v1.updateStagedTransactionRequest | sim | Staged transaction object |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.StagedTransaction |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

### Schemas

#### entity.StagedTransaction

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| created_at | string | não |  |
| data | object | não |  |
| description | string | não |  |
| id | string | não |  |
| processing_enrichment | boolean | não |  |
| session_id | string | não |  |
| status | entity.StagedTransactionStatus | não |  |
| transaction_date | string | não |  |
| type | entity.StagedTransactionType | não |  |
| updated_at | string | não |  |

#### entity.StagedTransactionStatus

Sem propriedades.

#### entity.StagedTransactionType

Sem propriedades.

#### v1.updateStagedTransactionRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| data | object | não |  |
| description | string | não |  |
| status | entity.StagedTransactionStatus | não |  |
| transaction_date | string | não |  |
| type | entity.StagedTransactionType | não |  |
