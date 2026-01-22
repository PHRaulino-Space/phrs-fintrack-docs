# API Keys

O FinTrack suporta autenticação via API Keys para acesso programático à API. Este método é ideal para integrações, scripts de automação e aplicações de terceiros que precisam acessar a API sem interação do usuário.

## Diferença entre JWT e API Key

| Característica | JWT | API Key |
|----------------|-----|---------|
| Duração | 24 horas | Longa duração (configurável) |
| Obtenção | Login interativo | Criada pelo usuário na aplicação |
| Uso principal | Frontend/Apps interativos | Scripts, automações, integrações |
| Workspace | Requer header `X-Workspace-ID` | Implícito na key |

## Formato da API Key

```
ftrack_<workspace_prefix>_<random_32_chars>
```

**Exemplo:** `ftrack_ws1a2b3c_k7x9m2p4q8r1s5t6u0v3w7y2z4a6b8c9`

**Componentes:**
- `ftrack_` - Prefixo fixo para identificação
- `<workspace_prefix>` - 8 caracteres do ID do workspace
- `<random>` - 32 caracteres aleatórios (base62)

:::warning Importante
A API Key completa é exibida **apenas uma vez** no momento da criação. Armazene-a em local seguro.
:::

## Autenticação com API Key

Para autenticar requisições usando API Key, inclua o header `X-API-Key`:

```bash
curl -X GET "https://api.fintrack.com/api/v1/expenses" \
  -H "X-API-Key: ftrack_ws1a2b3c_k7x9m2p4q8r1s5t6u0v3w7y2z4a6b8c9"
```

:::tip Workspace Implícito
Ao usar API Key, o header `X-Workspace-ID` **não é necessário**. O workspace está vinculado à própria key.
:::

---

## Endpoints

### 1. Criar API Key

Cria uma nova API Key para o workspace atual.

**Método:** `POST`
**Rota:** `/api-keys`
**Autenticação:** JWT (Cookie ou Bearer Token)

**Request Body:**

```json
{
  "name": "Script de importação",
  "expires_at": "2025-12-31T23:59:59Z"
}
```

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `name` | string | Sim | Nome descritivo da key (máx. 100 caracteres) |
| `expires_at` | string (ISO 8601) | Não | Data de expiração. Se omitido, a key não expira. |

**Response (201 Created):**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Script de importação",
  "key": "ftrack_ws1a2b3c_k7x9m2p4q8r1s5t6u0v3w7y2z4a6b8c9",
  "key_prefix": "ftrack_ws1a2b3c_k7x9",
  "expires_at": "2025-12-31T23:59:59Z",
  "created_at": "2024-01-15T10:30:00Z"
}
```

:::danger Atenção
O campo `key` contém a API Key completa e é retornado **apenas nesta resposta**. Copie e armazene em local seguro imediatamente.
:::

---

### 2. Listar API Keys

Retorna todas as API Keys do workspace atual.

**Método:** `GET`
**Rota:** `/api-keys`
**Autenticação:** JWT (Cookie ou Bearer Token)

**Response (200 OK):**

```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Script de importação",
    "key_prefix": "ftrack_ws1a2b3c_k7x9",
    "last_used_at": "2024-01-15T14:20:00Z",
    "expires_at": "2025-12-31T23:59:59Z",
    "created_at": "2024-01-15T10:30:00Z"
  },
  {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "name": "Integração Banco",
    "key_prefix": "ftrack_ws1a2b3c_m3n7",
    "last_used_at": null,
    "expires_at": null,
    "created_at": "2024-01-10T08:00:00Z"
  }
]
```

| Campo | Descrição |
|-------|-----------|
| `key_prefix` | Prefixo da key para identificação (a key completa não é retornada) |
| `last_used_at` | Última vez que a key foi usada para autenticação |
| `expires_at` | Data de expiração (`null` = nunca expira) |

---

### 3. Revogar API Key

Revoga (invalida) uma API Key existente. A key não poderá mais ser usada para autenticação.

**Método:** `DELETE`
**Rota:** `/api-keys/{id}`
**Autenticação:** JWT (Cookie ou Bearer Token)

**Parâmetros de Rota:**
- `id`: UUID da API Key a ser revogada

**Response (204 No Content):**
*Sucesso (sem corpo de resposta)*

**Response (404 Not Found):**
```json
{
  "error": "API key not found"
}
```

**Response (403 Forbidden):**
```json
{
  "error": "You don't have permission to revoke this API key"
}
```

---

## Códigos de Erro

| Código | Descrição |
|--------|-----------|
| `401 Unauthorized` | API Key inválida, expirada ou revogada |
| `403 Forbidden` | API Key não tem permissão para o recurso |
| `404 Not Found` | API Key não encontrada |

**Exemplo de erro:**

```json
{
  "error": "Invalid API key"
}
```

---

## Boas Práticas

### Segurança

1. **Nunca compartilhe** sua API Key em código público (GitHub, etc.)
2. **Use variáveis de ambiente** para armazenar a key em seus scripts
3. **Crie keys separadas** para cada integração/script
4. **Defina data de expiração** quando possível
5. **Revogue keys** que não estão mais em uso

### Exemplo com variável de ambiente

```bash
# Definir variável
export FINTRACK_API_KEY="ftrack_ws1a2b3c_k7x9m2p4q8r1s5t6u0v3w7y2z4a6b8c9"

# Usar no curl
curl -X GET "https://api.fintrack.com/api/v1/expenses" \
  -H "X-API-Key: $FINTRACK_API_KEY"
```

### Exemplo em Python

```python
import os
import requests

api_key = os.environ.get("FINTRACK_API_KEY")

response = requests.get(
    "https://api.fintrack.com/api/v1/expenses",
    headers={"X-API-Key": api_key}
)

print(response.json())
```

---

## Modelo de Dados

### ApiKey

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id` | UUID | Identificador único |
| `user_id` | UUID | Usuário que criou a key |
| `workspace_id` | UUID | Workspace vinculado à key |
| `name` | string | Nome descritivo |
| `key_hash` | string | Hash SHA-256 da key (interno) |
| `key_prefix` | string | Prefixo para identificação |
| `last_used_at` | timestamp | Última utilização |
| `expires_at` | timestamp | Data de expiração (opcional) |
| `revoked_at` | timestamp | Data de revogação (se revogada) |
| `created_at` | timestamp | Data de criação |
| `updated_at` | timestamp | Data de atualização |
