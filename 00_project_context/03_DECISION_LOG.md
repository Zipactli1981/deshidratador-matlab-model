# DECISION LOG — Deshidratador MATLAB / Q1

## D001 — Alcance físico
Mantener calentamiento directo de aire; circuito de agua y bombas fuera del alcance.

## D002 — Potencia eléctrica
Usar 1.03 kW medidos para el impulsor/ventilador durante todo el tiempo de secado.

## D003 — Eficiencia de quemador
`eta_burner = 0.78`; energía GLP = `Q_aux_tot / 0.78`.

## D004 — Denominador de f2/f3
Usar:
```text
water_removed_kg = (Mi - M_terminal) * md
```
El mismo denominador se usa para costo y emisiones específicas.

## D005 — Comparabilidad CORRECTED_R1
Conservar la configuración histórica explícita:
```text
seed 61001
PopulationSize 24
MaxGenerations 50
hybrid
gasLP reference
formal v96l bounds
```

## D006 — Build histórico
El build exacto histórico permanece desconocido; la incertidumbre se clasifica como documental no material:
```text
FULL_SOLVER_DEFAULTS_AUDIT =
PASS_WITH_DOCUMENTARY_BUILD_LIMITATION
```

## D007 — Puntos históricos reevaluados
Son muestras históricas reevaluadas bajo COST-E3D, no un frente Pareto corregido.

## D008 — CORRECTED_R1 postrun
La corrida está internamente validada, pero la interpretación científica queda pendiente de revisión comparativa.

## D009 — Diseño del protocolo comparativo

**Estado:** SUPERSEDED_BY_D010.

La decisión original era diseñar primero el protocolo comparativo antes de ejecutar cálculos.

## D010 — Protocolo comparativo v1.0 congelado

**Decisión:** adoptar `CORRECTED_R1 COMPARATIVE PROTOCOL v96z`, versión `v1.0`, con estado:

```text
FROZEN_APPROVED_FOR_POSTRUN_COMPARATIVE_IMPLEMENTATION
```

La arquitectura congelada incluye:
1. dataset de 18 soluciones;
2. auditoría interna exacta de H y C;
3. análisis descriptivo;
4. matriz cruzada 9x9;
5. diagnóstico near-tie separado;
6. set coverage completo y de núcleos;
7. nondominated sorting conjunto;
8. geometría del espacio objetivo;
9. gate condicional de hypervolume;
10. régimen terminal;
11. descomposición de f2/f3;
12. interpretación física/económica/ambiental;
13. implicaciones posteriores para manuscrito.

**Estado:** vigente.

## D011 — Metodología aprobada ≠ ejecución autorizada

**Decisión:** el congelamiento del protocolo no autoriza por sí mismo ejecutar MATLAB, Codex, `gamultiobj` ni scripts comparativos.

Cada implementación operativa CR1-COMP requiere autorización separada.

**Estado:** vigente.

## D012 — Recuperación documental de H.f2/f3 corregidos

**Decisión:** aceptar explícitamente bajo `CR1-COMP-01-D1` la recuperación documental de `H.f2/f3` corregidos desde la única fuente persistida validada:

```text
06_manuscript/article_Q1/review/COST_E3D_R2G_EXISTING_R1_REEVALUATION_MEMO_v96z.md
SHA-256 = 7C025689D5832CBA9ECB8D90E9A4A5D5E911A46B0109C6D1C270E19E7E8EBFB2
NUMERIC_REPRESENTATION = VALIDATED_17_SIGNIFICANT_DIGIT_DECIMAL_SERIALIZATION
```

La búsqueda exhaustiva determinó que no se persistió un MAT con los `double` corregidos. La excepción se limita al requisito de persistencia/precisión de `H.f2/f3`: los bits binary64 originales no están disponibles y su identidad no puede verificarse independientemente. `H.X` y `H.f1` conservan como fuente primaria el MAT histórico; la reevaluación documentó reproducción de `f1` en las nueve filas.

No se autoriza replay ni nueva evaluación del objective. No cambia la definición exacta de dominancia ni ninguna otra regla del protocolo comparativo v1.0.

**Estado:** VIGENTE.
