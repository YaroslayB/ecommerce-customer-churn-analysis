#  E-Commerce Customer Insights & Churn Analysis

Análisis end-to-end de comportamiento y abandono de clientes en una empresa de e-commerce, usando **MySQL** para limpieza/análisis de datos y **Power BI** para visualización ejecutiva.

> Proyecto final — Bootcamp de Análisis de Datos, Unicorn Academy (2026)

---

## Problema de negocio

¿Cómo identificar clientes de alto valor y clientes en riesgo de abandono para optimizar retención e ingresos en una empresa de e-commerce?

## Objetivos

- Identificar clientes de alto valor (concentración de revenue)
- Relacionar estado de suscripción con comportamiento de compra
- Detectar clientes en riesgo de abandono por inactividad
- Medir el impacto de cancelaciones previas como predictor de churn
- Analizar patrones de compra por categoría de producto

---

## Dataset

- **Nombre:** E-Commerce Customer Insights and Churn Dataset (Kaggle)
- **Volumen:** 5,000 órdenes / 5,000 clientes únicos / 2,000 productos únicos, 17 variables
- **Contenido:** demografía, transacciones, estado de suscripción/cancelaciones y variables de comportamiento (frecuencia de compra, última compra)
- **Calidad de datos:** 0 valores nulos en columnas críticas, 0 duplicados en `order_id`, 0 registros con precios o cantidades inválidas

---

## Metodología

**Etapa 1 — Extracción y exploración**
Análisis exploratorio completo del dataset: valores nulos, duplicados, rangos lógicos, consistencia entre fechas y valores categóricos.

**Etapa 2 — Limpieza y estructuración**
Modelo relacional normalizado en MySQL con 4 tablas: `dim_clientes`, `dim_productos`, `fac_comportamiento` (tabla de hechos con `total_orden` calculado) y `dim_segmento_riesgo` (clasificación de inactividad vía `DATEDIFF`).

**Etapa 3 — Análisis en SQL y hallazgos clave**

| # | Pregunta de negocio | Hallazgo |
|---|---|---|
| 1 | Segmentación de clientes por valor | El segmento **Alto valor** (27.3% de clientes) genera el **62.3%** de la facturación total |
| 2 | Perfil del cliente que cancela | Clientes cancelados compran **la mitad de frecuente** (14.3 vs 27.8 veces/año) y gastan **2.6x menos** que los activos |
| 3 | Facturación en riesgo | El 44.9% de clientes (cancelados + pausados) representa el **26.8%** de la facturación histórica |
| 4 | Cancelaciones previas como predictor | La tasa de abandono salta de **8% a 54%** al pasar de 1 a 3 cancelaciones — la 2ª cancelación es el punto de quiebre |
| 5 | Riesgo por inactividad | Clientes inactivos +1 año tienen **35-57% de tasa de abandono**, vs. 3.6% en clientes activos |

**Etapa 4 — Visualización en Power BI**

- **Segmentación RFM:** clasificación de los 5,000 clientes en 6 segmentos (Estrella, Fiel, Regular, En Riesgo, Cliente Nuevo, Fiel Perdido)
- **Tasa de abandono dinámica:** medidas calculadas filtrables por país, categoría, género y edad
- **Valor económico en riesgo:** facturación en manos de clientes de riesgo medio/alto

**Dashboard de 4 páginas:**
1. Resumen ejecutivo — salud general de la base de clientes
2. Segmentación por valor — mejores clientes vs. clientes en riesgo
3. Retención y abandono — por qué y cuándo se van los clientes
4. Recomendaciones operacionales — acciones sugeridas e impacto estimado

---

## Herramientas

- **MySQL Workbench** — limpieza, estructuración y análisis de datos
- **Power BI** — visualización y tablero de control ejecutivo

## Estructura del repositorio
├── sql/

│   ├── 01_exploracion.sql        # Análisis exploratorio inicial (calidad de datos)

│   ├── 02_limpieza_modelo.sql    # Creación del modelo relacional en MySQL

│   └── 03_analisis.sql           # 5 análisis de negocio con hallazgos

├── dashboard/

│   ├── dashboard.pdf             # dashboard/dashboard.pdf 

└── README.md

## Alcance

**Incluye:** análisis exploratorio completo, base de datos limpia con modelo relacional, clasificación de clientes por riesgo, análisis de patrones de abandono, segmentación de valor, dashboard interactivo y recomendaciones con impacto estimado.

**No incluye:** modelos de Machine Learning/predicción automática, integración con sistemas en tiempo real, datos de costos/márgenes, ni análisis multi-transacción (el dataset tiene una orden por cliente).

---

## Autora

**Yaroslay Bravo** — Operations Analyst | Data Analyst
[LinkedIn](https://www.linkedin.com/in/yaroslay)
