-- populate_fact_invoices.sql
-- Populates fact_invoices with synthetic invoice records based on subscriptions

-- Clear existing data
TRUNCATE TABLE dbo.fact_invoices;

DECLARE @InvoiceId INT = 1;

-- Cursor over subscriptions
DECLARE subscription_cursor CURSOR FAST_FORWARD FOR
SELECT 
    fs.subscription_id,
    fs.customer_id,
    fs.product_id,
    fs.start_date_id,
    fs.end_date_id,
    fs.billing_frequency,
    fs.mrr,
    fs.arr
FROM dbo.fact_subscriptions fs;

DECLARE @SubId INT;
DECLARE @CustomerId INT;
DECLARE @ProductId INT;
DECLARE @StartDateId INT;
DECLARE @EndDateId INT;
DECLARE @BillingFrequency VARCHAR(20);
DECLARE @MRR DECIMAL(12,2);
DECLARE @ARR DECIMAL(12,2);

OPEN subscription_cursor;
FETCH NEXT FROM subscription_cursor INTO 
    @SubId, @CustomerId, @ProductId, @StartDateId, @EndDateId, @BillingFrequency, @MRR, @ARR;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @CurrentDateId INT;
    DECLARE @EndBillingDateId INT;

    -- Determine billing period end (if no end_date, bill up to today)
    SET @CurrentDateId = @StartDateId;

    IF @EndDateId IS NOT NULL
        SET @EndBillingDateId = @EndDateId;
    ELSE
        SELECT @EndBillingDateId = date_id 
        FROM dbo.dim_date 
        WHERE [date] = CAST(GETDATE() AS DATE);

    WHILE @CurrentDateId <= @EndBillingDateId
    BEGIN
        DECLARE @InvoiceDateId INT = @CurrentDateId;
        DECLARE @DueDateId INT;
        DECLARE @PaidDateId INT;
        DECLARE @InvoiceAmount DECIMAL(12,2);
        DECLARE @CostAmount DECIMAL(12,2);
        DECLARE @TaxAmount DECIMAL(12,2);
        DECLARE @Status VARCHAR(20);

        -- Due date = invoice date + 30 days
        SELECT TOP 1 @DueDateId = date_id
        FROM dbo.dim_date
        WHERE [date] = DATEADD(DAY, 30, (SELECT [date] FROM dbo.dim_date WHERE date_id = @InvoiceDateId));

        -- Base invoice amount: MRR for Monthly, ARR for Annual
        IF @BillingFrequency = 'Monthly'
            SET @InvoiceAmount = @MRR;
        ELSE
            SET @InvoiceAmount = @ARR;

        -- Cost: random 40–70% of revenue
        SET @CostAmount = @InvoiceAmount * (0.4 + (ABS(CHECKSUM(NEWID())) % 31) / 100.0);

        -- Tax: random 5–10% of invoice amount
        SET @TaxAmount = @InvoiceAmount * (0.05 + (ABS(CHECKSUM(NEWID())) % 6) / 100.0);

        -- Payment behavior
        DECLARE @Rand INT = ABS(CHECKSUM(NEWID())) % 100;

        IF @Rand < 70
        BEGIN
            -- Paid on time or slightly early
            SELECT TOP 1 @PaidDateId = date_id
            FROM dbo.dim_date
            WHERE [date] BETWEEN
                  (SELECT [date] FROM dbo.dim_date WHERE date_id = @InvoiceDateId)
              AND (SELECT [date] FROM dbo.dim_date WHERE date_id = @DueDateId)
            ORDER BY NEWID();

            SET @Status = 'Paid';
        END
        ELSE IF @Rand < 90
        BEGIN
            -- Paid late
            SELECT TOP 1 @PaidDateId = date_id
            FROM dbo.dim_date
            WHERE [date] >
                  (SELECT [date] FROM dbo.dim_date WHERE date_id = @DueDateId)
              AND [date] <= GETDATE()
            ORDER BY NEWID();

            SET @Status = 'Paid';
        END
        ELSE
        BEGIN
            -- Still unpaid / overdue
            SET @PaidDateId = NULL;

            IF (SELECT [date] FROM dbo.dim_date WHERE date_id = @DueDateId) < GETDATE()
                SET @Status = 'Overdue';
            ELSE
                SET @Status = 'Unpaid';
        END

        -- Insert invoice row
        INSERT INTO dbo.fact_invoices (
            invoice_id,
            customer_id,
            product_id,
            invoice_date_id,
            due_date_id,
            paid_date_id,
            invoice_amount,
            cost_amount,
            tax_amount,
            currency,
            status
        )
        VALUES (
            @InvoiceId,
            @CustomerId,
            @ProductId,
            @InvoiceDateId,
            @DueDateId,
            @PaidDateId,
            @InvoiceAmount,
            @CostAmount,
            @TaxAmount,
            'USD',
            @Status
        );

        SET @InvoiceId = @InvoiceId + 1;

        -- Move to next billing period
        IF @BillingFrequency = 'Monthly'
        BEGIN
            SELECT TOP 1 @CurrentDateId = date_id
            FROM dbo.dim_date
            WHERE [date] >
                  (SELECT [date] FROM dbo.dim_date WHERE date_id = @CurrentDateId)
            ORDER BY [date];
        END
        ELSE
        BEGIN
            -- Annual: jump roughly 1 year forward
            SELECT TOP 1 @CurrentDateId = date_id
            FROM dbo.dim_date
            WHERE [date] >= DATEADD(YEAR, 1, (SELECT [date] FROM dbo.dim_date WHERE date_id = @CurrentDateId))
            ORDER BY [date];
        END

    END; -- end billing loop

    FETCH NEXT FROM subscription_cursor INTO 
        @SubId, @CustomerId, @ProductId, @StartDateId, @EndDateId, @BillingFrequency, @MRR, @ARR;
END;

CLOSE subscription_cursor;
DEALLOCATE subscription_cursor;
