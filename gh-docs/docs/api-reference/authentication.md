# Autenticação

O FinTrack implementa um sistema de autenticação híbrido, suportando login nativo (E-mail/Senha) e OAuth 2.0 (ex: GitHub). O gerenciamento de sessão é feito primariamente via Cookies seguros (`HttpOnly`), garantindo maior segurança contra ataques XSS.

## Mecanismo de Sessão

O sistema utiliza o cookie `fintrack_token` para armazenar o JWT (JSON Web Token) de acesso.

- **Cookie Name:** `fintrack_token`
- **Atributos:** `HttpOnly`, `Path=/`, `SameSite=Lax`, `MaxAge=24h`
- **Segurança:** O cookie não é acessível via JavaScript no frontend.

## Endpoints

### 1. Registro (Nativo)

Cria uma nova conta de usuário no sistema.

**Método:** `POST`
**Rota:** `/auth/register`

**Request Body:**

```json
{
  "name": "João da Silva",
  "email": "joao@exemplo.com",
  "password": "senha-forte-123"
}
```

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `name` | string | Sim | Nome completo do usuário |
| `email` | string | Sim | Endereço de e-mail (deve ser único) |
| `password` | string | Sim | Senha (min. 8 caracteres) |

**Response (201 Created):**
*Sucesso (sem corpo de resposta)*

---

### 2. Login (Nativo)

Autentica um usuário existente e inicia a sessão definindo o cookie `fintrack_token`.

**Método:** `POST`
**Rota:** `/auth/login`

**Request Body:**

```json
{
  "email": "joao@exemplo.com",
  "password": "senha-forte-123"
}
```

**Response (200 OK):**

```json
{
  "message": "Login successful"
}
```

*Nota: O cookie `fintrack_token` é setado automaticamente no header `Set-Cookie` da resposta.*

---

### 3. Login com OAuth (Social)

Inicia o fluxo de autenticação com um provedor externo (ex: GitHub).

**Método:** `GET`
**Rota:** `/auth/{provider}/login`

**Parâmetros de Rota:**
- `provider`: Nome do provedor (ex: `github`)

**Query Params (Opcional):**
- `redirect_to`: Caminho do frontend para onde o usuário deve ser redirecionado após o login (ex: `/dashboard`). Salvo no cookie `fintrack_post_login_redirect`.

**Comportamento:**
1.  Gera um `state` aleatório para proteção CSRF e o salva no cookie `oauth_state`.
2.  Redireciona o navegador para a página de autorização do provedor (HTTP 307).

---

### 4. Callback OAuth

Endpoint de retorno do provedor OAuth. Processa o código de autorização e finaliza o login.

**Método:** `GET`
**Rota:** `/auth/{provider}/callback`

**Parâmetros:**
- `code`: Código de autorização retornado pelo provedor.
- `state`: Token de validação CSRF (deve coincidir com o cookie `oauth_state`).

**Comportamento:**
1.  Valida o `state`.
2.  Troca o `code` por um token de acesso junto ao provedor.
3.  Cria ou atualiza o usuário no banco de dados.
4.  Gera o JWT e define o cookie `fintrack_token`.
5.  Redireciona o usuário para o frontend (baseado no cookie `fintrack_post_login_redirect` ou `/`).

---

### 5. Validar Sessão

Verifica se o usuário está autenticado e retorna seus dados básicos e workspaces.

**Método:** `GET`
**Rota:** `/auth/validate`

**Header Obrigatório:**
- Cookie `fintrack_token` válido.

**Response (200 OK):**

```json
{
  "status": "valid",
  "user": {
    "id": "uuid-usuario",
    "name": "João da Silva",
    "email": "joao@exemplo.com"
  },
  "workspaces": [
    {
      "id": "uuid-workspace-1",
      "name": "Pessoal",
      "role": "admin",
      "created_at": "2024-01-01T10:00:00Z",
      "updated_at": "2024-01-01T10:00:00Z"
    },
    {
      "id": "uuid-workspace-2",
      "name": "Empresa",
      "role": "member",
      "created_at": "2024-01-05T14:30:00Z",
      "updated_at": "2024-01-05T14:30:00Z"
    }
  ]
}
```

**Response (401 Unauthorized):**
Se o token for inválido, expirado ou não estiver presente.

---

### 6. Logout

Encerra a sessão do usuário.

**Método:** `POST`
**Rota:** `/auth/logout`

**Comportamento:**
- Invalida o cookie `fintrack_token` (define MaxAge como -1).

**Response (200 OK):**
*Sucesso (sem corpo de resposta)*
