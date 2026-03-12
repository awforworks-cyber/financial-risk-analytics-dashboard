-- financial_kpis_monthly.sql
-- Calculates monthly revenue and gross margin from invoices

SELECT
    d.year,
    d.month,
    d.month_name,
    SUM(fi.invoice_amount) AS total_revenue,
    SUM(fi.cost_amount)    AS total_cost,
    SUM(fi.invoice_amount) - SUM(fi.cost_amount) AS gross_margin,
    CASE 
        WHEN SUM(fi.invoice_amount) = 0 THEN NULL
        ELSE (SUM(fi.invoice_amount) - SUM(fi.cost_amount)) / SUM(fi.invoice_amount)
    END AS gross_margin_pct
FROM dbo.fact_invoices fi
JOIN dbo.dim_date d
    ON fi.invoice_date_id = d.date_id
GROUP BY
    d.year,
    d.month,
    d.month_name
ORDER BY
    d.year,
    d.month;
