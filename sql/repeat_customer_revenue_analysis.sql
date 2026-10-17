
USE RetailAnalyticsDB;
GO

-- Summarize each known customer's orders and revenue.
WITH CustomerMetrics AS (
    SELECT
        CAST(CustomerID AS INT) AS CustomerID,
        COUNT(DISTINCT InvoiceNo) AS TotalOrders,
        SUM(Revenue) AS TotalRevenue
    FROM dbo.retail_sales_cleaned
    WHERE CustomerID IS NOT NULL
    GROUP BY CAST(CustomerID AS INT)
),

-- Classify customers based on their number of orders.
CustomerTypes AS (
    SELECT
        CustomerID,
        TotalOrders,
        TotalRevenue,
        CASE
            WHEN TotalOrders = 1 THEN 'One-Time Customer'
            ELSE 'Repeat Customer'
        END AS CustomerType
    FROM CustomerMetrics
)

-- Compare customer counts and revenue by customer type.
SELECT
    CustomerType,
    COUNT(*) AS NumberOfCustomers,
    SUM(TotalOrders) AS TotalOrders,
    CAST(SUM(TotalRevenue) AS DECIMAL(18, 2)) AS TotalRevenue,
    CAST(
        100.0 * SUM(TotalRevenue)
        / NULLIF(SUM(SUM(TotalRevenue)) OVER (), 0)
        AS DECIMAL(5, 2)
    ) AS RevenueSharePercentage
FROM CustomerTypes
GROUP BY CustomerType
ORDER BY TotalRevenue DESC;
GO
