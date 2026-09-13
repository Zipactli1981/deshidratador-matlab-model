# ARTIFACT INDEX — Deshidratador MATLAB / Q1

CORRECTED_R1 validated postrun baseline HEAD:
```text
8a794c389edd10f9750e10a27eca0ec58c14da2d
```

## Handoff
`PROJECT_HANDOFF_COST_E3D_TO_CORRECTED_R1_v96z.md`

## Runner
`02_src_limpio/production/run_corrected_r1_cost_e3d_v96z.m`

Git blob:
`075742ff72bc5b7a51e8c54b6122feea7a2fb345`

SHA-256:
`AB481811872CA984F398D83A519C4C7A4584A2F1E401AE7F2F7CA9411EAE5B20`

## Auditoría estática
- `06_manuscript/article_Q1/review/CORRECTED_R1_STATIC_AUDIT_v96z.md`
- `06_manuscript/article_Q1/review/CORRECTED_R1_STATIC_DIFF_v96z.patch`

## Solver/defaults
- `06_manuscript/article_Q1/review/FULL_SOLVER_DEFAULTS_AUDIT_CORRECTED_R1_v96z.md`
- `06_manuscript/article_Q1/review/CURRENT_ENVIRONMENT_COMPATIBILITY_INSPECTION_v96z.md`
- `06_manuscript/article_Q1/review/CURRENT_ENVIRONMENT_COMPATIBILITY_MATLAB_EVIDENCE_v96z.txt`

## Manifest
`06_manuscript/article_Q1/review/EXECUTION_PROVENANCE_MANIFEST_CORRECTED_R1_v96z_POSTRUN_FINAL.md`

## Postrun
- `06_manuscript/article_Q1/review/CORRECTED_R1_POSTRUN_INTERNAL_AUDIT_v96z.md`
- `06_manuscript/article_Q1/review/CORRECTED_R1_POSTRUN_INTERNAL_AUDIT_v96z.xlsx`
- `06_manuscript/article_Q1/review/CORRECTED_R1_POSTRUN_INTERNAL_AUDIT_v96z_SHA256.txt`

Workbook SHA-256:
`A9D3ACDC65761AC0EC343A1BFDAF5C784ECD39467A1A79E2D91CEDA7E347C8C3`

SHA registry:
`721FD6BA3E7E9417CFC136A2A6984C7FBDB74DF30309CA280BD1B40AB576B7A0`

## Output no versionado
`05_runs/triobjective_formal_ga_v96m/CORRECTED_R1_COST_E3D_v96z_20260808_005736`

## Histórico R1
Artefacto:
`SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix_20260727_185454/R1/SEEDAWARE_FORMAL_R1_ONLY_seed_61001_output.mat`

SHA-256:
`A04D1ADCD769CE9D8ED858FA321D7AF6A22E42D1F8A954094084B4B5A2A2ECD0`


## Protocolo comparativo CORRECTED_R1

Artefacto canónico:

```text
06_manuscript/article_Q1/review/CORRECTED_R1_COMPARATIVE_PROTOCOL_v96z.md
```

Versión / estado:

```text
v1.0
FROZEN_APPROVED_FOR_POSTRUN_COMPARATIVE_IMPLEMENTATION
```

SHA-256:

```text
8A8C91DE2B9498A725B544D50E9BA32CD1A159D46E06814F6B9885C01EE062C3
```

Siguiente bloque definido:

```text
CR1-COMP-01_DATASET_FREEZE
```

## Productive fingerprints
```text
historical runner = 243554b3df9644a74c54d45472068557204d650c
formal design = 2006fe8da06740c9bcf0bc1b1c7bdd7b85df0268
corrected triobjective = d7fdcb88f94ef8a766af438ad7bb40f28bcda2bc
base objective = 2e3e29cc1d417eedd278ba579bc10b4c2eda4ba0
wrapper v18 = b825a513c95f50ac105d16346650cfe48f7d0096
cost params = 4b1fbfb8554ba59a79ed7908f62b83b38e8947c8
cost breakdown = e1c9a29df585c4f2016b07d5d1f28b71eb917f52
```

## Recuperación histórica de tesis — HB200

Rol canónico aprobado:

```text
PRIMARY_THESIS_LEGACY_BASELINE = HB200
R1_50GEN_ROLE = AUXILIARY_REPRODUCIBILITY_CONTROL
HB306_STATUS = RECOVERED_LATER_CHECKPOINT_PROVENANCE_UNRESOLVED
```

Raíz versionable compacta:

```text
06_manuscript/article_Q1/review/thesis_legacy_HB200/
```

Convenciones: `SOURCE_MATCH` significa identidad exacta de tamaño y SHA-256 con el RUN auditado; `INVENTORY_MATCH` significa además coincidencia con la fila correspondiente del inventario de 46 artefactos. Las tablas son serializaciones documentales o derivadas y no sustituyen a los MAT numéricos.

### Fuentes históricas upstream fuera del conjunto versionable

| Ruta | Rol | SHA-256 | Upstream / validación |
|---|---|---|---|
| `03_original_model/05_outputs_historicos/final_pop_HB200.mat` | `PRIMARY_NUMERIC_ARTIFACT` — población | `CA40083629C97A7851A15219F46ACF22C7C5AFE4EC09190E5BBA9618106977B9` | HB200; manifest de congelado y verificación física |
| `03_original_model/05_outputs_historicos/scores_HB200.mat` | `PRIMARY_NUMERIC_ARTIFACT` — scores | `F1D4A1AD85A533CE41D87FEAA04651B9604607E3D3F527EA5A3FCDA11971FD9B` | HB200; manifest de congelado y verificación física |

Estos MAT se preservan por checksum; no se copian ni se interpretan como generación 316 o prueba de frente Pareto global.

### Arneses no productivos

| Ruta | Rol | SHA-256 | Upstream / validación |
|---|---|---|---|
| `02_src_limpio/audit/build_thesis_legacy_input_freeze_v01.py` | `NONPRODUCTIVE_HARNESS` — congelado | `70587F5795922DBF6274605A01A5B9584A2EA4F49E31A0A3747F89EC5D76D9B9` | MAT HB200; `INVENTORY_MATCH` |
| `02_src_limpio/audit/run_thesis_legacy_reevaluation_r1_v01.m` | `NONPRODUCTIVE_HARNESS` — reevaluación | `2F2F693F109C87BC554ED2670F8B252A913F74151867C6EE48CE196BF3931005` | Freeze y modelo actual; `INVENTORY_MATCH` |
| `02_src_limpio/audit/postprocess_thesis_legacy_reevaluation_r1_v01.py` | `NONPRODUCTIVE_HARNESS` — posprocesado | `DC84A569D901D90AF64437530424543F4D3F137AD99BAFF2BCEC1C2F8B74EEFF` | Outputs serializados; `INVENTORY_MATCH` |
| `02_src_limpio/audit/generate_thesis_legacy_review_figures_v01.m` | `NONPRODUCTIVE_HARNESS` — figuras | `371409FBF46E4720530AC827020CE0E70B67BE12490D052E701F291AED458033` | Tablas derivadas; `INVENTORY_MATCH` |

Estado de registro:

```text
THESIS_LEGACY_ARTIFACT_REGISTRATION = LOCAL_COMPLETE_PENDING_VERSION_CONTROL
THESIS_LEGACY_ARTIFACT_PATHS_VERIFIED = YES
THESIS_LEGACY_ARTIFACT_SHA256_VERIFIED = YES
COMPACT_EVIDENCE_FILE_COUNT = 21
NONPRODUCTIVE_HARNESS_COUNT = 4
SOURCE_INVENTORY_REGISTERED_ROWS = 46
```

### Informe y auditoría/proveniencia compacta

Todas las rutas de esta sección se resuelven bajo `06_manuscript/article_Q1/review/thesis_legacy_HB200/`.

| Ruta | Rol | SHA-256 | Upstream / validación |
|---|---|---|---|
| `THESIS_LEGACY_SCIENTIFIC_REPORT_COMPLETE.md` | `SCIENTIFIC_REPORT` | `34A8A9DA16ECF3A23500A67CCD897C3E5DCAF658078EBEB3D6BB3FF363BDBE8B` | Evidencia completa; `SOURCE_MATCH+INVENTORY_MATCH` |
| `audit/THESIS_LEGACY_EXECUTION_MANIFEST.json` | `EXECUTION_MANIFEST` | `EF9968BC3DAE399D8D1106EF61DEDD25F5A2E198C255A70006CA5DF05BAF74F5` | Freeze, ejecución y posproceso; `SOURCE_MATCH+INVENTORY_MATCH` |
| `audit/THESIS_LEGACY_EXECUTION_SUMMARY.json` | `DOCUMENTARY_SUPPORT` | `731FC7EC590B486F3281F75FE6920DF54B3C28314DF837893D33FA394506D913` | Ejecución MATLAB; `SOURCE_MATCH+INVENTORY_MATCH` |
| `audit/THESIS_LEGACY_INPUT_FREEZE_MANIFEST.json` | `DOCUMENTARY_SUPPORT` | `66C68CA862833A858E644DF80AA73D40EB60CE65EEF11E81DCA820A6B2B19F62` | MAT HB200; `SOURCE_MATCH+INVENTORY_MATCH` |
| `audit/THESIS_LEGACY_RED_TEAM_CHECKS.csv` | `RED_TEAM_AUDIT` | `FAA581C68AE4D7BFC58948302851763124B82DF3BC71C72C297E3CB017D054CC` | Evidencia posprocesada; `PASS; SOURCE_MATCH+INVENTORY_MATCH` |
| `audit/THESIS_LEGACY_RED_TEAM_REPORT.md` | `RED_TEAM_AUDIT` | `A1D656084A32C222A4F5E779CCA22CBCFC377E89BA3A56A5885EA7D470207893` | Checks red-team; `PASS; SOURCE_MATCH+INVENTORY_MATCH` |
| `audit/THESIS_LEGACY_REPRODUCIBILITY_AUDIT.json` | `REPRODUCIBILITY_AUDIT` | `C52206C526BD41E516BD749BB7B8A3860EC4BFAFDCEB62C7D8628A917938B85F` | Resultados, timing y gas-LPG; `SOURCE_MATCH+INVENTORY_MATCH` |
| `audit/THESIS_LEGACY_SOFTWARE_IDENTITY.json` | `DOCUMENTARY_SUPPORT` | `287B1B5477070DF882DD47920475D99F53502B17FF9C03540244B6A568BFF820` | Identidades de software y datos; `SOURCE_MATCH+INVENTORY_MATCH` |
| `audit/THESIS_LEGACY_SHA256_MANIFEST.csv` | `SHA256_INVENTORY` | `050D8197627EAE90AA756F82EB6745CDFAC08817FE39433504F43AD0453B6E27` | 42 outputs y cuatro arneses; `SOURCE_MATCH`; se excluye a sí mismo |

### Tablas principales

| Ruta | Rol | SHA-256 | Upstream / validación |
|---|---|---|---|
| `tables/TABLE_T1_complete_HB200_inputs.csv` | `FROZEN_INPUT_DATASET` | `0504E4DB733536B9DB6F602410894A5F3D153D8F4A3537E2E7669A0DDF4A4294` | Freeze HB200; `SOURCE_MATCH+INVENTORY_MATCH` |
| `tables/TABLE_T2_current_reevaluation.csv` | `DERIVED_NUMERIC_TABLE` | `87606CF8185219F39187754C1E3B619561F2E9563F3E7495F3F28B8219445CE8` | Reevaluación actual y ranking; `SOURCE_MATCH+INVENTORY_MATCH` |
| `tables/TABLE_T3_status_transitions.csv` | `DERIVED_NUMERIC_TABLE` | `C47959827149ED9554BB3510434F3EEB81BC998AB100273F8390026B584FAD86` | Rangos históricos y actuales; `SOURCE_MATCH+INVENTORY_MATCH` |
| `tables/TABLE_T4_T_vs_C_joint_ranks.csv` | `DERIVED_NUMERIC_TABLE` | `BF72A459D163ADC6E10B198B8F735F103CC4D62BD73AF6F96E2A949A62A501B8` | Conjuntos finitos T/C; `SOURCE_MATCH+INVENTORY_MATCH` |
| `tables/TABLE_T5_gasLP_context.csv` | `DERIVED_NUMERIC_TABLE` | `73120F6F1ECBD0B192264C7EF1D2A3C7F4094BA7136CFA18189C332619E751AB` | Contexto gas-LPG; `SOURCE_MATCH+INVENTORY_MATCH` |
| `tables/TABLE_T6_timing_experiment.csv` | `DERIVED_NUMERIC_TABLE` | `B5EDB97DA6428F58A62C4111728341683953FB09E86461C8643C953FC8A19573` | Experimento timing; `SOURCE_MATCH+INVENTORY_MATCH` |

### Figuras de revisión

| Ruta | Rol | SHA-256 | Upstream / validación |
|---|---|---|---|
| `figures/FIG_T1_status_transitions.png` | `REVIEW_FIGURE` | `22A9D7AB14FF035E58628A8B37C5532C0AB6EE5736C6E90BCF31D6E47E75FE9E` | Tabla T3; `SOURCE_MATCH+INVENTORY_MATCH` |
| `figures/FIG_T2_thesis_current_geometry.png` | `REVIEW_FIGURE` | `1DBBD790F2946F44C509AB29CE6DAC67E3B5F76B9166E87DB9A8FFF123444309` | Tabla T2; `SOURCE_MATCH+INVENTORY_MATCH` |
| `figures/FIG_T3_T_vs_C.png` | `REVIEW_FIGURE` | `297F26E16F70E31CE59DA23B4F7E8D28A7DA88F2606335E836CA83F30A169DBA` | Tabla T4 y T–C; `SOURCE_MATCH+INVENTORY_MATCH` |
| `figures/FIG_T4_decision_provenance.png` | `REVIEW_FIGURE` | `014E1624D6534BE87570173A83F22BD7492D85D98B746C7F7814CC3651E5BA6D` | Estatus y proveniencia; `SOURCE_MATCH+INVENTORY_MATCH` |
| `figures/FIG_T5_gasLP_context.png` | `REVIEW_FIGURE` | `7E63662D90F12D901F30AF68D511D5E1DF0AAE93175929ABE60732E81D6035AB` | Tabla T5; uso contextual; `SOURCE_MATCH+INVENTORY_MATCH` |
| `figures/FIG_T6_timing_response.png` | `REVIEW_FIGURE` | `F823ED3E405A2A84469292197253E092B6C319596E4E8735904E87F9911F4381` | Tabla T6; `SOURCE_MATCH+INVENTORY_MATCH` |

### Outputs preservados fuera del conjunto compacto

Los MAT primarios/frozen del RUN, CSV raw o aliases redundantes, `THESIS_LEGACY_MATLAB_EXECUTION_DIARY.txt`, `THESIS_LEGACY_EXECUTION_SUMMARY.mat` y `THESIS_LEGACY_SCIENTIFIC_REPORT.md` permanecen fuera del conjunto versionable y preservados por el inventario SHA-256. No se modificó el protocolo H(9)-vs-C(9) v1.0.

## Protocolo nuevo de región operativa robusta — freeze local 2026-09-05

| Ruta | Rol | SHA-256 | Upstream / validación / estado |
|---|---|---|---|
| `06_manuscript/article_Q1/review/CURRENT_FORMULATION_ROBUST_OPERATING_REGION_PROTOCOL_v01.md` | `METHODOLOGICAL_PROTOCOL` | `7259B0855CF2F835851EE46FF8B8845FCAA0A1E07852419C76731F7F82A82599` | Autorización de campaña nueva; COST-E3D y opciones canónicas en Git `0e1233041e36dc0bf01ab314def3baf9e1c8faa0`; revisión estática de consistencia y hash de bytes locales; `FROZEN_DOCUMENTARY_PRE_EXECUTION` |

### Implementación no productiva auditada y dry validation

Raíz: `02_src_limpio/audit/robust_operating_region_v01/`.

| Archivo | Rol | SHA-256 | Upstream / validación |
|---|---|---|---|
| `README.md` | `IMPLEMENTATION_NOTE` | `3BE88A3F6AAFB883C2B0C466EFFDA997C8256C029E566ADBF29ADFD7A4F17F05` | Protocolo v01; audit/repair/reaudit y dry validation |
| `benchmark_manifest.template.json` | `BENCHMARK_PROVENANCE_TEMPLATE` | `A035F167A97AFB6ECF9A2791F1530AE0F96491E7077887044805605D389D70FD` | Benchmarks externos HB200/C; no inicialización |
| `campaign_manifest.template.json` | `CAMPAIGN_PROVENANCE_TEMPLATE` | `8555568A336587CB81318CD472BC11D67712E1C7E251D7DAF7E660725C8984AD` | Campos fail-closed por run/campaña |
| `frozen_config.json` | `FROZEN_CAMPAIGN_CONFIG` | `5131DA361C7C8688D755C724F2830C057980F7F2444DDC3B8983CCEEF4DCFE47` | Bytes exactos; `-text` path-scoped; configuración 5×24×200 |
| `requirements.txt` | `ANALYSIS_DEPENDENCY_SPEC` | `9403738B9BD9E46261005F7D1E26BFAC7048400205C30F2275AF43700B257ABB` | Runtime sintético Python, no modelo |
| `ror_core.py` | `NONPRODUCTIVE_ANALYSIS_HARNESS` | `4861F17E38CDF4F059AB3FB56370E0C5ECBE59C538B6F1DC23DFDA5FF20AE7CC` | Dominancia exacta, N_POOL, IGD+, HV, suficiencia, recomendaciones |
| `ror_postrun.py` | `ROR_POSTRUN_AND_PROVENANCE_AUDITOR` | `140CC26752F4BC2EC364D77FE31B997A6804D83D1F6F9B69F594AC2FAEA0925C` | Legacy 36/36 PASS; lifecycle markers estrictos y provenance-aware; default legacy preservado; real audit dry ACCEPT 5/5; protocolo intacto; sin métricas reales |
| `run_ror_campaign.m` | `NONPRODUCTIVE_CAMPAIGN_RUNNER` | `5B6A7A93A62C57B202324DF4A693D340DA4B29C33579E67EE33F68A8C687A9E8` | Guard usa helper compartido; runner fail-closed; dry preexecution PASS; cero llamadas científicas |
| `ror_options_equivalent.m` | `NONPRODUCTIVE_OPTIONS_GUARD_HELPER` | `69C999DA52D236C5196CD4D3401658B4A8292DD47C9EF56457A1E5F9189B9648` | Canonicalización exclusiva `doubleVector`/`doublevector`; mismatches reales fail-closed; checkcode 0 issues |
| `source_lock.json` | `PRODUCTIVE_SOURCE_LOCK` | `5F528E34A97BB279478BDD0FF5CF1D3A78EF7864D392CCC545162DAF0E2765EB` | 53 dependencias; bytes exactos; `-text` path-scoped |
| `test_ror_synthetic.py` | `ROR_LEGACY_POSTRUN_REGRESSION_TEST` | `0C5F30A4F591843081C2159E3F700965F5A3CBB81301D8593CC8D72048A180F2` | Legacy 36/36 PASS; contratos legacy/recovery, FAILED, mixed family, markers faltantes y seed incorrecta; default legacy preservado |

El registro HB200 anterior describe el estado de preparación local de aquel micropaso: su cierre posterior fue publicado mediante `0e1233041e36dc0bf01ab314def3baf9e1c8faa0`. En esta revisión main/origin/main coinciden en `cc429c059807127063175a62ec3aa3fcff986edf`, que incorpora posteriormente la infraestructura ROR. No se alteran los bytes ni roles HB200; sus MAT primarios siguen fuera del paquete compacto y preservados por checksum.

El protocolo nuevo conserva separado e intacto H(9)–C(9) v1.0. Trace runtime crossover externo no versionado: `C:\Program Files\MATLAB\R2026a\toolbox\globaloptim\globaloptim\private\validate.m`, SHA-256 `4EBF77F7E9D1D18B665C8B948AC639DD7BBD8DAB0FFAD3809AE3C013BF7214AB`, líneas 139–149.

## Orquestación de recuperación ROR — implementada, no ejecutada

Campaign recovery reservado para una autorización futura: `ROR_PRIMARY_20260907_RECOVERY_FROM_61003_A1`. Fuentes primarias finales previstas: 61001/61002 desde `ROR_PRIMARY_20260907_REAUTHORIZED`; 61003/61004/61005 desde recovery, con 61003 nuevamente desde cero. Base de validación común: guards positivos/negativos PASS; fixtures temporales recovery 6/6 PASS; MATLAB dry PASS; checkcode 0 mensajes; cero llamadas a `gamultiobj`, modelo u objective y cero optimizaciones.

| Ruta | Rol | SHA-256 | Upstream / validación |
|---|---|---|---|
| `02_src_limpio/audit/robust_operating_region_v01/run_ror_recovery_campaign.m` | `NONPRODUCTIVE_RECOVERY_RUNNER` | `AED03018ADBB8055FD26C06EA38FA7D0192CBE98A23C8B4BC16EC6C85EB06226` | Subset fijo 61003–61005; fresh start; manifest y provenance recovery; fail-closed |
| `02_src_limpio/audit/robust_operating_region_v01/ror_recovery_guards.m` | `NONPRODUCTIVE_RECOVERY_GUARD` | `9EB92F5D006128B361ACCF4411E62811184C537A5A1CFDA7CDD327F914C54ACB` | Unión final exacta, exclusiones, configuración y warm-start guards; MATLAB dry PASS |
| `02_src_limpio/audit/robust_operating_region_v01/ror_recovery.py` | `NONPRODUCTIVE_RECOVERY_PROVENANCE_HARNESS` | `473C2CF7063FEA765FF9C8FC8F5667FBDBE2E439F4947EAF293AE05EBF303492` | Auditoría read-only de originales y construcción sintética de identidad/provenance |
| `02_src_limpio/audit/robust_operating_region_v01/test_ror_recovery_dry.m` | `RECOVERY_DRY_TEST` | `971D60E005A9E28655F797A68016952D4349095CAC2A140EFBF4326A5B4A8563` | Guards y `optimoptions`; PASS; checkcode 0; sin ejecución científica |
| `02_src_limpio/audit/robust_operating_region_v01/test_ror_recovery_synthetic.py` | `ROR_RECOVERY_PROVENANCE_SYNTHETIC_TEST` | `0536C60C029233CA31B06B0A7E7CAA1ED1F8344D3237E8CACAE083B1D02A0A17` | Recovery 6/6 PASS; fixture legacy completo y lifecycle recovery real verificado; protocolo intacto; sin métricas reales |

### Evidencia del intento interrumpido 61003 — fuera del conjunto versionable

| Ruta | Rol | SHA-256 | Estado |
|---|---|---|---|
| `05_runs/robust_operating_region_v01/ROR_PRIMARY_20260907_REAUTHORIZED/seed_61003/FROZEN_CONFIG.json` | `INTERRUPTED_ATTEMPT_EVIDENCE` | `0B9638B4841D4C887DE8F78630FEEDE47B2D574C2399742EF0DB5FF1B9C858F7` | `NOT_PRIMARY_OPTIMIZATION_OUTPUT`; preservado, no resumible, no staged |
| `05_runs/robust_operating_region_v01/ROR_PRIMARY_20260907_REAUTHORIZED/seed_61003/SOLVER_DIARY.txt` | `INTERRUPTED_ATTEMPT_EVIDENCE` | `4C02A0578076D52226C45EF5CC4F3536D6EF4AE59F1B15891B548C77D1E8FC9C` | `NOT_PRIMARY_OPTIMIZATION_OUTPUT`; preservado, no resumible, no staged |

Las salidas completas 61001/61002 conservan integridad contra sus inventarios `SEED_SHA256.json`. El intento parcial 61003 no integra el conjunto primario, no aporta warm start/población/scores/RNG y no fue movido, renombrado ni modificado. Siguiente gate tras publicar: autorización explícita de recovery execution; ejecución científica NO autorizada en este estado.

## Infraestructura composite-postrun ROR

| Ruta | Rol | SHA-256 | Base de validación |
|---|---|---|---|
| `02_src_limpio/audit/robust_operating_region_v01/ror_composite_postrun.py` | `COMPOSITE_POSTRUN_ADAPTER_AND_ARTIFACT_PUBLICATION_LAYER` | `BC0F84078B06899473B27287A3DCB5374AFB37A5D787B25AE77B91611E387871` | Composite 10/10 PASS; familia legacy/recovery derivada del role validado; real audit dry ACCEPT 5/5; protocolo intacto; sin métricas reales |
| `02_src_limpio/audit/robust_operating_region_v01/test_ror_composite_synthetic.py` | `COMPOSITE_POSTRUN_SYNTHETIC_AND_PUBLICATION_TEST` | `BB5615E348B827720B1EBAC83E19522175BE233A5D45E31E8E7DC0C65D9D2B34` | Composite 10/10 PASS; fixtures recovery con lifecycle real; publicación transaccional y preservación de inputs; sin métricas reales |

El entorno Python aislado usado para validación no es artefacto científico ni forma parte del repositorio. El source map real validado contiene exactamente 61001–61005, con 61003–61005 desde recovery y el intento parcial original 61003 excluido.

## Postrun composite primario — derivados publicados, suficiencia FAIL

Upstream común: cinco fuentes primarias hash-exact del source map congelado; protocolo SHA-256 `7259B0855CF2F835851EE46FF8B8845FCAA0A1E07852419C76731F7F82A82599`; ejecución con Git HEAD `bb464a050accb0151756eedb79990c05ca85a579`; publicación `COMPLETE_TRANSACTIONAL`. Los derivados no sustituyen outputs primarios.

Raíz: `05_runs/robust_operating_region_v01/ROR_PRIMARY_20260907_COMPOSITE_POSTRUN/`.

| Ruta relativa | Rol | SHA-256 | Upstream / validación |
|---|---|---|---|
| `audit/POSTRUN_INTEGRITY.json` | `DERIVED_POSTRUN_ARTIFACT` | `5F100BA44F4272CE43DFED804BFBB2723EE52933EA03605D8AFE8C8B85CA40BA` | Auditoría 5/5; manifest/hash PASS |
| `audit/DOMINANCE_AUDIT.json` | `DERIVED_POSTRUN_ARTIFACT` | `D692CBB71F45150AA25A7ECEE2447F17EED3382A3BD78632BFFBF2B8E2489A1D` | U=112; N_POOL=22; cobertura dirigida 20/20; dominancia exacta |
| `audit/PRIMARY_SUFFICIENCY.json` | `DERIVED_POSTRUN_ARTIFACT` | `AC004B2D9B00473BA065F4A7021C3071F906F82E9782013E7B6238A86E8C8E9C` | FAIL sólo por HV ratio; sin políticas |
| `tables/ALL_RUNS.csv` | `DERIVED_POSTRUN_ARTIFACT` | `3B114A8A8CEAC06ED8F176A46892F788E7D291F5E71300DC133ACD3650F8B419` | Filas auditadas consolidadas; manifest/hash PASS |
| `tables/N_R.csv` | `DERIVED_POSTRUN_ARTIFACT` | `25789CAC80514BB16628B4E5BDB6A75CB4183E5178BE8AABF575ECE9CCF1C5CF` | N_r por seed 11/11/9/10/8; manifest/hash PASS |
| `tables/N_POOL.csv` | `DERIVED_POSTRUN_ARTIFACT` | `85EE646DA477C064D50CC8AC808BD6A1FC38F419169150ECC6993244D5DCE2D8` | 22 decisiones, 21 objetivos únicos; duplicado válido de objetivo en 61001 |
| `tables/INTER_RUN_METRICS.csv` | `DERIVED_POSTRUN_ARTIFACT` | `4028030A221CB7E2D155AB0D5AC347F190639B5384DCFA77148EEBEB82F60EE2` | IGD+, HV, contribuciones y extremos publicados |
| `numeric/N_POOL.mat` | `DERIVED_POSTRUN_ARTIFACT` | `C1D95216B9446F7B15E177702658D0B57929B3D2A4EAD4D5D9FD9BE36CADAD25` | Representación numérica derivada de N_POOL; manifest/hash PASS |
| `SHA256_MANIFEST.csv` | `DERIVED_ARTIFACT_HASH_INVENTORY` | `60B11805D7B601829A30B82C38F6267054A88311B67585844CB4CAA77DBC6F69` | Inventario de ocho derivados; validación 8/8 PASS |
| `COMPOSITE_POSTRUN_MANIFEST.json` | `COMPOSITE_POSTRUN_FINAL_MANIFEST` | `842BA68BD766AED30A309118BF1E5BECEEE07AB48A5DC7B59C0C2E793323FF0A` | Manifiesto final; inventario 9/9 PASS; `COMPLETED_BUT_INSUFFICIENT` |

## Diagnóstico secundario de presupuesto extendido 61001×400 — protocolo e infraestructura

Campaña prevista `ROR_BUDGET_DIAGNOSTIC_61001_G400_V01`; estado `PROTOCOL_AND_INFRASTRUCTURE_PASS_NOT_EXECUTED`. La campaña primaria 5×200 y su N_POOL permanecen inalterados.

| Path | Role | SHA-256 | Upstream | Validation basis |
|---|---|---|---|---|
| `06_manuscript/article_Q1/review/ROR_EXTENDED_BUDGET_DIAGNOSTIC_PROTOCOL_v01.md` | `EXTENDED_BUDGET_DIAGNOSTIC_PROTOCOL` | `4081B46D21D2EA4D7B4587A8AA40763F8BB718ECE20719C979CB5ABA7B6FBB5D` | Revisión científica primaria 5×200 y diseño read-only congelado | Freeze preejecución; hash audit PASS |
| `02_src_limpio/audit/robust_operating_region_v01/extended_diagnostic_config.json` | `EXTENDED_BUDGET_FROZEN_CONFIG` | `4D51261C86780E3B7B1DC4FB146B7A997241EAB216ADE70DC313662F4F024283` | Config primaria `5131DA...`; protocolo diagnóstico | Seed/config exactas; normalización/HV literales; guards/tests PASS |
| `02_src_limpio/audit/robust_operating_region_v01/extended_diagnostic_source_lock.json` | `EXTENDED_BUDGET_SOURCE_LOCK` | `608EB3BDB8016BA181A1798A7E16B10847CCB9D115993CF35259A992667DE735` | Protocolo, infraestructura, dependencias productivas y referencia primaria 61001 | 16/16 hashes PASS |
| `02_src_limpio/audit/robust_operating_region_v01/run_ror_extended_budget_diagnostic.m` | `EXTENDED_BUDGET_DIAGNOSTIC_RUNNER` | `B96429B7DB0B7EB000221EF7B517EF5B694073417796EEB34B1D4E0BA5A84C5B` | Config y source lock diagnósticos; objective productivo sólo como dependencia futura | Runner separado y bloqueado; MATLAB dry PASS; checkcode 0; no ejecución |
| `02_src_limpio/audit/robust_operating_region_v01/ror_extended_snapshot_outputfcn.m` | `PASSIVE_GENERATION_SNAPSHOT_OUTPUTFCN` | `F4647F0694E895B44975D1A0128D360BD93ADCDB1810E6071A0DD636E3308705` | Protocolo y config diagnósticos | Pasividad PASS; state/options intactos; `optchanged=false`; StopFlag intacto; snapshots sintéticos PASS |
| `02_src_limpio/audit/robust_operating_region_v01/ror_extended_diagnostic_guards.m` | `EXTENDED_BUDGET_CONFIG_GUARDS` | `F2A1100679F3A23C8A1C31B5ADF7BAC1AE07E9BD90D2B5D090C6AD3D86EA0764` | Config primaria y diagnóstica; hashes congelados | Guards positivos/negativos fail-closed PASS |
| `02_src_limpio/audit/robust_operating_region_v01/ror_extended_root_guard.m` | `EXTENDED_BUDGET_OUTPUT_ROOT_GUARD` | `4DA5BF7FA80DD8499DE0EFD40298887403D695B67F0EA3048EB83E0DF4B46D65` | Política de root diagnóstica separada y no-overwrite | Fixture de colisión fail-closed PASS |
| `02_src_limpio/audit/robust_operating_region_v01/ror_extended_diagnostic_postrun.py` | `EXTENDED_BUDGET_DIAGNOSTIC_POSTRUN` | `F7A32DE362710CB1978A7E08E437739A7B39847A2026834DB5612242D5196261` | Snapshots/final diagnósticos futuros y referencia primaria 61001 congelada | Fixtures exact/alternative y categorías A/B/C/D PASS; no postrun real |
| `02_src_limpio/audit/robust_operating_region_v01/test_ror_extended_diagnostic_dry.m` | `EXTENDED_BUDGET_MATLAB_DRY_TEST` | `D6BCA62774936D2D2A598C732B21C81C407A91DE50ADD655ABB3DF7E32CF9575` | Callback, guards, configuración y opciones sintéticas | MATLAB dry PASS; checkcode 0; 0 gamultiobj/model/objective |
| `02_src_limpio/audit/robust_operating_region_v01/test_ror_extended_diagnostic_synthetic.py` | `EXTENDED_BUDGET_SYNTHETIC_TEST` | `B8E3F97A8CC41A20E740876B499DD4535C9693618E6F5082425F3DE2B5F76616` | Postrun puro y configuración diagnóstica | 10/10 PASS; igualdad exacta, trayectoria alternativa, A/B/C/D y N_POOL inmutable |
