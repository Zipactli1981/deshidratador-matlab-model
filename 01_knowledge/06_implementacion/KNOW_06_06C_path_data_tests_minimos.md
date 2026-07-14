# KNOW 06.06C — PATH, DATA y pruebas mínimas

## Propósito

Cerrar primero tres asuntos operativos antes de tocar costo o irradiancia:

```text
PATH-B-001
DATA-B-001
TEST-B-002
```

## Cambios

### PATH-B-001

`setup_v05_paths.m` agrega explícitamente:

```text
03_original_model/04_data_original
```

Esto evita depender manualmente de `addpath(data_original)`.

### DATA-B-001

La resolución temporal del usuario mediante `addpath(data_original)` se integra al setup.

También se conserva la utilidad:

```text
03_original_model/03_utilities/load_environmental_data_original.m
```

para una futura sustitución explícita de `load('Mapeo4_temp100621.txt')` dentro del modelo, si se decide editar el `.mlx`.

### TEST-B-002

`test_case_base_v05.m` inicializa de forma robusta:

```matlab
test_status.errors = {};
test_status.warnings = {};
```

antes de cualquier `catch` o escritura.

### TEST-B-003

Se crea:

```text
02_src_limpio/validation/test_case_base_v06_minimal.m
```

Este test llama directamente una sola vez a `opt_tunel_mod2` con:

```text
m_max = 0.11
T_min = 50 °C
r_div2 = 0
t_rec_ini = 3 h
```

y reporta:

```text
Q_aux_tot
dry_time
M
MR
Irradiacion
```

## Restricción

No se toca `HYBRID-IRR-001`.

No se toca la fórmula de costo.

No se corre AG completo.

No se declaran Fig. 17, Fig. 20 ni Fig. 21 como resultados finales.
