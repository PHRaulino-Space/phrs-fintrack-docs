---
title: Ai
---
## DELETE `/ai/credentials/member`

**Resumo:** Remove this member's stored FINTRACK credential

Removes the encrypted value used by AI. Does not revoke the original API key or reverse completed operations.

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 403 | Forbidden | v1.ErrorResponse |

## DELETE `/ai/credentials/provider`

**Resumo:** Remove all stored workspace OpenRouter credential versions

Workspace administrators only. Immediately blocks new inference. Encrypted provider versions remain available only for existing pending billing receipts; explicit retention maintenance erases them after grace periods and pending-use checks. Does not revoke the key at OpenRouter or reverse completed operations.

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 403 | Forbidden | v1.ErrorResponse |

## DELETE `/ai/reports/{report_id}`

**Resumo:** Remove an AI report from active listings

Requires the current report revision and the requesting member's own active key with the report read scopes. Retains definitions and published history. Pending refreshes cannot publish into the deleted report.

**Consumes:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| report_id | path | string | sim | Report ID |
| request | body | v1.aiReportDeleteRequest | sim | Expected report revision |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 403 | Forbidden | v1.ErrorResponse |
| 409 | Conflict | v1.ErrorResponse |

## DELETE `/ai/skills/{skill_id}`

**Resumo:** Delete an AI skill from future selection

Workspace admin only, with expected revision. Retains immutable versions used by earlier runs. Does not cancel or authorize financial actions.

**Consumes:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| skill_id | path | string | sim | Skill ID |
| request | body | v1.aiSkillDeleteRequest | sim | Expected revision |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |
| 403 | Forbidden | v1.ErrorResponse |
| 409 | Conflict | v1.ErrorResponse |

## GET `/ai/capabilities`

**Resumo:** Read AI runtime capabilities

Human session and current workspace membership required. AI jobs are independent from general background jobs. inference_disabled_reason is sanitized runtime metadata (ai_jobs_disabled, read_only_smoke or execution_unavailable), omitted when enabled. Workspace policy, credentials, scopes and model compatibility are validated separately. Conditional mutations still require a fresh snapshot and exact human approval. Attachment kinds mean a native preparation adapter exists; actual bytes, limits, model support and bounded price are validated before paid dispatch. No credentials or private prompts are returned.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.aiCapabilitiesResponse |
| 401 | Unauthorized | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |

## GET `/ai/chats`

**Resumo:** List AI conversations

Session-only. Current workspace members can read shared conversations regardless of their individual execution scopes. Removed members lose access.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| page | query | integer | não | Page, starting at 1 |
| limit | query | integer | não | Page size, 1-50 |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIChatPage |
| 403 | Forbidden | v1.ErrorResponse |

## GET `/ai/chats/{chat_id}`

**Resumo:** Read an AI conversation and recent execution states

History remains available when budget or credentials prevent execution. Messages are returned in ascending sequence order; use next_before_sequence to page backwards.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| chat_id | path | string | sim | Chat ID |
| before_sequence | query | integer | não | Exclusive upper message sequence |
| limit | query | integer | não | Message page size, 1-100 |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIChatDetail |
| 403 | Forbidden | v1.ErrorResponse |

## GET `/ai/chats/{chat_id}/attachments`

**Resumo:** List private chat attachments

Active workspace members can read regardless of execution scopes or available AI budget. Pending, expired and deleted attachments are omitted. No object path or signed URL is returned.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| chat_id | path | string | sim | Chat ID |
| page | query | integer | não | Page, default 1 |
| limit | query | integer | não | Page size, default 20, maximum 50 |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIAttachmentPage |

## GET `/ai/chats/{chat_id}/attachments/{attachment_id}/content`

**Resumo:** Download a private chat attachment

Active membership and chat access are checked for every request and again after storage retrieval. Authenticated attachment download, never a presigned URL; no-store, nosniff and sandbox headers. Expired attachments return 410. Already received bytes cannot be revoked.

**Produces:** application/octet-stream

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| chat_id | path | string | sim | Chat ID |
| attachment_id | path | string | sim | Attachment ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | file |
| 403 | Forbidden | v1.ErrorResponse |
| 410 | Gone | v1.ErrorResponse |

## GET `/ai/chats/{chat_id}/public-research`

**Resumo:** List shared public research snapshots for a chat

Local cache only, maximum five nonexpired snapshots. Empty after expiry or restart. Requires session and current workspace membership; reader execution scopes and chat authorship do not filter shared contents.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| chat_id | path | string | sim | Chat ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIPublicResearchPage |
| 403 | Forbidden | v1.ErrorResponse |

## GET `/ai/chats/{chat_id}/public-research/{research_id}`

**Resumo:** Read an existing temporary public research snapshot

Session-only, current workspace member. Shared snapshot contents are readable without execution scopes; only the chat creator may create a new research request. Local cache read never repeats public HTTP. Expiry or restart returns 410. No publication date is inferred from collection time.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| chat_id | path | string | sim | Chat ID |
| research_id | path | string | sim | Public research ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.AIPublicResearch |
| 403 | Forbidden | v1.ErrorResponse |
| 410 | Gone | v1.ErrorResponse |

## GET `/ai/chats/{chat_id}/statements`

**Resumo:** List statement preparations in a shared chat

Paginated request/run pairs retain discovery after reload. Current workspace membership is required; no execution scope is needed for reading.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| chat_id | path | string | sim | Chat ID |
| page | query | integer | não | Page, default 1 |
| limit | query | integer | não | Page size, default 20, maximum 50 |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIStatementPage |

## GET `/ai/enrichments/{enrichment_id}`

**Resumo:** Read budgeted classification progress and suggestions

Current workspace members read structured progress, each ordinary budgeted child run and immutable suggestions. queued/processing/waiting_budget/uncertain are not completed classification; staging_prepared is PENDING staging only, never a ledger commit. No credentials or provider payloads are exposed.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| enrichment_id | path | string | sim | Confirmed enrichment action ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIEnrichmentDetail |
| 403 | Forbidden | v1.ErrorResponse |
| 404 | Not Found | v1.ErrorResponse |

## GET `/ai/maintenance/plans/{plan_id}`

**Resumo:** Read an AI maintenance plan and durable outcome

Current human workspace admin only. Reading never executes or retries deletion. Unknown outcomes preserve quota and require inspection of this same plan.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| plan_id | path | string | sim | Plan ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIMaintenanceResult |
| 403 | Forbidden | v1.ErrorResponse |
| 404 | Not Found | v1.ErrorResponse |

## GET `/ai/reports`

**Resumo:** List shared AI reports

Current workspace members read full content independently of key scopes, policy or remaining budget. Deleted reports are omitted.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| page | query | integer | não | Page, default 1 |
| limit | query | integer | não | Page size, default 20, maximum 50 |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIReportPage |

## GET `/ai/reports/{report_id}`

**Resumo:** Read an AI report and its last successful version

Includes the 20 most recent refresh runs. Failed, stale or incomplete refreshes retain the previous published version. Sources are derived from persisted successful tool reads.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| report_id | path | string | sim | Report ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIReportDetail |
| 403 | Forbidden | v1.ErrorResponse |
| 404 | Not Found | v1.ErrorResponse |

## GET `/ai/reports/{report_id}/definitions`

**Resumo:** Read immutable AI report definition revisions

Newest revision first; history remains readable by current members after report deletion.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| report_id | path | string | sim | Report ID |
| before_revision | query | integer | não | Load revisions older than this value |
| limit | query | integer | não | Page size, default 20, maximum 50 |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIReportDefinitions |

## GET `/ai/reports/{report_id}/versions`

**Resumo:** Read immutable published AI report versions

Newest version first. Each version retains its exact definition revision, requesting member, model, run, data date and recorded source evidence. Text is plain text; decimals are strings.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| report_id | path | string | sim | Report ID |
| before_version | query | integer | não | Load versions older than this value |
| limit | query | integer | não | Page size, default 20, maximum 50 |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIReportVersions |

## GET `/ai/runs/{run_id}`

**Resumo:** Read an AI execution with durable progress events

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| run_id | path | string | sim | Run ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIRunDetail |
| 403 | Forbidden | v1.ErrorResponse |

## GET `/ai/runs/{run_id}/confirmation`

**Resumo:** Read the exact financial action awaiting confirmation

Shared with current workspace members. Contains server snapshots and exact arguments_json. No key identifiers or private continuation are returned. Reading does not authorize an action.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| run_id | path | string | sim | Run ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIRunConfirmation |
| 403 | Forbidden | v1.ErrorResponse |
| 404 | Not Found | v1.ErrorResponse |

## GET `/ai/runs/{run_id}/enrichments`

**Resumo:** Discover enrichment jobs requested by a parent run

Structured discovery avoids extracting job handles from model prose. Current workspace membership is required; execution scopes remain separate. Returns the jobs and child runs without provider or member credentials.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| run_id | path | string | sim | Original parent run ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIEnrichmentPage |

## GET `/ai/runs/{run_id}/image-uploads`

**Resumo:** List the requester's confirmed image upload authorizations

Human session only. Structured non-secret metadata, never signed URLs or object keys. Only the original requester with current individual scopes may read. Authorization alone does not prove upload or image association.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| run_id | path | string | sim | Run ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIImageUploadPage |
| 403 | Forbidden | v1.ErrorResponse |
| 404 | Not Found | v1.ErrorResponse |

## GET `/ai/runs/{run_id}/open-finance-tokens`

**Resumo:** List the requester's Open Finance token deliveries

Cookie session only. Structured handles, connection IDs, expiry and delivery state, without plaintext tokens. Original requester and current individual scopes/credentials are revalidated. A ready token does not prove bank authorization or account synchronization.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| run_id | path | string | sim | Run ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIExternalHumanTokenPage |
| 403 | Forbidden | v1.ErrorResponse |
| 404 | Not Found | v1.ErrorResponse |

## GET `/ai/runs/{run_id}/skills`

**Resumo:** Read the exact skill versions selected for a run

Current workspace members may inspect selected instructions; these are not authorization or consent.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| run_id | path | string | sim | Run ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;entity.AISkillVersion&gt; |

## GET `/ai/settings`

**Resumo:** Read AI settings and this member's credential status

Available to current workspace members even when AI is disabled or its budget is exhausted. No credential values are returned. Requires a user session.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.aiSettingsResponse |
| 403 | Forbidden | v1.ErrorResponse |

## GET `/ai/skills`

**Resumo:** List shared workspace AI skills

Current members can read full instructions without an API key or available AI budget. Pagination excludes deleted skills.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| page | query | integer | não | Page (default 1) |
| limit | query | integer | não | Page size (default 20, maximum 50) |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AISkillPage |

## GET `/ai/skills/{skill_id}`

**Resumo:** Read a workspace AI skill

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| skill_id | path | string | sim | Skill ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.AISkill |
| 404 | Not Found | v1.ErrorResponse |

## GET `/ai/skills/{skill_id}/versions`

**Resumo:** Read immutable skill versions

Shared history remains available after deletion; newest revision first. Edits apply to selection on later messages, not to versions already bound to a run.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| skill_id | path | string | sim | Skill ID |
| before_revision | query | integer | não | Load versions older than this revision |
| limit | query | integer | não | Page size (default 20, maximum 50) |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AISkillVersions |

## GET `/ai/statements/{statement_id}`

**Resumo:** Read statement preparation and its run

Current workspace members read provenance, safe review issues, optional import session and run status without execution scopes. A queued statement may have a failed/cancelled run; prepared means staging only.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| statement_id | path | string | sim | Statement request ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIStatementResult |

## POST `/ai/chats`

**Resumo:** Create an AI conversation

The client supplies a stable UUID for this attempt. Only its creator can send messages. Model must be allowed by the workspace administrator.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| request | body | v1.aiCreateChatRequest | sim | Conversation |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.AIChat |
| 409 | Conflict | v1.ErrorResponse |

## POST `/ai/chats/{chat_id}/messages`

**Resumo:** Persist a message and queue an AI execution

Creator-only; requires the member's own current FINTRACK key and an active workspace provider credential. The stable message UUID deduplicates retries; revision must match the chat. No provider call occurs in this HTTP request. Text limit is 32 KiB. Execution must be enabled server-side.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| chat_id | path | string | sim | Chat ID |
| request | body | v1.aiSendMessageRequest | sim | Message and expected chat revision |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 202 | Accepted | usecase.AISendResult |
| 409 | Conflict | v1.ErrorResponse |
| 503 | Service Unavailable | v1.ErrorResponse |

## POST `/ai/chats/{chat_id}/public-research`

**Resumo:** Search the public web using an explicit human public query

Session-only and chat-creator-only. The human must enter the exact public query in a separate empty field and explicitly confirm its transmission to DuckDuckGo. Never prefill from model/chat/workspace data. Searches immediately and prefetches up to five results using a static official financial host allowlist; the model only reads the cached snapshot. No model call, credential, private workspace field or implicit query is transmitted. Same ID retries are cached within this process and TTL, including failures; snapshots expire after 15 minutes and are lost on restart. Missing publication dates stay explicit. Does not create a chat message or AI run.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| chat_id | path | string | sim | Chat ID |
| request | body | usecase.AICreatePublicResearch | sim | Exact public query and explicit confirmation |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.AIPublicResearch |
| 400 | Bad Request | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |
| 409 | Conflict | v1.ErrorResponse |
| 410 | Gone | v1.ErrorResponse |
| 429 | Too Many Requests | v1.ErrorResponse |
| 503 | Service Unavailable | v1.ErrorResponse |

## POST `/ai/chats/{chat_id}/statements`

**Resumo:** Prepare an uploaded statement for import review

Explicit human intent fixes attachments, target, month, model and optional instructions. Requires own imports:write key and chat authorship. Uses existing budgeted media runner; creates only a reviewable import session and PENDING rows after complete validation, never a ledger effect or invoice. Uncertain extraction creates no partial staging. Stable request ID makes retries idempotent.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| chat_id | path | string | sim | Chat ID |
| request | body | usecase.AIPrepareStatement | sim | Explicit statement preparation request |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 202 | Accepted | usecase.AIStatementResult |
| 400 | Bad Request | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |
| 409 | Conflict | v1.ErrorResponse |
| 503 | Service Unavailable | v1.ErrorResponse |

## POST `/ai/enrichments/{enrichment_id}/cancel`

**Resumo:** Request cancellation of an enrichment and all child runs

Only the original requester with current workspace membership may cancel. Future dispatch stops; in-flight provider outcomes remain reconcilable and incurred costs are not refunded or assumed zero. Repeating cancellation is idempotent. Queued children become cancelled; uncertain children retain accounting uncertainty. Human resume/recovery uses the existing requester-only child-run endpoints with their original credentials and current scopes.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| enrichment_id | path | string | sim | Enrichment action ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIEnrichmentDetail |
| 403 | Forbidden | v1.ErrorResponse |

## POST `/ai/maintenance/plans`

**Resumo:** Preview AI retention maintenance

Current human workspace admin only. Persists a bounded dry-run plan with exact resource IDs, grace periods and retention pins. No object deletion, secret erasure, billing call or inference occurs. Reusing the UUID with the same limit retrieves the original plan.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| request | body | usecase.AIMaintenancePlanRequest | sim | Stable plan ID and optional limit, default 20, maximum 50 |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIMaintenanceResult |
| 400 | Bad Request | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |
| 409 | Conflict | v1.ErrorResponse |

## POST `/ai/maintenance/plans/{plan_id}/execute`

**Resumo:** Execute an explicitly reviewed AI maintenance plan

The same current human admin confirms the exact stored digest. Revalidates authority, grace periods and pins before each action. Deletes only eligible original attachment bytes and erases only unneeded old ciphertext; audit rows, financial receipts and accounting remain. Retrying cannot expand the plan. An ambiguous DELETE/COMMIT remains durable and quota-bearing until confirmed.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| plan_id | path | string | sim | Plan ID |
| request | body | usecase.AIMaintenanceExecuteRequest | sim | Exact digest and explicit confirm=true |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIMaintenanceResult |
| 400 | Bad Request | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |
| 409 | Conflict | v1.ErrorResponse |

## POST `/ai/reports`

**Resumo:** Create a declarative AI report definition

Any current member with their own active FINTRACK credential and the required read scopes may create a report. Plain text and typed parameters only. Saving a definition performs no inference; id is idempotent for identical initial content.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| request | body | v1.aiReportCreateRequest | sim | Report ID and safe definition |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.AIReport |
| 400 | Bad Request | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |
| 409 | Conflict | v1.ErrorResponse |

## POST `/ai/reports/{report_id}/refresh`

**Resumo:** Refresh a shared report using this member's own key

Queues the existing AI runner with a pinned definition, model and requesting member credentials. Uses the same budget, cancellation and reconciliation controls. Read tools only. Publication atomically advances latest after full validation and expected-revision comparison. No scheduled refresh is created.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| report_id | path | string | sim | Report ID |
| request | body | usecase.AIRefreshReport | sim | Idempotency ID, current report revision and model |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 202 | Accepted | usecase.AIReportRefreshResult |
| 400 | Bad Request | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |
| 409 | Conflict | v1.ErrorResponse |
| 503 | Service Unavailable | v1.ErrorResponse |

## POST `/ai/runs/{run_id}/cancel`

**Resumo:** Request cancellation of this member's AI execution

Cancellation stops subsequent work. It does not undo completed operations or release charges whose outcome is unknown. Repeated requests are idempotent.

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| run_id | path | string | sim | Run ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.AIRun |
| 403 | Forbidden | v1.ErrorResponse |

## POST `/ai/runs/{run_id}/confirmation`

**Resumo:** Explicitly approve or reject this run's exact financial proposal

Human session and CSRF only, never API-key/MCP/model input. Only the original requester may decide. Digest, action ID and run revision must match. Approval queues the stored continuation without replaying inference. The financial executor revalidates scopes and record versions in its effect transaction. Rejection stops the run; cancellation never undoes completed effects. Approval requires both inference and financial mutation server gates.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| run_id | path | string | sim | Run ID |
| request | body | v1.aiConfirmationDecisionRequest | sim | Exact action and explicit human decision |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIRunConfirmation |
| 400 | Bad Request | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |
| 409 | Conflict | v1.ErrorResponse |
| 503 | Service Unavailable | v1.ErrorResponse |

## POST `/ai/runs/{run_id}/image-uploads/{action_id}/delivery`

**Resumo:** Deliver a confirmed image upload URL exclusively to its requester

Human session, CSRF and recent MFA when configured. Does not accept API-key/model calls. Revalidates the original individual key scopes, AI credential, run, confirmation, receipt, active target version and fixed five-minute deadline. URL is a secret capability: no-store; keep only in local UI memory and never send to chat or logs. PUT requires exact MIME and byte length and If-None-Match:*. Browser supplies Content-Length from the File bytes. Issuing or using the URL does not save the image association. Repeated delivery never renews the absolute deadline; cancellation cannot revoke a URL already issued.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| run_id | path | string | sim | Run ID |
| action_id | path | string | sim | Confirmed action ID |
| request | body | object | sim | Empty object |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIImageUploadDelivery |
| 403 | Forbidden | v1.ErrorResponse |
| 409 | Conflict | v1.ErrorResponse |
| 410 | Gone | v1.ErrorResponse |
| 503 | Service Unavailable | v1.ErrorResponse |

## POST `/ai/runs/{run_id}/open-finance-tokens/{action_id}/delivery`

**Resumo:** Deliver an Open Finance authorization token once to its requester

Cookie session, matching CSRF and recent MFA when configured. API keys and Bearer authorization are refused. Token is encrypted at rest and consumed before response; expired or consumed tokens cannot be delivered again. A lost delivery response must not trigger automatic reissuance. Keep plaintext only in transient browser memory for the consent SDK; never send to chat, logs, analytics, storage or a model. Cancellation cannot revoke a capability already delivered.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| run_id | path | string | sim | Run ID |
| action_id | path | string | sim | Confirmed action ID |
| request | body | object | sim | Empty object |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIExternalHumanToken |
| 403 | Forbidden | v1.ErrorResponse |
| 404 | Not Found | v1.ErrorResponse |
| 409 | Conflict | v1.ErrorResponse |
| 503 | Service Unavailable | v1.ErrorResponse |

## POST `/ai/runs/{run_id}/recover-financial`

**Resumo:** Recover a committed financial result

Only the requester may verify the persisted receipt under current access. Reads the same action without executing a mutation or making a paid call. A valid receipt records a continuation waiting for a separate manual resume; cancellation is preserved. An absent receipt leaves the outcome uncertain. Requires a human session.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| run_id | path | string | sim | Run ID |
| request | body | v1.aiFinancialRecoveryRequest | sim | Expected run revision |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIFinancialRecovery |
| 400 | Bad Request | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |
| 404 | Not Found | v1.ErrorResponse |
| 409 | Conflict | v1.ErrorResponse |

## POST `/ai/runs/{run_id}/recover-progress`

**Resumo:** Recover persisted execution progress

Requester-only local verification of the last settled provider turn and exact completed receipts in mixed batches. No inference or financial operation runs here. Recorded read results and completed effects are not repeated; remaining work awaits a separate human resume and every new mutation still requires its own confirmation. Missing proof or an unresolved financial action leaves uncertainty unchanged. Requires a human session.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| run_id | path | string | sim | Run ID |
| request | body | v1.aiRunResumeRequest | sim | Expected run revision |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AIProgressRecovery |
| 400 | Bad Request | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |
| 404 | Not Found | v1.ErrorResponse |
| 409 | Conflict | v1.ErrorResponse |

## POST `/ai/runs/{run_id}/resume`

**Resumo:** Resume a run waiting for budget

Only its requester may resume, using the last read revision and current access. Keeps the original model/key and resumes from the stored next step without replaying paid calls. Uncertain runs cannot be resumed. Requires a human session and an enabled worker.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| run_id | path | string | sim | Run ID |
| request | body | v1.aiRunResumeRequest | sim | Expected run revision |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.AIRun |
| 400 | Bad Request | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |
| 409 | Conflict | v1.ErrorResponse |
| 503 | Service Unavailable | v1.ErrorResponse |

## POST `/ai/skills`

**Resumo:** Create a reusable AI skill

Workspace admin and recent MFA when enabled. Instructions cannot authorize actions. Selection matches normalized keywords in the human message, or always; at most five skills are selected by relevance and stable ID. Creation ID is idempotent for the same initial content.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| request | body | v1.aiSkillCreateRequest | sim | Skill and selection criteria |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.AISkill |
| 400 | Bad Request | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |
| 409 | Conflict | v1.ErrorResponse |

## PUT `/ai/chats/{chat_id}/attachments/{attachment_id}`

**Resumo:** Upload a private AI chat attachment

Session and recent MFA when enabled; only the chat creator can upload. Exactly one multipart file, at most 10 MiB. PNG/JPEG, PDF, WAV/MP3 only; extension, declared MIME and bytes must agree. Stable attachment UUID deduplicates identical uploads. Runtime capabilities are available at /ai/capabilities. Native interpretation validates original bytes, model compatibility and bounded cost before dispatch; storage readiness alone does not guarantee readability. Logical retention is 30 days.

**Consumes:** multipart/form-data

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| chat_id | path | string | sim | Chat ID |
| attachment_id | path | string | sim | Stable attachment UUID |
| file | formData | file | sim | Private attachment, maximum 10 MiB |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.AIAttachment |
| 403 | Forbidden | v1.ErrorResponse |
| 409 | Conflict | v1.ErrorResponse |
| 413 | Request Entity Too Large | v1.ErrorResponse |
| 415 | Unsupported Media Type | v1.ErrorResponse |

## PUT `/ai/credentials/member`

**Resumo:** Store this member's own FINTRACK API key for AI executions

Requires a user session and a key owned by this user in the selected workspace. The key's current scopes and revocation are revalidated during execution; administrator credentials are never inherited.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| request | body | v1.aiCredentialRequest | sim | Individual FINTRACK API key |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AICredentialStatus |
| 400 | Bad Request | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |

## PUT `/ai/credentials/provider`

**Resumo:** Store a new version of the workspace OpenRouter credential

Workspace administrators only. Validates through the provider's read-only key endpoint. Previous versions are retained only for outstanding cost reconciliation; no inference runs here.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| request | body | v1.aiCredentialRequest | sim | OpenRouter API key |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | usecase.AICredentialStatus |
| 400 | Bad Request | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |

## PUT `/ai/reports/{report_id}`

**Resumo:** Revise a shared AI report definition

Any current member with their own key and both prior and replacement required scopes may edit. revision must match the current report revision. Existing published output remains available; a new refresh is explicit.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| report_id | path | string | sim | Report ID |
| request | body | v1.aiReportUpdateRequest | sim | Expected report revision and replacement definition |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.AIReport |
| 403 | Forbidden | v1.ErrorResponse |
| 409 | Conflict | v1.ErrorResponse |

## PUT `/ai/settings`

**Resumo:** Configure workspace AI policy

Workspace administrators only, with a recent MFA session when enabled. revision must match the last read policy. Monthly amounts are integer micro-USD and renew on UTC calendar months.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| request | body | v1.aiPolicyRequest | sim | AI workspace policy |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.AIWorkspacePolicy |
| 400 | Bad Request | v1.ErrorResponse |
| 403 | Forbidden | v1.ErrorResponse |
| 409 | Conflict | v1.ErrorResponse |

## PUT `/ai/skills/{skill_id}`

**Resumo:** Save a new immutable AI skill version

Workspace admin only; revision must match the version last read. Existing runs retain their selected snapshots.

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| skill_id | path | string | sim | Skill ID |
| request | body | v1.aiSkillUpdateRequest | sim | Expected revision and replacement content |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.AISkill |
| 403 | Forbidden | v1.ErrorResponse |
| 409 | Conflict | v1.ErrorResponse |

### Schemas

#### entity.AIActionState

Sem propriedades.

#### entity.AIAttachment

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| chat_id | string | não |  |
| content_type | string | não |  |
| created_at | string | não |  |
| expires_at | string | não |  |
| filename | string | não |  |
| id | string | não |  |
| kind | string | não |  |
| processing_reason | string | não |  |
| processing_state | string | não |  |
| provenance | string | não |  |
| sha256 | string | não |  |
| size_bytes | integer | não |  |
| state | string | não |  |
| uploaded_by | string | não |  |

#### entity.AIBudgetMonth

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| period | string | não |  |
| reserved_micros | integer | não |  |
| spent_micros | integer | não |  |
| workspace_id | string | não |  |

#### entity.AIChat

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| created_by | string | não |  |
| id | string | não |  |
| model | string | não |  |
| revision | integer | não |  |
| title | string | não |  |
| updated_at | string | não |  |
| workspace_id | string | não |  |

#### entity.AIEnrichment

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| batch_count | integer | não |  |
| cancel_requested | boolean | não |  |
| completed_at | string | não |  |
| created_at | string | não |  |
| id | string | não |  |
| input_count | integer | não |  |
| model | string | não |  |
| parent_chat_id | string | não |  |
| parent_run_id | string | não |  |
| requested_by | string | não |  |
| revision | integer | não |  |
| session_id | string | não |  |
| state | string | não |  |
| tool | string | não |  |

#### entity.AIEnrichmentBatch

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| completed_at | string | não |  |
| created_at | string | não |  |
| input_count | integer | não |  |
| job_id | string | não |  |
| number | integer | não |  |
| revision | integer | não |  |
| run_id | string | não |  |
| start_index | integer | não |  |
| state | string | não |  |
| suggestions | array&lt;entity.AIEnrichmentSuggestion&gt; | não |  |

#### entity.AIEnrichmentSuggestion

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| category_id | string | não |  |
| certain | boolean | não |  |
| index | integer | não |  |
| sub_category_id | string | não |  |

#### entity.AIMaintenanceItem

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| action | string | não |  |
| bytes | integer | não |  |
| eligible | boolean | não |  |
| eligible_after | string | não |  |
| id | string | não |  |
| kind | string | não |  |
| reason_codes | array&lt;string&gt; | não |  |
| state | string | não |  |
| version | integer | não |  |

#### entity.AIMaintenancePlan

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| completed_at | string | não |  |
| created_at | string | não |  |
| digest | string | não |  |
| expires_at | string | não |  |
| has_more | boolean | não |  |
| id | string | não |  |
| items | array&lt;entity.AIMaintenanceItem&gt; | não |  |
| limit | integer | não |  |
| requested_by | string | não |  |
| revision | integer | não |  |
| state | string | não |  |

#### entity.AIMessage

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| attachments | array&lt;entity.AIAttachment&gt; | não |  |
| author_id | string | não |  |
| author_name | string | não |  |
| avatar_url | string | não |  |
| chat_id | string | não |  |
| content | string | não |  |
| created_at | string | não |  |
| id | string | não |  |
| role | string | não |  |
| run_id | string | não |  |
| sequence | integer | não |  |

#### entity.AIPublicResearch

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| chat_id | string | não |  |
| created_at | string | não |  |
| expires_at | string | não |  |
| id | string | não |  |
| public_query | string | não |  |
| requested_by | string | não |  |
| snapshot | entity.AIPublicWebSnapshot | não |  |
| state | string | não |  |

#### entity.AIPublicWebCoverage

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| available | integer | não |  |
| excluded | integer | não |  |
| index_url | string | não |  |
| provider | string | não |  |
| publication_note | string | não |  |
| retrieved_at | string | não |  |
| returned | integer | não |  |
| status | string | não |  |
| truncated | boolean | não |  |

#### entity.AIPublicWebSnapshot

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| collected_at | string | não |  |
| coverage | entity.AIPublicWebCoverage | não |  |
| scope | string | não |  |
| sources | array&lt;entity.AIPublicWebSource&gt; | não |  |
| untrusted | boolean | não |  |

#### entity.AIPublicWebSource

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| date_status | string | não |  |
| excerpt | string | não |  |
| excerpt_truncated | boolean | não |  |
| format | string | não |  |
| handle | string | não |  |
| index_url | string | não |  |
| modified_date | string | não |  |
| published_date | string | não |  |
| publisher | string | não |  |
| retrieval_status | string | não |  |
| retrieval_url | string | não |  |
| retrieved_at | string | não |  |
| title | string | não |  |
| url | string | não |  |

#### entity.AIReport

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| created_by | string | não |  |
| definition | entity.AIReportDefinitionContent | não |  |
| definition_revision | integer | não |  |
| deleted_at | string | não |  |
| id | string | não |  |
| latest_version | integer | não |  |
| revision | integer | não |  |
| updated_at | string | não |  |
| updated_by | string | não |  |
| workspace_id | string | não |  |

#### entity.AIReportBlock

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| chart | entity.AIReportChart | não |  |
| metric | entity.AIReportMetric | não |  |
| source_ids | array&lt;string&gt; | não |  |
| table | entity.AIReportTable | não |  |
| text | string | não |  |
| title | string | não |  |
| type | string | não |  |

#### entity.AIReportChart

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| kind | string | não | line, bar, pie |
| series | array&lt;entity.AIReportSeries&gt; | não |  |
| unit | string | não |  |

#### entity.AIReportColumn

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| kind | string | não | text, number, date |
| label | string | não |  |
| unit | string | não |  |

#### entity.AIReportDefinition

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| created_by | string | não |  |
| definition | entity.AIReportDefinitionContent | não |  |
| deleted_at | string | não |  |
| report_id | string | não |  |
| revision | integer | não |  |
| workspace_id | string | não |  |

#### entity.AIReportDefinitionContent

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| description | string | não |  |
| parameters | entity.AIReportParameters | não |  |
| prompt | string | não |  |
| required_scopes | array&lt;string&gt; | não |  |
| schema_version | integer | não |  |
| title | string | não |  |

#### entity.AIReportDocument

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| blocks | array&lt;entity.AIReportBlock&gt; | não |  |
| data_as_of | string | não |  |
| schema_version | integer | não |  |
| title | string | não |  |

#### entity.AIReportEvidence

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| input_digest | string | não |  |
| output_digest | string | não |  |
| retrieved_at | string | não |  |
| step_id | string | não |  |

#### entity.AIReportMetric

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| unit | string | não |  |
| value | string | não |  |

#### entity.AIReportParameters

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| currency | string | não |  |
| end_date | string | não |  |
| start_date | string | não |  |

#### entity.AIReportPoint

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| label | string | não |  |
| value | string | não | exact decimal, never a JSON floating-point number |

#### entity.AIReportRefresh

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| definition_revision | integer | não |  |
| model | string | não |  |
| report_id | string | não |  |
| report_revision | integer | não |  |
| request_id | string | não |  |
| requested_by | string | não |  |
| run_id | string | não |  |
| workspace_id | string | não |  |

#### entity.AIReportSeries

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| name | string | não |  |
| points | array&lt;entity.AIReportPoint&gt; | não |  |

#### entity.AIReportSource

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| evidence | array&lt;entity.AIReportEvidence&gt; | não |  |
| id | string | não |  |
| kind | string | não |  |
| links | array&lt;entity.AIReportSourceLink&gt; | não |  |
| tool_name | string | não |  |

#### entity.AIReportSourceLink

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| data_end_date | string | não |  |
| data_start_date | string | não |  |
| modified_date | string | não |  |
| published_date | string | não |  |
| publisher | string | não |  |
| retrieval_url | string | não |  |
| retrieved_at | string | não |  |
| title | string | não |  |
| unit | string | não |  |
| url | string | não |  |

#### entity.AIReportTable

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| columns | array&lt;entity.AIReportColumn&gt; | não |  |
| rows | array&lt;array&lt;string&gt;&gt; | não |  |

#### entity.AIReportVersion

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| created_by | string | não |  |
| definition_revision | integer | não |  |
| document | entity.AIReportDocument | não |  |
| model | string | não |  |
| report_id | string | não |  |
| run_id | string | não |  |
| sources | array&lt;entity.AIReportSource&gt; | não |  |
| version | integer | não |  |
| workspace_id | string | não |  |

#### entity.AIResourceVersion

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| id | string | não |  |
| kind | string | não |  |
| version | string | não |  |

#### entity.AIRun

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| cancel_requested | boolean | não |  |
| chat_id | string | não |  |
| created_at | string | não |  |
| error_code | string | não |  |
| id | string | não |  |
| message_id | string | não |  |
| model | string | não |  |
| requested_by | string | não |  |
| revision | integer | não |  |
| state | entity.AIRunState | não |  |
| updated_at | string | não |  |

#### entity.AIRunEvent

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| kind | string | não |  |
| sequence | integer | não |  |
| state | entity.AIRunState | não |  |

#### entity.AIRunState

Sem propriedades.

#### entity.AISkill

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| created_by | string | não |  |
| deleted_at | string | não |  |
| description | string | não |  |
| enabled | boolean | não |  |
| id | string | não |  |
| instructions | string | não |  |
| keywords | array&lt;string&gt; | não |  |
| name | string | não |  |
| revision | integer | não |  |
| selection_mode | string | não |  |
| updated_at | string | não |  |
| updated_by | string | não |  |
| workspace_id | string | não |  |

#### entity.AISkillVersion

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| created_by | string | não |  |
| deleted_at | string | não |  |
| description | string | não |  |
| enabled | boolean | não |  |
| instructions | string | não |  |
| keywords | array&lt;string&gt; | não |  |
| name | string | não |  |
| revision | integer | não |  |
| selection_mode | string | não |  |
| skill_id | string | não |  |
| workspace_id | string | não |  |

#### entity.AIStatement

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| chat_id | string | não |  |
| completed_at | string | não |  |
| created_at | string | não |  |
| id | string | não |  |
| instruction | string | não |  |
| issues | array&lt;entity.AIStatementIssue&gt; | não |  |
| message_id | string | não |  |
| model | string | não |  |
| requested_by | string | não |  |
| row_count | integer | não |  |
| run_id | string | não |  |
| session_id | string | não |  |
| sources | array&lt;entity.AIStatementSource&gt; | não |  |
| staged_transaction_ids | array&lt;string&gt; | não |  |
| state | string | não |  |
| target | entity.AIStatementTarget | não |  |

#### entity.AIStatementIssue

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| code | string | não |  |
| message | string | não |  |
| row | integer | não |  |

#### entity.AIStatementSource

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| attachment_id | string | não |  |
| binding_created_at | string | não |  |
| content_type | string | não |  |
| expires_at | string | não |  |
| filename | string | não |  |
| provenance | string | não |  |
| sha256 | string | não |  |
| size_bytes | integer | não |  |

#### entity.AIStatementTarget

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| billing_month | string | não |  |
| currency_code | string | não |  |
| id | string | não |  |
| kind | string | não |  |

#### entity.AIWorkspacePolicy

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| allowed_models | array&lt;string&gt; | não |  |
| default_model | string | não |  |
| enabled | boolean | não |  |
| monthly_limit_micros | integer | não |  |
| revision | integer | não |  |
| updated_at | string | não |  |
| updated_by | string | não |  |
| workspace_id | string | não |  |

#### entity.CategoryType

Sem propriedades.

#### usecase.AIAttachmentPage

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| items | array&lt;entity.AIAttachment&gt; | não |  |
| limit | integer | não |  |
| page | integer | não |  |
| total | integer | não |  |

#### usecase.AIChatDetail

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| chat | entity.AIChat | não |  |
| has_more | boolean | não |  |
| messages | array&lt;entity.AIMessage&gt; | não |  |
| next_before_sequence | integer | não |  |
| runs | array&lt;entity.AIRun&gt; | não |  |

#### usecase.AIChatPage

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| items | array&lt;entity.AIChat&gt; | não |  |
| limit | integer | não |  |
| page | integer | não |  |
| total | integer | não |  |

#### usecase.AICreatePublicResearch

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| confirm_public_query | boolean | não |  |
| id | string | não |  |
| query | string | não |  |

#### usecase.AICredentialStatus

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| api_key_id | string | não |  |
| configured | boolean | não |  |
| fingerprint | string | não |  |
| id | string | não |  |
| validated_at | string | não |  |
| version | integer | não |  |

#### usecase.AIEnrichmentBatchDetail

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| batch | entity.AIEnrichmentBatch | não |  |
| run | entity.AIRun | não |  |

#### usecase.AIEnrichmentDetail

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| batches | array&lt;usecase.AIEnrichmentBatchDetail&gt; | não |  |
| completed_batches | integer | não |  |
| enrichment | entity.AIEnrichment | não |  |
| remaining_batches | integer | não |  |
| suggestions | array&lt;usecase.AIEnrichmentItem&gt; | não |  |

#### usecase.AIEnrichmentItem

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| category_id | string | não |  |
| category_name | string | não |  |
| certain | boolean | não |  |
| description | string | não |  |
| index | integer | não |  |
| sub_category_id | string | não |  |
| sub_category_name | string | não |  |
| type | entity.CategoryType | não |  |

#### usecase.AIEnrichmentPage

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| items | array&lt;usecase.AIEnrichmentDetail&gt; | não |  |

#### usecase.AIExternalHumanToken

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| access_token | string | não |  |
| action_id | string | não |  |
| connection_id | string | não |  |
| expires_at | string | não |  |
| tool | string | não |  |
| update_item | string | não |  |

#### usecase.AIExternalHumanTokenPage

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| items | array&lt;usecase.AIExternalHumanTokenStatus&gt; | não |  |

#### usecase.AIExternalHumanTokenStatus

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| action_id | string | não |  |
| connection_id | string | não |  |
| expires_at | string | não |  |
| institution | string | não |  |
| state | string | não |  |
| tool | string | não |  |

#### usecase.AIFinancialRecovery

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| receipt | usecase.AIMutationReceipt | não |  |
| receipt_json | string | não |  |
| run | entity.AIRun | não |  |

#### usecase.AIHumanConfirmation

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| created_at | string | não |  |
| digest | string | não |  |
| expires_at | string | não |  |
| id | string | não |  |
| requested_by | string | não |  |
| run_id | string | não |  |
| state | entity.AIActionState | não |  |
| updated_at | string | não |  |

#### usecase.AIHumanProposal

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| arguments | object | não |  |
| arguments_json | string | não |  |
| required_scopes | array&lt;string&gt; | não |  |
| resources | array&lt;entity.AIResourceVersion&gt; | não |  |
| tool | string | não |  |
| tool_version | string | não |  |

#### usecase.AIImageUploadDelivery

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| action_id | string | não |  |
| content_type | string | não |  |
| expires_at | string | não |  |
| headers | object | não |  |
| image_linked | boolean | não |  |
| key | string | não |  |
| method | string | não |  |
| size_bytes | integer | não |  |
| state | string | não |  |
| target_id | string | não |  |
| upload_completed | boolean | não |  |
| url | string | não |  |

#### usecase.AIImageUploadPage

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| items | array&lt;usecase.AIImageUploadView&gt; | não |  |

#### usecase.AIImageUploadView

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| action_id | string | não |  |
| content_type | string | não |  |
| expires_at | string | não |  |
| filename | string | não |  |
| handle | string | não |  |
| image_linked | boolean | não |  |
| size_bytes | integer | não |  |
| state | string | não |  |
| target_id | string | não |  |
| target_kind | string | não |  |
| target_name | string | não |  |
| upload_completed | boolean | não |  |

#### usecase.AIMaintenanceExecuteRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| confirm | boolean | não |  |
| digest | string | não |  |

#### usecase.AIMaintenancePlanRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| continue_after | string | não |  |
| id | string | não |  |
| limit | integer | não |  |

#### usecase.AIMaintenanceResult

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| plan | entity.AIMaintenancePlan | não |  |
| totals | usecase.AIMaintenanceTotals | não |  |

#### usecase.AIMaintenanceTotals

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| deleted | integer | não |  |
| eligible | integer | não |  |
| eligible_bytes | integer | não |  |
| erased | integer | não |  |
| retained | integer | não |  |
| selected | integer | não |  |
| unresolved | integer | não |  |

#### usecase.AIMutationCapability

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| constraints | array&lt;string&gt; | não |  |
| input_schema | object | não |  |
| name | string | não |  |
| reason | string | não |  |
| reason_code | string | não |  |
| required_scope | string | não |  |
| required_scopes | array&lt;string&gt; | não |  |
| status | usecase.AIMutationStatus | não |  |
| tool_version | string | não |  |

#### usecase.AIMutationReceipt

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| action_id | string | não |  |
| digest | string | não |  |
| executed_at | string | não |  |
| requested_by | string | não |  |
| result | object | não |  |
| run_id | string | não |  |
| tool | string | não |  |
| tool_version | string | não |  |
| workspace_id | string | não |  |

#### usecase.AIMutationStatus

Sem propriedades.

#### usecase.AIPrepareStatement

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| attachment_ids | array&lt;string&gt; | não |  |
| id | string | não |  |
| instruction | string | não |  |
| model | string | não |  |
| revision | integer | não |  |
| target | usecase.AIStatementTargetInput | não |  |

#### usecase.AIProgressRecovery

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| completed_tools | integer | não |  |
| phase | string | não |  |
| ready_to_publish | boolean | não |  |
| remaining_tools | integer | não |  |
| run | entity.AIRun | não |  |

#### usecase.AIPublicResearchPage

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| items | array&lt;entity.AIPublicResearch&gt; | não |  |

#### usecase.AIRefreshReport

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| id | string | não |  |
| model | string | não |  |
| revision | integer | não |  |

#### usecase.AIReportDefinitions

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| has_more | boolean | não |  |
| items | array&lt;entity.AIReportDefinition&gt; | não |  |
| next_before_revision | integer | não |  |

#### usecase.AIReportDetail

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| latest_version | entity.AIReportVersion | não |  |
| report | entity.AIReport | não |  |
| runs | array&lt;entity.AIRun&gt; | não |  |

#### usecase.AIReportPage

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| items | array&lt;entity.AIReport&gt; | não |  |
| limit | integer | não |  |
| page | integer | não |  |
| total | integer | não |  |

#### usecase.AIReportRefreshResult

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| refresh | entity.AIReportRefresh | não |  |
| report | entity.AIReport | não |  |
| run | entity.AIRun | não |  |

#### usecase.AIReportVersions

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| has_more | boolean | não |  |
| items | array&lt;entity.AIReportVersion&gt; | não |  |
| next_before_version | integer | não |  |

#### usecase.AIRunConfirmation

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| confirmation | usecase.AIHumanConfirmation | não |  |
| preview | object | não |  |
| proposal | usecase.AIHumanProposal | não |  |
| run | entity.AIRun | não |  |

#### usecase.AIRunDetail

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| events | array&lt;entity.AIRunEvent&gt; | não |  |
| run | entity.AIRun | não |  |

#### usecase.AISendResult

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| chat | entity.AIChat | não |  |
| message | entity.AIMessage | não |  |
| run | entity.AIRun | não |  |

#### usecase.AISkillPage

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| items | array&lt;entity.AISkill&gt; | não |  |
| limit | integer | não |  |
| page | integer | não |  |
| total | integer | não |  |

#### usecase.AISkillVersions

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| has_more | boolean | não |  |
| items | array&lt;entity.AISkillVersion&gt; | não |  |
| next_before_revision | integer | não |  |

#### usecase.AIStatementPage

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| items | array&lt;usecase.AIStatementResult&gt; | não |  |
| limit | integer | não |  |
| page | integer | não |  |
| total | integer | não |  |

#### usecase.AIStatementResult

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| run | entity.AIRun | não |  |
| statement | entity.AIStatement | não |  |

#### usecase.AIStatementTargetInput

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| billing_month | string | não |  |
| id | string | não |  |
| kind | string | não |  |

#### usecase.AIWorkspaceState

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| budget | entity.AIBudgetMonth | não |  |
| currency | string | não |  |
| policy | entity.AIWorkspacePolicy | não |  |
| timezone | string | não |  |

#### v1.aiAttachmentCapabilities

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| enabled | boolean | não |  |
| kinds | array&lt;string&gt; | não |  |
| max_file_bytes | integer | não |  |
| max_prompt_bytes | integer | não |  |
| max_prompt_items | integer | não |  |

#### v1.aiCapabilitiesResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| attachments | v1.aiAttachmentCapabilities | não |  |
| inference_disabled_reason | string | não |  |
| inference_enabled | boolean | não |  |
| mutations | array&lt;usecase.AIMutationCapability&gt; | não |  |
| mutations_enabled | boolean | não |  |

#### v1.aiConfirmationDecisionRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| action_id | string | não |  |
| approve | boolean | não |  |
| confirm_name | string | não |  |
| digest | string | não |  |
| revision | integer | não |  |

#### v1.aiCreateChatRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| id | string | não |  |
| model | string | não |  |
| title | string | não |  |

#### v1.aiCredentialRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| api_key | string | não |  |

#### v1.aiFinancialRecoveryRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| revision | integer | não |  |

#### v1.aiPolicyRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| allowed_models | array&lt;string&gt; | não |  |
| default_model | string | não |  |
| enabled | boolean | não |  |
| monthly_limit_micros | integer | não |  |
| revision | integer | não |  |

#### v1.aiReportCreateRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| definition | entity.AIReportDefinitionContent | não |  |
| id | string | não |  |

#### v1.aiReportDeleteRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| revision | integer | não |  |

#### v1.aiReportUpdateRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| definition | entity.AIReportDefinitionContent | não |  |
| revision | integer | não |  |

#### v1.aiRunResumeRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| revision | integer | não |  |

#### v1.aiSendMessageRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| attachment_ids | array&lt;string&gt; | não |  |
| content | string | não |  |
| id | string | não |  |
| model | string | não |  |
| revision | integer | não |  |

#### v1.aiSettingsResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| member_credential | usecase.AICredentialStatus | não |  |
| provider_credential | usecase.AICredentialStatus | não |  |
| workspace | usecase.AIWorkspaceState | não |  |

#### v1.aiSkillCreateRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| description | string | não |  |
| enabled | boolean | não |  |
| id | string | não |  |
| instructions | string | não |  |
| keywords | array&lt;string&gt; | não |  |
| name | string | não |  |
| selection_mode | string | não |  |

#### v1.aiSkillDeleteRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| revision | integer | não |  |

#### v1.aiSkillUpdateRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| description | string | não |  |
| enabled | boolean | não |  |
| instructions | string | não |  |
| keywords | array&lt;string&gt; | não |  |
| name | string | não |  |
| revision | integer | não |  |
| selection_mode | string | não |  |

#### v1.ErrorResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| error | string | não |  |
