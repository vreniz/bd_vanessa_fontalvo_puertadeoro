
--SQL Queries

--Query 1
--Available Inventory by Product
--Business Need
--The Supply Manager needs to know the current stock available for each product in
--order to plan future purchases.

SELECT
    p.product_name,
    SUM(i.stock) AS available_inventory
FROM eco_products p
JOIN eco_inventory i
ON p.product_id = i.product_id
GROUP BY p.product_name
ORDER BY available_inventory DESC;


---

--Query 2
-- Order History by City
--Business Need
--The Commercial Director needs to identify which cities generate the highest number
--of orders.

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




--Query 3
-- The Financial Manager needs to identify which product categories generate the
-- highest revenue.

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



--Query 4
-- The Logistics Coordinator needs to identify products that are close to running out
of stock. 

SELECT
    p.product_name,
    SUM(i.stock) AS available_inventory
FROM eco_products p
JOIN eco_inventory i
ON p.product_id = i.product_id
GROUP BY p.product_name
ORDER BY available_inventory ASC
LIMIT 5;




--Query 5
-- The Commercial Director needs to identify the most active clients based on the
-- number of orders placed.
SELECT
    c.client_name,
    COUNT(o.order_id) AS total_orders
FROM eco_clients c
JOIN eco_orders o
ON c.client_id = o.client_id
GROUP BY c.client_name
ORDER BY total_orders DESC;

-- Query 6
-- The General Manager needs to know the total inventory value stored at each
-- distribution center.
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