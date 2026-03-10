-- populate_dim_customer.sql
-- Populates dim_customer with synthetic B2B customers

-- Clear existing data
TRUNCATE TABLE dbo.dim_customer;

DECLARE @CustomerCount INT = 300;
DECLARE @i INT = 1;

WHILE @i <= @CustomerCount
BEGIN
    INSERT INTO dbo.dim_customer (
        customer_id,
        customer_name,
        industry,
        segment,
        region,
        size_band,
        signup_date_id,
        is_active
    )
    SELECT
        @i AS customer_id,
        CONCAT('Customer_', @i) AS customer_name,
        -- Industry (rotate through 5 industries)
        CHOOSE(((@i - 1) % 5) + 1, 'Healthcare', 'Finance', 'Retail', 'Tech', 'Manufacturing') AS industry,
        -- Segment (roughly 60% Small, 30% Mid, 10% Enterprise)
        CASE 
            WHEN @i <= @CustomerCount * 0.6 THEN 'Small'
            WHEN @i <= @CustomerCount * 0.9 THEN 'Mid'
            ELSE 'Enterprise'
        END AS segment,
        -- Region (rough split across 3 regions)
        CHOOSE(((@i - 1) % 3) + 1, 'North America', 'Europe', 'APAC') AS region,
        -- Size band based on segment
        CASE 
            WHEN @i <= @CustomerCount * 0.6 THEN '1-50'
            WHEN @i <= @CustomerCount * 0.9 THEN '51-200'
            ELSE '201-1000'
        END AS size_band,
        -- Signup date: spread over last 4 years
        (
            SELECT TOP 1 date_id 
            FROM dbo.dim_date 
            WHERE [date] BETWEEN DATEADD(YEAR, -4, GETDATE()) AND GETDATE()
            ORDER BY NEWID()
        ) AS signup_date_id,
        -- Most customers active, some inactive
        CASE 
            WHEN @i % 10 = 0 THEN 0   -- ~10% inactive
            ELSE 1
        END AS is_active;

    SET @i = @i + 1;
END;
