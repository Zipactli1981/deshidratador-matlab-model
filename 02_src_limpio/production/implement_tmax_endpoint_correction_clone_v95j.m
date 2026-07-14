function impl = implement_tmax_endpoint_correction_clone_v95j()
% IMPLEMENT_TMAX_ENDPOINT_CORRECTION_CLONE_v95j
% 9.5j — IMPLEMENT-TMAX-ENDPOINT-CORRECTION-CLONE-001
%
% Objetivo:
%   Implementar en clon nuevo la corrección TMAX diseñada en 9.5i:
%       M_prod_fin = M_prod(i);
%       MR_fin     = (M_prod_fin - Mf)/(Mi - Mf);
%
% Este micropaso:
%   - NO modifica v10.
%   - NO modifica v17.
%   - NO modifica v628b.
%   - Crea wrapper v18.
%   - Crea objective v95j.
%   - Ejecuta evaluación directa gasLP/hybrid/solar.
%   - NO ejecuta gamultiobj.
%   - NO libera todavía la corrida formal.
%
% Salidas:
%   logs/TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_v95j.md
%   logs/TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_v95j.txt
%   tables/TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_v95j_eval.csv
%   tables/TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_v95j_checks.csv
%   tables/TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_v95j_source_scan.csv
%   mat/TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_v95j.mat
%
% Uso:
%   impl = implement_tmax_endpoint_correction_clone_v95j();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Cargar diseño v95i
    % ---------------------------------------------------------------------
    designBaseDir = fullfile(rootDir,'05_runs','tmax_endpoint_correction_design_v95i');

    if ~isfolder(designBaseDir)
        error('No existe designBaseDir: %s', designBaseDir);
    end

    d = dir(designBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for k = 1:numel(d)
        keep(k) = startsWith(d(k).name,'TMAX_ENDPOINT_CORRECTION_DESIGN_v95i_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró diseño v95i.');
    end

    [~,idxDesign] = max([d.datenum]);
    designDir = fullfile(designBaseDir,d(idxDesign).name);
    designMat = fullfile(designDir,'mat','TMAX_ENDPOINT_CORRECTION_DESIGN_v95i.mat');

    if ~isfile(designMat)
        error('No existe MAT v95i: %s', designMat);
    end

    Sdesign = load(designMat);

    if ~isfield(Sdesign,'diagnosis')
        error('v95i no contiene diagnosis.');
    end

    if ~strcmp(string(Sdesign.diagnosis),"TMAX_ENDPOINT_CORRECTION_DESIGN_PASS")
        error('v95i no está en PASS. Diagnosis: %s', string(Sdesign.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Rutas fuente y destino
    % ---------------------------------------------------------------------
    wrapper_v17 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v17_nonphysical_penalty.m');
    objective_v628b = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v628b_nonphysical_penalty.m');

    wrapper_v18 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v18_endpoint_TMAX_corrected.m');
    objective_v95j = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v95j_endpoint_TMAX_corrected.m');

    if ~isfile(wrapper_v17)
        error('No existe wrapper v17: %s', wrapper_v17);
    end

    if ~isfile(objective_v628b)
        error('No existe objective v628b: %s', objective_v628b);
    end

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    implBaseDir = fullfile(rootDir,'05_runs','tmax_endpoint_correction_implementation_v95j');
    implDir = fullfile(implBaseDir,['TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_v95j_' timestamp]);

    logsDir = fullfile(implDir,'logs');
    tablesDir = fullfile(implDir,'tables');
    matDir = fullfile(implDir,'mat');

    if ~isfolder(implBaseDir), mkdir(implBaseDir); end
    if ~isfolder(implDir), mkdir(implDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Crear wrapper v18 desde v17
    % ---------------------------------------------------------------------
    txt17 = fileread(wrapper_v17);
    txt18 = txt17;

    txt18 = strrep(txt18, ...
        'function [Q_aux_tot, dry_time, M_prod_fin, MR_fin, Irradiacion, irr_diag] = opt_tunel_mod2_v17_nonphysical_penalty', ...
        'function [Q_aux_tot, dry_time, M_prod_fin, MR_fin, Irradiacion, irr_diag] = opt_tunel_mod2_v18_endpoint_TMAX_corrected');

    txt18 = strrep(txt18, ...
        'opt_tunel_mod2_v17_nonphysical_penalty', ...
        'opt_tunel_mod2_v18_endpoint_TMAX_corrected');

    % Corrección focalizada TMAX.
    % Se reemplaza solo el patrón legacy activo. Los comentarios pueden quedar,
    % pero serán revisados como no-activos en el escaneo.
    n_minM_before = count(string(txt18), "M_prod_fin=min(M_prod);");
    n_MRend_before = count(string(txt18), "MR_fin=MR(end-1);");

    txt18 = strrep(txt18, ...
        'M_prod_fin=min(M_prod);', ...
        'M_prod_fin=M_prod(i);');

    txt18 = strrep(txt18, ...
        'MR_fin=MR(end-1);', ...
        'MR_fin=(M_prod_fin-Mf)/(Mi-Mf);');

    % Metadato discreto
    headerNote = sprintf(['%% v18 endpoint-TMAX-corrected clone generated by implement_tmax_endpoint_correction_clone_v95j on %s\n' ...
                          '%% Correction: TMAX endpoint uses current state M_prod(i) and recalculated MR.\n'], ...
                          datestr(now,'yyyy-mm-dd HH:MM:SS'));

    txt18 = regexprep(txt18, '(^function\s)', [headerNote '$1'], 'once');

    fid = fopen(wrapper_v18,'w');
    if fid < 0
        error('No se pudo escribir wrapper v18: %s', wrapper_v18);
    end
    fwrite(fid, txt18);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Crear objective v95j desde v628b
    % ---------------------------------------------------------------------
    txtObj = fileread(objective_v628b);
    txt95j = txtObj;

    txt95j = strrep(txt95j, ...
        'function [f, detail] = objective_productive_corrected_v628b_nonphysical_penalty', ...
        'function [f, detail] = objective_productive_corrected_v95j_endpoint_TMAX_corrected');

    txt95j = strrep(txt95j, ...
        'objective_productive_corrected_v628b_nonphysical_penalty', ...
        'objective_productive_corrected_v95j_endpoint_TMAX_corrected');

    txt95j = strrep(txt95j, ...
        'opt_tunel_mod2_v17_nonphysical_penalty', ...
        'opt_tunel_mod2_v18_endpoint_TMAX_corrected');

    headerNoteObj = sprintf(['%% v95j endpoint-TMAX-corrected objective clone generated by implement_tmax_endpoint_correction_clone_v95j on %s\n' ...
                             '%% Calls opt_tunel_mod2_v18_endpoint_TMAX_corrected.\n'], ...
                             datestr(now,'yyyy-mm-dd HH:MM:SS'));

    txt95j = regexprep(txt95j, '(^function\s)', [headerNoteObj '$1'], 'once');

    % Agregar metadato si existe detail.created_by.
    % Usar char/sprintf para evitar incompatibilidad entre string, char y newline.
    if contains(txt95j, 'detail.created_by')
        metadataLine = sprintf('detail.endpoint_TMAX_correction = "v95j_v18_current_state_recalculated_MR";\n    detail.created_by');
        txt95j = strrep(txt95j, ...
            'detail.created_by', ...
            metadataLine);
    end

    fid = fopen(objective_v95j,'w');
    if fid < 0
        error('No se pudo escribir objective v95j: %s', objective_v95j);
    end
    fwrite(fid, txt95j);
    fclose(fid);

    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    if exist('opt_tunel_mod2_v18_endpoint_TMAX_corrected','file') ~= 2
        error('No quedó visible wrapper v18 después de crearlo.');
    end

    if exist('objective_productive_corrected_v95j_endpoint_TMAX_corrected','file') ~= 2
        error('No quedó visible objective v95j después de crearlo.');
    end

    % ---------------------------------------------------------------------
    % Evaluación directa con solución seleccionada
    % ---------------------------------------------------------------------
    x_selected = [ ...
        0.0740767982118, ...
        62.6832965028, ...
        0.672252618341, ...
        11.6517528081];

    modes = ["gasLP","hybrid","solar"];
    evalRows = {};

    for k = 1:numel(modes)
        mode = modes(k);
        [f, detail, status, errMsg] = local_eval_v95j(x_selected, mode);
        row = local_detail_to_row_v95j(mode, x_selected, f, detail, status, errMsg);
        evalRows{end+1,1} = row; %#ok<AGROW>
    end

    Teval = struct2table(vertcat(evalRows{:}));
    outEvalCsv = fullfile(tablesDir,'TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_v95j_eval.csv');
    writetable(Teval,outEvalCsv);

    gas = Teval(strcmp(string(Teval.mode),"gasLP"),:);
    hyb = Teval(strcmp(string(Teval.mode),"hybrid"),:);
    sol = Teval(strcmp(string(Teval.mode),"solar"),:);

    % ---------------------------------------------------------------------
    % Escaneo de fuente v18/v95j
    % ---------------------------------------------------------------------
    sourceRows = {};

    sourceRows{end+1,1} = local_source_row_v95j("wrapper_v18_exists", wrapper_v18, "", isfile(wrapper_v18), "v18 wrapper file exists.");
    sourceRows{end+1,1} = local_source_row_v95j("objective_v95j_exists", objective_v95j, "", isfile(objective_v95j), "v95j objective file exists.");
    sourceRows{end+1,1} = local_source_contains_v95j("v18_function_name", wrapper_v18, "opt_tunel_mod2_v18_endpoint_TMAX_corrected", "v18 function name found.");
    sourceRows{end+1,1} = local_source_contains_v95j("v95j_function_name", objective_v95j, "objective_productive_corrected_v95j_endpoint_TMAX_corrected", "v95j function name found.");
    sourceRows{end+1,1} = local_source_contains_v95j("v95j_calls_v18", objective_v95j, "opt_tunel_mod2_v18_endpoint_TMAX_corrected", "v95j calls v18 wrapper.");
    sourceRows{end+1,1} = local_source_contains_v95j("v18_current_M_endpoint", wrapper_v18, "M_prod_fin=M_prod(i);", "v18 contains current-index M endpoint.");
    sourceRows{end+1,1} = local_source_contains_v95j("v18_recalc_MR_endpoint", wrapper_v18, "MR_fin=(M_prod_fin-Mf)/(Mi-Mf);", "v18 contains recalculated MR endpoint.");
    sourceRows{end+1,1} = local_source_contains_active_v95j("v18_active_min_Mprod_absent", wrapper_v18, "M_prod_fin=min(M_prod);", false, "No active min(M_prod) endpoint assignment.");
    sourceRows{end+1,1} = local_source_contains_active_v95j("v18_active_MR_endminus1_absent", wrapper_v18, "MR_fin=MR(end-1);", false, "No active MR(end-1) endpoint assignment.");
    sourceRows{end+1,1} = local_source_contains_v95j("v18_guard_preserved", wrapper_v18, "nonphysical_guard_eval_v628b", "Physical guard call preserved.");
    sourceRows{end+1,1} = local_source_contains_v95j("v18_solar_penalty_preserved", wrapper_v18, "NONPHYSICAL_TRAJECTORY", "Nonphysical trajectory status preserved.");

    Tsource = struct2table(vertcat(sourceRows{:}));
    outSourceCsv = fullfile(tablesDir,'TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_v95j_source_scan.csv');
    writetable(Tsource,outSourceCsv);

    % ---------------------------------------------------------------------
    % Checks de validación
    % ---------------------------------------------------------------------
    maxPenaltyMR = 999.999;
    maxPenaltyCost = 999999.999;

    gas_ok = strcmp(string(gas.eval_status(1)),"OK") && strcmp(string(gas.detail_status(1)),"OK");
    hyb_ok = strcmp(string(hyb.eval_status(1)),"OK") && strcmp(string(hyb.detail_status(1)),"OK");

    gas_not_penalized = gas.MR_objective(1) < maxPenaltyMR && gas.cost_objective(1) < maxPenaltyCost;
    hyb_not_penalized = hyb.MR_objective(1) < maxPenaltyMR && hyb.cost_objective(1) < maxPenaltyCost;
    solar_penalized = sol.MR_objective(1) >= maxPenaltyMR || sol.cost_objective(1) >= maxPenaltyCost;

    MR_gas_recalc = (gas.M(1) - gas.Mf(1)) / (gas.Mi(1) - gas.Mf(1));
    MR_hyb_recalc = (hyb.M(1) - hyb.Mf(1)) / (hyb.Mi(1) - hyb.Mf(1));

    MR_gas_diff = abs(gas.MR(1) - MR_gas_recalc);
    MR_hyb_diff = abs(hyb.MR(1) - MR_hyb_recalc);

    delta_Q_aux = hyb.Q_aux_tot(1) - gas.Q_aux_tot(1);
    reduction_Q_aux_pct = 100 * (gas.Q_aux_tot(1) - hyb.Q_aux_tot(1)) / gas.Q_aux_tot(1);
    delta_dry_time = hyb.dry_time(1) - gas.dry_time(1);
    delta_MR = hyb.MR(1) - gas.MR(1);

    checks = {};

    checks{end+1,1} = local_check_row_v95j( ...
        "V01", ...
        "Direct evaluation gasLP", ...
        gas_ok && gas_not_penalized && isfinite(gas.M(1)) && isfinite(gas.MR(1)) && isfinite(gas.cost_objective(1)), ...
        sprintf("status=%s detail=%s MR=%.12g cost=%.12g", string(gas.eval_status(1)), string(gas.detail_status(1)), gas.MR_objective(1), gas.cost_objective(1)), ...
        "gasLP must be OK, finite and non-penalized.");

    checks{end+1,1} = local_check_row_v95j( ...
        "V02", ...
        "Direct evaluation hybrid", ...
        hyb_ok && hyb_not_penalized && hyb.Irradiacion(1) > 0 && isfinite(hyb.M(1)) && isfinite(hyb.MR(1)) && isfinite(hyb.cost_objective(1)), ...
        sprintf("status=%s detail=%s Irr=%.12g MR=%.12g cost=%.12g", string(hyb.eval_status(1)), string(hyb.detail_status(1)), hyb.Irradiacion(1), hyb.MR_objective(1), hyb.cost_objective(1)), ...
        "hybrid must be OK, irradiated, finite and non-penalized.");

    checks{end+1,1} = local_check_row_v95j( ...
        "V03", ...
        "Direct evaluation solar", ...
        solar_penalized, ...
        sprintf("solar MR=%.12g cost=%.12g detail=%s", sol.MR_objective(1), sol.cost_objective(1), string(sol.detail_status(1))), ...
        "solar must remain penalized/excluded.");

    checks{end+1,1} = local_check_row_v95j( ...
        "V04", ...
        "MR consistency", ...
        MR_gas_diff < 1e-8 && MR_hyb_diff < 1e-8, ...
        sprintf("gas diff=%.12g; hybrid diff=%.12g", MR_gas_diff, MR_hyb_diff), ...
        "MR must satisfy (M-Mf)/(Mi-Mf).");

    checks{end+1,1} = local_check_row_v95j( ...
        "V05", ...
        "TMAX endpoint logic", ...
        local_source_pass_v95j(Tsource,"v18_current_M_endpoint") && ...
        local_source_pass_v95j(Tsource,"v18_recalc_MR_endpoint") && ...
        local_source_pass_v95j(Tsource,"v18_active_min_Mprod_absent") && ...
        local_source_pass_v95j(Tsource,"v18_active_MR_endminus1_absent"), ...
        "v18 has M_prod(i), recalculated MR, and no active legacy endpoint assignment.", ...
        "TMAX must use current state endpoint and recalculated MR.");

    checks{end+1,1} = local_check_row_v95j( ...
        "V06", ...
        "Comparative physical sanity", ...
        reduction_Q_aux_pct > 1 && abs(delta_dry_time) <= 0.5 && abs(delta_MR) <= 0.02, ...
        sprintf("Q_aux reduction=%.12g%%; delta dry_time=%.12g; delta MR=%.12g", reduction_Q_aux_pct, delta_dry_time, delta_MR), ...
        "hybrid must reduce auxiliary energy while preserving comparable drying endpoint.");

    checks{end+1,1} = local_check_row_v95j( ...
        "V07", ...
        "No source overwrite", ...
        isfile(wrapper_v17) && isfile(objective_v628b) && isfile(wrapper_v18) && isfile(objective_v95j), ...
        "v17/v628b exist and v18/v95j were created as new files.", ...
        "Original guarded files must remain available.");

    checks{end+1,1} = local_check_row_v95j( ...
        "V08", ...
        "Objective call route", ...
        local_source_pass_v95j(Tsource,"v95j_calls_v18"), ...
        "v95j calls v18 wrapper.", ...
        "Corrected objective must call corrected wrapper.");

    Tchecks = struct2table(vertcat(checks{:}));
    outChecksCsv = fullfile(tablesDir,'TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_v95j_checks.csv');
    writetable(Tchecks,outChecksCsv);

    % ---------------------------------------------------------------------
    % Dictamen
    % ---------------------------------------------------------------------
    implFlags = struct();
    implFlags.wrapper_v18_created = isfile(wrapper_v18);
    implFlags.objective_v95j_created = isfile(objective_v95j);
    implFlags.v17_preserved = isfile(wrapper_v17);
    implFlags.v628b_preserved = isfile(objective_v628b);
    implFlags.n_minM_before = n_minM_before;
    implFlags.n_MRend_before = n_MRend_before;
    implFlags.gasLP_OK_nonpenalized = gas_ok && gas_not_penalized;
    implFlags.hybrid_OK_nonpenalized = hyb_ok && hyb_not_penalized;
    implFlags.solar_penalized = solar_penalized;
    implFlags.MR_consistency_pass = MR_gas_diff < 1e-8 && MR_hyb_diff < 1e-8;
    implFlags.TMAX_endpoint_logic_pass = Tchecks.pass(strcmp(string(Tchecks.id),"V05"));
    implFlags.comparative_physical_sanity_pass = Tchecks.pass(strcmp(string(Tchecks.id),"V06"));
    implFlags.all_validation_checks_pass = all(Tchecks.pass);
    implFlags.no_GA_executed = true;
    implFlags.formal_run_still_on_hold = true;
    implFlags.CO2_postprocess_design_still_pending = true;

    if implFlags.all_validation_checks_pass
        diagnosis = "TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_PASS";
    else
        diagnosis = "TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_REQUIRES_REVIEW";
    end

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_v95j.md');
    outTxt = fullfile(logsDir,'TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_v95j.txt');
    outMat = fullfile(matDir,'TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_v95j.mat');

    save(outMat, ...
        'diagnosis','implFlags','x_selected', ...
        'Teval','Tchecks','Tsource', ...
        'MR_gas_recalc','MR_hyb_recalc','MR_gas_diff','MR_hyb_diff', ...
        'delta_Q_aux','reduction_Q_aux_pct','delta_dry_time','delta_MR', ...
        'wrapper_v17','objective_v628b','wrapper_v18','objective_v95j', ...
        'designDir','implDir', ...
        'outMd','outTxt','outMat','outEvalCsv','outChecksCsv','outSourceCsv');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_v95j\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Este micropaso implementa la corrección TMAX en clones nuevos `v18` y `v95j`. No ejecuta AG.\n\n');

    fprintf(fid,'## Archivos creados\n\n');
    fprintf(fid,'| Tipo | Ruta |\n');
    fprintf(fid,'|---|---|\n');
    fprintf(fid,'| Wrapper corregido | `%s` |\n', wrapper_v18);
    fprintf(fid,'| Objective corregida | `%s` |\n\n', objective_v95j);

    fprintf(fid,'## Evaluación directa\n\n');
    fprintf(fid,'| Modo | eval_status | detail_status | MR obj | cost obj | Q_aux | Irradiacion | dry_time | M | Mf | Mi | MR | MR recalc | MR diff |\n');
    fprintf(fid,'|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|\n');

    for k = 1:height(Teval)
        mode = string(Teval.mode(k));
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
            string(Teval.eval_status(k)), ...
            string(Teval.detail_status(k)), ...
            Teval.MR_objective(k), ...
            Teval.cost_objective(k), ...
            Teval.Q_aux_tot(k), ...
            Teval.Irradiacion(k), ...
            Teval.dry_time(k), ...
            Teval.M(k), ...
            Teval.Mf(k), ...
            Teval.Mi(k), ...
            Teval.MR(k), ...
            mrRec, ...
            mrDiff);
    end

    fprintf(fid,'\n## Checks de validación\n\n');
    fprintf(fid,'| ID | Check | Pass | Evidencia | Criterio |\n');
    fprintf(fid,'|---|---|---:|---|---|\n');

    for k = 1:height(Tchecks)
        fprintf(fid,'| `%s` | `%s` | `%d` | %s | %s |\n', ...
            string(Tchecks.id(k)), ...
            string(Tchecks.check(k)), ...
            Tchecks.pass(k), ...
            string(Tchecks.evidence(k)), ...
            string(Tchecks.criterion(k)));
    end

    fprintf(fid,'\n## Escaneo de fuente\n\n');
    fprintf(fid,'| Item | Pass | Evidencia |\n');
    fprintf(fid,'|---|---:|---|\n');

    for k = 1:height(Tsource)
        fprintf(fid,'| `%s` | `%d` | %s |\n', ...
            string(Tsource.item(k)), ...
            Tsource.pass(k), ...
            string(Tsource.evidence(k)));
    end

    fprintf(fid,'\n## Métricas comparativas\n\n');
    fprintf(fid,'| Métrica | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| delta_Q_aux_hybrid_minus_gasLP | %.12g |\n', delta_Q_aux);
    fprintf(fid,'| reduction_Q_aux_pct | %.12g |\n', reduction_Q_aux_pct);
    fprintf(fid,'| delta_dry_time_hybrid_minus_gasLP | %.12g |\n', delta_dry_time);
    fprintf(fid,'| delta_MR_hybrid_minus_gasLP | %.12g |\n\n', delta_MR);

    fprintf(fid,'## Restricciones activas\n\n');
    fprintf(fid,'- No se ejecutó `gamultiobj`.\n');
    fprintf(fid,'- La corrida formal sigue detenida.\n');
    fprintf(fid,'- Falta diseñar CO2 opción A como postproceso.\n');
    fprintf(fid,'- Solar puro sigue excluido.\n\n');

    fprintf(fid,'## Siguiente paso\n\n');
    fprintf(fid,'Si el diagnóstico es `TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_PASS`, continuar con `9.5k — MINIMAL-PHYSICS-AUDIT-RECHECK-WITH-TMAX-CORRECTION-001`.\n\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % TXT
    % ---------------------------------------------------------------------
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'IMPLEMENT-TMAX-ENDPOINT-CORRECTION-CLONE-001\n');
    fprintf(fid,'status: TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'wrapper_v18_created: %d\n', implFlags.wrapper_v18_created);
    fprintf(fid,'objective_v95j_created: %d\n', implFlags.objective_v95j_created);
    fprintf(fid,'v17_preserved: %d\n', implFlags.v17_preserved);
    fprintf(fid,'v628b_preserved: %d\n', implFlags.v628b_preserved);
    fprintf(fid,'gasLP_OK_nonpenalized: %d\n', implFlags.gasLP_OK_nonpenalized);
    fprintf(fid,'hybrid_OK_nonpenalized: %d\n', implFlags.hybrid_OK_nonpenalized);
    fprintf(fid,'solar_penalized: %d\n', implFlags.solar_penalized);
    fprintf(fid,'MR_consistency_pass: %d\n', implFlags.MR_consistency_pass);
    fprintf(fid,'TMAX_endpoint_logic_pass: %d\n', implFlags.TMAX_endpoint_logic_pass);
    fprintf(fid,'comparative_physical_sanity_pass: %d\n', implFlags.comparative_physical_sanity_pass);
    fprintf(fid,'all_validation_checks_pass: %d\n', implFlags.all_validation_checks_pass);
    fprintf(fid,'no_GA_executed: %d\n', implFlags.no_GA_executed);
    fprintf(fid,'formal_run_still_on_hold: %d\n', implFlags.formal_run_still_on_hold);
    fprintf(fid,'CO2_postprocess_design_still_pending: %d\n', implFlags.CO2_postprocess_design_still_pending);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'KEY METRICS:\n');
    fprintf(fid,'MR_gas_recalc: %.12g\n', MR_gas_recalc);
    fprintf(fid,'MR_hyb_recalc: %.12g\n', MR_hyb_recalc);
    fprintf(fid,'MR_gas_diff: %.12g\n', MR_gas_diff);
    fprintf(fid,'MR_hyb_diff: %.12g\n', MR_hyb_diff);
    fprintf(fid,'delta_Q_aux: %.12g\n', delta_Q_aux);
    fprintf(fid,'reduction_Q_aux_pct: %.12g\n', reduction_Q_aux_pct);
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
    impl = struct();
    impl.status = 'TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_COMPLETED';
    impl.diagnosis = diagnosis;
    impl.implFlags = implFlags;
    impl.x_selected = x_selected;
    impl.Teval = Teval;
    impl.Tchecks = Tchecks;
    impl.Tsource = Tsource;
    impl.MR_gas_recalc = MR_gas_recalc;
    impl.MR_hyb_recalc = MR_hyb_recalc;
    impl.MR_gas_diff = MR_gas_diff;
    impl.MR_hyb_diff = MR_hyb_diff;
    impl.delta_Q_aux = delta_Q_aux;
    impl.reduction_Q_aux_pct = reduction_Q_aux_pct;
    impl.delta_dry_time = delta_dry_time;
    impl.delta_MR = delta_MR;
    impl.wrapper_v18 = wrapper_v18;
    impl.objective_v95j = objective_v95j;
    impl.implDir = implDir;
    impl.outMd = outMd;
    impl.outTxt = outTxt;
    impl.outMat = outMat;
    impl.outEvalCsv = outEvalCsv;
    impl.outChecksCsv = outChecksCsv;
    impl.outSourceCsv = outSourceCsv;

    disp('=== TMAX_ENDPOINT_CORRECTION_IMPLEMENTATION_v95j ===')
    disp(impl.status)
    disp('=== DIAGNOSIS ===')
    disp(impl.diagnosis)
    disp('=== IMPLEMENTATION FLAGS ===')
    disp(impl.implFlags)
    disp('=== DIRECT EVALUATION ===')
    disp(impl.Teval)
    disp('=== VALIDATION CHECKS ===')
    disp(impl.Tchecks)
    disp('=== SOURCE SCAN ===')
    disp(impl.Tsource)
    disp('=== KEY METRICS ===')
    fprintf('MR_gas_recalc = %.12g\n', impl.MR_gas_recalc);
    fprintf('MR_hyb_recalc = %.12g\n', impl.MR_hyb_recalc);
    fprintf('MR_gas_diff = %.12g\n', impl.MR_gas_diff);
    fprintf('MR_hyb_diff = %.12g\n', impl.MR_hyb_diff);
    fprintf('delta_Q_aux_hybrid_minus_gasLP = %.12g\n', impl.delta_Q_aux);
    fprintf('reduction_Q_aux_pct = %.12g\n', impl.reduction_Q_aux_pct);
    fprintf('delta_dry_time_hybrid_minus_gasLP = %.12g\n', impl.delta_dry_time);
    fprintf('delta_MR_hybrid_minus_gasLP = %.12g\n', impl.delta_MR);
    disp('=== OUTPUT FILES ===')
    disp(impl.outMd)
    disp(impl.outTxt)
    disp(impl.outMat)

end

% =========================================================================
% Funciones locales auxiliares
% =========================================================================

function [f, detail, status, errMsg] = local_eval_v95j(x, mode)
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

function row = local_detail_to_row_v95j(mode, x, f, detail, status, errMsg)

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

    row.detail_status = local_get_string_v95j(detail, {'status','detail_status','execution_status'}, "UNKNOWN");

    row.Q_aux_tot = local_get_numeric_v95j(detail, {'outputs.Q_aux_tot','Q_aux_tot','outputs.Q_aux'}, NaN);
    row.Irradiacion = local_get_numeric_v95j(detail, {'outputs.Irradiacion','Irradiacion'}, NaN);
    row.dry_time = local_get_numeric_v95j(detail, {'outputs.dry_time','dry_time'}, NaN);
    row.M = local_get_numeric_v95j(detail, {'outputs.M','M'}, NaN);
    row.MR = local_get_numeric_v95j(detail, {'outputs.MR','MR'}, NaN);

    row.Mf = local_get_numeric_v95j(detail, {'product.Mf','Mf'}, NaN);
    row.Mi = local_get_numeric_v95j(detail, {'product.Mi','Mi'}, NaN);
    row.M_des = local_get_numeric_v95j(detail, {'product.M_des','M_des'}, NaN);

    row.cost_specific = local_get_numeric_v95j(detail, {'cost.cost_specific_USD_per_kgwater','cost_specific_USD_per_kgwater'}, NaN);
    row.total_cost = local_get_numeric_v95j(detail, {'cost.total_cost_USD','total_cost_USD'}, NaN);

    row.execution_message = local_get_string_v95j(detail, {'execution.message','message'}, "");

end

function val = local_get_numeric_v95j(S, paths, defaultVal)
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

function val = local_get_string_v95j(S, paths, defaultVal)
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

function row = local_source_row_v95j(item, filePath, pattern, passVal, evidence)
    row = struct();
    row.item = string(item);
    row.file = string(filePath);
    row.pattern = string(pattern);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end

function row = local_source_contains_v95j(item, filePath, pattern, evidenceIfFound)
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

    row = local_source_row_v95j(item, filePath, pattern, passVal, evidence);
end

function row = local_source_contains_active_v95j(item, filePath, pattern, expectedContains, evidenceIfExpected)
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

            passVal = (activeContains == expectedContains);

            if passVal
                evidence = string(evidenceIfExpected);
            else
                evidence = sprintf('activeContains=%d, expectedContains=%d', activeContains, expectedContains);
            end

        catch ME
            evidence = "Could not read file: " + string(ME.message);
        end
    end

    row = local_source_row_v95j(item, filePath, pattern, passVal, evidence);
end

function tf = local_source_pass_v95j(Tsource, itemName)
    idx = strcmp(string(Tsource.item), string(itemName));
    if any(idx)
        tf = logical(Tsource.pass(find(idx,1,'first')));
    else
        tf = false;
    end
end

function row = local_check_row_v95j(id, checkName, passVal, evidence, criterion)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
    row.criterion = string(criterion);
end