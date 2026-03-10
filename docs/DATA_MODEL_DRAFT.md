# Data Model Draft – NorthRiver Analytics (B2B SaaS)

## dim_customer
Grain: one row per customer.

Columns:
- customer_id (PK, integer)
- customer_name (text)
- industry (text) – e.g., Healthcare, Finance, Retail
- segment (text) – e.g., Small, Mid, Enterprise
- region (text) – e.g., North America, Europe
- size_band (text) – e.g., 1-50 employees, 51-200, 201-1000, 1000+
- signup_date_id (int, FK to dim_date)
- is_active (boolean or tinyint)

## dim_product
Grain: one row per product/plan.

Columns:
- product_id (PK, integer)
- product_name (text)
- plan_type (text) – e.g., Basic, Pro, Enterprise
- module (text) – e.g., Core, Analytics, Add-on
- base_monthly_price (numeric)

## dim_date
Grain: one row per calendar date.

Columns:
- date_id (PK, integer)
- date (date)
- day (int)
- month (int)
- month_name (text)
- quarter (int)
- year (int)

## fact_invoices
Grain: one row per invoice issued to a customer.

Columns:
- invoice_id (PK, integer)
- customer_id (FK to dim_customer)
- product_id (FK to dim_product)
- invoice_date_id (FK to dim_date)
- due_date_id (FK to dim_date)
- paid_date_id (FK to dim_date, nullable)
- invoice_amount (numeric)
- cost_amount (numeric)
- tax_amount (numeric)
- currency (text)
- status (text) – e.g., Paid, Unpaid, Overdue, Written-off

## fact_subscriptions
Grain: one row per active subscription period (e.g., monthly snapshot).

Columns:
- subscription_id (PK, integer)
- customer_id (FK to dim_customer)
- product_id (FK to dim_product)
- start_date_id (FK to dim_date)
- end_date_id (FK to dim_date)
- billing_frequency (text) – e.g., Monthly, Annual
- mrr (numeric) – monthly recurring revenue
- arr (numeric) – annual recurring revenue
- is_active (boolean or tinyint)
