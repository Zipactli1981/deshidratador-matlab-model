# CORRECTED_R1 — auditoría interna postrun v96z

## Dictamen

```text
CORRECTED_R1_POSTRUN_INTERNAL_AUDIT = PASS
CORRECTED_R1_RESULTS_INTERNALLY_VALIDATED = YES
CORRECTED_R1_PARETO_FRONT_STATUS = INTERNAL_RUN_VALIDATED_COMPARATIVE_REVIEW_PENDING
DETAIL_REPLAY_EVALUATIONS = 9
GAMULTIOBJ_EXECUTIONS_ADDITIONAL = 0
F1_REPLAY_STATUS = PASS
F2_REPLAY_STATUS = PASS
F3_REPLAY_STATUS = PASS
X_BOUNDS_STATUS = PASS
MAT_CSV_LOG_CONSISTENCY = PASS
PENALTY_STATUS = PASS_NO_PENALTY_ROWS
PRODUCTIVE_CODE_MODIFIED = NO
```

Este dictamen valida consistencia interna. No declara las nueve filas como
frente Pareto corregido definitivo y no realiza comparación contra la R1
histórica reevaluada, sorting conjunto, hypervolume ni selección editorial.

## Identidad de ejecución

| Campo | Valor |
|---|---|
| HEAD | `3aacb69ec5972aeb5d155c78462715bb3f1f981c` |
| Seed / RNG | `61001` / `twister` |
| MATLAB | `26.1.0.3312084 (R2026a) Update 4` |
| Global Optimization Toolbox | `26.1 (R2026a)` |
| Inicio UTC | `2026-08-08T06:57:19.365Z` |
| Fin UTC | `2026-08-08T10:23:29.629Z` |
| Runtime solver | `12302.9888139 s` = `3.41749689275 h` |
| Exitflag | `0`, exclusivamente por alcanzar `MaxGenerations=50` |
| Generaciones / funccount | `50` / `1200` |
| Soluciones / finitas / penalizadas | `9` / `9` / `0` |
| Output | `05_runs/triobjective_formal_ga_v96m/CORRECTED_R1_COST_E3D_v96z_20260808_005736` |

## Consistencia cruzada

- `X`: `9x4` en MAT canónico y raw; identidad exacta entre ambos.
- `F`: `9x3` en MAT canónico y raw; identidad exacta entre ambos.
- `exitflag`, `output`, `population`, `scores`, runtime, bounds y modo:
  identidad entre MAT canónico y raw.
- CSV de soluciones y tabla serializada: mismas nueve parejas X/F. Las máximas
  diferencias por representación decimal son `4.263256414560601e-14` en X y
  `4.996003610813204e-16` en F.
- Tolerancias aplicadas: `absTol=1e-12`, `relTol=1e-10`.
- Las nueve filas X son únicas, las nueve parejas X/F son únicas y todos los X
  están dentro de los bounds congelados.
- Los checks, preflight y source scan existentes son consistentes y están en
  PASS. No existe error MATLAB.
- `opts` raw confirma población `24`, generaciones `50`, tolerancias `1e-5` y
  `1e-6`, `UseParallel=false` y `PlotFcn=[]`.

## Detail replay

Las nueve evaluaciones directas del objective corregido en modo `hybrid`
reprodujeron exactamente los tres objetivos almacenados:

```text
max_abs_diff_f1 = 0
max_abs_diff_f2 = 0
max_abs_diff_f3 = 0
max_rel_diff_f1 = 0
max_rel_diff_f2 = 0
max_rel_diff_f3 = 0
```

También fue exacta la trazabilidad interna `f1=MR`,
`f2=total_cost_USD/water_removed_kg` y
`f3=total_CO2_kg/water_removed_kg`. El workbook y JSON finales conservan por
fila `Q_aux_tot`, energía/costo solar, energía/costo eléctrico, masa/energía/
costo LPG, agua removida, costo total y CO2 total.

El objective detail no propaga directamente `termination_status` desde el
wrapper. Las nueve terminaciones se registran como `TMAX_REACHED` mediante una
inferencia explícita del detail devuelto: `dry_time=19.9 h`. Esta limitación de
interfaz queda visible y no altera la identidad numérica.

## Tabla de las nueve soluciones internamente validadas

| index | m_max | T_min | r_div2 | t_rec_ini | f1 | f2 | f3 | penalized | termination | dry_time | water_removed_kg | total_cost_USD | total_CO2_kg |
|---:|---:|---:|---:|---:|---:|---:|---:|:---:|---|---:|---:|---:|---:|
| 1 | 0.0919657511022433 | 67.6575511065566 | 0.528372221921637 | 13.2050964487692 | 0.0151635558533915 | 0.271207158740483 | 0.659583166418084 | NO | TMAX_REACHED | 19.9000000000000 | 169.134954538222 | 45.8706104640118 | 111.558568866299 |
| 2 | 0.0703361921141135 | 63.5177000486509 | 0.752327373669009 | 12.1035313590495 | 0.0955252717045421 | 0.184719765294859 | 0.421861788495655 | NO | TMAX_REACHED | 19.9000000000000 | 155.333703337698 | 28.6932052229208 | 65.5293539036949 |
| 3 | 0.0703062220788765 | 63.4402751227315 | 0.757046405475655 | 12.0497331287218 | 0.0976824159460894 | 0.184752491048282 | 0.421774675379642 | NO | TMAX_REACHED | 19.9000000000000 | 154.963237261432 | 28.6298441049556 | 65.3595690917192 |
| 4 | 0.0722133263195845 | 67.3965568300177 | 0.686594460224651 | 12.5054315485024 | 0.0355094146288510 | 0.199582924695207 | 0.466239599652462 | NO | TMAX_REACHED | 19.9000000000000 | 165.640774444176 | 33.0590702123477 | 77.2282883629761 |
| 5 | 0.0745255561018371 | 67.5720425101120 | 0.475903977237828 | 12.6028947102446 | 0.0288867993703157 | 0.217333659197927 | 0.514272751495238 | NO | TMAX_REACHED | 19.9000000000000 | 166.778136629881 | 36.2465027079838 | 85.7694512138974 |
| 6 | 0.0868621677528040 | 66.9646765312794 | 0.638580452778592 | 12.6738499204749 | 0.0223997054959829 | 0.241338449421739 | 0.579048792326815 | NO | TMAX_REACHED | 19.9000000000000 | 167.892224490907 | 40.5188491286022 | 97.2177898325223 |
| 7 | 0.0791659363765460 | 67.3130166294735 | 0.601401060105932 | 12.7427137083760 | 0.0265118054595229 | 0.223383226384940 | 0.530649545273739 | NO | TMAX_REACHED | 19.9000000000000 | 167.186016018908 | 37.3465516647479 | 88.7171833765616 |
| 8 | 0.0865946071447647 | 67.6276945615991 | 0.505366122977323 | 13.0348090032317 | 0.0182194532403282 | 0.254725747710310 | 0.615209940556747 | NO | TMAX_REACHED | 19.9000000000000 | 168.610137378291 | 42.9493433152234 | 103.730632593764 |
| 9 | 0.0714012572198925 | 65.0524287150717 | 0.737139402451866 | 12.3019832968389 | 0.0659289345079370 | 0.189853530177300 | 0.437935252008894 | NO | TMAX_REACHED | 19.9000000000000 | 160.416552551898 | 30.4556488008501 | 70.2520633682134 |

## Incidencias no científicas preservadas

1. Dos sesiones de auditoría terminaron durante importación del source scan,
   antes de `DETAIL_REPLAY_BEGIN`; consumieron cero evaluaciones del objective.
2. La tercera sesión realizó exactamente nueve replays y terminó correctamente.
3. El agregador provisional usó igualdad bit a bit para MAT↔CSV y una búsqueda
   textual demasiado restrictiva en el log, por lo que emitió un FAIL
   provisional. El JSON final lo reemplaza mediante reconciliación tolerante y
   conserva las diferencias cuantificadas arriba.
4. El builder del workbook devolvió código de proceso `1` después de imprimir
   `OVERALL_PASS=true` y exportar. La existencia, inspección estructural,
   ausencia de errores de fórmula y render de las cuatro hojas fueron
   verificados independientemente.

No se realizó commit, push, merge ni modificación de código productivo.
