library(tidyverse)
library(sf)
library(here)

# 1. CARGAR DATOS
# Leemos las tablas que creamos en el paso anterior
dim_sensores <- readRDS(here("data/processed/rds/dim_sensores.rds"))
fact_ruido   <- readRDS(here("data/processed/rds/fact_ruido.rds"))

# 2. UNIR DATOS 
# Usamos inner_join para asegurar que solo analizamos lo que tiene datos completos
datos_completos <- fact_ruido %>%
  inner_join(st_drop_geometry(dim_sensores), by = "codigo")


# GRÁFICO 1: Grafico de las coordenadas de los sensores y la intesidad del tráfico.

g1 <- ggplot(data = dim_sensores) +
  geom_sf(aes(color = trafico_intensidad), size = 3) + 
  scale_color_gradient(low = "green", high = "red") +  
  theme_minimal() +
  labs(title = "Mapa de Sensores por Tráfico")

ggsave(here("results/plots/intensidad_sensores_mapa.png"), g1)
print (g1)


# GRÁFICO 2:Gráfico de ruido diario


resumen_hora <- datos_completos %>%
  group_by(hora) %>%
  summarise(ruido_medio = mean(nivel_ruido, na.rm = TRUE))

g2 <- ggplot(resumen_hora, aes(x = hora, y = ruido_medio)) +
  geom_line(color = "purple", size = 1) +  
  geom_point() +                         
  scale_x_continuous(breaks = 0:23) +    
  theme_minimal() +
  labs(title = "Evolución Horaria del Ruido", y = "Decibelios (dB)")

ggsave(here("results/plots/horario.png"), g2)
g2



# GRÁFICO 3: Correlación ruido tráfico

resumen_sensor <- datos_completos %>%
  group_by(codigo, trafico_intensidad) %>%
  summarise(ruido_medio = mean(nivel_ruido, na.rm = TRUE))

g3 <- ggplot(resumen_sensor, aes(x = trafico_intensidad, y = ruido_medio)) +
  geom_point(size = 3) +                
  geom_smooth(method = "lm", color = "red") + # Dibuja la línea de tendencia
  theme_light() +
  labs(title = "Correlación Tráfico vs Ruido", x = "Coches (Intensidad)", y = "Ruido (dB)")

ggsave(here("results/plots/ruido_trafico_correlacion.png"), g3)
g3



# GRÁFICO 4:  (Día vs Noche / Semanal)

# Ordenamos los días para que no salgan alfabéticos (Jueves antes que Lunes)
datos_completos$dia_semana <- factor(datos_completos$dia_semana, 
                                     levels = c("lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo"))

g4 <- ggplot(datos_completos, aes(x = dia_semana, y = nivel_ruido)) +
  geom_boxplot(fill = "lightblue") +   #
  theme_minimal() +
  labs(title = "Distribución del Ruido por Día", x = "")

ggsave(here("results/plots/box_plot.png"), g4)
g4



