-- ==============================================================================
-- ANALYTICAL T-SQL QUERIES
-- Project: Inventory & Supply Chain Analytics Dashboard
-- Database: InventorySupplyChainDB
-- Target Engine: Microsoft SQL Server (T-SQL)
-- ==============================================================================

USE InventorySupplyChainDB;
GO

-- ==============================================================================
-- QUERY 1: Total Inventory Value & Total Units in Stock
-- Calculates total financial capital tied up in inventory across all warehouses.
-- Expected Total Value: $172,060.00 | Total Units: 1,070
-- ==============================================================================
SELECT 
    COUNT(DISTINCT i.ProductID)                     AS TotalActiveProducts,
    SUM(i.CurrentStock)                             AS TotalUnitsInStock,
    CAST(SUM(i.CurrentStock * p.UnitCost) AS DECIMAL(12,2)) AS TotalInventoryValue,
    CAST(AVG(p.UnitCost) AS DECIMAL(10,2))          AS AverageCatalogUnitCost
FROM dbo.Inventory i
INNER JOIN dbo.Products p ON i.ProductID = p.ProductID;
GO

-- ==============================================================================
-- QUERY 2: Warehouse-Wise Inventory Distribution
-- Shows stock volume and inventory value breakdown per physical warehouse.
-- ==============================================================================
SELECT 
    w.WarehouseID,
    w.WarehouseName,
    w.Location,
    COUNT(i.ProductID)                              AS StockKeepingUnitsCount,
    SUM(i.CurrentStock)                             AS TotalUnitsInStock,
    CAST(SUM(i.CurrentStock * p.UnitCost) AS DECIMAL(12,2)) AS WarehouseInventoryValue,
    CAST(
        SUM(i.CurrentStock * p.UnitCost) * 100.0 / 
        (SELECT SUM(i2.CurrentStock * p2.UnitCost) 
         FROM dbo.Inventory i2 
         INNER JOIN dbo.Products p2 ON i2.ProductID = p2.ProductID)
        AS DECIMAL(5,2)
    ) AS InventoryValueSharePct
FROM dbo.Warehouses w
INNER JOIN dbo.Inventory i ON w.WarehouseID = i.WarehouseID
INNER JOIN dbo.Products p ON i.ProductID = p.ProductID
GROUP BY w.WarehouseID, w.WarehouseName, w.Location
ORDER BY WarehouseInventoryValue DESC;
GO

-- ==============================================================================
-- QUERY 3: Inventory Value and Units by Product Category
-- Identifies which product segments represent the largest share of working capital.
-- ==============================================================================
SELECT 
    p.Category,
    COUNT(DISTINCT p.ProductID)                     AS ProductCount,
    SUM(i.CurrentStock)                             AS TotalUnitsInStock,
    CAST(SUM(i.CurrentStock * p.UnitCost) AS DECIMAL(12,2)) AS CategoryInventoryValue,
    CAST(
        SUM(i.CurrentStock * p.UnitCost) * 100.0 / 
        (SELECT SUM(i2.CurrentStock * p2.UnitCost) 
         FROM dbo.Inventory i2 
         INNER JOIN dbo.Products p2 ON i2.ProductID = p2.ProductID)
        AS DECIMAL(5,2)
    ) AS CategoryValueSharePct
FROM dbo.Products p
INNER JOIN dbo.Inventory i ON p.ProductID = i.ProductID
GROUP BY p.Category
ORDER BY CategoryInventoryValue DESC;
GO

-- ==============================================================================
-- QUERY 4: Low-Stock Products Requiring Replenishment
-- Returns inventory records where CurrentStock <= ReorderLevel.
-- Rule: If CurrentStock <= ReorderLevel -> "Reorder Required"
-- ==============================================================================
SELECT 
    i.InventoryID,
    p.ProductID,
    p.ProductName,
    p.Category,
    w.WarehouseName,
    i.CurrentStock,
    i.ReorderLevel,
    i.SafetyStock,
    (i.ReorderLevel - i.CurrentStock)               AS ShortageBelowReorder,
    CASE 
        WHEN i.CurrentStock <= i.SafetyStock THEN 'Critical Stockout Risk'
        WHEN i.CurrentStock <= i.ReorderLevel THEN 'Reorder Required'
        ELSE 'Stock Healthy'
    END AS StockStatus
FROM dbo.Inventory i
INNER JOIN dbo.Products p ON i.ProductID = p.ProductID
INNER JOIN dbo.Warehouses w ON i.WarehouseID = w.WarehouseID
WHERE i.CurrentStock <= i.ReorderLevel
ORDER BY 
    CASE WHEN i.CurrentStock <= i.SafetyStock THEN 1 ELSE 2 END,
    (i.ReorderLevel - i.CurrentStock) DESC;
GO

-- ==============================================================================
-- QUERY 5: Products Below Reorder Level with Estimated Reorder Cost
-- Calculates how much budget is needed to bring low-stock items back up to ReorderLevel.
-- ==============================================================================
SELECT 
    p.ProductID,
    p.ProductName,
    w.WarehouseName,
    s.SupplierName,
    s.LeadTimeDays,
    p.UnitCost,
    i.CurrentStock,
    i.ReorderLevel,
    (i.ReorderLevel - i.CurrentStock)               AS UnitsNeededToReachReorder,
    CAST((i.ReorderLevel - i.CurrentStock) * p.UnitCost AS DECIMAL(10,2)) AS EstimatedReplenishmentCost
FROM dbo.Inventory i
INNER JOIN dbo.Products p ON i.ProductID = p.ProductID
INNER JOIN dbo.Warehouses w ON i.WarehouseID = w.WarehouseID
INNER JOIN dbo.Suppliers s ON p.SupplierID = s.SupplierID
WHERE i.CurrentStock <= i.ReorderLevel
ORDER BY EstimatedReplenishmentCost DESC;
GO

-- ==============================================================================
-- QUERY 6: Critical Stockout-Risk Products
-- Stockout Risk Rule: CurrentStock <= SafetyStock
-- These items are in imminent danger of complete fulfillment disruption.
-- ==============================================================================
SELECT 
    i.InventoryID,
    p.ProductName,
    p.Category,
    w.WarehouseName,
    s.SupplierName,
    s.LeadTimeDays,
    i.CurrentStock,
    i.SafetyStock,
    i.ReorderLevel,
    CAST((i.CurrentStock * 100.0 / NULLIF(i.SafetyStock, 0)) AS DECIMAL(5,2)) AS SafetyStockCoveragePct
FROM dbo.Inventory i
INNER JOIN dbo.Products p ON i.ProductID = p.ProductID
INNER JOIN dbo.Warehouses w ON i.WarehouseID = w.WarehouseID
INNER JOIN dbo.Suppliers s ON p.SupplierID = s.SupplierID
WHERE i.CurrentStock <= i.SafetyStock
ORDER BY i.CurrentStock ASC;
GO

-- ==============================================================================
-- QUERY 7: Supplier Performance & Product Portfolio Overview
-- Analyzes vendor lead times, ratings, and total product value supplied.
-- ==============================================================================
SELECT 
    s.SupplierID,
    s.SupplierName,
    s.LeadTimeDays,
    s.SupplierRating,
    COUNT(DISTINCT p.ProductID)                     AS ProductsSuppliedCount,
    COALESCE(SUM(i.CurrentStock), 0)                AS TotalUnitsInStock,
    CAST(COALESCE(SUM(i.CurrentStock * p.UnitCost), 0) AS DECIMAL(12,2)) AS TotalInventoryValueSupplied
FROM dbo.Suppliers s
LEFT JOIN dbo.Products p ON s.SupplierID = p.SupplierID
LEFT JOIN dbo.Inventory i ON p.ProductID = i.ProductID
GROUP BY s.SupplierID, s.SupplierName, s.LeadTimeDays, s.SupplierRating
ORDER BY s.SupplierRating DESC, s.LeadTimeDays ASC;
GO

-- ==============================================================================
-- QUERY 8: Total Ordered Quantity & Order Status Distribution
-- Overview of all customer demand transactions.
-- ==============================================================================
SELECT 
    OrderStatus,
    COUNT(OrderID)                                  AS TotalOrdersCount,
    SUM(Quantity)                                   AS TotalOrderedUnits,
    CAST(AVG(Quantity * 1.0) AS DECIMAL(5,2))       AS AverageUnitsPerOrder
FROM dbo.Orders
GROUP BY OrderStatus
ORDER BY TotalOrdersCount DESC;
GO

-- ==============================================================================
-- QUERY 9: Monthly Order Trend (2026)
-- Examines demand seasonality and monthly order throughput across 2026.
-- ==============================================================================
SELECT 
    YEAR(OrderDate)                                 AS OrderYear,
    MONTH(OrderDate)                                AS OrderMonth,
    DATENAME(MONTH, OrderDate)                      AS MonthName,
    COUNT(OrderID)                                  AS TotalOrders,
    SUM(Quantity)                                   AS TotalUnitsOrdered
FROM dbo.Orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate), DATENAME(MONTH, OrderDate)
ORDER BY OrderYear, OrderMonth;
GO

-- ==============================================================================
-- QUERY 10: ABC Inventory Classification (SQL Window Function Implementation)
-- Ranks products by total inventory value and calculates cumulative percentage:
--   - Class A: Top items contributing up to 70% of total inventory value
--   - Class B: Items contributing between 70% and 90% of total inventory value
--   - Class C: Items contributing the remaining 10% (90% to 100%) of value
-- ==============================================================================
WITH ProductInventoryValue AS (
    SELECT 
        p.ProductID,
        p.ProductName,
        p.Category,
        p.UnitCost,
        SUM(i.CurrentStock)                         AS TotalUnitsInStock,
        CAST(SUM(i.CurrentStock * p.UnitCost) AS DECIMAL(12,2)) AS ProductInventoryValue
    FROM dbo.Products p
    INNER JOIN dbo.Inventory i ON p.ProductID = i.ProductID
    GROUP BY p.ProductID, p.ProductName, p.Category, p.UnitCost
),
RankedProducts AS (
    SELECT 
        ProductID,
        ProductName,
        Category,
        UnitCost,
        TotalUnitsInStock,
        ProductInventoryValue,
        SUM(ProductInventoryValue) OVER (
            ORDER BY ProductInventoryValue DESC, ProductID ASC
        ) AS CumulativeValue,
        SUM(ProductInventoryValue) OVER () AS GrandTotalValue
    FROM ProductInventoryValue
)
SELECT 
    ProductID,
    ProductName,
    Category,
    UnitCost,
    TotalUnitsInStock,
    ProductInventoryValue,
    CumulativeValue,
    CAST((CumulativeValue * 100.0 / GrandTotalValue) AS DECIMAL(5,2)) AS CumulativeValuePct,
    CASE 
        WHEN (CumulativeValue * 100.0 / GrandTotalValue) <= 70.0 THEN 'A'
        WHEN (CumulativeValue * 100.0 / GrandTotalValue) <= 90.0 THEN 'B'
        ELSE 'C'
    END AS ABC_Classification
FROM RankedProducts
ORDER BY ProductInventoryValue DESC;
GO

PRINT 'Analytical queries execution completed.';
GO
