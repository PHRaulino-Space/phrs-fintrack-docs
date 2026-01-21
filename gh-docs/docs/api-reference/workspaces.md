# Workspaces

Endpoints relacionados a Workspaces.

## `GET /workspaces`

Lista os workspaces do usuário.

- **Query Params**: `user_id` (UUID)

**Response (200 OK):**
```json
[
  {
    "id": "uuid-workspace-1",
    "name": "Pessoal",
    "created_at": "2024-01-01T10:00:00Z",
    "updated_at": "2024-01-01T10:00:00Z"
  },
  {
    "id": "uuid-workspace-2",
    "name": "Casa",
    "created_at": "2024-01-05T14:30:00Z",
    "updated_at": "2024-01-05T14:30:00Z"
  }
]
```

## `POST /workspaces`

Cria um novo workspace.

- **Payload**:
  ```json
  {
    "name": "My Workspace",
    "user_id": "uuid"
  }
  ```

**Response (201 Created):**
```json
{
  "id": "uuid-novo-workspace",
  "name": "My Workspace",
  "created_at": "2024-01-20T12:00:00Z",
  "updated_at": "2024-01-20T12:00:00Z"
}
```

## `GET /workspaces/{id}`

Detalhes de um workspace específico.

**Response (200 OK):**
```json
{
  "id": "uuid-workspace",
  "name": "Pessoal",
  "created_at": "2024-01-01T10:00:00Z",
  "updated_at": "2024-01-01T10:00:00Z",
  "members": [...],
  "accounts": [...]
}
```

## `PUT /workspaces/{id}`

Atualiza as informações de um workspace.

- **Payload**:
  ```json
  {
    "name": "Nome Atualizado"
  }
  ```

**Response (200 OK):**
```json
{
  "id": "uuid-workspace",
  "name": "Nome Atualizado",
  "created_at": "2024-01-01T10:00:00Z",
  "updated_at": "2024-01-21T09:00:00Z"
}
```

## `DELETE /workspaces/{id}`

Exclui um workspace e todos os dados associados.

**Response:** `204 No Content`
