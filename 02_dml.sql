--Insert
--Register a new client with an associated order
--Business Requirement
--Register a new client and create an order associated with that client.

-- New city (only if it does not exist)
INSERT INTO eco_cities (city_name)
VALUES ('Barranquilla');

-- New client
INSERT INTO eco_clients (client_name, city_id)
VALUES ('Green Market', 1);

-- New order
INSERT INTO eco_orders (order_id, client_id, order_date)
VALUES ('ORD001', 1, CURRENT_DATE);

-- Order details
INSERT INTO eco_order_details (order_id, product_id, quantity, unit_price)
VALUES
('ORD001', 1, 5, 20.00),
('ORD001', 2, 3, 15.50);


--Update
-- Modify the information of a distribution center
--Business Requirement
--Update the name and city assigned to a distribution center.

UPDATE eco_distribution_centers
SET center_name = 'North Distribution Center',
    city_id = 2
WHERE center_id = 1;


---

--Delete
-- Delete a product with no associated orders
--Business Requirement
--Delete a product only if it has no associated orders.

DELETE FROM eco_products
WHERE product_id = 5;

--Note:If the product exists in `eco_order_details`, PostgreSQL will prevent
--the deletion because of the foreign key constraint (`ON DELETE RESTRICT`).

