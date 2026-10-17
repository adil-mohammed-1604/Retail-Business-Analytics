
USE RetailAnalyticsDB;
GO

-- Summarize revenue, order count, and last purchase for each customer.
SELECT TOP 10
    CAST(CustomerID AS INT) AS CustomerID,
    CAST(SUM(Revenue) AS DECIMAL(18, 2)) AS TotalRevenue,
    COUNT(DISTINCT InvoiceNo) AS TotalOrders,
    MAX(InvoiceDate) AS LastPurchaseDate
FROM dbo.retail_sales_cleaned
WHERE CustomerID IS NOT NULL
GROUP BY CAST(CustomerID AS INT)
ORDER BY SUM(Revenue) DESC;
GO
