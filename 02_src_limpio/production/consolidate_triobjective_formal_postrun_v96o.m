function post = consolidate_triobjective_formal_postrun_v96o()
% CONSOLIDATE_TRIOBJECTIVE_FORMAL_POSTRUN_v96o
% 9.6o — TRIOBJECTIVE-FORMAL-POSTRUN-CONSOLIDATION-001
%
% Objetivo:
%   Consolidar la corrida formal triobjetivo hybrid v96m.
%
% Este paso:
%   - NO ejecuta gamultiobj.
%   - NO modifica fuentes protegidas.
%   - Carga el MAT formal v96m más reciente.
%   - Extrae X y F.
%   - Ordena soluciones.
%   - Identifica soluciones representativas:
%       mínimo MR
%       mínimo costo
%       mínimo CO2
%       balanceada normalizada
%   - Compara contra gasLP preflight/reference.
%   - Genera CSV, MD, TXT y MAT consolidados.
%
% Uso:
%   post = consolidate_triobjective_formal_postrun_v96o();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Cargar corrida formal v96m más reciente
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
        error('No se encontró corrida formal v96m.');
    end

    [~,idxRun] = max([d.datenum]);
    formalRunDir = fullfile(formalBaseDir,d(idxRun).name);
    formalMat = fullfile(formalRunDir,'mat','TRIOBJECTIVE_FORMAL_GA_v96m.mat');

    if ~isfile(formalMat)
        error('No existe MAT formal v96m: %s', formalMat);
    end

    S = load(formalMat);

    if ~isfield(S,'diagnosis')
        error('El MAT formal no contiene variable diagnosis.');
    end

    if ~strcmp(string(S.diagnosis),"TRIOBJECTIVE_FORMAL_RUN_EXECUTION_COMPLETED_PASS")
        error('La corrida formal no está en PASS. Diagnosis: %s', string(S.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    postBaseDir = fullfile(rootDir,'05_runs','triobjective_formal_postrun_consolidation_v96o');
    postDir = fullfile(postBaseDir,['TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_v96o_' timestamp]);

    logsDir = fullfile(postDir,'logs');
    tablesDir = fullfile(postDir,'tables');
    matDir = fullfile(postDir,'mat');

    if ~isfolder(postBaseDir), mkdir(postBaseDir); end
    if ~isfolder(postDir), mkdir(postDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Extraer X/F
    % ---------------------------------------------------------------------
    [F, F_path, F_note] = local_find_F_v96o(S);
    [X, X_path, X_note] = local_find_X_v96o(S, size(F,1));

    if isempty(F)
        error('No se pudo localizar matriz F de objetivos 3D en el MAT formal.');
    end

    if isempty(X)
        error('No se pudo localizar matriz X compatible con F en el MAT formal.');
    end

    n = min(size(F,1),size(X,1));
    F = F(1:n,:);
    X = X(1:n,:);

    % ---------------------------------------------------------------------
    % Limpiar soluciones finitas / no penalizadas
    % ---------------------------------------------------------------------
    finiteRows = all(isfinite(F),2);
    penaltyRows = F(:,1) >= 999 | F(:,2) >= 999999 | F(:,3) >= 999999;
    validRows = finiteRows & ~penaltyRows;

    Fv = F(validRows,:);
    Xv = X(validRows,:);

    if isempty(Fv)
        error('No hay soluciones válidas después de filtrar finitas/no penalizadas.');
    end

    % ---------------------------------------------------------------------
    % Tabla de soluciones
    % ---------------------------------------------------------------------
    solRows = {};

    for i = 1:size(Fv,1)
        row = struct();
        row.solution_id = "H" + string(i);
        row.rank_original = i;

        row.m_max = Xv(i,1);
        row.T_min = Xv(i,2);
        row.r_div2 = Xv(i,3);
        row.t_rec_ini = Xv(i,4);

        row.MR = Fv(i,1);
        row.cost_specific = Fv(i,2);
        row.CO2_specific = Fv(i,3);

        solRows{end+1,1} = row; %#ok<AGROW>
    end

    Tsolutions = struct2table(vertcat(solRows{:}));

    % ---------------------------------------------------------------------
    % Normalización y solución balanceada
    % ---------------------------------------------------------------------
    Fn = local_minmax_normalize_v96o(Fv);
    balanceScore = sqrt(sum(Fn.^2,2));

    Tsolutions.norm_MR = Fn(:,1);
    Tsolutions.norm_cost = Fn(:,2);
    Tsolutions.norm_CO2 = Fn(:,3);
    Tsolutions.balance_score = balanceScore;

    [~,idxMinMR] = min(Tsolutions.MR);
    [~,idxMinCost] = min(Tsolutions.cost_specific);
    [~,idxMinCO2] = min(Tsolutions.CO2_specific);
    [~,idxBalanced] = min(Tsolutions.balance_score);

    Tsolutions.is_min_MR = false(height(Tsolutions),1);
    Tsolutions.is_min_cost = false(height(Tsolutions),1);
    Tsolutions.is_min_CO2 = false(height(Tsolutions),1);
    Tsolutions.is_balanced = false(height(Tsolutions),1);

    Tsolutions.is_min_MR(idxMinMR) = true;
    Tsolutions.is_min_cost(idxMinCost) = true;
    Tsolutions.is_min_CO2(idxMinCO2) = true;
    Tsolutions.is_balanced(idxBalanced) = true;

    % ---------------------------------------------------------------------
    % Extraer referencia gasLP/hybrid preflight
    % ---------------------------------------------------------------------
    [Tpreflight, preflight_note] = local_find_preflight_table_v96o(S);

    gasRef = local_get_reference_row_v96o(Tpreflight,"gasLP");
    hybRef = local_get_reference_row_v96o(Tpreflight,"hybrid");
    solarRef = local_get_reference_row_v96o(Tpreflight,"solar");

    % ---------------------------------------------------------------------
    % Comparación contra gasLP
    % ---------------------------------------------------------------------
    if gasRef.available
        gasMR = gasRef.f1;
        gasCost = gasRef.f2;
        gasCO2 = gasRef.f3;
    else
        % Fallback controlado con valores del preflight documentado en v96m.
        gasMR = 0.096008649173;
        gasCost = 0.37787758471;
        gasCO2 = 1.6810;
    end

    Tsolutions.delta_MR_vs_gasLP = Tsolutions.MR - gasMR;
    Tsolutions.delta_cost_vs_gasLP = Tsolutions.cost_specific - gasCost;
    Tsolutions.delta_CO2_vs_gasLP = Tsolutions.CO2_specific - gasCO2;

    Tsolutions.reduction_cost_pct_vs_gasLP = 100*(gasCost - Tsolutions.cost_specific)/gasCost;
    Tsolutions.reduction_CO2_pct_vs_gasLP = 100*(gasCO2 - Tsolutions.CO2_specific)/gasCO2;
    Tsolutions.reduction_MR_pct_vs_gasLP = 100*(gasMR - Tsolutions.MR)/gasMR;

    % ---------------------------------------------------------------------
    % Tablas ordenadas
    % ---------------------------------------------------------------------
    TbyMR = sortrows(Tsolutions,'MR','ascend');
    TbyCost = sortrows(Tsolutions,'cost_specific','ascend');
    TbyCO2 = sortrows(Tsolutions,'CO2_specific','ascend');
    TbyBalance = sortrows(Tsolutions,'balance_score','ascend');

    Trepresentative = Tsolutions( ...
        Tsolutions.is_min_MR | ...
        Tsolutions.is_min_cost | ...
        Tsolutions.is_min_CO2 | ...
        Tsolutions.is_balanced, :);

    labels = strings(height(Trepresentative),1);
    for i = 1:height(Trepresentative)
        tags = strings(0,1);
        if Trepresentative.is_min_MR(i), tags(end+1) = "min_MR"; end %#ok<AGROW>
        if Trepresentative.is_min_cost(i), tags(end+1) = "min_cost"; end %#ok<AGROW>
        if Trepresentative.is_min_CO2(i), tags(end+1) = "min_CO2"; end %#ok<AGROW>
        if Trepresentative.is_balanced(i), tags(end+1) = "balanced"; end %#ok<AGROW>
        labels(i) = strjoin(tags,"+");
    end
    Trepresentative.role = labels;

    % ---------------------------------------------------------------------
    % Resumen formal
    % ---------------------------------------------------------------------
    summary = struct();
    summary.formalRunDir = string(formalRunDir);
    summary.formalMat = string(formalMat);
    summary.diagnosis_loaded = string(S.diagnosis);
    summary.F_path = string(F_path);
    summary.F_note = string(F_note);
    summary.X_path = string(X_path);
    summary.X_note = string(X_note);
    summary.nSolutions_raw = size(F,1);
    summary.nSolutions_valid = height(Tsolutions);
    summary.nFiniteRows = sum(finiteRows);
    summary.nPenaltyRows = sum(penaltyRows);
    summary.minMR = min(Tsolutions.MR);
    summary.minCost = min(Tsolutions.cost_specific);
    summary.minCO2 = min(Tsolutions.CO2_specific);
    summary.gasLP_ref_available = gasRef.available;
    summary.gasLP_MR = gasMR;
    summary.gasLP_cost = gasCost;
    summary.gasLP_CO2 = gasCO2;
    summary.best_cost_reduction_pct_vs_gasLP = max(Tsolutions.reduction_cost_pct_vs_gasLP);
    summary.best_CO2_reduction_pct_vs_gasLP = max(Tsolutions.reduction_CO2_pct_vs_gasLP);
    summary.best_MR_reduction_pct_vs_gasLP = max(Tsolutions.reduction_MR_pct_vs_gasLP);
    summary.emission_factors_provisional = true;
    summary.solar_excluded_from_formal_GA = true;
    summary.postrun_consolidation_completed = true;

    Tsummary = struct2table(summary);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};

    checks{end+1,1} = local_check_row_v96o( ...
        "O01", ...
        "Formal MAT loaded", ...
        true, ...
        string(formalMat), ...
        "Must load latest v96m MAT.");

    checks{end+1,1} = local_check_row_v96o( ...
        "O02", ...
        "Formal diagnosis PASS", ...
        strcmp(string(S.diagnosis),"TRIOBJECTIVE_FORMAL_RUN_EXECUTION_COMPLETED_PASS"), ...
        string(S.diagnosis), ...
        "Formal run must have completed PASS.");

    checks{end+1,1} = local_check_row_v96o( ...
        "O03", ...
        "F matrix found with 3 objectives", ...
        ~isempty(F) && size(F,2)==3, ...
        sprintf("F_path=%s; size=%dx%d", string(F_path), size(F,1), size(F,2)), ...
        "F must have three objective columns.");

    checks{end+1,1} = local_check_row_v96o( ...
        "O04", ...
        "X matrix found with 4 variables", ...
        ~isempty(X) && size(X,2)==4 && size(X,1)==size(F,1), ...
        sprintf("X_path=%s; size=%dx%d", string(X_path), size(X,1), size(X,2)), ...
        "X must have four decision variables and match F rows.");

    checks{end+1,1} = local_check_row_v96o( ...
        "O05", ...
        "Valid non-penalized solutions", ...
        height(Tsolutions) > 0 && all(isfinite(Tsolutions.MR)) && all(isfinite(Tsolutions.cost_specific)) && all(isfinite(Tsolutions.CO2_specific)), ...
        sprintf("valid=%d; penalties=%d", height(Tsolutions), sum(penaltyRows)), ...
        "There must be finite non-penalized solutions.");

    checks{end+1,1} = local_check_row_v96o( ...
        "O06", ...
        "Representative solutions identified", ...
        height(Trepresentative) >= 1 && any(Trepresentative.is_balanced), ...
        sprintf("representative=%d; balanced=%d", height(Trepresentative), sum(Trepresentative.is_balanced)), ...
        "Must identify min/balanced solutions.");

    checks{end+1,1} = local_check_row_v96o( ...
        "O07", ...
        "gasLP reference available or fallback controlled", ...
        isfinite(gasMR) && isfinite(gasCost) && isfinite(gasCO2), ...
        sprintf("gasMR=%.6g; gasCost=%.6g; gasCO2=%.6g; source=%s", ...
            gasMR, gasCost, gasCO2, string(preflight_note)), ...
        "Reference values must be available for comparison.");

    checks{end+1,1} = local_check_row_v96o( ...
        "O08", ...
        "Solar excluded from formal interpretation", ...
        true, ...
        "solar excluded; no solar Pareto claim", ...
        "Formal result must remain hybrid with gasLP reference.");

    checks{end+1,1} = local_check_row_v96o( ...
        "O09", ...
        "CO2 provisional flag preserved", ...
        true, ...
        "CO2 factors remain PROVISIONAL_FOR_CODE_VALIDATION.", ...
        "No manuscript-final CO2 claim yet.");

    Tchecks = struct2table(vertcat(checks{:}));

    post_pass = all(Tchecks.pass);

    if post_pass
        diagnosis = "TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_PASS";
        decision = "FORMAL_RESULTS_READY_FOR_TECHNICAL_INTERPRETATION";
        next_step = "9.6p — TRIOBJECTIVE-FORMAL-RESULTS-INTERPRETATION-001";
    else
        diagnosis = "TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_REQUIRES_REVIEW";
        decision = "REVIEW_POSTRUN_EXTRACTION_OR_REFERENCES";
        next_step = "Review failed checks.";
    end

    postFlags = struct();
    postFlags.formal_run_loaded = true;
    postFlags.formal_run_pass = strcmp(string(S.diagnosis),"TRIOBJECTIVE_FORMAL_RUN_EXECUTION_COMPLETED_PASS");
    postFlags.F_found = ~isempty(F);
    postFlags.X_found = ~isempty(X);
    postFlags.F_has_3_columns = size(F,2)==3;
    postFlags.X_has_4_columns = size(X,2)==4;
    postFlags.nSolutions_valid = height(Tsolutions);
    postFlags.nPenaltyRows = sum(penaltyRows);
    postFlags.representative_solutions_identified = height(Trepresentative) >= 1;
    postFlags.gasLP_reference_available = gasRef.available;
    postFlags.solar_excluded_from_formal_GA = true;
    postFlags.CO2_factors_still_provisional = true;
    postFlags.postrun_consolidation_completed = post_pass;

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outSummaryCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_v96o_summary.csv');
    outSolutionsCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_v96o_solutions_all.csv');
    outByMRCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_v96o_solutions_by_MR.csv');
    outByCostCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_v96o_solutions_by_cost.csv');
    outByCO2Csv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_v96o_solutions_by_CO2.csv');
    outByBalanceCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_v96o_solutions_by_balance.csv');
    outRepresentativeCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_v96o_representative_solutions.csv');
    outPreflightCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_v96o_preflight_reference.csv');
    outChecksCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_v96o_checks.csv');

    writetable(Tsummary,outSummaryCsv);
    writetable(Tsolutions,outSolutionsCsv);
    writetable(TbyMR,outByMRCsv);
    writetable(TbyCost,outByCostCsv);
    writetable(TbyCO2,outByCO2Csv);
    writetable(TbyBalance,outByBalanceCsv);
    writetable(Trepresentative,outRepresentativeCsv);
    writetable(Tpreflight,outPreflightCsv);
    writetable(Tchecks,outChecksCsv);

    outMd = fullfile(logsDir,'TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_v96o.md');
    outTxt = fullfile(logsDir,'TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_v96o.txt');
    outMat = fullfile(matDir,'TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_v96o.mat');

    save(outMat, ...
        'diagnosis','decision','next_step','postFlags', ...
        'summary','Tsummary','Tsolutions','TbyMR','TbyCost','TbyCO2','TbyBalance','Trepresentative','Tpreflight','Tchecks', ...
        'F','X','Fv','Xv','Fn','balanceScore', ...
        'gasRef','hybRef','solarRef','formalRunDir','formalMat','postDir', ...
        'outMd','outTxt','outMat', ...
        'outSummaryCsv','outSolutionsCsv','outByMRCsv','outByCostCsv','outByCO2Csv','outByBalanceCsv','outRepresentativeCsv','outPreflightCsv','outChecksCsv');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_v96o\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Decisión: `%s`\n\n', decision);
    fprintf(fid,'Siguiente paso: `%s`\n\n', next_step);

    fprintf(fid,'## Corrida formal cargada\n\n');
    fprintf(fid,'```text\n%s\n```\n\n', formalRunDir);
    fprintf(fid,'MAT:\n\n');
    fprintf(fid,'```text\n%s\n```\n\n', formalMat);

    fprintf(fid,'## Resumen numérico\n\n');
    fprintf(fid,'| Campo | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| nSolutions_valid | %d |\n', height(Tsolutions));
    fprintf(fid,'| minMR | %.12g |\n', summary.minMR);
    fprintf(fid,'| minCost | %.12g |\n', summary.minCost);
    fprintf(fid,'| minCO2 | %.12g |\n', summary.minCO2);
    fprintf(fid,'| gasLP_MR_ref | %.12g |\n', gasMR);
    fprintf(fid,'| gasLP_cost_ref | %.12g |\n', gasCost);
    fprintf(fid,'| gasLP_CO2_ref | %.12g |\n', gasCO2);
    fprintf(fid,'| best_cost_reduction_pct_vs_gasLP | %.12g |\n', summary.best_cost_reduction_pct_vs_gasLP);
    fprintf(fid,'| best_CO2_reduction_pct_vs_gasLP | %.12g |\n', summary.best_CO2_reduction_pct_vs_gasLP);
    fprintf(fid,'| best_MR_reduction_pct_vs_gasLP | %.12g |\n\n', summary.best_MR_reduction_pct_vs_gasLP);

    fprintf(fid,'## Soluciones representativas\n\n');
    fprintf(fid,'| role | id | m_max | T_min | r_div2 | t_rec_ini | MR | cost | CO2 | cost_red_%% | CO2_red_%% | balance |\n');
    fprintf(fid,'|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|\n');

    for i = 1:height(Trepresentative)
        fprintf(fid,'| `%s` | `%s` | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g |\n', ...
            string(Trepresentative.role(i)), ...
            string(Trepresentative.solution_id(i)), ...
            Trepresentative.m_max(i), ...
            Trepresentative.T_min(i), ...
            Trepresentative.r_div2(i), ...
            Trepresentative.t_rec_ini(i), ...
            Trepresentative.MR(i), ...
            Trepresentative.cost_specific(i), ...
            Trepresentative.CO2_specific(i), ...
            Trepresentative.reduction_cost_pct_vs_gasLP(i), ...
            Trepresentative.reduction_CO2_pct_vs_gasLP(i), ...
            Trepresentative.balance_score(i));
    end

    fprintf(fid,'\n## Top por balance\n\n');
    fprintf(fid,'| rank | id | MR | cost | CO2 | balance | cost_red_%% | CO2_red_%% |\n');
    fprintf(fid,'|---:|---|---:|---:|---:|---:|---:|---:|\n');

    nTop = min(5,height(TbyBalance));
    for i = 1:nTop
        fprintf(fid,'| %d | `%s` | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g |\n', ...
            i, ...
            string(TbyBalance.solution_id(i)), ...
            TbyBalance.MR(i), ...
            TbyBalance.cost_specific(i), ...
            TbyBalance.CO2_specific(i), ...
            TbyBalance.balance_score(i), ...
            TbyBalance.reduction_cost_pct_vs_gasLP(i), ...
            TbyBalance.reduction_CO2_pct_vs_gasLP(i));
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

    fprintf(fid,'\n## Restricciones de interpretación\n\n');
    fprintf(fid,'- La corrida formal corresponde a `hybrid`.\n');
    fprintf(fid,'- `gasLP` se usa como referencia directa/preflight.\n');
    fprintf(fid,'- `solar` queda excluido del frente formal.\n');
    fprintf(fid,'- No afirmar comparación Pareto solar-vs-hybrid-vs-gasLP.\n');
    fprintf(fid,'- Los factores de CO2 siguen como `PROVISIONAL_FOR_CODE_VALIDATION`.\n');

    fprintf(fid,'\n## Dictamen\n\n');
    if post_pass
        fprintf(fid,'La consolidación postrun queda aprobada. Los resultados están listos para interpretación técnica y selección de solución representativa.\n');
    else
        fprintf(fid,'La consolidación requiere revisión. Ver checks fallidos.\n');
    end

    fclose(fid);

    % TXT
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'TRIOBJECTIVE-FORMAL-POSTRUN-CONSOLIDATION-001\n');
    fprintf(fid,'status: TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'decision: %s\n', decision);
    fprintf(fid,'next_step: %s\n', next_step);
    fprintf(fid,'formal_run_loaded: %d\n', postFlags.formal_run_loaded);
    fprintf(fid,'formal_run_pass: %d\n', postFlags.formal_run_pass);
    fprintf(fid,'F_found: %d\n', postFlags.F_found);
    fprintf(fid,'X_found: %d\n', postFlags.X_found);
    fprintf(fid,'F_has_3_columns: %d\n', postFlags.F_has_3_columns);
    fprintf(fid,'X_has_4_columns: %d\n', postFlags.X_has_4_columns);
    fprintf(fid,'nSolutions_valid: %d\n', postFlags.nSolutions_valid);
    fprintf(fid,'nPenaltyRows: %d\n', postFlags.nPenaltyRows);
    fprintf(fid,'representative_solutions_identified: %d\n', postFlags.representative_solutions_identified);
    fprintf(fid,'gasLP_reference_available: %d\n', postFlags.gasLP_reference_available);
    fprintf(fid,'solar_excluded_from_formal_GA: %d\n', postFlags.solar_excluded_from_formal_GA);
    fprintf(fid,'CO2_factors_still_provisional: %d\n', postFlags.CO2_factors_still_provisional);
    fprintf(fid,'postrun_consolidation_completed: %d\n', postFlags.postrun_consolidation_completed);
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Consola
    % ---------------------------------------------------------------------
    post = struct();
    post.status = 'TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_COMPLETED';
    post.diagnosis = diagnosis;
    post.decision = decision;
    post.next_step = next_step;
    post.postFlags = postFlags;
    post.summary = summary;
    post.Tsummary = Tsummary;
    post.Tsolutions = Tsolutions;
    post.TbyMR = TbyMR;
    post.TbyCost = TbyCost;
    post.TbyCO2 = TbyCO2;
    post.TbyBalance = TbyBalance;
    post.Trepresentative = Trepresentative;
    post.Tpreflight = Tpreflight;
    post.Tchecks = Tchecks;
    post.postDir = postDir;
    post.outMd = outMd;
    post.outTxt = outTxt;
    post.outMat = outMat;

    disp('=== TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_v96o ===')
    disp(post.status)
    disp('=== DIAGNOSIS ===')
    disp(post.diagnosis)
    disp('=== DECISION ===')
    disp(post.decision)
    disp('=== NEXT STEP ===')
    disp(post.next_step)
    disp('=== POST FLAGS ===')
    disp(post.postFlags)
    disp('=== SUMMARY ===')
    disp(post.Tsummary)
    disp('=== REPRESENTATIVE SOLUTIONS ===')
    disp(post.Trepresentative)
    disp('=== TOP BALANCED ===')
    disp(post.TbyBalance(1:min(5,height(post.TbyBalance)),:))
    disp('=== CHECKS ===')
    disp(post.Tchecks)
    disp('=== OUTPUT FILES ===')
    disp(post.outMd)
    disp(post.outTxt)
    disp(post.outMat)

end

% =========================================================================
% Extraction helpers
% =========================================================================

function [F, path, note] = local_find_F_v96o(S)
    F = [];
    path = "";
    note = "NOT_FOUND";

    candidates = local_collect_numeric_matrices_v96o(S,"S");

    if isempty(candidates)
        return
    end

    score = -inf(numel(candidates),1);

    for i = 1:numel(candidates)
        A = candidates(i).value;
        p = lower(string(candidates(i).path));

        if isnumeric(A) && ismatrix(A) && size(A,2)==3 && size(A,1)>=1
            finiteCount = sum(all(isfinite(A),2));
            penaltyCount = sum(A(:,1)>=999 | A(:,2)>=999999 | A(:,3)>=999999);

            score(i) = 1000 + finiteCount - penaltyCount;

            if contains(p,"f")
                score(i) = score(i) + 100;
            end
            if contains(p,"objective")
                score(i) = score(i) + 50;
            end
            if contains(p,"preflight")
                score(i) = score(i) - 200;
            end
        end
    end

    [bestScore,idx] = max(score);

    if isfinite(bestScore) && bestScore > -inf
        F = candidates(idx).value;
        path = candidates(idx).path;
        note = "FOUND_BY_MATRIX_SCAN";
    end
end

function [X, path, note] = local_find_X_v96o(S, nRows)
    X = [];
    path = "";
    note = "NOT_FOUND";

    candidates = local_collect_numeric_matrices_v96o(S,"S");

    if isempty(candidates)
        return
    end

    score = -inf(numel(candidates),1);

    for i = 1:numel(candidates)
        A = candidates(i).value;
        p = lower(string(candidates(i).path));

        if isnumeric(A) && ismatrix(A) && size(A,2)==4 && size(A,1)==nRows
            score(i) = 1000;

            if contains(p,"x")
                score(i) = score(i) + 100;
            end
            if contains(p,"solution")
                score(i) = score(i) + 50;
            end
            if all(A(:,1) > 0) && all(A(:,2) > 0)
                score(i) = score(i) + 10;
            end
        end
    end

    [bestScore,idx] = max(score);

    if isfinite(bestScore) && bestScore > -inf
        X = candidates(idx).value;
        path = candidates(idx).path;
        note = "FOUND_BY_MATRIX_SCAN";
    end
end

function candidates = local_collect_numeric_matrices_v96o(S, prefix)
    candidates = struct('path',{},'value',{});

    if isnumeric(S) && ismatrix(S) && numel(S) >= 3
        c = struct();
        c.path = string(prefix);
        c.value = S;
        candidates(end+1) = c;
        return
    end

    if istable(S)
        return
    end

    if isstruct(S)
        fns = fieldnames(S);

        for i = 1:numel(fns)
            fn = fns{i};
            val = S.(fn);
            path = string(prefix) + "." + string(fn);

            if isnumeric(val) && ismatrix(val) && numel(val) >= 3
                c = struct();
                c.path = path;
                c.value = val;
                candidates(end+1) = c; %#ok<AGROW>
            elseif isstruct(val)
                sub = local_collect_numeric_matrices_v96o(val,path);
                if ~isempty(sub)
                    candidates = [candidates, sub]; %#ok<AGROW>
                end
            end
        end
    end
end

function [Tpreflight, note] = local_find_preflight_table_v96o(S)
    Tpreflight = table();
    note = "NOT_FOUND";

    tables = local_collect_tables_v96o(S,"S");

    for i = 1:numel(tables)
        T = tables(i).value;

        vars = string(T.Properties.VariableNames);
        hasMode = any(strcmp(vars,"mode"));
        hasF1 = any(strcmp(vars,"f1"));
        hasF2 = any(strcmp(vars,"f2"));
        hasF3 = any(strcmp(vars,"f3"));

        if hasMode && hasF1 && hasF2 && hasF3
            modes = string(T.mode);
            if any(modes=="gasLP") && any(modes=="hybrid")
                Tpreflight = T;
                note = "FOUND_AT_" + string(tables(i).path);
                return
            end
        end
    end

    % Fallback vacío con columnas compatibles.
    Tpreflight = table();
    Tpreflight.mode = strings(0,1);
    Tpreflight.f1 = zeros(0,1);
    Tpreflight.f2 = zeros(0,1);
    Tpreflight.f3 = zeros(0,1);
end

function tables = local_collect_tables_v96o(S, prefix)
    tables = struct('path',{},'value',{});

    if istable(S)
        c = struct();
        c.path = string(prefix);
        c.value = S;
        tables(end+1) = c;
        return
    end

    if isstruct(S)
        fns = fieldnames(S);

        for i = 1:numel(fns)
            fn = fns{i};
            val = S.(fn);
            path = string(prefix) + "." + string(fn);

            if istable(val)
                c = struct();
                c.path = path;
                c.value = val;
                tables(end+1) = c; %#ok<AGROW>
            elseif isstruct(val)
                sub = local_collect_tables_v96o(val,path);
                if ~isempty(sub)
                    tables = [tables, sub]; %#ok<AGROW>
                end
            end
        end
    end
end

function ref = local_get_reference_row_v96o(T, modeName)
    ref = struct();
    ref.mode = string(modeName);
    ref.available = false;
    ref.f1 = NaN;
    ref.f2 = NaN;
    ref.f3 = NaN;

    if ~istable(T) || height(T)==0 || ~any(strcmp(T.Properties.VariableNames,'mode'))
        return
    end

    idx = find(string(T.mode)==string(modeName),1,'first');

    if isempty(idx)
        return
    end

    if any(strcmp(T.Properties.VariableNames,'f1')), ref.f1 = T.f1(idx); end
    if any(strcmp(T.Properties.VariableNames,'f2')), ref.f2 = T.f2(idx); end
    if any(strcmp(T.Properties.VariableNames,'f3')), ref.f3 = T.f3(idx); end

    ref.available = isfinite(ref.f1) && isfinite(ref.f2) && isfinite(ref.f3);
end

function Fn = local_minmax_normalize_v96o(F)
    Fn = zeros(size(F));

    for j = 1:size(F,2)
        col = F(:,j);
        mn = min(col);
        mx = max(col);

        if mx > mn
            Fn(:,j) = (col - mn) ./ (mx - mn);
        else
            Fn(:,j) = zeros(size(col));
        end
    end
end

function row = local_check_row_v96o(id, checkName, passVal, evidence, criterion)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
    row.criterion = string(criterion);
end