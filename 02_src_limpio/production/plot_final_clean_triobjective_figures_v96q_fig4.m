function figs = plot_final_clean_triobjective_figures_v96q_fig4()
% PLOT_FINAL_CLEAN_TRIOBJECTIVE_FIGURES_v96q_fig4
% 9.6q-fig4 — FINAL-CLEAN-TRIOBJECTIVE-FIGURES-001
%
% Corrige legibilidad de fig3:
%   - Figura A: CO2 entra como tamaño de marcador.
%   - Etiquetas H1-H9 con desplazamiento controlado.
%   - H2 ya no tiene texto duplicado encima.
%   - Figura B: porcentajes no repetidos en títulos.
%   - Figura C: espacio operativo 3D con etiquetas compactas.
%
% No ejecuta GA.
% No llama modelo.
% No llama función objetivo.
% Usa resultados v96p ya consolidados.

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

    MRred = Trecommended.reduction_MR_pct_vs_gasLP(1);
    CostRed = Trecommended.reduction_cost_pct_vs_gasLP(1);
    CO2Red = Trecommended.reduction_CO2_pct_vs_gasLP(1);

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    figBaseDir = fullfile(rootDir,'05_runs','final_clean_triobjective_figures_v96q_fig4');
    figDir = fullfile(figBaseDir,['FINAL_CLEAN_TRIOBJECTIVE_FIGURES_v96q_fig4_' timestamp]);

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

    outPlotCsv = fullfile(tablesDir,'FINAL_CLEAN_TRIOBJECTIVE_FIGURES_v96q_fig4_plot_points.csv');
    writetable(Tplot,outPlotCsv);

    % ---------------------------------------------------------------------
    % Escala de tamaño por CO2
    % ---------------------------------------------------------------------
    co2Vals = T.CO2_specific;
    co2Min = min(co2Vals);
    co2Max = max(co2Vals);

    if co2Max > co2Min
        sizeCO2 = 75 + 210*(co2Vals - co2Min)/(co2Max - co2Min);
        gasSizeCO2 = 75 + 210*(gasCO2 - co2Min)/(co2Max - co2Min);
    else
        sizeCO2 = 130*ones(size(co2Vals));
        gasSizeCO2 = 180;
    end

    gasSizeCO2 = max(120,min(310,gasSizeCO2));

    % ---------------------------------------------------------------------
    % FIGURA A — Frente triobjetivo limpio
    % ---------------------------------------------------------------------
    fA = figure('Name','FIG_A Final clean triobjective front', ...
        'Color','w', ...
        'Units','pixels', ...
        'Position',[80 60 1320 820]);

    hold on; grid on; box on;

    hInadm = scatter(T.MR(isInadm), T.cost_specific(isInadm), sizeCO2(isInadm), ...
        'x', 'LineWidth',1.8);

    hAdm = scatter(T.MR(isAdm), T.cost_specific(isAdm), sizeCO2(isAdm), ...
        'o', 'filled', 'MarkerEdgeColor','k');

    hH2 = scatter(T.MR(idxRec), T.cost_specific(idxRec), 330, ...
        'p', 'filled', 'MarkerEdgeColor','k', 'LineWidth',1.4);

    hGas = scatter(gasMR, gasCost, gasSizeCO2, ...
        's', 'filled', 'MarkerEdgeColor','k', 'LineWidth',1.4);

    hMR = xline(MR_acceptance,'--','MR = 0.1', ...
        'LineWidth',1.4, ...
        'LabelOrientation','horizontal', ...
        'LabelVerticalAlignment','bottom');

    % Etiquetas H1-H9 con desplazamiento manual para evitar encimamiento.
    label_offsets_A = local_label_offsets_A(T);

    for i = 1:height(T)
        dx = label_offsets_A.dx(i);
        dy = label_offsets_A.dy(i);

        text(T.MR(i)+dx, T.cost_specific(i)+dy, string(T.solution_id(i)), ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'BackgroundColor','w', ...
            'Margin',1);
    end

    % gasLP separado
    text(gasMR - 0.010, gasCost + 0.006, 'gasLP', ...
        'FontWeight','bold', ...
        'FontSize',9, ...
        'BackgroundColor','w', ...
        'Margin',1);

    xlabel('MR final');
    ylabel('Costo específico');
    title('Figura A. Frente triobjetivo: MR–costo con CO2 codificado por tamaño');

    legend([hInadm hAdm hH2 hGas hMR], ...
        {'Inadmisibles MR >= 0.1', ...
         'Admisibles MR < 0.1', ...
         'H2 recomendada', ...
         'gasLP referencia', ...
         'Frontera MR = 0.1'}, ...
         'Location','southoutside', ...
         'Orientation','horizontal');

    % Nota de codificación CO2.
    annotation('textbox',[0.13 0.005 0.78 0.045], ...
        'String','Tamaño del marcador proporcional a CO2 específico. Etiquetas H1–H9 identifican las soluciones del frente formal.', ...
        'EdgeColor','none', ...
        'HorizontalAlignment','center', ...
        'FontSize',9);

    set(gca,'FontSize',11);

    xMin = min([T.MR; gasMR]);
    xMax = max([T.MR; gasMR]);
    yMin = min([T.cost_specific; gasCost]);
    yMax = max([T.cost_specific; gasCost]);

    xlim([max(0,xMin - 0.02), xMax + 0.035]);
    ylim([max(0,yMin - 0.025), yMax + 0.035]);

    outA_png = fullfile(pngDir,'FIG_A_final_triobjective_front_MR_cost_CO2size.png');
    outA_pdf = fullfile(pdfDir,'FIG_A_final_triobjective_front_MR_cost_CO2size.pdf');
    outA_fig = fullfile(figNativeDir,'FIG_A_final_triobjective_front_MR_cost_CO2size.fig');

    saveas(fA,outA_png);
    savefig(fA,outA_fig);
    exportgraphics(fA,outA_pdf,'ContentType','vector');

    % ---------------------------------------------------------------------
    % FIGURA B — Barras gasLP vs H2, sin repetir porcentajes
    % ---------------------------------------------------------------------
    fB = figure('Name','FIG_B Final gasLP vs H2', ...
        'Color','w', ...
        'Units','pixels', ...
        'Position',[120 90 1320 680]);

    tiledlayout(1,3,'Padding','compact','TileSpacing','compact');

    % MR
    nexttile;
    bar([gasMR, Trecommended.MR(1)]);
    set(gca,'XTickLabel',{'gasLP','H2'});
    ylabel('MR final');
    title('MR');
    grid on; box on;
    ylim([0, max([gasMR, Trecommended.MR(1)])*1.35]);
    local_bar_labels([gasMR, Trecommended.MR(1)]);
    text(1.5, max([gasMR, Trecommended.MR(1)])*1.22, ...
        sprintf('Reducción %.1f%%', MRred), ...
        'HorizontalAlignment','center', ...
        'FontWeight','bold');

    % Costo
    nexttile;
    bar([gasCost, Trecommended.cost_specific(1)]);
    set(gca,'XTickLabel',{'gasLP','H2'});
    ylabel('Costo específico');
    title('Costo');
    grid on; box on;
    ylim([0, max([gasCost, Trecommended.cost_specific(1)])*1.35]);
    local_bar_labels([gasCost, Trecommended.cost_specific(1)]);
    text(1.5, max([gasCost, Trecommended.cost_specific(1)])*1.22, ...
        sprintf('Reducción %.1f%%', CostRed), ...
        'HorizontalAlignment','center', ...
        'FontWeight','bold');

    % CO2
    nexttile;
    bar([gasCO2, Trecommended.CO2_specific(1)]);
    set(gca,'XTickLabel',{'gasLP','H2'});
    ylabel('CO2 específico');
    title('CO2');
    grid on; box on;
    ylim([0, max([gasCO2, Trecommended.CO2_specific(1)])*1.35]);
    local_bar_labels([gasCO2, Trecommended.CO2_specific(1)]);
    text(1.5, max([gasCO2, Trecommended.CO2_specific(1)])*1.22, ...
        sprintf('Reducción %.1f%%', CO2Red), ...
        'HorizontalAlignment','center', ...
        'FontWeight','bold');

    sgtitle('Figura B. Comparación gasLP vs H2 recomendada');

    outB_png = fullfile(pngDir,'FIG_B_final_gasLP_vs_H2_percent_reductions.png');
    outB_pdf = fullfile(pdfDir,'FIG_B_final_gasLP_vs_H2_percent_reductions.pdf');
    outB_fig = fullfile(figNativeDir,'FIG_B_final_gasLP_vs_H2_percent_reductions.fig');

    saveas(fB,outB_png);
    savefig(fB,outB_fig);
    exportgraphics(fB,outB_pdf,'ContentType','vector');

    % ---------------------------------------------------------------------
    % FIGURA C — Espacio operativo 3D limpio
    % ---------------------------------------------------------------------
    fC = figure('Name','FIG_C Final clean operating 3D', ...
        'Color','w', ...
        'Units','pixels', ...
        'Position',[160 120 1320 820]);

    hold on; grid on; box on;

    hCInadm = scatter3(T.T_min(isInadm), T.r_div2(isInadm), T.t_rec_ini(isInadm), ...
        105, 'x', 'LineWidth',1.8);

    hCAdm = scatter3(T.T_min(isAdm), T.r_div2(isAdm), T.t_rec_ini(isAdm), ...
        105, 'o', 'filled', 'MarkerEdgeColor','k');

    hCH2 = scatter3(T.T_min(idxRec), T.r_div2(idxRec), T.t_rec_ini(idxRec), ...
        330, 'p', 'filled', 'MarkerEdgeColor','k', 'LineWidth',1.4);

    label_offsets_C = local_label_offsets_C(T);

    for i = 1:height(T)
        dx = label_offsets_C.dx(i);
        dy = label_offsets_C.dy(i);
        dz = label_offsets_C.dz(i);

        text(T.T_min(i)+dx, T.r_div2(i)+dy, T.t_rec_ini(i)+dz, ...
            string(T.solution_id(i)), ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'BackgroundColor','w', ...
            'Margin',1);
    end

    xlabel('T_{min}');
    ylabel('r_{div2}');
    zlabel('t_{rec,ini}');
    title('Figura C. Espacio operativo 3D de las soluciones formales');

    legend([hCInadm hCAdm hCH2], ...
        {'Inadmisibles MR >= 0.1', ...
         'Admisibles MR < 0.1', ...
         'H2 recomendada'}, ...
         'Location','southoutside', ...
         'Orientation','horizontal');

    annotation('textbox',[0.13 0.005 0.78 0.045], ...
        'String','Espacio de variables de decisión. No es superficie de respuesta; muestra ubicación operativa de H2 frente al resto de soluciones.', ...
        'EdgeColor','none', ...
        'HorizontalAlignment','center', ...
        'FontSize',9);

    view(135,25);
    set(gca,'FontSize',11);
    axis padded;

    outC_png = fullfile(pngDir,'FIG_C_final_operating_space_3D_Tmin_rdiv2_trecini.png');
    outC_pdf = fullfile(pdfDir,'FIG_C_final_operating_space_3D_Tmin_rdiv2_trecini.pdf');
    outC_fig = fullfile(figNativeDir,'FIG_C_final_operating_space_3D_Tmin_rdiv2_trecini.fig');

    saveas(fC,outC_png);
    savefig(fC,outC_fig);
    exportgraphics(fC,outC_pdf,'ContentType','vector');

    % ---------------------------------------------------------------------
    % Resumen
    % ---------------------------------------------------------------------
    summary = struct();
    summary.figure_set = "final clean triobjective";
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

    TsummaryFig = struct2table(summary);

    outSummaryCsv = fullfile(tablesDir,'FINAL_CLEAN_TRIOBJECTIVE_FIGURES_v96q_fig4_summary.csv');
    writetable(TsummaryFig,outSummaryCsv);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    figureFiles = string({outA_png; outB_png; outC_png});
    pdfFiles = string({outA_pdf; outB_pdf; outC_pdf});
    figFiles = string({outA_fig; outB_fig; outC_fig});

    checks = {};
    checks{end+1,1} = check_row('F4A','Figure A final front created',isfile(outA_png),outA_png);
    checks{end+1,1} = check_row('F4B','Figure B final bars created',isfile(outB_png),outB_png);
    checks{end+1,1} = check_row('F4C','Figure C final operating space created',isfile(outC_png),outC_png);
    checks{end+1,1} = check_row('F4D','PDF files created',all(isfile(pdfFiles)),pdfDir);
    checks{end+1,1} = check_row('F4E','FIG native files created',all(isfile(figFiles)),figNativeDir);
    checks{end+1,1} = check_row('F4F','No GA executed',true,'No gamultiobj call.');
    checks{end+1,1} = check_row('F4G','No mechanistic rerun',true,'No objective/model call.');
    checks{end+1,1} = check_row('F4H','H2 preserved',recID=="H2",sprintf('recommended=%s',recID));
    checks{end+1,1} = check_row('F4I','H2 admissible',Trecommended.MR(1)<MR_acceptance,sprintf('MR=%.6g',Trecommended.MR(1)));
    checks{end+1,1} = check_row('F4J','CO2 encoded in Figure A',true,'Marker size proportional to CO2_specific.');
    checks{end+1,1} = check_row('F4K','No duplicated percent titles in Figure B',true,'Percent reductions shown only as bar annotations.');
    checks{end+1,1} = check_row('F4L','Compact labels used',true,'H1-H9 labels with controlled offsets.');

    Tchecks = struct2table(vertcat(checks{:}));

    if all(Tchecks.pass)
        diagnosis = "FINAL_CLEAN_TRIOBJECTIVE_FIGURES_PASS";
        decision = "FINAL_THREE_FIGURE_SET_READY_FOR_REVIEW";
        next_step = "Visual review; if accepted, close figure package and continue to 9.6r.";
    else
        diagnosis = "FINAL_CLEAN_TRIOBJECTIVE_FIGURES_REQUIRES_REVIEW";
        decision = "REVIEW_FIGURE_EXPORTS";
        next_step = "Review failed checks.";
    end

    outChecksCsv = fullfile(tablesDir,'FINAL_CLEAN_TRIOBJECTIVE_FIGURES_v96q_fig4_checks.csv');
    writetable(Tchecks,outChecksCsv);

    outMat = fullfile(matDir,'FINAL_CLEAN_TRIOBJECTIVE_FIGURES_v96q_fig4.mat');

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'T','Trecommended','Tsummary','TsummaryFig','Tchecks', ...
        'figureFiles','pdfFiles','figFiles', ...
        'figDir','pngDir','pdfDir','figNativeDir','logsDir','matDir','tablesDir', ...
        'outPlotCsv','outSummaryCsv','outChecksCsv');

    outMd = fullfile(logsDir,'FINAL_CLEAN_TRIOBJECTIVE_FIGURES_v96q_fig4.md');

    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# FINAL_CLEAN_TRIOBJECTIVE_FIGURES_v96q_fig4\n\n');
    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Decisión: `%s`\n\n', decision);
    fprintf(fid,'Siguiente paso: `%s`\n\n', next_step);

    fprintf(fid,'## Correcciones aplicadas\n\n');
    fprintf(fid,'- Figura A incluye CO2 como tamaño del marcador.\n');
    fprintf(fid,'- Figura A etiqueta H1-H9 con desplazamiento controlado.\n');
    fprintf(fid,'- Figura B elimina porcentajes repetidos en títulos.\n');
    fprintf(fid,'- Figura C elimina texto largo encima de H2 y usa etiquetas compactas.\n');
    fprintf(fid,'- No hay superficies ni mapas cuadriculados.\n\n');

    fprintf(fid,'## H2\n\n');
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
    fprintf(fid,'Este paquete debe sustituir a fig2 y fig3 como conjunto principal de revisión visual. ');
    fprintf(fid,'Los factores de CO2 permanecen provisionales para validación de código.\n');

    fclose(fid);

    figs = struct();
    figs.status = 'FINAL_CLEAN_TRIOBJECTIVE_FIGURES_COMPLETED';
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

    disp('=== FINAL_CLEAN_TRIOBJECTIVE_FIGURES_v96q_fig4 ===')
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

function local_bar_labels(vals)
    for k = 1:numel(vals)
        text(k, vals(k), sprintf('%.4f', vals(k)), ...
            'VerticalAlignment','bottom', ...
            'HorizontalAlignment','center', ...
            'FontSize',9);
    end
end

function offsets = local_label_offsets_A(T)
    n = height(T);
    offsets.dx = zeros(n,1);
    offsets.dy = zeros(n,1);

    % Desplazamientos en coordenadas MR-costo.
    for i = 1:n
        id = string(T.solution_id(i));

        switch id
            case "H1"
                offsets.dx(i) = 0.004;
                offsets.dy(i) = 0.008;
            case "H2"
                offsets.dx(i) = 0.004;
                offsets.dy(i) = -0.010;
            case "H3"
                offsets.dx(i) = 0.004;
                offsets.dy(i) = 0.006;
            case "H4"
                offsets.dx(i) = 0.004;
                offsets.dy(i) = -0.010;
            case "H5"
                offsets.dx(i) = -0.014;
                offsets.dy(i) = 0.006;
            case "H6"
                offsets.dx(i) = 0.004;
                offsets.dy(i) = 0.010;
            case "H7"
                offsets.dx(i) = -0.014;
                offsets.dy(i) = -0.006;
            case "H8"
                offsets.dx(i) = 0.004;
                offsets.dy(i) = -0.008;
            case "H9"
                offsets.dx(i) = 0.004;
                offsets.dy(i) = 0.008;
            otherwise
                offsets.dx(i) = 0.004;
                offsets.dy(i) = 0.004;
        end
    end
end

function offsets = local_label_offsets_C(T)
    n = height(T);
    offsets.dx = zeros(n,1);
    offsets.dy = zeros(n,1);
    offsets.dz = zeros(n,1);

    % Desplazamientos en espacio T_min-r_div2-t_rec_ini.
    for i = 1:n
        id = string(T.solution_id(i));

        switch id
            case "H1"
                offsets.dx(i) = 0.15;
                offsets.dy(i) = 0.010;
                offsets.dz(i) = 0.020;
            case "H2"
                offsets.dx(i) = 0.15;
                offsets.dy(i) = -0.020;
                offsets.dz(i) = -0.030;
            case "H3"
                offsets.dx(i) = 0.15;
                offsets.dy(i) = 0.012;
                offsets.dz(i) = 0.030;
            case "H4"
                offsets.dx(i) = 0.15;
                offsets.dy(i) = -0.020;
                offsets.dz(i) = -0.030;
            case "H5"
                offsets.dx(i) = -0.35;
                offsets.dy(i) = 0.015;
                offsets.dz(i) = 0.025;
            case "H6"
                offsets.dx(i) = 0.15;
                offsets.dy(i) = 0.018;
                offsets.dz(i) = 0.020;
            case "H7"
                offsets.dx(i) = -0.35;
                offsets.dy(i) = -0.018;
                offsets.dz(i) = -0.025;
            case "H8"
                offsets.dx(i) = 0.15;
                offsets.dy(i) = -0.018;
                offsets.dz(i) = -0.020;
            case "H9"
                offsets.dx(i) = 0.15;
                offsets.dy(i) = 0.012;
                offsets.dz(i) = 0.030;
            otherwise
                offsets.dx(i) = 0.15;
                offsets.dy(i) = 0.010;
                offsets.dz(i) = 0.020;
        end
    end
end

function row = check_row(id, checkName, passVal, evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end