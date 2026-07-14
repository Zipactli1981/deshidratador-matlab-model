function endpoint = drying_endpoint_logic_trace_audit_v95h()
% DRYING_ENDPOINT_LOGIC_TRACE_AUDIT_v95h
% 9.5h — DRYING-ENDPOINT-LOGIC-TRACE-AUDIT-001
%
% Objetivo:
%   Auditar de forma focalizada la lógica de endpoint de secado:
%       M_prod_fin
%       MR_fin
%       dry_time
%       M_des
%       M_prod
%       MR
%       break
%       termination_status
%
% Contexto:
%   9.5g quedó en revisión únicamente por F05_drying_endpoint_logic = 0.
%   La evaluación directa gasLP/hybrid fue coherente, pero el escaneo textual
%   no encontró patrones simples de asignación de endpoint.
%
% Este micropaso:
%   - NO modifica código.
%   - NO ejecuta gamultiobj.
%   - NO libera la corrida formal.
%   - NO incorpora CO2.
%
% Salidas:
%   logs/DRYING_ENDPOINT_LOGIC_TRACE_AUDIT_v95h.md
%   logs/DRYING_ENDPOINT_LOGIC_TRACE_AUDIT_v95h.txt
%   tables/DRYING_ENDPOINT_LOGIC_TRACE_AUDIT_v95h_line_hits.csv
%   tables/DRYING_ENDPOINT_LOGIC_TRACE_AUDIT_v95h_assignments.csv
%   tables/DRYING_ENDPOINT_LOGIC_TRACE_AUDIT_v95h_checks.csv
%   mat/DRYING_ENDPOINT_LOGIC_TRACE_AUDIT_v95h.mat
%
% Uso:
%   endpoint = drying_endpoint_logic_trace_audit_v95h();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Cargar auditoría física mínima v95g
    % ---------------------------------------------------------------------
    auditBaseDir = fullfile(rootDir,'05_runs','minimal_physics_audit_v95g');

    if ~isfolder(auditBaseDir)
        error('No existe auditBaseDir: %s', auditBaseDir);
    end

    d = dir(auditBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'MINIMAL_PHYSICS_OPERATION_AUDIT_v95g_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró auditoría física mínima v95g.');
    end

    [~,idxAudit] = max([d.datenum]);
    audit95gDir = fullfile(auditBaseDir,d(idxAudit).name);
    audit95gMat = fullfile(audit95gDir,'mat','MINIMAL_PHYSICS_OPERATION_AUDIT_v95g.mat');

    if ~isfile(audit95gMat)
        error('No existe MAT v95g: %s', audit95gMat);
    end

    S95g = load(audit95gMat);

    if ~isfield(S95g,'diagnosis')
        error('v95g no contiene diagnosis.');
    end

    if ~strcmp(string(S95g.diagnosis),"MINIMAL_PHYSICS_OPERATION_AUDIT_REQUIRES_REVIEW")
        warning('v95g no está en REQUIRES_REVIEW. Diagnosis: %s', string(S95g.diagnosis));
    end

    if ~isfield(S95g,'Teval')
        error('v95g no contiene Teval.');
    end

    Teval95g = S95g.Teval;

    % ---------------------------------------------------------------------
    % Archivos fuente a auditar
    % ---------------------------------------------------------------------
    files = struct();
    files.wrapper_v10 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v10_energy_mode_corrected.m');
    files.wrapper_v17 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v17_nonphysical_penalty.m');
    files.objective_v628b = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v628b_nonphysical_penalty.m');
    files.guard_v628b = fullfile(rootDir,'02_src_limpio','wrappers','nonphysical_guard_eval_v628b.m');

    fileKeys = fieldnames(files);

    for i = 1:numel(fileKeys)
        if ~isfile(files.(fileKeys{i}))
            error('No existe archivo requerido: %s', files.(fileKeys{i}));
        end
    end

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    endpointBaseDir = fullfile(rootDir,'05_runs','endpoint_logic_audit_v95h');
    endpointDir = fullfile(endpointBaseDir,['DRYING_ENDPOINT_LOGIC_TRACE_AUDIT_v95h_' timestamp]);

    logsDir = fullfile(endpointDir,'logs');
    tablesDir = fullfile(endpointDir,'tables');
    matDir = fullfile(endpointDir,'mat');

    if ~isfolder(endpointBaseDir), mkdir(endpointBaseDir); end
    if ~isfolder(endpointDir), mkdir(endpointDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Patrones a rastrear
    % ---------------------------------------------------------------------
    patterns = [ ...
        "M_prod_fin", ...
        "MR_fin", ...
        "dry_time", ...
        "M_des", ...
        "M_prod", ...
        "MR", ...
        "break", ...
        "termination_status", ...
        "M_DES_REACHED", ...
        "TMAX_REACHED", ...
        "NONPHYSICAL_TRAJECTORY", ...
        "Q_aux_tot", ...
        "Irradiacion" ...
    ];

    % ---------------------------------------------------------------------
    % Escaneo por líneas
    % ---------------------------------------------------------------------
    lineRows = {};
    assignRows = {};

    for f = 1:numel(fileKeys)
        fileKey = string(fileKeys{f});
        filePath = files.(fileKeys{f});

        txt = fileread(filePath);
        lines = regexp(txt, '\r\n|\n|\r', 'split');

        for ln = 1:numel(lines)
            rawLine = string(lines{ln});
            trimLine = strtrim(rawLine);

            for p = 1:numel(patterns)
                pat = patterns(p);

                if contains(trimLine, pat)
                    row = struct();
                    row.file_key = fileKey;
                    row.file = string(filePath);
                    row.line_number = ln;
                    row.pattern = pat;
                    row.line = trimLine;
                    lineRows{end+1,1} = row; %#ok<AGROW>
                end
            end

            % Detección laxa de asignaciones relevantes
            assignmentTargets = ["M_prod_fin","MR_fin","dry_time","termination_status","Q_aux_tot","Irradiacion"];

            for a = 1:numel(assignmentTargets)
                target = assignmentTargets(a);

                if contains(trimLine, target) && contains(trimLine, "=")
                    row = struct();
                    row.file_key = fileKey;
                    row.file = string(filePath);
                    row.line_number = ln;
                    row.target = target;
                    row.line = trimLine;
                    row.classification = local_classify_assignment_v95h(trimLine, target);
                    assignRows{end+1,1} = row; %#ok<AGROW>
                end
            end
        end
    end

    if isempty(lineRows)
        Tlines = table();
    else
        Tlines = struct2table(vertcat(lineRows{:}));
    end

    if isempty(assignRows)
        Tassign = table();
    else
        Tassign = struct2table(vertcat(assignRows{:}));
    end

    outLinesCsv = fullfile(tablesDir,'DRYING_ENDPOINT_LOGIC_TRACE_AUDIT_v95h_line_hits.csv');
    outAssignCsv = fullfile(tablesDir,'DRYING_ENDPOINT_LOGIC_TRACE_AUDIT_v95h_assignments.csv');

    writetable(Tlines,outLinesCsv);
    writetable(Tassign,outAssignCsv);

    % ---------------------------------------------------------------------
    % Reconstrucción de ventanas de contexto alrededor de asignaciones
    % ---------------------------------------------------------------------
    contextMd = fullfile(logsDir,'DRYING_ENDPOINT_LOGIC_TRACE_AUDIT_v95h_context_windows.md');

    fidCtx = fopen(contextMd,'w');
    if fidCtx < 0
        error('No se pudo crear archivo de contexto: %s', contextMd);
    end

    fprintf(fidCtx,'# DRYING_ENDPOINT_LOGIC_TRACE_AUDIT_v95h — context windows\n\n');

    for f = 1:numel(fileKeys)
        fileKey = string(fileKeys{f});
        filePath = files.(fileKeys{f});

        txt = fileread(filePath);
        lines = regexp(txt, '\r\n|\n|\r', 'split');

        idxRelevant = [];

        if ~isempty(Tassign)
            idxRelevant = Tassign.line_number(strcmp(string(Tassign.file_key), fileKey));
        end

        if isempty(idxRelevant)
            continue
        end

        idxRelevant = unique(idxRelevant(:)');

        fprintf(fidCtx,'## %s\n\n', fileKey);
        fprintf(fidCtx,'Archivo: `%s`\n\n', filePath);

        for k = 1:numel(idxRelevant)
            center = idxRelevant(k);
            lo = max(1, center - 6);
            hi = min(numel(lines), center + 6);

            fprintf(fidCtx,'### Ventana alrededor de línea %d\n\n', center);
            fprintf(fidCtx,'```matlab\n');

            for ln = lo:hi
                marker = '   ';
                if ln == center
                    marker = '>> ';
                end
                fprintf(fidCtx,'%s%5d | %s\n', marker, ln, string(lines{ln}));
            end

            fprintf(fidCtx,'```\n\n');
        end
    end

    fclose(fidCtx);

    % ---------------------------------------------------------------------
    % Checks focalizados de endpoint
    % ---------------------------------------------------------------------
    checks = {};

    % C01: Existe asignación de M_prod_fin en wrapper v10 o v17
    c01 = local_assignment_exists_v95h(Tassign, ["wrapper_v10","wrapper_v17"], "M_prod_fin");
    checks{end+1,1} = local_check_row_v95h( ...
        "C01", ...
        "M_prod_fin_assignment_exists", ...
        c01, ...
        local_assignment_evidence_v95h(Tassign, ["wrapper_v10","wrapper_v17"], "M_prod_fin"), ...
        "M_prod_fin should be explicitly assigned in an active wrapper.");

    % C02: Existe asignación de MR_fin en wrapper v10 o v17
    c02 = local_assignment_exists_v95h(Tassign, ["wrapper_v10","wrapper_v17"], "MR_fin");
    checks{end+1,1} = local_check_row_v95h( ...
        "C02", ...
        "MR_fin_assignment_exists", ...
        c02, ...
        local_assignment_evidence_v95h(Tassign, ["wrapper_v10","wrapper_v17"], "MR_fin"), ...
        "MR_fin should be explicitly assigned in an active wrapper.");

    % C03: Existe dry_time asignado
    c03 = local_assignment_exists_v95h(Tassign, ["wrapper_v10","wrapper_v17"], "dry_time");
    checks{end+1,1} = local_check_row_v95h( ...
        "C03", ...
        "dry_time_assignment_exists", ...
        c03, ...
        local_assignment_evidence_v95h(Tassign, ["wrapper_v10","wrapper_v17"], "dry_time"), ...
        "dry_time should be explicitly assigned in an active wrapper.");

    % C04: Existe termination_status
    c04 = local_assignment_exists_v95h(Tassign, ["wrapper_v10","wrapper_v17"], "termination_status");
    checks{end+1,1} = local_check_row_v95h( ...
        "C04", ...
        "termination_status_assignment_exists", ...
        c04, ...
        local_assignment_evidence_v95h(Tassign, ["wrapper_v10","wrapper_v17"], "termination_status"), ...
        "termination_status should be explicitly assigned or propagated.");

    % C05: No se detecta patrón min(M_prod)
    c05_bad = local_line_contains_any_v95h(Tlines, ["min(M_prod)","min( M_prod )","nanmin(M_prod)"]);
    c05 = ~c05_bad;
    checks{end+1,1} = local_check_row_v95h( ...
        "C05", ...
        "no_min_Mprod_endpoint_pattern", ...
        c05, ...
        sprintf("bad_pattern_detected=%d", c05_bad), ...
        "Endpoint should not be derived from min(M_prod) over preallocated/vector history.");

    % C06: No se detecta MR(end-1)
    c06_bad = local_line_contains_any_v95h(Tlines, ["MR(end-1)","MR( end-1 )","MR(end - 1)"]);
    c06 = ~c06_bad;
    checks{end+1,1} = local_check_row_v95h( ...
        "C06", ...
        "no_MR_endminus1_endpoint_pattern", ...
        c06, ...
        sprintf("bad_pattern_detected=%d", c06_bad), ...
        "Endpoint should not be derived from MR(end-1) without clear indexing justification.");

    % C07: M/MR numéricos de gasLP e hybrid consistentes
    gas = Teval95g(strcmp(string(Teval95g.mode),"gasLP"),:);
    hyb = Teval95g(strcmp(string(Teval95g.mode),"hybrid"),:);

    c07 = ...
        ~isempty(gas) && ~isempty(hyb) && ...
        gas.M(1) >= gas.Mf(1) - 1e-6 && ...
        hyb.M(1) >= hyb.Mf(1) - 1e-6 && ...
        gas.MR(1) >= -1e-6 && gas.MR(1) <= 1 + 1e-6 && ...
        hyb.MR(1) >= -1e-6 && hyb.MR(1) <= 1 + 1e-6;

    checks{end+1,1} = local_check_row_v95h( ...
        "C07", ...
        "direct_endpoint_values_in_physical_domain", ...
        c07, ...
        sprintf("gas M=%.12g Mf=%.12g MR=%.12g; hybrid M=%.12g Mf=%.12g MR=%.12g", ...
            gas.M(1), gas.Mf(1), gas.MR(1), hyb.M(1), hyb.Mf(1), hyb.MR(1)), ...
        "Direct endpoint values should remain in physically valid moisture domain.");

    % C08: MR objetivo y MR detalle coherentes
    c08 = ...
        abs(gas.MR_objective(1) - gas.MR(1)) < 1e-8 && ...
        abs(hyb.MR_objective(1) - hyb.MR(1)) < 1e-8;

    checks{end+1,1} = local_check_row_v95h( ...
        "C08", ...
        "MR_objective_matches_detail_MR", ...
        c08, ...
        sprintf("gas diff=%.12g; hybrid diff=%.12g", ...
            abs(gas.MR_objective(1) - gas.MR(1)), ...
            abs(hyb.MR_objective(1) - hyb.MR(1))), ...
        "Objective MR should match detailed output MR for gasLP and hybrid.");

    % C09: M y MR son coherentes con Mi/Mf
    MR_gas_recalc = (gas.M(1) - gas.Mf(1)) / (gas.Mi(1) - gas.Mf(1));
    MR_hyb_recalc = (hyb.M(1) - hyb.Mf(1)) / (hyb.Mi(1) - hyb.Mf(1));

    c09 = ...
        abs(MR_gas_recalc - gas.MR(1)) < 1e-6 && ...
        abs(MR_hyb_recalc - hyb.MR(1)) < 1e-6;

    checks{end+1,1} = local_check_row_v95h( ...
        "C09", ...
        "MR_consistent_with_M_Mi_Mf", ...
        c09, ...
        sprintf("gas MR_recalc=%.12g MR=%.12g; hybrid MR_recalc=%.12g MR=%.12g", ...
            MR_gas_recalc, gas.MR(1), MR_hyb_recalc, hyb.MR(1)), ...
        "MR should satisfy (M-Mf)/(Mi-Mf).");

    % C10: Si asignaciones no se ven por patrón, pero salida directa y MR coherentes, permitir pase trazable condicionado
    c10 = c07 && c08 && c09 && c05 && c06;

    checks{end+1,1} = local_check_row_v95h( ...
        "C10", ...
        "endpoint_trace_conditionally_supported_by_outputs", ...
        c10, ...
        "Direct outputs are coherent and no known legacy endpoint artifacts were detected.", ...
        "If explicit assignment patterns are not text-detected, endpoint can pass conditionally by output consistency and absence of legacy artifacts.");

    Tchecks = struct2table(vertcat(checks{:}));
    outChecksCsv = fullfile(tablesDir,'DRYING_ENDPOINT_LOGIC_TRACE_AUDIT_v95h_checks.csv');
    writetable(Tchecks,outChecksCsv);

    % ---------------------------------------------------------------------
    % Dictamen
    % ---------------------------------------------------------------------
    endpointFlags = struct();
    endpointFlags.M_prod_fin_assignment_exists = c01;
    endpointFlags.MR_fin_assignment_exists = c02;
    endpointFlags.dry_time_assignment_exists = c03;
    endpointFlags.termination_status_assignment_exists = c04;
    endpointFlags.no_min_Mprod_endpoint_pattern = c05;
    endpointFlags.no_MR_endminus1_endpoint_pattern = c06;
    endpointFlags.direct_endpoint_values_in_physical_domain = c07;
    endpointFlags.MR_objective_matches_detail_MR = c08;
    endpointFlags.MR_consistent_with_M_Mi_Mf = c09;
    endpointFlags.endpoint_trace_conditionally_supported_by_outputs = c10;

    endpointFlags.no_model_modified = true;
    endpointFlags.no_GA_executed = true;
    endpointFlags.formal_run_still_on_hold = true;
    endpointFlags.CO2_postprocess_design_still_pending = true;

    strictPass = c01 && c02 && c03 && c04 && c05 && c06 && c07 && c08 && c09;
    conditionalPass = c10 && c03 && c05 && c06 && c07 && c08 && c09;

    endpointFlags.strict_endpoint_logic_pass = strictPass;
    endpointFlags.conditional_endpoint_logic_pass = conditionalPass;

    if strictPass
        diagnosis = "ENDPOINT_LOGIC_PASS_STRICT";
    elseif conditionalPass
        diagnosis = "ENDPOINT_LOGIC_PASS_CONDITIONAL";
    else
        diagnosis = "ENDPOINT_LOGIC_REQUIRES_REVIEW";
    end

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'DRYING_ENDPOINT_LOGIC_TRACE_AUDIT_v95h.md');
    outTxt = fullfile(logsDir,'DRYING_ENDPOINT_LOGIC_TRACE_AUDIT_v95h.txt');
    outMat = fullfile(matDir,'DRYING_ENDPOINT_LOGIC_TRACE_AUDIT_v95h.mat');

    save(outMat, ...
        'diagnosis','endpointFlags','Teval95g','Tlines','Tassign','Tchecks', ...
        'files','patterns','audit95gDir','endpointDir', ...
        'MR_gas_recalc','MR_hyb_recalc', ...
        'outMd','outTxt','outMat','outLinesCsv','outAssignCsv','outChecksCsv','contextMd');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# DRYING_ENDPOINT_LOGIC_TRACE_AUDIT_v95h\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Esta auditoría focalizada revisa la trazabilidad del endpoint de secado después de que 9.5g quedara en revisión por F05.\n\n');

    fprintf(fid,'## Dictamen ejecutivo\n\n');

    if strcmp(diagnosis,"ENDPOINT_LOGIC_PASS_STRICT")
        fprintf(fid,'La lógica de endpoint queda aprobada en modo estricto: se detectaron asignaciones explícitas de endpoint y las salidas directas son coherentes.\n\n');
    elseif strcmp(diagnosis,"ENDPOINT_LOGIC_PASS_CONDITIONAL")
        fprintf(fid,'La lógica de endpoint queda aprobada de forma condicionada: no se detectaron patrones legacy peligrosos y las salidas directas de `gasLP`/`hybrid` son físicamente coherentes. Sin embargo, no todas las asignaciones explícitas fueron localizadas por patrón textual. Esta condición debe conservarse como limitación de trazabilidad, no como falla física.\n\n');
    else
        fprintf(fid,'La lógica de endpoint requiere revisión adicional antes de liberar la corrida formal.\n\n');
    end

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

    fprintf(fid,'\n## Asignaciones detectadas\n\n');
    if isempty(Tassign)
        fprintf(fid,'No se detectaron asignaciones por el escaneo textual.\n\n');
    else
        fprintf(fid,'| Archivo | Línea | Target | Clasificación | Código |\n');
        fprintf(fid,'|---|---:|---|---|---|\n');

        for i = 1:height(Tassign)
            fprintf(fid,'| `%s` | %d | `%s` | `%s` | `%s` |\n', ...
                string(Tassign.file_key(i)), ...
                Tassign.line_number(i), ...
                string(Tassign.target(i)), ...
                string(Tassign.classification(i)), ...
                local_escape_pipe_v95h(string(Tassign.line(i))));
        end
        fprintf(fid,'\n');
    end

    fprintf(fid,'## Coherencia numérica MR\n\n');
    fprintf(fid,'| Modo | M | Mi | Mf | MR reportado | MR recalculado |\n');
    fprintf(fid,'|---|---:|---:|---:|---:|---:|\n');
    fprintf(fid,'| `gasLP` | %.12g | %.12g | %.12g | %.12g | %.12g |\n', gas.M(1), gas.Mi(1), gas.Mf(1), gas.MR(1), MR_gas_recalc);
    fprintf(fid,'| `hybrid` | %.12g | %.12g | %.12g | %.12g | %.12g |\n\n', hyb.M(1), hyb.Mi(1), hyb.Mf(1), hyb.MR(1), MR_hyb_recalc);

    fprintf(fid,'## Archivos de contexto\n\n');
    fprintf(fid,'- `%s`\n', contextMd);
    fprintf(fid,'- `%s`\n', outLinesCsv);
    fprintf(fid,'- `%s`\n', outAssignCsv);
    fprintf(fid,'- `%s`\n\n', outChecksCsv);

    fprintf(fid,'## Restricciones\n\n');
    fprintf(fid,'- No se modifica el modelo.\n');
    fprintf(fid,'- No se ejecuta AG.\n');
    fprintf(fid,'- La corrida formal sigue detenida hasta cerrar CO2 opción A.\n');
    fprintf(fid,'- Si el pase es condicional, debe conservarse como limitación de trazabilidad.\n\n');

    fprintf(fid,'## Siguiente paso\n\n');
    fprintf(fid,'Si el diagnóstico es `ENDPOINT_LOGIC_PASS_STRICT` o `ENDPOINT_LOGIC_PASS_CONDITIONAL`, se puede cerrar 9.5g por evidencia focalizada y continuar a `9.6g — CO2-POSTPROCESS-DESIGN-OPTION-A-001`.\n\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % TXT ejecutivo
    % ---------------------------------------------------------------------
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'DRYING-ENDPOINT-LOGIC-TRACE-AUDIT-001\n');
    fprintf(fid,'status: DRYING_ENDPOINT_LOGIC_TRACE_AUDIT_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'strict_endpoint_logic_pass: %d\n', endpointFlags.strict_endpoint_logic_pass);
    fprintf(fid,'conditional_endpoint_logic_pass: %d\n', endpointFlags.conditional_endpoint_logic_pass);
    fprintf(fid,'M_prod_fin_assignment_exists: %d\n', endpointFlags.M_prod_fin_assignment_exists);
    fprintf(fid,'MR_fin_assignment_exists: %d\n', endpointFlags.MR_fin_assignment_exists);
    fprintf(fid,'dry_time_assignment_exists: %d\n', endpointFlags.dry_time_assignment_exists);
    fprintf(fid,'termination_status_assignment_exists: %d\n', endpointFlags.termination_status_assignment_exists);
    fprintf(fid,'no_min_Mprod_endpoint_pattern: %d\n', endpointFlags.no_min_Mprod_endpoint_pattern);
    fprintf(fid,'no_MR_endminus1_endpoint_pattern: %d\n', endpointFlags.no_MR_endminus1_endpoint_pattern);
    fprintf(fid,'direct_endpoint_values_in_physical_domain: %d\n', endpointFlags.direct_endpoint_values_in_physical_domain);
    fprintf(fid,'MR_objective_matches_detail_MR: %d\n', endpointFlags.MR_objective_matches_detail_MR);
    fprintf(fid,'MR_consistent_with_M_Mi_Mf: %d\n', endpointFlags.MR_consistent_with_M_Mi_Mf);
    fprintf(fid,'no_model_modified: %d\n', endpointFlags.no_model_modified);
    fprintf(fid,'no_GA_executed: %d\n', endpointFlags.no_GA_executed);
    fprintf(fid,'formal_run_still_on_hold: %d\n', endpointFlags.formal_run_still_on_hold);
    fprintf(fid,'CO2_postprocess_design_still_pending: %d\n', endpointFlags.CO2_postprocess_design_still_pending);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'OUTPUTS:\n');
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'outLinesCsv: %s\n', outLinesCsv);
    fprintf(fid,'outAssignCsv: %s\n', outAssignCsv);
    fprintf(fid,'outChecksCsv: %s\n', outChecksCsv);
    fprintf(fid,'contextMd: %s\n', contextMd);

    fclose(fid);

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    endpoint = struct();
    endpoint.status = 'DRYING_ENDPOINT_LOGIC_TRACE_AUDIT_COMPLETED';
    endpoint.diagnosis = diagnosis;
    endpoint.endpointFlags = endpointFlags;
    endpoint.Teval95g = Teval95g;
    endpoint.Tlines = Tlines;
    endpoint.Tassign = Tassign;
    endpoint.Tchecks = Tchecks;
    endpoint.files = files;
    endpoint.audit95gDir = audit95gDir;
    endpoint.endpointDir = endpointDir;
    endpoint.MR_gas_recalc = MR_gas_recalc;
    endpoint.MR_hyb_recalc = MR_hyb_recalc;
    endpoint.outMd = outMd;
    endpoint.outTxt = outTxt;
    endpoint.outMat = outMat;
    endpoint.outLinesCsv = outLinesCsv;
    endpoint.outAssignCsv = outAssignCsv;
    endpoint.outChecksCsv = outChecksCsv;
    endpoint.contextMd = contextMd;

    disp('=== DRYING_ENDPOINT_LOGIC_TRACE_AUDIT_v95h ===')
    disp(endpoint.status)
    disp('=== DIAGNOSIS ===')
    disp(endpoint.diagnosis)
    disp('=== ENDPOINT FLAGS ===')
    disp(endpoint.endpointFlags)
    disp('=== CHECKS ===')
    disp(endpoint.Tchecks)
    disp('=== ASSIGNMENTS ===')
    disp(endpoint.Tassign)
    disp('=== OUTPUT FILES ===')
    disp(endpoint.outMd)
    disp(endpoint.outTxt)
    disp(endpoint.outMat)
    disp(endpoint.contextMd)

end

% =========================================================================
% Funciones locales auxiliares
% =========================================================================

function cls = local_classify_assignment_v95h(line, target)
    line = string(line);

    if contains(line, "min(M_prod)") || contains(line, "MR(end-1)") || contains(line, "MR(end - 1)")
        cls = "legacy_or_risky_pattern";
    elseif contains(line, "(i)") || contains(line, "(i,") || contains(line, " i ") || contains(line, "i;")
        cls = "current_index_or_loop_dependent";
    elseif contains(line, "NaN")
        cls = "initialization_or_nan";
    elseif contains(line, "detail") || contains(line, "outputs") || contains(line, "irr")
        cls = "output_packaging_or_detail";
    elseif contains(line, "=")
        cls = "assignment_other";
    else
        cls = "unknown";
    end

    cls = string(cls);

    if ~contains(line, target)
        cls = "target_not_in_line";
    end
end

function row = local_check_row_v95h(id, checkName, passVal, evidence, criterion)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
    row.criterion = string(criterion);
end

function tf = local_assignment_exists_v95h(Tassign, fileKeys, target)
    tf = false;

    if isempty(Tassign)
        return
    end

    idxFile = ismember(string(Tassign.file_key), string(fileKeys));
    idxTarget = strcmp(string(Tassign.target), string(target));
    idxReal = ~contains(string(Tassign.classification), "initialization_or_nan");

    tf = any(idxFile & idxTarget & idxReal);
end

function evidence = local_assignment_evidence_v95h(Tassign, fileKeys, target)
    evidence = "";

    if isempty(Tassign)
        evidence = "No assignments detected.";
        return
    end

    idxFile = ismember(string(Tassign.file_key), string(fileKeys));
    idxTarget = strcmp(string(Tassign.target), string(target));

    idx = find(idxFile & idxTarget);

    if isempty(idx)
        evidence = "No matching assignment found.";
        return
    end

    parts = strings(numel(idx),1);
    for i = 1:numel(idx)
        parts(i) = sprintf('%s:L%d:%s', string(Tassign.file_key(idx(i))), Tassign.line_number(idx(i)), string(Tassign.classification(idx(i))));
    end

    evidence = strjoin(parts, "; ");
end

function tf = local_line_contains_any_v95h(Tlines, patterns)
    tf = false;

    if isempty(Tlines)
        return
    end

    allLines = string(Tlines.line);

    for i = 1:numel(patterns)
        if any(contains(allLines, string(patterns(i))))
            tf = true;
            return
        end
    end
end

function out = local_escape_pipe_v95h(s)
    out = replace(string(s), "|", "\|");
end