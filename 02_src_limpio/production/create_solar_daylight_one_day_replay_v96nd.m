function replay = create_solar_daylight_one_day_replay_v96nd()
% CREATE_SOLAR_DAYLIGHT_ONE_DAY_REPLAY_v96nd
% 9.6n-d — CREATE-SOLAR-DAYLIGHT-ONE-DAY-REPLAY-001
%
% Objetivo:
%   Crear un replay solar acotado a una jornada solar, sin GA.
%
% Pregunta:
%   ¿Qué alcanza el modo solar puro durante una ventana diurna?
%
% Este paso:
%   - NO ejecuta gamultiobj.
%   - NO ejecuta la formal v96m.
%   - NO modifica fuentes validadas.
%   - Intenta obtener trayectoria desde rutas existentes.
%   - Si hay trayectoria, resume desempeño diurno.
%   - Si no hay trayectoria, deja claro qué falta instrumentar.

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Cargar gate 9.6n-c
    % ---------------------------------------------------------------------
    gateBaseDir = fullfile(rootDir,'05_runs','solar_daylight_one_day_performance_gate_v96nc');

    if ~isfolder(gateBaseDir)
        error('No existe gateBaseDir: %s', gateBaseDir);
    end

    d = dir(gateBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'SOLAR_DAYLIGHT_ONE_DAY_PERFORMANCE_GATE_v96nc_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró gate v96nc.');
    end

    [~,idxGate] = max([d.datenum]);
    gateDirPrev = fullfile(gateBaseDir,d(idxGate).name);
    gateMat = fullfile(gateDirPrev,'mat','SOLAR_DAYLIGHT_ONE_DAY_PERFORMANCE_GATE_v96nc.mat');

    if ~isfile(gateMat)
        error('No existe MAT v96nc: %s', gateMat);
    end

    Sgate = load(gateMat);

    if ~strcmp(string(Sgate.diagnosis),"SOLAR_DAYLIGHT_ONE_DAY_GATE_PASS_REPLAY_REQUIRED")
        error('9.6n-c no está en estado REPLAY_REQUIRED. Diagnosis: %s', string(Sgate.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Carpetas
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    replayBaseDir = fullfile(rootDir,'05_runs','solar_daylight_one_day_replay_v96nd');
    replayDir = fullfile(replayBaseDir,['SOLAR_DAYLIGHT_ONE_DAY_REPLAY_v96nd_' timestamp]);

    logsDir = fullfile(replayDir,'logs');
    tablesDir = fullfile(replayDir,'tables');
    matDir = fullfile(replayDir,'mat');

    if ~isfolder(replayBaseDir), mkdir(replayBaseDir); end
    if ~isfolder(replayDir), mkdir(replayDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Configuración
    % ---------------------------------------------------------------------
    x_selected = [ ...
        0.0740767982118, ...
        62.6832965028, ...
        0.672252618341, ...
        11.6517528081];

    MR_target = 0.10;
    irradiance_threshold = 20;   % umbral genérico para detectar día solar
    daylight_window_h_nominal = [8, 18];

    objective_v96j_fix1 = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v96j_triobjective_CO2_fix1.m');
    objective_v95j = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v95j_endpoint_TMAX_corrected.m');
    wrapper_v18 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v18_endpoint_TMAX_corrected.m');
    wrapper_v17 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v17_nonphysical_penalty.m');
    wrapper_v10 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v10_energy_mode_corrected.m');
    objective_v628b = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v628b_nonphysical_penalty.m');

    % ---------------------------------------------------------------------
    % Intentos de replay / extracción de trayectoria
    % ---------------------------------------------------------------------
    attemptRows = {};
    candidateDetails = {};

    attemptList = local_build_attempts_v96nd(x_selected);

    for k = 1:numel(attemptList)
        a = attemptList{k};
        [status, errMsg, f, detail] = local_try_attempt_v96nd(a);

        audit = local_audit_detail_vectors_v96nd(detail);
        summary = local_try_daylight_summary_v96nd(detail, MR_target, irradiance_threshold, daylight_window_h_nominal);

        row = struct();
        row.attempt_id = string(a.id);
        row.call_description = string(a.description);
        row.status = string(status);
        row.error_message = string(errMsg);
        row.nobj = numel(f);
        row.f1 = local_vec_get_v96nd(f,1,NaN);
        row.f2 = local_vec_get_v96nd(f,2,NaN);
        row.f3 = local_vec_get_v96nd(f,3,NaN);
        row.detail_status = local_get_string_v96nd(detail, {'status','detail_status','execution_status'}, "UNKNOWN");
        row.has_detail = isstruct(detail);
        row.has_time_vector = audit.has_time_vector;
        row.has_irradiance_vector = audit.has_irradiance_vector;
        row.has_moisture_or_MR_vector = audit.has_moisture_or_MR_vector;
        row.has_energy_vector = audit.has_energy_vector;
        row.n_numeric_vector_candidates = audit.n_numeric_vector_candidates;
        row.daylight_summary_possible = summary.summary_possible;
        row.MR_end_daylight = summary.MR_end_daylight;
        row.M_end_daylight = summary.M_end_daylight;
        row.water_removed_daylight = summary.water_removed_daylight;
        row.solar_energy_or_irradiation_daylight = summary.solar_energy_or_irradiation_daylight;
        row.CO2_LPG = summary.CO2_LPG;
        row.CO2_electricity = summary.CO2_electricity;
        row.CO2_total = summary.CO2_total;
        row.reaches_MR_target_in_one_day = summary.reaches_MR_target_in_one_day;
        row.time_path = string(audit.time_candidate_path);
        row.irradiance_path = string(audit.irradiance_candidate_path);
        row.moisture_path = string(audit.moisture_candidate_path);
        row.energy_path = string(audit.energy_candidate_path);

        attemptRows{end+1,1} = row; %#ok<AGROW>

        candidateDetails{end+1,1} = struct( ...
            'attempt', a, ...
            'status', status, ...
            'error_message', errMsg, ...
            'f', f, ...
            'detail', detail, ...
            'audit', audit, ...
            'summary', summary); %#ok<AGROW>
    end

    Tattempts = struct2table(vertcat(attemptRows{:}));

    usableRows = Tattempts(Tattempts.daylight_summary_possible == true,:);
    has_usable_daylight_replay = ~isempty(usableRows);

    if has_usable_daylight_replay
        [~,idxBest] = min(usableRows.MR_end_daylight);
        best = usableRows(idxBest,:);

        Tdaylight = best(:,{ ...
            'attempt_id', ...
            'call_description', ...
            'MR_end_daylight', ...
            'M_end_daylight', ...
            'water_removed_daylight', ...
            'solar_energy_or_irradiation_daylight', ...
            'CO2_LPG', ...
            'CO2_electricity', ...
            'CO2_total', ...
            'reaches_MR_target_in_one_day', ...
            'time_path', ...
            'irradiance_path', ...
            'moisture_path', ...
            'energy_path'});
    else
        Tdaylight = table();
        Tdaylight.attempt_id = "NONE";
        Tdaylight.call_description = "NO_USABLE_SOLAR_DAYLIGHT_REPLAY_AVAILABLE";
        Tdaylight.MR_end_daylight = NaN;
        Tdaylight.M_end_daylight = NaN;
        Tdaylight.water_removed_daylight = NaN;
        Tdaylight.solar_energy_or_irradiation_daylight = NaN;
        Tdaylight.CO2_LPG = 0;
        Tdaylight.CO2_electricity = NaN;
        Tdaylight.CO2_total = NaN;
        Tdaylight.reaches_MR_target_in_one_day = false;
        Tdaylight.time_path = "";
        Tdaylight.irradiance_path = "";
        Tdaylight.moisture_path = "";
        Tdaylight.energy_path = "";
    end

    % ---------------------------------------------------------------------
    % Source scan
    % ---------------------------------------------------------------------
    sourceRows = {};

    sourceRows{end+1,1} = local_source_row_v96nd("objective_v96j_fix1_exists", objective_v96j_fix1, "", isfile(objective_v96j_fix1), "Triobjective objective exists.");
    sourceRows{end+1,1} = local_source_row_v96nd("objective_v95j_exists", objective_v95j, "", isfile(objective_v95j), "v95j objective exists.");
    sourceRows{end+1,1} = local_source_row_v96nd("wrapper_v18_exists", wrapper_v18, "", isfile(wrapper_v18), "v18 wrapper exists.");
    sourceRows{end+1,1} = local_source_row_v96nd("wrapper_v17_exists", wrapper_v17, "", isfile(wrapper_v17), "v17 wrapper exists.");
    sourceRows{end+1,1} = local_source_row_v96nd("wrapper_v10_exists", wrapper_v10, "", isfile(wrapper_v10), "v10 wrapper exists.");
    sourceRows{end+1,1} = local_source_row_v96nd("objective_v628b_exists", objective_v628b, "", isfile(objective_v628b), "v628b objective exists.");

    Tsource = struct2table(vertcat(sourceRows{:}));

    source_preservation_pass = all(Tsource.pass);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};

    checks{end+1,1} = local_check_row_v96nd( ...
        "D01", ...
        "Prior daylight gate requires replay", ...
        strcmp(string(Sgate.diagnosis),"SOLAR_DAYLIGHT_ONE_DAY_GATE_PASS_REPLAY_REQUIRED"), ...
        string(Sgate.diagnosis), ...
        "v96nc must require replay.");

    checks{end+1,1} = local_check_row_v96nd( ...
        "D02", ...
        "No GA executed", ...
        true, ...
        "This script does not call gamultiobj.", ...
        "Replay must be direct, not optimization.");

    checks{end+1,1} = local_check_row_v96nd( ...
        "D03", ...
        "Source preservation", ...
        source_preservation_pass, ...
        "Protected sources checked as available.", ...
        "No protected source may be missing.");

    checks{end+1,1} = local_check_row_v96nd( ...
        "D04", ...
        "At least one replay attempt executed", ...
        height(Tattempts) >= 1, ...
        sprintf("attempts=%d", height(Tattempts)), ...
        "Replay must test available routes.");

    checks{end+1,1} = local_check_row_v96nd( ...
        "D05", ...
        "Daylight summary available", ...
        has_usable_daylight_replay, ...
        sprintf("usable_daylight_replay=%d", has_usable_daylight_replay), ...
        "If false, source instrumentation is needed.");

    Tchecks = struct2table(vertcat(checks{:}));

    % ---------------------------------------------------------------------
    % Dictamen
    % ---------------------------------------------------------------------
    if has_usable_daylight_replay
        diagnosis = "SOLAR_DAYLIGHT_ONE_DAY_REPLAY_PASS_SUMMARY_AVAILABLE";
        decision = "USE_SOLAR_DAYLIGHT_SUMMARY_AND_KEEP_SOLAR_OUT_OF_FORMAL_GA";
        next_step = "9.6n-e — SOLAR-DAYLIGHT-RESULTS-INTERPRETATION-001";
        approved_to_run_formal_after_interpretation = true;
    else
        diagnosis = "SOLAR_DAYLIGHT_ONE_DAY_REPLAY_REQUIRES_SOURCE_INSTRUMENTATION";
        decision = "INSTRUMENT_SOLAR_REPLAY_ROUTE_OR_DOCUMENT_SOLAR_AS_UNQUANTIFIED_LIMITATION";
        next_step = "9.6n-e — SOLAR-REPLAY-SOURCE-INSTRUMENTATION-DESIGN-001";
        approved_to_run_formal_after_interpretation = false;
    end

    replayFlags = struct();
    replayFlags.prior_gate_v96nc_pass = strcmp(string(Sgate.diagnosis),"SOLAR_DAYLIGHT_ONE_DAY_GATE_PASS_REPLAY_REQUIRED");
    replayFlags.no_GA_executed = true;
    replayFlags.no_sources_modified = true;
    replayFlags.source_preservation_pass = source_preservation_pass;
    replayFlags.n_attempts = height(Tattempts);
    replayFlags.has_usable_daylight_replay = has_usable_daylight_replay;
    replayFlags.approved_to_run_formal_after_interpretation = approved_to_run_formal_after_interpretation;
    replayFlags.solar_kept_out_of_formal_GA = true;
    replayFlags.CO2_factors_still_provisional = true;

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outAttemptsCsv = fullfile(tablesDir,'SOLAR_DAYLIGHT_ONE_DAY_REPLAY_v96nd_attempts.csv');
    outDaylightCsv = fullfile(tablesDir,'SOLAR_DAYLIGHT_ONE_DAY_REPLAY_v96nd_daylight_summary.csv');
    outSourceCsv = fullfile(tablesDir,'SOLAR_DAYLIGHT_ONE_DAY_REPLAY_v96nd_source_scan.csv');
    outChecksCsv = fullfile(tablesDir,'SOLAR_DAYLIGHT_ONE_DAY_REPLAY_v96nd_checks.csv');

    writetable(Tattempts,outAttemptsCsv);
    writetable(Tdaylight,outDaylightCsv);
    writetable(Tsource,outSourceCsv);
    writetable(Tchecks,outChecksCsv);

    outMd = fullfile(logsDir,'SOLAR_DAYLIGHT_ONE_DAY_REPLAY_v96nd.md');
    outTxt = fullfile(logsDir,'SOLAR_DAYLIGHT_ONE_DAY_REPLAY_v96nd.txt');
    outMat = fullfile(matDir,'SOLAR_DAYLIGHT_ONE_DAY_REPLAY_v96nd.mat');

    save(outMat, ...
        'diagnosis','decision','next_step','replayFlags', ...
        'x_selected','MR_target','irradiance_threshold','daylight_window_h_nominal', ...
        'Tattempts','Tdaylight','Tsource','Tchecks','candidateDetails', ...
        'gateDirPrev','replayDir', ...
        'outMd','outTxt','outMat','outAttemptsCsv','outDaylightCsv','outSourceCsv','outChecksCsv');

    % Markdown
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# SOLAR_DAYLIGHT_ONE_DAY_REPLAY_v96nd\n\n');
    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Decisión: `%s`\n\n', decision);
    fprintf(fid,'Siguiente paso: `%s`\n\n', next_step);

    fprintf(fid,'## Configuración\n\n');
    fprintf(fid,'| Parámetro | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| MR_target | %.6g |\n', MR_target);
    fprintf(fid,'| irradiance_threshold | %.6g |\n', irradiance_threshold);
    fprintf(fid,'| daylight_start_h_nominal | %.6g |\n', daylight_window_h_nominal(1));
    fprintf(fid,'| daylight_end_h_nominal | %.6g |\n\n', daylight_window_h_nominal(2));

    fprintf(fid,'## Intentos de replay\n\n');
    fprintf(fid,'| attempt | status | detail | time | irr | MR/M | energy | daylight_summary | MR_end | solar_energy | CO2_total |\n');
    fprintf(fid,'|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|\n');

    for i = 1:height(Tattempts)
        fprintf(fid,'| `%s` | `%s` | `%s` | %d | %d | %d | %d | %d | %.12g | %.12g | %.12g |\n', ...
            string(Tattempts.attempt_id(i)), ...
            string(Tattempts.status(i)), ...
            string(Tattempts.detail_status(i)), ...
            Tattempts.has_time_vector(i), ...
            Tattempts.has_irradiance_vector(i), ...
            Tattempts.has_moisture_or_MR_vector(i), ...
            Tattempts.has_energy_vector(i), ...
            Tattempts.daylight_summary_possible(i), ...
            Tattempts.MR_end_daylight(i), ...
            Tattempts.solar_energy_or_irradiation_daylight(i), ...
            Tattempts.CO2_total(i));
    end

    fprintf(fid,'\n## Resumen solar diurno\n\n');
    fprintf(fid,'| Campo | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| MR_end_daylight | %.12g |\n', Tdaylight.MR_end_daylight(1));
    fprintf(fid,'| M_end_daylight | %.12g |\n', Tdaylight.M_end_daylight(1));
    fprintf(fid,'| water_removed_daylight | %.12g |\n', Tdaylight.water_removed_daylight(1));
    fprintf(fid,'| solar_energy_or_irradiation_daylight | %.12g |\n', Tdaylight.solar_energy_or_irradiation_daylight(1));
    fprintf(fid,'| CO2_LPG | %.12g |\n', Tdaylight.CO2_LPG(1));
    fprintf(fid,'| CO2_electricity | %.12g |\n', Tdaylight.CO2_electricity(1));
    fprintf(fid,'| CO2_total | %.12g |\n', Tdaylight.CO2_total(1));
    fprintf(fid,'| reaches_MR_target_in_one_day | %d |\n\n', Tdaylight.reaches_MR_target_in_one_day(1));

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
    if has_usable_daylight_replay
        fprintf(fid,'Se obtuvo un resumen solar diurno. Solar debe mantenerse fuera del GA formal; el resultado se interpreta como desempeño de una jornada solar, no como optimización equivalente.\n');
    else
        fprintf(fid,'No se obtuvo trayectoria solar diurna utilizable desde las rutas existentes. Para cuantificar solar, se requiere instrumentar una ruta de replay que exponga tiempo, irradiancia y MR/humedad. Alternativamente, solar puede documentarse como limitación no cuantificada y proceder con la formal híbrida.\n');
    end

    fclose(fid);

    % TXT
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'CREATE-SOLAR-DAYLIGHT-ONE-DAY-REPLAY-001\n');
    fprintf(fid,'status: SOLAR_DAYLIGHT_ONE_DAY_REPLAY_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'decision: %s\n', decision);
    fprintf(fid,'next_step: %s\n', next_step);
    fprintf(fid,'prior_gate_v96nc_pass: %d\n', replayFlags.prior_gate_v96nc_pass);
    fprintf(fid,'no_GA_executed: %d\n', replayFlags.no_GA_executed);
    fprintf(fid,'no_sources_modified: %d\n', replayFlags.no_sources_modified);
    fprintf(fid,'source_preservation_pass: %d\n', replayFlags.source_preservation_pass);
    fprintf(fid,'n_attempts: %d\n', replayFlags.n_attempts);
    fprintf(fid,'has_usable_daylight_replay: %d\n', replayFlags.has_usable_daylight_replay);
    fprintf(fid,'approved_to_run_formal_after_interpretation: %d\n', replayFlags.approved_to_run_formal_after_interpretation);
    fprintf(fid,'solar_kept_out_of_formal_GA: %d\n', replayFlags.solar_kept_out_of_formal_GA);
    fprintf(fid,'CO2_factors_still_provisional: %d\n', replayFlags.CO2_factors_still_provisional);
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fclose(fid);

    % Consola
    replay = struct();
    replay.status = 'SOLAR_DAYLIGHT_ONE_DAY_REPLAY_COMPLETED';
    replay.diagnosis = diagnosis;
    replay.decision = decision;
    replay.next_step = next_step;
    replay.replayFlags = replayFlags;
    replay.Tattempts = Tattempts;
    replay.Tdaylight = Tdaylight;
    replay.Tsource = Tsource;
    replay.Tchecks = Tchecks;
    replay.replayDir = replayDir;
    replay.outMd = outMd;
    replay.outTxt = outTxt;
    replay.outMat = outMat;

    disp('=== SOLAR_DAYLIGHT_ONE_DAY_REPLAY_v96nd ===')
    disp(replay.status)
    disp('=== DIAGNOSIS ===')
    disp(replay.diagnosis)
    disp('=== DECISION ===')
    disp(replay.decision)
    disp('=== NEXT STEP ===')
    disp(replay.next_step)
    disp('=== REPLAY FLAGS ===')
    disp(replay.replayFlags)
    disp('=== ATTEMPTS ===')
    disp(replay.Tattempts)
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
% Attempts
% =========================================================================

function attempts = local_build_attempts_v96nd(x)
    attempts = {};

    attempts{end+1} = struct( ...
        'id',"A01", ...
        'description',"objective_v96j_fix1(x,'solar')", ...
        'fun',@() objective_productive_corrected_v96j_triobjective_CO2_fix1(x,'solar'));

    attempts{end+1} = struct( ...
        'id',"A02", ...
        'description',"objective_v95j(x,'solar')", ...
        'fun',@() objective_productive_corrected_v95j_endpoint_TMAX_corrected(x,'solar'));

    attempts{end+1} = struct( ...
        'id',"A03", ...
        'description',"wrapper_v18(x,'solar')", ...
        'fun',@() opt_tunel_mod2_v18_endpoint_TMAX_corrected(x,'solar'));

    attempts{end+1} = struct( ...
        'id',"A04", ...
        'description',"wrapper_v18(x1,x2,x3,x4,'solar')", ...
        'fun',@() opt_tunel_mod2_v18_endpoint_TMAX_corrected(x(1),x(2),x(3),x(4),'solar'));

    attempts{end+1} = struct( ...
        'id',"A05", ...
        'description',"wrapper_v17(x,'solar')", ...
        'fun',@() opt_tunel_mod2_v17_nonphysical_penalty(x,'solar'));

    attempts{end+1} = struct( ...
        'id',"A06", ...
        'description',"wrapper_v10(x,'solar')", ...
        'fun',@() opt_tunel_mod2_v10_energy_mode_corrected(x,'solar'));
end

function [status, errMsg, f, detail] = local_try_attempt_v96nd(a)
    status = "OK";
    errMsg = "";
    f = NaN(1,3);
    detail = struct();

    try
        [out1,out2] = a.fun();

        if isnumeric(out1)
            f = double(out1(:))';
        elseif isstruct(out1)
            detail = out1;
        end

        if isstruct(out2)
            detail = out2;
        elseif isnumeric(out2) && all(isnan(f))
            f = double(out2(:))';
        end

    catch ME
        status = "ERROR";
        errMsg = string(ME.message);
        f = NaN(1,3);
        detail = struct();
    end

    if isempty(f)
        f = NaN(1,3);
    end

    if numel(f) < 3
        f2 = NaN(1,3);
        f2(1:numel(f)) = f;
        f = f2;
    end
end

% =========================================================================
% Daylight summary
% =========================================================================

function summary = local_try_daylight_summary_v96nd(detail, MR_target, irradiance_threshold, nominal_window)
    summary = struct();
    summary.summary_possible = false;
    summary.MR_end_daylight = NaN;
    summary.M_end_daylight = NaN;
    summary.water_removed_daylight = NaN;
    summary.solar_energy_or_irradiation_daylight = NaN;
    summary.CO2_LPG = 0;
    summary.CO2_electricity = NaN;
    summary.CO2_total = NaN;
    summary.reaches_MR_target_in_one_day = false;

    audit = local_audit_detail_vectors_v96nd(detail);

    if ~(audit.has_time_vector && audit.has_irradiance_vector && audit.has_moisture_or_MR_vector)
        return
    end

    try
        t = local_get_by_path_v96nd(detail, audit.time_candidate_path);
        irr = local_get_by_path_v96nd(detail, audit.irradiance_candidate_path);
        moist = local_get_by_path_v96nd(detail, audit.moisture_candidate_path);

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

        [t,idx] = sort(t);
        irr = irr(idx);
        moist = moist(idx);

        th = local_time_to_hours_v96nd(t);

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

        if contains(lower(string(audit.moisture_candidate_path)),"mr")
            MR_end = metricEnd;
            M_end = NaN;
        else
            M_end = metricEnd;

            M0 = moist(1);
            if isfinite(M0) && M0 ~= 0
                MR_end = metricEnd / M0;
            else
                MR_end = NaN;
            end
        end

        if audit.has_energy_vector
            e = local_get_by_path_v96nd(detail, audit.energy_candidate_path);
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

        summary.summary_possible = true;
        summary.MR_end_daylight = MR_end;
        summary.M_end_daylight = M_end;
        summary.water_removed_daylight = NaN;
        summary.solar_energy_or_irradiation_daylight = solarEnergy;
        summary.CO2_LPG = 0;
        summary.CO2_electricity = local_get_numeric_v96nd(detail, {'CO2.CO2_electricity_kg','CO2_electricity_kg'}, NaN);
        if isfinite(summary.CO2_electricity)
            summary.CO2_total = summary.CO2_electricity;
        else
            summary.CO2_total = NaN;
        end
        summary.reaches_MR_target_in_one_day = isfinite(MR_end) && MR_end <= MR_target;

    catch
        summary.summary_possible = false;
    end
end

function th = local_time_to_hours_v96nd(t)
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
% Detail audit
% =========================================================================

function audit = local_audit_detail_vectors_v96nd(detail)
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
    audit.n_numeric_vector_candidates = 0;

    if ~isstruct(detail)
        return
    end

    candidates = local_collect_numeric_vectors_v96nd(detail, "detail");
    audit.n_numeric_vector_candidates = numel(candidates);

    for i = 1:numel(candidates)
        p = lower(string(candidates(i).path));
        n = candidates(i).n;

        if ~audit.has_time_vector && n >= 5 && ...
                (contains(p,"time") || contains(p,"tiempo") || contains(p,"hora") || endsWith(p,".t"))
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

function candidates = local_collect_numeric_vectors_v96nd(S, prefix)
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
            sub = local_collect_numeric_vectors_v96nd(val, path);
            if ~isempty(sub)
                candidates = [candidates, sub]; %#ok<AGROW>
            end
        end
    end
end

function val = local_get_by_path_v96nd(S, path)
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

function row = local_source_row_v96nd(item, filePath, pattern, passVal, evidence)
    row = struct();
    row.item = string(item);
    row.file = string(filePath);
    row.pattern = string(pattern);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end

function row = local_check_row_v96nd(id, checkName, passVal, evidence, criterion)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
    row.criterion = string(criterion);
end

function val = local_vec_get_v96nd(v, idx, defaultVal)
    if numel(v) >= idx
        val = v(idx);
    else
        val = defaultVal;
    end
end

function val = local_get_numeric_v96nd(S, paths, defaultVal)
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

function val = local_get_string_v96nd(S, paths, defaultVal)
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