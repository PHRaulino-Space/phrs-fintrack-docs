# Categories & SubCategories

Categorias e subcategorias para classificar transações.

## Categories

### `GET /categories`

Lista todas as categorias do workspace.

**Header Obrigatório**: `X-Workspace-ID: <uuid>`

**Response (200 OK):**
```json
[
  {
    "id": "uuid-category-1",
    "name": "Moradia",
    "type": "EXPENSE",
    "color": "#3b82f6",
    "icon": "home",
    "created_at": "2024-01-01T10:00:00Z"
  }
]
```

### `POST /categories`

Cria uma nova categoria.

**Header Obrigatório**: `X-Workspace-ID: <uuid>`

**Request Body:**

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `name` | string | Sim | Nome da categoria |
| `type` | string | Sim | `INCOME` ou `EXPENSE` |
| `icon` | string | Sim | Identificador do ícone (Lucide/FontAwesome) |
| `color` | string | Sim | Hex Code (ex: `#FF0000`) |

```json
{
  "name": "Moradia",
  "type": "EXPENSE",
  "icon": "home",
  "color": "#3b82f6"
}
```

**Response (201 Created):**
```json
{
  "id": "uuid-nova-categoria",
  "name": "Moradia",
  "type": "EXPENSE",
  "icon": "home",
  "color": "#3b82f6"
}
```

### `GET /categories/{id}`

Obtém detalhes de uma categoria específica.

**Response (200 OK):**
```json
{
  "id": "uuid-category",
  "name": "Moradia",
  "sub_categories": [...]
}
```

### `PUT /categories/{id}`

Atualiza uma categoria.

**Request Body:**
```json
{
  "name": "Moradia e Contas",
  "color": "#1d4ed8"
}
```

**Response (200 OK):**
```json
{
  "id": "uuid-category",
  "name": "Moradia e Contas",
  "color": "#1d4ed8"
}
```

### `DELETE /categories/{id}`

Exclui uma categoria.

**Response:** `204 No Content`

---

## SubCategories

### `GET /sub-categories`

Lista todas as subcategorias do workspace.

**Header Obrigatório**: `X-Workspace-ID: <uuid>`

**Response (200 OK):**
```json
[
  {
    "id": "uuid-sub-1",
    "name": "Aluguel",
    "category_id": "uuid-category-pai"
  }
]
```

### `POST /sub-categories`

Cria uma subcategoria vinculada a uma categoria pai.

**Request Body:**

```json
{
  "name": "Aluguel",
  "category_id": "uuid-moradia"
}
```

**Response (201 Created):**
```json
{
  "id": "uuid-nova-sub",
  "name": "Aluguel",
  "category_id": "uuid-moradia"
}
```

### `GET /sub-categories/{id}`

Obtém detalhes de uma subcategoria.

### `PUT /sub-categories/{id}`

Atualiza uma subcategoria.

**Request Body:**
```json
{
  "name": "Aluguel Apartamento"
}
```

### `DELETE /sub-categories/{id}`

Exclui uma subcategoria.

**Response:** `204 No Content`
