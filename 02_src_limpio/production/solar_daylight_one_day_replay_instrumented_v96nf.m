function replay = solar_daylight_one_day_replay_instrumented_v96nf(x)
% SOLAR_DAYLIGHT_ONE_DAY_REPLAY_INSTRUMENTED_v96nf
% 9.6n-f — CREATE-SOLAR-DAYLIGHT-INSTRUMENTED-REPLAY-001
%
% Objetivo:
%   Ejecutar un replay solar directo, sin GA, usando la firma completa del
%   wrapper validado:
%
%   opt_tunel_mod2_v18_endpoint_TMAX_corrected( ...
%       m_max,T_min,r_div2,t_rec_ini, ...
%       W0,m_i,Mi,mwi,md,m_f,Mf,mwf,M_des,mode_operation)
%
% Este archivo:
%   - NO modifica v10/v17/v18/v95j/v96j_fix1.
%   - NO ejecuta gamultiobj.
%   - NO reintroduce solar al GA formal.
%   - Intenta extraer trayectoria desde irr_diag.
%   - Si no hay trayectoria, reporta escalar de endpoint sin inventar datos.
%
% Uso:
%   replay = solar_daylight_one_day_replay_instrumented_v96nf();

    if nargin < 1 || isempty(x)
        x = [ ...
            0.0740767982118, ...
            62.6832965028, ...
            0.672252618341, ...
            11.6517528081];
    end

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Configuración
    % ---------------------------------------------------------------------
    mode_operation = 'solar';
    MR_target = 0.10;

    irradiance_threshold = 20;        % umbral operativo genérico
    daylight_window_h_nominal = [8 18];

    EF_LPG_kgCO2_per_kWh = 0.2270;
    EF_grid_kgCO2_per_kWh = 0.4380;
    emission_factor_status = "PROVISIONAL_FOR_CODE_VALIDATION";

    m_max = x(1);
    T_min = x(2);
    r_div2 = x(3);
    t_rec_ini = x(4);

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    baseDir = fullfile(rootDir,'05_runs','solar_daylight_instrumented_replay_v96nf');
    runDir = fullfile(baseDir,['SOLAR_DAYLIGHT_INSTRUMENTED_REPLAY_v96nf_' timestamp]);

    logsDir = fullfile(runDir,'logs');
    tablesDir = fullfile(runDir,'tables');
    matDir = fullfile(runDir,'mat');

    if ~isfolder(baseDir), mkdir(baseDir); end
    if ~isfolder(runDir), mkdir(runDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Archivos protegidos
    % ---------------------------------------------------------------------
    objective_v95j = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v95j_endpoint_TMAX_corrected.m');
    objective_v96j_fix1 = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v96j_triobjective_CO2_fix1.m');
    wrapper_v18 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v18_endpoint_TMAX_corrected.m');
    wrapper_v17 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v17_nonphysical_penalty.m');
    wrapper_v10 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v10_energy_mode_corrected.m');

    if exist('opt_tunel_mod2_v18_endpoint_TMAX_corrected','file') ~= 2
        error('No está visible opt_tunel_mod2_v18_endpoint_TMAX_corrected.');
    end

    % ---------------------------------------------------------------------
    % Parámetros de producto: clonar la lógica usada por objective_v95j
    % ---------------------------------------------------------------------
    product = local_get_product_params_v96nf(rootDir, x);

    W0 = product.W0;
    m_i = product.m_i;
    Mi = product.Mi;
    mwi = product.mwi;
    md = product.md;
    m_f = product.m_f;
    Mf = product.Mf;
    mwf = product.mwf;
    M_des = product.M_des;

    % ---------------------------------------------------------------------
    % Llamada directa al wrapper v18 con firma completa
    % ---------------------------------------------------------------------
    call_status = "OK";
    call_error = "";

    Q_aux_tot = NaN;
    dry_time = NaN;
    M_prod_fin = NaN;
    MR_fin = NaN;
    Irradiacion = NaN;
    irr_diag = struct();

    tStart = tic;

    try
        [Q_aux_tot, dry_time, M_prod_fin, MR_fin, Irradiacion, irr_diag] = ...
            opt_tunel_mod2_v18_endpoint_TMAX_corrected( ...
                m_max, T_min, r_div2, t_rec_ini, ...
                W0, m_i, Mi, mwi, md, m_f, Mf, mwf, M_des, mode_operation);
    catch ME
        call_status = "ERROR";
        call_error = string(ME.message);
        irr_diag = struct();
    end

    runtime_s = toc(tStart);

    % ---------------------------------------------------------------------
    % Auditoría de irr_diag
    % ---------------------------------------------------------------------
    audit = local_audit_detail_vectors_v96nf(irr_diag);
    Taudit = struct2table(audit);

    trajectory_available = ...
        audit.has_time_vector && ...
        audit.has_irradiance_vector && ...
        audit.has_moisture_or_MR_vector;

    % ---------------------------------------------------------------------
    % Resumen diurno si hay trayectoria
    % ---------------------------------------------------------------------
    day = local_try_daylight_summary_v96nf( ...
        irr_diag, ...
        product, ...
        MR_target, ...
        irradiance_threshold, ...
        daylight_window_h_nominal, ...
        EF_grid_kgCO2_per_kWh);

    % ---------------------------------------------------------------------
    % Resumen escalar del endpoint del wrapper
    % ---------------------------------------------------------------------
    endpoint = struct();

    endpoint.mode = string(mode_operation);
    endpoint.call_status = string(call_status);
    endpoint.call_error = string(call_error);
    endpoint.runtime_s = runtime_s;

    endpoint.m_max = m_max;
    endpoint.T_min = T_min;
    endpoint.r_div2 = r_div2;
    endpoint.t_rec_ini = t_rec_ini;

    endpoint.W0 = W0;
    endpoint.m_i = m_i;
    endpoint.Mi = Mi;
    endpoint.mwi = mwi;
    endpoint.md = md;
    endpoint.m_f = m_f;
    endpoint.Mf = Mf;
    endpoint.mwf = mwf;
    endpoint.M_des = M_des;

    endpoint.Q_aux_tot = Q_aux_tot;
    endpoint.dry_time = dry_time;
    endpoint.M_prod_fin = M_prod_fin;
    endpoint.MR_fin = MR_fin;
    endpoint.Irradiacion = Irradiacion;

    endpoint.trajectory_available = trajectory_available;
    endpoint.has_time_vector = audit.has_time_vector;
    endpoint.has_irradiance_vector = audit.has_irradiance_vector;
    endpoint.has_moisture_or_MR_vector = audit.has_moisture_or_MR_vector;
    endpoint.has_energy_vector = audit.has_energy_vector;

    endpoint.CO2_LPG_kg = 0;
    endpoint.CO2_electricity_kg = NaN;
    endpoint.CO2_total_kg = NaN;
    endpoint.emission_factor_status = emission_factor_status;

    if isfinite(M_prod_fin)
        endpoint.water_removed_endpoint_kg = mwi - M_prod_fin*md;
    else
        endpoint.water_removed_endpoint_kg = NaN;
    end

    if isfinite(MR_fin)
        endpoint.reaches_MR_target_endpoint = MR_fin <= MR_target;
    else
        endpoint.reaches_MR_target_endpoint = false;
    end

    Tendpoint = struct2table(endpoint);

    % ---------------------------------------------------------------------
    % Tabla daylight
    % ---------------------------------------------------------------------
    if day.summary_possible
        daylight_status = "TRAJECTORY_DAYLIGHT_SUMMARY_AVAILABLE";
    elseif strcmp(call_status,"OK")
        daylight_status = "SCALAR_ENDPOINT_ONLY_NO_DAYLIGHT_TRAJECTORY";
    else
        daylight_status = "WRAPPER_CALL_ERROR_NO_DAYLIGHT_SUMMARY";
    end

    daylight = struct();

    daylight.mode = string(mode_operation);
    daylight.daylight_status = daylight_status;
    daylight.MR_target = MR_target;
    daylight.irradiance_threshold = irradiance_threshold;
    daylight.daylight_start_h_nominal = daylight_window_h_nominal(1);
    daylight.daylight_end_h_nominal = daylight_window_h_nominal(2);

    daylight.MR_end_daylight = day.MR_end_daylight;
    daylight.M_end_daylight = day.M_end_daylight;
    daylight.water_removed_daylight_kg = day.water_removed_daylight_kg;
    daylight.solar_energy_or_irradiation_daylight = day.solar_energy_or_irradiation_daylight;
    daylight.CO2_LPG_kg = 0;
    daylight.CO2_electricity_kg = day.CO2_electricity_kg;
    daylight.CO2_total_kg = day.CO2_total_kg;
    daylight.reaches_MR_target_in_one_day = day.reaches_MR_target_in_one_day;

    daylight.MR_endpoint_model = MR_fin;
    daylight.M_endpoint_model = M_prod_fin;
    daylight.water_removed_endpoint_kg = endpoint.water_removed_endpoint_kg;
    daylight.Irradiacion_endpoint_model = Irradiacion;
    daylight.Q_aux_tot_endpoint_model = Q_aux_tot;
    daylight.dry_time_endpoint_model = dry_time;
    daylight.reaches_MR_target_endpoint_model = endpoint.reaches_MR_target_endpoint;

    daylight.valid_daylight_quantification = day.summary_possible;
    daylight.valid_for_formal_GA = false;
    daylight.solar_kept_out_of_formal_GA = true;

    Tdaylight = struct2table(daylight);

    % ---------------------------------------------------------------------
    % Source scan
    % ---------------------------------------------------------------------
    sourceRows = {};

    sourceRows{end+1,1} = local_source_row_v96nf("objective_v95j_exists", objective_v95j, isfile(objective_v95j), "v95j available.");
    sourceRows{end+1,1} = local_source_row_v96nf("objective_v96j_fix1_exists", objective_v96j_fix1, isfile(objective_v96j_fix1), "v96j_fix1 available.");
    sourceRows{end+1,1} = local_source_row_v96nf("wrapper_v18_exists", wrapper_v18, isfile(wrapper_v18), "v18 available.");
    sourceRows{end+1,1} = local_source_row_v96nf("wrapper_v17_exists", wrapper_v17, isfile(wrapper_v17), "v17 available.");
    sourceRows{end+1,1} = local_source_row_v96nf("wrapper_v10_exists", wrapper_v10, isfile(wrapper_v10), "v10 available.");

    Tsource = struct2table(vertcat(sourceRows{:}));
    source_preservation_pass = all(Tsource.pass);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};

    checks{end+1,1} = local_check_row_v96nf( ...
        "F01", ...
        "No GA executed", ...
        true, ...
        "This function does not call gamultiobj.", ...
        "Solar replay must not optimize.");

    checks{end+1,1} = local_check_row_v96nf( ...
        "F02", ...
        "Source preservation", ...
        source_preservation_pass, ...
        sprintf("available sources=%d of %d", sum(Tsource.pass), height(Tsource)), ...
        "Protected sources must remain available.");

    checks{end+1,1} = local_check_row_v96nf( ...
        "F03", ...
        "v18 called with full signature", ...
        strcmp(call_status,"OK"), ...
        sprintf("call_status=%s; error=%s", call_status, call_error), ...
        "Instrumented replay must call v18 without missing-argument error.");

    checks{end+1,1} = local_check_row_v96nf( ...
        "F04", ...
        "Endpoint scalar outputs returned", ...
        strcmp(call_status,"OK") && any(isfinite([Q_aux_tot,dry_time,M_prod_fin,MR_fin,Irradiacion])), ...
        sprintf("Q_aux=%.6g; dry_time=%.6g; M=%.6g; MR=%.6g; Irr=%.6g", ...
            Q_aux_tot, dry_time, M_prod_fin, MR_fin, Irradiacion), ...
        "Wrapper should return endpoint scalar outputs.");

    checks{end+1,1} = local_check_row_v96nf( ...
        "F05", ...
        "Trajectory audit completed", ...
        true, ...
        sprintf("time=%d; irr=%d; moisture=%d; energy=%d", ...
            audit.has_time_vector, audit.has_irradiance_vector, audit.has_moisture_or_MR_vector, audit.has_energy_vector), ...
        "Replay must audit whether irr_diag exposes trajectory.");

    checks{end+1,1} = local_check_row_v96nf( ...
        "F06", ...
        "Solar kept out of formal GA", ...
        true, ...
        "valid_for_formal_GA=false", ...
        "Solar daylight replay is diagnostic only.");

    Tchecks = struct2table(vertcat(checks{:}));

    % ---------------------------------------------------------------------
    % Diagnóstico
    % ---------------------------------------------------------------------
    if strcmp(call_status,"OK") && day.summary_possible
        diagnosis = "SOLAR_DAYLIGHT_INSTRUMENTED_REPLAY_PASS_DAYLIGHT_SUMMARY";
        decision = "INTERPRET_SOLAR_DAYLIGHT_RESULTS_THEN_RUN_HYBRID_FORMAL";
        next_step = "9.6n-g — SOLAR-DAYLIGHT-RESULTS-INTERPRETATION-001";
        approved_to_run_formal_now = false;
    elseif strcmp(call_status,"OK")
        diagnosis = "SOLAR_DAYLIGHT_INSTRUMENTED_REPLAY_PASS_ENDPOINT_ONLY";
        decision = "DOCUMENT_SOLAR_ENDPOINT_ONLY_OR_INSTRUMENT_INTERNAL_TRAJECTORY";
        next_step = "9.6n-g — SOLAR-ENDPOINT-ONLY-INTERPRETATION-GATE-001";
        approved_to_run_formal_now = false;
    else
        diagnosis = "SOLAR_DAYLIGHT_INSTRUMENTED_REPLAY_REQUIRES_REVIEW";
        decision = "REVIEW_V18_CALL_OR_PRODUCT_PARAMETERS";
        next_step = "Review wrapper call.";
        approved_to_run_formal_now = false;
    end

    replayFlags = struct();
    replayFlags.no_GA_executed = true;
    replayFlags.no_sources_modified = true;
    replayFlags.source_preservation_pass = source_preservation_pass;
    replayFlags.v18_full_signature_call_status = call_status;
    replayFlags.v18_full_signature_call_ok = strcmp(call_status,"OK");
    replayFlags.trajectory_available = trajectory_available;
    replayFlags.daylight_summary_possible = day.summary_possible;
    replayFlags.endpoint_scalar_available = strcmp(call_status,"OK") && any(isfinite([Q_aux_tot,dry_time,M_prod_fin,MR_fin,Irradiacion]));
    replayFlags.solar_kept_out_of_formal_GA = true;
    replayFlags.approved_to_run_formal_now = approved_to_run_formal_now;
    replayFlags.CO2_factors_still_provisional = true;

    % ---------------------------------------------------------------------
    % Archivos de salida
    % ---------------------------------------------------------------------
    outEndpointCsv = fullfile(tablesDir,'SOLAR_DAYLIGHT_INSTRUMENTED_REPLAY_v96nf_endpoint.csv');
    outAuditCsv = fullfile(tablesDir,'SOLAR_DAYLIGHT_INSTRUMENTED_REPLAY_v96nf_trajectory_audit.csv');
    outDaylightCsv = fullfile(tablesDir,'SOLAR_DAYLIGHT_INSTRUMENTED_REPLAY_v96nf_daylight_summary.csv');
    outSourceCsv = fullfile(tablesDir,'SOLAR_DAYLIGHT_INSTRUMENTED_REPLAY_v96nf_source_scan.csv');
    outChecksCsv = fullfile(tablesDir,'SOLAR_DAYLIGHT_INSTRUMENTED_REPLAY_v96nf_checks.csv');

    writetable(Tendpoint,outEndpointCsv);
    writetable(Taudit,outAuditCsv);
    writetable(Tdaylight,outDaylightCsv);
    writetable(Tsource,outSourceCsv);
    writetable(Tchecks,outChecksCsv);

    outMd = fullfile(logsDir,'SOLAR_DAYLIGHT_INSTRUMENTED_REPLAY_v96nf.md');
    outTxt = fullfile(logsDir,'SOLAR_DAYLIGHT_INSTRUMENTED_REPLAY_v96nf.txt');
    outMat = fullfile(matDir,'SOLAR_DAYLIGHT_INSTRUMENTED_REPLAY_v96nf.mat');

    save(outMat, ...
        'diagnosis','decision','next_step','replayFlags', ...
        'x','product','mode_operation','MR_target','irradiance_threshold','daylight_window_h_nominal', ...
        'Q_aux_tot','dry_time','M_prod_fin','MR_fin','Irradiacion','irr_diag','audit','day', ...
        'Tendpoint','Taudit','Tdaylight','Tsource','Tchecks', ...
        'runDir','outMd','outTxt','outMat','outEndpointCsv','outAuditCsv','outDaylightCsv','outSourceCsv','outChecksCsv');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# SOLAR_DAYLIGHT_INSTRUMENTED_REPLAY_v96nf\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Decisión: `%s`\n\n', decision);
    fprintf(fid,'Siguiente paso: `%s`\n\n', next_step);

    fprintf(fid,'## Llamada al wrapper\n\n');
    fprintf(fid,'```matlab\n');
    fprintf(fid,'[Q_aux_tot, dry_time, M_prod_fin, MR_fin, Irradiacion, irr_diag] = ...\n');
    fprintf(fid,'    opt_tunel_mod2_v18_endpoint_TMAX_corrected(m_max,T_min,r_div2,t_rec_ini,W0,m_i,Mi,mwi,md,m_f,Mf,mwf,M_des,mode_operation);\n');
    fprintf(fid,'```\n\n');

    fprintf(fid,'## Endpoint escalar del modelo\n\n');
    fprintf(fid,'| Campo | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| Q_aux_tot | %.12g |\n', Q_aux_tot);
    fprintf(fid,'| dry_time | %.12g |\n', dry_time);
    fprintf(fid,'| M_prod_fin | %.12g |\n', M_prod_fin);
    fprintf(fid,'| MR_fin | %.12g |\n', MR_fin);
    fprintf(fid,'| Irradiacion | %.12g |\n', Irradiacion);
    fprintf(fid,'| water_removed_endpoint_kg | %.12g |\n', endpoint.water_removed_endpoint_kg);
    fprintf(fid,'| reaches_MR_target_endpoint | %d |\n\n', endpoint.reaches_MR_target_endpoint);

    fprintf(fid,'## Auditoría de trayectoria en irr_diag\n\n');
    fprintf(fid,'| Campo | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| has_time_vector | %d |\n', audit.has_time_vector);
    fprintf(fid,'| has_irradiance_vector | %d |\n', audit.has_irradiance_vector);
    fprintf(fid,'| has_moisture_or_MR_vector | %d |\n', audit.has_moisture_or_MR_vector);
    fprintf(fid,'| has_energy_vector | %d |\n', audit.has_energy_vector);
    fprintf(fid,'| n_numeric_vector_candidates | %d |\n\n', audit.n_numeric_vector_candidates);

    fprintf(fid,'## Resumen diurno\n\n');
    fprintf(fid,'| Campo | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| valid_daylight_quantification | %d |\n', daylight.valid_daylight_quantification);
    fprintf(fid,'| MR_end_daylight | %.12g |\n', daylight.MR_end_daylight);
    fprintf(fid,'| M_end_daylight | %.12g |\n', daylight.M_end_daylight);
    fprintf(fid,'| water_removed_daylight_kg | %.12g |\n', daylight.water_removed_daylight_kg);
    fprintf(fid,'| solar_energy_or_irradiation_daylight | %.12g |\n', daylight.solar_energy_or_irradiation_daylight);
    fprintf(fid,'| CO2_LPG_kg | %.12g |\n', daylight.CO2_LPG_kg);
    fprintf(fid,'| CO2_electricity_kg | %.12g |\n', daylight.CO2_electricity_kg);
    fprintf(fid,'| CO2_total_kg | %.12g |\n', daylight.CO2_total_kg);
    fprintf(fid,'| reaches_MR_target_in_one_day | %d |\n\n', daylight.reaches_MR_target_in_one_day);

    fprintf(fid,'## Checks\n\n');
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

    if strcmp(diagnosis,"SOLAR_DAYLIGHT_INSTRUMENTED_REPLAY_PASS_DAYLIGHT_SUMMARY")
        fprintf(fid,'Se obtuvo trayectoria suficiente para cuantificar desempeño solar diurno. Solar sigue fuera del GA formal; los resultados se interpretan como caso de jornada solar.\n');
    elseif strcmp(diagnosis,"SOLAR_DAYLIGHT_INSTRUMENTED_REPLAY_PASS_ENDPOINT_ONLY")
        fprintf(fid,'La llamada correcta a v18 funciona y entrega endpoint escalar, pero irr_diag no expone trayectoria suficiente para cuantificación diurna. Se debe decidir entre instrumentar internamente el wrapper o documentar solar como endpoint-only/no comparable.\n');
    else
        fprintf(fid,'La llamada instrumentada requiere revisión.\n');
    end

    fclose(fid);

    % TXT
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'CREATE-SOLAR-DAYLIGHT-INSTRUMENTED-REPLAY-001\n');
    fprintf(fid,'status: SOLAR_DAYLIGHT_INSTRUMENTED_REPLAY_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'decision: %s\n', decision);
    fprintf(fid,'next_step: %s\n', next_step);
    fprintf(fid,'no_GA_executed: %d\n', replayFlags.no_GA_executed);
    fprintf(fid,'no_sources_modified: %d\n', replayFlags.no_sources_modified);
    fprintf(fid,'source_preservation_pass: %d\n', replayFlags.source_preservation_pass);
    fprintf(fid,'v18_full_signature_call_status: %s\n', replayFlags.v18_full_signature_call_status);
    fprintf(fid,'v18_full_signature_call_ok: %d\n', replayFlags.v18_full_signature_call_ok);
    fprintf(fid,'trajectory_available: %d\n', replayFlags.trajectory_available);
    fprintf(fid,'daylight_summary_possible: %d\n', replayFlags.daylight_summary_possible);
    fprintf(fid,'endpoint_scalar_available: %d\n', replayFlags.endpoint_scalar_available);
    fprintf(fid,'solar_kept_out_of_formal_GA: %d\n', replayFlags.solar_kept_out_of_formal_GA);
    fprintf(fid,'approved_to_run_formal_now: %d\n', replayFlags.approved_to_run_formal_now);
    fprintf(fid,'CO2_factors_still_provisional: %d\n', replayFlags.CO2_factors_still_provisional);
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Consola
    % ---------------------------------------------------------------------
    replay = struct();
    replay.status = 'SOLAR_DAYLIGHT_INSTRUMENTED_REPLAY_COMPLETED';
    replay.diagnosis = diagnosis;
    replay.decision = decision;
    replay.next_step = next_step;
    replay.replayFlags = replayFlags;
    replay.Tendpoint = Tendpoint;
    replay.Taudit = Taudit;
    replay.Tdaylight = Tdaylight;
    replay.Tsource = Tsource;
    replay.Tchecks = Tchecks;
    replay.runDir = runDir;
    replay.outMd = outMd;
    replay.outTxt = outTxt;
    replay.outMat = outMat;

    disp('=== SOLAR_DAYLIGHT_INSTRUMENTED_REPLAY_v96nf ===')
    disp(replay.status)
    disp('=== DIAGNOSIS ===')
    disp(replay.diagnosis)
    disp('=== DECISION ===')
    disp(replay.decision)
    disp('=== NEXT STEP ===')
    disp(replay.next_step)
    disp('=== REPLAY FLAGS ===')
    disp(replay.replayFlags)
    disp('=== ENDPOINT ===')
    disp(replay.Tendpoint)
    disp('=== TRAJECTORY AUDIT ===')
    disp(replay.Taudit)
    disp('=== DAYLIGHT SUMMARY ===')
    disp(replay.Tdaylight)
    disp('=== CHECKS ===')
    disp(replay.Tchecks)
    disp('=== OUTPUT FILES ===')
    disp(replay.outMd)
    disp(replay.outTxt)
    disp(replay.outMat)

end

% =========================================================================
% Product parameters
% =========================================================================

function product = local_get_product_params_v96nf(rootDir, x)
    product = struct();

    product.W0 = NaN;
    product.m_i = 0.87;
    product.m_f = 0.08;
    product.m_des = 0.10;

    objective_v95j = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v95j_endpoint_TMAX_corrected.m');

    % Primero intentar extraer W0 y parámetros desde el detail de v95j.
    try
        [~, d_hyb] = objective_productive_corrected_v95j_endpoint_TMAX_corrected(x,'hybrid');

        product.W0 = local_get_numeric_v96nf(d_hyb, ...
            {'product.W0','product.W_0','inputs.W0','W0'}, product.W0);

        product.m_i = local_get_numeric_v96nf(d_hyb, ...
            {'product.m_i','m_i'}, product.m_i);

        product.m_f = local_get_numeric_v96nf(d_hyb, ...
            {'product.m_f','m_f'}, product.m_f);

        product.m_des = local_get_numeric_v96nf(d_hyb, ...
            {'product.m_des','m_des'}, product.m_des);
    catch
    end

    % Si W0 no viene en detail, intentar leerlo del código fuente.
    if ~isfinite(product.W0) && isfile(objective_v95j)
        txt = fileread(objective_v95j);

        product.W0 = local_parse_assignment_numeric_v96nf(txt,'W0',product.W0);
        product.m_i = local_parse_assignment_numeric_v96nf(txt,'m_i',product.m_i);
        product.m_f = local_parse_assignment_numeric_v96nf(txt,'m_f',product.m_f);
        product.m_des = local_parse_assignment_numeric_v96nf(txt,'m_des',product.m_des);
    end

    if ~isfinite(product.W0)
        error('No se pudo determinar W0 desde objective_v95j ni desde detail híbrido.');
    end

    product.Mi = product.m_i/(1-product.m_i);
    product.mwi = product.W0*product.m_i;
    product.md = product.mwi/product.Mi;

    product.Mf = product.m_f/(1-product.m_f);
    product.M_des = product.m_des/(1-product.m_des);
    product.mwf = product.Mf*product.md;
end

function val = local_parse_assignment_numeric_v96nf(txt, varName, defaultVal)
    val = defaultVal;

    expr = [char(varName) '\s*=\s*([-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)\s*;'];
    tok = regexp(txt, expr, 'tokens', 'once');

    if ~isempty(tok)
        tmp = str2double(tok{1});
        if isfinite(tmp)
            val = tmp;
        end
    end
end

% =========================================================================
% Daylight summary
% =========================================================================

function day = local_try_daylight_summary_v96nf(irr_diag, product, MR_target, irradiance_threshold, nominal_window, EF_grid)
    day = struct();
    day.summary_possible = false;
    day.MR_end_daylight = NaN;
    day.M_end_daylight = NaN;
    day.water_removed_daylight_kg = NaN;
    day.solar_energy_or_irradiation_daylight = NaN;
    day.CO2_electricity_kg = NaN;
    day.CO2_total_kg = NaN;
    day.reaches_MR_target_in_one_day = false;

    audit = local_audit_detail_vectors_v96nf(irr_diag);

    if ~(audit.has_time_vector && audit.has_irradiance_vector && audit.has_moisture_or_MR_vector)
        return
    end

    try
        t = local_get_by_path_v96nf(irr_diag, audit.time_candidate_path);
        irr = local_get_by_path_v96nf(irr_diag, audit.irradiance_candidate_path);
        moist = local_get_by_path_v96nf(irr_diag, audit.moisture_candidate_path);

        t = double(t(:));
        irr = double(irr(:));
        moist = double(moist(:));

        n = min([numel(t), numel(irr), numel(moist)]);

        if n < 5
            return
        end

        t = t(1:n);
        irr = irr(1:n);
        moist = moist(1:n);

        [t, idx] = sort(t);
        irr = irr(idx);
        moist = moist(idx);

        th = local_time_to_hours_v96nf(t);

        daylight = irr > irradiance_threshold;

        if ~any(daylight)
            hday = mod(th,24);
            daylight = hday >= nominal_window(1) & hday <= nominal_window(2);
        end

        if ~any(daylight)
            return
        end

        idxDay = find(daylight);
        idxEnd = idxDay(end);

        metricEnd = moist(idxEnd);
        moisturePath = lower(string(audit.moisture_candidate_path));

        if contains(moisturePath,"mr")
            MR_end = metricEnd;
            M_end = MR_end * product.Mi;
        else
            M_end = metricEnd;
            if isfinite(product.Mi) && product.Mi ~= 0
                MR_end = M_end / product.Mi;
            else
                MR_end = NaN;
            end
        end

        if audit.has_energy_vector
            e = local_get_by_path_v96nf(irr_diag, audit.energy_candidate_path);
            e = double(e(:));
            ne = min(numel(e),n);
            e = e(1:ne);

            if numel(e) == n
                e = e(idx);
                solarEnergy = e(idxEnd);
            else
                solarEnergy = NaN;
            end
        else
            solarEnergy = trapz(th(daylight), irr(daylight));
        end

        if isfinite(M_end)
            waterRemoved = product.mwi - M_end*product.md;
        else
            waterRemoved = NaN;
        end

        E_electricity_kWh = NaN;
        CO2_electricity = E_electricity_kWh * EF_grid;

        day.summary_possible = true;
        day.MR_end_daylight = MR_end;
        day.M_end_daylight = M_end;
        day.water_removed_daylight_kg = waterRemoved;
        day.solar_energy_or_irradiation_daylight = solarEnergy;
        day.CO2_electricity_kg = CO2_electricity;
        day.CO2_total_kg = CO2_electricity;
        day.reaches_MR_target_in_one_day = isfinite(MR_end) && MR_end <= MR_target;

    catch
        day.summary_possible = false;
    end
end

function th = local_time_to_hours_v96nf(t)
    tmax = max(t);

    if tmax > 10000
        th = t / 3600;
    elseif tmax > 100
        th = t / 60;
    else
        th = t;
    end
end

% =========================================================================
% Vector audit
% =========================================================================

function audit = local_audit_detail_vectors_v96nf(S)
    audit = struct();

    audit.has_detail_struct = isstruct(S);
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
    audit.n_numeric_vector_candidates = 0;

    if ~isstruct(S)
        return
    end

    candidates = local_collect_numeric_vectors_v96nf(S, "detail");
    audit.n_numeric_vector_candidates = numel(candidates);

    for i = 1:numel(candidates)
        p = lower(string(candidates(i).path));
        n = candidates(i).n;

        if ~audit.has_time_vector && n >= 5 && ...
                (contains(p,"time") || contains(p,"tiempo") || contains(p,"hora") || endsWith(p,".t") || contains(p,"t_vec"))
            audit.has_time_vector = true;
            audit.time_candidate_path = string(candidates(i).path);
            audit.n_time = n;
        end

        if ~audit.has_irradiance_vector && n >= 5 && ...
                (contains(p,"irr") || contains(p,"solar") || contains(p,"radiacion") || contains(p,"radiation") || contains(p,"g_t"))
            audit.has_irradiance_vector = true;
            audit.irradiance_candidate_path = string(candidates(i).path);
            audit.n_irradiance = n;
        end

        if ~audit.has_moisture_or_MR_vector && n >= 5 && ...
                (contains(p,"mr") || contains(p,"humedad") || contains(p,"moisture") || contains(p,"xr") || contains(p,"xw") || endsWith(p,".m"))
            audit.has_moisture_or_MR_vector = true;
            audit.moisture_candidate_path = string(candidates(i).path);
            audit.n_moisture = n;
        end

        if ~audit.has_energy_vector && n >= 5 && ...
                (contains(p,"q") || contains(p,"energy") || contains(p,"energia") || contains(p,"e_"))
            audit.has_energy_vector = true;
            audit.energy_candidate_path = string(candidates(i).path);
            audit.n_energy = n;
        end
    end
end

function candidates = local_collect_numeric_vectors_v96nf(S, prefix)
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
            sub = local_collect_numeric_vectors_v96nf(val, path);
            if ~isempty(sub)
                candidates = [candidates, sub]; %#ok<AGROW>
            end
        end
    end
end

function val = local_get_by_path_v96nf(S, path)
    parts = split(string(path),'.');

    if parts(1) == "detail"
        parts = parts(2:end);
    end

    val = S;

    for i = 1:numel(parts)
        p = char(parts(i));
        val = val.(p);
    end
end

% =========================================================================
% Generic helpers
% =========================================================================

function row = local_source_row_v96nf(item, filePath, passVal, evidence)
    row = struct();
    row.item = string(item);
    row.file = string(filePath);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end

function row = local_check_row_v96nf(id, checkName, passVal, evidence, criterion)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
    row.criterion = string(criterion);
end

function val = local_get_numeric_v96nf(S, paths, defaultVal)
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