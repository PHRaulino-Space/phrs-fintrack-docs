# Cenários de Teste E2E

Esta página documenta os cenários de teste end-to-end do FinTrack, organizados por fluxo de usuário. Cada cenário descreve o estado inicial, as ações do usuário e o resultado esperado.

---

## 1. Onboarding e Autenticação

### 1.1 Registro de Novo Usuário (Nativo)

**Pré-condição:** Nenhum usuário cadastrado com o email de teste.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/auth/register` com name, email, password | 201 Created |
| 2 | Verificar que usuário foi criado no banco | Usuário existe com password_hash |
| 3 | Verificar criação automática de workspace | Workspace "Personal" criado com role "admin" |
| 4 | Tentar registrar mesmo email novamente | 409 Conflict |

### 1.2 Login Nativo

**Pré-condição:** Usuário registrado.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/auth/login` com email e password corretos | 200 OK + cookie `fintrack_token` |
| 2 | Verificar cookie `fintrack_token` | HttpOnly, Path=/, MaxAge=24h |
| 3 | POST `/auth/login` com password incorreto | 401 Unauthorized |
| 4 | POST `/auth/login` com email inexistente | 401 Unauthorized |

### 1.3 Login via GitHub OAuth

**Pré-condição:** GitHub OAuth configurado.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | GET `/auth/github/login` | Redirect 307 para GitHub |
| 2 | Verificar cookie `oauth_state` | Estado CSRF salvo |
| 3 | Callback com code válido | Redirect para frontend + cookie `fintrack_token` |
| 4 | Verificar usuário criado | external_id = "github:{id}" |
| 5 | Login novamente com mesmo GitHub | Mesmo usuário retornado (não duplica) |

### 1.4 Validação de Sessão

**Pré-condição:** Usuário logado.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | GET `/auth/validate` com cookie válido | 200 OK + dados do usuário + workspaces |
| 2 | GET `/auth/validate` sem cookie | 401 Unauthorized |
| 3 | GET `/auth/validate` com token expirado | 401 Unauthorized |

### 1.5 Logout

**Pré-condição:** Usuário logado.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/auth/logout` | 200 OK |
| 2 | Verificar cookie `fintrack_token` | MaxAge=-1 (invalidado) |
| 3 | GET `/auth/validate` após logout | 401 Unauthorized |

---

## 2. Gestão de Workspaces

### 2.1 Listar Workspaces do Usuário

**Pré-condição:** Usuário logado com pelo menos 1 workspace.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | GET `/workspaces` | 200 OK + lista de workspaces com roles |
| 2 | Verificar workspace padrão | "Personal" com role "admin" |

### 2.2 Criar Novo Workspace

**Pré-condição:** Usuário logado.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/workspaces` com name | 201 Created |
| 2 | Verificar membership | Usuário é admin do novo workspace |
| 3 | Listar workspaces | Novo workspace aparece na lista |

### 2.3 Acessar Workspace sem Permissão

**Pré-condição:** Dois usuários, cada um com seu workspace.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | Usuário A tenta acessar workspace do Usuário B | 403 Forbidden |
| 2 | Header `X-Workspace-ID` com UUID inválido | 400 Bad Request |
| 3 | Header `X-Workspace-ID` ausente em rota protegida | 400 Bad Request |

---

## 3. Configuração Inicial

### 3.1 Criar Contas Bancárias

**Pré-condição:** Usuário logado, workspace selecionado.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/accounts` com name="Nubank", type="CHECKING" | 201 Created |
| 2 | POST `/accounts` com name="Poupança", type="SAVINGS" | 201 Created |
| 3 | POST `/accounts` com name="Carteira", type="CASH" | 201 Created |
| 4 | GET `/accounts` | 200 OK + 3 contas listadas |
| 5 | POST `/accounts` com mesmo nome | 409 Conflict (nome único por workspace) |

### 3.2 Criar Cartões de Crédito

**Pré-condição:** Conta bancária criada (para pagamento da fatura).

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/cards` com name, closing_day, due_day, limit, account_id | 201 Created |
| 2 | Verificar campos | closing_day=15, due_day=22 |
| 3 | GET `/cards` | 200 OK + cartão listado |
| 4 | POST `/cards` com account_id inexistente | 400 Bad Request |

### 3.3 Criar Categorias

**Pré-condição:** Workspace selecionado.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/categories` com name="Moradia", type="EXPENSE" | 201 Created |
| 2 | POST `/categories` com name="Salário", type="INCOME" | 201 Created |
| 3 | POST `/categories` com name="Investimentos", type="TRANSFER" | 201 Created |
| 4 | GET `/categories` | 200 OK + 3 categorias |

### 3.4 Criar Subcategorias

**Pré-condição:** Categoria criada.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/subcategories` com name="Aluguel", category_id | 201 Created |
| 2 | POST `/subcategories` com name="Condomínio", category_id | 201 Created |
| 3 | GET `/subcategories` | 200 OK + subcategorias com categoria pai |
| 4 | POST `/subcategories` com category_id inexistente | 400 Bad Request |

### 3.5 Criar Tags

**Pré-condição:** Workspace selecionado.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/tags` com name="Essencial" | 201 Created |
| 2 | POST `/tags` com name="Supérfluo" | 201 Created |
| 3 | POST `/tags` com name="Fixo" | 201 Created |
| 4 | GET `/tags` | 200 OK + 3 tags |

### 3.6 Criar Investimentos

**Pré-condição:** Conta bancária criada.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/investments` com name="Tesouro Selic", type="FIXED_INCOME" | 201 Created |
| 2 | POST `/investments` com name="IVVB11", type="ETF" | 201 Created |
| 3 | GET `/investments` | 200 OK + 2 investimentos |

---

## 4. Transações de Conta

### 4.1 Criar Receita (Income)

**Pré-condição:** Conta e categoria de receita criadas.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/incomes` com description, amount, account_id, category_id, transaction_date | 201 Created |
| 2 | Verificar transaction_status | "PAID" por padrão |
| 3 | GET `/incomes?account_id={id}` | Receita listada |
| 4 | POST `/incomes` com amount negativo | 400 Bad Request |
| 5 | POST `/incomes` sem category_id | 400 Bad Request |

### 4.2 Criar Despesa (Expense)

**Pré-condição:** Conta e categoria de despesa criadas.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/expenses` com description, amount, account_id, category_id, transaction_date | 201 Created |
| 2 | Adicionar tags à despesa | Tags associadas |
| 3 | GET `/expenses?account_id={id}` | Despesa listada com tags |
| 4 | GET `/expenses?start_date=2024-01-01&end_date=2024-01-31` | Filtro por período funciona |

### 4.3 Criar Transferência (Transfer)

**Pré-condição:** Duas contas criadas.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/transfers` com source_account_id, destination_account_id, amount | 201 Created |
| 2 | Verificar campos | source e destination diferentes |
| 3 | POST `/transfers` com source = destination | 400 Bad Request |
| 4 | GET `/transfers?account_id={source_id}` | Transferência listada |

### 4.4 Atualizar Transação

**Pré-condição:** Transação criada.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | PUT `/expenses/{id}` com novo amount | 200 OK |
| 2 | Verificar updated_at | Timestamp atualizado |
| 3 | PUT `/expenses/{id}` com category_id inexistente | 400 Bad Request |

### 4.5 Deletar Transação

**Pré-condição:** Transação criada.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | DELETE `/expenses/{id}` | 204 No Content |
| 2 | GET `/expenses/{id}` | 404 Not Found |
| 3 | Verificar soft delete | deleted_at preenchido no banco |

---

## 5. Transações de Cartão

### 5.1 Criar Despesa de Cartão

**Pré-condição:** Cartão e categoria criados.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/card-transactions/expenses` com card_id, amount, billing_month, category_id | 201 Created |
| 2 | Verificar billing_month | Formato "YYYY-MM" |
| 3 | Verificar criação de invoice | Invoice criada automaticamente se não existir |
| 4 | GET invoice | Status "OPEN" |

### 5.2 Criar Estorno de Cartão (Chargeback)

**Pré-condição:** Despesa de cartão criada.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/card-transactions/chargebacks` com card_id, amount, billing_month | 201 Created |
| 2 | Verificar saldo da fatura | Reduzido pelo valor do estorno |

### 5.3 Pagar Fatura do Cartão

**Pré-condição:** Despesas de cartão criadas, conta para pagamento.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/card-transactions/payments` com card_id, account_id, amount, billing_month | 201 Created |
| 2 | Verificar saldo da conta | Reduzido pelo valor do pagamento |
| 3 | Pagar valor total da fatura | Invoice status muda para "PAID" |

### 5.4 Fluxo Completo de Fatura

**Pré-condição:** Cartão com closing_day=15, due_day=22.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | Criar despesa de cartão em 10/01 (billing_month=2024-01) | Despesa na fatura de janeiro |
| 2 | Criar despesa de cartão em 20/01 (billing_month=2024-02) | Despesa na fatura de fevereiro |
| 3 | Criar 3 despesas na fatura de janeiro | Total acumulado corretamente |
| 4 | Pagar fatura parcialmente | Status continua "OPEN" |
| 5 | Pagar restante da fatura | Status muda para "PAID" |

---

## 6. Investimentos

### 6.1 Aporte em Investimento

**Pré-condição:** Investimento e conta criados.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/investments/{id}/deposits` com amount, account_id, transaction_date | 201 Created |
| 2 | Verificar saldo da conta | Reduzido pelo valor do aporte |
| 3 | GET `/investments/{id}` | Valor investido atualizado |

### 6.2 Resgate de Investimento

**Pré-condição:** Investimento com saldo.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/investments/{id}/withdrawals` com amount, account_id, transaction_date | 201 Created |
| 2 | Verificar saldo da conta | Aumentado pelo valor do resgate |
| 3 | Resgatar mais que o saldo investido | 400 Bad Request |

---

## 7. Transações Recorrentes

### 7.1 Criar Despesa Recorrente

**Pré-condição:** Conta e categoria criadas.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/recurring` com type="expense", frequency="MONTHLY", start_date, amount | 201 Created |
| 2 | Verificar is_active | true por padrão |
| 3 | GET `/recurring?type=expense` | Recorrência listada |

### 7.2 Criar Receita Recorrente

**Pré-condição:** Conta e categoria criadas.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/recurring` com type="income", frequency="MONTHLY", start_date="2024-01-05" | 201 Created |
| 2 | Verificar projeção | Slots gerados até fim do mês atual |

### 7.3 Criar Transferência Recorrente

**Pré-condição:** Duas contas criadas.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/recurring` com type="transfer", source_account_id, destination_account_id | 201 Created |
| 2 | GET `/recurring/{id}/projection` | Timeline com slots |

### 7.4 Consultar Projeção de Recorrência

**Pré-condição:** Recorrência criada em janeiro, consultando em junho.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | GET `/recurring/{id}/projection` | 6 slots (Jan-Jun) |
| 2 | Verificar slots sem pagamento | Status "PENDING" |
| 3 | Criar transação vinculada à recorrência | Slot correspondente muda para "PAID" |

### 7.5 Listar Pendências por Contexto

**Pré-condição:** Múltiplas recorrências com slots pendentes.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | GET `/recurring/pending?account_id={id}` | Lista de slots pendentes da conta |
| 2 | GET `/recurring/pending?card_id={id}` | Lista de slots pendentes do cartão |
| 3 | Verificar dados | Inclui category, subcategory, tags |

### 7.6 Desativar Recorrência

**Pré-condição:** Recorrência ativa.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | PATCH `/recurring/{id}/deactivate` | 200 OK |
| 2 | Verificar is_active | false |
| 3 | GET `/recurring/pending` | Recorrência não aparece mais |

### 7.7 Reconciliação FIFO

**Pré-condição:** Recorrência mensal iniciada em janeiro.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | Criar 3 pagamentos em março (antecipados) | 3 transações criadas |
| 2 | GET `/recurring/{id}/projection` | Slots Jan, Fev, Mar marcados como PAID |
| 3 | Verificar slots Abr, Mai, Jun | Status "PENDING" |
| 4 | Criar transação com status "IGNORE" | Consome um slot sem valor financeiro |

---

## 8. Import Sessions

### 8.1 Criar Sessão de Importação (Conta)

**Pré-condição:** Conta criada.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/import-sessions` com account_id, billing_month, target_value | 201 Created |
| 2 | Verificar description | "{account_name} \| {billing_month}" |
| 3 | GET `/import-sessions/{id}` | Sessão com initial_balance calculado |

### 8.2 Criar Sessão de Importação (Cartão)

**Pré-condição:** Cartão criado.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/import-sessions` com card_id, billing_month | 201 Created |
| 2 | Verificar criação de invoice | Invoice criada se não existir |
| 3 | Verificar target_value | Soma dos card_payments do mês |
| 4 | Criar sessão com invoice status "PAID" | 400 Bad Request |

### 8.3 Upload de Transações (CSV)

**Pré-condição:** Sessão de importação criada.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/import-sessions/{id}/staged-transactions` com CSV | 201 Created |
| 2 | Verificar auto-detecção de tipo | amount >= 0 → INCOME, amount < 0 → EXPENSE |
| 3 | GET `/import-sessions/{id}` | Lista de staged_transactions |
| 4 | Verificar status inicial | "PENDING" (campos incompletos) |

### 8.4 Editar Staged Transaction

**Pré-condição:** Staged transaction criada.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | PATCH `/import-sessions/{session_id}/staged-transactions/{id}` com category_id | 200 OK |
| 2 | Verificar status | Muda para "READY" se todos campos preenchidos |
| 3 | Remover campo obrigatório | Status volta para "PENDING" |

### 8.5 Vincular a Recorrência

**Pré-condição:** Staged transaction e recorrência compatível.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/import-sessions/{id}/bind` com staged_transaction_id, recurring_transaction_id | 200 OK |
| 2 | Verificar staged_transaction | recurring_id preenchido |
| 3 | Verificar tipo | Herdado da recorrência |

### 8.6 Fluxo de Enriquecimento (AI)

**Pré-condição:** Staged transactions sem categoria.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/import-sessions/{id}/enrich` | 202 Accepted |
| 2 | Verificar status das transações | "PROCESSING" durante enriquecimento |
| 3 | Aguardar conclusão | Status muda para "READY" ou "PENDING" |
| 4 | Verificar categorias sugeridas | category_id preenchido pela AI |

### 8.7 Validação de Sessão

**Pré-condição:** Sessão com staged transactions.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | GET `/import-sessions/{id}` | Retorna stats: `{ready: N, total: M}` |
| 2 | Todas transações READY + context_value == target_value | status: "ok" |
| 3 | Alguma transação PENDING | status: "pending" |
| 4 | context_value != target_value | status: "pending" |

### 8.8 Commit da Sessão

**Pré-condição:** Sessão com status "ok".

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/import-sessions/{id}/commit` | 200 OK |
| 2 | Verificar transações criadas | Registros em incomes/expenses/etc |
| 3 | Verificar transaction_status | "VALIDATING" |
| 4 | Verificar staged_transactions | Deletadas após commit |
| 5 | Commit com transações PENDING | 400 Bad Request |

### 8.9 Fechar Sessão (Validar Transações)

**Pré-condição:** Sessão commitada, transações em "VALIDATING".

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | POST `/import-sessions/{id}/close` | 200 OK |
| 2 | Verificar transações | Status muda para "PAID" |
| 3 | Verificar invoice (contexto cartão) | Status muda para "PAID" |
| 4 | GET `/import-sessions/{id}` | 404 Not Found (sessão deletada) |

### 8.10 Deletar Staged Transaction

**Pré-condição:** Staged transaction criada.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | DELETE `/import-sessions/{session_id}/staged-transactions/{id}` | 204 No Content |
| 2 | GET sessão | Transação removida da lista |
| 3 | Verificar context_value | Recalculado sem a transação |

### 8.11 Cancelar Sessão

**Pré-condição:** Sessão criada com staged transactions.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | DELETE `/import-sessions/{id}` | 204 No Content |
| 2 | Verificar staged_transactions | Todas deletadas |
| 3 | GET `/import-sessions/{id}` | 404 Not Found |

---

## 9. Notificações em Tempo Real

### 9.1 Conectar ao Stream

**Pré-condição:** Usuário logado, workspace selecionado.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | GET `/notifications/stream` com headers corretos | Conexão SSE estabelecida |
| 2 | Verificar evento inicial | `connected` com workspace_id |
| 3 | Aguardar 10 segundos | Recebe evento `heartbeat` |

### 9.2 Receber Notificação de Criação

**Pré-condição:** Conectado ao stream.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | Em outra aba, criar uma conta | Evento `account.created` recebido |
| 2 | Verificar payload | Contém id da conta criada |
| 3 | Criar transação | Evento `transaction.created` com id e type |

### 9.3 Receber Notificação de Atualização

**Pré-condição:** Conectado ao stream, conta existente.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | Atualizar nome da conta | Evento `account.updated` recebido |
| 2 | Verificar payload | Contém id da conta |

### 9.4 Isolamento por Workspace

**Pré-condição:** Dois usuários em workspaces diferentes, ambos conectados.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | Usuário A cria conta no workspace A | Usuário A recebe notificação |
| 2 | Verificar Usuário B | NÃO recebe notificação |

### 9.5 Notificação de Import Session

**Pré-condição:** Conectado ao stream, sessão de importação criada.

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | Atualizar staged_transaction (status muda) | Evento `staged_tx.status_changed` |
| 2 | Verificar payload | Contém id, session_id, status |

---

## 10. Cenários de Erro e Edge Cases

### 10.1 Token Expirado Durante Operação

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | Iniciar operação com token válido | Operação em andamento |
| 2 | Token expira durante a operação | 401 na próxima request |
| 3 | Refresh token (se implementado) | Nova sessão estabelecida |

### 10.2 Workspace Deletado Durante Uso

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | Usuário trabalhando no workspace | Operações funcionando |
| 2 | Admin deleta o workspace | 403 nas próximas requests |

### 10.3 Concorrência em Import Session

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | Duas abas editando mesma staged_transaction | Última edição prevalece |
| 2 | Commit simultâneo | Apenas um commit sucede |

### 10.4 Valores Monetários

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | Criar transação com amount=0 | 400 Bad Request |
| 2 | Criar transação com muitas casas decimais | Arredondado para 2 casas |
| 3 | Criar transação com valor muito alto | Aceito (verificar limites) |

### 10.5 Datas Inválidas

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | Criar transação com data futura | Aceito (transação agendada) |
| 2 | Criar recorrência com end_date < start_date | 400 Bad Request |
| 3 | billing_month com formato inválido | 400 Bad Request |

### 10.6 Soft Delete e Recuperação

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | Deletar conta | Soft delete (deleted_at preenchido) |
| 2 | Listar contas | Conta não aparece |
| 3 | Criar transação na conta deletada | 400 Bad Request |

### 10.7 Limites e Paginação

| Passo | Ação | Resultado Esperado |
|-------|------|-------------------|
| 1 | Criar 1000 transações | Todas criadas |
| 2 | GET sem paginação | Retorna todas (ou limite padrão) |
| 3 | GET com limit=10&offset=0 | Retorna 10 primeiras |
| 4 | GET com limit=10&offset=990 | Retorna últimas 10 |

---

## 11. Fluxo Completo E2E

### 11.1 Jornada do Novo Usuário

Este cenário simula a jornada completa de um novo usuário.

| Fase | Ações | Verificações |
|------|-------|--------------|
| **Onboarding** | Registro → Login → Validar sessão | Usuário criado, workspace padrão existe |
| **Setup** | Criar 2 contas, 1 cartão, 5 categorias, 3 tags | Todas entidades criadas corretamente |
| **Primeira Receita** | Criar receita de salário | Saldo da conta atualizado |
| **Primeiras Despesas** | Criar 5 despesas variadas | Categorias e tags associadas |
| **Cartão** | Criar 3 despesas de cartão | Fatura gerada automaticamente |
| **Pagar Fatura** | Pagar fatura do cartão | Status da invoice = PAID |
| **Recorrência** | Criar aluguel recorrente | Projeção gerada |
| **Import** | Criar sessão, upload CSV, enrich, commit, close | Transações importadas e validadas |
| **Investimento** | Criar investimento, fazer aporte | Saldo investido atualizado |

### 11.2 Ciclo Mensal Completo

Este cenário simula um mês completo de uso.

| Semana | Ações | Verificações |
|--------|-------|--------------|
| **Semana 1** | Receber salário, pagar aluguel | Receita e despesa recorrente registradas |
| **Semana 2** | Despesas do dia-a-dia (mercado, transporte) | Múltiplas transações, tags aplicadas |
| **Semana 3** | Importar extrato bancário | Sessão criada, transações reconciliadas |
| **Semana 4** | Fechar fatura, fazer aporte em investimento | Fatura paga, investimento atualizado |
| **Fim do Mês** | Verificar pendências de recorrências | Todas recorrências do mês resolvidas |

---

## 12. Checklist de Regressão

### API Básica
- [ ] Autenticação (register, login, logout, validate)
- [ ] CRUD de contas
- [ ] CRUD de cartões
- [ ] CRUD de categorias e subcategorias
- [ ] CRUD de tags
- [ ] CRUD de investimentos

### Transações
- [ ] Criar/editar/deletar incomes
- [ ] Criar/editar/deletar expenses
- [ ] Criar/editar/deletar transfers
- [ ] Filtros por data e conta
- [ ] Associação de tags

### Cartão de Crédito
- [ ] Criar despesas de cartão
- [ ] Criar estornos
- [ ] Pagar fatura
- [ ] Ciclo completo de fatura

### Recorrências
- [ ] CRUD de recorrências (todos os tipos)
- [ ] Projeção de slots
- [ ] Listagem de pendências
- [ ] Reconciliação FIFO
- [ ] Desativação

### Import Sessions
- [ ] Criar sessão (conta e cartão)
- [ ] Upload de transações
- [ ] Edição de staged transactions
- [ ] Vinculação com recorrências
- [ ] Commit e close
- [ ] Cancelamento

### Notificações
- [ ] Conexão SSE
- [ ] Eventos de CRUD
- [ ] Isolamento por workspace
- [ ] Heartbeat
