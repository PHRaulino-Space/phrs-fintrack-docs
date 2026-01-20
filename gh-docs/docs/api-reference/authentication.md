# Autenticação

O FinTrack utiliza autenticação baseada em tokens JWT (JSON Web Tokens).

## Fluxo

1.  O cliente envia credenciais (email/senha) para `/auth/login`.
2.  O servidor valida e retorna um `access_token`.
3.  O cliente deve armazenar este token (preferencialmente em HttpOnly Cookie ou memória, dependendo da implementação do frontend).
4.  Todas as requisições subsequentes devem incluir o cabeçalho:
    `Authorization: Bearer <token>`

## Endpoints

### Login

`POST /auth/login`

**Parâmetros:**
- `email` (string, required)
- `password` (string, required)

### Registro

`POST /auth/register`

**Parâmetros:**
- `name` (string, required)
- `email` (string, required)
- `password` (string, required)

### Refresh Token

*(Se implementado)*
`POST /auth/refresh`
Renova o token de acesso expirado.
