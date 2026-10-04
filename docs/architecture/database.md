# Arquitetura de dados

PostgreSQL é a persistência do backend. Não há uma única tabela “transactions” como livro físico: receitas, despesas, transferências, compras/pagamentos de cartão, aportes e resgates têm estruturas próprias. A consulta agregada de transações é um modelo de leitura montado pelos repositórios. Sessões de importação e transações preparadas têm ciclo de vida diferente dos lançamentos efetivos.

O setup registra entidades com GORM em backend/internal/infra/dbsetup/migrations.go. Funções e gatilhos SQL de backend/internal/infra/dbsetup/setup.go calculam estado de staging, notificam mudanças para atualização em tempo real e impedem associação de categoria arquivada. Há ainda índices/restrições explicitamente instalados, como username único sem distinção de caixa e prioridade de metas não negativa. O [mapa de domínio](../product/domain-map.md) explica as relações; [schema](../database/schema.md) aponta as entidades relevantes.

Não interprete um dump histórico como estado atual de produção. Esta documentação foi construída a partir de código e testes, sem inspeção de dados ou execução de migrações.

Fontes: backend/internal/infra/dbsetup/setup.go e migrations.go; backend/internal/entity; backend/internal/infra/postgres/repository.
