-- ============================================================
-- QUERIES_ANALISE.SQL
-- Projeto: Consulta e Análise Comercial em SQL (Olist E-Commerce)
-- Banco: SQLite (via DBeaver)
-- ============================================================


-- ------------------------------------------------------------
-- PERGUNTA 1: Quais são os 10 clientes que mais gastaram
-- no total de compras?
-- Técnica: INNER JOIN, SUM, GROUP BY, ORDER BY, LIMIT
-- ------------------------------------------------------------
SELECT
    c.customer_id,
    c.customer_state,
    ROUND(SUM(i.price + i.freight_value), 2) AS total_gasto
FROM clientes c
INNER JOIN pedidos p       ON c.customer_id = p.customer_id
INNER JOIN itens_pedidos i ON p.order_id = i.order_id
WHERE p.order_status = 'delivered'
GROUP BY c.customer_id, c.customer_state
ORDER BY total_gasto DESC
LIMIT 10;


-- ------------------------------------------------------------
-- PERGUNTA 2: Qual o faturamento total e a quantidade de itens
-- vendidos por categoria de produto?
-- Técnica: JOIN entre 3 tabelas, SUM, COUNT, GROUP BY
-- ------------------------------------------------------------
SELECT
    COALESCE(t.product_category_name_english, 'sem_categoria') AS categoria,
    COUNT(i.order_item_id)              AS quantidade_itens_vendidos,
    ROUND(SUM(i.price), 2)              AS faturamento_total
FROM itens_pedidos i
INNER JOIN produtos pr           ON i.product_id = pr.product_id
LEFT JOIN categoria_traducao t   ON pr.product_category_name = t.product_category_name
GROUP BY categoria
ORDER BY faturamento_total DESC;


-- ------------------------------------------------------------
-- PERGUNTA 3: Qual o ticket médio das vendas separadas por mês?
-- Técnica: Funções de data (strftime), agregação, GROUP BY
-- ------------------------------------------------------------
SELECT
    strftime('%Y-%m', p.order_purchase_timestamp) AS mes,
    COUNT(DISTINCT p.order_id)                     AS total_pedidos,
    ROUND(SUM(i.price), 2)                         AS faturamento_total,
    ROUND(SUM(i.price) / COUNT(DISTINCT p.order_id), 2) AS ticket_medio
FROM pedidos p
INNER JOIN itens_pedidos i ON p.order_id = i.order_id
WHERE p.order_status = 'delivered'
GROUP BY mes
ORDER BY mes ASC;


-- ------------------------------------------------------------
-- PERGUNTA 4: Quais produtos nunca foram vendidos ou possuem
-- baixo volume de vendas (menos de 5 unidades)?
-- Técnica: LEFT JOIN, COUNT, GROUP BY, HAVING
-- ------------------------------------------------------------
SELECT
    pr.product_id,
    COALESCE(t.product_category_name_english, 'sem_categoria') AS categoria,
    COUNT(i.order_item_id) AS unidades_vendidas
FROM produtos pr
LEFT JOIN itens_pedidos i        ON pr.product_id = i.product_id
LEFT JOIN categoria_traducao t   ON pr.product_category_name = t.product_category_name
GROUP BY pr.product_id, categoria
HAVING COUNT(i.order_item_id) < 5
ORDER BY unidades_vendidas ASC;


-- ------------------------------------------------------------
-- PERGUNTA 5: Qual o meio de pagamento preferido por estado (UF)?
-- Técnica: CTE, COUNT, GROUP BY, window function (ROW_NUMBER)
-- ------------------------------------------------------------
WITH pagamentos_por_estado AS (
    SELECT
        c.customer_state,
        pg.payment_type,
        COUNT(*) AS qtd_pagamentos,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_state
            ORDER BY COUNT(*) DESC
        ) AS ranking
    FROM pagamentos pg
    INNER JOIN pedidos p  ON pg.order_id = p.order_id
    INNER JOIN clientes c ON p.customer_id = c.customer_id
    GROUP BY c.customer_state, pg.payment_type
)
SELECT
    customer_state       AS estado,
    payment_type          AS meio_pagamento_preferido,
    qtd_pagamentos
FROM pagamentos_por_estado
WHERE ranking = 1
ORDER BY estado ASC;
