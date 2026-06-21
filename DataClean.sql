USE ecommerce_clean;

-- Crear la tabla de perfil de clientes -------------------------------------------------------------------------------------------------

CREATE TABLE dim_clientes (
    customer_id   VARCHAR(20)  PRIMARY KEY,
    age           INT,
    gender        VARCHAR(10),
    country       VARCHAR(50),
    signup_date   DATE,
    preferred_category VARCHAR(50)
);

INSERT INTO dim_clientes (customer_id, age, gender, country, signup_date, preferred_category)
SELECT 
    customer_id,
    age,
    TRIM(gender),
    TRIM(country),
    STR_TO_DATE(signup_date, '%m/%d/%Y'),
    TRIM(preferred_category)
FROM ecommerce_raw.data2;
  
SELECT 
	COUNT(*) AS total_clientes 
FROM dim_clientes; -- 5000 clientes insertados en la tabla

DESCRIBE dim_clientes;
/* dim_clientes creada y llenada correctamente
   - 5,000 registros insertados*/
   
   
-- Crear la tabla de de productos -------------------------------------------------------------------------------------------------
CREATE TABLE dim_productos (
    product_id     VARCHAR(20)   PRIMARY KEY,
    product_name   VARCHAR(100),
    category       VARCHAR(50)
);

INSERT INTO dim_productos (product_id, product_name, category)
SELECT DISTINCT 
    product_id,
    product_name,
    TRIM(category)
FROM ecommerce_raw.data2;

SELECT COUNT(*) AS total_productos FROM dim_productos;
   /* dim_productos creada y poblada correctamente
   - 2,000 registros insertados (catálogo de productos) */   
   
-- Crear la tabla de comportamiento transaccional -------------------------------------------------------------------------------------------------

CREATE TABLE fac_comportamiento (
    order_id              VARCHAR(20)    PRIMARY KEY,
    customer_id           VARCHAR(20),
    product_id            VARCHAR(20),
    order_date            DATE,
    last_purchase_date    DATE,
    unit_price            DECIMAL(10,2),
    quantity              INT,
    total_orden           DECIMAL(10,2),
    purchase_frequency    INT,
    cancellations_count   INT,
    subscription_status   VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES dim_clientes(customer_id),
    FOREIGN KEY (product_id)  REFERENCES dim_productos(product_id)
);

INSERT INTO fac_comportamiento (
    order_id,
    customer_id,
    product_id,
    order_date,
    last_purchase_date,
    unit_price,
    quantity,
    total_orden,
    purchase_frequency,
    cancellations_count,
    subscription_status
)
SELECT 
    order_id,
    customer_id,
    product_id,
    STR_TO_DATE(order_date, '%m/%d/%Y'),
    STR_TO_DATE(last_purchase_date, '%m/%d/%Y'),
    CAST(unit_price AS DECIMAL(10,2)),
    CAST(quantity AS UNSIGNED),
    CAST(unit_price AS DECIMAL(10,2)) * CAST(quantity AS UNSIGNED),
    CAST(purchase_frequency AS UNSIGNED),
    CAST(cancellations_count AS UNSIGNED),
    TRIM(subscription_status)
FROM ecommerce_raw.data2;

SELECT COUNT(*) AS total_comportamiento
FROM fac_comportamiento;
-- 5,000 registros insertados

SELECT 
    order_id,
    unit_price,
    quantity,
    total_orden,
    unit_price * quantity AS verificacion
FROM fac_comportamiento
LIMIT 10;

SELECT 
    MIN(purchase_frequency) AS frec_min,
    MAX(purchase_frequency) AS frec_max,
    ROUND(AVG(purchase_frequency), 2) AS frec_promedio
FROM fac_comportamiento;


/* fac_comportamiento creada y poblada correctamente
   - 5,000 registros insertados
   - total_orden calculada como unit_price * quantity
   - FOREIGN KEY vinculada a dim_clientes y dim_productos
   - unit_price representa el precio al momento de la transacción, 
     que puede variar por descuentos, promociones o cambios de precio. 
     Es un dato histórico de la venta, no del catálogo."*/
   
   
   -- Crear la tabla de clasificacion de riesgo por inactividad -------------------------------------------------------------------------------------------------
CREATE TABLE dim_segmento_riesgo (
    customer_id       VARCHAR(20)   PRIMARY KEY,
    dias_sin_compra   INT,
    nivel_riesgo      VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES dim_clientes(customer_id)
);

INSERT INTO dim_segmento_riesgo (customer_id, dias_sin_compra, nivel_riesgo)
SELECT
    customer_id,
    -- En la subconsulta me traigo la fecha mas reciente del dataset
    -- y calcula cuantos dias pasaron desde la ultima compra de cada cliente
    DATEDIFF( (SELECT MAX(last_purchase_date) FROM fac_comportamiento), -- Esto devuelve 2025-08-20 — la fecha más reciente del dataset. La usamos como el "hoy" para calcular cuánto tiempo lleva sin comprar cada cliente.
        last_purchase_date),
    CASE
        WHEN DATEDIFF((SELECT MAX(last_purchase_date) FROM fac_comportamiento), 
             last_purchase_date) <= 180 THEN 'Activo'
        WHEN DATEDIFF((SELECT MAX(last_purchase_date) FROM fac_comportamiento), 
             last_purchase_date) <= 365 THEN 'Alerta'
        WHEN DATEDIFF((SELECT MAX(last_purchase_date) FROM fac_comportamiento), 
             last_purchase_date) <= 730 THEN 'Riesgo Medio'
        ELSE 'Riesgo Alto'
    END
FROM fac_comportamiento;

SELECT 
	COUNT(*) AS total_segmentos
FROM dim_segmento_riesgo;
-- 5000 registros

SELECT 
    nivel_riesgo,
    COUNT(*) AS total_clientes
FROM dim_segmento_riesgo
GROUP BY nivel_riesgo
ORDER BY total_clientes DESC;

/* dim_segmento_riesgo creada y llena correctamente
   - 5,000 registros insertados
   - dias_sin_compra calculado con DATEDIFF contra la fecha maxima del dataset
   - Fecha de referencia: 2025-08-20 (fecha mas reciente en el dataset)
   - Limites operacionales: Activo ≤180d / Alerta ≤365d / Riesgo Medio ≤730d / Riesgo Alto >730d
   - Distribucion: Activo 1,864 / Alerta 979 / Riesgo Medio 1,193 / Riesgo Alto 964 */
   
   
   -- actualizar los nombres del nivel de riesgo por desorden en powerbi
SET SQL_SAFE_UPDATES = 0;

UPDATE dim_segmento_riesgo 
SET nivel_riesgo = CASE
    WHEN nivel_riesgo = 'Activo' THEN '1_Activo'
    WHEN nivel_riesgo = 'Alerta' THEN '2_Alerta'
    WHEN nivel_riesgo = 'Riesgo Medio' THEN '3_Riesgo Medio'
    WHEN nivel_riesgo = 'Riesgo Alto' THEN '4_Riesgo Alto'
END;

SET SQL_SAFE_UPDATES = 1;

SELECT DISTINCT nivel_riesgo FROM dim_segmento_riesgo ORDER BY nivel_riesgo;
