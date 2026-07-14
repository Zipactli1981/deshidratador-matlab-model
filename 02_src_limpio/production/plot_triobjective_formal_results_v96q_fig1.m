function figs = plot_triobjective_formal_results_v96q_fig1()
% PLOT_TRIOBJECTIVE_FORMAL_RESULTS_v96q_fig1
% 9.6q-fig1-fix1 — FIGURE-WINDOW-POSITION-REPAIR-001
%
% Genera figuras revisables del frente triobjetivo formal:
%   MR, costo específico, CO2 específico.
%
% Esta versión corrige la posición de ventanas para que no aparezcan
% pegadas a los márgenes de la pantalla.
%
% No ejecuta GA.
% No modifica fuentes protegidas.
% Carga la interpretación v96p más reciente.

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    MR_acceptance = 0.10;

    % Cambia a false si no quieres que MATLAB abra ventanas.
    showFigures = true;

    if showFigures
        visibleState = 'on';
    else
        visibleState = 'off';
    end

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
    Trep = S.TrepresentativeInterp;
    Tsummary = S.Tsummary;

    gasMR = Tsummary.gasLP_MR(1);
    gasCost = Tsummary.gasLP_cost(1);
    gasCO2 = Tsummary.gasLP_CO2(1);

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    figBaseDir = fullfile(rootDir,'05_runs','triobjective_formal_results_figures_v96q_fig1');
    figDir = fullfile(figBaseDir,['TRIOBJECTIVE_FORMAL_RESULTS_FIGURES_v96q_fig1_FIX1_' timestamp]);

    pngDir = fullfile(figDir,'png');
    figMatDir = fullfile(figDir,'fig');
    pdfDir = fullfile(figDir,'pdf');
    matDir = fullfile(figDir,'mat');
    logsDir = fullfile(figDir,'logs');

    if ~isfolder(figBaseDir), mkdir(figBaseDir); end
    if ~isfolder(figDir), mkdir(figDir); end
    if ~isfolder(pngDir), mkdir(pngDir); end
    if ~isfolder(figMatDir), mkdir(figMatDir); end
    if ~isfolder(pdfDir), mkdir(pdfDir); end
    if ~isfolder(matDir), mkdir(matDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end

    % ---------------------------------------------------------------------
    % Preparar datos
    % ---------------------------------------------------------------------
    isAdm = T.MR < MR_acceptance;
    isInadm = ~isAdm;

    recID = string(Trecommended.solution_id(1));
    idxRec = find(string(T.solution_id) == recID,1,'first');

    if isempty(idxRec)
        error('No se encontró la solución recomendada %s en Tsolutions.', recID);
    end

    idxMinMR = find(T.is_min_MR,1,'first');
    idxMinCost = find(T.is_min_cost,1,'first');
    idxMinCO2 = find(T.is_min_CO2,1,'first');

    % Posiciones fijas en pantalla.
    pos1 = [100 100 1150 760];
    pos2 = [140 120 1150 760];
    pos3 = [180 140 1150 760];
    pos4 = [220 160 1150 760];
    pos5 = [260 180 1200 680];
    pos6 = [300 200 1150 680];

    % ---------------------------------------------------------------------
    % Figura 1: Pareto 3D
    % ---------------------------------------------------------------------
    f1 = figure('Name','FIG01 Pareto 3D MR-Cost-CO2', ...
        'Color','w', ...
        'Units','pixels', ...
        'Position',pos1, ...
        'Visible',visibleState);

    hold on; grid on; box on;

    scatter3(T.MR(isInadm), T.cost_specific(isInadm), T.CO2_specific(isInadm), ...
        80, 'x', 'LineWidth', 1.5);

    scatter3(T.MR(isAdm), T.cost_specific(isAdm), T.CO2_specific(isAdm), ...
        80, 'o', 'filled');

    scatter3(T.MR(idxRec), T.cost_specific(idxRec), T.CO2_specific(idxRec), ...
        180, 'p', 'filled');

    scatter3(gasMR, gasCost, gasCO2, ...
        180, 's', 'filled');

    xlabel('MR final');
    ylabel('Costo específico');
    zlabel('CO2 específico');
    title('Frente formal híbrido: MR–costo–CO2');

    legend({'Inadmisibles MR >= 0.1','Admisibles MR < 0.1','H2 recomendada','gasLP referencia'}, ...
        'Location','best');

    local_label_points_3d(T);
    text(gasMR, gasCost, gasCO2, '  gasLP', 'FontWeight','bold');

    view(135,25);

    out1png = fullfile(pngDir,'FIG01_Pareto_3D_MR_cost_CO2.png');
    out1fig = fullfile(figMatDir,'FIG01_Pareto_3D_MR_cost_CO2.fig');
    out1pdf = fullfile(pdfDir,'FIG01_Pareto_3D_MR_cost_CO2.pdf');

    saveas(f1,out1png);
    savefig(f1,out1fig);
    exportgraphics(f1,out1pdf,'ContentType','vector');

    % ---------------------------------------------------------------------
    % Figura 2: MR vs costo
    % ---------------------------------------------------------------------
    f2 = figure('Name','FIG02 MR vs Cost', ...
        'Color','w', ...
        'Units','pixels', ...
        'Position',pos2, ...
        'Visible',visibleState);

    hold on; grid on; box on;

    scatter(T.MR(isInadm), T.cost_specific(isInadm), 80, 'x', 'LineWidth', 1.5);
    scatter(T.MR(isAdm), T.cost_specific(isAdm), 80, 'o', 'filled');
    scatter(T.MR(idxRec), T.cost_specific(idxRec), 180, 'p', 'filled');
    scatter(gasMR, gasCost, 180, 's', 'filled');

    xline(MR_acceptance,'--','MR = 0.1');

    xlabel('MR final');
    ylabel('Costo específico');
    title('Proyección MR vs costo');

    legend({'Inadmisibles','Admisibles','H2 recomendada','gasLP','MR = 0.1'}, ...
        'Location','best');

    local_label_points_2d(T,'MR','cost_specific');
    text(gasMR, gasCost, '  gasLP', 'FontWeight','bold');

    out2png = fullfile(pngDir,'FIG02_MR_vs_cost.png');
    out2fig = fullfile(figMatDir,'FIG02_MR_vs_cost.fig');
    out2pdf = fullfile(pdfDir,'FIG02_MR_vs_cost.pdf');

    saveas(f2,out2png);
    savefig(f2,out2fig);
    exportgraphics(f2,out2pdf,'ContentType','vector');

    % ---------------------------------------------------------------------
    % Figura 3: MR vs CO2
    % ---------------------------------------------------------------------
    f3 = figure('Name','FIG03 MR vs CO2', ...
        'Color','w', ...
        'Units','pixels', ...
        'Position',pos3, ...
        'Visible',visibleState);

    hold on; grid on; box on;

    scatter(T.MR(isInadm), T.CO2_specific(isInadm), 80, 'x', 'LineWidth', 1.5);
    scatter(T.MR(isAdm), T.CO2_specific(isAdm), 80, 'o', 'filled');
    scatter(T.MR(idxRec), T.CO2_specific(idxRec), 180, 'p', 'filled');
    scatter(gasMR, gasCO2, 180, 's', 'filled');

    xline(MR_acceptance,'--','MR = 0.1');

    xlabel('MR final');
    ylabel('CO2 específico');
    title('Proyección MR vs CO2');

    legend({'Inadmisibles','Admisibles','H2 recomendada','gasLP','MR = 0.1'}, ...
        'Location','best');

    local_label_points_2d(T,'MR','CO2_specific');
    text(gasMR, gasCO2, '  gasLP', 'FontWeight','bold');

    out3png = fullfile(pngDir,'FIG03_MR_vs_CO2.png');
    out3fig = fullfile(figMatDir,'FIG03_MR_vs_CO2.fig');
    out3pdf = fullfile(pdfDir,'FIG03_MR_vs_CO2.pdf');

    saveas(f3,out3png);
    savefig(f3,out3fig);
    exportgraphics(f3,out3pdf,'ContentType','vector');

    % ---------------------------------------------------------------------
    % Figura 4: costo vs CO2
    % ---------------------------------------------------------------------
    f4 = figure('Name','FIG04 Cost vs CO2', ...
        'Color','w', ...
        'Units','pixels', ...
        'Position',pos4, ...
        'Visible',visibleState);

    hold on; grid on; box on;

    scatter(T.cost_specific(isInadm), T.CO2_specific(isInadm), 80, 'x', 'LineWidth', 1.5);
    scatter(T.cost_specific(isAdm), T.CO2_specific(isAdm), 80, 'o', 'filled');
    scatter(T.cost_specific(idxRec), T.CO2_specific(idxRec), 180, 'p', 'filled');
    scatter(gasCost, gasCO2, 180, 's', 'filled');

    xlabel('Costo específico');
    ylabel('CO2 específico');
    title('Proyección costo vs CO2');

    legend({'Inadmisibles','Admisibles','H2 recomendada','gasLP'}, ...
        'Location','best');

    local_label_points_2d(T,'cost_specific','CO2_specific');
    text(gasCost, gasCO2, '  gasLP', 'FontWeight','bold');

    out4png = fullfile(pngDir,'FIG04_cost_vs_CO2.png');
    out4fig = fullfile(figMatDir,'FIG04_cost_vs_CO2.fig');
    out4pdf = fullfile(pdfDir,'FIG04_cost_vs_CO2.pdf');

    saveas(f4,out4png);
    savefig(f4,out4fig);
    exportgraphics(f4,out4pdf,'ContentType','vector');

    % ---------------------------------------------------------------------
    % Figura 5: barras gasLP vs H2
    % ---------------------------------------------------------------------
    f5 = figure('Name','FIG05 gasLP vs H2', ...
        'Color','w', ...
        'Units','pixels', ...
        'Position',pos5, ...
        'Visible',visibleState);

    tiledlayout(1,3,'Padding','compact','TileSpacing','compact');

    nexttile;
    bar([gasMR, Trecommended.MR(1)]);
    set(gca,'XTickLabel',{'gasLP','H2'});
    ylabel('MR final');
    title('MR');

    nexttile;
    bar([gasCost, Trecommended.cost_specific(1)]);
    set(gca,'XTickLabel',{'gasLP','H2'});
    ylabel('Costo específico');
    title('Costo');

    nexttile;
    bar([gasCO2, Trecommended.CO2_specific(1)]);
    set(gca,'XTickLabel',{'gasLP','H2'});
    ylabel('CO2 específico');
    title('CO2');

    sgtitle('Comparación gasLP vs H2 recomendada');

    out5png = fullfile(pngDir,'FIG05_gasLP_vs_H2_bars.png');
    out5fig = fullfile(figMatDir,'FIG05_gasLP_vs_H2_bars.fig');
    out5pdf = fullfile(pdfDir,'FIG05_gasLP_vs_H2_bars.pdf');

    saveas(f5,out5png);
    savefig(f5,out5fig);
    exportgraphics(f5,out5pdf,'ContentType','vector');

    % ---------------------------------------------------------------------
    % Figura 6: admisibilidad por MR
    % ---------------------------------------------------------------------
    f6 = figure('Name','FIG06 Admissibility by MR', ...
        'Color','w', ...
        'Units','pixels', ...
        'Position',pos6, ...
        'Visible',visibleState);

    hold on; grid on; box on;

    bar(categorical(string(T.solution_id)), T.MR);
    yline(MR_acceptance,'--','MR = 0.1');

    ylabel('MR final');
    xlabel('Solución');
    title('Admisibilidad por criterio MR < 0.1');

    out6png = fullfile(pngDir,'FIG06_admissibility_by_MR.png');
    out6fig = fullfile(figMatDir,'FIG06_admissibility_by_MR.fig');
    out6pdf = fullfile(pdfDir,'FIG06_admissibility_by_MR.pdf');

    saveas(f6,out6png);
    savefig(f6,out6fig);
    exportgraphics(f6,out6pdf,'ContentType','vector');

    % ---------------------------------------------------------------------
    % Resumen y checks
    % ---------------------------------------------------------------------
    figFiles = string({ ...
        out1png; ...
        out2png; ...
        out3png; ...
        out4png; ...
        out5png; ...
        out6png});

    pdfFiles = string({ ...
        out1pdf; ...
        out2pdf; ...
        out3pdf; ...
        out4pdf; ...
        out5pdf; ...
        out6pdf});

    figNativeFiles = string({ ...
        out1fig; ...
        out2fig; ...
        out3fig; ...
        out4fig; ...
        out5fig; ...
        out6fig});

    checks = {};
    checks{end+1,1} = local_check_row_fig1("FIG01","Pareto 3D PNG created",isfile(out1png),out1png);
    checks{end+1,1} = local_check_row_fig1("FIG02","MR vs cost PNG created",isfile(out2png),out2png);
    checks{end+1,1} = local_check_row_fig1("FIG03","MR vs CO2 PNG created",isfile(out3png),out3png);
    checks{end+1,1} = local_check_row_fig1("FIG04","Cost vs CO2 PNG created",isfile(out4png),out4png);
    checks{end+1,1} = local_check_row_fig1("FIG05","gasLP vs H2 PNG created",isfile(out5png),out5png);
    checks{end+1,1} = local_check_row_fig1("FIG06","MR admissibility PNG created",isfile(out6png),out6png);
    checks{end+1,1} = local_check_row_fig1("FIG07","PDF files created",all(isfile(pdfFiles)),pdfDir);
    checks{end+1,1} = local_check_row_fig1("FIG08","FIG native files created",all(isfile(figNativeFiles)),figMatDir);
    checks{end+1,1} = local_check_row_fig1("FIG09","No GA executed",true,"This script does not call gamultiobj.");
    checks{end+1,1} = local_check_row_fig1("FIG10","Window positions controlled",true,"Figures created with Units=pixels and Position fixed.");

    Tchecks = struct2table(vertcat(checks{:}));

    figures_pass = all(Tchecks.pass);

    if figures_pass
        diagnosis = "TRIOBJECTIVE_FORMAL_RESULTS_FIGURES_PASS";
        decision = "FIGURES_READY_FOR_VISUAL_REVIEW";
        next_step = "Visual review before 9.6r.";
    else
        diagnosis = "TRIOBJECTIVE_FORMAL_RESULTS_FIGURES_REQUIRES_REVIEW";
        decision = "REVIEW_FIGURE_EXPORTS";
        next_step = "Review failed checks.";
    end

    outChecksCsv = fullfile(logsDir,'TRIOBJECTIVE_FORMAL_RESULTS_FIGURES_v96q_fig1_checks.csv');
    writetable(Tchecks,outChecksCsv);

    outMat = fullfile(matDir,'TRIOBJECTIVE_FORMAL_RESULTS_FIGURES_v96q_fig1.mat');

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'T','Trecommended','Trep','Tsummary','Tchecks', ...
        'figDir','pngDir','figMatDir','pdfDir','figFiles','pdfFiles','figNativeFiles');

    outMd = fullfile(logsDir,'TRIOBJECTIVE_FORMAL_RESULTS_FIGURES_v96q_fig1.md');

    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD de figuras: %s', outMd);
    end

    fprintf(fid,'# TRIOBJECTIVE_FORMAL_RESULTS_FIGURES_v96q_fig1_FIX1\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Decisión: `%s`\n\n', decision);
    fprintf(fid,'Siguiente paso: `%s`\n\n', next_step);

    fprintf(fid,'## Corrección aplicada\n\n');
    fprintf(fid,'Las figuras se generan con posición fija de ventana mediante `Units=pixels` y `Position=[x y w h]`.\n\n');

    fprintf(fid,'## Figuras PNG\n\n');
    for i = 1:numel(figFiles)
        fprintf(fid,'- `%s`\n', figFiles(i));
    end

    fprintf(fid,'\n## Figuras PDF\n\n');
    for i = 1:numel(pdfFiles)
        fprintf(fid,'- `%s`\n', pdfFiles(i));
    end

    fprintf(fid,'\n## Checks\n\n');
    fprintf(fid,'| ID | Check | Pass | Evidencia |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | `%s` | %d | `%s` |\n', ...
            string(Tchecks.id(i)), string(Tchecks.check(i)), Tchecks.pass(i), string(Tchecks.evidence(i)));
    end

    fclose(fid);

    figs = struct();
    figs.status = 'TRIOBJECTIVE_FORMAL_RESULTS_FIGURES_COMPLETED';
    figs.diagnosis = diagnosis;
    figs.decision = decision;
    figs.next_step = next_step;
    figs.figDir = figDir;
    figs.pngDir = pngDir;
    figs.pdfDir = pdfDir;
    figs.figMatDir = figMatDir;
    figs.figFiles = figFiles;
    figs.pdfFiles = pdfFiles;
    figs.figNativeFiles = figNativeFiles;
    figs.Tchecks = Tchecks;
    figs.outMd = outMd;
    figs.outMat = outMat;

    disp('=== TRIOBJECTIVE_FORMAL_RESULTS_FIGURES_v96q_fig1_FIX1 ===')
    disp(figs.status)
    disp('=== DIAGNOSIS ===')
    disp(figs.diagnosis)
    disp('=== DECISION ===')
    disp(figs.decision)
    disp('=== NEXT STEP ===')
    disp(figs.next_step)
    disp('=== FIGURE PNG FILES ===')
    disp(figs.figFiles)
    disp('=== FIGURE PDF FILES ===')
    disp(figs.pdfFiles)
    disp('=== CHECKS ===')
    disp(figs.Tchecks)
    disp('=== OUTPUT DIR ===')
    disp(figs.figDir)
    disp(figs.outMd)

end

% =========================================================================
% Helpers
% =========================================================================

function local_label_points_3d(T)
    for i = 1:height(T)
        text(T.MR(i), T.cost_specific(i), T.CO2_specific(i), ...
            "  " + string(T.solution_id(i)));
    end
end

function local_label_points_2d(T, xField, yField)
    x = T.(xField);
    y = T.(yField);

    for i = 1:height(T)
        text(x(i), y(i), "  " + string(T.solution_id(i)));
    end
end

function row = local_check_row_fig1(id, checkName, passVal, evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end