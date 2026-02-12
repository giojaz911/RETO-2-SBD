
#Instalamos la dependencai here si hace falta para cargar el source del proyecto
if (!require(here))install.packages("here"); library(here)


#Cargamos los datos alojados en config.r
source(here("config/config.R"))

#Comprobamos que las carpetas de almacenado de datos existen, sino las creamos.
if (!dir.exists(PATH_RAW))  dir.create(PATH_RAW, recursive = TRUE)
if (!dir.exists(PATH_LOGS)) dir.create(PATH_LOGS, recursive = TRUE)


#Se crea la función de log
log_msg <- function(msg) {
  mensaje <- paste(Sys.time(), "-", msg)
  # Imprime en consola para que veas qué pasa
  cat(mensaje, "\n") 
  # Guarda en archivo
  cat(mensaje, "\n", file = FILE_LOG, append = TRUE)
}

log_msg("INICIANDO PROCESO DE DESCARGAS")
#Bucle para recorrer cada uno de los elementos de la lista de enlaces.
for (nombre in names(FUENTES)){
  
  fuente <- FUENTES[[nombre]]
  
  log(paste("Descargando", nombre))
  
  tryCatch({
    
    datos <- NULL
    
    if(fuente$tipo == "json")
    {
      
      response <- GET(fuente$url)
      txt <- content(response, as = "text", encoding = "UTF8")
      datos <- fromJSON(txt, flatten = TRUE)
      

    }
    #Si el tipo de archivo es geojson lo procesamos con st_read
    else if (fuente$tipo == "geojson")
    {
      datos <- st_read(fuente$url, quiet = TRUE)
    }
    else
    {
      stop("Tipo de archivo deconocido, Por favor introducir un Json o Geojson")
    }
    
    #Guardamos los datos
    archivo_destino <- file.path(PATH_RAW, paste0(nombre, ".rds"))
    saveRDS(datos, archivo_destino)
    
    log_msg(paste("EXITO: guardado en", archivo_destino))
  },
  error = function(e) {
    log_msg(paste("Error en", nombre, ":", e$message))
  })
  
  }
  log_msg("FIN DE LA DESCARGA")


