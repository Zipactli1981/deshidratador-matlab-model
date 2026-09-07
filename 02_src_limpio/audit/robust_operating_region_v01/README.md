# Región operativa robusta v01 — implementación no productiva

Gate implementado: ROBUST_OPERATING_REGION_IMPLEMENTATION_REPAIR.
Auditoría inicial: BLOCKED. Hallazgos CRITICAL/HIGH reparados; reauditoría independiente pendiente.
Siguiente gate: ROBUST_OPERATING_REGION_IMPLEMENTATION_REAUDIT.
No autoriza ejecución de campaña.

## Archivos y separación

- frozen_config.json: configuración exacta, SHA-256 5131DA361C7C8688D755C724F2830C057980F7F2444DDC3B8983CCEEF4DCFE47.
- source_lock.json: 53 archivos de los directorios productivos/dependencias/datos, Git blob + hash de bytes actuales. SHA-256 5F528E34A97BB279478BDD0FF5CF1D3A78EF7864D392CCC545162DAF0E2765EB.
- campaign_manifest.template.json: esquema de campaña sin autorización/identificador rellenado.
- run_ror_campaign.m: runner serial independiente, no llama al piloto ni carga MAT de entrada.
- ror_core.py: dominancia/ranks exactos, pool, IGD+, HV geométrico, coverage, suficiencia y políticas.
- ror_postrun.py: validación estática de fuentes; auditoría MAT/CSV y consolidación explícitamente separadas.
- benchmark_manifest.template.json: mapeo explícito futuro de MAT primario/hash/campos de benchmark, nunca inicialización.
- test_ror_synthetic.py: pruebas puramente sintéticas; MAT ficticios en TemporaryDirectory fuera del repositorio.
- requirements.txt: entorno Python de análisis probado, no dependencias del modelo.

El protocolo permanece sin cambios y conserva SHA-256:
7259B0855CF2F835851EE46FF8B8845FCAA0A1E07852419C76731F7F82A82599.

frozen_config.json y source_lock.json se hashean sobre sus bytes exactos. Reglas
acotadas por ruta con -text impiden que core.autocrlf transforme esos bytes:
git hash-object --path coincide con git hash-object --no-filters y el SHA-256
de worktree conserva los valores embebidos. No se cambió configuración Git global,
no se canonicalizan finales de línea y no se debilitó la verificación de contenido.

## Seguridad

El runner sin argumentos/confirmación true falla antes de IO, cambios de path, RNG u objective. Requiere además identificador seguro y autorización estructurada con approved=true, implementation_audit_pass=true, gate=ROBUST_OPERATING_REGION_EXECUTION, protocol_sha256 exacto, campaign_id coincidente, expected_head exacto y record de aprobación separado no vacío. El HEAD observado debe coincidir con el autorizado antes de reservar outputs. Ningún archivo de esta implementación concede esa autorización; execution_authorized permanece false.

No hay warm start, InitialPopulationMatrix/InitialScoresMatrix vacías, carga de MAT histórico, diseño latest, preflight de objective, evaluación gasLP ni replay. No se ejecuta postrun automáticamente. Directory reservation impide sobrescribir/reiniciar una campaña existente; un error detiene la secuencia sin reintentos. Captura detalles y objetivos de detalle en double durante las mismas llamadas del solver. Las tablas/ranks no dependen de JSON redondeado.

Preserva PopulationSize=24, MaxGenerations=200, MaxStallGenerations=100, seeds 61001–61005, twister, nvars=4, lb=[0.07,45,0,0], ub=[0.20,70,0.99,19], serial y opciones restantes exactas. MaxStallGenerations puede detener antes de 200.

## Validación permitida sin MATLAB

Desde el repositorio, con Python 3.12 + dependencias indicadas:

```text
python -B 02_src_limpio/audit/robust_operating_region_v01/test_ror_synthetic.py
python -B 02_src_limpio/audit/robust_operating_region_v01/ror_postrun.py --static D:/CODE/deshidratador
```

El segundo comando sólo lee fuentes, configuración/protocolo y Git; no carga MAT ni lanza MATLAB. Los tests no leen MAT históricos. No usar compilación que genere __pycache__ en el árbol; -B y ast.parse bastan.

Validación de reparación: 29 tests sintéticos PASS; sintaxis Python AST PASS; static source/config PASS (53 archivos); guards, llamada única a gamultiobj y ausencia de load en runner revisados estáticamente. La suite atraviesa audit_seed con NaN, +Inf/-Inf, bounds, penalización y precisión válida; también prueba procedencia obligatoria, benchmark inválido antes de derivación, fallo durante derivación, ausencia de outputs finales parciales y repetición limpia. NO se ha realizado parser/runtime MATLAB, optimoptions, which ni resolución privada de defaults en MATLAB. La selección efectiva de CreationFcn/CrossoverFcn/MutationFcn y otros defaults permanece PENDING_MATLAB_DRY_VALIDATION.

## Contrato futuro de artefactos

Raíz: 05_runs/robust_operating_region_v01/<campaign_id>/.
Subcarpetas audit, tables, numeric, figures y seed_61001…seed_61005 se crean sólo en ejecución explícita, no durante pruebas estáticas.

Cada semilla conserva PRIMARY_OUTPUT.mat (v7 doubles), EVALUATION_DETAILS.mat, FROZEN_CONFIG.json, FINAL_CANDIDATES.csv (17 cifras significativas), SOLVER_DIARY.txt y SEED_SHA256.json. MAT es fuente numérica; CSV se verifica por roundtrip. Metadata incluye timestamps absolutos inicio/fin, duración, directorio y rutas primarias absolutas, HEAD esperado/observado, generaciones, funccount, exitflag, output/mensaje completos, versión, RNG inicial/final, opciones y hashes de dependencias productivas. La ausencia o inconsistencia de cualquiera bloquea. Captura callObjectiveF permite consistencia exacta con los objetivos del detalle sin depender de serialización JSON.

Postrun exige cinco semillas/configuración/provenance completas, hashes y tamaños, fuente de cada candidato final, conteo real de llamadas y coherencia RNG/solver. Un error produce Blocked, no reparaciones. La unión científica es X/F retornados + population/scores finales, excluyendo no finitos/fuera de bounds/penalizados; todas las filas y razones permanecen en ALL_RUNS. Duplicados exactos retienen todas sus procedencias.

N_POOL usa normalización única, HV r=(1.1,1.1,1.1), IGD+ orientación q−p y reglas exactas del protocolo. Rango nulo bloquea sin epsilon. Recomendaciones sólo con suficiencia PASS; no rellena régimen terminal no propagado: NOT_RECOVERED. No crea sensibilidad local ficticia.

La interfaz postrun es opt-in (--run más --acknowledge-postrun); NO se ha utilizado sobre resultados reales. El preflight es enteramente read-only y exige antes de derivar los cinco runs y exactamente los manifests HB200_CURRENT/C, con ruta explícita, SHA-256 del MAT, campos, objective actual y 44/9 filas. La derivación completa ocurre en un directorio temporal hermano; sólo tras éxito total se publican los outputs, con rollback si falla la publicación. Un fallo no deja outputs finales parciales ni impide una repetición limpia. Los campos nulos bloquean; no se descubre el archivo más reciente.

Figuras y redacción del informe científico final requieren el gate posterior de interpretación; no se generan resultados o claims ahora. SHA256_MANIFEST.csv se crea al terminar la consolidación, excluyéndose a sí mismo; su hash se devuelve para registro externo. Si posteriormente se añaden figuras/informe se necesita un nuevo cierre documental del inventario, no una modificación silenciosa.

## Preservación

La reparación autorizada actualiza sólo implementación, reglas path-scoped y los dos documentos canónicos de estado. El protocolo, código productivo, manuscrito y staging permanecen intactos. No instalar paquetes ni ejecutar MATLAB por instrucciones de este README.
