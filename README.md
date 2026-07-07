# EcoMarket Riwi S.A.S. — Relational Database (3NF)

## Project description
EcoMarket Riwi S.A.S. sells and distributes fresh food to supermarkets,
restaurants and specialty stores across several cities. The whole operation used
to live in a single shared Excel file edited by the Purchasing, Logistics,
Inventory and Commercial teams, which accumulated duplicated clients, products
written many ways, inconsistent categories, repeated distribution centers and
mis-spelled cities. This project analyzes that raw file, normalizes it up to
Third Normal Form (3NF), designs the Entity–Relationship model, and implements a
clean relational database in PostgreSQL with full referential integrity, plus the
SQL scripts the business needs.

## Technologies
- **Database engine:** PostgreSQL (also portable to MySQL).
- **Modeling:** draw.io (`.drawio`) for the ER model (MER).
- **Data preparation:** clean the raw `.xlsx` and
  split it into one sheet per table, exported as CSV for loading.

## Database engine
PostgreSQL. Database name convention `bd_nombre_apellido_clan`:
 `bd_vanessa_fontalvo_puertadeoro`
All tables and columns are in English and start with the prefix `eco_`.

---

## Normalization process

### Initial state
One flat table of 20 rows with columns: `ClientName, City, Product, Category,
DistributionCenter, OrderID, OrderDate, Quantity, UnitPrice, Stock`. Every row
mixed client, city, product, category, center, order and stock data.

### Problems found (redundancy & inconsistency)
| Problem | Evidence |
|---|---|
| **Duplicated clients** | `SuperMax` / `super max` / `SuperMax `; `FreshMart` / `Fresh Mart`. 9 real clients. |
| **Products written many ways** | `Apple Gala` / `Gala Apple`; `Whole Milk` / `Milk 1L`; `Olive Oil` / `Extra Virgin Olive Oil`. Each real product is a consecutive pair sharing the same `UnitPrice` → 10 real products. |
| **Inconsistent categories** | singular/plural: `Fruit`/`Fruits`, `Meat`/`Meats`, `Oil`/`Oils`. 6 real categories. |
| **Duplicated distribution centers** | word order swapped: `Center North` / `North Center`, `Coast DC` / `Coastal DC`, `East Hub` / `Hub East`. 6 real centers. |
| **Inconsistent cities** | `Bogotá`/`Bogota`, `Medellín`/`Medellin`, `Cúcuta`/`Cucuta`, `B/manga`, `Manizalez`, `Pereria`, `Barranquila`. 12 spellings → 9 real cities. |
| **Redundancy** | client, city, product, category and center text repeated on every row; `Stock` repeated per order instead of per product/center. |

### First Normal Form (1NF)
- **What violated it:** although cells were atomic, the same real value appeared
  in many inconsistent spellings, so no reliable key could be defined; a single
  table mixed several entities.
- **Changes:** values were standardized to one canonical spelling per client,
  city, product, category and center (word-order and singular/plural variants
  collapsed); each attribute holds a single atomic value; `OrderID` is the
  reliable key of an order.

### Second Normal Form (2NF)
- **Partial dependencies:** attributes depending only on part of the business
  key — client name/city depend on the client; product name/price/category on the
  product; center name/city on the center.
- **Removed by** moving each group to its own table (`eco_clients`,
  `eco_products`, `eco_distribution_centers`) with a surrogate key; fact tables
  keep only foreign keys.

### Third Normal Form (3NF)
- **Transitive dependencies:** `City` depended on the client and on the center
  (not on the order); `Category` depended on the product; `Stock` depended on the
  product-at-a-center pair, not on the order.
- **Removed by** extracting `eco_cities` and `eco_categories` as lookup tables,
  and moving `Stock` into an `eco_inventory` table keyed by (product, center).
- **Order header vs. detail:** each order is split into a header (`eco_orders`:
  client + date) and its lines (`eco_order_details`: product + quantity + price),
  the professional pattern that also supports multi-line orders.

### Final normalized model — 8 tables
`eco_cities`, `eco_categories`, `eco_clients`, `eco_distribution_centers`,
`eco_products`, `eco_orders`, `eco_order_details`, `eco_inventory`.

---

## Database schema
| Table | Purpose | Keys |
|---|---|---|
| `eco_cities` | Cities | PK `city_id`; UNIQUE `city_name` |
| `eco_categories` | Product categories | PK `category_id`; UNIQUE `category_name` |
| `eco_clients` | Clients | PK `client_id`; UNIQUE `client_name`; FK `city_id` |
| `eco_distribution_centers` | Logistics centers | PK `center_id`; UNIQUE `center_name`; FK `city_id` |
| `eco_products` | Products | PK `product_id`; UNIQUE `product_name`; FK `category_id`; CHECK `unit_price>0` |
| `eco_orders` | Order header | PK `order_id`; FK `client_id` |
| `eco_order_details` | Order lines | PK `detail_id`; FK `order_id`, `product_id`; UNIQUE `(order_id, product_id)`; CHECK `quantity>0` |
| `eco_inventory` | Stock per product & center | PK `inventory_id`; FK `product_id`, `center_id`; UNIQUE `(product_id, center_id)`; CHECK `stock>=0` |

**Relationships (one-to-many):** a city has many clients and many centers; a
category classifies many products; a client places many orders; an order contains
many detail lines; a product appears in many lines and in many inventory records;
a center holds many inventory records.

## Entity Relationship Diagram
`MER-BD.drwaio.pdf` — relational model with tables, PK/FK/UNIQUE/NOT NULL
markers and crow's-foot one-to-many connectors. 

---

## Database creation instructions

The full DDL (`01_create_tables.sql`) contains all 8 tables with PK, FK, UNIQUE,
NOT NULL and CHECK constraints.

## Data loading instructions
The raw file cannot load directly (it is redundant and inconsistent), so it was
cleaned in Dbeaver and split into the 8 normalized tables exported as CSV in `csv/`. Load
them **in dependency order**:
```sql
\copy eco_cities               FROM 'csv/eco_cities.csv'              
\copy eco_categories           FROM 'csv/eco_categories.csv'           
\copy eco_clients              FROM 'csv/eco_clients.csv'             
\copy eco_distribution_centers FROM 'csv/eco_distribution_centers.csv' 
\copy eco_products             FROM 'csv/eco_products.csv'             
\copy eco_orders               FROM 'csv/eco_orders.csv'               
\copy eco_order_details        FROM 'csv/eco_order_details.csv'        
\copy eco_inventory            FROM 'csv/eco_inventory.csv'           
```
Can also import all data using the `03_Insert_into_tables`

---

# 5. Data Manipulation

## Insert
### Register a new client with an associated order
**Business Requirement**
Register a new client and create an order associated with that client.
```sql
-- New city (only if it does not exist)
INSERT INTO eco_cities (city_name)
VALUES ('Madrid');

-- New client
INSERT INTO eco_clients (client_name, city_id)
VALUES ('Green Market', 1);

-- New order
INSERT INTO eco_orders (order_id, client_id, order_date)
VALUES ('O1021', 1, CURRENT_DATE);

-- Order details
INSERT INTO eco_order_details (order_id, product_id, quantity, unit_price)
VALUES
('ORD001', 1, 5, 20.00),
('ORD001', 2, 3, 15.50);
```

---

## Update
### Modify the information of a distribution center
**Business Requirement**
Update the name and city assigned to a distribution center.
```sql
UPDATE eco_distribution_centers
SET center_name = 'North Distribution Center',
    city_id = 2
WHERE center_id = 1;
```

---

## Delete
### Delete a product with no associated orders
**Business Requirement**
Delete a product only if it has no associated orders.
```sql
DELETE FROM eco_products
WHERE product_id = 5;
```
> **Note:** If the product exists in `eco_order_details`, PostgreSQL will prevent
> the deletion because of the foreign key constraint (`ON DELETE RESTRICT`).

---

# SQL Queries

## Query 1
### Available Inventory by Product
**Business Need**
The Supply Manager needs to know the current stock available for each product in
order to plan future purchases.
```sql
SELECT
    p.product_name,
    SUM(i.stock) AS available_inventory
FROM eco_products p
JOIN eco_inventory i
ON p.product_id = i.product_id
GROUP BY p.product_name
ORDER BY available_inventory DESC;
```

---

## Query 2
### Order History by City
**Business Need**
The Commercial Director needs to identify which cities generate the highest number
of orders.
```sql
SELECT
    c.city_name,
    COUNT(o.order_id) AS total_orders
FROM eco_orders o
JOIN eco_clients cl
ON o.client_id = cl.client_id
JOIN eco_cities c
ON cl.city_id = c.city_id
GROUP BY c.city_name
ORDER BY total_orders DESC;
```

---

## Query 3
### Total Sales by Category
**Business Need**
The Financial Manager needs to identify which product categories generate the
highest revenue.
```sql
SELECT
    cat.category_name,
    SUM(od.quantity * od.unit_price) AS total_sales
FROM eco_order_details od
JOIN eco_products p
ON od.product_id = p.product_id
JOIN eco_categories cat
ON p.category_id = cat.category_id
GROUP BY cat.category_name
ORDER BY total_sales DESC;
```

---

## Query 4
### Products with the Lowest Inventory
**Business Need**
The Logistics Coordinator needs to identify products that are close to running out
of stock.
```sql
SELECT
    p.product_name,
    SUM(i.stock) AS available_inventory
FROM eco_products p
JOIN eco_inventory i
ON p.product_id = i.product_id
GROUP BY p.product_name
ORDER BY available_inventory ASC
LIMIT 5;
```

---

## Query 5
### Clients with the Highest Number of Orders
**Business Need**
The Commercial Director needs to identify the most active clients based on the
number of orders placed.
```sql
SELECT
    c.client_name,
    COUNT(o.order_id) AS total_orders
FROM eco_clients c
JOIN eco_orders o
ON c.client_id = o.client_id
GROUP BY c.client_name
ORDER BY total_orders DESC;
```

---

## Query 6
### Inventory Value by Distribution Center
**Business Need**
The General Manager needs to know the total inventory value stored at each
distribution center.
```sql
SELECT
    dc.center_name,
    SUM(i.stock * p.unit_price) AS inventory_value
FROM eco_distribution_centers dc
JOIN eco_inventory i
ON dc.center_id = i.center_id
JOIN eco_products p
ON i.product_id = p.product_id
GROUP BY dc.center_name
ORDER BY inventory_value DESC;
```

---

## SQL query explanation
1. **Available inventory per product** — sums stock across all centers per product.
2. **Order history per city** — counts orders grouped by the client's city.
3. **Total sales per category** — `quantity × unit_price` of order lines, grouped
   by category (revenue).
4. **Products with the lowest inventory** — total stock ascending, top 5.
5. **Clients with the most orders** — order count per client, most active first.
6. **Inventory value per distribution center** — `stock × product price` rolled up
   per center.

### Notes
- Queries group by name because `product_name`, `city_name`, `client_name` and
  `center_name` are `UNIQUE` in this schema. Grouping also by the `id`
  (`GROUP BY p.product_id, p.product_name`) is a more robust habit for tables
  without that constraint.
- Query 3 uses the `unit_price` stored in `eco_order_details` (the price at the
  time of sale), the correct choice for a financial report.
- In the INSERT, the ids (`city_id = 1`, `product_id = 1/2`) assume those rows
  exist. If Barranquilla is already loaded, its `UNIQUE(city_name)` will reject a
  re-insert; resolve ids with a subquery
  (`(SELECT city_id FROM eco_cities WHERE city_name = 'Barranquilla')`) if unsure.
- In the DELETE, `ON DELETE RESTRICT` blocks removing a product that has orders. If
  the given id does not exist, the DELETE simply affects 0 rows (no error).

## Developer information
- **Full name:** Vanessa Fontalvo
- **Clan:** Puerta de Oro


---

## 🚀 How to Run the Project

### 1. Start the PostgreSQL Container
Navigate to the project root folder (`bd_vanessa_fontalvo_puertadeoro`) and run the following command in your terminal:
```bash
docker compose up -d
```

Verify that the container is up and running successfully:
```bash
docker ps
```
You should see the container `bd_vanessa_fontalvo_puertadeoro` with the status **Up**.

### 2. Connection Details
The Docker container exposes PostgreSQL on **port 5433** of your local machine (mapped to the internal port 5432). Use these credentials to connect:

| Parameter | Value |
| :--- | :--- |
| **Host** | `localhost` |
| **Port** | `5433` |
| **Database** | `bd_vanessa_fontalvo_puertadeoro` |
| **Username** | `postgres` |
| **Password** | `postgres123` |

### 3. Connect via DBeaver
1. Open DBeaver and click on **New Connection** (the plug icon in the top-left corner).
2. Select **PostgreSQL** from the list and click **Next**.
3. Fill in the connection fields using the credentials from the table above (ensure you use port **5433**).
4. Click **Test Connection** to verify. If prompted to download the driver, accept it.
5. Click **Finish**.

---

## 📜 How to Test the Scripts

There are two ways to execute the `.sql` files.

### Option 1: Via DBeaver (Recommended)
1. Connect to the database following the steps above.
2. Open your `.sql` file via **File** ➡️ **Open File**, then copy and paste the script into the DBeaver SQL editor.
3. Ensure the script points to the correct database (verify the active connection and database name shown above the editor).
4. **Execution shortcuts:**
   * Execute the **entire script**: Press `Alt + X`
   * Execute a **single statement**: Press `Ctrl + Enter` (on the current cursor line)

### Option 2: Via Terminal (Alternative)
If you prefer the command line, you can execute the scripts directly inside the container:
```bash
docker exec -i bd_vanessa_fontalvo_puertadeoro-postgres psql -U postgres -d gestion_academica_universidad < path/to/your/script.sql
```


Github link: 
