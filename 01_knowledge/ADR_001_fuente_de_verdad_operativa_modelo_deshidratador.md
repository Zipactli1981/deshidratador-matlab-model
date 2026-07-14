\# ADR-001: Fuente de verdad operativa candidata del modelo deshidratador



Estado: Propuesta — no aprobada  

Fecha: 2026-07-14  

Repositorio: Zipactli1981/deshidratador-matlab-model  

Alcance: Selección preliminar de una cadena operativa MATLAB para auditoría y trabajo futuro.  

No autoriza: Ejecuciones formales, cambios físicos/metodológicos, uso científico de resultados ni publicación.



\## 1. Contexto



El repositorio contiene un modelo MATLAB de una planta deshidratadora híbrida solar–gas LP. La documentación raíz describe principalmente la línea consolidada hasta `v1.3-HYBRID-IRR\_COMPARE\_CONSOLIDADA`.



Después de esa etapa, el código evolucionó hacia una cadena más extensa con configuración `v68/v69`, objetivos `objective\_productive\_corrected\_\*` desde `v611` hasta `v96j`, wrappers `opt\_tunel\_mod2\_v10` a `v19`, runner formal triobjetivo `v96m` y runners `v96z` para control de semillas y replicaciones.



La documentación raíz todavía no consolida esa evolución como fuente de verdad operativa oficial.



\## 2. Problema



El repositorio carece de una declaración única, verificable y actualizada que indique qué archivos forman la cadena MATLAB autorizada para preparar, validar y eventualmente ejecutar una corrida formal reproducible.



La ambigüedad proviene de:



\- múltiples runners;

\- wrappers `v10` a `v19`;

\- objetivos `v611` a `v96j`;

\- artefactos `.mat` fuera de Git;

\- factores de CO2 provisionales;

\- documentación raíz desfasada respecto a la evolución `v96m/v96z`.



\## 3. Decisión preliminar



Se propone adoptar únicamente como fuente de verdad operativa candidata para auditoría y validación futura la siguiente secuencia.



Primera etapa acotada:



`run\_seedaware\_formal\_R1\_only\_v96z\_rngfix`



Etapa posterior de reproducibilidad, solo después de cerrar bloqueos:



`run\_seedaware\_minrep\_formal\_ga\_v96z\_rngfix`



Cadena interna candidata:



`run\_guarded\_triobjective\_formal\_ga\_v96m\_seedaware\_v96z\_rngfix`  

→ `objective\_productive\_corrected\_v96j\_triobjective\_CO2\_fix1`  

→ `objective\_productive\_corrected\_v95j\_endpoint\_TMAX\_corrected`  

→ `opt\_tunel\_mod2\_v18\_endpoint\_TMAX\_corrected`  

→ carga ambiental + psicrometría + costo histórico



Esta decisión es preliminar. No declara oficial la cadena ni autoriza ejecución formal.



\## 4. Justificación



La cadena `seed-aware/v18` es técnicamente más defendible que `v69/v10` porque incorpora la evolución formal `v96m/v96z`, el objetivo triobjetivo `v96j fix1` y el wrapper `v18` con endpoint corregido.



Es más defendible que el `v96m` original porque permite aplicar una semilla externa explícita. El `v96m` original fija internamente `rng(614960,'twister')`, lo que puede impedir replicaciones independientes si un runner externo intenta controlar semillas.



El runner `run\_seed\_controlled\_minrep\_formal\_ga\_v96z\_minrep` no se recomienda para nuevas replicaciones porque aplica una semilla externa y después llama al `v96m` original, que puede sobrescribirla.



El wrapper `v19` se mantiene como herramienta de sensibilidad, no como sustituto del `v18`, porque añade una entrada adicional y no aparece como dependencia directa de la cadena formal auditada.



\## 5. Bloqueos para declararla oficial



La cadena candidata no debe declararse oficial hasta cerrar, como mínimo:



\- recuperar o reconstruir `TRIOBJECTIVE\_FORMAL\_RUN\_DESIGN\_v96l.mat`;

\- recuperar o documentar `GAOPTS\_AUDIT\_v96z\_before\_formal\_run\_f4.mat`;

\- definir política de trazabilidad para `05\_runs/`, `06\_outputs/` y artefactos `.mat`;

\- sustituir, justificar o aprobar los factores provisionales de CO2;

\- verificar independencia real de semillas;

\- comparar estáticamente `v17 → v18`;

\- conciliar `README.md`, `MANIFEST.md`, `RUN\_INSTRUCTIONS.md` y `CODEX.md`;

\- documentar versión de MATLAB, toolboxes y entorno de ejecución.



\## 6. Estado recomendado por familia de archivos



| Archivo o familia | Rol | Estado recomendado |

|---|---|---|

| `productive\_run\_config\_v69.m` | Configuración productiva base | Candidata secundaria / baseline |

| `run\_guarded\_triobjective\_formal\_ga\_v96m.m` | Runner formal original | Referencia formal, no recomendado para replicación externa |

| `run\_guarded\_triobjective\_formal\_ga\_v96m\_seedaware\_v96z\_rngfix.m` | Runner formal con semilla externa | Componente de candidata principal |

| `run\_seedaware\_formal\_R1\_only\_v96z\_rngfix.m` | Una corrida formal seed-aware | Candidata principal para Gate A |

| `run\_seedaware\_minrep\_formal\_ga\_v96z\_rngfix.m` | Tres réplicas seed-aware | Candidata principal para Gate B |

| `run\_seed\_controlled\_minrep\_formal\_ga\_v96z\_minrep.m` | Primer runner de tres réplicas | No usar por ahora |

| `objective\_productive\_corrected\_v96j\_triobjective\_CO2\_fix1.m` | Objetivo triobjetivo estabilizado | Componente de candidata principal |

| `objective\_productive\_corrected\_v95j\_endpoint\_TMAX\_corrected.m` | Objetivo biobjetivo con endpoint corregido | Componente de candidata principal |

| `opt\_tunel\_mod2\_v18\_endpoint\_TMAX\_corrected.m` | Wrapper nominal de cadena formal | Componente de candidata principal |

| `opt\_tunel\_mod2\_v19\_eta\_sensitivity.m` | Sensibilidad de eficiencia | Diagnóstico independiente |



Estos estados son recomendaciones de gobernanza. No implican eliminación, renombrado ni obsolescencia.



\## 7. Reglas antes de ejecutar



Antes de cualquier corrida formal debe existir:



\- snapshot de commit;

\- estado limpio del árbol de trabajo;

\- versión de MATLAB y toolboxes;

\- inventario de artefactos externos con hashes;

\- confirmación de factores de CO2;

\- prueba mínima sin `gamultiobj`;

\- aprobación humana explícita;

\- criterios de éxito e interrupción.



`confirm\_execute=true` no debe ser la única barrera de ejecución.



\## 8. Decisiones pendientes



Antes de modificar código o ejecutar MATLAB debe decidirse:



\- si este ADR se adopta como propuesta formal de gobernanza;

\- si la cadena `seed-aware/v18` será la única candidata principal;

\- si R1 debe preceder cualquier minrep;

\- dónde están los artefactos `v96l`, `F4` y `minrep`;

\- si los artefactos externos son recuperables o deben regenerarse;

\- qué política se usará para resultados no versionados;

\- qué factores de CO2 se usarán;

\- si el objetivo futuro será biobjetivo o triobjetivo;

\- cómo se justificará el escenario solar, híbrido y gas LP;

\- cómo se conciliará esta decisión con el manuscrito.



\## 9. Próximo paso recomendado



El cambio mínimo recomendado es documental:



1\. Agregar este ADR en `01\_knowledge/`.

2\. Añadir una nota breve en `README.md`.

3\. Añadir una advertencia breve en `RUN\_INSTRUCTIONS.md`.



No deben modificarse todavía runners, objetivos, wrappers, ecuaciones, parámetros, factores de costo, factores de CO2, resultados, `.gitignore` ni `.gitattributes`.



\## 10. Estado final de esta decisión



Cadena candidata principal:



`run\_seedaware\_formal\_R1\_only\_v96z\_rngfix`  

→ runner formal v96m seed-aware  

→ objective v96j triobjective CO2 fix1  

→ objective v95j endpoint TMAX corrected  

→ wrapper v18 endpoint TMAX corrected  

→ datos ambientales + psicrometría + costo histórico



Cadena candidata posterior para replicación:



`run\_seedaware\_minrep\_formal\_ga\_v96z\_rngfix`



Estado:



PROPUESTA TÉCNICA PRELIMINAR  

NO OFICIAL  

NO AUTORIZADA PARA EJECUCIÓN  

SUJETA A RECUPERACIÓN DE EVIDENCIA Y APROBACIÓN DEL USUARIO

