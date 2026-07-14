# DATA-B-001 — Nota de parche

La corrección robusta de `load('Mapeo*_temp100621.txt')` debe aplicarse dentro de `opt_tunel_mod2.mlx` o en una versión `.m` controlada derivada de ese live script.

Se agregaron:

```text
03_original_model/03_utilities/get_project_root_original.m
03_original_model/03_utilities/load_environmental_data_original.m
02_src_limpio/main/setup_v05_paths.m
```

Patrón recomendado dentro de `opt_tunel_mod2`:

```matlab
data = load_environmental_data_original('Mapeo4_temp100621.txt');
```

Esto carga desde:

```text
03_original_model/04_data_original/Mapeo4_temp100621.txt
```

No cambia resultados si el archivo es el mismo.
