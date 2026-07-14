# KNOW 06.06H — HYBRID-IRR-001 Tipo D

## Propósito

Crear una versión dedicada exclusivamente a `HYBRID-IRR-001`.

## Diagnóstico confirmado

En:

```text
02_src_limpio/wrappers/opt_tunel_mod2_v06_data_controlled.m
```

aparece:

```matlab
I(i)=I_busc;
...
I(i)=0;
```

La segunda asignación anula la irradiancia interpolada antes de calcular `G`, `E_capt` e `Irradiacion`.

## Evidencia diagnóstica local

Punto operativo:

```text
m_max = 0.12
T_min = 50
r_div2 = 0
t_rec_ini = 0
W0 = 0.85
```

Resultado histórico v0.9:

```text
Q_aux_tot = 1234.608652
dry_time = 19.9
M = 2.439033823
MR = 0.3578232197
Irradiacion = 0
```

Resultado diagnóstico sin anulación:

```text
Q_aux_tot = 859.5652820963
dry_time = 19.9
M = 3.3487979280
MR = 0.1701299723
Irradiacion = 487.2805200000
```

## Clasificación

```text
HYBRID-IRR-001 | Tipo D — corrección computacional con cambio de resultados
```

Puede alterar:

```text
Fig. 20
Fig. 21
cualquier resultado híbrido
```

## Implementación

Se mantiene el wrapper histórico:

```text
02_src_limpio/wrappers/opt_tunel_mod2_v06_data_controlled.m
```

Se crea wrapper corregido:

```text
02_src_limpio/wrappers/opt_tunel_mod2_v10_energy_mode_corrected.m
```

Selector explícito:

```text
gasLP  -> I_effective = 0
hybrid -> I_effective = I_busc
solar  -> I_effective = I_busc
```

## Prueba A/B por modo

```text
02_src_limpio/validation/test_hybrid_irradiance_modes_v10.m
```

Reporta:

```text
mode
I_effective
Irradiacion
Q_aux_tot
dry_time
M
MR
```

## Restricciones

No se modifica costo.

No se corre AG.

No se declaran resultados finales.
