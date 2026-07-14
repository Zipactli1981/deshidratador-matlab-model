function post = postprocess_R1_vs_legacy_reference_v96z()
% POSTPROCESS_R1_VS_LEGACY_REFERENCE_v96z
%
% 9.6z-postprocess-r1-a
% POSTPROCESS-R1-VS-LEGACY-AND-REFERENCE-001
%
% No ejecuta GA.
% No ejecuta modelo.
% Solo carga salidas existentes de R1, legacy formal y referencia.

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    runsRoot = fullfile(articleRoot,'runs');
    reviewDir = fullfile(articleRoot,'review');
    tablesDir = fullfile(articleRoot,'tables');
    traceDir = fullfile(articleRoot,'traceability');

    mkdir_if_needed(reviewDir);
    mkdir_if_needed(tablesDir);
    mkdir_if_needed(traceDir);

    % ------------------------------------------------------------------
    % Localizar R1 formal seed-aware
    % ------------------------------------------------------------------
    r1Files = dir(fullfile(runsRoot,'**','SEEDAWARE_FORMAL_R1_ONLY_seed_61001_output.mat'));

    if isempty(r1Files)
        error('No se encontró SEEDAWARE_FORMAL_R1_ONLY_seed_61001_output.mat dentro de article_Q1\runs.');
    end

    [~,idxNewest] = max([r1Files.datenum]);
    r1Mat = fullfile(r1Files(idxNewest).folder,r1Files(idxNewest).name);
    S1 = load(r1Mat);

    if ~isfield(S1,'formal')
        error('El MAT R1 no contiene la variable formal.');
    end

    if ~isfield(S1.formal,'Tsolutions') || ~istable(S1.formal.Tsolutions)
        error('El MAT R1 no contiene formal.Tsolutions como tabla.');
    end

    Tsol = S1.formal.Tsolutions;

    if isfield(S1.formal,'Trun') && istable(S1.formal.Trun)
        Trun = S1.formal.Trun;
    else
        Trun = table();
    end

    if isfield(S1.formal,'Treference') && istable(S1.formal.Treference)
        Tref = S1.formal.Treference;
    else
        Tref = table();
    end

    % ------------------------------------------------------------------
    % Referencia gasLP/hybrid
    % ------------------------------------------------------------------
    gasMR = 0.096008649173;
    gasCost = 0.37787758471;
    gasCO2 = 1.681;

    hybridRefMR = 0.0959172010556;
    hybridRefCost = 0.265706336789;
    hybridRefCO2 = 1.0584;

    if ~isempty(Tref) && ismember('mode',Tref.Properties.VariableNames)
        if any(string(Tref.mode)=="gasLP")
            ig = find(string(Tref.mode)=="gasLP",1);
            gasMR = get_reference_value(Tref,ig,{'f1','MR'});
            gasCost = get_reference_value(Tref,ig,{'f2','cost_specific','cost_specific_USD_per_kgwater'});
            gasCO2 = get_reference_value(Tref,ig,{'f3','CO2_specific','CO2_specific_kgCO2_per_kgwater'});
        end

        if any(string(Tref.mode)=="hybrid")
            ih = find(string(Tref.mode)=="hybrid",1);
            hybridRefMR = get_reference_value(Tref,ih,{'f1','MR'});
            hybridRefCost = get_reference_value(Tref,ih,{'f2','cost_specific','cost_specific_USD_per_kgwater'});
            hybridRefCO2 = get_reference_value(Tref,ih,{'f3','CO2_specific','CO2_specific_kgCO2_per_kgwater'});
        end
    end

    % ------------------------------------------------------------------
    % Validar columnas R1
    % ------------------------------------------------------------------
    requiredVars = {
        'solution_index'
        'm_max'
        'T_min'
        'r_div2'
        't_rec_ini'
        'MR'
        'cost_specific_USD_per_kgwater'
        'CO2_specific_kgCO2_per_kgwater'
    };

    missingVars = setdiff(requiredVars,Tsol.Properties.VariableNames);
    if ~isempty(missingVars)
        error('Tsolutions no contiene columnas requeridas: %s', strjoin(string(missingVars),', '));
    end

    % ------------------------------------------------------------------
    % Tabla R1 enriquecida
    % ------------------------------------------------------------------
    T = Tsol;

    T.MR_feasible_010 = T.MR <= 0.1;
    T.cost_reduction_vs_gasLP_pct = 100*(gasCost - T.cost_specific_USD_per_kgwater)/gasCost;
    T.CO2_reduction_vs_gasLP_pct = 100*(gasCO2 - T.CO2_specific_kgCO2_per_kgwater)/gasCO2;
    T.MR_reduction_vs_gasLP_pct = 100*(gasMR - T.MR)/gasMR;

    T.cost_reduction_vs_hybrid_ref_pct = 100*(hybridRefCost - T.cost_specific_USD_per_kgwater)/hybridRefCost;
    T.CO2_reduction_vs_hybrid_ref_pct = 100*(hybridRefCO2 - T.CO2_specific_kgCO2_per_kgwater)/hybridRefCO2;
    T.MR_reduction_vs_hybrid_ref_pct = 100*(hybridRefMR - T.MR)/hybridRefMR;

    fcols = [T.MR, T.cost_specific_USD_per_kgwater, T.CO2_specific_kgCO2_per_kgwater];

    fmin = min(fcols,[],1,'omitnan');
    fmax = max(fcols,[],1,'omitnan');
    denom = fmax - fmin;
    denom(denom==0) = 1;

    Fnorm = (fcols - fmin)./denom;

    T.norm_MR = Fnorm(:,1);
    T.norm_cost = Fnorm(:,2);
    T.norm_CO2 = Fnorm(:,3);
    T.norm_L2_all_objectives = sqrt(sum(Fnorm.^2,2));
    T.norm_sum_all_objectives = sum(Fnorm,2);
    T.norm_chebyshev = max(Fnorm,[],2);

    % ------------------------------------------------------------------
    % Selecciones R1
    % ------------------------------------------------------------------
    Tselected = table();

    Tselected = add_selection(Tselected,T,"min_cost_all", ...
        find(T.cost_specific_USD_per_kgwater == min(T.cost_specific_USD_per_kgwater,[],'omitnan'),1));

    Tselected = add_selection(Tselected,T,"min_CO2_all", ...
        find(T.CO2_specific_kgCO2_per_kgwater == min(T.CO2_specific_kgCO2_per_kgwater,[],'omitnan'),1));

    Tselected = add_selection(Tselected,T,"min_MR_all", ...
        find(T.MR == min(T.MR,[],'omitnan'),1));

    Tselected = add_selection(Tselected,T,"balanced_L2_all", ...
        find(T.norm_L2_all_objectives == min(T.norm_L2_all_objectives,[],'omitnan'),1));

    Tfeas = T(T.MR_feasible_010,:);

    if height(Tfeas) > 0
        Tselected = add_selection(Tselected,Tfeas,"min_cost_MR_le_0p1", ...
            find(Tfeas.cost_specific_USD_per_kgwater == min(Tfeas.cost_specific_USD_per_kgwater,[],'omitnan'),1));

        Tselected = add_selection(Tselected,Tfeas,"min_CO2_MR_le_0p1", ...
            find(Tfeas.CO2_specific_kgCO2_per_kgwater == min(Tfeas.CO2_specific_kgCO2_per_kgwater,[],'omitnan'),1));

        Tselected = add_selection(Tselected,Tfeas,"balanced_L2_MR_le_0p1", ...
            find(Tfeas.norm_L2_all_objectives == min(Tfeas.norm_L2_all_objectives,[],'omitnan'),1));

        Tselected = add_selection(Tselected,Tfeas,"min_MR_MR_le_0p1", ...
            find(Tfeas.MR == min(Tfeas.MR,[],'omitnan'),1));
    end

    % Eliminar duplicados exactos por selection + solution_index
    if height(Tselected) > 0
        [~,ia] = unique(strcat(string(Tselected.selection),"_",string(Tselected.solution_index)),'stable');
        Tselected = Tselected(ia,:);
    end

    % ------------------------------------------------------------------
    % Buscar legacy formal v96m
    % ------------------------------------------------------------------
    legacyFiles = dir(fullfile(rootDir,'05_runs','triobjective_formal_ga_v96m','**','TRIOBJECTIVE_FORMAL_GA_v96m.mat'));

    keep = true(numel(legacyFiles),1);
    for k = 1:numel(legacyFiles)
        p = lower(fullfile(legacyFiles(k).folder,legacyFiles(k).name));
        if contains(p,'seedaware') || contains(p,'smoke')
            keep(k) = false;
        end
    end
    legacyFiles = legacyFiles(keep);

    legacy_status = "NOT_FOUND";
    legacyMat = "";
    Tlegacy_summary = table();

    if ~isempty(legacyFiles)
        [~,il] = max([legacyFiles.datenum]);
        legacyMat = string(fullfile(legacyFiles(il).folder,legacyFiles(il).name));
        SL = load(legacyMat);

        legacy_status = "FOUND";

        if isfield(SL,'Tsolutions') && istable(SL.Tsolutions)
            TL = SL.Tsolutions;
        elseif isfield(SL,'formal') && isfield(SL.formal,'Tsolutions') && istable(SL.formal.Tsolutions)
            TL = SL.formal.Tsolutions;
        else
            TL = table();
            legacy_status = "FOUND_BUT_NO_TSOLUTIONS";
        end

        if ~isempty(TL)
            Tlegacy_summary = summarize_front(TL,"legacy_v96m");
        end
    end

    TR1_summary = summarize_front(T,"R1_seedaware_61001");

    Tall_summary = TR1_summary;
    if ~isempty(Tlegacy_summary)
        Tall_summary = [Tall_summary; Tlegacy_summary];
    end

    % ------------------------------------------------------------------
    % Comparación de referencia
    % ------------------------------------------------------------------
    Treference_compare = table();

    Treference_compare.case = ["gasLP_reference"; "hybrid_reference"];
    Treference_compare.MR = [gasMR; hybridRefMR];
    Treference_compare.cost_specific_USD_per_kgwater = [gasCost; hybridRefCost];
    Treference_compare.CO2_specific_kgCO2_per_kgwater = [gasCO2; hybridRefCO2];

    % ------------------------------------------------------------------
    % Decisión metodológica preliminar
    % ------------------------------------------------------------------
    runtime_h = NaN;

    if ~isempty(Trun) && ismember('runtime_h',Trun.Properties.VariableNames)
        runtime_h = Trun.runtime_h(1);
    elseif isfield(S1,'elapsed')
        runtime_h = S1.elapsed/3600;
    end

    nFeasible = sum(T.MR_feasible_010);

    if height(Tfeas) > 0
        bestFeasibleCost = min(Tfeas.cost_specific_USD_per_kgwater,[],'omitnan');
        bestFeasibleCO2 = min(Tfeas.CO2_specific_kgCO2_per_kgwater,[],'omitnan');
    else
        bestFeasibleCost = NaN;
        bestFeasibleCO2 = NaN;
    end

    if nFeasible >= 3 && runtime_h > 20
        decision = "DO_NOT_RUN_R2_R3_YET";
        next_step = "Prepare manuscript-level R1 analysis and decide whether R2/R3 are worth ~25 h each.";
    elseif nFeasible >= 3
        decision = "R1_SUFFICIENT_FOR_PRELIMINARY_MANUSCRIPT_TABLES";
        next_step = "Generate R1 Pareto figures and H2-like selected-solution table.";
    else
        decision = "R1_INSUFFICIENT_CONSIDER_R2";
        next_step = "Inspect front quality before deciding R2.";
    end

    diagnosis = "POSTPROCESS_R1_VS_LEGACY_REFERENCE_COMPLETED";

    % ------------------------------------------------------------------
    % Guardar tablas
    % ------------------------------------------------------------------
    r1Csv = fullfile(tablesDir,'POSTPROCESS_R1_v96z_Tsolutions_enriched.csv');
    selectedCsv = fullfile(tablesDir,'POSTPROCESS_R1_v96z_Tselected.csv');
    summaryCsv = fullfile(tablesDir,'POSTPROCESS_R1_v96z_Tsummary.csv');
    refCsv = fullfile(tablesDir,'POSTPROCESS_R1_v96z_Treference_compare.csv');

    writetable(T,r1Csv);
    writetable(Tselected,selectedCsv);
    writetable(Tall_summary,summaryCsv);
    writetable(Treference_compare,refCsv);

    % ------------------------------------------------------------------
    % Reporte Markdown
    % ------------------------------------------------------------------
    reportMd = fullfile(reviewDir,'POSTPROCESS_R1_vs_legacy_reference_v96z.md');

    fid = fopen(reportMd,'w');
    fprintf(fid,'# POSTPROCESS_R1_vs_legacy_reference_v96z\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);

    fprintf(fid,'## R1 run\n\n');
    fprintf(fid,'| item | value |\n');
    fprintf(fid,'|---|---:|\n');

    if isfield(S1,'seed')
        fprintf(fid,'| seed | %d |\n', S1.seed);
    else
        fprintf(fid,'| seed | NaN |\n');
    end

    fprintf(fid,'| runtime_h | %.12g |\n', runtime_h);
    fprintf(fid,'| nSolutions | %d |\n', height(T));
    fprintf(fid,'| nMR_feasible_le_0p1 | %d |\n', nFeasible);
    fprintf(fid,'| best feasible cost | %.12g |\n', bestFeasibleCost);
    fprintf(fid,'| best feasible CO2 | %.12g |\n', bestFeasibleCO2);

    fprintf(fid,'\n## Reference values\n\n');
    fprintf(fid,'| case | MR | cost | CO2 |\n');
    fprintf(fid,'|---|---:|---:|---:|\n');
    for i = 1:height(Treference_compare)
        fprintf(fid,'| `%s` | %.12g | %.12g | %.12g |\n', ...
            Treference_compare.case(i), ...
            Treference_compare.MR(i), ...
            Treference_compare.cost_specific_USD_per_kgwater(i), ...
            Treference_compare.CO2_specific_kgCO2_per_kgwater(i));
    end

    fprintf(fid,'\n## Selected R1 solutions\n\n');
    fprintf(fid,'| selection | idx | MR | cost | CO2 | MR feasible | cost red vs gasLP %% | CO2 red vs gasLP %% | norm L2 |\n');
    fprintf(fid,'|---|---:|---:|---:|---:|---:|---:|---:|---:|\n');

    for i = 1:height(Tselected)
        fprintf(fid,'| `%s` | %d | %.12g | %.12g | %.12g | %d | %.6g | %.6g | %.12g |\n', ...
            Tselected.selection(i), ...
            Tselected.solution_index(i), ...
            Tselected.MR(i), ...
            Tselected.cost_specific_USD_per_kgwater(i), ...
            Tselected.CO2_specific_kgCO2_per_kgwater(i), ...
            Tselected.MR_feasible_010(i), ...
            Tselected.cost_reduction_vs_gasLP_pct(i), ...
            Tselected.CO2_reduction_vs_gasLP_pct(i), ...
            Tselected.norm_L2_all_objectives(i));
    end

    fprintf(fid,'\n## R1 full front\n\n');
    fprintf(fid,'| idx | m_max | T_min | r_div2 | t_rec_ini | MR | cost | CO2 | MR<=0.1 | cost red %% | CO2 red %% |\n');
    fprintf(fid,'|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|\n');

    for i = 1:height(T)
        fprintf(fid,'| %d | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g | %d | %.6g | %.6g |\n', ...
            T.solution_index(i), ...
            T.m_max(i), ...
            T.T_min(i), ...
            T.r_div2(i), ...
            T.t_rec_ini(i), ...
            T.MR(i), ...
            T.cost_specific_USD_per_kgwater(i), ...
            T.CO2_specific_kgCO2_per_kgwater(i), ...
            T.MR_feasible_010(i), ...
            T.cost_reduction_vs_gasLP_pct(i), ...
            T.CO2_reduction_vs_gasLP_pct(i));
    end

    fprintf(fid,'\n## Front summaries\n\n');
    fprintf(fid,'| run | nSolutions | minMR | minCost | minCO2 | nMR<=0.1 |\n');
    fprintf(fid,'|---|---:|---:|---:|---:|---:|\n');

    for i = 1:height(Tall_summary)
        fprintf(fid,'| `%s` | %d | %.12g | %.12g | %.12g | %d |\n', ...
            Tall_summary.run_id(i), ...
            Tall_summary.nSolutions(i), ...
            Tall_summary.minMR(i), ...
            Tall_summary.minCost(i), ...
            Tall_summary.minCO2(i), ...
            Tall_summary.nMR_feasible_010(i));
    end

    fprintf(fid,'\n## Legacy status\n\n');
    fprintf(fid,'`%s`\n\n',legacy_status);
    fprintf(fid,'Legacy MAT: `%s`\n\n',legacyMat);

    fprintf(fid,'## Methodological note\n\n');
    fprintf(fid,'This postprocess does not execute GA. CO2 factors remain provisional for code validation.\n');

    fclose(fid);

    % ------------------------------------------------------------------
    % Guardar MAT
    % ------------------------------------------------------------------
    outMat = fullfile(traceDir,'POSTPROCESS_R1_vs_legacy_reference_v96z.mat');

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'r1Mat','legacy_status','legacyMat', ...
        'T','Tselected','Tall_summary','Treference_compare','Tref','Trun', ...
        'r1Csv','selectedCsv','summaryCsv','refCsv','reportMd','outMat');

    post = struct();
    post.status = 'POSTPROCESS_R1_vs_legacy_reference_v96z_COMPLETED';
    post.diagnosis = diagnosis;
    post.decision = decision;
    post.next_step = next_step;
    post.r1Mat = r1Mat;
    post.legacy_status = legacy_status;
    post.legacyMat = legacyMat;
    post.Tsolutions_enriched = T;
    post.Tselected = Tselected;
    post.Tsummary = Tall_summary;
    post.Treference_compare = Treference_compare;
    post.reportMd = reportMd;
    post.outMat = outMat;

    disp('=== POSTPROCESS_R1_vs_legacy_reference_v96z ===')
    disp(post.status)
    disp('=== DIAGNOSIS ===')
    disp(post.diagnosis)
    disp('=== DECISION ===')
    disp(post.decision)
    disp('=== NEXT STEP ===')
    disp(post.next_step)
    disp('=== SELECTED SOLUTIONS ===')
    disp(post.Tselected)
    disp('=== FRONT SUMMARY ===')
    disp(post.Tsummary)
    disp('=== REFERENCE COMPARE ===')
    disp(post.Treference_compare)
    disp('=== LEGACY STATUS ===')
    disp(post.legacy_status)
    disp(post.legacyMat)
    disp('=== REPORT ===')
    disp(post.reportMd)
end

function val = get_reference_value(T,rowIdx,candidateNames)
    val = NaN;
    for k = 1:numel(candidateNames)
        name = candidateNames{k};
        if ismember(name,T.Properties.VariableNames)
            val = T.(name)(rowIdx);
            return;
        end
    end
end

function Tsummary = summarize_front(T,run_id)
    Tsummary = table();

    Tsummary.run_id = string(run_id);
    Tsummary.nSolutions = height(T);

    if height(T)==0
        Tsummary.minMR = NaN;
        Tsummary.minCost = NaN;
        Tsummary.minCO2 = NaN;
        Tsummary.nMR_feasible_010 = 0;
        return;
    end

    Tsummary.minMR = min(T.MR,[],'omitnan');
    Tsummary.minCost = min(T.cost_specific_USD_per_kgwater,[],'omitnan');
    Tsummary.minCO2 = min(T.CO2_specific_kgCO2_per_kgwater,[],'omitnan');
    Tsummary.nMR_feasible_010 = sum(T.MR <= 0.1);
end

function Tout = add_selection(Tout,T,selectionName,idx)
    if isempty(idx) || isnan(idx) || idx < 1 || idx > height(T)
        return;
    end

    row = T(idx,:);
    row.selection = string(selectionName);
    row = movevars(row,'selection','Before',1);

    if isempty(Tout) || height(Tout)==0
        Tout = row;
    else
        Tout = [Tout; row]; %#ok<AGROW>
    end
end

function mkdir_if_needed(folderPath)
    if ~isfolder(folderPath)
        mkdir(folderPath);
    end
end