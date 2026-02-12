#Cargamos las librerias y dependencias

if (!require("here")) install.packages("here"); library(here)
source(here("config/config.R"))


#Definir archivo de log
log_file <- function(msg){
  cat(mensake, "\n")
  cat(mensaje, "\n", file = log_file, append = TRUE)

}

log_msg("INICIANDO LIMPIEZA DE DATOS")

tryCatch(
  {
  
    log_msg("Cargando archivos .rds desde data/raw/...")
    
    trafico_raw <- readRDS("data/raw/trafico_bilbao.rds")
    mediciones_raw <- readRDS("data/raw/sonometro_mediciones.rds")
    ubicacion_raw <- readRDS("data/raw/sonometro_ubicacion.rds")
    
    
    log_msg("Datos cargados correctamente")
    
    #Limpieza de Tráfico
    
    trafico_clean <- trafico_raw %>%
      mutate(
        # conversión de string a número
        intensidad = as.numeric(Intensidad),
        ocupacion = as.numeric(Ocupacion)
      ) %>%
      #Seleccionamos las columnas de interés del dataset trafico limpio
      select(id_tramo = CodigoSeccion, intensidad, ocupacion, geometry) %>%
      filter(!is.na(intensidad)) %>%
      #Aseguramos que las geometrías sean validas
      st_make_valid() %>%
      #Eliminamos duplicados en base a id_tramo
      distinct(id_tramo, .keep_all = TRUE)
    
    log_msg(paste("Tráfico limpio:", nrow(trafico_clean), "Filas procesadas"))
    
    
    #Limpieza de ubicación
    
    ubicacion_clean <- ubicacion_raw  %>%
      rename(codigo = name, direccion = address)  %>%
      
      mutate(
        # Aseguramos que sea texto
        direccion = as.character(direccion),
        

        # 1. Convertimos de Latin1 a UTF-8 (Arregla la Ñ y tildes)
        direccion = iconv(direccion, from = "latin1", to = "UTF-8"),
        
        # 2. Quitamos espacios sobrantes al principio y final
        direccion = trimws(direccion),
        
        # 3. Pasamos todo a mayusculas
        direccion = toupper(direccion)
      ) %>%
      
      select(codigo, direccion, geometry)  %>%
      filter(!is.na(codigo))  %>%
      st_transform(st_crs(trafico_clean))  %>%
      distinct(codigo, .keep_all = TRUE)
    
    log_msg("Calculando las distancias: Cruzando sensores con Tráfico")
    
    #ENCUENTRA EL ÍNDICE DE LA CARRETERA MÁS CERCANA PARA CADA SENSOR
    indices_cercanos <- st_nearest_feature(ubicacion_clean, trafico_clean)
    
    dim_sensores <- ubicacion_clean  %>%
      mutate(
              trafico_intensidad = trafico_clean$intensidad[indices_cercanos],
              trafico_ocupacion = trafico_clean$ocupacion[indices_cercanos],
              id_tramo_cercano = trafico_clean$id_tramo[indices_cercanos]
      )
    
    log_msg("Procesando Mediciones")
    
    fact_ruido <- mediciones_raw  %>%
    rename(codigo = nombre_dispositivo)  %>% #renombrar columnas para que coincidan
    mutate(
            #Conversión de valores correspondientes.        
            nivel_ruido = as.numeric(decibelios),
            fecha_hora = ymd_hms(fecha_medicion),
            
            #Separacion de fehca y hora
            fecha = as.Date(fecha_hora),
            hora = hour(fecha_hora),
            dia_semana = wday(fecha_hora, label = TRUE, abbr=  FALSE, week_start = 1),
            
            # Categorización de la franja horaria
            franja = case_when(
              hora >= 7 & hora < 22 ~ "Diurno",
              TRUE ~ "Nocturno"
            )
    
      
      )  %>%
      
    filter(!is.na(nivel_ruido))   %>%
    select(codigo, fecha_hora, fecha, hora, dia_semana, franja, nivel_ruido)  %>%
    distinct(codigo, fecha_hora, .keep_all = TRUE)
    
    

    
    
    log_msg(paste("Limpieza de datos Mediciones realizada", nrow(fact_ruido), "número de filas procesadas"))
    
    #Guardar los datasets limpios en rds
    if(!dir.exists(here("data/processed/rds"))) dir.create(here("data/processed/rds"))
    
    saveRDS(dim_sensores, here("data/processed/rds/dim_sensores.rds"))
    saveRDS(fact_ruido, here("data/processed/rds/fact_ruido.rds"))
    
    
    #Guardar los datasets limpios en csv para PowerBi
    
    if(!dir.exists(here("data/processed/csv"))) dir.create(here("data/processed/csv"))
    
    csv_sensores <- dim_sensores  %>%
      mutate(
              latitud = st_coordinates(geometry)[,2],
              longitud = st_coordinates(geometry)[,1]
                                       
      ) %>%
      st_drop_geometry()
    
      csv_ruido <- fact_ruido %>%
        mutate(fecha = as.character(fecha))
      
    write_csv(csv_sensores, here("data/processed/csv/sensores.csv"))
    write_csv(csv_ruido, here("data/processed/csv/ruido.csv"))
    
    log_msg("CSV CREADOS CON EXITO")
  
},
  error = function(e){
    log_msg(paste("ERROR:", e$message))
  }
)
fact_ruido
dim_sensores

