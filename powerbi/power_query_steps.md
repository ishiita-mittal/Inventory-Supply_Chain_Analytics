# Power Query Transformation Steps

This guide outlines the simple Power Query (ETL) process used to clean and prepare the inventory data before loading it into the Power BI model.

---

## The ETL Workflow

```text
SQL Server (or CSVs)
        ↓
   Power Query
        ↓
 Clean / Transform
        ↓
Merge / Relate Data
        ↓
  Power BI Model
```

---

## 1. Connecting to the Data Source

### Option A: From SQL Server
1. In Power BI Desktop, click **Get Data** → **SQL Server**.
2. Enter Server name (e.g. `localhost` or `.`) and Database name: `InventorySupplyChainDB`.
3. Select **Import** mode and click **OK**.
4. Check all 5 tables: `Suppliers`, `Products`, `Warehouses`, `Inventory`, and `Orders`.
5. Click **Transform Data** to open the Power Query Editor.

### Option B: From CSV Files (Alternative)
1. Click **Get Data** → **Text/CSV**.
2. Select the CSV files from the project `data/` folder:
   * `suppliers.csv`
   * `products.csv`
   * `warehouses.csv`
   * `inventory.csv`
   * `orders.csv`
3. Click **Transform Data**.

---

## 2. Basic Transformations Applied

### Step 1: Set Correct Data Types
Ensure each column has an explicit, correct data type:

* **Suppliers**:
  * `SupplierID` → Whole Number (`Int64.Type`)
  * `SupplierName` → Text
  * `LeadTimeDays` → Whole Number
  * `SupplierRating` → Decimal Number (`type number`)
* **Products**:
  * `ProductID` → Whole Number
  * `ProductName` → Text
  * `Category` → Text
  * `UnitCost` → Fixed Decimal / Currency (`Currency.Type`)
  * `SupplierID` → Whole Number
* **Warehouses**:
  * `WarehouseID` → Whole Number
  * `WarehouseName` → Text
  * `Location` → Text
* **Inventory**:
  * `InventoryID`, `ProductID`, `WarehouseID` → Whole Number
  * `CurrentStock`, `ReorderLevel`, `SafetyStock` → Whole Number
* **Orders**:
  * `OrderID`, `ProductID`, `WarehouseID` → Whole Number
  * `OrderDate` → Date (`type date`)
  * `Quantity` → Whole Number
  * `OrderStatus` → Text

### Step 2: Clean Text & Remove Whitespace
* Select text columns (`SupplierName`, `ProductName`, `Category`, `WarehouseName`, `Location`, `OrderStatus`).
* Go to **Transform** tab → **Format** → **Trim** to remove any accidental leading or trailing spaces.

### Step 3: Check for Nulls
* Verify that primary key, foreign key, stock, and cost columns do not contain nulls.
* In Power Query, select **View** tab → check **Column Quality** to confirm 100% valid data.

### Step 4: Optional Table Merge (Supplier into Products)
To see vendor info directly inside the Product table:
1. Select the `Products` query.
2. Click **Merge Queries** (Home tab).
3. Select `Suppliers` as the second table.
4. Join on `SupplierID = SupplierID` (Left Outer Join).
5. Expand `SupplierName` and `LeadTimeDays`.
*(Note: Alternatively, you can keep `Suppliers` separate and link it in the Power BI relationship view as done in our star schema).*

---

## 3. Load into Data Model

1. Click **Close & Apply** on the top-left Home ribbon.
2. Power Query loads the cleaned tables into Power BI's in-memory engine.
3. You can now build the star schema relationships in **Model View** and write the DAX measures.
