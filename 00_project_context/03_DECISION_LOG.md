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

## D014 — Campaña nueva de región operativa robusta: freeze v01

**Estado:** FROZEN_DOCUMENTARY_PRE_EXECUTION, 2026-09-05.

Adoptar `06_manuscript/article_Q1/review/CURRENT_FORMULATION_ROBUST_OPERATING_REGION_PROTOCOL_v01.md`, SHA-256 `7259B0855CF2F835851EE46FF8B8845FCAA0A1E07852419C76731F7F82A82599`, como metodología vigente de una campaña NUEVA. No modifica D010/D013 ni el protocolo histórico H(9)–C(9) v1.0. Los límites documentales de D012 describían aquel momento; el paquete HB200 fue posteriormente registrado/publicado en `0e1233041e36dc0bf01ab314def3baf9e1c8faa0`, confirmado en origin/main; 25 hashes compactos/arneses coinciden con ARTIFACT_INDEX.

Roles: HB200 baseline histórico principal trazable; C piloto congelado de formulación actual; campaña nueva búsqueda primaria multi-semilla. No frente global ni superioridad causal del optimizador.

Congelar cinco semillas 61001–61005, twister, PopulationSize=24, MaxGenerations=200, MaxStallGenerations=100, ejecución serial y demás opciones validadas. Dominio completo de cuatro variables del objective COST-E3D: lb=[0.07,45,0,0], ub=[0.20,70,0.99,19]. Inicialización independiente normal, sin HB200/C ni scores precargados.

Congelar universo final X/F + population/scores por corrida, exclusión auditada de penalizados, dominancia exacta y N_POOL sin benchmarks. Normalización común desde N_POOL; IGD+ empírico, HV común r=(1.10,1.10,1.10), coverage/contribuciones y extremos. Suficiencia conjunta: 5/5 válidas, pool finito no penalizado, IGD+ max<=0.10/mediana<=0.05, minHV/maxHV>=0.90 y extremos dentro de 0.10 en >=4/5 corridas por objetivo. Rango nulo bloquea métricas, no permite epsilon ni sustituciones silenciosas.

Sólo con PASS seleccionar cuatro políticas: mínimos f1/f2/f3 y distancia ideal normalizada de pesos iguales, desempates deterministas. FAIL no autoriza ampliar presupuesto, reiniciar ni rescatar con warm start. Umbrales operativos, no prueba de convergencia global.

NEXT_GATE = ROBUST_OPERATING_REGION_IMPLEMENTATION. Freeze NO autoriza MATLAB, gamultiobj, nuevas evaluaciones/replays ni optimizaciones; tampoco edición de código productivo/manuscrito, staging, commit, push, PR o merge.
