function gate = solar_endpoint_only_interpretation_gate_v96ng()
% SOLAR_ENDPOINT_ONLY_INTERPRETATION_GATE_v96ng
% 9.6n-g — SOLAR-ENDPOINT-ONLY-INTERPRETATION-GATE-001
%
% Objetivo:
%   Cerrar metodológicamente el intento solar diurno.
%
% Este gate:
%   - NO ejecuta gamultiobj.
%   - NO ejecuta la formal v96m.
%   - NO modifica fuentes.
%   - Interpreta el resultado endpoint-only de 9.6n-f.
%   - Autoriza que solar deje de bloquear la formal hybrid/gasLP.
%
% Uso:
%   gate = solar_endpoint_only_interpretation_gate_v96ng();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Cargar 9.6n-f más reciente
    % ---------------------------------------------------------------------
    replayBaseDir = fullfile(rootDir,'05_runs','solar_daylight_instrumented_replay_v96nf');

    if ~isfolder(replayBaseDir)
        error('No existe replayBaseDir: %s', replayBaseDir);
    end

    d = dir(replayBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'SOLAR_DAYLIGHT_INSTRUMENTED_REPLAY_v96nf_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró replay v96nf.');
    end

    [~,idxReplay] = max([d.datenum]);
    replayDirPrev = fullfile(replayBaseDir,d(idxReplay).name);
    replayMat = fullfile(replayDirPrev,'mat','SOLAR_DAYLIGHT_INSTRUMENTED_REPLAY_v96nf.mat');

    if ~isfile(replayMat)
        error('No existe MAT v96nf: %s', replayMat);
    end

    Sreplay = load(replayMat);

    expectedDiagnosis = "SOLAR_DAYLIGHT_INSTRUMENTED_REPLAY_PASS_ENDPOINT_ONLY";

    if ~strcmp(string(Sreplay.diagnosis), expectedDiagnosis)
        error('9.6n-f no está en ENDPOINT_ONLY. Diagnosis: %s', string(Sreplay.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Cargar aprobación formal 9.6n más reciente
    % ---------------------------------------------------------------------
    approvalBaseDir = fullfile(rootDir,'05_runs','triobjective_formal_execution_approval_v96n');

    if ~isfolder(approvalBaseDir)
        error('No existe approvalBaseDir: %s', approvalBaseDir);
    end

    da = dir(approvalBaseDir);
    da = da([da.isdir]);
    da = da(~ismember({da.name},{'.','..','.MATLABDriveTag'}));

    keepA = false(size(da));
    for i = 1:numel(da)
        keepA(i) = startsWith(da(i).name,'TRIOBJECTIVE_FORMAL_EXECUTION_APPROVAL_v96n_');
    end
    da = da(keepA);

    if isempty(da)
        error('No se encontró aprobación v96n.');
    end

    [~,idxApproval] = max([da.datenum]);
    approvalDirPrev = fullfile(approvalBaseDir,da(idxApproval).name);
    approvalMat = fullfile(approvalDirPrev,'mat','TRIOBJECTIVE_FORMAL_EXECUTION_APPROVAL_v96n.mat');

    if ~isfile(approvalMat)
        error('No existe MAT v96n: %s', approvalMat);
    end

    Sapproval = load(approvalMat);

    if ~strcmp(string(Sapproval.diagnosis),"TRIOBJECTIVE_FORMAL_RUN_EXECUTION_APPROVAL_PASS")
        error('9.6n no está aprobado. Diagnosis: %s', string(Sapproval.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    gateBaseDir = fullfile(rootDir,'05_runs','solar_endpoint_only_interpretation_gate_v96ng');
    gateDir = fullfile(gateBaseDir,['SOLAR_ENDPOINT_ONLY_INTERPRETATION_GATE_v96ng_' timestamp]);

    logsDir = fullfile(gateDir,'logs');
    tablesDir = fullfile(gateDir,'tables');
    matDir = fullfile(gateDir,'mat');

    if ~isfolder(gateBaseDir), mkdir(gateBaseDir); end
    if ~isfolder(gateDir), mkdir(gateDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Extraer datos clave del replay
    % ---------------------------------------------------------------------
    Tendpoint = Sreplay.Tendpoint;
    Tdaylight = Sreplay.Tdaylight;
    Taudit = Sreplay.Taudit;
    TchecksReplay = Sreplay.Tchecks;

    replayFlags = Sreplay.replayFlags;

    solar_call_ok = replayFlags.v18_full_signature_call_ok == true;
    endpoint_scalar_available = replayFlags.endpoint_scalar_available == true;
    trajectory_available = replayFlags.trajectory_available == true;
    daylight_summary_possible = replayFlags.daylight_summary_possible == true;
    solar_kept_out_of_formal_GA_prev = replayFlags.solar_kept_out_of_formal_GA == true;
    source_preservation_prev = replayFlags.source_preservation_pass == true;

    Q_aux_tot = local_table_get_numeric_v96ng(Tendpoint,'Q_aux_tot',NaN);
    dry_time = local_table_get_numeric_v96ng(Tendpoint,'dry_time',NaN);
    M_prod_fin = local_table_get_numeric_v96ng(Tendpoint,'M_prod_fin',NaN);
    MR_fin = local_table_get_numeric_v96ng(Tendpoint,'MR_fin',NaN);
    Irradiacion = local_table_get_numeric_v96ng(Tendpoint,'Irradiacion',NaN);

    has_time_vector = local_table_get_logical_v96ng(Taudit,'has_time_vector',false);
    has_irradiance_vector = local_table_get_logical_v96ng(Taudit,'has_irradiance_vector',false);
    has_moisture_or_MR_vector = local_table_get_logical_v96ng(Taudit,'has_moisture_or_MR_vector',false);
    has_energy_vector = local_table_get_logical_v96ng(Taudit,'has_energy_vector',false);
    n_numeric_vector_candidates = local_table_get_numeric_v96ng(Taudit,'n_numeric_vector_candidates',NaN);

    % ---------------------------------------------------------------------
    % Interpretación metodológica
    % ---------------------------------------------------------------------
    interpRows = {};

    interpRows{end+1,1} = local_interp_row_v96ng( ...
        "I01", ...
        "Solar replay call", ...
        solar_call_ok, ...
        "v18 accepts full signature and returns without missing-argument error.", ...
        "The previous call-signature problem is closed.");

    interpRows{end+1,1} = local_interp_row_v96ng( ...
        "I02", ...
        "Endpoint-only result", ...
        endpoint_scalar_available && ~daylight_summary_possible, ...
        sprintf("Q_aux=%.6g; dry_time=%.6g; M=%.6g; MR=%.6g; Irr=%.6g", ...
            Q_aux_tot, dry_time, M_prod_fin, MR_fin, Irradiacion), ...
        "Solar cannot be quantified as daylight trajectory from current outputs.");

    interpRows{end+1,1} = local_interp_row_v96ng( ...
        "I03", ...
        "No daylight trajectory", ...
        ~trajectory_available && ~has_time_vector && ~has_irradiance_vector && ~has_moisture_or_MR_vector, ...
        sprintf("time=%d; irradiance=%d; moisture_or_MR=%d; energy=%d; candidates=%.0f", ...
            has_time_vector, has_irradiance_vector, has_moisture_or_MR_vector, has_energy_vector, n_numeric_vector_candidates), ...
        "Current irr_diag is insufficient for one-day solar performance.");

    interpRows{end+1,1} = local_interp_row_v96ng( ...
        "I04", ...
        "Solar not comparable by dry_time", ...
        true, ...
        "Solar-only is bounded by daily irradiance and should not be compared against hybrid/gasLP by calendar dry_time-to-target.", ...
        "Do not force solar into formal Pareto front.");

    interpRows{end+1,1} = local_interp_row_v96ng( ...
        "I05", ...
        "Solar excluded from formal GA", ...
        solar_kept_out_of_formal_GA_prev, ...
        "Replay explicitly kept solar out of formal GA.", ...
        "Formal route remains hybrid with gasLP reference.");

    interpRows{end+1,1} = local_interp_row_v96ng( ...
        "I06", ...
        "Further solar work classification", ...
        true, ...
        "Quantifying solar daylight requires deeper internal instrumentation of v18 or a solar-specific model branch.", ...
        "Classify as future work / model limitation, not blocker for formal hybrid GA.");

    Tinterpretation = struct2table(vertcat(interpRows{:}));

    % ---------------------------------------------------------------------
    % Decisión de alcance
    % ---------------------------------------------------------------------
    scopeRows = {};

    scopeRows{end+1,1} = local_scope_row_v96ng( ...
        "S01", ...
        "Formal optimization scope", ...
        "hybrid triobjective optimization", ...
        true);

    scopeRows{end+1,1} = local_scope_row_v96ng( ...
        "S02", ...
        "Reference case", ...
        "gasLP direct/reference evaluation", ...
        true);

    scopeRows{end+1,1} = local_scope_row_v96ng( ...
        "S03", ...
        "Solar status", ...
        "excluded from formal GA; endpoint-only diagnostic; daylight trajectory not quantified", ...
        true);

    scopeRows{end+1,1} = local_scope_row_v96ng( ...
        "S04", ...
        "Forbidden claim", ...
        "do not claim full solar-vs-hybrid-vs-gasLP Pareto comparison", ...
        true);

    scopeRows{end+1,1} = local_scope_row_v96ng( ...
        "S05", ...
        "Allowed claim", ...
        "solar-only requires separate daylight/window formulation and is outside the current formal optimization", ...
        true);

    scopeRows{end+1,1} = local_scope_row_v96ng( ...
        "S06", ...
        "Next operational action", ...
        "run guarded formal hybrid GA v96m after this gate passes", ...
        true);

    Tscope = struct2table(vertcat(scopeRows{:}));

    % ---------------------------------------------------------------------
    % Source scan
    % ---------------------------------------------------------------------
    formal_script_v96m = fullfile(rootDir,'02_src_limpio','production','run_guarded_triobjective_formal_ga_v96m.m');
    objective_v96j_fix1 = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v96j_triobjective_CO2_fix1.m');
    objective_v95j = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v95j_endpoint_TMAX_corrected.m');
    wrapper_v18 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v18_endpoint_TMAX_corrected.m');
    replay_v96nf = fullfile(rootDir,'02_src_limpio','production','solar_daylight_one_day_replay_instrumented_v96nf.m');

    sourceRows = {};
    sourceRows{end+1,1} = local_source_row_v96ng("formal_script_v96m_exists",formal_script_v96m,isfile(formal_script_v96m),"Formal hybrid script exists.");
    sourceRows{end+1,1} = local_source_row_v96ng("objective_v96j_fix1_exists",objective_v96j_fix1,isfile(objective_v96j_fix1),"Triobjective objective exists.");
    sourceRows{end+1,1} = local_source_row_v96ng("objective_v95j_exists",objective_v95j,isfile(objective_v95j),"Base objective exists.");
    sourceRows{end+1,1} = local_source_row_v96ng("wrapper_v18_exists",wrapper_v18,isfile(wrapper_v18),"v18 wrapper exists.");
    sourceRows{end+1,1} = local_source_row_v96ng("replay_v96nf_exists",replay_v96nf,isfile(replay_v96nf),"Instrumented solar replay exists.");

    Tsource = struct2table(vertcat(sourceRows{:}));
    source_preservation_pass = all(Tsource.pass) && source_preservation_prev;

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    formal_not_executed_yet = Sapproval.approvalFlags.formal_run_not_executed_yet == true;
    modeFormal_ok = strcmp(string(Sapproval.approvalFlags.modeFormal),"hybrid");
    referenceMode_ok = strcmp(string(Sapproval.approvalFlags.referenceMode),"gasLP");

    checks = {};

    checks{end+1,1} = local_check_row_v96ng( ...
        "G01", ...
        "Prior solar replay endpoint-only", ...
        strcmp(string(Sreplay.diagnosis), expectedDiagnosis), ...
        string(Sreplay.diagnosis), ...
        "9.6n-f must have endpoint-only diagnosis.");

    checks{end+1,1} = local_check_row_v96ng( ...
        "G02", ...
        "v18 full-signature call resolved", ...
        solar_call_ok, ...
        sprintf("v18_full_signature_call_ok=%d", solar_call_ok), ...
        "The missing-argument issue must be closed.");

    checks{end+1,1} = local_check_row_v96ng( ...
        "G03", ...
        "No daylight trajectory available", ...
        ~trajectory_available && ~daylight_summary_possible, ...
        sprintf("trajectory_available=%d; daylight_summary_possible=%d", trajectory_available, daylight_summary_possible), ...
        "Solar daylight cannot be quantified from current outputs.");

    checks{end+1,1} = local_check_row_v96ng( ...
        "G04", ...
        "Endpoint is not valid solar performance claim", ...
        endpoint_scalar_available && (MR_fin >= 999 || ~isfinite(Q_aux_tot) || ~isfinite(Irradiacion)), ...
        sprintf("Q_aux=%.6g; MR=%.6g; Irr=%.6g", Q_aux_tot, MR_fin, Irradiacion), ...
        "Endpoint-only values must not be presented as valid solar drying performance.");

    checks{end+1,1} = local_check_row_v96ng( ...
        "G05", ...
        "Solar kept out of formal GA", ...
        solar_kept_out_of_formal_GA_prev, ...
        "solar_kept_out_of_formal_GA=1", ...
        "Solar must remain outside formal Pareto front.");

    checks{end+1,1} = local_check_row_v96ng( ...
        "G06", ...
        "Formal hybrid approval still valid", ...
        formal_not_executed_yet && modeFormal_ok && referenceMode_ok, ...
        sprintf("formal_not_executed=%d; modeFormal=%s; referenceMode=%s", ...
            formal_not_executed_yet, string(Sapproval.approvalFlags.modeFormal), string(Sapproval.approvalFlags.referenceMode)), ...
        "Formal route must remain hybrid with gasLP reference.");

    checks{end+1,1} = local_check_row_v96ng( ...
        "G07", ...
        "Source preservation", ...
        source_preservation_pass, ...
        sprintf("source_preservation_pass=%d", source_preservation_pass), ...
        "No protected source may be missing.");

    checks{end+1,1} = local_check_row_v96ng( ...
        "G08", ...
        "No GA executed in this gate", ...
        true, ...
        "This gate does not call gamultiobj.", ...
        "This is interpretation only.");

    Tchecks = struct2table(vertcat(checks{:}));

    gate_pass = all(Tchecks.pass);

    if gate_pass
        diagnosis = "SOLAR_ENDPOINT_ONLY_INTERPRETATION_GATE_PASS";
        decision = "SOLAR_NO_LONGER_BLOCKS_HYBRID_FORMAL_RUN";
        next_step = "Execute: formal = run_guarded_triobjective_formal_ga_v96m(true);";
        approved_to_run_formal_now = true;
    else
        diagnosis = "SOLAR_ENDPOINT_ONLY_INTERPRETATION_GATE_REQUIRES_REVIEW";
        decision = "REVIEW_SOLAR_ENDPOINT_OR_FORMAL_APPROVAL_STATUS";
        next_step = "Review failed checks.";
        approved_to_run_formal_now = false;
    end

    gateFlags = struct();
    gateFlags.prior_replay_endpoint_only = strcmp(string(Sreplay.diagnosis), expectedDiagnosis);
    gateFlags.no_GA_executed = true;
    gateFlags.no_sources_modified = true;
    gateFlags.v18_full_signature_call_ok = solar_call_ok;
    gateFlags.endpoint_scalar_available = endpoint_scalar_available;
    gateFlags.trajectory_available = trajectory_available;
    gateFlags.daylight_summary_possible = daylight_summary_possible;
    gateFlags.solar_endpoint_not_valid_performance_claim = MR_fin >= 999 || ~isfinite(Q_aux_tot) || ~isfinite(Irradiacion);
    gateFlags.solar_excluded_from_formal_GA = true;
    gateFlags.solar_no_longer_blocks_formal = gate_pass;
    gateFlags.formal_not_executed_yet = formal_not_executed_yet;
    gateFlags.modeFormal = string(Sapproval.approvalFlags.modeFormal);
    gateFlags.referenceMode = string(Sapproval.approvalFlags.referenceMode);
    gateFlags.approved_to_run_formal_now = approved_to_run_formal_now;
    gateFlags.CO2_factors_still_provisional = true;

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outInterpretationCsv = fullfile(tablesDir,'SOLAR_ENDPOINT_ONLY_INTERPRETATION_GATE_v96ng_interpretation.csv');
    outScopeCsv = fullfile(tablesDir,'SOLAR_ENDPOINT_ONLY_INTERPRETATION_GATE_v96ng_scope.csv');
    outEndpointCsv = fullfile(tablesDir,'SOLAR_ENDPOINT_ONLY_INTERPRETATION_GATE_v96ng_endpoint.csv');
    outAuditCsv = fullfile(tablesDir,'SOLAR_ENDPOINT_ONLY_INTERPRETATION_GATE_v96ng_audit.csv');
    outSourceCsv = fullfile(tablesDir,'SOLAR_ENDPOINT_ONLY_INTERPRETATION_GATE_v96ng_source_scan.csv');
    outChecksCsv = fullfile(tablesDir,'SOLAR_ENDPOINT_ONLY_INTERPRETATION_GATE_v96ng_checks.csv');

    writetable(Tinterpretation,outInterpretationCsv);
    writetable(Tscope,outScopeCsv);
    writetable(Tendpoint,outEndpointCsv);
    writetable(Taudit,outAuditCsv);
    writetable(Tsource,outSourceCsv);
    writetable(Tchecks,outChecksCsv);

    outMd = fullfile(logsDir,'SOLAR_ENDPOINT_ONLY_INTERPRETATION_GATE_v96ng.md');
    outTxt = fullfile(logsDir,'SOLAR_ENDPOINT_ONLY_INTERPRETATION_GATE_v96ng.txt');
    outMat = fullfile(matDir,'SOLAR_ENDPOINT_ONLY_INTERPRETATION_GATE_v96ng.mat');

    save(outMat, ...
        'diagnosis','decision','next_step','gateFlags', ...
        'Tinterpretation','Tscope','Tendpoint','Tdaylight','Taudit','TchecksReplay','Tsource','Tchecks', ...
        'Sreplay','Sapproval','replayDirPrev','approvalDirPrev','gateDir', ...
        'outMd','outTxt','outMat','outInterpretationCsv','outScopeCsv','outEndpointCsv','outAuditCsv','outSourceCsv','outChecksCsv');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# SOLAR_ENDPOINT_ONLY_INTERPRETATION_GATE_v96ng\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Decisión: `%s`\n\n', decision);
    fprintf(fid,'Siguiente paso: `%s`\n\n', next_step);

    fprintf(fid,'## Interpretación técnica\n\n');
    fprintf(fid,'El replay solar instrumentado resolvió la llamada al wrapper v18 con firma completa, pero sólo produjo resultado endpoint-only. No hay trayectoria suficiente para cuantificar jornada solar porque faltan simultáneamente vector de tiempo, irradiancia y humedad/MR.\n\n');
    fprintf(fid,'El endpoint solar no debe usarse como desempeño físico válido: `MR_fin = %.12g`, `Q_aux_tot = %.12g`, `Irradiacion = %.12g`.\n\n', MR_fin, Q_aux_tot, Irradiacion);

    fprintf(fid,'## Alcance aprobado\n\n');
    fprintf(fid,'| ID | Campo | Alcance | Aprobado |\n');
    fprintf(fid,'|---|---|---|---:|\n');

    for i = 1:height(Tscope)
        fprintf(fid,'| `%s` | `%s` | `%s` | %d |\n', ...
            string(Tscope.id(i)), ...
            string(Tscope.field(i)), ...
            string(Tscope.scope(i)), ...
            Tscope.approved(i));
    end

    fprintf(fid,'\n## Interpretación\n\n');
    fprintf(fid,'| ID | Tema | Aceptado | Evidencia | Implicación |\n');
    fprintf(fid,'|---|---|---:|---|---|\n');

    for i = 1:height(Tinterpretation)
        fprintf(fid,'| `%s` | `%s` | `%d` | %s | %s |\n', ...
            string(Tinterpretation.id(i)), ...
            string(Tinterpretation.topic(i)), ...
            Tinterpretation.accepted(i), ...
            string(Tinterpretation.evidence(i)), ...
            string(Tinterpretation.implication(i)));
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

    if gate_pass
        fprintf(fid,'Solar puro deja de bloquear la corrida formal. Queda excluido del GA formal porque no se dispone de trayectoria diurna y el endpoint solar actual no constituye desempeño físico válido. La formal autorizada queda limitada a optimización triobjetivo hybrid con referencia gasLP.\n\n');
        fprintf(fid,'Comando autorizado:\n\n');
        fprintf(fid,'```matlab\nformal = run_guarded_triobjective_formal_ga_v96m(true);\n```\n');
    else
        fprintf(fid,'No se autoriza todavía la formal. Revisar checks fallidos.\n');
    end

    fclose(fid);

    % TXT
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'SOLAR-ENDPOINT-ONLY-INTERPRETATION-GATE-001\n');
    fprintf(fid,'status: SOLAR_ENDPOINT_ONLY_INTERPRETATION_GATE_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'decision: %s\n', decision);
    fprintf(fid,'next_step: %s\n', next_step);
    fprintf(fid,'prior_replay_endpoint_only: %d\n', gateFlags.prior_replay_endpoint_only);
    fprintf(fid,'no_GA_executed: %d\n', gateFlags.no_GA_executed);
    fprintf(fid,'no_sources_modified: %d\n', gateFlags.no_sources_modified);
    fprintf(fid,'v18_full_signature_call_ok: %d\n', gateFlags.v18_full_signature_call_ok);
    fprintf(fid,'endpoint_scalar_available: %d\n', gateFlags.endpoint_scalar_available);
    fprintf(fid,'trajectory_available: %d\n', gateFlags.trajectory_available);
    fprintf(fid,'daylight_summary_possible: %d\n', gateFlags.daylight_summary_possible);
    fprintf(fid,'solar_endpoint_not_valid_performance_claim: %d\n', gateFlags.solar_endpoint_not_valid_performance_claim);
    fprintf(fid,'solar_excluded_from_formal_GA: %d\n', gateFlags.solar_excluded_from_formal_GA);
    fprintf(fid,'solar_no_longer_blocks_formal: %d\n', gateFlags.solar_no_longer_blocks_formal);
    fprintf(fid,'formal_not_executed_yet: %d\n', gateFlags.formal_not_executed_yet);
    fprintf(fid,'modeFormal: %s\n', gateFlags.modeFormal);
    fprintf(fid,'referenceMode: %s\n', gateFlags.referenceMode);
    fprintf(fid,'approved_to_run_formal_now: %d\n', gateFlags.approved_to_run_formal_now);
    fprintf(fid,'CO2_factors_still_provisional: %d\n', gateFlags.CO2_factors_still_provisional);
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Consola
    % ---------------------------------------------------------------------
    gate = struct();
    gate.status = 'SOLAR_ENDPOINT_ONLY_INTERPRETATION_GATE_COMPLETED';
    gate.diagnosis = diagnosis;
    gate.decision = decision;
    gate.next_step = next_step;
    gate.gateFlags = gateFlags;
    gate.Tinterpretation = Tinterpretation;
    gate.Tscope = Tscope;
    gate.Tendpoint = Tendpoint;
    gate.Taudit = Taudit;
    gate.Tsource = Tsource;
    gate.Tchecks = Tchecks;
    gate.gateDir = gateDir;
    gate.outMd = outMd;
    gate.outTxt = outTxt;
    gate.outMat = outMat;

    disp('=== SOLAR_ENDPOINT_ONLY_INTERPRETATION_GATE_v96ng ===')
    disp(gate.status)
    disp('=== DIAGNOSIS ===')
    disp(gate.diagnosis)
    disp('=== DECISION ===')
    disp(gate.decision)
    disp('=== NEXT STEP ===')
    disp(gate.next_step)
    disp('=== GATE FLAGS ===')
    disp(gate.gateFlags)
    disp('=== INTERPRETATION ===')
    disp(gate.Tinterpretation)
    disp('=== SCOPE ===')
    disp(gate.Tscope)
    disp('=== ENDPOINT ===')
    disp(gate.Tendpoint)
    disp('=== AUDIT ===')
    disp(gate.Taudit)
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

function row = local_interp_row_v96ng(id, topic, accepted, evidence, implication)
    row = struct();
    row.id = string(id);
    row.topic = string(topic);
    row.accepted = logical(accepted);
    row.evidence = string(evidence);
    row.implication = string(implication);
end

function row = local_scope_row_v96ng(id, field, scope, approved)
    row = struct();
    row.id = string(id);
    row.field = string(field);
    row.scope = string(scope);
    row.approved = logical(approved);
end

function row = local_source_row_v96ng(item, filePath, passVal, evidence)
    row = struct();
    row.item = string(item);
    row.file = string(filePath);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end

function row = local_check_row_v96ng(id, checkName, passVal, evidence, criterion)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
    row.criterion = string(criterion);
end

function val = local_table_get_numeric_v96ng(T, varName, defaultVal)
    val = defaultVal;

    if istable(T) && any(strcmp(T.Properties.VariableNames,varName)) && height(T) >= 1
        tmp = T.(varName);
        if isnumeric(tmp) && ~isempty(tmp)
            val = double(tmp(1));
        elseif islogical(tmp) && ~isempty(tmp)
            val = double(tmp(1));
        end
    end
end

function val = local_table_get_logical_v96ng(T, varName, defaultVal)
    val = defaultVal;

    if istable(T) && any(strcmp(T.Properties.VariableNames,varName)) && height(T) >= 1
        tmp = T.(varName);
        if islogical(tmp) && ~isempty(tmp)
            val = logical(tmp(1));
        elseif isnumeric(tmp) && ~isempty(tmp)
            val = logical(tmp(1));
        end
    end
end