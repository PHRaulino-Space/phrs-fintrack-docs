# Import Sessions

Gerencia o ciclo de vida da importação de arquivos bancários (CSV).

## Fluxo
1. `POST /import-sessions`: Cria a sessão.
2. `POST /.../upload`: Envia o arquivo.
3. `GET /.../staged-transactions`: Revisa e corrige.
4. `POST /.../commit`: Efetiva no banco.

## `POST /import-sessions`

Cria uma "gaveta" para processar um arquivo.

**Request Body:**

```json
{
  "account_id": "uuid-conta",     // Para extratos de conta corrente
  "card_id": "uuid-cartao",       // Para faturas de cartão
  "billing_month": "2023-11",     // Obrigatório se for cartão
  "target_value": 0               // Opcional (valor de controle)
}
```

## `POST /import-sessions/{id}/upload`

Faz o upload do arquivo CSV.

- **Content-Type**: `multipart/form-data`
- **Field**: `file` (binary)

## `GET /import-sessions/{id}/staged-transactions`

Retorna as transações lidas do arquivo, já com sugestões de categoria da IA.

**Response (Parcial):**

```json
[
  {
    "id": "uuid-temp",
    "transaction_date": "2023-11-05",
    "amount": 50.00,
    "description": "UBER *VIAGEM",
    "type": "EXPENSE",
    "status": "PENDING",
    "data": {
      "suggested_category_id": "uuid-transporte",
      "confidence_score": 0.98
    }
  }
]
```

## `POST /import-sessions/{id}/commit`

Finaliza a sessão. Transforma todas as `StagedTransactions` com status `READY` em `Expense`/`Income` reais.
