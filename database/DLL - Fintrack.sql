-- =====================================================
-- FINANCIAL MANAGEMENT SYSTEM - OPTIMIZED DDL
-- =====================================================

-- Drop schema if exists (recreate everything)
DROP SCHEMA IF EXISTS fintrack CASCADE;

-- Create schema
CREATE SCHEMA fintrack;

-- Set search path to use the schema
SET search_path TO fintrack, public;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- ENUMS
-- =====================================================

CREATE TYPE "account_type" AS ENUM (
  'checking',
  'savings',
  'wallet',
  'investment'
);

CREATE TYPE "investment_type" AS ENUM (
  'renda_fixa',
  'renda_variavel',
  'tesouro_direto',
  'fundo_investimento'
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
  'validating',
  'paid',
  'pending',
  'ignore'
);


-- =====================================================
-- LOOKUP TABLES
-- =====================================================

CREATE TABLE "currencies" (
  "code" VARCHAR(3) PRIMARY KEY,
  "name" VARCHAR(50) NOT NULL,
  "symbol" VARCHAR(5) NOT NULL,
  "is_active" BOOLEAN NOT NULL DEFAULT true,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "exchange_rates" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "from_currency" VARCHAR(3) NOT NULL,
  "to_currency" VARCHAR(3) NOT NULL,
  "rate" NUMERIC(15, 8) NOT NULL,
  "rate_date" DATE NOT NULL,
  "source" VARCHAR(50),
  "created_at" timestamp DEFAULT (now()),
  CONSTRAINT "chk_exchange_rate_positive" CHECK ("rate" > 0),
  CONSTRAINT "chk_different_currencies" CHECK ("from_currency" != "to_currency"),
  CONSTRAINT "uq_exchange_rates_date_pair" UNIQUE ("from_currency", "to_currency", "rate_date")
);

-- =====================================================
-- CORE TABLES
-- =====================================================

CREATE TABLE "users" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "name" VARCHAR(100) NOT NULL,
  "username" VARCHAR(100) UNIQUE NOT NULL,
  "email" VARCHAR(100) UNIQUE NOT NULL,
  "is_active" BOOLEAN NOT NULL DEFAULT true,
  "deleted_at" timestamp NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  CONSTRAINT "chk_email_format" CHECK ("email" ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE TABLE "accounts" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "user_id" UUID NOT NULL,
  "name" VARCHAR(100) NOT NULL,
  "type" account_type NOT NULL,
  "initial_balance" NUMERIC(15, 2) NOT NULL DEFAULT 0,
  "currency_code" VARCHAR(3) NOT NULL DEFAULT 'BRL',
  "is_active" BOOLEAN NOT NULL DEFAULT true,
  "deleted_at" timestamp NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  CONSTRAINT "uq_accounts_user_name" UNIQUE ("user_id", "name")
);

CREATE TABLE "categories" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "name" VARCHAR(100) UNIQUE NOT NULL,
  "color" VARCHAR(7) NOT NULL,
  "icon" VARCHAR(100) NOT NULL,
  "is_active" BOOLEAN NOT NULL DEFAULT true,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  CONSTRAINT "chk_color_hex" CHECK ("color" ~* '^#[0-9A-Fa-f]{6}$')
);

CREATE TABLE "sub_categories" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "name" VARCHAR(100) NOT NULL,
  "category_id" UUID NOT NULL,
  "is_active" BOOLEAN NOT NULL DEFAULT true,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "cards" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "name" VARCHAR(100) NOT NULL,
  "credit_limit" NUMERIC(15, 2) NOT NULL,
  "account_id" UUID NOT NULL,
  "closing_date" INTEGER NOT NULL,
  "due_date" INTEGER NOT NULL,
  "is_active" BOOLEAN NOT NULL DEFAULT true,
  "deleted_at" timestamp NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  CONSTRAINT "chk_closing_date" CHECK ("closing_date" BETWEEN 1 AND 31),
  CONSTRAINT "chk_due_date" CHECK ("due_date" BETWEEN 1 AND 31),
  CONSTRAINT "chk_due_after_closing" CHECK ("due_date" != "closing_date"),
  CONSTRAINT "chk_credit_limit_positive" CHECK ("credit_limit" >= 0),
  CONSTRAINT "uq_cards_account_name" UNIQUE ("account_id", "name")
);

CREATE TABLE "invoices" (
  "card_id" UUID NOT NULL,
  "billing_month" VARCHAR(7) NOT NULL,
  "status" invoice_status NOT NULL DEFAULT 'open',
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  PRIMARY KEY ("card_id", "billing_month"),
  CONSTRAINT "chk_billing_month_format" CHECK ("billing_month" ~ '^[0-9]{4}-[0-9]{2}$'),
  CONSTRAINT "chk_billing_month_valid" CHECK (
    SUBSTRING("billing_month", 6, 2)::INTEGER BETWEEN 1 AND 12 AND
    SUBSTRING("billing_month", 1, 4)::INTEGER BETWEEN 1900 AND 2100
  )
);

CREATE TABLE "investments" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "asset_name" VARCHAR(100) NOT NULL,
  "type" investment_type NOT NULL,
  "account_id" UUID NOT NULL,
  "index_type" index_type,
  "index_value" VARCHAR(50),
  "liquidity" liquidity_type NOT NULL,
  "is_rescued" BOOLEAN NOT NULL DEFAULT false,
  "validity" DATE,
  "current_value" NUMERIC(15, 2),
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "tags" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "name" VARCHAR(100) NOT NULL,
  "color" VARCHAR(7),
  "is_active" BOOLEAN NOT NULL DEFAULT true,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  CONSTRAINT "chk_tag_color_hex" CHECK ("color" IS NULL OR "color" ~* '^#[0-9A-Fa-f]{6}$')
);

-- =====================================================
-- RECURRING TABLES
-- =====================================================

CREATE TABLE "recurring_transfers" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "amount" NUMERIC(15, 2) NOT NULL,
  "source_account_id" UUID NOT NULL,
  "destination_account_id" UUID NOT NULL,
  "frequency" transaction_frequency NOT NULL,
  "start_date" DATE NOT NULL,
  "end_date" DATE,
  "is_active" BOOLEAN NOT NULL DEFAULT true,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  CONSTRAINT "chk_transfer_amount_positive" CHECK ("amount" > 0),
  CONSTRAINT "chk_transfer_dates" CHECK ("end_date" IS NULL OR "end_date" >= "start_date"),
  CONSTRAINT "chk_different_accounts" CHECK ("source_account_id" != "destination_account_id")
);

CREATE TABLE "recurring_transactions" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "amount" NUMERIC(15, 2) NOT NULL,
  "description" VARCHAR(200) NOT NULL,
  "frequency" transaction_frequency NOT NULL,
  "start_date" DATE NOT NULL,
  "end_date" DATE,
  "account_id" UUID NOT NULL,
  "category_id" UUID NOT NULL,
  "subcategory_id" UUID,
  "is_active" BOOLEAN NOT NULL DEFAULT true,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  CONSTRAINT "chk_recurring_amount" CHECK ("amount" != 0),
  CONSTRAINT "chk_recurring_dates" CHECK ("end_date" IS NULL OR "end_date" >= "start_date")
);

-- =====================================================
-- TRANSACTION TABLES
-- =====================================================

CREATE TABLE "transfers" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "recurring_transfer_id" UUID,
  "transaction_date" DATE NOT NULL,
  "amount" NUMERIC(15, 2) NOT NULL,
  "source_account_id" UUID NOT NULL,
  "destination_account_id" UUID NOT NULL,
  "transaction_status" transaction_status NOT NULL DEFAULT 'validating',
  "description" TEXT,
  "deleted_at" timestamp NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  CONSTRAINT "chk_transfer_amount_positive" CHECK ("amount" > 0),
  CONSTRAINT "chk_transfer_different_accounts" CHECK ("source_account_id" != "destination_account_id")
);

CREATE TABLE "incomes" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "description" TEXT NOT NULL,
  "amount" NUMERIC(15, 2) NOT NULL,
  "account_id" UUID NOT NULL,
  "category_id" UUID NOT NULL,
  "subcategory_id" UUID,
  "recurring_transaction_id" UUID,
  "transaction_status" transaction_status NOT NULL DEFAULT 'validating',
  "deleted_at" timestamp NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  CONSTRAINT "chk_income_amount_positive" CHECK ("amount" > 0)
);

CREATE TABLE "expenses" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "description" TEXT NOT NULL,
  "amount" NUMERIC(15, 2) NOT NULL,
  "account_id" UUID NOT NULL,
  "category_id" UUID NOT NULL,
  "subcategory_id" UUID,
  "recurring_transaction_id" UUID,
  "transaction_status" transaction_status NOT NULL DEFAULT 'validating',
  "deleted_at" timestamp NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  CONSTRAINT "chk_expense_amount_positive" CHECK ("amount" > 0)
);

CREATE TABLE "card_expenses" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "description" TEXT NOT NULL,
  "amount" NUMERIC(15, 2) NOT NULL,
  "subcategory_id" UUID,
  "category_id" UUID NOT NULL,
  "card_id" UUID NOT NULL,
  "billing_month" VARCHAR(7) NOT NULL,
  "recurring_card_transaction_id" UUID,
  "transaction_status" transaction_status NOT NULL DEFAULT 'validating',
  "deleted_at" timestamp NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  CONSTRAINT "chk_card_expense_amount_positive" CHECK ("amount" > 0),
  CONSTRAINT "chk_card_expense_billing_month_format" CHECK ("billing_month" ~ '^[0-9]{4}-[0-9]{2}$'),
  CONSTRAINT "chk_card_expense_billing_month_valid" CHECK (
    SUBSTRING("billing_month", 6, 2)::INTEGER BETWEEN 1 AND 12 AND
    SUBSTRING("billing_month", 1, 4)::INTEGER BETWEEN 1900 AND 2100
  )
);

CREATE TABLE "recurring_card_transactions" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "description" TEXT NOT NULL,
  "amount" NUMERIC(15, 2) NOT NULL,
  "card_id" UUID NOT NULL,
  "category_id" UUID NOT NULL,
  "subcategory_id" UUID,
  "start_date" DATE NOT NULL,
  "end_date" DATE,
  "frequency" transaction_frequency,
  "is_active" BOOLEAN NOT NULL DEFAULT true,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  CONSTRAINT "chk_recurring_card_amount_positive" CHECK ("amount" > 0),
  CONSTRAINT "chk_recurring_card_dates" CHECK ("end_date" IS NULL OR "end_date" >= "start_date"),
  CONSTRAINT "chk_subscription_or_installment" CHECK (
    ("end_date" IS NULL AND "frequency" IS NOT NULL) OR
    ("end_date" IS NOT NULL)
  )
);

CREATE TABLE "card_chargebacks" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "description" TEXT NOT NULL,
  "amount" NUMERIC(15, 2) NOT NULL,
  "card_id" UUID NOT NULL,
  "billing_month" VARCHAR(7) NOT NULL,
  "transaction_status" transaction_status NOT NULL DEFAULT 'validating',
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  CONSTRAINT "chk_chargeback_amount_positive" CHECK ("amount" > 0),
  CONSTRAINT "chk_chargeback_billing_month_format" CHECK ("billing_month" ~ '^[0-9]{4}-[0-9]{2}$'),
  CONSTRAINT "chk_chargeback_billing_month_valid" CHECK (
    SUBSTRING("billing_month", 6, 2)::INTEGER BETWEEN 1 AND 12 AND
    SUBSTRING("billing_month", 1, 4)::INTEGER BETWEEN 1900 AND 2100
  )
);

CREATE TABLE "card_payments" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "amount" NUMERIC(15, 2) NOT NULL,
  "account_id" UUID NOT NULL,
  "card_id" UUID NOT NULL,
  "billing_month" VARCHAR(7) NOT NULL,
  "is_final_payment" BOOLEAN NOT NULL DEFAULT false,
  "transaction_status" transaction_status NOT NULL DEFAULT 'validating',
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  CONSTRAINT "chk_payment_amount_positive" CHECK ("amount" > 0),
  CONSTRAINT "chk_payment_billing_month_format" CHECK ("billing_month" ~ '^[0-9]{4}-[0-9]{2}$'),
  CONSTRAINT "chk_payment_billing_month_valid" CHECK (
    SUBSTRING("billing_month", 6, 2)::INTEGER BETWEEN 1 AND 12 AND
    SUBSTRING("billing_month", 1, 4)::INTEGER BETWEEN 1900 AND 2100
  )
);

CREATE TABLE "investment_deposits" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "description" TEXT,
  "amount" NUMERIC(15, 2) NOT NULL,
  "recurring_transaction_id" UUID,
  "investment_id" UUID NOT NULL,
  "account_id" UUID NOT NULL,
  "transaction_status" transaction_status NOT NULL DEFAULT 'validating',
  "deleted_at" timestamp NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  CONSTRAINT "chk_deposit_amount_positive" CHECK ("amount" > 0)
);

CREATE TABLE "investment_withdrawals" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "description" TEXT,
  "amount" NUMERIC(15, 2) NOT NULL,
  "recurring_transaction_id" UUID,
  "investment_id" UUID NOT NULL,
  "account_id" UUID NOT NULL,
  "transaction_status" transaction_status NOT NULL DEFAULT 'validating',
  "deleted_at" timestamp NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  CONSTRAINT "chk_withdrawal_amount_positive" CHECK ("amount" > 0)
);

-- =====================================================
-- TAG RELATIONSHIP TABLES
-- =====================================================

CREATE TABLE "recurring_transactions_tags" (
  "recurring_transaction_id" UUID NOT NULL,
  "tag_id" UUID NOT NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  PRIMARY KEY ("recurring_transaction_id", "tag_id")
);

CREATE TABLE "incomes_tags" (
  "income_id" UUID NOT NULL,
  "tag_id" UUID NOT NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  PRIMARY KEY ("income_id", "tag_id")
);

CREATE TABLE "expenses_tags" (
  "expense_id" UUID NOT NULL,
  "tag_id" UUID NOT NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  PRIMARY KEY ("expense_id", "tag_id")
);

CREATE TABLE "investments_tags" (
  "investment_id" UUID NOT NULL,
  "tag_id" UUID NOT NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  PRIMARY KEY ("investment_id", "tag_id")
);

CREATE TABLE "card_expenses_tags" (
  "card_expense_id" UUID NOT NULL,
  "tag_id" UUID NOT NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  PRIMARY KEY ("card_expense_id", "tag_id")
);

CREATE TABLE "recurring_card_transactions_tags" (
  "recurring_card_transaction_id" UUID NOT NULL,
  "tag_id" UUID NOT NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  PRIMARY KEY ("recurring_card_transaction_id", "tag_id")
);

-- =====================================================
-- INTEGRATION TABLE
-- =====================================================


-- FOREIGN KEYS
-- =====================================================

-- Currencies
ALTER TABLE "accounts" ADD FOREIGN KEY ("currency_code") REFERENCES "currencies" ("code") ON DELETE RESTRICT;
ALTER TABLE "exchange_rates" ADD FOREIGN KEY ("from_currency") REFERENCES "currencies" ("code") ON DELETE RESTRICT;
ALTER TABLE "exchange_rates" ADD FOREIGN KEY ("to_currency") REFERENCES "currencies" ("code") ON DELETE RESTRICT;

-- User relationships
ALTER TABLE "accounts" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE;

-- Account relationships
ALTER TABLE "cards" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;
ALTER TABLE "investments" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;
ALTER TABLE "recurring_transactions" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;
ALTER TABLE "incomes" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;
ALTER TABLE "expenses" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;
ALTER TABLE "card_payments" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;
ALTER TABLE "investment_deposits" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;
ALTER TABLE "investment_withdrawals" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;

-- Transfer relationships
ALTER TABLE "transfers" ADD FOREIGN KEY ("source_account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;
ALTER TABLE "transfers" ADD FOREIGN KEY ("destination_account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;
ALTER TABLE "transfers" ADD FOREIGN KEY ("recurring_transfer_id") REFERENCES "recurring_transfers" ("id") ON DELETE SET NULL;
ALTER TABLE "recurring_transfers" ADD FOREIGN KEY ("source_account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;
ALTER TABLE "recurring_transfers" ADD FOREIGN KEY ("destination_account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;

-- Category relationships
ALTER TABLE "sub_categories" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("id") ON DELETE CASCADE;
ALTER TABLE "incomes" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("id") ON DELETE RESTRICT;
ALTER TABLE "incomes" ADD FOREIGN KEY ("subcategory_id") REFERENCES "sub_categories" ("id") ON DELETE SET NULL;
ALTER TABLE "expenses" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("id") ON DELETE RESTRICT;
ALTER TABLE "expenses" ADD FOREIGN KEY ("subcategory_id") REFERENCES "sub_categories" ("id") ON DELETE SET NULL;
ALTER TABLE "recurring_transactions" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("id") ON DELETE RESTRICT;
ALTER TABLE "recurring_transactions" ADD FOREIGN KEY ("subcategory_id") REFERENCES "sub_categories" ("id") ON DELETE SET NULL;
ALTER TABLE "card_expenses" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("id") ON DELETE RESTRICT;
ALTER TABLE "card_expenses" ADD FOREIGN KEY ("subcategory_id") REFERENCES "sub_categories" ("id") ON DELETE SET NULL;

-- Card and invoice relationships
ALTER TABLE "invoices" ADD FOREIGN KEY ("card_id") REFERENCES "cards" ("id") ON DELETE CASCADE;
ALTER TABLE "card_expenses" ADD FOREIGN KEY ("card_id", "billing_month") REFERENCES "invoices" ("card_id", "billing_month") ON DELETE CASCADE;
ALTER TABLE "card_expenses" ADD FOREIGN KEY ("recurring_card_transaction_id") REFERENCES "recurring_card_transactions" ("id") ON DELETE SET NULL;
ALTER TABLE "recurring_card_transactions" ADD FOREIGN KEY ("card_id") REFERENCES "cards" ("id") ON DELETE CASCADE;
ALTER TABLE "recurring_card_transactions" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("id") ON DELETE RESTRICT;
ALTER TABLE "recurring_card_transactions" ADD FOREIGN KEY ("subcategory_id") REFERENCES "sub_categories" ("id") ON DELETE SET NULL;
ALTER TABLE "card_chargebacks" ADD FOREIGN KEY ("card_id", "billing_month") REFERENCES "invoices" ("card_id", "billing_month") ON DELETE CASCADE;
ALTER TABLE "card_payments" ADD FOREIGN KEY ("card_id", "billing_month") REFERENCES "invoices" ("card_id", "billing_month") ON DELETE CASCADE;

-- Investment relationships
ALTER TABLE "investment_deposits" ADD FOREIGN KEY ("investment_id") REFERENCES "investments" ("id") ON DELETE CASCADE;
ALTER TABLE "investment_withdrawals" ADD FOREIGN KEY ("investment_id") REFERENCES "investments" ("id") ON DELETE CASCADE;

-- Recurring transaction relationships
ALTER TABLE "incomes" ADD FOREIGN KEY ("recurring_transaction_id") REFERENCES "recurring_transactions" ("id") ON DELETE SET NULL;
ALTER TABLE "expenses" ADD FOREIGN KEY ("recurring_transaction_id") REFERENCES "recurring_transactions" ("id") ON DELETE SET NULL;
ALTER TABLE "investment_deposits" ADD FOREIGN KEY ("recurring_transaction_id") REFERENCES "recurring_transactions" ("id") ON DELETE SET NULL;
ALTER TABLE "investment_withdrawals" ADD FOREIGN KEY ("recurring_transaction_id") REFERENCES "recurring_transactions" ("id") ON DELETE SET NULL;

-- Tag relationships
ALTER TABLE "recurring_transactions_tags" ADD FOREIGN KEY ("recurring_transaction_id") REFERENCES "recurring_transactions" ("id") ON DELETE CASCADE;
ALTER TABLE "recurring_transactions_tags" ADD FOREIGN KEY ("tag_id") REFERENCES "tags" ("id") ON DELETE CASCADE;
ALTER TABLE "incomes_tags" ADD FOREIGN KEY ("income_id") REFERENCES "incomes" ("id") ON DELETE CASCADE;
ALTER TABLE "incomes_tags" ADD FOREIGN KEY ("tag_id") REFERENCES "tags" ("id") ON DELETE CASCADE;
ALTER TABLE "expenses_tags" ADD FOREIGN KEY ("expense_id") REFERENCES "expenses" ("id") ON DELETE CASCADE;
ALTER TABLE "expenses_tags" ADD FOREIGN KEY ("tag_id") REFERENCES "tags" ("id") ON DELETE CASCADE;
ALTER TABLE "investments_tags" ADD FOREIGN KEY ("investment_id") REFERENCES "investments" ("id") ON DELETE CASCADE;
ALTER TABLE "investments_tags" ADD FOREIGN KEY ("tag_id") REFERENCES "tags" ("id") ON DELETE CASCADE;
ALTER TABLE "card_expenses_tags" ADD FOREIGN KEY ("card_expense_id") REFERENCES "card_expenses" ("id") ON DELETE CASCADE;
ALTER TABLE "card_expenses_tags" ADD FOREIGN KEY ("tag_id") REFERENCES "tags" ("id") ON DELETE CASCADE;
ALTER TABLE "recurring_card_transactions_tags" ADD FOREIGN KEY ("recurring_card_transaction_id") REFERENCES "recurring_card_transactions" ("id") ON DELETE CASCADE;
ALTER TABLE "recurring_card_transactions_tags" ADD FOREIGN KEY ("tag_id") REFERENCES "tags" ("id") ON DELETE CASCADE;

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- User and account indexes
CREATE INDEX "idx_accounts_user_id" ON "accounts" ("user_id");
CREATE INDEX "idx_accounts_active" ON "accounts" ("is_active") WHERE "is_active" = true;

-- Category indexes
CREATE UNIQUE INDEX "uq_sub_categories_name_category" ON "sub_categories" ("name", "category_id");

-- Card and invoice indexes
CREATE INDEX "idx_invoices_status" ON "invoices" ("status");
CREATE INDEX "idx_invoices_billing_month" ON "invoices" ("billing_month");
CREATE INDEX "idx_invoices_card_id" ON "invoices" ("card_id");

-- Transaction date indexes (critical for financial queries)
CREATE INDEX "idx_transfers_transaction_date" ON "transfers" ("transaction_date");
CREATE INDEX "idx_incomes_transaction_date" ON "incomes" ("transaction_date");
CREATE INDEX "idx_expenses_transaction_date" ON "expenses" ("transaction_date");
CREATE INDEX "idx_card_expenses_transaction_date" ON "card_expenses" ("transaction_date");

-- Performance indexes for ID fields are not needed (unique primary keys)

-- Status indexes for filtering
CREATE INDEX "idx_transfers_status" ON "transfers" ("transaction_status");
CREATE INDEX "idx_incomes_status" ON "incomes" ("transaction_status");
CREATE INDEX "idx_expenses_status" ON "expenses" ("transaction_status");
CREATE INDEX "idx_card_expenses_status" ON "card_expenses" ("transaction_status");
CREATE INDEX "idx_card_chargebacks_status" ON "card_chargebacks" ("transaction_status");
CREATE INDEX "idx_card_payments_status" ON "card_payments" ("transaction_status");

-- Account-based indexes
CREATE INDEX "idx_transfers_source_account" ON "transfers" ("source_account_id");
CREATE INDEX "idx_transfers_destination_account" ON "transfers" ("destination_account_id");
CREATE INDEX "idx_incomes_account" ON "incomes" ("account_id");
CREATE INDEX "idx_expenses_account" ON "expenses" ("account_id");

-- Category indexes
CREATE INDEX "idx_incomes_category" ON "incomes" ("category_id");
CREATE INDEX "idx_incomes_subcategory" ON "incomes" ("subcategory_id");
CREATE INDEX "idx_expenses_category" ON "expenses" ("category_id");
CREATE INDEX "idx_expenses_subcategory" ON "expenses" ("subcategory_id");
CREATE INDEX "idx_card_expenses_category" ON "card_expenses" ("category_id");
CREATE INDEX "idx_card_expenses_subcategory" ON "card_expenses" ("subcategory_id");

-- Recurring transaction indexes
CREATE INDEX "idx_incomes_recurring" ON "incomes" ("recurring_transaction_id");
CREATE INDEX "idx_expenses_recurring" ON "expenses" ("recurring_transaction_id");
CREATE INDEX "idx_recurring_transactions_account" ON "recurring_transactions" ("account_id");
CREATE INDEX "idx_recurring_transfers_source" ON "recurring_transfers" ("source_account_id");
CREATE INDEX "idx_recurring_transfers_destination" ON "recurring_transfers" ("destination_account_id");

-- Invoice and card indexes
CREATE INDEX "idx_card_expenses_card_billing" ON "card_expenses" ("card_id", "billing_month");
CREATE INDEX "idx_card_expenses_recurring_card_transaction" ON "card_expenses" ("recurring_card_transaction_id");

-- Recurring card transactions indexes
CREATE INDEX "idx_recurring_card_transactions_card" ON "recurring_card_transactions" ("card_id");
CREATE INDEX "idx_recurring_card_transactions_category" ON "recurring_card_transactions" ("category_id");
CREATE INDEX "idx_recurring_card_transactions_subcategory" ON "recurring_card_transactions" ("subcategory_id");
CREATE INDEX "idx_recurring_card_transactions_active" ON "recurring_card_transactions" ("is_active") WHERE "is_active" = true;
CREATE INDEX "idx_recurring_card_transactions_dates" ON "recurring_card_transactions" ("start_date", "end_date");
CREATE INDEX "idx_card_chargebacks_card_billing" ON "card_chargebacks" ("card_id", "billing_month");
CREATE INDEX "idx_card_payments_account" ON "card_payments" ("account_id");
CREATE INDEX "idx_card_payments_card_billing" ON "card_payments" ("card_id", "billing_month");

-- Investment indexes
CREATE INDEX "idx_investments_account" ON "investments" ("account_id");
CREATE INDEX "idx_investments_type" ON "investments" ("type");
CREATE INDEX "idx_investment_deposits_investment" ON "investment_deposits" ("investment_id");
CREATE INDEX "idx_investment_deposits_account" ON "investment_deposits" ("account_id");
CREATE INDEX "idx_investment_withdrawals_investment" ON "investment_withdrawals" ("investment_id");
CREATE INDEX "idx_investment_withdrawals_account" ON "investment_withdrawals" ("account_id");


-- Exchange rates indexes
CREATE INDEX "idx_exchange_rates_from_currency" ON "exchange_rates" ("from_currency");
CREATE INDEX "idx_exchange_rates_to_currency" ON "exchange_rates" ("to_currency");
CREATE INDEX "idx_exchange_rates_date" ON "exchange_rates" ("rate_date");

-- Soft delete indexes
CREATE INDEX "idx_users_deleted" ON "users" ("deleted_at") WHERE "deleted_at" IS NULL;
CREATE INDEX "idx_accounts_deleted" ON "accounts" ("deleted_at") WHERE "deleted_at" IS NULL;
CREATE INDEX "idx_cards_deleted" ON "cards" ("deleted_at") WHERE "deleted_at" IS NULL;

-- Function to approve all validating transactions
CREATE OR REPLACE FUNCTION approve_all_validating_transactions()
RETURNS TABLE(
    table_name TEXT,
    updated_count INTEGER
) AS $$
DECLARE
    transfers_count INTEGER;
    incomes_count INTEGER;
    expenses_count INTEGER;
    card_expenses_count INTEGER;
    card_chargebacks_count INTEGER;
    card_payments_count INTEGER;
    investment_deposits_count INTEGER;
    investment_withdrawals_count INTEGER;
BEGIN
    -- Update transfers
    UPDATE transfers SET transaction_status = 'paid' 
    WHERE transaction_status = 'validating';
    GET DIAGNOSTICS transfers_count = ROW_COUNT;
    
    -- Update incomes
    UPDATE incomes SET transaction_status = 'paid' 
    WHERE transaction_status = 'validating';
    GET DIAGNOSTICS incomes_count = ROW_COUNT;
    
    -- Update expenses
    UPDATE expenses SET transaction_status = 'paid' 
    WHERE transaction_status = 'validating';
    GET DIAGNOSTICS expenses_count = ROW_COUNT;
    
    -- Update card_expenses
    UPDATE card_expenses SET transaction_status = 'paid' 
    WHERE transaction_status = 'validating';
    GET DIAGNOSTICS card_expenses_count = ROW_COUNT;
    
    -- Update card_chargebacks
    UPDATE card_chargebacks SET transaction_status = 'paid' 
    WHERE transaction_status = 'validating';
    GET DIAGNOSTICS card_chargebacks_count = ROW_COUNT;
    
    -- Update card_payments
    UPDATE card_payments SET transaction_status = 'paid' 
    WHERE transaction_status = 'validating';
    GET DIAGNOSTICS card_payments_count = ROW_COUNT;
    
    -- Update investment_deposits
    UPDATE investment_deposits SET transaction_status = 'paid' 
    WHERE transaction_status = 'validating';
    GET DIAGNOSTICS investment_deposits_count = ROW_COUNT;
    
    -- Update investment_withdrawals
    UPDATE investment_withdrawals SET transaction_status = 'paid' 
    WHERE transaction_status = 'validating';
    GET DIAGNOSTICS investment_withdrawals_count = ROW_COUNT;
    
    -- Return summary
    RETURN QUERY VALUES
        ('transfers', transfers_count),
        ('incomes', incomes_count),
        ('expenses', expenses_count),
        ('card_expenses', card_expenses_count),
        ('card_chargebacks', card_chargebacks_count),
        ('card_payments', card_payments_count),
        ('investment_deposits', investment_deposits_count),
        ('investment_withdrawals', investment_withdrawals_count);
END;
$$ LANGUAGE plpgsql;


-- TRIGGERS FOR UPDATED_AT
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to all tables with updated_at
CREATE TRIGGER trigger_users_updated_at BEFORE UPDATE ON "users" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_accounts_updated_at BEFORE UPDATE ON "accounts" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_categories_updated_at BEFORE UPDATE ON "categories" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_sub_categories_updated_at BEFORE UPDATE ON "sub_categories" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_cards_updated_at BEFORE UPDATE ON "cards" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_invoices_updated_at BEFORE UPDATE ON "invoices" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_investments_updated_at BEFORE UPDATE ON "investments" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_tags_updated_at BEFORE UPDATE ON "tags" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_recurring_transfers_updated_at BEFORE UPDATE ON "recurring_transfers" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_recurring_transactions_updated_at BEFORE UPDATE ON "recurring_transactions" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_transfers_updated_at BEFORE UPDATE ON "transfers" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_incomes_updated_at BEFORE UPDATE ON "incomes" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_expenses_updated_at BEFORE UPDATE ON "expenses" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_card_expenses_updated_at BEFORE UPDATE ON "card_expenses" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_recurring_card_transactions_updated_at BEFORE UPDATE ON "recurring_card_transactions" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_card_chargebacks_updated_at BEFORE UPDATE ON "card_chargebacks" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_card_payments_updated_at BEFORE UPDATE ON "card_payments" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_investment_deposits_updated_at BEFORE UPDATE ON "investment_deposits" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_investment_withdrawals_updated_at BEFORE UPDATE ON "investment_withdrawals" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_currencies_updated_at BEFORE UPDATE ON "currencies" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_recurring_transactions_tags_updated_at BEFORE UPDATE ON "recurring_transactions_tags" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_incomes_tags_updated_at BEFORE UPDATE ON "incomes_tags" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_expenses_tags_updated_at BEFORE UPDATE ON "expenses_tags" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_investments_tags_updated_at BEFORE UPDATE ON "investments_tags" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_card_expenses_tags_updated_at BEFORE UPDATE ON "card_expenses_tags" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_recurring_card_transactions_tags_updated_at BEFORE UPDATE ON "recurring_card_transactions_tags" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- INITIAL DATA
-- =====================================================

-- Insert default currencies
INSERT INTO "currencies" ("code", "name", "symbol") VALUES
('BRL', 'Real Brasileiro', 'R$'),
('USD', 'US Dollar', '$'),
('EUR', 'Euro', '€');

-- Insert initial exchange rates (example rates - should be updated with real data)
INSERT INTO "exchange_rates" ("from_currency", "to_currency", "rate", "rate_date", "source") VALUES
('USD', 'BRL', 5.20, CURRENT_DATE, 'manual'),
('EUR', 'BRL', 5.60, CURRENT_DATE, 'manual'),
('BRL', 'USD', 0.192, CURRENT_DATE, 'manual'),
('BRL', 'EUR', 0.179, CURRENT_DATE, 'manual'),
('USD', 'EUR', 0.92, CURRENT_DATE, 'manual'),
('EUR', 'USD', 1.09, CURRENT_DATE, 'manual');

-- =====================================================
-- USEFUL VIEWS
-- =====================================================

CREATE VIEW "v_account_balances" AS
SELECT 
    a.id,
    a.name,
    a.type,
    a.currency_code,
    a.initial_balance,
    COALESCE(income_total.total, 0) AS total_incomes,
    COALESCE(expense_total.total, 0) AS total_expenses,
    COALESCE(transfer_in.total, 0) AS total_transfers_in,
    COALESCE(transfer_out.total, 0) AS total_transfers_out,
    COALESCE(investment_deposits.total, 0) AS total_investment_deposits,
    COALESCE(investment_withdrawals.total, 0) AS total_investment_withdrawals,
    a.initial_balance + 
    COALESCE(income_total.total, 0) - 
    COALESCE(expense_total.total, 0) + 
    COALESCE(transfer_in.total, 0) - 
    COALESCE(transfer_out.total, 0) -
    COALESCE(investment_deposits.total, 0) +
    COALESCE(investment_withdrawals.total, 0) AS current_balance
FROM accounts a
LEFT JOIN (
    SELECT account_id, SUM(amount) as total
    FROM incomes 
    WHERE transaction_status = 'paid' AND deleted_at IS NULL
    GROUP BY account_id
) income_total ON a.id = income_total.account_id
LEFT JOIN (
    SELECT account_id, SUM(amount) as total
    FROM expenses 
    WHERE transaction_status = 'paid' AND deleted_at IS NULL
    GROUP BY account_id
) expense_total ON a.id = expense_total.account_id
LEFT JOIN (
    SELECT destination_account_id as account_id, SUM(amount) as total
    FROM transfers 
    WHERE transaction_status = 'paid' AND deleted_at IS NULL
    GROUP BY destination_account_id
) transfer_in ON a.id = transfer_in.account_id
LEFT JOIN (
    SELECT source_account_id as account_id, SUM(amount) as total
    FROM transfers 
    WHERE transaction_status = 'paid' AND deleted_at IS NULL
    GROUP BY source_account_id
) transfer_out ON a.id = transfer_out.account_id
LEFT JOIN (
    SELECT account_id, SUM(amount) as total
    FROM investment_deposits 
    WHERE transaction_status = 'paid' AND deleted_at IS NULL
    GROUP BY account_id
) investment_deposits ON a.id = investment_deposits.account_id
LEFT JOIN (
    SELECT account_id, SUM(amount) as total
    FROM investment_withdrawals 
    WHERE transaction_status = 'paid' AND deleted_at IS NULL
    GROUP BY account_id
) investment_withdrawals ON a.id = investment_withdrawals.account_id
WHERE a.deleted_at IS NULL;

-- View for monthly expenses by category
CREATE VIEW "v_monthly_expenses_by_category" AS
SELECT 
    DATE_TRUNC('month', e.transaction_date) as month_year,
    c.name as category_name,
    c.color as category_color,
    COUNT(*) as transaction_count,
    SUM(e.amount) as total_amount,
    AVG(e.amount) as average_amount
FROM expenses e
JOIN categories c ON e.category_id = c.id
WHERE e.transaction_status = 'paid' AND e.deleted_at IS NULL
GROUP BY DATE_TRUNC('month', e.transaction_date), c.id, c.name, c.color
ORDER BY month_year DESC, total_amount DESC;

-- View for card invoice summary
CREATE VIEW "v_card_invoice_summary" AS
SELECT 
    i.card_id,
    i.billing_month,
    c.name as card_name,
    i.status,
    COALESCE(SUM(ce.amount), 0) as total_expenses,
    COALESCE(SUM(cp.amount), 0) as total_payments,
    COALESCE(SUM(cb.amount), 0) as total_chargebacks,
    COALESCE(SUM(ce.amount), 0) - COALESCE(SUM(cb.amount), 0) as net_invoice_amount,
    COALESCE(SUM(ce.amount), 0) - COALESCE(SUM(cb.amount), 0) - COALESCE(SUM(cp.amount), 0) as remaining_balance,
    COUNT(ce.id) as expense_count
FROM invoices i
JOIN cards c ON i.card_id = c.id
LEFT JOIN card_expenses ce ON i.card_id = ce.card_id AND i.billing_month = ce.billing_month AND ce.deleted_at IS NULL
LEFT JOIN card_chargebacks cb ON i.card_id = cb.card_id AND i.billing_month = cb.billing_month
LEFT JOIN card_payments cp ON i.card_id = cp.card_id AND i.billing_month = cp.billing_month
GROUP BY i.card_id, i.billing_month, c.name, i.status
ORDER BY i.billing_month DESC;

-- View for investment portfolio summary
CREATE VIEW "v_investment_portfolio" AS
SELECT 
    inv.id,
    inv.asset_name,
    inv.type,
    inv.liquidity,
    a.name as account_name,
    COALESCE(deposits.total_deposits, 0) as total_invested,
    COALESCE(withdrawals.total_withdrawals, 0) as total_withdrawn,
    COALESCE(deposits.total_deposits, 0) - COALESCE(withdrawals.total_withdrawals, 0) as net_invested,
    inv.current_value,
    CASE 
        WHEN COALESCE(deposits.total_deposits, 0) > 0 
        THEN ((inv.current_value - (COALESCE(deposits.total_deposits, 0) - COALESCE(withdrawals.total_withdrawals, 0))) / 
              (COALESCE(deposits.total_deposits, 0) - COALESCE(withdrawals.total_withdrawals, 0))) * 100
        ELSE 0 
    END as return_percentage
FROM investments inv
JOIN accounts a ON inv.account_id = a.id
LEFT JOIN (
    SELECT investment_id, SUM(amount) as total_deposits
    FROM investment_deposits 
    WHERE transaction_status = 'paid' AND deleted_at IS NULL
    GROUP BY investment_id
) deposits ON inv.id = deposits.investment_id
LEFT JOIN (
    SELECT investment_id, SUM(amount) as total_withdrawals
    FROM investment_withdrawals 
    WHERE transaction_status = 'paid' AND deleted_at IS NULL
    GROUP BY investment_id
) withdrawals ON inv.id = withdrawals.investment_id
WHERE inv.is_rescued = false;

-- View for cash flow analysis
CREATE VIEW "v_monthly_cash_flow" AS
WITH monthly_data AS (
    SELECT 
        DATE_TRUNC('month', transaction_date) as month_year,
        'income' as type,
        SUM(amount) as amount
    FROM incomes 
    WHERE transaction_status = 'paid' AND deleted_at IS NULL
    GROUP BY DATE_TRUNC('month', transaction_date)
    
    UNION ALL
    
    SELECT 
        DATE_TRUNC('month', transaction_date) as month_year,
        'expense' as type,
        SUM(amount) as amount
    FROM expenses 
    WHERE transaction_status = 'paid' AND deleted_at IS NULL
    GROUP BY DATE_TRUNC('month', transaction_date)
)
SELECT 
    month_year,
    COALESCE(MAX(CASE WHEN type = 'income' THEN amount END), 0) as total_income,
    COALESCE(MAX(CASE WHEN type = 'expense' THEN amount END), 0) as total_expense,
    COALESCE(MAX(CASE WHEN type = 'income' THEN amount END), 0) - 
    COALESCE(MAX(CASE WHEN type = 'expense' THEN amount END), 0) as net_cash_flow
FROM monthly_data
GROUP BY month_year
ORDER BY month_year DESC;
