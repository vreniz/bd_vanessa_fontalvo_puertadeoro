INSERT INTO public.eco_categories (category_name) VALUES
	 ('Dairy'),
	 ('Fruits'),
	 ('Grains'),
	 ('Meat'),
	 ('Oils'),
	 ('Vegetables');


INSERT INTO public.eco_cities (city_name) VALUES
	 ('Barranquilla'),
	 ('Bogotá'),
	 ('Bucaramanga'),
	 ('Cali'),
	 ('Cartagena'),
	 ('Cúcuta'),
	 ('Manizales'),
	 ('Medellín'),
	 ('Pereira');

INSERT INTO public.eco_clients (client_name,city_id) VALUES
	 ('EcoStore',5),
	 ('FoodPlus',7),
	 ('FreshMart',8),
	 ('GreenBuy',2),
	 ('MarketOne',3),
	 ('MiniShop',4),
	 ('QuickFood',6),
	 ('RetailCo',9),
	 ('SuperMax',1);


INSERT INTO public.eco_distribution_centers (center_name,city_id) VALUES
	 ('Center North',2),
	 ('Center West',8),
	 ('Coast DC',1),
	 ('Coffee DC',7),
	 ('East Hub',3),
	 ('South Hub',4);

INSERT INTO public.eco_inventory (product_id,center_id,stock) VALUES
	 (6,1,95),
	 (2,2,165),
	 (7,6,52),
	 (9,3,60),
	 (4,3,182),
	 (10,5,36),
	 (8,4,81),
	 (3,4,104),
	 (1,1,43),
	 (5,5,127);

INSERT INTO public.eco_order_details (order_id,product_id,quantity,unit_price) VALUES
	 ('O1001',6,10,25.00),
	 ('O1002',6,5,25.00),
	 ('O1003',2,20,12.00),
	 ('O1004',2,15,12.00),
	 ('O1005',7,12,38.00),
	 ('O1006',7,8,38.00),
	 ('O1007',9,25,65.00),
	 ('O1008',9,10,65.00),
	 ('O1009',4,30,2.00),
	 ('O1010',4,18,2.00);
	 ('O1011',10,6,89.00),
	 ('O1012',10,4,89.00),
	 ('O1013',8,14,42.00),
	 ('O1014',8,9,42.00),
	 ('O1015',3,22,18.00),
	 ('O1016',3,16,18.00),
	 ('O1017',1,11,11.00),
	 ('O1018',1,7,11.00),
	 ('O1019',5,19,23.00),
	 ('O1020',5,13,23.00);

INSERT INTO public.eco_orders (order_id,client_id,order_date) VALUES
	 ('O1001',9,'2026-05-01'),
	 ('O1002',9,'2026-05-02'),
	 ('O1003',3,'2026-05-02'),
	 ('O1004',3,'2026-05-03'),
	 ('O1005',6,'2026-05-04'),
	 ('O1006',6,'2026-05-05'),
	 ('O1007',9,'2026-05-06'),
	 ('O1008',9,'2026-05-07'),
	 ('O1009',1,'2026-05-08'),
	 ('O1010',1,'2026-05-09');
	 ('O1011',5,'2026-05-10'),
	 ('O1012',5,'2026-05-11'),
	 ('O1013',8,'2026-05-12'),
	 ('O1014',8,'2026-05-13'),
	 ('O1015',2,'2026-05-14'),
	 ('O1016',2,'2026-05-15'),
	 ('O1017',4,'2026-05-16'),
	 ('O1018',4,'2026-05-17'),
	 ('O1019',7,'2026-05-18'),
	 ('O1020',7,'2026-05-19');
     
INSERT INTO public.eco_products (product_name,category_id,unit_price) VALUES
	 ('Iceberg Lettuce',6,11.00),
	 ('Banana',2,12.00),
	 ('Tomato',6,18.00),
	 ('Rice 1kg',3,2.00),
	 ('Pasta',3,23.00),
	 ('Gala Apple',2,25.00),
	 ('Whole Milk 1L',1,38.00),
	 ('Eggs x12',1,42.00),
	 ('Chicken Breast',4,65.00),
	 ('Extra Virgin Olive Oil',5,89.00);
