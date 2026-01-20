# Relacionamentos

Entenda como as tabelas se conectam.

## Diagrama

Veja a seção [Arquitetura de Banco de Dados](../architecture/database.md) para o diagrama ER.

## Chaves Estrangeiras Principais

- **Workspace é a raiz**: Quase tudo (`accounts`, `categories`, `tags`) pertence a um `workspace_id`. Isso garante o isolamento multi-tenant.
- **Transação pertence a Conta**: `expenses.account_id` -> `accounts.id`.
- **Transação tem Categoria**: `expenses.category_id` -> `categories.id`.
- **Cartão vinculado a Conta**: `cards.account_id` -> `accounts.id`. Isso define de onde sai o dinheiro para pagar a fatura.
