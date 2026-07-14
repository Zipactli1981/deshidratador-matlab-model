# MINIMAL_SEED_REPLICATION_DESIGN_v96z_minrep

## Dictamen

El artículo Q1 requiere validación adicional. La corrida formal actual se conserva como corrida base, pero no debe usarse sola para sostener afirmaciones fuertes de robustez algorítmica.

La auditoría previa determinó: `RESULTS_SUFFICIENT_FOR_THESIS_WITH_CONDITIONAL_SCOPE`. En particular, permitió reportar H2 como solución de compromiso dentro del frente obtenido, pero bloqueó afirmar óptimo global o convergencia plena.

## Diseño de réplicas

| Réplica | Semilla | PopulationSize | MaxGenerations | Runtime esperado [h] |
|---|---:|---:|---:|---:|
| R1 | 61001 | 24 | 50 | 7.13 |
| R2 | 61002 | 24 | 50 | 7.13 |
| R3 | 61003 | 24 | 50 | 7.13 |

Tiempo adicional estimado: `21.39 h`.

## Criterios de aceptación

| ID | Criterio | Regla | Importancia |
|---|---|---|---|
| C1 | Cada réplica debe completar sin error. | `run_status == OK` | critical |
| C2 | Cada réplica debe producir filas finitas. | `nFiniteRows > 0` | critical |
| C3 | Debe existir al menos una solución admisible por MR en cada réplica. | `any(MR < 0.1)` | critical |
| C4 | Debe aparecer una solución tipo H2 o equivalente en al menos 2 de 3 réplicas. | `at least 2/3 replicates with admissible compromise solution` | critical |
| C5 | La solución tipo H2 debe reducir costo específico frente a gas LP. | `cost_reduction_pct_vs_gasLP > 0` | high |
| C6 | La solución tipo H2 debe reducir CO2 específico frente a gas LP. | `CO2_reduction_pct_vs_gasLP > 0` | high |
| C7 | La solución tipo H2 debe cumplir MR < 0.1. | `MR < 0.1` | critical |
| C8 | No se debe afirmar óptimo global aunque las réplicas sean consistentes. | `Use robust compromise wording, not global optimum wording.` | critical |

## Solución equivalente a H2

| Métrica | Definición |
|---|---|
| MR | Must satisfy MR < 0.1. |
| cost_specific | Must be lower than gasLP reference, or within accepted trade-off if CO2/MR strongly improve. |
| CO2_specific | Must be lower than gasLP reference while CO2 factors remain fixed. |
| dominance_vs_gasLP | Preferred: simultaneous improvement in MR, cost and CO2 vs gasLP. |
| role_in_front | Compromise solution, not necessarily minMR, minCost or minCO2. |
| selection_basis | Selected from admissible front by normalized balance score or equivalent compromise criterion. |

## Decisiones

| Item | Valor |
|---|---|
| Current Q1 readiness | Current results are a valid base but not sufficient for a strong Q1 article. |
| Minimum required action | Run three additional seed replicates with same GA configuration. |
| Execution cost | Expected total additional runtime: 21.39 h |
| Main risk | Equivalent compromise solution may shift due to stochastic GA behavior. |
| Recommended claim after successful replication | H2-like compromise behavior is robust across independent seeds. |
| Still forbidden after successful replication | Do not claim global optimum or full convergence proof. |
| If replication fails | Report current result as preliminary and redesign GA parameter sensitivity. |
| CO2 dependency | CO2 claims remain dependent on definitive emission factors. |

## Siguiente paso

`9.6z-minrep-runprep — CREATE-SEED-CONTROLLED-REPLICATION-RUNNER-001`

Ese paso debe crear un corredor de réplicas con semilla explícita y modo seguro, todavía sin ejecución automática hasta aprobación.
