# AUDIT_INTERNAL_RNG_v96m_v96z_rngfix

## Diagnosis

`V96M_INTERNAL_RNG_AUDIT_FOUND_RNG_CALL`

## Decision

`CREATE_SEED_AWARE_CLONE_REQUIRED`

## Next step

`9.6z-rngfix-b — CREATE-SEED-AWARE-v96m-CLONE-001`

## Source audited

`C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_guarded_triobjective_formal_ga_v96m.m`

## Summary

- rng hits: `1`
- gamultiobj found: `1`
- optimoptions found: `1`
- Tsolutions found: `1`

## Hits

| line | pattern | text |
|---:|---|---|
| 131 | `rng(` | `rng(614960,'twister');` |
| 35 | `gamultiobj` | `%   - Ejecuta gamultiobj solo si confirm_execute=true.` |
| 192 | `gamultiobj` | `% Opciones gamultiobj` |
| 194 | `gamultiobj` | `opts = optimoptions('gamultiobj', ...` |
| 231 | `gamultiobj` | `[X,F,exitflag,output,population,scores] = gamultiobj(objfun, nvars, [], [], [], [], lb, ub, opts); %#ok<ASGLU>` |
| 413 | `gamultiobj` | `"If execution is requested, gamultiobj must complete without error.");` |
| 194 | `optimoptions` | `opts = optimoptions('gamultiobj', ...` |
| 198 | `UseParallel` | `'UseParallel', false, ...` |
| 19 | `PopulationSize` | `%   PopulationSize = 24` |
| 195 | `PopulationSize` | `'PopulationSize', popSize, ...` |
| 222 | `PopulationSize` | `fprintf('PopulationSize: %d\n', popSize);` |
| 519 | `PopulationSize` | `fprintf(fid,'\| PopulationSize \| %d \|\n', popSize);` |
| 20 | `MaxGenerations` | `%   MaxGenerations = 50` |
| 196 | `MaxGenerations` | `'MaxGenerations', maxGen, ...` |
| 223 | `MaxGenerations` | `fprintf('MaxGenerations: %d\n', maxGen);` |
| 520 | `MaxGenerations` | `fprintf(fid,'\| MaxGenerations \| %d \|\n', maxGen);` |
| 287 | `save(` | `save(outRawMat,'X','F','exitflag','output','population','scores','runtime_s','run_status','run_error','lb','ub','opts','modeFormal','popSize','maxGen');` |
| 483 | `save(` | `save(outMat, ...` |
| 314 | `Tsolutions` | `Tsolutions = table();` |
| 316 | `Tsolutions` | `Tsolutions = struct2table(vertcat(solutionRows{:}));` |
| 320 | `Tsolutions` | `writetable(Tsolutions,outSolutionsCsv);` |
| 488 | `Tsolutions` | `'Tpreflight','Trun','Tsolutions','Treference','Tsource','Tchecks', ...` |
| 643 | `Tsolutions` | `formal.Tsolutions = Tsolutions;` |
| 145 | `Tpreflight` | `Tpreflight = struct2table(vertcat(preRows{:}));` |
| 148 | `Tpreflight` | `writetable(Tpreflight,outPreflightCsv);` |
| 150 | `Tpreflight` | `gasPre = Tpreflight(strcmp(string(Tpreflight.mode),"gasLP"),:);` |
| 151 | `Tpreflight` | `hybPre = Tpreflight(strcmp(string(Tpreflight.mode),"hybrid"),:);` |
| 152 | `Tpreflight` | `solPre = Tpreflight(strcmp(string(Tpreflight.mode),"solar"),:);` |
| 488 | `Tpreflight` | `'Tpreflight','Trun','Tsolutions','Treference','Tsource','Tchecks', ...` |
| 528 | `Tpreflight` | `for i = 1:height(Tpreflight)` |
| 530 | `Tpreflight` | `string(Tpreflight.mode(i)), ...` |
| 531 | `Tpreflight` | `string(Tpreflight.status(i)), ...` |
| 532 | `Tpreflight` | `string(Tpreflight.detail_status(i)), ...` |
| 533 | `Tpreflight` | `Tpreflight.nobj(i), ...` |
| 534 | `Tpreflight` | `Tpreflight.f1(i), ...` |
| 535 | `Tpreflight` | `Tpreflight.f2(i), ...` |
| 536 | `Tpreflight` | `Tpreflight.f3(i));` |
| 641 | `Tpreflight` | `formal.Tpreflight = Tpreflight;` |
| 659 | `Tpreflight` | `disp(formal.Tpreflight)` |
| 367 | `Trun` | `Trun = struct2table(runRow);` |
| 370 | `Trun` | `writetable(Trun,outRunCsv);` |
| 488 | `Trun` | `'Tpreflight','Trun','Tsolutions','Treference','Tsource','Tchecks', ...` |
| 543 | `Trun` | `string(Trun.mode(1)), ...` |
| 544 | `Trun` | `string(Trun.run_status(1)), ...` |
| 545 | `Trun` | `Trun.runtime_h(1), ...` |
| 546 | `Trun` | `Trun.exitflag(1), ...` |
| 547 | `Trun` | `Trun.nSolutions(1), ...` |
| 548 | `Trun` | `Trun.nFiniteRows(1), ...` |
| 549 | `Trun` | `Trun.nPenaltyRows(1), ...` |
| 550 | `Trun` | `Trun.minMR(1), ...` |
| 551 | `Trun` | `Trun.minCost(1), ...` |
| 552 | `Trun` | `Trun.minCO2(1));` |
| 642 | `Trun` | `formal.Trun = Trun;` |
| 661 | `Trun` | `disp(formal.Trun)` |

## Context

### Hit 1 — line 131 — `rng(`

```matlab
    128:     popSize = 24;
    129:     maxGen = 50;
    130: 
>>> 131:     rng(614960,'twister');
    132: 
    133:     % ---------------------------------------------------------------------
    134:     % Preflight directo
```

### Hit 2 — line 35 — `gamultiobj`

```matlab
    32: %   - NO modifica v10/v17/v628b/v18/v95j.
    33: %   - NO modifica objective v96j_fix1.
    34: %   - Ejecuta preflight siempre.
>>> 35: %   - Ejecuta gamultiobj solo si confirm_execute=true.
    36: %   - Guarda MAT/CSV/MD/TXT.
    37: %   - Mantiene solar excluido.
    38: %   - Marca CO2 con factores provisionales.
```

### Hit 3 — line 192 — `gamultiobj`

```matlab
    189:     end
    190: 
    191:     % ---------------------------------------------------------------------
>>> 192:     % Opciones gamultiobj
    193:     % ---------------------------------------------------------------------
    194:     opts = optimoptions('gamultiobj', ...
    195:         'PopulationSize', popSize, ...
```

### Hit 4 — line 194 — `gamultiobj`

```matlab
    191:     % ---------------------------------------------------------------------
    192:     % Opciones gamultiobj
    193:     % ---------------------------------------------------------------------
>>> 194:     opts = optimoptions('gamultiobj', ...
    195:         'PopulationSize', popSize, ...
    196:         'MaxGenerations', maxGen, ...
    197:         'Display', 'iter', ...
```

### Hit 5 — line 231 — `gamultiobj`

```matlab
    228:         tStart = tic;
    229: 
    230:         try
>>> 231:             [X,F,exitflag,output,population,scores] = gamultiobj(objfun, nvars, [], [], [], [], lb, ub, opts); %#ok<ASGLU>
    232:             runtime_s = toc(tStart);
    233:             run_status = "OK";
    234:             run_error = "";
```

### Hit 6 — line 413 — `gamultiobj`

```matlab
    410:         "Formal run completed if requested", ...
    411:         (~confirm_execute) || (confirm_execute && strcmp(run_status,"OK")), ...
    412:         sprintf("confirm_execute=%d; run_status=%s; error=%s", confirm_execute, string(run_status), string(run_error)), ...
>>> 413:         "If execution is requested, gamultiobj must complete without error.");
    414: 
    415:     checks{end+1,1} = local_check_row_v96m( ...
    416:         "M06", ...
```

### Hit 7 — line 194 — `optimoptions`

```matlab
    191:     % ---------------------------------------------------------------------
    192:     % Opciones gamultiobj
    193:     % ---------------------------------------------------------------------
>>> 194:     opts = optimoptions('gamultiobj', ...
    195:         'PopulationSize', popSize, ...
    196:         'MaxGenerations', maxGen, ...
    197:         'Display', 'iter', ...
```

### Hit 8 — line 198 — `UseParallel`

```matlab
    195:         'PopulationSize', popSize, ...
    196:         'MaxGenerations', maxGen, ...
    197:         'Display', 'iter', ...
>>> 198:         'UseParallel', false, ...
    199:         'FunctionTolerance', 1e-5, ...
    200:         'ConstraintTolerance', 1e-6, ...
    201:         'PlotFcn', []);
```

### Hit 9 — line 19 — `PopulationSize`

```matlab
    16: % Escenario aprobado en 9.6l:
    17: %   F1 — HYBRID_TRIOBJECTIVE_FORMAL_PLUS_GASLP_REFERENCE
    18: %   Mode = hybrid
>>> 19: %   PopulationSize = 24
    20: %   MaxGenerations = 50
    21: %
    22: % Seguridad:
```

### Hit 10 — line 195 — `PopulationSize`

```matlab
    192:     % Opciones gamultiobj
    193:     % ---------------------------------------------------------------------
    194:     opts = optimoptions('gamultiobj', ...
>>> 195:         'PopulationSize', popSize, ...
    196:         'MaxGenerations', maxGen, ...
    197:         'Display', 'iter', ...
    198:         'UseParallel', false, ...
```

### Hit 11 — line 222 — `PopulationSize`

```matlab
    219:     if confirm_execute
    220:         fprintf('\n=== EXECUTING TRIOBJECTIVE FORMAL GA v96m ===\n');
    221:         fprintf('Mode: %s\n', modeFormal);
>>> 222:         fprintf('PopulationSize: %d\n', popSize);
    223:         fprintf('MaxGenerations: %d\n', maxGen);
    224:         fprintf('Estimated runtime from v96l: %.3f h\n', Sdesign.designFlags.recommended_estimated_runtime_h);
    225: 
```

### Hit 12 — line 519 — `PopulationSize`

```matlab
    516:     fprintf(fid,'## Configuración formal\n\n');
    517:     fprintf(fid,'| Parámetro | Valor |\n');
    518:     fprintf(fid,'|---|---:|\n');
>>> 519:     fprintf(fid,'| PopulationSize | %d |\n', popSize);
    520:     fprintf(fid,'| MaxGenerations | %d |\n', maxGen);
    521:     fprintf(fid,'| nvars | %d |\n', nvars);
    522:     fprintf(fid,'| confirm_execute | %d |\n\n', confirm_execute);
```

### Hit 13 — line 20 — `MaxGenerations`

```matlab
    17: %   F1 — HYBRID_TRIOBJECTIVE_FORMAL_PLUS_GASLP_REFERENCE
    18: %   Mode = hybrid
    19: %   PopulationSize = 24
>>> 20: %   MaxGenerations = 50
    21: %
    22: % Seguridad:
    23: %   confirm_execute = false por defecto.
```

### Hit 14 — line 196 — `MaxGenerations`

```matlab
    193:     % ---------------------------------------------------------------------
    194:     opts = optimoptions('gamultiobj', ...
    195:         'PopulationSize', popSize, ...
>>> 196:         'MaxGenerations', maxGen, ...
    197:         'Display', 'iter', ...
    198:         'UseParallel', false, ...
    199:         'FunctionTolerance', 1e-5, ...
```

### Hit 15 — line 223 — `MaxGenerations`

```matlab
    220:         fprintf('\n=== EXECUTING TRIOBJECTIVE FORMAL GA v96m ===\n');
    221:         fprintf('Mode: %s\n', modeFormal);
    222:         fprintf('PopulationSize: %d\n', popSize);
>>> 223:         fprintf('MaxGenerations: %d\n', maxGen);
    224:         fprintf('Estimated runtime from v96l: %.3f h\n', Sdesign.designFlags.recommended_estimated_runtime_h);
    225: 
    226:         objfun = @(x) objective_productive_corrected_v96j_triobjective_CO2_fix1(x, modeFormal);
```

### Hit 16 — line 520 — `MaxGenerations`

```matlab
    517:     fprintf(fid,'| Parámetro | Valor |\n');
    518:     fprintf(fid,'|---|---:|\n');
    519:     fprintf(fid,'| PopulationSize | %d |\n', popSize);
>>> 520:     fprintf(fid,'| MaxGenerations | %d |\n', maxGen);
    521:     fprintf(fid,'| nvars | %d |\n', nvars);
    522:     fprintf(fid,'| confirm_execute | %d |\n\n', confirm_execute);
    523: 
```

### Hit 17 — line 287 — `save(`

```matlab
    284:     minCO2 = local_min_or_nan_v96m(F,3);
    285: 
    286:     outRawMat = fullfile(matDir,'TRIOBJECTIVE_FORMAL_GA_v96m_raw.mat');
>>> 287:     save(outRawMat,'X','F','exitflag','output','population','scores','runtime_s','run_status','run_error','lb','ub','opts','modeFormal','popSize','maxGen');
    288: 
    289:     % ---------------------------------------------------------------------
    290:     % Soluciones
```

### Hit 18 — line 483 — `save(`

```matlab
    480:     outTxt = fullfile(logsDir,'TRIOBJECTIVE_FORMAL_GA_v96m.txt');
    481:     outMat = fullfile(matDir,'TRIOBJECTIVE_FORMAL_GA_v96m.mat');
    482: 
>>> 483:     save(outMat, ...
    484:         'diagnosis','formalFlags', ...
    485:         'x_selected','lb','ub','nvars','popSize','maxGen','modeFormal','referenceMode', ...
    486:         'confirm_execute','run_status','run_error','runtime_s','exitflag','output', ...
```

### Hit 19 — line 314 — `Tsolutions`

```matlab
    311:     end
    312: 
    313:     if isempty(solutionRows)
>>> 314:         Tsolutions = table();
    315:     else
    316:         Tsolutions = struct2table(vertcat(solutionRows{:}));
    317:     end
```

### Hit 20 — line 316 — `Tsolutions`

```matlab
    313:     if isempty(solutionRows)
    314:         Tsolutions = table();
    315:     else
>>> 316:         Tsolutions = struct2table(vertcat(solutionRows{:}));
    317:     end
    318: 
    319:     outSolutionsCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_GA_v96m_solutions.csv');
```

### Hit 21 — line 320 — `Tsolutions`

```matlab
    317:     end
    318: 
    319:     outSolutionsCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_GA_v96m_solutions.csv');
>>> 320:     writetable(Tsolutions,outSolutionsCsv);
    321: 
    322:     % ---------------------------------------------------------------------
    323:     % Referencia gasLP para x_selected
```

### Hit 22 — line 488 — `Tsolutions`

```matlab
    485:         'x_selected','lb','ub','nvars','popSize','maxGen','modeFormal','referenceMode', ...
    486:         'confirm_execute','run_status','run_error','runtime_s','exitflag','output', ...
    487:         'X','F','population','scores', ...
>>> 488:         'Tpreflight','Trun','Tsolutions','Treference','Tsource','Tchecks', ...
    489:         'objective_v96j_fix1','objective_v95j','wrapper_v10','wrapper_v17','wrapper_v18','objective_v628b', ...
    490:         'designDir','formalDir', ...
    491:         'outMd','outTxt','outMat','outRawMat','outPreflightCsv','outRunCsv','outSolutionsCsv','outReferenceCsv','outSourceCsv','outChecksCsv');
```

### Hit 23 — line 643 — `Tsolutions`

```matlab
    640:     formal.formalFlags = formalFlags;
    641:     formal.Tpreflight = Tpreflight;
    642:     formal.Trun = Trun;
>>> 643:     formal.Tsolutions = Tsolutions;
    644:     formal.Treference = Treference;
    645:     formal.Tchecks = Tchecks;
    646:     formal.Tsource = Tsource;
```

### Hit 24 — line 145 — `Tpreflight`

```matlab
    142:         preRows{end+1,1} = local_preflight_row_v96m(mode, x_selected, f, d0, status, errMsg); %#ok<AGROW>
    143:     end
    144: 
>>> 145:     Tpreflight = struct2table(vertcat(preRows{:}));
    146: 
    147:     outPreflightCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_GA_v96m_preflight.csv');
    148:     writetable(Tpreflight,outPreflightCsv);
```

### Hit 25 — line 148 — `Tpreflight`

```matlab
    145:     Tpreflight = struct2table(vertcat(preRows{:}));
    146: 
    147:     outPreflightCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_GA_v96m_preflight.csv');
>>> 148:     writetable(Tpreflight,outPreflightCsv);
    149: 
    150:     gasPre = Tpreflight(strcmp(string(Tpreflight.mode),"gasLP"),:);
    151:     hybPre = Tpreflight(strcmp(string(Tpreflight.mode),"hybrid"),:);
```

### Hit 26 — line 150 — `Tpreflight`

```matlab
    147:     outPreflightCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_GA_v96m_preflight.csv');
    148:     writetable(Tpreflight,outPreflightCsv);
    149: 
>>> 150:     gasPre = Tpreflight(strcmp(string(Tpreflight.mode),"gasLP"),:);
    151:     hybPre = Tpreflight(strcmp(string(Tpreflight.mode),"hybrid"),:);
    152:     solPre = Tpreflight(strcmp(string(Tpreflight.mode),"solar"),:);
    153: 
```

### Hit 27 — line 151 — `Tpreflight`

```matlab
    148:     writetable(Tpreflight,outPreflightCsv);
    149: 
    150:     gasPre = Tpreflight(strcmp(string(Tpreflight.mode),"gasLP"),:);
>>> 151:     hybPre = Tpreflight(strcmp(string(Tpreflight.mode),"hybrid"),:);
    152:     solPre = Tpreflight(strcmp(string(Tpreflight.mode),"solar"),:);
    153: 
    154:     preflight_pass = ...
```

### Hit 28 — line 152 — `Tpreflight`

```matlab
    149: 
    150:     gasPre = Tpreflight(strcmp(string(Tpreflight.mode),"gasLP"),:);
    151:     hybPre = Tpreflight(strcmp(string(Tpreflight.mode),"hybrid"),:);
>>> 152:     solPre = Tpreflight(strcmp(string(Tpreflight.mode),"solar"),:);
    153: 
    154:     preflight_pass = ...
    155:         strcmp(string(gasPre.status(1)),"OK") && gasPre.nobj(1)==3 && strcmp(string(gasPre.detail_status(1)),"OK") && ...
```

### Hit 29 — line 488 — `Tpreflight`

```matlab
    485:         'x_selected','lb','ub','nvars','popSize','maxGen','modeFormal','referenceMode', ...
    486:         'confirm_execute','run_status','run_error','runtime_s','exitflag','output', ...
    487:         'X','F','population','scores', ...
>>> 488:         'Tpreflight','Trun','Tsolutions','Treference','Tsource','Tchecks', ...
    489:         'objective_v96j_fix1','objective_v95j','wrapper_v10','wrapper_v17','wrapper_v18','objective_v628b', ...
    490:         'designDir','formalDir', ...
    491:         'outMd','outTxt','outMat','outRawMat','outPreflightCsv','outRunCsv','outSolutionsCsv','outReferenceCsv','outSourceCsv','outChecksCsv');
```

### Hit 30 — line 528 — `Tpreflight`

```matlab
    525:     fprintf(fid,'| mode | status | detail | nobj | f1 MR | f2 cost | f3 CO2 |\n');
    526:     fprintf(fid,'|---|---|---|---:|---:|---:|---:|\n');
    527: 
>>> 528:     for i = 1:height(Tpreflight)
    529:         fprintf(fid,'| `%s` | `%s` | `%s` | %d | %.12g | %.12g | %.12g |\n', ...
    530:             string(Tpreflight.mode(i)), ...
    531:             string(Tpreflight.status(i)), ...
```

### Hit 31 — line 530 — `Tpreflight`

```matlab
    527: 
    528:     for i = 1:height(Tpreflight)
    529:         fprintf(fid,'| `%s` | `%s` | `%s` | %d | %.12g | %.12g | %.12g |\n', ...
>>> 530:             string(Tpreflight.mode(i)), ...
    531:             string(Tpreflight.status(i)), ...
    532:             string(Tpreflight.detail_status(i)), ...
    533:             Tpreflight.nobj(i), ...
```

### Hit 32 — line 531 — `Tpreflight`

```matlab
    528:     for i = 1:height(Tpreflight)
    529:         fprintf(fid,'| `%s` | `%s` | `%s` | %d | %.12g | %.12g | %.12g |\n', ...
    530:             string(Tpreflight.mode(i)), ...
>>> 531:             string(Tpreflight.status(i)), ...
    532:             string(Tpreflight.detail_status(i)), ...
    533:             Tpreflight.nobj(i), ...
    534:             Tpreflight.f1(i), ...
```

### Hit 33 — line 532 — `Tpreflight`

```matlab
    529:         fprintf(fid,'| `%s` | `%s` | `%s` | %d | %.12g | %.12g | %.12g |\n', ...
    530:             string(Tpreflight.mode(i)), ...
    531:             string(Tpreflight.status(i)), ...
>>> 532:             string(Tpreflight.detail_status(i)), ...
    533:             Tpreflight.nobj(i), ...
    534:             Tpreflight.f1(i), ...
    535:             Tpreflight.f2(i), ...
```

### Hit 34 — line 533 — `Tpreflight`

```matlab
    530:             string(Tpreflight.mode(i)), ...
    531:             string(Tpreflight.status(i)), ...
    532:             string(Tpreflight.detail_status(i)), ...
>>> 533:             Tpreflight.nobj(i), ...
    534:             Tpreflight.f1(i), ...
    535:             Tpreflight.f2(i), ...
    536:             Tpreflight.f3(i));
```

### Hit 35 — line 534 — `Tpreflight`

```matlab
    531:             string(Tpreflight.status(i)), ...
    532:             string(Tpreflight.detail_status(i)), ...
    533:             Tpreflight.nobj(i), ...
>>> 534:             Tpreflight.f1(i), ...
    535:             Tpreflight.f2(i), ...
    536:             Tpreflight.f3(i));
    537:     end
```

### Hit 36 — line 535 — `Tpreflight`

```matlab
    532:             string(Tpreflight.detail_status(i)), ...
    533:             Tpreflight.nobj(i), ...
    534:             Tpreflight.f1(i), ...
>>> 535:             Tpreflight.f2(i), ...
    536:             Tpreflight.f3(i));
    537:     end
    538: 
```

### Hit 37 — line 536 — `Tpreflight`

```matlab
    533:             Tpreflight.nobj(i), ...
    534:             Tpreflight.f1(i), ...
    535:             Tpreflight.f2(i), ...
>>> 536:             Tpreflight.f3(i));
    537:     end
    538: 
    539:     fprintf(fid,'\n## Resumen de corrida\n\n');
```

### Hit 38 — line 641 — `Tpreflight`

```matlab
    638:     formal.status = 'TRIOBJECTIVE_FORMAL_GA_v96m_COMPLETED';
    639:     formal.diagnosis = diagnosis;
    640:     formal.formalFlags = formalFlags;
>>> 641:     formal.Tpreflight = Tpreflight;
    642:     formal.Trun = Trun;
    643:     formal.Tsolutions = Tsolutions;
    644:     formal.Treference = Treference;
```

### Hit 39 — line 659 — `Tpreflight`

```matlab
    656:     disp('=== FORMAL FLAGS ===')
    657:     disp(formal.formalFlags)
    658:     disp('=== PREFLIGHT ===')
>>> 659:     disp(formal.Tpreflight)
    660:     disp('=== RUN SUMMARY ===')
    661:     disp(formal.Trun)
    662:     disp('=== CHECKS ===')
```

### Hit 40 — line 367 — `Trun`

```matlab
    364:         runRow.output_message = "";
    365:     end
    366: 
>>> 367:     Trun = struct2table(runRow);
    368: 
    369:     outRunCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_GA_v96m_run_summary.csv');
    370:     writetable(Trun,outRunCsv);
```

### Hit 41 — line 370 — `Trun`

```matlab
    367:     Trun = struct2table(runRow);
    368: 
    369:     outRunCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_GA_v96m_run_summary.csv');
>>> 370:     writetable(Trun,outRunCsv);
    371: 
    372:     % ---------------------------------------------------------------------
    373:     % Checks
```

### Hit 42 — line 488 — `Trun`

```matlab
    485:         'x_selected','lb','ub','nvars','popSize','maxGen','modeFormal','referenceMode', ...
    486:         'confirm_execute','run_status','run_error','runtime_s','exitflag','output', ...
    487:         'X','F','population','scores', ...
>>> 488:         'Tpreflight','Trun','Tsolutions','Treference','Tsource','Tchecks', ...
    489:         'objective_v96j_fix1','objective_v95j','wrapper_v10','wrapper_v17','wrapper_v18','objective_v628b', ...
    490:         'designDir','formalDir', ...
    491:         'outMd','outTxt','outMat','outRawMat','outPreflightCsv','outRunCsv','outSolutionsCsv','outReferenceCsv','outSourceCsv','outChecksCsv');
```

### Hit 43 — line 543 — `Trun`

```matlab
    540:     fprintf(fid,'| mode | run_status | runtime_h | exitflag | nSolutions | nFiniteRows | nPenaltyRows | minMR | minCost | minCO2 |\n');
    541:     fprintf(fid,'|---|---|---:|---:|---:|---:|---:|---:|---:|---:|\n');
    542:     fprintf(fid,'| `%s` | `%s` | %.6f | %.0f | %d | %d | %d | %.12g | %.12g | %.12g |\n', ...
>>> 543:         string(Trun.mode(1)), ...
    544:         string(Trun.run_status(1)), ...
    545:         Trun.runtime_h(1), ...
    546:         Trun.exitflag(1), ...
```

### Hit 44 — line 544 — `Trun`

```matlab
    541:     fprintf(fid,'|---|---|---:|---:|---:|---:|---:|---:|---:|---:|\n');
    542:     fprintf(fid,'| `%s` | `%s` | %.6f | %.0f | %d | %d | %d | %.12g | %.12g | %.12g |\n', ...
    543:         string(Trun.mode(1)), ...
>>> 544:         string(Trun.run_status(1)), ...
    545:         Trun.runtime_h(1), ...
    546:         Trun.exitflag(1), ...
    547:         Trun.nSolutions(1), ...
```

### Hit 45 — line 545 — `Trun`

```matlab
    542:     fprintf(fid,'| `%s` | `%s` | %.6f | %.0f | %d | %d | %d | %.12g | %.12g | %.12g |\n', ...
    543:         string(Trun.mode(1)), ...
    544:         string(Trun.run_status(1)), ...
>>> 545:         Trun.runtime_h(1), ...
    546:         Trun.exitflag(1), ...
    547:         Trun.nSolutions(1), ...
    548:         Trun.nFiniteRows(1), ...
```

### Hit 46 — line 546 — `Trun`

```matlab
    543:         string(Trun.mode(1)), ...
    544:         string(Trun.run_status(1)), ...
    545:         Trun.runtime_h(1), ...
>>> 546:         Trun.exitflag(1), ...
    547:         Trun.nSolutions(1), ...
    548:         Trun.nFiniteRows(1), ...
    549:         Trun.nPenaltyRows(1), ...
```

### Hit 47 — line 547 — `Trun`

```matlab
    544:         string(Trun.run_status(1)), ...
    545:         Trun.runtime_h(1), ...
    546:         Trun.exitflag(1), ...
>>> 547:         Trun.nSolutions(1), ...
    548:         Trun.nFiniteRows(1), ...
    549:         Trun.nPenaltyRows(1), ...
    550:         Trun.minMR(1), ...
```

### Hit 48 — line 548 — `Trun`

```matlab
    545:         Trun.runtime_h(1), ...
    546:         Trun.exitflag(1), ...
    547:         Trun.nSolutions(1), ...
>>> 548:         Trun.nFiniteRows(1), ...
    549:         Trun.nPenaltyRows(1), ...
    550:         Trun.minMR(1), ...
    551:         Trun.minCost(1), ...
```

### Hit 49 — line 549 — `Trun`

```matlab
    546:         Trun.exitflag(1), ...
    547:         Trun.nSolutions(1), ...
    548:         Trun.nFiniteRows(1), ...
>>> 549:         Trun.nPenaltyRows(1), ...
    550:         Trun.minMR(1), ...
    551:         Trun.minCost(1), ...
    552:         Trun.minCO2(1));
```

### Hit 50 — line 550 — `Trun`

```matlab
    547:         Trun.nSolutions(1), ...
    548:         Trun.nFiniteRows(1), ...
    549:         Trun.nPenaltyRows(1), ...
>>> 550:         Trun.minMR(1), ...
    551:         Trun.minCost(1), ...
    552:         Trun.minCO2(1));
    553: 
```

### Hit 51 — line 551 — `Trun`

```matlab
    548:         Trun.nFiniteRows(1), ...
    549:         Trun.nPenaltyRows(1), ...
    550:         Trun.minMR(1), ...
>>> 551:         Trun.minCost(1), ...
    552:         Trun.minCO2(1));
    553: 
    554:     fprintf(fid,'\n## Referencia gasLP en x_selected\n\n');
```

### Hit 52 — line 552 — `Trun`

```matlab
    549:         Trun.nPenaltyRows(1), ...
    550:         Trun.minMR(1), ...
    551:         Trun.minCost(1), ...
>>> 552:         Trun.minCO2(1));
    553: 
    554:     fprintf(fid,'\n## Referencia gasLP en x_selected\n\n');
    555:     fprintf(fid,'| mode | status | detail | f1 MR | f2 cost | f3 CO2 |\n');
```

### Hit 53 — line 642 — `Trun`

```matlab
    639:     formal.diagnosis = diagnosis;
    640:     formal.formalFlags = formalFlags;
    641:     formal.Tpreflight = Tpreflight;
>>> 642:     formal.Trun = Trun;
    643:     formal.Tsolutions = Tsolutions;
    644:     formal.Treference = Treference;
    645:     formal.Tchecks = Tchecks;
```

### Hit 54 — line 661 — `Trun`

```matlab
    658:     disp('=== PREFLIGHT ===')
    659:     disp(formal.Tpreflight)
    660:     disp('=== RUN SUMMARY ===')
>>> 661:     disp(formal.Trun)
    662:     disp('=== CHECKS ===')
    663:     disp(formal.Tchecks)
    664:     disp('=== OUTPUT FILES ===')
```

## Checks

| id | check | pass | evidence |
|---|---|---:|---|
| `RNG_A01` | v96m file exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_guarded_triobjective_formal_ga_v96m.m` |
| `RNG_A02` | v96m read successfully | 1 | `nLines=875` |
| `RNG_A03` | rng audit performed | 1 | `rng_hits=1` |
| `RNG_A04` | gamultiobj located | 1 | `has_gamultiobj=1` |
| `RNG_A05` | optimoptions located | 1 | `has_optimoptions=1` |
| `RNG_A06` | Tsolutions located | 1 | `has_Tsolutions=1` |
| `RNG_A07` | No GA executed | 1 | `No gamultiobj call; only text scan.` |
| `RNG_A08` | No model executed | 1 | `No objective/model call.` |
| `RNG_A09` | No source modified | 1 | `Audit only.` |
