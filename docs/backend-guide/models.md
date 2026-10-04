# Entidades

As entidades estão em backend/internal/entity. Estruturas como Account, Card/Invoice, Income/Expense/Transfer, ImportSession/StagedTransaction, Investment e Goal modelam persistência e resposta, com campos, tags GORM e relações específicas. Campos financeiros não devem ser inferidos de um exemplo resumido; consulte a struct atual e as validações no caso de uso/handler.

O setup GORM registra os modelos em backend/internal/infra/dbsetup/migrations.go. Funções e gatilhos adicionais ficam em setup.go. O [schema](../database/schema.md) e o [mapa de domínio](../product/domain-map.md) orientam a navegação.

Fontes: backend/internal/entity, backend/internal/infra/dbsetup/migrations.go.
