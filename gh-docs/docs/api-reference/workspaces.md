---
sidebar_position: 2
---

# Workspaces

Endpoints para gerenciar workspaces (contextos isolados de dados financeiros).

## Endpoints

| Metodo | Endpoint | Descricao |
|--------|----------|-----------|
| GET | `/workspaces` | Listar workspaces do usuario |
| POST | `/workspaces` | Criar novo workspace |
| GET | `/workspaces/:id` | Obter workspace por ID |

## Listar Workspaces

```http
GET /api/v1/workspaces
Authorization: Bearer {token}
```

**Response (200 OK):**

```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Financas Pessoais",
    "role": "ADMIN",
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  },
  {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "name": "Familia",
    "role": "MEMBER",
    "created_at": "2024-01-20T14:00:00Z",
    "updated_at": "2024-01-20T14:00:00Z"
  }
]
```

## Criar Workspace

```http
POST /api/v1/workspaces
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**

```json
{
  "name": "Empresa XYZ"
}
```

**Response (201 Created):**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440002",
  "name": "Empresa XYZ",
  "created_at": "2024-01-25T09:00:00Z",
  "updated_at": "2024-01-25T09:00:00Z"
}
```

**Notas:**
- O usuario que cria o workspace recebe automaticamente papel `ADMIN`
- O nome deve ter entre 1 e 100 caracteres

**Erros:**

| Status | Descricao |
|--------|-----------|
| 400 | Nome invalido ou ausente |
| 401 | Nao autenticado |

## Obter Workspace

```http
GET /api/v1/workspaces/:id
Authorization: Bearer {token}
```

**Path Parameters:**

| Parametro | Tipo | Descricao |
|-----------|------|-----------|
| `id` | UUID | ID do workspace |

**Response (200 OK):**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Financas Pessoais",
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

**Erros:**

| Status | Descricao |
|--------|-----------|
| 403 | Sem permissao para acessar |
| 404 | Workspace nao encontrado |

## Modelo de Dados

### Workspace

```typescript
interface Workspace {
  id: string;           // UUID
  name: string;         // 1-100 caracteres
  created_at: string;   // ISO 8601
  updated_at: string;   // ISO 8601
}
```

### WorkspaceWithRole

```typescript
interface WorkspaceWithRole extends Workspace {
  role: 'ADMIN' | 'MEMBER';
}
```

### WorkspaceMember

```typescript
interface WorkspaceMember {
  workspace_id: string;
  user_id: string;
  role: 'ADMIN' | 'MEMBER';
  created_at: string;
}
```

## Papeis e Permissoes

| Papel | Descricao | Permissoes |
|-------|-----------|------------|
| `ADMIN` | Administrador | Acesso total, pode convidar/remover membros |
| `MEMBER` | Membro | Pode criar/editar transacoes, sem acesso a configuracoes |

### Matriz de Permissoes

| Acao | ADMIN | MEMBER |
|------|-------|--------|
| Ver transacoes | X | X |
| Criar transacoes | X | X |
| Editar transacoes | X | X |
| Ver configuracoes | X | |
| Editar configuracoes | X | |
| Convidar membros | X | |
| Remover membros | X | |
| Deletar workspace | X | |

## Exemplos

### cURL - Listar

```bash
curl -X GET http://localhost:8080/api/v1/workspaces \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."
```

### cURL - Criar

```bash
curl -X POST http://localhost:8080/api/v1/workspaces \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{"name": "Meu Novo Workspace"}'
```

### JavaScript

```javascript
// Listar workspaces
const { data: workspaces } = await api.get('/workspaces');

// Criar workspace
const { data: newWorkspace } = await api.post('/workspaces', {
  name: 'Empresa ABC'
});

// Selecionar workspace para proximas requisicoes
api.defaults.headers['X-Workspace-ID'] = workspaces[0].id;
```

## Fluxo de Criacao

```mermaid
sequenceDiagram
    participant C as Cliente
    participant A as API
    participant DB as Database

    C->>A: POST /workspaces {name}
    A->>A: Validar autenticacao
    A->>A: Validar nome
    A->>DB: INSERT workspace
    DB-->>A: workspace
    A->>DB: INSERT workspace_member (ADMIN)
    DB-->>A: member
    A-->>C: 201 Created + workspace
```
