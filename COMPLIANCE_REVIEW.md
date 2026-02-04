# PHRS FinTrack — Documento de Análise para Compliance

**Versão do Documento:** 1.0
**Data de Elaboração:** 03 de Fevereiro de 2026
**Autor:** Pedro Henrique Raulino (Desenvolvedor e Proprietário)
**Classificação:** Confidencial — Uso Interno para Avaliação de Compliance

---

## Sumário

1. [Visão Geral do Projeto](#1-visão-geral-do-projeto)
2. [Objetivo e Propósito da Aplicação](#2-objetivo-e-propósito-da-aplicação)
3. [Stack Tecnológica](#3-stack-tecnológica)
4. [Arquitetura da Aplicação](#4-arquitetura-da-aplicação)
5. [Funcionalidades Detalhadas](#5-funcionalidades-detalhadas)
   - 5.1 [Autenticação e Registro de Usuários](#51-autenticação-e-registro-de-usuários)
   - 5.2 [Dashboard Financeiro](#52-dashboard-financeiro)
   - 5.3 [Gestão de Contas Bancárias](#53-gestão-de-contas-bancárias)
   - 5.4 [Gestão de Cartões de Crédito](#54-gestão-de-cartões-de-crédito)
   - 5.5 [Gestão de Categorias e Tags](#55-gestão-de-categorias-e-tags)
   - 5.6 [Gestão de Transações](#56-gestão-de-transações)
   - 5.7 [Importação de Dados (CSV)](#57-importação-de-dados-csv)
   - 5.8 [Orçamentos (Budgets)](#58-orçamentos-budgets)
   - 5.9 [Investimentos e Portfólio](#59-investimentos-e-portfólio)
   - 5.10 [Metas Financeiras (Goals)](#510-metas-financeiras-goals)
   - 5.11 [Transações Recorrentes](#511-transações-recorrentes)
   - 5.12 [Notificações](#512-notificações)
   - 5.13 [Configurações do Usuário](#513-configurações-do-usuário)
   - 5.14 [Workspaces](#514-workspaces)
6. [Segurança da Aplicação](#6-segurança-da-aplicação)
7. [Tratamento e Proteção de Dados](#7-tratamento-e-proteção-de-dados)
8. [Integrações Externas e APIs](#8-integrações-externas-e-apis)
9. [Infraestrutura e Dependências](#9-infraestrutura-e-dependências)
10. [Análise de Riscos e Mitigações](#10-análise-de-riscos-e-mitigações)
11. [Conformidade Regulatória](#11-conformidade-regulatória)
12. [Declarações e Esclarecimentos Finais](#12-declarações-e-esclarecimentos-finais)
13. [Anexos](#13-anexos)

---

## 1. Visão Geral do Projeto

| Campo | Descrição |
|---|---|
| **Nome da Aplicação** | PHRS FinTrack |
| **Tipo** | Aplicação Web (Single Page Application) |
| **Versão** | 1.0.0 |
| **Licença** | Privada (`"private": true`) |
| **Repositório** | GitHub — repositório privado |
| **Natureza** | Ferramenta pessoal de gestão financeira |
| **Público-Alvo** | Pessoas físicas que desejam organizar suas finanças pessoais |
| **Modelo de Negócio** | Gratuito / sem monetização definida |
| **Relação com o Itaú** | Nenhuma — projeto pessoal do colaborador, sem vínculo institucional |

O **PHRS FinTrack** é uma aplicação web de gestão financeira pessoal que permite aos usuários registrar, categorizar e acompanhar suas receitas, despesas, investimentos e metas financeiras. A aplicação é puramente um **frontend** (interface de usuário) que se comunica com uma API backend separada.

**Importante:** A aplicação **não é** um produto financeiro, **não realiza** transações bancárias reais, **não se conecta** a nenhuma API bancária, **não movimenta** dinheiro e **não oferece** consultoria financeira. Trata-se exclusivamente de uma ferramenta de **registro e visualização** de dados financeiros inseridos manualmente pelo próprio usuário.

---

## 2. Objetivo e Propósito da Aplicação

### 2.1 Problema que Resolve

Muitas pessoas têm dificuldade em organizar e visualizar suas finanças pessoais de forma consolidada. O PHRS FinTrack oferece uma interface intuitiva para que o usuário possa:

- Registrar suas contas bancárias, cartões e transações manualmente
- Categorizar receitas e despesas
- Acompanhar orçamentos mensais
- Monitorar o desempenho de investimentos
- Definir e acompanhar metas financeiras
- Identificar padrões de gastos através de gráficos e relatórios

### 2.2 O que a Aplicação NÃO Faz

Para fins de clareza junto à área de compliance, é importante destacar o que a aplicação **não faz**:

- **NÃO** acessa contas bancárias de terceiros
- **NÃO** realiza operações financeiras (transferências, pagamentos, PIX, etc.)
- **NÃO** se conecta a APIs do Open Finance / Open Banking
- **NÃO** se conecta a nenhuma API bancária (Itaú ou qualquer outro banco)
- **NÃO** armazena credenciais bancárias (agência, conta, senha de banco)
- **NÃO** oferece recomendações de investimento ou consultoria financeira
- **NÃO** processa ou armazena dados de cartão de crédito reais (números, CVV, etc.)
- **NÃO** utiliza dados corporativos do Itaú ou de qualquer instituição financeira
- **NÃO** utiliza a marca, logotipo ou propriedade intelectual do Itaú
- **NÃO** coleta dados de terceiros sem consentimento
- **NÃO** compartilha dados com terceiros

---

## 3. Stack Tecnológica

### 3.1 Framework Principal

| Tecnologia | Versão | Finalidade |
|---|---|---|
| **Next.js** | 16.1.6 | Framework React para aplicações web |
| **React** | 19.0.0 | Biblioteca de interface de usuário |
| **TypeScript** | 5.7.3 | Linguagem com tipagem estática |

### 3.2 Interface de Usuário (UI)

| Tecnologia | Versão | Finalidade |
|---|---|---|
| **Tailwind CSS** | 4.0.7 | Framework CSS utilitário |
| **Radix UI** | Diversas | Componentes de UI acessíveis (20+ pacotes) |
| **shadcn/ui** | 3.8.1 | Sistema de componentes reutilizáveis |
| **Recharts** | 2.15.1 | Biblioteca de gráficos para visualização de dados |
| **Lucide React** | 0.475.0 | Biblioteca de ícones |
| **Tabler Icons** | 3.22.0 | Biblioteca de ícones |

### 3.3 Gerenciamento de Estado e Dados

| Tecnologia | Versão | Finalidade |
|---|---|---|
| **Zustand** | 5.0.10 | Gerenciamento de estado global |
| **TanStack React Query** | 5.90.20 | Cache e sincronização de dados do servidor |
| **TanStack React Table** | 8.20.5 | Gerenciamento de tabelas de dados |
| **Axios** | 1.13.2 | Cliente HTTP para comunicação com API |

### 3.4 Formulários e Validação

| Tecnologia | Versão | Finalidade |
|---|---|---|
| **React Hook Form** | 7.53.2 | Gerenciamento de formulários |
| **Zod** | 3.23.8 | Validação de esquemas de dados |

### 3.5 Utilitários

| Tecnologia | Versão | Finalidade |
|---|---|---|
| **date-fns** | 4.1.0 | Manipulação de datas |
| **date-fns-tz** | 3.2.0 | Suporte a fusos horários |
| **react-dropzone** | 14.3.8 | Upload de arquivos (importação CSV) |
| **cmdk** | 1.0.4 | Menu de busca global (Cmd+K) |
| **country-region-data** | 3.1.0 | Dados de países e regiões para perfil |

### 3.6 Testes e Desenvolvimento

| Tecnologia | Versão | Finalidade |
|---|---|---|
| **Jest** | 30.2.0 | Framework de testes |
| **React Testing Library** | 16.3.1 | Testes de componentes |
| **MSW (Mock Service Worker)** | 2.12.7 | Simulação de APIs para desenvolvimento |
| **Faker.js** | 9.3.0 | Geração de dados fictícios para testes |
| **ESLint** | 9.x | Análise estática de código |
| **Prettier** | 3.4.2 | Formatação de código |

### 3.7 Avaliação de Segurança das Dependências

Todas as dependências são bibliotecas **open source amplamente utilizadas** pela comunidade de desenvolvimento web, mantidas por organizações reconhecidas (Vercel, Meta/Facebook, Radix, TanStack). Nenhuma das dependências:

- Coleta telemetria com dados do usuário final
- Envia dados para servidores externos em runtime
- Possui histórico de vulnerabilidades críticas não corrigidas
- É mantida por entidades de reputação questionável

---

## 4. Arquitetura da Aplicação

### 4.1 Diagrama de Arquitetura de Alto Nível

```
┌─────────────────────────────────────────────────────────────────┐
│                        NAVEGADOR DO USUÁRIO                     │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    PHRS FINTRACK (Frontend)                │  │
│  │                                                           │  │
│  │  ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐  │  │
│  │  │  Autenticação│  │   Dashboard  │  │  Gerenciamento  │  │  │
│  │  │  & Segurança │  │  Financeiro  │  │  de Dados       │  │  │
│  │  └──────┬───────┘  └──────┬───────┘  └────────┬────────┘  │  │
│  │         │                 │                    │           │  │
│  │  ┌──────▼─────────────────▼────────────────────▼────────┐ │  │
│  │  │              Camada de Serviços (Axios)               │ │  │
│  │  │         Cache Local (Zustand + localStorage)          │ │  │
│  │  └──────────────────────┬────────────────────────────────┘ │  │
│  └─────────────────────────┼─────────────────────────────────┘  │
│                            │                                    │
│                     HTTPS (API REST)                            │
│                            │                                    │
└────────────────────────────┼────────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │   API BACKEND   │
                    │  (Servidor      │
                    │   separado)     │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │   BANCO DE      │
                    │   DADOS         │
                    └─────────────────┘
```

### 4.2 Camadas da Aplicação

```
Camada de Apresentação (UI)
    │
    ├── Páginas (Next.js App Router)
    ├── Componentes React (shadcn/ui + customizados)
    ├── Gráficos e Visualizações (Recharts)
    └── Temas (claro/escuro)
    │
Camada de Estado e Lógica
    │
    ├── Zustand (estado global: autenticação, cache de dados)
    ├── React Query (sincronização com servidor)
    ├── React Hook Form + Zod (validação de formulários)
    └── Context API (tema, busca, dados financeiros)
    │
Camada de Comunicação
    │
    ├── Axios (cliente HTTP com interceptors)
    ├── SSE - Server-Sent Events (sincronização em tempo real)
    └── Headers de autenticação (cookies HttpOnly, workspace ID)
```

### 4.3 Modelo de Rotas

A aplicação utiliza o **App Router** do Next.js com três grupos de rotas:

| Grupo | Prefixo | Acesso | Descrição |
|---|---|---|---|
| **(auth)** | `/login`, `/register`, etc. | Público | Páginas de autenticação |
| **(fintrack)** | `/dashboard`, `/transactions`, etc. | Protegido | Funcionalidades principais |
| **(errors)** | `/401`, `/403`, `/404`, `/503` | Público | Páginas de erro |

---

## 5. Funcionalidades Detalhadas

### 5.1 Autenticação e Registro de Usuários

#### 5.1.1 Login

| Aspecto | Detalhe |
|---|---|
| **Rota** | `/login` |
| **Método** | `POST /api/v1/auth/login` |
| **Dados Coletados** | E-mail e senha |
| **Sessão** | Cookie HttpOnly (`session`) emitido pelo backend |
| **Persistência** | Cookie gerenciado pelo backend; workspace ativo em `localStorage` |

**Fluxo:**

1. Usuário informa e-mail e senha na tela de login
2. Frontend envia as credenciais via HTTPS para o endpoint de login da API
3. Backend valida credenciais e retorna cookie de sessão com flag `HttpOnly`
4. Se MFA estiver habilitado, o usuário é redirecionado para `/verify-mfa`
5. Frontend valida a sessão via `GET /auth/validate` e carrega dados do usuário
6. Usuário é redirecionado para o Dashboard

#### 5.1.2 Registro

| Aspecto | Detalhe |
|---|---|
| **Rota** | `/register` |
| **Método** | `POST /api/v1/auth/register` |
| **Dados Coletados** | Nome completo, e-mail, senha |
| **Validação** | Todos os campos são obrigatórios |

#### 5.1.3 Recuperação de Senha

| Aspecto | Detalhe |
|---|---|
| **Rota (solicitar)** | `/forgot-password` |
| **Rota (redefinir)** | `/reset-password` |
| **Método** | `POST /api/v1/auth/forgot-password` → `POST /api/v1/auth/reset-password` |
| **Mecanismo** | Token de redefinição com expiração de 1 hora |
| **Dados Coletados** | E-mail (solicitação) / Token + nova senha (redefinição) |

#### 5.1.4 Autenticação Multifator (MFA)

| Aspecto | Detalhe |
|---|---|
| **Rota** | `/verify-mfa` |
| **Método TOTP** | `POST /api/v1/auth/verify-mfa` |
| **Método Recovery** | `POST /api/v1/auth/verify-recovery-code` |
| **Tipo de MFA** | TOTP (Time-based One-Time Password) |
| **Códigos de Recuperação** | Códigos de uso único gerados na ativação do MFA |

#### 5.1.5 Logout

| Aspecto | Detalhe |
|---|---|
| **Método** | `POST /api/v1/auth/logout` |
| **Ação** | Invalida sessão no backend e limpa estado local |

---

### 5.2 Dashboard Financeiro

| Aspecto | Detalhe |
|---|---|
| **Rota** | `/dashboard` |
| **Acesso** | Autenticado |
| **Dados Exibidos** | Resumo financeiro do mês selecionado |

**Funcionalidades do Dashboard:**

| Componente | Descrição |
|---|---|
| **Summary Cards** | Exibe receita total, despesa total, saldo e economia do mês |
| **Tendência Receita/Despesa** | Gráfico de linha mostrando evolução mensal de receitas e despesas |
| **Fontes de Receita** | Gráfico de pizza com distribuição das fontes de renda |
| **Uso do Dinheiro** | Gráfico de pizza com distribuição de gastos por categoria |
| **Resultado Líquido** | Gráfico de barras comparando receita vs. despesa por período |
| **Gráfico por Categoria** | Breakdown de gastos por categoria com valores e percentuais |
| **Visão Geral de Cartões** | Lista de cartões com fatura atual, limite e utilização |
| **Histórico de Faturas** | Gráfico temporal das faturas de cada cartão |
| **Ranking por Categoria** | Classificação dos maiores gastos no cartão por categoria |
| **Filtro Mês/Ano** | Seletor para navegação temporal dos dados |

**Dados consumidos da API:**
- `GET /api/v1/dashboard?month=X&year=Y` — resumo financeiro geral
- `GET /api/v1/dashboard/cards?month=X&year=Y` — resumo de cartões

---

### 5.3 Gestão de Contas Bancárias

| Aspecto | Detalhe |
|---|---|
| **Rota** | `/workspace/accounts` |
| **Acesso** | Autenticado |
| **Operações** | Criar, visualizar, editar, excluir contas |

**Dados armazenados por conta:**

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | UUID | Identificador único |
| `name` | String | Nome da conta (ex.: "Conta Corrente Itaú") |
| `type` | Enum | Tipo: `CHECKING`, `SAVINGS`, `INVESTMENT`, `CREDIT` |
| `balance` | Number | Saldo atual informado pelo usuário |
| `currency` | String | Moeda (ex.: BRL) |
| `color` | String | Cor para identificação visual |
| `icon` | String | Ícone para identificação visual |
| `isActive` | Boolean | Se a conta está ativa |

**Esclarecimento:** Os dados de conta são **meramente descritivos** e informados manualmente pelo usuário. Não há conexão real com nenhuma instituição financeira. O "saldo" é um valor digitado pelo usuário para fins de controle pessoal.

---

### 5.4 Gestão de Cartões de Crédito

| Aspecto | Detalhe |
|---|---|
| **Rota** | `/workspace/cards` |
| **Acesso** | Autenticado |
| **Operações** | Criar, visualizar, editar, excluir cartões |

**Dados armazenados por cartão:**

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | UUID | Identificador único |
| `name` | String | Nome do cartão (ex.: "Visa Platinum") |
| `lastFourDigits` | String | Últimos 4 dígitos (informado pelo usuário) |
| `brand` | String | Bandeira (Visa, Mastercard, etc.) |
| `limit` | Number | Limite total do cartão |
| `closingDay` | Number | Dia de fechamento da fatura |
| `dueDay` | Number | Dia de vencimento da fatura |
| `color` | String | Cor para identificação visual |
| `isActive` | Boolean | Se o cartão está ativo |

**Esclarecimento sobre dados sensíveis de cartão:**
- A aplicação **NÃO** armazena número completo do cartão
- **NÃO** armazena CVV, data de validade ou qualquer dado de segurança
- **NÃO** processa pagamentos
- Os "últimos 4 dígitos" são opcionais e servem apenas para identificação visual pelo próprio usuário
- O "limite" é informado manualmente para fins de controle pessoal
- **NÃO há integração com gateways de pagamento**

---

### 5.5 Gestão de Categorias e Tags

#### 5.5.1 Categorias

| Aspecto | Detalhe |
|---|---|
| **Rota** | `/workspace/categories` |
| **Tipos** | `INCOME` (receita), `EXPENSE` (despesa) |
| **Hierarquia** | Categorias podem ter subcategorias |
| **Exemplos** | Alimentação, Transporte, Salário, Freelance, etc. |

#### 5.5.2 Tags

| Aspecto | Detalhe |
|---|---|
| **Rota** | `/workspace/tags` |
| **Finalidade** | Marcação livre para organização adicional de transações |
| **Exemplos** | "Urgente", "Supérfluo", "Investimento", etc. |

---

### 5.6 Gestão de Transações

| Aspecto | Detalhe |
|---|---|
| **Rota** | `/transactions` |
| **Acesso** | Autenticado |
| **Tipos de Visualização** | Por conta, por cartão, por investimento, por recorrência |

**Dados por transação:**

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | UUID | Identificador único |
| `description` | String | Descrição da transação |
| `amount` | Number | Valor da transação |
| `type` | Enum | `INCOME` ou `EXPENSE` |
| `date` | Date | Data da transação |
| `category` | Referência | Categoria vinculada |
| `tags` | Array | Tags vinculadas |
| `account` ou `card` | Referência | Conta ou cartão vinculado |
| `notes` | String | Observações adicionais (opcional) |

**Funcionalidades:**

- Listagem paginada com filtros por mês/ano
- Criação manual de transações via formulário (sheet lateral)
- Edição e exclusão de transações existentes
- Abas separadas para transações de contas, cartões, investimentos e recorrentes
- Visualização em tabela com ordenação

**Endpoints da API:**
- `GET /api/v1/transactions/accounts/:month/:year`
- `GET /api/v1/transactions/cards/:month/:year`
- `POST /api/v1/transactions/accounts`
- `POST /api/v1/transactions/cards`

---

### 5.7 Importação de Dados (CSV)

| Aspecto | Detalhe |
|---|---|
| **Rota** | `/import-sessions` |
| **Acesso** | Autenticado |
| **Formatos** | Arquivos CSV |
| **Mecanismo** | Upload via drag-and-drop (react-dropzone) |

**Fluxo de Importação:**

1. Usuário faz upload de um arquivo CSV com transações
2. Sistema cria uma "sessão de importação" com status de processamento
3. Transações são "staged" (preparadas) para revisão
4. Usuário revisa as transações staged e pode reconciliá-las
5. Após reconciliação, transações são efetivadas no sistema

**Funcionalidades:**
- Listagem de sessões de importação com status
- Visualização detalhada de cada sessão (`/import-sessions/[id]`)
- Estatísticas por sessão (total de linhas, processadas, erros)
- Reconciliação de transações staged

**Endpoints da API:**
- `GET /api/v1/import-sessions`
- `POST /api/v1/import-sessions`
- `GET /api/v1/import-sessions/:id`
- `GET /api/v1/import-sessions/:id/staged`
- `POST /api/v1/import-sessions/:id/reconcile`

**Esclarecimento:** O upload de CSV é feito pelo próprio usuário com dados que ele possui (extratos que ele mesmo baixou do seu banco). A aplicação não acessa bancos para obter esses dados automaticamente.

---

### 5.8 Orçamentos (Budgets)

| Aspecto | Detalhe |
|---|---|
| **Rota** | `/budgets` |
| **Acesso** | Autenticado |
| **Finalidade** | Definir limites de gastos mensais por categoria |

**Dados por orçamento:**

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | UUID | Identificador único |
| `category` | Referência | Categoria do orçamento |
| `amount` | Number | Valor limite definido pelo usuário |
| `month` | Number | Mês de referência |
| `year` | Number | Ano de referência |
| `spent` | Number | Valor já gasto (calculado) |

**Funcionalidades:**
- Cards de resumo (total orçado, total gasto, economia, categorias sem orçamento)
- Gráfico de barras comparando orçado vs. gasto por categoria
- Cards individuais por categoria com barra de progresso
- Criação, edição e exclusão de orçamentos
- Filtro por mês/ano

**Endpoints da API:**
- `GET /api/v1/budgets?month=X&year=Y`
- `GET /api/v1/budgets/summary?month=X&year=Y`
- `POST /api/v1/budgets`
- `PATCH /api/v1/budgets/:id`
- `DELETE /api/v1/budgets/:id`

---

### 5.9 Investimentos e Portfólio

| Aspecto | Detalhe |
|---|---|
| **Rota (gestão)** | `/workspace/investments` |
| **Rota (portfólio)** | `/investments-portfolio` |
| **Acesso** | Autenticado |
| **Finalidade** | Registrar e acompanhar investimentos pessoais |

**Tipos de investimento suportados:**

| Tipo | Descrição |
|---|---|
| `CDB` | Certificado de Depósito Bancário |
| `LCI` | Letra de Crédito Imobiliário |
| `LCA` | Letra de Crédito do Agronegócio |
| `TESOURO_DIRETO` | Títulos Públicos Federais |
| `FUNDO` | Fundos de Investimento |
| `ACAO` | Ações |
| `FII` | Fundos Imobiliários |
| `CRIPTO` | Criptomoedas |
| `PREVIDENCIA` | Previdência Privada |
| `OUTROS` | Outros tipos |

**Dados por investimento:**

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | UUID | Identificador único |
| `name` | String | Nome do investimento |
| `type` | Enum | Tipo do investimento (conforme tabela acima) |
| `institution` | String | Instituição onde foi feito |
| `currentValue` | Number | Valor atual informado pelo usuário |
| `investedValue` | Number | Valor investido |
| `profitability` | Number | Rentabilidade (%) |
| `dueDate` | Date | Data de vencimento (quando aplicável) |

**Funcionalidades do Portfólio:**
- Visão consolidada de todos os investimentos
- Distribuição por tipo de ativo (gráficos)
- Evolução temporal do patrimônio investido
- Performance de cada investimento

**Esclarecimento:** Todos os dados de investimento são inseridos manualmente pelo usuário. A aplicação não se conecta a corretoras, não executa ordens de compra/venda e não acessa dados de mercado em tempo real.

---

### 5.10 Metas Financeiras (Goals)

| Aspecto | Detalhe |
|---|---|
| **Rota** | `/goals` |
| **Acesso** | Autenticado |
| **Finalidade** | Definir e acompanhar metas de economia/investimento |

**Dados por meta:**

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | UUID | Identificador único |
| `name` | String | Nome da meta (ex.: "Viagem para Europa") |
| `targetAmount` | Number | Valor alvo |
| `currentAmount` | Number | Valor acumulado até o momento |
| `deadline` | Date | Data limite para atingir a meta |
| `category` | String | Categoria da meta |
| `status` | Enum | Status da meta |

**Funcionalidades:**
- Criação de metas com valor alvo e prazo
- Registro de depósitos/aportes na meta
- Barra de progresso visual
- Edição e exclusão de metas

**Endpoints da API:**
- `GET /api/v1/goals`
- `POST /api/v1/goals`
- `PATCH /api/v1/goals/:id`
- `DELETE /api/v1/goals/:id`
- `POST /api/v1/goals/:id/deposit`

---

### 5.11 Transações Recorrentes

| Aspecto | Detalhe |
|---|---|
| **Rota** | `/workspace/recurring` |
| **Acesso** | Autenticado |
| **Finalidade** | Cadastrar despesas/receitas que se repetem periodicamente |

**Frequências suportadas:**

| Frequência | Descrição |
|---|---|
| `DAILY` | Diária |
| `WEEKLY` | Semanal |
| `MONTHLY` | Mensal |
| `BIMONTHLY` | Bimestral |
| `QUARTERLY` | Trimestral |
| `SEMIANNUAL` | Semestral |
| `ANNUAL` | Anual |

**Dados:**
- Descrição, valor, categoria, frequência, data de início, data de término (opcional)
- Vinculação a uma conta ou cartão

---

### 5.12 Notificações

| Aspecto | Detalhe |
|---|---|
| **Rota** | `/notifications` |
| **Acesso** | Autenticado |
| **Mecanismo** | Polling + SSE (Server-Sent Events) |

**Tipos de notificação:**
- Alertas de orçamento (limite próximo ou ultrapassado)
- Lembretes de contas a pagar
- Atualizações do sistema
- Notificações de metas atingidas

**Endpoints:**
- `GET /api/v1/notifications` — listar notificações
- `GET /api/v1/notifications/stream` — canal SSE para tempo real

---

### 5.13 Configurações do Usuário

#### 5.13.1 Perfil

| Aspecto | Detalhe |
|---|---|
| **Rota** | `/settings/profile` |
| **Dados** | Nome, e-mail |
| **Operações** | Visualizar e atualizar perfil, alterar senha |

**Endpoints:**
- `GET /api/v1/user/profile`
- `PUT /api/v1/user/profile`
- `PUT /api/v1/user/password`

#### 5.13.2 Chaves de API

| Aspecto | Detalhe |
|---|---|
| **Rota** | `/settings/api-keys` |
| **Finalidade** | Gerenciar chaves de API para integrações externas |
| **Operações** | Criar, listar, revogar chaves |

**Esclarecimento:** As chaves de API são para uso futuro de integrações que o próprio usuário configurar. Não há integrações pré-configuradas com serviços de terceiros.

#### 5.13.3 Segurança

| Aspecto | Detalhe |
|---|---|
| **Rota** | `/settings/security` |
| **Funcionalidades** | MFA (TOTP), Passkeys, Códigos de recuperação |

**Operações de segurança disponíveis:**

| Operação | Endpoint | Descrição |
|---|---|---|
| Ver configurações | `GET /security/settings` | Estado atual da segurança |
| Iniciar setup MFA | `POST /security/mfa/setup` | Gera QR code TOTP |
| Verificar/ativar MFA | `POST /security/mfa/verify` | Ativa MFA com código de 6 dígitos |
| Desativar MFA | `DELETE /security/mfa` | Remove MFA da conta |
| Regenerar recovery codes | `POST /security/recovery-codes/regenerate` | Novos códigos de recuperação |
| Registrar passkey | `POST /security/passkeys` | WebAuthn/FIDO2 passkey |
| Remover passkey | `DELETE /security/passkeys/:id` | Remove passkey |

---

### 5.14 Workspaces

| Aspecto | Detalhe |
|---|---|
| **Finalidade** | Separação lógica de contextos financeiros |
| **Exemplo** | "Finanças Pessoais", "Empresa MEI", etc. |
| **Isolamento** | Dados de cada workspace são isolados via header `X-Workspace-ID` |

**Funcionalidades:**
- Criação de novos workspaces
- Alternância entre workspaces (via seletor no sidebar)
- Cache limpo automaticamente ao trocar de workspace

**Papéis:**
- `ADMIN` — controle total do workspace
- `MEMBER` — acesso aos dados do workspace

---

## 6. Segurança da Aplicação

### 6.1 Autenticação

| Mecanismo | Implementação |
|---|---|
| **Sessão** | Cookies `HttpOnly` gerenciados pelo backend |
| **MFA** | TOTP (Time-based One-Time Password) com app autenticador |
| **Recovery Codes** | Códigos de uso único para acesso emergencial |
| **Passkeys** | Suporte a WebAuthn/FIDO2 (biometria, chave de segurança) |
| **Reset de Senha** | Token com expiração de 1 hora |

### 6.2 Autorização

| Mecanismo | Implementação |
|---|---|
| **Rotas Protegidas** | Componente `ProtectedRoute` que valida sessão antes de renderizar |
| **Workspace Isolation** | Header `X-Workspace-ID` em todas as requisições autenticadas |
| **Validação de Sessão** | `GET /auth/validate` executado no carregamento da aplicação |
| **Auto-logout** | Respostas `401` do backend disparam logout automático + redirecionamento |

### 6.3 Comunicação

| Mecanismo | Implementação |
|---|---|
| **Protocolo** | HTTPS (TLS) para todas as comunicações com a API |
| **Credenciais** | `withCredentials: true` no Axios para envio automático de cookies |
| **Interceptors** | Interceptors Axios para injeção de headers e tratamento de erros |

### 6.4 Proteção do Frontend

| Mecanismo | Implementação |
|---|---|
| **Validação de Entrada** | Zod schemas para validação de todos os formulários |
| **Tipagem Estática** | TypeScript strict mode para prevenção de erros em tempo de compilação |
| **XSS** | React com JSX previne injeção de HTML por padrão |
| **CSRF** | Cookies HttpOnly + validação de sessão no backend |

### 6.5 Armazenamento Local

| Dado | Local | Justificativa |
|---|---|---|
| Workspace ativo | `localStorage` | Persistir seleção entre recarregamentos |
| Cache de dados financeiros | `localStorage` (Zustand persist) | Performance — evitar re-fetch desnecessário |
| Tema (claro/escuro) | `localStorage` | Preferência visual do usuário |

**Esclarecimento:** Nenhum dado sensível (senhas, tokens, dados bancários reais) é armazenado em `localStorage`. O token de sessão é mantido exclusivamente em cookie `HttpOnly`, inacessível via JavaScript.

---

## 7. Tratamento e Proteção de Dados

### 7.1 Dados Pessoais Coletados

| Dado | Finalidade | Base Legal (LGPD) |
|---|---|---|
| **Nome** | Identificação do usuário na interface | Execução de contrato (Art. 7º, V) |
| **E-mail** | Login, recuperação de senha, notificações | Execução de contrato (Art. 7º, V) |
| **Senha** | Autenticação | Execução de contrato (Art. 7º, V) |

### 7.2 Dados Financeiros Inseridos pelo Usuário

| Dado | Natureza | Observação |
|---|---|---|
| Nomes de contas | Descritivo | Não contém dados bancários reais |
| Saldos | Informado manualmente | Não verificado contra bancos |
| Transações | Informado manualmente ou importado via CSV | Dados do próprio usuário |
| Últimos 4 dígitos do cartão | Opcional, descritivo | Não é dado sensível de cartão |
| Limites de cartão | Informado manualmente | Para controle pessoal |
| Valores de investimento | Informado manualmente | Não conectado a corretoras |
| Metas e orçamentos | Informado manualmente | Dados de planejamento pessoal |

### 7.3 Dados que NÃO São Coletados

- Número completo de cartão de crédito
- CVV ou código de segurança de cartão
- Senha de banco ou internet banking
- CPF, RG ou outros documentos de identidade
- Número de agência e conta corrente real
- Dados biométricos (exceto uso de passkeys via WebAuthn do navegador)
- Dados de localização (GPS)
- Contatos do dispositivo
- Histórico de navegação
- Dados de outros aplicativos

### 7.4 Compartilhamento de Dados

A aplicação **NÃO** compartilha dados do usuário com terceiros. Não há:

- Integração com redes de publicidade
- Pixels de rastreamento (Facebook Pixel, Google Analytics, etc.)
- Venda ou cessão de dados para terceiros
- Compartilhamento com parceiros comerciais
- Envio de dados para serviços de analytics

### 7.5 Retenção e Exclusão

- Todos os dados ficam armazenados no backend (servidor da aplicação)
- O cache local (`localStorage`) pode ser limpo pelo usuário a qualquer momento
- A exclusão de conta deve remover todos os dados associados no backend

---

## 8. Integrações Externas e APIs

### 8.1 Integrações em Produção

| Serviço | Finalidade | Dados Enviados |
|---|---|---|
| **API Backend própria** | Armazenamento e processamento de dados | Dados financeiros do usuário (conforme seção 7) |

### 8.2 Recursos Externos Carregados

| Recurso | URL | Finalidade | Dados Enviados |
|---|---|---|---|
| Avatares placeholder | `https://i.pravatar.cc` | Imagens de avatar padrão | Nenhum dado do usuário |
| Imagens UI placeholder | `https://ui.shadcn.com` | Imagens de exemplo da biblioteca UI | Nenhum dado do usuário |

**Esclarecimento:** Esses recursos são imagens estáticas carregadas apenas para fins de placeholder/demonstração. Nenhum dado do usuário é transmitido para esses domínios.

### 8.3 O Que NÃO Existe na Aplicação

| Integração | Status |
|---|---|
| Open Banking / Open Finance | **NÃO EXISTE** |
| APIs bancárias (Itaú, Bradesco, BB, etc.) | **NÃO EXISTE** |
| APIs de corretoras (XP, Clear, BTG, etc.) | **NÃO EXISTE** |
| APIs de pagamento (PagSeguro, Stripe, etc.) | **NÃO EXISTE** |
| APIs de dados de mercado (B3, Bloomberg, etc.) | **NÃO EXISTE** |
| Google Analytics / Firebase | **NÃO EXISTE** |
| Facebook SDK / Pixel | **NÃO EXISTE** |
| Serviços de e-mail marketing | **NÃO EXISTE** |
| SDKs de redes sociais | **NÃO EXISTE** |
| Serviços de geolocalização | **NÃO EXISTE** |

---

## 9. Infraestrutura e Dependências

### 9.1 Ambiente de Desenvolvimento

A aplicação utiliza **Mock Service Worker (MSW)** durante o desenvolvimento, que simula todas as respostas da API diretamente no navegador. Isso significa que em ambiente de desenvolvimento:

- Nenhuma chamada de rede real é feita a servidores externos
- Todos os dados são fictícios, gerados pela biblioteca Faker.js
- O service worker intercepta chamadas HTTP e retorna dados mockados
- A flag `NEXT_PUBLIC_MSW_ENABLED=true` controla esse comportamento

### 9.2 Ambiente de Produção

Em produção, o MSW é desabilitado e a aplicação se comunica com uma API backend real via HTTPS. A aplicação frontend:

- É servida como arquivos estáticos (HTML, CSS, JS)
- Comunica-se exclusivamente com a API backend configurada
- Não tem acesso direto a bancos de dados
- Não executa lógica de negócio sensível (essa responsabilidade é do backend)

### 9.3 Variáveis de Ambiente

| Variável | Finalidade | Sensibilidade |
|---|---|---|
| `NEXT_PUBLIC_MSW_ENABLED` | Ativar/desativar mocks | Não sensível |
| `NEXT_PUBLIC_API_BASE_URL` | URL base da API | Não sensível (configuração) |
| `NEXT_PUBLIC_API_PREFIX` | Prefixo de rotas da API | Não sensível (configuração) |

**Nota:** Todas as variáveis são prefixadas com `NEXT_PUBLIC_`, o que significa que são expostas ao navegador. Nenhuma contém dados sensíveis como chaves secretas, tokens de API ou credenciais de banco de dados.

---

## 10. Análise de Riscos e Mitigações

### 10.1 Riscos Identificados

| # | Risco | Severidade | Probabilidade | Mitigação |
|---|---|---|---|---|
| 1 | Vazamento de dados financeiros pessoais do usuário | Média | Baixa | Dados são auto-inseridos; backend com autenticação; HTTPS |
| 2 | Acesso não autorizado à conta | Média | Baixa | MFA, cookies HttpOnly, validação de sessão, passkeys |
| 3 | XSS (Cross-Site Scripting) | Baixa | Muito Baixa | React sanitiza output por padrão; validação Zod nos inputs |
| 4 | CSRF (Cross-Site Request Forgery) | Baixa | Muito Baixa | Cookies HttpOnly; validação de sessão server-side |
| 5 | Confusão com produto oficial do Itaú | Baixa | Muito Baixa | Não utiliza marca, logo ou nome do Itaú; app pessoal |
| 6 | Uso indevido como consultoria financeira | Baixa | Baixa | App é ferramenta de registro; não faz recomendações |
| 7 | Dados em localStorage acessíveis | Baixa | Baixa | Apenas cache de dados e preferências; sem tokens ou senhas |

### 10.2 Riscos NÃO Aplicáveis

| Risco | Por que NÃO se aplica |
|---|---|
| Fraude financeira | App não movimenta dinheiro |
| Lavagem de dinheiro | App não processa transações reais |
| Vazamento de dados bancários de clientes | App não acessa dados de terceiros |
| Conflito de interesse com o Itaú | App não compete com produtos do banco |
| Uso de dados corporativos | App não utiliza nenhum dado do Itaú |
| Insider trading | App não acessa dados de mercado em tempo real |
| Violação de sigilo bancário | App não acessa dados de correntistas |

---

## 11. Conformidade Regulatória

### 11.1 LGPD (Lei Geral de Proteção de Dados)

| Requisito | Status | Observação |
|---|---|---|
| Base legal para tratamento | Conforme | Execução de contrato (serviço solicitado pelo próprio usuário) |
| Coleta mínima de dados | Conforme | Apenas nome, e-mail e senha; dados financeiros são inseridos voluntariamente |
| Consentimento | Conforme | Usuário insere dados voluntariamente ao usar a plataforma |
| Direito de exclusão | A implementar | Backend deve suportar exclusão completa de dados |
| Direito de portabilidade | Parcialmente | Exportação via funcionalidades futuras |
| Política de privacidade | A implementar | Documento formal de política de privacidade |
| Encarregado de dados (DPO) | N/A | Aplicável caso o volume de dados justifique |

### 11.2 Resolução BCB n° 32/2020 (Open Banking)

**Não aplicável.** A aplicação não participa do ecossistema Open Banking e não acessa APIs reguladas pelo Banco Central.

### 11.3 Resolução CMN n° 4.893/2021 (Segurança Cibernética)

**Não aplicável diretamente.** A aplicação é um projeto pessoal e não é um serviço prestado pela instituição financeira. Contudo, as práticas de segurança adotadas (MFA, HTTPS, HttpOnly cookies) estão alinhadas com as recomendações da resolução.

### 11.4 PCI DSS (Payment Card Industry Data Security Standard)

**Não aplicável.** A aplicação não processa, armazena ou transmite dados completos de cartão de crédito (PAN, CVV, data de validade). Os únicos dados relacionados a cartões são os últimos 4 dígitos (opcionais) e o limite (informado manualmente), que não são considerados dados de titular de cartão pelo PCI DSS.

---

## 12. Declarações e Esclarecimentos Finais

### 12.1 Declaração de Independência

Este projeto é uma **iniciativa pessoal** do desenvolvedor, sem qualquer vínculo, patrocínio, endosso ou associação com o Banco Itaú Unibanco S.A. ou qualquer empresa do conglomerado Itaú. O desenvolvimento foi realizado inteiramente:

- Fora do horário de trabalho
- Utilizando equipamento pessoal
- Sem utilização de dados corporativos, ferramentas proprietárias ou informações confidenciais do empregador
- Sem utilização de propriedade intelectual do Itaú

### 12.2 Declaração de Não Competição

O PHRS FinTrack é uma **ferramenta de organização pessoal** e não compete com nenhum produto ou serviço oferecido pelo Banco Itaú, incluindo mas não limitado a:

- Aplicativo Itaú (internet banking)
- Íon (plataforma de investimentos)
- Iti (pagamentos)
- Credicard
- Qualquer outro produto financeiro do conglomerado

### 12.3 Declaração de Propriedade Intelectual

- O código-fonte utiliza exclusivamente bibliotecas open source com licenças permissivas (MIT, Apache 2.0)
- O design da interface é baseado no sistema de componentes shadcn/ui (licença MIT)
- Não há utilização de marca registrada, logotipo ou identidade visual do Itaú
- O nome "FinTrack" é genérico e descritivo, sem associação com marcas do Itaú

### 12.4 Disponibilidade para Esclarecimentos

O desenvolvedor se coloca à disposição para quaisquer esclarecimentos adicionais que a área de compliance julgue necessários, incluindo:

- Demonstração da aplicação em funcionamento
- Acesso ao código-fonte para auditoria
- Detalhamento técnico de qualquer funcionalidade
- Apresentação da arquitetura do backend (quando aplicável)

---

## 13. Anexos

### Anexo A — Mapa Completo de Rotas da Aplicação

| Rota | Tipo | Autenticação | Descrição |
|---|---|---|---|
| `/login` | Pública | Não | Tela de login |
| `/register` | Pública | Não | Tela de cadastro |
| `/forgot-password` | Pública | Não | Solicitar recuperação de senha |
| `/reset-password` | Pública | Não | Redefinir senha com token |
| `/verify-mfa` | Pública | Parcial | Verificação de segundo fator |
| `/dashboard` | Protegida | Sim | Painel financeiro principal |
| `/workspace/accounts` | Protegida | Sim | Gestão de contas |
| `/workspace/cards` | Protegida | Sim | Gestão de cartões |
| `/workspace/categories` | Protegida | Sim | Gestão de categorias |
| `/workspace/tags` | Protegida | Sim | Gestão de tags |
| `/workspace/investments` | Protegida | Sim | Gestão de investimentos |
| `/workspace/recurring` | Protegida | Sim | Transações recorrentes |
| `/transactions` | Protegida | Sim | Gestão de transações |
| `/import-sessions` | Protegida | Sim | Importação de dados |
| `/import-sessions/[id]` | Protegida | Sim | Detalhes de importação |
| `/budgets` | Protegida | Sim | Orçamentos mensais |
| `/investments-portfolio` | Protegida | Sim | Portfólio de investimentos |
| `/goals` | Protegida | Sim | Metas financeiras |
| `/notifications` | Protegida | Sim | Central de notificações |
| `/settings/profile` | Protegida | Sim | Perfil do usuário |
| `/settings/api-keys` | Protegida | Sim | Chaves de API |
| `/settings/security` | Protegida | Sim | Configurações de segurança |
| `/401` | Pública | Não | Erro: não autorizado |
| `/403` | Pública | Não | Erro: acesso negado |
| `/404` | Pública | Não | Erro: página não encontrada |
| `/503` | Pública | Não | Erro: serviço indisponível |

### Anexo B — Mapa Completo de Endpoints da API

| Método | Endpoint | Descrição | Autenticação |
|---|---|---|---|
| `POST` | `/auth/login` | Login do usuário | Não |
| `POST` | `/auth/register` | Registro de novo usuário | Não |
| `GET` | `/auth/validate` | Validar sessão ativa | Sim (cookie) |
| `POST` | `/auth/logout` | Encerrar sessão | Sim |
| `POST` | `/auth/forgot-password` | Solicitar reset de senha | Não |
| `POST` | `/auth/reset-password` | Redefinir senha | Não |
| `POST` | `/auth/verify-mfa` | Verificar código MFA | Parcial |
| `POST` | `/auth/verify-recovery-code` | Verificar código de recuperação | Parcial |
| `GET` | `/accounts` | Listar contas | Sim |
| `POST` | `/accounts` | Criar conta | Sim |
| `PATCH` | `/accounts/:id` | Atualizar conta | Sim |
| `DELETE` | `/accounts/:id` | Excluir conta | Sim |
| `GET` | `/cards` | Listar cartões | Sim |
| `POST` | `/cards` | Criar cartão | Sim |
| `PATCH` | `/cards/:id` | Atualizar cartão | Sim |
| `DELETE` | `/cards/:id` | Excluir cartão | Sim |
| `GET` | `/categories` | Listar categorias | Sim |
| `POST` | `/categories` | Criar categoria | Sim |
| `PATCH` | `/categories/:id` | Atualizar categoria | Sim |
| `DELETE` | `/categories/:id` | Excluir categoria | Sim |
| `GET` | `/categories/:id/subcategories` | Listar subcategorias | Sim |
| `GET` | `/tags` | Listar tags | Sim |
| `POST` | `/tags` | Criar tag | Sim |
| `PATCH` | `/tags/:id` | Atualizar tag | Sim |
| `DELETE` | `/tags/:id` | Excluir tag | Sim |
| `GET` | `/investments` | Listar investimentos | Sim |
| `POST` | `/investments` | Criar investimento | Sim |
| `PATCH` | `/investments/:id` | Atualizar investimento | Sim |
| `DELETE` | `/investments/:id` | Excluir investimento | Sim |
| `GET` | `/investments/:id/transactions` | Transações do investimento | Sim |
| `GET` | `/investments/:id/value-updates` | Histórico de valores | Sim |
| `GET` | `/recurring` | Listar recorrências | Sim |
| `POST` | `/recurring` | Criar recorrência | Sim |
| `PATCH` | `/recurring/:id` | Atualizar recorrência | Sim |
| `DELETE` | `/recurring/:id` | Excluir recorrência | Sim |
| `GET` | `/transactions/accounts/:month/:year` | Transações de contas | Sim |
| `GET` | `/transactions/cards/:month/:year` | Transações de cartões | Sim |
| `POST` | `/transactions/accounts` | Criar transação (conta) | Sim |
| `POST` | `/transactions/cards` | Criar transação (cartão) | Sim |
| `GET` | `/import-sessions` | Listar sessões de importação | Sim |
| `POST` | `/import-sessions` | Criar sessão de importação | Sim |
| `GET` | `/import-sessions/:id` | Detalhes da sessão | Sim |
| `GET` | `/import-sessions/:id/staged` | Transações staged | Sim |
| `POST` | `/import-sessions/:id/reconcile` | Reconciliar transações | Sim |
| `GET` | `/budgets` | Listar orçamentos | Sim |
| `GET` | `/budgets/summary` | Resumo de orçamentos | Sim |
| `POST` | `/budgets` | Criar orçamento | Sim |
| `PATCH` | `/budgets/:id` | Atualizar orçamento | Sim |
| `DELETE` | `/budgets/:id` | Excluir orçamento | Sim |
| `GET` | `/goals` | Listar metas | Sim |
| `POST` | `/goals` | Criar meta | Sim |
| `PATCH` | `/goals/:id` | Atualizar meta | Sim |
| `DELETE` | `/goals/:id` | Excluir meta | Sim |
| `POST` | `/goals/:id/deposit` | Depositar em meta | Sim |
| `GET` | `/dashboard` | Resumo financeiro | Sim |
| `GET` | `/dashboard/cards` | Resumo de cartões | Sim |
| `GET` | `/api-keys` | Listar chaves de API | Sim |
| `POST` | `/api-keys` | Criar chave de API | Sim |
| `DELETE` | `/api-keys/:id` | Revogar chave de API | Sim |
| `GET` | `/security/settings` | Configurações de segurança | Sim |
| `POST` | `/security/mfa/setup` | Iniciar setup MFA | Sim |
| `POST` | `/security/mfa/verify` | Verificar e ativar MFA | Sim |
| `DELETE` | `/security/mfa` | Desativar MFA | Sim |
| `POST` | `/security/recovery-codes/regenerate` | Regenerar recovery codes | Sim |
| `POST` | `/security/passkeys` | Registrar passkey | Sim |
| `DELETE` | `/security/passkeys/:id` | Remover passkey | Sim |
| `GET` | `/user/profile` | Obter perfil | Sim |
| `PUT` | `/user/profile` | Atualizar perfil | Sim |
| `PUT` | `/user/password` | Alterar senha | Sim |
| `GET` | `/notifications` | Listar notificações | Sim |
| `GET` | `/notifications/stream` | SSE de notificações | Sim |
| `GET` | `/workspaces` | Listar workspaces | Sim |
| `POST` | `/workspaces` | Criar workspace | Sim |

### Anexo C — Lista Completa de Dependências de Produção

| Pacote | Versão | Licença | Finalidade |
|---|---|---|---|
| next | 16.1.6 | MIT | Framework web |
| react | 19.0.0 | MIT | Biblioteca de UI |
| react-dom | 19.0.0 | MIT | Renderização DOM |
| typescript | 5.7.3 | Apache-2.0 | Tipagem estática |
| axios | 1.13.2 | MIT | Cliente HTTP |
| zustand | 5.0.10 | MIT | Estado global |
| zod | 3.23.8 | MIT | Validação de dados |
| react-hook-form | 7.53.2 | MIT | Formulários |
| @hookform/resolvers | 3.9.1 | MIT | Resolvers para RHF |
| @tanstack/react-query | 5.90.20 | MIT | Cache de dados |
| @tanstack/react-table | 8.20.5 | MIT | Tabelas de dados |
| recharts | 2.15.1 | MIT | Gráficos |
| date-fns | 4.1.0 | MIT | Utilitário de datas |
| date-fns-tz | 3.2.0 | MIT | Fusos horários |
| tailwindcss | 4.0.7 | MIT | Framework CSS |
| tailwindcss-animate | 1.0.7 | MIT | Animações CSS |
| @tailwindcss/typography | 0.5.16 | MIT | Tipografia CSS |
| next-themes | 0.4.4 | MIT | Tema claro/escuro |
| class-variance-authority | 0.7.0 | Apache-2.0 | Variantes CSS |
| clsx | 2.1.1 | MIT | Classes CSS |
| tailwind-merge | 3.0.1 | MIT | Merge de classes |
| cmdk | 1.0.4 | MIT | Menu de comando |
| react-day-picker | 8.10.1 | MIT | Seletor de data |
| react-dropzone | 14.3.8 | MIT | Upload de arquivos |
| vaul | 1.1.2 | MIT | Componente drawer |
| country-region-data | 3.1.0 | MIT | Dados geográficos |
| lucide-react | 0.475.0 | ISC | Ícones |
| @tabler/icons-react | 3.22.0 | MIT | Ícones |
| @faker-js/faker | 9.3.0 | MIT | Dados fictícios (dev) |
| @radix-ui/* (20 pacotes) | Diversas | MIT | Componentes UI acessíveis |

**Nota:** Todas as dependências utilizam licenças permissivas (MIT, Apache-2.0, ISC), compatíveis com uso comercial e projetos privados.

---

*Documento elaborado com base na análise estática do código-fonte da aplicação PHRS FinTrack, versão 1.0.0.*

*Para quaisquer dúvidas ou esclarecimentos adicionais, favor contatar o desenvolvedor.*
