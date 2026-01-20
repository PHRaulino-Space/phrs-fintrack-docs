---
sidebar_position: 3
---

# Accounts (Contas)

Endpoints para gerenciar contas bancarias e financeiras.

## Endpoints

| Metodo | Endpoint | Descricao |
|--------|----------|-----------|
| GET | `/accounts` | Listar contas do workspace |
| POST | `/accounts` | Criar nova conta |
| GET | `/accounts/:id` | Obter conta por ID |

## Listar Contas

```http
GET /api/v1/accounts
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
```

**Response (200 OK):**

```json
[
  {
    "id": "acc-123-456-789",
    "workspace_id": "ws-123-456",
    "name": "Nubank Conta Corrente",
    "type": "CHECKING",
    "initial_balance": 2500.00,
    "currency_code": "BRL",
    "is_active": true,
    "currency": {
      "code": "BRL",
      "name": "Brazilian Real",
      "symbol": "R$",
      "is_active": true
    },
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  },
  {
    "id": "acc-789-012-345",
    "workspace_id": "ws-123-456",
    "name": "Bradesco Poupanca",
    "type": "SAVINGS",
    "initial_balance": 10000.00,
    "currency_code": "BRL",
    "is_active": true,
    "currency": {
      "code": "BRL",
      "name": "Brazilian Real",
      "symbol": "R$",
      "is_active": true
    },
    "created_at": "2024-01-16T14:00:00Z",
    "updated_at": "2024-01-16T14:00:00Z"
  }
]
```

## Criar Conta

```http
POST /api/v1/accounts
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
Content-Type: application/json
```

**Request Body:**

```json
{
  "name": "Nubank Conta Corrente",
  "type": "CHECKING",
  "initial_balance": 2500.00,
  "currency_code": "BRL",
  "is_active": true
}
```

**Campos:**

| Campo | Tipo | Obrigatorio | Descricao |
|-------|------|-------------|-----------|
| `name` | string | Sim | Nome da conta (1-100 chars) |
| `type` | string | Sim | Tipo da conta (enum) |
| `initial_balance` | number | Nao | Saldo inicial (default: 0) |
| `currency_code` | string | Nao | Codigo da moeda (default: BRL) |
| `is_active` | boolean | Nao | Conta ativa (default: true) |

**Tipos de Conta:**

| Tipo | Descricao |
|------|-----------|
| `CHECKING` | Conta Corrente |
| `SAVINGS` | Poupanca |
| `WALLET` | Carteira Digital |
| `INVESTMENT` | Investimentos |
| `CRIPTO` | Exchange Crypto |
| `CRIPTOWALLET` | Carteira Crypto |

**Response (201 Created):**

```json
{
  "id": "acc-123-456-789",
  "workspace_id": "ws-123-456",
  "name": "Nubank Conta Corrente",
  "type": "CHECKING",
  "initial_balance": 2500.00,
  "currency_code": "BRL",
  "is_active": true,
  "currency": {
    "code": "BRL",
    "name": "Brazilian Real",
    "symbol": "R$",
    "is_active": true
  },
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

**Erros:**

| Status | Descricao |
|--------|-----------|
| 400 | Dados invalidos |
| 409 | Nome ja existe no workspace |

## Obter Conta

```http
GET /api/v1/accounts/:id
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
```

**Path Parameters:**

| Parametro | Tipo | Descricao |
|-----------|------|-----------|
| `id` | UUID | ID da conta |

**Response (200 OK):**

```json
{
  "id": "acc-123-456-789",
  "workspace_id": "ws-123-456",
  "name": "Nubank Conta Corrente",
  "type": "CHECKING",
  "initial_balance": 2500.00,
  "currency_code": "BRL",
  "is_active": true,
  "currency": {
    "code": "BRL",
    "name": "Brazilian Real",
    "symbol": "R$",
    "is_active": true
  },
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

## Modelo de Dados

### Account

```typescript
interface Account {
  id: string;              // UUID
  workspace_id: string;    // UUID
  name: string;            // 1-100 caracteres
  type: AccountType;       // Enum
  initial_balance: number; // Decimal 15,2
  currency_code: string;   // 3 caracteres (ISO 4217)
  is_active: boolean;
  currency?: Currency;     // Relacionamento
  deleted_at?: string;     // Soft delete
  created_at: string;      // ISO 8601
  updated_at: string;      // ISO 8601
}

type AccountType =
  | 'CHECKING'
  | 'SAVINGS'
  | 'WALLET'
  | 'INVESTMENT'
  | 'CRIPTO'
  | 'CRIPTOWALLET';
```

### Currency

```typescript
interface Currency {
  code: string;      // ISO 4217 (ex: BRL, USD)
  name: string;      // Nome completo
  symbol: string;    // Simbolo (ex: R$, $)
  is_active: boolean;
}
```

## Exemplos

### cURL - Listar

```bash
curl -X GET http://localhost:8080/api/v1/accounts \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..." \
  -H "X-Workspace-ID: ws-123-456"
```

### cURL - Criar

```bash
curl -X POST http://localhost:8080/api/v1/accounts \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..." \
  -H "X-Workspace-ID: ws-123-456" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Inter Conta Digital",
    "type": "CHECKING",
    "initial_balance": 500.00,
    "currency_code": "BRL"
  }'
```

### JavaScript

```javascript
// Listar contas
const { data: accounts } = await api.get('/accounts');

// Criar conta
const { data: newAccount } = await api.post('/accounts', {
  name: 'Binance',
  type: 'CRIPTO',
  initial_balance: 0,
  currency_code: 'USD'
});
```

## Calculo de Saldo

O saldo atual de uma conta e calculado como:

```
Saldo Atual = Saldo Inicial
            + SUM(Receitas)
            - SUM(Despesas)
            + SUM(Transferencias Recebidas)
            - SUM(Transferencias Enviadas)
            - SUM(Pagamentos de Cartao)
```

:::info
O saldo e calculado dinamicamente, nao e armazenado. Para obter o saldo atual, calcule baseado nas transacoes.
:::
