DROP TABLE IF EXISTS "card_expense_tags" CASCADE;
DROP TABLE IF EXISTS "investments_tags" CASCADE;
DROP TABLE IF EXISTS "expenses_tags" CASCADE;
DROP TABLE IF EXISTS "incomes_tags" CASCADE;
DROP TABLE IF EXISTS "investment_withdrawal" CASCADE;
DROP TABLE IF EXISTS "investment_deposit" CASCADE;
DROP TABLE IF EXISTS "card_payments" CASCADE;
DROP TABLE IF EXISTS "card_chargebacks" CASCADE;
DROP TABLE IF EXISTS "card_expenses" CASCADE;
DROP TABLE IF EXISTS "expenses" CASCADE;
DROP TABLE IF EXISTS "incomes" CASCADE;
DROP TABLE IF EXISTS "recurring_transactions_tags" CASCADE;
DROP TABLE IF EXISTS "tags" CASCADE;
DROP TABLE IF EXISTS "investments" CASCADE;
DROP TABLE IF EXISTS "recurring_transactions" CASCADE;
DROP TABLE IF EXISTS "transfers" CASCADE;
DROP TABLE IF EXISTS "invoices" CASCADE;
DROP TABLE IF EXISTS "cards" CASCADE;
DROP TABLE IF EXISTS "transaction_statuses" CASCADE;
DROP TABLE IF EXISTS "subcategories" CASCADE;
DROP TABLE IF EXISTS "categories" CASCADE;
DROP TABLE IF EXISTS "accounts" CASCADE;
DROP TABLE IF EXISTS "users" CASCADE;
DROP TABLE IF EXISTS "external_sync" CASCADE;

CREATE TYPE "account_type" AS ENUM (
  'checking',
  'savings',
  'wallet',
  'investment'
);

CREATE TYPE "currency" AS ENUM (
  'BRL',
  'USD',
  'EUR'
);

CREATE TYPE "investment_type" AS ENUM (
  'renda_fixa',
  'renda_variavel',
  'tesouro_direto'
);

CREATE TYPE "index_type" AS ENUM (
  'CDI',
  'IPCA',
  'SELIC',
  'FIXED'
);

CREATE TYPE "liquidity_type" AS ENUM (
  'daily',
  'monthly',
  'at_maturity'
);

CREATE TYPE "invoice_status" AS ENUM (
  'open',
  'paid',
  'overdue'
);

CREATE TYPE "transaction_frequency" AS ENUM (
  'daily',
  'weekly',
  'biweekly',
  'monthly',
  'bimonthly',
  'quarterly',
  'yearly'
);

CREATE TYPE "sync_type" AS ENUM (
  'incomes',
  'expenses',
  'card_expenses',
  'card_chargebacks',
  'card_payments',
  'transfers',
  'recurring_transactions',
  'investment_deposit',
  'investment_withdrawal',
  'investments'
);

CREATE TYPE "integration_source" AS ENUM (
  'mobills'
);

CREATE TABLE "external_sync" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "id_local" UUID NOT NULL,
  "id_mobills" UUID NOT NULL,
  "sync_type" sync_type NOT NULL,
  "source" integration_source NOT NULL,
  "created_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "users" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "name" VARCHAR(100) NOT NULL,
  "username" VARCHAR(100) UNIQUE NOT NULL,
  "email" VARCHAR(100) UNIQUE NOT NULL,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "accounts" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "user_id" UUID NOT NULL,
  "name" VARCHAR(100) UNIQUE NOT NULL,
  "type" account_type NOT NULL,
  "initial_balance" NUMERIC(15,2) NOT NULL,
  "currency" currency NOT NULL,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "categories" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "name" VARCHAR(100) UNIQUE NOT NULL,
  "color" VARCHAR(100) NOT NULL,
  "icon" VARCHAR(100) NOT NULL,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "subcategories" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "name" VARCHAR(100) UNIQUE NOT NULL,
  "category_id" UUID NOT NULL,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "transaction_statuses" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "name" VARCHAR(50) UNIQUE NOT NULL,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "cards" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "name" VARCHAR(100) UNIQUE NOT NULL,
  "credit_limit" NUMERIC(15,2) NOT NULL,
  "account_id" UUID NOT NULL,
  "closing_date" INTEGER NOT NULL,
  "due_date" INTEGER NOT NULL,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "invoices" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "card_id" UUID NOT NULL,
  "billing_month" DATE NOT NULL,
  "status" invoice_status NOT NULL,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "transfers" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transfer_date" DATE NOT NULL,
  "amount" NUMERIC(15,2) NOT NULL,
  "source_account_id" UUID NOT NULL,
  "destination_account_id" UUID NOT NULL,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "recurring_transactions" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "amount" NUMERIC(15,2) NOT NULL,
  "description" VARCHAR(50) NOT NULL,
  "frequency" transaction_frequency NOT NULL,
  "start_date" DATE NOT NULL,
  "end_date" DATE,
  "account_id" UUID NOT NULL,
  "category_id" UUID NOT NULL,
  "subcategory_id" UUID,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "investments" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "asset_name" VARCHAR(100) NOT NULL,
  "type" investment_type NOT NULL,
  "account_id" UUID NOT NULL,
  "index_type" index_type,
  "index_value" VARCHAR(50),
  "liquidity" liquidity_type,
  "is_rescued" BOOLEAN,
  "validity" DATE,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "tags" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "name" VARCHAR(100) NOT NULL,
  "color" VARCHAR(20),
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "recurring_transactions_tags" (
  "recurring_transactions_id" UUID NOT NULL,
  "tag_id" UUID NOT NULL,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "incomes" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "description" TEXT,
  "amount" NUMERIC(15,2) NOT NULL,
  "account_id" UUID NOT NULL,
  "recurring_transaction_id" UUID,
  "category_id" UUID NOT NULL,
  "subcategory_id" UUID,
  "transaction_status_id" UUID NOT NULL,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "expenses" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "description" TEXT,
  "amount" NUMERIC(15,2) NOT NULL,
  "account_id" UUID NOT NULL,
  "category_id" UUID NOT NULL,
  "subcategory_id" UUID,
  "transaction_status_id" UUID NOT NULL,
  "recurring_transaction_id" UUID,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "card_expenses" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "description" TEXT,
  "amount" NUMERIC(15,2) NOT NULL,
  "subcategory_id" UUID,
  "category_id" UUID,
  "recurring_transaction_id" UUID,
  "invoice_id" UUID,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "card_chargebacks" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "description" TEXT,
  "amount" NUMERIC(15,2) NOT NULL,
  "invoice_id" UUID,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "card_payments" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "amount" NUMERIC(15,2) NOT NULL,
  "account_id" UUID NOT NULL,
  "invoice_id" UUID NOT NULL,
  "is_finalized" BOOLEAN NOT NULL DEFAULT false,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "investment_deposit" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "description" TEXT,
  "amount" NUMERIC(15,2) NOT NULL,
  "recurring_transaction_id" UUID,
  "investment_id" UUID,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "investment_withdrawal" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "description" TEXT,
  "amount" NUMERIC(15,2) NOT NULL,
  "recurring_transaction_id" UUID,
  "investment_id" UUID,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "incomes_tags" (
  "income_id" UUID NOT NULL,
  "tag_id" UUID NOT NULL,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "expenses_tags" (
  "expense_id" UUID NOT NULL,
  "tag_id" UUID NOT NULL,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "investments_tags" (
  "investment_id" UUID NOT NULL,
  "tag_id" UUID NOT NULL,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "card_expense_tags" (
  "card_expense_id" UUID NOT NULL,
  "tag_id" UUID NOT NULL,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE UNIQUE INDEX ON "invoices" ("card_id", "billing_month");

-- Tags e suas relações: Cascade
ALTER TABLE recurring_transactions_tags
  ADD CONSTRAINT fk_recurring_transactions_tags_transaction_id FOREIGN KEY (recurring_transactions_id)
  REFERENCES recurring_transactions(id) ON DELETE CASCADE;

ALTER TABLE recurring_transactions_tags
  ADD CONSTRAINT fk_recurring_transactions_tags_tag_id FOREIGN KEY (tag_id)
  REFERENCES tags(id) ON DELETE CASCADE;

ALTER TABLE incomes_tags
  ADD CONSTRAINT fk_incomes_tags_income_id FOREIGN KEY (income_id)
  REFERENCES incomes(id) ON DELETE CASCADE;

ALTER TABLE incomes_tags
  ADD CONSTRAINT fk_incomes_tags_tag_id FOREIGN KEY (tag_id)
  REFERENCES tags(id) ON DELETE CASCADE;

ALTER TABLE expenses_tags
  ADD CONSTRAINT fk_expenses_tags_expense_id FOREIGN KEY (expense_id)
  REFERENCES expenses(id) ON DELETE CASCADE;

ALTER TABLE expenses_tags
  ADD CONSTRAINT fk_expenses_tags_tag_id FOREIGN KEY (tag_id)
  REFERENCES tags(id) ON DELETE CASCADE;

ALTER TABLE investments_tags
  ADD CONSTRAINT fk_investments_tags_investment_id FOREIGN KEY (investment_id)
  REFERENCES investments(id) ON DELETE CASCADE;

ALTER TABLE investments_tags
  ADD CONSTRAINT fk_investments_tags_tag_id FOREIGN KEY (tag_id)
  REFERENCES tags(id) ON DELETE CASCADE;

ALTER TABLE card_expense_tags
  ADD CONSTRAINT fk_card_expense_tags_expense_id FOREIGN KEY (card_expense_id)
  REFERENCES card_expenses(id) ON DELETE CASCADE;

ALTER TABLE card_expense_tags
  ADD CONSTRAINT fk_card_expense_tags_tag_id FOREIGN KEY (tag_id)
  REFERENCES tags(id) ON DELETE CASCADE;

-- Usuário excluído: apaga contas
ALTER TABLE accounts
  ADD CONSTRAINT fk_accounts_user_id FOREIGN KEY (user_id)
  REFERENCES users(id) ON DELETE CASCADE;

-- Conta excluída: apaga cartões e transações
ALTER TABLE cards
  ADD CONSTRAINT fk_cards_account_id FOREIGN KEY (account_id)
  REFERENCES accounts(id) ON DELETE CASCADE;

ALTER TABLE investments
  ADD CONSTRAINT fk_investments_account_id FOREIGN KEY (account_id)
  REFERENCES accounts(id) ON DELETE CASCADE;

ALTER TABLE recurring_transactions
  ADD CONSTRAINT fk_recurring_transactions_account_id FOREIGN KEY (account_id)
  REFERENCES accounts(id) ON DELETE CASCADE;

ALTER TABLE transfers
  ADD CONSTRAINT fk_transfers_source_account_id FOREIGN KEY (source_account_id)
  REFERENCES accounts(id) ON DELETE CASCADE;

ALTER TABLE transfers
  ADD CONSTRAINT fk_transfers_destination_account_id FOREIGN KEY (destination_account_id)
  REFERENCES accounts(id) ON DELETE CASCADE;

ALTER TABLE incomes
  ADD CONSTRAINT fk_incomes_account_id FOREIGN KEY (account_id)
  REFERENCES accounts(id) ON DELETE CASCADE;

ALTER TABLE expenses
  ADD CONSTRAINT fk_expenses_account_id FOREIGN KEY (account_id)
  REFERENCES accounts(id) ON DELETE CASCADE;

ALTER TABLE card_payments
  ADD CONSTRAINT fk_card_payments_account_id FOREIGN KEY (account_id)
  REFERENCES accounts(id) ON DELETE CASCADE;

-- Excluir fatura remove despesas e pagamentos do cartão
ALTER TABLE card_expenses
  ADD CONSTRAINT fk_card_expenses_invoice_id FOREIGN KEY (invoice_id)
  REFERENCES invoices(id) ON DELETE CASCADE;

ALTER TABLE card_chargebacks
  ADD CONSTRAINT fk_card_chargebacks_invoice_id FOREIGN KEY (invoice_id)
  REFERENCES invoices(id) ON DELETE CASCADE;

ALTER TABLE card_payments
  ADD CONSTRAINT fk_card_payments_invoice_id FOREIGN KEY (invoice_id)
  REFERENCES invoices(id) ON DELETE CASCADE;

-- Excluir investimento remove movimentações
ALTER TABLE investment_deposit
  ADD CONSTRAINT fk_investment_deposit_investment_id FOREIGN KEY (investment_id)
  REFERENCES investments(id) ON DELETE CASCADE;

ALTER TABLE investment_withdrawal
  ADD CONSTRAINT fk_investment_withdrawal_investment_id FOREIGN KEY (investment_id)
  REFERENCES investments(id) ON DELETE CASCADE;

-- Excluir categoria/subcategoria apenas se não houver vínculo
-- (você pode usar RESTRICT por padrão ou SET NULL se quiser manter o registro órfão)
ALTER TABLE subcategories
  ADD CONSTRAINT fk_subcategories_category_id FOREIGN KEY (category_id)
  REFERENCES categories(id) ON DELETE CASCADE;

ALTER TABLE incomes
  ADD CONSTRAINT fk_incomes_category_id FOREIGN KEY (category_id)
  REFERENCES categories(id) ON DELETE RESTRICT;

ALTER TABLE incomes
  ADD CONSTRAINT fk_incomes_subcategory_id FOREIGN KEY (subcategory_id)
  REFERENCES subcategories(id) ON DELETE SET NULL;

ALTER TABLE expenses
  ADD CONSTRAINT fk_expenses_category_id FOREIGN KEY (category_id)
  REFERENCES categories(id) ON DELETE RESTRICT;

ALTER TABLE expenses
  ADD CONSTRAINT fk_expenses_subcategory_id FOREIGN KEY (subcategory_id)
  REFERENCES subcategories(id) ON DELETE SET NULL;

ALTER TABLE recurring_transactions
  ADD CONSTRAINT fk_recurring_transactions_category_id FOREIGN KEY (category_id)
  REFERENCES categories(id) ON DELETE RESTRICT;

ALTER TABLE recurring_transactions
  ADD CONSTRAINT fk_recurring_transactions_subcategory_id FOREIGN KEY (subcategory_id)
  REFERENCES subcategories(id) ON DELETE SET NULL;

ALTER TABLE accounts ADD CONSTRAINT chk_accounts_initial_balance CHECK (initial_balance >= 0);
ALTER TABLE cards ADD CONSTRAINT chk_cards_credit_limit CHECK (credit_limit >= 0);
ALTER TABLE incomes ADD CONSTRAINT chk_incomes_amount CHECK (amount > 0);
ALTER TABLE expenses ADD CONSTRAINT chk_expenses_amount CHECK (amount > 0);
ALTER TABLE card_expenses ADD CONSTRAINT chk_card_expenses_amount CHECK (amount > 0);
ALTER TABLE card_chargebacks ADD CONSTRAINT chk_card_chargebacks_amount CHECK (amount > 0);
ALTER TABLE card_payments ADD CONSTRAINT chk_card_payments_amount CHECK (amount > 0);
ALTER TABLE investment_deposit ADD CONSTRAINT chk_investment_deposit_amount CHECK (amount > 0);
ALTER TABLE investment_withdrawal ADD CONSTRAINT chk_investment_withdrawal_amount CHECK (amount > 0);
ALTER TABLE transfers ADD CONSTRAINT chk_transfers_amount CHECK (amount > 0);
ALTER TABLE recurring_transactions ADD CONSTRAINT chk_recurring_transactions_amount CHECK (amount > 0);

-- Índices para external_sync
CREATE INDEX idx_external_sync_id_local ON external_sync(id_local);

-- Índices para accounts
CREATE INDEX idx_accounts_user_id ON accounts(user_id);

-- Índices para incomes
CREATE INDEX idx_incomes_account_id ON incomes(account_id);
CREATE INDEX idx_incomes_recurring_transaction_id ON incomes(recurring_transaction_id);
CREATE INDEX idx_incomes_category_id ON incomes(category_id);
CREATE INDEX idx_incomes_subcategory_id ON incomes(subcategory_id);
CREATE INDEX idx_incomes_transaction_status_id ON incomes(transaction_status_id);

-- Índices para expenses
CREATE INDEX idx_expenses_account_id ON expenses(account_id);
CREATE INDEX idx_expenses_recurring_transaction_id ON expenses(recurring_transaction_id);
CREATE INDEX idx_expenses_category_id ON expenses(category_id);
CREATE INDEX idx_expenses_subcategory_id ON expenses(subcategory_id);
CREATE INDEX idx_expenses_transaction_status_id ON expenses(transaction_status_id);

-- Índices para transfers
CREATE INDEX idx_transfers_source_account_id ON transfers(source_account_id);
CREATE INDEX idx_transfers_destination_account_id ON transfers(destination_account_id);

-- Índices para recurring_transactions
CREATE INDEX idx_recurring_transactions_account_id ON recurring_transactions(account_id);
CREATE INDEX idx_recurring_transactions_category_id ON recurring_transactions(category_id);
CREATE INDEX idx_recurring_transactions_subcategory_id ON recurring_transactions(subcategory_id);

-- Índices para investments
CREATE INDEX idx_investments_account_id ON investments(account_id);

-- Índices para card_expenses
CREATE INDEX idx_card_expenses_invoice_id ON card_expenses(invoice_id);
CREATE INDEX idx_card_expenses_category_id ON card_expenses(category_id);
CREATE INDEX idx_card_expenses_subcategory_id ON card_expenses(subcategory_id);

-- Índices para card_chargebacks
CREATE INDEX idx_card_chargebacks_invoice_id ON card_chargebacks(invoice_id);

-- Índices para card_payments
CREATE INDEX idx_card_payments_account_id ON card_payments(account_id);
CREATE INDEX idx_card_payments_invoice_id ON card_payments(invoice_id);

-- Índices para investment_deposit
CREATE INDEX idx_investment_deposit_investment_id ON investment_deposit(investment_id);
CREATE INDEX idx_investment_deposit_recurring_transaction_id ON investment_deposit(recurring_transaction_id);

-- Índices para investment_withdrawal
CREATE INDEX idx_investment_withdrawal_investment_id ON investment_withdrawal(investment_id);
CREATE INDEX idx_investment_withdrawal_recurring_transaction_id ON investment_withdrawal(recurring_transaction_id);