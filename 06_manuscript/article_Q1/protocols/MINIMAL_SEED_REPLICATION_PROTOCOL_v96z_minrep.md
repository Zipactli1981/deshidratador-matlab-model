# MINIMAL_SEED_REPLICATION_PROTOCOL_v96z_minrep

## Purpose

Design a minimal independent-seed replication protocol for the formal hybrid triobjective GA. This is required to strengthen the robustness of the optimization results for a Q1 journal article.

## Replicate design

| Replicate | Seed | Mode | PopulationSize | MaxGenerations | Expected runtime [h] |
|---|---:|---|---:|---:|---:|
| R1 | 61001 | hybrid | 24 | 50 | 7.13 |
| R2 | 61002 | hybrid | 24 | 50 | 7.13 |
| R3 | 61003 | hybrid | 24 | 50 | 7.13 |

Expected total runtime: `21.39 h`.

## Acceptance criteria

| ID | Criterion | Acceptance rule | Importance |
|---|---|---|---|
| C1 | Cada réplica debe completar sin error. | `run_status == OK` | critical |
| C2 | Cada réplica debe producir filas finitas. | `nFiniteRows > 0` | critical |
| C3 | Debe existir al menos una solución admisible por MR en cada réplica. | `any(MR < 0.1)` | critical |
| C4 | Debe aparecer una solución tipo H2 o equivalente en al menos 2 de 3 réplicas. | `at least 2/3 replicates with admissible compromise solution` | critical |
| C5 | La solución tipo H2 debe reducir costo específico frente a gas LP. | `cost_reduction_pct_vs_gasLP > 0` | high |
| C6 | La solución tipo H2 debe reducir CO2 específico frente a gas LP. | `CO2_reduction_pct_vs_gasLP > 0` | high |
| C7 | La solución tipo H2 debe cumplir MR < 0.1. | `MR < 0.1` | critical |
| C8 | No se debe afirmar óptimo global aunque las réplicas sean consistentes. | `Use robust compromise wording, not global optimum wording.` | critical |

## H2-equivalent solution

| Metric | Definition |
|---|---|
| MR | Must satisfy MR < 0.1. |
| cost_specific | Must be lower than gasLP reference, or within accepted trade-off if CO2/MR strongly improve. |
| CO2_specific | Must be lower than gasLP reference while CO2 factors remain fixed. |
| dominance_vs_gasLP | Preferred: simultaneous improvement in MR, cost and CO2 vs gasLP. |
| role_in_front | Compromise solution, not necessarily minMR, minCost or minCO2. |
| selection_basis | Selected from admissible front by normalized balance score or equivalent compromise criterion. |

## Execution rule

Do not execute these replicates until a seed-controlled runner is created and approved. The existing formal runner must be checked to guarantee that each replicate uses the intended random seed.
