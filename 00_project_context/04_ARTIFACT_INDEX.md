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
| `ror_postrun.py` | `NONPRODUCTIVE_POSTRUN_HARNESS` | `3DE3CDDB69B5563C6C56FC9CFD65D614AAC42D51688B3B3006A2CAB396EEBE5D` | Preflight/derivación/publicación transaccional |
| `run_ror_campaign.m` | `NONPRODUCTIVE_CAMPAIGN_RUNNER` | `06EC1FAAB6CBB0B141517EBD8A899A4E5B0604E5D036F6E7A614424B897DBB13` | Runner fail-closed; no warm start/autoretry |
| `source_lock.json` | `PRODUCTIVE_SOURCE_LOCK` | `5F528E34A97BB279478BDD0FF5CF1D3A78EF7864D392CCC545162DAF0E2765EB` | 53 dependencias; bytes exactos; `-text` path-scoped |
| `test_ror_synthetic.py` | `SYNTHETIC_TEST_HARNESS` | `DF1D3EA9A6391F31BD9BC1C6688B8CE098AE2097A8FF39C33E839A3C825D3E47` | 29/29 PASS; no MATLAB/modelo |

El registro HB200 anterior describe el estado de preparación local de aquel micropaso: su cierre posterior fue publicado mediante `0e1233041e36dc0bf01ab314def3baf9e1c8faa0`. En esta revisión main/origin/main coinciden con ese commit y se verifican nuevamente 25/25 hashes de los artefactos compactos y arneses. No se alteran sus bytes ni roles; MAT primarios siguen fuera del paquete compacto y preservados por checksum.

El protocolo nuevo conserva separado e intacto H(9)–C(9) v1.0. No existen outputs de la campaña nueva. Implementación reauditada y dry validation PASS, sin llamadas científicas. Trace runtime crossover externo no versionado: `C:\Program Files\MATLAB\R2026a\toolbox\globaloptim\globaloptim\private\validate.m`, SHA-256 `4EBF77F7E9D1D18B665C8B948AC639DD7BBD8DAB0FFAD3809AE3C013BF7214AB`, líneas 139–149. Siguiente gate: `ROBUST_OPERATING_REGION_IMPLEMENTATION_LOCAL_COMMIT`; ejecución científica NO autorizada.
