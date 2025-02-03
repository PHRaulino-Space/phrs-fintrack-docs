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
  "type" VARCHAR(50) NOT NULL,
  "initial_balance" NUMERIC(15,2) NOT NULL,
  "currency" VARCHAR(10) NOT NULL,
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
  "status" UUID NOT NULL,
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
  "frequency" VARCHAR(50) NOT NULL,
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
  "type" VARCHAR(50) NOT NULL,
  "account_id" UUID NOT NULL,
  "index_type" VARCHAR(50),
  "index_value" VARCHAR(50),
  "liquidity" VARCHAR(50),
  "fl_rescued" BOOLEAN,
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

CREATE TABLE "expenses_card" (
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

CREATE TABLE "chargeback_card" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "description" TEXT,
  "amount" NUMERIC(15,2) NOT NULL,
  "invoice_id" UUID,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE TABLE "payment_card" (
  "id" UUID PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "transaction_date" DATE NOT NULL,
  "amount" NUMERIC(15,2) NOT NULL,
  "account_id" UUID NOT NULL,
  "invoice_id" UUID NOT NULL,
  "fl_finally" BOOLEAN NOT NULL DEFAULT false,
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

CREATE TABLE "expense_card_tags" (
  "expense_card_id" UUID NOT NULL,
  "tag_id" UUID NOT NULL,
  "created_at" TIMESTAMP DEFAULT (now()),
  "updated_at" TIMESTAMP DEFAULT (now())
);

CREATE UNIQUE INDEX ON "invoices" ("card_id", "billing_month");

ALTER TABLE "accounts" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "subcategories" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("id");

ALTER TABLE "cards" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id");

ALTER TABLE "invoices" ADD FOREIGN KEY ("card_id") REFERENCES "cards" ("id");

ALTER TABLE "invoices" ADD FOREIGN KEY ("status") REFERENCES "transaction_statuses" ("id");

ALTER TABLE "transfers" ADD FOREIGN KEY ("source_account_id") REFERENCES "accounts" ("id");

ALTER TABLE "transfers" ADD FOREIGN KEY ("destination_account_id") REFERENCES "accounts" ("id");

ALTER TABLE "recurring_transactions" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id");

ALTER TABLE "recurring_transactions" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("id");

ALTER TABLE "recurring_transactions" ADD FOREIGN KEY ("subcategory_id") REFERENCES "subcategories" ("id");

ALTER TABLE "investments" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id");

ALTER TABLE "recurring_transactions_tags" ADD FOREIGN KEY ("recurring_transactions_id") REFERENCES "recurring_transactions" ("id");

ALTER TABLE "recurring_transactions_tags" ADD FOREIGN KEY ("tag_id") REFERENCES "tags" ("id");

ALTER TABLE "incomes" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id");

ALTER TABLE "incomes" ADD FOREIGN KEY ("recurring_transaction_id") REFERENCES "recurring_transactions" ("id");

ALTER TABLE "incomes" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("id");

ALTER TABLE "incomes" ADD FOREIGN KEY ("subcategory_id") REFERENCES "subcategories" ("id");

ALTER TABLE "incomes" ADD FOREIGN KEY ("transaction_status_id") REFERENCES "transaction_statuses" ("id");

ALTER TABLE "expenses" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id");

ALTER TABLE "expenses" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("id");

ALTER TABLE "expenses" ADD FOREIGN KEY ("subcategory_id") REFERENCES "subcategories" ("id");

ALTER TABLE "expenses" ADD FOREIGN KEY ("transaction_status_id") REFERENCES "transaction_statuses" ("id");

ALTER TABLE "expenses" ADD FOREIGN KEY ("recurring_transaction_id") REFERENCES "recurring_transactions" ("id");

ALTER TABLE "expenses_card" ADD FOREIGN KEY ("subcategory_id") REFERENCES "subcategories" ("id");

ALTER TABLE "expenses_card" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("id");

ALTER TABLE "expenses_card" ADD FOREIGN KEY ("recurring_transaction_id") REFERENCES "recurring_transactions" ("id");

ALTER TABLE "expenses_card" ADD FOREIGN KEY ("invoice_id") REFERENCES "invoices" ("id");

ALTER TABLE "chargeback_card" ADD FOREIGN KEY ("invoice_id") REFERENCES "invoices" ("id");

ALTER TABLE "payment_card" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id");

ALTER TABLE "payment_card" ADD FOREIGN KEY ("invoice_id") REFERENCES "invoices" ("id");

ALTER TABLE "investment_deposit" ADD FOREIGN KEY ("recurring_transaction_id") REFERENCES "recurring_transactions" ("id");

ALTER TABLE "investment_deposit" ADD FOREIGN KEY ("investment_id") REFERENCES "investments" ("id");

ALTER TABLE "investment_withdrawal" ADD FOREIGN KEY ("recurring_transaction_id") REFERENCES "recurring_transactions" ("id");

ALTER TABLE "investment_withdrawal" ADD FOREIGN KEY ("investment_id") REFERENCES "investments" ("id");

ALTER TABLE "incomes_tags" ADD FOREIGN KEY ("income_id") REFERENCES "incomes" ("id");

ALTER TABLE "incomes_tags" ADD FOREIGN KEY ("tag_id") REFERENCES "tags" ("id");

ALTER TABLE "expenses_tags" ADD FOREIGN KEY ("expense_id") REFERENCES "expenses" ("id");

ALTER TABLE "expenses_tags" ADD FOREIGN KEY ("tag_id") REFERENCES "tags" ("id");

ALTER TABLE "investments_tags" ADD FOREIGN KEY ("investment_id") REFERENCES "investments" ("id");

ALTER TABLE "investments_tags" ADD FOREIGN KEY ("tag_id") REFERENCES "tags" ("id");

ALTER TABLE "expense_card_tags" ADD FOREIGN KEY ("expense_card_id") REFERENCES "expenses_card" ("id");

ALTER TABLE "expense_card_tags" ADD FOREIGN KEY ("tag_id") REFERENCES "tags" ("id");
