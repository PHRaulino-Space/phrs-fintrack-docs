# Relações do domínio

Workspace é a fronteira de membros, contas, cartões, categorias, metas e orçamentos. Income/Expense/Transfer referem contas; compras e pagamentos referem cartão e fatura por competência. A conta de pagamento é escolhida no pagamento, **não** guardada como card.account_id. Investimento usa uma conta; metas podem vincular investimentos; sessões de importação preparam linhas antes de criar registros finais.

O [mapa de domínio](../product/domain-map.md) e as páginas de [contas e cartões](../product/accounts-cards.md), [investimentos e metas](../product/investments-goals.md) e [importação](../product/imports-open-finance.md) detalham efeitos e limites. Para chaves e tags GORM, consulte backend/internal/entity; para SQL e exclusão, backend/internal/infra/postgres/repository.

Esta página descreve relações do código, não uma introspecção de banco em execução.
