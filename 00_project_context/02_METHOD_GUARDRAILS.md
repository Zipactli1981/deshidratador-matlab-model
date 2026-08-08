# METHOD GUARDRAILS — Deshidratador MATLAB / Q1

## Jerarquía de evidencia

1. `01_CURRENT_STATE.md`
2. `05_PHASE_HANDOFF_CURRENT.md`
3. manifests y auditorías canónicas
4. código y objetos Git
5. artefactos de corrida
6. chats previos

Si un chat antiguo contradice un estado canónico posterior, prevalece el estado canónico posterior.

## Separación conceptual

Distinguir siempre:
- evidencia;
- inferencia;
- decisión metodológica;
- resultado operativo;
- interpretación científica.

## Ejecución

Requieren autorización explícita en la conversación actual:
- MATLAB para cálculos;
- `gamultiobj`;
- nueva optimización;
- replays adicionales de objective;
- R2/R3/minrep/400gen;
- sensibilidad que evalúe modelo/objective.

No interpretar una autorización de inspección como autorización de optimización.

## Git

Distinguir:
- cambios locales;
- commit local;
- push;
- PR;
- merge;
- cambios remotos.

Push, PR, merge y operaciones remotas requieren autorización explícita.

## Código productivo

No modificar objective, modelo, wrappers o funciones de costo sólo para facilitar una auditoría o comparación.

## Pareto y comparación

- Los 9 vectores históricos reevaluados NO son el Pareto corregido.
- Las 9 soluciones `CORRECTED_R1` están internamente validadas, pero la interpretación comparativa está pendiente.
- No declarar un frente Pareto definitivo sin revisión específica.
- No usar `f2/f3` históricos antiguos como si pertenecieran a COST-E3D.
- Para comparación justa, usar los vectores históricos reevaluados bajo la formulación corregida.

## Manuscrito

No incorporar resultados como definitivos hasta completar:
1. validación interna;
2. revisión comparativa;
3. dominancia/métricas que se determine pertinente;
4. interpretación física/económica/ambiental;
5. revisión de afirmaciones cuantitativas.

## Contexto

No reconstruir fases cerradas salvo que una decisión nueva dependa de evidencia específica. Mantener handoffs compactos.

## Implementación comparativa postrun

El protocolo comparativo v1.0 está metodológicamente congelado y aprobado para implementación postrun.

Esto NO implica autorización automática de ejecución.

Los scripts comparativos postrun podrán autorizarse de forma separada únicamente para:
- leer artefactos existentes;
- construir el dataset de 18 soluciones;
- calcular dominancia, cobertura, Pareto rank y métricas aprobadas;
- generar tablas y figuras.

No podrán:
- evaluar nuevamente el modelo u objective;
- llamar a `gamultiobj`;
- iniciar nuevas optimizaciones;
- modificar código productivo.

El inicio de cada bloque operativo CR1-COMP requiere autorización explícita en la conversación vigente.
