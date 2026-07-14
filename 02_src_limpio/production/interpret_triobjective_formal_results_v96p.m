function interp = interpret_triobjective_formal_results_v96p()
% INTERPRET_TRIOBJECTIVE_FORMAL_RESULTS_v96p
% 9.6p — TRIOBJECTIVE-FORMAL-RESULTS-INTERPRETATION-001
%
% Objetivo:
%   Interpretar técnicamente el frente formal hybrid v96m consolidado en v96o.
%
% Este paso:
%   - NO ejecuta gamultiobj.
%   - NO modifica fuentes protegidas.
%   - Carga la consolidación v96o.
%   - Separa soluciones admisibles por MR < 0.1.
%   - Selecciona solución recomendada.
%   - Emite dictamen técnico.
%   - Genera CSV, MD, TXT y MAT.
%
% Criterio operativo:
%   MR < 0.1 se toma como criterio de secado aceptable.
%
% Uso:
%   interp = interpret_triobjective_formal_results_v96p();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    MR_acceptance = 0.10;

    % ---------------------------------------------------------------------
    % Cargar consolidación v96o más reciente
    % ---------------------------------------------------------------------
    postBaseDir = fullfile(rootDir,'05_runs','triobjective_formal_postrun_consolidation_v96o');

    if ~isfolder(postBaseDir)
        error('No existe postBaseDir: %s', postBaseDir);
    end

    d = dir(postBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_v96o_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró consolidación v96o.');
    end

    [~,idxPost] = max([d.datenum]);
    postDirPrev = fullfile(postBaseDir,d(idxPost).name);
    postMat = fullfile(postDirPrev,'mat','TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_v96o.mat');

    if ~isfile(postMat)
        error('No existe MAT v96o: %s', postMat);
    end

    S = load(postMat);

    if ~strcmp(string(S.diagnosis),"TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_PASS")
        error('La consolidación v96o no está en PASS. Diagnosis: %s', string(S.diagnosis));
    end

    Tsolutions = S.Tsolutions;
    Trepresentative = S.Trepresentative;
    Tsummary = S.Tsummary;
    Tpreflight = S.Tpreflight;

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    interpBaseDir = fullfile(rootDir,'05_runs','triobjective_formal_results_interpretation_v96p');
    interpDir = fullfile(interpBaseDir,['TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_v96p_' timestamp]);

    logsDir = fullfile(interpDir,'logs');
    tablesDir = fullfile(interpDir,'tables');
    matDir = fullfile(interpDir,'mat');

    if ~isfolder(interpBaseDir), mkdir(interpBaseDir); end
    if ~isfolder(interpDir), mkdir(interpDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Clasificar soluciones admisibles
    % ---------------------------------------------------------------------
    Tsolutions.acceptable_MR = Tsolutions.MR < MR_acceptance;
    Tsolutions.operationally_admissible = Tsolutions.acceptable_MR;

    inadmissible_reason = strings(height(Tsolutions),1);
    for i = 1:height(Tsolutions)
        if Tsolutions.acceptable_MR(i)
            inadmissible_reason(i) = "";
        else
            inadmissible_reason(i) = "MR >= 0.1; insufficient drying for operational recommendation";
        end
    end
    Tsolutions.inadmissible_reason = inadmissible_reason;

    Tadmissible = Tsolutions(Tsolutions.operationally_admissible,:);
    Tinadmissible = Tsolutions(~Tsolutions.operationally_admissible,:);

    if isempty(Tadmissible)
        error('No hay soluciones admisibles por MR < %.4g.', MR_acceptance);
    end

    % ---------------------------------------------------------------------
    % Selección recomendada
    % ---------------------------------------------------------------------
    % Regla:
    %   1) Filtrar MR < 0.1.
    %   2) Elegir menor balance_score entre admisibles.
    %   3) En empate, menor CO2.
    %   4) En empate, menor costo.
    TadmissibleSorted = sortrows(Tadmissible, {'balance_score','CO2_specific','cost_specific'}, {'ascend','ascend','ascend'});
    Trecommended = TadmissibleSorted(1,:);

    recommended_id = string(Trecommended.solution_id(1));

    % Alternativas admisibles
    TadmByMR = sortrows(Tadmissible,'MR','ascend');
    TadmByCost = sortrows(Tadmissible,'cost_specific','ascend');
    TadmByCO2 = sortrows(Tadmissible,'CO2_specific','ascend');
    TadmByBalance = sortrows(Tadmissible,'balance_score','ascend');

    TbestAdmissible = unique([ ...
        TadmByMR(1,:); ...
        TadmByCost(1,:); ...
        TadmByCO2(1,:); ...
        TadmByBalance(1,:) ...
        ], 'rows');

    role = strings(height(TbestAdmissible),1);
    for i = 1:height(TbestAdmissible)
        tags = strings(0,1);

        if string(TbestAdmissible.solution_id(i)) == string(TadmByMR.solution_id(1))
            tags(end+1) = "best_admissible_MR"; %#ok<AGROW>
        end

        if string(TbestAdmissible.solution_id(i)) == string(TadmByCost.solution_id(1))
            tags(end+1) = "best_admissible_cost"; %#ok<AGROW>
        end

        if string(TbestAdmissible.solution_id(i)) == string(TadmByCO2.solution_id(1))
            tags(end+1) = "best_admissible_CO2"; %#ok<AGROW>
        end

        if string(TbestAdmissible.solution_id(i)) == string(TadmByBalance.solution_id(1))
            tags(end+1) = "recommended_balance_admissible"; %#ok<AGROW>
        end

        role(i) = strjoin(tags,"+");
    end
    TbestAdmissible.role_admissible = role;

    % ---------------------------------------------------------------------
    % Referencia gasLP
    % ---------------------------------------------------------------------
    gasRef = local_get_reference_row_v96p(Tpreflight,"gasLP");
    hybRef = local_get_reference_row_v96p(Tpreflight,"hybrid");
    solarRef = local_get_reference_row_v96p(Tpreflight,"solar");

    % ---------------------------------------------------------------------
    % Dictamen por solución representativa global
    % ---------------------------------------------------------------------
    TrepresentativeInterp = Trepresentative;
    TrepresentativeInterp.acceptable_MR = TrepresentativeInterp.MR < MR_acceptance;

    interpretation = strings(height(TrepresentativeInterp),1);

    for i = 1:height(TrepresentativeInterp)
        sid = string(TrepresentativeInterp.solution_id(i));
        role_i = string(TrepresentativeInterp.role(i));
        mr = TrepresentativeInterp.MR(i);
        costRed = TrepresentativeInterp.reduction_cost_pct_vs_gasLP(i);
        co2Red = TrepresentativeInterp.reduction_CO2_pct_vs_gasLP(i);

        if mr >= MR_acceptance
            interpretation(i) = role_i + ": not recommended; MR >= 0.1 despite economic/environmental advantage.";
        elseif sid == recommended_id
            interpretation(i) = role_i + ": recommended; admissible drying and simultaneous cost/CO2 improvement vs gasLP.";
        elseif costRed < 0 || co2Red < 0
            interpretation(i) = role_i + ": admissible drying but worsens cost and/or CO2 vs gasLP.";
        else
            interpretation(i) = role_i + ": admissible alternative; not selected because balance score is less favorable.";
        end
    end

    TrepresentativeInterp.interpretation = interpretation;

    % ---------------------------------------------------------------------
    % Texto técnico sintético
    % ---------------------------------------------------------------------
    recommendedText = sprintf([ ...
        'Recommended solution %s: m_max=%.6g, T_min=%.6g, r_div2=%.6g, t_rec_ini=%.6g, ' ...
        'MR=%.6g, cost_specific=%.6g, CO2_specific=%.6g. ' ...
        'Compared with gasLP reference: cost reduction=%.4g%%, CO2 reduction=%.4g%%, MR reduction=%.4g%%.' ], ...
        string(Trecommended.solution_id(1)), ...
        Trecommended.m_max(1), ...
        Trecommended.T_min(1), ...
        Trecommended.r_div2(1), ...
        Trecommended.t_rec_ini(1), ...
        Trecommended.MR(1), ...
        Trecommended.cost_specific(1), ...
        Trecommended.CO2_specific(1), ...
        Trecommended.reduction_cost_pct_vs_gasLP(1), ...
        Trecommended.reduction_CO2_pct_vs_gasLP(1), ...
        Trecommended.reduction_MR_pct_vs_gasLP(1));

    % ---------------------------------------------------------------------
    % Scope / claims
    % ---------------------------------------------------------------------
    claimRows = {};

    claimRows{end+1,1} = local_claim_row_v96p( ...
        "C01", ...
        "Allowed", ...
        "The formal optimization is triobjective for hybrid mode only.", ...
        true);

    claimRows{end+1,1} = local_claim_row_v96p( ...
        "C02", ...
        "Allowed", ...
        "gasLP is used as direct reference/preflight comparison.", ...
        true);

    claimRows{end+1,1} = local_claim_row_v96p( ...
        "C03", ...
        "Allowed", ...
        "H2 is the recommended operational compromise among admissible solutions.", ...
        true);

    claimRows{end+1,1} = local_claim_row_v96p( ...
        "C04", ...
        "Allowed with caveat", ...
        "CO2 reductions are computational-validation results using provisional emission factors.", ...
        true);

    claimRows{end+1,1} = local_claim_row_v96p( ...
        "C05", ...
        "Forbidden", ...
        "Do not claim a full solar-vs-hybrid-vs-gasLP Pareto comparison.", ...
        false);

    claimRows{end+1,1} = local_claim_row_v96p( ...
        "C06", ...
        "Forbidden", ...
        "Do not present solar endpoint MR=1000 or NaN values as physical solar performance.", ...
        false);

    Tclaims = struct2table(vertcat(claimRows{:}));

    % ---------------------------------------------------------------------
    % Resumen
    % ---------------------------------------------------------------------
    summary = struct();
    summary.postMat = string(postMat);
    summary.MR_acceptance = MR_acceptance;
    summary.nSolutions_total = height(Tsolutions);
    summary.nSolutions_admissible = height(Tadmissible);
    summary.nSolutions_inadmissible = height(Tinadmissible);
    summary.recommended_solution_id = string(Trecommended.solution_id(1));
    summary.recommended_MR = Trecommended.MR(1);
    summary.recommended_cost_specific = Trecommended.cost_specific(1);
    summary.recommended_CO2_specific = Trecommended.CO2_specific(1);
    summary.recommended_m_max = Trecommended.m_max(1);
    summary.recommended_T_min = Trecommended.T_min(1);
    summary.recommended_r_div2 = Trecommended.r_div2(1);
    summary.recommended_t_rec_ini = Trecommended.t_rec_ini(1);
    summary.recommended_cost_reduction_pct_vs_gasLP = Trecommended.reduction_cost_pct_vs_gasLP(1);
    summary.recommended_CO2_reduction_pct_vs_gasLP = Trecommended.reduction_CO2_pct_vs_gasLP(1);
    summary.recommended_MR_reduction_pct_vs_gasLP = Trecommended.reduction_MR_pct_vs_gasLP(1);
    summary.gasLP_MR = gasRef.f1;
    summary.gasLP_cost = gasRef.f2;
    summary.gasLP_CO2 = gasRef.f3;
    summary.solar_excluded_from_formal_GA = true;
    summary.CO2_factors_still_provisional = true;

    Tsummary = struct2table(summary);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};

    checks{end+1,1} = local_check_row_v96p( ...
        "P01", ...
        "Postrun v96o loaded", ...
        true, ...
        string(postMat), ...
        "Must load v96o consolidation.");

    checks{end+1,1} = local_check_row_v96p( ...
        "P02", ...
        "Postrun v96o PASS", ...
        strcmp(string(S.diagnosis),"TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_PASS"), ...
        string(S.diagnosis), ...
        "v96o must be PASS.");

    checks{end+1,1} = local_check_row_v96p( ...
        "P03", ...
        "Admissible solutions exist", ...
        height(Tadmissible) >= 1, ...
        sprintf("admissible=%d of %d with MR < %.4g", height(Tadmissible), height(Tsolutions), MR_acceptance), ...
        "At least one solution must satisfy drying criterion.");

    checks{end+1,1} = local_check_row_v96p( ...
        "P04", ...
        "Recommended solution is admissible", ...
        Trecommended.MR(1) < MR_acceptance, ...
        sprintf("recommended=%s; MR=%.6g", string(Trecommended.solution_id(1)), Trecommended.MR(1)), ...
        "Recommended solution must satisfy MR < 0.1.");

    checks{end+1,1} = local_check_row_v96p( ...
        "P05", ...
        "Recommended improves cost vs gasLP", ...
        Trecommended.reduction_cost_pct_vs_gasLP(1) > 0, ...
        sprintf("cost reduction=%.6g%%", Trecommended.reduction_cost_pct_vs_gasLP(1)), ...
        "Recommended solution should reduce cost vs gasLP.");

    checks{end+1,1} = local_check_row_v96p( ...
        "P06", ...
        "Recommended improves CO2 vs gasLP", ...
        Trecommended.reduction_CO2_pct_vs_gasLP(1) > 0, ...
        sprintf("CO2 reduction=%.6g%%", Trecommended.reduction_CO2_pct_vs_gasLP(1)), ...
        "Recommended solution should reduce CO2 vs gasLP.");

    checks{end+1,1} = local_check_row_v96p( ...
        "P07", ...
        "Solar exclusion preserved", ...
        true, ...
        "solar excluded from formal interpretation; no solar Pareto claim", ...
        "Solar must remain outside formal GA interpretation.");

    checks{end+1,1} = local_check_row_v96p( ...
        "P08", ...
        "CO2 provisional flag preserved", ...
        true, ...
        "CO2 factors remain PROVISIONAL_FOR_CODE_VALIDATION.", ...
        "No manuscript-final CO2 claim yet.");

    Tchecks = struct2table(vertcat(checks{:}));

    interp_pass = all(Tchecks.pass);

    if interp_pass
        diagnosis = "TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_PASS";
        decision = "RECOMMENDED_SOLUTION_SELECTED";
        next_step = "9.6q — TRIOBJECTIVE-FORMAL-RESULTS-REPORT-PACKAGE-001";
    else
        diagnosis = "TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_REQUIRES_REVIEW";
        decision = "REVIEW_ADMISSIBILITY_OR_RECOMMENDATION";
        next_step = "Review failed checks.";
    end

    interpFlags = struct();
    interpFlags.postrun_loaded = true;
    interpFlags.postrun_pass = strcmp(string(S.diagnosis),"TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_PASS");
    interpFlags.MR_acceptance = MR_acceptance;
    interpFlags.nSolutions_total = height(Tsolutions);
    interpFlags.nSolutions_admissible = height(Tadmissible);
    interpFlags.nSolutions_inadmissible = height(Tinadmissible);
    interpFlags.recommended_solution_selected = interp_pass;
    interpFlags.recommended_solution_id = string(Trecommended.solution_id(1));
    interpFlags.recommended_MR = Trecommended.MR(1);
    interpFlags.recommended_cost_reduction_pct_vs_gasLP = Trecommended.reduction_cost_pct_vs_gasLP(1);
    interpFlags.recommended_CO2_reduction_pct_vs_gasLP = Trecommended.reduction_CO2_pct_vs_gasLP(1);
    interpFlags.solar_excluded_from_formal_GA = true;
    interpFlags.CO2_factors_still_provisional = true;

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outSummaryCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_v96p_summary.csv');
    outAllCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_v96p_all_solutions_classified.csv');
    outAdmissibleCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_v96p_admissible_solutions.csv');
    outInadmissibleCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_v96p_inadmissible_solutions.csv');
    outRecommendedCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_v96p_recommended_solution.csv');
    outBestAdmissibleCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_v96p_best_admissible_solutions.csv');
    outRepresentativeCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_v96p_representative_interpretation.csv');
    outClaimsCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_v96p_claims_scope.csv');
    outChecksCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_v96p_checks.csv');

    writetable(Tsummary,outSummaryCsv);
    writetable(Tsolutions,outAllCsv);
    writetable(Tadmissible,outAdmissibleCsv);
    writetable(Tinadmissible,outInadmissibleCsv);
    writetable(Trecommended,outRecommendedCsv);
    writetable(TbestAdmissible,outBestAdmissibleCsv);
    writetable(TrepresentativeInterp,outRepresentativeCsv);
    writetable(Tclaims,outClaimsCsv);
    writetable(Tchecks,outChecksCsv);

    outMd = fullfile(logsDir,'TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_v96p.md');
    outTxt = fullfile(logsDir,'TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_v96p.txt');
    outMat = fullfile(matDir,'TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_v96p.mat');

    save(outMat, ...
        'diagnosis','decision','next_step','interpFlags', ...
        'summary','Tsummary','Tsolutions','Tadmissible','Tinadmissible','Trecommended','TbestAdmissible','TrepresentativeInterp','Tclaims','Tchecks', ...
        'gasRef','hybRef','solarRef','recommendedText','postDirPrev','postMat','interpDir', ...
        'outMd','outTxt','outMat', ...
        'outSummaryCsv','outAllCsv','outAdmissibleCsv','outInadmissibleCsv','outRecommendedCsv','outBestAdmissibleCsv','outRepresentativeCsv','outClaimsCsv','outChecksCsv');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_v96p\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Decisión: `%s`\n\n', decision);
    fprintf(fid,'Siguiente paso: `%s`\n\n', next_step);

    fprintf(fid,'## Criterio de admisibilidad\n\n');
    fprintf(fid,'Se considera solución operacionalmente admisible si:\n\n');
    fprintf(fid,'```text\nMR < %.4g\n```\n\n', MR_acceptance);

    fprintf(fid,'Soluciones admisibles: `%d` de `%d`.\n\n', height(Tadmissible), height(Tsolutions));

    fprintf(fid,'## Solución recomendada\n\n');
    fprintf(fid,'```text\n%s\n```\n\n', recommendedText);

    fprintf(fid,'| Campo | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| solution_id | `%s` |\n', string(Trecommended.solution_id(1)));
    fprintf(fid,'| m_max | %.12g |\n', Trecommended.m_max(1));
    fprintf(fid,'| T_min | %.12g |\n', Trecommended.T_min(1));
    fprintf(fid,'| r_div2 | %.12g |\n', Trecommended.r_div2(1));
    fprintf(fid,'| t_rec_ini | %.12g |\n', Trecommended.t_rec_ini(1));
    fprintf(fid,'| MR | %.12g |\n', Trecommended.MR(1));
    fprintf(fid,'| cost_specific | %.12g |\n', Trecommended.cost_specific(1));
    fprintf(fid,'| CO2_specific | %.12g |\n', Trecommended.CO2_specific(1));
    fprintf(fid,'| cost_reduction_pct_vs_gasLP | %.12g |\n', Trecommended.reduction_cost_pct_vs_gasLP(1));
    fprintf(fid,'| CO2_reduction_pct_vs_gasLP | %.12g |\n', Trecommended.reduction_CO2_pct_vs_gasLP(1));
    fprintf(fid,'| MR_reduction_pct_vs_gasLP | %.12g |\n\n', Trecommended.reduction_MR_pct_vs_gasLP(1));

    fprintf(fid,'## Mejores soluciones admisibles\n\n');
    fprintf(fid,'| role | id | MR | cost | CO2 | cost_red_%% | CO2_red_%% | MR_red_%% | balance |\n');
    fprintf(fid,'|---|---|---:|---:|---:|---:|---:|---:|---:|\n');

    for i = 1:height(TbestAdmissible)
        fprintf(fid,'| `%s` | `%s` | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g |\n', ...
            string(TbestAdmissible.role_admissible(i)), ...
            string(TbestAdmissible.solution_id(i)), ...
            TbestAdmissible.MR(i), ...
            TbestAdmissible.cost_specific(i), ...
            TbestAdmissible.CO2_specific(i), ...
            TbestAdmissible.reduction_cost_pct_vs_gasLP(i), ...
            TbestAdmissible.reduction_CO2_pct_vs_gasLP(i), ...
            TbestAdmissible.reduction_MR_pct_vs_gasLP(i), ...
            TbestAdmissible.balance_score(i));
    end

    fprintf(fid,'\n## Interpretación de soluciones representativas\n\n');
    fprintf(fid,'| role | id | MR | cost | CO2 | acceptable_MR | interpretación |\n');
    fprintf(fid,'|---|---|---:|---:|---:|---:|---|\n');

    for i = 1:height(TrepresentativeInterp)
        fprintf(fid,'| `%s` | `%s` | %.12g | %.12g | %.12g | %d | %s |\n', ...
            string(TrepresentativeInterp.role(i)), ...
            string(TrepresentativeInterp.solution_id(i)), ...
            TrepresentativeInterp.MR(i), ...
            TrepresentativeInterp.cost_specific(i), ...
            TrepresentativeInterp.CO2_specific(i), ...
            TrepresentativeInterp.acceptable_MR(i), ...
            string(TrepresentativeInterp.interpretation(i)));
    end

    fprintf(fid,'\n## Soluciones inadmisibles por humedad\n\n');
    fprintf(fid,'| id | MR | cost | CO2 | razón |\n');
    fprintf(fid,'|---|---:|---:|---:|---|\n');

    for i = 1:height(Tinadmissible)
        fprintf(fid,'| `%s` | %.12g | %.12g | %.12g | %s |\n', ...
            string(Tinadmissible.solution_id(i)), ...
            Tinadmissible.MR(i), ...
            Tinadmissible.cost_specific(i), ...
            Tinadmissible.CO2_specific(i), ...
            string(Tinadmissible.inadmissible_reason(i)));
    end

    fprintf(fid,'\n## Alcance de afirmaciones\n\n');
    fprintf(fid,'| ID | Tipo | Afirmación | Usar |\n');
    fprintf(fid,'|---|---|---|---:|\n');

    for i = 1:height(Tclaims)
        fprintf(fid,'| `%s` | `%s` | %s | %d |\n', ...
            string(Tclaims.id(i)), ...
            string(Tclaims.claim_type(i)), ...
            string(Tclaims.claim(i)), ...
            Tclaims.allowed(i));
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

    fprintf(fid,'\n## Dictamen técnico\n\n');
    if interp_pass
        fprintf(fid,'La solución recomendada es `%s`. Es admisible por humedad, mejora simultáneamente costo y CO2 frente a gasLP y representa el compromiso más equilibrado del frente formal híbrido. Las soluciones de mínimo costo y mínimo CO2 no se recomiendan como operación principal porque no cumplen `MR < %.4g`. La solución de mínimo MR tampoco se recomienda como operación base porque mejora el secado pero empeora costo y CO2 frente a gasLP.\n\n', ...
            string(Trecommended.solution_id(1)), MR_acceptance);
        fprintf(fid,'La interpretación queda limitada al modo híbrido con gasLP como referencia. Solar queda excluido del frente formal y los factores de CO2 siguen siendo provisionales.\n');
    else
        fprintf(fid,'La interpretación requiere revisión. Ver checks fallidos.\n');
    end

    fclose(fid);

    % TXT
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'TRIOBJECTIVE-FORMAL-RESULTS-INTERPRETATION-001\n');
    fprintf(fid,'status: TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'decision: %s\n', decision);
    fprintf(fid,'next_step: %s\n', next_step);
    fprintf(fid,'postrun_loaded: %d\n', interpFlags.postrun_loaded);
    fprintf(fid,'postrun_pass: %d\n', interpFlags.postrun_pass);
    fprintf(fid,'MR_acceptance: %.12g\n', interpFlags.MR_acceptance);
    fprintf(fid,'nSolutions_total: %d\n', interpFlags.nSolutions_total);
    fprintf(fid,'nSolutions_admissible: %d\n', interpFlags.nSolutions_admissible);
    fprintf(fid,'nSolutions_inadmissible: %d\n', interpFlags.nSolutions_inadmissible);
    fprintf(fid,'recommended_solution_selected: %d\n', interpFlags.recommended_solution_selected);
    fprintf(fid,'recommended_solution_id: %s\n', interpFlags.recommended_solution_id);
    fprintf(fid,'recommended_MR: %.12g\n', interpFlags.recommended_MR);
    fprintf(fid,'recommended_cost_reduction_pct_vs_gasLP: %.12g\n', interpFlags.recommended_cost_reduction_pct_vs_gasLP);
    fprintf(fid,'recommended_CO2_reduction_pct_vs_gasLP: %.12g\n', interpFlags.recommended_CO2_reduction_pct_vs_gasLP);
    fprintf(fid,'solar_excluded_from_formal_GA: %d\n', interpFlags.solar_excluded_from_formal_GA);
    fprintf(fid,'CO2_factors_still_provisional: %d\n', interpFlags.CO2_factors_still_provisional);
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Consola
    % ---------------------------------------------------------------------
    interp = struct();
    interp.status = 'TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_COMPLETED';
    interp.diagnosis = diagnosis;
    interp.decision = decision;
    interp.next_step = next_step;
    interp.interpFlags = interpFlags;
    interp.summary = summary;
    interp.Tsummary = Tsummary;
    interp.Tsolutions = Tsolutions;
    interp.Tadmissible = Tadmissible;
    interp.Tinadmissible = Tinadmissible;
    interp.Trecommended = Trecommended;
    interp.TbestAdmissible = TbestAdmissible;
    interp.TrepresentativeInterp = TrepresentativeInterp;
    interp.Tclaims = Tclaims;
    interp.Tchecks = Tchecks;
    interp.recommendedText = recommendedText;
    interp.interpDir = interpDir;
    interp.outMd = outMd;
    interp.outTxt = outTxt;
    interp.outMat = outMat;

    disp('=== TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_v96p ===')
    disp(interp.status)
    disp('=== DIAGNOSIS ===')
    disp(interp.diagnosis)
    disp('=== DECISION ===')
    disp(interp.decision)
    disp('=== NEXT STEP ===')
    disp(interp.next_step)
    disp('=== INTERP FLAGS ===')
    disp(interp.interpFlags)
    disp('=== SUMMARY ===')
    disp(interp.Tsummary)
    disp('=== RECOMMENDED SOLUTION ===')
    disp(interp.Trecommended)
    disp('=== BEST ADMISSIBLE ===')
    disp(interp.TbestAdmissible)
    disp('=== REPRESENTATIVE INTERPRETATION ===')
    disp(interp.TrepresentativeInterp)
    disp('=== CHECKS ===')
    disp(interp.Tchecks)
    disp('=== OUTPUT FILES ===')
    disp(interp.outMd)
    disp(interp.outTxt)
    disp(interp.outMat)

end

% =========================================================================
% Helpers
% =========================================================================

function ref = local_get_reference_row_v96p(T, modeName)
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

function row = local_claim_row_v96p(id, claim_type, claim, allowed)
    row = struct();
    row.id = string(id);
    row.claim_type = string(claim_type);
    row.claim = string(claim);
    row.allowed = logical(allowed);
end

function row = local_check_row_v96p(id, checkName, passVal, evidence, criterion)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
    row.criterion = string(criterion);
end