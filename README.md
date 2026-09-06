# Inventory & Supply Chain Analytics Dashboard

## Project Status

**Completed Analytics Prototype**

## Overview

An end-to-end inventory and supply chain analytics prototype built using **Microsoft SQL Server, T-SQL, Power Query, DAX, and Power BI**.

The project analyzes inventory levels, product value, supplier information, warehouse distribution, orders, reorder requirements, and stockout risk through a relational database and an interactive Power BI dashboard.

## Business Problem

Organizations managing inventory across multiple warehouses need visibility into stock levels, inventory value, supplier information, and replenishment requirements.

This project focuses on identifying:

- Products requiring reorder
- Products at stockout risk
- High-value inventory
- Inventory distribution across warehouses
- Inventory value by product and category
- Supplier-related inventory information

## Objectives

1. Design a relational database in SQL Server for inventory, orders, products, suppliers, and warehouses.
2. Use T-SQL to create, populate, clean, join, and analyze data across multiple tables.
3. Use Power Query to transform and prepare data before loading it into Power BI.
4. Build a relational data model with appropriate table relationships.
5. Use DAX to calculate inventory value, perform ABC inventory classification, identify stockout risk, and calculate a basic reorder point for replenishment analysis.
6. Develop an interactive Power BI dashboard for inventory and supply chain analysis.

## Technology Stack

- **Microsoft SQL Server** – Relational database
- **SQL Server Management Studio (SSMS)** – Database management
- **T-SQL** – Database creation and analytical queries
- **Power Query (M)** – Data transformation and merging
- **Power BI** – Data modeling and dashboard visualization
- **DAX** – Measures and inventory calculations

## Database

The SQL Server database is named:

`InventorySupplyChainDB`

It contains five main tables:

### Suppliers

Stores supplier information including supplier name, lead time, and supplier rating.

### Products

Stores product details including product name, category, unit cost, and supplier reference.

### Warehouses

Stores warehouse names and locations.

### Inventory

Stores product stock levels for each warehouse, including current stock, reorder level, and safety stock.

### Orders

Stores order information including product, warehouse, order date, quantity, and order status.

Primary keys and foreign-key relationships are used to maintain relationships between the tables.

## Data Processing

Power Query is used as the ETL layer between the source data and Power BI.

The transformation process includes:

- Setting appropriate data types
- Preparing and cleaning source data
- Validating data
- Merging related datasets
- Preparing data for the Power BI data model

### Data Flow

```text
SQL Server
    ↓
Power Query
    ↓
Data Transformation & Merging
    ↓
Power BI Data Model
    ↓
DAX Calculations
    ↓
Power BI Dashboard
```

## Analytics

### Inventory Value

Inventory value is calculated using:

```text
Current Stock × Unit Cost
```

### Reorder Analysis

### Reorder Point Analysis

A basic reorder point is calculated using:

Average Daily Demand × Lead Time + Safety Stock

Inventory is flagged for reorder when:

Current Stock <= Calculated Reorder Point

### Stockout Risk

Inventory is considered at stockout risk when:

```text
Current Stock <= Safety Stock
```

### ABC Inventory Classification

### ABC Inventory Classification

Products are classified into **A, B, and C categories using cumulative inventory value**.

- A: Products contributing to approximately the first 70% of cumulative inventory value
- B: Products contributing to approximately the next 20%
- C: Remaining products

### Warehouse Analysis

Inventory value and stock levels are compared across different warehouses to identify differences in inventory distribution.

### Supplier Analysis

Supplier information such as supplier name, lead time, and rating can be analyzed alongside product and inventory information.

## Power BI Dashboard

The interactive dashboard includes:

- **Total Inventory Value**
- **Total Units**
- **Reorder Required**
- **Stockout Risk**
- **Inventory Value by Category**
- **Inventory Value by Warehouse**
- **Top Products by Inventory Value**
- **Stock Level vs Reorder Point**
- **ABC Inventory Classification**
- **Category filter**
- **Warehouse filter**
- **Supplier filter**

The dashboard is designed as a single-page executive analytics view.

## Project Structure

```text
Inventory-Supply-Chain-Analytics/
│
├── README.md
├── Inventory supply chain analytics.pbix
│
├── data/
│   ├── suppliers.csv
│   ├── products.csv
│   ├── warehouses.csv
│   ├── inventory.csv
│   └── orders.csv
│
├── database/
│   ├── database.sql
│   ├── sample_data.sql
│   └── analytical_queries.sql
│
├── powerbi/
│   ├── data_model.md
│   ├── dax_measures.md
│   └── power_query_steps.md
│
└── docs/
    └── data_dictionary.md
```

## Key SQL Analysis

The SQL analytical layer contains queries for:

- Inventory value analysis
- Inventory by warehouse
- Inventory by category
- Low-stock identification
- Reorder analysis
- Stockout-risk analysis
- Order quantity analysis
- Supplier analysis
- Product and inventory joins
- ABC inventory analysis

## Future Improvements

As a prototype, the project can be extended with:

- Supplier performance scorecards
- Order fulfillment analysis
- Demand forecasting
- More advanced stockout prediction
- Dynamic demand and lead-time analysis
- Automated Power BI Service refresh
- Additional dashboard pages

## Note

This project is a **completed analytics prototype** developed to demonstrate an end-to-end inventory and supply chain reporting workflow. It is intended for learning, portfolio, and demonstration purposes rather than production deployment.
