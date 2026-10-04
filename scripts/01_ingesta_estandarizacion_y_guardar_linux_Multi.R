# ==============================================================================
# INGESTA AUTOMATIZADA DE MICRODATOS GEIH (DANE) - MÚLTIPLES ARCHIVOS
# Pensado para Linux Mint
# ==============================================================================
# Único parámetro a modificar: los archivos comprimidos (.zip o .rar) que están
# en tu carpeta de Descargas. Puedes poner uno o varios.
nombres_archivos <- c(
  "Enero 2026.zip",
  "Febrero 2026.zip"
)
# ==============================================================================
# Resultado: data/raw/2026_01/, data/raw/2026_02/, ... (una carpeta año_mes
# por cada archivo comprimido).
#
# Requisitos opcionales del sistema para .rar (una de las dos opciones):
#   sudo apt install unrar
#   sudo apt install p7zip-full p7zip-rar
# ==============================================================================


# ------------------------------------------------------------------------------
# 0. CONFIGURACIÓN INTERNA
# ------------------------------------------------------------------------------
extensiones_datos <- c("csv", "txt", "dta", "sav")
limpiar_temp      <- TRUE
max_niveles_anid  <- 3

message("==============================================================")
message(" INGESTA GEIH - ", length(nombres_archivos), " archivo(s) solicitado(s)")
message("==============================================================")

cargar_paquete <- function(pkg, obligatorio = TRUE) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    if (obligatorio) {
      message("[paquetes] Instalando '", pkg, "'...")
      install.packages(pkg, repos = "https://cloud.r-project.org", quiet = TRUE)
    } else {
      return(FALSE)
    }
  }
  invisible(requireNamespace(pkg, quietly = TRUE))
}

message("[paquetes] Verificando dependencias...")
invisible(lapply(c("data.table", "haven"), cargar_paquete))
tiene_archive <- cargar_paquete("archive", obligatorio = FALSE)
message("[paquetes] Soporte 'archive': ", ifelse(tiene_archive, "disponible", "no disponible"))


# ------------------------------------------------------------------------------
# 1. CARPETA DE DESCARGAS (Linux Mint: "Descargas" o "Downloads")
# ------------------------------------------------------------------------------
obtener_ruta_descargas <- function() {
  # 1) Consultar la carpeta oficial del sistema (respeta el idioma)
  if (nzchar(Sys.which("xdg-user-dir"))) {
    xdg <- tryCatch(system2("xdg-user-dir", "DOWNLOAD", stdout = TRUE, stderr = FALSE),
                    error = function(e) character(0))
    if (length(xdg) == 1 && nzchar(xdg) && dir.exists(xdg)) return(xdg)
  }
  # 2) Alternativas habituales
  home <- path.expand("~")
  candidatas <- file.path(home, c("Descargas", "Downloads"))
  existentes <- candidatas[dir.exists(candidatas)]
  if (length(existentes) == 0) stop("No se encontró Descargas/Downloads en: ", home)
  existentes[1]
}

message("[paso 1] Ubicando carpeta de Descargas...")
dir_descargas <- obtener_ruta_descargas()
message("[paso 1] Carpeta de descargas: ", dir_descargas)


# ------------------------------------------------------------------------------
# 2. ESTRUCTURA DE CARPETAS
# ------------------------------------------------------------------------------
message("[paso 2] Verificando estructura de carpetas...")
dir_temp <- file.path("data", "temp")
dir_raw  <- file.path("data", "raw")
for (d in c(dir_temp, dir_raw)) {
  if (!dir.exists(d)) {
    dir.create(d, recursive = TRUE, showWarnings = FALSE)
    message("[paso 2] Carpeta creada: ", d)
  } else {
    message("[paso 2] Carpeta ya existe: ", d)
  }
}


# ------------------------------------------------------------------------------
# 3. FUNCIONES AUXILIARES
# ------------------------------------------------------------------------------

# 3.1 Nombre de archivo -> "AAAA_MM"  (ej. "Enero 2026.zip" -> "2026_01")
meses_es <- c(enero = 1, febrero = 2, marzo = 3, abril = 4, mayo = 5, junio = 6,
              julio = 7, agosto = 8, septiembre = 9, setiembre = 9,
              octubre = 10, noviembre = 11, diciembre = 12)

nombre_a_periodo <- function(nombre_archivo) {
  base <- tolower(tools::file_path_sans_ext(basename(nombre_archivo)))
  base <- iconv(base, to = "ASCII//TRANSLIT")           # quita tildes
  base <- ifelse(is.na(base), tolower(tools::file_path_sans_ext(nombre_archivo)), base)

  anio <- regmatches(base, regexpr("(19|20)[0-9]{2}", base))
  mes  <- NA_integer_
  for (m in names(meses_es)) {
    if (grepl(m, base, fixed = TRUE)) { mes <- meses_es[[m]]; break }
  }
  if (length(anio) == 1 && !is.na(mes)) {
    return(sprintf("%s_%02d", anio, mes))
  }
  # Plan B: nombre limpio, con aviso
  alterno <- gsub("[^A-Za-z0-9]+", "_", tools::file_path_sans_ext(basename(nombre_archivo)))
  warning("No se pudo deducir año_mes de '", nombre_archivo,
          "'. Se usará la carpeta: ", alterno, call. = FALSE)
  alterno
}

# 3.2 Extracción
buscar_7z <- function() {
  ruta <- Sys.which(c("7z", "7za", "7zz"))
  ruta <- ruta[nzchar(ruta)]
  if (length(ruta) > 0) unname(ruta[1]) else ""
}

extraer_archivo <- function(ruta, destino) {
  ext <- tolower(tools::file_ext(ruta))
  dir.create(destino, recursive = TRUE, showWarnings = FALSE)
  ok <- FALSE

  if (ext == "zip") {
    ok <- tryCatch({ utils::unzip(ruta, exdir = destino); TRUE },
                   error = function(e) FALSE,
                   warning = function(w) length(list.files(destino, recursive = TRUE)) > 0)
  }
  if (!ok && ext == "rar" && nzchar(Sys.which("unrar"))) {
    st <- system2("unrar", c("x", "-o+", "-y", shQuote(ruta), shQuote(paste0(destino, "/"))),
                  stdout = FALSE, stderr = FALSE)
    ok <- identical(st, 0L)
  }
  if (!ok) {
    z7 <- buscar_7z()
    if (nzchar(z7)) {
      st <- system2(z7, c("x", shQuote(ruta), paste0("-o", shQuote(destino)), "-y"),
                    stdout = FALSE, stderr = FALSE)
      ok <- identical(st, 0L)
    }
  }
  if (!ok && tiene_archive) {
    ok <- tryCatch({ archive::archive_extract(ruta, dir = destino); TRUE },
                   error = function(e) FALSE)
  }
  if (!ok) {
    stop("No se pudo descomprimir '", basename(ruta), "'.\n",
         "  Instala: sudo apt install unrar p7zip-full p7zip-rar")
  }
  invisible(TRUE)
}

# 3.3 Aplanar carpetas contenedoras únicas (evita carpeta/carpeta)
aplanar_contenedores <- function(dir) {
  repeat {
    items <- list.files(dir, all.files = TRUE, no.. = TRUE, full.names = TRUE)
    items <- items[!basename(items) %in% c("__MACOSX", ".DS_Store")]
    if (length(items) == 1 && dir.exists(items)) {
      message("[paso 3]   Carpeta contenedora '", basename(items), "' -> se aplana")
      tmp <- file.path(dir, paste0(".__colapsando_", as.integer(Sys.time())))
      file.rename(items, tmp)
      hijos <- list.files(tmp, all.files = TRUE, no.. = TRUE, full.names = TRUE)
      file.rename(hijos, file.path(dir, basename(hijos)))
      unlink(tmp, recursive = TRUE, force = TRUE)
    } else break
  }
  invisible(dir)
}

# 3.4 Comprimidos anidados
extraer_anidados <- function(dir, nivel = 1) {
  if (nivel > max_niveles_anid) return(invisible(NULL))
  anidados <- list.files(dir, pattern = "\\.(zip|rar)$", recursive = TRUE,
                         full.names = TRUE, ignore.case = TRUE)
  anidados <- anidados[!grepl("__MACOSX", anidados, fixed = TRUE)]
  if (length(anidados) == 0) return(invisible(NULL))
  for (a in anidados) {
    message("[paso 3]   Comprimido anidado: ", basename(a))
    destino_a <- file.path(dirname(a), tools::file_path_sans_ext(basename(a)))
    extraer_archivo(a, destino_a)
    file.remove(a)
    aplanar_contenedores(destino_a)
  }
  extraer_anidados(dir, nivel + 1)
}


# ------------------------------------------------------------------------------
# 4. PROCESAMIENTO DE UN ARCHIVO (descomprimir -> buscar -> copiar a año_mes)
# ------------------------------------------------------------------------------
procesar_archivo <- function(nombre_archivo) {
  message("\n--------------------------------------------------------------")
  message("[archivo] Procesando: ", nombre_archivo)

  ruta_archivo <- file.path(dir_descargas, nombre_archivo)
  if (!file.exists(ruta_archivo)) stop("No existe: ", ruta_archivo)
  message("[archivo] Encontrado (", round(file.size(ruta_archivo) / 1024^2, 1), " MB)")

  periodo     <- nombre_a_periodo(nombre_archivo)
  dir_periodo <- file.path(dir_raw, periodo)
  dir_staging <- file.path(dir_temp, periodo)
  message("[archivo] Período detectado: ", periodo, " -> destino: ", dir_periodo)

  # Descompresión
  if (dir.exists(dir_staging)) unlink(dir_staging, recursive = TRUE, force = TRUE)
  message("[paso 3] Descomprimiendo en ", dir_staging, "...")
  extraer_archivo(ruta_archivo, dir_staging)
  aplanar_contenedores(dir_staging)
  extraer_anidados(dir_staging)
  message("[paso 3] Archivos extraídos: ", length(list.files(dir_staging, recursive = TRUE)))

  # Búsqueda recursiva
  patron <- paste0("\\.(", paste(extensiones_datos, collapse = "|"), ")$")
  encontrados <- list.files(dir_staging, pattern = patron, recursive = TRUE,
                            full.names = TRUE, ignore.case = TRUE)
  encontrados <- encontrados[!grepl("__MACOSX", encontrados, fixed = TRUE) &
                               !startsWith(basename(encontrados), "._")]
  if (length(encontrados) == 0) stop("No se hallaron archivos de datos en ", dir_staging)
  message("[paso 4] Archivos de datos encontrados: ", length(encontrados))

  # Copia a data/raw/AAAA_MM
  dir.create(dir_periodo, recursive = TRUE, showWarnings = FALSE)
  usados <- character(0)
  copiados <- 0L
  for (f in encontrados) {
    nombre <- basename(f)
    if (tolower(nombre) %in% tolower(usados)) {
      nombre <- paste0(basename(dirname(f)), "__", nombre)
      message("[paso 4]   Nombre repetido, se renombra: ", nombre)
    }
    usados <- c(usados, nombre)
    if (file.copy(f, file.path(dir_periodo, nombre), overwrite = TRUE)) {
      copiados <- copiados + 1L
      message("[paso 4]   Copiado: ", nombre)
    } else {
      warning("No se pudo copiar: ", f, call. = FALSE)
    }
  }

  if (limpiar_temp) {
    unlink(dir_staging, recursive = TRUE, force = TRUE)
    message("[paso 4] Temporal limpiado: ", dir_staging)
  }
  message("[archivo] OK: ", copiados, " archivo(s) en ", dir_periodo)

  data.frame(archivo = nombre_archivo, periodo = periodo,
             n_archivos = copiados, estado = "OK", detalle = "",
             stringsAsFactors = FALSE)
}


# ------------------------------------------------------------------------------
# 5. EJECUCIÓN SOBRE TODOS LOS ARCHIVOS (un error no detiene a los demás)
# ------------------------------------------------------------------------------
resultados <- lapply(nombres_archivos, function(nm) {
  tryCatch(
    procesar_archivo(nm),
    error = function(e) {
      message("[ERROR] ", nm, ": ", conditionMessage(e))
      data.frame(archivo = nm, periodo = NA_character_, n_archivos = 0L,
                 estado = "ERROR", detalle = conditionMessage(e),
                 stringsAsFactors = FALSE)
    }
  )
})
resumen_ingesta <- do.call(rbind, resultados)

message("\n==============================================================")
message(" RESUMEN DE INGESTA")
message("==============================================================")
print(resumen_ingesta[, c("archivo", "periodo", "n_archivos", "estado")], row.names = FALSE)
message("OK: ", sum(resumen_ingesta$estado == "OK"), " | Con error: ",
        sum(resumen_ingesta$estado == "ERROR"))
message("Datos en: ", normalizePath(dir_raw))


# ------------------------------------------------------------------------------
# 6. BLOQUE DE ANÁLISIS BASE
# ------------------------------------------------------------------------------

# 6.1 Períodos disponibles en data/raw
listar_periodos <- function() sort(list.dirs(dir_raw, recursive = FALSE, full.names = FALSE))

# 6.2 Lectura según extensión
leer_geih <- function(ruta) {
  ext <- tolower(tools::file_ext(ruta))
  message("[lectura] ", basename(ruta))
  df <- switch(
    ext,
    csv = , txt = data.table::fread(ruta, sep = "auto", dec = ",",
                                    encoding = "UTF-8", data.table = FALSE),
    dta = haven::read_dta(ruta),
    sav = haven::read_sav(ruta),
    stop("Extensión no soportada: ", ext)
  )
  as.data.frame(df)
}

# 6.3 Estandarización
estandarizar_geih <- function(df) {
  names(df) <- tolower(trimws(gsub("[^A-Za-z0-9_]+", "_", names(df))))
  for (col in grep("^fex", names(df), value = TRUE)) {
    if (!is.numeric(df[[col]])) df[[col]] <- as.numeric(gsub(",", ".", as.character(df[[col]])))
  }
  df
}

# 6.4 Leer un módulo (por parte del nombre) en uno o varios períodos y apilarlos
#     Ej.: leer_modulo("Ocupados", periodos = c("2026_01", "2026_02"))
leer_modulo <- function(patron, periodos = listar_periodos()) {
  piezas <- lapply(periodos, function(p) {
    archivos <- list.files(file.path(dir_raw, p), pattern = patron,
                           full.names = TRUE, ignore.case = TRUE)
    archivos <- archivos[grepl("\\.(csv|txt|dta|sav)$", archivos, ignore.case = TRUE)]
    if (length(archivos) == 0) {
      warning("Sin archivos '", patron, "' en ", p, call. = FALSE)
      return(NULL)
    }
    df <- estandarizar_geih(leer_geih(archivos[1]))
    df$periodo <- p
    df
  })
  data.table::rbindlist(piezas, fill = TRUE, use.names = TRUE) |> as.data.frame()
}

# 6.5 Estimación ponderada y coeficiente de variación
# NOTA: con ids = ~1 el error estándar es una aproximación (muestreo simple).
# Para un CV oficial declara estratos/conglomerados según la metodología del DANE.
calcular_cv <- function(df, variable, peso, por = NULL, tipo = c("total", "media")) {
  tipo <- match.arg(tipo)
  cargar_paquete("survey")
  diseno <- survey::svydesign(ids = ~1, data = df,
                              weights = stats::as.formula(paste0("~", peso)))
  f_var <- stats::as.formula(paste0("~", variable))
  fun   <- if (tipo == "total") survey::svytotal else survey::svymean

  if (is.null(por)) {
    est <- fun(f_var, diseno, na.rm = TRUE)
    data.frame(estimacion = as.numeric(coef(est)),
               error_est  = as.numeric(survey::SE(est)),
               cv_pct     = as.numeric(survey::cv(est)) * 100)
  } else {
    est <- survey::svyby(f_var, stats::as.formula(paste0("~", por)),
                         diseno, fun, na.rm = TRUE, vartype = c("se", "cv"))
    est$cv <- est$cv * 100
    est
  }
}

# 6.6 Flujo de ejemplo (descomenta y ajusta)
# listar_periodos()
# ocupados <- leer_modulo("Ocupados", periodos = c("2026_01", "2026_02"))
# fex <- grep("^fex", names(ocupados), value = TRUE)[1]
# calcular_cv(ocupados, variable = "p6500", peso = fex, por = "periodo", tipo = "media")
