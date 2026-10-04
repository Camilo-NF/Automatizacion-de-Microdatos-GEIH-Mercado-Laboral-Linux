# Automatizacion de Microdatos GEIH: Mercado Laboral (Linux)

Este repositorio contiene scripts en R diseñados para automatizar la descarga, descompresión, estructuración y limpieza inicial de los microdatos de la Gran Encuesta Integrada de Hogares (GEIH) del DANE, enfocados específicamente en el análisis del mercado laboral en entornos Linux (Ubuntu / Linux Mint).

---

## Prerrequisitos del sistema

Antes de comenzar, asegúrate de contar con lo siguiente:
* Un sistema operativo **Linux** (como Ubuntu o Linux Mint).
* **R** instalado. Si no lo tienes, puedes instalarlo desde la terminal con `sudo apt install r-base` o descargarlo directamente desde el [sitio web oficial de CRAN](https://cran.r-project.org/).
* Este repositorio descargado en tu equipo.
* *(Opcional)* Un entorno de desarrollo de tu preferencia, como **VS Code** (con la extensión de R) o **RStudio**. Si prefieres no usar entornos gráficos, puedes ejecutar todo directamente desde la terminal con comandos de consola.

---

## Paso 1: Instalar las dependencias del sistema operativo

Linux requiere ciertas bibliotecas internas para que R pueda compilar paquetes avanzados como `fs`, `xml2` o `tidyverse`. Si omites este paso, la instalación fallará.

1. Abre tu terminal normal de Linux.
1.2. Copia y pega el siguiente bloque de comandos, luego presiona Enter:
   ```bash
   sudo apt update
   sudo apt install -y libuv1-dev libxml2-dev libssl-dev libcurl4-openssl-dev libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff-dev libjpeg-dev
1.3. El sistema te pedirá tu contraseña de administrador (sudo). Escríbela y presiona Enter (al escribirla no se verá nada en pantalla por seguridad, lo cual es normal).

---

## Paso 2: Abrir R dentro de la carpeta del proyecto

Para que R reconozca los archivos del repositorio de manera automática sin enredos de rutas:

2.1. Abre el explorador de archivos de Linux y entra a la carpeta raíz de este repositorio.
2.2. Haz clic derecho en un espacio vacío dentro de la carpeta y selecciona "Abrir en la terminal".
2.3. Escribe la letra R en mayúscula en esa terminal y presiona Enter para abrir la consola de R directamente en este directorio.
2.4. *Alternativa:* Si lo prefieres, puedes abrir RStudio o tu entorno habitual desde el menú de aplicaciones de tu sistema, y asegurarte de configurar tu sesión apuntando a la carpeta de este proyecto.

---

## Paso 3: Instalar los paquetes necesarios en R

Para instalar las librerías requeridas (tidyverse, fs, zip y stringi), tienes dos opciones según tu nivel de comodidad:

**Opción A: Para usuarios avanzados (Mediante el script automatizado)**
Si ya conoces el flujo de R, simplemente ejecuta el archivo de configuración de este repositorio dentro de tu consola de R para que el script detecte y descargue todo lo que falte automáticamente:
```r
source("00_preparacion_entorno_y_dependencias_linux.R")
```

**Opción B: Para quienes prefieren copiar y pegar (Instalación manual)**

Si no quieres complicarte con archivos de configuración y prefieres hacerlo tú mismo, copia y pega este comando directamente en tu consola de R y presiona Enter:
```r
install.packages(
  c("tidyverse", "fs", "zip", "stringi"),
  repos = "https://cloud.r-project.org"
)
```

---

## Paso 4: Configurar, modificar y ejecutar el flujo de trabajo en R

Una vez que el entorno está completamente configurado, el proceso se realiza editando y ejecutando el script base para procesar un archivo individual ubicado en la carpeta `scripts/01_ingesta_estandarizacion_y_guardar_linux.R`. 

*(Nota: Si más adelante necesitas procesar un gran volumen de archivos en masa de forma automática, este repositorio también incluye una versión avanzada en `scripts/01_ingesta_estandarizacion_y_guardar_linux_Multi.R`, la cual detallaremos más adelante).*

Para procesar tus archivos de forma muy sencilla —abriendo el archivo con un doble clic, cambiando el nombre del mes, guardando y ejecutando con Enter de forma sucesiva—, sigue estos pasos:


### 4.1. Descargar los microdatos de la GEIH (DANE)
Si aún no cuentas con los archivos comprimidos, puedes descargarlos directamente desde el portal oficial del **[Catálogo de Microdatos del DANE](https://microdatos.dane.gov.co/)**. 

Asegúrate de que el archivo comprimido que descargues (por ejemplo, `Enero 2026.zip`) quede guardado en tu carpeta personal de descargas del sistema operativo (por ejemplo, en `/home/Usuario/Descargas/`). Los archivos originales de origen se mantienen siempre fuera del repositorio en dicha ubicación.


### 4.2. Abrir R directamente desde la carpeta del proyecto
Para que R reconozca los archivos de inmediato sin enredos de rutas:
1. Entra con el explorador de archivos de tu sistema operativo a la carpeta raíz de este repositorio.
2. Abre R asegurándote de que el directorio de trabajo sea esta misma carpeta (puedes hacer clic derecho en un espacio vacío de la carpeta, seleccionar "Abrir en la terminal" y escribir `R`).


### 4.3. Abrir y modificar el script (¡Puedes usar doble clic!)
1. Ve a la carpeta `scripts/` dentro del explorador de archivos de tu computador.
2. Abre el archivo **`01_ingesta_estandarizacion_y_guardar_linux.R`** haciendo doble clic sobre él (se abrirá con tu editor de texto predeterminado o con RStudio si lo tienes instalado).
3. En las primeras líneas verás la sección de parámetros iniciales:
   ```r
   # 2. Definir parámetros iniciales
   # Modifica esto cuando cambies de mes/año (ej: "Febrero 2026.zip")
   nombre_archivo_zip <- "Enero 2026.zip" 
   ruta_descargas <- path(Sys.getenv("HOME"), "Descargas")
   ruta_destino_base  <- path("data/raw")
    ```
4. Cambia "Enero 2026.zip" por el nombre exacto del archivo que quieres procesar.
5. Guarda los cambios en el archivo (puedes presionar Ctrl + S).


### 4.4. Ejecutar el script (Presionando Enter)
Dirígete a la consola de R que abriste en el paso 4.2, escribe el siguiente comando y presiona Enter para poner en marcha el proceso:
   ```r
   source("scripts/01_ingesta_estandarizacion_y_guardar_linux.R")
   ```


### 4.5. ¿Cómo procesar varios meses de forma sucesiva?
Si quieres hacer lo mismo para otro mes (como por ejemplo, pasar de Enero a Febrero) de forma rápida:
1. Vuelves a abrir el archivo 01_ingesta_estandarizacion_y_guardar_linux.R (puedes dejarlo abierto de antes o hacerle doble clic de nuevo).
2. Cambias el nombre del archivo por el nuevo mes (ej: "Febrero 2026.zip").
3. Guardas los cambios (Ctrl + S).
4. Te vas a la consola de R, presionas la flecha hacia arriba (↑) en tu teclado para que aparezca el comando source(...) que ya habías escrito antes, y le vuelves a dar Enter. ¡Listo! Puedes repetir este ciclo las veces que necesites.


### 4.6. ¿Qué verás durante el proceso y cómo se organizan las carpetas?
**Mensajes en pantalla:** Mientras corre, el script te irá reportando cada etapa en tiempo real: confirmará si halló el archivo en tu carpeta externa de descargas, te avisará cuando cree la estructura correspondiente, te notificará la descompresión limpia omitiendo subcarpetas internas, y finalmente confirmará la estandarización de las cabeceras.

Lógica de rutas y almacenamiento:
**Archivos Originales:** Permanecen intactos fuera del repositorio en tu directorio de descargas (ej. /home/Usuario/Descargas/).

*repositorio/data/temp/:* **Carpeta temporal** interna del repositorio donde el script realiza la descompresión y lectura inicial de los archivos tal cual como vienen del DANE.

*carpeta personal/data/raw/* **(Archivos Definitivos):** Se ubica de forma accesible en tu carpeta personal de archivos (por ejemplo, en el directorio general de usuario donde por defecto suele descargar y organizarse para la mayoría de usuarios), conteniendo carpetas ordenadas por período (ej. 2026_01/) con los microdatos limpios, descomprimidos y con las columnas estandarizadas (en minúsculas, sin espacios ni tildes), listos para arrancar con el análisis.
