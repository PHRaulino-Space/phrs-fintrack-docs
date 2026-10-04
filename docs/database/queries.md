# Consultas e modelos de leitura

A leitura /transactions combina receitas, despesas, transferências, aportes, resgates e pagamentos de cartão, com projeções opcionais. Não é uma consulta SELECT sobre uma tabela única transactions. O saldo por conta, a fatura, o orçamento e o dashboard usam filtros e regras diferentes; uma query manual genérica pode somar estados ou moedas incorretos.

Antes de analisar um número, use a [matriz de cobertura](../product/coverage.md) para localizar o repositório correto e veja as fórmulas nas páginas de domínio. Por exemplo, backend/internal/infra/postgres/repository/transaction_query_postgres.go constrói o extrato, budget_postgres.go trata orçamento e dashboard_postgres.go agrega indicadores. A documentação não inclui SQL solto sem filtros de workspace, exclusão lógica, status e período.
