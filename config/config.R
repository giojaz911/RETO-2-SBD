# config/config.R

# --- 1. GESTIÓN DE DEPENDENCIAS (LIBRERÍAS) ---
# Comprobamos si pacman está instalado. Si no, lo instala.
if (!require("pacman")) install.packages("pacman")

# Aquí pones TODAS las librerías que usará tu proyecto.
pacman::p_load(
  httr,       # Para descargar de la web (GET)
  jsonlite,   # Para leer JSON (fromJSON)
  sf,         # Para mapas y GeoJSON (st_read)
  here,       # Para arreglar las rutas de archivos
  lubridate,  # Para arreglar fechas (lo usarás luego)
  dplyr,      # Para manipular datos (select, filter...)
  readr       # Para guardar CSVs
)

# --- 2. RUTAS DEL PROYECTO ---

PATH_RAW     <- here("data/raw")
PATH_CLEAN   <- here("data/clean")
PATH_CURATED <- here("data/curated")
PATH_LOGS    <- here("logs")
FILE_LOG     <- here("logs/execution.log")

# --- 3. FUENTES DE DATOS ---
FUENTES <- list(
  trafico_bilbao = list(
    url  = "https://www.bilbao.eus/aytoonline/srvDatasetTrafico?formato=geojson",
    tipo = "geojson"
  ),
  sonometro_ubicacion = list(
    url  = "https://www.bilbao.eus/aytoonline/jsp/opendata/movilidad/od_sonometro_ubicacion.jsp?idioma=c&formato=geojson",
    tipo = "geojson"
  ),
  sonometro_mediciones = list(
    url  = "https://www.bilbao.eus/aytoonline/jsp/opendata/movilidad/od_sonometro_mediciones.jsp?idioma=c&formato=json",
    tipo = "json"
  )
)