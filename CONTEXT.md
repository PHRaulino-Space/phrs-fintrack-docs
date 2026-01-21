# Recurring Transactions Service - Documentação Técnica

## 1. Visão Geral

O **Recurring Transactions Service** é um serviço modular e independente desenvolvido em Go que gerencia transações recorrentes no sistema de finanças pessoais. Sua principal responsabilidade é calcular e auditar compromissos financeiros através de uma lógica de **reconciliação por contagem (FIFO - First-In, First-Out)**.

Este serviço funciona como um motor de inteligência que identifica pendências financeiras, permitindo que outras partes do sistema (como Import Session) possam reutilizar suas funcionalidades.

---

## 2. Arquitetura do Banco de Dados

### 2.1 Tabelas Principais de Recorrência

O serviço trabalha com quatro tabelas principais que definem as regras de geração dos "slots" (frequência, valor e contas envolvidas):

| Tabela | Descrição |
|--------|-----------|
| `recurring_expenses` | Define despesas recorrentes atreladas a uma conta bancária |
| `recurring_incomes` | Define receitas recorrentes atreladas a uma conta bancária |
| `recurring_transfers` | Define transferências automáticas entre duas contas (source e destination) |
| `recurring_card_transactions` | Define transações recorrentes que incidem sobre a fatura de um cartão de crédito |

### 2.2 Tabelas de Relacionamento (Tags)

Estas tabelas permitem que transações herdem etiquetas de classificação:

- `recurring_expenses_tags`
- `recurring_incomes_tags`
- `recurring_card_transactions_tags`

> **Nota**: A tabela `recurring_transfers` não possui tabela de tags associada no DDL atual.

### 2.3 Enum de Frequência

```sql
transaction_frequency: DAILY, WEEKLY, BIWEEKLY, MONTHLY, BIMONTHLY, QUARTERLY, YEARLY
```

---

## 3. Lógica Central: Reconciliação por Consumo de Slots (FIFO)

### 3.1 Conceito

A lógica de pendências **não é baseada em match de data exata**, mas sim em um balanço entre:
- **Quantidade de ocorrências projetadas** (slots esperados)
- **Quantidade de registros efetivados** (pagamentos realizados)

### 3.2 Processo de Reconciliação

#### Passo 1: Projeção de Slots
Gera uma lista ordenada de datas de vencimento esperadas:

- **Início**: `start_date` da recorrência
- **Fim**: Último dia do mês atual
- **Interrupção**: Se houver `end_date` anterior ao fim do mês atual
- **Resultado**: Lista ordenada de datas (ex: [Jan, Fev, Mar, Abr, Mai, Jun])

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

### 3.3 Exemplo Prático

**Cenário**: Recorrência mensal iniciada em Janeiro, consultada em Junho

**Timeline Projetada**: 
```
Jan, Fev, Mar, Abr, Mai, Jun (6 slots)
```

**Registros no Banco**:
- Janeiro: `PAID` (pago em janeiro)
- Fevereiro: `IGNORE` (usuário optou por não pagar)
- Março: `PAID` (pago em março)
- Abril: `PAID` (pago em março também - pagamento antecipado)

**Total Resolvido**: 4 registros

**Consumo de Slots**: Jan, Fev, Mar e Abr são preenchidos

**Resultado Pendente**: 
- Maio → **PENDING**
- Junho → **PENDING**

---

## 4. Status de Transações

### 4.1 Status Válidos

| Status | Descrição | Comportamento |
|--------|-----------|---------------|
| `PAID` | Transação efetivada/paga | Consome um slot da fila |
| `IGNORE` | Exceção/Pulado pelo usuário | Consome um slot mas sem valor financeiro |
| `PENDING` | Slot vazio | Não possui registro correspondente |
| `VALIDATING` | Em processo de validação | Não consome slot |

### 4.2 Regra do Status IGNORE

Registros com status `IGNORE`:
- Encerram a pendência de um slot tanto quanto um `PAID`
- Não representam valor financeiro no saldo
- Servem para quando o usuário decide que naquele período específico a recorrência não deve ser cobrada
- Não aparecem na lista de pendências atuais

---

## 5. Endpoints do Serviço

### 5.1 ListPendingByContext

**Descrição**: Lista todas as transações recorrentes pendentes para um contexto específico.

**Input**:
```go
{
  "account_id": "uuid",  // OU
  "card_id": "uuid"
}
```

**Ação**:
- Identifica todas as recorrências ativas para o contexto
- Calcula os slots vazios (gaps) até o fim do mês atual
- Retorna apenas as pendências

**Output**:
```json
[
  {
    "recurring_id": "uuid",
    "description": "Aluguel Apartamento",
    "amount": 1500.00,
    "reference_date": "2025-05-10",
    "reference_period": "Maio/2025",
    "category": {
      "id": "uuid",
      "name": "Moradia"
    },
    "sub_category": {
      "id": "uuid",
      "name": "Aluguel"
    },
    "tags": ["Essencial", "Fixo"]
  }
]
```

**Características**:
- Filtra por `workspace_id` para isolamento
- Retorna metadados completos (categoria, subcategoria, tags)
- Indica claramente qual período está pendente

---

### 5.2 GetRecurringProjection

**Descrição**: Retorna a timeline completa de uma recorrência específica com o status de cada slot.

**Input**:
```go
{
  "recurring_transaction_id": "uuid"
}
```

**Ação**:
- Gera a timeline completa desde `start_date` até o final do mês atual
- Para cada slot, verifica se foi consumido ou está pendente

**Output**:
```json
{
  "recurring_id": "uuid",
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

**Características**:
- Mostra histórico completo da recorrência
- Permite auditoria visual do cumprimento dos compromissos
- Identifica pagamentos antecipados (quando `paid_date` ≠ `expected_date`)

---

### 5.3 ListRecurringTransactions

**Descrição**: Lista todos os modelos de recorrência cadastrados sem cálculos de projeção.

**Input**:
```go
{
  "workspace_id": "uuid",
  "account_id": "uuid",      // Opcional
  "card_id": "uuid",         // Opcional
  "is_active": true          // Opcional
}
```

**Ação**:
- Retorna dados brutos das tabelas de configuração
- Sem processamento de slots ou pendências
- Apenas listagem dos modelos cadastrados

**Output**:
```json
[
  {
    "id": "uuid",
    "type": "expense",
    "description": "Netflix",
    "amount": 49.90,
    "account_id": "uuid",
    "category_id": "uuid",
    "sub_category_id": "uuid",
    "frequency": "MONTHLY",
    "start_date": "2024-01-15",
    "end_date": null,
    "is_active": true,
    "tags": ["Entretenimento", "Assinatura"]
  }
]
```

**Características**:
- Dados puros das tabelas
- Útil para interfaces de CRUD
- Sem lógica de negócio aplicada

---

## 6. Regras de Negócio

### 6.1 Motor de Projeção por Frequência

O serviço deve calcular o intervalo entre slots respeitando rigorosamente cada tipo de frequência:

| Frequência | Intervalo |
|------------|-----------|
| `DAILY` | 1 dia |
| `WEEKLY` | 7 dias |
| `BIWEEKLY` | 14 dias |
| `MONTHLY` | 1 mês (mesmo dia) |
| `BIMONTHLY` | 2 meses |
| `QUARTERLY` | 3 meses |
| `YEARLY` | 1 ano |

### 6.2 Limite de Projeção

- A projeção gera datas até **o último dia do mês atual**
- Se `end_date` estiver preenchida e for anterior ao final do mês atual, a projeção cessa naquela data
- Não projeta datas futuras além do mês corrente

### 6.3 Tratamento de Exceções

- Registros com status `IGNORE` devem "consumir" um slot exatamente como um `PAID`
- Serve para quando o usuário decide que naquele período específico a recorrência não deve ser cobrada
- Não aparecem como pendentes

### 6.4 Flexibilidade de Datas

**Característica fundamental**: O pagamento não precisa ocorrer na data exata do slot.

**Exemplo**:
- Slot esperado: 05/04/2025
- Pagamento realizado: 28/03/2025 (antecipado)
- **Resultado**: O slot de Abril é consumido mesmo assim

Isso resolve:
- ✅ Pagamentos antecipados
- ✅ Pagamentos atrasados
- ✅ Múltiplos pagamentos no mesmo dia
- ✅ Pagamentos em lote

---

## 7. Segurança e Performance

### 7.1 Isolamento de Dados

**Regra obrigatória**: Toda consulta SQL deve incluir filtro por `workspace_id`

```sql
WHERE workspace_id = $1
```

Isso garante que:
- Um usuário nunca acesse dados de outro workspace
- Suporte multi-tenant robusto
- Conformidade com privacidade de dados

### 7.2 Otimização de Queries

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

### 7.3 Filtros de Contexto

O serviço deve aceitar diferentes contextos de busca:

**Para Contas** (`account_id`):
- `recurring_incomes`
- `recurring_expenses`
- `recurring_transfers`

**Para Cartões** (`card_id`):
- `recurring_card_transactions`

---

## 8. Estrutura de Implementação em Go

### 8.1 Camadas Sugeridas

```
internal/
├── recurring/
│   ├── domain/
│   │   ├── entity.go          # Structs das recorrências
│   │   └── repository.go      # Interfaces do Repository
│   ├── usecase/
│   │   ├── list_pending.go    # Lógica de pendências
│   │   ├── get_projection.go  # Lógica de projeção
│   │   └── list_recurring.go  # Listagem simples
│   ├── repository/
│   │   └── postgres.go        # Implementação PostgreSQL
│   └── handler/
│       └── http.go            # Handlers HTTP
```

### 8.2 Interfaces Principais

```go
type RecurringRepository interface {
    ListByAccount(ctx context.Context, accountID uuid.UUID) ([]Recurring, error)
    ListByCard(ctx context.Context, cardID uuid.UUID) ([]Recurring, error)
    GetByID(ctx context.Context, id uuid.UUID) (*Recurring, error)
    CountResolvedSlots(ctx context.Context, recurringID uuid.UUID) (int, error)
}

type RecurringUseCase interface {
    ListPending(ctx context.Context, filter PendingFilter) ([]PendingRecurring, error)
    GetProjection(ctx context.Context, recurringID uuid.UUID) (*RecurringProjection, error)
    ListAll(ctx context.Context, filter RecurringFilter) ([]Recurring, error)
}
```

### 8.3 Structs de Retorno

```go
type PendingRecurring struct {
    RecurringID    uuid.UUID
    Description    string
    Amount         float64
    ReferenceDate  time.Time
    ReferencePeriod string // "Maio/2025"
    Category       Category
    SubCategory    SubCategory
    Tags           []string
}

type RecurringProjection struct {
    RecurringID   uuid.UUID
    Description   string
    Frequency     string
    StartDate     time.Time
    EndDate       *time.Time
    Slots         []ProjectionSlot
}

type ProjectionSlot struct {
    SlotNumber      int
    ExpectedDate    time.Time
    Status          string // PAID, IGNORE, PENDING
    PaidDate        *time.Time
    TransactionID   *uuid.UUID
}
```

---

## 9. Casos de Uso Detalhados

### 9.1 Cenário: Pagamento Antecipado

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

### 9.2 Cenário: Uso do Status IGNORE

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

### 9.3 Cenário: Recorrência com Término

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

## 10. Benefícios da Arquitetura

### 10.1 Separação de Responsabilidades
- ✅ Serviço independente e reutilizável
- ✅ Pode ser consumido por múltiplas partes do sistema
- ✅ Facilita testes unitários e de integração

### 10.2 Flexibilidade Financeira
- ✅ Suporta pagamentos antecipados
- ✅ Suporta pagamentos atrasados
- ✅ Permite exceções via status IGNORE
- ✅ Mantém histórico completo

### 10.3 Auditoria e Transparência
- ✅ Histórico completo de cada recorrência
- ✅ Identificação clara de pendências
- ✅ Rastreamento de pagamentos realizados
- ✅ Suporte a análise de fluxo de caixa

### 10.4 Escalabilidade
- ✅ Queries otimizadas (bulk processing)
- ✅ Isolamento por workspace
- ✅ Suporte a múltiplos tipos de recorrência
- ✅ Performance mantida com alto volume de dados

---

## 11. Próximos Passos

Esta documentação cobre o **Recurring Transactions Service** como um componente independente. O serviço está pronto para ser consumido por outras partes do sistema que necessitem:

- Listar pendências financeiras
- Auditar cumprimento de compromissos
- Projetar obrigações futuras
- Vincular transações importadas a recorrências

A integração com outros serviços (como Import Session) deve ser documentada separadamente, mantendo a modularidade e independência deste componente.