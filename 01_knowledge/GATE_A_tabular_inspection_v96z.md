\# Gate A — Inspección tabular fina v96z



Estado: Dictamen documental  

Fecha: 2026-07-14  

Repositorio: Zipactli1981/deshidratador-matlab-model  

Relación: Complementa ADR-001, inventario v96z y Gate A / Gate B prerrequisitos  

No autoriza: ejecución MATLAB, `gamultiobj`, corrida formal, uso científico de resultados ni modificación de código.



\## 1. Propósito



Este documento resume la inspección tabular fina de los archivos CSV asociados a los artefactos Gate A:



\- `TRIOBJECTIVE\_FORMAL\_RUN\_DESIGN\_v96l`

\- `GAOPTS\_AUDIT\_v96z\_before\_formal\_run\_f4`



La inspección se realizó sin ejecutar MATLAB, sin ejecutar código del modelo y sin correr `gamultiobj`.



\## 2. Escenario recomendado



El escenario recomendado es:



| Campo | Valor |

|---|---|

| `scenario\_id` | `F1` |

| `name` | `HYBRID\_TRIOBJECTIVE\_FORMAL\_PLUS\_GASLP\_REFERENCE` |

| `modes` | `hybrid` |

| `population\_size` | `24` |

| `max\_generations` | `50` |

| `eval\_count\_per\_mode` | `1224` |

| `total\_eval\_count` | `1224` |

| `estimated\_runtime\_h` | `7.61265561178125` |

| `recommended` | `true` |



El escenario F1 se interpreta como la ruta formal mínima triobjetivo híbrida. No representa una comparación formal completa entre gas LP, híbrido y solar.



\## 3. Configuración del solver



| Parámetro | Valor |

|---|---|

| Solver | `gamultiobj` |

| Objetivos | `3` |

| Objetivos declarados | MR, costo específico, CO2 específico |

| Variables de decisión | `4` |

| Variables | `m\_max`, `T\_min`, `r\_div2`, `t\_rec\_ini` |

| Modo formal | `hybrid` |

| Modo de referencia | `gasLP` |

| PopulationSize formal | `24` |

| MaxGenerations formal | `50` |

| RNG type | `twister` |

| Política `confirm\_execute` | requerida para ejecución |

| Estado factores CO2 | `PROVISIONAL\_FOR\_CODE\_VALIDATION` |



\## 4. Punto seleccionado y límites



Punto seleccionado:



| Variable | `x\_selected` |

|---|---:|

| `m\_max` | `0.0740767982118` |

| `T\_min` | `62.6832965028` |

| `r\_div2` | `0.672252618341` |

| `t\_rec\_ini` | `11.6517528081` |



Límites formales:



| Variable | `lb\_global` | `ub\_global` | `delta\_formal` | `lb\_formal` | `ub\_formal` |

|---|---:|---:|---:|---:|---:|

| `m\_max` | `0.05` | `0.12` | `0.02` | `0.0540767982118` | `0.0940767982118` |

| `T\_min` | `55` | `70` | `5` | `57.6832965028` | `67.6832965028` |

| `r\_div2` | `0` | `0.95` | `0.25` | `0.422252618341` | `0.922252618341` |

| `t\_rec\_ini` | `8` | `14` | `3` | `8.6517528081` | `14` |



Fórmula documentada:



`lb = max(lb\_global, x\_selected - delta)`  

`ub = min(ub\_global, x\_selected + delta)`



\## 5. Preflight triobjetivo



| Modo | Estado | `f1` MR | `f2` costo | `f3` CO2 | `detail\_status` | `Q\_aux\_tot` | `Irradiacion` | `dry\_time` | `CO2\_specific` |

|---|---|---:|---:|---:|---|---:|---:|---:|---:|

| `gasLP` | `OK` | `0.0960086491729676` | `0.377877584709771` | `1.68102998335545` | `OK` | `1185.86683689984` | `0` | `19.9` | `1.68102998335545` |

| `hybrid` | `OK` | `0.095917201055571` | `0.265706336788744` | `1.05843988917656` | `OK` | `714.840046628502` | `487.28052` | `19.9` | `1.05843988917656` |

| `solar` | `OK` | `1000` | `1000000` | `1000000` | `INVALID\_COST` | `NaN` | `NaN` | `NaN` | `NaN` |



Interpretación operativa:



\- gas LP e híbrido tienen evaluación triobjetivo finita en el preflight.

\- solar está técnicamente evaluado, pero penalizado con `\[1000, 1e6, 1e6]`.

\- El estado de factores de emisión es `PROVISIONAL\_FOR\_CODE\_VALIDATION`.

\- Estos resultados no deben usarse como evidencia científica final.



\## 6. Política de semillas



| Contexto | Semilla | Control RNG | Válido para replicación independiente |

|---|---:|---|---:|

| `original\_v96m` | `614960` | `INTERNAL\_FIXED\_SEED` | `0` |

| `seedaware\_formal\_clone\_with\_rngSeed` | `NaN` | `EXTERNAL\_SEED\_APPLIED` | `1` |

| `seedaware\_formal\_clone\_without\_rngSeed` | `614960` | `LEGACY\_INTERNAL\_SEED\_614960\_APPLIED` | `0` |

| `seedaware\_smoke\_S1` | `61001` | `EXTERNAL\_SEED\_APPLIED` | `1` |

| `seedaware\_smoke\_S2` | `61002` | `EXTERNAL\_SEED\_APPLIED` | `1` |

| `planned\_formal\_R1` | `61001` | `EXTERNAL\_SEED\_APPLIED` | `1` |

| `planned\_formal\_R2` | `61002` | `EXTERNAL\_SEED\_APPLIED` | `1` |

| `planned\_formal\_R3` | `61003` | `EXTERNAL\_SEED\_APPLIED` | `1` |



Dictamen:



\- El runner original `v96m` no es adecuado para replicación independiente porque fija internamente `rng(614960,'twister')`.

\- La cadena `seed-aware` sí está diseñada para recibir semilla externa.

\- R1, R2 y R3 están planeadas con semillas `61001`, `61002` y `61003`.

\- Esta tabla documenta intención y diseño, no sustituye una verificación de ejecución.



\## 7. Checks F4



Los checks F4 reportan `pass=1` para:



\- existencia del runner formal original;

\- existencia del clon seed-aware;

\- existencia del diseño v96l;

\- presencia de `gamultiobj` en runner original y clon;

\- presencia de `optimoptions/gamultiobj`;

\- detección de semilla fija en original;

\- presencia de rama externa `rngSeed`;

\- presencia de metadatos de semilla;

\- detección de `PopulationSize = 24`;

\- detección de `MaxGenerations = 50`;

\- extracción de `x\_selected`;

\- extracción de límites globales;

\- cálculo de límites formales;

\- completitud de tabla de límites;

\- uso de límites desde `Sdesign`.



Riesgo: las evidencias F4 contienen rutas absolutas de la computadora anterior:



`C:\\Users\\PC\\MATLAB Drive\\modelo\_deshidratador\_GA\_chile\_red\_controlado\_v1\_3\_HYBRID\_IRR\_COMPARE\_CONSOLIDADA\\...`



Por tanto, los checks son evidencia histórica/local y deben reconciliarse con la ruta actual:



`D:\\CODE\\deshidratador`



\## 8. Requisitos y aceptación



Requisitos ya satisfechos según la tabla:



\- usar `objective\_productive\_corrected\_v96j\_triobjective\_CO2\_fix1`;

\- mantener solar excluido;

\- marcar factores de CO2 como provisionales;

\- no usar smoke outputs como ciencia;

\- proteger v10, v17, v628b, v18 y v95j.



Requisitos pendientes según la tabla:



\- almacenar `F` como matriz de tres columnas;

\- actualizar tablas y reportes finales;

\- almacenar `X`, `F`, población, scores y output;

\- almacenar criterios de selección por separado;

\- ejecutar formal solo después de aprobación explícita.



Criterios de aceptación que bloquean aceptación final:



\- la corrida formal debe completar sin error MATLAB;

\- `F` debe tener exactamente tres columnas;

\- deben existir al menos cinco candidatos híbridos finitos no penalizados;

\- ningún candidato aceptado debe tener `f=\[1000,1e6,1e6]`;

\- replay detallado debe confirmar MR/costo/CO2;

\- deben generarse salidas MAT y CSV;

\- el estado de factores CO2 debe permanecer explícito;

\- los resultados formales no deben promoverse a manuscrito hasta consolidación y auditoría.



\## 9. Dictamen



Gate A cuenta con una configuración candidata coherente para una futura corrida formal híbrida triobjetivo, con:



\- escenario recomendado F1;

\- población 24;

\- 50 generaciones;

\- cuatro variables de decisión;

\- límites formales derivados de `x\_selected ± delta`;

\- control externo de semilla en la variante seed-aware;

\- R1 planeada con semilla 61001;

\- CO2 explícitamente provisional.



Sin embargo, Gate A no queda autorizado para ejecución porque:



\- los factores CO2 siguen en estado provisional;

\- hay rutas absolutas históricas que deben reconciliarse;

\- los checks son evidencia local, no aprobación metodológica;

\- solar permanece penalizado/excluido;

\- faltan requisitos de almacenamiento de resultados;

\- faltan criterios de selección final independientes;

\- aún no se ha verificado la ruta actual `D:\\CODE\\deshidratador` contra los scripts productores y consumidores.



\## 10. Próximo paso recomendado



Antes de cualquier ejecución debe hacerse una inspección estática de correspondencia entre:



\- rutas históricas registradas en F4;

\- ruta actual `D:\\CODE\\deshidratador`;

\- scripts productores;

\- scripts consumidores;

\- archivos versionados en `main`;

\- artefactos externos ignorados por Git.



No debe ejecutarse MATLAB ni `gamultiobj` hasta cerrar esa correspondencia documental.

