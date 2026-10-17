
USE RetailAnalyticsDB;
GO

-- Calculate revenue for each month.
WITH MonthlySales AS (
    SELECT
        DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1)
            AS SalesMonth,
        SUM(Revenue) AS MonthlyRevenue
    FROM dbo.retail_sales_cleaned
    GROUP BY
        DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1)
),

-- Compare each month with the previous month.
MonthlyComparison AS (
    SELECT
        SalesMonth,
        MonthlyRevenue,
        LAG(MonthlyRevenue) OVER (
            ORDER BY SalesMonth
        ) AS PreviousMonthRevenue
    FROM MonthlySales
)

-- Calculate the absolute and percentage change in revenue.
SELECT
    SalesMonth,
    CAST(MonthlyRevenue AS DECIMAL(18, 2)) AS MonthlyRevenue,
    CAST(PreviousMonthRevenue AS DECIMAL(18, 2))
        AS PreviousMonthRevenue,
    CAST(
        MonthlyRevenue - PreviousMonthRevenue
        AS DECIMAL(18, 2)
    ) AS RevenueChange,
    CAST(
        100.0 * (MonthlyRevenue - PreviousMonthRevenue)
        / NULLIF(PreviousMonthRevenue, 0)
        AS DECIMAL(8, 2)
    ) AS MonthOverMonthGrowthPercentage
FROM MonthlyComparison
ORDER BY SalesMonth;
GO
