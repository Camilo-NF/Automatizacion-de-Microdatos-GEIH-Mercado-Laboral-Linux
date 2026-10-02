# ==============================================================================
# Script: Preparación del entorno de trabajo y dependencias Linux (Blindado)
# ==============================================================================

# 1. Definir la lista completa de paquetes requeridos
paquetes_requeridos <- c("tidyverse", "fs", "zip", "stringi")

# 2. Obtener los paquetes instalados de forma segura (evita errores si está vacío)
matriz_instalados <- installed.packages()
if (nrow(matriz_instalados) > 0) {
  paquetes_instalados <- matriz_instalados[, "Package"]
} else {
  paquetes_instalados <- character(0)
}

# 3. Filtrar cuáles paquetes faltan realmente
paquetes_faltantes <- paquetes_requeridos[!(paquetes_requeridos %in% paquetes_instalados)]

# 4. Proceder con la instalación solo si hay paquetes faltantes
if (length(paquetes_faltantes) > 0) {
  cat("Se detectaron paquetes faltantes:", paste(paquetes_faltantes, collapse = ", "), "\n")
  cat("Iniciando la descarga e instalación desde el repositorio oficial...\n")
  
  install.packages(paquetes_faltantes, repos = "https://cloud.r-project.org")
  
  cat("Instalación de paquetes de R finalizada correctamente.\n")
} else {
  cat("Todos los paquetes necesarios ya se encuentran instalados.\n")
}

# 5. Cargar librerías en la sesión
cat("Cargando librerías en la sesión...\n")

library(tidyverse)
library(fs)
library(zip)
library(stringi)

cat("¡Entorno listo y verificado! El espacio de trabajo está preparado.\n")
