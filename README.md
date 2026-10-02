# Automatizacion de Microdatos GEIH: Mercado Laboral (Linux)

Este repositorio contiene scripts en R diseñados para automatizar la descarga, descompresión, estructuración y limpieza inicial de los microdatos de la Gran Encuesta Integrada de Hogares (GEIH) del DANE, enfocados específicamente en el análisis del mercado laboral en entornos Linux (Ubuntu / Linux Mint).

---

## Prerrequisitos del sistema

Antes de comenzar, asegúrate de contar con lo siguiente:
* Un sistema operativo **Linux** (como Ubuntu o Linux Mint).
* **R** instalado. Si no lo tienes, puedes instalarlo desde la terminal con `sudo apt install r-base` o descargarlo directamente desde el [sitio web oficial de CRAN](https://cran.r-project.org/).
* Un entorno de desarrollo de tu preferencia, como **VS Code** (con la extensión de R) o **RStudio**.
* Este repositorio descargado en tu equipo.
  
---

## Paso 1: Instalar las dependencias del sistema operativo

Linux requiere ciertas bibliotecas internas para que R pueda compilar paquetes avanzados como `fs`, `xml2` o `tidyverse`. Si omites este paso, la instalación fallará.

1. Abre tu terminal normal de Linux.
2. Copia y pega el siguiente bloque de comandos, luego presiona Enter:
   ```bash
   sudo apt update
   sudo apt install -y libuv1-dev libxml2-dev libssl-dev libcurl4-openssl-dev libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff-dev libjpeg-dev
3. El sistema te pedirá tu contraseña de administrador (sudo). Escríbela y presiona Enter (al escribirla no se verá nada en pantalla por seguridad, lo cual es normal).

---

## Paso 2: Abrir R dentro de la carpeta del proyecto

Para que R reconozca los archivos del repositorio de manera automática sin enredos de rutas:

1. Abre el explorador de archivos de Linux y entra a la carpeta raíz de este repositorio.
2. Haz clic derecho en un espacio vacío dentro de la carpeta y selecciona "Abrir en la terminal".
3. Escribe la letra R en mayúscula en esa terminal y presiona Enter para abrir la consola de R directamente en este directorio.
4. *Alternativa:* Si lo prefieres, puedes abrir RStudio o tu entorno habitual desde el menú de aplicaciones de tu sistema, y asegurarte de configurar tu sesión apuntando a la carpeta de este proyecto.

---

## Paso 3: Instalar los paquetes necesarios en R

Para instalar las librerías requeridas (tidyverse, fs, zip y stringi), tienes dos opciones según tu nivel de comodidad:

**Opción A: Para usuarios avanzados (Mediante el script automatizado)**

Si ya conoces el flujo de R, simplemente ejecuta el archivo de configuración de este repositorio dentro de tu consola de R para que el script detecte y descargue todo lo que falte automáticamente:
