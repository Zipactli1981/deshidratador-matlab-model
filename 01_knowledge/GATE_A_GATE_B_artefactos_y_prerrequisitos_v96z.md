\# Gate A / Gate B — Artefactos y prerrequisitos v96z



Estado: Documento de clasificación operativa  

Fecha: 2026-07-14  

Repositorio: Zipactli1981/deshidratador-matlab-model  

Relación: Complementa ADR-001 e inventario de artefactos externos v96z  

No autoriza: Ejecución MATLAB, `gamultiobj`, corrida formal, uso científico de resultados ni modificación de código.



\## 1. Propósito



Este documento clasifica los artefactos inventariados para la cadena candidata `v96z` y separa los prerrequisitos de Gate A y Gate B.



El objetivo es distinguir entre entradas obligatorias, evidencia de auditoría, resultados generados, trazabilidad para manuscrito y archivos que requieren inspección adicional.



Este documento no declara oficial la cadena candidata y no autoriza ninguna ejecución.



\## 2. Criterio de clasificación



\- C1: Entrada obligatoria para reproducibilidad.

\- C2: Evidencia de auditoría.

\- C3: Resultado generado.

\- C4: Trazabilidad para manuscrito.

\- C5: Soporte documental.

\- C6: Requiere inspección adicional.



La categoría es operativa, no científica. Un archivo clasificado como evidencia de auditoría no queda automáticamente validado como evidencia científica.



\## 3. Resumen de hallazgos



El inventario `inventario\_artefactos\_externos\_v96z\_20260714.csv` contiene 46 archivos locales con ruta, tamaño, fecha y hash SHA-256.



El inventario confirma la existencia local de artefactos relevantes, incluyendo:



\- `TRIOBJECTIVE\_FORMAL\_RUN\_DESIGN\_v96l.mat`

\- `GAOPTS\_AUDIT\_v96z\_before\_formal\_run\_f4.mat`

\- `MINIMAL\_SEED\_REPLICATION\_DESIGN\_v96z\_minrep.mat`

\- `SEED\_CONTROLLED\_REPLICATION\_RUNNER\_RUNPREP\_v96z\_minrep.mat`

\- artefactos seed-aware asociados a R1

\- auditorías RNG

\- matriz de trazabilidad de costo y CO2



Sin embargo, el inventario no cubre todas las dependencias críticas de Gate A ni Gate B. Faltan piezas de la cadena activa que deben fijarse por commit, como runners, objetivos, wrapper v18, funciones de costo, funciones psicrométricas, loader ambiental y datos consumidos.



\## 4. Gate A: R1 seed-aware



Gate A corresponde a una primera validación acotada de la cadena:



`run\_seedaware\_formal\_R1\_only\_v96z\_rngfix`



Este gate no debe ejecutarse todavía. Primero debe completarse su paquete documental y de inspección.



\### 4.1 Artefactos presentes en el inventario



Artefactos mínimos presentes:



\- `run\_seedaware\_formal\_R1\_only\_v96z\_rngfix.m`

\- `TRIOBJECTIVE\_FORMAL\_RUN\_DESIGN\_v96l.mat`

\- `TRIOBJECTIVE\_FORMAL\_RUN\_DESIGN\_v96l\_scenarios.csv`

\- `TRIOBJECTIVE\_FORMAL\_RUN\_DESIGN\_v96l\_requirements.csv`

\- `TRIOBJECTIVE\_FORMAL\_RUN\_DESIGN\_v96l\_checks.csv`

\- `GAOPTS\_AUDIT\_v96z\_before\_formal\_run\_f4.mat`

\- `GAOPTS\_AUDIT\_v96z\_before\_formal\_run\_f4\_Tbounds.csv`

\- `GAOPTS\_AUDIT\_v96z\_before\_formal\_run\_f4\_Tgaopts.csv`

\- `GAOPTS\_AUDIT\_v96z\_before\_formal\_run\_f4\_Tseed.csv`

\- `GAOPTS\_AUDIT\_v96z\_before\_formal\_run\_f4\_Tchecks.csv`

\- `SEEDAWARE\_FORMAL\_R1\_ONLY\_v96z\_rngfix\_Tplan.csv`

\- `AUDIT\_INTERNAL\_RNG\_v96m\_v96z\_rngfix.md`

\- `audit\_internal\_rng\_v96m\_v96z\_rngfix\_checks.csv`

\- `audit\_internal\_rng\_v96m\_v96z\_rngfix\_hits.csv`

\- `FINAL\_COST\_CO2\_FACTOR\_TRACEABILITY\_MATRIX\_v96z.csv`

\- `FINAL\_COST\_CO2\_FACTOR\_TRACEABILITY\_MATRIX\_v96z.md`



\### 4.2 Dependencias críticas ausentes del inventario



Gate A no queda habilitado solo con el inventario. También deben identificarse y fijarse por commit:



\- `run\_guarded\_triobjective\_formal\_ga\_v96m\_seedaware\_v96z\_rngfix.m`

\- `objective\_productive\_corrected\_v96j\_triobjective\_CO2\_fix1.m`

\- `objective\_productive\_corrected\_v95j\_endpoint\_TMAX\_corrected.m`

\- `opt\_tunel\_mod2\_v18\_endpoint\_TMAX\_corrected.m`

\- `setup\_v05\_paths.m`

\- `build\_cost\_params\_historical.m`

\- `calc\_cost\_breakdown.m`

\- loader ambiental

\- funciones psicrométricas

\- archivos ambientales consumidos

\- versión de MATLAB

\- versión de Global Optimization Toolbox

\- toolboxes adicionales



\### 4.3 Inspecciones pendientes antes de cualquier ejecución



Antes de considerar Gate A documentalmente completo debe inspeccionarse:



\- variables contenidas en `TRIOBJECTIVE\_FORMAL\_RUN\_DESIGN\_v96l.mat`

\- variables contenidas en `GAOPTS\_AUDIT\_v96z\_before\_formal\_run\_f4.mat`

\- correspondencia entre esos `.mat` y el commit actual

\- productor de cada artefacto

\- consumidor de cada artefacto

\- rutas absolutas internas

\- hashes

\- forma de límites

\- opciones de solver

\- semilla prevista

\- coherencia con `ADR-001`



Esta inspección no autoriza ejecución.



\## 5. Gate B: minrep seed-aware



Gate B corresponde a replicaciones mínimas con la cadena seed-aware corregida.



Gate B requiere todo lo de Gate A y, adicionalmente:



\- `run\_seedaware\_minrep\_formal\_ga\_v96z\_rngfix.m`

\- definición documentada y con hash de semillas R1–R3

\- población

\- generaciones

\- límites

\- opciones del solver

\- orden de ejecución

\- criterios de aceptación

\- criterios de interrupción

\- evidencia de que cada semilla llega al runner seed-aware

\- auditoría de que ningún componente posterior restablece el RNG

\- contrato de almacenamiento y hashes para salidas de cada réplica



\### 5.1 Advertencia sobre artefactos minrep anteriores



Los artefactos:



\- `MINIMAL\_SEED\_REPLICATION\_DESIGN\_v96z\_minrep.\*`

\- `SEED\_CONTROLLED\_REPLICATION\_RUNNER\_RUNPREP\_v96z\_minrep.\*`

\- `minimal\_seed\_replication\_design\_v96z\_minrep.csv`



pertenecen nominalmente al primer runner `seed-controlled`, no necesariamente al runner `seed-aware/rngfix`.



No deben reutilizarse automáticamente como entradas válidas para Gate B.



Su uso requiere inspección adicional porque el primer runner minrep podía aplicar una semilla externa y después llamar al `v96m` original, que podía sobrescribirla.



\## 6. Archivos que no deben usarse todavía como evidencia científica



No deben usarse como evidencia científica definitiva:



\- smoke tests de semillas

\- auditorías RNG

\- auditorías GAOPTS

\- checks

\- preflights

\- `SEEDAWARE\_FORMAL\_R1\_ONLY\_v96z\_rngfix.\*`

\- `MINIMAL\_SEED\_REPLICATION\_DESIGN\_v96z\_minrep.\*`

\- `SEED\_CONTROLLED\_REPLICATION\_RUNNER\_RUNPREP\_v96z\_minrep.\*`

\- matriz `FINAL\_COST\_CO2\_FACTOR\_TRACEABILITY\_MATRIX\_v96z.\*` como respaldo definitivo de CO2

\- cualquier `.mat` no inspeccionado

\- cualquier PASS no vinculado a commit, entorno, script generador, entradas, hash y criterio metodológico aprobado

\- cualquier resultado de una sola R1 como demostración de reproducibilidad o convergencia



Estos archivos pueden ser evidencia operativa o de auditoría, pero no sostienen todavía conclusiones físicas, económicas, ambientales o estadísticas.



\## 7. Riesgos principales



Riesgos identificados:



\- el inventario mezcla código versionado y artefactos externos;

\- algunas rutas son locales a `D:\\CODE\\deshidratador`;

\- no se documenta el script exacto que generó cada archivo;

\- no se registra el commit asociado a cada artefacto;

\- los `.mat` no tienen esquema de variables documentado;

\- hay duplicados Markdown/TXT sin precedencia declarada;

\- el diseño minrep anterior puede confundirse con el runner seed-aware corregido;

\- los informes pueden contener PASS autorreferenciales;

\- los factores de CO2 continúan provisionales;

\- el inventario no cubre todas las dependencias de Gate A o Gate B.



\## 8. Decisiones pendientes



Antes de pasar a inspección de `.mat` o cualquier ejecución debe decidirse:



\- si Gate A y Gate B se aceptan como marco de trabajo;

\- si R1 debe preceder obligatoriamente a minrep;

\- qué artefactos se consideran entradas obligatorias;

\- qué artefactos son solo evidencia de auditoría;

\- qué artefactos son resultados generados;

\- qué `.mat` deben inspeccionarse primero;

\- qué columnas adicionales debe tener un inventario v2;

\- qué se considera uso científico permitido;

\- cómo se documentarán productor, consumidor y commit asociado;

\- qué factores de CO2 serán aprobados o sustituidos;

\- cómo se tratarán los artefactos minrep de la cadena seed-controlled anterior.



\## 9. Próximo paso recomendado



El siguiente paso recomendado es una inspección estática segura de los `.mat` de entrada de Gate A, sin ejecutar MATLAB ni `gamultiobj`.



Archivos prioritarios:



\- `TRIOBJECTIVE\_FORMAL\_RUN\_DESIGN\_v96l.mat`

\- `GAOPTS\_AUDIT\_v96z\_before\_formal\_run\_f4.mat`



La inspección debe registrar:



\- variables

\- clases

\- tamaños

\- campos de estructuras

\- rutas absolutas, si existen

\- fechas internas, si existen

\- relación con scripts productores

\- relación con scripts consumidores

\- posible correspondencia con el commit actual



Esta inspección no debe ejecutar el modelo ni el algoritmo genético.

