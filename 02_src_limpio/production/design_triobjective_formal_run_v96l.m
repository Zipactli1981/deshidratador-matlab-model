function design = design_triobjective_formal_run_v96l()
% DESIGN_TRIOBJECTIVE_FORMAL_RUN_v96l
% 9.6l — TRIOBJECTIVE-FORMAL-RUN-DESIGN-001
%
% Objetivo:
%   Diseñar la corrida formal triobjetivo:
%
%       f(1) = MR_final
%       f(2) = cost_specific_USD_per_kgwater
%       f(3) = CO2_specific_kgCO2_per_kgwater
%
% Función objetivo formal candidata:
%   objective_productive_corrected_v96j_triobjective_CO2_fix1
%
% Este micropaso:
%   - NO ejecuta gamultiobj.
%   - NO modifica v10/v17/v628b/v18/v95j.
%   - NO modifica objective v96j_fix1.
%   - Diseña población, generaciones, escenarios y criterios.
%   - Mantiene la corrida formal detenida.
%   - Señala que factores de emisión siguen provisionales.
%
% Uso:
%   design = design_triobjective_formal_run_v96l();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Cargar smoke triobjetivo 9.6k
    % ---------------------------------------------------------------------
    smokeBaseDir = fullfile(rootDir,'05_runs','triobjective_smoke_ga_v96k');

    if ~isfolder(smokeBaseDir)
        error('No existe smokeBaseDir: %s', smokeBaseDir);
    end

    d = dir(smokeBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'TRIOBJECTIVE_SMOKE_GA_v96k_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró smoke v96k.');
    end

    [~,idxSmoke] = max([d.datenum]);
    smokeDir = fullfile(smokeBaseDir,d(idxSmoke).name);
    smokeMat = fullfile(smokeDir,'mat','TRIOBJECTIVE_SMOKE_GA_v96k.mat');

    if ~isfile(smokeMat)
        error('No existe MAT v96k: %s', smokeMat);
    end

    Ssmoke = load(smokeMat);

    if ~strcmp(string(Ssmoke.diagnosis),"GUARDED_TRIOBJECTIVE_SMOKE_GA_PASS")
        error('Smoke v96k no está en PASS. Diagnosis: %s', string(Ssmoke.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Archivos protegidos y función candidata
    % ---------------------------------------------------------------------
    objective_v96j_fix1 = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v96j_triobjective_CO2_fix1.m');
    objective_v95j = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v95j_endpoint_TMAX_corrected.m');
    wrapper_v10 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v10_energy_mode_corrected.m');
    wrapper_v17 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v17_nonphysical_penalty.m');
    wrapper_v18 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v18_endpoint_TMAX_corrected.m');
    objective_v628b = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v628b_nonphysical_penalty.m');

    if exist('objective_productive_corrected_v96j_triobjective_CO2_fix1','file') ~= 2
        error('No está visible objective_productive_corrected_v96j_triobjective_CO2_fix1.');
    end

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    designBaseDir = fullfile(rootDir,'05_runs','triobjective_formal_run_design_v96l');
    designDir = fullfile(designBaseDir,['TRIOBJECTIVE_FORMAL_RUN_DESIGN_v96l_' timestamp]);

    logsDir = fullfile(designDir,'logs');
    tablesDir = fullfile(designDir,'tables');
    matDir = fullfile(designDir,'mat');

    if ~isfolder(designBaseDir), mkdir(designBaseDir); end
    if ~isfolder(designDir), mkdir(designDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Configuración base de variables
    % ---------------------------------------------------------------------
    x_selected = [ ...
        0.0740767982118, ...
        62.6832965028, ...
        0.672252618341, ...
        11.6517528081];

    lb_global = [0.05, 55, 0.00, 8.00];
    ub_global = [0.12, 70, 0.95, 14.00];

    delta_formal = [0.020, 5.0, 0.25, 3.0];

    lb_formal = max(lb_global, x_selected - delta_formal);
    ub_formal = min(ub_global, x_selected + delta_formal);

    nvars = 4;

    % ---------------------------------------------------------------------
    % Runtime base desde smoke
    % ---------------------------------------------------------------------
    TrunsSmoke = Ssmoke.Truns;

    gasSmoke = TrunsSmoke(strcmp(string(TrunsSmoke.mode),"gasLP"),:);
    hybSmoke = TrunsSmoke(strcmp(string(TrunsSmoke.mode),"hybrid"),:);

    if isempty(gasSmoke) || isempty(hybSmoke)
        error('Smoke v96k no contiene gasLP e hybrid.');
    end

    gas_runtime_s = gasSmoke.runtime_s(1);
    hyb_runtime_s = hybSmoke.runtime_s(1);

    gas_funccount = gasSmoke.funccount(1);
    hyb_funccount = hybSmoke.funccount(1);

    sec_per_eval_gas = gas_runtime_s / gas_funccount;
    sec_per_eval_hyb = hyb_runtime_s / hyb_funccount;

    sec_per_eval_ref = max(sec_per_eval_gas, sec_per_eval_hyb);

    % ---------------------------------------------------------------------
    % Escenarios formales
    % ---------------------------------------------------------------------
    % Estimación simple:
    %   eval_count ~= PopulationSize * (MaxGenerations + 1)
    %   runtime ~= eval_count * sec_per_eval_ref * nModes * margin
    %
    % nModes:
    %   F1: hybrid formal + gasLP reference post-eval.
    %   F2: hybrid formal + gasLP formal separate.
    %
    % Para artículo triobjetivo, la recomendación operativa sigue siendo:
    %   F1: formal hybrid triobjetivo y referencia gasLP por evaluación/comparación.
    %
    % Razón:
    %   La decisión física central es demostrar trade-off triobjetivo del modo híbrido.
    %   gasLP queda como referencia comparativa, no necesariamente como segundo frente
    %   formal completo, salvo que se busque comparar dos frentes.

    scenarios = {};

    scenarios{end+1,1} = local_scenario_row_v96l( ...
        "F1", ...
        "HYBRID_TRIOBJECTIVE_FORMAL_PLUS_GASLP_REFERENCE", ...
        "hybrid", ...
        24, ...
        50, ...
        1, ...
        true, ...
        "Recommended minimum formal triobjective route.", ...
        sec_per_eval_ref);

    scenarios{end+1,1} = local_scenario_row_v96l( ...
        "F2", ...
        "HYBRID_TRIOBJECTIVE_BALANCED_PLUS_GASLP_REFERENCE", ...
        "hybrid", ...
        32, ...
        80, ...
        1, ...
        false, ...
        "More robust front, higher runtime.", ...
        sec_per_eval_ref);

    scenarios{end+1,1} = local_scenario_row_v96l( ...
        "F3", ...
        "FULL_COMPARATIVE_GASLP_AND_HYBRID_TRIOBJECTIVE", ...
        "gasLP_and_hybrid", ...
        32, ...
        80, ...
        2, ...
        false, ...
        "Formal fronts for both modes; highest runtime.", ...
        sec_per_eval_ref);

    Tscenarios = struct2table(vertcat(scenarios{:}));

    % ---------------------------------------------------------------------
    % Direct formal preflight candidate
    % ---------------------------------------------------------------------
    modesPreflight = ["gasLP","hybrid","solar"];
    preRows = {};

    for i = 1:numel(modesPreflight)
        mode = modesPreflight(i);
        [f, d, status, errMsg] = local_eval_triobjective_v96l(x_selected, mode);
        preRows{end+1,1} = local_preflight_row_v96l(mode, x_selected, f, d, status, errMsg); %#ok<AGROW>
    end

    Tpreflight = struct2table(vertcat(preRows{:}));

    gasPre = Tpreflight(strcmp(string(Tpreflight.mode),"gasLP"),:);
    hybPre = Tpreflight(strcmp(string(Tpreflight.mode),"hybrid"),:);
    solPre = Tpreflight(strcmp(string(Tpreflight.mode),"solar"),:);

    preflight_pass = ...
        strcmp(string(gasPre.status(1)),"OK") && gasPre.nobj(1)==3 && strcmp(string(gasPre.detail_status(1)),"OK") && ...
        strcmp(string(hybPre.status(1)),"OK") && hybPre.nobj(1)==3 && strcmp(string(hybPre.detail_status(1)),"OK") && ...
        solPre.nobj(1)==3 && solPre.f1(1)>=999.999 && solPre.f2(1)>=999999.999 && solPre.f3(1)>=999999.999;

    % ---------------------------------------------------------------------
    % Requisitos para corrida formal
    % ---------------------------------------------------------------------
    reqRows = {};

    reqRows{end+1,1} = local_req_row_v96l("R01","Use v96j_fix1 objective",true,true,"objective_productive_corrected_v96j_triobjective_CO2_fix1.");
    reqRows{end+1,1} = local_req_row_v96l("R02","Keep solar excluded",true,true,"Solar remains penalized [1000,1e6,1e6].");
    reqRows{end+1,1} = local_req_row_v96l("R03","Use F as 3-column matrix",true,false,"Formal script must store MR, cost and CO2.");
    reqRows{end+1,1} = local_req_row_v96l("R04","Update final tables and reports",true,false,"Output tables must include f1/f2/f3 labels.");
    reqRows{end+1,1} = local_req_row_v96l("R05","Store raw X,F,population,scores,output",true,false,"Required for reproducibility.");
    reqRows{end+1,1} = local_req_row_v96l("R06","Store selected solution criteria separately",true,false,"Selection cannot assume 2D Pareto only.");
    reqRows{end+1,1} = local_req_row_v96l("R07","Flag emission factors as provisional",true,true,"No manuscript-final CO2 claims until factors confirmed.");
    reqRows{end+1,1} = local_req_row_v96l("R08","Do not use smoke outputs as science",true,true,"Smoke only validates execution path.");
    reqRows{end+1,1} = local_req_row_v96l("R09","Run formal only after explicit user approval",true,false,"Formal run will take hours.");
    reqRows{end+1,1} = local_req_row_v96l("R10","Protect v10/v17/v628b/v18/v95j",true,true,"No source overwrite.");

    Trequirements = struct2table(vertcat(reqRows{:}));

    % ---------------------------------------------------------------------
    % Criterios de aceptación formal
    % ---------------------------------------------------------------------
    accRows = {};

    accRows{end+1,1} = local_acceptance_row_v96l("A01","Formal GA completes without MATLAB error.",true);
    accRows{end+1,1} = local_acceptance_row_v96l("A02","F has exactly 3 columns.",true);
    accRows{end+1,1} = local_acceptance_row_v96l("A03","At least 5 finite non-penalized hybrid Pareto candidates.",true);
    accRows{end+1,1} = local_acceptance_row_v96l("A04","No accepted candidate has f=[1000,1e6,1e6].",true);
    accRows{end+1,1} = local_acceptance_row_v96l("A05","For selected candidates, detail replay confirms MR/cost/CO2.",true);
    accRows{end+1,1} = local_acceptance_row_v96l("A06","Raw MAT and CSV outputs are generated.",true);
    accRows{end+1,1} = local_acceptance_row_v96l("A07","CO2 factor status remains explicitly logged.",true);
    accRows{end+1,1} = local_acceptance_row_v96l("A08","Formal results are not promoted to manuscript until consolidated/audited.",true);

    Tacceptance = struct2table(vertcat(accRows{:}));

    % ---------------------------------------------------------------------
    % Source scan
    % ---------------------------------------------------------------------
    sourceRows = {};

    sourceRows{end+1,1} = local_source_row_v96l("objective_v96j_fix1_exists", objective_v96j_fix1, "", isfile(objective_v96j_fix1), "Triobjective objective fix1 exists.");
    sourceRows{end+1,1} = local_source_row_v96l("objective_v95j_preserved", objective_v95j, "", isfile(objective_v95j), "v95j preserved.");
    sourceRows{end+1,1} = local_source_row_v96l("wrapper_v10_preserved", wrapper_v10, "", isfile(wrapper_v10), "v10 preserved.");
    sourceRows{end+1,1} = local_source_row_v96l("wrapper_v17_preserved", wrapper_v17, "", isfile(wrapper_v17), "v17 preserved.");
    sourceRows{end+1,1} = local_source_row_v96l("wrapper_v18_preserved", wrapper_v18, "", isfile(wrapper_v18), "v18 preserved.");
    sourceRows{end+1,1} = local_source_row_v96l("objective_v628b_preserved", objective_v628b, "", isfile(objective_v628b), "v628b preserved.");

    sourceRows{end+1,1} = local_source_contains_v96l("fix1_calls_v95j", objective_v96j_fix1, "objective_productive_corrected_v95j_endpoint_TMAX_corrected", "fix1 calls validated v95j.");
    sourceRows{end+1,1} = local_source_contains_v96l("fix1_has_1x3_valid_f", objective_v96j_fix1, "f = [f_base(1), f_base(2), CO2_specific_kgCO2_per_kgwater];", "fix1 builds 1x3 objective.");
    sourceRows{end+1,1} = local_source_contains_v96l("fix1_has_1x3_penalty", objective_v96j_fix1, "penalty = [1000, 1e6, 1e6];", "fix1 has 1x3 penalty.");
    sourceRows{end+1,1} = local_source_contains_v96l("fix1_has_provisional_factors", objective_v96j_fix1, "PROVISIONAL_FOR_CODE_VALIDATION", "fix1 marks provisional factors.");

    Tsource = struct2table(vertcat(sourceRows{:}));

    % ---------------------------------------------------------------------
    % Checks de diseño
    % ---------------------------------------------------------------------
    recScenario = Tscenarios(strcmp(string(Tscenarios.recommended),"true"),:);
    if isempty(recScenario)
        recScenario = Tscenarios(1,:);
    end

    checks = {};

    checks{end+1,1} = local_check_row_v96l( ...
        "D01", ...
        "Prior smoke pass", ...
        strcmp(string(Ssmoke.diagnosis),"GUARDED_TRIOBJECTIVE_SMOKE_GA_PASS"), ...
        string(Ssmoke.diagnosis), ...
        "Smoke v96k must be PASS.");

    checks{end+1,1} = local_check_row_v96l( ...
        "D02", ...
        "Formal preflight pass", ...
        preflight_pass, ...
        sprintf("gas f=[%.6g %.6g %.6g]; hybrid f=[%.6g %.6g %.6g]; solar f=[%.6g %.6g %.6g]", ...
            gasPre.f1(1), gasPre.f2(1), gasPre.f3(1), ...
            hybPre.f1(1), hybPre.f2(1), hybPre.f3(1), ...
            solPre.f1(1), solPre.f2(1), solPre.f3(1)), ...
        "Direct formal preflight must validate 3 objectives.");

    checks{end+1,1} = local_check_row_v96l( ...
        "D03", ...
        "Recommended scenario available", ...
        height(recScenario) >= 1, ...
        sprintf("recommended scenario=%s", string(recScenario.scenario_id(1))), ...
        "At least one recommended scenario must exist.");

    checks{end+1,1} = local_check_row_v96l( ...
        "D04", ...
        "Runtime estimated", ...
        all(isfinite(Tscenarios.estimated_runtime_h)) && all(Tscenarios.estimated_runtime_h > 0), ...
        "All scenarios have positive runtime estimate.", ...
        "Formal runtime must be estimated before approval.");

    checks{end+1,1} = local_check_row_v96l( ...
        "D05", ...
        "Source preservation", ...
        all(Tsource.pass), ...
        "Protected sources preserved; triobjective objective available.", ...
        "No protected source may be overwritten.");

    checks{end+1,1} = local_check_row_v96l( ...
        "D06", ...
        "Emission factors still provisional", ...
        true, ...
        "Formal code may run, but manuscript-final CO2 claims remain blocked until factors are referenced.", ...
        "Factor status must be explicit.");

    Tchecks = struct2table(vertcat(checks{:}));

    design_pass = all(Tchecks.pass);

    if design_pass
        diagnosis = "TRIOBJECTIVE_FORMAL_RUN_DESIGN_PASS";
    else
        diagnosis = "TRIOBJECTIVE_FORMAL_RUN_DESIGN_REQUIRES_REVIEW";
    end

    % ---------------------------------------------------------------------
    % Flags
    % ---------------------------------------------------------------------
    designFlags = struct();
    designFlags.prior_smoke_pass = strcmp(string(Ssmoke.diagnosis),"GUARDED_TRIOBJECTIVE_SMOKE_GA_PASS");
    designFlags.objective_v96j_fix1_selected = true;
    designFlags.preflight_pass = preflight_pass;
    designFlags.recommended_scenario_id = string(recScenario.scenario_id(1));
    designFlags.recommended_population_size = recScenario.population_size(1);
    designFlags.recommended_max_generations = recScenario.max_generations(1);
    designFlags.recommended_estimated_runtime_h = recScenario.estimated_runtime_h(1);
    designFlags.recommended_modes = string(recScenario.modes(1));
    designFlags.source_preservation_pass = all(Tsource.pass);
    designFlags.emission_factors_provisional = true;
    designFlags.formal_run_script_pending = true;
    designFlags.formal_run_not_approved_yet = true;
    designFlags.no_GA_executed_in_this_step = true;
    designFlags.formal_run_still_on_hold = true;

    % ---------------------------------------------------------------------
    % Salidas CSV
    % ---------------------------------------------------------------------
    outScenariosCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RUN_DESIGN_v96l_scenarios.csv');
    outPreflightCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RUN_DESIGN_v96l_preflight.csv');
    outReqCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RUN_DESIGN_v96l_requirements.csv');
    outAcceptanceCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RUN_DESIGN_v96l_acceptance.csv');
    outChecksCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RUN_DESIGN_v96l_checks.csv');
    outSourceCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RUN_DESIGN_v96l_source_scan.csv');

    writetable(Tscenarios,outScenariosCsv);
    writetable(Tpreflight,outPreflightCsv);
    writetable(Trequirements,outReqCsv);
    writetable(Tacceptance,outAcceptanceCsv);
    writetable(Tchecks,outChecksCsv);
    writetable(Tsource,outSourceCsv);

    % ---------------------------------------------------------------------
    % MAT
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'TRIOBJECTIVE_FORMAL_RUN_DESIGN_v96l.md');
    outTxt = fullfile(logsDir,'TRIOBJECTIVE_FORMAL_RUN_DESIGN_v96l.txt');
    outMat = fullfile(matDir,'TRIOBJECTIVE_FORMAL_RUN_DESIGN_v96l.mat');

    save(outMat, ...
        'diagnosis','designFlags', ...
        'x_selected','lb_global','ub_global','delta_formal','lb_formal','ub_formal','nvars', ...
        'sec_per_eval_gas','sec_per_eval_hyb','sec_per_eval_ref', ...
        'Tscenarios','Tpreflight','Trequirements','Tacceptance','Tchecks','Tsource', ...
        'objective_v96j_fix1','objective_v95j','wrapper_v10','wrapper_v17','wrapper_v18','objective_v628b', ...
        'smokeDir','designDir', ...
        'outMd','outTxt','outMat','outScenariosCsv','outPreflightCsv','outReqCsv','outAcceptanceCsv','outChecksCsv','outSourceCsv');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# TRIOBJECTIVE_FORMAL_RUN_DESIGN_v96l\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Función objetivo formal candidata:\n\n');
    fprintf(fid,'```text\nobjective_productive_corrected_v96j_triobjective_CO2_fix1\n```\n\n');

    fprintf(fid,'## Vector objetivo\n\n');
    fprintf(fid,'```matlab\n');
    fprintf(fid,'f(1) = MR_final;\n');
    fprintf(fid,'f(2) = cost_specific_USD_per_kgwater;\n');
    fprintf(fid,'f(3) = CO2_specific_kgCO2_per_kgwater;\n');
    fprintf(fid,'```\n\n');

    fprintf(fid,'## Dominio formal propuesto\n\n');
    fprintf(fid,'| Variable | lb | ub |\n');
    fprintf(fid,'|---|---:|---:|\n');
    fprintf(fid,'| m_max | %.12g | %.12g |\n', lb_formal(1), ub_formal(1));
    fprintf(fid,'| T_min | %.12g | %.12g |\n', lb_formal(2), ub_formal(2));
    fprintf(fid,'| r_div2 | %.12g | %.12g |\n', lb_formal(3), ub_formal(3));
    fprintf(fid,'| t_rec_ini | %.12g | %.12g |\n\n', lb_formal(4), ub_formal(4));

    fprintf(fid,'## Escenarios formales\n\n');
    fprintf(fid,'| ID | Nombre | Modos | Pop | Gen | Runtime h estimado | Recomendado | Nota |\n');
    fprintf(fid,'|---|---|---|---:|---:|---:|---:|---|\n');

    for i = 1:height(Tscenarios)
        fprintf(fid,'| `%s` | `%s` | `%s` | %d | %d | %.3f | `%s` | %s |\n', ...
            string(Tscenarios.scenario_id(i)), ...
            string(Tscenarios.name(i)), ...
            string(Tscenarios.modes(i)), ...
            Tscenarios.population_size(i), ...
            Tscenarios.max_generations(i), ...
            Tscenarios.estimated_runtime_h(i), ...
            string(Tscenarios.recommended(i)), ...
            string(Tscenarios.note(i)));
    end

    fprintf(fid,'\n## Preflight formal\n\n');
    fprintf(fid,'| mode | status | detail | nobj | f1 MR | f2 cost | f3 CO2 |\n');
    fprintf(fid,'|---|---|---|---:|---:|---:|---:|\n');

    for i = 1:height(Tpreflight)
        fprintf(fid,'| `%s` | `%s` | `%s` | %d | %.12g | %.12g | %.12g |\n', ...
            string(Tpreflight.mode(i)), ...
            string(Tpreflight.status(i)), ...
            string(Tpreflight.detail_status(i)), ...
            Tpreflight.nobj(i), ...
            Tpreflight.f1(i), ...
            Tpreflight.f2(i), ...
            Tpreflight.f3(i));
    end

    fprintf(fid,'\n## Requisitos\n\n');
    fprintf(fid,'| ID | Requisito | Obligatorio | Ya satisfecho | Nota |\n');
    fprintf(fid,'|---|---|---:|---:|---|\n');

    for i = 1:height(Trequirements)
        fprintf(fid,'| `%s` | %s | `%d` | `%d` | %s |\n', ...
            string(Trequirements.id(i)), ...
            string(Trequirements.requirement(i)), ...
            Trequirements.required(i), ...
            Trequirements.already_satisfied(i), ...
            string(Trequirements.note(i)));
    end

    fprintf(fid,'\n## Criterios de aceptación formal\n\n');
    fprintf(fid,'| ID | Criterio | Bloquea aceptación |\n');
    fprintf(fid,'|---|---|---:|\n');

    for i = 1:height(Tacceptance)
        fprintf(fid,'| `%s` | %s | `%d` |\n', ...
            string(Tacceptance.id(i)), ...
            string(Tacceptance.criterion(i)), ...
            Tacceptance.blocks_acceptance(i));
    end

    fprintf(fid,'\n## Checks de diseño\n\n');
    fprintf(fid,'| ID | Check | Pass | Evidencia | Criterio |\n');
    fprintf(fid,'|---|---|---:|---|---|\n');

    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | `%s` | `%d` | %s | %s |\n', ...
            string(Tchecks.id(i)), ...
            string(Tchecks.check(i)), ...
            Tchecks.pass(i), ...
            string(Tchecks.evidence(i)), ...
            string(Tchecks.criterion(i)));
    end

    fprintf(fid,'\n## Recomendación operativa\n\n');
    fprintf(fid,'Escenario recomendado: `%s`.\n\n', string(recScenario.scenario_id(1)));
    fprintf(fid,'Población: `%d`.\n\n', recScenario.population_size(1));
    fprintf(fid,'Generaciones: `%d`.\n\n', recScenario.max_generations(1));
    fprintf(fid,'Tiempo estimado: `%.3f h`.\n\n', recScenario.estimated_runtime_h(1));

    fprintf(fid,'## Restricciones activas\n\n');
    fprintf(fid,'- No se ejecutó `gamultiobj` en este paso.\n');
    fprintf(fid,'- La corrida formal sigue detenida.\n');
    fprintf(fid,'- Los factores de emisión siguen provisionales.\n');
    fprintf(fid,'- No se permiten conclusiones finales hasta consolidación postcorrida.\n');
    fprintf(fid,'- Solar puro sigue excluido.\n\n');

    fprintf(fid,'## Siguiente paso\n\n');
    fprintf(fid,'Si el diagnóstico es `TRIOBJECTIVE_FORMAL_RUN_DESIGN_PASS`, continuar con `9.6m — CREATE-TRIOBJECTIVE-FORMAL-RUN-SCRIPT-001`.\n\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % TXT ejecutivo
    % ---------------------------------------------------------------------
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'TRIOBJECTIVE-FORMAL-RUN-DESIGN-001\n');
    fprintf(fid,'status: TRIOBJECTIVE_FORMAL_RUN_DESIGN_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'prior_smoke_pass: %d\n', designFlags.prior_smoke_pass);
    fprintf(fid,'objective_v96j_fix1_selected: %d\n', designFlags.objective_v96j_fix1_selected);
    fprintf(fid,'preflight_pass: %d\n', designFlags.preflight_pass);
    fprintf(fid,'recommended_scenario_id: %s\n', designFlags.recommended_scenario_id);
    fprintf(fid,'recommended_population_size: %d\n', designFlags.recommended_population_size);
    fprintf(fid,'recommended_max_generations: %d\n', designFlags.recommended_max_generations);
    fprintf(fid,'recommended_estimated_runtime_h: %.6f\n', designFlags.recommended_estimated_runtime_h);
    fprintf(fid,'recommended_modes: %s\n', designFlags.recommended_modes);
    fprintf(fid,'source_preservation_pass: %d\n', designFlags.source_preservation_pass);
    fprintf(fid,'emission_factors_provisional: %d\n', designFlags.emission_factors_provisional);
    fprintf(fid,'formal_run_script_pending: %d\n', designFlags.formal_run_script_pending);
    fprintf(fid,'formal_run_not_approved_yet: %d\n', designFlags.formal_run_not_approved_yet);
    fprintf(fid,'no_GA_executed_in_this_step: %d\n', designFlags.no_GA_executed_in_this_step);
    fprintf(fid,'formal_run_still_on_hold: %d\n', designFlags.formal_run_still_on_hold);
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);

    fclose(fid);

    % ---------------------------------------------------------------------
    % Salida consola
    % ---------------------------------------------------------------------
    design = struct();
    design.status = 'TRIOBJECTIVE_FORMAL_RUN_DESIGN_COMPLETED';
    design.diagnosis = diagnosis;
    design.designFlags = designFlags;
    design.x_selected = x_selected;
    design.lb_formal = lb_formal;
    design.ub_formal = ub_formal;
    design.Tscenarios = Tscenarios;
    design.Tpreflight = Tpreflight;
    design.Trequirements = Trequirements;
    design.Tacceptance = Tacceptance;
    design.Tchecks = Tchecks;
    design.Tsource = Tsource;
    design.designDir = designDir;
    design.outMd = outMd;
    design.outTxt = outTxt;
    design.outMat = outMat;

    disp('=== TRIOBJECTIVE_FORMAL_RUN_DESIGN_v96l ===')
    disp(design.status)
    disp('=== DIAGNOSIS ===')
    disp(design.diagnosis)
    disp('=== DESIGN FLAGS ===')
    disp(design.designFlags)
    disp('=== SCENARIOS ===')
    disp(design.Tscenarios)
    disp('=== PREFLIGHT ===')
    disp(design.Tpreflight)
    disp('=== CHECKS ===')
    disp(design.Tchecks)
    disp('=== OUTPUT FILES ===')
    disp(design.outMd)
    disp(design.outTxt)
    disp(design.outMat)

end

% =========================================================================
% Helpers
% =========================================================================

function row = local_scenario_row_v96l(id, name, modes, popSize, maxGen, nModes, recommended, note, sec_per_eval_ref)
    margin = 1.35;

    eval_count_per_mode = popSize * (maxGen + 1);
    total_eval_count = eval_count_per_mode * nModes;
    estimated_runtime_s = total_eval_count * sec_per_eval_ref * margin;

    row = struct();
    row.scenario_id = string(id);
    row.name = string(name);
    row.modes = string(modes);
    row.population_size = popSize;
    row.max_generations = maxGen;
    row.nModes = nModes;
    row.eval_count_per_mode = eval_count_per_mode;
    row.total_eval_count = total_eval_count;
    row.sec_per_eval_ref = sec_per_eval_ref;
    row.runtime_margin = margin;
    row.estimated_runtime_s = estimated_runtime_s;
    row.estimated_runtime_h = estimated_runtime_s / 3600;
    row.recommended = string(logical(recommended));
    row.note = string(note);
end

function [f, detail, status, errMsg] = local_eval_triobjective_v96l(x, mode)
    status = "OK";
    errMsg = "";
    detail = struct();

    try
        [f, detail] = objective_productive_corrected_v96j_triobjective_CO2_fix1(x, mode);
        f = double(f(:))';

        if numel(f) ~= 3
            status = "BAD_OBJECTIVE_SIZE";
            f = [1000, 1e6, 1e6];
        end

        if any(~isfinite(f)) || any(~isreal(f))
            status = "BAD_OBJECTIVE_VALUE";
            f = [1000, 1e6, 1e6];
        end

    catch ME
        f = [1000, 1e6, 1e6];
        detail = struct();
        status = "ERROR";
        errMsg = string(ME.message);
    end
end

function row = local_preflight_row_v96l(mode, x, f, detail, status, errMsg)
    row = struct();

    row.mode = string(mode);
    row.status = string(status);
    row.error_message = string(errMsg);

    row.m_max = x(1);
    row.T_min = x(2);
    row.r_div2 = x(3);
    row.t_rec_ini = x(4);

    row.nobj = numel(f);
    row.f1 = local_vec_get_v96l(f,1,NaN);
    row.f2 = local_vec_get_v96l(f,2,NaN);
    row.f3 = local_vec_get_v96l(f,3,NaN);

    row.detail_status = local_get_string_v96l(detail, {'status','detail_status','execution_status'}, "UNKNOWN");
    row.Q_aux_tot = local_get_numeric_v96l(detail, {'outputs.Q_aux_tot','Q_aux_tot'}, NaN);
    row.Irradiacion = local_get_numeric_v96l(detail, {'outputs.Irradiacion','Irradiacion'}, NaN);
    row.dry_time = local_get_numeric_v96l(detail, {'outputs.dry_time','dry_time'}, NaN);
    row.M = local_get_numeric_v96l(detail, {'outputs.M','M'}, NaN);
    row.CO2_total_kg = local_get_numeric_v96l(detail, {'CO2.CO2_total_kg'}, NaN);
    row.CO2_specific = local_get_numeric_v96l(detail, {'CO2.CO2_specific_kgCO2_per_kgwater'}, NaN);
    row.emission_factor_status = local_get_string_v96l(detail, {'CO2.emission_factor_status'}, "");
end

function row = local_req_row_v96l(id, requirement, required, already_satisfied, note)
    row = struct();
    row.id = string(id);
    row.requirement = string(requirement);
    row.required = logical(required);
    row.already_satisfied = logical(already_satisfied);
    row.note = string(note);
end

function row = local_acceptance_row_v96l(id, criterion, blocks_acceptance)
    row = struct();
    row.id = string(id);
    row.criterion = string(criterion);
    row.blocks_acceptance = logical(blocks_acceptance);
end

function row = local_check_row_v96l(id, checkName, passVal, evidence, criterion)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
    row.criterion = string(criterion);
end

function row = local_source_row_v96l(item, filePath, pattern, passVal, evidence)
    row = struct();
    row.item = string(item);
    row.file = string(filePath);
    row.pattern = string(pattern);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end

function row = local_source_contains_v96l(item, filePath, pattern, evidenceIfFound)
    passVal = false;
    evidence = "FILE_NOT_FOUND";

    if isfile(filePath)
        try
            txt = fileread(filePath);
            passVal = contains(txt, pattern);
            if passVal
                evidence = string(evidenceIfFound);
            else
                evidence = "Pattern not found.";
            end
        catch ME
            evidence = "Could not read file: " + string(ME.message);
        end
    end

    row = local_source_row_v96l(item, filePath, pattern, passVal, evidence);
end

function val = local_vec_get_v96l(v, idx, defaultVal)
    if numel(v) >= idx
        val = v(idx);
    else
        val = defaultVal;
    end
end

function val = local_get_numeric_v96l(S, paths, defaultVal)
    val = defaultVal;

    for k = 1:numel(paths)
        parts = split(string(paths{k}),'.');

        try
            tmp = S;
            ok = true;

            for j = 1:numel(parts)
                part = char(parts(j));
                if isstruct(tmp) && isfield(tmp, part)
                    tmp = tmp.(part);
                else
                    ok = false;
                    break
                end
            end

            if ok && isnumeric(tmp) && ~isempty(tmp)
                val = double(tmp(1));
                return
            end
        catch
        end
    end
end

function val = local_get_string_v96l(S, paths, defaultVal)
    val = string(defaultVal);

    for k = 1:numel(paths)
        parts = split(string(paths{k}),'.');

        try
            tmp = S;
            ok = true;

            for j = 1:numel(parts)
                part = char(parts(j));
                if isstruct(tmp) && isfield(tmp, part)
                    tmp = tmp.(part);
                else
                    ok = false;
                    break
                end
            end

            if ok && ~isempty(tmp)
                val = string(tmp);
                return
            end
        catch
        end
    end
end