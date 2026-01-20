# Referência da API

Esta seção documenta os endpoints da API REST do FinTrack.

**Base URL**: `http://localhost:8080/api/v1`

## Autenticação

A maioria dos endpoints requer autenticação via Bearer Token.

### Login

`POST /auth/login`

Autentica um usuário e retorna o token JWT.

**Body:**
```json
{
  "email": "user@example.com",
  "password": "securepassword"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "uuid",
    "name": "User Name",
    "email": "user@example.com"
  }
}
```

### Register

`POST /auth/register`

Cria um novo usuário.

**Body:**
```json
{
  "name": "User Name",
  "email": "user@example.com",
  "password": "securepassword"
}
```

## Workspaces

Gerenciamento de contextos financeiros. Cabeçalho `X-Workspace-ID` não é necessário aqui.

### Listar Workspaces

`GET /workspaces?user_id={uuid}`

### Criar Workspace

`POST /workspaces`

**Body:**
```json
{
  "name": "Personal Finances",
  "user_id": "uuid" // ID do criador
}
```

## Contas (Accounts)

Requer cabeçalho `X-Workspace-ID`.

### Listar Contas

`GET /accounts`

### Criar Conta

`POST /accounts`

**Body:**
```json
{
  "name": "Nubank",
  "type": "CHECKING", // CHECKING, SAVINGS, WALLET, INVESTMENT
  "initial_balance": 1000.00,
  "currency_code": "BRL"
}
```

## Transações (Expenses/Incomes)

Requer cabeçalho `X-Workspace-ID`.

### Listar Despesas

`GET /expenses?account_id={uuid}&start_date={date}&end_date={date}`

### Criar Despesa

`POST /expenses`

**Body:**
```json
{
  "description": "Lunch",
  "amount": 50.00,
  "transaction_date": "2023-10-27",
  "category_id": "uuid",
  "account_id": "uuid"
}
```
*Nota: Para receitas, use `/incomes` com estrutura similar.*

## Importação

Fluxo de upload e processamento.

### Criar Sessão

`POST /import-sessions`

**Body:**
```json
{
  "account_id": "uuid", // ou card_id
  "billing_month": "2023-10" // opcional, para cartões
}
```

### Upload de Arquivo

`POST /import-sessions/{id}/upload`

Enviar arquivo como `multipart/form-data` (campo `file`).

### Listar Transações em Staging

`GET /import-sessions/{id}/staged-transactions`

Retorna as transações lidas do arquivo com sugestões de categoria.

### Commit (Finalizar)

`POST /import-sessions/{id}/commit`

Efetiva as transações no banco de dados.
