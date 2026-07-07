-- =====================================================================
-- Archivo 01: creación de base de datos y tablas (DDL) — diseño 3FN
-- FILE 01: creation of database and tables (DDL) — 3NF design
-- =====================================================================

-- ---------- Main TABLES----------
CREATE TABLE eco_cities (
    city_id    SERIAL       PRIMARY KEY,
    city_name  VARCHAR(80)  NOT NULL UNIQUE
);

CREATE TABLE eco_categories (
    category_id   SERIAL       PRIMARY KEY,
    category_name VARCHAR(60)  NOT NULL UNIQUE
);

CREATE TABLE eco_clients (
    client_id   SERIAL        PRIMARY KEY,
    client_name VARCHAR(120)  NOT NULL UNIQUE,
    city_id     INT           NOT NULL,
    CONSTRAINT fk_client_city
        FOREIGN KEY (city_id) REFERENCES eco_cities (city_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE eco_distribution_centers (
    center_id   SERIAL        PRIMARY KEY,
    center_name VARCHAR(80)   NOT NULL UNIQUE,
    city_id     INT           NOT NULL,
    CONSTRAINT fk_center_city
        FOREIGN KEY (city_id) REFERENCES eco_cities (city_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE eco_products (
    product_id   SERIAL         PRIMARY KEY,
    product_name VARCHAR(120)   NOT NULL UNIQUE,
    category_id  INT            NOT NULL,
    unit_price   NUMERIC(10,2)  NOT NULL,
    CONSTRAINT chk_product_price CHECK (unit_price > 0),
    CONSTRAINT fk_product_category
        FOREIGN KEY (category_id) REFERENCES eco_categories (category_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ---------- inventory ----------
CREATE TABLE eco_inventory (
    inventory_id SERIAL  PRIMARY KEY,
    product_id   INT     NOT NULL,
    center_id    INT     NOT NULL,
    stock        INT     NOT NULL,
    CONSTRAINT chk_inventory_stock CHECK (stock >= 0),
    CONSTRAINT uq_inventory_product_center UNIQUE (product_id, center_id),
    CONSTRAINT fk_inventory_product
        FOREIGN KEY (product_id) REFERENCES eco_products (product_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_center
        FOREIGN KEY (center_id) REFERENCES eco_distribution_centers (center_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ---------- orders ----------
CREATE TABLE eco_orders (
    order_id   VARCHAR(15)  PRIMARY KEY,
    client_id  INT          NOT NULL,
    order_date DATE         NOT NULL,
    CONSTRAINT fk_order_client
        FOREIGN KEY (client_id) REFERENCES eco_clients (client_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE eco_order_details (
    detail_id  SERIAL         PRIMARY KEY,
    order_id   VARCHAR(15)    NOT NULL,
    product_id INT            NOT NULL,
    quantity   INT            NOT NULL,
    unit_price NUMERIC(10,2)  NOT NULL,
    CONSTRAINT chk_detail_qty   CHECK (quantity > 0),
    CONSTRAINT chk_detail_price CHECK (unit_price > 0),
    CONSTRAINT uq_order_product UNIQUE (order_id, product_id),
    CONSTRAINT fk_detail_order
        FOREIGN KEY (order_id) REFERENCES eco_orders (order_id)
        ON UPDATE CASCADE ON DELETE CASCADE,            -- borrar el pedido borra sus líneas
    CONSTRAINT fk_detail_product
        FOREIGN KEY (product_id) REFERENCES eco_products (product_id)
        ON UPDATE CASCADE ON DELETE RESTRICT            -- no se puede borrar un producto con pedidos
);


