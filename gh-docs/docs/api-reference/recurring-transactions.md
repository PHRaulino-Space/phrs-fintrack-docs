---
sidebar_position: 8
title: Recurring Transactions API
description: Referência completa da API de Transações Recorrentes
---

# Recurring Transactions API

API para gerenciamento e reconciliação de transações recorrentes no sistema de finanças pessoais.

## Visão Geral

O **Recurring Transactions Service** é um serviço modular que gerencia transações recorrentes através de uma lógica de **reconciliação por contagem (FIFO - First-In, First-Out)**. Sua principal responsabilidade é calcular e auditar compromissos financeiros, identificando pendências que podem ser consumidas por outras partes do sistema (como Import Session).

### Conceito Principal

A lógica de pendências **não é baseada em match de data exata**, mas sim em um balanço entre:
- **Quantidade de ocorrências projetadas** (slots esperados)
- **Quantidade de registros efetivados** (pagamentos realizados)

---

## Modelos de Dados

### Tabelas de Recorrência

| Tabela | Descrição | Contexto |
|--------|-----------|----------|
| `recurring_incomes` | Receitas recorrentes atreladas a uma conta | Conta |
| `recurring_expenses` | Despesas recorrentes atreladas a uma conta | Conta |
| `recurring_transfers` | Transferências automáticas entre duas contas | Conta |
| `recurring_card_transactions` | Transações recorrentes em fatura de cartão | Cartão |

### Tabelas de Tags

- `recurring_incomes_tags`
- `recurring_expenses_tags`
- `recurring_card_transactions_tags`

:::note
A tabela `recurring_transfers` não possui tabela de tags associada.
:::

### Enum: TransactionFrequency

```
DAILY | WEEKLY | BIWEEKLY | MONTHLY | BIMONTHLY | QUARTERLY | YEARLY
```

| Frequência | Intervalo |
|------------|-----------|
| `DAILY` | 1 dia |
| `WEEKLY` | 7 dias |
| `BIWEEKLY` | 14 dias |
| `MONTHLY` | 1 mês (mesmo dia) |
| `BIMONTHLY` | 2 meses |
| `QUARTERLY` | 3 meses |
| `YEARLY` | 1 ano |

---

## Entidades

### RecurringIncome

```json
{
  "id": "uuid",
  "description": "Salário",
  "amount": 5000.00,
  "account_id": "uuid",
  "category_id": "uuid",
  "subcategory_id": "uuid",
  "frequency": "MONTHLY",
  "start_date": "2024-01-05",
  "end_date": null,
  "is_active": true,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

### RecurringExpense

```json
{
  "id": "uuid",
  "description": "Aluguel",
  "amount": 1500.00,
  "account_id": "uuid",
  "category_id": "uuid",
  "subcategory_id": "uuid",
  "frequency": "MONTHLY",
  "start_date": "2024-01-10",
  "end_date": null,
  "is_active": true,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

### RecurringTransfer

```json
{
  "id": "uuid",
  "description": "Reserva Mensal",
  "amount": 500.00,
  "source_account_id": "uuid",
  "destination_account_id": "uuid",
  "frequency": "MONTHLY",
  "start_date": "2024-01-01",
  "end_date": null,
  "is_active": true,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

### RecurringCardTransaction

```json
{
  "id": "uuid",
  "description": "Netflix",
  "amount": 49.90,
  "card_id": "uuid",
  "category_id": "uuid",
  "subcategory_id": "uuid",
  "frequency": "MONTHLY",
  "start_date": "2024-01-15",
  "end_date": null,
  "is_active": true,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

---

## Lógica de Reconciliação (FIFO)

### Processo de Reconciliação

#### Passo 1: Projeção de Slots

Gera uma lista ordenada de datas de vencimento esperadas:

- **Início**: `start_date` da recorrência
- **Fim**: Último dia do mês atual
- **Interrupção**: Se houver `end_date` anterior ao fim do mês atual
- **Resultado**: Lista ordenada de datas

**Exemplo:**
```
Timeline: [Jan, Fev, Mar, Abr, Mai, Jun] (6 slots)
```

#### Passo 2: Contagem de Registros Resolvidos

Conta quantos registros existem nas tabelas finais vinculados ao ID da recorrência:

- **Filtro de Status**: Considera apenas `PAID` ou `IGNORE`
- **Flexibilidade de Data**: A `transaction_date` do registro final não precisa coincidir com o mês do slot
- **Regra FIFO**: Pagamentos "consomem" vagas na fila por ordem de chegada

#### Passo 3: Identificação de Gaps (Slots Vazios)

Algoritmo de cruzamento:

1. Pegue o número total de registros resolvidos (R registros)
2. Os primeiros R slots da Timeline são considerados "liquidados"
3. Todos os slots subsequentes (do slot R+1 em diante) são considerados **PENDENTES**

### Exemplo Prático

**Cenário**: Recorrência mensal iniciada em Janeiro, consultada em Junho

**Timeline Projetada**:
```
Jan, Fev, Mar, Abr, Mai, Jun (6 slots)
```

**Registros no Banco**:
| Mês | Status | Observação |
|-----|--------|------------|
| Janeiro | `PAID` | Pago em janeiro |
| Fevereiro | `IGNORE` | Usuário optou por não pagar |
| Março | `PAID` | Pago em março |
| Abril | `PAID` | Pago em março (antecipado) |

**Total Resolvido**: 4 registros

**Consumo de Slots**: Jan, Fev, Mar e Abr são preenchidos

**Resultado Pendente**:
- Maio → **PENDING**
- Junho → **PENDING**

---

## Status de Transações

| Status | Descrição | Comportamento |
|--------|-----------|---------------|
| `PAID` | Transação efetivada/paga | Consome um slot da fila |
| `IGNORE` | Exceção/Pulado pelo usuário | Consome um slot mas sem valor financeiro |
| `PENDING` | Slot vazio | Não possui registro correspondente |
| `VALIDATING` | Em processo de validação | Não consome slot |

### Regra do Status IGNORE

Registros com status `IGNORE`:
- Encerram a pendência de um slot tanto quanto um `PAID`
- Não representam valor financeiro no saldo
- Servem para quando o usuário decide que naquele período específico a recorrência não deve ser cobrada
- Não aparecem na lista de pendências atuais

---

## Endpoints

### Listar Pendências por Contexto

Lista todas as transações recorrentes pendentes para um contexto específico.

```http
GET /recurring/pending
```

**Query Parameters:**

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `account_id` | UUID | ID da conta (para contexto de conta) |
| `card_id` | UUID | ID do cartão (para contexto de cartão) |

:::info Regra de Contexto
Deve informar `account_id` **OU** `card_id` (não ambos).

**Para Contas** (`account_id`):
- `recurring_incomes`
- `recurring_expenses`
- `recurring_transfers`

**Para Cartões** (`card_id`):
- `recurring_card_transactions`
:::

**Response (200 OK):**

```json
[
  {
    "recurring_id": "uuid",
    "type": "expense",
    "description": "Aluguel Apartamento",
    "amount": 1500.00,
    "reference_date": "2025-05-10",
    "reference_period": "Maio/2025",
    "category": {
      "id": "uuid",
      "name": "Moradia"
    },
    "subcategory": {
      "id": "uuid",
      "name": "Aluguel"
    },
    "tags": ["Essencial", "Fixo"]
  }
]
```

**Comportamento:**
- Identifica todas as recorrências ativas para o contexto
- Calcula os slots vazios (gaps) até o fim do mês atual
- Retorna apenas as pendências
- Filtra por `workspace_id` para isolamento
- Retorna metadados completos (categoria, subcategoria, tags)

---

### Obter Projeção de Recorrência

Retorna a timeline completa de uma recorrência específica com o status de cada slot.

```http
GET /recurring/:id/projection
```

**Response (200 OK):**

```json
{
  "recurring_id": "uuid",
  "type": "expense",
  "description": "Internet Fibra",
  "frequency": "MONTHLY",
  "start_date": "2025-01-05",
  "end_date": null,
  "projection": [
    {
      "slot_number": 1,
      "expected_date": "2025-01-05",
      "status": "PAID",
      "paid_date": "2025-01-05",
      "transaction_id": "uuid"
    },
    {
      "slot_number": 2,
      "expected_date": "2025-02-05",
      "status": "IGNORE",
      "paid_date": null,
      "transaction_id": "uuid"
    },
    {
      "slot_number": 3,
      "expected_date": "2025-03-05",
      "status": "PAID",
      "paid_date": "2025-03-03",
      "transaction_id": "uuid"
    },
    {
      "slot_number": 4,
      "expected_date": "2025-04-05",
      "status": "PAID",
      "paid_date": "2025-03-03",
      "transaction_id": "uuid"
    },
    {
      "slot_number": 5,
      "expected_date": "2025-05-05",
      "status": "PENDING",
      "paid_date": null,
      "transaction_id": null
    },
    {
      "slot_number": 6,
      "expected_date": "2025-06-05",
      "status": "PENDING",
      "paid_date": null,
      "transaction_id": null
    }
  ]
}
```

**Características:**
- Mostra histórico completo da recorrência
- Permite auditoria visual do cumprimento dos compromissos
- Identifica pagamentos antecipados (quando `paid_date` ≠ `expected_date`)

---

### Listar Transações Recorrentes

Lista todos os modelos de recorrência cadastrados sem cálculos de projeção.

```http
GET /recurring
```

**Query Parameters:**

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `account_id` | UUID | Não | Filtrar por conta |
| `card_id` | UUID | Não | Filtrar por cartão |
| `is_active` | boolean | Não | Filtrar por status ativo |
| `type` | string | Não | Filtrar por tipo (`income`, `expense`, `transfer`, `card_transaction`) |

**Response (200 OK):**

```json
[
  {
    "id": "uuid",
    "type": "expense",
    "description": "Netflix",
    "amount": 49.90,
    "account_id": "uuid",
    "category_id": "uuid",
    "subcategory_id": "uuid",
    "frequency": "MONTHLY",
    "start_date": "2024-01-15",
    "end_date": null,
    "is_active": true,
    "tags": ["Entretenimento", "Assinatura"]
  }
]
```

**Características:**
- Dados puros das tabelas
- Útil para interfaces de CRUD
- Sem lógica de negócio aplicada

---

### Criar Recorrência

Cria uma nova transação recorrente.

```http
POST /recurring
```

**Request Body (Exemplo - Expense):**

```json
{
  "type": "expense",
  "description": "Academia Smart Fit",
  "amount": 89.90,
  "account_id": "uuid-conta",
  "category_id": "uuid-categoria",
  "subcategory_id": "uuid-subcategoria",
  "frequency": "MONTHLY",
  "start_date": "2024-01-05",
  "end_date": null,
  "is_active": true,
  "tag_ids": ["uuid-tag-1", "uuid-tag-2"]
}
```

**Request Body (Exemplo - Transfer):**

```json
{
  "type": "transfer",
  "description": "Reserva Emergência",
  "amount": 500.00,
  "source_account_id": "uuid-conta-origem",
  "destination_account_id": "uuid-conta-destino",
  "frequency": "MONTHLY",
  "start_date": "2024-01-01",
  "is_active": true
}
```

**Request Body (Exemplo - Card Transaction):**

```json
{
  "type": "card_transaction",
  "description": "Spotify Premium",
  "amount": 21.90,
  "card_id": "uuid-cartao",
  "category_id": "uuid-categoria",
  "subcategory_id": "uuid-subcategoria",
  "frequency": "MONTHLY",
  "start_date": "2024-01-10",
  "is_active": true,
  "tag_ids": ["uuid-tag-1"]
}
```

**Response (201 Created):** Objeto da recorrência criada

---

### Obter Recorrência

Retorna os detalhes de uma recorrência específica.

```http
GET /recurring/:id
```

**Response (200 OK):**

```json
{
  "id": "uuid",
  "type": "expense",
  "description": "Aluguel",
  "amount": 1500.00,
  "account_id": "uuid",
  "category": {
    "id": "uuid",
    "name": "Moradia"
  },
  "subcategory": {
    "id": "uuid",
    "name": "Aluguel"
  },
  "frequency": "MONTHLY",
  "start_date": "2024-01-10",
  "end_date": null,
  "is_active": true,
  "tags": [
    { "id": "uuid", "name": "Essencial" },
    { "id": "uuid", "name": "Fixo" }
  ],
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

---

### Atualizar Recorrência

Atualiza uma recorrência existente.

```http
PUT /recurring/:id
```

**Request Body:**

```json
{
  "description": "Aluguel Apartamento Centro",
  "amount": 1600.00,
  "category_id": "uuid-nova-categoria",
  "is_active": true
}
```

**Response (200 OK):** Objeto da recorrência atualizada

:::warning Atenção
Alterações em recorrências afetam apenas slots futuros. Registros já efetivados nas tabelas principais não são modificados.
:::

---

### Desativar Recorrência

Desativa uma recorrência sem excluí-la.

```http
PATCH /recurring/:id/deactivate
```

**Response (200 OK):**

```json
{
  "message": "Recurring transaction deactivated successfully"
}
```

:::tip Recomendação
Prefira desativar ao invés de excluir para manter histórico de auditoria.
:::

---

### Excluir Recorrência

Remove permanentemente uma recorrência.

```http
DELETE /recurring/:id
```

**Response:** `204 No Content`

:::danger Atenção
Esta ação é irreversível. Registros já efetivados nas tabelas principais não são afetados, mas perdem a referência à recorrência.
:::

---

## Regras de Negócio

### Limite de Projeção

- A projeção gera datas até **o último dia do mês atual**
- Se `end_date` estiver preenchida e for anterior ao final do mês atual, a projeção cessa naquela data
- Não projeta datas futuras além do mês corrente

### Flexibilidade de Datas

**Característica fundamental**: O pagamento não precisa ocorrer na data exata do slot.

**Exemplo**:
- Slot esperado: 05/04/2025
- Pagamento realizado: 28/03/2025 (antecipado)
- **Resultado**: O slot de Abril é consumido mesmo assim

Isso resolve:
- Pagamentos antecipados
- Pagamentos atrasados
- Múltiplos pagamentos no mesmo dia
- Pagamentos em lote

### Tratamento de Exceções

- Registros com status `IGNORE` devem "consumir" um slot exatamente como um `PAID`
- Serve para quando o usuário decide que naquele período específico a recorrência não deve ser cobrada
- Não aparecem como pendentes

---

## Casos de Uso

### Cenário 1: Pagamento Antecipado

**Situação**:
- Recorrência: Internet mensal, dia 10 de cada mês
- Usuário pagou as contas de Março, Abril e Maio no dia 28/02

**Comportamento do Sistema**:
```
Timeline: [10/03, 10/04, 10/05, 10/06]
Pagamentos no banco: 3 registros em 28/02 (todos PAID)

Resultado:
- Slot 10/03 → PAID (consumido pelo 1º pagamento de 28/02)
- Slot 10/04 → PAID (consumido pelo 2º pagamento de 28/02)
- Slot 10/05 → PAID (consumido pelo 3º pagamento de 28/02)
- Slot 10/06 → PENDING
```

### Cenário 2: Uso do Status IGNORE

**Situação**:
- Recorrência: Academia mensal, dia 5
- Em Março o usuário estava viajando e não usou a academia
- Conseguiu cancelar a cobrança daquele mês

**Comportamento do Sistema**:
```
Timeline: [05/01, 05/02, 05/03, 05/04, 05/05, 05/06]

Registros:
- Janeiro: PAID
- Fevereiro: PAID
- Março: IGNORE (criado manualmente pelo usuário)
- Abril: PAID
- Maio e Junho: Sem registro

Resultado ao consultar pendências em Junho:
- Maio → PENDING
- Junho → PENDING

(Março não aparece como pendente pois foi marcado como IGNORE)
```

### Cenário 3: Recorrência com Término

**Situação**:
- Recorrência: Financiamento em 12x, começou em 01/01/2025
- `end_date`: 01/12/2025

**Comportamento do Sistema**:
```
Consultando em Junho de 2025:
Timeline gerada: [01/01, 01/02, 01/03, 01/04, 01/05, 01/06]

Pagamentos: 4 registros PAID

Resultado:
- Slots 1 a 4 → PAID
- Slots 5 e 6 → PENDING

Consultando em Janeiro de 2026:
Timeline gerada: [01/01, 01/02, ..., 01/12]
(Não projeta além de 01/12 por causa do end_date)
```

---

## Segurança

### Isolamento de Dados

**Regra obrigatória**: Toda consulta SQL deve incluir filtro por `workspace_id`

```sql
WHERE workspace_id = $1
```

Isso garante que:
- Um usuário nunca acesse dados de outro workspace
- Suporte multi-tenant robusto
- Conformidade com privacidade de dados

### Otimização de Queries

**Problema**: Evitar N+1 queries ao verificar status de múltiplas recorrências

**Solução**: Bulk processing

```sql
-- Buscar todas as recorrências ativas
SELECT * FROM recurring_expenses
WHERE account_id = $1 AND workspace_id = $2 AND is_active = true;

-- Buscar todos os registros resolvidos de uma vez
SELECT recurring_expense_id, COUNT(*) as resolved_count
FROM expenses
WHERE recurring_expense_id = ANY($1)
  AND transaction_status IN ('PAID', 'IGNORE')
GROUP BY recurring_expense_id;
```

---

## Códigos de Erro

| Código | Descrição |
|--------|-----------|
| `400` | Request inválido (falta account_id ou card_id, parâmetros inválidos) |
| `401` | Não autorizado |
| `403` | Permissão insuficiente para o workspace |
| `404` | Recorrência não encontrada |
| `422` | Dados inválidos (ex: end_date antes de start_date) |
| `500` | Erro interno do servidor |
