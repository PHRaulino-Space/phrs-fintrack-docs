# Schema e entidades principais

O catálogo de modelos atual está em backend/internal/infra/dbsetup/migrations.go. Entidades financeiras incluem Account, Card, Invoice, Income, Expense, Transfer, Investment, InvestmentDeposit, InvestmentWithdrawal, InvestmentValueHistory, Goal, Budget, RecurringIncome/Expense/Transfer/CardTransaction, ImportSession e StagedTransaction. Há também WorkspaceMember/Invite, Category/SubCategory/Tag, Opportunity, Notification, ApiKey e entidades OpenFinance.

O livro consultado em /transactions é um modelo de leitura, não uma tabela transactions. Valores de investimento podem vir de fotografias; metas leem ativos vinculados; preparada em importação não é final. Para relações e semântica, use o [mapa de domínio](../product/domain-map.md), a [matriz de cobertura](../product/coverage.md) e as páginas de jornada.

Tipos PostgreSQL, funções, gatilhos e restrições explícitas são criados em backend/internal/infra/dbsetup/setup.go e migrations.go. Campos e índices concretos devem ser consultados nas structs de backend/internal/entity e nos repositórios antes de alteração de schema. Não houve introspecção de banco nesta revisão.
