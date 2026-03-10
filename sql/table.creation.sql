-- table_creation.sql
-- Creates core dimension and fact tables for NorthRiver Analytics (B2B SaaS)

-- Drop tables if they already exist (for development/reset purposes)
IF OBJECT_ID('dbo.fact_subscriptions', 'U') IS NOT NULL DROP TABLE dbo.fact_subscriptions;
IF OBJECT_ID('dbo.fact_invoices', 'U') IS NOT NULL DROP TABLE dbo.fact_invoices;
IF OBJECT_ID('dbo.dim_product', 'U') IS NOT NULL DROP TABLE dbo.dim_product;
IF OBJECT_ID('dbo.dim_customer', 'U') IS NOT NULL DROP TABLE dbo.dim_customer;
IF OBJECT_ID('dbo.dim_date', 'U') IS NOT NULL DROP TABLE dbo.dim_date;
GO

-- Dimension: dim_date
CREATE TABLE dbo.dim_date (
    date_id     INT         NOT NULL PRIMARY KEY,
    [date]      DATE        NOT NULL,
    [day]       TINYINT     NOT NULL,
    [month]     TINYINT     NOT NULL,
    month_name  VARCHAR(15) NOT NULL,
    [quarter]   TINYINT     NOT NULL,
    [year]      SMALLINT    NOT NULL
);
GO

-- Dimension: dim_customer
CREATE TABLE dbo.dim_customer (
    customer_id     INT          NOT NULL PRIMARY KEY,
    customer_name   VARCHAR(100) NOT NULL,
    industry        VARCHAR(50)  NULL,
    segment         VARCHAR(50)  NULL,   -- Small, Mid, Enterprise
    region          VARCHAR(50)  NULL,   -- North America, Europe, etc.
    size_band       VARCHAR(50)  NULL,   -- 1-50, 51-200, etc.
    signup_date_id  INT          NULL,   -- FK to dim_date (we'll add constraints later)
    is_active       BIT          NOT NULL DEFAULT 1
);
GO

-- Dimension: dim_product
CREATE TABLE dbo.dim_product (
    product_id         INT           NOT NULL PRIMARY KEY,
    product_name       VARCHAR(100)  NOT NULL,
    plan_type          VARCHAR(50)   NOT NULL,  -- Basic, Pro, Enterprise
    module             VARCHAR(50)   NULL,      -- Core, Analytics, Add-on, etc.
    base_monthly_price DECIMAL(10,2) NOT NULL
);
GO

-- Fact: fact_invoices
-- Grain: one row per invoice issued to a customer
CREATE TABLE dbo.fact_invoices (
    invoice_id       INT           NOT NULL PRIMARY KEY,
    customer_id      INT           NOT NULL,   -- FK to dim_customer
    product_id       INT           NOT NULL,   -- FK to dim_product
    invoice_date_id  INT           NOT NULL,   -- FK to dim_date (invoice date)
    due_date_id      INT           NOT NULL,   -- FK to dim_date (due date)
    paid_date_id     INT           NULL,       -- FK to dim_date (actual payment date)
    invoice_amount   DECIMAL(12,2) NOT NULL,   -- total invoiced amount (before tax or incl tax per your choice)
    cost_amount      DECIMAL(12,2) NOT NULL,   -- allocated cost for this invoice
    tax_amount       DECIMAL(12,2) NOT NULL,   -- tax component
    currency         VARCHAR(10)   NOT NULL,   -- e.g., USD, EUR
    status           VARCHAR(20)   NOT NULL    -- e.g., Paid, Unpaid, Overdue, Written-off
);
GO
