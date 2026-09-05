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

## D012 — HB200 como procedencia histórica principal

**Decisión:** adoptar `HB200` como baseline histórico principal de época de tesis para la arquitectura científica del artículo Q1.

```text
PRIMARY_THESIS_LEGACY_BASELINE = HB200
HB306_STATUS = RECOVERED_LATER_CHECKPOINT_PROVENANCE_UNRESOLVED
HB306_EQUIVALENT_TO_THESIS_GENERATION_316 = NOT_PROVEN
R1_50GEN_ROLE = AUXILIARY_REPRODUCIBILITY_CONTROL
```

**Justificación:** HB200 posee la procedencia más fuerte respecto del compromiso publicado en la tesis y la campaña posterior reportada lo reevaluó determinísticamente bajo el modelo y objetivos actuales. La existencia de `HB306` no permite certificar continuidad desde HB200 ni equivalencia con la generación 316 documentada en la tesis.

**Límite probatorio actual:** los nuevos artefactos HB200 no están montados en el contexto activo; por ello, los números de la campaña permanecen como resultados reportados pendientes de registro/hash canónico.

**Estado:** vigente.

## D013 — Separación entre protocolo R1-50gen v1.0 y rediseño HB200-v04

**Decisión:** conservar `CORRECTED_R1_COMPARATIVE_PROTOCOL_v96z.md` v1.0 como protocolo congelado histórico de la comparación `H(9)-vs-C(9)`. No se reescribe retrospectivamente para incorporar HB200.

La arquitectura posterior para v04 se tratará como rediseño científico separado:

```text
Gas-LPG context
-> thesis-era HB200 physical designs
-> deterministic common-basis reevaluation
-> frozen current C portfolio
-> paired recirculation-timing insight
```

El `R1` de 50 generaciones se conserva únicamente como control auxiliar reproducible.

**Estado:** vigente.
