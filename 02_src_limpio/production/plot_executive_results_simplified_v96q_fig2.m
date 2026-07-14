function figs = plot_executive_results_simplified_v96q_fig2()
% PLOT_EXECUTIVE_RESULTS_SIMPLIFIED_v96q_fig2
% 9.6q-fig2 — EXECUTIVE-RESULTS-FIGURES-SIMPLIFIED-001
%
% Objetivo:
%   Generar un paquete mínimo de 3 figuras limpias para revisión visual:
%
%   FIG_A: Frente MR vs costo con H2, gasLP y frontera MR = 0.1.
%   FIG_B: Comparación gasLP vs H2 en MR, costo y CO2.
%   FIG_C: Espacio operativo T_min vs r_div2 con admisibles/inadmisibles.
%
% Este script:
%   - NO ejecuta gamultiobj.
%   - NO llama la función objetivo.
%   - NO llama el modelo mecanístico.
%   - NO genera superficies 3D.
%   - NO genera “sábanas” cuadriculadas.
%   - Usa solo resultados ya consolidados en v96p.
%
% Uso:
%   figs = plot_executive_results_simplified_v96q_fig2();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    MR_acceptance = 0.10;

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

    T = S.Tsolutions;
    Trecommended = S.Trecommended;
    Tsummary = S.Tsummary;

    gasMR = Tsummary.gasLP_MR(1);
    gasCost = Tsummary.gasLP_cost(1);
    gasCO2 = Tsummary.gasLP_CO2(1);

    recID = string(Trecommended.solution_id(1));
    idxRec = find(string(T.solution_id) == recID,1,'first');

    if isempty(idxRec)
        error('No se encontró la solución recomendada %s en Tsolutions.', recID);
    end

    isAdm = T.MR < MR_acceptance;
    isInadm = ~isAdm;

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    figBaseDir = fullfile(rootDir,'05_runs','executive_results_figures_simplified_v96q_fig2');
    figDir = fullfile(figBaseDir,['EXECUTIVE_RESULTS_FIGURES_SIMPLIFIED_v96q_fig2_' timestamp]);

    pngDir = fullfile(figDir,'png');
    pdfDir = fullfile(figDir,'pdf');
    figNativeDir = fullfile(figDir,'fig');
    logsDir = fullfile(figDir,'logs');
    matDir = fullfile(figDir,'mat');
    tablesDir = fullfile(figDir,'tables');

    mkdir_if_needed(figBaseDir);
    mkdir_if_needed(figDir);
    mkdir_if_needed(pngDir);
    mkdir_if_needed(pdfDir);
    mkdir_if_needed(figNativeDir);
    mkdir_if_needed(logsDir);
    mkdir_if_needed(matDir);
    mkdir_if_needed(tablesDir);

    % ---------------------------------------------------------------------
    % Exportar tabla base de puntos graficados
    % ---------------------------------------------------------------------
    Tplot = T;
    Tplot.is_admissible_MR = isAdm;
    Tplot.is_recommended = string(T.solution_id) == recID;

    outPlotCsv = fullfile(tablesDir,'EXECUTIVE_RESULTS_FIGURES_SIMPLIFIED_v96q_fig2_plot_points.csv');
    writetable(Tplot,outPlotCsv);

    % ---------------------------------------------------------------------
    % FIGURA A — Frente ejecutivo MR vs costo
    % ---------------------------------------------------------------------
    fA = figure('Name','FIG_A Executive front MR-cost', ...
        'Color','w', ...
        'Units','pixels', ...
        'Position',[120 100 1120 720]);

    hold on; grid on; box on;

    % Inadmisibles
    scatter(T.MR(isInadm), T.cost_specific(isInadm), ...
        95, 'x', ...
        'LineWidth',1.8);

    % Admisibles
    scatter(T.MR(isAdm), T.cost_specific(isAdm), ...
        95, 'o', ...
        'filled', ...
        'MarkerEdgeColor','k');

    % H2
    scatter(T.MR(idxRec), T.cost_specific(idxRec), ...
        230, 'p', ...
        'filled', ...
        'MarkerEdgeColor','k', ...
        'LineWidth',1.2);

    % gasLP
    scatter(gasMR, gasCost, ...
        210, 's', ...
        'filled', ...
        'MarkerEdgeColor','k', ...
        'LineWidth',1.2);

    xline(MR_acceptance,'--','MR = 0.1', ...
        'LineWidth',1.4, ...
        'LabelOrientation','horizontal', ...
        'LabelVerticalAlignment','bottom');

    % Etiquetas solo necesarias
    for i = 1:height(T)
        text(T.MR(i), T.cost_specific(i), "  " + string(T.solution_id(i)), ...
            'FontSize',9);
    end

    text(gasMR, gasCost, '  gasLP', ...
        'FontWeight','bold', ...
        'FontSize',10);

    text(T.MR(idxRec), T.cost_specific(idxRec), '  H2 recomendada', ...
        'FontWeight','bold', ...
        'FontSize',10);

    xlabel('MR final');
    ylabel('Costo específico');
    title('Figura A. Frente formal híbrido: secado vs costo');

    legend({'Inadmisibles MR >= 0.1', ...
            'Admisibles MR < 0.1', ...
            'H2 recomendada', ...
            'gasLP referencia', ...
            'Frontera MR = 0.1'}, ...
            'Location','best');

    set(gca,'FontSize',11);
    axis padded;

    outA_png = fullfile(pngDir,'FIG_A_executive_front_MR_vs_cost.png');
    outA_pdf = fullfile(pdfDir,'FIG_A_executive_front_MR_vs_cost.pdf');
    outA_fig = fullfile(figNativeDir,'FIG_A_executive_front_MR_vs_cost.fig');

    saveas(fA,outA_png);
    savefig(fA,outA_fig);
    exportgraphics(fA,outA_pdf,'ContentType','vector');

    % ---------------------------------------------------------------------
    % FIGURA B — Barras gasLP vs H2
    % ---------------------------------------------------------------------
    fB = figure('Name','FIG_B gasLP vs H2', ...
        'Color','w', ...
        'Units','pixels', ...
        'Position',[160 130 1120 620]);

    tiledlayout(1,3,'Padding','compact','TileSpacing','compact');

    % MR
    nexttile;
    b1 = bar([gasMR, Trecommended.MR(1)]);
    set(gca,'XTickLabel',{'gasLP','H2'});
    ylabel('MR final');
    title('MR');
    grid on; box on;
    text(1,gasMR,sprintf(' %.4f',gasMR),'VerticalAlignment','bottom','HorizontalAlignment','center');
    text(2,Trecommended.MR(1),sprintf(' %.4f',Trecommended.MR(1)),'VerticalAlignment','bottom','HorizontalAlignment','center');

    % Costo
    nexttile;
    b2 = bar([gasCost, Trecommended.cost_specific(1)]);
    set(gca,'XTickLabel',{'gasLP','H2'});
    ylabel('Costo específico');
    title(sprintf('Costo: %.1f%% menor', Trecommended.reduction_cost_pct_vs_gasLP(1)));
    grid on; box on;
    text(1,gasCost,sprintf(' %.4f',gasCost),'VerticalAlignment','bottom','HorizontalAlignment','center');
    text(2,Trecommended.cost_specific(1),sprintf(' %.4f',Trecommended.cost_specific(1)),'VerticalAlignment','bottom','HorizontalAlignment','center');

    % CO2
    nexttile;
    b3 = bar([gasCO2, Trecommended.CO2_specific(1)]);
    set(gca,'XTickLabel',{'gasLP','H2'});
    ylabel('CO2 específico');
    title(sprintf('CO2: %.1f%% menor', Trecommended.reduction_CO2_pct_vs_gasLP(1)));
    grid on; box on;
    text(1,gasCO2,sprintf(' %.4f',gasCO2),'VerticalAlignment','bottom','HorizontalAlignment','center');
    text(2,Trecommended.CO2_specific(1),sprintf(' %.4f',Trecommended.CO2_specific(1)),'VerticalAlignment','bottom','HorizontalAlignment','center');

    sgtitle('Figura B. Comparación gasLP vs H2 recomendada');

    outB_png = fullfile(pngDir,'FIG_B_gasLP_vs_H2_bars.png');
    outB_pdf = fullfile(pdfDir,'FIG_B_gasLP_vs_H2_bars.pdf');
    outB_fig = fullfile(figNativeDir,'FIG_B_gasLP_vs_H2_bars.fig');

    saveas(fB,outB_png);
    savefig(fB,outB_fig);
    exportgraphics(fB,outB_pdf,'ContentType','vector');

    % ---------------------------------------------------------------------
    % FIGURA C — Espacio operativo T_min vs r_div2
    % ---------------------------------------------------------------------
    fC = figure('Name','FIG_C Operating space Tmin-rdiv2', ...
        'Color','w', ...
        'Units','pixels', ...
        'Position',[200 160 1120 720]);

    hold on; grid on; box on;

    scatter(T.T_min(isInadm), T.r_div2(isInadm), ...
        105, 'x', ...
        'LineWidth',1.8);

    scatter(T.T_min(isAdm), T.r_div2(isAdm), ...
        105, 'o', ...
        'filled', ...
        'MarkerEdgeColor','k');

    scatter(T.T_min(idxRec), T.r_div2(idxRec), ...
        240, 'p', ...
        'filled', ...
        'MarkerEdgeColor','k', ...
        'LineWidth',1.2);

    for i = 1:height(T)
        text(T.T_min(i), T.r_div2(i), "  " + string(T.solution_id(i)), ...
            'FontSize',9);
    end

    text(T.T_min(idxRec), T.r_div2(idxRec), '  H2 recomendada', ...
        'FontWeight','bold', ...
        'FontSize',10);

    xlabel('T_{min}');
    ylabel('r_{div2}');
    title('Figura C. Ubicación operativa de H2 en T_{min} vs r_{div2}');

    legend({'Inadmisibles MR >= 0.1', ...
            'Admisibles MR < 0.1', ...
            'H2 recomendada'}, ...
            'Location','best');

    set(gca,'FontSize',11);
    axis padded;

    outC_png = fullfile(pngDir,'FIG_C_operating_space_Tmin_vs_rdiv2.png');
    outC_pdf = fullfile(pdfDir,'FIG_C_operating_space_Tmin_vs_rdiv2.pdf');
    outC_fig = fullfile(figNativeDir,'FIG_C_operating_space_Tmin_vs_rdiv2.fig');

    saveas(fC,outC_png);
    savefig(fC,outC_fig);
    exportgraphics(fC,outC_pdf,'ContentType','vector');

    % ---------------------------------------------------------------------
    % Resumen ejecutivo
    % ---------------------------------------------------------------------
    summary = struct();
    summary.figure_set = "executive simplified";
    summary.no_surfaces_3D = true;
    summary.no_mechanistic_rerun = true;
    summary.no_GA_executed = true;
    summary.recommended_solution_id = recID;
    summary.H2_m_max = Trecommended.m_max(1);
    summary.H2_T_min = Trecommended.T_min(1);
    summary.H2_r_div2 = Trecommended.r_div2(1);
    summary.H2_t_rec_ini = Trecommended.t_rec_ini(1);
    summary.H2_MR = Trecommended.MR(1);
    summary.H2_cost_specific = Trecommended.cost_specific(1);
    summary.H2_CO2_specific = Trecommended.CO2_specific(1);
    summary.H2_cost_reduction_pct_vs_gasLP = Trecommended.reduction_cost_pct_vs_gasLP(1);
    summary.H2_CO2_reduction_pct_vs_gasLP = Trecommended.reduction_CO2_pct_vs_gasLP(1);
    summary.H2_MR_reduction_pct_vs_gasLP = Trecommended.reduction_MR_pct_vs_gasLP(1);
    summary.n_formal_solutions = height(T);
    summary.n_admissible_MR = sum(isAdm);
    summary.n_inadmissible_MR = sum(isInadm);
    summary.CO2_factor_status = "PROVISIONAL_FOR_CODE_VALIDATION";

    TsummaryFig = struct2table(summary);

    outSummaryCsv = fullfile(tablesDir,'EXECUTIVE_RESULTS_FIGURES_SIMPLIFIED_v96q_fig2_summary.csv');
    writetable(TsummaryFig,outSummaryCsv);

    % ---------------------------------------------------------------------
    % Checks y salida
    % ---------------------------------------------------------------------
    figureFiles = string({outA_png; outB_png; outC_png});
    pdfFiles = string({outA_pdf; outB_pdf; outC_pdf});
    figFiles = string({outA_fig; outB_fig; outC_fig});

    checks = {};
    checks{end+1,1} = check_row('F2A','Figure A created',isfile(outA_png),outA_png);
    checks{end+1,1} = check_row('F2B','Figure B created',isfile(outB_png),outB_png);
    checks{end+1,1} = check_row('F2C','Figure C created',isfile(outC_png),outC_png);
    checks{end+1,1} = check_row('F2D','PDF files created',all(isfile(pdfFiles)),pdfDir);
    checks{end+1,1} = check_row('F2E','FIG native files created',all(isfile(figFiles)),figNativeDir);
    checks{end+1,1} = check_row('F2F','No GA executed',true,'No gamultiobj call.');
    checks{end+1,1} = check_row('F2G','No mechanistic rerun',true,'No objective/model call.');
    checks{end+1,1} = check_row('F2H','No 3D surface generated',true,'Only 2D executive figures and bar chart.');
    checks{end+1,1} = check_row('F2I','H2 preserved',recID=="H2",sprintf('recommended=%s',recID));
    checks{end+1,1} = check_row('F2J','H2 admissible',Trecommended.MR(1)<MR_acceptance,sprintf('MR=%.6g',Trecommended.MR(1)));

    Tchecks = struct2table(vertcat(checks{:}));

    if all(Tchecks.pass)
        diagnosis = "EXECUTIVE_RESULTS_FIGURES_SIMPLIFIED_PASS";
        decision = "THREE_CLEAN_FIGURE_SET_READY_FOR_REVIEW";
        next_step = "Visual review; use these figures for narrative before 9.6r.";
    else
        diagnosis = "EXECUTIVE_RESULTS_FIGURES_SIMPLIFIED_REQUIRES_REVIEW";
        decision = "REVIEW_FIGURE_EXPORTS";
        next_step = "Review failed checks.";
    end

    outChecksCsv = fullfile(tablesDir,'EXECUTIVE_RESULTS_FIGURES_SIMPLIFIED_v96q_fig2_checks.csv');
    writetable(Tchecks,outChecksCsv);

    outMat = fullfile(matDir,'EXECUTIVE_RESULTS_FIGURES_SIMPLIFIED_v96q_fig2.mat');

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'T','Trecommended','Tsummary','TsummaryFig','Tchecks', ...
        'figureFiles','pdfFiles','figFiles', ...
        'figDir','pngDir','pdfDir','figNativeDir','logsDir','matDir','tablesDir', ...
        'outPlotCsv','outSummaryCsv','outChecksCsv');

    outMd = fullfile(logsDir,'EXECUTIVE_RESULTS_FIGURES_SIMPLIFIED_v96q_fig2.md');

    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# EXECUTIVE_RESULTS_FIGURES_SIMPLIFIED_v96q_fig2\n\n');
    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Decisión: `%s`\n\n', decision);
    fprintf(fid,'Siguiente paso: `%s`\n\n', next_step);

    fprintf(fid,'## Criterio editorial\n\n');
    fprintf(fid,'Este paquete elimina superficies 3D y mapas cuadriculados. ');
    fprintf(fid,'Se conservan únicamente tres figuras limpias para comunicar el resultado principal.\n\n');

    fprintf(fid,'## Solución recomendada\n\n');
    fprintf(fid,'| Campo | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| solution_id | `%s` |\n', recID);
    fprintf(fid,'| m_max | %.12g |\n', Trecommended.m_max(1));
    fprintf(fid,'| T_min | %.12g |\n', Trecommended.T_min(1));
    fprintf(fid,'| r_div2 | %.12g |\n', Trecommended.r_div2(1));
    fprintf(fid,'| t_rec_ini | %.12g |\n', Trecommended.t_rec_ini(1));
    fprintf(fid,'| MR | %.12g |\n', Trecommended.MR(1));
    fprintf(fid,'| cost_specific | %.12g |\n', Trecommended.cost_specific(1));
    fprintf(fid,'| CO2_specific | %.12g |\n', Trecommended.CO2_specific(1));
    fprintf(fid,'| cost_reduction_pct_vs_gasLP | %.12g |\n', Trecommended.reduction_cost_pct_vs_gasLP(1));
    fprintf(fid,'| CO2_reduction_pct_vs_gasLP | %.12g |\n\n', Trecommended.reduction_CO2_pct_vs_gasLP(1));

    fprintf(fid,'## Figuras PNG\n\n');
    for i = 1:numel(figureFiles)
        fprintf(fid,'- `%s`\n', figureFiles(i));
    end

    fprintf(fid,'\n## Checks\n\n');
    fprintf(fid,'| ID | Check | Pass | Evidencia |\n');
    fprintf(fid,'|---|---|---:|---|\n');

    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | `%s` | `%d` | `%s` |\n', ...
            string(Tchecks.id(i)), ...
            string(Tchecks.check(i)), ...
            Tchecks.pass(i), ...
            string(Tchecks.evidence(i)));
    end

    fprintf(fid,'\n## Dictamen\n\n');
    fprintf(fid,'Las tres figuras limpias están listas para revisión visual. ');
    fprintf(fid,'Este conjunto debe tener prioridad sobre las superficies exploratorias previas.\n');

    fclose(fid);

    figs = struct();
    figs.status = 'EXECUTIVE_RESULTS_FIGURES_SIMPLIFIED_COMPLETED';
    figs.diagnosis = diagnosis;
    figs.decision = decision;
    figs.next_step = next_step;
    figs.figureFiles = figureFiles;
    figs.pdfFiles = pdfFiles;
    figs.figFiles = figFiles;
    figs.TsummaryFig = TsummaryFig;
    figs.Tchecks = Tchecks;
    figs.figDir = figDir;
    figs.pngDir = pngDir;
    figs.pdfDir = pdfDir;
    figs.figNativeDir = figNativeDir;
    figs.outMd = outMd;
    figs.outMat = outMat;

    disp('=== EXECUTIVE_RESULTS_FIGURES_SIMPLIFIED_v96q_fig2 ===')
    disp(figs.status)
    disp('=== DIAGNOSIS ===')
    disp(figs.diagnosis)
    disp('=== DECISION ===')
    disp(figs.decision)
    disp('=== NEXT STEP ===')
    disp(figs.next_step)
    disp('=== SUMMARY ===')
    disp(figs.TsummaryFig)
    disp('=== FIGURES ===')
    disp(figs.figureFiles)
    disp('=== CHECKS ===')
    disp(figs.Tchecks)
    disp('=== PNG DIR ===')
    disp(figs.pngDir)

end

% =========================================================================
% Helpers
% =========================================================================

function mkdir_if_needed(folderPath)
    if ~isfolder(folderPath)
        mkdir(folderPath);
    end
end

function row = check_row(id, checkName, passVal, evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end