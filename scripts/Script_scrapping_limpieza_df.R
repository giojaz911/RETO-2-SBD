library(httr)
library(jsonlite)
library(sf)


url1 <- "https://www.bilbao.eus/aytoonline/srvDatasetTrafico?formato=geojson"
url2 <- "https://www.bilbao.eus/aytoonline/jsp/opendata/movilidad/od_sonometro_ubicacion.jsp?idioma=c&f%20ormato=geojson"
url3 <- "https://www.bilbao.eus/aytoonline/jsp/opendata/movilidad/od_sonometro_mediciones.jsp?idioma=c&formato=json"


#Cargar geoJsons
geo1 <- st_read(url1)
geo2 <- st_read(url2)

#Cargar Jsons
resp <- GET(url3)
datos <- content(resp, as = "text", encoding = "UTF-8")
json <- fromJSON(datos)
head(json)


#Convertir a DataFrames.
df_Trafico <- as.data.frame(geo1)
df_Ubicacion <- as.data.frame(geo2)
df_Mediciones <- as.data.frame(json)


#Limpiar DataFrames

#Comprobar si hay nulos
sapply(df_Trafico, function(x) sum(is.na(x)))#No hay nulos
sapply(df_Ubicacion, function(x) sum(is.na(x)))#No hay nulos
sapply(df_Mediciones, function(x) sum(is.na(x)))#No hay nulos

#Pasar a númericos las columnas de Latitud y Longitud en DataFrame Ubicación.
df_Ubicacion$latitude <- as.numeric(df_Ubicacion$latitude)
df_Ubicacion$longitude <- as.numeric(df_Ubicacion$longitude)

#Pasar a número la columna de Decibelios en el DataFrame Mediciones
df_Mediciones$decibelios <- as.numeric(df_Mediciones$decibelios)


#Outliers en la longitud y Latitud.
boxplot(df_Ubicacion$latitude, main="Outliers Latitud")
boxplot(df_Ubicacion$longitude, main="Outliers Longitud")








# Carga las librerías si no están
library(sf)
library(dplyr)
library(here)

# Lee los archivos brutos
trafico <- readRDS(here("data/raw/trafico_bilbao.rds"))
ubicacion <- readRDS(here("data/raw/sonometro_ubicacion.rds"))
mediciones <- readRDS(here("data/raw/sonometro_mediciones.rds"))

# --- LO QUE NECESITO QUE ME PEGUES ---
print("--- ESTRUCTURA TRÁFICO ---")
glimpse(trafico)

print("--- ESTRUCTURA UBICACIÓN ---")
glimpse(ubicacion)

print("--- ESTRUCTURA MEDICIONES ---")
glimpse(mediciones)

trafico
mediciones
