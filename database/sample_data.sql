-- ==============================================================================
-- SAMPLE DATA INSERTION SCRIPT
-- Project: Inventory & Supply Chain Analytics Dashboard
-- Database: InventorySupplyChainDB
-- Target Engine: Microsoft SQL Server (T-SQL)
-- ==============================================================================

USE InventorySupplyChainDB;
GO

-- ==============================================================================
-- 1. Insert Suppliers (6 vendors)
-- ==============================================================================
INSERT INTO dbo.Suppliers (SupplierID, SupplierName, LeadTimeDays, SupplierRating) VALUES
(1, 'TechCorp Components', 7, 4.85),
(2, 'Apex Global Logistics', 14, 4.20),
(3, 'Silicon Distro', 10, 4.65),
(4, 'OmniPower Solutions', 21, 3.90),
(5, 'Pacific Optics & Fiber', 12, 4.75),
(6, 'Vanguard Office Hardware', 5, 4.50);

PRINT 'Inserted 6 suppliers.';
GO

-- ==============================================================================
-- 2. Insert Products (15 catalog items across 7 realistic categories)
-- ==============================================================================
INSERT INTO dbo.Products (ProductID, ProductName, Category, UnitCost, SupplierID) VALUES
(1, 'Enterprise Server Blade', 'Components', 1250.00, 1),
(2, '24-Port Gigabit PoE Switch', 'Networking', 320.00, 3),
(3, '4TB Enterprise NVMe SSD', 'Storage', 280.00, 3),
(4, 'Smart UPS 1500VA', 'Power', 450.00, 4),
(5, 'Ergonomic Mesh Chair', 'Office Equipment', 180.00, 6),
(6, 'Ultra-Wide 34-Inch Monitor', 'Electronics', 550.00, 1),
(7, 'Cat6a Shielded Cable 100m', 'Accessories', 35.00, 2),
(8, 'Industrial Surge Protector', 'Power', 65.00, 4),
(9, '10Gb SFP+ Optical Transceiver', 'Networking', 85.00, 5),
(10, 'Wireless Mechanical Keyboard', 'Accessories', 75.00, 6),
(11, '16TB SATA Enterprise HDD', 'Storage', 240.00, 3),
(12, 'Dual Monitor Arm Mount', 'Office Equipment', 95.00, 6),
(13, 'HD Conference Webcam 4K', 'Electronics', 140.00, 1),
(14, 'Fiber Optic Patch Cord 10m', 'Accessories', 18.00, 5),
(15, 'Heavy-Duty Server Rack 42U', 'Components', 850.00, 2);

PRINT 'Inserted 15 products.';
GO

-- ==============================================================================
-- 3. Insert Warehouses (4 distribution facilities)
-- ==============================================================================
INSERT INTO dbo.Warehouses (WarehouseID, WarehouseName, Location) VALUES
(1, 'Dallas Central Hub', 'Dallas, TX'),
(2, 'Reno Logistics Center', 'Reno, NV'),
(3, 'Chicago Midwest Depot', 'Chicago, IL'),
(4, 'Atlanta Distribution Center', 'Atlanta, GA');

PRINT 'Inserted 4 warehouses.';
GO

-- ==============================================================================
-- 4. Insert Inventory (26 multi-warehouse stock allocations)
-- Balances designed with realistic variation:
--   Healthy: CurrentStock > ReorderLevel (13 records)
--   Low Stock: SafetyStock < CurrentStock <= ReorderLevel (7 records)
--   Critical Stockout Risk: CurrentStock <= SafetyStock (6 records)
-- ==============================================================================
INSERT INTO dbo.Inventory (InventoryID, ProductID, WarehouseID, CurrentStock, ReorderLevel, SafetyStock) VALUES
(1,  1, 1,  12, 15,  5),  -- Low Stock (Reorder Required)
(2,  1, 2,   4, 10,  5),  -- Critical Stockout Risk (CurrentStock <= SafetyStock)
(3,  2, 1,  45, 30, 15),  -- Healthy
(4,  2, 3,  18, 25, 10),  -- Low Stock (Reorder Required)
(5,  3, 1,  80, 50, 20),  -- Healthy
(6,  3, 2,  15, 35, 15),  -- Critical Stockout Risk (CurrentStock <= SafetyStock)
(7,  4, 1,  22, 20,  8),  -- Healthy
(8,  4, 4,   6, 15,  8),  -- Critical Stockout Risk (CurrentStock <= SafetyStock)
(9,  5, 3,  35, 30, 10),  -- Healthy
(10, 5, 4,  14, 25, 10),  -- Low Stock (Reorder Required)
(11, 6, 1,  28, 20,  8),  -- Healthy
(12, 6, 2,   8, 15,  6),  -- Low Stock (Reorder Required)
(13, 7, 1, 150, 80, 30),  -- Healthy
(14, 7, 3,  40, 60, 25),  -- Low Stock (Reorder Required)
(15, 8, 2,  95, 50, 20),  -- Healthy
(16, 8, 4,  18, 40, 20),  -- Critical Stockout Risk (CurrentStock <= SafetyStock)
(17, 9, 1, 110, 60, 25),  -- Healthy
(18, 9, 2,  20, 45, 20),  -- Critical Stockout Risk (CurrentStock <= SafetyStock)
(19, 10, 3, 65, 40, 15),  -- Healthy
(20, 10, 4, 12, 30, 15),  -- Critical Stockout Risk (CurrentStock <= SafetyStock)
(21, 11, 1, 50, 35, 15),  -- Healthy
(22, 11, 3, 16, 25, 10),  -- Low Stock (Reorder Required)
(23, 12, 2, 42, 30, 10),  -- Healthy
(24, 13, 1, 38, 25, 10),  -- Healthy
(25, 14, 4, 120, 60, 25), -- Healthy
(26, 15, 1,  7, 10,  4);  -- Low Stock (Reorder Required)

PRINT 'Inserted 26 inventory records.';
GO

-- ==============================================================================
-- 5. Insert Orders (28 customer orders across 2026)
-- Realistic distribution of fulfillment statuses across the year 2026
-- ==============================================================================
INSERT INTO dbo.Orders (OrderID, ProductID, WarehouseID, OrderDate, Quantity, OrderStatus) VALUES
(101, 1,  1, '2026-01-14',  2, 'Completed'),
(102, 3,  1, '2026-01-22', 10, 'Completed'),
(103, 2,  3, '2026-02-05',  5, 'Completed'),
(104, 6,  1, '2026-02-18',  4, 'Completed'),
(105, 7,  3, '2026-02-27', 15, 'Completed'),
(106, 4,  4, '2026-03-08',  3, 'Completed'),
(107, 9,  1, '2026-03-15', 20, 'Completed'),
(108, 5,  4, '2026-03-29',  6, 'Completed'),
(109, 11, 1, '2026-04-03',  8, 'Completed'),
(110, 10, 4, '2026-04-12',  5, 'Cancelled'),
(111, 8,  2, '2026-04-20', 12, 'Completed'),
(112, 1,  2, '2026-05-02',  1, 'Completed'),
(113, 14, 4, '2026-05-14', 25, 'Completed'),
(114, 12, 2, '2026-05-25',  7, 'Completed'),
(115, 13, 1, '2026-06-04',  6, 'Completed'),
(116, 2,  1, '2026-06-16',  8, 'Completed'),
(117, 15, 1, '2026-06-28',  2, 'Completed'),
(118, 3,  2, '2026-07-05',  5, 'Shipped'),
(119, 7,  1, '2026-07-12', 30, 'Shipped'),
(120, 4,  1, '2026-07-21',  4, 'Shipped'),
(121, 9,  2, '2026-07-30',  8, 'Shipped'),
(122, 6,  2, '2026-08-04',  3, 'Processing'),
(123, 8,  4, '2026-08-11',  6, 'Processing'),
(124, 10, 3, '2026-08-18', 10, 'Processing'),
(125, 5,  3, '2026-08-25',  5, 'Pending'),
(126, 11, 3, '2026-08-29',  4, 'Pending'),
(127, 1,  1, '2026-09-02',  2, 'Pending'),
(128, 15, 1, '2026-09-04',  1, 'Pending');

PRINT 'Inserted 28 orders.';
GO

PRINT 'Sample data insertion complete.';
GO
