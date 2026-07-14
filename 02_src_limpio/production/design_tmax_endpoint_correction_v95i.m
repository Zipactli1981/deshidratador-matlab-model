function design = design_tmax_endpoint_correction_v95i()
% DESIGN_TMAX_ENDPOINT_CORRECTION_v95i
% 9.5i — TMAX-ENDPOINT-CORRECTION-DESIGN-001
%
% Objetivo:
%   Diseñar una corrección mínima y trazable para la rama TMAX_REACHED,
%   sin modificar todavía los wrappers activos.
%
% Contexto:
%   9.5h detectó que existen asignaciones correctas de endpoint:
%       M_prod_fin = M_prod(i);
%       MR_fin     = MR(i);
%
%   pero también existen patrones legacy/riesgosos en TMAX:
%       M_prod_fin = min(M_prod);
%       MR_fin     = MR(end-1);
%
%   Además, MR reportado no coincidió exactamente con:
%       MR = (M - Mf)/(Mi - Mf)
%
% Este micropaso:
%   - NO modifica v10.
%   - NO modifica v17.
%   - NO crea todavía v18.
%   - NO modifica la función objetivo.
%   - NO ejecuta gamultiobj.
%   - NO libera corrida formal.
%   - Solo diseña la corrección y sus criterios de validación.
%
% Salidas:
%   logs/TMAX_ENDPOINT_CORRECTION_DESIGN_v95i.md
%   logs/TMAX_ENDPOINT_CORRECTION_DESIGN_v95i.txt
%   tables/TMAX_ENDPOINT_CORRECTION_DESIGN_v95i_patch_plan.csv
%   tables/TMAX_ENDPOINT_CORRECTION_DESIGN_v95i_validation_plan.csv
%   tables/TMAX_ENDPOINT_CORRECTION_DESIGN_v95i_risks.csv
%   mat/TMAX_ENDPOINT_CORRECTION_DESIGN_v95i.mat
%
% Uso:
%   design = design_tmax_endpoint_correction_v95i();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Cargar auditoría endpoint v95h
    % ---------------------------------------------------------------------
    endpointBaseDir = fullfile(rootDir,'05_runs','endpoint_logic_audit_v95h');

    if ~isfolder(endpointBaseDir)
        error('No existe endpointBaseDir: %s', endpointBaseDir);
    end

    d = dir(endpointBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'DRYING_ENDPOINT_LOGIC_TRACE_AUDIT_v95h_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró auditoría endpoint v95h.');
    end

    [~,idxEndpoint] = max([d.datenum]);
    endpointDir = fullfile(endpointBaseDir,d(idxEndpoint).name);
    endpointMat = fullfile(endpointDir,'mat','DRYING_ENDPOINT_LOGIC_TRACE_AUDIT_v95h.mat');

    if ~isfile(endpointMat)
        error('No existe MAT v95h: %s', endpointMat);
    end

    S95h = load(endpointMat);

    if ~isfield(S95h,'diagnosis')
        error('v95h no contiene diagnosis.');
    end

    if ~strcmp(string(S95h.diagnosis),"ENDPOINT_LOGIC_REQUIRES_REVIEW")
        warning('v95h no está en ENDPOINT_LOGIC_REQUIRES_REVIEW. Diagnosis: %s', string(S95h.diagnosis));
    end

    if ~isfield(S95h,'endpointFlags') || ~isfield(S95h,'Tassign') || ~isfield(S95h,'Tchecks')
        error('v95h no contiene endpointFlags, Tassign o Tchecks.');
    end

    endpointFlags = S95h.endpointFlags;
    Tassign = S95h.Tassign;
    Tchecks95h = S95h.Tchecks;
    Teval95g = S95h.Teval95g;

    % ---------------------------------------------------------------------
    % Cargar auditoría física mínima v95g
    % ---------------------------------------------------------------------
    auditBaseDir = fullfile(rootDir,'05_runs','minimal_physics_audit_v95g');

    if ~isfolder(auditBaseDir)
        error('No existe auditBaseDir: %s', auditBaseDir);
    end

    d2 = dir(auditBaseDir);
    d2 = d2([d2.isdir]);
    d2 = d2(~ismember({d2.name},{'.','..','.MATLABDriveTag'}));

    keep2 = false(size(d2));
    for i = 1:numel(d2)
        keep2(i) = startsWith(d2(i).name,'MINIMAL_PHYSICS_OPERATION_AUDIT_v95g_');
    end
    d2 = d2(keep2);

    if isempty(d2)
        error('No se encontró auditoría física mínima v95g.');
    end

    [~,idxAudit] = max([d2.datenum]);
    audit95gDir = fullfile(auditBaseDir,d2(idxAudit).name);
    audit95gMat = fullfile(audit95gDir,'mat','MINIMAL_PHYSICS_OPERATION_AUDIT_v95g.mat');

    if ~isfile(audit95gMat)
        error('No existe MAT v95g: %s', audit95gMat);
    end

    S95g = load(audit95gMat);

    % ---------------------------------------------------------------------
    % Archivos fuente base
    % ---------------------------------------------------------------------
    wrapper_v17 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v17_nonphysical_penalty.m');
    objective_v628b = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v628b_nonphysical_penalty.m');

    if ~isfile(wrapper_v17)
        error('No existe wrapper v17: %s', wrapper_v17);
    end

    if ~isfile(objective_v628b)
        error('No existe objective v628b: %s', objective_v628b);
    end

    proposed_wrapper_v18 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v18_endpoint_TMAX_corrected.m');
    proposed_objective_v95j = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v95j_endpoint_TMAX_corrected.m');

    % ---------------------------------------------------------------------
    % Carpeta de diseño
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    designBaseDir = fullfile(rootDir,'05_runs','tmax_endpoint_correction_design_v95i');
    designDir = fullfile(designBaseDir,['TMAX_ENDPOINT_CORRECTION_DESIGN_v95i_' timestamp]);

    logsDir = fullfile(designDir,'logs');
    tablesDir = fullfile(designDir,'tables');
    matDir = fullfile(designDir,'mat');

    if ~isfolder(designBaseDir), mkdir(designBaseDir); end
    if ~isfolder(designDir), mkdir(designDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Evidencia resumida de v95h
    % ---------------------------------------------------------------------
    gas = Teval95g(strcmp(string(Teval95g.mode),"gasLP"),:);
    hyb = Teval95g(strcmp(string(Teval95g.mode),"hybrid"),:);

    if isempty(gas) || isempty(hyb)
        error('Teval95g no contiene filas gasLP e hybrid.');
    end

    MR_gas_recalc = (gas.M(1) - gas.Mf(1)) / (gas.Mi(1) - gas.Mf(1));
    MR_hyb_recalc = (hyb.M(1) - hyb.Mf(1)) / (hyb.Mi(1) - hyb.Mf(1));

    MR_gas_diff = gas.MR(1) - MR_gas_recalc;
    MR_hyb_diff = hyb.MR(1) - MR_hyb_recalc;

    % ---------------------------------------------------------------------
    % Plan de parche
    % ---------------------------------------------------------------------
    patchRows = {};

    row = struct();
    row.step = "P01";
    row.action = "Clone wrapper v17 to v18";
    row.source_file = string(wrapper_v17);
    row.target_file = string(proposed_wrapper_v18);
    row.change_type = "new_clone";
    row.required = true;
    row.description = "Create a new wrapper clone to preserve v17 as historical guarded wrapper.";
    patchRows{end+1,1} = row;

    row = struct();
    row.step = "P02";
    row.action = "Replace TMAX endpoint M assignment";
    row.source_file = string(proposed_wrapper_v18);
    row.target_file = string(proposed_wrapper_v18);
    row.change_type = "minimal_endpoint_patch";
    row.required = true;
    row.description = "In TMAX_REACHED branch, replace M_prod_fin=min(M_prod) with M_prod_fin=M_prod(i).";
    patchRows{end+1,1} = row;

    row = struct();
    row.step = "P03";
    row.action = "Replace TMAX endpoint MR assignment";
    row.source_file = string(proposed_wrapper_v18);
    row.target_file = string(proposed_wrapper_v18);
    row.change_type = "minimal_endpoint_patch";
    row.required = true;
    row.description = "In TMAX_REACHED branch, replace MR_fin=MR(end-1) with MR_fin=MR(i) or recalculated MR_fin=(M_prod_fin-Mf)/(Mi-Mf).";
    patchRows{end+1,1} = row;

    row = struct();
    row.step = "P04";
    row.action = "Prefer recalculated MR after M_prod_fin";
    row.source_file = string(proposed_wrapper_v18);
    row.target_file = string(proposed_wrapper_v18);
    row.change_type = "consistency_patch";
    row.required = true;
    row.description = "To remove index ambiguity, compute MR_fin=(M_prod_fin-Mf)/(Mi-Mf) after assigning M_prod_fin.";
    patchRows{end+1,1} = row;

    row = struct();
    row.step = "P05";
    row.action = "Keep M_DES_REACHED branch current-index based";
    row.source_file = string(proposed_wrapper_v18);
    row.target_file = string(proposed_wrapper_v18);
    row.change_type = "protect_existing_correct_logic";
    row.required = true;
    row.description = "Preserve M_prod_fin=M_prod(i), dry_time=t(i)/3600-t_ini, and current-index endpoint when M_des is reached.";
    patchRows{end+1,1} = row;

    row = struct();
    row.step = "P06";
    row.action = "Preserve NONPHYSICAL_TRAJECTORY penalty";
    row.source_file = string(proposed_wrapper_v18);
    row.target_file = string(proposed_wrapper_v18);
    row.change_type = "protect_guard_logic";
    row.required = true;
    row.description = "Do not alter physical guard behavior or solar penalty logic.";
    patchRows{end+1,1} = row;

    row = struct();
    row.step = "P07";
    row.action = "Clone objective v628b to v95j";
    row.source_file = string(objective_v628b);
    row.target_file = string(proposed_objective_v95j);
    row.change_type = "new_clone";
    row.required = true;
    row.description = "Create objective clone that calls wrapper v18 instead of v17.";
    patchRows{end+1,1} = row;

    row = struct();
    row.step = "P08";
    row.action = "Add endpoint correction metadata";
    row.source_file = string(proposed_objective_v95j);
    row.target_file = string(proposed_objective_v95j);
    row.change_type = "instrumentation_metadata";
    row.required = true;
    row.description = "Mark objective as endpoint-TMAX-corrected for traceability.";
    patchRows{end+1,1} = row;

    Tpatch = struct2table(vertcat(patchRows{:}));

    % ---------------------------------------------------------------------
    % Diseño de sustituciones esperadas
    % ---------------------------------------------------------------------
    replacementRows = {};

    row = struct();
    row.id = "R01";
    row.scope = "TMAX_REACHED branch";
    row.find_pattern = "M_prod_fin=min(M_prod);";
    row.replace_with = "M_prod_fin=M_prod(i);";
    row.required = true;
    row.note = "Use current integration index instead of vector minimum.";
    replacementRows{end+1,1} = row;

    row = struct();
    row.id = "R02";
    row.scope = "TMAX_REACHED branch";
    row.find_pattern = "MR_fin=MR(end-1);";
    row.replace_with = "MR_fin=(M_prod_fin-Mf)/(Mi-Mf);";
    row.required = true;
    row.note = "Prefer recalculated MR from final moisture to remove index shift.";
    replacementRows{end+1,1} = row;

    row = struct();
    row.id = "R03";
    row.scope = "TMAX_REACHED branch";
    row.find_pattern = "dry_time=t(i)/3600-t_ini;";
    row.replace_with = "dry_time=t(i)/3600-t_ini;";
    row.required = false;
    row.note = "Keep existing current-index dry_time.";
    replacementRows{end+1,1} = row;

    row = struct();
    row.id = "R04";
    row.scope = "Objective wrapper call";
    row.find_pattern = "opt_tunel_mod2_v17_nonphysical_penalty";
    row.replace_with = "opt_tunel_mod2_v18_endpoint_TMAX_corrected";
    row.required = true;
    row.note = "Objective clone must call v18, not modify v628b.";
    replacementRows{end+1,1} = row;

    Treplacements = struct2table(vertcat(replacementRows{:}));

    % ---------------------------------------------------------------------
    % Plan de validación
    % ---------------------------------------------------------------------
    validationRows = {};

    row = struct();
    row.id = "V01";
    row.validation = "Direct evaluation gasLP";
    row.required_result = "OK, non-penalized, finite M, finite MR, finite cost.";
    row.blocks_formal_run = true;
    validationRows{end+1,1} = row;

    row = struct();
    row.id = "V02";
    row.validation = "Direct evaluation hybrid";
    row.required_result = "OK, non-penalized, Irradiacion > 0, finite M, finite MR, finite cost.";
    row.blocks_formal_run = true;
    validationRows{end+1,1} = row;

    row = struct();
    row.id = "V03";
    row.validation = "Direct evaluation solar";
    row.required_result = "Penalized as INVALID_COST/NONPHYSICAL_TRAJECTORY; no solar performance claim.";
    row.blocks_formal_run = true;
    validationRows{end+1,1} = row;

    row = struct();
    row.id = "V04";
    row.validation = "MR consistency";
    row.required_result = "For gasLP and hybrid, abs(MR - (M-Mf)/(Mi-Mf)) < 1e-8.";
    row.blocks_formal_run = true;
    validationRows{end+1,1} = row;

    row = struct();
    row.id = "V05";
    row.validation = "TMAX endpoint logic";
    row.required_result = "TMAX_REACHED branch uses M_prod(i) and recalculated MR; no active min(M_prod) or MR(end-1).";
    row.blocks_formal_run = true;
    validationRows{end+1,1} = row;

    row = struct();
    row.id = "V06";
    row.validation = "Comparative physical sanity";
    row.required_result = "Hybrid keeps comparable drying time/MR and reduces Q_aux relative to gasLP for selected solution.";
    row.blocks_formal_run = true;
    validationRows{end+1,1} = row;

    row = struct();
    row.id = "V07";
    row.validation = "No source overwrite";
    row.required_result = "v10, v17 and v628b remain unchanged; v18 and v95j are new files.";
    row.blocks_formal_run = true;
    validationRows{end+1,1} = row;

    row = struct();
    row.id = "V08";
    row.validation = "Smoke recheck with corrected objective";
    row.required_result = "Small direct or micro-smoke test passes before formal run.";
    row.blocks_formal_run = true;
    validationRows{end+1,1} = row;

    Tvalidation = struct2table(vertcat(validationRows{:}));

    % ---------------------------------------------------------------------
    % Riesgos y decisiones
    % ---------------------------------------------------------------------
    riskRows = {};

    row = struct();
    row.risk = "Endpoint correction changes objective values";
    row.level = "expected";
    row.mitigation = "Treat v18/v95j results as corrected, not directly identical to v17/v628b.";
    riskRows{end+1,1} = row;

    row = struct();
    row.risk = "Large GA results would be invalid if run before correction";
    row.level = "high";
    row.mitigation = "Keep formal run blocked until v95j direct validation passes.";
    riskRows{end+1,1} = row;

    row = struct();
    row.risk = "Patch accidentally changes non-TMAX branch";
    row.level = "medium";
    row.mitigation = "Use targeted replacements and verify M_DES_REACHED branch remains current-index.";
    riskRows{end+1,1} = row;

    row = struct();
    row.risk = "CO2 still absent";
    row.level = "medium";
    row.mitigation = "Continue to CO2 option A after endpoint correction validates.";
    riskRows{end+1,1} = row;

    row = struct();
    row.risk = "Solar branch remains invalid";
    row.level = "known_limit";
    row.mitigation = "Keep solar excluded; do not reintroduce until separate branch review.";
    riskRows{end+1,1} = row;

    Trisks = struct2table(vertcat(riskRows{:}));

    % ---------------------------------------------------------------------
    % Flags de diseño
    % ---------------------------------------------------------------------
    designFlags = struct();
    designFlags.v95h_requires_review = strcmp(string(S95h.diagnosis),"ENDPOINT_LOGIC_REQUIRES_REVIEW");
    designFlags.legacy_min_Mprod_detected = ~endpointFlags.no_min_Mprod_endpoint_pattern;
    designFlags.legacy_MR_endminus1_detected = ~endpointFlags.no_MR_endminus1_endpoint_pattern;
    designFlags.MR_inconsistency_detected = ~endpointFlags.MR_consistent_with_M_Mi_Mf;
    designFlags.correction_required_before_formal_run = true;
    designFlags.clone_v17_to_v18_required = true;
    designFlags.clone_objective_v628b_to_v95j_required = true;
    designFlags.no_source_modified_in_this_step = true;
    designFlags.no_GA_executed = true;
    designFlags.formal_run_still_on_hold = true;
    designFlags.CO2_postprocess_design_still_pending = true;

    if designFlags.v95h_requires_review && ...
       designFlags.legacy_min_Mprod_detected && ...
       designFlags.legacy_MR_endminus1_detected && ...
       designFlags.MR_inconsistency_detected && ...
       designFlags.correction_required_before_formal_run

        diagnosis = "TMAX_ENDPOINT_CORRECTION_DESIGN_PASS";
    else
        diagnosis = "TMAX_ENDPOINT_CORRECTION_DESIGN_REQUIRES_REVIEW";
    end

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'TMAX_ENDPOINT_CORRECTION_DESIGN_v95i.md');
    outTxt = fullfile(logsDir,'TMAX_ENDPOINT_CORRECTION_DESIGN_v95i.txt');
    outMat = fullfile(matDir,'TMAX_ENDPOINT_CORRECTION_DESIGN_v95i.mat');

    outPatchCsv = fullfile(tablesDir,'TMAX_ENDPOINT_CORRECTION_DESIGN_v95i_patch_plan.csv');
    outReplacementCsv = fullfile(tablesDir,'TMAX_ENDPOINT_CORRECTION_DESIGN_v95i_replacements.csv');
    outValidationCsv = fullfile(tablesDir,'TMAX_ENDPOINT_CORRECTION_DESIGN_v95i_validation_plan.csv');
    outRisksCsv = fullfile(tablesDir,'TMAX_ENDPOINT_CORRECTION_DESIGN_v95i_risks.csv');

    writetable(Tpatch,outPatchCsv);
    writetable(Treplacements,outReplacementCsv);
    writetable(Tvalidation,outValidationCsv);
    writetable(Trisks,outRisksCsv);

    save(outMat, ...
        'diagnosis','designFlags', ...
        'Tpatch','Treplacements','Tvalidation','Trisks', ...
        'Tassign','Tchecks95h','Teval95g', ...
        'MR_gas_recalc','MR_hyb_recalc','MR_gas_diff','MR_hyb_diff', ...
        'wrapper_v17','objective_v628b','proposed_wrapper_v18','proposed_objective_v95j', ...
        'endpointDir','audit95gDir','designDir', ...
        'outMd','outTxt','outMat','outPatchCsv','outReplacementCsv','outValidationCsv','outRisksCsv');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# TMAX_ENDPOINT_CORRECTION_DESIGN_v95i\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Este documento diseña la corrección mínima para la rama `TMAX_REACHED`. No modifica código y no ejecuta AG.\n\n');

    fprintf(fid,'## Evidencia que motiva la corrección\n\n');
    fprintf(fid,'| Evidencia | Estado |\n');
    fprintf(fid,'|---|---|\n');
    fprintf(fid,'| `ENDPOINT_LOGIC_REQUIRES_REVIEW` en 9.5h | `%d` |\n', designFlags.v95h_requires_review);
    fprintf(fid,'| `min(M_prod)` detectado | `%d` |\n', designFlags.legacy_min_Mprod_detected);
    fprintf(fid,'| `MR(end-1)` detectado | `%d` |\n', designFlags.legacy_MR_endminus1_detected);
    fprintf(fid,'| Inconsistencia MR detectada | `%d` |\n\n', designFlags.MR_inconsistency_detected);

    fprintf(fid,'## Diferencia MR observada\n\n');
    fprintf(fid,'| Modo | MR reportado | MR recalculado | diferencia |\n');
    fprintf(fid,'|---|---:|---:|---:|\n');
    fprintf(fid,'| `gasLP` | %.12g | %.12g | %.12g |\n', gas.MR(1), MR_gas_recalc, MR_gas_diff);
    fprintf(fid,'| `hybrid` | %.12g | %.12g | %.12g |\n\n', hyb.MR(1), MR_hyb_recalc, MR_hyb_diff);

    fprintf(fid,'## Corrección diseñada\n\n');
    fprintf(fid,'La corrección propuesta consiste en clonar `v17` a `v18` y modificar únicamente la rama `TMAX_REACHED` para que el endpoint use el estado actual de integración:\n\n');
    fprintf(fid,'```matlab\n');
    fprintf(fid,'dry_time   = t(i)/3600 - t_ini;\n');
    fprintf(fid,'M_prod_fin = M_prod(i);\n');
    fprintf(fid,'MR_fin     = (M_prod_fin - Mf)/(Mi - Mf);\n');
    fprintf(fid,'```\n\n');

    fprintf(fid,'No se modifica la rama `M_DES_REACHED` y no se modifica la lógica de penalización `NONPHYSICAL_TRAJECTORY`.\n\n');

    fprintf(fid,'## Plan de parche\n\n');
    fprintf(fid,'| Paso | Acción | Tipo | Requerido | Descripción |\n');
    fprintf(fid,'|---|---|---|---:|---|\n');

    for i = 1:height(Tpatch)
        fprintf(fid,'| `%s` | %s | `%s` | `%d` | %s |\n', ...
            string(Tpatch.step(i)), ...
            string(Tpatch.action(i)), ...
            string(Tpatch.change_type(i)), ...
            Tpatch.required(i), ...
            string(Tpatch.description(i)));
    end

    fprintf(fid,'\n## Sustituciones previstas\n\n');
    fprintf(fid,'| ID | Alcance | Buscar | Reemplazar con | Requerido | Nota |\n');
    fprintf(fid,'|---|---|---|---|---:|---|\n');

    for i = 1:height(Treplacements)
        fprintf(fid,'| `%s` | %s | `%s` | `%s` | `%d` | %s |\n', ...
            string(Treplacements.id(i)), ...
            string(Treplacements.scope(i)), ...
            string(Treplacements.find_pattern(i)), ...
            string(Treplacements.replace_with(i)), ...
            Treplacements.required(i), ...
            string(Treplacements.note(i)));
    end

    fprintf(fid,'\n## Plan de validación\n\n');
    fprintf(fid,'| ID | Validación | Resultado requerido | Bloquea corrida formal |\n');
    fprintf(fid,'|---|---|---|---:|\n');

    for i = 1:height(Tvalidation)
        fprintf(fid,'| `%s` | %s | %s | `%d` |\n', ...
            string(Tvalidation.id(i)), ...
            string(Tvalidation.validation(i)), ...
            string(Tvalidation.required_result(i)), ...
            Tvalidation.blocks_formal_run(i));
    end

    fprintf(fid,'\n## Riesgos\n\n');
    fprintf(fid,'| Riesgo | Nivel | Mitigación |\n');
    fprintf(fid,'|---|---|---|\n');

    for i = 1:height(Trisks)
        fprintf(fid,'| %s | `%s` | %s |\n', ...
            string(Trisks.risk(i)), ...
            string(Trisks.level(i)), ...
            string(Trisks.mitigation(i)));
    end

    fprintf(fid,'\n## Dictamen operativo\n\n');
    fprintf(fid,'No debe ejecutarse la corrida formal hasta implementar y validar la corrección en un clon nuevo. El siguiente micropaso debe crear `v18` y `v95j`, y ejecutar evaluación directa `gasLP`/`hybrid`/`solar`.\n\n');

    fprintf(fid,'## Siguiente paso\n\n');
    fprintf(fid,'`9.5j — IMPLEMENT-TMAX-ENDPOINT-CORRECTION-CLONE-001`\n\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % TXT ejecutivo
    % ---------------------------------------------------------------------
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'TMAX-ENDPOINT-CORRECTION-DESIGN-001\n');
    fprintf(fid,'status: TMAX_ENDPOINT_CORRECTION_DESIGN_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'v95h_requires_review: %d\n', designFlags.v95h_requires_review);
    fprintf(fid,'legacy_min_Mprod_detected: %d\n', designFlags.legacy_min_Mprod_detected);
    fprintf(fid,'legacy_MR_endminus1_detected: %d\n', designFlags.legacy_MR_endminus1_detected);
    fprintf(fid,'MR_inconsistency_detected: %d\n', designFlags.MR_inconsistency_detected);
    fprintf(fid,'correction_required_before_formal_run: %d\n', designFlags.correction_required_before_formal_run);
    fprintf(fid,'clone_v17_to_v18_required: %d\n', designFlags.clone_v17_to_v18_required);
    fprintf(fid,'clone_objective_v628b_to_v95j_required: %d\n', designFlags.clone_objective_v628b_to_v95j_required);
    fprintf(fid,'no_source_modified_in_this_step: %d\n', designFlags.no_source_modified_in_this_step);
    fprintf(fid,'no_GA_executed: %d\n', designFlags.no_GA_executed);
    fprintf(fid,'formal_run_still_on_hold: %d\n', designFlags.formal_run_still_on_hold);
    fprintf(fid,'CO2_postprocess_design_still_pending: %d\n', designFlags.CO2_postprocess_design_still_pending);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'PROPOSED FILES:\n');
    fprintf(fid,'wrapper_v18: %s\n', proposed_wrapper_v18);
    fprintf(fid,'objective_v95j: %s\n\n', proposed_objective_v95j);

    fprintf(fid,'OUTPUTS:\n');
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'outPatchCsv: %s\n', outPatchCsv);
    fprintf(fid,'outReplacementCsv: %s\n', outReplacementCsv);
    fprintf(fid,'outValidationCsv: %s\n', outValidationCsv);
    fprintf(fid,'outRisksCsv: %s\n', outRisksCsv);

    fclose(fid);

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    design = struct();
    design.status = 'TMAX_ENDPOINT_CORRECTION_DESIGN_COMPLETED';
    design.diagnosis = diagnosis;
    design.designFlags = designFlags;
    design.Tpatch = Tpatch;
    design.Treplacements = Treplacements;
    design.Tvalidation = Tvalidation;
    design.Trisks = Trisks;
    design.MR_gas_recalc = MR_gas_recalc;
    design.MR_hyb_recalc = MR_hyb_recalc;
    design.MR_gas_diff = MR_gas_diff;
    design.MR_hyb_diff = MR_hyb_diff;
    design.wrapper_v17 = wrapper_v17;
    design.objective_v628b = objective_v628b;
    design.proposed_wrapper_v18 = proposed_wrapper_v18;
    design.proposed_objective_v95j = proposed_objective_v95j;
    design.endpointDir = endpointDir;
    design.audit95gDir = audit95gDir;
    design.designDir = designDir;
    design.outMd = outMd;
    design.outTxt = outTxt;
    design.outMat = outMat;
    design.outPatchCsv = outPatchCsv;
    design.outReplacementCsv = outReplacementCsv;
    design.outValidationCsv = outValidationCsv;
    design.outRisksCsv = outRisksCsv;

    disp('=== TMAX_ENDPOINT_CORRECTION_DESIGN_v95i ===')
    disp(design.status)
    disp('=== DIAGNOSIS ===')
    disp(design.diagnosis)
    disp('=== DESIGN FLAGS ===')
    disp(design.designFlags)
    disp('=== PATCH PLAN ===')
    disp(design.Tpatch)
    disp('=== REPLACEMENTS ===')
    disp(design.Treplacements)
    disp('=== VALIDATION PLAN ===')
    disp(design.Tvalidation)
    disp('=== PROPOSED FILES ===')
    disp(design.proposed_wrapper_v18)
    disp(design.proposed_objective_v95j)
    disp('=== OUTPUT FILES ===')
    disp(design.outMd)
    disp(design.outTxt)
    disp(design.outMat)

end