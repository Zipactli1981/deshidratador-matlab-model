# KNOW 06.07 — compare_operation_modes.m

## Propósito

Consolidar `compare_operation_modes.m` como comparación diagnóstica de modos de operación después del cierre de `HYBRID-IRR-001`, `MODE-ENERGY-001` y `AUD-HYBRID-B-002`.

## Archivo implementado

```text
02_src_limpio/comparison/compare_operation_modes.m
```

## Regla energética usada

```text
gasLP:
I_effective = 0
calor_aux = true

hybrid:
I_effective = I_busc
calor_aux = true

solar:
I_effective = I_busc
calor_aux = false
```

## Casos incluidos

```text
case_01_validated:
m_max = 0.12
T_min = 50
r_div2 = 0
t_rec_ini = 0
W0 = 0.85

case_02_robustness:
m_max = 0.11
T_min = 55
r_div2 = 0.5
t_rec_ini = 3
W0 = 200
```

## Resultado validado

```text
compare_operation_modes()
status = COMPARISON_ONLY_NO_GA
```

Todos los casos quedaron clasificados como `SECADO_INCOMPLETO`. Esto no invalida la prueba porque los puntos son diagnósticos de lógica energética, no puntos optimizados ni resultados productivos.

## Advertencia

No se deben usar estos resultados como Fig. 20 ni Fig. 21. Deben recalcularse las corridas productivas con la lógica corregida.

## Restricciones

```text
No se corrió AG.
No se modificó costo.
No se declaran resultados finales.
```
