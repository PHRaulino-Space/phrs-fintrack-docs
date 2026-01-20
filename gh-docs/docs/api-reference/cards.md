# Cards

Endpoints para gestão de cartões de crédito.

## `GET /cards`

Lista cartões.

## `POST /cards`

Cria um cartão.

- **Payload**:
  ```json
  {
    "name": "Visa",
    "limit": 5000,
    "closing_day": 5,
    "due_day": 10,
    "account_id": "uuid-conta-pagamento"
  }
  ```
