-- populate_dim_date.sql
-- Populates dim_date with a calendar range for reporting

-- Adjust these as needed
DECLARE @StartDate DATE = '2020-01-01';
DECLARE @EndDate   DATE = '2026-12-31';

-- Clear existing data (if any)
TRUNCATE TABLE dbo.dim_date;

;WITH Dates AS (
    SELECT @StartDate AS [date]
    UNION ALL
    SELECT DATEADD(DAY, 1, [date])
    FROM Dates
    WHERE [date] < @EndDate
)
INSERT INTO dbo.dim_date (
    date_id,
    [date],
    [day],
    [month],
    month_name,
    [quarter],
    [year]
)
SELECT 
    CONVERT(INT, FORMAT([date], 'yyyyMMdd')) AS date_id,
    [date],
    DAY([date])                              AS [day],
    MONTH([date])                            AS [month],
    DATENAME(MONTH, [date])                  AS month_name,
    DATEPART(QUARTER, [date])                AS [quarter],
    YEAR([date])                             AS [year]
FROM Dates
OPTION (MAXRECURSION 32767);
