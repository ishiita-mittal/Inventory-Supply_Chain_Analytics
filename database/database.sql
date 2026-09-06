-- ==============================================================================
-- DATABASE CREATION & SCHEMA DDL SCRIPT
-- Project: Inventory & Supply Chain Analytics Dashboard
-- Database: InventorySupplyChainDB
-- Target Engine: Microsoft SQL Server (T-SQL)
-- ==============================================================================

-- 1. Create Database if it does not already exist
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'InventorySupplyChainDB')
BEGIN
    CREATE DATABASE InventorySupplyChainDB;
    PRINT 'Database [InventorySupplyChainDB] created successfully.';
END
ELSE
BEGIN
    PRINT 'Database [InventorySupplyChainDB] already exists.';
END
GO

USE InventorySupplyChainDB;
GO

-- ==============================================================================
-- 2. Clean teardown (Reverse Foreign Key Order)
-- ==============================================================================
IF OBJECT_ID(N'dbo.Orders', N'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Orders;
    PRINT 'Dropped table [Orders].';
END
GO

IF OBJECT_ID(N'dbo.Inventory', N'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Inventory;
    PRINT 'Dropped table [Inventory].';
END
GO

IF OBJECT_ID(N'dbo.Products', N'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Products;
    PRINT 'Dropped table [Products].';
END
GO

IF OBJECT_ID(N'dbo.Warehouses', N'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Warehouses;
    PRINT 'Dropped table [Warehouses].';
END
GO

IF OBJECT_ID(N'dbo.Suppliers', N'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Suppliers;
    PRINT 'Dropped table [Suppliers].';
END
GO

-- ==============================================================================
-- 3. Table Creation
-- ==============================================================================

-- TABLE 1: Suppliers
-- Tracks vendor profile, expected fulfillment lead time, and quality rating.
CREATE TABLE dbo.Suppliers (
    SupplierID      INT             NOT NULL,
    SupplierName    VARCHAR(100)    NOT NULL,
    LeadTimeDays    INT             NOT NULL,
    SupplierRating  DECIMAL(3, 2)   NOT NULL,
    CONSTRAINT PK_Suppliers PRIMARY KEY CLUSTERED (SupplierID),
    CONSTRAINT CHK_Suppliers_LeadTime CHECK (LeadTimeDays >= 0),
    CONSTRAINT CHK_Suppliers_Rating CHECK (SupplierRating >= 0.00 AND SupplierRating <= 5.00)
);
PRINT 'Created table [Suppliers].';
GO

-- TABLE 2: Products
-- Product master catalog with unit cost, category classification, and primary vendor.
CREATE TABLE dbo.Products (
    ProductID       INT             NOT NULL,
    ProductName     VARCHAR(100)    NOT NULL,
    Category        VARCHAR(50)     NOT NULL,
    UnitCost        DECIMAL(10, 2)  NOT NULL,
    SupplierID      INT             NOT NULL,
    CONSTRAINT PK_Products PRIMARY KEY CLUSTERED (ProductID),
    CONSTRAINT FK_Products_Suppliers FOREIGN KEY (SupplierID) 
        REFERENCES dbo.Suppliers (SupplierID)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT CHK_Products_UnitCost CHECK (UnitCost >= 0.00)
);
PRINT 'Created table [Products].';
GO

-- TABLE 3: Warehouses
-- Physical facility details and geographic locations.
CREATE TABLE dbo.Warehouses (
    WarehouseID     INT             NOT NULL,
    WarehouseName   VARCHAR(100)    NOT NULL,
    Location        VARCHAR(100)    NOT NULL,
    CONSTRAINT PK_Warehouses PRIMARY KEY CLUSTERED (WarehouseID)
);
PRINT 'Created table [Warehouses].';
GO

-- TABLE 4: Inventory
-- Current stock levels, replenishment trigger points, and minimum safety reserves.
CREATE TABLE dbo.Inventory (
    InventoryID     INT             NOT NULL,
    ProductID       INT             NOT NULL,
    WarehouseID     INT             NOT NULL,
    CurrentStock    INT             NOT NULL,
    ReorderLevel    INT             NOT NULL,
    SafetyStock     INT             NOT NULL,
    CONSTRAINT PK_Inventory PRIMARY KEY CLUSTERED (InventoryID),
    CONSTRAINT FK_Inventory_Products FOREIGN KEY (ProductID) 
        REFERENCES dbo.Products (ProductID)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT FK_Inventory_Warehouses FOREIGN KEY (WarehouseID) 
        REFERENCES dbo.Warehouses (WarehouseID)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT UQ_Inventory_Product_Warehouse UNIQUE (ProductID, WarehouseID),
    CONSTRAINT CHK_Inventory_CurrentStock CHECK (CurrentStock >= 0),
    CONSTRAINT CHK_Inventory_ReorderLevel CHECK (ReorderLevel >= 0),
    CONSTRAINT CHK_Inventory_SafetyStock CHECK (SafetyStock >= 0),
    CONSTRAINT CHK_Inventory_ThresholdOrder CHECK (SafetyStock <= ReorderLevel)
);
PRINT 'Created table [Inventory].';
GO

-- TABLE 5: Orders
-- Customer/client sales order transactions fulfilling from designated warehouses.
CREATE TABLE dbo.Orders (
    OrderID         INT             NOT NULL,
    ProductID       INT             NOT NULL,
    WarehouseID     INT             NOT NULL,
    OrderDate       DATE            NOT NULL,
    Quantity        INT             NOT NULL,
    OrderStatus     VARCHAR(30)     NOT NULL,
    CONSTRAINT PK_Orders PRIMARY KEY CLUSTERED (OrderID),
    CONSTRAINT FK_Orders_Products FOREIGN KEY (ProductID) 
        REFERENCES dbo.Products (ProductID)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT FK_Orders_Warehouses FOREIGN KEY (WarehouseID) 
        REFERENCES dbo.Warehouses (WarehouseID)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT CHK_Orders_Quantity CHECK (Quantity > 0),
    CONSTRAINT CHK_Orders_Status CHECK (OrderStatus IN ('Completed', 'Shipped', 'Processing', 'Pending', 'Cancelled'))
);
PRINT 'Created table [Orders].';
GO

-- ==============================================================================
-- 4. Performance Indexes on Foreign Keys & Analytical Columns
-- ==============================================================================
CREATE NONCLUSTERED INDEX IX_Products_SupplierID ON dbo.Products(SupplierID);
CREATE NONCLUSTERED INDEX IX_Inventory_ProductID ON dbo.Inventory(ProductID);
CREATE NONCLUSTERED INDEX IX_Inventory_WarehouseID ON dbo.Inventory(WarehouseID);
CREATE NONCLUSTERED INDEX IX_Orders_ProductID ON dbo.Orders(ProductID);
CREATE NONCLUSTERED INDEX IX_Orders_WarehouseID ON dbo.Orders(WarehouseID);
CREATE NONCLUSTERED INDEX IX_Orders_OrderDate ON dbo.Orders(OrderDate);
PRINT 'Indexes created successfully.';
GO

PRINT 'Database schema setup complete.';
GO
