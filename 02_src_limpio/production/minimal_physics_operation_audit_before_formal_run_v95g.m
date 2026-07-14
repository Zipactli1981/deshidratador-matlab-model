function audit = minimal_physics_operation_audit_before_formal_run_v95g()
% MINIMAL_PHYSICS_OPERATION_AUDIT_BEFORE_FORMAL_RUN_v95g
% 9.5g — MINIMAL-PHYSICS-OPERATION-AUDIT-BEFORE-FORMAL-RUN-001
%
% Objetivo:
%   Ejecutar una auditoría física mínima de gasLP/hybrid antes de liberar
%   la corrida formal guardada MR-costo.
%
% Este micropaso:
%   - NO ejecuta gamultiobj.
%   - NO modifica v10.
%   - NO modifica v611.
%   - NO modifica la función objetivo guardada.
%   - NO reintroduce solar puro.
%
% Requiere:
%   - 9.4h FORMAL_RUN_VALUE_GATE_PASS_HOLD_EXECUTION
%
% Salidas:
%   logs/MINIMAL_PHYSICS_OPERATION_AUDIT_v95g.md
%   logs/MINIMAL_PHYSICS_OPERATION_AUDIT_v95g.txt
%   tables/MINIMAL_PHYSICS_OPERATION_AUDIT_v95g_direct_eval.csv
%   tables/MINIMAL_PHYSICS_OPERATION_AUDIT_v95g_checks.csv
%   tables/MINIMAL_PHYSICS_OPERATION_AUDIT_v95g_source_scan.csv
%   mat/MINIMAL_PHYSICS_OPERATION_AUDIT_v95g.mat
%
% Uso:
%   audit = minimal_physics_operation_audit_before_formal_run_v95g();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    objName = 'objective_productive_corrected_v628b_nonphysical_penalty';

    if exist(objName,'file') ~= 2
        error('No se encontró la función objetivo guardada: %s', objName);
    end

    % ---------------------------------------------------------------------
    % Cargar último value gate v94h
    % ---------------------------------------------------------------------
    gateBaseDir = fullfile(rootDir,'05_runs','formal_value_gate_v94h');

    if ~isfolder(gateBaseDir)
        error('No existe gateBaseDir: %s', gateBaseDir);
    end

    d = dir(gateBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'FORMAL_RUN_VALUE_GATE_v94h_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró value gate v94h.');
    end

    [~,idxGate] = max([d.datenum]);
    gateDir = fullfile(gateBaseDir,d(idxGate).name);
    gateMat = fullfile(gateDir,'mat','FORMAL_RUN_VALUE_GATE_v94h.mat');

    if ~isfile(gateMat)
        error('No existe MAT v94h: %s', gateMat);
    end

    Sgate = load(gateMat);

    if ~isfield(Sgate,'diagnosis')
        error('v94h no contiene diagnosis.');
    end

    if ~strcmp(string(Sgate.diagnosis),"FORMAL_RUN_VALUE_GATE_PASS_HOLD_EXECUTION")
        error('v94h no está en PASS_HOLD_EXECUTION. Diagnosis: %s', string(Sgate.diagnosis));
    end

    formalDesign = Sgate.formalDesign;
    launchCommand = string(Sgate.launchCommand);

    % ---------------------------------------------------------------------
    % Crear carpeta de auditoría
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    auditBaseDir = fullfile(rootDir,'05_runs','minimal_physics_audit_v95g');
    auditDir = fullfile(auditBaseDir,['MINIMAL_PHYSICS_OPERATION_AUDIT_v95g_' timestamp]);

    logsDir = fullfile(auditDir,'logs');
    tablesDir = fullfile(auditDir,'tables');
    matDir = fullfile(auditDir,'mat');

    if ~isfolder(auditBaseDir), mkdir(auditBaseDir); end
    if ~isfolder(auditDir), mkdir(auditDir); end
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

    % Umbrales de auditoría mínima
    tol_dry_time_h = 0.50;
    tol_MR_abs = 0.020;
    min_Qaux_reduction_pct = 1.0;
    min_hybrid_irradiacion = 1e-6;
    max_allowed_penalty_MR = 999.999;
    max_allowed_penalty_cost = 999999.999;

    % ---------------------------------------------------------------------
    % Evaluación directa gasLP/hybrid/solar en x_selected
    % ---------------------------------------------------------------------
    modes = ["gasLP","hybrid","solar"];
    evalRows = {};

    for i = 1:numel(modes)
        mode = modes(i);

        [f, detail, status, errMsg] = local_eval_guarded_objective_v95g(x_selected, mode);
        row = local_detail_to_row_v95g(mode, x_selected, f, detail, status, errMsg);
        evalRows{end+1,1} = row; %#ok<AGROW>
    end

    Teval = struct2table(vertcat(evalRows{:}));
    outEvalCsv = fullfile(tablesDir,'MINIMAL_PHYSICS_OPERATION_AUDIT_v95g_direct_eval.csv');
    writetable(Teval,outEvalCsv);

    gas = Teval(strcmp(string(Teval.mode),"gasLP"),:);
    hyb = Teval(strcmp(string(Teval.mode),"hybrid"),:);
    sol = Teval(strcmp(string(Teval.mode),"solar"),:);

    % ---------------------------------------------------------------------
    % Revisión de fuentes: no corrige, solo escanea evidencias
    % ---------------------------------------------------------------------
    wrapper_v10 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v10_energy_mode_corrected.m');
    wrapper_v17 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v17_nonphysical_penalty.m');
    guard_v628b = fullfile(rootDir,'02_src_limpio','wrappers','nonphysical_guard_eval_v628b.m');
    objective_v628b = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v628b_nonphysical_penalty.m');

    sourceRows = {};

    sourceRows{end+1,1} = local_source_scan_row_v95g("wrapper_v10_exists", wrapper_v10, "", isfile(wrapper_v10), "Base wrapper available for read-only scan.");
    sourceRows{end+1,1} = local_source_scan_row_v95g("wrapper_v17_exists", wrapper_v17, "", isfile(wrapper_v17), "Guarded wrapper available for read-only scan.");
    sourceRows{end+1,1} = local_source_scan_row_v95g("guard_v628b_exists", guard_v628b, "", isfile(guard_v628b), "Nonphysical guard function available.");
    sourceRows{end+1,1} = local_source_scan_row_v95g("objective_v628b_exists", objective_v628b, "", isfile(objective_v628b), "Guarded objective available.");

    sourceRows{end+1,1} = local_source_scan_file_contains_v95g("v17_calls_guard", wrapper_v17, "nonphysical_guard_eval_v628b", "Guarded wrapper calls nonphysical guard.");
    sourceRows{end+1,1} = local_source_scan_file_contains_v95g("v17_has_nonphysical_status", wrapper_v17, "NONPHYSICAL_TRAJECTORY", "Guarded wrapper can label nonphysical trajectory.");
    sourceRows{end+1,1} = local_source_scan_file_contains_v95g("guard_checks_relative_humidity", guard_v628b, "relative_humidity", "Guard includes relative humidity domain check.");
    sourceRows{end+1,1} = local_source_scan_file_contains_v95g("guard_checks_temperature", guard_v628b, "temperature", "Guard includes temperature domain check.");
    sourceRows{end+1,1} = local_source_scan_file_contains_v95g("guard_checks_M_prod", guard_v628b, "M_prod", "Guard includes product moisture check.");

    sourceRows{end+1,1} = local_source_scan_file_contains_v95g("v10_uses_current_endpoint_M", wrapper_v10, "M_prod_fin = M_prod(i)", "Base wrapper contains current-index final moisture assignment.");
    sourceRows{end+1,1} = local_source_scan_file_contains_v95g("v10_uses_current_endpoint_MR", wrapper_v10, "MR_fin = MR(i)", "Base wrapper contains current-index final MR assignment.");

    sourceRows{end+1,1} = local_source_scan_file_contains_v95g("v10_contains_legacy_min_Mprod_pattern", wrapper_v10, "M_prod_fin = min(M_prod)", "Legacy min(M_prod) endpoint pattern present.");
    sourceRows{end+1,1} = local_source_scan_file_contains_v95g("v10_contains_legacy_MR_endminus1_pattern", wrapper_v10, "MR_fin = MR(end-1)", "Legacy MR(end-1) endpoint pattern present.");

    sourceRows{end+1,1} = local_source_scan_file_contains_v95g("v10_contains_t_rec_ini", wrapper_v10, "t_rec_ini", "Recirculation start variable appears in base wrapper.");
    sourceRows{end+1,1} = local_source_scan_file_contains_v95g("v10_contains_r_div2", wrapper_v10, "r_div2", "Recirculation ratio variable appears in base wrapper.");

    Tsource = struct2table(vertcat(sourceRows{:}));
    outSourceCsv = fullfile(tablesDir,'MINIMAL_PHYSICS_OPERATION_AUDIT_v95g_source_scan.csv');
    writetable(Tsource,outSourceCsv);

    % ---------------------------------------------------------------------
    % Checks físicos mínimos
    % ---------------------------------------------------------------------
    checks = {};

    % F01
    pass_F01 = ...
        strcmp(string(hyb.eval_status(1)),"OK") && ...
        hyb.Irradiacion(1) > min_hybrid_irradiacion && ...
        (abs(gas.Irradiacion(1)) < min_hybrid_irradiacion || isnan(gas.Irradiacion(1)));

    checks{end+1,1} = local_check_row_v95g( ...
        "F01", ...
        "hybrid_uses_solar_input", ...
        pass_F01, ...
        sprintf("hybrid Irradiacion = %.12g; gasLP Irradiacion = %.12g", hyb.Irradiacion(1), gas.Irradiacion(1)), ...
        "Hybrid must use positive solar irradiation while gasLP must not.");

    % F02
    gas_not_penalized = gas.MR_objective(1) < max_allowed_penalty_MR && gas.cost_objective(1) < max_allowed_penalty_cost;
    hyb_not_penalized = hyb.MR_objective(1) < max_allowed_penalty_MR && hyb.cost_objective(1) < max_allowed_penalty_cost;
    solar_penalized = sol.MR_objective(1) >= max_allowed_penalty_MR || sol.cost_objective(1) >= max_allowed_penalty_cost;

    pass_F02 = ...
        strcmp(string(gas.eval_status(1)),"OK") && ...
        strcmp(string(hyb.eval_status(1)),"OK") && ...
        gas_not_penalized && ...
        hyb_not_penalized && ...
        solar_penalized;

    checks{end+1,1} = local_check_row_v95g( ...
        "F02", ...
        "gasLP_hybrid_physical_domain", ...
        pass_F02, ...
        sprintf("gasLP penalized=%d; hybrid penalized=%d; solar penalized=%d", ~gas_not_penalized, ~hyb_not_penalized, solar_penalized), ...
        "gasLP and hybrid must remain non-penalized; solar must remain excluded/penalized.");

    % F03
    delta_Q_aux = hyb.Q_aux_tot(1) - gas.Q_aux_tot(1);
    reduction_Q_aux_pct = 100 * (gas.Q_aux_tot(1) - hyb.Q_aux_tot(1)) / gas.Q_aux_tot(1);
    delta_dry_time = hyb.dry_time(1) - gas.dry_time(1);
    delta_MR = hyb.MR(1) - gas.MR(1);

    pass_F03 = ...
        isfinite(delta_Q_aux) && ...
        isfinite(reduction_Q_aux_pct) && ...
        reduction_Q_aux_pct > min_Qaux_reduction_pct && ...
        abs(delta_dry_time) <= tol_dry_time_h && ...
        abs(delta_MR) <= tol_MR_abs;

    checks{end+1,1} = local_check_row_v95g( ...
        "F03", ...
        "auxiliary_control_logic", ...
        pass_F03, ...
        sprintf("Q_aux reduction = %.6g%%; delta dry_time = %.6g h; delta MR = %.12g", reduction_Q_aux_pct, delta_dry_time, delta_MR), ...
        "Hybrid should reduce auxiliary energy while preserving comparable drying endpoint.");

    % F04
    r_div2 = x_selected(3);
    t_rec_ini = x_selected(4);
    pass_F04_numeric = isfinite(r_div2) && r_div2 >= 0 && r_div2 <= 1 && isfinite(t_rec_ini) && t_rec_ini >= 0 && t_rec_ini <= 24;

    has_t_rec = local_source_scan_pass_v95g(Tsource,"v10_contains_t_rec_ini");
    has_r_div2 = local_source_scan_pass_v95g(Tsource,"v10_contains_r_div2");

    pass_F04 = pass_F04_numeric && has_t_rec && has_r_div2;

    checks{end+1,1} = local_check_row_v95g( ...
        "F04", ...
        "recirculation_logic", ...
        pass_F04, ...
        sprintf("r_div2 = %.12g; t_rec_ini = %.12g; source_has_r_div2=%d; source_has_t_rec_ini=%d", r_div2, t_rec_ini, has_r_div2, has_t_rec), ...
        "Recirculation variables must remain in physical range and appear in active wrapper.");

    % F05
    gas_M_ge_Mf = gas.M(1) >= gas.Mf(1) - 1e-6;
    hyb_M_ge_Mf = hyb.M(1) >= hyb.Mf(1) - 1e-6;

    gas_MR_domain = gas.MR(1) >= -1e-6 && gas.MR(1) <= 1 + 1e-6;
    hyb_MR_domain = hyb.MR(1) >= -1e-6 && hyb.MR(1) <= 1 + 1e-6;

    current_endpoint_supported = ...
        local_source_scan_pass_v95g(Tsource,"v10_uses_current_endpoint_M") || ...
        local_source_scan_pass_v95g(Tsource,"v10_uses_current_endpoint_MR");

    legacy_min_pattern_present = local_source_scan_pass_v95g(Tsource,"v10_contains_legacy_min_Mprod_pattern");
    legacy_endminus1_pattern_present = local_source_scan_pass_v95g(Tsource,"v10_contains_legacy_MR_endminus1_pattern");

    pass_F05 = ...
        gas_M_ge_Mf && hyb_M_ge_Mf && ...
        gas_MR_domain && hyb_MR_domain && ...
        current_endpoint_supported;

    checks{end+1,1} = local_check_row_v95g( ...
        "F05", ...
        "drying_endpoint_logic", ...
        pass_F05, ...
        sprintf("gas M=%.12g Mf=%.12g MR=%.12g; hybrid M=%.12g Mf=%.12g MR=%.12g; current_endpoint_supported=%d; legacy_min_pattern_present=%d; legacy_MR_endminus1_present=%d", ...
            gas.M(1), gas.Mf(1), gas.MR(1), hyb.M(1), hyb.Mf(1), hyb.MR(1), current_endpoint_supported, legacy_min_pattern_present, legacy_endminus1_pattern_present), ...
        "Endpoint must be from physical final state and remain in moisture-domain bounds.");

    % F06
    pass_F06 = solar_penalized && strcmp(string(formalDesign.excluded_mode),"solar");

    checks{end+1,1} = local_check_row_v95g( ...
        "F06", ...
        "solar_branch_not_reintroduced", ...
        pass_F06, ...
        sprintf("solar objective = [%.12g %.12g]; excluded_mode=%s", sol.MR_objective(1), sol.cost_objective(1), string(formalDesign.excluded_mode)), ...
        "Pure solar remains excluded until branch correction and revalidation.");

    Tchecks = struct2table(vertcat(checks{:}));
    outChecksCsv = fullfile(tablesDir,'MINIMAL_PHYSICS_OPERATION_AUDIT_v95g_checks.csv');
    writetable(Tchecks,outChecksCsv);

    % ---------------------------------------------------------------------
    % Dictamen
    % ---------------------------------------------------------------------
    auditFlags = struct();
    auditFlags.F01_hybrid_uses_solar_input = pass_F01;
    auditFlags.F02_gasLP_hybrid_physical_domain = pass_F02;
    auditFlags.F03_auxiliary_control_logic = pass_F03;
    auditFlags.F04_recirculation_logic = pass_F04;
    auditFlags.F05_drying_endpoint_logic = pass_F05;
    auditFlags.F06_solar_branch_not_reintroduced = pass_F06;

    auditFlags.all_minimal_physics_checks_pass = all(Tchecks.pass);
    auditFlags.no_model_modified = true;
    auditFlags.no_GA_executed = true;
    auditFlags.formal_run_still_on_hold = true;
    auditFlags.CO2_postprocess_design_still_pending = true;

    if auditFlags.all_minimal_physics_checks_pass
        diagnosis = "MINIMAL_PHYSICS_OPERATION_AUDIT_PASS";
    else
        diagnosis = "MINIMAL_PHYSICS_OPERATION_AUDIT_REQUIRES_REVIEW";
    end

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'MINIMAL_PHYSICS_OPERATION_AUDIT_v95g.md');
    outTxt = fullfile(logsDir,'MINIMAL_PHYSICS_OPERATION_AUDIT_v95g.txt');
    outMat = fullfile(matDir,'MINIMAL_PHYSICS_OPERATION_AUDIT_v95g.mat');

    save(outMat, ...
        'diagnosis','auditFlags','x_selected','varNames', ...
        'Teval','Tchecks','Tsource', ...
        'delta_Q_aux','reduction_Q_aux_pct','delta_dry_time','delta_MR', ...
        'formalDesign','launchCommand','gateDir','auditDir', ...
        'wrapper_v10','wrapper_v17','guard_v628b','objective_v628b', ...
        'outMd','outTxt','outMat','outEvalCsv','outChecksCsv','outSourceCsv');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# MINIMAL_PHYSICS_OPERATION_AUDIT_v95g\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Esta auditoría revisa la física mínima necesaria antes de liberar la corrida formal guardada. No ejecuta `gamultiobj` y no modifica código fuente.\n\n');

    fprintf(fid,'## Evaluación directa de referencia\n\n');
    fprintf(fid,'| Modo | eval_status | detail_status | MR obj | cost obj | Q_aux | Irradiacion | dry_time | M | Mf | MR |\n');
    fprintf(fid,'|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|\n');

    for i = 1:height(Teval)
        fprintf(fid,'| `%s` | `%s` | `%s` | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g |\n', ...
            string(Teval.mode(i)), ...
            string(Teval.eval_status(i)), ...
            string(Teval.detail_status(i)), ...
            Teval.MR_objective(i), ...
            Teval.cost_objective(i), ...
            Teval.Q_aux_tot(i), ...
            Teval.Irradiacion(i), ...
            Teval.dry_time(i), ...
            Teval.M(i), ...
            Teval.Mf(i), ...
            Teval.MR(i));
    end

    fprintf(fid,'\n## Checks físicos mínimos\n\n');
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
    fprintf(fid,'| Item | Archivo | Pass | Evidencia |\n');
    fprintf(fid,'|---|---|---:|---|\n');

    for i = 1:height(Tsource)
        fprintf(fid,'| `%s` | `%s` | `%d` | %s |\n', ...
            string(Tsource.item(i)), ...
            string(Tsource.file(i)), ...
            Tsource.pass(i), ...
            string(Tsource.evidence(i)));
    end

    fprintf(fid,'\n## Interpretación\n\n');

    if strcmp(diagnosis,"MINIMAL_PHYSICS_OPERATION_AUDIT_PASS")
        fprintf(fid,'La auditoría mínima no detectó una razón física inmediata para bloquear la corrida formal MR-costo de `hybrid`. La ejecución formal sigue en pausa porque falta cerrar el diseño de postproceso CO2 opción A.\n\n');
    else
        fprintf(fid,'La auditoría mínima detectó uno o más puntos que requieren revisión antes de ejecutar la corrida formal. No debe lanzarse la corrida hasta resolverlos.\n\n');
    end

    fprintf(fid,'## Restricciones activas\n\n');
    fprintf(fid,'- Esta auditoría no valida completamente toda la física del modelo.\n');
    fprintf(fid,'- Esta auditoría no corrige la rama solar.\n');
    fprintf(fid,'- Esta auditoría no incorpora CO2.\n');
    fprintf(fid,'- La corrida formal permanece detenida hasta cerrar 9.6g.\n');
    fprintf(fid,'- No se permite cerrar conclusiones finales de artículo todavía.\n\n');

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

    fprintf(fid,'MINIMAL-PHYSICS-OPERATION-AUDIT-BEFORE-FORMAL-RUN-001\n');
    fprintf(fid,'status: MINIMAL_PHYSICS_OPERATION_AUDIT_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'all_minimal_physics_checks_pass: %d\n', auditFlags.all_minimal_physics_checks_pass);
    fprintf(fid,'F01_hybrid_uses_solar_input: %d\n', auditFlags.F01_hybrid_uses_solar_input);
    fprintf(fid,'F02_gasLP_hybrid_physical_domain: %d\n', auditFlags.F02_gasLP_hybrid_physical_domain);
    fprintf(fid,'F03_auxiliary_control_logic: %d\n', auditFlags.F03_auxiliary_control_logic);
    fprintf(fid,'F04_recirculation_logic: %d\n', auditFlags.F04_recirculation_logic);
    fprintf(fid,'F05_drying_endpoint_logic: %d\n', auditFlags.F05_drying_endpoint_logic);
    fprintf(fid,'F06_solar_branch_not_reintroduced: %d\n', auditFlags.F06_solar_branch_not_reintroduced);
    fprintf(fid,'no_model_modified: %d\n', auditFlags.no_model_modified);
    fprintf(fid,'no_GA_executed: %d\n', auditFlags.no_GA_executed);
    fprintf(fid,'formal_run_still_on_hold: %d\n', auditFlags.formal_run_still_on_hold);
    fprintf(fid,'CO2_postprocess_design_still_pending: %d\n', auditFlags.CO2_postprocess_design_still_pending);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'KEY METRICS:\n');
    fprintf(fid,'delta_Q_aux_hybrid_minus_gasLP: %.12g\n', delta_Q_aux);
    fprintf(fid,'reduction_Q_aux_pct: %.12g\n', reduction_Q_aux_pct);
    fprintf(fid,'delta_dry_time_hybrid_minus_gasLP: %.12g\n', delta_dry_time);
    fprintf(fid,'delta_MR_hybrid_minus_gasLP: %.12g\n\n', delta_MR);

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
    audit = struct();
    audit.status = 'MINIMAL_PHYSICS_OPERATION_AUDIT_COMPLETED';
    audit.diagnosis = diagnosis;
    audit.auditFlags = auditFlags;
    audit.x_selected = x_selected;
    audit.Teval = Teval;
    audit.Tchecks = Tchecks;
    audit.Tsource = Tsource;
    audit.delta_Q_aux = delta_Q_aux;
    audit.reduction_Q_aux_pct = reduction_Q_aux_pct;
    audit.delta_dry_time = delta_dry_time;
    audit.delta_MR = delta_MR;
    audit.launchCommand = launchCommand;
    audit.auditDir = auditDir;
    audit.outMd = outMd;
    audit.outTxt = outTxt;
    audit.outMat = outMat;
    audit.outEvalCsv = outEvalCsv;
    audit.outChecksCsv = outChecksCsv;
    audit.outSourceCsv = outSourceCsv;

    disp('=== MINIMAL_PHYSICS_OPERATION_AUDIT_v95g ===')
    disp(audit.status)
    disp('=== DIAGNOSIS ===')
    disp(audit.diagnosis)
    disp('=== AUDIT FLAGS ===')
    disp(audit.auditFlags)
    disp('=== DIRECT EVALUATION ===')
    disp(audit.Teval)
    disp('=== CHECKS ===')
    disp(audit.Tchecks)
    disp('=== SOURCE SCAN ===')
    disp(audit.Tsource)
    disp('=== KEY METRICS ===')
    fprintf('delta_Q_aux_hybrid_minus_gasLP = %.12g\n', audit.delta_Q_aux);
    fprintf('reduction_Q_aux_pct = %.12g\n', audit.reduction_Q_aux_pct);
    fprintf('delta_dry_time_hybrid_minus_gasLP = %.12g\n', audit.delta_dry_time);
    fprintf('delta_MR_hybrid_minus_gasLP = %.12g\n', audit.delta_MR);
    disp('=== OUTPUT FILES ===')
    disp(audit.outMd)
    disp(audit.outTxt)
    disp(audit.outMat)

end

% =========================================================================
% Funciones locales auxiliares
% =========================================================================

function [f, detail, status, errMsg] = local_eval_guarded_objective_v95g(x, mode)
    status = "OK";
    errMsg = "";
    detail = struct();

    try
        [f, detail] = objective_productive_corrected_v628b_nonphysical_penalty(x, mode);
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

function row = local_detail_to_row_v95g(mode, x, f, detail, status, errMsg)

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

    row.detail_status = local_get_string_v95g(detail, {'status','detail_status','execution_status'}, "UNKNOWN");

    row.Q_aux_tot = local_get_numeric_v95g(detail, {'outputs.Q_aux_tot','Q_aux_tot','outputs.Q_aux'}, NaN);
    row.Irradiacion = local_get_numeric_v95g(detail, {'outputs.Irradiacion','Irradiacion'}, NaN);
    row.dry_time = local_get_numeric_v95g(detail, {'outputs.dry_time','dry_time'}, NaN);
    row.M = local_get_numeric_v95g(detail, {'outputs.M','M'}, NaN);
    row.MR = local_get_numeric_v95g(detail, {'outputs.MR','MR'}, NaN);

    row.Mf = local_get_numeric_v95g(detail, {'product.Mf','Mf'}, NaN);
    row.Mi = local_get_numeric_v95g(detail, {'product.Mi','Mi'}, NaN);
    row.M_des = local_get_numeric_v95g(detail, {'product.M_des','M_des'}, NaN);

    row.cost_specific = local_get_numeric_v95g(detail, {'cost.cost_specific_USD_per_kgwater','cost_specific_USD_per_kgwater'}, NaN);
    row.total_cost = local_get_numeric_v95g(detail, {'cost.total_cost_USD','total_cost_USD'}, NaN);

    row.execution_message = local_get_string_v95g(detail, {'execution.message','message'}, "");

end

function row = local_check_row_v95g(id, checkName, passVal, evidence, criterion)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
    row.criterion = string(criterion);
end

function row = local_source_scan_row_v95g(item, filePath, pattern, passVal, evidence)
    row = struct();
    row.item = string(item);
    row.file = string(filePath);
    row.pattern = string(pattern);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end

function row = local_source_scan_file_contains_v95g(item, filePath, pattern, evidenceIfFound)
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

    row = local_source_scan_row_v95g(item, filePath, pattern, passVal, evidence);
end

function passVal = local_source_scan_pass_v95g(Tsource, itemName)
    idx = strcmp(string(Tsource.item), string(itemName));
    if any(idx)
        passVal = logical(Tsource.pass(find(idx,1,'first')));
    else
        passVal = false;
    end
end

function val = local_get_numeric_v95g(S, paths, defaultVal)
    val = defaultVal;

    for i = 1:numel(paths)
        p = string(paths{i});
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

function val = local_get_string_v95g(S, paths, defaultVal)
    val = string(defaultVal);

    for i = 1:numel(paths)
        p = string(paths{i});
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