---
title: Transfers
---
## DELETE `/transfers/{id}`

**Resumo:** Delete a transfer

Delete an existing transfer in the authenticated workspace. Foreign IDs return 404.

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
| 403 | Forbidden | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

## GET `/transfers`

**Resumo:** List transfers

List transfers for an account in the authenticated workspace (as either source or destination). Foreign account IDs return 404.

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
| 403 | Forbidden | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

## GET `/transfers/{id}`

**Resumo:** Get a single transfer

Get a single transfer by its ID in the authenticated workspace. Foreign IDs return 404.

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
| 200 | OK | v1.transferResponse |
| 400 | Bad Request | object |
| 403 | Forbidden | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

## POST `/transfers`

**Resumo:** Create a new transfer

Create a new transfer between accounts in the authenticated workspace. Source and destination must belong to that workspace.

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
| 403 | Forbidden | object |
| 404 | Not Found | object |
| 500 | Internal Server Error | object |

## PUT `/transfers/{id}`

**Resumo:** Update a transfer

Update an existing transfer in the authenticated workspace. PUT remains a partial update: omitted fields are preserved. Empty description clears it. Amount, when present, must be greater than 0; zero or negative returns 400 without writing. recurring_transaction_id omitted preserves the current link; null unsets it. Foreign IDs return 404.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Transfer ID |
| transfer | body | v1.updateTransferRequest | sim | Partial transfer fields (omitted preserved; empty description clears; invalid amount rejected; recurring_transaction_id null unsets) |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.transferResponse |
| 400 | Bad Request | object |
| 403 | Forbidden | object |
| 404 | Not Found | object |
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
| image_key | string | não |  |
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
| recurring_transfer_id | string | não |  |
| source_account_id | string | sim |  |
| transaction_date | string | sim |  |
| transaction_status | entity.TransactionStatus | não |  |

#### v1.transferResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não |  |
| created_at | string | não |  |
| description | string | não |  |
| destination_account_id | string | não |  |
| destination_account_name | string | não |  |
| id | string | não |  |
| recurring_transfer_id | string | não |  |
| source_account_id | string | não |  |
| source_account_name | string | não |  |
| transaction_date | string | não |  |
| transaction_status | entity.TransactionStatus | não |  |
| updated_at | string | não |  |

#### v1.updateTransferRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | não | Amount. Omitted preserves the current value. When present must be greater than 0; zero or negative returns 400 without writing. |
| description | string | não | Description. Omitted preserves the current value. Empty string clears it. |
| destination_account_id | string | não | Destination account ID. Omitted preserves the current value. |
| recurring_transaction_id | string | não | Recurring transfer ID. Omitted preserves the current link; null unsets it. |
| source_account_id | string | não | Source account ID. Omitted preserves the current value. |
| transaction_date | string | não | Transaction date (YYYY-MM-DD). Omitted preserves the current value. |
| transaction_status | object | não | Transaction status. Omitted preserves the current value. |
