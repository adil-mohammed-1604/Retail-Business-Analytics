
USE RetailAnalyticsDB;
GO

-- Calculate total revenue for each country.
WITH CountryRevenue AS (
    SELECT
        Country,
        SUM(Revenue) AS TotalRevenue
    FROM dbo.retail_sales_cleaned
    GROUP BY Country
),

-- Calculate total revenue across all countries.
CountryShare AS (
    SELECT
        Country,
        TotalRevenue,
        SUM(TotalRevenue) OVER () AS OverallRevenue,

        -- Rank countries by revenue from highest to lowest.
        RANK() OVER (
            ORDER BY TotalRevenue DESC
        ) AS RevenueRank
    FROM CountryRevenue
)

-- Calculate each country's percentage of total revenue.
SELECT
    Country,
    RevenueRank,
    CAST(TotalRevenue AS DECIMAL(18, 2)) AS TotalRevenue,
    CAST(
        100.0 * TotalRevenue / NULLIF(OverallRevenue, 0)
        AS DECIMAL(6, 2)
    ) AS RevenueSharePercentage
FROM CountryShare
ORDER BY RevenueRank;
GO
