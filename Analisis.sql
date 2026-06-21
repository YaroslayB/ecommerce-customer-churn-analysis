-- ANALISIS A: Facturacion total por pais
SELECT 
    dc.country,
    COUNT(fc.customer_id)               AS total_clientes,
    SUM(fc.total_orden)                 AS facturacion_total,
    ROUND(AVG(fc.total_orden), 2)       AS gasto_promedio_por_orden
FROM fac_comportamiento fc
JOIN dim_clientes dc ON fc.customer_id = dc.customer_id
GROUP BY dc.country
ORDER BY facturacion_total DESC;

-- ANALISIS B: Facturacion total por categoria de producto
SELECT 
    dc.preferred_category,
    COUNT(fc.customer_id)          AS total_clientes,
    SUM(fc.total_orden)            AS facturacion_total,
    ROUND(AVG(fc.total_orden), 2)  AS gasto_promedio_por_orden
FROM fac_comportamiento fc
JOIN dim_clientes dc ON fc.customer_id = dc.customer_id
GROUP BY dc.preferred_category
ORDER BY facturacion_total DESC;

-- ANALISIS C: Facturacion total por genero
SELECT 
    dc.gender,
    COUNT(fc.customer_id)           AS total_clientes,
    SUM(fc.total_orden)             AS facturacion_total,
    ROUND(AVG(fc.total_orden), 2)   AS gasto_promedio_por_orden
FROM fac_comportamiento fc
JOIN dim_clientes dc ON fc.customer_id = dc.customer_id
GROUP BY dc.gender
ORDER BY facturacion_total DESC;

-- ANALISIS D: Facturacion por categoria del producto comprado
SELECT 
    dp.category,
    COUNT(fc.customer_id)          AS total_clientes,
    SUM(fc.total_orden)            AS facturacion_total,
    ROUND(AVG(fc.total_orden), 2)  AS gasto_promedio_por_orden
FROM fac_comportamiento fc
JOIN dim_productos dp ON fc.product_id = dp.product_id
GROUP BY dp.category
ORDER BY facturacion_total DESC;

/* ANALISIS EXPLORATORIO COMPLEMENTARIO: Facturacion por pais, categoria y genero
   Los resultados mostraron una distribucion uniforme entre todos los grupos,
   
   - Por pais: UK $733,092 (promedio $850). Diferencia minima
     entre los 6 paises, entre $820 y $854 de gasto promedio.
   
   - Por categoria preferida: Clothing con $879,333. Diferencia de
     apenas $59 en gasto promedio entre las 5 categorias.
   
   - Por categoria comprada: Clothing con $876,266. Los resultados
     son casi identicos a la categoria preferida, 
   
   - Por genero: Femenino genera mayor facturacion total ($2,106,060) por
     volumen, masculino tiene mayor gasto promedio ($857 vs $835).
   
    Las variables demograficas no son predictores relevantes de valor. */

/***************************************************INICIO*********************************************/
-- ANALISIS 1: Segmentacion de clientes por valor
/* Los umbrales fueron definidos con criterio operacional basado en el 
   rango de precios del catálogo de productos.  
   
   Criterio de segmentacion:
   - Valor bajo:  total_orden < $800  
   - Valor medio: total_orden $800-$1,200
   - Alto valor:  total_orden >= $1,200 
   
   Este criterio permite identificar que segmento de clientes debe priorizarse
   en estrategias de retencion y fidelizacion. */
SELECT 
    CASE 
        WHEN total_orden >= 1200 THEN 'Alto valor'
        WHEN total_orden >= 800  THEN 'Valor medio'
        ELSE 'Valor bajo'
    END AS segmento_valor,
    COUNT(customer_id) AS total_clientes,
    ROUND(AVG(total_orden), 2) AS gasto_promedio,
    ROUND(SUM(total_orden), 2) AS facturacion_total,
    ROUND(COUNT(customer_id) * 100.0 /
        (SELECT COUNT(*) FROM fac_comportamiento), 2) AS porcentaje_clientes,
    ROUND(SUM(total_orden) * 100.0 /
        (SELECT SUM(total_orden) FROM fac_comportamiento), 2) AS porcentaje_facturacion
FROM fac_comportamiento
GROUP BY segmento_valor
ORDER BY facturacion_total DESC;


/* HALLAZGO 1: La segmentación por valor de transacción revela una concentración
   de facturación en el segmento Alto valor:
   1,367 clientes (27.34% de la base) generan $2,628,538, equivalente al
   62.28% de la facturación total.

   el segmento Valor bajo concentra 2,913 clientes (58.26%) pero
   aporta apenas $871,870, el 20.66% de la facturación. Esto significa que
   un cliente de Alto valor genera en promedio $1,922 por transacción, mientras
   que uno de Valor bajo genera $299, 

   El segmento Valor medio es el más pequeño en volumen (720 clientes, 14.40%), 
   la mayoría gasta mucho o gasta poco, con poco punto intermedio. */

/************************************************************************************************/

-- ANALISIS 2: Perfil promedio del cliente segun estado de suscripcion
SELECT 
    fc.subscription_status,
    COUNT(fc.customer_id) AS total_clientes,
    ROUND(AVG(dc.age), 1) AS edad_promedio,
    ROUND(AVG(fc.purchase_frequency), 1) AS frecuencia_prom_compra,
    ROUND(AVG(fc.cancellations_count), 1) AS cancelaciones_promedio,
    ROUND(AVG(fc.total_orden), 2) AS gasto_promedio_por_orden,
    ROUND(COUNT(fc.customer_id) * 100.0 / 
    (SELECT COUNT(*) FROM fac_comportamiento), 1) AS porcentaje_del_total
FROM fac_comportamiento fc
JOIN dim_clientes dc ON fc.customer_id = dc.customer_id
GROUP BY fc.subscription_status
ORDER BY total_clientes DESC;

/* HALLAZGO 2: El 55.1% de los clientes está activo, 29.9% canceló y 15.1%
   está en pausa
   diferencias notorias entre los tres grupos:

   - Frecuencia de compra: activos compran 27.8 veces/año vs cancelados 14.3,
     casi la mitad. Los pausados están en un punto intermedio con 21.0.
   - Cancelaciones promedio: activos tienen 1.5 cancelaciones vs cancelados 3.2,
     más del doble. Pausados en 2.1.
   - Gasto promedio: activos gastan $1,121 vs cancelados $430, una diferencia
     de 2.6 veces. Pausados en $650.

   Conclusión: el perfil del cliente que abandona compra menos
   frecuentemente, tiene más historial de cancelaciones y gasta menos por
   orden. Estos tres indicadores podrian ser son señales tempranas de abandono. */
   
   
/************************************************************************************************/
   
-- ANALISIS 3: Distribución de facturación por estado de suscripción
SELECT 
    subscription_status,
    COUNT(customer_id)                                              AS total_clientes,
    ROUND(SUM(total_orden), 2)                                     AS facturacion_total,
    ROUND(AVG(total_orden), 2)                                     AS gasto_promedio,
    ROUND(COUNT(customer_id) * 100.0 /
        (SELECT COUNT(*) FROM fac_comportamiento), 2)              AS porcentaje_clientes,
    ROUND(SUM(total_orden) * 100.0 /
        (SELECT SUM(total_orden) FROM fac_comportamiento), 2)      AS porcentaje_facturacion
FROM fac_comportamiento
GROUP BY subscription_status
ORDER BY facturacion_total DESC;

/* HALLAZGO 3: El 44.92% de los clientes (cancelados + en pausa) representa
   $1,132,015 en facturación histórica, equivalente al 26.82% del total.
   
   De ese monto, $641,963 corresponde a clientes que ya cancelaron 
   definitivamente, y $490,051 a clientes en pausa que podrian representar
   una oportunidad de reactivación antes de que procedan a cancelar.
   
   Los clientes activos concentran el 73.18% de la facturación total
   ($3,088,439), lo que confirma que retener a los clientes activos
   es la prioridad número uno de la ecommerce. */

   
-- ANALISIS 4: Tasa de abandono segun historial de cancelaciones
SELECT 
    cancellations_count AS cancelaciones_previas,
    COUNT(customer_id) AS total_clientes,
    SUM(CASE WHEN subscription_status = 'cancelled' 
        THEN 1 ELSE 0 END) AS total_status_cancelados,
    ROUND(SUM(CASE WHEN subscription_status = 'cancelled' 
        THEN 1 ELSE 0 END) * 100.0 / COUNT(customer_id), 1) AS tasa_abandono
FROM fac_comportamiento
GROUP BY cancellations_count
ORDER BY cancellations_count ASC;

/* HALLAZGO 4: El historial de cancelaciones puede ser un predictor 
   de abandono en el dataset. Se identifican dos grupos distintos:

   - 0 y 1 cancelación: tasa de abandono muy baja (8.0% y 7.8%).
     Estos clientes son estables y tienen bajo riesgo de abandonar.
   
   - 2 o más cancelaciones: la tasa salta a 22.9% con
     2 cancelaciones, 54.0% con 3, 62.9% con 4 y 54.8% con 5.
     Es decir, a partir de la segunda cancelación el riesgo se multiplica
     casi 3 veces 

   La segunda cancelación es el punto de quiebre.
   Un cliente con 0-1 cancelaciones tiene menos del 8% de riesgo.
   En cuanto llega a 2 cancelaciones ese riesgo sube a 23%, y con 3
   ya supera el 50%. La intervención debe ocurrir antes de que el
   cliente llegue a su segunda cancelación. */
   
   
-- ANALISIS 5: Riesgo de abandono segun nivel de inactividad -----------------------------------

-- Criterios de clasificacion de dim_segmento_riesgo:
-- Activo:       ultima compra hace menos de 180 dias (6 meses)
-- Alerta:       entre 180 y 365 dias sin comprar (6 a 12 meses)
-- Riesgo Medio: entre 365 y 730 dias sin comprar (1 a 2 años)
-- Riesgo Alto:  mas de 730 dias sin comprar (mas de 2 años)
-- Fecha de referencia: MAX(last_purchase_date) = 2025-08-20


SELECT 
    dr.nivel_riesgo,
    COUNT(fc.customer_id) AS total_clientes,
    SUM(CASE WHEN fc.subscription_status = 'cancelled' THEN 1 
        ELSE 0 END) AS total_cancelados,
    ROUND(SUM(CASE WHEN fc.subscription_status = 'cancelled' 
        THEN 1 ELSE 0 END) * 100.0 / COUNT(fc.customer_id), 1) AS tasa_abandono,
    ROUND(SUM(fc.total_orden), 2) AS facturacion_total
FROM fac_comportamiento fc
JOIN dim_segmento_riesgo dr ON fc.customer_id = dr.customer_id
GROUP BY dr.nivel_riesgo
ORDER BY facturacion_total DESC;


/* HALLAZGO 5: El nivel de inactividad es un predictor de abandono.
   Los clientes Activos (última compra hace menos de 6 meses) tienen una
   tasa de abandono de 3.6%, mientras que los segmentos inactivos
   superan el 35%:

   - Activo: 1,864 clientes / 3.6% abandono / $2,179,058 facturación
   - Alerta: 979 clientes / 35.0% abandono / $546,264
   - Riesgo Medio: 1,193 clientes / 57.3% abandono / $717,602
   - Riesgo Alto: 964 clientes / 41.5% abandono / $777,529

   La diferencia entre Activo y Riesgo Medio es de 53.7 puntos porcentuales,
   lo que confirma que la inactividad es uno de los factores 
   del abandono.

   Desde una perspectiva de negocio, los segmentos Alerta + Riesgo Medio +
   Riesgo Alto suman 3,136 clientes con $2,041,396 en facturación histórica.
   Recuperar aunque sea el 20% de esos clientes representaría $408,279
   adicionales para la plataforma. */
   

   
