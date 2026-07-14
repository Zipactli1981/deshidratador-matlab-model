function recheck = minimal_physics_audit_recheck_with_tmax_correction_v95k()
% MINIMAL_PHYSICS_AUDIT_RECHECK_WITH_TMAX_CORRECTION_v95k
% 9.5k — MINIMAL-PHYSICS-AUDIT-RECHECK-WITH-TMAX-CORRECTION-001
%
% Objetivo:
%   Repetir la auditoría física mínima usando la función objetivo corregida:
%       objective_productive_corrected_v95j_endpoint_TMAX_corrected
%
% Contexto:
%   9.5g quedó en revisión por F05.
%   9.5h confirmó patrones legacy/riesgosos de endpoint TMAX.
%   9.5i diseñó la corrección.
%   9.5j implementó v18/v95j y validó MR consistency + endpoint TMAX.
%
% Este micropaso:
%   - NO modifica v10.
%   - NO modifica v17.
%   - NO modifica v628b.
%   - NO modifica v18/v95j.
%   - NO ejecuta gamultiobj.
%   - NO libera todavía la corrida formal.
%   - Repite auditoría física mínima con objective v95j.
%
% Salidas:
%   logs/MINIMAL_PHYSICS_AUDIT_RECHECK_v95k.md
%   logs/MINIMAL_PHYSICS_AUDIT_RECHECK_v95k.txt
%   tables/MINIMAL_PHYSICS_AUDIT_RECHECK_v95k_eval.csv
%   tables/MINIMAL_PHYSICS_AUDIT_RECHECK_v95k_checks.csv
%   tables/MINIMAL_PHYSICS_AUDIT_RECHECK_v95k_source_scan.csv
%   mat/MINIMAL_PHYSICS_AUDIT_RECHECK_v95k.mat
%
% Uso:
%   recheck = minimal_physics_audit_recheck_with_tmax_correction_v95k();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    objName = 'objective_productive_corrected_v95j_endpoint_TMAX_corrected';

    if exist(objName,'file') ~= 2
        error('No se encontró la función objetivo corregida: %s', objName);
    end

    % ---------------------------------------------------------------------
    % Cargar implementación v95j
    % ---------------------------------------------------------------------
    implBaseDir = fullfile(rootDir,'05_runs','tmax_endpoint_correction_implementation_v95j');

    if ~isfolder(implBaseDir)
        error('No existe implBaseDir: %s', implBaseDir);
    end

    d = dir(implBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_v95j_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró implementación v95j.');
    end

    [~,idxImpl] = max([d.datenum]);
    implDir = fullfile(implBaseDir,d(idxImpl).name);
    implMat = fullfile(implDir,'mat','TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_v95j.mat');

    if ~isfile(implMat)
        error('No existe MAT v95j: %s', implMat);
    end

    S95j = load(implMat);

    if ~isfield(S95j,'diagnosis')
        error('v95j no contiene diagnosis.');
    end

    if ~strcmp(string(S95j.diagnosis),"TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_PASS")
        error('v95j no está en PASS. Diagnosis: %s', string(S95j.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Cargar value gate v94h
    % ---------------------------------------------------------------------
    gateBaseDir = fullfile(rootDir,'05_runs','formal_value_gate_v94h');

    if ~isfolder(gateBaseDir)
        error('No existe gateBaseDir: %s', gateBaseDir);
    end

    dg = dir(gateBaseDir);
    dg = dg([dg.isdir]);
    dg = dg(~ismember({dg.name},{'.','..','.MATLABDriveTag'}));

    keepG = false(size(dg));
    for i = 1:numel(dg)
        keepG(i) = startsWith(dg(i).name,'FORMAL_RUN_VALUE_GATE_v94h_');
    end
    dg = dg(keepG);

    if isempty(dg)
        error('No se encontró value gate v94h.');
    end

    [~,idxGate] = max([dg.datenum]);
    gateDir = fullfile(gateBaseDir,dg(idxGate).name);
    gateMat = fullfile(gateDir,'mat','FORMAL_RUN_VALUE_GATE_v94h.mat');

    if ~isfile(gateMat)
        error('No existe MAT v94h: %s', gateMat);
    end

    Sgate = load(gateMat);

    if ~strcmp(string(Sgate.diagnosis),"FORMAL_RUN_VALUE_GATE_PASS_HOLD_EXECUTION")
        error('v94h no está en PASS_HOLD_EXECUTION. Diagnosis: %s', string(Sgate.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Crear carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    recheckBaseDir = fullfile(rootDir,'05_runs','minimal_physics_recheck_v95k');
    recheckDir = fullfile(recheckBaseDir,['MINIMAL_PHYSICS_AUDIT_RECHECK_v95k_' timestamp]);

    logsDir = fullfile(recheckDir,'logs');
    tablesDir = fullfile(recheckDir,'tables');
    matDir = fullfile(recheckDir,'mat');

    if ~isfolder(recheckBaseDir), mkdir(recheckBaseDir); end
    if ~isfolder(recheckDir), mkdir(recheckDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Solución seleccionada de referencia
    % ---------------------------------------------------------------------
    x_selected = [ ...
        0.0740767982118, ...
        62.6832965028, ...
        0.672252618341, ...
        11.6517528081];

    varNames = ["m_max","T_min","r_div2","t_rec_ini"];

    % Umbrales de recheck
    tol_dry_time_h = 0.50;
    tol_MR_abs = 0.020;
    min_Qaux_reduction_pct = 1.0;
    min_hybrid_irradiacion = 1e-6;
    max_allowed_penalty_MR = 999.999;
    max_allowed_penalty_cost = 999999.999;
    tol_MR_recalc = 1e-8;

    % ---------------------------------------------------------------------
    % Evaluación directa gasLP/hybrid/solar con objective v95j
    % ---------------------------------------------------------------------
    modes = ["gasLP","hybrid","solar"];
    evalRows = {};

    for i = 1:numel(modes)
        mode = modes(i);
        [f, detail, status, errMsg] = local_eval_objective_v95k(x_selected, mode);
        row = local_detail_to_row_v95k(mode, x_selected, f, detail, status, errMsg);
        evalRows{end+1,1} = row; %#ok<AGROW>
    end

    Teval = struct2table(vertcat(evalRows{:}));
    outEvalCsv = fullfile(tablesDir,'MINIMAL_PHYSICS_AUDIT_RECHECK_v95k_eval.csv');
    writetable(Teval,outEvalCsv);

    gas = Teval(strcmp(string(Teval.mode),"gasLP"),:);
    hyb = Teval(strcmp(string(Teval.mode),"hybrid"),:);
    sol = Teval(strcmp(string(Teval.mode),"solar"),:);

    if isempty(gas) || isempty(hyb) || isempty(sol)
        error('Evaluación incompleta: faltan filas gasLP/hybrid/solar.');
    end

    % ---------------------------------------------------------------------
    % Escaneo de fuentes corregidas
    % ---------------------------------------------------------------------
    wrapper_v10 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v10_energy_mode_corrected.m');
    wrapper_v17 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v17_nonphysical_penalty.m');
    wrapper_v18 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v18_endpoint_TMAX_corrected.m');
    objective_v628b = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v628b_nonphysical_penalty.m');
    objective_v95j = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v95j_endpoint_TMAX_corrected.m');
    guard_v628b = fullfile(rootDir,'02_src_limpio','wrappers','nonphysical_guard_eval_v628b.m');

    sourceRows = {};

    sourceRows{end+1,1} = local_source_row_v95k("wrapper_v10_preserved", wrapper_v10, "", isfile(wrapper_v10), "Original v10 preserved.");
    sourceRows{end+1,1} = local_source_row_v95k("wrapper_v17_preserved", wrapper_v17, "", isfile(wrapper_v17), "Guarded v17 preserved.");
    sourceRows{end+1,1} = local_source_row_v95k("objective_v628b_preserved", objective_v628b, "", isfile(objective_v628b), "Objective v628b preserved.");
    sourceRows{end+1,1} = local_source_row_v95k("wrapper_v18_exists", wrapper_v18, "", isfile(wrapper_v18), "Corrected wrapper v18 exists.");
    sourceRows{end+1,1} = local_source_row_v95k("objective_v95j_exists", objective_v95j, "", isfile(objective_v95j), "Corrected objective v95j exists.");
    sourceRows{end+1,1} = local_source_row_v95k("guard_v628b_exists", guard_v628b, "", isfile(guard_v628b), "Nonphysical guard exists.");

    sourceRows{end+1,1} = local_source_contains_v95k("v95j_calls_v18", objective_v95j, "opt_tunel_mod2_v18_endpoint_TMAX_corrected", "v95j calls corrected wrapper v18.");
    sourceRows{end+1,1} = local_source_contains_v95k("v18_calls_guard", wrapper_v18, "nonphysical_guard_eval_v628b", "v18 preserves nonphysical guard call.");
    sourceRows{end+1,1} = local_source_contains_v95k("v18_current_M_endpoint", wrapper_v18, "M_prod_fin=M_prod(i);", "v18 contains current-index M endpoint.");
    sourceRows{end+1,1} = local_source_contains_v95k("v18_recalc_MR_endpoint", wrapper_v18, "MR_fin=(M_prod_fin-Mf)/(Mi-Mf);", "v18 contains recalculated MR endpoint.");

    sourceRows{end+1,1} = local_source_active_absent_v95k("v18_active_min_Mprod_absent", wrapper_v18, "M_prod_fin=min(M_prod);", "No active min(M_prod) endpoint assignment in v18.");
    sourceRows{end+1,1} = local_source_active_absent_v95k("v18_active_MR_endminus1_absent", wrapper_v18, "MR_fin=MR(end-1);", "No active MR(end-1) endpoint assignment in v18.");
    sourceRows{end+1,1} = local_source_contains_v95k("v18_NONPHYSICAL_preserved", wrapper_v18, "NONPHYSICAL_TRAJECTORY", "v18 preserves nonphysical status.");
    sourceRows{end+1,1} = local_source_contains_v95k("v18_TMAX_status_present", wrapper_v18, "TMAX_REACHED", "v18 preserves TMAX status.");
    sourceRows{end+1,1} = local_source_contains_v95k("v18_MDES_status_present", wrapper_v18, "M_DES_REACHED", "v18 preserves M_DES status.");

    Tsource = struct2table(vertcat(sourceRows{:}));
    outSourceCsv = fullfile(tablesDir,'MINIMAL_PHYSICS_AUDIT_RECHECK_v95k_source_scan.csv');
    writetable(Tsource,outSourceCsv);

    % ---------------------------------------------------------------------
    % Métricas directas
    % ---------------------------------------------------------------------
    gas_not_penalized = gas.MR_objective(1) < max_allowed_penalty_MR && gas.cost_objective(1) < max_allowed_penalty_cost;
    hyb_not_penalized = hyb.MR_objective(1) < max_allowed_penalty_MR && hyb.cost_objective(1) < max_allowed_penalty_cost;
    solar_penalized = sol.MR_objective(1) >= max_allowed_penalty_MR || sol.cost_objective(1) >= max_allowed_penalty_cost;

    MR_gas_recalc = (gas.M(1) - gas.Mf(1)) / (gas.Mi(1) - gas.Mf(1));
    MR_hyb_recalc = (hyb.M(1) - hyb.Mf(1)) / (hyb.Mi(1) - hyb.Mf(1));

    MR_gas_diff = abs(gas.MR(1) - MR_gas_recalc);
    MR_hyb_diff = abs(hyb.MR(1) - MR_hyb_recalc);

    delta_Q_aux = hyb.Q_aux_tot(1) - gas.Q_aux_tot(1);
    reduction_Q_aux_pct = 100 * (gas.Q_aux_tot(1) - hyb.Q_aux_tot(1)) / gas.Q_aux_tot(1);
    delta_dry_time = hyb.dry_time(1) - gas.dry_time(1);
    delta_MR = hyb.MR(1) - gas.MR(1);
    delta_cost = hyb.cost_objective(1) - gas.cost_objective(1);
    reduction_cost_pct = 100 * (gas.cost_objective(1) - hyb.cost_objective(1)) / gas.cost_objective(1);

    % ---------------------------------------------------------------------
    % Checks físicos mínimos corregidos
    % ---------------------------------------------------------------------
    checks = {};

    % F01
    pass_F01 = ...
        strcmp(string(hyb.eval_status(1)),"OK") && ...
        hyb.Irradiacion(1) > min_hybrid_irradiacion && ...
        abs(gas.Irradiacion(1)) < min_hybrid_irradiacion;

    checks{end+1,1} = local_check_row_v95k( ...
        "F01", ...
        "hybrid_uses_solar_input", ...
        pass_F01, ...
        sprintf("hybrid Irradiacion=%.12g; gasLP Irradiacion=%.12g", hyb.Irradiacion(1), gas.Irradiacion(1)), ...
        "Hybrid must use positive solar irradiation while gasLP must not.");

    % F02
    pass_F02 = ...
        strcmp(string(gas.eval_status(1)),"OK") && ...
        strcmp(string(hyb.eval_status(1)),"OK") && ...
        strcmp(string(gas.detail_status(1)),"OK") && ...
        strcmp(string(hyb.detail_status(1)),"OK") && ...
        gas_not_penalized && ...
        hyb_not_penalized && ...
        solar_penalized;

    checks{end+1,1} = local_check_row_v95k( ...
        "F02", ...
        "gasLP_hybrid_physical_domain", ...
        pass_F02, ...
        sprintf("gas penalized=%d; hybrid penalized=%d; solar penalized=%d", ~gas_not_penalized, ~hyb_not_penalized, solar_penalized), ...
        "gasLP and hybrid must be non-penalized; solar remains excluded/penalized.");

    % F03
    pass_F03 = ...
        isfinite(reduction_Q_aux_pct) && ...
        reduction_Q_aux_pct > min_Qaux_reduction_pct && ...
        abs(delta_dry_time) <= tol_dry_time_h && ...
        abs(delta_MR) <= tol_MR_abs;

    checks{end+1,1} = local_check_row_v95k( ...
        "F03", ...
        "auxiliary_control_logic", ...
        pass_F03, ...
        sprintf("Q_aux reduction=%.12g%%; delta dry_time=%.12g h; delta MR=%.12g", reduction_Q_aux_pct, delta_dry_time, delta_MR), ...
        "Hybrid should reduce auxiliary energy while preserving comparable drying endpoint.");

    % F04
    r_div2 = x_selected(3);
    t_rec_ini = x_selected(4);

    pass_F04 = ...
        isfinite(r_div2) && r_div2 >= 0 && r_div2 <= 1 && ...
        isfinite(t_rec_ini) && t_rec_ini >= 0 && t_rec_ini <= 24 && ...
        local_source_pass_v95k(Tsource,"v18_current_M_endpoint");

    checks{end+1,1} = local_check_row_v95k( ...
        "F04", ...
        "recirculation_logic", ...
        pass_F04, ...
        sprintf("r_div2=%.12g; t_rec_ini=%.12g", r_div2, t_rec_ini), ...
        "Recirculation variables must remain in physical range.");

    % F05
    pass_F05 = ...
        gas.M(1) >= gas.Mf(1) - 1e-6 && ...
        hyb.M(1) >= hyb.Mf(1) - 1e-6 && ...
        gas.MR(1) >= -1e-6 && gas.MR(1) <= 1 + 1e-6 && ...
        hyb.MR(1) >= -1e-6 && hyb.MR(1) <= 1 + 1e-6 && ...
        MR_gas_diff < tol_MR_recalc && ...
        MR_hyb_diff < tol_MR_recalc && ...
        local_source_pass_v95k(Tsource,"v18_current_M_endpoint") && ...
        local_source_pass_v95k(Tsource,"v18_recalc_MR_endpoint") && ...
        local_source_pass_v95k(Tsource,"v18_active_min_Mprod_absent") && ...
        local_source_pass_v95k(Tsource,"v18_active_MR_endminus1_absent");

    checks{end+1,1} = local_check_row_v95k( ...
        "F05", ...
        "drying_endpoint_logic_corrected", ...
        pass_F05, ...
        sprintf("gas MR diff=%.12g; hybrid MR diff=%.12g; v18 endpoint current/recalc and legacy-active absent", MR_gas_diff, MR_hyb_diff), ...
        "Endpoint must use current M, recalculated MR, and satisfy MR=(M-Mf)/(Mi-Mf).");

    % F06
    pass_F06 = solar_penalized && ...
        local_source_pass_v95k(Tsource,"v18_NONPHYSICAL_preserved");

    checks{end+1,1} = local_check_row_v95k( ...
        "F06", ...
        "solar_branch_not_reintroduced", ...
        pass_F06, ...
        sprintf("solar objective=[%.12g %.12g]; detail=%s", sol.MR_objective(1), sol.cost_objective(1), string(sol.detail_status(1))), ...
        "Pure solar remains excluded until branch correction and revalidation.");

    % F07
    pass_F07 = ...
        local_source_pass_v95k(Tsource,"wrapper_v10_preserved") && ...
        local_source_pass_v95k(Tsource,"wrapper_v17_preserved") && ...
        local_source_pass_v95k(Tsource,"objective_v628b_preserved") && ...
        local_source_pass_v95k(Tsource,"wrapper_v18_exists") && ...
        local_source_pass_v95k(Tsource,"objective_v95j_exists") && ...
        local_source_pass_v95k(Tsource,"v95j_calls_v18");

    checks{end+1,1} = local_check_row_v95k( ...
        "F07", ...
        "corrected_objective_route_and_source_preservation", ...
        pass_F07, ...
        "v10/v17/v628b preserved; v18/v95j exist; v95j calls v18.", ...
        "Corrected route must be explicit and original files must remain protected.");

    % F08
    pass_F08 = ...
        strcmp(string(S95j.diagnosis),"TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_PASS") && ...
        S95j.implFlags.all_validation_checks_pass && ...
        S95j.implFlags.MR_consistency_pass && ...
        S95j.implFlags.TMAX_endpoint_logic_pass;

    checks{end+1,1} = local_check_row_v95k( ...
        "F08", ...
        "v95j_implementation_prior_validation", ...
        pass_F08, ...
        sprintf("v95j diagnosis=%s; all checks=%d", string(S95j.diagnosis), S95j.implFlags.all_validation_checks_pass), ...
        "The prior implementation validation must be PASS.");

    Tchecks = struct2table(vertcat(checks{:}));
    outChecksCsv = fullfile(tablesDir,'MINIMAL_PHYSICS_AUDIT_RECHECK_v95k_checks.csv');
    writetable(Tchecks,outChecksCsv);

    % ---------------------------------------------------------------------
    % Dictamen
    % ---------------------------------------------------------------------
    recheckFlags = struct();
    recheckFlags.F01_hybrid_uses_solar_input = pass_F01;
    recheckFlags.F02_gasLP_hybrid_physical_domain = pass_F02;
    recheckFlags.F03_auxiliary_control_logic = pass_F03;
    recheckFlags.F04_recirculation_logic = pass_F04;
    recheckFlags.F05_drying_endpoint_logic_corrected = pass_F05;
    recheckFlags.F06_solar_branch_not_reintroduced = pass_F06;
    recheckFlags.F07_corrected_objective_route_and_source_preservation = pass_F07;
    recheckFlags.F08_v95j_implementation_prior_validation = pass_F08;

    recheckFlags.all_minimal_physics_recheck_pass = all(Tchecks.pass);
    recheckFlags.objective_for_formal_run_candidate = string(objName);
    recheckFlags.formal_run_previous_command_needs_update = true;
    recheckFlags.no_model_modified_in_this_step = true;
    recheckFlags.no_GA_executed = true;
    recheckFlags.formal_run_still_on_hold = true;
    recheckFlags.CO2_postprocess_design_still_pending = true;

    if recheckFlags.all_minimal_physics_recheck_pass
        diagnosis = "MINIMAL_PHYSICS_AUDIT_RECHECK_PASS_WITH_TMAX_CORRECTION";
    else
        diagnosis = "MINIMAL_PHYSICS_AUDIT_RECHECK_REQUIRES_REVIEW";
    end

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'MINIMAL_PHYSICS_AUDIT_RECHECK_v95k.md');
    outTxt = fullfile(logsDir,'MINIMAL_PHYSICS_AUDIT_RECHECK_v95k.txt');
    outMat = fullfile(matDir,'MINIMAL_PHYSICS_AUDIT_RECHECK_v95k.mat');

    save(outMat, ...
        'diagnosis','recheckFlags','x_selected','varNames', ...
        'Teval','Tchecks','Tsource', ...
        'MR_gas_recalc','MR_hyb_recalc','MR_gas_diff','MR_hyb_diff', ...
        'delta_Q_aux','reduction_Q_aux_pct','delta_dry_time','delta_MR','delta_cost','reduction_cost_pct', ...
        'wrapper_v10','wrapper_v17','wrapper_v18','objective_v628b','objective_v95j','guard_v628b', ...
        'implDir','gateDir','recheckDir', ...
        'outMd','outTxt','outMat','outEvalCsv','outChecksCsv','outSourceCsv');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# MINIMAL_PHYSICS_AUDIT_RECHECK_v95k\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Esta auditoría repite el control físico mínimo usando `objective_productive_corrected_v95j_endpoint_TMAX_corrected`.\n\n');

    fprintf(fid,'## Evaluación directa corregida\n\n');
    fprintf(fid,'| Modo | eval_status | detail_status | MR obj | cost obj | Q_aux | Irradiacion | dry_time | M | Mf | Mi | MR | MR recalc | MR diff |\n');
    fprintf(fid,'|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|\n');

    for i = 1:height(Teval)
        mode = string(Teval.mode(i));

        if mode == "gasLP"
            mrRec = MR_gas_recalc;
            mrDiff = MR_gas_diff;
        elseif mode == "hybrid"
            mrRec = MR_hyb_recalc;
            mrDiff = MR_hyb_diff;
        else
            mrRec = NaN;
            mrDiff = NaN;
        end

        fprintf(fid,'| `%s` | `%s` | `%s` | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g |\n', ...
            mode, ...
            string(Teval.eval_status(i)), ...
            string(Teval.detail_status(i)), ...
            Teval.MR_objective(i), ...
            Teval.cost_objective(i), ...
            Teval.Q_aux_tot(i), ...
            Teval.Irradiacion(i), ...
            Teval.dry_time(i), ...
            Teval.M(i), ...
            Teval.Mf(i), ...
            Teval.Mi(i), ...
            Teval.MR(i), ...
            mrRec, ...
            mrDiff);
    end

    fprintf(fid,'\n## Checks físicos mínimos corregidos\n\n');
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

    fprintf(fid,'\n## Escaneo de fuente\n\n');
    fprintf(fid,'| Item | Pass | Evidencia |\n');
    fprintf(fid,'|---|---:|---|\n');

    for i = 1:height(Tsource)
        fprintf(fid,'| `%s` | `%d` | %s |\n', ...
            string(Tsource.item(i)), ...
            Tsource.pass(i), ...
            string(Tsource.evidence(i)));
    end

    fprintf(fid,'\n## Métricas comparativas corregidas\n\n');
    fprintf(fid,'| Métrica | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| delta_Q_aux_hybrid_minus_gasLP | %.12g |\n', delta_Q_aux);
    fprintf(fid,'| reduction_Q_aux_pct | %.12g |\n', reduction_Q_aux_pct);
    fprintf(fid,'| delta_cost_hybrid_minus_gasLP | %.12g |\n', delta_cost);
    fprintf(fid,'| reduction_cost_pct | %.12g |\n', reduction_cost_pct);
    fprintf(fid,'| delta_dry_time_hybrid_minus_gasLP | %.12g |\n', delta_dry_time);
    fprintf(fid,'| delta_MR_hybrid_minus_gasLP | %.12g |\n\n', delta_MR);

    fprintf(fid,'## Dictamen\n\n');

    if strcmp(diagnosis,"MINIMAL_PHYSICS_AUDIT_RECHECK_PASS_WITH_TMAX_CORRECTION")
        fprintf(fid,'La auditoría física mínima queda aprobada con la corrección TMAX implementada en `v18/v95j`. La función objetivo candidata para la corrida formal debe actualizarse a `objective_productive_corrected_v95j_endpoint_TMAX_corrected`.\n\n');
    else
        fprintf(fid,'La auditoría física mínima corregida requiere revisión. No debe ejecutarse corrida formal.\n\n');
    end

    fprintf(fid,'## Restricciones activas\n\n');
    fprintf(fid,'- No se ejecutó `gamultiobj`.\n');
    fprintf(fid,'- La corrida formal sigue detenida.\n');
    fprintf(fid,'- Falta diseñar CO2 opción A como postproceso.\n');
    fprintf(fid,'- El comando formal anterior debe actualizarse para usar `objective_productive_corrected_v95j_endpoint_TMAX_corrected` antes de cualquier ejecución.\n');
    fprintf(fid,'- Solar puro sigue excluido.\n\n');

    fprintf(fid,'## Siguiente paso\n\n');
    fprintf(fid,'`9.6g — CO2-POSTPROCESS-DESIGN-OPTION-A-001`\n\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % TXT ejecutivo
    % ---------------------------------------------------------------------
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'MINIMAL-PHYSICS-AUDIT-RECHECK-WITH-TMAX-CORRECTION-001\n');
    fprintf(fid,'status: MINIMAL_PHYSICS_AUDIT_RECHECK_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'F01_hybrid_uses_solar_input: %d\n', recheckFlags.F01_hybrid_uses_solar_input);
    fprintf(fid,'F02_gasLP_hybrid_physical_domain: %d\n', recheckFlags.F02_gasLP_hybrid_physical_domain);
    fprintf(fid,'F03_auxiliary_control_logic: %d\n', recheckFlags.F03_auxiliary_control_logic);
    fprintf(fid,'F04_recirculation_logic: %d\n', recheckFlags.F04_recirculation_logic);
    fprintf(fid,'F05_drying_endpoint_logic_corrected: %d\n', recheckFlags.F05_drying_endpoint_logic_corrected);
    fprintf(fid,'F06_solar_branch_not_reintroduced: %d\n', recheckFlags.F06_solar_branch_not_reintroduced);
    fprintf(fid,'F07_corrected_objective_route_and_source_preservation: %d\n', recheckFlags.F07_corrected_objective_route_and_source_preservation);
    fprintf(fid,'F08_v95j_implementation_prior_validation: %d\n', recheckFlags.F08_v95j_implementation_prior_validation);
    fprintf(fid,'all_minimal_physics_recheck_pass: %d\n', recheckFlags.all_minimal_physics_recheck_pass);
    fprintf(fid,'objective_for_formal_run_candidate: %s\n', recheckFlags.objective_for_formal_run_candidate);
    fprintf(fid,'formal_run_previous_command_needs_update: %d\n', recheckFlags.formal_run_previous_command_needs_update);
    fprintf(fid,'no_model_modified_in_this_step: %d\n', recheckFlags.no_model_modified_in_this_step);
    fprintf(fid,'no_GA_executed: %d\n', recheckFlags.no_GA_executed);
    fprintf(fid,'formal_run_still_on_hold: %d\n', recheckFlags.formal_run_still_on_hold);
    fprintf(fid,'CO2_postprocess_design_still_pending: %d\n', recheckFlags.CO2_postprocess_design_still_pending);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'KEY METRICS:\n');
    fprintf(fid,'MR_gas_recalc: %.12g\n', MR_gas_recalc);
    fprintf(fid,'MR_hyb_recalc: %.12g\n', MR_hyb_recalc);
    fprintf(fid,'MR_gas_diff: %.12g\n', MR_gas_diff);
    fprintf(fid,'MR_hyb_diff: %.12g\n', MR_hyb_diff);
    fprintf(fid,'delta_Q_aux: %.12g\n', delta_Q_aux);
    fprintf(fid,'reduction_Q_aux_pct: %.12g\n', reduction_Q_aux_pct);
    fprintf(fid,'delta_cost: %.12g\n', delta_cost);
    fprintf(fid,'reduction_cost_pct: %.12g\n', reduction_cost_pct);
    fprintf(fid,'delta_dry_time: %.12g\n', delta_dry_time);
    fprintf(fid,'delta_MR: %.12g\n\n', delta_MR);

    fprintf(fid,'OUTPUTS:\n');
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'outEvalCsv: %s\n', outEvalCsv);
    fprintf(fid,'outChecksCsv: %s\n', outChecksCsv);
    fprintf(fid,'outSourceCsv: %s\n', outSourceCsv);

    fclose(fid);

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    recheck = struct();
    recheck.status = 'MINIMAL_PHYSICS_AUDIT_RECHECK_COMPLETED';
    recheck.diagnosis = diagnosis;
    recheck.recheckFlags = recheckFlags;
    recheck.x_selected = x_selected;
    recheck.Teval = Teval;
    recheck.Tchecks = Tchecks;
    recheck.Tsource = Tsource;
    recheck.MR_gas_recalc = MR_gas_recalc;
    recheck.MR_hyb_recalc = MR_hyb_recalc;
    recheck.MR_gas_diff = MR_gas_diff;
    recheck.MR_hyb_diff = MR_hyb_diff;
    recheck.delta_Q_aux = delta_Q_aux;
    recheck.reduction_Q_aux_pct = reduction_Q_aux_pct;
    recheck.delta_dry_time = delta_dry_time;
    recheck.delta_MR = delta_MR;
    recheck.delta_cost = delta_cost;
    recheck.reduction_cost_pct = reduction_cost_pct;
    recheck.objective_for_formal_run_candidate = string(objName);
    recheck.recheckDir = recheckDir;
    recheck.implDir = implDir;
    recheck.gateDir = gateDir;
    recheck.outMd = outMd;
    recheck.outTxt = outTxt;
    recheck.outMat = outMat;
    recheck.outEvalCsv = outEvalCsv;
    recheck.outChecksCsv = outChecksCsv;
    recheck.outSourceCsv = outSourceCsv;

    disp('=== MINIMAL_PHYSICS_AUDIT_RECHECK_v95k ===')
    disp(recheck.status)
    disp('=== DIAGNOSIS ===')
    disp(recheck.diagnosis)
    disp('=== RECHECK FLAGS ===')
    disp(recheck.recheckFlags)
    disp('=== DIRECT EVALUATION ===')
    disp(recheck.Teval)
    disp('=== CHECKS ===')
    disp(recheck.Tchecks)
    disp('=== SOURCE SCAN ===')
    disp(recheck.Tsource)
    disp('=== KEY METRICS ===')
    fprintf('MR_gas_recalc = %.12g\n', recheck.MR_gas_recalc);
    fprintf('MR_hyb_recalc = %.12g\n', recheck.MR_hyb_recalc);
    fprintf('MR_gas_diff = %.12g\n', recheck.MR_gas_diff);
    fprintf('MR_hyb_diff = %.12g\n', recheck.MR_hyb_diff);
    fprintf('delta_Q_aux_hybrid_minus_gasLP = %.12g\n', recheck.delta_Q_aux);
    fprintf('reduction_Q_aux_pct = %.12g\n', recheck.reduction_Q_aux_pct);
    fprintf('delta_cost_hybrid_minus_gasLP = %.12g\n', recheck.delta_cost);
    fprintf('reduction_cost_pct = %.12g\n', recheck.reduction_cost_pct);
    fprintf('delta_dry_time_hybrid_minus_gasLP = %.12g\n', recheck.delta_dry_time);
    fprintf('delta_MR_hybrid_minus_gasLP = %.12g\n', recheck.delta_MR);
    disp('=== OBJECTIVE CANDIDATE FOR FORMAL RUN ===')
    disp(recheck.objective_for_formal_run_candidate)
    disp('=== OUTPUT FILES ===')
    disp(recheck.outMd)
    disp(recheck.outTxt)
    disp(recheck.outMat)

end

% =========================================================================
% Funciones locales auxiliares
% =========================================================================

function [f, detail, status, errMsg] = local_eval_objective_v95k(x, mode)
    status = "OK";
    errMsg = "";
    detail = struct();

    try
        [f, detail] = objective_productive_corrected_v95j_endpoint_TMAX_corrected(x, mode);
        f = double(f(:))';

        if numel(f) < 2
            f = [1000, 1e6];
            status = "BAD_OBJECTIVE_SIZE";
        else
            f = f(1:2);
        end

        if any(~isfinite(f)) || any(~isreal(f))
            f = [1000, 1e6];
            status = "BAD_OBJECTIVE_VALUE";
        end

    catch ME
        f = [1000, 1e6];
        detail = struct();
        status = "ERROR";
        errMsg = string(ME.message);
    end
end

function row = local_detail_to_row_v95k(mode, x, f, detail, status, errMsg)

    row = struct();

    row.mode = string(mode);
    row.eval_status = string(status);
    row.error_message = string(errMsg);

    row.m_max = x(1);
    row.T_min = x(2);
    row.r_div2 = x(3);
    row.t_rec_ini = x(4);

    row.MR_objective = f(1);
    row.cost_objective = f(2);

    row.detail_status = local_get_string_v95k(detail, {'status','detail_status','execution_status'}, "UNKNOWN");

    row.Q_aux_tot = local_get_numeric_v95k(detail, {'outputs.Q_aux_tot','Q_aux_tot','outputs.Q_aux'}, NaN);
    row.Irradiacion = local_get_numeric_v95k(detail, {'outputs.Irradiacion','Irradiacion'}, NaN);
    row.dry_time = local_get_numeric_v95k(detail, {'outputs.dry_time','dry_time'}, NaN);
    row.M = local_get_numeric_v95k(detail, {'outputs.M','M'}, NaN);
    row.MR = local_get_numeric_v95k(detail, {'outputs.MR','MR'}, NaN);

    row.Mf = local_get_numeric_v95k(detail, {'product.Mf','Mf'}, NaN);
    row.Mi = local_get_numeric_v95k(detail, {'product.Mi','Mi'}, NaN);
    row.M_des = local_get_numeric_v95k(detail, {'product.M_des','M_des'}, NaN);

    row.cost_specific = local_get_numeric_v95k(detail, {'cost.cost_specific_USD_per_kgwater','cost_specific_USD_per_kgwater'}, NaN);
    row.total_cost = local_get_numeric_v95k(detail, {'cost.total_cost_USD','total_cost_USD'}, NaN);

    row.execution_message = local_get_string_v95k(detail, {'execution.message','message'}, "");

end

function val = local_get_numeric_v95k(S, paths, defaultVal)
    val = defaultVal;

    for k = 1:numel(paths)
        p = string(paths{k});
        parts = split(p,'.');

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
                val = tmp(1);
                return
            end
        catch
        end
    end
end

function val = local_get_string_v95k(S, paths, defaultVal)
    val = string(defaultVal);

    for k = 1:numel(paths)
        p = string(paths{k});
        parts = split(p,'.');

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

function row = local_source_row_v95k(item, filePath, pattern, passVal, evidence)
    row = struct();
    row.item = string(item);
    row.file = string(filePath);
    row.pattern = string(pattern);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end

function row = local_source_contains_v95k(item, filePath, pattern, evidenceIfFound)
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

    row = local_source_row_v95k(item, filePath, pattern, passVal, evidence);
end

function row = local_source_active_absent_v95k(item, filePath, pattern, evidenceIfAbsent)
    passVal = false;
    evidence = "FILE_NOT_FOUND";

    if isfile(filePath)
        try
            txt = fileread(filePath);
            lines = regexp(txt, '\r\n|\n|\r', 'split');

            activeContains = false;

            for k = 1:numel(lines)
                ln = strtrim(string(lines{k}));
                if strlength(ln) == 0
                    continue
                end
                if startsWith(ln,"%")
                    continue
                end
                if contains(ln, string(pattern))
                    activeContains = true;
                    break
                end
            end

            passVal = ~activeContains;

            if passVal
                evidence = string(evidenceIfAbsent);
            else
                evidence = "Active legacy pattern detected.";
            end

        catch ME
            evidence = "Could not read file: " + string(ME.message);
        end
    end

    row = local_source_row_v95k(item, filePath, pattern, passVal, evidence);
end

function tf = local_source_pass_v95k(Tsource, itemName)
    idx = strcmp(string(Tsource.item), string(itemName));
    if any(idx)
        tf = logical(Tsource.pass(find(idx,1,'first')));
    else
        tf = false;
    end
end

function row = local_check_row_v95k(id, checkName, passVal, evidence, criterion)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
    row.criterion = string(criterion);
end