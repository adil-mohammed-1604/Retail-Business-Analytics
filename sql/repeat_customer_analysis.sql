USE RetailAnalyticsDB;
GO

-- Count the number of orders placed by each known customer.
WITH CustomerOrders AS (
    SELECT
        CAST(CustomerID AS INT) AS CustomerID,
        COUNT(DISTINCT InvoiceNo) AS OrderCount
    FROM dbo.retail_sales_cleaned
    WHERE CustomerID IS NOT NULL
    GROUP BY CAST(CustomerID AS INT)
)

-- Group customers by how many orders they placed.
SELECT
    CASE
        WHEN OrderCount = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS CustomerType,
    COUNT(*) AS NumberOfCustomers,
    SUM(OrderCount) AS TotalOrders
FROM CustomerOrders
GROUP BY
    CASE
        WHEN OrderCount = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END
ORDER BY NumberOfCustomers DESC;





USE RetailAnalyticsDB;
GO

-- Find each known customer's first purchase month.
WITH CustomerFirstPurchase AS (
    SELECT
        CAST(CustomerID AS INT) AS CustomerID,
        MIN(DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1))
            AS FirstPurchaseMonth
    FROM dbo.retail_sales_cleaned
    WHERE CustomerID IS NOT NULL
    GROUP BY CAST(CustomerID AS INT)
),

-- Find the distinct months in which each customer purchased.
CustomerMonthlyPurchases AS (
    SELECT DISTINCT
        CAST(CustomerID AS INT) AS CustomerID,
        DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1)
            AS PurchaseMonth
    FROM dbo.retail_sales_cleaned
    WHERE CustomerID IS NOT NULL
),

-- Count customers from each first-purchase month who returned.
CohortRetention AS (
    SELECT
        fp.FirstPurchaseMonth,
        DATEDIFF(
            MONTH,
            fp.FirstPurchaseMonth,
            mp.PurchaseMonth
        ) AS MonthsSinceFirstPurchase,
        COUNT(DISTINCT mp.CustomerID) AS RetainedCustomers
    FROM CustomerFirstPurchase AS fp
    INNER JOIN CustomerMonthlyPurchases AS mp
        ON fp.CustomerID = mp.CustomerID
    GROUP BY
        fp.FirstPurchaseMonth,
        DATEDIFF(
            MONTH,
            fp.FirstPurchaseMonth,
            mp.PurchaseMonth
        )
)

-- Display retained customers by cohort and month.
SELECT
    FirstPurchaseMonth,
    MonthsSinceFirstPurchase,
    RetainedCustomers
FROM CohortRetention
ORDER BY
    FirstPurchaseMonth,
    MonthsSinceFirstPurchase;
GO


