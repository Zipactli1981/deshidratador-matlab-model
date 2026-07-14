# KNOW 06.06D — Cierre estricto DATA-B-001

## Propósito

Cerrar `DATA-B-001` de forma estricta, sin depender únicamente del path de MATLAB para resolver:

```matlab
load('Mapeo4_temp100621.txt')
```

## Archivo controlado nuevo

```text
02_src_limpio/wrappers/opt_tunel_mod2_v06_data_controlled.m
```

Este archivo se deriva de:

```text
03_original_model/01_active_original/opt_tunel_mod2.mlx
```

## Cambio aplicado

Las cargas ambientales por nombre relativo se sustituyen por:

```matlab
data = load_environmental_data_original('Mapeo4_temp100621.txt');
```

o equivalente según el archivo `Mapeo*_temp100621.txt` detectado.

## Loader

```text
03_original_model/03_utilities/load_environmental_data_original.m
```

Carga desde:

```text
03_original_model/04_data_original/
```

## Prueba mínima

`test_case_base_v06_minimal.m` ahora llama:

```matlab
opt_tunel_mod2_v06_data_controlled(...)
```

con una sola combinación:

```text
m_max = 0.11
T_min = 50 °C
r_div2 = 0
t_rec_ini = 3 h
```

## Restricciones

No se tocó:

```text
HYBRID-IRR-001
costos
cinética
física
run_opt_GA.mlx
figuras finales del artículo
```

## Clasificación

```text
DATA-B-001 | Tipo B — trazabilidad de datos | ¿Cambia resultados?: No, si el archivo cargado es el mismo | Estado: Cerrado estrictamente
```
