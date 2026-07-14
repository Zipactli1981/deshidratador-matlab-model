function figs = plot_corrected_triobjective_executive_figures_v96q_fig3()
% PLOT_CORRECTED_TRIOBJECTIVE_EXECUTIVE_FIGURES_v96q_fig3
% 9.6q-fig3 — CORRECTED-TRIOBJECTIVE-EXECUTIVE-FIGURES-001
%
% Objetivo:
%   Generar un paquete corregido de 3 figuras ejecutivas para el problema
%   triobjetivo formal:
%
%   FIG_A:
%       Frente triobjetivo simplificado:
%       X = MR final
%       Y = costo específico
%       tamaño del marcador = CO2 específico
%       incluye gasLP, H2, frontera MR=0.1
%
%   FIG_B:
%       Comparación gasLP vs H2:
%       MR, costo específico y CO2 específico
%       incluye porcentaje de diferencia/reducción.
%
%   FIG_C:
%       Espacio operativo 3D:
%       X = T_min
%       Y = r_div2
%       Z = t_rec_ini
%       admisibilidad por MR
%       H2 destacado.
%
% Este script:
%   - NO ejecuta gamultiobj.
%   - NO llama la función objetivo.
%   - NO llama el modelo mecanístico.
%   - NO genera superficies de respuesta.
%   - Usa únicamente resultados ya consolidados en v96p.
%
% Uso:
%   figs = plot_corrected_triobjective_executive_figures_v96q_fig3();

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

    recID = string(Trecommended.solution_id(1));
    idxRec = find(string(T.solution_id) == recID,1,'first');

    if isempty(idxRec)
        error('No se encontró la solución recomendada %s en Tsolutions.', recID);
    end

    gasMR = Tsummary.gasLP_MR(1);
    gasCost = Tsummary.gasLP_cost(1);
    gasCO2 = Tsummary.gasLP_CO2(1);

    isAdm = T.MR < MR_acceptance;
    isInadm = ~isAdm;

    % Puntos que sí vale la pena etiquetar.
    labelIDs = ["H1","H2","H4","H9"];
    mustLabel = ismember(string(T.solution_id), labelIDs);

    idxH1 = find(string(T.solution_id)=="H1",1,'first');
    idxH2 = find(string(T.solution_id)=="H2",1,'first');
    idxH4 = find(string(T.solution_id)=="H4",1,'first');
    idxH9 = find(string(T.solution_id)=="H9",1,'first');

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    figBaseDir = fullfile(rootDir,'05_runs','corrected_triobjective_executive_figures_v96q_fig3');
    figDir = fullfile(figBaseDir,['CORRECTED_TRIOBJECTIVE_EXECUTIVE_FIGURES_v96q_fig3_' timestamp]);

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
    % Tabla base
    % ---------------------------------------------------------------------
    Tplot = T;
    Tplot.is_admissible_MR = isAdm;
    Tplot.is_recommended = string(T.solution_id) == recID;
    Tplot.is_labeled_in_figures = mustLabel;

    outPlotCsv = fullfile(tablesDir,'CORRECTED_TRIOBJECTIVE_EXECUTIVE_FIGURES_v96q_fig3_plot_points.csv');
    writetable(Tplot,outPlotCsv);

    % ---------------------------------------------------------------------
    % Escala de tamaño para CO2
    % ---------------------------------------------------------------------
    co2Vals = T.CO2_specific;
    co2Min = min(co2Vals);
    co2Max = max(co2Vals);

    if co2Max > co2Min
        sizeCO2 = 80 + 220*(co2Vals - co2Min)/(co2Max - co2Min);
        gasSizeCO2 = 80 + 220*(gasCO2 - co2Min)/(co2Max - co2Min);
    else
        sizeCO2 = 140*ones(size(co2Vals));
        gasSizeCO2 = 180;
    end

    gasSizeCO2 = max(120,min(320,gasSizeCO2));

    % ---------------------------------------------------------------------
    % FIGURA A — Frente triobjetivo simplificado
    % ---------------------------------------------------------------------
    fA = figure('Name','FIG_A Triobjective executive bubble front', ...
        'Color','w', ...
        'Units','pixels', ...
        'Position',[100 80 1180 760]);

    hold on; grid on; box on;

    % Inadmisibles
    scatter(T.MR(isInadm), T.cost_specific(isInadm), sizeCO2(isInadm), ...
        'x', ...
        'LineWidth',1.8);

    % Admisibles
    scatter(T.MR(isAdm), T.cost_specific(isAdm), sizeCO2(isAdm), ...
        'o', ...
        'filled', ...
        'MarkerEdgeColor','k');

    % H2
    scatter(T.MR(idxRec), T.cost_specific(idxRec), 320, ...
        'p', ...
        'filled', ...
        'MarkerEdgeColor','k', ...
        'LineWidth',1.4);

    % gasLP
    scatter(gasMR, gasCost, gasSizeCO2, ...
        's', ...
        'filled', ...
        'MarkerEdgeColor','k', ...
        'LineWidth',1.4);

    xline(MR_acceptance,'--','MR = 0.1', ...
        'LineWidth',1.4, ...
        'LabelOrientation','horizontal', ...
        'LabelVerticalAlignment','bottom');

    % Etiquetas selectivas, no todas.
    local_label_point_2d(T, mustLabel, 'MR', 'cost_specific');

    text(T.MR(idxRec), T.cost_specific(idxRec), '  H2 recomendada', ...
        'FontWeight','bold', ...
        'FontSize',10);

    text(gasMR, gasCost, '  gasLP', ...
        'FontWeight','bold', ...
        'FontSize',10);

    xlabel('MR final');
    ylabel('Costo específico');
    title('Figura A. Frente triobjetivo: MR–costo con CO2 codificado por tamaño');

    legend({'Inadmisibles MR >= 0.1', ...
            'Admisibles MR < 0.1', ...
            'H2 recomendada', ...
            'gasLP referencia', ...
            'Frontera MR = 0.1'}, ...
            'Location','best');

    annotationText = sprintf('Tamaño del marcador: CO2 específico. H2: MR %.4f, costo %.4f, CO2 %.4f.', ...
        Trecommended.MR(1), Trecommended.cost_specific(1), Trecommended.CO2_specific(1));

    annotation('textbox',[0.13 0.01 0.78 0.05], ...
        'String',annotationText, ...
        'EdgeColor','none', ...
        'HorizontalAlignment','center', ...
        'FontSize',9);

    set(gca,'FontSize',11);
    axis padded;

    outA_png = fullfile(pngDir,'FIG_A_triobjective_bubble_front_MR_cost_CO2size.png');
    outA_pdf = fullfile(pdfDir,'FIG_A_triobjective_bubble_front_MR_cost_CO2size.pdf');
    outA_fig = fullfile(figNativeDir,'FIG_A_triobjective_bubble_front_MR_cost_CO2size.fig');

    saveas(fA,outA_png);
    savefig(fA,outA_fig);
    exportgraphics(fA,outA_pdf,'ContentType','vector');

    % ---------------------------------------------------------------------
    % FIGURA B — Barras gasLP vs H2 con porcentajes
    % ---------------------------------------------------------------------
    MRred = Trecommended.reduction_MR_pct_vs_gasLP(1);
    CostRed = Trecommended.reduction_cost_pct_vs_gasLP(1);
    CO2Red = Trecommended.reduction_CO2_pct_vs_gasLP(1);

    fB = figure('Name','FIG_B gasLP vs H2 with percent differences', ...
        'Color','w', ...
        'Units','pixels', ...
        'Position',[140 110 1180 650]);

    tiledlayout(1,3,'Padding','compact','TileSpacing','compact');

    % MR
    nexttile;
    bar([gasMR, Trecommended.MR(1)]);
    set(gca,'XTickLabel',{'gasLP','H2'});
    ylabel('MR final');
    title(sprintf('MR: %.1f%% menor', MRred));
    grid on; box on;
    ylim([0, max([gasMR, Trecommended.MR(1)])*1.30]);
    text(1,gasMR,sprintf('%.4f',gasMR), ...
        'VerticalAlignment','bottom', ...
        'HorizontalAlignment','center', ...
        'FontSize',9);
    text(2,Trecommended.MR(1),sprintf('%.4f',Trecommended.MR(1)), ...
        'VerticalAlignment','bottom', ...
        'HorizontalAlignment','center', ...
        'FontSize',9);
    text(1.5, max([gasMR, Trecommended.MR(1)])*1.18, ...
        sprintf('Reducción %.1f%%', MRred), ...
        'HorizontalAlignment','center', ...
        'FontWeight','bold');

    % Costo
    nexttile;
    bar([gasCost, Trecommended.cost_specific(1)]);
    set(gca,'XTickLabel',{'gasLP','H2'});
    ylabel('Costo específico');
    title(sprintf('Costo: %.1f%% menor', CostRed));
    grid on; box on;
    ylim([0, max([gasCost, Trecommended.cost_specific(1)])*1.30]);
    text(1,gasCost,sprintf('%.4f',gasCost), ...
        'VerticalAlignment','bottom', ...
        'HorizontalAlignment','center', ...
        'FontSize',9);
    text(2,Trecommended.cost_specific(1),sprintf('%.4f',Trecommended.cost_specific(1)), ...
        'VerticalAlignment','bottom', ...
        'HorizontalAlignment','center', ...
        'FontSize',9);
    text(1.5, max([gasCost, Trecommended.cost_specific(1)])*1.18, ...
        sprintf('Reducción %.1f%%', CostRed), ...
        'HorizontalAlignment','center', ...
        'FontWeight','bold');

    % CO2
    nexttile;
    bar([gasCO2, Trecommended.CO2_specific(1)]);
    set(gca,'XTickLabel',{'gasLP','H2'});
    ylabel('CO2 específico');
    title(sprintf('CO2: %.1f%% menor', CO2Red));
    grid on; box on;
    ylim([0, max([gasCO2, Trecommended.CO2_specific(1)])*1.30]);
    text(1,gasCO2,sprintf('%.4f',gasCO2), ...
        'VerticalAlignment','bottom', ...
        'HorizontalAlignment','center', ...
        'FontSize',9);
    text(2,Trecommended.CO2_specific(1),sprintf('%.4f',Trecommended.CO2_specific(1)), ...
        'VerticalAlignment','bottom', ...
        'HorizontalAlignment','center', ...
        'FontSize',9);
    text(1.5, max([gasCO2, Trecommended.CO2_specific(1)])*1.18, ...
        sprintf('Reducción %.1f%%', CO2Red), ...
        'HorizontalAlignment','center', ...
        'FontWeight','bold');

    sgtitle('Figura B. Comparación gasLP vs H2 recomendada');

    outB_png = fullfile(pngDir,'FIG_B_gasLP_vs_H2_percent_reductions.png');
    outB_pdf = fullfile(pdfDir,'FIG_B_gasLP_vs_H2_percent_reductions.pdf');
    outB_fig = fullfile(figNativeDir,'FIG_B_gasLP_vs_H2_percent_reductions.fig');

    saveas(fB,outB_png);
    savefig(fB,outB_fig);
    exportgraphics(fB,outB_pdf,'ContentType','vector');

    % ---------------------------------------------------------------------
    % FIGURA C — Espacio operativo 3D
    % ---------------------------------------------------------------------
    fC = figure('Name','FIG_C Operating 3D Tmin-rdiv2-trecini', ...
        'Color','w', ...
        'Units','pixels', ...
        'Position',[180 140 1180 760]);

    hold on; grid on; box on;

    % Inadmisibles
    scatter3(T.T_min(isInadm), T.r_div2(isInadm), T.t_rec_ini(isInadm), ...
        100, ...
        'x', ...
        'LineWidth',1.8);

    % Admisibles
    scatter3(T.T_min(isAdm), T.r_div2(isAdm), T.t_rec_ini(isAdm), ...
        100, ...
        'o', ...
        'filled', ...
        'MarkerEdgeColor','k');

    % H2
    scatter3(T.T_min(idxRec), T.r_div2(idxRec), T.t_rec_ini(idxRec), ...
        300, ...
        'p', ...
        'filled', ...
        'MarkerEdgeColor','k', ...
        'LineWidth',1.4);

    % Etiquetas selectivas
    local_label_point_3d(T, mustLabel, 'T_min', 'r_div2', 't_rec_ini');

    text(T.T_min(idxRec), T.r_div2(idxRec), T.t_rec_ini(idxRec), ...
        '  H2 recomendada', ...
        'FontWeight','bold', ...
        'FontSize',10);

    xlabel('T_{min}');
    ylabel('r_{div2}');
    zlabel('t_{rec,ini}');
    title('Figura C. Espacio operativo 3D: T_{min}–r_{div2}–t_{rec,ini}');

    legend({'Inadmisibles MR >= 0.1', ...
            'Admisibles MR < 0.1', ...
            'H2 recomendada'}, ...
            'Location','best');

    view(135,25);
    set(gca,'FontSize',11);
    axis padded;

    annotation('textbox',[0.13 0.01 0.78 0.05], ...
        'String','Espacio de variables de decisión. No es superficie de respuesta; muestra ubicación operativa de las soluciones formales.', ...
        'EdgeColor','none', ...
        'HorizontalAlignment','center', ...
        'FontSize',9);

    outC_png = fullfile(pngDir,'FIG_C_operating_space_3D_Tmin_rdiv2_trecini.png');
    outC_pdf = fullfile(pdfDir,'FIG_C_operating_space_3D_Tmin_rdiv2_trecini.pdf');
    outC_fig = fullfile(figNativeDir,'FIG_C_operating_space_3D_Tmin_rdiv2_trecini.fig');

    saveas(fC,outC_png);
    savefig(fC,outC_fig);
    exportgraphics(fC,outC_pdf,'ContentType','vector');

    % ---------------------------------------------------------------------
    % Resumen ejecutivo
    % ---------------------------------------------------------------------
    summary = struct();
    summary.figure_set = "corrected triobjective executive";
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
    summary.H2_MR_reduction_pct_vs_gasLP = MRred;
    summary.H2_cost_reduction_pct_vs_gasLP = CostRed;
    summary.H2_CO2_reduction_pct_vs_gasLP = CO2Red;
    summary.n_formal_solutions = height(T);
    summary.n_admissible_MR = sum(isAdm);
    summary.n_inadmissible_MR = sum(isInadm);
    summary.CO2_factor_status = "PROVISIONAL_FOR_CODE_VALIDATION";
    summary.figure_A_interpretation = "MR-cost plane with CO2 encoded by marker size";
    summary.figure_B_interpretation = "gasLP vs H2 with percent reductions";
    summary.figure_C_interpretation = "3D operating decision-space; not response surface";

    TsummaryFig = struct2table(summary);

    outSummaryCsv = fullfile(tablesDir,'CORRECTED_TRIOBJECTIVE_EXECUTIVE_FIGURES_v96q_fig3_summary.csv');
    writetable(TsummaryFig,outSummaryCsv);

    % ---------------------------------------------------------------------
    % Checks y salida
    % ---------------------------------------------------------------------
    figureFiles = string({outA_png; outB_png; outC_png});
    pdfFiles = string({outA_pdf; outB_pdf; outC_pdf});
    figFiles = string({outA_fig; outB_fig; outC_fig});

    checks = {};
    checks{end+1,1} = check_row('F3A','Figure A triobjective bubble front created',isfile(outA_png),outA_png);
    checks{end+1,1} = check_row('F3B','Figure B percent comparison created',isfile(outB_png),outB_png);
    checks{end+1,1} = check_row('F3C','Figure C operating 3D created',isfile(outC_png),outC_png);
    checks{end+1,1} = check_row('F3D','PDF files created',all(isfile(pdfFiles)),pdfDir);
    checks{end+1,1} = check_row('F3E','FIG native files created',all(isfile(figFiles)),figNativeDir);
    checks{end+1,1} = check_row('F3F','No GA executed',true,'No gamultiobj call.');
    checks{end+1,1} = check_row('F3G','No mechanistic rerun',true,'No objective/model call.');
    checks{end+1,1} = check_row('F3H','H2 preserved',recID=="H2",sprintf('recommended=%s',recID));
    checks{end+1,1} = check_row('F3I','H2 admissible',Trecommended.MR(1)<MR_acceptance,sprintf('MR=%.6g',Trecommended.MR(1)));
    checks{end+1,1} = check_row('F3J','CO2 included in Figure A',true,'Marker size represents CO2_specific.');
    checks{end+1,1} = check_row('F3K','MR percentage included in Figure B',isfinite(MRred),sprintf('MR reduction=%.6g%%',MRred));
    checks{end+1,1} = check_row('F3L','Selective labels used',true,'Only H1,H2,H4,H9 and gasLP emphasized.');

    Tchecks = struct2table(vertcat(checks{:}));

    if all(Tchecks.pass)
        diagnosis = "CORRECTED_TRIOBJECTIVE_EXECUTIVE_FIGURES_PASS";
        decision = "CORRECTED_THREE_FIGURE_SET_READY_FOR_REVIEW";
        next_step = "Visual review; if accepted, use this as main figure set before 9.6r.";
    else
        diagnosis = "CORRECTED_TRIOBJECTIVE_EXECUTIVE_FIGURES_REQUIRES_REVIEW";
        decision = "REVIEW_FIGURE_EXPORTS";
        next_step = "Review failed checks.";
    end

    outChecksCsv = fullfile(tablesDir,'CORRECTED_TRIOBJECTIVE_EXECUTIVE_FIGURES_v96q_fig3_checks.csv');
    writetable(Tchecks,outChecksCsv);

    outMat = fullfile(matDir,'CORRECTED_TRIOBJECTIVE_EXECUTIVE_FIGURES_v96q_fig3.mat');

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'T','Trecommended','Tsummary','TsummaryFig','Tchecks', ...
        'figureFiles','pdfFiles','figFiles', ...
        'figDir','pngDir','pdfDir','figNativeDir','logsDir','matDir','tablesDir', ...
        'outPlotCsv','outSummaryCsv','outChecksCsv');

    outMd = fullfile(logsDir,'CORRECTED_TRIOBJECTIVE_EXECUTIVE_FIGURES_v96q_fig3.md');

    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# CORRECTED_TRIOBJECTIVE_EXECUTIVE_FIGURES_v96q_fig3\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Decisión: `%s`\n\n', decision);
    fprintf(fid,'Siguiente paso: `%s`\n\n', next_step);

    fprintf(fid,'## Correcciones frente a fig2\n\n');
    fprintf(fid,'- Figura A incorpora CO2 mediante tamaño del marcador.\n');
    fprintf(fid,'- Figura A evita etiquetar todos los puntos; enfatiza H1, H2, H4, H9 y gasLP.\n');
    fprintf(fid,'- Figura B incorpora porcentaje de reducción de MR, costo y CO2.\n');
    fprintf(fid,'- Figura C usa espacio operativo 3D T_min-r_div2-t_rec_ini.\n');
    fprintf(fid,'- No se generan superficies de respuesta ni sábanas cuadriculadas.\n\n');

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
    fprintf(fid,'| MR_reduction_pct_vs_gasLP | %.12g |\n', MRred);
    fprintf(fid,'| cost_reduction_pct_vs_gasLP | %.12g |\n', CostRed);
    fprintf(fid,'| CO2_reduction_pct_vs_gasLP | %.12g |\n\n', CO2Red);

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
    fprintf(fid,'Este paquete corrige el problema de representación triobjetivo y reduce el ruido visual. ');
    fprintf(fid,'Debe revisarse visualmente antes de continuar a 9.6r. ');
    fprintf(fid,'La Figura C es espacio de variables de decisión, no superficie de respuesta. ');
    fprintf(fid,'Los factores de CO2 siguen como provisionales para validación de código.\n');

    fclose(fid);

    figs = struct();
    figs.status = 'CORRECTED_TRIOBJECTIVE_EXECUTIVE_FIGURES_COMPLETED';
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

    disp('=== CORRECTED_TRIOBJECTIVE_EXECUTIVE_FIGURES_v96q_fig3 ===')
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

function local_label_point_2d(T, mask, xField, yField)
    idx = find(mask);
    for k = 1:numel(idx)
        i = idx(k);
        text(T.(xField)(i), T.(yField)(i), ...
            "  " + string(T.solution_id(i)), ...
            'FontSize',9, ...
            'FontWeight','bold');
    end
end

function local_label_point_3d(T, mask, xField, yField, zField)
    idx = find(mask);
    for k = 1:numel(idx)
        i = idx(k);
        text(T.(xField)(i), T.(yField)(i), T.(zField)(i), ...
            "  " + string(T.solution_id(i)), ...
            'FontSize',9, ...
            'FontWeight','bold');
    end
end

function row = check_row(id, checkName, passVal, evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end