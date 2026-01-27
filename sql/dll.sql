-- DROP SCHEMA public;

CREATE SCHEMA public AUTHORIZATION pg_database_owner;

-- DROP TYPE public."account_type";

CREATE TYPE public."account_type" AS ENUM (
	'CHECKING',
	'SAVINGS',
	'WALLET',
	'INVESTMENT',
	'CRIPTO',
	'CRIPTOWALLET');

-- DROP TYPE public."category_type";

CREATE TYPE public."category_type" AS ENUM (
	'INCOME',
	'EXPENSE');

-- DROP TYPE public.halfvec;

CREATE TYPE public.halfvec (
	INPUT = halfvec_in,
	OUTPUT = halfvec_out,
	RECEIVE = halfvec_recv,
	SEND = halfvec_send,
	TYPMOD_IN = halfvec_typmod_in,
	ALIGNMENT = 4,
	STORAGE = secondary,
	CATEGORY = U,
	DELIMITER = ',');

-- DROP TYPE public."index_type";

CREATE TYPE public."index_type" AS ENUM (
	'CDI',
	'IPCA',
	'SELIC',
	'FIXED');

-- DROP TYPE public."investment_type";

CREATE TYPE public."investment_type" AS ENUM (
	'RENDA_FIXA',
	'RENDA_VARIAVEL',
	'TESOURO_DIRETO',
	'FUNDO_INVESTIMENTO');

-- DROP TYPE public."invoice_status";

CREATE TYPE public."invoice_status" AS ENUM (
	'OPEN',
	'PAID',
	'OVERDUE');

-- DROP TYPE public."liquidity_type";

CREATE TYPE public."liquidity_type" AS ENUM (
	'DAILY',
	'MONTHLY',
	'AT_MATURITY');

-- DROP TYPE public.sparsevec;

CREATE TYPE public.sparsevec (
	INPUT = sparsevec_in,
	OUTPUT = sparsevec_out,
	RECEIVE = sparsevec_recv,
	SEND = sparsevec_send,
	TYPMOD_IN = sparsevec_typmod_in,
	ALIGNMENT = 4,
	STORAGE = secondary,
	CATEGORY = U,
	DELIMITER = ',');

-- DROP TYPE public."staged_transaction_status";

CREATE TYPE public."staged_transaction_status" AS ENUM (
	'PROCESSING',
	'COMPLETED',
	'PENDING',
	'READY');

-- DROP TYPE public."staged_transaction_type";

CREATE TYPE public."staged_transaction_type" AS ENUM (
	'INCOME',
	'EXPENSE',
	'TRANSFER',
	'INVESTMENT_DEPOSIT',
	'INVESTMENT_WITHDRAWAL',
	'CARD_PAYMENT',
	'CARD_EXPENSE',
	'CARD_CHARGEBACK');

-- DROP TYPE public."transaction_frequency";

CREATE TYPE public."transaction_frequency" AS ENUM (
	'DAILY',
	'WEEKLY',
	'BIWEEKLY',
	'MONTHLY',
	'BIMONTHLY',
	'QUARTERLY',
	'YEARLY');

-- DROP TYPE public."transaction_status";

CREATE TYPE public."transaction_status" AS ENUM (
	'VALIDATING',
	'PAID',
	'PENDING',
	'IGNORE');

-- DROP TYPE public.vector;

CREATE TYPE public.vector (
	INPUT = vector_in,
	OUTPUT = vector_out,
	RECEIVE = vector_recv,
	SEND = vector_send,
	TYPMOD_IN = vector_typmod_in,
	ALIGNMENT = 4,
	STORAGE = secondary,
	CATEGORY = U,
	DELIMITER = ',');
-- public.category_embeddings definition

-- Drop table

-- DROP TABLE public.category_embeddings;

CREATE TABLE public.category_embeddings (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	description_text varchar(255) NOT NULL,
	description_vector public.vector NULL,
	category_vector public.vector NULL,
	workspace_id uuid NULL,
	sub_category_vector public.vector NULL,
	model varchar(100) NULL,
	created_at timestamptz DEFAULT now() NULL,
	CONSTRAINT category_embeddings_pkey PRIMARY KEY (id),
	CONSTRAINT uni_category_embeddings_description_text UNIQUE (description_text)
);
CREATE INDEX idx_category_embeddings_description_text ON public.category_embeddings USING btree (description_text);
CREATE INDEX idx_category_embeddings_workspace_id ON public.category_embeddings USING btree (workspace_id);


-- public.currencies definition

-- Drop table

-- DROP TABLE public.currencies;

CREATE TABLE public.currencies (
	code varchar(3) NOT NULL,
	"name" varchar(50) NOT NULL,
	symbol varchar(5) NOT NULL,
	is_active bool DEFAULT true NOT NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT currencies_pkey PRIMARY KEY (code)
);


-- public.users definition

-- Drop table

-- DROP TABLE public.users;

CREATE TABLE public.users (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	"name" varchar(100) NULL,
	email varchar(255) NOT NULL,
	password_hash varchar(255) NULL,
	external_id varchar(255) NULL,
	deleted_at timestamptz NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	"role" varchar(20) DEFAULT 'user'::character varying NULL,
	CONSTRAINT uni_users_email UNIQUE (email),
	CONSTRAINT uni_users_external_id UNIQUE (external_id),
	CONSTRAINT users_pkey PRIMARY KEY (id)
);
CREATE INDEX idx_users_external_id ON public.users USING btree (external_id);


-- public.workspaces definition

-- Drop table

-- DROP TABLE public.workspaces;

CREATE TABLE public.workspaces (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	"name" varchar(100) NOT NULL,
	default_currency_code varchar(3) DEFAULT 'BRL'::character varying NOT NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT workspaces_pkey PRIMARY KEY (id)
);


-- public.accounts definition

-- Drop table

-- DROP TABLE public.accounts;

CREATE TABLE public.accounts (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	workspace_id uuid NOT NULL,
	"name" varchar(100) NOT NULL,
	"type" public."account_type" NOT NULL,
	initial_balance numeric(15, 2) DEFAULT 0 NOT NULL,
	currency_code varchar(3) DEFAULT 'BRL'::character varying NOT NULL,
	is_active bool DEFAULT true NOT NULL,
	deleted_at timestamptz NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT accounts_pkey PRIMARY KEY (id),
	CONSTRAINT fk_currencies_accounts FOREIGN KEY (currency_code) REFERENCES public.currencies(code),
	CONSTRAINT fk_workspaces_accounts FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id)
);
CREATE UNIQUE INDEX uq_accounts_workspace_name ON public.accounts USING btree (workspace_id, name);

-- Table Triggers

create trigger accounts_notify after
insert
    or
delete
    or
update
    on
    public.accounts for each row execute function notify_workspace_event();


-- public.api_keys definition

-- Drop table

-- DROP TABLE public.api_keys;

CREATE TABLE public.api_keys (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	user_id uuid NOT NULL,
	workspace_id uuid NOT NULL,
	"name" varchar(100) NOT NULL,
	key_hash varchar(255) NOT NULL,
	key_prefix varchar(20) NOT NULL,
	scopes _text DEFAULT '{}'::text[] NULL,
	last_used_at timestamptz NULL,
	expires_at timestamptz NULL,
	revoked_at timestamptz NULL,
	created_at timestamptz NULL,
	updated_at timestamptz NULL,
	CONSTRAINT api_keys_pkey PRIMARY KEY (id),
	CONSTRAINT fk_api_keys_user FOREIGN KEY (user_id) REFERENCES public.users(id),
	CONSTRAINT fk_api_keys_workspace FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id)
);
CREATE INDEX idx_api_keys_key_prefix ON public.api_keys USING btree (key_prefix);
CREATE INDEX idx_api_keys_user_id ON public.api_keys USING btree (user_id);
CREATE INDEX idx_api_keys_workspace_id ON public.api_keys USING btree (workspace_id);


-- public.cards definition

-- Drop table

-- DROP TABLE public.cards;

CREATE TABLE public.cards (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	"name" varchar(100) NOT NULL,
	credit_limit numeric(15, 2) NOT NULL,
	workspace_id uuid NOT NULL,
	closing_date int8 NOT NULL,
	due_date int8 NOT NULL,
	is_active bool DEFAULT true NOT NULL,
	deleted_at timestamptz NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT cards_pkey PRIMARY KEY (id),
	CONSTRAINT chk_cards_closing_date CHECK (((closing_date >= 1) AND (closing_date <= 31))),
	CONSTRAINT chk_cards_credit_limit CHECK ((credit_limit >= (0)::numeric)),
	CONSTRAINT chk_cards_due_date CHECK ((((due_date >= 1) AND (due_date <= 31)) AND (due_date <> closing_date))),
	CONSTRAINT fk_workspaces_cards FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id)
);
CREATE UNIQUE INDEX uq_cards_workspace_name ON public.cards USING btree (name, workspace_id);

-- Table Triggers

create trigger cards_notify after
insert
    or
delete
    or
update
    on
    public.cards for each row execute function notify_workspace_event();


-- public.categories definition

-- Drop table

-- DROP TABLE public.categories;

CREATE TABLE public.categories (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	workspace_id uuid NOT NULL,
	"name" varchar(100) NOT NULL,
	"type" public."category_type" NOT NULL,
	color varchar(7) NOT NULL,
	icon varchar(100) NOT NULL,
	is_active bool DEFAULT true NOT NULL,
	vector public.vector NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT categories_pkey PRIMARY KEY (id),
	CONSTRAINT chk_categories_color CHECK (((color)::text ~ '^#[0-9A-Fa-f]{6}$'::text)),
	CONSTRAINT fk_workspaces_categories FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id)
);
CREATE UNIQUE INDEX uq_categories_workspace_name_type ON public.categories USING btree (workspace_id, name, type);

-- Table Triggers

create trigger categories_notify after
insert
    or
delete
    or
update
    on
    public.categories for each row execute function notify_workspace_event();


-- public.exchange_rates definition

-- Drop table

-- DROP TABLE public.exchange_rates;

CREATE TABLE public.exchange_rates (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	from_currency varchar(3) NOT NULL,
	to_currency varchar(3) NOT NULL,
	rate numeric(15, 8) NOT NULL,
	rate_date date NOT NULL,
	"source" varchar(50) NULL,
	created_at timestamptz DEFAULT now() NULL,
	CONSTRAINT chk_exchange_rates_from_currency CHECK (((from_currency)::text <> (to_currency)::text)),
	CONSTRAINT chk_exchange_rates_rate CHECK ((rate > (0)::numeric)),
	CONSTRAINT exchange_rates_pkey PRIMARY KEY (id),
	CONSTRAINT fk_exchange_rates_from_currency_rel FOREIGN KEY (from_currency) REFERENCES public.currencies(code),
	CONSTRAINT fk_exchange_rates_to_currency_rel FOREIGN KEY (to_currency) REFERENCES public.currencies(code)
);
CREATE UNIQUE INDEX uq_exchange_rates_date_pair ON public.exchange_rates USING btree (from_currency, to_currency, rate_date);


-- public.import_sessions definition

-- Drop table

-- DROP TABLE public.import_sessions;

CREATE TABLE public.import_sessions (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	workspace_id uuid NOT NULL,
	user_id uuid NOT NULL,
	description varchar(255) NULL,
	account_id uuid NULL,
	card_id uuid NULL,
	billing_month varchar(7) NULL,
	target_value numeric(15, 2) NULL,
	created_at timestamptz DEFAULT now() NULL,
	CONSTRAINT import_sessions_pkey PRIMARY KEY (id),
	CONSTRAINT fk_accounts_import_sessions FOREIGN KEY (account_id) REFERENCES public.accounts(id),
	CONSTRAINT fk_cards_import_sessions FOREIGN KEY (card_id) REFERENCES public.cards(id),
	CONSTRAINT fk_users_import_sessions FOREIGN KEY (user_id) REFERENCES public.users(id),
	CONSTRAINT fk_workspaces_import_sessions FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id)
);

-- Table Triggers

create trigger import_sessions_notify after
insert
    or
delete
    or
update
    on
    public.import_sessions for each row execute function notify_workspace_event();


-- public.investments definition

-- Drop table

-- DROP TABLE public.investments;

CREATE TABLE public.investments (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	asset_name varchar(100) NOT NULL,
	"type" public."investment_type" NOT NULL,
	account_id uuid NOT NULL,
	"index_type" public."index_type" NULL,
	index_value varchar(50) NULL,
	liquidity public."liquidity_type" NOT NULL,
	is_rescued bool DEFAULT false NOT NULL,
	validity date NULL,
	current_value numeric(15, 2) NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT investments_pkey PRIMARY KEY (id),
	CONSTRAINT fk_accounts_investments FOREIGN KEY (account_id) REFERENCES public.accounts(id)
);

-- Table Triggers

create trigger investments_notify after
insert
    or
delete
    or
update
    on
    public.investments for each row execute function notify_workspace_event();


-- public.invoices definition

-- Drop table

-- DROP TABLE public.invoices;

CREATE TABLE public.invoices (
	card_id uuid NOT NULL,
	billing_month varchar(7) NOT NULL,
	status public."invoice_status" DEFAULT 'OPEN'::invoice_status NOT NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT chk_invoices_billing_month CHECK ((((billing_month)::text ~ '^[0-9]{4}-[0-9]{2}$'::text) AND ((("substring"((billing_month)::text, 6, 2))::integer >= 1) AND (("substring"((billing_month)::text, 6, 2))::integer <= 12)))),
	CONSTRAINT invoices_pkey PRIMARY KEY (card_id, billing_month),
	CONSTRAINT fk_cards_invoices FOREIGN KEY (card_id) REFERENCES public.cards(id)
);

-- Table Triggers

create trigger invoices_notify after
insert
    or
delete
    or
update
    on
    public.invoices for each row execute function notify_workspace_event();


-- public.recurring_transfers definition

-- Drop table

-- DROP TABLE public.recurring_transfers;

CREATE TABLE public.recurring_transfers (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	description text NULL,
	amount numeric(15, 2) NOT NULL,
	source_account_id uuid NOT NULL,
	destination_account_id uuid NOT NULL,
	frequency public."transaction_frequency" NOT NULL,
	start_date date NOT NULL,
	end_date date NULL,
	is_active bool DEFAULT true NOT NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT chk_recurring_transfers_amount CHECK ((amount > (0)::numeric)),
	CONSTRAINT chk_recurring_transfers_destination_account_id CHECK ((source_account_id <> destination_account_id)),
	CONSTRAINT chk_recurring_transfers_end_date CHECK (((end_date IS NULL) OR (end_date >= start_date))),
	CONSTRAINT chk_recurring_transfers_source_account_id CHECK ((source_account_id <> destination_account_id)),
	CONSTRAINT chk_recurring_transfers_start_date CHECK (((end_date IS NULL) OR (end_date >= start_date))),
	CONSTRAINT recurring_transfers_pkey PRIMARY KEY (id),
	CONSTRAINT fk_accounts_recurring_transfers_as_destination FOREIGN KEY (destination_account_id) REFERENCES public.accounts(id),
	CONSTRAINT fk_accounts_recurring_transfers_as_source FOREIGN KEY (source_account_id) REFERENCES public.accounts(id)
);

-- Table Triggers

create trigger recurring_transfers_notify after
insert
    or
delete
    or
update
    on
    public.recurring_transfers for each row execute function notify_recurring_event();


-- public.staged_transactions definition

-- Drop table

-- DROP TABLE public.staged_transactions;

CREATE TABLE public.staged_transactions (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	session_id uuid NOT NULL,
	"type" public."staged_transaction_type" NOT NULL,
	status public."staged_transaction_status" DEFAULT 'PENDING'::staged_transaction_status NOT NULL,
	transaction_date date NOT NULL,
	amount numeric(15, 2) NOT NULL,
	"data" jsonb NULL,
	line_number int4 NULL,
	processing_enrichment bool DEFAULT false NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	description text NOT NULL,
	CONSTRAINT staged_transactions_pkey PRIMARY KEY (id),
	CONSTRAINT fk_import_sessions_staged_transactions FOREIGN KEY (session_id) REFERENCES public.import_sessions(id)
);

-- Table Triggers

create trigger staged_transaction_status_trigger after
update
    of status on
    public.staged_transactions for each row execute function notify_staged_transaction_update();
create trigger staged_transaction_validate_trigger before
insert
    or
update
    of data,
    type,
    transaction_date,
    processing_enrichment on
    public.staged_transactions for each row execute function calculate_staged_transaction_status();
create trigger staged_transactions_notify after
update
    on
    public.staged_transactions for each row execute function notify_staged_tx_event();


-- public.sub_categories definition

-- Drop table

-- DROP TABLE public.sub_categories;

CREATE TABLE public.sub_categories (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	workspace_id uuid NOT NULL,
	"name" varchar(100) NOT NULL,
	category_id uuid NOT NULL,
	is_active bool DEFAULT true NOT NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	vector public.vector NULL,
	CONSTRAINT sub_categories_pkey PRIMARY KEY (id),
	CONSTRAINT fk_categories_sub_categories FOREIGN KEY (category_id) REFERENCES public.categories(id),
	CONSTRAINT fk_workspaces_sub_categories FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id)
);

-- Table Triggers

create trigger sub_categories_notify after
insert
    or
delete
    or
update
    on
    public.sub_categories for each row execute function notify_workspace_event();


-- public.tags definition

-- Drop table

-- DROP TABLE public.tags;

CREATE TABLE public.tags (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	workspace_id uuid NOT NULL,
	"name" varchar(100) NOT NULL,
	color varchar(7) NULL,
	is_active bool DEFAULT true NOT NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT tags_pkey PRIMARY KEY (id),
	CONSTRAINT fk_workspaces_tags FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id)
);

-- Table Triggers

create trigger tags_notify after
insert
    or
delete
    or
update
    on
    public.tags for each row execute function notify_workspace_event();


-- public.transfers definition

-- Drop table

-- DROP TABLE public.transfers;

CREATE TABLE public.transfers (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	recurring_transfer_id uuid NULL,
	transaction_date date NOT NULL,
	amount numeric(15, 2) NOT NULL,
	source_account_id uuid NOT NULL,
	destination_account_id uuid NOT NULL,
	"transaction_status" public."transaction_status" DEFAULT 'VALIDATING'::transaction_status NOT NULL,
	description text NULL,
	deleted_at timestamptz NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT chk_transfers_amount CHECK ((amount > (0)::numeric)),
	CONSTRAINT chk_transfers_destination_account_id CHECK ((source_account_id <> destination_account_id)),
	CONSTRAINT chk_transfers_source_account_id CHECK ((source_account_id <> destination_account_id)),
	CONSTRAINT transfers_pkey PRIMARY KEY (id),
	CONSTRAINT fk_accounts_transfers_as_destination FOREIGN KEY (destination_account_id) REFERENCES public.accounts(id),
	CONSTRAINT fk_accounts_transfers_as_source FOREIGN KEY (source_account_id) REFERENCES public.accounts(id),
	CONSTRAINT fk_recurring_transfers_transfers FOREIGN KEY (recurring_transfer_id) REFERENCES public.recurring_transfers(id)
);

-- Table Triggers

create trigger transfers_notify after
insert
    or
delete
    or
update
    on
    public.transfers for each row execute function notify_transaction_event();


-- public.workspace_invites definition

-- Drop table

-- DROP TABLE public.workspace_invites;

CREATE TABLE public.workspace_invites (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	workspace_id uuid NOT NULL,
	email varchar(255) NOT NULL,
	"token" varchar(255) NOT NULL,
	expires_at timestamptz NOT NULL,
	created_at timestamptz DEFAULT now() NULL,
	CONSTRAINT uni_workspace_invites_token UNIQUE (token),
	CONSTRAINT workspace_invites_pkey PRIMARY KEY (id),
	CONSTRAINT fk_workspaces_invites FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id)
);
CREATE INDEX idx_workspace_invites_token ON public.workspace_invites USING btree (token);


-- public.workspace_members definition

-- Drop table

-- DROP TABLE public.workspace_members;

CREATE TABLE public.workspace_members (
	workspace_id uuid NOT NULL,
	user_id uuid NOT NULL,
	"role" varchar(50) DEFAULT 'member'::character varying NOT NULL,
	created_at timestamptz DEFAULT now() NULL,
	CONSTRAINT workspace_members_pkey PRIMARY KEY (workspace_id, user_id),
	CONSTRAINT fk_users_workspaces FOREIGN KEY (user_id) REFERENCES public.users(id),
	CONSTRAINT fk_workspaces_members FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id)
);


-- public.card_chargebacks definition

-- Drop table

-- DROP TABLE public.card_chargebacks;

CREATE TABLE public.card_chargebacks (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	transaction_date date NOT NULL,
	description text NOT NULL,
	amount numeric(15, 2) NOT NULL,
	card_id uuid NOT NULL,
	billing_month varchar(7) NOT NULL,
	"transaction_status" public."transaction_status" DEFAULT 'VALIDATING'::transaction_status NOT NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT card_chargebacks_pkey PRIMARY KEY (id),
	CONSTRAINT chk_card_chargebacks_amount CHECK ((amount > (0)::numeric)),
	CONSTRAINT chk_card_chargebacks_billing_month CHECK (((billing_month)::text ~ '^[0-9]{4}-[0-9]{2}$'::text)),
	CONSTRAINT fk_invoices_card_chargebacks FOREIGN KEY (card_id,billing_month) REFERENCES public.invoices(card_id,billing_month)
);

-- Table Triggers

create trigger card_chargebacks_notify after
insert
    or
delete
    or
update
    on
    public.card_chargebacks for each row execute function notify_transaction_event();


-- public.card_payments definition

-- Drop table

-- DROP TABLE public.card_payments;

CREATE TABLE public.card_payments (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	transaction_date date NOT NULL,
	amount numeric(15, 2) NOT NULL,
	account_id uuid NOT NULL,
	card_id uuid NOT NULL,
	billing_month varchar(7) NOT NULL,
	is_final_payment bool DEFAULT false NOT NULL,
	"transaction_status" public."transaction_status" DEFAULT 'VALIDATING'::transaction_status NOT NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT card_payments_pkey PRIMARY KEY (id),
	CONSTRAINT chk_card_payments_amount CHECK ((amount > (0)::numeric)),
	CONSTRAINT chk_card_payments_billing_month CHECK (((billing_month)::text ~ '^[0-9]{4}-[0-9]{2}$'::text)),
	CONSTRAINT fk_accounts_card_payments FOREIGN KEY (account_id) REFERENCES public.accounts(id),
	CONSTRAINT fk_invoices_card_payments FOREIGN KEY (card_id,billing_month) REFERENCES public.invoices(card_id,billing_month)
);

-- Table Triggers

create trigger card_payments_notify after
insert
    or
delete
    or
update
    on
    public.card_payments for each row execute function notify_transaction_event();


-- public.investment_deposits definition

-- Drop table

-- DROP TABLE public.investment_deposits;

CREATE TABLE public.investment_deposits (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	transaction_date date NOT NULL,
	description text NULL,
	amount numeric(15, 2) NOT NULL,
	recurring_transaction_id uuid NULL,
	investment_id uuid NOT NULL,
	account_id uuid NOT NULL,
	"transaction_status" public."transaction_status" DEFAULT 'VALIDATING'::transaction_status NOT NULL,
	deleted_at timestamptz NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT investment_deposits_pkey PRIMARY KEY (id),
	CONSTRAINT fk_accounts_investment_deposits FOREIGN KEY (account_id) REFERENCES public.accounts(id),
	CONSTRAINT fk_investments_investment_deposits FOREIGN KEY (investment_id) REFERENCES public.investments(id)
);

-- Table Triggers

create trigger investment_deposits_notify after
insert
    or
delete
    or
update
    on
    public.investment_deposits for each row execute function notify_transaction_event();


-- public.investment_withdrawals definition

-- Drop table

-- DROP TABLE public.investment_withdrawals;

CREATE TABLE public.investment_withdrawals (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	transaction_date date NOT NULL,
	description text NULL,
	amount numeric(15, 2) NOT NULL,
	recurring_transaction_id uuid NULL,
	investment_id uuid NOT NULL,
	account_id uuid NOT NULL,
	"transaction_status" public."transaction_status" DEFAULT 'VALIDATING'::transaction_status NOT NULL,
	deleted_at timestamptz NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT investment_withdrawals_pkey PRIMARY KEY (id),
	CONSTRAINT fk_accounts_investment_withdrawals FOREIGN KEY (account_id) REFERENCES public.accounts(id),
	CONSTRAINT fk_investments_investment_withdrawals FOREIGN KEY (investment_id) REFERENCES public.investments(id)
);

-- Table Triggers

create trigger investment_withdrawals_notify after
insert
    or
delete
    or
update
    on
    public.investment_withdrawals for each row execute function notify_transaction_event();


-- public.investments_tags definition

-- Drop table

-- DROP TABLE public.investments_tags;

CREATE TABLE public.investments_tags (
	investment_id uuid NOT NULL,
	tag_id uuid NOT NULL,
	CONSTRAINT investments_tags_pkey PRIMARY KEY (investment_id, tag_id),
	CONSTRAINT fk_investments_tags FOREIGN KEY (investment_id) REFERENCES public.investments(id),
	CONSTRAINT fk_investments_tags_tag FOREIGN KEY (tag_id) REFERENCES public.tags(id)
);


-- public.recurring_card_transactions definition

-- Drop table

-- DROP TABLE public.recurring_card_transactions;

CREATE TABLE public.recurring_card_transactions (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	description varchar NOT NULL,
	amount numeric(15, 2) NOT NULL,
	card_id uuid NOT NULL,
	category_id uuid NOT NULL,
	sub_category_id uuid NULL,
	frequency public."transaction_frequency" NULL,
	start_date date NOT NULL,
	end_date date NULL,
	is_active bool DEFAULT true NOT NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT chk_recurring_card_transactions_amount CHECK ((amount > (0)::numeric)),
	CONSTRAINT chk_recurring_card_transactions_end_date CHECK (((end_date IS NULL) OR (end_date >= start_date))),
	CONSTRAINT chk_recurring_card_transactions_start_date CHECK (((end_date IS NULL) OR (end_date >= start_date))),
	CONSTRAINT recurring_card_transactions_pkey PRIMARY KEY (id),
	CONSTRAINT fk_cards_recurring_card_transactions FOREIGN KEY (card_id) REFERENCES public.cards(id),
	CONSTRAINT fk_categories_recurring_card_transactions FOREIGN KEY (category_id) REFERENCES public.categories(id),
	CONSTRAINT fk_sub_categories_recurring_card_transactions FOREIGN KEY (sub_category_id) REFERENCES public.sub_categories(id)
);

-- Table Triggers

create trigger recurring_card_transactions_notify after
insert
    or
delete
    or
update
    on
    public.recurring_card_transactions for each row execute function notify_recurring_event();


-- public.recurring_card_transactions_tags definition

-- Drop table

-- DROP TABLE public.recurring_card_transactions_tags;

CREATE TABLE public.recurring_card_transactions_tags (
	recurring_card_transaction_id uuid NOT NULL,
	tag_id uuid NOT NULL,
	CONSTRAINT recurring_card_transactions_tags_pkey PRIMARY KEY (recurring_card_transaction_id, tag_id),
	CONSTRAINT fk_recurring_card_transactions_tags FOREIGN KEY (recurring_card_transaction_id) REFERENCES public.recurring_card_transactions(id),
	CONSTRAINT fk_recurring_card_transactions_tags_tag FOREIGN KEY (tag_id) REFERENCES public.tags(id)
);


-- public.recurring_expenses definition

-- Drop table

-- DROP TABLE public.recurring_expenses;

CREATE TABLE public.recurring_expenses (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	description varchar(200) NOT NULL,
	amount numeric(15, 2) NOT NULL,
	account_id uuid NOT NULL,
	category_id uuid NOT NULL,
	sub_category_id uuid NULL,
	frequency public."transaction_frequency" NOT NULL,
	start_date date NOT NULL,
	end_date date NULL,
	is_active bool DEFAULT true NOT NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT chk_recurring_expenses_amount CHECK ((amount > (0)::numeric)),
	CONSTRAINT chk_recurring_expenses_end_date CHECK (((end_date IS NULL) OR (end_date >= start_date))),
	CONSTRAINT chk_recurring_expenses_start_date CHECK (((end_date IS NULL) OR (end_date >= start_date))),
	CONSTRAINT recurring_expenses_pkey PRIMARY KEY (id),
	CONSTRAINT fk_accounts_recurring_expenses FOREIGN KEY (account_id) REFERENCES public.accounts(id),
	CONSTRAINT fk_categories_recurring_expenses FOREIGN KEY (category_id) REFERENCES public.categories(id),
	CONSTRAINT fk_sub_categories_recurring_expenses FOREIGN KEY (sub_category_id) REFERENCES public.sub_categories(id)
);

-- Table Triggers

create trigger recurring_expenses_notify after
insert
    or
delete
    or
update
    on
    public.recurring_expenses for each row execute function notify_recurring_event();


-- public.recurring_expenses_tags definition

-- Drop table

-- DROP TABLE public.recurring_expenses_tags;

CREATE TABLE public.recurring_expenses_tags (
	recurring_expense_id uuid NOT NULL,
	tag_id uuid NOT NULL,
	CONSTRAINT recurring_expenses_tags_pkey PRIMARY KEY (recurring_expense_id, tag_id),
	CONSTRAINT fk_recurring_expenses_tags FOREIGN KEY (recurring_expense_id) REFERENCES public.recurring_expenses(id),
	CONSTRAINT fk_recurring_expenses_tags_tag FOREIGN KEY (tag_id) REFERENCES public.tags(id)
);


-- public.recurring_incomes definition

-- Drop table

-- DROP TABLE public.recurring_incomes;

CREATE TABLE public.recurring_incomes (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	description varchar(200) NOT NULL,
	amount numeric(15, 2) NOT NULL,
	account_id uuid NOT NULL,
	category_id uuid NOT NULL,
	sub_category_id uuid NULL,
	frequency public."transaction_frequency" NOT NULL,
	start_date date NOT NULL,
	end_date date NULL,
	is_active bool DEFAULT true NOT NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT chk_recurring_incomes_amount CHECK ((amount > (0)::numeric)),
	CONSTRAINT chk_recurring_incomes_end_date CHECK (((end_date IS NULL) OR (end_date >= start_date))),
	CONSTRAINT chk_recurring_incomes_start_date CHECK (((end_date IS NULL) OR (end_date >= start_date))),
	CONSTRAINT recurring_incomes_pkey PRIMARY KEY (id),
	CONSTRAINT fk_accounts_recurring_incomes FOREIGN KEY (account_id) REFERENCES public.accounts(id),
	CONSTRAINT fk_categories_recurring_incomes FOREIGN KEY (category_id) REFERENCES public.categories(id),
	CONSTRAINT fk_sub_categories_recurring_incomes FOREIGN KEY (sub_category_id) REFERENCES public.sub_categories(id)
);

-- Table Triggers

create trigger recurring_incomes_notify after
insert
    or
delete
    or
update
    on
    public.recurring_incomes for each row execute function notify_recurring_event();


-- public.recurring_incomes_tags definition

-- Drop table

-- DROP TABLE public.recurring_incomes_tags;

CREATE TABLE public.recurring_incomes_tags (
	recurring_income_id uuid NOT NULL,
	tag_id uuid NOT NULL,
	CONSTRAINT recurring_incomes_tags_pkey PRIMARY KEY (recurring_income_id, tag_id),
	CONSTRAINT fk_recurring_incomes_tags FOREIGN KEY (recurring_income_id) REFERENCES public.recurring_incomes(id),
	CONSTRAINT fk_recurring_incomes_tags_tag FOREIGN KEY (tag_id) REFERENCES public.tags(id)
);


-- public.card_expenses definition

-- Drop table

-- DROP TABLE public.card_expenses;

CREATE TABLE public.card_expenses (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	transaction_date date NOT NULL,
	description text NOT NULL,
	amount numeric(15, 2) NOT NULL,
	sub_category_id uuid NULL,
	category_id uuid NOT NULL,
	card_id uuid NOT NULL,
	billing_month varchar(7) NOT NULL,
	recurring_card_transaction_id uuid NULL,
	"transaction_status" public."transaction_status" DEFAULT 'VALIDATING'::transaction_status NOT NULL,
	deleted_at timestamptz NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT card_expenses_pkey PRIMARY KEY (id),
	CONSTRAINT chk_card_expenses_amount CHECK ((amount > (0)::numeric)),
	CONSTRAINT chk_card_expenses_billing_month CHECK (((billing_month)::text ~ '^[0-9]{4}-[0-9]{2}$'::text)),
	CONSTRAINT fk_categories_card_expenses FOREIGN KEY (category_id) REFERENCES public.categories(id),
	CONSTRAINT fk_invoices_card_expenses FOREIGN KEY (card_id,billing_month) REFERENCES public.invoices(card_id,billing_month),
	CONSTRAINT fk_recurring_card_transactions_card_expenses FOREIGN KEY (recurring_card_transaction_id) REFERENCES public.recurring_card_transactions(id),
	CONSTRAINT fk_sub_categories_card_expenses FOREIGN KEY (sub_category_id) REFERENCES public.sub_categories(id)
);

-- Table Triggers

create trigger card_expenses_notify after
insert
    or
delete
    or
update
    on
    public.card_expenses for each row execute function notify_transaction_event();


-- public.card_expenses_tags definition

-- Drop table

-- DROP TABLE public.card_expenses_tags;

CREATE TABLE public.card_expenses_tags (
	card_expense_id uuid NOT NULL,
	tag_id uuid NOT NULL,
	CONSTRAINT card_expenses_tags_pkey PRIMARY KEY (card_expense_id, tag_id),
	CONSTRAINT fk_card_expenses_tags FOREIGN KEY (card_expense_id) REFERENCES public.card_expenses(id),
	CONSTRAINT fk_card_expenses_tags_tag FOREIGN KEY (tag_id) REFERENCES public.tags(id)
);


-- public.expenses definition

-- Drop table

-- DROP TABLE public.expenses;

CREATE TABLE public.expenses (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	transaction_date date NOT NULL,
	description text NOT NULL,
	amount numeric(15, 2) NOT NULL,
	account_id uuid NOT NULL,
	category_id uuid NOT NULL,
	sub_category_id uuid NULL,
	recurring_expense_id uuid NULL,
	"transaction_status" public."transaction_status" DEFAULT 'VALIDATING'::transaction_status NOT NULL,
	deleted_at timestamptz NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT chk_expenses_amount CHECK ((amount > (0)::numeric)),
	CONSTRAINT expenses_pkey PRIMARY KEY (id),
	CONSTRAINT fk_accounts_expenses FOREIGN KEY (account_id) REFERENCES public.accounts(id),
	CONSTRAINT fk_categories_expenses FOREIGN KEY (category_id) REFERENCES public.categories(id),
	CONSTRAINT fk_recurring_expenses_expenses FOREIGN KEY (recurring_expense_id) REFERENCES public.recurring_expenses(id),
	CONSTRAINT fk_sub_categories_expenses FOREIGN KEY (sub_category_id) REFERENCES public.sub_categories(id)
);

-- Table Triggers

create trigger expenses_notify after
insert
    or
delete
    or
update
    on
    public.expenses for each row execute function notify_transaction_event();


-- public.expenses_tags definition

-- Drop table

-- DROP TABLE public.expenses_tags;

CREATE TABLE public.expenses_tags (
	expense_id uuid NOT NULL,
	tag_id uuid NOT NULL,
	CONSTRAINT expenses_tags_pkey PRIMARY KEY (expense_id, tag_id),
	CONSTRAINT fk_expenses_tags FOREIGN KEY (expense_id) REFERENCES public.expenses(id),
	CONSTRAINT fk_tags_expenses_tags FOREIGN KEY (tag_id) REFERENCES public.tags(id)
);


-- public.incomes definition

-- Drop table

-- DROP TABLE public.incomes;

CREATE TABLE public.incomes (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	transaction_date date NOT NULL,
	description text NOT NULL,
	amount numeric(15, 2) NOT NULL,
	account_id uuid NOT NULL,
	category_id uuid NOT NULL,
	sub_category_id uuid NULL,
	recurring_income_id uuid NULL,
	"transaction_status" public."transaction_status" DEFAULT 'VALIDATING'::transaction_status NOT NULL,
	deleted_at timestamptz NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT chk_incomes_amount CHECK ((amount > (0)::numeric)),
	CONSTRAINT incomes_pkey PRIMARY KEY (id),
	CONSTRAINT fk_accounts_incomes FOREIGN KEY (account_id) REFERENCES public.accounts(id),
	CONSTRAINT fk_categories_incomes FOREIGN KEY (category_id) REFERENCES public.categories(id),
	CONSTRAINT fk_recurring_incomes_incomes FOREIGN KEY (recurring_income_id) REFERENCES public.recurring_incomes(id),
	CONSTRAINT fk_sub_categories_incomes FOREIGN KEY (sub_category_id) REFERENCES public.sub_categories(id)
);

-- Table Triggers

create trigger incomes_notify after
insert
    or
delete
    or
update
    on
    public.incomes for each row execute function notify_transaction_event();


-- public.incomes_tags definition

-- Drop table

-- DROP TABLE public.incomes_tags;

CREATE TABLE public.incomes_tags (
	income_id uuid NOT NULL,
	tag_id uuid NOT NULL,
	CONSTRAINT incomes_tags_pkey PRIMARY KEY (income_id, tag_id),
	CONSTRAINT fk_incomes_tags FOREIGN KEY (income_id) REFERENCES public.incomes(id),
	CONSTRAINT fk_tags_incomes_tags FOREIGN KEY (tag_id) REFERENCES public.tags(id)
);

