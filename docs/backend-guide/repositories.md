# Repositórios PostgreSQL

As implementações concretas estão em backend/internal/infra/postgres/repository, e os contratos consumidos pelos casos de uso ficam em backend/internal/usecase. O projeto usa GORM e SQL específico quando uma consulta exige filtros, agregações, locks ou transações. Consulte o código de cada repositório para status, moeda e período: a consulta agregada de transações, por exemplo, combina tabelas físicas diferentes.

Operações que precisam ser atômicas, como commit de importação e confirmação de exclusão com dependências, usam transações e testes de falha. Não copie exemplos antigos de pgx/Squirrel; eles não representam a implementação atual.

Fontes: backend/internal/infra/postgres/repository/import_postgres.go, transaction_query_postgres.go, impact_confirm_postgres.go e backend/internal/usecase/interfaces.go.
