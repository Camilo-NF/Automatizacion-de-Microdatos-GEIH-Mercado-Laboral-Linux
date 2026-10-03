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

## Paso 4: Ejecución y configuración del flujo de trabajo para el mercado laboral

Una vez que el entorno está completamente configurado, el proceso de ingesta y limpieza de los microdatos se realiza a través del script ubicado en `scripts/01_ingesta_estandarizacion_y_guardar_linux.R`. 

Tienes dos caminos principales para hacerlo: configurar los parámetros directamente en el código antes de ejecutarlo, o seguir el paso a paso detallado a continuación.

---

### Paso 4.1: Ubicar el archivo ZIP de la GEIH
Antes de abrir cualquier script, asegúrate de cumplir con una condición clave:
* El archivo comprimido del DANE (por ejemplo, `Enero 2026.zip`) **debe estar guardado obligatoriamente en tu carpeta de Descargas** del sistema. El script está programado para buscarlo allí automáticamente de forma genérica, sin importar el nombre de tu usuario en Linux.

---

### Paso 4.2: Abrir y revisar el script de parámetros

Para adaptar el script a tus archivos:

1. Dirígete a la carpeta `scripts/` de este repositorio en tu computador.
2. Abre el archivo **`01_ingesta_estandarizacion_y_guardar_linux.R`** usando el editor de texto o entorno de tu preferencia (como VS Code, Gedit, Nano, RStudio, etc.).
3. Localiza las primeras líneas del archivo correspondientes a los **parámetros iniciales**, las cuales se ven así:

```r
# 2. Definir parámetros iniciales
# Modifica esto cuando cambies de mes/año (ej: "Febrero 2026.zip")
nombre_archivo_zip <- "Enero 2026.zip" 
ruta_descargas <- path(Sys.getenv("HOME"), "Descargas")
ruta_destino_base  <- path("data/raw")
```

### Paso 4.3: Ajustar los parámetros según tus necesidades

Dentro de esas líneas del código, puedes personalizar lo siguiente:

*nombre_archivo_zip:* Cambia "Enero 2026.zip" por el nombre exacto del archivo de la GEIH que descargaste del DANE.   
*ruta_descargas:* Por defecto detecta tu carpeta personal de Descargas de forma automática. Si por alguna razón tienes el archivo guardado en otra ruta, puedes modificar esta línea escribiendo la ruta completa entre comillas (ejemplo: path("/home/tu-usuario/documentos/mis_datos")).
*ruta_destino_base:* Define dónde se guardarán los resultados procesados. Por defecto creará una carpeta limpia llamada data/raw en la raíz del proyecto.   Una vez que hagas tus modificaciones, guarda los cambios en el archivo (archivo y guardar cambios).


### Paso 4.4: Cargar y ejecutar el script en R

Con los parámetros listos, tienes dos formas válidas para correr el proceso:

**Opción A (Desde la consola interactiva de R):**
1. Abre tu terminal en la raíz del repositorio o abre tu entorno de R preferido asegurándote de que el directorio de trabajo sea la carpeta del proyecto.
2. Ejecuta el siguiente comando para cargar y poner en marcha el script de ingesta:
```r
source("scripts/01_ingesta_estandarizacion_y_guardar_linux.R")
```

**Opción B (Directamente desde la terminal sin abrir la consola interactiva):**
1. Abre tu terminal habitual de Linux ubicada en la carpeta raíz del proyecto.
2. Ejecuta el script completo con una sola línea de comandos mediante Rscript:
```Bash
Rscript scripts/01_ingesta_estandarizacion_y_guardar_linux.R
```

### Paso 4.5: ¿Qué verás durante el proceso y qué obtienes al final?

1. Mensajes en pantalla: Mientras corre, el script te irá reportando cada etapa en tiempo real: confirmará si halló el archivo ZIP en descargas, te avisará cuando cree la carpeta estandarizada correspondiente (por ejemplo, data/raw/2026_01/), te notificará la descompresión limpia omitiendo subcarpetas internas del DANE, y finalmente confirmará la estandarización de las cabeceras.
2. Resultado final: Obtendrás una carpeta local organizada bajo data/raw/ con todos los microdatos limpios, descomprimidos y con las columnas estandarizadas (en minúsculas, sin espacios ni tildes mediante codificación Latin-ASCII), listos para arrancar con el siguiente análisis del mercado laboral. 

