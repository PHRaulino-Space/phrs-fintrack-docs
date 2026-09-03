---
title: Open Finance
---
## DELETE `/open-finance/connections/{id}`

**Resumo:** Disconnect an Open Finance connection

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Connection ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |

## GET `/open-finance/account-links/{id}/transactions`

**Resumo:** List synchronized transaction copies

Lists every provider transaction version and whether it is new, imported, ignored, or deleted at the provider.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Account link ID |
| page | query | integer | não | Page |
| page_size | query | integer | não | Page size |
| review_status | query | string | não | Review status |
| provider_status | query | string | não | Provider status |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.OpenFinanceTransactionPage |

## GET `/open-finance/connections`

**Resumo:** List Open Finance connections

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;entity.OpenFinanceConnection&gt; |

## GET `/open-finance/connections/{id}/accounts`

**Resumo:** List provider accounts for a connection

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Connection ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;usecase.OpenFinanceAccountResponse&gt; |

## POST `/open-finance/account-links/{id}/sync`

**Resumo:** Synchronize transactions into import sessions

Fetches normalized transactions and creates review-only import sessions. It never writes financial domain transactions.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Account link ID |
| payload | body | v1.syncOpenFinanceAccountRequest | não | Optional date range |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.OpenFinanceSyncResult |

## POST `/open-finance/connect-token`

**Resumo:** Create an Open Finance authorization token

Creates a short-lived token for the provider's consent widget. Provider credentials never leave the backend.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | usecase.OpenFinanceConnectResponse |
| 500 | Internal Server Error | object |

## POST `/open-finance/connections/{id}/connect-token`

**Resumo:** Create an authorization token to refresh an existing connection

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Connection ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | usecase.OpenFinanceConnectResponse |

## POST `/open-finance/connections/{id}/finalize`

**Resumo:** Finalize a widget connection

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Pending connection ID |
| payload | body | v1.attachConnectionRequest | sim | Item returned by Pluggy Connect |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.OpenFinanceConnection |

## POST `/open-finance/connections/attach`

**Resumo:** Attach an existing provider connection

Attaches an item already visible in the Pluggy dashboard. Pluggy does not expose an item-list endpoint, so item_id is required.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| payload | body | v1.attachConnectionRequest | sim | Existing item |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.OpenFinanceConnection |

## POST `/open-finance/transactions/{id}/restore`

**Resumo:** Restore an ignored synchronized transaction to its automatic session

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Synchronized transaction ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.StagedTransaction |

## POST `/open-finance/webhooks`

**Resumo:** Receive an Open Finance provider webhook

Persist a provider webhook event for asynchronous processing

**Consumes:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Open-Finance-Webhook-Secret | header | string | sim | Webhook secret |
| payload | body | object | sim | Provider webhook payload |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 202 | Accepted |  |
| 400 | Bad Request | object |
| 401 | Unauthorized | object |
| 500 | Internal Server Error | object |

## PUT `/open-finance/connections/{id}/accounts/{external_account_id}/link`

**Resumo:** Link a provider account to a Fintrack account or card

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Connection ID |
| external_account_id | path | string | sim | Provider account ID |
| payload | body | v1.linkOpenFinanceAccountRequest | sim | Local target |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.OpenFinanceAccountLink |

### Schemas

#### entity.OpenFinanceAccountLink

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_id | string | não |  |
| card_id | string | não |  |
| connection_id | string | não |  |
| created_at | string | não |  |
| currency_code | string | não |  |
| external_account_id | string | não |  |
| id | string | não |  |
| import_session_id | string | não |  |
| kind | string | não |  |
| last_synced_at | string | não |  |
| name | string | não |  |
| provider | string | não |  |
| subtype | string | não |  |
| updated_at | string | não |  |
| workspace_id | string | não |  |

#### entity.OpenFinanceConnection

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_links | array&lt;entity.OpenFinanceAccountLink&gt; | não |  |
| created_at | string | não |  |
| external_id | string | não |  |
| id | string | não |  |
| institution_name | string | não |  |
| provider | string | não |  |
| status | string | não |  |
| updated_at | string | não |  |
| user_id | string | não |  |
| workspace_id | string | não |  |

#### entity.OpenFinanceImportedTransaction

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_link_id | string | não |  |
| created_at | string | não |  |
| external_transaction_id | string | não |  |
| id | string | não |  |
| import_session_id | string | não |  |
| provider | string | não |  |
| provider_status | string | não |  |
| review_status | string | não |  |
| reviewed_at | string | não |  |
| snapshot | object | não |  |
| staged_transaction_id | string | não |  |
| updated_at | string | não |  |

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

#### openfinance.AccountKind

Sem propriedades.

#### usecase.OpenFinanceAccountResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_id | string | não |  |
| balance | number | não |  |
| card_id | string | não |  |
| connection_external_id | string | não |  |
| currency_code | string | não |  |
| external_id | string | não |  |
| import_session_id | string | não |  |
| kind | openfinance.AccountKind | não |  |
| link_id | string | não |  |
| name | string | não |  |
| number | string | não |  |
| subtype | string | não |  |

#### usecase.OpenFinanceConnectResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| access_token | string | não |  |
| connection_id | string | não |  |
| expires_at | string | não |  |

#### usecase.OpenFinanceSyncResult

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| import_session_ids | array&lt;string&gt; | não |  |
| imported | integer | não |  |
| skipped | integer | não |  |

#### usecase.OpenFinanceTransactionPage

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| data | array&lt;entity.OpenFinanceImportedTransaction&gt; | não |  |
| page | integer | não |  |
| page_size | integer | não |  |
| total | integer | não |  |
| total_pages | integer | não |  |

#### v1.attachConnectionRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| item_id | string | sim |  |

#### v1.linkOpenFinanceAccountRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| account_id | string | não |  |
| card_id | string | não |  |

#### v1.syncOpenFinanceAccountRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| date_from | string | não |  |
| date_to | string | não |  |
