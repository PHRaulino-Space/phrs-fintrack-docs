# Produto FinTrack: comportamento observado

Esta seção descreve **o código neste checkout**, não uma proposta de produto. Os exemplos monetários são fictícios. Os checkpoints usados na leitura são backend `cc862284112cd171e145895b2fb83fa576e5befc`, frontend `fbb75d06862c324b5e5a0fc2076498d634c6e627` e documentação-base `e3f78176a5ad8dfc355e28d659e415bf6af62060` (4 de outubro de 2026). Mudanças sem commit feitas depois desses pontos devem ser conferidas de novo antes de usar as fórmulas como contrato.

## Comece pelo fluxo

| Área | O que o usuário faz | Leitura técnica |
| --- | --- | --- |
| Acesso, membros, moedas, categorias, preferências e integrações MCP | Entra, escolhe workspace, administra o catálogo e o acesso | [Acesso, taxonomia e ferramentas](./access-categories-tools.md) |
| Contas e cartões | Configura contas, transferências, compras e faturas | [Contas e cartões](./accounts-cards.md) |
| Livro de transações e recorrências | Consulta lançamentos, agenda, paga e concilia | [Transações e recorrências](./transactions-recurring.md) |
| Importação e Open Finance | Revê linhas, confirma importação e sincroniza instituições | [Importações e Open Finance](./imports-open-finance.md) |
| Investimentos e metas | Lança posições, acompanha valor e vincula metas | [Investimentos e metas](./investments-goals.md) |
| Planejamento, orçamentos e dashboard | Examina mês, projeções, realizado e indicadores | [Planejamento, orçamentos e dashboard](./planning-budgets-dashboard.md) |

Consulte o [mapa do domínio](./domain-map.md) para entender os efeitos entre áreas, a [matriz de cobertura](./coverage.md) para localizar fontes e testes, o [glossário](./glossary.md) para termos, e as [lacunas](./known-gaps.md) antes de interpretar projeções como saldos contábeis. Os contratos HTTP detalhados estão na [referência de API](../api-simple/index.md); as jornadas aqui explicam efeitos, datas, cálculo e limites que uma lista de endpoints não revela.

## Como ler números

Uma data civil como `2026-05-31` é um dia de calendário e uma competência como `2026-05` é um mês; timestamps de auditoria representam instantes. A moeda de uma conta, investimento ou meta não implica conversão automática. Sempre confira a seleção de status, conta, workspace, período e fonte de cada valor na página específica. Quantias dos exemplos usam duas casas decimais por clareza; o arredondamento efetivo é aquele indicado na implementação de cada operação.

## Escopo desta revisão

O inventário foi feito em `frontend/src/app/**/page.tsx`, `frontend/src/components/layout/data/sidebar-data.tsx`, `frontend/src/hooks`, `frontend/src/services`, `frontend/e2e`, `backend/internal/controller/http/v1/router.go` e handlers do mesmo diretório, `backend/internal/usecase`, `backend/internal/entity`, `backend/internal/infra/postgres/repository`, `backend/internal/infra/dbsetup` e testes adjacentes. A árvore canônica de edição é **`backend/docs`**; `frontend/docs` é outro checkout limpo do mesmo repositório e commit, mantido intacto nesta tarefa. Não houve consulta a dados financeiros reais.
