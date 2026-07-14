# INSPECT_BOUNDS_SOURCE_v96z_f3

## Purpose

Inspect source lines related to bounds and gamultiobj without executing GA or model.

## Matched lines

| file | line | patterns | text |
|---|---:|---|---|
| `run_guarded_triobjective_formal_ga_v96m` | 35 | `gamultiobj` | `%   - Ejecuta gamultiobj solo si confirm_execute=true.` |
| `run_guarded_triobjective_formal_ga_v96m` | 104 | `lb` | `formalBaseDir = fullfile(rootDir,'05_runs','triobjective_formal_ga_v96m');` |
| `run_guarded_triobjective_formal_ga_v96m` | 105 | `lb` | `formalDir = fullfile(formalBaseDir,['TRIOBJECTIVE_FORMAL_GA_v96m_' timestamp]);` |
| `run_guarded_triobjective_formal_ga_v96m` | 111 | `lb` | `if ~isfolder(formalBaseDir), mkdir(formalBaseDir); end` |
| `run_guarded_triobjective_formal_ga_v96m` | 121 | `lb` | `lb = Sdesign.lb_formal;` |
| `run_guarded_triobjective_formal_ga_v96m` | 122 | `ub` | `ub = Sdesign.ub_formal;` |
| `run_guarded_triobjective_formal_ga_v96m` | 123 | `nvars` | `nvars = Sdesign.nvars;` |
| `run_guarded_triobjective_formal_ga_v96m` | 192 | `gamultiobj` | `% Opciones gamultiobj` |
| `run_guarded_triobjective_formal_ga_v96m` | 194 | `gamultiobj` | `opts = optimoptions('gamultiobj', ...` |
| `run_guarded_triobjective_formal_ga_v96m` | 206 | `nvars` | `X = NaN(0,nvars);` |
| `run_guarded_triobjective_formal_ga_v96m` | 210 | `nvars` | `population = NaN(0,nvars);` |
| `run_guarded_triobjective_formal_ga_v96m` | 231 | `lb, ub, nvars, gamultiobj` | `[X,F,exitflag,output,population,scores] = gamultiobj(objfun, nvars, [], [], [], [], lb, ub, opts); %#ok<ASGLU>` |
| `run_guarded_triobjective_formal_ga_v96m` | 240 | `nvars` | `X = NaN(0,nvars);` |
| `run_guarded_triobjective_formal_ga_v96m` | 244 | `nvars` | `population = NaN(0,nvars);` |
| `run_guarded_triobjective_formal_ga_v96m` | 254 | `ub` | `% Normalizar F si hubo ejecución` |
| `run_guarded_triobjective_formal_ga_v96m` | 270 | `nvars` | `X = NaN(0,nvars);` |
| `run_guarded_triobjective_formal_ga_v96m` | 287 | `lb, ub` | `save(outRawMat,'X','F','exitflag','output','population','scores','runtime_s','run_status','run_error','lb','ub','opts','modeFormal','popSize','maxGen');` |
| `run_guarded_triobjective_formal_ga_v96m` | 341 | `ub` | `runRow.exitflag = double(exitflag);` |
| `run_guarded_triobjective_formal_ga_v96m` | 350 | `ub` | `runRow.generations = double(output.generations);` |
| `run_guarded_triobjective_formal_ga_v96m` | 356 | `ub` | `runRow.funccount = double(output.funccount);` |
| `run_guarded_triobjective_formal_ga_v96m` | 413 | `gamultiobj` | `"If execution is requested, gamultiobj must complete without error.");` |
| `run_guarded_triobjective_formal_ga_v96m` | 485 | `lb, ub, nvars` | `'x_selected','lb','ub','nvars','popSize','maxGen','modeFormal','referenceMode', ...` |
| `run_guarded_triobjective_formal_ga_v96m` | 521 | `nvars` | `fprintf(fid,'\| nvars \| %d \|\n', nvars);` |
| `run_guarded_triobjective_formal_ga_v96m` | 682 | `ub` | `f = double(f(:))';` |
| `run_guarded_triobjective_formal_ga_v96m` | 840 | `ub` | `val = double(tmp(1));` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 47 | `gamultiobj` | `%   - Ejecuta gamultiobj solo si confirm_execute=true.` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 116 | `lb` | `formalBaseDir = fullfile(rootDir,'05_runs','triobjective_formal_ga_v96m');` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 117 | `lb` | `formalDir = fullfile(formalBaseDir,['TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix_' timestamp]);` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 123 | `lb` | `if ~isfolder(formalBaseDir), mkdir(formalBaseDir); end` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 133 | `lb` | `lb = Sdesign.lb_formal;` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 134 | `ub` | `ub = Sdesign.ub_formal;` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 135 | `nvars` | `nvars = Sdesign.nvars;` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 211 | `gamultiobj` | `% Opciones gamultiobj` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 213 | `gamultiobj` | `opts = optimoptions('gamultiobj', ...` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 225 | `nvars` | `X = NaN(0,nvars);` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 229 | `nvars` | `population = NaN(0,nvars);` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 250 | `lb, ub, nvars, gamultiobj` | `[X,F,exitflag,output,population,scores] = gamultiobj(objfun, nvars, [], [], [], [], lb, ub, opts); %#ok<ASGLU>` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 259 | `nvars` | `X = NaN(0,nvars);` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 263 | `nvars` | `population = NaN(0,nvars);` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 273 | `ub` | `% Normalizar F si hubo ejecución` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 289 | `nvars` | `X = NaN(0,nvars);` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 306 | `lb, ub` | `save(outRawMat,'X','F','exitflag','output','population','scores','runtime_s','run_status','run_error','lb','ub','opts','modeFormal','popSize','maxGen');` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 360 | `ub` | `runRow.exitflag = double(exitflag);` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 369 | `ub` | `runRow.generations = double(output.generations);` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 375 | `ub` | `runRow.funccount = double(output.funccount);` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 432 | `gamultiobj` | `"If execution is requested, gamultiobj must complete without error.");` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 504 | `lb, ub, nvars` | `'x_selected','lb','ub','nvars','popSize','maxGen','modeFormal','referenceMode', ...` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 540 | `nvars` | `fprintf(fid,'\| nvars \| %d \|\n', nvars);` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 706 | `ub` | `f = double(f(:))';` |
| `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` | 864 | `ub` | `val = double(tmp(1));` |
| `v96z_rngfix_smoke` | 47 | `gamultiobj` | `%   - Ejecuta gamultiobj solo si confirm_execute=true.` |
| `v96z_rngfix_smoke` | 116 | `lb` | `formalBaseDir = fullfile(rootDir,'05_runs','triobjective_formal_ga_v96m');` |
| `v96z_rngfix_smoke` | 117 | `lb` | `formalDir = fullfile(formalBaseDir,['TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix_SMOKE_' timestamp]);` |
| `v96z_rngfix_smoke` | 123 | `lb` | `if ~isfolder(formalBaseDir), mkdir(formalBaseDir); end` |
| `v96z_rngfix_smoke` | 133 | `lb` | `lb = Sdesign.lb_formal;` |
| `v96z_rngfix_smoke` | 134 | `ub` | `ub = Sdesign.ub_formal;` |
| `v96z_rngfix_smoke` | 135 | `nvars` | `nvars = Sdesign.nvars;` |
| `v96z_rngfix_smoke` | 211 | `gamultiobj` | `% Opciones gamultiobj` |
| `v96z_rngfix_smoke` | 213 | `gamultiobj` | `opts = optimoptions('gamultiobj', ...` |
| `v96z_rngfix_smoke` | 225 | `nvars` | `X = NaN(0,nvars);` |
| `v96z_rngfix_smoke` | 229 | `nvars` | `population = NaN(0,nvars);` |
| `v96z_rngfix_smoke` | 250 | `lb, ub, nvars, gamultiobj` | `[X,F,exitflag,output,population,scores] = gamultiobj(objfun, nvars, [], [], [], [], lb, ub, opts); %#ok<ASGLU>` |
| `v96z_rngfix_smoke` | 259 | `nvars` | `X = NaN(0,nvars);` |
| `v96z_rngfix_smoke` | 263 | `nvars` | `population = NaN(0,nvars);` |
| `v96z_rngfix_smoke` | 273 | `ub` | `% Normalizar F si hubo ejecución` |
| `v96z_rngfix_smoke` | 289 | `nvars` | `X = NaN(0,nvars);` |
| `v96z_rngfix_smoke` | 306 | `lb, ub` | `save(outRawMat,'X','F','exitflag','output','population','scores','runtime_s','run_status','run_error','lb','ub','opts','modeFormal','popSize','maxGen');` |
| `v96z_rngfix_smoke` | 360 | `ub` | `runRow.exitflag = double(exitflag);` |
| `v96z_rngfix_smoke` | 369 | `ub` | `runRow.generations = double(output.generations);` |
| `v96z_rngfix_smoke` | 375 | `ub` | `runRow.funccount = double(output.funccount);` |
| `v96z_rngfix_smoke` | 432 | `gamultiobj` | `"If execution is requested, gamultiobj must complete without error.");` |
| `v96z_rngfix_smoke` | 504 | `lb, ub, nvars` | `'x_selected','lb','ub','nvars','popSize','maxGen','modeFormal','referenceMode', ...` |
| `v96z_rngfix_smoke` | 540 | `nvars` | `fprintf(fid,'\| nvars \| %d \|\n', nvars);` |
| `v96z_rngfix_smoke` | 706 | `ub` | `f = double(f(:))';` |
| `v96z_rngfix_smoke` | 864 | `ub` | `val = double(tmp(1));` |
