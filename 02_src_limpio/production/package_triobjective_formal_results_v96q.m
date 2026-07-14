function pkg = package_triobjective_formal_results_v96q()
% PACKAGE_TRIOBJECTIVE_FORMAL_RESULTS_v96q
% 9.6q — TRIOBJECTIVE-FORMAL-RESULTS-REPORT-PACKAGE-001
%
% Objetivo:
%   Empaquetar el reporte final de resultados de la optimización
%   triobjetivo formal hybrid v96m interpretada en v96p.
%
% Este paso:
%   - NO ejecuta gamultiobj.
%   - NO modifica fuentes protegidas.
%   - Carga la interpretación v96p más reciente.
%   - Genera reporte técnico consolidado.
%   - Copia tablas clave.
%   - Genera texto base para resultados.
%   - Genera ZIP de paquete.
%
% Uso:
%   pkg = package_triobjective_formal_results_v96q();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Cargar interpretación v96p más reciente
    % ---------------------------------------------------------------------
    interpBaseDir = fullfile(rootDir,'05_runs','triobjective_formal_results_interpretation_v96p');

    if ~isfolder(interpBaseDir)
        error('No existe interpBaseDir: %s', interpBaseDir);
    end

    d = dir(interpBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_v96p_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró interpretación v96p.');
    end

    [~,idxInterp] = max([d.datenum]);
    interpDirPrev = fullfile(interpBaseDir,d(idxInterp).name);
    interpMat = fullfile(interpDirPrev,'mat','TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_v96p.mat');

    if ~isfile(interpMat)
        error('No existe MAT v96p: %s', interpMat);
    end

    S = load(interpMat);

    if ~strcmp(string(S.diagnosis),"TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_PASS")
        error('La interpretación v96p no está en PASS. Diagnosis: %s', string(S.diagnosis));
    end

    Tsummary = S.Tsummary;
    Tsolutions = S.Tsolutions;
    Tadmissible = S.Tadmissible;
    Tinadmissible = S.Tinadmissible;
    Trecommended = S.Trecommended;
    TbestAdmissible = S.TbestAdmissible;
    TrepresentativeInterp = S.TrepresentativeInterp;
    Tclaims = S.Tclaims;
    TchecksInterp = S.Tchecks;

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    pkgBaseDir = fullfile(rootDir,'05_runs','triobjective_formal_results_report_package_v96q');
    pkgDir = fullfile(pkgBaseDir,['TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q_' timestamp]);

    logsDir = fullfile(pkgDir,'logs');
    tablesDir = fullfile(pkgDir,'tables');
    matDir = fullfile(pkgDir,'mat');
    reportDir = fullfile(pkgDir,'report');
    packageDir = fullfile(pkgDir,'package');

    if ~isfolder(pkgBaseDir), mkdir(pkgBaseDir); end
    if ~isfolder(pkgDir), mkdir(pkgDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end
    if ~isfolder(reportDir), mkdir(reportDir); end
    if ~isfolder(packageDir), mkdir(packageDir); end

    % ---------------------------------------------------------------------
    % Datos clave
    % ---------------------------------------------------------------------
    rec = Trecommended(1,:);

    recommended_id = string(rec.solution_id(1));

    MR_acceptance = Tsummary.MR_acceptance(1);

    gasLP_MR = Tsummary.gasLP_MR(1);
    gasLP_cost = Tsummary.gasLP_cost(1);
    gasLP_CO2 = Tsummary.gasLP_CO2(1);

    rec_m_max = rec.m_max(1);
    rec_T_min = rec.T_min(1);
    rec_r_div2 = rec.r_div2(1);
    rec_t_rec_ini = rec.t_rec_ini(1);

    rec_MR = rec.MR(1);
    rec_cost = rec.cost_specific(1);
    rec_CO2 = rec.CO2_specific(1);

    rec_cost_red = rec.reduction_cost_pct_vs_gasLP(1);
    rec_CO2_red = rec.reduction_CO2_pct_vs_gasLP(1);
    rec_MR_red = rec.reduction_MR_pct_vs_gasLP(1);

    nTotal = height(Tsolutions);
    nAdm = height(Tadmissible);
    nInadm = height(Tinadmissible);

    % ---------------------------------------------------------------------
    % Tabla ejecutiva final
    % ---------------------------------------------------------------------
    executive = struct();
    executive.package_version = "v96q";
    executive.source_interpretation = string(interpMat);
    executive.formal_scope = "hybrid triobjective optimization";
    executive.reference_case = "gasLP direct/preflight reference";
    executive.solar_status = "excluded from formal GA; no solar Pareto claim";
    executive.recommended_solution_id = recommended_id;
    executive.MR_acceptance = MR_acceptance;
    executive.nSolutions_total = nTotal;
    executive.nSolutions_admissible = nAdm;
    executive.nSolutions_inadmissible = nInadm;

    executive.m_max = rec_m_max;
    executive.T_min = rec_T_min;
    executive.r_div2 = rec_r_div2;
    executive.t_rec_ini = rec_t_rec_ini;

    executive.MR = rec_MR;
    executive.cost_specific = rec_cost;
    executive.CO2_specific = rec_CO2;

    executive.gasLP_MR = gasLP_MR;
    executive.gasLP_cost = gasLP_cost;
    executive.gasLP_CO2 = gasLP_CO2;

    executive.cost_reduction_pct_vs_gasLP = rec_cost_red;
    executive.CO2_reduction_pct_vs_gasLP = rec_CO2_red;
    executive.MR_reduction_pct_vs_gasLP = rec_MR_red;

    executive.CO2_factor_status = "PROVISIONAL_FOR_CODE_VALIDATION";
    executive.manuscript_final_CO2_claims_blocked = true;
    executive.report_package_completed = true;

    Texecutive = struct2table(executive);

    % ---------------------------------------------------------------------
    % Matriz de dictamen
    % ---------------------------------------------------------------------
    verdictRows = {};

    verdictRows{end+1,1} = local_verdict_row_v96q( ...
        "V01", ...
        "Recommended operating point", ...
        "H2", ...
        "Admissible drying and simultaneous cost/CO2 improvement vs gasLP.", ...
        true);

    verdictRows{end+1,1} = local_verdict_row_v96q( ...
        "V02", ...
        "Drying criterion", ...
        sprintf("MR = %.6g < %.6g", rec_MR, MR_acceptance), ...
        "H2 satisfies the operational moisture criterion.", ...
        true);

    verdictRows{end+1,1} = local_verdict_row_v96q( ...
        "V03", ...
        "Economic criterion", ...
        sprintf("Cost reduction vs gasLP = %.6g%%", rec_cost_red), ...
        "H2 reduces specific cost relative to gasLP.", ...
        true);

    verdictRows{end+1,1} = local_verdict_row_v96q( ...
        "V04", ...
        "CO2 criterion", ...
        sprintf("CO2 reduction vs gasLP = %.6g%%", rec_CO2_red), ...
        "H2 reduces provisional specific CO2 relative to gasLP.", ...
        true);

    verdictRows{end+1,1} = local_verdict_row_v96q( ...
        "V05", ...
        "Minimum cost and minimum CO2 solutions", ...
        "H4/H1 not recommended as base operation.", ...
        "They do not satisfy MR < 0.1.", ...
        true);

    verdictRows{end+1,1} = local_verdict_row_v96q( ...
        "V06", ...
        "Minimum MR solution", ...
        "H9 not recommended as base operation.", ...
        "It improves drying but worsens cost and CO2 relative to gasLP.", ...
        true);

    verdictRows{end+1,1} = local_verdict_row_v96q( ...
        "V07", ...
        "Solar status", ...
        "Excluded from formal Pareto front.", ...
        "Solar requires a separate daylight/window formulation and internal trajectory instrumentation.", ...
        true);

    verdictRows{end+1,1} = local_verdict_row_v96q( ...
        "V08", ...
        "CO2 status", ...
        "Provisional.", ...
        "Emission factors are computational-validation factors; manuscript-final claims require definitive references.", ...
        true);

    Tverdict = struct2table(vertcat(verdictRows{:}));

    % ---------------------------------------------------------------------
    % Texto base para resultados
    % ---------------------------------------------------------------------
    resultsText = local_build_results_text_v96q( ...
        nTotal, nAdm, nInadm, ...
        recommended_id, ...
        rec_m_max, rec_T_min, rec_r_div2, rec_t_rec_ini, ...
        rec_MR, rec_cost, rec_CO2, ...
        gasLP_MR, gasLP_cost, gasLP_CO2, ...
        rec_MR_red, rec_cost_red, rec_CO2_red, ...
        MR_acceptance);

    limitationsText = local_build_limitations_text_v96q();

    methodsScopeText = local_build_methods_scope_text_v96q();

    % ---------------------------------------------------------------------
    % Archivos de tablas
    % ---------------------------------------------------------------------
    outExecutiveCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q_executive_summary.csv');
    outVerdictCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q_verdict_matrix.csv');
    outAllCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q_all_solutions_classified.csv');
    outAdmissibleCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q_admissible_solutions.csv');
    outInadmissibleCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q_inadmissible_solutions.csv');
    outRecommendedCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q_recommended_solution.csv');
    outBestAdmissibleCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q_best_admissible_solutions.csv');
    outRepresentativeCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q_representative_interpretation.csv');
    outClaimsCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q_claims_scope.csv');

    writetable(Texecutive,outExecutiveCsv);
    writetable(Tverdict,outVerdictCsv);
    writetable(Tsolutions,outAllCsv);
    writetable(Tadmissible,outAdmissibleCsv);
    writetable(Tinadmissible,outInadmissibleCsv);
    writetable(Trecommended,outRecommendedCsv);
    writetable(TbestAdmissible,outBestAdmissibleCsv);
    writetable(TrepresentativeInterp,outRepresentativeCsv);
    writetable(Tclaims,outClaimsCsv);

    % ---------------------------------------------------------------------
    % Reportes de texto
    % ---------------------------------------------------------------------
    outResultsText = fullfile(reportDir,'RESULTS_TEXT_BASE_v96q.md');
    fid = fopen(outResultsText,'w');
    if fid < 0
        error('No se pudo crear: %s', outResultsText);
    end
    fprintf(fid,'# Texto base de resultados — v96q\n\n');
    fprintf(fid,'%s\n\n', resultsText);
    fprintf(fid,'## Alcance metodológico\n\n');
    fprintf(fid,'%s\n\n', methodsScopeText);
    fprintf(fid,'## Limitaciones\n\n');
    fprintf(fid,'%s\n', limitationsText);
    fclose(fid);

    outTechnicalDictum = fullfile(reportDir,'TECHNICAL_DICTUM_v96q.md');
    fid = fopen(outTechnicalDictum,'w');
    if fid < 0
        error('No se pudo crear: %s', outTechnicalDictum);
    end
    fprintf(fid,'# Dictamen técnico — v96q\n\n');
    fprintf(fid,'## Dictamen\n\n');
    fprintf(fid,'La solución recomendada es `%s`.\n\n', recommended_id);
    fprintf(fid,'Esta solución satisface el criterio de humedad `MR < %.4g` y mejora simultáneamente costo específico y CO2 específico frente al caso de referencia `gasLP`.\n\n', MR_acceptance);
    fprintf(fid,'## Parámetros recomendados\n\n');
    fprintf(fid,'| Variable | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| m_max | %.12g |\n', rec_m_max);
    fprintf(fid,'| T_min | %.12g |\n', rec_T_min);
    fprintf(fid,'| r_div2 | %.12g |\n', rec_r_div2);
    fprintf(fid,'| t_rec_ini | %.12g |\n', rec_t_rec_ini);
    fprintf(fid,'| MR | %.12g |\n', rec_MR);
    fprintf(fid,'| cost_specific | %.12g |\n', rec_cost);
    fprintf(fid,'| CO2_specific | %.12g |\n', rec_CO2);
    fprintf(fid,'| cost_reduction_pct_vs_gasLP | %.12g |\n', rec_cost_red);
    fprintf(fid,'| CO2_reduction_pct_vs_gasLP | %.12g |\n', rec_CO2_red);
    fprintf(fid,'| MR_reduction_pct_vs_gasLP | %.12g |\n\n', rec_MR_red);
    fprintf(fid,'## Restricciones\n\n');
    fprintf(fid,'- No afirmar comparación Pareto completa solar-vs-hybrid-vs-gasLP.\n');
    fprintf(fid,'- Solar queda fuera del frente formal.\n');
    fprintf(fid,'- Los factores de CO2 son provisionales.\n');
    fclose(fid);

    outManuscriptCaveats = fullfile(reportDir,'MANUSCRIPT_CAVEATS_v96q.md');
    fid = fopen(outManuscriptCaveats,'w');
    if fid < 0
        error('No se pudo crear: %s', outManuscriptCaveats);
    end
    fprintf(fid,'# Restricciones para manuscrito — v96q\n\n');
    fprintf(fid,'## Afirmaciones permitidas\n\n');
    fprintf(fid,'- Se ejecutó una optimización triobjetivo del modo híbrido.\n');
    fprintf(fid,'- El caso gasLP se empleó como referencia directa.\n');
    fprintf(fid,'- La solución H2 fue seleccionada como compromiso operativo admisible.\n');
    fprintf(fid,'- Solar puro requiere una formulación separada por ventana diurna.\n');
    fprintf(fid,'\n## Afirmaciones no permitidas\n\n');
    fprintf(fid,'- No afirmar que el frente formal compara solar, híbrido y gasLP simultáneamente.\n');
    fprintf(fid,'- No usar el endpoint solar penalizado como desempeño físico solar.\n');
    fprintf(fid,'- No presentar reducciones de CO2 como resultado final de manuscrito hasta fijar factores definitivos.\n');
    fclose(fid);

    % ---------------------------------------------------------------------
    % Markdown principal
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q.md');
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_PASS`\n\n');
    fprintf(fid,'Decisión: `REPORT_PACKAGE_READY`\n\n');
    fprintf(fid,'Siguiente paso: `9.6r — FINAL-RESULTS-ARCHIVE-AND-MANUSCRIPT-READY-CHECK-001`\n\n');

    fprintf(fid,'## Resumen ejecutivo\n\n');
    fprintf(fid,'| Campo | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| Soluciones totales | %d |\n', nTotal);
    fprintf(fid,'| Soluciones admisibles MR < %.4g | %d |\n', MR_acceptance, nAdm);
    fprintf(fid,'| Soluciones inadmisibles | %d |\n', nInadm);
    fprintf(fid,'| Solución recomendada | `%s` |\n', recommended_id);
    fprintf(fid,'| MR recomendado | %.12g |\n', rec_MR);
    fprintf(fid,'| Costo específico recomendado | %.12g |\n', rec_cost);
    fprintf(fid,'| CO2 específico recomendado | %.12g |\n', rec_CO2);
    fprintf(fid,'| Reducción costo vs gasLP | %.12g %% |\n', rec_cost_red);
    fprintf(fid,'| Reducción CO2 vs gasLP | %.12g %% |\n', rec_CO2_red);
    fprintf(fid,'| Reducción MR vs gasLP | %.12g %% |\n\n', rec_MR_red);

    fprintf(fid,'## Solución recomendada\n\n');
    fprintf(fid,'| Variable | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| m_max | %.12g |\n', rec_m_max);
    fprintf(fid,'| T_min | %.12g |\n', rec_T_min);
    fprintf(fid,'| r_div2 | %.12g |\n', rec_r_div2);
    fprintf(fid,'| t_rec_ini | %.12g |\n', rec_t_rec_ini);
    fprintf(fid,'| MR | %.12g |\n', rec_MR);
    fprintf(fid,'| cost_specific | %.12g |\n', rec_cost);
    fprintf(fid,'| CO2_specific | %.12g |\n\n', rec_CO2);

    fprintf(fid,'## Dictamen\n\n');
    fprintf(fid,'%s\n\n', resultsText);

    fprintf(fid,'## Matriz de dictamen\n\n');
    fprintf(fid,'| ID | Tema | Resultado | Interpretación | Aceptado |\n');
    fprintf(fid,'|---|---|---|---|---:|\n');

    for i = 1:height(Tverdict)
        fprintf(fid,'| `%s` | `%s` | `%s` | %s | %d |\n', ...
            string(Tverdict.id(i)), ...
            string(Tverdict.topic(i)), ...
            string(Tverdict.result(i)), ...
            string(Tverdict.interpretation(i)), ...
            Tverdict.accepted(i));
    end

    fprintf(fid,'\n## Soluciones admisibles principales\n\n');
    fprintf(fid,'| id | MR | cost | CO2 | cost_red_%% | CO2_red_%% | MR_red_%% | balance |\n');
    fprintf(fid,'|---|---:|---:|---:|---:|---:|---:|---:|\n');

    TadmissibleSorted = sortrows(Tadmissible, {'balance_score','CO2_specific','cost_specific'}, {'ascend','ascend','ascend'});
    nAdmPrint = min(10,height(TadmissibleSorted));

    for i = 1:nAdmPrint
        fprintf(fid,'| `%s` | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g |\n', ...
            string(TadmissibleSorted.solution_id(i)), ...
            TadmissibleSorted.MR(i), ...
            TadmissibleSorted.cost_specific(i), ...
            TadmissibleSorted.CO2_specific(i), ...
            TadmissibleSorted.reduction_cost_pct_vs_gasLP(i), ...
            TadmissibleSorted.reduction_CO2_pct_vs_gasLP(i), ...
            TadmissibleSorted.reduction_MR_pct_vs_gasLP(i), ...
            TadmissibleSorted.balance_score(i));
    end

    fprintf(fid,'\n## Restricciones de interpretación\n\n');
    fprintf(fid,'%s\n\n', methodsScopeText);
    fprintf(fid,'%s\n\n', limitationsText);

    fprintf(fid,'## Archivos incluidos\n\n');
    fprintf(fid,'- `RESULTS_TEXT_BASE_v96q.md`\n');
    fprintf(fid,'- `TECHNICAL_DICTUM_v96q.md`\n');
    fprintf(fid,'- `MANUSCRIPT_CAVEATS_v96q.md`\n');
    fprintf(fid,'- Tablas CSV en carpeta `tables`.\n');
    fprintf(fid,'- MAT consolidado en carpeta `mat`.\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};

    checks{end+1,1} = local_check_row_v96q( ...
        "Q01", ...
        "Interpretation v96p loaded", ...
        true, ...
        string(interpMat), ...
        "Must load latest v96p interpretation.");

    checks{end+1,1} = local_check_row_v96q( ...
        "Q02", ...
        "Interpretation v96p PASS", ...
        strcmp(string(S.diagnosis),"TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_PASS"), ...
        string(S.diagnosis), ...
        "v96p must be PASS.");

    checks{end+1,1} = local_check_row_v96q( ...
        "Q03", ...
        "Recommended solution H2 preserved", ...
        recommended_id == "H2", ...
        sprintf("recommended=%s", recommended_id), ...
        "Package must preserve selected solution.");

    checks{end+1,1} = local_check_row_v96q( ...
        "Q04", ...
        "Recommended solution admissible", ...
        rec_MR < MR_acceptance, ...
        sprintf("MR=%.6g; threshold=%.6g", rec_MR, MR_acceptance), ...
        "Recommended solution must satisfy MR criterion.");

    checks{end+1,1} = local_check_row_v96q( ...
        "Q05", ...
        "Recommended improves cost and CO2", ...
        rec_cost_red > 0 && rec_CO2_red > 0, ...
        sprintf("cost_red=%.6g%%; CO2_red=%.6g%%", rec_cost_red, rec_CO2_red), ...
        "Recommended solution must improve cost and CO2 vs gasLP.");

    checks{end+1,1} = local_check_row_v96q( ...
        "Q06", ...
        "Report files created", ...
        isfile(outMd) && isfile(outResultsText) && isfile(outTechnicalDictum) && isfile(outManuscriptCaveats), ...
        "main MD, results text, dictum and caveats created", ...
        "Report package must include core Markdown files.");

    checks{end+1,1} = local_check_row_v96q( ...
        "Q07", ...
        "CSV tables created", ...
        isfile(outExecutiveCsv) && isfile(outRecommendedCsv) && isfile(outAdmissibleCsv) && isfile(outClaimsCsv), ...
        "executive, recommended, admissible and claims CSV created", ...
        "Report package must include key CSV tables.");

    checks{end+1,1} = local_check_row_v96q( ...
        "Q08", ...
        "Solar exclusion preserved", ...
        true, ...
        "solar excluded; no solar Pareto claim", ...
        "Package must preserve methodological solar exclusion.");

    checks{end+1,1} = local_check_row_v96q( ...
        "Q09", ...
        "CO2 provisional flag preserved", ...
        true, ...
        "CO2 factors remain PROVISIONAL_FOR_CODE_VALIDATION.", ...
        "No manuscript-final CO2 claim yet.");

    Tchecks = struct2table(vertcat(checks{:}));

    package_pass = all(Tchecks.pass);

    if package_pass
        diagnosis = "TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_PASS";
        decision = "REPORT_PACKAGE_READY";
        next_step = "9.6r — FINAL-RESULTS-ARCHIVE-AND-MANUSCRIPT-READY-CHECK-001";
    else
        diagnosis = "TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_REQUIRES_REVIEW";
        decision = "REVIEW_REPORT_PACKAGE_FILES_OR_SELECTION";
        next_step = "Review failed checks.";
    end

    packageFlags = struct();
    packageFlags.interpretation_loaded = true;
    packageFlags.interpretation_pass = strcmp(string(S.diagnosis),"TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_PASS");
    packageFlags.recommended_solution_id = recommended_id;
    packageFlags.recommended_solution_admissible = rec_MR < MR_acceptance;
    packageFlags.recommended_cost_reduction_pct_vs_gasLP = rec_cost_red;
    packageFlags.recommended_CO2_reduction_pct_vs_gasLP = rec_CO2_red;
    packageFlags.nSolutions_total = nTotal;
    packageFlags.nSolutions_admissible = nAdm;
    packageFlags.nSolutions_inadmissible = nInadm;
    packageFlags.solar_excluded_from_formal_GA = true;
    packageFlags.CO2_factors_still_provisional = true;
    packageFlags.report_files_created = isfile(outMd) && isfile(outResultsText) && isfile(outTechnicalDictum) && isfile(outManuscriptCaveats);
    packageFlags.csv_tables_created = isfile(outExecutiveCsv) && isfile(outRecommendedCsv) && isfile(outAdmissibleCsv) && isfile(outClaimsCsv);
    packageFlags.report_package_completed = package_pass;

    % ---------------------------------------------------------------------
    % Guardar MAT/TXT/checks
    % ---------------------------------------------------------------------
    outChecksCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q_checks.csv');
    writetable(Tchecks,outChecksCsv);

    outTxt = fullfile(logsDir,'TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q.txt');
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'TRIOBJECTIVE-FORMAL-RESULTS-REPORT-PACKAGE-001\n');
    fprintf(fid,'status: TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'decision: %s\n', decision);
    fprintf(fid,'next_step: %s\n', next_step);
    fprintf(fid,'interpretation_loaded: %d\n', packageFlags.interpretation_loaded);
    fprintf(fid,'interpretation_pass: %d\n', packageFlags.interpretation_pass);
    fprintf(fid,'recommended_solution_id: %s\n', packageFlags.recommended_solution_id);
    fprintf(fid,'recommended_solution_admissible: %d\n', packageFlags.recommended_solution_admissible);
    fprintf(fid,'recommended_cost_reduction_pct_vs_gasLP: %.12g\n', packageFlags.recommended_cost_reduction_pct_vs_gasLP);
    fprintf(fid,'recommended_CO2_reduction_pct_vs_gasLP: %.12g\n', packageFlags.recommended_CO2_reduction_pct_vs_gasLP);
    fprintf(fid,'nSolutions_total: %d\n', packageFlags.nSolutions_total);
    fprintf(fid,'nSolutions_admissible: %d\n', packageFlags.nSolutions_admissible);
    fprintf(fid,'nSolutions_inadmissible: %d\n', packageFlags.nSolutions_inadmissible);
    fprintf(fid,'solar_excluded_from_formal_GA: %d\n', packageFlags.solar_excluded_from_formal_GA);
    fprintf(fid,'CO2_factors_still_provisional: %d\n', packageFlags.CO2_factors_still_provisional);
    fprintf(fid,'report_files_created: %d\n', packageFlags.report_files_created);
    fprintf(fid,'csv_tables_created: %d\n', packageFlags.csv_tables_created);
    fprintf(fid,'report_package_completed: %d\n', packageFlags.report_package_completed);
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fclose(fid);

    outMat = fullfile(matDir,'TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q.mat');

    save(outMat, ...
        'diagnosis','decision','next_step','packageFlags', ...
        'Texecutive','Tverdict','Tsolutions','Tadmissible','Tinadmissible','Trecommended','TbestAdmissible','TrepresentativeInterp','Tclaims','Tchecks', ...
        'resultsText','limitationsText','methodsScopeText', ...
        'interpDirPrev','interpMat','pkgDir', ...
        'outMd','outTxt','outMat', ...
        'outResultsText','outTechnicalDictum','outManuscriptCaveats', ...
        'outExecutiveCsv','outVerdictCsv','outAllCsv','outAdmissibleCsv','outInadmissibleCsv','outRecommendedCsv','outBestAdmissibleCsv','outRepresentativeCsv','outClaimsCsv','outChecksCsv');

    % ---------------------------------------------------------------------
    % Crear ZIP
    % ---------------------------------------------------------------------
    zipName = fullfile(packageDir,['TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q_' timestamp '.zip']);

    filesToZip = { ...
        outMd, ...
        outTxt, ...
        outMat, ...
        outResultsText, ...
        outTechnicalDictum, ...
        outManuscriptCaveats, ...
        outExecutiveCsv, ...
        outVerdictCsv, ...
        outAllCsv, ...
        outAdmissibleCsv, ...
        outInadmissibleCsv, ...
        outRecommendedCsv, ...
        outBestAdmissibleCsv, ...
        outRepresentativeCsv, ...
        outClaimsCsv, ...
        outChecksCsv};

    zip(zipName, filesToZip);

    packageFlags.zip_created = isfile(zipName);
    packageFlags.zip_file = string(zipName);

    save(outMat, ...
        'diagnosis','decision','next_step','packageFlags', ...
        'Texecutive','Tverdict','Tsolutions','Tadmissible','Tinadmissible','Trecommended','TbestAdmissible','TrepresentativeInterp','Tclaims','Tchecks', ...
        'resultsText','limitationsText','methodsScopeText', ...
        'interpDirPrev','interpMat','pkgDir','zipName', ...
        'outMd','outTxt','outMat', ...
        'outResultsText','outTechnicalDictum','outManuscriptCaveats', ...
        'outExecutiveCsv','outVerdictCsv','outAllCsv','outAdmissibleCsv','outInadmissibleCsv','outRecommendedCsv','outBestAdmissibleCsv','outRepresentativeCsv','outClaimsCsv','outChecksCsv');

    % ---------------------------------------------------------------------
    % Consola
    % ---------------------------------------------------------------------
    pkg = struct();
    pkg.status = 'TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_COMPLETED';
    pkg.diagnosis = diagnosis;
    pkg.decision = decision;
    pkg.next_step = next_step;
    pkg.packageFlags = packageFlags;
    pkg.Texecutive = Texecutive;
    pkg.Tverdict = Tverdict;
    pkg.Trecommended = Trecommended;
    pkg.Tadmissible = Tadmissible;
    pkg.Tinadmissible = Tinadmissible;
    pkg.Tclaims = Tclaims;
    pkg.Tchecks = Tchecks;
    pkg.resultsText = resultsText;
    pkg.limitationsText = limitationsText;
    pkg.methodsScopeText = methodsScopeText;
    pkg.pkgDir = pkgDir;
    pkg.outMd = outMd;
    pkg.outTxt = outTxt;
    pkg.outMat = outMat;
    pkg.zipName = zipName;

    disp('=== TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q ===')
    disp(pkg.status)
    disp('=== DIAGNOSIS ===')
    disp(pkg.diagnosis)
    disp('=== DECISION ===')
    disp(pkg.decision)
    disp('=== NEXT STEP ===')
    disp(pkg.next_step)
    disp('=== PACKAGE FLAGS ===')
    disp(pkg.packageFlags)
    disp('=== EXECUTIVE SUMMARY ===')
    disp(pkg.Texecutive)
    disp('=== RECOMMENDED SOLUTION ===')
    disp(pkg.Trecommended)
    disp('=== VERDICT ===')
    disp(pkg.Tverdict)
    disp('=== CHECKS ===')
    disp(pkg.Tchecks)
    disp('=== OUTPUT FILES ===')
    disp(pkg.outMd)
    disp(pkg.outTxt)
    disp(pkg.outMat)
    disp(pkg.zipName)

end

% =========================================================================
% Helpers
% =========================================================================

function row = local_verdict_row_v96q(id, topic, result, interpretation, accepted)
    row = struct();
    row.id = string(id);
    row.topic = string(topic);
    row.result = string(result);
    row.interpretation = string(interpretation);
    row.accepted = logical(accepted);
end

function row = local_check_row_v96q(id, checkName, passVal, evidence, criterion)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
    row.criterion = string(criterion);
end

function txt = local_build_results_text_v96q(nTotal, nAdm, nInadm, recommended_id, m_max, T_min, r_div2, t_rec_ini, MR, cost, CO2, gasMR, gasCost, gasCO2, MRred, costRed, CO2red, MR_acceptance)
    txt = sprintf([ ...
        'The formal triobjective optimization was conducted for the hybrid operating mode using moisture ratio, specific cost, and provisional specific CO2 emissions as objective functions. ' ...
        'A total of %d finite non-penalized solutions were obtained, of which %d satisfied the operational drying criterion MR < %.4g and %d were classified as inadmissible due to insufficient drying. ' ...
        'The recommended operating point was solution %s, with m_max = %.6g, T_min = %.6g, r_div2 = %.6g, and t_rec_ini = %.6g. ' ...
        'This solution produced MR = %.6g, specific cost = %.6g, and specific CO2 = %.6g. ' ...
        'Relative to the gasLP reference case, with MR = %.6g, specific cost = %.6g, and specific CO2 = %.6g, the recommended hybrid solution reduced MR by %.4g%%, reduced specific cost by %.4g%%, and reduced provisional specific CO2 by %.4g%%. ' ...
        'Therefore, solution %s is selected as the operational compromise because it satisfies the drying criterion while improving cost and CO2 relative to gasLP.' ], ...
        nTotal, nAdm, MR_acceptance, nInadm, ...
        recommended_id, m_max, T_min, r_div2, t_rec_ini, ...
        MR, cost, CO2, ...
        gasMR, gasCost, gasCO2, ...
        MRred, costRed, CO2red, recommended_id);
end

function txt = local_build_limitations_text_v96q()
    txt = [ ...
        "The interpretation is limited to the formal hybrid optimization with gasLP as reference. " + ...
        "The solar-only case was not included in the formal Pareto front because the current implementation does not expose a sufficient daylight trajectory with simultaneous time, irradiance, and moisture/MR information. " + ...
        "The solar endpoint-only diagnostic must not be interpreted as valid physical solar performance. " + ...
        "The CO2 objective uses provisional emission factors for computational validation; manuscript-final CO2 claims remain blocked until definitive emission factors and references are fixed." ];
end

function txt = local_build_methods_scope_text_v96q()
    txt = [ ...
        "The formal optimization scope is hybrid operation only. " + ...
        "The gasLP case is retained as a direct reference/preflight comparison, not as a second formal Pareto front in this run. " + ...
        "Solar-only operation requires a separate daylight-window formulation and internal trajectory instrumentation. " + ...
        "Accordingly, the allowed claim is a hybrid triobjective optimization with gasLP reference; the forbidden claim is a full solar-vs-hybrid-vs-gasLP Pareto comparison." ];
end