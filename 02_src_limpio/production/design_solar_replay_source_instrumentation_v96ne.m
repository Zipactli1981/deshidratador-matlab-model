function design = design_solar_replay_source_instrumentation_v96ne()
% DESIGN_SOLAR_REPLAY_SOURCE_INSTRUMENTATION_v96ne
% 9.6n-e — SOLAR-REPLAY-SOURCE-INSTRUMENTATION-DESIGN-001
%
% Objetivo:
%   Diseñar la instrumentación mínima para obtener replay solar diurno:
%       tiempo
%       irradiancia
%       humedad/MR
%       energía solar o irradiación
%       CO2 operativo
%
% Este paso:
%   - NO ejecuta gamultiobj.
%   - NO modifica fuentes protegidas.
%   - NO corrige solar todavía.
%   - Inspecciona archivos fuente.
%   - Identifica firmas function.
%   - Busca candidatos de trayectoria.
%   - Define la ruta clonada para 9.6n-f.

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Cargar resultado 9.6n-d
    % ---------------------------------------------------------------------
    replayBaseDir = fullfile(rootDir,'05_runs','solar_daylight_one_day_replay_v96nd');

    if ~isfolder(replayBaseDir)
        error('No existe replayBaseDir: %s', replayBaseDir);
    end

    d = dir(replayBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'SOLAR_DAYLIGHT_ONE_DAY_REPLAY_v96nd_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró replay v96nd.');
    end

    [~,idxReplay] = max([d.datenum]);
    replayDirPrev = fullfile(replayBaseDir,d(idxReplay).name);
    replayMat = fullfile(replayDirPrev,'mat','SOLAR_DAYLIGHT_ONE_DAY_REPLAY_v96nd.mat');

    if ~isfile(replayMat)
        error('No existe MAT v96nd: %s', replayMat);
    end

    Sreplay = load(replayMat);

    if ~strcmp(string(Sreplay.diagnosis),"SOLAR_DAYLIGHT_ONE_DAY_REPLAY_REQUIRES_SOURCE_INSTRUMENTATION")
        error('9.6n-d no está en estado SOURCE_INSTRUMENTATION. Diagnosis: %s', string(Sreplay.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Archivos fuente a inspeccionar
    % ---------------------------------------------------------------------
    files = struct([]);

    files(end+1).id = "objective_v96j_fix1";
    files(end).path = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v96j_triobjective_CO2_fix1.m');
    files(end).role = "triobjective wrapper objective";

    files(end+1).id = "objective_v95j";
    files(end).path = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v95j_endpoint_TMAX_corrected.m');
    files(end).role = "validated two-objective endpoint objective";

    files(end+1).id = "wrapper_v18";
    files(end).path = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v18_endpoint_TMAX_corrected.m');
    files(end).role = "endpoint TMAX corrected wrapper";

    files(end+1).id = "wrapper_v17";
    files(end).path = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v17_nonphysical_penalty.m');
    files(end).role = "nonphysical penalty wrapper";

    files(end+1).id = "wrapper_v10";
    files(end).path = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v10_energy_mode_corrected.m');
    files(end).role = "energy mode corrected wrapper";

    files(end+1).id = "objective_v628b";
    files(end).path = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v628b_nonphysical_penalty.m');
    files(end).role = "older protected objective";

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    designBaseDir = fullfile(rootDir,'05_runs','solar_replay_source_instrumentation_design_v96ne');
    designDir = fullfile(designBaseDir,['SOLAR_REPLAY_SOURCE_INSTRUMENTATION_DESIGN_v96ne_' timestamp]);

    logsDir = fullfile(designDir,'logs');
    tablesDir = fullfile(designDir,'tables');
    matDir = fullfile(designDir,'mat');

    if ~isfolder(designBaseDir), mkdir(designBaseDir); end
    if ~isfolder(designDir), mkdir(designDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Inspección de fuentes
    % ---------------------------------------------------------------------
    srcRows = {};
    candidateRows = {};
    signatureRows = {};

    for i = 1:numel(files)
        fp = files(i).path;

        if isfile(fp)
            txt = fileread(fp);
            existsFlag = true;
        else
            txt = "";
            existsFlag = false;
        end

        sig = local_extract_function_signature_v96ne(txt);

        srcRow = struct();
        srcRow.id = files(i).id;
        srcRow.role = files(i).role;
        srcRow.file = string(fp);
        srcRow.exists = existsFlag;
        srcRow.n_chars = strlength(string(txt));
        srcRow.has_function_line = strlength(sig.function_line) > 0;
        srcRow.function_line = sig.function_line;
        srcRow.function_name = sig.function_name;
        srcRow.n_inputs_signature = sig.n_inputs;
        srcRow.n_outputs_signature = sig.n_outputs;
        srcRow.has_solar_string = contains(txt,'solar');
        srcRow.has_gasLP_string = contains(txt,'gasLP');
        srcRow.has_hybrid_string = contains(txt,'hybrid');
        srcRow.has_Irradiacion = contains(txt,'Irradiacion');
        srcRow.has_Q_aux_tot = contains(txt,'Q_aux_tot');
        srcRow.has_dry_time = contains(txt,'dry_time');
        srcRow.has_MR = contains(txt,'MR');
        srcRow.has_time_tokens = local_contains_any_v96ne(txt,["time","tiempo","hora","t_vec","tspan"]);
        srcRow.has_irradiance_tokens = local_contains_any_v96ne(txt,["Irr","Irradiacion","radiacion","radiation","G_t","solar"]);
        srcRow.has_moisture_tokens = local_contains_any_v96ne(txt,["MR","M","humedad","moisture","XR","Xw"]);
        srcRow.has_energy_tokens = local_contains_any_v96ne(txt,["Q_aux","energia","energy","E_","Irradiacion"]);
        srcRow.has_detail_assignment = contains(txt,'detail.');
        srcRow.has_outputs_struct = contains(txt,'outputs.');
        srcRow.has_penalty = contains(txt,'penalty');

        srcRows{end+1,1} = srcRow; %#ok<AGROW>

        sigRow = struct();
        sigRow.id = files(i).id;
        sigRow.file = string(fp);
        sigRow.function_line = sig.function_line;
        sigRow.has_function_line = strlength(sig.function_line) > 0;
        sigRow.function_name = sig.function_name;
        sigRow.inputs_raw = sig.inputs_raw;
        sigRow.outputs_raw = sig.outputs_raw;
        sigRow.n_inputs = sig.n_inputs;
        sigRow.n_outputs = sig.n_outputs;

        signatureRows{end+1,1} = sigRow; %#ok<AGROW>

        cand = local_find_candidate_lines_v96ne(txt, files(i).id);
        for j = 1:numel(cand)
            candidateRows{end+1,1} = cand(j); %#ok<AGROW>
        end
    end

    Tsource = struct2table(vertcat(srcRows{:}));
    Tsignatures = struct2table(vertcat(signatureRows{:}));

    if isempty(candidateRows)
        Tcandidates = table();
        Tcandidates.source_id = strings(0,1);
        Tcandidates.line_number = zeros(0,1);
        Tcandidates.category = strings(0,1);
        Tcandidates.line_text = strings(0,1);
    else
        Tcandidates = struct2table(vertcat(candidateRows{:}));
    end

    % ---------------------------------------------------------------------
    % Diseñar instrumentación
    % ---------------------------------------------------------------------
    proposed_function = "solar_daylight_one_day_replay_instrumented_v96nf";
    proposed_file = fullfile(rootDir,'02_src_limpio','production',proposed_function + ".m");

    reqRows = {};

    reqRows{end+1,1} = local_req_row_v96ne("R01","Clone-only implementation",true,"No modificar v10/v17/v18/v95j/v96j_fix1.");
    reqRows{end+1,1} = local_req_row_v96ne("R02","Expose trajectory",true,"detail.time, detail.irradiance, detail.MR_or_M, detail.energy_solar.");
    reqRows{end+1,1} = local_req_row_v96ne("R03","Solar day window",true,"Evaluar solo ventana con irradiancia útil o 08:00–18:00 como fallback.");
    reqRows{end+1,1} = local_req_row_v96ne("R04","No dry_time target for solar",true,"No usar horas nocturnas hasta MR objetivo.");
    reqRows{end+1,1} = local_req_row_v96ne("R05","CO2 accounting",true,"GLP=0; electricidad solo si existe ventilador/control.");
    reqRows{end+1,1} = local_req_row_v96ne("R06","Do not reintroduce solar in GA",true,"Solar queda fuera del frente formal.");
    reqRows{end+1,1} = local_req_row_v96ne("R07","Return table-compatible summary",true,"MR_end_daylight, water_removed_daylight, irradiation_daylight, CO2_total.");
    reqRows{end+1,1} = local_req_row_v96ne("R08","Abort if trajectory cannot be produced",true,"No inventar datos.");

    Trequirements = struct2table(vertcat(reqRows{:}));

    designRows = {};

    designRows{end+1,1} = local_design_row_v96ne( ...
        "P01", ...
        "Create instrumented replay function", ...
        proposed_file, ...
        "New file only. No overwrite of protected sources.");

    designRows{end+1,1} = local_design_row_v96ne( ...
        "P02", ...
        "Use available source inspection", ...
        "Tsource/Tcandidates", ...
        "Use candidate assignments for Irradiacion, Q_aux_tot, dry_time, M, MR if available.");

    designRows{end+1,1} = local_design_row_v96ne( ...
        "P03", ...
        "Fallback strategy", ...
        "If wrappers do not expose trajectory", ...
        "Create diagnostic stub that reports inability and does not fabricate solar results.");

    designRows{end+1,1} = local_design_row_v96ne( ...
        "P04", ...
        "Validation after creation", ...
        "run_solar_daylight_one_day_replay_instrumented_v96nf", ...
        "Must return time/irradiance/MR or explicitly fail with instrumentation_required.");

    Tdesign = struct2table(vertcat(designRows{:}));

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    protected_ok = all(Tsource.exists);

    has_signature_info = any(Tsignatures.has_function_line);
    has_candidate_info = height(Tcandidates) > 0;

    checks = {};

    checks{end+1,1} = local_check_row_v96ne( ...
        "E01", ...
        "Prior replay requires instrumentation", ...
        strcmp(string(Sreplay.diagnosis),"SOLAR_DAYLIGHT_ONE_DAY_REPLAY_REQUIRES_SOURCE_INSTRUMENTATION"), ...
        string(Sreplay.diagnosis), ...
        "9.6n-d must require source instrumentation.");

    checks{end+1,1} = local_check_row_v96ne( ...
        "E02", ...
        "Protected sources exist", ...
        protected_ok, ...
        sprintf("existing protected/source files=%d of %d", sum(Tsource.exists), height(Tsource)), ...
        "All inspected source files must exist.");

    checks{end+1,1} = local_check_row_v96ne( ...
        "E03", ...
        "Function signatures inspected", ...
        has_signature_info, ...
        sprintf("function signatures detected=%d", sum(Tsignatures.n_inputs >= 0 & Tsignatures.has_function_line)), ...
        "Instrumentation design must inspect actual signatures.");

    checks{end+1,1} = local_check_row_v96ne( ...
        "E04", ...
        "Candidate lines inspected", ...
        true, ...
        sprintf("candidate lines found=%d", height(Tcandidates)), ...
        "Design must search for trajectory/energy tokens.");

    checks{end+1,1} = local_check_row_v96ne( ...
        "E05", ...
        "Clone-only route defined", ...
        strlength(proposed_file) > 0, ...
        proposed_file, ...
        "Next implementation must create a new replay file only.");

    checks{end+1,1} = local_check_row_v96ne( ...
        "E06", ...
        "No GA executed", ...
        true, ...
        "This design script does not call gamultiobj.", ...
        "Solar replay design must not optimize.");

    Tchecks = struct2table(vertcat(checks{:}));

    design_pass = all(Tchecks.pass);

    if design_pass
        diagnosis = "SOLAR_REPLAY_SOURCE_INSTRUMENTATION_DESIGN_PASS";
        decision = "CREATE_CLONED_SOLAR_DAYLIGHT_REPLAY_INSTRUMENTED";
        next_step = "9.6n-f — CREATE-SOLAR-DAYLIGHT-INSTRUMENTED-REPLAY-001";
    else
        diagnosis = "SOLAR_REPLAY_SOURCE_INSTRUMENTATION_DESIGN_REQUIRES_REVIEW";
        decision = "REVIEW_SOURCE_SIGNATURES_BEFORE_IMPLEMENTATION";
        next_step = "Review failed checks.";
    end

    designFlags = struct();
    designFlags.prior_replay_v96nd_requires_instrumentation = strcmp(string(Sreplay.diagnosis),"SOLAR_DAYLIGHT_ONE_DAY_REPLAY_REQUIRES_SOURCE_INSTRUMENTATION");
    designFlags.no_GA_executed = true;
    designFlags.no_sources_modified = true;
    designFlags.protected_sources_exist = protected_ok;
    designFlags.function_signatures_inspected = has_signature_info;
    designFlags.candidate_lines_found = height(Tcandidates);
    designFlags.has_candidate_info = has_candidate_info;
    designFlags.clone_only_route_defined = true;
    designFlags.proposed_function = proposed_function;
    designFlags.proposed_file = string(proposed_file);
    designFlags.solar_kept_out_of_formal_GA = true;
    designFlags.CO2_factors_still_provisional = true;

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outSourceCsv = fullfile(tablesDir,'SOLAR_REPLAY_SOURCE_INSTRUMENTATION_DESIGN_v96ne_source_scan.csv');
    outSignaturesCsv = fullfile(tablesDir,'SOLAR_REPLAY_SOURCE_INSTRUMENTATION_DESIGN_v96ne_signatures.csv');
    outCandidatesCsv = fullfile(tablesDir,'SOLAR_REPLAY_SOURCE_INSTRUMENTATION_DESIGN_v96ne_candidate_lines.csv');
    outReqCsv = fullfile(tablesDir,'SOLAR_REPLAY_SOURCE_INSTRUMENTATION_DESIGN_v96ne_requirements.csv');
    outDesignCsv = fullfile(tablesDir,'SOLAR_REPLAY_SOURCE_INSTRUMENTATION_DESIGN_v96ne_design_plan.csv');
    outChecksCsv = fullfile(tablesDir,'SOLAR_REPLAY_SOURCE_INSTRUMENTATION_DESIGN_v96ne_checks.csv');

    writetable(Tsource,outSourceCsv);
    writetable(Tsignatures,outSignaturesCsv);
    writetable(Tcandidates,outCandidatesCsv);
    writetable(Trequirements,outReqCsv);
    writetable(Tdesign,outDesignCsv);
    writetable(Tchecks,outChecksCsv);

    outMd = fullfile(logsDir,'SOLAR_REPLAY_SOURCE_INSTRUMENTATION_DESIGN_v96ne.md');
    outTxt = fullfile(logsDir,'SOLAR_REPLAY_SOURCE_INSTRUMENTATION_DESIGN_v96ne.txt');
    outMat = fullfile(matDir,'SOLAR_REPLAY_SOURCE_INSTRUMENTATION_DESIGN_v96ne.mat');

    save(outMat, ...
        'diagnosis','decision','next_step','designFlags', ...
        'Tsource','Tsignatures','Tcandidates','Trequirements','Tdesign','Tchecks', ...
        'proposed_function','proposed_file','replayDirPrev','designDir', ...
        'outMd','outTxt','outMat','outSourceCsv','outSignaturesCsv','outCandidatesCsv','outReqCsv','outDesignCsv','outChecksCsv');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# SOLAR_REPLAY_SOURCE_INSTRUMENTATION_DESIGN_v96ne\n\n');
    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Decisión: `%s`\n\n', decision);
    fprintf(fid,'Siguiente paso: `%s`\n\n', next_step);

    fprintf(fid,'## Ruta propuesta\n\n');
    fprintf(fid,'Función propuesta:\n\n');
    fprintf(fid,'```text\n%s\n```\n\n', proposed_function);
    fprintf(fid,'Archivo propuesto:\n\n');
    fprintf(fid,'```text\n%s\n```\n\n', proposed_file);

    fprintf(fid,'## Firmas detectadas\n\n');
    fprintf(fid,'| id | function | inputs | outputs | line |\n');
    fprintf(fid,'|---|---|---:|---:|---|\n');

    for i = 1:height(Tsignatures)
        fprintf(fid,'| `%s` | `%s` | %d | %d | `%s` |\n', ...
            string(Tsignatures.id(i)), ...
            string(Tsignatures.function_name(i)), ...
            Tsignatures.n_inputs(i), ...
            Tsignatures.n_outputs(i), ...
            string(Tsignatures.function_line(i)));
    end

    fprintf(fid,'\n## Fuente inspeccionada\n\n');
    fprintf(fid,'| id | exists | solar | Irr | Q_aux | dry_time | MR | detail | outputs |\n');
    fprintf(fid,'|---|---:|---:|---:|---:|---:|---:|---:|---:|\n');

    for i = 1:height(Tsource)
        fprintf(fid,'| `%s` | %d | %d | %d | %d | %d | %d | %d | %d |\n', ...
            string(Tsource.id(i)), ...
            Tsource.exists(i), ...
            Tsource.has_solar_string(i), ...
            Tsource.has_Irradiacion(i), ...
            Tsource.has_Q_aux_tot(i), ...
            Tsource.has_dry_time(i), ...
            Tsource.has_MR(i), ...
            Tsource.has_detail_assignment(i), ...
            Tsource.has_outputs_struct(i));
    end

    fprintf(fid,'\n## Líneas candidatas encontradas\n\n');
    fprintf(fid,'| source | line | category | text |\n');
    fprintf(fid,'|---|---:|---|---|\n');

    maxLines = min(height(Tcandidates),80);
    for i = 1:maxLines
        fprintf(fid,'| `%s` | %d | `%s` | `%s` |\n', ...
            string(Tcandidates.source_id(i)), ...
            Tcandidates.line_number(i), ...
            string(Tcandidates.category(i)), ...
            local_md_escape_v96ne(string(Tcandidates.line_text(i))));
    end

    if height(Tcandidates) > maxLines
        fprintf(fid,'\nSe omitieron %d líneas candidatas adicionales en el MD; revisar CSV completo.\n\n', height(Tcandidates)-maxLines);
    end

    fprintf(fid,'\n## Requisitos\n\n');
    fprintf(fid,'| ID | Requisito | Obligatorio | Nota |\n');
    fprintf(fid,'|---|---|---:|---|\n');

    for i = 1:height(Trequirements)
        fprintf(fid,'| `%s` | %s | `%d` | %s |\n', ...
            string(Trequirements.id(i)), ...
            string(Trequirements.requirement(i)), ...
            Trequirements.required(i), ...
            string(Trequirements.note(i)));
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
    if design_pass
        fprintf(fid,'Se aprueba diseñar una ruta clonada de replay solar diurno. La implementación debe crear un archivo nuevo, no modificar fuentes protegidas, no ejecutar GA y no reintroducir solar en el frente formal.\n');
    else
        fprintf(fid,'No se aprueba todavía la implementación. Revisar checks fallidos.\n');
    end

    fclose(fid);

    % TXT
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'SOLAR-REPLAY-SOURCE-INSTRUMENTATION-DESIGN-001\n');
    fprintf(fid,'status: SOLAR_REPLAY_SOURCE_INSTRUMENTATION_DESIGN_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'decision: %s\n', decision);
    fprintf(fid,'next_step: %s\n', next_step);
    fprintf(fid,'prior_replay_v96nd_requires_instrumentation: %d\n', designFlags.prior_replay_v96nd_requires_instrumentation);
    fprintf(fid,'no_GA_executed: %d\n', designFlags.no_GA_executed);
    fprintf(fid,'no_sources_modified: %d\n', designFlags.no_sources_modified);
    fprintf(fid,'protected_sources_exist: %d\n', designFlags.protected_sources_exist);
    fprintf(fid,'function_signatures_inspected: %d\n', designFlags.function_signatures_inspected);
    fprintf(fid,'candidate_lines_found: %d\n', designFlags.candidate_lines_found);
    fprintf(fid,'clone_only_route_defined: %d\n', designFlags.clone_only_route_defined);
    fprintf(fid,'proposed_function: %s\n', designFlags.proposed_function);
    fprintf(fid,'proposed_file: %s\n', designFlags.proposed_file);
    fprintf(fid,'solar_kept_out_of_formal_GA: %d\n', designFlags.solar_kept_out_of_formal_GA);
    fprintf(fid,'CO2_factors_still_provisional: %d\n', designFlags.CO2_factors_still_provisional);
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Consola
    % ---------------------------------------------------------------------
    design = struct();
    design.status = 'SOLAR_REPLAY_SOURCE_INSTRUMENTATION_DESIGN_COMPLETED';
    design.diagnosis = diagnosis;
    design.decision = decision;
    design.next_step = next_step;
    design.designFlags = designFlags;
    design.Tsource = Tsource;
    design.Tsignatures = Tsignatures;
    design.Tcandidates = Tcandidates;
    design.Trequirements = Trequirements;
    design.Tdesign = Tdesign;
    design.Tchecks = Tchecks;
    design.designDir = designDir;
    design.outMd = outMd;
    design.outTxt = outTxt;
    design.outMat = outMat;

    disp('=== SOLAR_REPLAY_SOURCE_INSTRUMENTATION_DESIGN_v96ne ===')
    disp(design.status)
    disp('=== DIAGNOSIS ===')
    disp(design.diagnosis)
    disp('=== DECISION ===')
    disp(design.decision)
    disp('=== NEXT STEP ===')
    disp(design.next_step)
    disp('=== DESIGN FLAGS ===')
    disp(design.designFlags)
    disp('=== SIGNATURES ===')
    disp(design.Tsignatures)
    disp('=== SOURCE SCAN ===')
    disp(design.Tsource)
    disp('=== CANDIDATES ===')
    disp(design.Tcandidates)
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

function sig = local_extract_function_signature_v96ne(txt)
    sig = struct();
    sig.function_line = "";
    sig.function_name = "";
    sig.inputs_raw = "";
    sig.outputs_raw = "";
    sig.n_inputs = -1;
    sig.n_outputs = -1;

    if strlength(string(txt)) == 0
        return
    end

    lines = splitlines(string(txt));

    idx = find(startsWith(strtrim(lines),"function"),1,'first');

    if isempty(idx)
        return
    end

    line = strtrim(lines(idx));
    sig.function_line = line;

    expr = "^function\s+(?:(?<outputs>\[[^\]]+\]|\w+)\s*=\s*)?(?<name>\w+)\s*\((?<inputs>[^\)]*)\)";
    tok = regexp(char(line), expr, 'names', 'once');

    if isempty(tok)
        expr2 = "^function\s+(?<name>\w+)";
        tok2 = regexp(char(line), expr2, 'names', 'once');
        if ~isempty(tok2)
            sig.function_name = string(tok2.name);
        end
        return
    end

    sig.function_name = string(tok.name);

    if isfield(tok,'inputs')
        sig.inputs_raw = string(strtrim(tok.inputs));
        if strlength(sig.inputs_raw) == 0
            sig.n_inputs = 0;
        else
            sig.n_inputs = numel(split(sig.inputs_raw,","));
        end
    end

    if isfield(tok,'outputs') && ~isempty(tok.outputs)
        raw = string(strtrim(tok.outputs));
        sig.outputs_raw = raw;

        raw2 = erase(raw,"[");
        raw2 = erase(raw2,"]");
        raw2 = strtrim(raw2);

        if strlength(raw2) == 0
            sig.n_outputs = 0;
        else
            sig.n_outputs = numel(split(raw2,","));
        end
    else
        sig.n_outputs = 0;
    end
end

function yes = local_contains_any_v96ne(txt, tokens)
    yes = false;
    for i = 1:numel(tokens)
        if contains(txt,tokens(i))
            yes = true;
            return
        end
    end
end

function rows = local_find_candidate_lines_v96ne(txt, source_id)
    rows = struct('source_id',{},'line_number',{},'category',{},'line_text',{});

    if strlength(string(txt)) == 0
        return
    end

    lines = splitlines(string(txt));

    tokenGroups = struct();
    tokenGroups.time = ["time","tiempo","hora","t_vec","tspan","dry_time"];
    tokenGroups.irradiance = ["Irr","Irradiacion","radiacion","radiation","G_t","solar"];
    tokenGroups.moisture = ["MR","humedad","moisture","XR","Xw","M"];
    tokenGroups.energy = ["Q_aux","energia","energy","E_","Irradiacion"];
    tokenGroups.outputs = ["detail.","outputs.","out.","result.","hist.","trace."];

    cats = fieldnames(tokenGroups);

    for i = 1:numel(lines)
        l = string(lines(i));
        ls = lower(l);

        for c = 1:numel(cats)
            cat = string(cats{c});
            toks = tokenGroups.(cats{c});

            hit = false;
            for t = 1:numel(toks)
                if contains(ls, lower(toks(t)))
                    hit = true;
                    break
                end
            end

            if hit
                row = struct();
                row.source_id = string(source_id);
                row.line_number = i;
                row.category = cat;
                row.line_text = strtrim(l);
                rows(end+1) = row; %#ok<AGROW>
            end
        end
    end
end

function row = local_req_row_v96ne(id, requirement, required, note)
    row = struct();
    row.id = string(id);
    row.requirement = string(requirement);
    row.required = logical(required);
    row.note = string(note);
end

function row = local_design_row_v96ne(id, action, target, note)
    row = struct();
    row.id = string(id);
    row.action = string(action);
    row.target = string(target);
    row.note = string(note);
end

function row = local_check_row_v96ne(id, checkName, passVal, evidence, criterion)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
    row.criterion = string(criterion);
end

function s = local_md_escape_v96ne(s)
    s = replace(s,"|","\|");
    s = replace(s,"`","'");
end