-- populate_fact_subscriptions.sql
-- Populates fact_subscriptions with synthetic SaaS subscription records

-- Clear existing data
TRUNCATE TABLE dbo.fact_subscriptions;

DECLARE @MaxSubscriptionId INT = 1;

-- Cursor over active customers
DECLARE customer_cursor CURSOR FAST_FORWARD FOR
SELECT customer_id, segment
FROM dbo.dim_customer
WHERE is_active = 1;

DECLARE @CustomerId INT;
DECLARE @Segment    VARCHAR(50);

OPEN customer_cursor;

FETCH NEXT FROM customer_cursor INTO @CustomerId, @Segment;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @SubCount INT;

    -- Small: 1 subscription, Mid: 1-2, Enterprise: 2-3
    SET @SubCount = CASE 
                        WHEN @Segment = 'Small' THEN 1
                        WHEN @Segment = 'Mid' THEN 1 + (ABS(CHECKSUM(NEWID())) % 2)
                        ELSE 2 + (ABS(CHECKSUM(NEWID())) % 2)
                    END;

    DECLARE @s INT = 1;

    WHILE @s <= @SubCount
    BEGIN
        DECLARE @ProductId INT;
        DECLARE @BillingFrequency VARCHAR(20);
        DECLARE @StartDateId INT;
        DECLARE @EndDateId INT;
        DECLARE @IsActive BIT;
        DECLARE @MRR DECIMAL(12,2);
        DECLARE @ARR DECIMAL(12,2);
        DECLARE @BasePrice DECIMAL(12,2);

        -- Random product
        SELECT TOP 1 
            @ProductId = product_id,
            @BasePrice = base_monthly_price
        FROM dbo.dim_product
        ORDER BY NEWID();

        -- Billing frequency (more Monthly than Annual)
        SET @BillingFrequency = CASE 
                                    WHEN ABS(CHECKSUM(NEWID())) % 100 < 70 THEN 'Monthly'
                                    ELSE 'Annual'
                                END;

        -- Start date: random in last 3 years
        SELECT TOP 1 @StartDateId = date_id
        FROM dbo.dim_date
        WHERE [date] BETWEEN DATEADD(YEAR, -3, GETDATE()) AND GETDATE()
        ORDER BY NEWID();

        -- Some subscriptions ended, others active
        IF ABS(CHECKSUM(NEWID())) % 100 < 20  -- ~20% ended
        BEGIN
            SELECT TOP 1 @EndDateId = date_id
            FROM dbo.dim_date
            WHERE date_id > @StartDateId
              AND [date] <= GETDATE()
            ORDER BY NEWID();

            SET @IsActive = 0;
        END
        ELSE
        BEGIN
            SET @EndDateId = NULL;
            SET @IsActive = 1;
        END;

        -- MRR and ARR based on base price and billing frequency
        IF @BillingFrequency = 'Monthly'
        BEGIN
            SET @MRR = @BasePrice;
            SET @ARR = @BasePrice * 12;
        END
        ELSE
        BEGIN
            -- Annual billing: MRR is ARR / 12
            SET @ARR = @BasePrice * 12;
            SET @MRR = @ARR / 12;
        END;

        INSERT INTO dbo.fact_subscriptions (
            subscription_id,
            customer_id,
            product_id,
            start_date_id,
            end_date_id,
            billing_frequency,
            mrr,
            arr,
            is_active
        )
        VALUES (
            @MaxSubscriptionId,
            @CustomerId,
            @ProductId,
            @StartDateId,
            @EndDateId,
            @BillingFrequency,
            @MRR,
            @ARR,
            @IsActive
        );

        SET @MaxSubscriptionId = @MaxSubscriptionId + 1;
        SET @s = @s + 1;
    END;

    FETCH NEXT FROM customer_cursor INTO @CustomerId, @Segment;
END;

CLOSE customer_cursor;
DEALLOCATE customer_cursor;
