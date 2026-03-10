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

