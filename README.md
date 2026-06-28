# Código en R: Masa monetaria e inflación en Ecuador (2020-2026)

En este repositorio dejé los archivos y el código que usé para revisar si la cantidad de dinero en circulación (M2) realmente afecta al Índice de Precios al Consumidor (IPC) en Ecuador. La idea era ver si la teoría económica clásica funciona en un país dolarizado, especialmente con los cambios que hubo después de la pandemia.

## ¿Qué hay aquí dentro?

* **script_modelo_vec.R:** Mi script de RStudio. Tiene todo el proceso: pruebas ADF, cointegración de Johansen, chequeo de residuos, la IRF y la FEVD.
* **datos_bce_mensual.csv:** Los datos mensuales que bajé de la página del Banco Central del Ecuador (BCE).
* **grafico_irf.png:** El gráfico final de la función impulso-respuesta.

## Librerías necesarias
Para correr el código en R necesitas estos paquetes: `urca`, `vars`, `tseries`, `tidyverse` y `flextable`.

## Lo que se encuentra en el análisis

Las series originales resultaron ser no estacionarias, así que les saqué la primera diferencia para estabilizarlas. Como el test de Johansen marcó que había cointegración, el modelo VEC fue la mejor opción para la estimación.

El dato clave apareció en la descomposición de varianza (FEVD). Resulta que la inflación en Ecuador se explica casi por completo por su propia inercia y arrastre histórico (un 99%). En cambio, los movimientos en la masa monetaria (M2) no llegan a pesar ni el 1% en el largo plazo. Esto demuestra que estar dolarizados cambia las reglas: el dinero se vuelve endógeno y se adapta a la economía, en lugar de ser el causante directo de la inflación.
