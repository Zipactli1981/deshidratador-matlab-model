function maps = surrogate_response_maps_from_formal_front_v96q_rsm1_fix1(nGrid)
% SURROGATE_RESPONSE_MAPS_FROM_FORMAL_FRONT_v96q_rsm1_fix1
% 9.6q-rsm1-fix1 — FAST-SURROGATE-RESPONSE-MAPS-FROM-FORMAL-FRONT-001
%
% Objetivo:
%   Generar mapas/superficies empíricas rápidas a partir del frente formal
%   ya calculado, SIN volver a llamar el modelo mecanístico.
%
% Justificación:
%   El RSM mecanístico local se detuvo porque el modelo llama vpasolve
%   dentro de wetbulb_AirH2O en cada simulación. Este script evita ese
%   cuello de botella y usa únicamente las 9 soluciones formales ya
%   consolidadas.
%
% Este paso:
%   - NO ejecuta gamultiobj.
%   - NO llama objective_productive_corrected_v96j_triobjective_CO2_fix1.
%   - NO llama wetbulb_AirH2O.
%   - NO usa vpasolve.
%   - NO modifica fuentes protegidas.
%   - Carga Tsolutions y Trecommended desde v96p.
%   - Genera mapas interpolados/surrogados:
%       1) T_min vs r_div2
%       2) T_min vs m_max
%       3) r_div2 vs m_max
%     para:
%       MR, costo específico, CO2 específico.
%
% Uso:
%   maps = surrogate_response_maps_from_formal_front_v96q_rsm1_fix1();
%   maps = surrogate_response_maps_from_formal_front_v96q_rsm1_fix1(80);
%
% Nota:
%   Estas NO son superficies mecanísticas nuevas. Son mapas empíricos
%   interpolados del frente formal. Sirven para inspección visual rápida
%   y discusión de tendencias alrededor de H2.

    if nargin < 1 || isempty(nGrid)
        nGrid = 80;
    end

    if nGrid < 20
        error('nGrid debe ser >= 20 para mapas interpolados visibles.');
    end

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
        error('No se encontró solución recomendada %s en Tsolutions.', recID);
    end

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    mapBaseDir = fullfile(rootDir,'05_runs','surrogate_response_maps_from_formal_front_v96q_rsm1_fix1');
    mapDir = fullfile(mapBaseDir,['SURROGATE_RESPONSE_MAPS_FROM_FORMAL_FRONT_v96q_rsm1_fix1_' timestamp]);

    pngDir = fullfile(mapDir,'png');
    pdfDir = fullfile(mapDir,'pdf');
    figDir = fullfile(mapDir,'fig');
    tablesDir = fullfile(mapDir,'tables');
    logsDir = fullfile(mapDir,'logs');
    matDir = fullfile(mapDir,'mat');

    if ~isfolder(mapBaseDir), mkdir(mapBaseDir); end
    if ~isfolder(mapDir), mkdir(mapDir); end
    if ~isfolder(pngDir), mkdir(pngDir); end
    if ~isfolder(pdfDir), mkdir(pdfDir); end
    if ~isfolder(figDir), mkdir(figDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Datos base
    % ---------------------------------------------------------------------
    T.acceptable_MR = T.MR < MR_acceptance;

    xH2 = [ ...
        Trecommended.m_max(1), ...
        Trecommended.T_min(1), ...
        Trecommended.r_div2(1), ...
        Trecommended.t_rec_ini(1)];

    gas = struct();
    gas.MR = Tsummary.gasLP_MR(1);
    gas.cost = Tsummary.gasLP_cost(1);
    gas.CO2 = Tsummary.gasLP_CO2(1);

    % ---------------------------------------------------------------------
    % Generar mapas por pares
    % ---------------------------------------------------------------------
    mapPairs = { ...
        'T_min','r_div2','T_min vs r_div2'; ...
        'T_min','m_max','T_min vs m_max'; ...
        'r_div2','m_max','r_div2 vs m_max'};

    metrics = { ...
        'MR','MR final'; ...
        'cost_specific','Costo específico'; ...
        'CO2_specific','CO2 específico provisional'};

    figureFiles = strings(0,1);
    pdfFiles = strings(0,1);
    figFiles = strings(0,1);

    mapTables = {};

    for p = 1:size(mapPairs,1)

        xName = mapPairs{p,1};
        yName = mapPairs{p,2};
        pairLabel = mapPairs{p,3};

        xData = T.(xName);
        yData = T.(yName);

        xMin = min(xData);
        xMax = max(xData);
        yMin = min(yData);
        yMax = max(yData);

        xPad = 0.03*(xMax - xMin);
        yPad = 0.03*(yMax - yMin);

        if xPad == 0, xPad = 0.01; end
        if yPad == 0, yPad = 0.01; end

        xGrid = linspace(xMin - xPad, xMax + xPad, nGrid);
        yGrid = linspace(yMin - yPad, yMax + yPad, nGrid);
        [XG,YG] = meshgrid(xGrid,yGrid);

        for m = 1:size(metrics,1)

            zName = metrics{m,1};
            zLabel = metrics{m,2};

            zData = T.(zName);

            % Interpolación dentro del dominio del frente.
            try
                Finterp = scatteredInterpolant(xData, yData, zData, 'natural', 'none');
            catch
                Finterp = scatteredInterpolant(xData, yData, zData, 'linear', 'none');
            end

            ZG = Finterp(XG,YG);

            % Fallback nearest para visualización de zona externa al casco.
            Fnear = scatteredInterpolant(xData, yData, zData, 'nearest', 'nearest');
            ZG_near = Fnear(XG,YG);

            ZG_plot = ZG;
            nanMask = ~isfinite(ZG_plot);
            ZG_plot(nanMask) = ZG_near(nanMask);

            % Tabla de mapa
            Tmap = table();
            Tmap.pair = repmat(string(pairLabel),numel(XG),1);
            Tmap.metric = repmat(string(zName),numel(XG),1);
            Tmap.x_name = repmat(string(xName),numel(XG),1);
            Tmap.y_name = repmat(string(yName),numel(XG),1);
            Tmap.x_value = XG(:);
            Tmap.y_value = YG(:);
            Tmap.z_interpolated = ZG(:);
            Tmap.z_plot_filled_nearest = ZG_plot(:);
            Tmap.inside_interpolation_hull = isfinite(ZG(:));

            mapTables{end+1,1} = Tmap; %#ok<AGROW>

            % ---------------------------------------------------------
            % Figura contour
            % ---------------------------------------------------------
            figTitle = sprintf('%s — %s', pairLabel, zLabel);

            f = figure('Name',figTitle, ...
                'Color','w', ...
                'Units','pixels', ...
                'Position',[120+25*p+20*m 100+25*p+20*m 1150 760], ...
                'Visible','on');

            hold on; grid on; box on;

            contourf(XG,YG,ZG_plot,18,'LineStyle','none');
            colorbar;

            contour(XG,YG,ZG_plot,10,'LineColor',[0.25 0.25 0.25]);

            if strcmp(zName,'MR')
                try
                    contour(XG,YG,ZG_plot,[MR_acceptance MR_acceptance], ...
                        'LineColor','k','LineStyle','--','LineWidth',2);
                catch
                end
            end

            % Puntos formales
            scatter(xData(~T.acceptable_MR), yData(~T.acceptable_MR), 90, 'x', 'LineWidth', 1.6);
            scatter(xData(T.acceptable_MR), yData(T.acceptable_MR), 90, 'o', 'filled');

            % H2
            h2x = Trecommended.(xName)(1);
            h2y = Trecommended.(yName)(1);
            scatter(h2x,h2y,190,'p','filled','MarkerEdgeColor','k');
            text(h2x,h2y,'  H2','FontWeight','bold','Color','k');

            % Etiquetas de soluciones
            for i = 1:height(T)
                text(xData(i),yData(i),"  " + string(T.solution_id(i)));
            end

            xlabel(local_axis_label_from_name(xName));
            ylabel(local_axis_label_from_name(yName));
            title(figTitle);

            legend({'Mapa interpolado','Contornos','Inadmisibles MR >= 0.1','Admisibles MR < 0.1','H2 recomendada'}, ...
                'Location','best');

            safeName = local_safe_filename(sprintf('MAP_%s_%s', pairLabel, zName));

            outPng = fullfile(pngDir,[safeName '.png']);
            outPdf = fullfile(pdfDir,[safeName '.pdf']);
            outFig = fullfile(figDir,[safeName '.fig']);

            saveas(f,outPng);
            savefig(f,outFig);
            exportgraphics(f,outPdf,'ContentType','vector');

            figureFiles(end+1,1) = string(outPng); %#ok<AGROW>
            pdfFiles(end+1,1) = string(outPdf); %#ok<AGROW>
            figFiles(end+1,1) = string(outFig); %#ok<AGROW>

            % ---------------------------------------------------------
            % Figura surface 3D
            % ---------------------------------------------------------
            figTitle3D = sprintf('%s — superficie %s', pairLabel, zLabel);

            fs = figure('Name',figTitle3D, ...
                'Color','w', ...
                'Units','pixels', ...
                'Position',[180+25*p+20*m 140+25*p+20*m 1150 760], ...
                'Visible','on');

            hold on; grid on; box on;

            surf(XG,YG,ZG_plot,'EdgeAlpha',0.2);
            colorbar;

            zH2 = Fnear(h2x,h2y);
            scatter3(h2x,h2y,zH2,190,'p','filled','MarkerEdgeColor','k');
            text(h2x,h2y,zH2,'  H2','FontWeight','bold','Color','k');

            scatter3(xData,yData,zData,80,'filled','MarkerEdgeColor','k');

            xlabel(local_axis_label_from_name(xName));
            ylabel(local_axis_label_from_name(yName));
            zlabel(zLabel);
            title(figTitle3D);

            view(135,28);

            safeName3D = local_safe_filename(sprintf('SURF_%s_%s', pairLabel, zName));

            outPng = fullfile(pngDir,[safeName3D '.png']);
            outPdf = fullfile(pdfDir,[safeName3D '.pdf']);
            outFig = fullfile(figDir,[safeName3D '.fig']);

            saveas(fs,outPng);
            savefig(fs,outFig);
            exportgraphics(fs,outPdf,'ContentType','vector');

            figureFiles(end+1,1) = string(outPng); %#ok<AGROW>
            pdfFiles(end+1,1) = string(outPdf); %#ok<AGROW>
            figFiles(end+1,1) = string(outFig); %#ok<AGROW>
        end
    end

    TallMaps = vertcat(mapTables{:});

    outMapsCsv = fullfile(tablesDir,'SURROGATE_RESPONSE_MAPS_FROM_FORMAL_FRONT_v96q_rsm1_fix1_grid_values.csv');
    outSolutionsCsv = fullfile(tablesDir,'SURROGATE_RESPONSE_MAPS_FROM_FORMAL_FRONT_v96q_rsm1_fix1_formal_solutions.csv');
    outRecommendedCsv = fullfile(tablesDir,'SURROGATE_RESPONSE_MAPS_FROM_FORMAL_FRONT_v96q_rsm1_fix1_H2_recommended.csv');

    writetable(TallMaps,outMapsCsv);
    writetable(T,outSolutionsCsv);
    writetable(Trecommended,outRecommendedCsv);

    % ---------------------------------------------------------------------
    % Resumen
    % ---------------------------------------------------------------------
    summary = struct();
    summary.method = "surrogate/interpolated maps from formal Pareto front";
    summary.no_mechanistic_rerun = true;
    summary.no_GA_executed = true;
    summary.no_vpasolve_called = true;
    summary.n_formal_solutions = height(T);
    summary.n_admissible = sum(T.MR < MR_acceptance);
    summary.recommended_solution_id = string(Trecommended.solution_id(1));
    summary.H2_m_max = Trecommended.m_max(1);
    summary.H2_T_min = Trecommended.T_min(1);
    summary.H2_r_div2 = Trecommended.r_div2(1);
    summary.H2_t_rec_ini = Trecommended.t_rec_ini(1);
    summary.H2_MR = Trecommended.MR(1);
    summary.H2_cost_specific = Trecommended.cost_specific(1);
    summary.H2_CO2_specific = Trecommended.CO2_specific(1);
    summary.H2_cost_reduction_pct_vs_gasLP = Trecommended.reduction_cost_pct_vs_gasLP(1);
    summary.H2_CO2_reduction_pct_vs_gasLP = Trecommended.reduction_CO2_pct_vs_gasLP(1);
    summary.CO2_factor_status = "PROVISIONAL_FOR_CODE_VALIDATION";
    summary.map_interpretation = "visual/surrogate only; not a new mechanistic RSM";

    TsummaryMaps = struct2table(summary);

    outSummaryCsv = fullfile(tablesDir,'SURROGATE_RESPONSE_MAPS_FROM_FORMAL_FRONT_v96q_rsm1_fix1_summary.csv');
    writetable(TsummaryMaps,outSummaryCsv);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};

    checks{end+1,1} = local_check_row( ...
        "SM01", ...
        "Formal interpretation loaded", ...
        true, ...
        string(interpMat), ...
        "Must load v96p PASS file.");

    checks{end+1,1} = local_check_row( ...
        "SM02", ...
        "H2 preserved", ...
        string(Trecommended.solution_id(1)) == "H2", ...
        sprintf("recommended=%s", string(Trecommended.solution_id(1))), ...
        "Recommended solution should remain H2.");

    checks{end+1,1} = local_check_row( ...
        "SM03", ...
        "No mechanistic rerun", ...
        true, ...
        "This script does not call objective function, tunel_mod2, wetbulb_AirH2O, or vpasolve.", ...
        "Maps must be instantaneous surrogate visualizations.");

    checks{end+1,1} = local_check_row( ...
        "SM04", ...
        "Figure files created", ...
        numel(figureFiles) == 18 && all(isfile(figureFiles)), ...
        sprintf("PNG figures=%d", numel(figureFiles)), ...
        "Expected 18 PNG files: 3 pairs × 3 metrics × 2 plot types.");

    checks{end+1,1} = local_check_row( ...
        "SM05", ...
        "PDF files created", ...
        numel(pdfFiles) == 18 && all(isfile(pdfFiles)), ...
        sprintf("PDF figures=%d", numel(pdfFiles)), ...
        "Expected 18 PDF files.");

    checks{end+1,1} = local_check_row( ...
        "SM06", ...
        "CSV tables created", ...
        isfile(outMapsCsv) && isfile(outSolutionsCsv) && isfile(outRecommendedCsv), ...
        "map grid, formal solutions and H2 CSV created", ...
        "Core CSV files must exist.");

    checks{end+1,1} = local_check_row( ...
        "SM07", ...
        "CO2 provisional flag preserved", ...
        true, ...
        "CO2 remains PROVISIONAL_FOR_CODE_VALIDATION.", ...
        "No manuscript-final CO2 claim yet.");

    Tchecks = struct2table(vertcat(checks{:}));

    maps_pass = all(Tchecks.pass);

    if maps_pass
        diagnosis = "SURROGATE_RESPONSE_MAPS_FROM_FORMAL_FRONT_PASS";
        decision = "SURROGATE_MAPS_READY_FOR_VISUAL_REVIEW";
        next_step = "Review maps visually; then decide whether mechanistic RSM is still needed.";
    else
        diagnosis = "SURROGATE_RESPONSE_MAPS_FROM_FORMAL_FRONT_REQUIRES_REVIEW";
        decision = "REVIEW_SURROGATE_MAP_EXPORTS";
        next_step = "Review failed checks.";
    end

    outChecksCsv = fullfile(tablesDir,'SURROGATE_RESPONSE_MAPS_FROM_FORMAL_FRONT_v96q_rsm1_fix1_checks.csv');
    writetable(Tchecks,outChecksCsv);

    % ---------------------------------------------------------------------
    % Guardar MAT y MD
    % ---------------------------------------------------------------------
    outMat = fullfile(matDir,'SURROGATE_RESPONSE_MAPS_FROM_FORMAL_FRONT_v96q_rsm1_fix1.mat');

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'T','Trecommended','Tsummary','TallMaps','TsummaryMaps','Tchecks', ...
        'figureFiles','pdfFiles','figFiles', ...
        'mapDir','pngDir','pdfDir','figDir','tablesDir','logsDir','matDir', ...
        'outMapsCsv','outSolutionsCsv','outRecommendedCsv','outSummaryCsv','outChecksCsv');

    outMd = fullfile(logsDir,'SURROGATE_RESPONSE_MAPS_FROM_FORMAL_FRONT_v96q_rsm1_fix1.md');

    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# SURROGATE_RESPONSE_MAPS_FROM_FORMAL_FRONT_v96q_rsm1_fix1\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Decisión: `%s`\n\n', decision);
    fprintf(fid,'Siguiente paso: `%s`\n\n', next_step);

    fprintf(fid,'## Nota metodológica\n\n');
    fprintf(fid,'Estos mapas son superficies empíricas/interpoladas a partir de las 9 soluciones del frente formal. ');
    fprintf(fid,'No son un nuevo barrido mecanístico y no sustituyen una RSM mecanística futura. ');
    fprintf(fid,'Se generan para inspección visual rápida y para contextualizar la ubicación de H2.\n\n');

    fprintf(fid,'## H2\n\n');
    fprintf(fid,'| Variable/Métrica | Valor |\n');
    fprintf(fid,'|---|---:|\n');
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

    fprintf(fid,'\n## Dictamen\n\n');
    if maps_pass
        fprintf(fid,'Los mapas surrogados fueron generados correctamente. Pueden usarse para revisión visual rápida del frente formal y de la ubicación relativa de H2. ');
        fprintf(fid,'Para afirmaciones mecanísticas finas se requiere una RSM mecanística posterior, preferentemente optimizando primero wetbulb_AirH2O para evitar vpasolve repetido.\n');
    else
        fprintf(fid,'La generación de mapas requiere revisión. Ver checks fallidos.\n');
    end

    fclose(fid);

    % ---------------------------------------------------------------------
    % Consola
    % ---------------------------------------------------------------------
    maps = struct();
    maps.status = 'SURROGATE_RESPONSE_MAPS_FROM_FORMAL_FRONT_COMPLETED';
    maps.diagnosis = diagnosis;
    maps.decision = decision;
    maps.next_step = next_step;
    maps.TsummaryMaps = TsummaryMaps;
    maps.Tchecks = Tchecks;
    maps.figureFiles = figureFiles;
    maps.pdfFiles = pdfFiles;
    maps.figFiles = figFiles;
    maps.mapDir = mapDir;
    maps.pngDir = pngDir;
    maps.pdfDir = pdfDir;
    maps.figDir = figDir;
    maps.tablesDir = tablesDir;
    maps.outMd = outMd;
    maps.outMat = outMat;

    disp('=== SURROGATE_RESPONSE_MAPS_FROM_FORMAL_FRONT_v96q_rsm1_fix1 ===')
    disp(maps.status)
    disp('=== DIAGNOSIS ===')
    disp(maps.diagnosis)
    disp('=== DECISION ===')
    disp(maps.decision)
    disp('=== NEXT STEP ===')
    disp(maps.next_step)
    disp('=== SUMMARY ===')
    disp(maps.TsummaryMaps)
    disp('=== CHECKS ===')
    disp(maps.Tchecks)
    disp('=== PNG DIR ===')
    disp(maps.pngDir)
    disp('=== OUTPUT MD ===')
    disp(maps.outMd)

end

% =========================================================================
% Helpers
% =========================================================================

function label = local_axis_label_from_name(name)
    name = string(name);

    switch name
        case "m_max"
            label = 'm_{max}';
        case "T_min"
            label = 'T_{min}';
        case "r_div2"
            label = 'r_{div2}';
        case "t_rec_ini"
            label = 't_{rec,ini}';
        otherwise
            label = char(name);
    end
end

function safe = local_safe_filename(name)
    safe = string(name);
    safe = replace(safe," ","_");
    safe = replace(safe,"—","_");
    safe = replace(safe,"-","_");
    safe = replace(safe,"/","_");
    safe = replace(safe,"\","_");
    safe = replace(safe,":","_");
    safe = replace(safe,".","p");
    safe = char(safe);
end

function row = local_check_row(id, checkName, passVal, evidence, criterion)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
    row.criterion = string(criterion);
end