# Investments

Endpoints relacionados a Investments (Investimentos).

## `GET /investments`

Lista os investimentos de uma conta.

- **Query Params**: `account_id` (UUID)

**Response (200 OK):**
```json
[
  {
    "id": "uuid-investment-1",
    "asset_name": "Tesouro Selic",
    "type": "TESOURO_DIRETO",
    "account_id": "uuid-account",
    "liquidity": "DAILY",
    "current_value": 1000.00
  }
]
```

## `POST /investments`

Cria um novo investimento.

- **Payload**:
  ```json
  {
    "asset_name": "Tesouro Selic",
    "type": "TESOURO_DIRETO",
    "account_id": "uuid-account",
    "liquidity": "DAILY",
    "index_type": "SELIC",
    "current_value": 1000.00
  }
  ```

**Response (201 Created):**
```json
{
  "id": "uuid-new-investment",
  "asset_name": "Tesouro Selic",
  "type": "TESOURO_DIRETO",
  "created_at": "2024-01-20T12:00:00Z"
}
```

## `GET /investments/{id}`

Detalhes de um investimento específico.

**Response (200 OK):**
```json
{
  "id": "uuid-investment",
  "asset_name": "Tesouro Selic",
  "type": "TESOURO_DIRETO",
  "account_id": "uuid-account",
  "liquidity": "DAILY",
  "current_value": 1000.00,
  "investment_deposits": [...],
  "investment_withdrawals": [...]
}
```

## `PUT /investments/{id}`

Atualiza as informações de um investimento.

- **Payload**:
  ```json
  {
    "asset_name": "Tesouro Selic 2029",
    "current_value": 1050.00
  }
  ```

**Response (200 OK):**
```json
{
  "id": "uuid-investment",
  "asset_name": "Tesouro Selic 2029",
  "current_value": 1050.00
}
```

## `DELETE /investments/{id}`

Exclui um investimento.

**Response:** `204 No Content`
