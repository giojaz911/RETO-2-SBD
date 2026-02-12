# 📊 Análisis de Correlación: Tráfico y Ruido en Bilbao

![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white)
![Data Analysis](https://img.shields.io/badge/Data%20Analysis-Project-green?style=for-the-badge)

Este proyecto tiene como objetivo analizar la **relación entre la intensidad del tráfico y los niveles de ruido** en la ciudad de Bilbao. Utilizando datos abiertos procedentes del Ayuntamiento de Bilbao, se procesan, limpian y cruzan datasets de tráfico y mediciones acústicas para generar visualizaciones que permitan entender patrones de contaminación acústica.

---

## 📂 Estructura del Proyecto

El proyecto está organizado de manera modular para diferenciar claramente entre datos crudos, scripts de procesamiento y resultados.

```mermaid
graph TD
    Bilbao_Ruido_Trafico/
│
├── config/                      # ⚙️ CONFIGURACIÓN CENTRAL
│   └── config.R                 # - El "cerebro" organizativo.
│                                # - Carga todas las librerías (sf, tidyverse).
│                                # - Define rutas relativas y variables globales.
│
├── data/                        # 💾 ARQUITECTURA DE DATOS
│   ├── raw/                     # [INPUT] Datos Crudos (Inmutables)
│   │   ├── trafico_bilbao.gson  # - Copia exacta de la fuente original.
│   │   └── mediciones.json
│   │   └── ubicacion.geojson      # - Nunca se modifican (Backup de seguridad).
│   │
│   └── processed/               # [OUTPUT] Datos Transformados (ETL)
│       ├── rds/                 # - Almacenamiento optimizado para R.
│       │   ├── dim_sensores.rds # - Mantiene tipos de datos (factores, fechas).
│       │   └── fact_ruido.rds   # - Carga instantánea para los scripts.
│       │
│       └── csv/                 # - Capa de Servicio para Power BI.
│           ├── sensores.csv     # - Archivos planos universales.
│           └── ruido.csv        # - Listos para importar sin transformación extra.
│
├── scripts/                     # 🧠 LÓGICA DE PROCESAMIENTO (PIPELINE)
│   ├── 01_ingesta.R             # - Lectura de JSON y GeoJSON.
│   │                            # - Control de errores con tryCatch.
│   │
│   ├── 02_limpieza.R            # - Data Wrangling y limpieza (dplyr).
│   │                            # - Cálculo geoespacial (st_nearest_feature).
│   │
│   └── 03_analisis.R            # - Generación de Insights.
│                                # - Creación de gráficos con ggplot2.
│
├── results/                     # 📊 ENTREGABLES VISUALES
│   └── plots/                   # - Galería de imágenes generadas.
│       ├── mapa_trafico.png       # - Gráficos listos para la memoria/informe.
│       └── correlacion.png
│       └── boxplot.png
│       └── horario.png
│
├── logs/                        # 📝 AUDITORÍA Y TRAZABILIDAD
│   └── execution.log            # - Historial de ejecuciones y errores.
│
└── Bilbao_Ruido.Rproj           # 🛠️ ENTORNO RSTUDIO
                                 # - Garantiza rutas relativas y portabilidad.
```

---

## 🛠️ Descripción de los Scripts

Cada script en la carpeta `scripts/` cumple una función específica en el flujo de trabajo (ETL):

### 1. `01_descarga_de_datos.R` (Extracción)
*   **Función**: Descarga los datos necesarios directamente desde el portal de Open Data de Bilbao.
*   **Input**: URLs configuradas en `config/config.R`.
*   **Output**: Archivos `.rds` guardados en `data/raw/`.
*   **Datos Descargados**:
    *   `trafico_bilbao.rds` (GeoJSON) - Información del tráfico en tiempo real.
    *   `sonometro_ubicacion.rds` (GeoJSON) - Ubicación de los sensores de ruido.
    *   `sonometro_mediciones.rds` (JSON) - Mediciones de decibelios.

### 2. `02_limpieza_datos.R` (Transformación)
*   **Función**: Limpia, normaliza y cruza los datos.
*   **Procesos Clave**:
    *   Corrección de codificación (UTF-8) y nombres de columnas.
    *   Conversión de tipos de datos (texto a numérico, fechas).
    *   **Cruce Espacial**: Asigna a cada sensor de ruido el tramo de tráfico más cercano utilizando geo-procesamiento (`sf`).
    *   Generación de `csv` para exportación a herramientas como Power BI.
*   **Output**: Datasets limpios en `data/processed/rds/` y `data/processed/csv/`.

### 3. `03_analisis_datos.R` (Carga y Visualización)
*   **Función**: Genera gráficos y análisis exploratorio de los datos procesados.
*   **Visualizaciones Generadas** (`results/plots/`):
    *   `intensidad_sensores_mapa.png`: Mapa de calor de sensores según intensidad de tráfico.
    *   `horario.png`: Evolución temporal del ruido promedio por hora.
    *   `ruido_trafico_correlacion.png`: Gráfico de dispersión para analizar la correlación.
    *   `box_plot.png`: Distribución del ruido por día de la semana.

---

## 🗃️ Esquema de Datos

A continuación se detalla la estructura de los datos generados en la fase de limpieza.

### 🔹 `dim_sensores` (Sensores y Tráfico)
Archivo: `data/processed/rds/dim_sensores.rds` / `data/processed/csv/sensores.csv`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `codigo` | `chr` | Identificador único del sensor de ruido (ej. "Urquijo"). |
| `direccion` | `chr` | Dirección física donde está ubicado el sensor. |
| `trafico_intensidad` | `num` | Número de vehículos detectados en el tramo más cercano. |
| `trafico_ocupacion` | `num` | Porcentaje de ocupación de la vía. |
| `id_tramo_cercano` | `chr` | ID del tramo de carretera asignado al sensor. |
| `latitud` / `longitud` | `num` | Coordenadas geográficas (en CSV). |

### 🔹 `fact_ruido` (Mediciones de Ruido)
Archivo: `data/processed/rds/fact_ruido.rds` / `data/processed/csv/ruido.csv`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `codigo` | `chr` | ID del sensor (Foreing Key hacia `dim_sensores`). |
| `fecha_hora` | `dttm` | Timestamp completo de la medición. |
| `fecha` | `date` | Fecha de la medición (YYYY-MM-DD). |
| `hora` | `int` | Hora del día (0-23). |
| `dia_semana` | `ord` | Día de la semana (Lunes, Martes...). |
| `franja` | `chr` | Clasificación horaria: "Diurno" (7-22h) o "Nocturno". |
| `nivel_ruido` | `num` | Nivel de ruido medido en decibelios (dB). |

---

## 🚀 Cómo Ejecutar

1.  Abre el proyecto `RETO-2-SBD.Rproj` en RStudio.
2.  Asegúrate de tener instaladas las librerías necesarias (se gestionan en `config/config.R` con `pacman`).
3.  Ejecuta los scripts en orden secuencial:
    ```r
    source("scripts/01_descarga_de_datos.R")
    source("scripts/02_limpieza_datos.R")
    source("scripts/03_analisis_datos.R")
    ```
4.  Revisa la carpeta `results/plots/` para ver los gráficos generados.

---

