# NorthRiver Analytics – Interview Talking Points

This file is for interview prep. It summarizes how to talk about the NorthRiver Analytics project in a clear, business-focused way.

---

## 1. 30-second project pitch

NorthRiver Analytics is an end-to-end financial and customer risk analytics case study for a synthetic B2B SaaS company. I designed a warehouse-style data model, built monthly financial KPIs in SQL, and then used Python to forecast revenue and analyze customer-level revenue concentration and overdue payment risk. The goal was to replicate the kind of reporting and insight an Operations or Data Analyst would deliver to support planning, collections, and continuous improvement work.

---

## 2. What problem you were solving

- At a high level: “How is the business performing over time, and where are the biggest revenue and collections risks?”
- More specifically:
  - What does revenue growth look like month-over-month and year-over-year?
  - How concentrated is revenue in the top customers, and in which segments/industries/regions?
  - Among those top customers, who is consistently late on payments or building up large overdue balances?
  - Where should operations and finance teams focus if they want to stabilize cash flow and reduce risk?

---

## 3. Data model and tools used

- **Data model**
  - Star schema with dimensions for date, customer, and product, plus fact tables for invoices and subscriptions.
  - `dim_customer` captures segment, industry, region, and signup date, which makes it easy to slice revenue and risk by customer attributes.
  - `fact_invoices` captures invoice amounts, costs, taxes, dates, and status so you can build both revenue and collections/aging views.

- **Tools**
  - SQL Server: table creation, population scripts, and monthly financial KPIs.
  - Python (pandas, NumPy): revenue forecasting, model evaluation, revenue/risk driver analysis.
  - CSV outputs prepared for use in Power BI and Excel.

---

## 4. Revenue forecasting – how you explain it

- Built monthly financial KPIs in SQL and exported them to `monthly_financial_kpis.csv`.
- In the `revenue_forecast` notebook, created two simple, explainable models:
  - **Model V1 (baseline):** rolling 3-month average used as a flat forecast. Easy to explain: “next month looks like the average of the last three.”
  - **Model V2 (improved):** linear trend model using NumPy’s `polyfit`/`polyval` to fit a line through revenue over time and project it forward.
- Evaluated both models on a 6-month holdout period using:
  - Mean Absolute Error (MAE) – average dollar error per month.
  - Mean Absolute Percentage Error (MAPE) – average percentage error per month.
- What you learned:
  - The trend model captures the overall growth pattern better than the flat average during stable periods.
  - Both models overestimate after a sharp one-month revenue drop in March 2026, which shows the limitation of simple trend-based forecasting when the business experiences a sudden shock.
  - In an operations setting, you’d pair this with scenario analysis or segment-level models to handle structural changes.

---

## 5. Revenue and risk driver analysis – how you explain it

- **Step 1 – Understand the overall revenue trend**
  - Built a `period` column (year + month) and calculated year-over-year revenue changes.
  - Found that revenue is generally growing strongly year-over-year through mid-2024 to early 2026, with one major exception: a ~43% drop in March 2026 compared to March 2025.
  - Framing: “The business is on a strong upward trajectory overall, but March 2026 looks like a one-off event that deserves its own root-cause analysis.”

- **Step 2 – Top-10 customer concentration**
  - Used `customer_revenue_concentration_summary.csv` to quantify revenue concentration among the top 10 customers.
  - Key points:
    - The top 5 customers account for just over ~58% of revenue within the top-10 group.
    - Customer_19 alone contributes about 18.8% of top-10 revenue (175k+), and Customer_5 adds another ~12.5%.
    - All top-10 accounts are in the Small segment but diversified across Tech, Manufacturing, Finance, and Retail, and across North America, Europe, and APAC.
  - Framing: “Revenue is meaningfully concentrated in a small group of Small-segment customers, particularly in Tech and Finance, so any disruption among a handful of accounts has a large impact.”

- **Step 3 – Overdue/payment risk**
  - Used `customer_overdue_risk_summary.csv` to layer overdue metrics on top of the same set of customers.
  - Key points:
    - Overdue ratios (by invoice count and amount) are typically in the 8–12% range even for top customers.
    - Customer_19: ~9.8% of its billed revenue is overdue (~17k), making it both the biggest revenue driver and the largest contributor to overdue balances.
    - Customer_5: highest overdue ratios at roughly 12.2% of invoices and revenue, with ~14k overdue – about 1 in 8 invoices are late.
    - Customer_29: smaller revenue but overdue around 11.5%, so mid-tier accounts can also be structurally late payers.
  - Framing: “Some of our most important customers are also structurally late payers. That combination of high revenue and high overdue percentage marks them as high-impact targets for collections improvements.”

- **Step 4 – Combined insight**
  - Several customers (19, 5, 22, 27, 29) sit in the intersection of “high revenue share” and “high overdue percentage.”
  - These accounts drive both revenue and collections risk, so they are the first place operations and finance should focus when improving credit terms, payment reminders, or follow-up workflows.

---

## 6. How this maps to an Operations/Data Analyst role

When asked “Why is this project relevant to this role?” you can say:

- It shows that you can **collect, clean, and combine data** from different sources (SQL outputs, invoices, customer dimensions) and organize it into reusable datasets for analysis.
- It demonstrates **basic statistical and analytical methods**: rolling averages, linear trend models, YoY comparisons, and error metrics like MAE/MAPE.
- It mirrors the workflow of an Operations Data Analyst:
  - Start at KPI level → drill into drivers → identify risks → export tables that feed dashboards and decision-making.
- It includes **documentation and communication**:
  - Data design notes, a data dictionary, notebooks with clear narrative, a case study, and CSVs that are ready for Power BI or Excel.
- It naturally connects to **continuous improvement / DMAIC**:
  - Define: revenue and collections stability as the problem space.
  - Measure: build KPIs and customer-level metrics.
  - Analyze: identify concentration and high-risk customers.
  - Improve: recommend tightening processes around specific high-impact accounts.
  - Control: propose dashboards using the exported summary tables.

---

## 7. “What would you do next?” answers

If asked how you would extend or improve this project:

- Build **segment-level or customer-cohort forecasts** instead of a single aggregate model, so you can see different behavior for different customer groups.
- Add **Power BI or Excel dashboards** that track:
  - Revenue and margin trends.
  - Top-customer concentration over time.
  - Overdue balances by customer and segment.
- Integrate process metrics (e.g., average days to pay, aging buckets) to support more targeted collections strategies.
- Introduce simple **scenario analysis** (e.g., what happens if one or two big customers churn or improve payment behavior by X%).

Use this file as your quick review before interviews so that when you talk about the project, you sound structured, confident, and business-focused.