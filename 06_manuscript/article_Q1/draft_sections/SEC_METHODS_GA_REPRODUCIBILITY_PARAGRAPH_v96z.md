# SEC_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_v96z

## Status

`DRAFT_READY_FOR_REVIEW`

## Micropaso

`9.6z-methods-c`

## Identifier

`SAVE-AND-AUDIT-METHODS-GA-REPRODUCIBILITY-PARAGRAPH-001`

## Intended master location

Methods section, after the optimization-problem formulation and before the presentation of selected operating points.

## Source table

- `R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z.md`
- `R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z.csv`
- `R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z_report.md`

## Manuscript text -- English

### Reproducibility configuration of the formal multiobjective run

The formal multiobjective optimization run used to generate the selected candidate solutions was configured as a controlled seed-aware execution of MATLAB's `gamultiobj` algorithm. The run, identified as R1, used a fixed random seed of 61001, a population size of 24 individuals, and a maximum generation limit of 50 generations. The algorithm terminated with `exitflag = 0`, corresponding to termination by the prescribed generation limit. Therefore, the resulting solution set is interpreted as a computed nondominated set obtained under the specified configuration, not as proof of global convergence or global optimality.

The optimization problem was formulated with three objectives: final moisture ratio, economic performance, and CO2 emissions. The decision variables were the air mass flow rate `m_dot`, the minimum control temperature `T_min`, the recirculation ratio `r_rec`, and the recirculation onset time `t_rec_ini`. Candidate feasibility was evaluated using the final moisture-ratio threshold MR <= 0.1. The formal run was performed for hybrid solar--gas-LPG operation; solar-only operation was not included in the formal multiobjective comparison because it represents a non-equivalent operating mode.

The R1 run required approximately 25.4 h of wall-clock computation. The selected operating points discussed in the Results section include R1_solution_7 as the energy-saving feasible candidate, R1_solution_3 as a balanced feasible candidate, and R1_solution_9 as an aggressive drying boundary case. The historical H2 point was retained only as a reference case and was not treated as a newly optimized R1 solution. Since the present manuscript is based on a single controlled seed-aware formal run, no claim of statistical robustness is made. Additional independent seed replications would be required to support such a claim.

## Version tecnica de control -- Espanol

### Configuracion de reproducibilidad de la corrida multiobjetivo formal

La corrida formal de optimizacion multiobjetivo usada para generar las soluciones candidatas seleccionadas se configuro como una ejecucion controlada con semilla fija del algoritmo `gamultiobj` de MATLAB. La corrida, identificada como R1, utilizo la semilla aleatoria 61001, una poblacion de 24 individuos y un limite maximo de 50 generaciones. El algoritmo termino con `exitflag = 0`, correspondiente a terminacion por el limite de generaciones prescrito. Por tanto, el conjunto de soluciones resultante se interpreta como un conjunto no dominado computado bajo la configuracion especificada, no como prueba de convergencia global ni de optimalidad global.

El problema de optimizacion se formulo con tres objetivos: razon de humedad final, desempeno economico y emisiones de CO2. Las variables de decision fueron el flujo masico de aire `m_dot`, la temperatura minima de control `T_min`, la razon de recirculacion `r_rec` y el tiempo de inicio de recirculacion `t_rec_ini`. La factibilidad de los candidatos se evaluo mediante el umbral de razon de humedad final MR <= 0.1. La corrida formal se realizo para operacion hibrida solar--gas LP; la operacion solo solar no se incluyo en la comparacion multiobjetivo formal porque representa un modo operativo no equivalente.

La corrida R1 requirio aproximadamente 25.4 h de computo. Los puntos operativos seleccionados discutidos en la seccion de resultados incluyen R1_solution_7 como candidato factible de ahorro energetico, R1_solution_3 como candidato factible balanceado y R1_solution_9 como caso limite de secado agresivo. El punto historico H2 se conservo unicamente como caso de referencia y no se trato como una solucion R1 recientemente optimizada. Dado que el manuscrito actual se basa en una sola corrida formal controlada con semilla fija, no se afirma robustez estadistica. Para sostener dicha afirmacion serian necesarias replicas independientes con semillas adicionales.

## Traceability notes

| Item | Value |
|---|---|
| Algorithm | `gamultiobj` |
| Run identifier | R1 |
| Seed | 61001 |
| Population size | 24 |
| Maximum generations | 50 |
| Exitflag | 0 |
| Approximate wall-clock time | 25.4 h |
| Objectives | MR, economic objective, CO2 objective |
| Decision variables | `m_dot`, `T_min`, `r_rec`, `t_rec_ini` |
| Feasibility criterion | MR <= 0.1 |
| Formal operation mode | hybrid |
| Solar-only mode | excluded from formal GA comparison |
| Main interpretation constraint | computed nondominated set, not global optimum |
| Robustness constraint | statistical robustness not claimed |

## Internal verdict

`SEC_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_v96z_READY_FOR_METHODS_INTEGRATION`
