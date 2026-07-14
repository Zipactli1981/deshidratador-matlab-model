function approval = approve_triobjective_formal_run_execution_v96n()
% APPROVE_TRIOBJECTIVE_FORMAL_RUN_EXECUTION_v96n
% 9.6n — TRIOBJECTIVE-FORMAL-RUN-EXECUTION-APPROVAL-001
%
% Objetivo:
%   Emitir aprobación técnica final para ejecutar la corrida formal
%   triobjetivo con:
%
%       formal = run_guarded_triobjective_formal_ga_v96m(true);
%
% Este micropaso:
%   - NO ejecuta gamultiobj.
%   - NO modifica fuentes.
%   - Verifica que 9.6m esté en SCRIPT_READY_NO_EXECUTION.
%   - Verifica que la corrida formal siga detenida.
%   - Registra comando aprobado, configuración y restricciones.
%
% Uso:
%   approval = approve_triobjective_formal_run_execution_v96n();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Cargar salida 9.6m
    % ---------------------------------------------------------------------
    formalBaseDir = fullfile(rootDir,'05_runs','triobjective_formal_ga_v96m');

    if ~isfolder(formalBaseDir)
        error('No existe formalBaseDir: %s', formalBaseDir);
    end

    d = dir(formalBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'TRIOBJECTIVE_FORMAL_GA_v96m_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró salida v96m.');
    end

    [~,idxFormal] = max([d.datenum]);
    formalDirPrev = fullfile(formalBaseDir,d(idxFormal).name);
    formalMat = fullfile(formalDirPrev,'mat','TRIOBJECTIVE_FORMAL_GA_v96m.mat');

    if ~isfile(formalMat)
        error('No existe MAT v96m: %s', formalMat);
    end

    Sformal = load(formalMat);

    if ~strcmp(string(Sformal.diagnosis),"TRIOBJECTIVE_FORMAL_RUN_SCRIPT_READY_NO_EXECUTION")
        error('v96m no está en SCRIPT_READY_NO_EXECUTION. Diagnosis: %s', string(Sformal.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Archivos y función formal
    % ---------------------------------------------------------------------
    formal_script = fullfile(rootDir,'02_src_limpio','production','run_guarded_triobjective_formal_ga_v96m.m');
    objective_v96j_fix1 = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v96j_triobjective_CO2_fix1.m');

    objective_v95j = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v95j_endpoint_TMAX_corrected.m');
    wrapper_v10 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v10_energy_mode_corrected.m');
    wrapper_v17 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v17_nonphysical_penalty.m');
    wrapper_v18 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v18_endpoint_TMAX_corrected.m');
    objective_v628b = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v628b_nonphysical_penalty.m');

    if ~isfile(formal_script)
        error('No existe formal script v96m: %s', formal_script);
    end

    if ~isfile(objective_v96j_fix1)
        error('No existe objective v96j_fix1: %s', objective_v96j_fix1);
    end

    if exist('run_guarded_triobjective_formal_ga_v96m','file') ~= 2
        error('No está visible run_guarded_triobjective_formal_ga_v96m.');
    end

    if exist('objective_productive_corrected_v96j_triobjective_CO2_fix1','file') ~= 2
        error('No está visible objective_productive_corrected_v96j_triobjective_CO2_fix1.');
    end

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    approvalBaseDir = fullfile(rootDir,'05_runs','triobjective_formal_execution_approval_v96n');
    approvalDir = fullfile(approvalBaseDir,['TRIOBJECTIVE_FORMAL_EXECUTION_APPROVAL_v96n_' timestamp]);

    logsDir = fullfile(approvalDir,'logs');
    tablesDir = fullfile(approvalDir,'tables');
    matDir = fullfile(approvalDir,'mat');

    if ~isfolder(approvalBaseDir), mkdir(approvalBaseDir); end
    if ~isfolder(approvalDir), mkdir(approvalDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Datos de configuración desde v96m
    % ---------------------------------------------------------------------
    flags = Sformal.formalFlags;

    approved_command = "formal = run_guarded_triobjective_formal_ga_v96m(true);";
    safe_command = "formal = run_guarded_triobjective_formal_ga_v96m(false);";

    population_size = flags.population_size;
    max_generations = flags.max_generations;
    modeFormal = string(flags.modeFormal);
    referenceMode = string(flags.referenceMode);

    estimated_runtime_h = NaN;
    try
        designDir = Sformal.designDir;
        designMat = fullfile(designDir,'mat','TRIOBJECTIVE_FORMAL_RUN_DESIGN_v96l.mat');
        if isfile(designMat)
            Sdesign = load(designMat);
            estimated_runtime_h = Sdesign.designFlags.recommended_estimated_runtime_h;
        end
    catch
        estimated_runtime_h = NaN;
    end

    % ---------------------------------------------------------------------
    % Preflight de confirmación rápida
    % ---------------------------------------------------------------------
    x_selected = Sformal.x_selected;

    modesPreflight = ["gasLP","hybrid","solar"];
    preRows = {};

    for i = 1:numel(modesPreflight)
        mode = modesPreflight(i);
        [f, d0, status, errMsg] = local_eval_triobjective_v96n(x_selected, mode);
        preRows{end+1,1} = local_preflight_row_v96n(mode, x_selected, f, d0, status, errMsg); %#ok<AGROW>
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
    % Source scan
    % ---------------------------------------------------------------------
    sourceRows = {};

    sourceRows{end+1,1} = local_source_row_v96n("formal_script_exists", formal_script, "", isfile(formal_script), "Formal script v96m exists.");
    sourceRows{end+1,1} = local_source_row_v96n("objective_v96j_fix1_exists", objective_v96j_fix1, "", isfile(objective_v96j_fix1), "Triobjective objective fix1 exists.");
    sourceRows{end+1,1} = local_source_row_v96n("objective_v95j_preserved", objective_v95j, "", isfile(objective_v95j), "v95j preserved.");
    sourceRows{end+1,1} = local_source_row_v96n("wrapper_v10_preserved", wrapper_v10, "", isfile(wrapper_v10), "v10 preserved.");
    sourceRows{end+1,1} = local_source_row_v96n("wrapper_v17_preserved", wrapper_v17, "", isfile(wrapper_v17), "v17 preserved.");
    sourceRows{end+1,1} = local_source_row_v96n("wrapper_v18_preserved", wrapper_v18, "", isfile(wrapper_v18), "v18 preserved.");
    sourceRows{end+1,1} = local_source_row_v96n("objective_v628b_preserved", objective_v628b, "", isfile(objective_v628b), "v628b preserved.");

    sourceRows{end+1,1} = local_source_contains_v96n("formal_has_confirm_execute_guard", formal_script, "confirm_execute", "Formal script has execution guard.");
    sourceRows{end+1,1} = local_source_contains_v96n("formal_calls_v96j_fix1", formal_script, "objective_productive_corrected_v96j_triobjective_CO2_fix1", "Formal script calls v96j_fix1.");
    sourceRows{end+1,1} = local_source_contains_v96n("formal_has_true_command_documented", formal_script, "run_guarded_triobjective_formal_ga_v96m(true)", "Execution command documented.");
    sourceRows{end+1,1} = local_source_contains_v96n("objective_has_provisional_factor_flag", objective_v96j_fix1, "PROVISIONAL_FOR_CODE_VALIDATION", "Objective marks provisional factors.");

    Tsource = struct2table(vertcat(sourceRows{:}));
    source_preservation_pass = all(Tsource.pass);

    % ---------------------------------------------------------------------
    % Approval checks
    % ---------------------------------------------------------------------
    checks = {};

    checks{end+1,1} = local_check_row_v96n( ...
        "N01", ...
        "v96m script ready", ...
        strcmp(string(Sformal.diagnosis),"TRIOBJECTIVE_FORMAL_RUN_SCRIPT_READY_NO_EXECUTION"), ...
        string(Sformal.diagnosis), ...
        "v96m must be ready and not executed.");

    checks{end+1,1} = local_check_row_v96n( ...
        "N02", ...
        "formal run still not executed", ...
        flags.confirm_execute == false && strcmp(string(flags.run_status),"NOT_EXECUTED") && flags.formal_run_executed == false, ...
        sprintf("confirm_execute=%d; run_status=%s; formal_run_executed=%d", flags.confirm_execute, string(flags.run_status), flags.formal_run_executed), ...
        "Approval must occur before formal execution.");

    checks{end+1,1} = local_check_row_v96n( ...
        "N03", ...
        "approval preflight pass", ...
        preflight_pass, ...
        sprintf("gas f=[%.6g %.6g %.6g]; hybrid f=[%.6g %.6g %.6g]; solar f=[%.6g %.6g %.6g]", ...
            gasPre.f1(1), gasPre.f2(1), gasPre.f3(1), ...
            hybPre.f1(1), hybPre.f2(1), hybPre.f3(1), ...
            solPre.f1(1), solPre.f2(1), solPre.f3(1)), ...
        "gasLP/hybrid valid; solar penalized.");

    checks{end+1,1} = local_check_row_v96n( ...
        "N04", ...
        "source preservation", ...
        source_preservation_pass, ...
        "Formal script, objective and protected sources available.", ...
        "No protected source may be missing.");

    checks{end+1,1} = local_check_row_v96n( ...
        "N05", ...
        "formal configuration", ...
        population_size == 24 && max_generations == 50 && modeFormal == "hybrid" && referenceMode == "gasLP", ...
        sprintf("pop=%d; gen=%d; mode=%s; reference=%s", population_size, max_generations, modeFormal, referenceMode), ...
        "Formal configuration must match F1.");

    checks{end+1,1} = local_check_row_v96n( ...
        "N06", ...
        "runtime estimate available", ...
        isfinite(estimated_runtime_h) && estimated_runtime_h > 0, ...
        sprintf("estimated_runtime_h=%.6f", estimated_runtime_h), ...
        "Runtime estimate must be available before execution.");

    checks{end+1,1} = local_check_row_v96n( ...
        "N07", ...
        "emission factors provisional", ...
        flags.emission_factors_provisional == true, ...
        "Factors are provisional; CO2 manuscript-final claims remain blocked.", ...
        "Factor status must be explicit.");

    checks{end+1,1} = local_check_row_v96n( ...
        "N08", ...
        "approved command fixed", ...
        approved_command == "formal = run_guarded_triobjective_formal_ga_v96m(true);", ...
        approved_command, ...
        "Approved command must execute v96m with true.");

    Tchecks = struct2table(vertcat(checks{:}));

    approval_pass = all(Tchecks.pass);

    if approval_pass
        diagnosis = "TRIOBJECTIVE_FORMAL_RUN_EXECUTION_APPROVAL_PASS";
    else
        diagnosis = "TRIOBJECTIVE_FORMAL_RUN_EXECUTION_APPROVAL_REQUIRES_REVIEW";
    end

    % ---------------------------------------------------------------------
    % Flags
    % ---------------------------------------------------------------------
    approvalFlags = struct();
    approvalFlags.v96m_script_ready = strcmp(string(Sformal.diagnosis),"TRIOBJECTIVE_FORMAL_RUN_SCRIPT_READY_NO_EXECUTION");
    approvalFlags.formal_run_not_executed_yet = flags.formal_run_executed == false;
    approvalFlags.preflight_pass = preflight_pass;
    approvalFlags.source_preservation_pass = source_preservation_pass;
    approvalFlags.objective_v96j_fix1_used = true;
    approvalFlags.population_size = population_size;
    approvalFlags.max_generations = max_generations;
    approvalFlags.modeFormal = modeFormal;
    approvalFlags.referenceMode = referenceMode;
    approvalFlags.estimated_runtime_h = estimated_runtime_h;
    approvalFlags.emission_factors_provisional = true;
    approvalFlags.manuscript_final_CO2_claims_blocked = true;
    approvalFlags.formal_run_command_approved = approval_pass;
    approvalFlags.no_GA_executed_in_this_step = true;
    approvalFlags.next_step_is_manual_execution = approval_pass;

    % ---------------------------------------------------------------------
    % CSV outputs
    % ---------------------------------------------------------------------
    outPreflightCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_EXECUTION_APPROVAL_v96n_preflight.csv');
    outSourceCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_EXECUTION_APPROVAL_v96n_source_scan.csv');
    outChecksCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_EXECUTION_APPROVAL_v96n_checks.csv');

    writetable(Tpreflight,outPreflightCsv);
    writetable(Tsource,outSourceCsv);
    writetable(Tchecks,outChecksCsv);

    % ---------------------------------------------------------------------
    % MAT/TXT/MD
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'TRIOBJECTIVE_FORMAL_EXECUTION_APPROVAL_v96n.md');
    outTxt = fullfile(logsDir,'TRIOBJECTIVE_FORMAL_EXECUTION_APPROVAL_v96n.txt');
    outMat = fullfile(matDir,'TRIOBJECTIVE_FORMAL_EXECUTION_APPROVAL_v96n.mat');

    save(outMat, ...
        'diagnosis','approvalFlags', ...
        'approved_command','safe_command', ...
        'population_size','max_generations','modeFormal','referenceMode','estimated_runtime_h', ...
        'Tpreflight','Tsource','Tchecks', ...
        'formal_script','objective_v96j_fix1','objective_v95j','wrapper_v10','wrapper_v17','wrapper_v18','objective_v628b', ...
        'formalDirPrev','approvalDir', ...
        'outMd','outTxt','outMat','outPreflightCsv','outSourceCsv','outChecksCsv');

    % Markdown
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# TRIOBJECTIVE_FORMAL_EXECUTION_APPROVAL_v96n\n\n');
    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);

    fprintf(fid,'## Comando aprobado\n\n');
    fprintf(fid,'```matlab\n%s\n```\n\n', approved_command);

    fprintf(fid,'## Comando seguro de preflight\n\n');
    fprintf(fid,'```matlab\n%s\n```\n\n', safe_command);

    fprintf(fid,'## Configuración aprobada\n\n');
    fprintf(fid,'| Parámetro | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| PopulationSize | %d |\n', population_size);
    fprintf(fid,'| MaxGenerations | %d |\n', max_generations);
    fprintf(fid,'| estimated_runtime_h | %.6f |\n\n', estimated_runtime_h);

    fprintf(fid,'| Campo | Valor |\n');
    fprintf(fid,'|---|---|\n');
    fprintf(fid,'| modeFormal | `%s` |\n', modeFormal);
    fprintf(fid,'| referenceMode | `%s` |\n', referenceMode);
    fprintf(fid,'| objective | `objective_productive_corrected_v96j_triobjective_CO2_fix1` |\n\n');

    fprintf(fid,'## Preflight de aprobación\n\n');
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

    fprintf(fid,'\n## Restricciones vigentes\n\n');
    fprintf(fid,'- Este paso NO ejecutó `gamultiobj`.\n');
    fprintf(fid,'- La corrida formal durará aproximadamente `%.3f h`.\n', estimated_runtime_h);
    fprintf(fid,'- Los factores de emisión siguen provisionales.\n');
    fprintf(fid,'- CO2 puede usarse para arquitectura computacional y selección triobjetivo, pero no como valor final de manuscrito hasta fijar factores documentados.\n');
    fprintf(fid,'- Solar puro sigue excluido/penalizado.\n\n');

    fprintf(fid,'## Siguiente acción\n\n');
    if approval_pass
        fprintf(fid,'Ejecutar manualmente:\n\n```matlab\n%s\n```\n\n', approved_command);
        fprintf(fid,'Después de terminar, continuar con `9.6o — TRIOBJECTIVE-FORMAL-POSTRUN-CONSOLIDATION-001`.\n');
    else
        fprintf(fid,'No ejecutar corrida formal. Revisar checks fallidos.\n');
    end

    fclose(fid);

    % TXT
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'TRIOBJECTIVE-FORMAL-RUN-EXECUTION-APPROVAL-001\n');
    fprintf(fid,'status: TRIOBJECTIVE_FORMAL_EXECUTION_APPROVAL_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'v96m_script_ready: %d\n', approvalFlags.v96m_script_ready);
    fprintf(fid,'formal_run_not_executed_yet: %d\n', approvalFlags.formal_run_not_executed_yet);
    fprintf(fid,'preflight_pass: %d\n', approvalFlags.preflight_pass);
    fprintf(fid,'source_preservation_pass: %d\n', approvalFlags.source_preservation_pass);
    fprintf(fid,'objective_v96j_fix1_used: %d\n', approvalFlags.objective_v96j_fix1_used);
    fprintf(fid,'population_size: %d\n', approvalFlags.population_size);
    fprintf(fid,'max_generations: %d\n', approvalFlags.max_generations);
    fprintf(fid,'modeFormal: %s\n', approvalFlags.modeFormal);
    fprintf(fid,'referenceMode: %s\n', approvalFlags.referenceMode);
    fprintf(fid,'estimated_runtime_h: %.6f\n', approvalFlags.estimated_runtime_h);
    fprintf(fid,'emission_factors_provisional: %d\n', approvalFlags.emission_factors_provisional);
    fprintf(fid,'manuscript_final_CO2_claims_blocked: %d\n', approvalFlags.manuscript_final_CO2_claims_blocked);
    fprintf(fid,'formal_run_command_approved: %d\n', approvalFlags.formal_run_command_approved);
    fprintf(fid,'no_GA_executed_in_this_step: %d\n', approvalFlags.no_GA_executed_in_this_step);
    fprintf(fid,'next_step_is_manual_execution: %d\n', approvalFlags.next_step_is_manual_execution);
    fprintf(fid,'approved_command: %s\n', approved_command);
    fprintf(fid,'safe_command: %s\n', safe_command);
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Salida consola
    % ---------------------------------------------------------------------
    approval = struct();
    approval.status = 'TRIOBJECTIVE_FORMAL_EXECUTION_APPROVAL_COMPLETED';
    approval.diagnosis = diagnosis;
    approval.approvalFlags = approvalFlags;
    approval.approved_command = approved_command;
    approval.safe_command = safe_command;
    approval.Tpreflight = Tpreflight;
    approval.Tsource = Tsource;
    approval.Tchecks = Tchecks;
    approval.approvalDir = approvalDir;
    approval.outMd = outMd;
    approval.outTxt = outTxt;
    approval.outMat = outMat;

    disp('=== TRIOBJECTIVE_FORMAL_EXECUTION_APPROVAL_v96n ===')
    disp(approval.status)
    disp('=== DIAGNOSIS ===')
    disp(approval.diagnosis)
    disp('=== APPROVAL FLAGS ===')
    disp(approval.approvalFlags)
    disp('=== APPROVED COMMAND ===')
    disp(approval.approved_command)
    disp('=== PREFLIGHT ===')
    disp(approval.Tpreflight)
    disp('=== CHECKS ===')
    disp(approval.Tchecks)
    disp('=== OUTPUT FILES ===')
    disp(approval.outMd)
    disp(approval.outTxt)
    disp(approval.outMat)

end

% =========================================================================
% Helpers
% =========================================================================

function [f, detail, status, errMsg] = local_eval_triobjective_v96n(x, mode)
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

function row = local_preflight_row_v96n(mode, x, f, detail, status, errMsg)
    row = struct();

    row.mode = string(mode);
    row.status = string(status);
    row.error_message = string(errMsg);

    row.m_max = x(1);
    row.T_min = x(2);
    row.r_div2 = x(3);
    row.t_rec_ini = x(4);

    row.nobj = numel(f);
    row.f1 = local_vec_get_v96n(f,1,NaN);
    row.f2 = local_vec_get_v96n(f,2,NaN);
    row.f3 = local_vec_get_v96n(f,3,NaN);

    row.detail_status = local_get_string_v96n(detail, {'status','detail_status','execution_status'}, "UNKNOWN");
    row.Q_aux_tot = local_get_numeric_v96n(detail, {'outputs.Q_aux_tot','Q_aux_tot'}, NaN);
    row.Irradiacion = local_get_numeric_v96n(detail, {'outputs.Irradiacion','Irradiacion'}, NaN);
    row.dry_time = local_get_numeric_v96n(detail, {'outputs.dry_time','dry_time'}, NaN);
    row.M = local_get_numeric_v96n(detail, {'outputs.M','M'}, NaN);
    row.CO2_total_kg = local_get_numeric_v96n(detail, {'CO2.CO2_total_kg'}, NaN);
    row.CO2_specific = local_get_numeric_v96n(detail, {'CO2.CO2_specific_kgCO2_per_kgwater'}, NaN);
    row.emission_factor_status = local_get_string_v96n(detail, {'CO2.emission_factor_status'}, "");
end

function row = local_source_row_v96n(item, filePath, pattern, passVal, evidence)
    row = struct();
    row.item = string(item);
    row.file = string(filePath);
    row.pattern = string(pattern);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end

function row = local_source_contains_v96n(item, filePath, pattern, evidenceIfFound)
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

    row = local_source_row_v96n(item, filePath, pattern, passVal, evidence);
end

function row = local_check_row_v96n(id, checkName, passVal, evidence, criterion)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
    row.criterion = string(criterion);
end

function val = local_vec_get_v96n(v, idx, defaultVal)
    if numel(v) >= idx
        val = v(idx);
    else
        val = defaultVal;
    end
end

function val = local_get_numeric_v96n(S, paths, defaultVal)
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

function val = local_get_string_v96n(S, paths, defaultVal)
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