# CURRENT FORMULATION ROBUST OPERATING REGION PROTOCOL v01

## 1. Identidad, alcance y autoridad

```text
PROTOCOL_ID = CURRENT_FORMULATION_ROBUST_OPERATING_REGION_v01
FREEZE_DATE = 2026-09-05
STATUS = FROZEN_DOCUMENTARY_PRE_EXECUTION
SOURCE_BASELINE_COMMIT = 0e1233041e36dc0bf01ab314def3baf9e1c8faa0
NEXT_GATE = ROBUST_OPERATING_REGION_IMPLEMENTATION
MATLAB_EXECUTION_AUTHORIZED = NO
GAMULTIOBJ_EXECUTION_AUTHORIZED = NO
NEW_OPTIMIZATION_AUTHORIZED = NO
```

Pregunta: “What reproducible nondominated operating region can be obtained for the hybrid solar-LPG dryer under the current objective formulation and the complete four-variable control space, and what operational recommendations can be derived from that region?”

Este documento preespecifica una campaña NUEVA; no implementa ni ejecuta nada. El protocolo histórico CORRECTED_R1_COMPARATIVE_PROTOCOL_v96z.md v1.0 (H(9)–C(9), SHA-256 8A8C91DE2B9498A725B544D50E9BA32CD1A159D46E06814F6B9885C01EE062C3) permanece intacto. Sus reglas exactas de dominancia se heredan, no sus poblaciones ni dominio estrecho.

Roles:

- HB200_ROLE = PRIMARY_TRACEABLE_THESIS_ERA_HISTORICAL_BASELINE.
- C_ROLE = FROZEN_CURRENT_FORMULATION_PILOT_REFERENCE (CORRECTED_R1, nueve soluciones).
- NEW_CAMPAIGN_ROLE = PRIMARY_MULTI-SEED_CURRENT_FORMULATION_SEARCH.

HB200 y C no son frentes globales. C no constituye evidencia causal de superioridad del optimizador. Robustez aquí significa estabilidad empírica entre semillas bajo datos, formulación y presupuesto fijos, no tolerancia física a incertidumbre ambiental o perturbaciones.

## 2. Formulación y dominio congelados

Minimización simultánea de tres objetivos COST-E3D:

- f1 = MR terminal, adimensional, devuelto por el wrapper corregido.
- f2 = costo total operativo USD / agua removida kg.
- f3 = (3.00 * masa_GLP_kg + 0.4440 * electricidad_kWh) / agua removida kg; unidades operativas kg CO2e/kg de agua removida. “masa_GLP_kg” denota el campo exacto cost.LPG_mass_kg, sin alterar su cálculo.

Denominador común: agua removida = (Mi − M_terminal(x)) * md. Costo y emisiones reutilizan exactamente los mismos consumos y denominador del detalle productivo. Alcance de emisiones: GLP y electricidad del impulsor, no ciclo de vida. La suma de CO2 de GLP y CO2e de red se reporta con esa salvedad.

```text
objective = objective_productive_corrected_v96j_triobjective_CO2_fix1
base_objective = objective_productive_corrected_v95j_endpoint_TMAX_corrected
wrapper = opt_tunel_mod2_v18_endpoint_TMAX_corrected
mode = hybrid
referenceMode = gasLP
nvars = 4
x = [m_max, T_min, r_div2, t_rec_ini]
lb = [0.07, 45, 0.00, 0]
ub = [0.20, 70, 0.99, 19]
```

Variables continuas: m_max kg/s; T_min °C; r_div2 fracción adimensional; t_rec_ini horas. Bounds inclusivos, tomados de la validación interna de la base objetiva. El piloto C empleó una ventana propuesta más estrecha/diferente; no se trasladan sus bounds a la campaña nueva. referenceMode identifica el benchmark gasLP y NO cambia la llamada primaria hybrid ni añade evaluaciones gasLP.

Se conserva W0=200 kg, humedad inicial 0.87 base húmeda, objetivo nominal 0.08 y umbral deseado 0.10; Mi=0.87/0.13 y md=26 kg. Horizonte y discretización del wrapper permanecen iguales (tmax=20 h; paso 0.1 h; extremo efectivo reportado 19.9 h). t_rec=0 significa inicio temporal inmediato, no ausencia de recirculación.

Sin restricciones lineales, igualdad, nonlcon ni variables enteras añadidas. Se mantienen las validaciones físicas internas y la penalización triobjetivo [1000, 1e6, 1e6], incluyendo errores atrapados. No se convierte el incumplimiento de humedad deseada/TMAX en una nueva restricción. Un punto TMAX finito no penalizado puede ser admisible, pero su régimen debe reportarse.

Parámetros contables no se reestiman: potencia 1.03 kW, eficiencia quemador 0.78, PCI GLP 46.16 MJ/kg; precios/moneda y reglas energéticas son los de los archivos congelados siguientes.

## 3. Identidad productiva y procedencia

Rutas relativas al repositorio D:/CODE/deshidratador. Identidades Git blob (SHA-1 de objeto Git, NO SHA-256 de bytes worktree) verificadas en SOURCE_BASELINE_COMMIT:

| Archivo | Git blob |
|---|---|
| 02_src_limpio/production/objective_productive_corrected_v96j_triobjective_CO2_fix1.m | d7fdcb88f94ef8a766af438ad7bb40f28bcda2bc |
| 02_src_limpio/production/objective_productive_corrected_v95j_endpoint_TMAX_corrected.m | 2e3e29cc1d417eedd278ba579bc10b4c2eda4ba0 |
| 02_src_limpio/wrappers/opt_tunel_mod2_v18_endpoint_TMAX_corrected.m | b825a513c95f50ac105d16346650cfe48f7d0096 |
| 02_src_limpio/cost/build_cost_params_historical.m | 4b1fbfb8554ba59a79ed7908f62b83b38e8947c8 |
| 02_src_limpio/cost/calc_cost_breakdown.m | e1c9a29df585c4f2016b07d5d1f28b71eb917f52 |
| 02_src_limpio/main/setup_v05_paths.m | 89e2044be604522fe5c08bbf220d3cc67b0cd73d |
| 03_original_model/01_active_original/tunel_mod2.mlx | a6922eb59f4fe40aa241d935aad90f6c8ebcf63f |
| 03_original_model/04_data_original/Mapeo4_temp100621.txt | 2e3f7fe8be4511c3a3c884fdd1fc6fbf07da3420 |
| 02_src_limpio/production/run_corrected_r1_cost_e3d_v96z.m (referencia de configuración, NO ejecutor nuevo) | 075742ff72bc5b7a51e8c54b6122feea7a2fb345 |

También se congela por el commit el árbol de dependencias productivas 02_src_limpio y 03_original_model: ninguna dependencia puede sustituirse por otra versión. La implementación deberá enumerar rutas efectivamente resueltas y SHA-256 de bytes, incluidos auxiliares físicos/psicrométricos y datos; detectar shadowing o dependencias no registradas antes del gate de ejecución. No seleccionar automáticamente “último archivo”. Git blob y SHA-256 worktree se conservan como identidades distintas por los finales de línea.

Entorno de referencia validado: MATLAB 26.1.0.3312084 (R2026a) Update 4, Global Optimization Toolbox 26.1 (R2026a), PCWIN64. Fuente: FULL_SOLVER_DEFAULTS_AUDIT_CORRECTED_R1_v96z.md y auditoría HB200 registrada. Un cambio material de entorno/opciones exige revisión antes de ejecutar; no implica autorización para iniciar MATLAB ahora.

El runner CORRECTED_R1 tiene guards y lógica para un único piloto/50 generaciones y selección histórica de bounds; no debe ejecutarse sin cambios ni modificarse como atajo. La implementación será un arnés no productivo separado que aplique ESTE protocolo, sin sus preflights/evaluaciones automáticas. Esto es una tarea de implementación, no una incompatibilidad del diseño científico.

## 4. Corridas, inicialización y opciones

```text
PRIMARY_RUN_COUNT = 5
SEEDS = [61001, 61002, 61003, 61004, 61005]
RNG = twister
PopulationSize = 24
MaxGenerations = 200
UseParallel = false
PRIMARY_HB200_INITIALIZATION = NO
PRIMARY_C_INITIALIZATION = NO
InitialPopulationMatrix = []
InitialScoresMatrix = []
```

Orden fijo de ejecución: semillas ascendentes, una corrida independiente por semilla. Restablecer RNG con su semilla inmediatamente antes de la inicialización normal del solver; no consumir aleatoriedad entre reset y solver. Registrar estado RNG inicial/final. Reutilizar el número 61001 del piloto no significa reutilizar su población ni una corrida previa: dominio, presupuesto y ejecución son nuevos.

Opciones restantes heredadas de la auditoría validada:

| Opción | Valor congelado |
|---|---|
| FunctionTolerance; ConstraintTolerance | 1e-5; 1e-6 |
| Display; PlotFcn; OutputFcn | iter; []; [] |
| PopulationType; InitialPopulationRange | doubleVector; [-10,10] default ajustado por bounds |
| ParetoFraction; CrossoverFraction | 0.35; 0.8 |
| DistanceMeasureFcn | {@distancecrowding,'phenotype'} |
| SelectionFcn | {@selectiontournament,2} |
| CreationFcn / CrossoverFcn / MutationFcn almacenadas | [] / [] / [] (resolución dinámica validada) |
| Funciones efectivas esperadas | gacreationuniform / crossoverintermediate / mutationadaptfeasible |
| MaxStallGenerations; MaxTime | 100; Inf |
| HybridFcn; UseVectorized | []; off (false) |
| MigrationDirection; MigrationFraction; MigrationInterval | forward; 0.2; 20 (sin efecto con población escalar) |
| PlotInterval; IntegerTolerance | 1; 1e-5 (sin efecto aquí) |

No se utiliza FunctionTolerance ni ConstraintTolerance para calcular ranks. MaxStallGenerations=100 puede detener una corrida ANTES de 200; se acepta una parada normal documentada por criterio solver sin afirmar convergencia. No forzar la continuación. Registrar opciones almacenadas y efectivas, no depender silenciosamente de defaults de otro release.

PopulationSize=24 preserva el tamaño validado; 200 aumenta la profundidad frente al piloto de 50; cinco semillas permiten observar variabilidad entre corridas. Presupuesto nominal 5*24*200=24000 evaluaciones de población, no funccount contractual ni límite rígido de llamadas: reportar conteo real incluyendo creación y particularidades solver. Alcanzar MaxGenerations no demuestra convergencia.

Una semilla es la unidad independiente de evidencia. Individuos, generaciones o duplicados no son réplicas independientes. Una sola corrida no demuestra robustez, convergencia estocástica ni desempeño esperado de gamultiobj.

## 5. Captura y gate postrun

Conservar sin sobrescribir por semilla: X/F retornados, population/scores finales, exitflag/output completo, generaciones reales, funccount, tiempo de pared, RNG, opciones, rutas/hashes/versiones y log íntegro. MAT double de precisión completa es la fuente numérica; CSV es exportación derivada, no base redondeada de dominancia.

El arnés podrá capturar los detalles devueltos EN LAS MISMAS llamadas que solicita el solver; ninguna llamada adicional al objective para completar tablas. La instrumentación no cambia valores devueltos, RNG, opciones ni decisiones de parada. Registrar llamadas reales con identificador y x/F/detail. La consistencia de objective se audita contra estos datos persistidos, no mediante replay automático.

Cada corrida requiere integridad MAT/CSV/log; dimensiones; bounds exactos; finitud y penalizaciones; consistencia X/F/population/scores y detalle; semilla y provenance; opciones congeladas; hashes; generaciones; funccount; exitflag/mensaje; errores MATLAB y reproducibilidad documental. Diferencias decimales de CSV se distinguen de discrepancias MAT; no redondear para aprobar dominancia.

Una terminación normal por límite 200 o stall es elegible; error, interrupción manual o salida incompleta invalidan la corrida. Mantener separados errores físicos atrapados/penalizados por diseño y fallos del proceso. Registrar todos los penalizados; no admitirlos a conjuntos científicos aunque sus scores sean finitos. Identificar penalización mediante estado y sentinel/reglas del código congelado, no exclusivamente isfinite. Discrepancias de mismo x con distintos F a precisión completa bloquean consistencia, no se promedian.

No reintentar una corrida ni programar replays automáticamente. Cualquier nueva evaluación o recuperación tras fallo exige autorización separada.

## 6. Universo de evidencia, duplicados y dominancia

Para evitar dependencia de frecuencia de logging, el universo científico de cada corrida se define ANTES de ejecutar como la unión de X/F devueltos y population/scores finales; las evaluaciones intermedias quedan como procedencia, NO se añaden selectivamente al pool. “Todas las soluciones” en este protocolo significa todos estos candidatos finales persistidos. Publicar los conteos antes/después de exclusión y deduplicación.

A_r = candidatos de ese universo con x y F reales finitos, bounds satisfechos, auditados y no penalizados. N_r = subconjunto exactamente no dominado de A_r. U = unión de A_r de las cinco corridas; N_POOL = subconjunto exactamente no dominado de U. No incorporar HB200/C, reinicios ni warm starts. Conservar multiplicidad/procedencia por separado; deduplicar diseños sólo por igualdad exacta de sus cuatro coordenadas. Si distintos x comparten F exacto, conservarlos como decisiones distintas; para métricas de distancia/HV usar vectores objetivos únicos sin ponderación por duplicados.

Minimización: a domina b iff f_k(a)<=f_k(b) para todo k y f_j(a)<f_j(b) para algún j. Igualdad exacta no domina. Usar doubles completos MAT sin tolerancia, redondeo ni epsilon. El diagnóstico separado near-tie 1e-12*max(1,abs(a_k),abs(b_k)) no cambia conjuntos/ranks.

Nombre: “pooled multi-seed nondominated approximation” o “multi-seed approximation of the nondominated operating region”. No “true/exact/global Pareto front”.

## 7. Métricas comunes y casos límite

Sólo tras terminar las cinco corridas válidas se congela N_POOL y su checksum. Definir una única normalización empírica usando N_POOL: l_k=min f_k, u_k=max f_k, z_k(f)=(f_k-l_k)/(u_k-l_k). Aplicar idénticos l/u a TODAS las corridas; no normalizar por semilla ni recortar coordenadas >1. Guardar l/u con precisión completa.

Si alguna corrida es inválida, VALID_RUNS<5 y suficiencia FAIL; las métricas parciales se etiquetan exploratorias, no sustituyen resultados primarios. Si N_POOL/N_r está vacío no hay PASS. Rango nulo en cualquier objetivo: HV=BLOCKED, IGD+ normalizado y balanced también indefinidos; no sustituir denominador por epsilon, ni eliminar objetivos. PRIMARY_SUFFICIENCY=NOT_DETERMINABLE, requiere decisión metodológica explícita sin nuevas ejecuciones automáticas. Estos casos no autorizan modificar criterios después de resultados.

Reportar:

A. |A_r| y |N_r| por semilla, diseños únicos y vectores objetivos únicos separados.
B. |U| y |N_POOL| con la misma distinción.
C. Contribución de semilla: número y fracción de diseños únicos de N_POOL presentes en A_r; crédito compartido completo y conteo exclusivo separados. Fracciones con crédito compartido pueden sumar >1; no interpretarlas como partición.
D. Set coverage dirigido C(A,B)=|{b en B: existe a en A que domina estrictamente b}|/|B|, para cada par ordenado N_r/N_s, con diseños únicos. Igualdad no cuenta. Denominador vacío: NOT_DETERMINABLE.
E. Pooled-reference IGD+ normalizado: para P=objetivos únicos normalizados de N_POOL y Q_r=objetivos únicos normalizados de N_r,

IGDplus_r = (1/|P|) * sum_{p in P} min_{q in Q_r} sqrt(sum_k max(q_k-p_k,0)^2).

La orientación q−p corresponde a minimización. Referencia empírica común, no frente verdadero; contiene contribuciones de las propias corridas, por lo que es una medida interna descriptiva y no validación independiente. Publicar cinco valores, máximo y mediana (tercer valor ordenado).

F. HV común secundario: volumen de la unión de cajas [q_1,1.10]×[q_2,1.10]×[q_3,1.10] para q en Q_r que satisfaga q_k<=1.10 en todas las coordenadas. Usar sólo conjuntos ND, misma normalización y referencia r=(1.10,1.10,1.10). Los puntos fuera de referencia no aportan caja; reportar cuántos, no recortarlos ni mover referencia. Calcular volumen geométrico 3D determinista, no Monte Carlo. HV vacío=0. Si MAX_HV=0, ratio indefinido y criterio de HV FAIL; no dividir entre cero. Métrica relativa interna de estabilidad, no distancia al Pareto global.

Extremos: por objetivo k y corrida r, e_rk=min_{q in Q_r} q_k; mejor pooled=0. No exigir que una misma solución alcance todos los extremos.

## 8. Suficiencia preespecificada y cierre

PRIMARY_SUFFICIENCY=PASS requiere simultáneamente:

1. VALID_RUNS=5/5.
2. Todas las soluciones de N_POOL son finitas, auditadas y no penalizadas.
3. MAX_POOLED_REFERENCE_IGD_PLUS<=0.10 y MEDIAN_POOLED_REFERENCE_IGD_PLUS<=0.05.
4. MIN_HV/MAX_HV>=0.90, con MAX_HV>0 y HV definido.
5. Para CADA objetivo, al menos cuatro de cinco corridas tienen e_rk<=0.10.

No redondear antes de comparar umbrales. Son criterios operativos de suficiencia bajo el presupuesto ensayado, no pruebas de convergencia global. HV es secundario en interpretación, pero forma parte obligatoria de este gate conjunto.

PASS → SUFFICIENT_FOR_OPERATING_REGION_INTERPRETATION.
FAIL → COMPLETED_BUT_INSUFFICIENT (o registro de corrida incompleta/invalidada cuando corresponda).
Métrica esencial indefinida → BLOCKED/NOT_DETERMINABLE, nunca PASS.

En FAIL/BLOCKED no aumentar generaciones/población/semillas, relanzar ni iniciar warm start HB200. Cualquier ampliación exige nueva pregunta, protocolo/desviación documentada y autorización. Una campaña informada por HB200 sería una fase independiente preespecificada, no rescate retrospectivo.

## 9. Benchmarks congelados y límites causales

Sólo tras congelar N_POOL comparar separadamente con los 44 HB200_current_reevaluated y con C(9), usando exclusivamente objetivos actuales archivados; también reportar sus núcleos ND sin confundirlos con el total. Fuentes: paquete HB200 registrado, T2/T4 y manifiestos de entrada; C mantiene sus identidades originales. Recuperar precisión primaria existente desde los MAT declarados en manifiestos; si falta, BLOCKED para comparación exacta, no recalcular modelo ni usar cifras redondeadas.

Aplicar dominancia exacta y coverage a cada comparación por separado; los benchmarks no cambian normalización, referencia ni suficiencia primaria. Evaluar regiones históricas competitivas recuperadas, extensión de aproximación, dominancia de algunos benchmarks y trade-offs incomparables. No interpretar diferencias como efecto causal aislado de gamultiobj: objetivos históricos, dominio, presupuesto e inicialización no constituyen un experimento controlado de optimizadores.

## 10. Políticas de decisión y operación

Sólo si PRIMARY_SUFFICIENCY=PASS seleccionar exclusivamente diseños de N_POOL:

- MOISTURE_PRIORITY: mínimo f1.
- COST_PRIORITY: mínimo f2.
- EMISSIONS_PRIORITY: mínimo f3.
- BALANCED_COMPROMISE: mínimo sqrt(z1^2+z2^2+z3^2), pesos iguales, con la normalización N_POOL de sección 7.

Desempate determinista para valores de política exactamente iguales en double: orden lexicográfico ascendente (f1,f2,f3,x1,x2,x3,x4); si mismo diseño, procedencia semilla menor y luego identificador de fila menor. No usar tolerancia para convertir near-ties en empates; reportarlos como diagnóstico. Mantener varias etiquetas de política si seleccionan el mismo diseño. Congelar implementación numérica de distancia antes de resultados.

Balanced es una regla de decisión de igual ponderación, no un óptimo universal. No inferir que la caja envolvente de N_POOL es íntegramente admisible ni que un punto es “la operación óptima de la planta”.

Por política reportar x completo/unidades, MR, USD/kg agua, kg CO2e/kg agua, dry_time h, LPG_mass_kg, LPG_fuel_input_MJ, Q_aux_tot y unidad nativa documentada, electricidad kWh, t_rec, régimen terminal, semilla y procedencias compartidas. Usar detalles guardados durante llamadas solver. Si termination_status no está propagado, separar etiqueta inferida de dry_time/criterio terminal de una etiqueta directamente observada; no inventar. Campo ausente: NOT_RECOVERED y limitación, no replay automático.

Robustez local observable: descripción de vecinos existentes y cobertura por semillas dentro de N_POOL, cuando disponible; no extrapolar sensibilidad causal ni robustez a perturbaciones sin ensayos. Cualquier análisis de vecindad adicional se etiqueta descriptivo y no altera suficiencia ni selección.

Nombres: moisture-priority / cost-priority / emissions-priority / balanced compromise operating point. Claims permitidos sólo si los datos respaldan: “reproducible multi-seed nondominated operating-region approximation”; “stable high-quality nondominated region under the tested computational budget”. Prohibidos sin evidencia independiente: “global optimum”, “true Pareto front”, “exact Pareto front”, “global convergence”, “gamultiobj proved superior”.

## 11. Artefactos previstos, no creados en este freeze

Raíz futura RUN = 05_runs/robust_operating_region_v01/<campaign_id>/, identificador único fijado antes de ejecutar, sin sobrescritura. Todos los nombres siguientes son relativos a RUN.

| Ruta prevista | Rol / contenido mínimo |
|---|---|
| CAMPAIGN_MANIFEST.json | protocolo/hash, baseline, autorizaciones, cinco semillas, entorno y estado |
| audit/SOFTWARE_IDENTITY.json | rutas resueltas, Git blobs y SHA-256 de dependencias/datos |
| seed_<seed>/FROZEN_CONFIG.json | x/bounds, RNG, opciones completas y efectiva resolución |
| seed_<seed>/PRIMARY_OUTPUT.mat | evidencia primaria X/F, population/scores, output/exitflag/RNG/options |
| seed_<seed>/SOLVER_DIARY.txt | log íntegro, errores, paradas y tiempos |
| seed_<seed>/EVALUATION_DETAILS.mat | detalles de llamadas solver ya realizadas, x/F/call_id, sin replays |
| seed_<seed>/FINAL_CANDIDATES.csv | exportación derivada con procedencia y estados |
| tables/ALL_RUNS.csv | unión trazable de candidatos finales, exclusiones y duplicados |
| tables/N_R.csv | ND auditado por corrida |
| numeric/N_POOL.mat | pool ND de precisión completa, normalización y procedencia |
| tables/N_POOL.csv | representación derivada del pool |
| audit/POSTRUN_INTEGRITY.json | validación por corrida, conteos, exitflag, hashes, bounds/penalizaciones |
| audit/DOMINANCE_AUDIT.json | definición exacta, ranks, conjuntos, igualdad y near-ties separados |
| tables/INTER_RUN_METRICS.csv | tamaños/contribuciones, coverage, IGD+, HV, extremos |
| audit/PRIMARY_SUFFICIENCY.json | cinco condiciones, valores completos, PASS/FAIL/BLOCKED |
| tables/BENCHMARK_COMPARISON.csv | N_POOL–HB200 actual y N_POOL–C por separado |
| tables/OPERATING_RECOMMENDATIONS.csv | cuatro políticas sólo con suficiencia PASS |
| figures/FIG_R1_pool_and_runs.png | geometría objetivos y procedencia por semilla |
| figures/FIG_R2_inter_run_stability.png | métricas internas y umbrales |
| figures/FIG_R3_benchmarks.png | benchmarks externos sin mezclarlos en el pool |
| figures/FIG_R4_operating_policies.png | puntos/políticas y controles, condicionada a PASS |
| SHA256_MANIFEST.csv | todos los artefactos cerrados, tamaño/hash/rol; excluye a sí mismo |
| SCIENTIFIC_REPORT_COMPLETE.md | resultados, insuficiencias, alcance, limitaciones y claims |

MAT primarios y logs se preservarán, no se versionarán automáticamente. Exportaciones deben documentar redondeo sin afectar cálculo. El manifest se finaliza antes del inventario SHA; no cadenas de hashes circulares. Registrar hash del inventario en el cierre externo. No crear ahora ninguno de estos outputs.

## 12. Gates y trazabilidad documental

Fuentes inspeccionadas: CURRENT_STATE, PHASE_HANDOFF_CURRENT, protocolo histórico v1.0, DECISION_LOG, ARTIFACT_INDEX, METHOD_GUARDRAILS; informe/auditorías/tablas HB200 registradas; objective/base/wrapper/costos y auditoría de opciones. Este freeze no cambia reglas históricas ni resultados existentes.

NEXT_GATE = ROBUST_OPERATING_REGION_IMPLEMENTATION: preparar y revisar un arnés no productivo, configuración/manifest y análisis que implementen exactamente estas reglas. Pruebas que inicien MATLAB, solver o modelo requieren permiso explícito separado; ningún dry-run con evaluación queda autorizado por el nombre “implementación”. Después, un gate separado de autorización de ejecución. Este micropaso termina con documentos locales y hash registrado, sin staging, commit, push, PR, merge, nuevas evaluaciones o edición del manuscrito.
