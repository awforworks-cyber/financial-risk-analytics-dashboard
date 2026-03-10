# Data Dictionary – NorthRiver Analytics (B2B SaaS)

This document explains the business meaning of each table and key column.

---

## Table: dim_date

**Grain:** One row per calendar date.

Used for:
- Grouping metrics by day, month, quarter, and year.
- Linking facts (invoices, subscriptions) to time.

Key columns:
- **date_id** – Surrogate key used in fact tables instead of the raw date.
- **date** – Actual calendar date (e.g., 2024-03-10).
- **day** – Day of month (1–31).
- **month** – Month number (1–12).
- **month_name** – Month name (e.g., March).
- **quarter** – Quarter number (1–4).
- **year** – Year number (e.g., 2024).

---

## Table: dim_customer

**Grain:** One row per customer (company).

Used for:
- Analyzing revenue, margin, and risk by customer attributes like industry, size, and region.

Key columns:
- **customer_id** – Surrogate key for each customer, used in fact tables.
- **customer_name** – Customer/company name.
- **industry** – Industry category (e.g., Healthcare, Finance).
- **segment** – Customer segment (e.g., Small, Mid, Enterprise).
- **region** – Geographic region (e.g., North America, Europe).
- **size_band** – Size bucket by employee count (e.g., 1–50, 51–200).
- **signup_date_id** – Links to dim_date so we know when the customer signed up.
- **is_active** – Indicates if the customer is currently active (1) or not (0).

---

## Table: dim_product

**Grain:** One row per product or subscription plan.

Used for:
- Analyzing performance by product, plan type, and module.

Key columns:
- **product_id** – Surrogate key for each product, used in fact tables.
- **product_name** – Name of the product/plan.
- **plan_type** – Plan tier (e.g., Basic, Pro, Enterprise).
- **module** – Module or category (e.g., Core, Analytics, Add-on).
- **base_monthly_price** – Standard monthly price for this product/plan.

---

## Table: fact_invoices

**Grain:** One row per invoice issued to a customer.

Used for:
- Tracking billed revenue, payment timing, and invoice status.
- Building cash flow and aging/collections analysis.

Key columns:
- **invoice_id** – Unique identifier for each invoice.
- **customer_id** – Links the invoice to a customer in dim_customer.
- **product_id** – Links the invoice to a product in dim_product.
- **invoice_date_id** – When the invoice was issued (links to dim_date).
- **due_date_id** – When payment is due (links to dim_date).
- **paid_date_id** – When payment was actually received (links to dim_date, can be null).
- **invoice_amount** – Total amount billed on the invoice.
- **cost_amount** – Estimated cost associated with this invoice (for margin).
- **tax_amount** – Tax portion of the invoice.
- **currency** – Currency code (e.g., USD).
- **status** – Current status (e.g., Paid, Unpaid, Overdue, Written-off).

---

## Table: fact_subscriptions

**Grain:** One row per subscription snapshot period (e.g., monthly).

Used for:
- Tracking recurring revenue (MRR/ARR) and subscription activity.
- Analyzing subscription mix by product, segment, and billing frequency.

Key columns:
- **subscription_id** – Unique identifier for a subscription instance.
- **customer_id** – Links the subscription to a customer in dim_customer.
- **product_id** – Links the subscription to a product in dim_product.
- **start_date_id** – When the subscription started (links to dim_date).
- **end_date_id** – When the subscription ended, if applicable (links to dim_date).
- **billing_frequency** – Billing cadence (e.g., Monthly, Annual).
- **mrr** – Monthly Recurring Revenue amount for this subscription.
- **arr** – Annual Recurring Revenue amount for this subscription.
- **is_active** – Indicates if the subscription is active in the snapshot period (1) or not (0).
