# CODEX.md — Instrucciones para Codex

## Contexto del proyecto

Este repositorio contiene el proyecto MATLAB del modelo de una planta deshidratadora híbrida solar–gas LP. Incluye modelado dinámico, optimización multiobjetivo, análisis de resultados y soporte para manuscrito/artículo.

Ruta local principal:

D:\CODE\deshidratador

Repositorio GitHub:

https://github.com/Zipactli1981/deshidratador-matlab-model

## Rol esperado de Codex

Codex debe actuar como asistente técnico para programación MATLAB, auditoría, documentación y trazabilidad metodológica.

Debe trabajar de forma conservadora, con cambios pequeños, verificables y reversibles.

## Estructura del repositorio

Carpetas principales:

01_knowledge/
02_src_limpio/
03_original_model/
04_data/
05_runs/
06_manuscript/
06_outputs/
99_legacy_do_not_run/

Archivos principales:

README.md
MANIFEST.md
RUN_INSTRUCTIONS.md
CHANGELOG.md
VERSION.txt
.gitignore
.gitattributes
CODEX.md

## Carpetas prioritarias

### 02_src_limpio/

Es la carpeta principal de código activo MATLAB.

Codex puede proponer cambios aquí, especialmente en:

- config/
- main/
- production/
- validation/
- wrappers/
- cost/
- ga/
- comparison/
- audit/

Antes de modificar funciones MATLAB, Codex debe identificar entradas, salidas, dependencias y scripts que llaman a la función.

### 01_knowledge/

Contiene conocimiento metodológico, notas de implementación, decisiones y matrices.

Codex puede editar documentación aquí si el usuario lo solicita, pero no debe borrar notas históricas sin autorización.

### 06_manuscript/

Contiene material del artículo y tesis.

Codex puede trabajar redacción técnica, consistencia, tablas y trazabilidad textual. No debe cambiar resultados numéricos sin verificar su origen.

## Carpetas restringidas

### 03_original_model/

Es referencia histórica. No modificar salvo autorización explícita.

Si se necesita adaptar código original, copiar o adaptar hacia 02_src_limpio/ manteniendo trazabilidad.

### 99_legacy_do_not_run/

No ejecutar. No modificar salvo autorización explícita.

### 05_runs/ y 06_outputs/

Contienen corridas, salidas o resultados generados.

No modificar, borrar ni versionar resultados sin autorización explícita.

## Archivos binarios o generados

Por defecto, Codex no debe agregar ni modificar:

*.mat
*.fig
*.zip
*.7z
*.rar
*.pdf
*.png
*.html

Solo pueden incluirse si el usuario lo autoriza explícitamente.

## Reglas para MATLAB

Codex debe:

- Mantener coherencia entre nombre de archivo y nombre de función.
- No cambiar firmas de funciones sin revisar dependencias.
- Evitar rutas absolutas innecesarias.
- Preferir configuración centralizada de rutas y parámetros.
- Separar scripts de ejecución y funciones reutilizables.
- No ejecutar optimizaciones largas sin autorización.
- Proponer pruebas pequeñas antes de cambios amplios.
- Mantener comentarios técnicos útiles.

## Temas metodológicos sensibles

Codex debe tener cuidado especial con:

- Física de operación del modelo.
- Balance energético.
- Temperatura.
- Humedad.
- Recirculación.
- Irradiancia.
- Modo híbrido, solar y gas LP.
- Cálculo económico.
- Estimación de CO2.
- Semillas y replicaciones del algoritmo genético.
- Interpretación de frentes de Pareto.
- Trazabilidad hacia manuscrito.

No asumir que un resultado es físicamente válido solo porque el código corre.

## Flujo de trabajo recomendado

Para cada tarea:

1. Diagnóstico.
2. Plan mínimo.
3. Cambio localizado.
4. Prueba mínima.
5. Resumen técnico.
6. Recomendación de commit.

Los commits deben ser pequeños y descriptivos.

Ejemplos:

docs: add Codex project instructions
fix: correct path setup for clean MATLAB source
test: add smoke test for hybrid irradiance modes
refactor: isolate cost parameter construction
docs: update CO2 traceability notes

## Instrucción final

La prioridad del proyecto no es solo que el código corra. Los cambios deben ser defendibles físicamente, trazables metodológicamente y útiles para publicación académica.
