# Power BI Data Model

## Overview

This document describes the simple star-schema-oriented data model used for the **Inventory & Supply Chain Analytics Dashboard** prototype.

The model separates descriptive dimension tables (Suppliers, Products, Warehouses) from quantitative fact tables (Inventory, Orders).

---

## Tables & Roles

| Table Name | Model Role | Primary Key | Foreign Keys | Description |
| :--- | :--- | :--- | :--- | :--- |
| **Suppliers** | Dimension | `SupplierID` | None | Vendor details, lead times, and ratings |
| **Products** | Dimension | `ProductID` | `SupplierID` | Product catalog, categories, and unit costs |
| **Warehouses** | Dimension | `WarehouseID` | None | Physical warehouse locations |
| **Inventory** | Fact | `InventoryID` | `ProductID`, `WarehouseID` | Current stock, reorder levels, safety stock |
| **Orders** | Fact | `OrderID` | `ProductID`, `WarehouseID` | Customer order transactions across 2026 |

---

## Model Relationships

All relationships in this prototype use standard **One-to-Many (`1:*`)** cardinality with a **Single cross-filter direction** flowing from dimensions to facts:

1. **Suppliers → Products**
   * Primary Key: `Suppliers[SupplierID]`
   * Foreign Key: `Products[SupplierID]`
   * Cardinality: 1 to Many (`1:*`)
   * Purpose: Filters products by vendor name or lead time.

2. **Products → Inventory**
   * Primary Key: `Products[ProductID]`
   * Foreign Key: `Inventory[ProductID]`
   * Cardinality: 1 to Many (`1:*`)
   * Purpose: Filters inventory balances and threshold alerts by product and category.

3. **Warehouses → Inventory**
   * Primary Key: `Warehouses[WarehouseID]`
   * Foreign Key: `Inventory[WarehouseID]`
   * Cardinality: 1 to Many (`1:*`)
   * Purpose: Filters stock allocations by warehouse facility and geographic location.

4. **Products → Orders**
   * Primary Key: `Products[ProductID]`
   * Foreign Key: `Orders[ProductID]`
   * Cardinality: 1 to Many (`1:*`)
   * Purpose: Analyzes order quantities and demand by product and category.

5. **Warehouses → Orders**
   * Primary Key: `Warehouses[WarehouseID]`
   * Foreign Key: `Orders[WarehouseID]`
   * Cardinality: 1 to Many (`1:*`)
   * Purpose: Tracks fulfillment volume and order statuses by warehouse.

---

## Model Diagram

```text
               +----------------------+
               |      Suppliers       |
               |----------------------|
               | PK  SupplierID       |
               |     SupplierName     |
               |     LeadTimeDays     |
               |     SupplierRating   |
               +----------+-----------+
                          | 1
                          |
                          | *
               +----------v-----------+
               |       Products       |
               |----------------------|
               | PK  ProductID        |
               |     ProductName      |
               |     Category         |
               |     UnitCost         |
               | FK  SupplierID       |
               +-----+----------+-----+
                     | 1        | 1
                     |          |
       +-------------+          +-------------+
       | *                                    | *
+------v-----------------+             +------v-----------------+
|       Inventory        |             |         Orders         |
|------------------------|             |------------------------|
| PK  InventoryID        |             | PK  OrderID            |
| FK  ProductID          |             | FK  ProductID          |
| FK  WarehouseID        |             | FK  WarehouseID        |
|     CurrentStock       |             |     OrderDate          |
|     ReorderLevel       |             |     Quantity           |
|     SafetyStock        |             |     OrderStatus        |
+------^-----------------+             +------^-----------------+
       | *                                    | *
       |                                      |
       +-------------+          +-------------+
                     | 1        | 1
               +-----+----------+-----+
               |      Warehouses      |
               |----------------------|
               | PK  WarehouseID      |
               |     WarehouseName    |
               |     Location         |
               +----------------------+
```

---

## Key Modeling Principles

* **Single-Direction Filtering**: Filters flow strictly from dimensions down to facts. This prevents circular filter paths and unexpected calculation results.
* **No Direct Fact-to-Fact Joins**: `Inventory` and `Orders` are not joined directly. Instead, both connect to shared dimensions (`Products` and `Warehouses`).
* **Easy to Explain**: This structure follows standard Kimball dimensional design, keeping the prototype clean, efficient, and easy to walk through in an interview.
