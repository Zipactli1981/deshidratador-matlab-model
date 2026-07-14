# SEED_CONTROLLED_REPLICATION_RUNNER_RUNPREP_v96z_minrep

## Dictamen

Se creó un runner de réplicas con control explícito de semilla. Este paso no ejecutó GA. La ejecución real permanece bloqueada hasta preflight y aprobación.

## Runner base auditado

- Runner base: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_guarded_triobjective_formal_ga_v96m.m`
- Contiene `rng(`: `true`
- Contiene `gamultiobj`: `true`

## Runner creado

- Runner seed-controlled: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_seed_controlled_minrep_formal_ga_v96z_minrep.m`
- Approval gate: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\approve_seed_controlled_minrep_execution_v96z_minrep.m`
- Comandos: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\protocols\APPROVED_COMMANDS_MINREP_RUNNER_v96z_minrep_runprep.md`

## Réplicas

| Replicate | Seed | PopulationSize | MaxGenerations | Expected runtime [h] |
|---|---:|---:|---:|---:|
| R1 | 61001 | 24 | 50 | 7.13 |
| R2 | 61002 | 24 | 50 | 7.13 |
| R3 | 61003 | 24 | 50 | 7.13 |

Tiempo total esperado: `21.39 h`.

## Criterios de aceptación

| ID | Criterion | Rule | Importance |
|---|---|---|---|
| C1 | Cada réplica debe completar sin error. | `run_status == OK` | critical |
| C2 | Cada réplica debe producir filas finitas. | `nFiniteRows > 0` | critical |
| C3 | Debe existir al menos una solución admisible por MR en cada réplica. | `any(MR < 0.1)` | critical |
| C4 | Debe aparecer una solución tipo H2 o equivalente en al menos 2 de 3 réplicas. | `at least 2/3 replicates with admissible compromise solution` | critical |
| C5 | La solución tipo H2 debe reducir costo específico frente a gas LP. | `cost_reduction_pct_vs_gasLP > 0` | high |
| C6 | La solución tipo H2 debe reducir CO2 específico frente a gas LP. | `CO2_reduction_pct_vs_gasLP > 0` | high |
| C7 | La solución tipo H2 debe cumplir MR < 0.1. | `MR < 0.1` | critical |
| C8 | No se debe afirmar óptimo global aunque las réplicas sean consistentes. | `Use robust compromise wording, not global optimum wording.` | critical |

## H2 equivalent

| Metric | Definition |
|---|---|
| MR | Must satisfy MR < 0.1. |
| cost_specific | Must be lower than gasLP reference, or within accepted trade-off if CO2/MR strongly improve. |
| CO2_specific | Must be lower than gasLP reference while CO2 factors remain fixed. |
| dominance_vs_gasLP | Preferred: simultaneous improvement in MR, cost and CO2 vs gasLP. |
| role_in_front | Compromise solution, not necessarily minMR, minCost or minCO2. |
| selection_basis | Selected from admissible front by normalized balance score or equivalent compromise criterion. |

## Secuencia correcta

1. Ejecutar preflight:

```matlab
pre = run_seed_controlled_minrep_formal_ga_v96z_minrep(false);
```

2. Ejecutar approval gate:

```matlab
approval = approve_seed_controlled_minrep_execution_v96z_minrep();
```

3. Solo si ambos pasan, ejecutar:

```matlab
minrepRun = run_seed_controlled_minrep_formal_ga_v96z_minrep(true);
```
