-- Enable UUID extension for PostgreSQL
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Accounts Table
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    initial_balance NUMERIC(15, 2) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    user_id UUID NOT NULL REFERENCES users (id)
);

-- Categories Table
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    transaction_type_id UUID NOT NULL REFERENCES transaction_types (id)
);

-- Subcategories Table
CREATE TABLE subcategories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    category_id UUID NOT NULL REFERENCES categories (id)
);

-- Transaction Types Table
CREATE TABLE transaction_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL
);

-- Transaction Statuses Table
CREATE TABLE transaction_statuses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL
);

-- Transactions Table
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_date DATE NOT NULL,
    description TEXT,
    amount NUMERIC(15, 2) NOT NULL,
    account_id UUID NOT NULL REFERENCES accounts (id),
    category_id UUID NOT NULL REFERENCES categories (id),
    subcategory_id UUID REFERENCES subcategories (id),
    transaction_type_id UUID NOT NULL REFERENCES transaction_types (id),
    transaction_status_id UUID NOT NULL REFERENCES transaction_statuses (id),
    transfer_id UUID REFERENCES transactions (id),
    invoice_id UUID REFERENCES invoices (id),
    recurring_transaction_id UUID REFERENCES recurring_transactions (id),
    investment_id UUID REFERENCES investments (id)
);

-- Cards Table
CREATE TABLE cards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    credit_limit NUMERIC(15, 2) NOT NULL,
    account_id UUID NOT NULL REFERENCES accounts (id)
);

-- Invoices Table
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    card_id UUID NOT NULL REFERENCES cards (id),
    billing_month DATE NOT NULL,
    due_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    payment_transaction_id UUID REFERENCES transactions (id)
);

-- Transfers Table
CREATE TABLE transfers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_account_id UUID NOT NULL REFERENCES accounts (id),
    destination_account_id UUID NOT NULL REFERENCES accounts (id),
    amount NUMERIC(15, 2) NOT NULL,
    transfer_date DATE NOT NULL,
    description TEXT
);

-- Recurring Transactions Table
CREATE TABLE recurring_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    amount NUMERIC(15, 2) NOT NULL,
    frequency VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    transaction_type_id UUID NOT NULL REFERENCES transaction_types (id),
    category_id UUID NOT NULL REFERENCES categories (id),
    subcategory_id UUID REFERENCES subcategories (id)
);

-- Investments Table
CREATE TABLE investments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    asset_name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    account_id UUID NOT NULL REFERENCES accounts (id),
    index_type VARCHAR(50),
    application_date DATE NOT NULL,
    maturity_date DATE,
    invested_amount NUMERIC(15, 2) NOT NULL,
    current_value NUMERIC(15, 2)
);

-- Tags Table
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    color VARCHAR(20)
);

-- Transaction Tags Table
CREATE TABLE transaction_tags (
    transaction_id UUID NOT NULL REFERENCES transactions (id),
    tag_id UUID NOT NULL REFERENCES tags (id),
    PRIMARY KEY (transaction_id, tag_id)
);
