CREATE DATABASE ecommerce_raw;
CREATE DATABASE ecommerce_clean;

USE ecommerce_raw;

SELECT * FROM ecommerce_raw.data2;

/**Exploracion inicial de los datos**/

-- Ver las primeras 20 filas para entender la estructura
SELECT * 
FROM data2 
LIMIT 20;

-- Contar el total de registros
SELECT 
	COUNT(*) AS total_registros
FROM data2; /*5000 registros*/

-- Ver los tipos de datos de todas las columns
DESCRIBE data2;

-- Identificar valores nulos y unicos

-- Contar valores nulos de las columnas importantes ** ver otra opcion para revisar nulos**
SELECT 
    COUNT(*) - COUNT(order_id) AS nulos_order_id,
    COUNT(*) - COUNT(customer_id) AS nulos_customer_id,
    COUNT(*) - COUNT(product_id) AS nulos_product_id,
    COUNT(*) - COUNT(order_date) AS nulos_order_date,
    COUNT(*) - COUNT(unit_price) AS nulos_unit_price,
    COUNT(*) - COUNT(quantity) AS nulos_quantity
FROM data2;

/**************************
Se realizó validación de valores nulos en variables clave. 
No se identificaron valores faltantes, por lo que no sera necesario aplicar cambios.
********************************/

-- Verificar duplicados en order_id (debe ser único para PK)
SELECT order_id, 
		COUNT(*) AS veces_repetido
FROM data2
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT 
	COUNT(DISTINCT order_id) AS ordenes_unicas
FROM data2;
-- 5000 ordenes unicas, tambien esta opcion para identificar si hay misma cantidad de ordenes unicas como filas

SELECT 
	COUNT(DISTINCT customer_id) AS clientes_unicos
FROM data2;
-- 5000 clientes unicos

-- Cuántos productos únicos tenemos
SELECT 
	COUNT(DISTINCT product_id) AS productos_unicos
FROM data2;
/* "El catálogo de productos contiene 2,000 
referencias únicas distribuidas entre 5,000 órdenes, 
lo que indica que los productos se repiten entre clientes,*/


-- Verificar valores únicos de subscription_status (detectar inconsistencias)
SELECT 
	DISTINCT subscription_status 
FROM data2; 

-- Revision de edades (mínimo, máximo, promedio) para identificar que no existan edades extranas
SELECT 
    MIN(age) AS edad_minima,
    MAX(age) AS edad_maxima,
    AVG(age) AS edad_promedio
FROM data2;
-- edad minima> 18 - edad maxima> 69 - edad promedio> 43.416
  
-- Conocer los de paises unicos e identificar si hay nombres "raros"
SELECT 
	DISTINCT country
FROM data2;

-- Verificar valores unicos de gender
SELECT 
	DISTINCT gender 
FROM data2; -- Male, Female, Other

-- Verificar valores unicos de preferred_category y category
SELECT 
	DISTINCT preferred_category 
FROM data2;

SELECT 
	DISTINCT category 
FROM data2;

-- Revision de los valores para identificar rangos de precios y cantidades

-- unit_price
SELECT 
    MIN(unit_price) AS precio_minimo,
    MAX(unit_price) AS precio_maximo,
    AVG(unit_price) AS precio_promedio
FROM data2;
-- precio_minimo> 10.01 - precio_maximo> 996.56 - precio_promedio> 223.52

-- quantity
SELECT 
    MIN(quantity) AS cantidad_minima,
    MAX(quantity) AS cantidad_maxima,
    AVG(quantity) AS cantidad_promedio
FROM data2;
-- cantidad_minima> 1 - cantidad_maxima> 9 - cantidad_promedio> 4.116

-- purchase_frequency
SELECT 
    MIN(purchase_frequency) AS frecuencia_minima,
    MAX(purchase_frequency) AS frecuencia_maxima
FROM data2;

-- Detectar precios o cantidades invalidas (negativos o cero)
SELECT 
	COUNT(*) AS registros_invalidos
FROM data2
WHERE unit_price <= 0 OR quantity <= 0;

-- Revision de cancellations_count 
SELECT 
    MIN(cancellations_count) AS min_cancelaciones,
    MAX(cancellations_count) AS max_cancelaciones
FROM data2;

-- SECCION DE FECHAS

SELECT 
	DISTINCT signup_date 
FROM data2
LIMIT 10;  -- Ver formato

SELECT 
    MIN(STR_TO_DATE(signup_date, '%m/%d/%Y')) AS primera_fecha_registro,
    MAX(STR_TO_DATE(signup_date, '%m/%d/%Y')) AS ultima_fecha_registro
FROM data2;
-- primera_fecha_registro> 2019-01-01 - ultima_fecha_registro> 2025-07-30

SELECT 
	DISTINCT order_date 
FROM data2
LIMIT 10; -- para ver el formato

SELECT 
    MIN(STR_TO_DATE(order_date, '%m/%d/%Y')) AS primera_orden,
    MAX(STR_TO_DATE(order_date, '%m/%d/%Y')) AS ultima_orden
FROM data2;
-- primera_orden> 2019-01-31 - ultima_orden> 2025-08-20

-- Rango de last_purchase_date (última compra de cada cliente)
SELECT 
    MIN(STR_TO_DATE(last_purchase_date, '%m/%d/%Y')) AS primera_ultima_compra,
    MAX(STR_TO_DATE(last_purchase_date, '%m/%d/%Y')) AS ultima_ultima_compra
FROM data2;

-- Validar que signup_date no sea posterior a order_date (error lógico)
SELECT 
	COUNT(*) AS fechas_inconsistentes
FROM data2
WHERE STR_TO_DATE(signup_date, '%m/%d/%Y') > STR_TO_DATE(order_date, '%m/%d/%Y');


/****************************************************************************
-- RESUMEN 

-- Total de registros: 5,000
-- Valores nulos en columnas críticas: 0
-- Duplicados en order_id: 0
-- Edades entre 18 y 69 años (promedio: 43.416)
-- Precios entre 10.01 y 996.56 (promedio: 223.52)
-- Cantidades entre 1 y 9 (promedio: 4.116)
-- Frecuencia de compra entre 1 y 55
-- Cancelaciones entre 0 y 5
-- Registros con precio o cantidad inválida: 0
-- Productos únicos: 2,000 
-- Estados de suscripción: active, cancelled, paused
-- Géneros: Female, Male, Other
-- Categorías de producto: Sports, Home, Clothing, Beauty, Electronics
-- Países: Canada, USA, Pakistan, India, Germany, UK
-- Fechas de registro: 2019-01-01 a 2025-07-30
-- Fechas de orden: 2019-01-31 a 2025-08-20
-- Fechas de última compra: 2020-09-20 a 2025-08-20
-- Fechas inconsistentes (registro posterior a orden): 0

Ahora> Crear base de datos CLEAN
