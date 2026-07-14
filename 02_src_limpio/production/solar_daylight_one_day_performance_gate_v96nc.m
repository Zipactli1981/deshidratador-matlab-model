function gate = solar_daylight_one_day_performance_gate_v96nc()
% SOLAR_DAYLIGHT_ONE_DAY_PERFORMANCE_GATE_v96nc
% 9.6n-c — SOLAR-DAYLIGHT-ONE-DAY-PERFORMANCE-GATE
%
% Objetivo:
%   Evaluar si el modo solar puro puede tratarse como desempeño de una
%   jornada solar, no como modo equivalente dentro del GA formal.
%
% Pregunta correcta para solar:
%   ¿Qué MR/humedad alcanza al cierre de una ventana solar diaria?
%
% Pregunta que NO se debe forzar:
%   ¿Cuánto tarda solar puro en llegar a MR objetivo contando noche?
%
% Este paso:
%   - NO ejecuta gamultiobj.
%   - NO ejecuta corrida formal v96m.
%   - NO modifica v10/v17/v18/v95j/v96j_fix1.
%   - Evalúa el estado actual de solar.
%   - Determina si las salidas actuales contienen trayectoria suficiente.
%   - Si no hay trayectoria disponible por penalización, recomienda crear
%     un replay solar diurno acotado antes de decidir si se documenta o no.
%
% Uso:
%   gate = solar_daylight_one_day_performance_gate_v96nc();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Cargar aprobación 9.6n como contexto
    % ---------------------------------------------------------------------
    approvalBaseDir = fullfile(rootDir,'05_runs','triobjective_formal_execution_approval_v96n');

    if ~isfolder(approvalBaseDir)
        error('No existe approvalBaseDir: %s', approvalBaseDir);
    end

    d = dir(approvalBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'TRIOBJECTIVE_FORMAL_EXECUTION_APPROVAL_v96n_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró aprobación v96n.');
    end

    [~,idxApproval] = max([d.datenum]);
    approvalDirPrev = fullfile(approvalBaseDir,d(idxApproval).name);
    approvalMat = fullfile(approvalDirPrev,'mat','TRIOBJECTIVE_FORMAL_EXECUTION_APPROVAL_v96n.mat');

    if ~isfile(approvalMat)
        error('No existe MAT v96n: %s', approvalMat);
    end

    Sapproval = load(approvalMat);

    if ~strcmp(string(Sapproval.diagnosis),"TRIOBJECTIVE_FORMAL_RUN_EXECUTION_APPROVAL_PASS")
        error('9.6n no está en PASS. Diagnosis: %s', string(Sapproval.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Archivos protegidos
    % ---------------------------------------------------------------------
    objective_v96j_fix1 = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v96j_triobjective_CO2_fix1.m');
    formal_script_v96m = fullfile(rootDir,'02_src_limpio','production','run_guarded_triobjective_formal_ga_v96m.m');

    wrapper_v10 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v10_energy_mode_corrected.m');
    wrapper_v17 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v17_nonphysical_penalty.m');
    wrapper_v18 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v18_endpoint_TMAX_corrected.m');
    objective_v95j = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v95j_endpoint_TMAX_corrected.m');
    objective_v628b = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v628b_nonphysical_penalty.m');

    if exist('objective_productive_corrected_v96j_triobjective_CO2_fix1','file') ~= 2
        error('No está visible objective_productive_corrected_v96j_triobjective_CO2_fix1.');
    end

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    gateBaseDir = fullfile(rootDir,'05_runs','solar_daylight_one_day_performance_gate_v96nc');
    gateDir = fullfile(gateBaseDir,['SOLAR_DAYLIGHT_ONE_DAY_PERFORMANCE_GATE_v96nc_' timestamp]);

    logsDir = fullfile(gateDir,'logs');
    tablesDir = fullfile(gateDir,'tables');
    matDir = fullfile(gateDir,'mat');

    if ~isfolder(gateBaseDir), mkdir(gateBaseDir); end
    if ~isfolder(gateDir), mkdir(gateDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Punto seleccionado
    % ---------------------------------------------------------------------
    x_selected = [ ...
        0.0740767982118, ...
        62.6832965028, ...
        0.672252618341, ...
        11.6517528081];

    MR_target = 0.10;

    % Definición conceptual para el gate.
    % No se fuerza en simulación todavía; solo se registra.
    daylight_definition = "SOLAR_DAY_WINDOW_REQUIRED_NOT_YET_IMPLEMENTED";
    daylight_metric = "MR_final_at_end_of_solar_day";
    solar_question = "How far does solar-only drying progress during one solar day?";

    % ---------------------------------------------------------------------
    % Evaluación directa actual con objetivo triobjetivo
    % ---------------------------------------------------------------------
    modes = ["gasLP","hybrid","solar"];
    evalRows = {};
    detailSolar = struct();

    for i = 1:numel(modes)
        mode = modes(i);
        [f, d0, status, errMsg] = local_eval_triobjective_v96nc(x_selected, mode);

        if mode == "solar"
            detailSolar = d0;
        end

        evalRows{end+1,1} = local_eval_row_v96nc(mode, x_selected, f, d0, status, errMsg); %#ok<AGROW>
    end

    Teval = struct2table(vertcat(evalRows{:}));

    gas = Teval(strcmp(string(Teval.mode),"gasLP"),:);
    hyb = Teval(strcmp(string(Teval.mode),"hybrid"),:);
    sol = Teval(strcmp(string(Teval.mode),"solar"),:);

    gas_valid = strcmp(string(gas.status(1)),"OK") && strcmp(string(gas.detail_status(1)),"OK") && gas.nobj(1)==3;
    hyb_valid = strcmp(string(hyb.status(1)),"OK") && strcmp(string(hyb.detail_status(1)),"OK") && hyb.nobj(1)==3;

    solar_penalized = sol.nobj(1)==3 && ...
        sol.f1(1) >= 999.999 && ...
        sol.f2(1) >= 999999.999 && ...
        sol.f3(1) >= 999999.999;

    solar_current_detail_status = string(sol.detail_status(1));

    % ---------------------------------------------------------------------
    % Auditoría de disponibilidad de trayectoria solar
    % ---------------------------------------------------------------------
    trajectoryAudit = local_audit_solar_trajectory_v96nc(detailSolar);
    TtrajectoryAudit = struct2table(trajectoryAudit);

    has_time_vector = trajectoryAudit.has_time_vector;
    has_irradiance_vector = trajectoryAudit.has_irradiance_vector;
    has_moisture_or_MR_vector = trajectoryAudit.has_moisture_or_MR_vector;
    has_energy_vector = trajectoryAudit.has_energy_vector;

    daylight_replay_possible_from_current_detail = ...
        has_time_vector && has_irradiance_vector && has_moisture_or_MR_vector;

    % ---------------------------------------------------------------------
    % Si hubiera trayectoria, intentar resumen diurno.
    % En el estado actual se espera que NO exista porque solar está penalizado.
    % ---------------------------------------------------------------------
    daylightRows = {};

    if daylight_replay_possible_from_current_detail
        daylightRows{end+1,1} = local_daylight_summary_placeholder_v96nc( ...
            "solar", ...
            "TRAJECTORY_FIELDS_DETECTED_BUT_REPLAY_NOT_IMPLEMENTED_IN_THIS_GATE", ...
            MR_target);
    else
        daylightRows{end+1,1} = local_daylight_summary_placeholder_v96nc( ...
            "solar", ...
            "NO_USABLE_SOLAR_DAYLIGHT_TRAJECTORY_FROM_CURRENT_OBJECTIVE", ...
            MR_target);
    end

    Tdaylight = struct2table(vertcat(daylightRows{:}));

    % ---------------------------------------------------------------------
    % Opciones metodológicas
    % ---------------------------------------------------------------------
    optionRows = {};

    optionRows{end+1,1} = local_option_row_v96nc( ...
        "A", ...
        "DO_NOT_FORCE_SOLAR_IN_FORMAL_GA", ...
        true, ...
        "Solar-only is not operationally equivalent to hybrid/gasLP under dry_time-to-target.", ...
        "Keep formal GA focused on hybrid with gasLP reference.");

    optionRows{end+1,1} = local_option_row_v96nc( ...
        "B", ...
        "CREATE_SOLAR_DAYLIGHT_REPLAY", ...
        ~daylight_replay_possible_from_current_detail, ...
        "Needed to answer one-day solar question without counting night hours.", ...
        "Recommended before writing final methodological exclusion.");

    optionRows{end+1,1} = local_option_row_v96nc( ...
        "C", ...
        "RUN_HYBRID_FORMAL_NOW_AND_DOCUMENT_SOLAR_AS_FUTURE_WORK", ...
        false, ...
        "Possible, but weaker because solar one-day behavior would remain unquantified.", ...
        "Not recommended until daylight gate is closed.");

    optionRows{end+1,1} = local_option_row_v96nc( ...
        "D", ...
        "REINTRODUCE_SOLAR_IN_MULTI_MODE_GA", ...
        false, ...
        "Not appropriate unless solar has an equivalent operational definition.", ...
        "Do not do this in current formal route.");

    Toptions = struct2table(vertcat(optionRows{:}));

    % ---------------------------------------------------------------------
    % Requisitos para el replay solar diurno si se crea
    % ---------------------------------------------------------------------
    reqRows = {};

    reqRows{end+1,1} = local_req_row_v96nc("R01","Use one-day solar window, not dry_time-to-target over night.",true);
    reqRows{end+1,1} = local_req_row_v96nc("R02","Report MR or moisture at end of solar day.",true);
    reqRows{end+1,1} = local_req_row_v96nc("R03","Report water removed during solar day.",true);
    reqRows{end+1,1} = local_req_row_v96nc("R04","Report solar irradiation/energy used or available.",true);
    reqRows{end+1,1} = local_req_row_v96nc("R05","Report auxiliary LPG energy as zero for solar-only.",true);
    reqRows{end+1,1} = local_req_row_v96nc("R06","Report electrical CO2 only if fans/control electricity is modeled.",true);
    reqRows{end+1,1} = local_req_row_v96nc("R07","Do not compare solar dry_time directly against hybrid/gasLP.",true);
    reqRows{end+1,1} = local_req_row_v96nc("R08","If MR target is not reached in one day, exclude solar from formal production optimization.",true);
    reqRows{end+1,1} = local_req_row_v96nc("R09","Do not modify protected validated sources.",true);

    Trequirements = struct2table(vertcat(reqRows{:}));

    % ---------------------------------------------------------------------
    % Source scan
    % ---------------------------------------------------------------------
    sourceRows = {};

    sourceRows{end+1,1} = local_source_row_v96nc("objective_v96j_fix1_exists", objective_v96j_fix1, "", isfile(objective_v96j_fix1), "Triobjective objective exists.");
    sourceRows{end+1,1} = local_source_row_v96nc("formal_script_v96m_exists", formal_script_v96m, "", isfile(formal_script_v96m), "Formal script exists.");
    sourceRows{end+1,1} = local_source_row_v96nc("v10_preserved", wrapper_v10, "", isfile(wrapper_v10), "v10 preserved.");
    sourceRows{end+1,1} = local_source_row_v96nc("v17_preserved", wrapper_v17, "", isfile(wrapper_v17), "v17 preserved.");
    sourceRows{end+1,1} = local_source_row_v96nc("v18_preserved", wrapper_v18, "", isfile(wrapper_v18), "v18 preserved.");
    sourceRows{end+1,1} = local_source_row_v96nc("v95j_preserved", objective_v95j, "", isfile(objective_v95j), "v95j preserved.");
    sourceRows{end+1,1} = local_source_row_v96nc("v628b_preserved", objective_v628b, "", isfile(objective_v628b), "v628b preserved.");

    sourceRows{end+1,1} = local_source_contains_v96nc("objective_has_1x3_penalty", objective_v96j_fix1, "penalty = [1000, 1e6, 1e6];", "Objective has controlled 1x3 penalty.");
    sourceRows{end+1,1} = local_source_contains_v96nc("formal_script_is_hybrid_mode", formal_script_v96m, "modeFormal = ""hybrid"";", "Formal GA remains hybrid-only.");

    Tsource = struct2table(vertcat(sourceRows{:}));
    source_preservation_pass = all(Tsource.pass);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};

    checks{end+1,1} = local_check_row_v96nc( ...
        "C01", ...
        "Formal approval exists", ...
        strcmp(string(Sapproval.diagnosis),"TRIOBJECTIVE_FORMAL_RUN_EXECUTION_APPROVAL_PASS"), ...
        string(Sapproval.diagnosis), ...
        "9.6n must be approved before this gate.");

    checks{end+1,1} = local_check_row_v96nc( ...
        "C02", ...
        "Formal not yet executed", ...
        Sapproval.approvalFlags.formal_run_not_executed_yet == true, ...
        "formal_run_not_executed_yet=1", ...
        "This methodological gate must occur before formal execution.");

    checks{end+1,1} = local_check_row_v96nc( ...
        "C03", ...
        "gasLP and hybrid remain valid", ...
        gas_valid && hyb_valid, ...
        sprintf("gas f=[%.6g %.6g %.6g]; hybrid f=[%.6g %.6g %.6g]", ...
            gas.f1(1), gas.f2(1), gas.f3(1), ...
            hyb.f1(1), hyb.f2(1), hyb.f3(1)), ...
        "Validated modes must remain valid.");

    checks{end+1,1} = local_check_row_v96nc( ...
        "C04", ...
        "solar currently excluded in triobjective objective", ...
        solar_penalized, ...
        sprintf("solar detail=%s; f=[%.6g %.6g %.6g]", ...
            solar_current_detail_status, sol.f1(1), sol.f2(1), sol.f3(1)), ...
        "Solar should not be forced into formal GA while penalized.");

    checks{end+1,1} = local_check_row_v96nc( ...
        "C05", ...
        "daylight trajectory availability checked", ...
        true, ...
        sprintf("time=%d; irradiance=%d; moisture_or_MR=%d; energy=%d", ...
            has_time_vector, has_irradiance_vector, has_moisture_or_MR_vector, has_energy_vector), ...
        "Gate must determine whether current detail can support daylight summary.");

    checks{end+1,1} = local_check_row_v96nc( ...
        "C06", ...
        "current objective cannot yet answer one-day solar performance", ...
        ~daylight_replay_possible_from_current_detail, ...
        sprintf("daylight_replay_possible_from_current_detail=%d", daylight_replay_possible_from_current_detail), ...
        "If no trajectory exists, create dedicated daylight replay.");

    checks{end+1,1} = local_check_row_v96nc( ...
        "C07", ...
        "source preservation", ...
        source_preservation_pass, ...
        "Protected files are available.", ...
        "No protected source may be missing.");

    checks{end+1,1} = local_check_row_v96nc( ...
        "C08", ...
        "formal hybrid route remains valid", ...
        strcmp(string(Sapproval.approvalFlags.modeFormal),"hybrid") && strcmp(string(Sapproval.approvalFlags.referenceMode),"gasLP"), ...
        sprintf("modeFormal=%s; referenceMode=%s", ...
            string(Sapproval.approvalFlags.modeFormal), string(Sapproval.approvalFlags.referenceMode)), ...
        "Hybrid formal route remains valid after solar methodological separation.");

    Tchecks = struct2table(vertcat(checks{:}));

    % ---------------------------------------------------------------------
    % Decisión
    % ---------------------------------------------------------------------
    if solar_penalized && ~daylight_replay_possible_from_current_detail
        diagnosis = "SOLAR_DAYLIGHT_ONE_DAY_GATE_PASS_REPLAY_REQUIRED";
        decision = "CREATE_SOLAR_DAYLIGHT_REPLAY_BEFORE_FORMAL_RUN";
        next_step = "9.6n-d — CREATE-SOLAR-DAYLIGHT-ONE-DAY-REPLAY-001";
        approved_to_run_formal_now = false;
    elseif solar_penalized && daylight_replay_possible_from_current_detail
        diagnosis = "SOLAR_DAYLIGHT_ONE_DAY_GATE_PASS_TRAJECTORY_AVAILABLE";
        decision = "SUMMARIZE_SOLAR_DAYLIGHT_PERFORMANCE_THEN_FORMAL";
        next_step = "9.6n-d — SUMMARIZE-SOLAR-DAYLIGHT-TRAJECTORY-001";
        approved_to_run_formal_now = false;
    else
        diagnosis = "SOLAR_DAYLIGHT_ONE_DAY_GATE_REQUIRES_REVIEW";
        decision = "REVIEW_SOLAR_STATUS_BEFORE_FORMAL";
        next_step = "Review solar objective/detail status.";
        approved_to_run_formal_now = false;
    end

    gateFlags = struct();
    gateFlags.formal_approval_v96n_pass = strcmp(string(Sapproval.diagnosis),"TRIOBJECTIVE_FORMAL_RUN_EXECUTION_APPROVAL_PASS");
    gateFlags.formal_not_executed_yet = Sapproval.approvalFlags.formal_run_not_executed_yet;
    gateFlags.gasLP_valid = gas_valid;
    gateFlags.hybrid_valid = hyb_valid;
    gateFlags.solar_penalized = solar_penalized;
    gateFlags.solar_current_detail_status = solar_current_detail_status;
    gateFlags.daylight_question_defined = true;
    gateFlags.daylight_replay_possible_from_current_detail = daylight_replay_possible_from_current_detail;
    gateFlags.has_time_vector = has_time_vector;
    gateFlags.has_irradiance_vector = has_irradiance_vector;
    gateFlags.has_moisture_or_MR_vector = has_moisture_or_MR_vector;
    gateFlags.has_energy_vector = has_energy_vector;
    gateFlags.source_preservation_pass = source_preservation_pass;
    gateFlags.approved_to_run_formal_now = approved_to_run_formal_now;
    gateFlags.replay_required_before_formal = strcmp(decision,"CREATE_SOLAR_DAYLIGHT_REPLAY_BEFORE_FORMAL_RUN");
    gateFlags.no_GA_executed_in_this_step = true;
    gateFlags.no_sources_modified = true;
    gateFlags.CO2_factors_still_provisional = true;

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outEvalCsv = fullfile(tablesDir,'SOLAR_DAYLIGHT_ONE_DAY_PERFORMANCE_GATE_v96nc_eval.csv');
    outTrajectoryCsv = fullfile(tablesDir,'SOLAR_DAYLIGHT_ONE_DAY_PERFORMANCE_GATE_v96nc_trajectory_audit.csv');
    outDaylightCsv = fullfile(tablesDir,'SOLAR_DAYLIGHT_ONE_DAY_PERFORMANCE_GATE_v96nc_daylight_summary.csv');
    outOptionsCsv = fullfile(tablesDir,'SOLAR_DAYLIGHT_ONE_DAY_PERFORMANCE_GATE_v96nc_options.csv');
    outReqCsv = fullfile(tablesDir,'SOLAR_DAYLIGHT_ONE_DAY_PERFORMANCE_GATE_v96nc_requirements.csv');
    outSourceCsv = fullfile(tablesDir,'SOLAR_DAYLIGHT_ONE_DAY_PERFORMANCE_GATE_v96nc_source_scan.csv');
    outChecksCsv = fullfile(tablesDir,'SOLAR_DAYLIGHT_ONE_DAY_PERFORMANCE_GATE_v96nc_checks.csv');

    writetable(Teval,outEvalCsv);
    writetable(TtrajectoryAudit,outTrajectoryCsv);
    writetable(Tdaylight,outDaylightCsv);
    writetable(Toptions,outOptionsCsv);
    writetable(Trequirements,outReqCsv);
    writetable(Tsource,outSourceCsv);
    writetable(Tchecks,outChecksCsv);

    outMd = fullfile(logsDir,'SOLAR_DAYLIGHT_ONE_DAY_PERFORMANCE_GATE_v96nc.md');
    outTxt = fullfile(logsDir,'SOLAR_DAYLIGHT_ONE_DAY_PERFORMANCE_GATE_v96nc.txt');
    outMat = fullfile(matDir,'SOLAR_DAYLIGHT_ONE_DAY_PERFORMANCE_GATE_v96nc.mat');

    save(outMat, ...
        'diagnosis','decision','next_step','gateFlags', ...
        'x_selected','MR_target','daylight_definition','daylight_metric','solar_question', ...
        'Teval','TtrajectoryAudit','Tdaylight','Toptions','Trequirements','Tsource','Tchecks', ...
        'objective_v96j_fix1','formal_script_v96m','wrapper_v10','wrapper_v17','wrapper_v18','objective_v95j','objective_v628b', ...
        'approvalDirPrev','gateDir', ...
        'outMd','outTxt','outMat','outEvalCsv','outTrajectoryCsv','outDaylightCsv','outOptionsCsv','outReqCsv','outSourceCsv','outChecksCsv');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# SOLAR_DAYLIGHT_ONE_DAY_PERFORMANCE_GATE_v96nc\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Decisión: `%s`\n\n', decision);
    fprintf(fid,'Siguiente paso: `%s`\n\n', next_step);

    fprintf(fid,'## Pregunta metodológica solar\n\n');
    fprintf(fid,'Solar puro no se evalúa por tiempo total hasta MR objetivo contando noche. La pregunta correcta es: ¿qué humedad alcanza durante una jornada solar disponible?\n\n');

    fprintf(fid,'## Evaluación directa actual\n\n');
    fprintf(fid,'| mode | status | detail | nobj | f1 MR | f2 cost | f3 CO2 | Q_aux | Irr | dry_time | M |\n');
    fprintf(fid,'|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|\n');

    for i = 1:height(Teval)
        fprintf(fid,'| `%s` | `%s` | `%s` | %d | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g |\n', ...
            string(Teval.mode(i)), ...
            string(Teval.status(i)), ...
            string(Teval.detail_status(i)), ...
            Teval.nobj(i), ...
            Teval.f1(i), ...
            Teval.f2(i), ...
            Teval.f3(i), ...
            Teval.Q_aux_tot(i), ...
            Teval.Irradiacion(i), ...
            Teval.dry_time(i), ...
            Teval.M(i));
    end

    fprintf(fid,'\n## Auditoría de trayectoria solar\n\n');
    fprintf(fid,'| Campo | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| has_time_vector | %d |\n', has_time_vector);
    fprintf(fid,'| has_irradiance_vector | %d |\n', has_irradiance_vector);
    fprintf(fid,'| has_moisture_or_MR_vector | %d |\n', has_moisture_or_MR_vector);
    fprintf(fid,'| has_energy_vector | %d |\n', has_energy_vector);
    fprintf(fid,'| daylight_replay_possible_from_current_detail | %d |\n\n', daylight_replay_possible_from_current_detail);

    fprintf(fid,'## Opciones\n\n');
    fprintf(fid,'| ID | Opción | Recomendada | Razón | Implicación |\n');
    fprintf(fid,'|---|---|---:|---|---|\n');

    for i = 1:height(Toptions)
        fprintf(fid,'| `%s` | `%s` | `%d` | %s | %s |\n', ...
            string(Toptions.option_id(i)), ...
            string(Toptions.name(i)), ...
            Toptions.recommended(i), ...
            string(Toptions.reason(i)), ...
            string(Toptions.implication(i)));
    end

    fprintf(fid,'\n## Requisitos para replay solar diurno\n\n');
    fprintf(fid,'| ID | Requisito | Obligatorio |\n');
    fprintf(fid,'|---|---|---:|\n');

    for i = 1:height(Trequirements)
        fprintf(fid,'| `%s` | %s | `%d` |\n', ...
            string(Trequirements.id(i)), ...
            string(Trequirements.requirement(i)), ...
            Trequirements.required(i));
    end

    fprintf(fid,'\n## Checks\n\n');
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

    fprintf(fid,'\n## Dictamen\n\n');

    if strcmp(decision,"CREATE_SOLAR_DAYLIGHT_REPLAY_BEFORE_FORMAL_RUN")
        fprintf(fid,'El objetivo triobjetivo actual penaliza solar y no entrega una trayectoria solar diurna utilizable. Por tanto, no puede responder todavía cuánta humedad alcanza solar en una jornada. Se recomienda crear un replay solar diurno acotado, sin GA, antes de ejecutar la formal híbrida.\n\n');
    else
        fprintf(fid,'Revisar decisión y trayectoria antes de ejecutar formal.\n\n');
    end

    fprintf(fid,'## Restricciones\n\n');
    fprintf(fid,'- No se ejecutó `gamultiobj`.\n');
    fprintf(fid,'- No se modificaron fuentes.\n');
    fprintf(fid,'- Solar no se reintroduce en el GA formal.\n');
    fprintf(fid,'- Formal híbrida sigue detenida hasta cerrar este gate solar diurno.\n');
    fprintf(fid,'- CO2 sigue con factores provisionales.\n');

    fclose(fid);

    % TXT
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'SOLAR-DAYLIGHT-ONE-DAY-PERFORMANCE-GATE\n');
    fprintf(fid,'status: SOLAR_DAYLIGHT_ONE_DAY_PERFORMANCE_GATE_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'decision: %s\n', decision);
    fprintf(fid,'next_step: %s\n', next_step);
    fprintf(fid,'formal_approval_v96n_pass: %d\n', gateFlags.formal_approval_v96n_pass);
    fprintf(fid,'formal_not_executed_yet: %d\n', gateFlags.formal_not_executed_yet);
    fprintf(fid,'gasLP_valid: %d\n', gateFlags.gasLP_valid);
    fprintf(fid,'hybrid_valid: %d\n', gateFlags.hybrid_valid);
    fprintf(fid,'solar_penalized: %d\n', gateFlags.solar_penalized);
    fprintf(fid,'solar_current_detail_status: %s\n', gateFlags.solar_current_detail_status);
    fprintf(fid,'daylight_question_defined: %d\n', gateFlags.daylight_question_defined);
    fprintf(fid,'daylight_replay_possible_from_current_detail: %d\n', gateFlags.daylight_replay_possible_from_current_detail);
    fprintf(fid,'has_time_vector: %d\n', gateFlags.has_time_vector);
    fprintf(fid,'has_irradiance_vector: %d\n', gateFlags.has_irradiance_vector);
    fprintf(fid,'has_moisture_or_MR_vector: %d\n', gateFlags.has_moisture_or_MR_vector);
    fprintf(fid,'has_energy_vector: %d\n', gateFlags.has_energy_vector);
    fprintf(fid,'source_preservation_pass: %d\n', gateFlags.source_preservation_pass);
    fprintf(fid,'approved_to_run_formal_now: %d\n', gateFlags.approved_to_run_formal_now);
    fprintf(fid,'replay_required_before_formal: %d\n', gateFlags.replay_required_before_formal);
    fprintf(fid,'no_GA_executed_in_this_step: %d\n', gateFlags.no_GA_executed_in_this_step);
    fprintf(fid,'no_sources_modified: %d\n', gateFlags.no_sources_modified);
    fprintf(fid,'CO2_factors_still_provisional: %d\n', gateFlags.CO2_factors_still_provisional);
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Salida consola
    % ---------------------------------------------------------------------
    gate = struct();
    gate.status = 'SOLAR_DAYLIGHT_ONE_DAY_PERFORMANCE_GATE_COMPLETED';
    gate.diagnosis = diagnosis;
    gate.decision = decision;
    gate.next_step = next_step;
    gate.gateFlags = gateFlags;
    gate.Teval = Teval;
    gate.TtrajectoryAudit = TtrajectoryAudit;
    gate.Tdaylight = Tdaylight;
    gate.Toptions = Toptions;
    gate.Trequirements = Trequirements;
    gate.Tsource = Tsource;
    gate.Tchecks = Tchecks;
    gate.gateDir = gateDir;
    gate.outMd = outMd;
    gate.outTxt = outTxt;
    gate.outMat = outMat;

    disp('=== SOLAR_DAYLIGHT_ONE_DAY_PERFORMANCE_GATE_v96nc ===')
    disp(gate.status)
    disp('=== DIAGNOSIS ===')
    disp(gate.diagnosis)
    disp('=== DECISION ===')
    disp(gate.decision)
    disp('=== NEXT STEP ===')
    disp(gate.next_step)
    disp('=== GATE FLAGS ===')
    disp(gate.gateFlags)
    disp('=== DIRECT EVALUATION ===')
    disp(gate.Teval)
    disp('=== TRAJECTORY AUDIT ===')
    disp(gate.TtrajectoryAudit)
    disp('=== DAYLIGHT SUMMARY PLACEHOLDER ===')
    disp(gate.Tdaylight)
    disp('=== OPTIONS ===')
    disp(gate.Toptions)
    disp('=== CHECKS ===')
    disp(gate.Tchecks)
    disp('=== OUTPUT FILES ===')
    disp(gate.outMd)
    disp(gate.outTxt)
    disp(gate.outMat)

end

% =========================================================================
% Helpers
% =========================================================================

function [f, detail, status, errMsg] = local_eval_triobjective_v96nc(x, mode)
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

function row = local_eval_row_v96nc(mode, x, f, detail, status, errMsg)
    row = struct();

    row.mode = string(mode);
    row.status = string(status);
    row.error_message = string(errMsg);

    row.m_max = x(1);
    row.T_min = x(2);
    row.r_div2 = x(3);
    row.t_rec_ini = x(4);

    row.nobj = numel(f);
    row.f1 = local_vec_get_v96nc(f,1,NaN);
    row.f2 = local_vec_get_v96nc(f,2,NaN);
    row.f3 = local_vec_get_v96nc(f,3,NaN);

    row.detail_status = local_get_string_v96nc(detail, {'status','detail_status','execution_status'}, "UNKNOWN");
    row.Q_aux_tot = local_get_numeric_v96nc(detail, {'outputs.Q_aux_tot','Q_aux_tot'}, NaN);
    row.Irradiacion = local_get_numeric_v96nc(detail, {'outputs.Irradiacion','Irradiacion'}, NaN);
    row.dry_time = local_get_numeric_v96nc(detail, {'outputs.dry_time','dry_time'}, NaN);
    row.M = local_get_numeric_v96nc(detail, {'outputs.M','M'}, NaN);
    row.MR = local_get_numeric_v96nc(detail, {'outputs.MR','MR'}, NaN);
    row.CO2_total_kg = local_get_numeric_v96nc(detail, {'CO2.CO2_total_kg'}, NaN);
    row.CO2_specific = local_get_numeric_v96nc(detail, {'CO2.CO2_specific_kgCO2_per_kgwater'}, NaN);
    row.emission_factor_status = local_get_string_v96nc(detail, {'CO2.emission_factor_status'}, "");
end

function audit = local_audit_solar_trajectory_v96nc(detail)
    audit = struct();

    audit.has_detail_struct = isstruct(detail);
    audit.has_time_vector = false;
    audit.has_irradiance_vector = false;
    audit.has_moisture_or_MR_vector = false;
    audit.has_energy_vector = false;

    audit.time_candidate_path = "";
    audit.irradiance_candidate_path = "";
    audit.moisture_candidate_path = "";
    audit.energy_candidate_path = "";

    audit.n_time = 0;
    audit.n_irradiance = 0;
    audit.n_moisture = 0;
    audit.n_energy = 0;

    if ~isstruct(detail)
        return
    end

    candidates = local_collect_numeric_vectors_v96nc(detail, "detail");

    for i = 1:numel(candidates)
        p = lower(string(candidates(i).path));
        n = candidates(i).n;

        if ~audit.has_time_vector && n >= 5 && (contains(p,"time") || contains(p,"tiempo") || contains(p,"hora") || endsWith(p,".t"))
            audit.has_time_vector = true;
            audit.time_candidate_path = string(candidates(i).path);
            audit.n_time = n;
        end

        if ~audit.has_irradiance_vector && n >= 5 && (contains(p,"irr") || contains(p,"solar") || contains(p,"radiacion") || contains(p,"radiation") || contains(p,"g_t"))
            audit.has_irradiance_vector = true;
            audit.irradiance_candidate_path = string(candidates(i).path);
            audit.n_irradiance = n;
        end

        if ~audit.has_moisture_or_MR_vector && n >= 5 && (contains(p,"mr") || contains(p,"humedad") || contains(p,"moisture") || contains(p,"xr") || contains(p,"xw") || endsWith(p,".m"))
            audit.has_moisture_or_MR_vector = true;
            audit.moisture_candidate_path = string(candidates(i).path);
            audit.n_moisture = n;
        end

        if ~audit.has_energy_vector && n >= 5 && (contains(p,"q") || contains(p,"energy") || contains(p,"energia") || contains(p,"e_"))
            audit.has_energy_vector = true;
            audit.energy_candidate_path = string(candidates(i).path);
            audit.n_energy = n;
        end
    end

    audit.n_numeric_vector_candidates = numel(candidates);
end

function candidates = local_collect_numeric_vectors_v96nc(S, prefix)
    candidates = struct('path',{},'n',{});

    if ~isstruct(S)
        return
    end

    fns = fieldnames(S);

    for i = 1:numel(fns)
        fn = fns{i};
        val = S.(fn);
        path = string(prefix) + "." + string(fn);

        if isnumeric(val) && isvector(val) && numel(val) >= 2
            c = struct();
            c.path = path;
            c.n = numel(val);
            candidates(end+1) = c; %#ok<AGROW>
        elseif isstruct(val)
            sub = local_collect_numeric_vectors_v96nc(val, path);
            if ~isempty(sub)
                candidates = [candidates, sub]; %#ok<AGROW>
            end
        end
    end
end

function row = local_daylight_summary_placeholder_v96nc(mode, status, MR_target)
    row = struct();
    row.mode = string(mode);
    row.summary_status = string(status);
    row.MR_target = MR_target;
    row.MR_end_daylight = NaN;
    row.M_end_daylight = NaN;
    row.water_removed_daylight = NaN;
    row.solar_energy_or_irradiation = NaN;
    row.LPG_aux_energy = 0;
    row.CO2_LPG = 0;
    row.CO2_electricity = NaN;
    row.CO2_total = NaN;
    row.reaches_MR_target_in_one_day = false;
    row.valid_for_formal_GA = false;
end

function row = local_option_row_v96nc(id, name, recommended, reason, implication)
    row = struct();
    row.option_id = string(id);
    row.name = string(name);
    row.recommended = logical(recommended);
    row.reason = string(reason);
    row.implication = string(implication);
end

function row = local_req_row_v96nc(id, requirement, required)
    row = struct();
    row.id = string(id);
    row.requirement = string(requirement);
    row.required = logical(required);
end

function row = local_source_row_v96nc(item, filePath, pattern, passVal, evidence)
    row = struct();
    row.item = string(item);
    row.file = string(filePath);
    row.pattern = string(pattern);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end

function row = local_source_contains_v96nc(item, filePath, pattern, evidenceIfFound)
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

    row = local_source_row_v96nc(item, filePath, pattern, passVal, evidence);
end

function row = local_check_row_v96nc(id, checkName, passVal, evidence, criterion)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
    row.criterion = string(criterion);
end

function val = local_vec_get_v96nc(v, idx, defaultVal)
    if numel(v) >= idx
        val = v(idx);
    else
        val = defaultVal;
    end
end

function val = local_get_numeric_v96nc(S, paths, defaultVal)
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

function val = local_get_string_v96nc(S, paths, defaultVal)
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