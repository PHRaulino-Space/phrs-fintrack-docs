# Cards

Endpoints para gestão de cartões de crédito.

## `GET /cards`

Lista todos os cartões do workspace.

**Header Obrigatório**: `X-Workspace-ID: <uuid>`

### Response (200 OK)

```json
[
  {
    "id": "uuid-card-1",
    "name": "Nubank Roxinho",
    "closing_date": 25,
    "due_date": 5,
    "credit_limit": 10000.00,
    "workspace_id": "uuid-workspace"
  }
]
```

## `POST /cards`

Cria um novo cartão de crédito.

**Header Obrigatório**: `X-Workspace-ID: <uuid>`

### Request Body

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `name` | string | Sim | Nome do cartão |
| `closing_date` | integer | Sim | Dia de fechamento da fatura (1-31) |
| `due_date` | integer | Sim | Dia de vencimento da fatura (1-31) |
| `credit_limit` | number | Sim | Limite de crédito |

```json
{
  "name": "Visa Infinite",
  "closing_date": 20,
  "due_date": 5,
  "credit_limit": 50000.00
  "workspace_id": "uuid-workspace"
}
```

### Response (201 Created)

```json
{
  "id": "uuid-novo-card",
  "name": "Visa Infinite",
  "closing_date": 20,
  "due_date": 5,
  "credit_limit": 50000.00,
  "workspace_id": "uuid-workspace"
}
```

## `GET /cards/{id}`

Obtém detalhes de um cartão específico.

**Parâmetros**: `id` (UUID no path).

**Response (200 OK):**
```json
{
  "id": "uuid-card",
  "name": "Visa Infinite",
  "closing_date": 20,
  "due_date": 5,
  "credit_limit": 50000.00,
  "account_id": "uuid-conta-corrente"
}
```

## `PUT /cards/{id}`

Atualiza as informações de um cartão existente.

**Header Obrigatório**: `X-Workspace-ID: <uuid>`

### Request Body

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `name` | string | Não | Novo nome |
| `closing_date` | integer | Não | Novo dia de fechamento |
| `due_date` | integer | Não | Novo dia de vencimento |
| `credit_limit` | number | Não | Novo limite |

```json
{
  "name": "Visa Infinite (Black)",
  "credit_limit": 60000.00
}
```

**Response (200 OK):**
```json
{
  "id": "uuid-card",
  "name": "Visa Infinite (Black)",
  "closing_date": 20,
  "due_date": 5,
  "credit_limit": 60000.00,
  "workspace_id": "uuid-workspace"
}
```

## `DELETE /cards/{id}`

Exclui (ou inativa via soft-delete) um cartão.

**Response:** `204 No Content`
