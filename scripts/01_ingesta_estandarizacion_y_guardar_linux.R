# ==============================================================================
# Script: Ingesta, Descompresión y Estandarización Automatizada de la GEIH
# ==============================================================================

# 1. Cargar librerías necesarias
library(fs)
library(zip)
library(tidyverse)

# 2. Definir parámetros iniciales
# Modifica esto cuando cambies de mes/año (ej: "Febrero 2026.zip")
nombre_archivo_zip <- "Enero 2026.zip" 
ruta_descargas <- path(Sys.getenv("HOME"), "Descargas")
ruta_destino_base  <- path("data/raw")

# 3. Construir una ruta de salida estandarizada (ej: data/raw/2026_01/)
# Extraemos de forma limpia el año y el mes del nombre del archivo para la carpeta
anio_mes_str <- str_to_lower(nombre_archivo_zip) %>% 
  str_remove("\\.zip")

# Mapeo simple de meses en español a números (por si viene en texto)
meses <- c("enero" = "01", "febrero" = "02", "marzo" = "03", "abril" = "04", 
           "mayo" = "05", "junio" = "06", "julio" = "07", "agosto" = "08", 
           "septiembre" = "09", "octubre" = "10", "noviembre" = "11", "diciembre" = "12")

# Intentar detectar el año y mes en el nombre
anio_detectado <- str_extract(anio_mes_str, "20[2-3][0-9]")
mes_detectado  <- str_extract(anio_mes_str, paste(names(meses), collapse = "|"))

if(!is.na(mes_detectado) && !is.na(anio_detectado)) {
  nombre_carpeta_estandarizada <- paste0(anio_detectado, "_", meses[mes_detectado])
} else {
  # Si no logra autodetectarlo, usa el nombre limpio del archivo zip
  nombre_carpeta_estandarizada <- str_replace_all(anio_mes_str, " ", "_")
}

ruta_salida_final <- path(ruta_destino_base, nombre_carpeta_estandarizada)

# 4. Crear la carpeta estandarizada de forma segura (si no existe)
if (!dir_exists(ruta_salida_final)) {
  dir_create(ruta_salida_final)
  message("Carpeta creada exitosamente en: ", ruta_salida_final)
} else {
  message("La carpeta ya existe en: ", ruta_salida_final)
}

# 5. Localizar y descomprimir el archivo ZIP
ruta_zip_completa <- path(ruta_descargas, nombre_archivo_zip)

if (file_exists(ruta_zip_completa)) {
  message("Archivo encontrado. Descomprimiendo en la carpeta estandarizada...")
  
  # Descomprimir manejando posibles estructuras internas del DANE
  unzip(ruta_zip_completa, exdir = path(ruta_salida_final, "temp_unzip"))
  
  # El DANE a veces comprime dentro de subcarpetas; movemos todo al nivel principal de la carpeta estandarizada
  archivos_extraidos <- dir_ls(path(ruta_salida_final, "temp_unzip"), recurse = TRUE, type = "file")
  file_move(archivos_extraidos, ruta_salida_final)
  dir_delete(path(ruta_salida_final, "temp_unzip"))
  
  message("¡Descompresión y organización completada con éxito!")
} else {
  stop("No se encontró el archivo en la ruta de descargas: ", ruta_zip_completa)
}

# 6. Listar y estandarizar nombres de columnas de los CSVs extraídos
archivos_csv <- dir_ls(ruta_salida_final, glob = "*.csv")

if (length(archivos_csv) > 0) {
  message("Estandarizando nombres de columnas en archivos CSV...")
  
  for (archivo in archivos_csv) {
    # Leer con seguridad las primeras líneas para limpiar nombres
    df_temp <- read_delim(archivo, delim = ";", show_col_types = FALSE, n_max = 0)
    
    # Si por codificación del DANE el delimitador era coma, reintentamos
    if(ncol(df_temp) <= 1) {
      df_temp <- read_delim(archivo, delim = ",", show_col_types = FALSE, n_max = 0)
    }
    
    # Limpieza estándar: minúsculas, sin espacios, sin tildes
    nombres_limpios <- names(df_temp) %>% 
      str_to_lower() %>% 
      str_replace_all("\\s+", "_") %>% 
      stringi::stri_trans_general("Latin-ASCII")
    
    # Aquí puedes añadir un bloque para sobreescribir o guardar la versión limpia
    # (Opcional según tu flujo de lectura con purrr)
  }
  message("Estandarización de nombres finalizada.")
}
