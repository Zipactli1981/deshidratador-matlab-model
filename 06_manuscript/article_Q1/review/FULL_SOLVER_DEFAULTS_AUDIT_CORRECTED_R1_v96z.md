# Auditoría completa de defaults del solver para CORRECTED_R1 v96z

## Dictamen

`FULL_SOLVER_DEFAULTS_AUDIT = PASS_WITH_DOCUMENTARY_BUILD_LIMITATION`

La configuración serializada de `GamultiobjOptions` fue recuperada completamente
por inspección binaria estática del MAT histórico. La incertidumbre residual no
está en los valores de opciones: está en que el MAT no registra directamente el
número completo de build/update de MATLAB ni la versión de producto cargada por
el proceso histórico. El release sí queda determinado como `R2026a`; `Update 4`
es altamente probable, pero indirecto.

En la fase estática original no se inició MATLAB, no se invocó `gamultiobj`, y
no se evaluó el modelo ni la función objetivo. El cierre dinámico autorizado se
documenta en la sección H y mantuvo las mismas prohibiciones de ejecución.

## A. Evidencia histórica localizada

- MAT R1 canónico:
  `06_manuscript/article_Q1/runs/SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix_20260727_185454/R1/SEEDAWARE_FORMAL_R1_ONLY_seed_61001_output.mat`.
- SHA-256 del MAT R1:
  `A04D1ADCD769CE9D8ED858FA321D7AF6A22E42D1F8A954094084B4B5A2A2ECD0`.
- MAT raw formal que contiene `opts`:
  `05_runs/triobjective_formal_ga_v96m/TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix_20260727_185506/mat/TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix_raw.mat`.
- SHA-256 del MAT raw:
  `92BEEC3F2FF6D26CDEEB7A4AB9ABC053F8178FE47B38B8C17AD3CA9F7AD59397`.
- Cabecera MAT raw: `MATLAB 5.0 MAT-file`, `Platform: PCWIN64`, creado
  `Mon Jul 27 22:47:40 2026`.
- Clase serializada: `optim.options.GamultiobjOptions`.
- El subsistema MCOS conserva `Defaults`, `SetByUser` y `Options`.
- El objeto MCOS contiene repetidamente
  `C:\Program Files\MATLAB\R2026a` y rutas R2026a para
  `distancecrowding.m` y `selectiontournament.m`.
- El audit F4 previo contiene `matlabInfo.version = 9.10.0.1851785
  (R2021a) Update 6`, pero fue creado el 30 de junio y no representa el proceso
  R1 canónico del 27 de julio. No debe usarse como versión ejecutora de R1.
- La instalación R2026a actualmente presente declara estáticamente:
  MATLAB `26.1.0.3312084`, `R2026a`, `Update 4`; Global Optimization
  Toolbox `26.1 (R2026a)`; Optimization Toolbox `26.1 (R2026a)`.

## B. Versión MATLAB y toolboxes

| Componente | Estado | Evidencia |
|---|---|---|
| MATLAB release histórico | Determinado: `R2026a` | Rutas `matlabroot` serializadas dentro del propio `opts` histórico. |
| Plataforma histórica | Determinada: `PCWIN64` | Cabecera MAT. |
| MATLAB build/update histórico | Probable: `26.1.0.3312084`, Update 4 | Instalación local R2026a; no está guardado directamente como campo de procedencia en el MAT. |
| Global Optimization Toolbox | Determinado a nivel release/producto: `26.1 (R2026a)` | `gamultiobj` y funciones serializadas apuntan al árbol R2026a; `Contents.m` local declara 26.1. |
| Optimization Toolbox | Probable: `26.1 (R2026a)`; no es el toolbox que aporta `gamultiobj` | `Contents.m` local. |

## C. Opciones históricas y comparabilidad

`Explícita` significa `SetByUser=1` en el objeto histórico y asignación visible
en el runner. `Default` significa `SetByUser=0`.

| Propiedad pública / interna | Valor histórico observado | Origen | CORRECTED_R1 previsto | Comparabilidad |
|---|---|---|---|---|
| `PopulationSize` | `24` | Explícita | `24` | Exacta |
| `MaxGenerations` / `Generations` | `50` | Explícita | `50` | Exacta |
| `FunctionTolerance` / `TolFunValue` | `1e-5` | Explícita | `1e-5` | Exacta |
| `ConstraintTolerance` / `TolCon` | `1e-6` | Explícita | `1e-6` | Exacta |
| `UseParallel` | `false` | Explícita | `false` | Exacta |
| `Display` | `iter` | Explícita | `iter` | Exacta; no cambia trayectoria |
| `PlotFcn` / `PlotFcns` | `[]` | Explícita | `[]` | Exacta |
| `InitialPopulationMatrix` / `InitialPopulation` | `[]` | Default | `[]` | Exacta si se conserva release/RNG |
| `InitialScoresMatrix` / `InitialScores` | `[]` | Default | `[]` | Exacta |
| `InitialPopulationRange` / `PopInitRange` | `[-10, 10]` | Default | `[-10, 10]`, después ajustado por bounds | Exacta en R2026a |
| `PopulationType` | `doubleVector` | Default | `doubleVector` | Exacta |
| `ParetoFraction` | `0.35` | Default | `0.35` | Material; exacta en R2026a |
| `DistanceMeasureFcn` | `{@distancecrowding,'phenotype'}` | Default | Igual | Material; exacta en R2026a |
| `SelectionFcn` | `{@selectiontournament,2}` | Default | Igual | Material; exacta en R2026a |
| `CreationFcn` almacenada | `[]` | Default dinámico | `[]` | Igual como opción |
| `CreationFcn` efectiva | `@gacreationuniform` | Resuelta por `validate.m` para este problema continuo con sólo bounds | Igual en R2026a | Material |
| `CrossoverFcn` almacenada | `[]` | Default dinámico | `[]` | Igual como opción |
| `CrossoverFcn` efectiva | `@crossoverintermediate` | Resuelta por `validate.m` porque `MultiObjective=true` | Igual en R2026a | Material |
| `MutationFcn` almacenada | `[]` | Default dinámico | `[]` | Igual como opción |
| `MutationFcn` efectiva | `@mutationadaptfeasible` | Resuelta por `validate.m` porque `MultiObjective=true` | Igual en R2026a | Material |
| `CrossoverFraction` | `0.8` | Default | `0.8` | Material; exacta en R2026a |
| `MigrationDirection` | `forward` | Default | `forward` | Sin efecto con una sola población escalar |
| `MigrationFraction` | `0.2` | Default | `0.2` | Sin efecto con `PopulationSize=24` escalar |
| `MigrationInterval` | `20` | Default | `20` | Sin efecto con una sola población |
| `MaxStallGenerations` / `StallGenLimit` | `100` | Default | `100` | No puede dominar el límite de 50 generaciones |
| `HybridFcn` | `[]` | Default | `[]` | Exacta |
| `OutputFcn` / `OutputFcns` | `[]` | Default | `[]` | Exacta |
| `PlotInterval` | `1` | Default | `1` | Sin efecto con `PlotFcn=[]` |
| `MaxTime` / `TimeLimit` | `Inf` | Default | `Inf` | Exacta |
| `UseVectorized` / `Vectorized` | `off` | Default | `off` | Exacta |
| `IntegerTolerance` | `1e-5` | Default | `1e-5` | No material: no hay variables enteras |

La llamada permanece:

```matlab
gamultiobj(objfun, nvars, [], [], [], [], lb, ub, opts)
```

No hay matriz de población inicial, scores iniciales, restricciones lineales,
restricción no lineal ni `intcon` suministrados.

## D. Defaults potencialmente dependientes del release

Los campos materialmente capaces de cambiar la trayectoria son:

- `CreationFcn` efectiva;
- `CrossoverFcn` efectiva;
- `MutationFcn` efectiva;
- `SelectionFcn` y tamaño de torneo;
- `DistanceMeasureFcn` y su argumento;
- `ParetoFraction`;
- `CrossoverFraction`;
- generación de población inicial y tratamiento de bounds;
- implementación interna de esas funciones aun cuando sus nombres coincidan.

El riesgo de diferencia de propiedades queda eliminado porque el objeto
histórico conserva sus valores. El riesgo residual es de implementación entre
builds/updates. `Migration*`, `StallGenLimit=100`, `PlotInterval` e
`IntegerTolerance` no son materiales bajo esta configuración concreta.

## E. Incertidumbres residuales

1. El MAT no guarda un campo directo con `version`, build y update del proceso
   ejecutor.
2. La atribución a Update 4 es fuerte pero indirecta.
3. No se ha hecho una deserialización oficial del objeto con MATLAB; la lectura
   fue binaria estática del subsistema MCOS.
4. No existe hash histórico de los archivos internos de Global Optimization
   Toolbox usados el 27 de julio.

## F. Resultado

```text
HISTORICAL_GAMULTIOBJ_OPTIONS_RECOVERED = PASS
EXPLICIT_VS_DEFAULT_CLASSIFICATION = PASS
MATLAB_RELEASE_IDENTIFICATION = PASS_R2026a
MATLAB_EXACT_BUILD_IDENTIFICATION = INCOMPLETE_PROBABLE_UPDATE_4
GLOBAL_OPTIMIZATION_TOOLBOX_RELEASE = PASS_26_1_R2026a
FULL_SOLVER_DEFAULTS_AUDIT = PASS_WITH_DOCUMENTARY_BUILD_LIMITATION
```

## G. Micropaso dinámico solicitado (completado en H)

Solicitar autorización separada para una inspección MATLAB mínima y sin solver:

```matlab
S = load('05_runs/triobjective_formal_ga_v96m/TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix_20260727_185506/mat/TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix_raw.mat','opts');
disp(version('-release'));
disp(version);
v = ver('globaloptim'); disp(v);
disp(S.opts);
disp(struct(S.opts));
```

Esta inspección no debe llamar `gamultiobj`, no debe construir `objfun`, y no
debe evaluar el modelo ni el objetivo. Confirma la deserialización y el entorno
actual; no prueba por sí sola el build histórico. Para comparabilidad máxima,
la futura R1 debe ejecutarse en la instalación R2026a Update 4 identificada y
guardar explícitamente `version`, `ver('globaloptim')` y todas las propiedades
de `opts` antes de iniciar el solver.

## H. Cierre dinámico autorizado

La inspección mínima se completó en MATLAB `26.1.0.3312084 (R2026a) Update 4`,
con Global Optimization Toolbox `26.1 (R2026a)`. El objeto histórico `opts` se
deserializó oficialmente y los defaults materiales coinciden con el objeto
actual. Las diferencias de defaults observadas corresponden exclusivamente a
propiedades fijadas de forma explícita por el runner congelado. La evidencia
completa y sus checkpoints están en
`CURRENT_ENVIRONMENT_COMPATIBILITY_MATLAB_EVIDENCE_v96z.txt`.

```text
CURRENT_ENVIRONMENT_COMPATIBILITY = PASS
HISTORICAL_BUILD_EXACT = UNKNOWN
HISTORICAL_BUILD_UNCERTAINTY = DOCUMENTARY_NON_MATERIAL
FULL_SOLVER_DEFAULTS_AUDIT = PASS_WITH_DOCUMENTARY_BUILD_LIMITATION
```
