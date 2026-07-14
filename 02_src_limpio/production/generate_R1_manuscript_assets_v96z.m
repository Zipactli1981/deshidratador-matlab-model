function assets = generate_R1_manuscript_assets_v96z()
% GENERATE_R1_MANUSCRIPT_ASSETS_v96z
%
% 9.6z-manuscript-r1-assets-a
% GENERATE-R1-TABLES-AND-PARETO-FIGURES-001
%
% No ejecuta GA.
% No ejecuta modelo.
% Solo genera tablas y figuras de manuscrito desde:
%   POSTPROCESS_R1_vs_legacy_reference_v96z.mat

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    tablesDir = fullfile(articleRoot,'tables');
    figuresDir = fullfile(articleRoot,'figures');
    reviewDir = fullfile(articleRoot,'review');
    traceDir = fullfile(articleRoot,'traceability');

    mkdir_if_needed(tablesDir);
    mkdir_if_needed(figuresDir);
    mkdir_if_needed(reviewDir);
    mkdir_if_needed(traceDir);

    postMat = fullfile(traceDir,'POSTPROCESS_R1_vs_legacy_reference_v96z.mat');

    if ~isfile(postMat)
        error('No se encontró POSTPROCESS_R1_vs_legacy_reference_v96z.mat. Ejecuta primero postprocess_R1_vs_legacy_reference_v96z().');
    end

    S = load(postMat);

    if ~isfield(S,'T') || ~istable(S.T)
        error('El postproceso no contiene tabla T.');
    end

    if ~isfield(S,'Tselected') || ~istable(S.Tselected)
        error('El postproceso no contiene tabla Tselected.');
    end

    if ~isfield(S,'Tall_summary') || ~istable(S.Tall_summary)
        error('El postproceso no contiene tabla Tall_summary.');
    end

    if ~isfield(S,'Treference_compare') || ~istable(S.Treference_compare)
        error('El postproceso no contiene tabla Treference_compare.');
    end

    T = S.T;
    Tselected = S.Tselected;
    Tsummary = S.Tall_summary;
    Tref = S.Treference_compare;

    % ------------------------------------------------------------------
    % Selecciones principales para narrativa
    % ------------------------------------------------------------------
    Tsel_compact = compact_selected_table(Tselected);
    Tfront_compact = compact_front_table(T);
    Tsummary_compact = Tsummary;

    % Identificar solución 7 y solución 3 si existen
    Tsol7 = T(T.solution_index == 7,:);
    Tsol3 = T(T.solution_index == 3,:);
    Tsol1 = T(T.solution_index == 1,:);
    Tsol9 = T(T.solution_index == 9,:);

    % ------------------------------------------------------------------
    % Tabla comparativa gasLP vs solución 7 vs solución 3
    % ------------------------------------------------------------------
    gasRow = Tref(string(Tref.case)=="gasLP_reference",:);

    if isempty(gasRow)
        gasMR = 0.096008649173;
        gasCost = 0.37787758471;
        gasCO2 = 1.681;
    else
        gasMR = gasRow.MR(1);
        gasCost = gasRow.cost_specific_USD_per_kgwater(1);
        gasCO2 = gasRow.CO2_specific_kgCO2_per_kgwater(1);
    end

    case_name = strings(0,1);
    solution_index = [];
    MR = [];
    cost = [];
    CO2 = [];
    cost_reduction_vs_gasLP_pct = [];
    CO2_reduction_vs_gasLP_pct = [];
    interpretation = strings(0,1);

    append_case("gasLP reference", NaN, gasMR, gasCost, gasCO2, 0, 0, ...
        "Reference fossil-only operating mode.");
    if height(Tsol7) > 0
        append_case("R1 solution 7: lowest cost/CO2 with MR<=0.1", ...
            Tsol7.solution_index(1), Tsol7.MR(1), Tsol7.cost_specific_USD_per_kgwater(1), ...
            Tsol7.CO2_specific_kgCO2_per_kgwater(1), ...
            Tsol7.cost_reduction_vs_gasLP_pct(1), Tsol7.CO2_reduction_vs_gasLP_pct(1), ...
            "Operationally attractive feasible solution.");
    end
    if height(Tsol3) > 0
        append_case("R1 solution 3: balanced L2 feasible solution", ...
            Tsol3.solution_index(1), Tsol3.MR(1), Tsol3.cost_specific_USD_per_kgwater(1), ...
            Tsol3.CO2_specific_kgCO2_per_kgwater(1), ...
            Tsol3.cost_reduction_vs_gasLP_pct(1), Tsol3.CO2_reduction_vs_gasLP_pct(1), ...
            "Balanced Pareto compromise.");
    end
    if height(Tsol1) > 0
        append_case("R1 solution 1: cost/CO2 extreme, not MR-feasible", ...
            Tsol1.solution_index(1), Tsol1.MR(1), Tsol1.cost_specific_USD_per_kgwater(1), ...
            Tsol1.CO2_specific_kgCO2_per_kgwater(1), ...
            Tsol1.cost_reduction_vs_gasLP_pct(1), Tsol1.CO2_reduction_vs_gasLP_pct(1), ...
            "Pareto extreme; not recommended as final drying point.");
    end
    if height(Tsol9) > 0
        append_case("R1 solution 9: minimum MR extreme", ...
            Tsol9.solution_index(1), Tsol9.MR(1), Tsol9.cost_specific_USD_per_kgwater(1), ...
            Tsol9.CO2_specific_kgCO2_per_kgwater(1), ...
            Tsol9.cost_reduction_vs_gasLP_pct(1), Tsol9.CO2_reduction_vs_gasLP_pct(1), ...
            "Shows cost/CO2 penalty of aggressive drying.");
    end

    Tcomparison = table(case_name, solution_index, MR, cost, CO2, ...
        cost_reduction_vs_gasLP_pct, CO2_reduction_vs_gasLP_pct, interpretation);

    % ------------------------------------------------------------------
    % Guardar tablas CSV
    % ------------------------------------------------------------------
    frontCsv = fullfile(tablesDir,'MANUSCRIPT_R1_v96z_Table_front_compact.csv');
    selectedCsv = fullfile(tablesDir,'MANUSCRIPT_R1_v96z_Table_selected_solutions.csv');
    comparisonCsv = fullfile(tablesDir,'MANUSCRIPT_R1_v96z_Table_reference_comparison.csv');
    summaryCsv = fullfile(tablesDir,'MANUSCRIPT_R1_v96z_Table_R1_vs_legacy_summary.csv');

    writetable(Tfront_compact,frontCsv);
    writetable(Tsel_compact,selectedCsv);
    writetable(Tcomparison,comparisonCsv);
    writetable(Tsummary_compact,summaryCsv);

    % ------------------------------------------------------------------
    % Figuras
    % ------------------------------------------------------------------
    fig3dPng = fullfile(figuresDir,'MANUSCRIPT_R1_v96z_Fig_Pareto3D.png');
    fig3dFig = fullfile(figuresDir,'MANUSCRIPT_R1_v96z_Fig_Pareto3D.fig');

    figMRcostPng = fullfile(figuresDir,'MANUSCRIPT_R1_v96z_Fig_MR_vs_cost.png');
    figMRcostFig = fullfile(figuresDir,'MANUSCRIPT_R1_v96z_Fig_MR_vs_cost.fig');

    figMRco2Png = fullfile(figuresDir,'MANUSCRIPT_R1_v96z_Fig_MR_vs_CO2.png');
    figMRco2Fig = fullfile(figuresDir,'MANUSCRIPT_R1_v96z_Fig_MR_vs_CO2.fig');

    figCostCO2Png = fullfile(figuresDir,'MANUSCRIPT_R1_v96z_Fig_cost_vs_CO2.png');
    figCostCO2Fig = fullfile(figuresDir,'MANUSCRIPT_R1_v96z_Fig_cost_vs_CO2.fig');

    figBarsPng = fullfile(figuresDir,'MANUSCRIPT_R1_v96z_Fig_reference_vs_selected_bars.png');
    figBarsFig = fullfile(figuresDir,'MANUSCRIPT_R1_v96z_Fig_reference_vs_selected_bars.fig');

    make_pareto3d(T,fig3dPng,fig3dFig);
    make_scatter2d(T,'MR','cost_specific_USD_per_kgwater','MR','Specific cost [USD kg^{-1}_{water}]', ...
        figMRcostPng,figMRcostFig);
    make_scatter2d(T,'MR','CO2_specific_kgCO2_per_kgwater','MR','Specific CO2 [kgCO2 kg^{-1}_{water}]', ...
        figMRco2Png,figMRco2Fig);
    make_scatter2d(T,'cost_specific_USD_per_kgwater','CO2_specific_kgCO2_per_kgwater', ...
        'Specific cost [USD kg^{-1}_{water}]','Specific CO2 [kgCO2 kg^{-1}_{water}]', ...
        figCostCO2Png,figCostCO2Fig);
    make_reference_bars(Tcomparison,figBarsPng,figBarsFig);

    % ------------------------------------------------------------------
    % Checks
    % ------------------------------------------------------------------
    checks = {};
    checks{end+1,1} = check_row("A01","Postprocess MAT exists",isfile(postMat),string(postMat));
    checks{end+1,1} = check_row("A02","R1 front has rows",height(T)>0,string(height(T)));
    checks{end+1,1} = check_row("A03","Selected table has rows",height(Tselected)>0,string(height(Tselected)));
    checks{end+1,1} = check_row("A04","At least one MR<=0.1 solution",sum(T.MR<=0.1)>0,string(sum(T.MR<=0.1)));
    checks{end+1,1} = check_row("A05","Solution 7 available",height(Tsol7)>0,"Candidate lowest cost/CO2 among MR-feasible.");
    checks{end+1,1} = check_row("A06","Solution 3 available",height(Tsol3)>0,"Candidate balanced L2 solution.");
    checks{end+1,1} = check_row("A07","Front CSV written",isfile(frontCsv),string(frontCsv));
    checks{end+1,1} = check_row("A08","Selected CSV written",isfile(selectedCsv),string(selectedCsv));
    checks{end+1,1} = check_row("A09","Comparison CSV written",isfile(comparisonCsv),string(comparisonCsv));
    checks{end+1,1} = check_row("A10","Summary CSV written",isfile(summaryCsv),string(summaryCsv));
    checks{end+1,1} = check_row("A11","Pareto 3D PNG written",isfile(fig3dPng),string(fig3dPng));
    checks{end+1,1} = check_row("A12","MR-cost PNG written",isfile(figMRcostPng),string(figMRcostPng));
    checks{end+1,1} = check_row("A13","MR-CO2 PNG written",isfile(figMRco2Png),string(figMRco2Png));
    checks{end+1,1} = check_row("A14","Cost-CO2 PNG written",isfile(figCostCO2Png),string(figCostCO2Png));
    checks{end+1,1} = check_row("A15","Reference bars PNG written",isfile(figBarsPng),string(figBarsPng));
    checks{end+1,1} = check_row("A16","No GA executed",true,"Only postprocess and plotting.");
    checks{end+1,1} = check_row("A17","No source modified",true,"Read-only with respect to model sources.");

    Tchecks = struct2table(vertcat(checks{:}));

    if all(Tchecks.pass)
        diagnosis = "MANUSCRIPT_R1_ASSETS_PASS";
        decision = "R1_TABLES_AND_FIGURES_READY_FOR_MANUSCRIPT_DRAFT";
        next_step = "Draft Results subsection using Solution 7 and Solution 3 as operational and balanced candidates.";
    else
        diagnosis = "MANUSCRIPT_R1_ASSETS_REQUIRES_REVIEW";
        decision = "DO_NOT_USE_ASSETS_UNTIL_FAILED_CHECKS_ARE_FIXED";
        next_step = "Inspect failed asset-generation checks.";
    end

    checksCsv = fullfile(tablesDir,'MANUSCRIPT_R1_v96z_Tchecks.csv');
    writetable(Tchecks,checksCsv);

    % ------------------------------------------------------------------
    % Reporte Markdown
    % ------------------------------------------------------------------
    reportMd = fullfile(reviewDir,'MANUSCRIPT_R1_ASSETS_v96z.md');

    fid = fopen(reportMd,'w');
    fprintf(fid,'# MANUSCRIPT_R1_ASSETS_v96z\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);

    fprintf(fid,'## Generated tables\n\n');
    fprintf(fid,'| table | path |\n');
    fprintf(fid,'|---|---|\n');
    fprintf(fid,'| Front compact | `%s` |\n', frontCsv);
    fprintf(fid,'| Selected solutions | `%s` |\n', selectedCsv);
    fprintf(fid,'| Reference comparison | `%s` |\n', comparisonCsv);
    fprintf(fid,'| R1 vs legacy summary | `%s` |\n', summaryCsv);

    fprintf(fid,'\n## Generated figures\n\n');
    fprintf(fid,'| figure | PNG | FIG |\n');
    fprintf(fid,'|---|---|---|\n');
    fprintf(fid,'| Pareto 3D | `%s` | `%s` |\n', fig3dPng, fig3dFig);
    fprintf(fid,'| MR vs cost | `%s` | `%s` |\n', figMRcostPng, figMRcostFig);
    fprintf(fid,'| MR vs CO2 | `%s` | `%s` |\n', figMRco2Png, figMRco2Fig);
    fprintf(fid,'| Cost vs CO2 | `%s` | `%s` |\n', figCostCO2Png, figCostCO2Fig);
    fprintf(fid,'| Reference vs selected bars | `%s` | `%s` |\n', figBarsPng, figBarsFig);

    fprintf(fid,'\n## Selected solutions for manuscript\n\n');
    fprintf(fid,'| selection | idx | MR | cost | CO2 | cost red vs gasLP %% | CO2 red vs gasLP %% |\n');
    fprintf(fid,'|---|---:|---:|---:|---:|---:|---:|\n');
    for i = 1:height(Tsel_compact)
        fprintf(fid,'| `%s` | %.0f | %.12g | %.12g | %.12g | %.6g | %.6g |\n', ...
            Tsel_compact.selection(i), ...
            Tsel_compact.solution_index(i), ...
            Tsel_compact.MR(i), ...
            Tsel_compact.cost_specific_USD_per_kgwater(i), ...
            Tsel_compact.CO2_specific_kgCO2_per_kgwater(i), ...
            Tsel_compact.cost_reduction_vs_gasLP_pct(i), ...
            Tsel_compact.CO2_reduction_vs_gasLP_pct(i));
    end

    fprintf(fid,'\n## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            Tchecks.id(i), sanitize_md(Tchecks.check(i)), Tchecks.pass(i), sanitize_md(Tchecks.evidence(i)));
    end

    fprintf(fid,'\n## Manuscript note\n\n');
    fprintf(fid,'CO2 factors remain provisional for code validation. ');
    fprintf(fid,'Manuscript-final environmental claims require definitive emission factors.\n');

    fclose(fid);

    % ------------------------------------------------------------------
    % Guardar MAT
    % ------------------------------------------------------------------
    outMat = fullfile(traceDir,'MANUSCRIPT_R1_ASSETS_v96z.mat');

    figurePaths = struct();
    figurePaths.fig3dPng = fig3dPng;
    figurePaths.fig3dFig = fig3dFig;
    figurePaths.figMRcostPng = figMRcostPng;
    figurePaths.figMRcostFig = figMRcostFig;
    figurePaths.figMRco2Png = figMRco2Png;
    figurePaths.figMRco2Fig = figMRco2Fig;
    figurePaths.figCostCO2Png = figCostCO2Png;
    figurePaths.figCostCO2Fig = figCostCO2Fig;
    figurePaths.figBarsPng = figBarsPng;
    figurePaths.figBarsFig = figBarsFig;

    tablePaths = struct();
    tablePaths.frontCsv = frontCsv;
    tablePaths.selectedCsv = selectedCsv;
    tablePaths.comparisonCsv = comparisonCsv;
    tablePaths.summaryCsv = summaryCsv;
    tablePaths.checksCsv = checksCsv;

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'postMat','Tfront_compact','Tsel_compact','Tcomparison','Tsummary_compact','Tchecks', ...
        'figurePaths','tablePaths','reportMd','outMat');

    assets = struct();
    assets.status = 'MANUSCRIPT_R1_ASSETS_v96z_COMPLETED';
    assets.diagnosis = diagnosis;
    assets.decision = decision;
    assets.next_step = next_step;
    assets.Tfront_compact = Tfront_compact;
    assets.Tselected_compact = Tsel_compact;
    assets.Tcomparison = Tcomparison;
    assets.Tsummary = Tsummary_compact;
    assets.Tchecks = Tchecks;
    assets.figurePaths = figurePaths;
    assets.tablePaths = tablePaths;
    assets.reportMd = reportMd;
    assets.outMat = outMat;

    disp('=== MANUSCRIPT_R1_ASSETS_v96z ===')
    disp(assets.status)
    disp('=== DIAGNOSIS ===')
    disp(assets.diagnosis)
    disp('=== DECISION ===')
    disp(assets.decision)
    disp('=== NEXT STEP ===')
    disp(assets.next_step)
    disp('=== SELECTED COMPACT ===')
    disp(assets.Tselected_compact)
    disp('=== COMPARISON ===')
    disp(assets.Tcomparison)
    disp('=== SUMMARY ===')
    disp(assets.Tsummary)
    disp('=== CHECKS ===')
    disp(assets.Tchecks)
    disp('=== FIGURES ===')
    disp(assets.figurePaths)
    disp('=== REPORT ===')
    disp(assets.reportMd)

    function append_case(name,idx,mr,cst,co2,costRed,co2Red,note)
        case_name(end+1,1) = string(name);
        solution_index(end+1,1) = idx;
        MR(end+1,1) = mr;
        cost(end+1,1) = cst;
        CO2(end+1,1) = co2;
        cost_reduction_vs_gasLP_pct(end+1,1) = costRed;
        CO2_reduction_vs_gasLP_pct(end+1,1) = co2Red;
        interpretation(end+1,1) = string(note);
    end
end

function Tcompact = compact_selected_table(Tselected)
    keepSelections = [
        "min_cost_all"
        "min_MR_all"
        "balanced_L2_all"
        "min_cost_MR_le_0p1"
        "balanced_L2_MR_le_0p1"
    ];

    keep = ismember(string(Tselected.selection),keepSelections);
    Tcompact = Tselected(keep,:);

    vars = {
        'selection'
        'solution_index'
        'm_max'
        'T_min'
        'r_div2'
        't_rec_ini'
        'MR'
        'cost_specific_USD_per_kgwater'
        'CO2_specific_kgCO2_per_kgwater'
        'MR_feasible_010'
        'cost_reduction_vs_gasLP_pct'
        'CO2_reduction_vs_gasLP_pct'
        'norm_L2_all_objectives'
    };

    Tcompact = Tcompact(:,vars);
end

function Tcompact = compact_front_table(T)
    vars = {
        'solution_index'
        'm_max'
        'T_min'
        'r_div2'
        't_rec_ini'
        'MR'
        'cost_specific_USD_per_kgwater'
        'CO2_specific_kgCO2_per_kgwater'
        'MR_feasible_010'
        'cost_reduction_vs_gasLP_pct'
        'CO2_reduction_vs_gasLP_pct'
    };

    Tcompact = T(:,vars);
end

function make_pareto3d(T,outPng,outFig)
    f = figure('Visible','off');
    scatter3(T.MR, T.cost_specific_USD_per_kgwater, T.CO2_specific_kgCO2_per_kgwater, 60, 'filled');
    grid on;
    xlabel('MR');
    ylabel('Specific cost [USD kg^{-1}_{water}]');
    zlabel('Specific CO2 [kgCO2 kg^{-1}_{water}]');
    title('R1 seed-aware Pareto front');
    text(T.MR, T.cost_specific_USD_per_kgwater, T.CO2_specific_kgCO2_per_kgwater, ...
        compose('  %d',T.solution_index), 'FontSize',8);
    view(135,25);
    saveas(f,outFig);
    exportgraphics(f,outPng,'Resolution',300);
    close(f);
end

function make_scatter2d(T,xvar,yvar,xlab,ylab,outPng,outFig)
    f = figure('Visible','off');

    feasible = T.MR_feasible_010;

    scatter(T.(xvar)(~feasible), T.(yvar)(~feasible), 70, 'o');
    hold on;
    scatter(T.(xvar)(feasible), T.(yvar)(feasible), 70, 'filled');

    grid on;
    xlabel(xlab);
    ylabel(ylab);
    title(sprintf('R1 seed-aware: %s vs %s', xlab, ylab));

    for i = 1:height(T)
        text(T.(xvar)(i), T.(yvar)(i), sprintf('  %d',T.solution_index(i)), 'FontSize',8);
    end

    legend({'MR>0.1','MR<=0.1'},'Location','best');

    saveas(f,outFig);
    exportgraphics(f,outPng,'Resolution',300);
    close(f);
end

function make_reference_bars(Tcomparison,outPng,outFig)
    f = figure('Visible','off');

    % Compatibilidad: el código construye la tabla con variable case_name,
    % no con variable case.
    if ismember('case_name',Tcomparison.Properties.VariableNames)
        rawLabels = string(Tcomparison.case_name);
    elseif ismember('case',Tcomparison.Properties.VariableNames)
        rawLabels = string(Tcomparison.case);
    else
        rawLabels = "case_" + string((1:height(Tcomparison))');
    end

    labels = rawLabels;
    labels = replace(labels,"R1 solution ","S");
    labels = replace(labels,": "," ");
    labels = replace(labels,"gasLP reference","gasLP");
    labels = replace(labels,"gasLP_reference","gasLP");

    requiredVars = {'MR','cost','CO2'};
    missingVars = setdiff(requiredVars,Tcomparison.Properties.VariableNames);
    if ~isempty(missingVars)
        close(f);
        error('Tcomparison no contiene columnas requeridas para barras: %s', strjoin(string(missingVars),', '));
    end

    Y = [Tcomparison.MR, Tcomparison.cost, Tcomparison.CO2];

    bar(Y);
    grid on;
    xticks(1:height(Tcomparison));
    xticklabels(labels);
    xtickangle(25);
    ylabel('Metric value');
    title('Reference and selected R1 solutions');
    legend({'MR','Specific cost','Specific CO2'},'Location','best');

    saveas(f,outFig);
    exportgraphics(f,outPng,'Resolution',300);
    close(f);
end

function row = check_row(id, checkName, passVal, evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end

function mkdir_if_needed(folderPath)
    if ~isfolder(folderPath)
        mkdir(folderPath);
    end
end

function s = sanitize_md(x)
    s = string(x);
    s = replace(s, newline, " ");
    s = replace(s, "|", "\|");
    s = replace(s, "`", "'");
end