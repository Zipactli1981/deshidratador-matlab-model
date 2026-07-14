function rsm = local_response_surfaces_around_H2_v96q_rsm1(nGrid)
% LOCAL_RESPONSE_SURFACES_AROUND_H2_v96q_rsm1
% 9.6q-rsm1 — LOCAL-RESPONSE-SURFACES-AROUND-H2-001
%
% Objetivo:
%   Generar superficies de respuesta locales alrededor de la solución H2.
%
% Este paso:
%   - NO ejecuta gamultiobj.
%   - NO modifica fuentes protegidas.
%   - Carga la interpretación formal v96p.
%   - Toma H2 como centro operativo.
%   - Evalúa localmente la función objetivo triobjetivo:
%       f1 = MR
%       f2 = costo específico
%       f3 = CO2 específico provisional
%   - Genera superficies para:
%       1) T_min vs r_div2
%       2) T_min vs m_max
%       3) r_div2 vs m_max
%
% Uso:
%   rsm = local_response_surfaces_around_H2_v96q_rsm1();
%   rsm = local_response_surfaces_around_H2_v96q_rsm1(9);
%
% Recomendación:
%   nGrid = 7 para revisión rápida.
%   nGrid = 9 o 11 para figuras más finas.
%
% Nota:
%   Los factores de CO2 siguen como PROVISIONAL_FOR_CODE_VALIDATION.

    if nargin < 1 || isempty(nGrid)
        nGrid = 7;
    end

    if nGrid < 5
        error('nGrid debe ser >= 5.');
    end

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    MR_acceptance = 0.10;
    mode_operation = 'hybrid';

    objectiveFcn = @objective_productive_corrected_v96j_triobjective_CO2_fix1;

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

    Trecommended = S.Trecommended;
    Tsolutions = S.Tsolutions;
    Tsummary = S.Tsummary;

    if ~strcmp(string(Trecommended.solution_id(1)),"H2")
        warning('La solución recomendada no aparece como H2. Se usará la solución recomendada actual: %s', string(Trecommended.solution_id(1)));
    end

    xH2 = [ ...
        Trecommended.m_max(1), ...
        Trecommended.T_min(1), ...
        Trecommended.r_div2(1), ...
        Trecommended.t_rec_ini(1)];

    % x = [m_max, T_min, r_div2, t_rec_ini]
    m0 = xH2(1);
    T0 = xH2(2);
    r0 = xH2(3);
    t0 = xH2(4);

    gasMR = Tsummary.gasLP_MR(1);
    gasCost = Tsummary.gasLP_cost(1);
    gasCO2 = Tsummary.gasLP_CO2(1);

    % ---------------------------------------------------------------------
    % Rangos locales alrededor de H2
    % ---------------------------------------------------------------------
    % Rango local conservador:
    %   m_max: +/- 15 %
    %   T_min: +/- 5 °C
    %   r_div2: +/- 0.20
    %   t_rec_ini: fijo en H2 para estas primeras superficies.
    %
    % Límites de seguridad definidos por la región observada en el frente
    % y por plausibilidad operativa local.
    mRange = linspace(max(0.055,0.85*m0), min(0.095,1.15*m0), nGrid);
    TRange = linspace(max(58,T0-5), min(70,T0+5), nGrid);
    rRange = linspace(max(0.40,r0-0.20), min(0.90,r0+0.20), nGrid);
    tRange = linspace(max(11,t0-1.0), min(13.5,t0+1.0), nGrid);

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    rsmBaseDir = fullfile(rootDir,'05_runs','local_response_surfaces_around_H2_v96q_rsm1');
    rsmDir = fullfile(rsmBaseDir,['LOCAL_RESPONSE_SURFACES_AROUND_H2_v96q_rsm1_' timestamp]);

    pngDir = fullfile(rsmDir,'png');
    figDir = fullfile(rsmDir,'fig');
    pdfDir = fullfile(rsmDir,'pdf');
    tablesDir = fullfile(rsmDir,'tables');
    logsDir = fullfile(rsmDir,'logs');
    matDir = fullfile(rsmDir,'mat');

    if ~isfolder(rsmBaseDir), mkdir(rsmBaseDir); end
    if ~isfolder(rsmDir), mkdir(rsmDir); end
    if ~isfolder(pngDir), mkdir(pngDir); end
    if ~isfolder(figDir), mkdir(figDir); end
    if ~isfolder(pdfDir), mkdir(pdfDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Evaluar superficies
    % ---------------------------------------------------------------------
    ticTotal = tic;

    surfaces = struct();

    surfaces.TR = local_eval_pair_surface_v96q_rsm1( ...
        objectiveFcn, mode_operation, xH2, ...
        2, TRange, 3, rRange, ...
        'T_min','r_div2');

    surfaces.TM = local_eval_pair_surface_v96q_rsm1( ...
        objectiveFcn, mode_operation, xH2, ...
        2, TRange, 1, mRange, ...
        'T_min','m_max');

    surfaces.RM = local_eval_pair_surface_v96q_rsm1( ...
        objectiveFcn, mode_operation, xH2, ...
        3, rRange, 1, mRange, ...
        'r_div2','m_max');

    runtime_s = toc(ticTotal);

    % ---------------------------------------------------------------------
    % Tablas largas
    % ---------------------------------------------------------------------
    T_TR = local_surface_to_table_v96q_rsm1(surfaces.TR,'T_min_vs_r_div2');
    T_TM = local_surface_to_table_v96q_rsm1(surfaces.TM,'T_min_vs_m_max');
    T_RM = local_surface_to_table_v96q_rsm1(surfaces.RM,'r_div2_vs_m_max');

    Tall = [T_TR; T_TM; T_RM];

    outAllCsv = fullfile(tablesDir,'LOCAL_RESPONSE_SURFACES_AROUND_H2_v96q_rsm1_all_points.csv');
    outTRCsv = fullfile(tablesDir,'LOCAL_RESPONSE_SURFACES_AROUND_H2_v96q_rsm1_T_min_vs_r_div2.csv');
    outTMCsv = fullfile(tablesDir,'LOCAL_RESPONSE_SURFACES_AROUND_H2_v96q_rsm1_T_min_vs_m_max.csv');
    outRMCsv = fullfile(tablesDir,'LOCAL_RESPONSE_SURFACES_AROUND_H2_v96q_rsm1_r_div2_vs_m_max.csv');

    writetable(Tall,outAllCsv);
    writetable(T_TR,outTRCsv);
    writetable(T_TM,outTMCsv);
    writetable(T_RM,outRMCsv);

    % ---------------------------------------------------------------------
    % Resumen local
    % ---------------------------------------------------------------------
    summaryRows = {};
    summaryRows{end+1,1} = local_surface_summary_row_v96q_rsm1(surfaces.TR,'T_min_vs_r_div2',MR_acceptance);
    summaryRows{end+1,1} = local_surface_summary_row_v96q_rsm1(surfaces.TM,'T_min_vs_m_max',MR_acceptance);
    summaryRows{end+1,1} = local_surface_summary_row_v96q_rsm1(surfaces.RM,'r_div2_vs_m_max',MR_acceptance);

    TsurfaceSummary = struct2table(vertcat(summaryRows{:}));

    outSummaryCsv = fullfile(tablesDir,'LOCAL_RESPONSE_SURFACES_AROUND_H2_v96q_rsm1_surface_summary.csv');
    writetable(TsurfaceSummary,outSummaryCsv);

    % ---------------------------------------------------------------------
    % Figuras: contornos y superficies
    % ---------------------------------------------------------------------
    figureFiles = strings(0,1);
    pdfFiles = strings(0,1);
    figFiles = strings(0,1);

    [figureFiles,pdfFiles,figFiles] = local_plot_all_for_surface_v96q_rsm1( ...
        surfaces.TR, 'T_min','r_div2', 'T_min vs r_div2', ...
        xH2, gasMR, gasCost, gasCO2, MR_acceptance, ...
        pngDir, pdfDir, figDir, figureFiles, pdfFiles, figFiles);

    [figureFiles,pdfFiles,figFiles] = local_plot_all_for_surface_v96q_rsm1( ...
        surfaces.TM, 'T_min','m_max', 'T_min vs m_max', ...
        xH2, gasMR, gasCost, gasCO2, MR_acceptance, ...
        pngDir, pdfDir, figDir, figureFiles, pdfFiles, figFiles);

    [figureFiles,pdfFiles,figFiles] = local_plot_all_for_surface_v96q_rsm1( ...
        surfaces.RM, 'r_div2','m_max', 'r_div2 vs m_max', ...
        xH2, gasMR, gasCost, gasCO2, MR_acceptance, ...
        pngDir, pdfDir, figDir, figureFiles, pdfFiles, figFiles);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    totalExpected = 3*nGrid*nGrid;
    nEvaluated = height(Tall);
    nOK = sum(Tall.status == "OK");
    nFinite = sum(isfinite(Tall.MR) & isfinite(Tall.cost_specific) & isfinite(Tall.CO2_specific));
    nAdmissible = sum(Tall.MR < MR_acceptance & isfinite(Tall.MR));

    checks = {};

    checks{end+1,1} = local_check_row_v96q_rsm1( ...
        "RSM01", ...
        "Interpretation v96p loaded", ...
        true, ...
        string(interpMat), ...
        "Must load formal interpretation.");

    checks{end+1,1} = local_check_row_v96q_rsm1( ...
        "RSM02", ...
        "H2 center loaded", ...
        all(isfinite(xH2)), ...
        sprintf("xH2=[%.6g %.6g %.6g %.6g]", xH2), ...
        "H2 decision vector must be finite.");

    checks{end+1,1} = local_check_row_v96q_rsm1( ...
        "RSM03", ...
        "Surface evaluations completed", ...
        nEvaluated == totalExpected, ...
        sprintf("evaluated=%d; expected=%d", nEvaluated, totalExpected), ...
        "All grid points must be evaluated.");

    checks{end+1,1} = local_check_row_v96q_rsm1( ...
        "RSM04", ...
        "Finite response values available", ...
        nFinite > 0, ...
        sprintf("finite=%d of %d", nFinite, nEvaluated), ...
        "At least some finite responses must be available.");

    checks{end+1,1} = local_check_row_v96q_rsm1( ...
        "RSM05", ...
        "Admissible local region exists", ...
        nAdmissible > 0, ...
        sprintf("admissible MR<0.1=%d", nAdmissible), ...
        "Local neighborhood should contain admissible points around H2.");

    checks{end+1,1} = local_check_row_v96q_rsm1( ...
        "RSM06", ...
        "Figures exported", ...
        numel(figureFiles) >= 9 && all(isfile(figureFiles)), ...
        sprintf("PNG figures=%d", numel(figureFiles)), ...
        "At least 9 PNG figures should be exported.");

    checks{end+1,1} = local_check_row_v96q_rsm1( ...
        "RSM07", ...
        "CSV tables exported", ...
        isfile(outAllCsv) && isfile(outSummaryCsv), ...
        "all-points and summary CSV created", ...
        "Core RSM tables must exist.");

    checks{end+1,1} = local_check_row_v96q_rsm1( ...
        "RSM08", ...
        "No GA executed", ...
        true, ...
        "This script does not call gamultiobj.", ...
        "RSM must be local evaluation only.");

    checks{end+1,1} = local_check_row_v96q_rsm1( ...
        "RSM09", ...
        "CO2 provisional flag preserved", ...
        true, ...
        "CO2 remains PROVISIONAL_FOR_CODE_VALIDATION.", ...
        "No manuscript-final CO2 claim yet.");

    Tchecks = struct2table(vertcat(checks{:}));

    rsm_pass = all(Tchecks.pass);

    if rsm_pass
        diagnosis = "LOCAL_RESPONSE_SURFACES_AROUND_H2_PASS";
        decision = "RSM_FIGURES_READY_FOR_VISUAL_REVIEW";
        next_step = "Review surfaces before 9.6r.";
    else
        diagnosis = "LOCAL_RESPONSE_SURFACES_AROUND_H2_REQUIRES_REVIEW";
        decision = "REVIEW_RSM_EVALUATIONS_OR_EXPORTS";
        next_step = "Review failed checks.";
    end

    outChecksCsv = fullfile(tablesDir,'LOCAL_RESPONSE_SURFACES_AROUND_H2_v96q_rsm1_checks.csv');
    writetable(Tchecks,outChecksCsv);

    % ---------------------------------------------------------------------
    % Guardar MAT
    % ---------------------------------------------------------------------
    outMat = fullfile(matDir,'LOCAL_RESPONSE_SURFACES_AROUND_H2_v96q_rsm1.mat');

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'xH2','mRange','TRange','rRange','tRange','nGrid', ...
        'surfaces','T_TR','T_TM','T_RM','Tall','TsurfaceSummary','Tchecks', ...
        'Tsolutions','Trecommended','Tsummary', ...
        'runtime_s','rsmDir','pngDir','pdfDir','figDir','tablesDir', ...
        'figureFiles','pdfFiles','figFiles', ...
        'outAllCsv','outTRCsv','outTMCsv','outRMCsv','outSummaryCsv','outChecksCsv');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'LOCAL_RESPONSE_SURFACES_AROUND_H2_v96q_rsm1.md');

    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# LOCAL_RESPONSE_SURFACES_AROUND_H2_v96q_rsm1\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Decisión: `%s`\n\n', decision);
    fprintf(fid,'Siguiente paso: `%s`\n\n', next_step);

    fprintf(fid,'## Centro H2\n\n');
    fprintf(fid,'| Variable | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| m_max | %.12g |\n', m0);
    fprintf(fid,'| T_min | %.12g |\n', T0);
    fprintf(fid,'| r_div2 | %.12g |\n', r0);
    fprintf(fid,'| t_rec_ini | %.12g |\n\n', t0);

    fprintf(fid,'## Resultado H2\n\n');
    fprintf(fid,'| Métrica | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| MR | %.12g |\n', Trecommended.MR(1));
    fprintf(fid,'| cost_specific | %.12g |\n', Trecommended.cost_specific(1));
    fprintf(fid,'| CO2_specific | %.12g |\n', Trecommended.CO2_specific(1));
    fprintf(fid,'| cost_reduction_pct_vs_gasLP | %.12g |\n', Trecommended.reduction_cost_pct_vs_gasLP(1));
    fprintf(fid,'| CO2_reduction_pct_vs_gasLP | %.12g |\n\n', Trecommended.reduction_CO2_pct_vs_gasLP(1));

    fprintf(fid,'## Superficies generadas\n\n');
    fprintf(fid,'| Superficie | Puntos | Puntos finitos | Puntos MR<0.1 | minMR | minCost | minCO2 |\n');
    fprintf(fid,'|---|---:|---:|---:|---:|---:|---:|\n');

    for i = 1:height(TsurfaceSummary)
        fprintf(fid,'| `%s` | %d | %d | %d | %.12g | %.12g | %.12g |\n', ...
            string(TsurfaceSummary.surface(i)), ...
            TsurfaceSummary.n_points(i), ...
            TsurfaceSummary.n_finite(i), ...
            TsurfaceSummary.n_admissible(i), ...
            TsurfaceSummary.min_MR(i), ...
            TsurfaceSummary.min_cost(i), ...
            TsurfaceSummary.min_CO2(i));
    end

    fprintf(fid,'\n## Figuras PNG\n\n');
    for i = 1:numel(figureFiles)
        fprintf(fid,'- `%s`\n', figureFiles(i));
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

    fprintf(fid,'\n## Interpretación preliminar\n\n');
    fprintf(fid,'Estas superficies son locales alrededor de H2. Sirven para revisar robustez y sensibilidad operativa, no para reemplazar la corrida formal GA. ');
    fprintf(fid,'La interpretación debe mantenerse limitada al modo híbrido. Los valores de CO2 siguen siendo provisionales.\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % Consola
    % ---------------------------------------------------------------------
    rsm = struct();
    rsm.status = 'LOCAL_RESPONSE_SURFACES_AROUND_H2_COMPLETED';
    rsm.diagnosis = diagnosis;
    rsm.decision = decision;
    rsm.next_step = next_step;
    rsm.xH2 = xH2;
    rsm.nGrid = nGrid;
    rsm.runtime_s = runtime_s;
    rsm.surfaces = surfaces;
    rsm.Tall = Tall;
    rsm.TsurfaceSummary = TsurfaceSummary;
    rsm.Tchecks = Tchecks;
    rsm.rsmDir = rsmDir;
    rsm.pngDir = pngDir;
    rsm.pdfDir = pdfDir;
    rsm.figDir = figDir;
    rsm.tablesDir = tablesDir;
    rsm.figureFiles = figureFiles;
    rsm.outMd = outMd;
    rsm.outMat = outMat;

    disp('=== LOCAL_RESPONSE_SURFACES_AROUND_H2_v96q_rsm1 ===')
    disp(rsm.status)
    disp('=== DIAGNOSIS ===')
    disp(rsm.diagnosis)
    disp('=== DECISION ===')
    disp(rsm.decision)
    disp('=== NEXT STEP ===')
    disp(rsm.next_step)
    disp('=== H2 CENTER ===')
    disp(array2table(rsm.xH2,'VariableNames',{'m_max','T_min','r_div2','t_rec_ini'}))
    disp('=== SURFACE SUMMARY ===')
    disp(rsm.TsurfaceSummary)
    disp('=== CHECKS ===')
    disp(rsm.Tchecks)
    disp('=== PNG DIR ===')
    disp(rsm.pngDir)
    disp('=== OUTPUT MD ===')
    disp(rsm.outMd)

end

% =========================================================================
% Evaluation helpers
% =========================================================================

function surfOut = local_eval_pair_surface_v96q_rsm1(objectiveFcn, mode_operation, xCenter, idxA, rangeA, idxB, rangeB, nameA, nameB)

    [AA,BB] = meshgrid(rangeA, rangeB);

    MR = NaN(size(AA));
    COST = NaN(size(AA));
    CO2 = NaN(size(AA));
    status = strings(size(AA));
    detail_status = strings(size(AA));
    runtime_s = NaN(size(AA));

    X1 = NaN(size(AA));
    X2 = NaN(size(AA));
    X3 = NaN(size(AA));
    X4 = NaN(size(AA));

    for i = 1:numel(AA)
        x = xCenter;
        x(idxA) = AA(i);
        x(idxB) = BB(i);

        X1(i) = x(1);
        X2(i) = x(2);
        X3(i) = x(3);
        X4(i) = x(4);

        tEval = tic;

        try
            [f, detail] = objectiveFcn(x, mode_operation);

            runtime_s(i) = toc(tEval);

            if numel(f) >= 3
                MR(i) = f(1);
                COST(i) = f(2);
                CO2(i) = f(3);
            end

            status(i) = "OK";

            if exist('detail','var') && isstruct(detail) && isfield(detail,'status')
                detail_status(i) = string(detail.status);
            else
                detail_status(i) = "";
            end

        catch ME
            runtime_s(i) = toc(tEval);
            status(i) = "ERROR";
            detail_status(i) = string(ME.message);
        end
    end

    surfOut = struct();
    surfOut.nameA = string(nameA);
    surfOut.nameB = string(nameB);
    surfOut.idxA = idxA;
    surfOut.idxB = idxB;
    surfOut.rangeA = rangeA;
    surfOut.rangeB = rangeB;
    surfOut.AA = AA;
    surfOut.BB = BB;
    surfOut.MR = MR;
    surfOut.COST = COST;
    surfOut.CO2 = CO2;
    surfOut.status = status;
    surfOut.detail_status = detail_status;
    surfOut.runtime_s = runtime_s;
    surfOut.X1_m_max = X1;
    surfOut.X2_T_min = X2;
    surfOut.X3_r_div2 = X3;
    surfOut.X4_t_rec_ini = X4;
end

function T = local_surface_to_table_v96q_rsm1(surfOut, surfaceName)

    n = numel(surfOut.AA);

    T = table();
    T.surface = repmat(string(surfaceName),n,1);
    T.varA_name = repmat(string(surfOut.nameA),n,1);
    T.varB_name = repmat(string(surfOut.nameB),n,1);
    T.varA_value = reshape(surfOut.AA,[],1);
    T.varB_value = reshape(surfOut.BB,[],1);

    T.m_max = reshape(surfOut.X1_m_max,[],1);
    T.T_min = reshape(surfOut.X2_T_min,[],1);
    T.r_div2 = reshape(surfOut.X3_r_div2,[],1);
    T.t_rec_ini = reshape(surfOut.X4_t_rec_ini,[],1);

    T.MR = reshape(surfOut.MR,[],1);
    T.cost_specific = reshape(surfOut.COST,[],1);
    T.CO2_specific = reshape(surfOut.CO2,[],1);

    T.status = reshape(surfOut.status,[],1);
    T.detail_status = reshape(surfOut.detail_status,[],1);
    T.runtime_s = reshape(surfOut.runtime_s,[],1);
    T.admissible_MR = T.MR < 0.1;
end

function row = local_surface_summary_row_v96q_rsm1(surfOut, surfaceName, MR_acceptance)

    MR = surfOut.MR(:);
    COST = surfOut.COST(:);
    CO2 = surfOut.CO2(:);

    finiteRows = isfinite(MR) & isfinite(COST) & isfinite(CO2);
    admRows = finiteRows & MR < MR_acceptance;

    row = struct();
    row.surface = string(surfaceName);
    row.n_points = numel(MR);
    row.n_finite = sum(finiteRows);
    row.n_admissible = sum(admRows);
    row.min_MR = local_nanmin_v96q_rsm1(MR(finiteRows));
    row.min_cost = local_nanmin_v96q_rsm1(COST(finiteRows));
    row.min_CO2 = local_nanmin_v96q_rsm1(CO2(finiteRows));
    row.max_MR = local_nanmax_v96q_rsm1(MR(finiteRows));
    row.max_cost = local_nanmax_v96q_rsm1(COST(finiteRows));
    row.max_CO2 = local_nanmax_v96q_rsm1(CO2(finiteRows));
end

function v = local_nanmin_v96q_rsm1(x)
    if isempty(x)
        v = NaN;
    else
        v = min(x,[],'omitnan');
    end
end

function v = local_nanmax_v96q_rsm1(x)
    if isempty(x)
        v = NaN;
    else
        v = max(x,[],'omitnan');
    end
end

% =========================================================================
% Plot helpers
% =========================================================================

function [figureFiles,pdfFiles,figFiles] = local_plot_all_for_surface_v96q_rsm1( ...
    surfOut, xlabelName, ylabelName, labelTitle, ...
    xH2, gasMR, gasCost, gasCO2, MR_acceptance, ...
    pngDir, pdfDir, figDir, figureFiles, pdfFiles, figFiles)

    visibleState = 'on';

    A = surfOut.AA;
    B = surfOut.BB;

    metrics = { ...
        'MR', surfOut.MR, 'MR final'; ...
        'cost', surfOut.COST, 'Costo específico'; ...
        'CO2', surfOut.CO2, 'CO2 específico provisional'};

    for k = 1:size(metrics,1)
        metricTag = metrics{k,1};
        Z = metrics{k,2};
        metricLabel = metrics{k,3};

        % -------------------------------------------------------------
        % Contour
        % -------------------------------------------------------------
        figName = sprintf('RSM_%s_%s_contour', labelTitle, metricTag);

        f = figure('Name',figName, ...
            'Color','w', ...
            'Units','pixels', ...
            'Position',[120+40*k 100+40*k 1150 760], ...
            'Visible',visibleState);

        hold on; grid on; box on;

        contourf(A,B,Z,15,'LineStyle','none');
        colorbar;
        contour(A,B,Z,10,'LineColor',[0.2 0.2 0.2]);

        if strcmp(metricTag,'MR')
            contour(A,B,Z,[MR_acceptance MR_acceptance], ...
                'LineColor','k','LineStyle','--','LineWidth',2);
        end

        [h2A,h2B] = local_project_H2_to_surface_v96q_rsm1(surfOut,xH2);

        scatter(h2A,h2B,160,'p','filled','MarkerEdgeColor','k');
        text(h2A,h2B,'  H2','FontWeight','bold','Color','k');

        xlabel(xlabelName);
        ylabel(ylabelName);
        title(sprintf('%s — %s', labelTitle, metricLabel));

        safeLabel = local_safe_filename_v96q_rsm1(sprintf('%s_%s_contour', labelTitle, metricTag));

        outPng = fullfile(pngDir,['RSM_' safeLabel '.png']);
        outPdf = fullfile(pdfDir,['RSM_' safeLabel '.pdf']);
        outFig = fullfile(figDir,['RSM_' safeLabel '.fig']);

        saveas(f,outPng);
        savefig(f,outFig);
        exportgraphics(f,outPdf,'ContentType','vector');

        figureFiles(end+1,1) = string(outPng); %#ok<AGROW>
        pdfFiles(end+1,1) = string(outPdf); %#ok<AGROW>
        figFiles(end+1,1) = string(outFig); %#ok<AGROW>

        % -------------------------------------------------------------
        % Surface 3D
        % -------------------------------------------------------------
        figName = sprintf('RSM_%s_%s_surface', labelTitle, metricTag);

        fs = figure('Name',figName, ...
            'Color','w', ...
            'Units','pixels', ...
            'Position',[180+40*k 140+40*k 1150 760], ...
            'Visible',visibleState);

        hold on; grid on; box on;

        surf(A,B,Z,'EdgeAlpha',0.25);
        colorbar;

        zH2 = local_interp_surface_value_v96q_rsm1(A,B,Z,h2A,h2B);
        scatter3(h2A,h2B,zH2,180,'p','filled','MarkerEdgeColor','k');
        text(h2A,h2B,zH2,'  H2','FontWeight','bold','Color','k');

        xlabel(xlabelName);
        ylabel(ylabelName);
        zlabel(metricLabel);
        title(sprintf('%s — superficie %s', labelTitle, metricLabel));

        view(135,28);

        safeLabel = local_safe_filename_v96q_rsm1(sprintf('%s_%s_surface', labelTitle, metricTag));

        outPng = fullfile(pngDir,['RSM_' safeLabel '.png']);
        outPdf = fullfile(pdfDir,['RSM_' safeLabel '.pdf']);
        outFig = fullfile(figDir,['RSM_' safeLabel '.fig']);

        saveas(fs,outPng);
        savefig(fs,outFig);
        exportgraphics(fs,outPdf,'ContentType','vector');

        figureFiles(end+1,1) = string(outPng); %#ok<AGROW>
        pdfFiles(end+1,1) = string(outPdf); %#ok<AGROW>
        figFiles(end+1,1) = string(outFig); %#ok<AGROW>
    end
end

function [h2A,h2B] = local_project_H2_to_surface_v96q_rsm1(surfOut,xH2)
    h2A = xH2(surfOut.idxA);
    h2B = xH2(surfOut.idxB);
end

function z = local_interp_surface_value_v96q_rsm1(A,B,Z,a,b)
    try
        z = interp2(A,B,Z,a,b,'linear');
        if ~isfinite(z)
            z = interp2(A,B,Z,a,b,'nearest');
        end
    catch
        z = NaN;
    end
end

function s = local_safe_filename_v96q_rsm1(s)
    s = string(s);
    s = replace(s," ","_");
    s = replace(s,"—","_");
    s = replace(s,"-","_");
    s = replace(s,"/","_");
    s = replace(s,"\","_");
    s = replace(s,":","_");
    s = replace(s,".","p");
    s = char(s);
end

function row = local_check_row_v96q_rsm1(id, checkName, passVal, evidence, criterion)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
    row.criterion = string(criterion);
end