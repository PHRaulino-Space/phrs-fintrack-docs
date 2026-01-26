# Repositories

A camada de repositório (`internal/usecase/repo`) é responsável pela persistência de dados. Ela implementa as interfaces definidas na camada de UseCase.

## PostgreSQL

Usamos drivers padrão (`pgx` ou `lib/pq`) para conectar ao Postgres. Frequentemente usamos um Builder de SQL (como `Squirrel`) para construir queries dinâmicas de forma segura.

## Exemplo de Implementação

```go
func (r *AccountRepo) Create(ctx context.Context, a *entity.Account) error {
    sql, args, err := r.Builder.
        Insert("accounts").
        Columns("id", "workspace_id", "name", ...).
        Values(a.ID, a.WorkspaceID, a.Name, ...).
        ToSql()

    if err != nil {
        return fmt.Errorf("AccountRepo - Create - r.Builder: %w", err)
    }

    _, err = r.Pool.Exec(ctx, sql, args...)
    if err != nil {
        return fmt.Errorf("AccountRepo - Create - r.Pool.Exec: %w", err)
    }

    return nil
}
```
