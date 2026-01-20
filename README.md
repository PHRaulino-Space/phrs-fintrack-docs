# Documentação do Banco de Dados - Sistema de Organização Financeira

## Visão Geral
Este banco de dados foi projetado para gerenciar transações financeiras, controlar receitas, despesas, transferências, faturas, investimentos e gerar relatórios detalhados para um melhor planejamento financeiro pessoal.

## Estrutura do Projeto

Este repositório contém a documentação do projeto Fintrack. Os repositórios de código fonte (frontend e backend) estão organizados como submódulos Git:

- **Frontend**: [phrs-fintrack-frontend](https://github.com/PHRaulino-Space/phrs-fintrack-frontend)
- **Backend**: [phrs-fintrack-backend](https://github.com/PHRaulino-Space/phrs-fintrack-backend)

### Instalando os Submódulos

Para clonar o projeto completo com todos os submódulos, execute:

```bash
# Clonar o repositório com submódulos
git clone --recurse-submodules https://github.com/PHRaulino-Space/fintrack-docs.git

# OU, se já clonou o repositório, execute o script de instalação:
bash install-submodules.sh
```

Para atualizar os submódulos posteriormente:

```bash
git submodule update --remote --recursive
```

---

## Entidades e Regras de Negócio

### **1. Users (Usuários)**
- **Descrição**: Representa os usuários do sistema. No caso deste sistema, haverá apenas um usuário ativo, utilizado para organização de dados.
- **Campos**:
  - `id` (UUID, PK): Identificador único do usuário.
  - `name` (VARCHAR 100): Nome do usuário.
  - `email` (VARCHAR 100): E-mail do usuário. Deve ser único.
  - `created_at` (TIMESTAMP): Data e hora de criação do usuário. Padrão: data atual.

---

### **2. Accounts (Contas)**
- **Descrição**: Representa contas bancárias ou carteiras digitais.
- **Campos**:
  - `id` (UUID, PK): Identificador único da conta.
  - `name` (VARCHAR 100): Nome da conta.
  - `type` (VARCHAR 50): Tipo de conta (ex.: corrente, poupança, carteira digital).
  - `initial_balance` (NUMERIC 15,2): Saldo inicial da conta.
  - `currency` (VARCHAR 10): Moeda da conta (ex.: BRL, USD).
  - `user_id` (UUID, FK): Referência ao usuário proprietário da conta.

---

### **3. Categories (Categorias)**
- **Descrição**: Agrupamento principal para categorizar transações.
- **Campos**:
  - `id` (UUID, PK): Identificador único da categoria.
  - `name` (VARCHAR 100): Nome da categoria.
  - `transaction_type_id` (UUID, FK): Tipo de transação associado (ex.: receita, despesa).

---

### **4. Subcategories (Subcategorias)**
- **Descrição**: Subcategorias vinculadas a uma categoria principal.
- **Campos**:
  - `id` (UUID, PK): Identificador único da subcategoria.
  - `name` (VARCHAR 100): Nome da subcategoria.
  - `category_id` (UUID, FK): Referência à categoria associada.

---

### **5. Transaction Types (Tipos de Transações)**
- **Descrição**: Tabela de domínio que define os tipos de transações possíveis (ex.: receita, despesa, transferência).
- **Campos**:
  - `id` (UUID, PK): Identificador único do tipo de transação.
  - `name` (VARCHAR 100): Nome do tipo de transação.

---

### **6. Transaction Statuses (Status de Transações)**
- **Descrição**: Tabela de domínio que define os status de uma transação (ex.: paga, pendente, cancelada).
- **Campos**:
  - `id` (UUID, PK): Identificador único do status.
  - `name` (VARCHAR 50): Nome do status.

---

### **7. Transactions (Transações)**
- **Descrição**: Registra todas as movimentações financeiras no sistema.
- **Campos**:
  - `id` (UUID, PK): Identificador único da transação.
  - `transaction_date` (DATE): Data da transação.
  - `description` (TEXT): Descrição da transação.
  - `amount` (NUMERIC 15,2): Valor da transação. Negativo para despesas e positivo para receitas.
  - `account_id` (UUID, FK): Referência à conta associada.
  - `category_id` (UUID, FK): Categoria associada à transação.
  - `subcategory_id` (UUID, FK, opcional): Subcategoria associada à transação.
  - `transaction_type_id` (UUID, FK): Tipo da transação.
  - `transaction_status_id` (UUID, FK): Status da transação.
  - `transfer_id` (UUID, FK, opcional): Referência à transferência associada, se aplicável.
  - `invoice_id` (UUID, FK, opcional): Referência à fatura associada, se aplicável.
  - `recurring_transaction_id` (UUID, FK, opcional): Referência à transação recorrente associada, se aplicável.
  - `investment_id` (UUID, FK, opcional): Referência ao investimento associado, se aplicável.

---

### **8. Cards (Cartões)**
- **Descrição**: Representa os cartões de crédito vinculados a contas bancárias.
- **Campos**:
  - `id` (UUID, PK): Identificador único do cartão.
  - `name` (VARCHAR 100): Nome do cartão.
  - `credit_limit` (NUMERIC 15,2): Limite de crédito do cartão.
  - `account_id` (UUID, FK): Referência à conta associada ao cartão.

---

### **9. Invoices (Faturas)**
- **Descrição**: Registra as faturas de cartões de crédito.
- **Campos**:
  - `id` (UUID, PK): Identificador único da fatura.
  - `card_id` (UUID, FK): Referência ao cartão associado.
  - `billing_month` (DATE): Mês referente à fatura.
  - `due_date` (DATE): Data de vencimento da fatura.
  - `status` (VARCHAR 50): Status da fatura (ex.: aberta, paga, vencida).
  - `payment_transaction_id` (UUID, FK, opcional): Referência à transação de pagamento, se aplicável.

---

### **10. Transfers (Transferências)**
- **Descrição**: Representa transferências financeiras entre contas.
- **Campos**:
  - `id` (UUID, PK): Identificador único da transferência.
  - `source_account_id` (UUID, FK): Conta de origem.
  - `destination_account_id` (UUID, FK): Conta de destino.
  - `amount` (NUMERIC 15,2): Valor da transferência.
  - `transfer_date` (DATE): Data da transferência.
  - `description` (TEXT): Descrição da transferência.

---

### **11. Recurring Transactions (Transações Recorrentes)**
- **Descrição**: Representa transações que ocorrem periodicamente.
- **Campos**:
  - `id` (UUID, PK): Identificador único da transação recorrente.
  - `amount` (NUMERIC 15,2): Valor da transação.
  - `frequency` (VARCHAR 50): Frequência da transação (ex.: mensal, semanal).
  - `start_date` (DATE): Data de início da recorrência.
  - `end_date` (DATE, opcional): Data de término da recorrência.
  - `transaction_type_id` (UUID, FK): Tipo da transação recorrente.
  - `category_id` (UUID, FK): Categoria associada.
  - `subcategory_id` (UUID, FK, opcional): Subcategoria associada.

---

### **12. Investments (Investimentos)**
- **Descrição**: Registra informações sobre investimentos realizados.
- **Campos**:
  - `id` (UUID, PK): Identificador único do investimento.
  - `asset_name` (VARCHAR 100): Nome do ativo investido.
  - `type` (VARCHAR 50): Tipo de investimento (ex.: renda fixa, ações).
  - `account_id` (UUID, FK): Referência à conta associada.
  - `index_type` (VARCHAR 50, opcional): Indexador do investimento (ex.: CDI, IPCA).
  - `application_date` (DATE): Data de aplicação.
  - `maturity_date` (DATE, opcional): Data de vencimento.
  - `invested_amount` (NUMERIC 15,2): Valor investido.
  - `current_value` (NUMERIC 15,2): Valor atual do investimento.

---

### **13. Tags**
- **Descrição**: Permite categorizar transações com marcações personalizadas.
- **Campos**:
  - `id` (UUID, PK): Identificador único da tag.
  - `name` (VARCHAR 100): Nome da tag.
  - `color` (VARCHAR 20, opcional): Cor associada à tag.

---

### **14. Transaction Tags**
- **Descrição**: Relaciona tags a transações, permitindo múltiplas tags por transação.
- **Campos**:
  - `transaction_id` (UUID, FK): Referência à transação.
  - `tag_id` (UUID, FK): Referência à tag.
  - **Chave Primária**: Combinação de `transaction_id` e `tag_id`.

---

## Relacionamentos

- **Users → Accounts**: Um usuário possui várias contas.
- **Accounts → Transactions**: Cada transação está vinculada a uma conta.
- **Cards → Invoices**: Um cartão pode ter várias faturas.
- **Invoices → Transactions**: Uma fatura pode estar vinculada a uma transação de pagamento.
- **Investments → Transactions**: Um investimento pode ter transações associadas, como aportes ou resgates.
- **Recurring Transactions → Transactions**: Transações recorrentes podem gerar múltiplas transações.

---

## Autor
**Paulo Henrique Raulino da Silva**  
Sistema projetado para organização financeira
