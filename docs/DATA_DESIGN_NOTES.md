# Data Design Notes – NorthRiver Analytics (B2B SaaS)

These notes describe how the synthetic data should look so it feels realistic and supports the case study.

---

## Customers (dim_customer)

Target volume:
- ~200–500 customers.

Patterns:
- Mix of industries: e.g., Healthcare, Finance, Retail, Tech, Manufacturing.
- Segments: Small, Mid, Enterprise (more Small than Enterprise).
- Regions: North America, Europe, APAC.
- Size bands aligned with segment (Enterprise customers mostly in larger size bands).
- Signup dates spread over the last 3–5 years.
- Most customers are active, some churned (is_active = 0).

---

## Products (dim_product)

Target volume:
- ~5–10 core products/plans.

Patterns:
- Plan types: Basic, Pro, Enterprise.
- Modules: Core, Analytics, Add-on.
- base_monthly_price higher for Pro/Enterprise than Basic.

---

## Subscriptions (fact_subscriptions)

Target volume:
- Each active customer should have 1–3 subscriptions.
- Total rows: ~1,000–2,000 subscription records.

Patterns:
- Mix of Monthly and Annual billing_frequency (more Monthly).
- MRR/ARR consistent with base_monthly_price and billing_frequency.
- start_date_id mostly after customer signup_date_id.
- Some subscriptions ended (end_date_id filled, is_active = 0).
- Others still active (end_date_id NULL, is_active = 1).

---

## Invoices (fact_invoices)

Target volume:
- Each active subscription generates invoices over time.
- Total rows: ~10,000–20,000 invoices.

Patterns:
- invoice_date_id aligned with subscription billing cycle (monthly for Monthly, annually for Annual).
- due_date_id a set number of days after invoice_date_id (e.g., 30 days).
- paid_date_id:
  - On-time for most invoices (within due date).
  - Late for some invoices (simulate 10–20% overdue).
  - NULL and status = Unpaid or Written-off for bad debt.
- invoice_amount:
  - Based on product price and billing_frequency.
- cost_amount:
  - A % of invoice_amount (e.g., 30–60%) to support margin calculations.
- tax_amount:
  - A small % of invoice_amount (e.g., 5–10%).
- status:
  - Paid, Unpaid, Overdue, Written-off, based on paid_date_id vs due_date_id.

---

## High-level goals

The synthetic data should:

- Show revenue growth/flattening over time.
- Have a few large customers that account for a big share of revenue (concentration risk).
- Include a noticeable but not extreme amount of late/overdue invoices.
- Allow calculation of:
  - Revenue, cost, and margin trends.
  - Customer concentration (top N customers % of total revenue).
  - Basic customer risk / health indicators based on payment behavior and subscription activity.
