
USE RetailAnalyticsDB;
GO

-- Set the analysis date to one day after the latest transaction.
DECLARE @AnalysisDate DATE;

SELECT @AnalysisDate =
    DATEADD(DAY, 1, CAST(MAX(InvoiceDate) AS DATE))
FROM dbo.retail_sales_cleaned;

-- Summarize each customer's purchase behavior.
WITH CustomerMetrics AS (
    SELECT
        CAST(CustomerID AS INT) AS CustomerID,
        MAX(InvoiceDate) AS LastPurchaseDate,
        COUNT(DISTINCT InvoiceNo) AS TotalOrders,
        SUM(Revenue) AS TotalRevenue,
        DATEDIFF(
            DAY,
            MAX(InvoiceDate),
            @AnalysisDate
        ) AS RecencyDays
    FROM dbo.retail_sales_cleaned
    WHERE CustomerID IS NOT NULL
    GROUP BY CAST(CustomerID AS INT)
),

-- Select high-revenue customers who have not purchased recently.
HighValueAtRisk AS (
    SELECT
        *,
        NTILE(5) OVER (
            ORDER BY TotalRevenue DESC
        ) AS RevenueGroup
    FROM CustomerMetrics
)

SELECT TOP 20
    CustomerID,
    CAST(TotalRevenue AS DECIMAL(18, 2)) AS TotalRevenue,
    TotalOrders,
    LastPurchaseDate,
    RecencyDays
FROM HighValueAtRisk
WHERE RevenueGroup = 1
  AND RecencyDays >= 90
ORDER BY TotalRevenue DESC;
GO
