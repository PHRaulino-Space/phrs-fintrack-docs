---
sidebar_position: 1
---

# Autenticacao

A API do FinTrack usa JWT (JSON Web Tokens) para autenticacao. Os tokens sao enviados via cookies HttpOnly ou header Authorization.

## Visao Geral

```mermaid
sequenceDiagram
    participant C as Cliente
    participant A as API
    participant G as GitHub

    Note over C,A: Login Nativo
    C->>A: POST /auth/login
    A-->>C: Set-Cookie: fintrack_token

    Note over C,G: Login OAuth
    C->>A: GET /auth/github/login
    A-->>C: Redirect to GitHub
    C->>G: Authorize
    G->>A: Callback with code
    A-->>C: Set-Cookie + Redirect
```

## Endpoints

### Registro (Nativo)

```http
POST /api/v1/auth/register
```

**Request Body:**

```json
{
  "name": "Joao Silva",
  "email": "joao@exemplo.com",
  "password": "senha-segura-123"
}
```

**Response (201 Created):**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Joao Silva",
  "email": "joao@exemplo.com",
  "created_at": "2024-01-15T10:30:00Z"
}
```

**Erros:**

| Status | Descricao |
|--------|-----------|
| 400 | Email invalido ou senha fraca |
| 409 | Email ja cadastrado |

---

### Login (Nativo)

```http
POST /api/v1/auth/login
```

**Request Body:**

```json
{
  "email": "joao@exemplo.com",
  "password": "senha-segura-123"
}
```

**Response (200 OK):**

```json
{
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Joao Silva",
    "email": "joao@exemplo.com"
  },
  "workspaces": [
    {
      "id": "ws-123-456",
      "name": "Financas Pessoais",
      "role": "ADMIN"
    }
  ]
}
```

**Cookies Definidos:**

| Cookie | Duracao | Flags |
|--------|---------|-------|
| `fintrack_token` | 24h | HttpOnly, Secure, SameSite=Lax |

**Erros:**

| Status | Descricao |
|--------|-----------|
| 400 | Dados invalidos |
| 401 | Credenciais incorretas |

---

### Login OAuth (GitHub)

```http
GET /api/v1/auth/github/login?redirect_to=/dashboard
```

**Query Parameters:**

| Parametro | Tipo | Descricao |
|-----------|------|-----------|
| `redirect_to` | string | URL para redirecionar apos login |

**Response:** Redirect para GitHub OAuth

---

### Callback OAuth

```http
GET /api/v1/auth/github/callback?code=xxx&state=xxx
```

**Flow:**
1. GitHub redireciona com `code` e `state`
2. Backend troca code por access token
3. Busca informacoes do usuario no GitHub
4. Cria/atualiza usuario no banco
5. Define cookie JWT
6. Redireciona para `redirect_to` ou `/`

---

### Validar Sessao

```http
GET /api/v1/auth/validate
```

**Headers:**

```
Cookie: fintrack_token=eyJhbGciOiJIUzI1NiIs...
```

ou

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Response (200 OK):**

```json
{
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Joao Silva",
    "email": "joao@exemplo.com",
    "avatar_url": "https://avatars.githubusercontent.com/u/12345"
  },
  "workspaces": [
    {
      "id": "ws-123-456",
      "name": "Financas Pessoais",
      "slug": "financas-pessoais",
      "role": "ADMIN"
    },
    {
      "id": "ws-789-012",
      "name": "Familia",
      "slug": "familia",
      "role": "MEMBER"
    }
  ]
}
```

**Erros:**

| Status | Descricao |
|--------|-----------|
| 401 | Token invalido ou expirado |

---

### Logout

```http
POST /api/v1/auth/logout
```

**Response (200 OK):**

```json
{
  "message": "Logged out successfully"
}
```

**Efeito:** Remove cookie `fintrack_token`

## JWT Token

### Estrutura

```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "sub": "550e8400-e29b-41d4-a716-446655440000",
    "iat": 1705312200,
    "exp": 1705398600
  }
}
```

### Claims

| Claim | Descricao |
|-------|-----------|
| `sub` | ID do usuario (UUID) |
| `iat` | Timestamp de emissao |
| `exp` | Timestamp de expiracao (24h) |

## Headers de Autenticacao

### Cookie (Preferido)

```http
Cookie: fintrack_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Authorization Header

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## Workspace Header

Apos autenticado, todas as requisicoes devem incluir:

```http
X-Workspace-ID: 550e8400-e29b-41d4-a716-446655440000
```

**Erros:**

| Status | Descricao |
|--------|-----------|
| 400 | Header ausente ou UUID invalido |
| 403 | Usuario nao tem acesso ao workspace |

## Exemplos de Uso

### cURL - Login

```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -c cookies.txt \
  -d '{
    "email": "joao@exemplo.com",
    "password": "senha-segura-123"
  }'
```

### cURL - Request Autenticado

```bash
curl -X GET http://localhost:8080/api/v1/accounts \
  -b cookies.txt \
  -H "X-Workspace-ID: ws-123-456"
```

### JavaScript (Axios)

```javascript
import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:8080/api/v1',
  withCredentials: true, // Enviar cookies
});

// Login
const { data } = await api.post('/auth/login', {
  email: 'joao@exemplo.com',
  password: 'senha-segura-123',
});

// Request autenticado
const accounts = await api.get('/accounts', {
  headers: {
    'X-Workspace-ID': data.workspaces[0].id,
  },
});
```

### Python (Requests)

```python
import requests

session = requests.Session()

# Login
response = session.post(
    'http://localhost:8080/api/v1/auth/login',
    json={
        'email': 'joao@exemplo.com',
        'password': 'senha-segura-123'
    }
)
data = response.json()

# Request autenticado
accounts = session.get(
    'http://localhost:8080/api/v1/accounts',
    headers={
        'X-Workspace-ID': data['workspaces'][0]['id']
    }
)
```

## Seguranca

### Boas Praticas

1. **HTTPS**: Sempre use HTTPS em producao
2. **Senhas**: Minimo 7 caracteres
3. **Tokens**: Armazenados em cookies HttpOnly
4. **CORS**: Configurado para origem especifica

### Fluxo OAuth Seguro

1. State token previne CSRF
2. Cookies temporarios durante fluxo
3. Tokens trocados server-side
4. Redirect validado contra whitelist
