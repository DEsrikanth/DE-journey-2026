-- =============================================================
-- Insurance database schema (general insurance: policies and claims)
-- Database : insurance_db (PostgreSQL 17)
-- Run      : psql -U postgres -d insurance_db -f 01_create_tables.sql
-- Order    : parent tables first (agents, customers), then policies,
--            then claims, because a FOREIGN KEY can only point to a
--            table that already exists.
-- Data     : synthetic only (Python Faker). Never real company data.
-- =============================================================

-- 1. Agents: who sells policies
CREATE TABLE agents (
    agent_id     VARCHAR(10) PRIMARY KEY,
    agent_name   VARCHAR(60) NOT NULL,
    branch       VARCHAR(40) NOT NULL,
    join_date    DATE
);

-- 2. Customers: who buys policies
CREATE TABLE customers (
    customer_id    VARCHAR(10) PRIMARY KEY,
    customer_name  VARCHAR(60) NOT NULL,
    gender         CHAR(1) CHECK (gender IN ('M', 'F', 'O')),
    date_of_birth  DATE,
    city           VARCHAR(40),
    state          VARCHAR(40)
);

-- 3. Policies: what was sold (one customer can hold many policies)
CREATE TABLE policies (
    policy_no     VARCHAR(12) PRIMARY KEY,
    customer_id   VARCHAR(10) NOT NULL REFERENCES customers (customer_id),
    agent_id      VARCHAR(10) REFERENCES agents (agent_id),
    product       VARCHAR(15) NOT NULL CHECK (product IN ('Motor', 'Health', 'Home', 'Travel')),
    sum_insured   NUMERIC(12, 2) CHECK (sum_insured > 0),
    premium       NUMERIC(10, 2) NOT NULL CHECK (premium > 0),
    start_date    DATE NOT NULL,
    end_date      DATE NOT NULL,
    status        VARCHAR(12) NOT NULL CHECK (status IN ('Active', 'Expired', 'Cancelled', 'Renewed')),
    CHECK (end_date > start_date)
);

-- 4. Claims: money customers ask back (one policy can have many claims)
CREATE TABLE claims (
    claim_id         VARCHAR(12) PRIMARY KEY,
    policy_no        VARCHAR(12) NOT NULL REFERENCES policies (policy_no),
    claim_date       DATE NOT NULL,
    cause            VARCHAR(40),
    claim_amount     NUMERIC(12, 2) NOT NULL CHECK (claim_amount > 0),
    approved_amount  NUMERIC(12, 2) CHECK (approved_amount >= 0),
    status           VARCHAR(12) NOT NULL CHECK (status IN ('Pending', 'Approved', 'Rejected', 'Settled')),
    settlement_date  DATE
);
