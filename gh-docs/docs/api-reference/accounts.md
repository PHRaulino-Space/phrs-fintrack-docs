# Accounts

Endpoints para gestão de contas bancárias e carteiras.

## `GET /accounts`

Lista todas as contas ativas do workspace atual.

**Header Obrigatório**: `X-Workspace-ID: <uuid>`

### Response (200 OK)

```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "workspace_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "name": "Nubank",
    "type": "CHECKING",
    "initial_balance": 1500.50,
    "currency_code": "BRL",
    "is_active": true,
    "created_at": "2023-10-01T10:00:00Z",
    "updated_at": "2023-10-01T10:00:00Z"
  }
]
```

## `POST /accounts`

Cria uma nova conta no workspace.

**Header Obrigatório**: `X-Workspace-ID: <uuid>`

### Request Body

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `name` | string | Sim | Nome da conta (ex: Nubank, Carteira) |
| `type` | string | Sim | `CHECKING`, `SAVINGS`, `WALLET`, `INVESTMENT`, `CRIPTO` |
| `initial_balance` | number | Sim | Saldo inicial da conta |
| `currency_code` | string | Sim | Código ISO da moeda (ex: BRL) |

```json
{
  "name": "Investimentos Rico",
  "type": "INVESTMENT",
  "initial_balance": 50000.00,
  "currency_code": "BRL"
}
```

### Response (201 Created)

Retorna o objeto `Account` criado (mesma estrutura do GET).

## `GET /accounts/{id}`

Obtém detalhes de uma conta específica.

**Parâmetros**: `id` (UUID no path).

## Definições de Tipo

### AccountType (Enum)
- `CHECKING`: Conta Corrente
- `SAVINGS`: Poupança
- `WALLET`: Dinheiro Físico
- `INVESTMENT`: Conta de Investimento
- `CRIPTO`: Corretora de Cripto
- `CRIPTOWALLET`: Wallet On-chain
