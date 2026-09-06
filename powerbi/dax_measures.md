# DAX Measures & Calculations

This guide contains the beginner-friendly DAX measures and calculated columns used in the **Inventory & Supply Chain Analytics** prototype. All formulas reference the actual tables and columns in the project.

---

## 1. Total Inventory Value (Measure)

* **Business Idea**: Calculates the total dollar value of all products currently on hand in the warehouses.
* **Formula Concept**: Current Stock × Unit Cost

```dax
Total Inventory Value = 
SUMX (
    Inventory,
    Inventory[CurrentStock] * RELATED ( Products[UnitCost] )
)
```

* **How It Works**:
  * `SUMX` iterates row-by-row through the `Inventory` table.
  * It multiplies the `CurrentStock` in each row by the `UnitCost` looked up from the related `Products` table using `RELATED()`.
  * It sums the total across all rows in the current filter context ($172,060.00 across the sample data).

---

## 2. Total Units in Stock (Measure)

* **Business Idea**: Counts the total physical units stored across all warehouses.

```dax
Total Units = 
SUM ( Inventory[CurrentStock] )
```

* **How It Works**:
  * Adds up the numbers in the `CurrentStock` column of the `Inventory` table (1,070 total units in the sample data).

---

## 3. Products Requiring Reorder (Measure)

* **Business Idea**: Counts how many inventory allocations have reached or fallen below their reorder threshold.

```dax
Products Requiring Reorder = 
CALCULATE (
    COUNTROWS ( Inventory ),
    Inventory[CurrentStock] <= Inventory[ReorderLevel]
)
```

* **How It Works**:
  * Filters the `Inventory` table to rows where `CurrentStock <= ReorderLevel`, then counts those rows (13 items in the sample data).

---

## 4. Reorder Status (Calculated Column in `Inventory`)

* **Business Idea**: A row-level label that clearly flags whether an item needs replenishment.

```dax
Reorder Status = 
IF (
    Inventory[CurrentStock] <= Inventory[ReorderLevel],
    "Reorder Required",
    "Stock Healthy"
)
```

* **Rule**:
  * If `CurrentStock <= ReorderLevel` → `"Reorder Required"`
  * Otherwise → `"Stock Healthy"`
* **Usage**: Used in slicers, chart legends, and table visuals.

---

## 5. Stockout Risk (Measure)

* **Business Idea**: Flags items in immediate danger of completely running out of stock.
* **Transparent Rule**: If `CurrentStock <= SafetyStock`, the buffer stock is breached and the item is at high stockout risk.

```dax
Stockout Risk Products = 
CALCULATE (
    COUNTROWS ( Inventory ),
    Inventory[CurrentStock] <= Inventory[SafetyStock]
)
```

* **How It Works**:
  * Filters the `Inventory` table to rows where `CurrentStock <= SafetyStock` and counts them (6 critical items in the sample data).
  * This is a simple, rules-based threshold check (not a complex predictive model).

---

## 6. Total Order Quantity (Measure)

* **Business Idea**: Calculates total customer demand across all orders in 2026.

```dax
Total Order Quantity = 
SUM ( Orders[Quantity] )
```

* **How It Works**:
  * Sums the `Quantity` column in the `Orders` table (217 units in the sample data).

---

## 7. ABC Classification (Calculated Column in `Products`)

* **Business Idea**:
  * **Class A**: Highest-value items that make up the bulk (~70%) of total inventory value.
  * **Class B**: Medium-value items (~next 20% of inventory value).
  * **Class C**: Lower-value bulk items (~remaining 10% of inventory value).

### Step 1: Add `Product Inventory Value` (Calculated Column in `Products`)
Calculates the total dollar value for each individual product across all warehouses:

```dax
Product Inventory Value = 
SUMX (
    RELATEDTABLE ( Inventory ),
    Inventory[CurrentStock] * Products[UnitCost]
)
```

### Step 2: Add `ABC Classification` (Calculated Column in `Products`)
Ranks each product by its total inventory value and segments it:

```dax
ABC Classification = 
VAR TotalValue = SUMX ( ALL ( Products ), Products[Product Inventory Value] )
VAR CurrentVal = Products[Product Inventory Value]
VAR CumulativeVal = 
    SUMX (
        FILTER ( Products, Products[Product Inventory Value] >= CurrentVal ),
        Products[Product Inventory Value]
    )
VAR RunningPct = DIVIDE ( CumulativeVal, TotalValue, 0 )
RETURN
SWITCH (
    TRUE (),
    RunningPct <= 0.70, "A",
    RunningPct <= 0.90, "B",
    "C"
)
```

* **Sample Data Breakdown**:
  * **Class A (6 products)**: Top items like NVMe SSDs, PoE Switches, and Server Blades.
  * **Class B (5 products)**: Medium items like Transceivers, Chairs, and Surge Protectors.
  * **Class C (4 products)**: Lower-cost items like Keyboards, Webcams, and Patch Cords.

---

## Summary of Measures for Quick Copy-Paste

| Measure Name | Home Table | Formula |
| :--- | :--- | :--- |
| `Total Inventory Value` | `Inventory` | `SUMX ( Inventory, Inventory[CurrentStock] * RELATED ( Products[UnitCost] ) )` |
| `Total Units` | `Inventory` | `SUM ( Inventory[CurrentStock] )` |
| `Products Requiring Reorder` | `Inventory` | `CALCULATE ( COUNTROWS ( Inventory ), Inventory[CurrentStock] <= Inventory[ReorderLevel] )` |
| `Stockout Risk Products` | `Inventory` | `CALCULATE ( COUNTROWS ( Inventory ), Inventory[CurrentStock] <= Inventory[SafetyStock] )` |
| `Total Order Quantity` | `Orders` | `SUM ( Orders[Quantity] )` |
