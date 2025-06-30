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

CREATE TYPE "transaction_status" AS ENUM (
  'paid',
  'pending',
  'ignore'
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
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "users" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "name" VARCHAR(100) NOT NULL,
  "username" VARCHAR(100) UNIQUE NOT NULL,
  "email" VARCHAR(100) UNIQUE NOT NULL,
  "is_active" BOOLEAN NOT NULL DEFAULT true,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "accounts" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "user_id" UUID NOT NULL,
  "name" VARCHAR(100) UNIQUE NOT NULL,
  "type" account_type NOT NULL,
  "initial_balance" NUMERIC(15, 2) NOT NULL,
  "currency" currency NOT NULL,
  "is_active" BOOLEAN NOT NULL DEFAULT true,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "categories" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "name" VARCHAR(100) UNIQUE NOT NULL,
  "color" VARCHAR(100) NOT NULL,
  "icon" VARCHAR(100) NOT NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "sub_categories" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "name" VARCHAR(100) NOT NULL,
  "category_id" UUID NOT NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "cards" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "name" VARCHAR(100) UNIQUE NOT NULL,
  "credit_limit" NUMERIC(15, 2) NOT NULL,
  "account_id" UUID NOT NULL,
  "closing_date" INTEGER NOT NULL,
  "due_date" INTEGER NOT NULL,
  "is_active" BOOLEAN NOT NULL DEFAULT true,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "invoices" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "card_id" UUID NOT NULL,
  "billing_month" DATE NOT NULL,
  "status" invoice_status NOT NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "transfers" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "recurring_transfer_id" UUID,
  "transfer_date" DATE NOT NULL,
  "amount" NUMERIC(15, 2) NOT NULL,
  "source_account_id" UUID NOT NULL,
  "destination_account_id" UUID NOT NULL,
  "transaction_status" transaction_status NOT NULL DEFAULT 'pending',
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "recurring_transfers" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "amount" NUMERIC(15, 2) NOT NULL,
  "source_account_id" UUID NOT NULL,
  "destination_account_id" UUID NOT NULL,
  "frequency" transaction_frequency NOT NULL,
  "start_date" DATE NOT NULL,
  "end_date" DATE,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "recurring_transactions" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "amount" NUMERIC(15, 2) NOT NULL,
  "description" VARCHAR(50) NOT NULL,
  "frequency" transaction_frequency NOT NULL,
  "start_date" DATE NOT NULL,
  "end_date" DATE,
  "account_id" UUID NOT NULL,
  "category_id" UUID NOT NULL,
  "subcategory_id" UUID,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
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
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "tags" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "name" VARCHAR(100) NOT NULL,
  "color" VARCHAR(20),
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "recurring_transactions_tags" (
  "recurring_transaction_id" UUID NOT NULL,
  "tag_id" UUID NOT NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "incomes" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "description" TEXT,
  "amount" NUMERIC(15, 2) NOT NULL,
  "account_id" UUID NOT NULL,
  "recurring_transaction_id" UUID,
  "category_id" UUID NOT NULL,
  "subcategory_id" UUID,
  "transaction_status" transaction_status NOT NULL DEFAULT 'pending',
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "expenses" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "description" TEXT,
  "amount" NUMERIC(15, 2) NOT NULL,
  "account_id" UUID NOT NULL,
  "category_id" UUID NOT NULL,
  "subcategory_id" UUID,
  "transaction_status" transaction_status NOT NULL DEFAULT 'pending',
  "recurring_transaction_id" UUID,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "card_expenses" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "description" TEXT,
  "amount" NUMERIC(15, 2) NOT NULL,
  "subcategory_id" UUID,
  "category_id" UUID,
  "recurring_transaction_id" UUID,
  "invoice_id" UUID NOT NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "card_chargebacks" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "description" TEXT,
  "amount" NUMERIC(15, 2) NOT NULL,
  "invoice_id" UUID NOT NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "card_payments" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "amount" NUMERIC(15, 2) NOT NULL,
  "account_id" UUID NOT NULL,
  "invoice_id" UUID NOT NULL,
  "is_final_payment" BOOLEAN NOT NULL DEFAULT false,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "investment_deposit" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "description" TEXT,
  "amount" NUMERIC(15, 2) NOT NULL,
  "recurring_transaction_id" UUID,
  "investment_id" UUID,
  "account_id" UUID NOT NULL,
  "transaction_status" transaction_status NOT NULL DEFAULT 'pending',
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "investment_withdrawal" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "description" TEXT,
  "amount" NUMERIC(15, 2) NOT NULL,
  "recurring_transaction_id" UUID,
  "investment_id" UUID,
  "account_id" UUID NOT NULL,
  "transaction_status" transaction_status NOT NULL DEFAULT 'pending',
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "incomes_tags" (
  "income_id" UUID NOT NULL,
  "tag_id" UUID NOT NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "expenses_tags" (
  "expense_id" UUID NOT NULL,
  "tag_id" UUID NOT NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "investments_tags" (
  "investment_id" UUID NOT NULL,
  "tag_id" UUID NOT NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "card_expense_tags" (
  "card_expense_id" UUID NOT NULL,
  "tag_id" UUID NOT NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

ALTER TABLE "transfers" ADD FOREIGN KEY ("recurring_transfer_id") REFERENCES "recurring_transfers" ("id") ON DELETE SET NULL;

ALTER TABLE "recurring_transfers" ADD FOREIGN KEY ("source_account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;

ALTER TABLE "recurring_transfers" ADD FOREIGN KEY ("destination_account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;

ALTER TABLE "card_expenses" ADD FOREIGN KEY ("recurring_transaction_id") REFERENCES "recurring_transactions" ("id") ON DELETE SET NULL;

ALTER TABLE "expenses" ADD FOREIGN KEY ("recurring_transaction_id") REFERENCES "recurring_transactions" ("id") ON DELETE SET NULL;

ALTER TABLE "incomes" ADD FOREIGN KEY ("recurring_transaction_id") REFERENCES "recurring_transactions" ("id") ON DELETE SET NULL;

ALTER TABLE "recurring_transactions_tags" ADD FOREIGN KEY ("recurring_transaction_id") REFERENCES "recurring_transactions" ("id") ON DELETE SET NULL;

ALTER TABLE "recurring_transactions_tags" ADD FOREIGN KEY ("tag_id") REFERENCES "tags" ("id") ON DELETE SET NULL;

ALTER TABLE "incomes_tags" ADD FOREIGN KEY ("income_id") REFERENCES "incomes" ("id") ON DELETE CASCADE;

ALTER TABLE "incomes_tags" ADD FOREIGN KEY ("tag_id") REFERENCES "tags" ("id") ON DELETE SET NULL;

ALTER TABLE "expenses_tags" ADD FOREIGN KEY ("expense_id") REFERENCES "expenses" ("id") ON DELETE CASCADE;

ALTER TABLE "expenses_tags" ADD FOREIGN KEY ("tag_id") REFERENCES "tags" ("id") ON DELETE SET NULL;

ALTER TABLE "investments_tags" ADD FOREIGN KEY ("investment_id") REFERENCES "investments" ("id") ON DELETE SET NULL;

ALTER TABLE "investments_tags" ADD FOREIGN KEY ("tag_id") REFERENCES "tags" ("id") ON DELETE SET NULL;

ALTER TABLE "card_expense_tags" ADD FOREIGN KEY ("card_expense_id") REFERENCES "card_expenses" ("id") ON DELETE SET NULL;

ALTER TABLE "card_expense_tags" ADD FOREIGN KEY ("tag_id") REFERENCES "tags" ("id") ON DELETE SET NULL;

ALTER TABLE "accounts" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE;

ALTER TABLE "cards" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;

ALTER TABLE "investments" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;

ALTER TABLE "investment_deposit" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;

ALTER TABLE "investment_withdrawal" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;

ALTER TABLE "recurring_transactions" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;

ALTER TABLE "transfers" ADD FOREIGN KEY ("source_account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;

ALTER TABLE "transfers" ADD FOREIGN KEY ("destination_account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;

ALTER TABLE "incomes" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;

ALTER TABLE "expenses" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;

ALTER TABLE "card_payments" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;

ALTER TABLE "card_expenses" ADD FOREIGN KEY ("invoice_id") REFERENCES "invoices" ("id") ON DELETE CASCADE;

ALTER TABLE "card_chargebacks" ADD FOREIGN KEY ("invoice_id") REFERENCES "invoices" ("id") ON DELETE CASCADE;

ALTER TABLE "card_payments" ADD FOREIGN KEY ("invoice_id") REFERENCES "invoices" ("id") ON DELETE CASCADE;

ALTER TABLE "investment_deposit" ADD FOREIGN KEY ("investment_id") REFERENCES "investments" ("id") ON DELETE CASCADE;

ALTER TABLE "investment_withdrawal" ADD FOREIGN KEY ("investment_id") REFERENCES "investments" ("id") ON DELETE CASCADE;

ALTER TABLE "sub_categories" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("id") ON DELETE CASCADE;

ALTER TABLE "incomes" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("id") ON DELETE RESTRICT;

ALTER TABLE "incomes" ADD FOREIGN KEY ("subcategory_id") REFERENCES "sub_categories" ("id") ON DELETE SET NULL;

ALTER TABLE "expenses" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("id") ON DELETE RESTRICT;

ALTER TABLE "expenses" ADD FOREIGN KEY ("subcategory_id") REFERENCES "sub_categories" ("id") ON DELETE SET NULL;

ALTER TABLE "recurring_transactions" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("id") ON DELETE RESTRICT;

ALTER TABLE "recurring_transactions" ADD FOREIGN KEY ("subcategory_id") REFERENCES "sub_categories" ("id") ON DELETE SET NULL;

CREATE INDEX "idx_external_sync_id_local" ON "external_sync" ("id_local");

CREATE INDEX "idx_accounts_user_id" ON "accounts" ("user_id");

CREATE UNIQUE INDEX ON "sub_categories" ("name", "category_id");

CREATE UNIQUE INDEX ON "invoices" ("card_id", "billing_month");

CREATE INDEX "idx_transfers_source_account_id" ON "transfers" ("source_account_id");

CREATE INDEX "idx_transfers_destination_account_id" ON "transfers" ("destination_account_id");

CREATE INDEX "idx_recurring_transactions_source_account_id" ON "recurring_transfers" ("source_account_id");

CREATE INDEX "idx_recurring_transactions_destination_account_id" ON "recurring_transfers" ("destination_account_id");

CREATE INDEX "idx_recurring_transactions_account_id" ON "recurring_transactions" ("account_id");

CREATE INDEX "idx_recurring_transactions_category_id" ON "recurring_transactions" ("category_id");

CREATE INDEX "idx_recurring_transactions_subcategory_id" ON "recurring_transactions" ("subcategory_id");

CREATE INDEX "idx_investments_account_id" ON "investments" ("account_id");

CREATE INDEX "idx_incomes_account_id" ON "incomes" ("account_id");

CREATE INDEX "idx_incomes_recurring_transaction_id" ON "incomes" ("recurring_transaction_id");

CREATE INDEX "idx_incomes_category_id" ON "incomes" ("category_id");

CREATE INDEX "idx_incomes_subcategory_id" ON "incomes" ("subcategory_id");

CREATE INDEX "idx_expenses_account_id" ON "expenses" ("account_id");

CREATE INDEX "idx_expenses_recurring_transaction_id" ON "expenses" ("recurring_transaction_id");

CREATE INDEX "idx_expenses_category_id" ON "expenses" ("category_id");

CREATE INDEX "idx_expenses_subcategory_id" ON "expenses" ("subcategory_id");

CREATE INDEX "idx_card_expenses_invoice_id" ON "card_expenses" ("invoice_id");

CREATE INDEX "idx_card_expenses_category_id" ON "card_expenses" ("category_id");

CREATE INDEX "idx_card_expenses_subcategory_id" ON "card_expenses" ("subcategory_id");

CREATE INDEX "idx_card_chargebacks_invoice_id" ON "card_chargebacks" ("invoice_id");

CREATE INDEX "idx_card_payments_account_id" ON "card_payments" ("account_id");

CREATE INDEX "idx_card_payments_invoice_id" ON "card_payments" ("invoice_id");

CREATE INDEX "idx_investment_deposit_investment_id" ON "investment_deposit" ("investment_id");

CREATE INDEX "idx_investment_deposit_account_id" ON "investment_deposit" ("account_id");

CREATE INDEX "idx_investment_deposit_recurring_transaction_id" ON "investment_deposit" ("recurring_transaction_id");

CREATE INDEX "idx_investment_withdrawal_investment_id" ON "investment_withdrawal" ("investment_id");

CREATE INDEX "idx_investment_withdrawal_account_id" ON "investment_withdrawal" ("account_id");

CREATE INDEX "idx_investment_withdrawal_recurring_transaction_id" ON "investment_withdrawal" ("recurring_transaction_id");
