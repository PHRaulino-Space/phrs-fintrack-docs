# GitNexus Engineering Plan

> Task: Implementar um fluxo seguro de desvinculação e revinculação de contas/cartões Open Finance sem apagar histórico nem deixar vínculos que bloqueiem uma nova associação.
> Evidence verified at commit 2df8ab54fc01eec09aa81b7829d121d12e370e29; GitNexus index fresh/current, runner GitNexus 1.6.11 on Node v22.23.2, PDG present.
> Evidence provenance schema 2; global dirty digest 63c037087aa26119b63dea8235dfec8178dfa66def0338786c7948c5c2562018; cited-path manifest 14 sorted entries; exact generated plan path excluded.

## 1. Objective

Criar dois ciclos de vida distintos e explícitos: **desvincular uma conta local** (mantém o consentimento/conexão do provedor) e **desconectar a conexão Open Finance** (revoga o item no provedor e desvincula todas as contas locais). A desvinculação deve ser idempotente, permitir revinculação ao destino correto e preservar a trilha de importação, as decisões de revisão e as transações financeiras já materializadas.

## 2. Current Behaviour

- [verified] `DisconnectConnection` chama primeiro o provedor e depois o repositório; a transação local desativa sessões e faz soft-delete da conexão, mas não muda nem remove os `OpenFinanceAccountLink` (`internal/usecase/openfinance.go:333-348`, `internal/usecase/repo/openfinance_postgres.go:30-59`).
- [verified] `LinkAccount` rejeita qualquer registro encontrado por `(provider, external_account_id)` como “already linked” antes de alcançar o ramo de reaproveitamento existente em `UpsertAccountLink` (`internal/usecase/openfinance.go:225-288`, `internal/usecase/repo/openfinance_postgres.go:94-120`). Este é o bloqueio observado após desconectar e conectar novamente.
- [verified] `OpenFinanceAccountLink` tem índice único global em `(provider, external_account_id)` e não possui estado de desvinculação; `OpenFinanceImportedTransaction` depende do link com `OnDelete:CASCADE` (`internal/entity/openfinance.go:27-65`). Excluir fisicamente o link destruiria a trilha de idempotência/auditoria.
- [verified] A sessão automática guarda `account_id`/`card_id`, permanece persistente e é usada como destino prioritário no commit; as linhas staged permanecem como trilha depois de importar/ignorar/sobrescrever (`internal/entity/import.go:70-125`, `internal/usecase/repo/import_postgres.go:411-540`). Isso permite retargetar pendências atualizando a sessão, sem reescrever transações finais.
- [verified] Sincronização manual, agendada e por webhook ainda conseguem localizar links porque os getters e preloads atuais não distinguem ativo de desvinculado (`internal/usecase/openfinance.go:290-331`, `internal/usecase/openfinance.go:583-638`, `internal/usecase/repo/openfinance_postgres.go:62-92,166-179`).
- [verified] Consulta somente-leitura ao banco conectado em 2026-09-11 encontrou 9 links em conexões ativas e 0 links em conexões desconectadas, consistente com a limpeza manual já realizada; a migração ainda precisa cobrir outros ambientes e futuras desconexões.

## 3. Relevant Architecture

- [verified] O fluxo segue controller Gin → `OpenFinanceUseCase` → `OpenFinanceRepo`/PostgreSQL, com contexto de workspace aplicado no use case (`AGENTS.md`, `internal/controller/http/v1/openfinance.go:22-36`, `internal/usecase/openfinance.go:225-348`).
- [verified] `DELETE /open-finance/connections/{id}` representa a revogação remota e não deve ser reutilizado para desvinculação local (`internal/controller/http/v1/openfinance.go:84-104`).
- [verified] O contrato MCP de workspace espelha as rotas Open Finance e marca operações de exclusão como destrutivas (`cmd/mcp-server/tools/workspace_api.go:373-386`).
- [verified] Alterações de rota exigem anotações Swagger, regeneração por `make swagger` e paridade entre Gin, comentários e artefatos gerados (`AGENTS.md`, `Makefile:69-120`, `internal/controller/http/v1/swagger_parity_scan_test.go:15-45`, `internal/controller/http/v1/swagger_parity_test.go:24-88`).

## 4. GitNexus Findings

- [graph] `context(uid=OpenFinanceUseCaseImpl.DisconnectConnection)` encontrou como dependente direto o handler `openFinanceRoutes.disconnectConnection` e como saídas o provider e o repositório. A análise é lower-bound por dispatch de interfaces.
- [graph] `context(uid=OpenFinanceUseCaseImpl.LinkAccount)` confirmou o caminho `GetAccountLinkByExternalID → UpsertAccountLink → ensureAutomaticSession` e o handler HTTP como chamador direto.
- [graph] `impact(LinkAccount, upstream, maxDepth=2)` retornou risco LOW e um dependente d=1: `openFinanceRoutes.linkAccount`.
- [graph] `impact(UpsertAccountLink, upstream, maxDepth=2)` retornou risco LOW; d=1 é `LinkAccount`, e d=2 é o handler HTTP.
- [graph] `impact(GetAccountLinkByExternalID, upstream, maxDepth=2)` retornou dois dependentes d=1: `LinkAccount` e `processWebhookEvent`, atingindo três fluxos de webhook.
- [graph] `impact(GetAccountLink, upstream, maxDepth=2)` retornou três dependentes d=1: `ListSyncedTransactions`, `RestoreSyncedTransaction` e `SyncAccount`. O plano preserva leitura de auditoria e adiciona validação de atividade apenas nas operações mutáveis.
- [graph] `impact(GetConnection, upstream, maxDepth=2)` retornou risco MEDIUM e seis dependentes d=1. Por isso o plano evita mudar a semântica geral deste getter; a filtragem de links ativos fica em listagens e operações específicas.
- [graph] `impact(ListConnectionsForSync, upstream, maxDepth=2)` retornou d=1 `SyncAllLinkedAccounts` e d=2 `startCronJobs`; a consulta deve excluir links desvinculados.
- [graph] O `api_impact` não reconheceu as rotas Gin deste arquivo; impacto de API foi verificado diretamente no registro de rotas, Swagger e catálogo MCP.
- [graph] `detect_changes(scope=all)` registrou 5 arquivos já modificados, risco HIGH, referentes ao cron de sincronização das 22h e à correção de `import_session_ids`. A execução deste plano deve preservar e revalidar esse trabalho não commitado.

## 5. Statement-Level PDG Findings

- [graph] No slice de `LinkAccount` ancorado em `internal/usecase/openfinance.go:260`, o acesso ao vínculo existente é controlado pela localização da conta remota e pelas validações de kind/destino em `:247`, `:254` e `:257`. Consequência: a decisão ativo/desvinculado deve ocorrer somente depois dessas validações e antes da escrita transacional.
- [graph] No slice de `UpsertAccountLink` ancorado em `internal/usecase/repo/openfinance_postgres.go:97`, a existência do registro alimenta diretamente a verificação de workspace e os ramos update/create. Consequência: lock, checagem de estado, reativação do link e retarget da sessão devem ficar na mesma transação.
- [graph] O slice de `DisconnectConnection` mostra a ordem condicional `links → session_ids → desativar sessões → soft-delete da conexão` em `internal/usecase/repo/openfinance_postgres.go:31-59`. A marcação dos links como desvinculados deve ser inserida nessa mesma transação antes de finalizar a conexão.
- [graph] Os dois primeiros slices foram limitados por profundidade 2; as condições críticas foram verificadas no código-fonte, e nenhum resultado PDG truncado é usado como prova de ausência de dependências.

## 6. Proposed Changes

1. **Estado de ciclo de vida no vínculo** — `internal/entity/openfinance.go`, `OpenFinanceAccountLink`.
   - [inferred] Adicionar `UnlinkedAt *time.Time` explícito (não `gorm.DeletedAt`) e índice simples. `NULL` significa vínculo ativo; preenchido significa tombstone reutilizável.
   - [verified] Manter `ID`, `ConnectionID`, `ImportSessionID`, `AccountID`/`CardID` anteriores e todos os registros importados; não executar hard-delete nem cascade.
   - [inferred] Representar o resultado da tentativa de bind de forma neutra para que o repositório diferencie `created`, `reactivated`, `already_active` e `foreign_workspace` sem depender da camada HTTP.

2. **Migração e backfill idempotentes** — `internal/app/migrations.go`, `AutoMigrate`.
   - [inferred] Executar `AutoMigrate` para a nova coluna e, depois, marcar como desvinculados os links cuja conexão já possui `deleted_at`; desativar suas sessões automáticas.
   - [inferred] O backfill deve poder rodar várias vezes e não tocar links de conexões ativas. A implantação continua usando `cmd/dbsetup -schema -migrate`, nunca migration no startup.

3. **Transições transacionais no repositório** — `internal/usecase/repo/openfinance_postgres.go`.
   - [inferred] Adicionar operação idempotente de unlink por `(link_id, workspace_id)`: `SELECT ... FOR UPDATE`, retornar sucesso se já desvinculado, preencher `unlinked_at` e desativar a sessão associada numa única transação.
   - [inferred] Fortalecer `UpsertAccountLink`: bloquear o registro existente, rejeitar vínculo ativo ou pertencente a outro workspace, e somente reativar tombstone do mesmo workspace. Na reativação, conservar IDs/histórico, trocar conexão e destino, limpar `unlinked_at` e atualizar `ImportSession.account_id`, `card_id`, `is_active=true` atomically.
   - [inferred] Converter conflito de criação concorrente no mesmo resultado “already active”, evitando erro 500 por unique violation.
   - [inferred] Atualizar `DisconnectConnection` para marcar todos os links da conexão com o mesmo `unlinked_at` enquanto desativa sessões e a conexão.
   - [inferred] `ListConnections` e `ListConnectionsForSync` devem preload/considerar apenas links com `unlinked_at IS NULL`; o `EXISTS` da sincronização agendada deve aplicar o mesmo predicado.
   - [inferred] Manter getters de auditoria capazes de acessar tombstones pelo workspace. Operações de sync/restore e lookup do webhook devem checar atividade explicitamente, preservando `ListImportedTransactions` para consulta histórica.

4. **Orquestração no use case** — `internal/usecase/openfinance.go`, interfaces e implementação.
   - [inferred] Adicionar a operação pública de unlink local, que valida workspace e chama apenas o repositório; ela não chama `provider.DeleteConnection`.
   - [inferred] Ajustar `LinkAccount` para permitir o tombstone do mesmo workspace e deixar o repositório decidir atomically entre criar/reativar/conflitar. Vínculo ativo continua retornando validação; outro workspace continua proibido.
   - [inferred] Em `ListProviderAccounts`, não popular `link_id/account_id/card_id` para tombstones, fazendo a conta remota reaparecer como disponível para vínculo.
   - [inferred] Em `SyncAccount`, `RestoreSyncedTransaction` e `processWebhookEvent`, ignorar/rejeitar tombstones antes de buscar ou escrever transações. Revalidar a atividade depois da chamada de rede e antes de staging para estreitar a janela de corrida.
   - [verified] Ao reativar, a sessão preservada passa a apontar ao novo destino; pendências já staged são materializadas no novo `account_id/card_id` porque o commit prioriza o destino da sessão. Registros terminais e transações finais não são movidos.

5. **Contrato HTTP e MCP** — `internal/controller/http/v1/openfinance.go`, `cmd/mcp-server/tools/workspace_api.go`.
   - [inferred] Registrar `DELETE /open-finance/account-links/{id}` com retorno `204 No Content`, idempotente, protegido pelo mesmo workspace/CSRF das demais mutações.
   - [inferred] Documentar no Swagger: “remove apenas a associação local; não revoga o consentimento, não apaga histórico e desativa pendências até uma revinculação”. ID inválido retorna 400; link de outro workspace não fica observável; vínculo inexistente segue a política 404 atual.
   - [inferred] Expor `unlink_open_finance_account` no catálogo MCP com `pathParams("id:account_link_id")`, `destructive()` para confirmação explícita e `openWorld()` consistente com as operações Open Finance existentes.

6. **Documentação gerada** — `openapi/docs.go`, `openapi/swagger.json`, `openapi/swagger.yaml` e cópias existentes sob `docs/`.
   - [verified] Rodar `make swagger` uma única vez no fim, depois que rota, tipos e comentários estiverem estáveis.

## 7. Implementation Sequence

1. Revalidar o digest do working tree e preservar as cinco alterações locais já existentes; executar impacto GitNexus antes de editar cada símbolo compartilhado.
2. Adicionar o estado `unlinked_at` e o resultado de lifecycle ao modelo; atualizar `AutoMigrate` com backfill idempotente e teste de migração.
3. Implementar primeiro os testes de integração do repositório para unlink, reativação, preservação de histórico, desconexão em lote e concorrência; fazê-los falhar contra o comportamento atual.
4. Implementar as transações com row lock em `UpsertAccountLink`, na nova operação de unlink e em `DisconnectConnection`; então ajustar as queries ativas/agendadas.
5. Atualizar contratos e implementação do use case, incluindo o retarget da sessão, validações de atividade e o comportamento diferenciado entre unlink local e disconnect remoto.
6. Adicionar rota/handler, documentação Swagger e operação MCP; adicionar testes HTTP da rota e manter erros sem vazamento cross-workspace.
7. Regenerar OpenAPI e cópias do submódulo uma vez; rodar paridade Swagger.
8. Executar checks unitários e de integração, reindexar GitNexus e rodar `detect_changes(scope=all)`; revisar separadamente o risco do cron das 22h que já está no mesmo working tree.

## 8. Test Strategy

### Unitários (`internal/usecase/openfinance_test.go`)

- vínculo ativo → `LinkAccount` → erro de validação “already linked”;
- tombstone do mesmo workspace → `LinkAccount` → sucesso, mesmo link/session ID e novo destino;
- tombstone de outro workspace → `LinkAccount` → forbidden sem alteração;
- unlink local → não chama provider e encaminha `link_id/workspace_id` corretos;
- sync manual ou restore em tombstone → rejeita sem chamar provider/staging;
- webhook para conta desvinculada → evento concluído sem staging;
- listagem de contas remotas → tombstone aparece sem `link_id` e pode ser vinculado novamente;
- conexão desconectada → fluxo remoto permanece separado e delega marcação em lote ao repo.

### Integração PostgreSQL (novo `internal/usecase/repo/openfinance_link_lifecycle_postgres_test.go`, seguindo o padrão de `internal/usecase/repo/import_commit_postgres_test.go`)

- unlink ativo → `unlinked_at` preenchido + sessão inativa, contagens e IDs de imported/staged/final inalterados;
- segundo unlink → sucesso idempotente e timestamps/dados estáveis;
- rebind → mesmo link/session ID, `unlinked_at=NULL`, sessão ativa e novo target;
- pendência criada antes do unlink → após rebind/commit, materializa apenas no novo target;
- `IMPORTED`, `IGNORED`, `SUPERSEDED` → preservados e não reimportados após rebind;
- disconnect de conexão com vários links → todos tombstoned e sessões inativas atomicamente;
- corrida unlink × rebind → row lock serializa; estado final corresponde à última transição válida, sem link duplicado;
- dois binds concorrentes → um sucesso e um conflito de domínio, nunca unique violation exposta;
- backfill executado duas vezes → mesmo resultado e nenhuma alteração em links ativos.

### HTTP/contrato

- UUID inválido → 400; ativo → 204; repetição → 204; outro workspace/inexistente → política 404 sem enumeração;
- `TestHTTPRoutesMatchSwaggerRouterPairs`, `TestGeneratedOpenAPIMatchesRouterAnnotations` e cópias OpenAPI permanecem verdes.

### Comandos de verificação

1. `make swagger`
2. `go test -count=1 ./internal/usecase ./internal/controller/http/v1`
3. `make test-integration`
4. `make check`
5. GitNexus `detect_changes(scope=all)` sem resultado parcial/truncado.

## 9. Risk and Impact Analysis

- **Alto — preservação de auditoria:** [verified] hard-delete do link pode apagar `open_finance_imported_transactions` por cascade. Mitigação: tombstone explícito, asserts de contagem/IDs e proibição de `Delete` nessa operação.
- **Alto — destino de pendências:** [verified] sessão e staged carregam referência de destino. Mitigação: reativar e retargetar a sessão na mesma transação do link; testar commit posterior no destino novo.
- **Médio — concorrência:** [inferred] bind e unlink separados podem repetir o erro ou expor unique violation. Mitigação: row lock, resultado de domínio e teste com duas conexões PostgreSQL.
- **Médio — sync/webhook em voo:** [graph] `GetAccountLinkByExternalID` alimenta `LinkAccount` e três fluxos `processWebhookEvent`; `GetAccountLink` alimenta list/restore/sync. Mitigação: atividade explícita, recheck pré-staging e nenhum hard-delete.
- **Médio — `GetConnection`:** [graph] seis d=1 (`CreateUpdateConnectToken`, `DisconnectConnection`, `FinalizeConnection`, `LinkAccount`, `ListProviderAccounts`, `SyncAccount`). Mitigação: não alterar sua semântica geral; filtrar tombstones no consumidor/listagens.
- **Baixo — API:** [graph] handlers `linkAccount` e `disconnectConnection` são os d=1 dos use cases atuais. A nova rota é aditiva, mas Swagger/MCP e cliente deverão adotar o contrato.
- **Baixo — cron:** [graph] `ListConnectionsForSync` afeta diretamente `SyncAllLinkedAccounts`; a condição `unlinked_at IS NULL` impede sincronização de tombstones.
- **Rollout:** [inferred] a coluna nullable é backward-compatible. Implantar schema/backfill antes ou junto do binário; o backfill atual deve ser no-op no banco consultado (0 links legados em conexão desconectada).
- **Observabilidade:** [inferred] logar `workspace_id`, `account_link_id`, `connection_id` e resultado `unlinked/reactivated/already_active`; nunca logar payload financeiro. Métricas úteis: contagem de unlink, rebind e conflito.

## 10. Files Expected to Change

| File | Symbols/area | Reason |
| ---- | ------------ | ------ |
| `internal/entity/openfinance.go` | `OpenFinanceAccountLink` | Estado explícito e resultado de lifecycle |
| `internal/app/migrations.go` | `AutoMigrate` | Coluna + backfill idempotente |
| `internal/usecase/openfinance.go` | interfaces, `LinkAccount`, `DisconnectConnection`, `ListProviderAccounts`, `SyncAccount`, `RestoreSyncedTransaction`, `processWebhookEvent` | Semântica de unlink/rebind e guards ativos |
| `internal/usecase/repo/openfinance_postgres.go` | `DisconnectConnection`, `UpsertAccountLink`, list/get methods, nova transição unlink | Atomicidade, reativação e filtros |
| `internal/controller/http/v1/openfinance.go` | route registration + novo handler | Endpoint DELETE local e Swagger |
| `cmd/mcp-server/tools/workspace_api.go` | `workspaceToolSpecs` | Expor operação com confirmação |
| `internal/usecase/openfinance_test.go` | stubs e cenários Open Finance | Regressões do use case |
| `internal/usecase/repo/openfinance_link_lifecycle_postgres_test.go` | novo arquivo integration | Estado, preservação e concorrência PostgreSQL |
| `internal/controller/http/v1/openfinance_test.go` | novo/expandido teste HTTP | Status, workspace e idempotência |
| `openapi/docs.go`, `openapi/swagger.json`, `openapi/swagger.yaml`, cópias sob `docs/` | gerados | Paridade do contrato |

## 11. Reusable Implementation Context

```yaml
implementation_context:
  task_summary: "Adicionar unlink/rebind local idempotente para account links Open Finance, preservando histórico, staging e IDs."
  acceptance_criteria:
    - "DELETE do account link não chama o provedor nem apaga imported/staged/final transactions."
    - "A mesma conta externa pode ser vinculada novamente no mesmo workspace sem remoção manual no banco."
    - "A sessão automática é desativada no unlink e reativada/retargetada no rebind."
    - "Sync manual, cron e webhook ignoram tombstones."
    - "Disconnect da conexão tombstoneia todos os seus links."
    - "Transições repetidas e concorrentes são determinísticas."
  evidence_provenance:
    schema_version: 2
    head_commit: "2df8ab54fc01eec09aa81b7829d121d12e370e29"
    generated_plan_path: "docs/plans/2026-09-11-gitnexus-plan-open-finance-account-unlink.md"
    global_dirty_digest:
      algorithm: "sha256"
      canonicalization: "gitnexus-evidence-provenance-v2 NUL-framed UTF-8 records"
      value: "63c037087aa26119b63dea8235dfec8178dfa66def0338786c7948c5c2562018"
    cited_path_manifest:
      - path: "AGENTS.md"
        object_kind: {head: "regular", index: "regular", worktree: "regular", untracked: "absent"}
        state: "clean"
        rename_from: null
        rename_to: null
        head_digest: "sha256:aeaece6e19fed515e4dab049677ab556f6db81c5a73f632946e3231b498fdc03"
        index_digest: "sha256:aeaece6e19fed515e4dab049677ab556f6db81c5a73f632946e3231b498fdc03"
        worktree_digest: "sha256:aeaece6e19fed515e4dab049677ab556f6db81c5a73f632946e3231b498fdc03"
        untracked_digest: "absent"
      - path: "Makefile"
        object_kind: {head: "regular", index: "regular", worktree: "regular", untracked: "absent"}
        state: "clean"
        rename_from: null
        rename_to: null
        head_digest: "sha256:e95db87627a30f938b64aa6dde32b44b10bf7bb5f5933e30464c8d9ff92e9f9a"
        index_digest: "sha256:e95db87627a30f938b64aa6dde32b44b10bf7bb5f5933e30464c8d9ff92e9f9a"
        worktree_digest: "sha256:e95db87627a30f938b64aa6dde32b44b10bf7bb5f5933e30464c8d9ff92e9f9a"
        untracked_digest: "absent"
      - path: "cmd/mcp-server/tools/workspace_api.go"
        object_kind: {head: "regular", index: "regular", worktree: "regular", untracked: "absent"}
        state: "clean"
        rename_from: null
        rename_to: null
        head_digest: "sha256:93fbcecf5bd3c715903c24f74287206aff035bd6259a00f6ac1e7832dc949744"
        index_digest: "sha256:93fbcecf5bd3c715903c24f74287206aff035bd6259a00f6ac1e7832dc949744"
        worktree_digest: "sha256:93fbcecf5bd3c715903c24f74287206aff035bd6259a00f6ac1e7832dc949744"
        untracked_digest: "absent"
      - path: "internal/app/migrations.go"
        object_kind: {head: "regular", index: "regular", worktree: "regular", untracked: "absent"}
        state: "clean"
        rename_from: null
        rename_to: null
        head_digest: "sha256:a19d557f16ee81fea31fc9da8adc0cb684b925eb67b41f5ced935c368be77dbb"
        index_digest: "sha256:a19d557f16ee81fea31fc9da8adc0cb684b925eb67b41f5ced935c368be77dbb"
        worktree_digest: "sha256:a19d557f16ee81fea31fc9da8adc0cb684b925eb67b41f5ced935c368be77dbb"
        untracked_digest: "absent"
      - path: "internal/controller/http/v1/openfinance.go"
        object_kind: {head: "regular", index: "regular", worktree: "regular", untracked: "absent"}
        state: "clean"
        rename_from: null
        rename_to: null
        head_digest: "sha256:dcf2ebe0a9d5d8bd89e6cfd9cfcd8a46a62d64e72340e42d18707330f3398dc0"
        index_digest: "sha256:dcf2ebe0a9d5d8bd89e6cfd9cfcd8a46a62d64e72340e42d18707330f3398dc0"
        worktree_digest: "sha256:dcf2ebe0a9d5d8bd89e6cfd9cfcd8a46a62d64e72340e42d18707330f3398dc0"
        untracked_digest: "absent"
      - path: "internal/controller/http/v1/swagger_parity_scan_test.go"
        object_kind: {head: "regular", index: "regular", worktree: "regular", untracked: "absent"}
        state: "clean"
        rename_from: null
        rename_to: null
        head_digest: "sha256:41b261156f1ec55a2d7bff8f1123c9bf1ccbbeca8160bbf8b07e1147fb6397ab"
        index_digest: "sha256:41b261156f1ec55a2d7bff8f1123c9bf1ccbbeca8160bbf8b07e1147fb6397ab"
        worktree_digest: "sha256:41b261156f1ec55a2d7bff8f1123c9bf1ccbbeca8160bbf8b07e1147fb6397ab"
        untracked_digest: "absent"
      - path: "internal/controller/http/v1/swagger_parity_test.go"
        object_kind: {head: "regular", index: "regular", worktree: "regular", untracked: "absent"}
        state: "clean"
        rename_from: null
        rename_to: null
        head_digest: "sha256:78227251e3b1fabc98deea70d8bc735aeef565d26e04d13b8f6a1ec6bc663de5"
        index_digest: "sha256:78227251e3b1fabc98deea70d8bc735aeef565d26e04d13b8f6a1ec6bc663de5"
        worktree_digest: "sha256:78227251e3b1fabc98deea70d8bc735aeef565d26e04d13b8f6a1ec6bc663de5"
        untracked_digest: "absent"
      - path: "internal/entity/import.go"
        object_kind: {head: "regular", index: "regular", worktree: "regular", untracked: "absent"}
        state: "clean"
        rename_from: null
        rename_to: null
        head_digest: "sha256:d0e15a68d333d18e872537a7abc29fb94eb0cba3d3f6a440984a9e55695b6157"
        index_digest: "sha256:d0e15a68d333d18e872537a7abc29fb94eb0cba3d3f6a440984a9e55695b6157"
        worktree_digest: "sha256:d0e15a68d333d18e872537a7abc29fb94eb0cba3d3f6a440984a9e55695b6157"
        untracked_digest: "absent"
      - path: "internal/entity/openfinance.go"
        object_kind: {head: "regular", index: "regular", worktree: "regular", untracked: "absent"}
        state: "clean"
        rename_from: null
        rename_to: null
        head_digest: "sha256:b93985e0ca9dbc7101e45cf422bee70ec87f674d0388b0f8366d5214889beade"
        index_digest: "sha256:b93985e0ca9dbc7101e45cf422bee70ec87f674d0388b0f8366d5214889beade"
        worktree_digest: "sha256:b93985e0ca9dbc7101e45cf422bee70ec87f674d0388b0f8366d5214889beade"
        untracked_digest: "absent"
      - path: "internal/usecase/openfinance.go"
        object_kind: {head: "regular", index: "regular", worktree: "regular", untracked: "absent"}
        state: "unstaged"
        rename_from: null
        rename_to: null
        head_digest: "sha256:b4b85636daff4a43c587f118ada1f28227ad105d0d9ab07fdc434f539684cfb7"
        index_digest: "sha256:b4b85636daff4a43c587f118ada1f28227ad105d0d9ab07fdc434f539684cfb7"
        worktree_digest: "sha256:710f64a950fb6df74c0e37c4c54a9cefc1cff86057d4e221abbba1b8d6ce57ea"
        untracked_digest: "absent"
      - path: "internal/usecase/openfinance_test.go"
        object_kind: {head: "regular", index: "regular", worktree: "regular", untracked: "absent"}
        state: "unstaged"
        rename_from: null
        rename_to: null
        head_digest: "sha256:c9cfa4a2ac34423268f553ac3bd5b388041c809d4aa14c9ad7a3e9a099c00e2a"
        index_digest: "sha256:c9cfa4a2ac34423268f553ac3bd5b388041c809d4aa14c9ad7a3e9a099c00e2a"
        worktree_digest: "sha256:99669b941961c04bca889cfe2795678def4468e2ee765d02898e795facbedcbb"
        untracked_digest: "absent"
      - path: "internal/usecase/repo/import_commit_postgres_test.go"
        object_kind: {head: "regular", index: "regular", worktree: "regular", untracked: "absent"}
        state: "clean"
        rename_from: null
        rename_to: null
        head_digest: "sha256:57dc92275f374478cb546f09192e73833e845ecc7837c2ee420fa7854808a358"
        index_digest: "sha256:57dc92275f374478cb546f09192e73833e845ecc7837c2ee420fa7854808a358"
        worktree_digest: "sha256:57dc92275f374478cb546f09192e73833e845ecc7837c2ee420fa7854808a358"
        untracked_digest: "absent"
      - path: "internal/usecase/repo/import_postgres.go"
        object_kind: {head: "regular", index: "regular", worktree: "regular", untracked: "absent"}
        state: "clean"
        rename_from: null
        rename_to: null
        head_digest: "sha256:be5aaad2cbc9631f7f2c7176a90bf0d1f9ed22733c57e9e2f224c0c31fb33d59"
        index_digest: "sha256:be5aaad2cbc9631f7f2c7176a90bf0d1f9ed22733c57e9e2f224c0c31fb33d59"
        worktree_digest: "sha256:be5aaad2cbc9631f7f2c7176a90bf0d1f9ed22733c57e9e2f224c0c31fb33d59"
        untracked_digest: "absent"
      - path: "internal/usecase/repo/openfinance_postgres.go"
        object_kind: {head: "regular", index: "regular", worktree: "regular", untracked: "absent"}
        state: "unstaged"
        rename_from: null
        rename_to: null
        head_digest: "sha256:af83de1152aa51040c241e963d78ea5be166df37452cbefefcfe77709431fd11"
        index_digest: "sha256:af83de1152aa51040c241e963d78ea5be166df37452cbefefcfe77709431fd11"
        worktree_digest: "sha256:ff0bf14da8018f27ab11ce22dc5e2557835769cc7c75fa1e9e9a18dd1dfafb3b"
        untracked_digest: "absent"
  primary_symbols:
    - symbol: "OpenFinanceUseCaseImpl.LinkAccount"
      file: "internal/usecase/openfinance.go"
      lines: "225-288"
      role: "Decide create/rebind/conflict after provider and target validation"
    - symbol: "OpenFinanceUseCaseImpl.DisconnectConnection"
      file: "internal/usecase/openfinance.go"
      lines: "333-348"
      role: "Remote consent teardown distinct from local unlink"
    - symbol: "OpenFinanceRepo.UpsertAccountLink"
      file: "internal/usecase/repo/openfinance_postgres.go"
      lines: "94-120"
      role: "Atomic lifecycle transition for create/reactivate"
    - symbol: "OpenFinanceRepo.DisconnectConnection"
      file: "internal/usecase/repo/openfinance_postgres.go"
      lines: "30-59"
      role: "Atomic bulk unlink/session deactivation/connection soft-delete"
  related_symbols:
    - symbol: "OpenFinanceUseCaseImpl.processWebhookEvent"
      relationship: "CALLS GetAccountLinkByExternalID"
      relevance: "Must ignore unlinked accounts"
    - symbol: "OpenFinanceUseCaseImpl.SyncAllLinkedAccounts"
      relationship: "CALLS ListConnectionsForSync"
      relevance: "Cron must receive only active links"
    - symbol: "OpenFinanceUseCaseImpl.ListSyncedTransactions"
      relationship: "CALLS GetAccountLink/ListImportedTransactions"
      relevance: "Audit remains readable after unlink"
    - symbol: "ImportRepo.commitSession"
      relationship: "reads ImportSession target before materializing staged rows"
      relevance: "Pending rows follow the retargeted session"
  execution_path:
    - "Validate workspace, connection, provider account kind, and local target."
    - "Repository locks existing account link by provider/external ID."
    - "Active same-workspace link conflicts; tombstone same-workspace link is reactivated; foreign workspace is forbidden; absent link is created."
    - "Reactivation updates link and import-session target atomically while preserving IDs and review records."
    - "Local unlink locks the link, sets unlinked_at, and deactivates the session without provider call or deletion."
    - "Connection disconnect performs the same transition for every child link before soft-deleting the connection."
  pdg_constraints:
    - description: "Provider account/kind validation controls whether lifecycle resolution may run."
      affected_statements: ["internal/usecase/openfinance.go:247", "internal/usecase/openfinance.go:254", "internal/usecase/openfinance.go:257", "internal/usecase/openfinance.go:260"]
      implementation_consequence: "Do not open the bind transaction before remote and target validation."
    - description: "Existing-row lookup controls workspace rejection and update/create paths."
      affected_statements: ["internal/usecase/repo/openfinance_postgres.go:95", "internal/usecase/repo/openfinance_postgres.go:97", "internal/usecase/repo/openfinance_postgres.go:98", "internal/usecase/repo/openfinance_postgres.go:103"]
      implementation_consequence: "Lock and lifecycle decision must share one DB transaction."
    - description: "Disconnect orders session deactivation before connection soft-delete."
      affected_statements: ["internal/usecase/repo/openfinance_postgres.go:31", "internal/usecase/repo/openfinance_postgres.go:43", "internal/usecase/repo/openfinance_postgres.go:56"]
      implementation_consequence: "Bulk link tombstoning belongs in that same transaction."
  architectural_patterns:
    - pattern: "Workspace scoping at usecase/repository boundaries"
      example_location: "internal/usecase/openfinance.go:225-234"
      usage_guidance: "Every link transition requires workspace ownership and must not reveal foreign records."
    - pattern: "GORM transaction + row lock for commit-critical state"
      example_location: "internal/usecase/repo/import_postgres.go:411-430"
      usage_guidance: "Reuse clause.Locking Strength UPDATE for competing lifecycle transitions."
    - pattern: "Gin route plus Swagger annotation and generated parity"
      example_location: "internal/controller/http/v1/openfinance.go:84-104"
      usage_guidance: "Register, annotate, regenerate once, and run parity tests."
  files_to_modify:
    - file: "internal/entity/openfinance.go"
      symbols: ["OpenFinanceAccountLink"]
      intended_change: "Add explicit unlinked lifecycle state without GORM soft-delete semantics."
    - file: "internal/app/migrations.go"
      symbols: ["AutoMigrate"]
      intended_change: "Add schema and idempotent legacy backfill."
    - file: "internal/usecase/openfinance.go"
      symbols: ["OpenFinanceRepo", "OpenFinanceUseCase", "OpenFinanceUseCaseImpl.LinkAccount", "OpenFinanceUseCaseImpl.DisconnectConnection", "OpenFinanceUseCaseImpl.ListProviderAccounts", "OpenFinanceUseCaseImpl.SyncAccount", "OpenFinanceUseCaseImpl.RestoreSyncedTransaction", "OpenFinanceUseCaseImpl.processWebhookEvent"]
      intended_change: "Expose unlink, allow safe rebind, and guard mutable paths against tombstones."
    - file: "internal/usecase/repo/openfinance_postgres.go"
      symbols: ["OpenFinanceRepo.DisconnectConnection", "OpenFinanceRepo.UpsertAccountLink", "OpenFinanceRepo.ListConnections", "OpenFinanceRepo.ListConnectionsForSync"]
      intended_change: "Atomic lifecycle transitions and active-only operational queries."
    - file: "internal/controller/http/v1/openfinance.go"
      symbols: ["newOpenFinanceRoutes"]
      intended_change: "Register and document local account-link DELETE."
    - file: "cmd/mcp-server/tools/workspace_api.go"
      symbols: ["workspaceToolSpecs"]
      intended_change: "Expose unlink operation with destructive confirmation."
  tests:
    - file: "internal/usecase/openfinance_test.go"
      scenarios: ["active conflict", "same-workspace rebind", "foreign tombstone", "unlink without provider call", "detached sync/restore/webhook", "provider list availability"]
    - file: "internal/usecase/repo/openfinance_link_lifecycle_postgres_test.go"
      scenarios: ["atomic unlink", "idempotency", "rebind target/session", "audit preservation", "bulk disconnect", "concurrent unlink/rebind", "concurrent bind", "backfill"]
    - file: "internal/controller/http/v1/openfinance_test.go"
      scenarios: ["400 invalid UUID", "204 active/repeated", "workspace isolation"]
    - file: "internal/controller/http/v1/swagger_parity_test.go"
      scenarios: ["new route matches annotation and generated artifact"]
  verification_commands:
    - "make swagger"
    - "go test -count=1 ./internal/usecase ./internal/controller/http/v1"
    - "make test-integration"
    - "make check"
    - "GitNexus detect_changes(scope=all)"
  risks:
    - "Hard delete cascades through OpenFinanceImportedTransaction and destroys idempotency/audit."
    - "Session target must be updated atomically or pending transactions can commit to the old destination."
    - "Interface dispatch makes GitNexus impact counts lower bounds; confirm every interface implementation and stub after edits."
    - "The working tree already contains the 22h cron and empty-array response fix; preserve them."
  assumptions:
    - "Unlink is local-only; verify by asserting provider.DeleteConnection is never called."
    - "Already materialized financial transactions stay in their original account/card; verify no UPDATE/DELETE on ledger tables."
    - "Pending staged rows remain stored but inactive and are retargeted through ImportSession on rebind; verify commit destination in integration."
    - "Global account ownership remains workspace-exclusive; verify foreign-workspace tombstones stay forbidden."
  open_questions:
    - "Frontend button/modal wiring belongs to the separate frontend repository and is intentionally deferred from this backend plan."
    - "Automatic movement of already-imported ledger transactions between accounts/cards is explicitly out of scope and would need a separate audited transfer workflow."
  avoid:
    - "Do not hard-delete OpenFinanceAccountLink or its imported transaction records."
    - "Do not clear ImportSessionID or create a new session during same-workspace rebind."
    - "Do not call the provider when only unlinking a local account/card mapping."
    - "Do not broaden GetConnection semantics; its six direct dependents make that change unnecessarily risky."
    - "Do not overwrite the existing uncommitted cron and sync-response changes."
```

## 12. Assumptions and Open Questions

### Assumptions adopted by this plan

- [assumed] “Desvincular conta” é uma operação local e não revoga o consentimento bancário; “desconectar conexão” continua sendo a operação remota.
- [assumed] Transações financeiras já importadas permanecem na conta/cartão original. Corrigi-las automaticamente seria uma mutação financeira separada e arriscada.
- [assumed] Pendências permanecem armazenadas, porém invisíveis/inativas durante o unlink; no rebind, a sessão recebe o novo destino e as pendências voltam a ser revisáveis.
- [assumed] A mesma conta externa continua pertencendo a um único workspace. Transferência cross-workspace não está autorizada e conflita com a idempotência global atual.

### Explicitamente deferido

- UI do frontend: botão “Desvincular”, modal explicando preservação e consumo do novo DELETE; é outro repositório e estava reservado ao plano profundo.
- Movimento automático de transações finais já importadas para outra conta/cartão.
- Liberação/transferência da mesma conta externa entre workspaces.

## 13. Definition of Done

- `DELETE /open-finance/account-links/{id}` existe, é idempotente, workspace-safe e não chama o provedor.
- Link e sessão são tombstonados/desativados atomicamente; nenhum imported/staged/final record é apagado.
- Revincular a mesma conta externa no mesmo workspace reutiliza link e sessão, atualiza o destino e não retorna “already linked”.
- Transações terminais preservam status/idempotência; pendências passam a materializar no novo destino após rebind.
- Sync manual, cron e webhook não processam tombstones; listagem remota mostra a conta como disponível.
- Disconnect da conexão aplica unlink a todos os filhos na mesma transação.
- Backfill é idempotente e cobre links legados ligados a conexões soft-deleted.
- Swagger, artefatos OpenAPI e catálogo MCP refletem a rota.
- Testes unitários, HTTP, integração PostgreSQL, `make check` e `detect_changes(scope=all)` passam sem parcial/truncado; as mudanças locais preexistentes permanecem intactas.
