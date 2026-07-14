# Workspace de manuscrito — tesis ES

## Propósito

Esta carpeta contiene la versión editable de la sección de resultados para tesis. La evidencia computacional original permanece en `05_runs`.

## Regla de uso

- `05_runs` = evidencia, trazabilidad, resultados congelados.
- `06_manuscript/thesis_ES` = escritura final editable.
- `02_src_limpio/production` = scripts, no manuscrito.

## Archivo principal a editar

`sections/01_resultados_optimizacion_triobjetivo_v1.md`

## Figuras

- `figures/png/Figura_1_frente_triobjetivo_hibrido.png`
- `figures/png/Figura_2_gasLP_vs_H2.png`
- `figures/png/Figura_3_espacio_operativo_hibrido.png`
- También están disponibles en PDF dentro de `figures/pdf/`.

## Tablas

- `tables/resultados_valores_principales.csv`
- `tables/figuras_finales.csv`
- `tables/soluciones_clave_H1_H2_H4_H9.csv`
- `tables/checks_seccion_resultados.csv`

## Trazabilidad

La carpeta `traceability/` contiene el MAT y reporte de cierre del paso `9.6v-ES`.

## Resultado principal

Solución recomendada: H2.

- MR H2: 0.0473145515233
- Costo específico H2: 0.279041996361
- CO2 específico H2: 1.1843914651
- Reducción MR vs gas LP: 50.7184488784 %
- Reducción costo vs gas LP: 26.155451487 %
- Reducción CO2 vs gas LP: 29.5437037514 %

## Advertencias metodológicas

- CO2 sigue como comparación preliminar hasta fijar factores de emisión definitivos.
- El modo solar puro queda fuera del frente formal y requiere formulación de ventana solar.
