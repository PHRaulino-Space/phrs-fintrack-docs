# Tags

Tags para classificar e organizar transações de forma flexível.

## `GET /tags`

Lista todas as tags do workspace.

**Header Obrigatório**: `X-Workspace-ID: <uuid>`

**Response (200 OK):**
```json
[
  {
    "id": "uuid-tag-1",
    "name": "Viagem",
    "color": "#f59e0b",
    "is_active": true,
    "created_at": "2024-01-01T10:00:00Z"
  }
]
```

## `POST /tags`

Cria uma nova tag.

**Header Obrigatório**: `X-Workspace-ID: <uuid>`

**Request Body:**

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `name` | string | Sim | Nome da tag |
| `color` | string | Não | Hex Code (ex: `#FF0000`) |

```json
{
  "name": "Projeto X",
  "color": "#10b981"
}
```

**Response (201 Created):**
```json
{
  "id": "uuid-nova-tag",
  "name": "Projeto X",
  "color": "#10b981",
  "is_active": true
}
```

## `GET /tags/{id}`

Obtém detalhes de uma tag específica.

**Response (200 OK):**
```json
{
  "id": "uuid-tag",
  "name": "Projeto X",
  "color": "#10b981"
}
```

## `PUT /tags/{id}`

Atualiza uma tag.

**Request Body:**
```json
{
  "name": "Projeto Y",
  "color": "#3b82f6"
}
```

**Response (200 OK):**
```json
{
  "id": "uuid-tag",
  "name": "Projeto Y",
  "color": "#3b82f6"
}
```

## `DELETE /tags/{id}`

Exclui uma tag.

**Response:** `204 No Content`
