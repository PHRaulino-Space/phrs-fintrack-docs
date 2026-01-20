# Models (Entities)

As entidades representam os objetos de domínio e estão em `internal/entity`. Elas são structs Go puras, frequentemente mapeadas para JSON.

## Exemplo: Account

```go
type Account struct {
    ID             uuid.UUID   `json:"id" db:"id"`
    WorkspaceID    uuid.UUID   `json:"workspace_id" db:"workspace_id"`
    Name           string      `json:"name" db:"name"`
    Type           AccountType `json:"type" db:"type"`
    InitialBalance float64     `json:"initial_balance" db:"initial_balance"`
    CurrencyCode   string      `json:"currency_code" db:"currency_code"`
    CreatedAt      time.Time   `json:"created_at" db:"created_at"`
    UpdatedAt      time.Time   `json:"updated_at" db:"updated_at"`
}
```

Observe as tags `json` (para API) e `db` (para queries SQL).
