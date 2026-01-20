# Categories

Categorias para classificar transações.

## `GET /categories`

Lista todas as categorias do workspace.

## `POST /categories`

**Request Body:**

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `name` | string | Nome da categoria |
| `type` | string | `INCOME` ou `EXPENSE` |
| `icon` | string | Identificador do ícone (Lucide/FontAwesome) |
| `color` | string | Hex Code (ex: `#FF0000`) |

```json
{
  "name": "Moradia",
  "type": "EXPENSE",
  "icon": "home",
  "color": "#3b82f6"
}
```

## `POST /sub-categories`

Cria uma subcategoria vinculada a uma categoria pai.

**Request Body:**

```json
{
  "name": "Aluguel",
  "category_id": "uuid-moradia"
}
```
