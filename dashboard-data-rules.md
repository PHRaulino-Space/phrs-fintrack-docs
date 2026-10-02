# Dashboard - Regras e Dados por Aba

Documentação das regras de negócio, estruturas de dados e endpoints necessários para a tela de Dashboard do Fintrack.

---

## Visão Geral

O Dashboard possui **3 abas** e um **filtro global** de mês/ano que afeta todas elas. Os dados são carregados via dois endpoints chamados em paralelo (`Promise.allSettled`), permitindo que uma aba funcione mesmo se a outra falhar.

### Filtro Global

| Campo | Tipo     | Regra                                |
|-------|----------|--------------------------------------|
| month | `number` | 1–12, inicializa com o mês atual     |
| year  | `number` | 2024–2028, inicializa com o ano atual |

---

## Endpoints

| Endpoint                                        | Método | Parâmetros         | Retorno            |
|-------------------------------------------------|--------|--------------------|--------------------|
| `/dashboard/financial-summary?month={m}&year={y}` | GET    | `month`, `year`    | `FinancialSummary` |
| `/dashboard/cards-summary?month={m}&year={y}`     | GET    | `month`, `year`    | `CardsSummary`     |

- Ambos são chamados em paralelo via `Promise.allSettled`.
- Se **ambos** falharem, exibe mensagem de erro genérica.
- Se **apenas um** falhar, a aba correspondente fica indisponível enquanto a outra funciona normalmente.

---

## Aba 1: Resumo Financeiro

**Valor da tab:** `summary` | **Endpoint:** `financial-summary`

### 1.1 Summary Cards (6 cards)

| Card               | Campo fonte        | Cálculo / Regra                                                    | Formatação        |
|--------------------|--------------------|--------------------------------------------------------------------|-------------------|
| Saldo Atual        | `currentBalance`   | Valor direto do backend                                            | Moeda BRL         |
| Entradas           | `totalIncome`      | Valor direto do backend                                            | Moeda BRL         |
| Saídas             | `totalExpenses`    | Valor direto do backend                                            | Moeda BRL         |
| Resultado Líquido  | derivado           | `totalIncome - totalExpenses`                                      | Moeda BRL, verde se positivo, vermelho se negativo |
| Taxa de Poupança   | `savingsRate`      | `((totalIncome - totalExpenses) / totalIncome) * 100`              | Percentual (%)    |
| Total Investido    | `totalInvested`    | Valor total acumulado da carteira de investimentos                 | Moeda BRL         |

### 1.2 Gráfico de Fontes de Receita (IncomeSourceChart)

- **Tipo:** Barra horizontal
- **Dados:** Array `incomeByCategory`
- **Campos por item:**

| Campo    | Tipo     | Descrição                              |
|----------|----------|----------------------------------------|
| `name`   | `string` | Nome da fonte (Salário, Freelance, Investimentos, Outros) |
| `amount` | `number` | Valor recebido                         |
| `color`  | `string` | Cor hexadecimal para o gráfico         |

### 1.3 Gráfico de Uso do Dinheiro (MoneyUsageChart)

- **Tipo:** Radar (5 eixos)
- **Campos do `FinancialSummary` utilizados:**

| Eixo do Radar     | Campo fonte         | Descrição                              |
|--------------------|---------------------|----------------------------------------|
| Aportes            | `investedThisMonth` | Investimentos realizados no mês        |
| Cartões            | `cardExpenses`      | Despesas em cartões de crédito         |
| Não utilizado      | `unusedAmount`      | Saldo restante após todas as alocações |
| Não planejado      | `unplannedExpenses` | Despesas fora do orçamento             |
| Planejado          | `plannedExpenses`   | Despesas dentro do orçamento           |

### 1.4 Gráfico de Resultado Líquido por Mês (NetResultChart)

- **Tipo:** Barra vertical
- **Dados:** Array `monthlyTrend` (últimos 6 meses)
- **Campos por item:**

| Campo      | Tipo     | Descrição                        |
|------------|----------|----------------------------------|
| `month`    | `string` | Abreviação do mês (Jan, Fev...) |
| `income`   | `number` | Total de receitas no mês         |
| `expenses` | `number` | Total de despesas no mês         |
| `net`      | `number` | `income - expenses`              |

### 1.5 Tendência Receita vs Despesa (IncomeExpenseTrend)

- **Tipo:** Linha (2 séries)
- **Dados:** Mesmo array `monthlyTrend`
- **Séries:** `income` e `expenses` ao longo dos meses

### 1.6 Gráfico de Categorias de Despesa (CategoryChart)

- **Tipo:** Donut/Pizza
- **Dados:** Array `expensesByCategory`
- **Regra:** Top 5 categorias por valor; demais agrupadas como "Outros"
- **Campos por item:**

| Campo    | Tipo     | Descrição              |
|----------|----------|------------------------|
| `name`   | `string` | Nome da categoria      |
| `amount` | `number` | Valor gasto            |
| `color`  | `string` | Cor hexadecimal        |

---

## Aba 2: Gestão de Cartões

**Valor da tab:** `cards` | **Endpoint:** `cards-summary`

### 2.1 Visão Geral do Crédito (CreditOverview)

| Card                   | Campo fonte        | Cálculo / Regra                                                         |
|------------------------|--------------------|-------------------------------------------------|
| Limite Total           | `totalLimit`       | Soma dos limites de todos os cartões             |
| Limite Utilizado       | `totalUsed`        | Soma dos valores utilizados                      |
| Fatura Aberta          | `openInvoiceValue` | Valor da fatura do mês corrente                  |
| Comprometimento Total  | derivado           | `(totalUsed / totalLimit) * 100` com barra de progresso |

**Regra de cor do comprometimento:**

| Percentual     | Cor       |
|----------------|-----------|
| < 70%          | Verde     |
| >= 70%         | Vermelho  |

### 2.2 Histórico de Faturas (InvoiceHistory)

- **Tipo:** Tabela paginada (10 itens por página)
- **Dados:** Array `invoiceHistory` (últimos 6 meses)
- **Campos por item:**

| Campo      | Tipo     | Valores possíveis             | Descrição                  |
|------------|----------|-------------------------------|----------------------------|
| `month`    | `string` | Formato `YYYY-MM`            | Mês de referência          |
| `cardName` | `string` | —                             | Nome do cartão             |
| `amount`   | `number` | —                             | Valor da fatura            |
| `status`   | `string` | `"paid"`, `"pending"`, `"closed"` | Status da fatura      |

### 2.3 Lista de Cartões (CardsOverviewList)

- **Tipo:** Lista scrollável
- **Dados:** Array `cardsOverview`
- **Ordenação:** Por percentual de uso (maior primeiro)
- **Campos por item:**

| Campo         | Tipo      | Descrição                              |
|---------------|-----------|----------------------------------------|
| `id`          | `string`  | Identificador único                    |
| `name`        | `string`  | Nome do cartão                         |
| `limit`       | `number`  | Limite de crédito                      |
| `used`        | `number`  | Valor utilizado                        |
| `available`   | `number`  | Crédito disponível (`limit - used`)    |
| `closingDate` | `number`  | Dia do fechamento (1–31)               |
| `dueDate`     | `number`  | Dia do vencimento (1–31)               |
| `isActive`    | `boolean` | Cartão ativo ou inativo                |
| `automaticDebit` | `boolean` | Débito automático configurado no cartão; padrão falso |

A Gestão de Cartões mostra apenas cartões ativos. Limite total, limite usado,
fatura aberta, histórico, recorrências e categorias dessa aba consideram apenas
esses cartões. A aba Resumo Financeiro preserva suas próprias consultas.

**Regra de cor por uso:**

| Percentual     | Cor       |
|----------------|-----------|
| < 75%          | Verde     |
| >= 75% e < 90% | Laranja  |
| >= 90%         | Vermelho  |

### 2.4 Despesas por Categoria (CardCategoryBarChart + CardCategoryRanking)

- **Gráfico:** Barras verticais das dez maiores categorias e `Outros`, com nome e percentual sob cada barra; linha azul escura fina e pontilhada conecta suavemente as médias históricas específicas, sem marcadores. Em telas estreitas, a área do gráfico rola horizontalmente para preservar rótulos.
- **Ranking:** Mesmas categorias, com valores exatos
- **Dados:** Array `expensesByCategory` (do `CardsSummary`)
- **Campos por item:**

| Campo        | Tipo     | Descrição                              |
|--------------|----------|----------------------------------------|
| `category`   | `string` | Nome da categoria                      |
| `amount`     | `number` | Valor gasto                            |
| `color`      | `string` | Cor hexadecimal                        |
| `percentage` | `number` | Percentual normalizado (soma = 100%)   |
| `historicalAverage` | `number` | Média específica da categoria nos até três meses completos anteriores |

Para cada categoria, a média é a soma dos gastos nos meses disponíveis da
janela dividida pela quantidade desses meses (0, 1, 2 ou 3). Um mês com gastos
em outras categorias conta no divisor com zero para a categoria ausente.
`Outros` soma, em cada mês histórico, as categorias fora das dez maiores
do mês selecionado. Sem histórico, a média é zero. A linha de referência de
cada barra representa a média daquela categoria.

---

## Aba 3: Planejamento

**Valor da tab:** `planning` | **Endpoint:** `financial-summary` (usa dados de `budgets` e `pendingBills`)

### 3.1 Cards de Resumo (4 cards)

| Card             | Cálculo                                                                              | Cor                |
|------------------|--------------------------------------------------------------------------------------|--------------------|
| Total orçado     | `sum(budgets[].planned)` — se não houver budgets, usa `plannedExpenses`              | Padrão             |
| Total realizado  | `totalExpenses` (do `FinancialSummary`)                                              | Padrão             |
| Total pendente   | `sum(pendingBills.filter(status != "paid")[].amount)`                                 | Amarelo (amber-600)|
| Total quitado    | `sum(pendingBills.filter(status == "paid")[].amount)`                                 | Verde (emerald-600)|

### 3.2 Pendências do Período

- **Tipo:** Tabela paginada (10 itens por página)
- **Abas:** `Contas` mostra receitas/despesas recorrentes de conta; `Cartões`
  mostra faturas com ao menos uma despesa `CARD_EXPENSE` registrada,
  não ignorada e com `recurring_card_transaction_id`.
- A linha de fatura usa o subtotal dessas despesas recorrentes confirmadas.
  Compras avulsas, estornos, pagamentos, ajustes e projeções não entram nos
  detalhes, contagens ou subtotal.
- `Pagamento` da fatura reflete `cards.automatic_debit`; o pagamento das
  ocorrências de conta continua a refletir a configuração da recorrência.
- Todas as sete colunas aceitam ordenação crescente, decrescente e sem ordenação
  explícita. A ordenação opera sobre todos os itens da aba antes da paginação.

As linhas são montadas no frontend a partir de `/recurring/pending` e das
faturas e suas transações. O status visual depende da data alvo: vencido,
a vencer em até sete dias, ou pendente. O subtotal recorrente confirmado não é
o total integral nem o saldo a pagar da fatura.

### 3.3 Orçamentos

- **Tipo:** Lista scrollável (máx. 12 itens)
- **Dados:** Array `budgets`

#### Estrutura `Budget`

| Campo      | Tipo     | Descrição                    |
|------------|----------|------------------------------|
| `category` | `string` | Nome da categoria            |
| `planned`  | `number` | Valor planejado/orçado       |
| `actual`   | `number` | Valor realizado/gasto        |
| `color`    | `string` | Cor hexadecimal da categoria |

#### Regras de Exibição

| Elemento         | Cálculo                                          | Regra de cor                              |
|------------------|--------------------------------------------------|-------------------------------------------|
| Barra de progresso | `min(round((actual / planned) * 100), 100)`     | Verde se dentro do limite, vermelho se estourado |
| Badge de status  | `actual > planned` ?                             | "Estourado" (vermelho) / "Dentro do limite" (verde) |
| Valores          | `{actual} / {planned}`                           | Moeda BRL                                 |

---

## Interfaces TypeScript Completas

### FinancialSummary

```typescript
interface FinancialSummary {
  currentBalance: number
  totalIncome: number
  totalExpenses: number
  totalInvested: number
  investedThisMonth: number
  plannedExpenses: number
  unplannedExpenses: number
  goalsContribution: number
  cardExpenses: number
  unusedAmount: number
  savingsRate: number
  monthlyVariation: number
  expensesByCategory: ExpenseByCategory[]
  incomeByCategory: IncomeByCategory[]
  categoryComparison: CategoryComparison[]
  monthlyTrend: MonthlyTrend[]
  budgets: Budget[]
  month: number
  year: number
}
```

### CardsSummary

```typescript
interface CardsSummary {
  cardsOverview: CardOverview[]
  totalLimit: number
  totalUsed: number
  totalAvailable: number
  openInvoiceValue: number
  invoiceHistory: InvoiceHistory[]
  recurringExpenses: RecurringCardExpense[]
  expensesByCategory: CardCategoryExpense[]
  month: number
  year: number
}
```

### Tipos Auxiliares

```typescript
interface ExpenseByCategory {
  name: string
  amount: number
  color: string
}

interface IncomeByCategory {
  name: string
  amount: number
  color: string
}

interface CategoryComparison {
  category: string
  expense: number
  income: number
  color: string
}

interface MonthlyTrend {
  month: string
  income: number
  expenses: number
  net: number
}

interface Budget {
  category: string
  planned: number
  actual: number
  color: string
}

interface CardOverview {
  id: string
  name: string
  limit: number
  used: number
  available: number
  closingDate: number      // dia do mês (1-31)
  dueDate: number          // dia do mês (1-31)
  isActive: boolean
  automaticDebit: boolean
}

interface InvoiceHistory {
  month: string            // formato YYYY-MM
  cardName: string
  amount: number
  status: "paid" | "pending" | "closed"
}

interface RecurringCardExpense {
  id: string
  description: string
  amount: number
  cardName: string
  category: string
  status: "active" | "paused"
  nextDate: string
}

interface CardCategoryExpense {
  category: string
  amount: number
  color: string
  percentage: number
  historicalAverage: number
}
```

---

## Formatação Padrão

| Item               | Regra                                                            |
|--------------------|------------------------------------------------------------------|
| Valores monetários | `toLocaleString("pt-BR", { style: "currency", currency: "BRL" })` |
| Datas curtas       | `dd/MM` via `toLocaleDateString("pt-BR", { day: "2-digit", month: "2-digit" })` |
| Percentuais        | Arredondados com `Math.round`, exibidos com sufixo `%`          |
