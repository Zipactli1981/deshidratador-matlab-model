# PROJECT CHARTER — Deshidratador MATLAB / artículo Q1

## Propósito

Desarrollar, auditar y documentar de forma reproducible el modelo y la optimización multiobjetivo de una planta deshidratadora híbrida solar–GLP, con el objetivo de sustentar un artículo científico Q1.

## Alcance

El proyecto integra:
- modelo térmico del secado;
- optimización multiobjetivo;
- comparación híbrido vs. referencia GLP;
- objetivos de humedad final, costo específico y emisiones específicas;
- trazabilidad física, económica y ambiental;
- análisis de soluciones e integración posterior al manuscrito.

## Arquitectura física preservada

- Calentamiento directo de aire.
- Circuito de agua fuera del alcance.
- Modelo eléctrico limitado al impulsor/ventilador de aire.
- Potencia eléctrica activa: 1.03 kW durante todo el tiempo de secado.
- Eficiencia de quemador: 0.78.
- `Q_aux_tot` representa energía térmica suplementaria útil.
- Energía de combustible GLP: `Q_aux_tot / 0.78`.
- El denominador canónico de `f2` y `f3` es el agua realmente removida.

## Objetivos actuales

```text
f1 = MR_final
f2 = total_cost_USD / water_removed_kg
f3 = total_CO2_kg / water_removed_kg
```

Unidades:

```text
f2 = USD/kg_water_removed
f3 = kgCO2e/kg_water_removed
```

## Principio de reproducibilidad

Las conclusiones científicas deben derivarse de código versionado, artefactos identificables, manifests/auditorías y comparaciones explícitamente documentadas. Chats y memoria conversacional son auxiliares; no sustituyen la evidencia versionada.

## Estado general

La corrección COST-E3D y la nueva `CORRECTED_R1` están completadas y validadas internamente.

La revisión comparativa científica entre las 9 soluciones de `CORRECTED_R1` y
los mismos 9 vectores históricos R1 reevaluados con COST-E3D está cerrada y
validada dentro de su alcance de conjuntos finitos. D019 congeló la
arquitectura narrativa `SYSTEM_FIRST` y D020 cerró el posicionamiento
bibliográfico con estrechamiento explícito de la novedad. La fase vigente es
la reescritura controlada del manuscrito; esto no amplía el alcance científico
ni autoriza nuevas ejecuciones o inferencias sobre convergencia, robustez entre
semillas o globalidad.
