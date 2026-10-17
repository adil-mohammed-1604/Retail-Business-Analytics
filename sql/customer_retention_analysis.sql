
USE RetailAnalyticsDB;
GO

-- Identify each customer's first purchase month.
WITH CustomerFirstPurchase AS (
    SELECT
        CAST(CustomerID AS INT) AS CustomerID,
        MIN(DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1))
            AS FirstPurchaseMonth
    FROM dbo.retail_sales_cleaned
    WHERE CustomerID IS NOT NULL
    GROUP BY CAST(CustomerID AS INT)
),

-- Identify each customer's distinct purchase months.
CustomerMonthlyPurchases AS (
    SELECT DISTINCT
        CAST(CustomerID AS INT) AS CustomerID,
        DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1)
            AS PurchaseMonth
    FROM dbo.retail_sales_cleaned
    WHERE CustomerID IS NOT NULL
),

-- Count customers retained in each cohort and month.
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
),

-- Get the original size of each cohort.
CohortSize AS (
    SELECT
        FirstPurchaseMonth,
        COUNT(*) AS OriginalCustomers
    FROM CustomerFirstPurchase
    GROUP BY FirstPurchaseMonth
)

-- Calculate retention percentages.
SELECT
    cr.FirstPurchaseMonth,
    cr.MonthsSinceFirstPurchase,
    cs.OriginalCustomers,
    cr.RetainedCustomers,
    CAST(
        100.0 * cr.RetainedCustomers
        / NULLIF(cs.OriginalCustomers, 0)
        AS DECIMAL(5,2)
    ) AS RetentionPercentage
FROM CohortRetention AS cr
INNER JOIN CohortSize AS cs
    ON cr.FirstPurchaseMonth = cs.FirstPurchaseMonth
ORDER BY
    cr.FirstPurchaseMonth,
    cr.MonthsSinceFirstPurchase;
GO
