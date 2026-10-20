# Produto FinTrack: comportamento observado

Esta seção descreve **o código neste checkout**, não uma proposta de produto. Os exemplos monetários são fictícios. A revisão de 20/10/2026 conferiu os commits base backend `8e68227cc642bb60e90db5dba313000e7f45e798`, frontend `bd33f1c8a6e2de962d1bb1d9f2248fcc97bc46f4` e docs `9e35dbed4f5aa056d317d6a6697beeadc38a7c3c`, incluindo alterações locais de implementação descritas na matriz e nas lacunas. Fontes e testes prevalecem sobre um resultado histórico de check.

## Comece pelo fluxo

| Área | O que o usuário faz | Leitura técnica |
| --- | --- | --- |
| Acesso, membros, moedas, categorias, preferências e integrações MCP | Entra, escolhe workspace, administra o catálogo e o acesso | [Acesso, taxonomia e ferramentas](./access-categories-tools.md) |
| Contas e cartões | Configura contas, transferências, compras e faturas | [Contas e cartões](./accounts-cards.md) |
| Livro de transações e recorrências | Consulta lançamentos, agenda, paga e concilia | [Transações e recorrências](./transactions-recurring.md) |
| Importação e Open Finance | Revê linhas, confirma importação e sincroniza instituições | [Importações e Open Finance](./imports-open-finance.md) |
| Patrimônio | Cadastra bens, avaliações, financiamento e classifica gastos | [Patrimônio](./assets.md) |
| Investimentos e metas | Lança posições, acompanha valor e vincula metas | [Investimentos e metas](./investments-goals.md) |
| Planejamento, orçamentos e dashboard | Examina mês, projeções, realizado e indicadores | [Planejamento, orçamentos e dashboard](./planning-budgets-dashboard.md) |

Consulte o [mapa do domínio](./domain-map.md) para entender os efeitos entre áreas, a [matriz de cobertura](./coverage.md) para localizar fontes e testes, o [glossário](./glossary.md) para termos, e as [lacunas](./known-gaps.md) antes de interpretar projeções como saldos contábeis. Os contratos HTTP detalhados estão na [referência de API](../api-simple/index.md); as jornadas aqui explicam efeitos, datas, cálculo e limites que uma lista de endpoints não revela.

## Como ler números

Uma data civil como `2026-05-31` é um dia de calendário e uma competência como `2026-05` é um mês; timestamps de auditoria representam instantes. A moeda de uma conta, investimento ou meta não implica conversão automática. Sempre confira a seleção de status, conta, workspace, período e fonte de cada valor na página específica. Quantias dos exemplos usam duas casas decimais por clareza; o arredondamento efetivo é aquele indicado na implementação de cada operação.

## Escopo desta revisão

O inventário foi feito em `frontend/src/app/**/page.tsx`, `frontend/src/components/layout/data/sidebar-data.tsx`, `frontend/src/hooks`, `frontend/src/services`, `frontend/e2e`, `backend/internal/controller/http/v1/router.go` e handlers do mesmo diretório, `backend/internal/usecase`, `backend/internal/entity`, `backend/internal/infra/postgres/repository`, `backend/internal/infra/dbsetup` e testes adjacentes. A árvore canônica de edição é **`backend/docs`**; `frontend/docs` é outro checkout do mesmo repositório e recebeu as mesmas fontes/OpenAPI nesta atualização, sem commit nem mudança de ponteiros. Não houve consulta a dados financeiros reais.
