# APPROVED_COMMANDS_MINREP_RUNNER_v96z_minrep_runprep

## Estado

El runner seed-controlled fue creado, pero las réplicas NO se ejecutaron en runprep.

## Primero: preflight sin ejecución

```matlab
addpath(genpath(fullfile(rootDir,'02_src_limpio')));
rehash;

pre = run_seed_controlled_minrep_formal_ga_v96z_minrep(false);
disp(pre.status)
disp(pre.diagnosis)
disp(pre.decision)
disp(pre.next_step)
disp(pre.Treplicates)
disp(pre.Tchecks)
```

## Segundo: aprobación de ejecución

```matlab
approval = approve_seed_controlled_minrep_execution_v96z_minrep();
disp(approval.status)
disp(approval.diagnosis)
disp(approval.approved_command)
```

## Tercero: ejecución real, solo si aceptas ~21.39 h

```matlab
minrepRun = run_seed_controlled_minrep_formal_ga_v96z_minrep(true);
```

## Advertencia

No ejecutar `true` hasta revisar que el preflight esté en PASS.
