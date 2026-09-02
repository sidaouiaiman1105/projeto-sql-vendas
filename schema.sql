-- ============================================================
-- SCHEMA.SQL
-- Projeto: Consulta e Análise Comercial em SQL (Olist E-Commerce)
-- Banco: SQLite (via DBeaver)
-- ============================================================

-- 1. Tabela de Clientes
CREATE TABLE clientes (
    customer_id            TEXT PRIMARY KEY,
    customer_unique_id     TEXT,
    customer_zip_code      TEXT,
    customer_city          TEXT,
    customer_state         TEXT
);

-- 2. Tabela de Tradução de Categoria de Produto
--    (o dataset original traz as categorias em português;
--     essa tabela traduz para inglês, facilitando os relatórios)
CREATE TABLE categoria_traducao (
    product_category_name          TEXT PRIMARY KEY,
    product_category_name_english  TEXT
);

-- 3. Tabela de Produtos
CREATE TABLE produtos (
    product_id              TEXT PRIMARY KEY,
    product_category_name   TEXT,
    product_weight_g        REAL,
    product_length_cm       REAL,
    product_height_cm       REAL,
    product_width_cm        REAL,
    FOREIGN KEY (product_category_name) REFERENCES categoria_traducao(product_category_name)
);

-- 4. Tabela de Pedidos
CREATE TABLE pedidos (
    order_id                       TEXT PRIMARY KEY,
    customer_id                    TEXT,
    order_status                   TEXT,
    order_purchase_timestamp       TIMESTAMP,
    order_approved_at              TIMESTAMP,
    order_delivered_customer_date  TIMESTAMP,
    order_estimated_delivery_date  TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES clientes(customer_id)
);

-- 5. Tabela de Itens do Pedido
CREATE TABLE itens_pedidos (
    order_id            TEXT,
    order_item_id       INTEGER,
    product_id          TEXT,
    price                REAL,
    freight_value        REAL,
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id) REFERENCES pedidos(order_id),
    FOREIGN KEY (product_id) REFERENCES produtos(product_id)
);

-- 6. Tabela de Pagamentos
CREATE TABLE pagamentos (
    order_id               TEXT,
    payment_sequential     INTEGER,
    payment_type           TEXT,
    payment_installments   INTEGER,
    payment_value          REAL,
    PRIMARY KEY (order_id, payment_sequential),
    FOREIGN KEY (order_id) REFERENCES pedidos(order_id)
);
