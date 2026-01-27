---
title: Import Sessions
description: "Endpoints de importação"
---
Endpoints de importação

## DELETE `/import-sessions/{id}`

**Resumo:** Delete import session

Delete an import session and all its staged transactions

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Session ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## DELETE `/import-sessions/{id}/staged-transactions`

**Resumo:** Delete all staged transactions in session

Delete all staged transactions for a specific import session

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Session ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## GET `/import-sessions`

**Resumo:** List import sessions

List all import sessions for the workspace

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;entity.ImportSession&gt; |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## GET `/import-sessions/{id}`

**Resumo:** Get import session with enriched data

Get detailed import session with enriched data including initial balance, context value, transactions, and stats

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Session ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.ImportSessionResponse |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## GET `/import-sessions/{id}/staged-transactions`

**Resumo:** List staged transactions in session

Get all staged transactions for a specific import session

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Session ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;entity.StagedTransaction&gt; |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## POST `/import-sessions`

**Resumo:** Create a new import session

Create a new import session.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| session | body | v1.createImportSessionRequest | sim | Import Session payload |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.ImportSession |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## POST `/import-sessions/{id}/bind`

**Resumo:** Bind staged transaction to recurring pattern

Bind a staged transaction to a recurring transaction pattern. Automatically copies category, subcategory, tags, and description from the recurring pattern.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Session ID |
| request | body | v1.bindRecurringRequest | sim | Bind request |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## POST `/import-sessions/{id}/close`

**Resumo:** Close session and trigger reconciliation

Close an import session and trigger reconciliation. Updates all VALIDATING transactions to PAID status. Requires admin role. For card context, also updates invoice status to PAID.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Session ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |
| 403 | Forbidden | object |
| 500 | Internal Server Error | object |

## POST `/import-sessions/{id}/commit`

**Resumo:** Commit staged transactions to main tables

Commit all READY staged transactions to their respective main tables (incomes, expenses, transfers, etc). Sets transaction status to VALIDATING or IGNORE based on the ignore flag.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Session ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## POST `/import-sessions/{id}/enrich`

**Resumo:** Enrich staged transactions

Trigger enrichment for all PENDING staged transactions in a session.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Session ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## POST `/import-sessions/{id}/staged-transactions`

**Resumo:** Create staged transactions

Create one or more staged transactions for an import session

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Session ID |
| transactions | body | array&lt;v1.createStagedTransactionRequest&gt; | sim | Array of staged transactions |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | array&lt;entity.StagedTransaction&gt; |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

## POST `/import-sessions/{id}/upload`

**Resumo:** Upload CSV file

Upload a CSV file to import transactions into the session. The file is parsed and transactions are created as staged.

**Consumes:** multipart/form-data

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Session ID |
| file | formData | file | sim | CSV file to upload |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | object |
| 400 | Bad Request | object |
| 500 | Internal Server Error | object |

### Schemas

#### entity.ImportSession

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_id | string | não |  |
| billing_month | string | não | YYYY-MM |
| card_id | string | não |  |
| created_at | string | não |  |
| description | string | não |  |
| id | string | não |  |
| staged_transactions | array&lt;entity.StagedTransaction&gt; | não | Relationships |
| stats | object | não | Transient |
| target_value | number | não |  |
| type | string | não |  |
| user_id | string | não |  |
| workspace_id | string | não |  |

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

#### usecase.ImportSessionResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_id | string | não |  |
| billing_month | string | não | YYYY-MM |
| card_id | string | não |  |
| context_value | number | não |  |
| created_at | string | não |  |
| description | string | não |  |
| id | string | não |  |
| initial_balance | number | não |  |
| staged_transactions | array&lt;entity.StagedTransaction&gt; | não | Relationships |
| stats | usecase.SessionStats | não |  |
| status | string | não |  |
| target_value | number | não |  |
| transactions | array&lt;entity.StagedTransaction&gt; | não |  |
| type | string | não |  |
| user_id | string | não |  |
| workspace_id | string | não |  |

#### usecase.SessionStats

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| ready | integer | não |  |
| total | integer | não |  |

#### v1.bindRecurringRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| recurring_transaction_id | string | sim |  |
| staged_transaction_id | string | sim |  |

#### v1.createImportSessionRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_id | string | não |  |
| billing_month | string | não |  |
| card_id | string | não |  |
| target_value | number | não |  |

#### v1.createStagedTransactionRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| amount | number | sim |  |
| data | object | não |  |
| description | string | não |  |
| line_number | integer | não |  |
| transaction_date | string | sim |  |
| type | entity.StagedTransactionType | sim |  |
