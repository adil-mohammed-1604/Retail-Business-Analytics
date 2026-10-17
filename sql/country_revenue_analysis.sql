
-- Create the database for the retail analytics project
CREATE DATABASE RetailAnalyticsDB;
GO

-- Select the new database
USE RetailAnalyticsDB;
GO



USE RetailAnalyticsDB;
GO


USE RetailAnalyticsDB;
GO

-- List all tables in the current database
SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';
GO



USE RetailAnalyticsDB;
GO

-- Check the total number of imported rows
SELECT COUNT(*) AS TotalRows
FROM dbo.retail_sales_cleaned;
GO

-- Preview the first 10 records
SELECT TOP 10 *
FROM dbo.retail_sales_cleaned;
GO

-- Check for missing customer IDs
SELECT COUNT(*) AS MissingCustomerIDs
FROM dbo.retail_sales_cleaned
WHERE CustomerID IS NULL;
GO



USE RetailAnalyticsDB;
GO

-- 1. Overall sales performance
SELECT
    SUM(Revenue) AS TotalRevenue,
    COUNT(DISTINCT InvoiceNo) AS TotalOrders,
    COUNT(DISTINCT CustomerID) AS UniqueCustomers,
    CAST(
        SUM(Revenue) / NULLIF(COUNT(DISTINCT InvoiceNo), 0)
        AS DECIMAL(18, 2)
    ) AS AverageOrderValue
FROM dbo.retail_sales_cleaned;
GO

-- 2. Monthly revenue and order volume
SELECT
    YEAR(InvoiceDate) AS SalesYear,
    MONTH(InvoiceDate) AS SalesMonth,
    SUM(Revenue) AS MonthlyRevenue,
    COUNT(DISTINCT InvoiceNo) AS MonthlyOrders
FROM dbo.retail_sales_cleaned
GROUP BY
    YEAR(InvoiceDate),
    MONTH(InvoiceDate)
ORDER BY
    SalesYear,
    SalesMonth;
GO

-- 3. Top 10 products by revenue
SELECT TOP 10
    StockCode,
    Description,
    SUM(Revenue) AS TotalRevenue,
    SUM(Quantity) AS UnitsSold
FROM dbo.retail_sales_cleaned
GROUP BY
    StockCode,
    Description
ORDER BY
    TotalRevenue DESC;
GO



USE RetailAnalyticsDB;
GO

-- Rank countries by total revenue using a CTE and window function
WITH CountrySales AS (
    SELECT
        Country,
        SUM(Revenue) AS TotalRevenue,
        COUNT(DISTINCT InvoiceNo) AS TotalOrders
    FROM dbo.retail_sales_cleaned
    GROUP BY Country
)
SELECT
    Country,
    TotalRevenue,
    TotalOrders,
    RANK() OVER (ORDER BY TotalRevenue DESC) AS RevenueRank
FROM CountrySales
ORDER BY RevenueRank;
GO



USE RetailAnalyticsDB;
GO

-- Calculate country revenue and order counts separately, then join them
WITH CountryRevenue AS (
    SELECT
        Country,
        SUM(Revenue) AS TotalRevenue
    FROM dbo.retail_sales_cleaned
    GROUP BY Country
),
CountryOrders AS (
    SELECT
        Country,
        COUNT(DISTINCT InvoiceNo) AS TotalOrders
    FROM dbo.retail_sales_cleaned
    GROUP BY Country
)
SELECT
    cr.Country,
    cr.TotalRevenue,
    co.TotalOrders,
    CAST(
        cr.TotalRevenue / NULLIF(co.TotalOrders, 0)
        AS DECIMAL(18, 2)
    ) AS RevenuePerOrder
FROM CountryRevenue AS cr
INNER JOIN CountryOrders AS co
    ON cr.Country = co.Country
ORDER BY cr.TotalRevenue DESC;
GO


