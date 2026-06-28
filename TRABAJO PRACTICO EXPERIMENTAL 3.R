# ==============================================================================
# TRABAJO PRÁCTICO EXPERIMENTAL #3 - ECONOMETRÍA APLICADA
# Modelos de Series de Tiempo Multivariantes (IPC vs M2) 
# Período de Análisis: 2020 - 2026
# ==============================================================================

# 1. PREPARACIÓN, CARGA DE DATOS Y LIBRERÍAS
# ------------------------------------------------------------------------------
library(urca)       # Test de Johansen 
library(vars)       # Estimación VAR/VEC, IRF y FEVD 
library(tseries)    # Test Dickey-Fuller Aumentada (ADF)
library(tidyverse)  # Manipulación de datos y gráficos
library(flextable)  # Tablas con formato APA 7

# Importar dataset
ruta_archivo <- "C:/Users/GRACE/OneDrive/Documentos/datos_bce_mensual.csv"
datos_bce <- read.csv(ruta_archivo)

# Transformar a objetos de series de tiempo (Frecuencia mensual)
ipc_ts <- ts(datos_bce$IPC_Indice, start = c(2020, 1), frequency = 12)
m2_ts  <- ts(datos_bce$M2_Millones, start = c(2020, 1), frequency = 12)

# Matriz conjunta para análisis multivariante
pre_matriz <- cbind(ipc_ts, m2_ts)
colnames(pre_matriz) <- c("IPC", "M2")

# 2. ANÁLISIS DE ESTACIONARIEDAD (TEST ADF)
# ------------------------------------------------------------------------------
plot(pre_matriz, main = "Series Macroeconómicas en Niveles Originales (BCE)", 
     col = "darkblue", lwd = 2, xlab = "Tiempo")

print("--- TEST ADF EN NIVELES ---")
print(adf.test(ipc_ts))
print(adf.test(m2_ts))

print("--- TEST ADF EN PRIMERAS DIFERENCIAS ---")
print(adf.test(diff(ipc_ts)))
print(adf.test(diff(m2_ts)))

plot(diff(pre_matriz), main = "Series Macroeconómicas en Primeras Diferencias", 
     col = "darkred", lwd = 1.5, xlab = "Tiempo")

# 3. ANÁLISIS DE COINTEGRACIÓN DE JOHANSEN 
# ------------------------------------------------------------------------------
print("--- CRITERIOS DE SELECCIÓN DE REZAGOS ---")
seleccion_p <- VARselect(pre_matriz, lag.max = 6, type = "const")
print(seleccion_p$selection)

test_johansen <- ca.jo(pre_matriz, type = "trace", ecdet = "const", K = 2)
print("--- RESULTADOS DEL TEST DE JOHANSEN ---")
summary(test_johansen)

# 4. ESTIMACIÓN DEL MODELO DE CORRECCIÓN DE ERRORES (VEC)
# ------------------------------------------------------------------------------
print("--- ESTIMACIÓN DEL MODELO VEC (RUTA B - r = 1) ---")
modelo_final_vec <- vec2var(test_johansen, r = 1)
summary(modelo_final_vec)

# 5. DIAGNÓSTICO DE LOS RESIDUOS
# ------------------------------------------------------------------------------
print("--- TEST DE AUTOCORRELACIÓN BRUERSCH-GODFREY ---")
print(serial.test(modelo_final_vec, lags.pt = 12, type = "PT.asymptotic"))

print("--- TEST DE HETEROCEDASTICIDAD ARCH ---")
print(arch.test(modelo_final_vec, lags.single = 4))

print("--- TEST DE NORMALIDAD ---")
print(normality.test(modelo_final_vec))

# 6. ANÁLISIS DE POLÍTICA (IRF Y FEVD) EN VENTANAS EXTERNAS
# ------------------------------------------------------------------------------
irf_m2_hacia_ipc <- irf(modelo_final_vec, impulse = "M2", response = "IPC",
                        n.ahead = 16, boot = TRUE, ci = 0.95)

windows()
plot(irf_m2_hacia_ipc, main = "Respuesta del IPC ante un shock en M2 (Modelo VEC)",
     ylab = "IPC", xlab = "Meses posteriores al shock")

print("--- DESCOMPOSICIÓN DE VARIANZA (FEVD) ---")
fevd_resultado <- fevd(modelo_final_vec, n.ahead = 16)
print(fevd_resultado)

tabla_ipc_viewer <- as.data.frame(fevd_resultado$IPC) * 100
View(tabla_ipc_viewer)

# 7. FORMATEO Y EXPORTACIÓN DE TABLA A FORMATO APA 7
# ------------------------------------------------------------------------------
datos_tabla <- data.frame(
  Periodo = c(1, 2, 4, 8, 12, 16),
  IPC = c(100.00, 99.93, 99.90, 99.78, 99.62, 99.38),
  M2 = c(0.00, 0.07, 0.10, 0.22, 0.38, 0.62)
)

tabla_apa <- flextable(datos_tabla)
tabla_apa <- set_header_labels(tabla_apa,
                               Periodo = "Período (Mes)", 
                               IPC = "Variabilidad explicada por el IPC (%)", 
                               M2 = "Variabilidad explicada por la Masa Monetaria M2 (%)"
)
tabla_apa <- theme_apa(tabla_apa)
tabla_apa <- align(tabla_apa, align = "center", part = "all")
tabla_apa <- autofit(tabla_apa)

tabla_apa

save_as_docx(tabla_apa, path = "tabla_fevd_apa.docx")