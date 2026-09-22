# GitNexus Engineering Plan

> Task: Replace the application-wide Pluggy credentials with securely stored credentials owned by each workspace.
> Evidence verified at commit `36c2bda8ee7750295eb175cf2f47421c10ca1127`; GitNexus index is 1 commit behind HEAD and could not be refreshed because the runner is not available on PATH. Source verification is authoritative.
> Evidence provenance schema 2; global dirty digest `0a9c85780067d9afcd0764f307b60891e3cee927ee11eaeb5ec7826d10fd82cd`; cited-path manifest 11 sorted entries; exact generated plan path excluded.

## 1. Objective

Provide a Pluggy configuration per workspace, managed only by workspace admins, without exposing `client_secret`, and make every Open Finance operation resolve the provider from the owning workspace credential.

## 2. Current Behaviour

- [verified] `buildUseCases` constructs one Pluggy client from global config and injects it into one `OpenFinanceUseCaseImpl` (`internal/app/wiring_usecases.go:136-137`).
- [verified] `OpenFinanceUseCaseImpl` stores that singleton provider and uses it for token creation, connection reads, manual sync, scheduled sync, and webhook processing (`internal/usecase/openfinance.go:95-106`, `109-650`).
- [verified] connections are workspace-scoped but have no credential reference (`internal/entity/openfinance.go:10-25`); the scheduled job iterates every connection (`internal/app/jobs.go:32-39`).
- [verified] the global webhook route checks one environment secret (`internal/controller/http/v1/openfinance.go:38-47`).

## 3. Relevant Architecture

- [verified] GORM auto-migrates Open Finance entities in `internal/app/migrations.go:84-88`; a credential entity belongs in that migration boundary.
- [verified] AES-GCM encryption is available through `service.CipherService` (`internal/service/crypto.go:17-64`), but it is currently built in `buildAuthDeps`, after `buildUseCases` (`internal/app/wiring.go:49-52`, `internal/app/wiring_auth.go:50-53`).
- [verified] workspace routes have membership middleware; `workspaceStepUp` already provides a five-minute MFA step-up group (`internal/controller/http/v1/router.go:158-161`).
- [verified] repository methods already enforce `workspace_id` on interactive connection and account-link access (`internal/usecase/repo/openfinance_postgres.go:62-91`, `166-179`).

## 4. GitNexus Findings

- [graph, stale index] `impact(NewOpenFinanceUseCase, upstream)` reports HIGH risk: direct dependency `buildUseCases`, then application startup; affected modules include Usecase, App, and Httpserver.
- [graph, stale index] `impact(newOpenFinanceWebhookRoute, upstream)` reports HIGH risk: direct dependency `NewRouter`, then application startup; affected modules include V1, Config, and Httpserver.
- [graph, stale index] `context(SyncAllLinkedAccounts)` identifies `startCronJobs` as its direct caller and the singleton provider as a direct dependency.

## 5. Statement-Level PDG Findings

- [graph] `pdg_query(controls, internal/usecase/openfinance.go)` shows that `CreateConnectToken` persists the pending connection before requesting a provider token; provider failure triggers disconnect cleanup (`openfinance.go:114-125`). Preserve this ordering and ensure a missing workspace credential fails before a pending connection is persisted.
- [graph] `FinalizeConnection` only persists the external Item after the provider's `ClientUserID` is verified (`openfinance.go:173-178`). Keep this ownership check with the workspace-resolved provider.
- [verified] scheduled sync obtains each connection's workspace and user context before provider calls (`openfinance.go:309-331`); provider resolution must use the connection workspace, not an ambient request workspace.

## 6. Proposed Changes

1. Add `OpenFinanceWorkspaceCredential`: one record per `(workspace_id, provider)`, with encrypted secret, client ID, non-secret configuration fields, and timestamps. Add `CredentialID` to `OpenFinanceConnection` so existing connections continue to resolve their original provider credentials after a later replacement. Do not serialize encrypted data.
2. Extend the Open Finance repository with credential CRUD/lookup and eager-load credential data for scheduled connections. Keep queries workspace-scoped and do not delete a credential referenced by a live connection.
3. Replace the singleton `provider` dependency with a credential-aware provider resolver/factory. It decrypts just-in-time, creates a per-credential Pluggy client, and returns a validation error when no credential exists. Reuse the existing cipher service; create it once in app wiring and inject it into both auth and Open Finance construction.
4. Add workspace-admin, MFA-step-up protected API endpoints to get credential status, validate-and-save a credential, and remove it only when no active connections depend on it. Responses expose only provider, client-ID suffix/status/timestamps—never a secret.
5. Resolve the provider from each connection's credential for every existing workflow: create/attach/finalize/update, accounts, manual sync, disconnect, cron sync, and webhook event processing. Keep the webhook ingress secret global for endpoint authentication; it is server infrastructure, not customer Pluggy application data.
6. Retain global Pluggy environment variables only as an explicit legacy fallback for pre-migration connections during rollout; new connections require workspace credentials. Mark their removal as a follow-up after existing connections are migrated or retired.

## 7. Implementation Sequence

1. Add entity fields, migration registration, repository methods, and repository tests for credential uniqueness, workspace isolation, and deletion guards.
2. Introduce a provider resolver backed by encrypted workspace credentials; refactor use-case construction and all provider call sites. Add unit tests proving missing credentials do not create pending connections and that cron resolves credentials per connection workspace.
3. Add credential status/save/delete use-case methods and protected routes. Register mutation routes under both `workspaceStepUp` and an admin guard; add Swagger annotations and regenerate OpenAPI artifacts.
4. Update webhook processing and scheduled-sync paths to load credentials by connection reference; test that incoming events for different workspace connections use their own provider credentials.
5. Implement the frontend credential settings panel and API client in a separate frontend change after the backend contract is verified. Preserve the user's unrelated local frontend change.
6. Run `make check`, targeted tests, `make swagger`, and final graph/change review. Remove legacy fallback only in a separately approved migration release.

## 8. Test Strategy

- `internal/usecase/openfinance_test.go`: missing workspace credential; encrypted credential resolver; create-token ordering; manual and scheduled sync credential selection.
- `internal/usecase/repo/openfinance_postgres_test.go` (new or existing): provider/workspace uniqueness and credential deletion rejection when active connections exist.
- `internal/controller/http/v1/*_test.go`: non-admin denied, stale MFA denied, admin can save status but never receives `client_secret`.
- `internal/infra/openfinance/pluggy/client_test.go`: credential-specific clients do not share cached API keys.
- Commands: `make test`, `make typecheck`, `make lint`, `make swagger`, then `make check`.

## 9. Risk and Impact Analysis

- [graph] HIGH-risk startup wiring and webhook routing require all constructor and router callers to be updated together.
- [verified] a Pluggy client caches an API key in-memory (`internal/infra/openfinance/pluggy/client.go:172-194`); never reuse that cache across credential records.
- [inferred] changing an active credential can orphan existing Items, because the new Pluggy application need not see Items created by the old one. Prevent destructive replacement while active connections exist; require disconnect/reconnect.
- [verified] webhook events are durable and retried (`internal/usecase/repo/openfinance_postgres.go:273-304`); failure to decrypt or resolve a credential must remain retriable and must not leak a secret in `last_error` or logs.

## 10. Files Expected to Change

| File | Symbols | Reason |
| --- | --- | --- |
| `internal/entity/openfinance.go` | credential + connection entity | Persist encrypted workspace credentials and immutable connection reference. |
| `internal/app/migrations.go` | `autoMigrate` | Create schema. |
| `internal/usecase/repo/openfinance_postgres.go` | `OpenFinanceRepo` | Credential lifecycle and scoped lookup. |
| `internal/usecase/openfinance.go` | `OpenFinanceUseCaseImpl` | Resolve providers per credential. |
| `internal/app/wiring*.go` | dependency construction | Share cipher and provider resolver. |
| `internal/controller/http/v1/openfinance.go`, `router.go` | routes | Admin/MFA credential controls. |
| `internal/usecase/openfinance_test.go` | tests | Regression coverage. |

## 11. Reusable Implementation Context

```yaml
implementation_context:
  task_summary: 'Store and use Pluggy credentials per workspace.'
  acceptance_criteria:
    - 'A workspace admin can securely save and inspect non-secret credential status.'
    - 'No API response, log, or JSON entity exposes client_secret.'
    - 'Every Open Finance provider request is resolved from the owning workspace credential.'
    - 'Existing connection credential identity cannot silently change.'
  evidence_provenance:
    schema_version: 2
    head_commit: '36c2bda8ee7750295eb175cf2f47421c10ca1127'
    generated_plan_path: 'docs/plans/2026-09-17-gitnexus-plan-workspace-pluggy-credentials.md'
    global_dirty_digest: { algorithm: 'sha256', canonicalization: 'gitnexus-evidence-provenance-v2 NUL-framed UTF-8 records', value: '0a9c85780067d9afcd0764f307b60891e3cee927ee11eaeb5ec7826d10fd82cd' }
    cited_path_manifest:
      - { path: 'AGENTS.md', object_kind: { head: 'regular', index: 'regular', worktree: 'regular', untracked: 'absent' }, state: 'clean', rename_from: null, rename_to: null, head_digest: 'sha256:aeaece6e19fed515e4dab049677ab556f6db81c5a73f632946e3231b498fdc03', index_digest: 'sha256:aeaece6e19fed515e4dab049677ab556f6db81c5a73f632946e3231b498fdc03', worktree_digest: 'sha256:aeaece6e19fed515e4dab049677ab556f6db81c5a73f632946e3231b498fdc03', untracked_digest: 'absent' }
      - { path: 'Makefile', object_kind: { head: 'regular', index: 'regular', worktree: 'regular', untracked: 'absent' }, state: 'clean', rename_from: null, rename_to: null, head_digest: 'sha256:e95db87627a30f938b64aa6dde32b44b10bf7bb5f5933e30464c8d9ff92e9f9a', index_digest: 'sha256:e95db87627a30f938b64aa6dde32b44b10bf7bb5f5933e30464c8d9ff92e9f9a', worktree_digest: 'sha256:e95db87627a30f938b64aa6dde32b44b10bf7bb5f5933e30464c8d9ff92e9f9a', untracked_digest: 'absent' }
      - { path: 'internal/app/migrations.go', object_kind: { head: 'regular', index: 'regular', worktree: 'regular', untracked: 'absent' }, state: 'clean', rename_from: null, rename_to: null, head_digest: 'sha256:a19d557f16ee81fea31fc9da8adc0cb684b925eb67b41f5ced935c368be77dbb', index_digest: 'sha256:a19d557f16ee81fea31fc9da8adc0cb684b925eb67b41f5ced935c368be77dbb', worktree_digest: 'sha256:a19d557f16ee81fea31fc9da8adc0cb684b925eb67b41f5ced935c368be77dbb', untracked_digest: 'absent' }
      - { path: 'internal/app/wiring_usecases.go', object_kind: { head: 'regular', index: 'regular', worktree: 'regular', untracked: 'absent' }, state: 'clean', rename_from: null, rename_to: null, head_digest: 'sha256:8b45590d6922810ba0a4a409467ad6066c00d665706d26797b4a47ebd1918315', index_digest: 'sha256:8b45590d6922810ba0a4a409467ad6066c00d665706d26797b4a47ebd1918315', worktree_digest: 'sha256:8b45590d6922810ba0a4a409467ad6066c00d665706d26797b4a47ebd1918315', untracked_digest: 'absent' }
      - { path: 'internal/controller/http/v1/openfinance.go', object_kind: { head: 'regular', index: 'regular', worktree: 'regular', untracked: 'absent' }, state: 'clean', rename_from: null, rename_to: null, head_digest: 'sha256:dcf2ebe0a9d5d8bd89e6cfd9cfcd8a46a62d64e72340e42d18707330f3398dc0', index_digest: 'sha256:dcf2ebe0a9d5d8bd89e6cfd9cfcd8a46a62d64e72340e42d18707330f3398dc0', worktree_digest: 'sha256:dcf2ebe0a9d5d8bd89e6cfd9cfcd8a46a62d64e72340e42d18707330f3398dc0', untracked_digest: 'absent' }
      - { path: 'internal/controller/http/v1/router.go', object_kind: { head: 'regular', index: 'regular', worktree: 'regular', untracked: 'absent' }, state: 'clean', rename_from: null, rename_to: null, head_digest: 'sha256:9b07db59a8aed9fde66ee203ded54796d204e4c96ab899eb5e1f9bfd9053de95', index_digest: 'sha256:9b07db59a8aed9fde66ee203ded54796d204e4c96ab899eb5e1f9bfd9053de95', worktree_digest: 'sha256:9b07db59a8aed9fde66ee203ded54796d204e4c96ab899eb5e1f9bfd9053de95', untracked_digest: 'absent' }
      - { path: 'internal/entity/openfinance.go', object_kind: { head: 'regular', index: 'regular', worktree: 'regular', untracked: 'absent' }, state: 'clean', rename_from: null, rename_to: null, head_digest: 'sha256:b93985e0ca9dbc7101e45cf422bee70ec87f674d0388b0f8366d5214889beade', index_digest: 'sha256:b93985e0ca9dbc7101e45cf422bee70ec87f674d0388b0f8366d5214889beade', worktree_digest: 'sha256:b93985e0ca9dbc7101e45cf422bee70ec87f674d0388b0f8366d5214889beade', untracked_digest: 'absent' }
      - { path: 'internal/service/crypto.go', object_kind: { head: 'regular', index: 'regular', worktree: 'regular', untracked: 'absent' }, state: 'clean', rename_from: null, rename_to: null, head_digest: 'sha256:373f35298aaf7c2480abec2cf50f66418e8e7f0f43ea1964deea469befe42b1b', index_digest: 'sha256:373f35298aaf7c2480abec2cf50f66418e8e7f0f43ea1964deea469befe42b1b', worktree_digest: 'sha256:373f35298aaf7c2480abec2cf50f66418e8e7f0f43ea1964deea469befe42b1b', untracked_digest: 'absent' }
      - { path: 'internal/usecase/openfinance.go', object_kind: { head: 'regular', index: 'regular', worktree: 'regular', untracked: 'absent' }, state: 'clean', rename_from: null, rename_to: null, head_digest: 'sha256:710f64a950fb6df74c0e37c4c54a9cefc1cff86057d4e221abbba1b8d6ce57ea', index_digest: 'sha256:710f64a950fb6df74c0e37c4c54a9cefc1cff86057d4e221abbba1b8d6ce57ea', worktree_digest: 'sha256:710f64a950fb6df74c0e37c4c54a9cefc1cff86057d4e221abbba1b8d6ce57ea', untracked_digest: 'absent' }
      - { path: 'internal/usecase/openfinance_test.go', object_kind: { head: 'regular', index: 'regular', worktree: 'regular', untracked: 'absent' }, state: 'clean', rename_from: null, rename_to: null, head_digest: 'sha256:99669b941961c04bca889cfe2795678def4468e2ee765d02898e795facbedcbb', index_digest: 'sha256:99669b941961c04bca889cfe2795678def4468e2ee765d02898e795facbedcbb', worktree_digest: 'sha256:99669b941961c04bca889cfe2795678def4468e2ee765d02898e795facbedcbb', untracked_digest: 'absent' }
      - { path: 'internal/usecase/repo/openfinance_postgres.go', object_kind: { head: 'regular', index: 'regular', worktree: 'regular', untracked: 'absent' }, state: 'clean', rename_from: null, rename_to: null, head_digest: 'sha256:ff0bf14da8018f27ab11ce22dc5e2557835769cc7c75fa1e9e9a18dd1dfafb3b', index_digest: 'sha256:ff0bf14da8018f27ab11ce22dc5e2557835769cc7c75fa1e9e9a18dd1dfafb3b', worktree_digest: 'sha256:ff0bf14da8018f27ab11ce22dc5e2557835769cc7c75fa1e9e9a18dd1dfafb3b', untracked_digest: 'absent' }
  primary_symbols:
    - { symbol: 'OpenFinanceUseCaseImpl', file: 'internal/usecase/openfinance.go', lines: '95-650', role: 'provider-call orchestration' }
    - { symbol: 'buildUseCases', file: 'internal/app/wiring_usecases.go', lines: '43-168', role: 'singleton provider construction' }
    - { symbol: 'newOpenFinanceWebhookRoute', file: 'internal/controller/http/v1/openfinance.go', lines: '38-47', role: 'webhook ingress' }
  related_symbols:
    - { symbol: 'SyncAllLinkedAccounts', relationship: 'CALLS provider', relevance: 'background workflow' }
    - { symbol: 'CipherService', relationship: 'encrypt/decrypt', relevance: 'secret storage pattern' }
  execution_path:
    - 'Admin saves encrypted workspace credential.'
    - 'Use case resolves credential for workspace/connection.'
    - 'Resolver creates isolated Pluggy client.'
    - 'Interactive, cron, and webhook flows call that client.'
  pdg_constraints:
    - { description: 'Resolve credential before persisting a pending connection.', affected_statements: ['internal/usecase/openfinance.go:114-125'], implementation_consequence: 'missing configuration has no partial connection side effect' }
    - { description: 'Retain Item client-reference verification before final persistence.', affected_statements: ['internal/usecase/openfinance.go:173-178'], implementation_consequence: 'do not weaken authorization check' }
  architectural_patterns:
    - { pattern: 'encrypted entity fields are json-hidden', example_location: 'internal/entity/mfa_setting.go:MFASetting', usage_guidance: 'use SecretEnc with json:-' }
    - { pattern: 'workspace step-up group', example_location: 'internal/controller/http/v1/router.go:158-161', usage_guidance: 'credential mutations require it plus admin authorization' }
  files_to_modify:
    - { file: 'internal/entity/openfinance.go', symbols: ['OpenFinanceWorkspaceCredential', 'OpenFinanceConnection'], intended_change: 'credential persistence and reference' }
    - { file: 'internal/usecase/openfinance.go', symbols: ['OpenFinanceUseCaseImpl'], intended_change: 'credential-aware provider resolution' }
    - { file: 'internal/controller/http/v1/openfinance.go', symbols: ['openFinanceRoutes'], intended_change: 'credential management API' }
  tests:
    - { file: 'internal/usecase/openfinance_test.go', scenarios: ['missing credential → no connection created', 'two workspaces → distinct providers', 'active connection → replacement/removal rejected'] }
  verification_commands: ['make test', 'make typecheck', 'make lint', 'make swagger', 'make check']
  risks:
    - 'Startup and webhook route changes have HIGH graph impact.'
    - 'Old Pluggy application credentials may be required for existing Items.'
  assumptions:
    - 'Existing connections can remain on an explicit legacy fallback until a controlled migration; verify production inventory before removing it.'
  open_questions:
    - 'Confirm the desired rollout policy for existing workspace connections before removal of global environment credentials.'
  avoid:
    - 'Never return, log, or store plaintext client_secret.'
    - 'Do not reuse API-key caches across workspace credentials.'
    - 'Do not overwrite an active credential referenced by a connection.'
```

## 12. Assumptions and Open Questions

- [assumed] Existing connections should use a temporary global legacy fallback until administrators reconnect them under a workspace credential. Confirm before the fallback is removed.
- Deferred: frontend settings UI, because the frontend has an unrelated user modification and must be changed in its own verified worktree step.

## 13. Definition of Done

- Credential storage is encrypted and non-serializable.
- Only a stepped-up workspace admin can manage it.
- New Open Finance connections fail cleanly without workspace credentials.
- Every provider call resolves the credential bound to its workspace/connection.
- Scheduled sync and webhook retry work with separate workspace credentials.
- Unit checks, Swagger generation, and graph change review pass.
