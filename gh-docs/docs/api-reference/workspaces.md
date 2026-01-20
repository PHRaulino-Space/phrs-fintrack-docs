# Workspaces

Endpoints relacionados a Workspaces.

## `GET /workspaces`

Lista os workspaces do usuário.

- **Query Params**: `user_id` (UUID)

## `POST /workspaces`

Cria um novo workspace.

- **Payload**:
  ```json
  {
    "name": "My Workspace",
    "user_id": "uuid"
  }
  ```

## `GET /workspaces/{id}`

Detalhes de um workspace específico.
