# 📖 Data Dictionary: Inventory & Supply Chain Analytics

This document provides a comprehensive technical and business data dictionary for the **InventorySupplyChainDB** database and its analytical models in Power BI.

---

## 📑 Entity Index

1. [Suppliers Table](#1-suppliers-table)
2. [Products Table](#2-products-table)
3. [Warehouses Table](#3-warehouses-table)
4. [Inventory Table](#4-inventory-table)
5. [Orders Table](#5-orders-table)

---

## 1. Suppliers Table

* **Physical Name**: `dbo.Suppliers`
* **Model Entity**: `Dim_Suppliers`
* **Grain**: One record per approved external vendor / supplier.
* **Row Count**: 6 rows

| Column Name | SQL Data Type | Power BI Type | PK/FK | Nullable | Description & Business Rules | Example Values |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `SupplierID` | `INT` | Whole Number | **PK** | No | Unique identifier for each vendor. | `1`, `2`, `3` |
| `SupplierName` | `VARCHAR(100)` | Text | None | No | Legal commercial operating name of vendor. | `'TechCorp Components'`, `'Apex Global Logistics'` |
| `LeadTimeDays` | `INT` | Whole Number | None | No | Expected calendar days from purchase order placement to receipt at warehouse (`>= 0`). | `7`, `14`, `21` |
| `SupplierRating` | `DECIMAL(3,2)` | Decimal Number | None | No | Vendor scorecard rating evaluated from `0.00` to `5.00` based on historical on-time delivery and defect rate. | `4.85`, `4.20`, `3.90` |

---

## 2. Products Table

* **Physical Name**: `dbo.Products`
* **Model Entity**: `Dim_Products`
* **Grain**: One record per distinct product catalog SKU.
* **Row Count**: 15 rows

| Column Name | SQL Data Type | Power BI Type | PK/FK | Nullable | Description & Business Rules | Example Values |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `ProductID` | `INT` | Whole Number | **PK** | No | Unique internal identifier for the catalog item. | `1`, `2`, `3` |
| `ProductName` | `VARCHAR(100)` | Text | None | No | Standard descriptive commercial name of the product. | `'Enterprise Server Blade'`, `'Smart UPS 1500VA'` |
| `Category` | `VARCHAR(50)` | Text | None | No | High-level business classification (Electronics, Accessories, Networking, Storage, Components, Office Equipment, Power). | `'Networking'`, `'Storage'`, `'Power'` |
| `UnitCost` | `DECIMAL(10,2)` | Currency | None | No | Acquisition cost per unit paid to supplier in USD (`>= 0.00`). | `1250.00`, `320.00`, `35.00` |
| `SupplierID` | `INT` | Whole Number | **FK** | No | Foreign key linking to `Suppliers.SupplierID`. | `1`, `3`, `4` |

---

## 3. Warehouses Table

* **Physical Name**: `dbo.Warehouses`
* **Model Entity**: `Dim_Warehouses`
* **Grain**: One record per physical storage and distribution facility.
* **Row Count**: 4 rows

| Column Name | SQL Data Type | Power BI Type | PK/FK | Nullable | Description & Business Rules | Example Values |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `WarehouseID` | `INT` | Whole Number | **PK** | No | Unique facility identifier. | `1`, `2`, `3`, `4` |
| `WarehouseName` | `VARCHAR(100)` | Text | None | No | Commercial name of the facility. | `'Dallas Central Hub'`, `'Reno Logistics Center'` |
| `Location` | `VARCHAR(100)` | Text | None | No | City and State of the facility. | `'Dallas, TX'`, `'Chicago, IL'` |

---

## 4. Inventory Table

* **Physical Name**: `dbo.Inventory`
* **Model Entity**: `Fact_Inventory` (Periodic Snapshot)
* **Grain**: One record per Product per Warehouse location.
* **Row Count**: 26 rows

| Column Name | SQL Data Type | Power BI Type | PK/FK | Nullable | Description & Business Rules | Example Values |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `InventoryID` | `INT` | Whole Number | **PK** | No | Unique identifier for the inventory allocation row. | `1`, `2`, `3` |
| `ProductID` | `INT` | Whole Number | **FK** | No | Foreign key linking to `Products.ProductID`. | `1`, `2`, `3` |
| `WarehouseID` | `INT` | Whole Number | **FK** | No | Foreign key linking to `Warehouses.WarehouseID`. | `1`, `2`, `3` |
| `CurrentStock` | `INT` | Whole Number | None | No | Physical units currently available on the shelf (`>= 0`). | `12`, `4`, `80` |
| `ReorderLevel` | `INT` | Whole Number | None | No | Threshold that triggers a purchase replenishment order (`>= 0`). If `CurrentStock <= ReorderLevel`, reorder is required. | `15`, `10`, `50` |
| `SafetyStock` | `INT` | Whole Number | None | No | Buffer reserve to protect against lead time variability or sudden demand spikes (`>= 0`, `<= ReorderLevel`). If `CurrentStock <= SafetyStock`, critical stockout risk. | `5`, `15`, `20` |

---

## 5. Orders Table

* **Physical Name**: `dbo.Orders`
* **Model Entity**: `Fact_Orders` (Transactional Grain)
* **Grain**: One record per customer order line fulfillment.
* **Row Count**: 28 rows

| Column Name | SQL Data Type | Power BI Type | PK/FK | Nullable | Description & Business Rules | Example Values |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `OrderID` | `INT` | Whole Number | **PK** | No | Unique sales order line transaction ID. | `101`, `102`, `103` |
| `ProductID` | `INT` | Whole Number | **FK** | No | Foreign key linking to `Products.ProductID`. | `1`, `3`, `6` |
| `WarehouseID` | `INT` | Whole Number | **FK** | No | Foreign key identifying fulfillment warehouse. | `1`, `2`, `3`, `4` |
| `OrderDate` | `DATE` | Date | None | No | Calendar date when the order was placed (spanning 2026). | `'2026-01-14'`, `'2026-06-16'` |
| `Quantity` | `INT` | Whole Number | None | No | Number of units ordered (`> 0`). | `2`, `10`, `30` |
| `OrderStatus` | `VARCHAR(30)` | Text | None | No | Current fulfillment state (`'Completed'`, `'Shipped'`, `'Processing'`, `'Pending'`, `'Cancelled'`). | `'Completed'`, `'Shipped'` |
