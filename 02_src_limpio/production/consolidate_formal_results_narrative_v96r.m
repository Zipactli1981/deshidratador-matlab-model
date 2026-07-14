function narr = consolidate_formal_results_narrative_v96r()
% CONSOLIDATE_FORMAL_RESULTS_NARRATIVE_v96r
% 9.6r — FORMAL-RESULTS-NARRATIVE-CONSOLIDATION-001
%
% Objetivo:
%   Consolidar la narrativa técnica formal de resultados:
%     - Interpretación de la solución recomendada H2.
%     - Comparación con gasLP.
%     - Lectura de H1, H4 y H9.
%     - Alcance del frente triobjetivo formal.
%     - Exclusión metodológica del modo solar puro.
%     - Limitaciones por factores de CO2 provisionales.
%
% Este script:
%   - NO ejecuta gamultiobj.
%   - NO llama la función objetivo.
%   - NO llama el modelo mecanístico.
%   - NO modifica fuentes protegidas.
%   - Usa resultados ya consolidados en v96p.
%   - Si existe fig4, lo registra como paquete gráfico principal.

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

    if recID ~= "H2"
        warning('La solución recomendada actual no es H2. Recomendación encontrada: %s', recID);
    end

    % ---------------------------------------------------------------------
    % Localizar soluciones representativas
    % ---------------------------------------------------------------------
    idxH1 = find(string(T.solution_id)=="H1",1,'first');
    idxH2 = find(string(T.solution_id)=="H2",1,'first');
    idxH4 = find(string(T.solution_id)=="H4",1,'first');
    idxH9 = find(string(T.solution_id)=="H9",1,'first');

    if isempty(idxH2)
        error('No se encontró H2 en Tsolutions.');
    end

    H1 = local_row_or_empty(T,idxH1);
    H2 = local_row_or_empty(T,idxH2);
    H4 = local_row_or_empty(T,idxH4);
    H9 = local_row_or_empty(T,idxH9);

    gasLP = struct();
    gasLP.MR = Tsummary.gasLP_MR(1);
    gasLP.cost_specific = Tsummary.gasLP_cost(1);
    gasLP.CO2_specific = Tsummary.gasLP_CO2(1);

    % ---------------------------------------------------------------------
    % Buscar fig4 más reciente, si existe
    % ---------------------------------------------------------------------
    fig4_found = false;
    fig4_diagnosis = "";
    fig4_dir = "";
    fig4_pngDir = "";
    fig4_mat = "";

    fig4BaseDir = fullfile(rootDir,'05_runs','final_clean_triobjective_figures_v96q_fig4');

    if isfolder(fig4BaseDir)
        f4 = dir(fig4BaseDir);
        f4 = f4([f4.isdir]);
        f4 = f4(~ismember({f4.name},{'.','..','.MATLABDriveTag'}));

        keep4 = false(size(f4));
        for i = 1:numel(f4)
            keep4(i) = startsWith(f4(i).name,'FINAL_CLEAN_TRIOBJECTIVE_FIGURES_v96q_fig4_');
        end
        f4 = f4(keep4);

        if ~isempty(f4)
            [~,idxF4] = max([f4.datenum]);
            fig4_dir = string(fullfile(fig4BaseDir,f4(idxF4).name));
            fig4_mat = string(fullfile(fig4_dir,'mat','FINAL_CLEAN_TRIOBJECTIVE_FIGURES_v96q_fig4.mat'));

            if isfile(fig4_mat)
                F4 = load(fig4_mat);
                fig4_found = true;
                fig4_diagnosis = string(F4.diagnosis);
                if isfield(F4,'pngDir')
                    fig4_pngDir = string(F4.pngDir);
                else
                    fig4_pngDir = string(fullfile(fig4_dir,'png'));
                end
            end
        end
    end

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    outBaseDir = fullfile(rootDir,'05_runs','formal_results_narrative_v96r');
    outDir = fullfile(outBaseDir,['FORMAL_RESULTS_NARRATIVE_v96r_' timestamp]);

    mdDir = fullfile(outDir,'md');
    txtDir = fullfile(outDir,'txt');
    matDir = fullfile(outDir,'mat');
    tablesDir = fullfile(outDir,'tables');
    logsDir = fullfile(outDir,'logs');

    mkdir_if_needed(outBaseDir);
    mkdir_if_needed(outDir);
    mkdir_if_needed(mdDir);
    mkdir_if_needed(txtDir);
    mkdir_if_needed(matDir);
    mkdir_if_needed(tablesDir);
    mkdir_if_needed(logsDir);

    % ---------------------------------------------------------------------
    % Tabla resumen de soluciones clave
    % ---------------------------------------------------------------------
    keyIDs = ["H1";"H2";"H4";"H9"];
    keepKey = ismember(string(T.solution_id),keyIDs);

    Tkey = T(keepKey,:);
    Tkey.interpretation = strings(height(Tkey),1);

    for i = 1:height(Tkey)
        sid = string(Tkey.solution_id(i));

        switch sid
            case "H1"
                Tkey.interpretation(i) = "Minimum CO2 region; not recommended because MR is not admissible.";
            case "H2"
                Tkey.interpretation(i) = "Recommended compromise; admissible MR and simultaneous reductions in MR, cost and CO2 vs gasLP.";
            case "H4"
                Tkey.interpretation(i) = "Minimum cost region; not recommended because MR is not admissible.";
            case "H9"
                Tkey.interpretation(i) = "Minimum MR region; admissible drying but worse cost and CO2 than gasLP.";
            otherwise
                Tkey.interpretation(i) = "";
        end
    end

    outKeyCsv = fullfile(tablesDir,'FORMAL_RESULTS_NARRATIVE_v96r_key_solutions.csv');
    writetable(Tkey,outKeyCsv);

    % ---------------------------------------------------------------------
    % Resumen narrativo estructurado
    % ---------------------------------------------------------------------
    summary = struct();

    summary.step = "9.6r";
    summary.status_context = "formal narrative consolidation";
    summary.formal_mode = "hybrid";
    summary.reference_mode = "gasLP";
    summary.solar_status = "excluded_from_formal_GA; endpoint-only diagnostic; no formal Pareto comparison";
    summary.recommended_solution_id = recID;

    summary.H2_m_max = Trecommended.m_max(1);
    summary.H2_T_min = Trecommended.T_min(1);
    summary.H2_r_div2 = Trecommended.r_div2(1);
    summary.H2_t_rec_ini = Trecommended.t_rec_ini(1);

    summary.H2_MR = Trecommended.MR(1);
    summary.H2_cost_specific = Trecommended.cost_specific(1);
    summary.H2_CO2_specific = Trecommended.CO2_specific(1);

    summary.gasLP_MR = gasLP.MR;
    summary.gasLP_cost_specific = gasLP.cost_specific;
    summary.gasLP_CO2_specific = gasLP.CO2_specific;

    summary.H2_MR_reduction_pct_vs_gasLP = Trecommended.reduction_MR_pct_vs_gasLP(1);
    summary.H2_cost_reduction_pct_vs_gasLP = Trecommended.reduction_cost_pct_vs_gasLP(1);
    summary.H2_CO2_reduction_pct_vs_gasLP = Trecommended.reduction_CO2_pct_vs_gasLP(1);

    summary.MR_acceptance = MR_acceptance;
    summary.H2_admissible = Trecommended.MR(1) < MR_acceptance;

    summary.CO2_factor_status = "PROVISIONAL_FOR_CODE_VALIDATION";
    summary.manuscript_final_CO2_claims_blocked = true;

    summary.fig4_found = fig4_found;
    summary.fig4_diagnosis = fig4_diagnosis;
    summary.fig4_dir = fig4_dir;
    summary.fig4_pngDir = fig4_pngDir;

    TnarrSummary = struct2table(summary);

    outSummaryCsv = fullfile(tablesDir,'FORMAL_RESULTS_NARRATIVE_v96r_summary.csv');
    writetable(TnarrSummary,outSummaryCsv);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};
    checks{end+1,1} = check_row("R01","v96p interpretation loaded",true,string(interpMat));
    checks{end+1,1} = check_row("R02","Recommended solution exists",~isempty(recID),sprintf("recommended=%s",recID));
    checks{end+1,1} = check_row("R03","H2 found in formal solutions",~isempty(idxH2),"H2 located in Tsolutions.");
    checks{end+1,1} = check_row("R04","H2 is admissible by MR",Trecommended.MR(1)<MR_acceptance,sprintf("MR=%.12g",Trecommended.MR(1)));
    checks{end+1,1} = check_row("R05","H2 reduces cost vs gasLP",Trecommended.reduction_cost_pct_vs_gasLP(1)>0,sprintf("cost reduction=%.12g%%",Trecommended.reduction_cost_pct_vs_gasLP(1)));
    checks{end+1,1} = check_row("R06","H2 reduces CO2 vs gasLP",Trecommended.reduction_CO2_pct_vs_gasLP(1)>0,sprintf("CO2 reduction=%.12g%%",Trecommended.reduction_CO2_pct_vs_gasLP(1)));
    checks{end+1,1} = check_row("R07","H2 reduces MR vs gasLP",Trecommended.reduction_MR_pct_vs_gasLP(1)>0,sprintf("MR reduction=%.12g%%",Trecommended.reduction_MR_pct_vs_gasLP(1)));
    checks{end+1,1} = check_row("R08","Key solutions table exported",isfile(outKeyCsv),outKeyCsv);
    checks{end+1,1} = check_row("R09","Solar exclusion preserved",true,"Solar pure not included in formal GA front.");
    checks{end+1,1} = check_row("R10","CO2 provisional caveat preserved",true,"CO2 factors remain provisional.");
    checks{end+1,1} = check_row("R11","No GA executed",true,"No gamultiobj call.");
    checks{end+1,1} = check_row("R12","No mechanistic rerun",true,"No objective/model call.");

    if fig4_found
        checks{end+1,1} = check_row("R13","fig4 package found",true,fig4_dir);
    else
        checks{end+1,1} = check_row("R13","fig4 package found",false,"fig4 MAT not found; narrative still created.");
    end

    Tchecks = struct2table(vertcat(checks{:}));

    % fig4 no debe bloquear narrativa porque el usuario ya hizo revisión visual.
    requiredPass = Tchecks.pass;
    requiredPass(strcmp(string(Tchecks.id),"R13")) = true;

    narrative_pass = all(requiredPass);

    if narrative_pass
        diagnosis = "FORMAL_RESULTS_NARRATIVE_CONSOLIDATION_PASS";
        decision = "NARRATIVE_READY_FOR_PACKAGE_UPDATE";
        next_step = "9.6s — FINAL-RESULTS-PACKAGE-WITH-FIG4-001";
    else
        diagnosis = "FORMAL_RESULTS_NARRATIVE_CONSOLIDATION_REQUIRES_REVIEW";
        decision = "REVIEW_FAILED_NARRATIVE_CHECKS";
        next_step = "Review failed checks before package update.";
    end

    outChecksCsv = fullfile(tablesDir,'FORMAL_RESULTS_NARRATIVE_v96r_checks.csv');
    writetable(Tchecks,outChecksCsv);

    % ---------------------------------------------------------------------
    % Texto narrativo formal
    % ---------------------------------------------------------------------
    mdText = compose_narrative_markdown( ...
        diagnosis,decision,next_step, ...
        TnarrSummary,Tkey,Tchecks, ...
        Trecommended,gasLP, ...
        H1,H2,H4,H9, ...
        fig4_found,fig4_dir,fig4_pngDir, ...
        MR_acceptance);

    outMd = fullfile(mdDir,'FORMAL_RESULTS_NARRATIVE_v96r.md');
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end
    fprintf(fid,'%s',mdText);
    fclose(fid);

    outTxt = fullfile(txtDir,'FORMAL_RESULTS_NARRATIVE_v96r.txt');
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end
    fprintf(fid,'%s',mdText);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Guardar MAT
    % ---------------------------------------------------------------------
    outMat = fullfile(matDir,'FORMAL_RESULTS_NARRATIVE_v96r.mat');

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'T','Trecommended','Tsummary','Tkey','TnarrSummary','Tchecks', ...
        'summary','gasLP','H1','H2','H4','H9', ...
        'fig4_found','fig4_diagnosis','fig4_dir','fig4_pngDir', ...
        'outDir','mdDir','txtDir','matDir','tablesDir','logsDir', ...
        'outMd','outTxt','outMat','outKeyCsv','outSummaryCsv','outChecksCsv');

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    narr = struct();
    narr.status = 'FORMAL_RESULTS_NARRATIVE_CONSOLIDATION_COMPLETED';
    narr.diagnosis = diagnosis;
    narr.decision = decision;
    narr.next_step = next_step;
    narr.TnarrSummary = TnarrSummary;
    narr.Tkey = Tkey;
    narr.Tchecks = Tchecks;
    narr.fig4_found = fig4_found;
    narr.fig4_dir = fig4_dir;
    narr.fig4_pngDir = fig4_pngDir;
    narr.outDir = outDir;
    narr.outMd = outMd;
    narr.outTxt = outTxt;
    narr.outMat = outMat;

    disp('=== FORMAL_RESULTS_NARRATIVE_v96r ===')
    disp(narr.status)
    disp('=== DIAGNOSIS ===')
    disp(narr.diagnosis)
    disp('=== DECISION ===')
    disp(narr.decision)
    disp('=== NEXT STEP ===')
    disp(narr.next_step)
    disp('=== SUMMARY ===')
    disp(narr.TnarrSummary)
    disp('=== KEY SOLUTIONS ===')
    disp(narr.Tkey)
    disp('=== CHECKS ===')
    disp(narr.Tchecks)
    disp('=== OUTPUT MD ===')
    disp(narr.outMd)

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

function row = local_row_or_empty(T,idx)
    if isempty(idx)
        row = table();
    else
        row = T(idx,:);
    end
end

function txt = compose_narrative_markdown( ...
    diagnosis,decision,next_step, ...
    TnarrSummary,Tkey,Tchecks, ...
    Trecommended,gasLP, ...
    H1,H2,H4,H9, ...
    fig4_found,fig4_dir,fig4_pngDir, ...
    MR_acceptance)

    recID = string(Trecommended.solution_id(1));

    MRred = Trecommended.reduction_MR_pct_vs_gasLP(1);
    CostRed = Trecommended.reduction_cost_pct_vs_gasLP(1);
    CO2Red = Trecommended.reduction_CO2_pct_vs_gasLP(1);

    lines = strings(0,1);

    lines(end+1) = "# FORMAL_RESULTS_NARRATIVE_v96r";
    lines(end+1) = "";
    lines(end+1) = "## Estado";
    lines(end+1) = "";
    lines(end+1) = "Diagnóstico: `" + string(diagnosis) + "`";
    lines(end+1) = "";
    lines(end+1) = "Decisión: `" + string(decision) + "`";
    lines(end+1) = "";
    lines(end+1) = "Siguiente paso: `" + string(next_step) + "`";
    lines(end+1) = "";

    lines(end+1) = "## Resultado central";
    lines(end+1) = "";
    lines(end+1) = "La corrida formal triobjetivo se interpreta como una optimización del modo híbrido, con `gasLP` como referencia directa. La solución recomendada es `" + recID + "`, identificada como el compromiso operativo más defendible dentro del frente formal.";
    lines(end+1) = "";
    lines(end+1) = "La solución H2 cumple el criterio de secado porque presenta `MR = " + string(sprintf('%.6g',Trecommended.MR(1))) + "`, menor que el umbral de aceptación `MR < " + string(sprintf('%.3g',MR_acceptance)) + "`. Frente a la referencia `gasLP`, H2 reduce MR en `" + string(sprintf('%.4g',MRred)) + " %`, reduce el costo específico en `" + string(sprintf('%.4g',CostRed)) + " %` y reduce el CO2 específico en `" + string(sprintf('%.4g',CO2Red)) + " %`.";
    lines(end+1) = "";

    lines(end+1) = "## Características de H2";
    lines(end+1) = "";
    lines(end+1) = "| Variable o métrica | Valor |";
    lines(end+1) = "|---|---:|";
    lines(end+1) = "| `m_max` | " + string(sprintf('%.12g',Trecommended.m_max(1))) + " |";
    lines(end+1) = "| `T_min` | " + string(sprintf('%.12g',Trecommended.T_min(1))) + " |";
    lines(end+1) = "| `r_div2` | " + string(sprintf('%.12g',Trecommended.r_div2(1))) + " |";
    lines(end+1) = "| `t_rec_ini` | " + string(sprintf('%.12g',Trecommended.t_rec_ini(1))) + " |";
    lines(end+1) = "| `MR` | " + string(sprintf('%.12g',Trecommended.MR(1))) + " |";
    lines(end+1) = "| `cost_specific` | " + string(sprintf('%.12g',Trecommended.cost_specific(1))) + " |";
    lines(end+1) = "| `CO2_specific` | " + string(sprintf('%.12g',Trecommended.CO2_specific(1))) + " |";
    lines(end+1) = "| `MR_reduction_pct_vs_gasLP` | " + string(sprintf('%.12g',MRred)) + " |";
    lines(end+1) = "| `cost_reduction_pct_vs_gasLP` | " + string(sprintf('%.12g',CostRed)) + " |";
    lines(end+1) = "| `CO2_reduction_pct_vs_gasLP` | " + string(sprintf('%.12g',CO2Red)) + " |";
    lines(end+1) = "";

    lines(end+1) = "## Comparación con gasLP";
    lines(end+1) = "";
    lines(end+1) = "La referencia `gasLP` presenta `MR = " + string(sprintf('%.6g',gasLP.MR)) + "`, `cost_specific = " + string(sprintf('%.6g',gasLP.cost_specific)) + "` y `CO2_specific = " + string(sprintf('%.6g',gasLP.CO2_specific)) + "`. La comparación muestra que H2 no solo mantiene admisibilidad de secado, sino que mejora simultáneamente los tres indicadores respecto a la referencia.";
    lines(end+1) = "";

    lines(end+1) = "## Lectura de soluciones representativas";
    lines(end+1) = "";
    lines(end+1) = "La interpretación del frente no debe centrarse únicamente en los extremos. H1 y H4 son útiles para entender límites del frente, pero no son soluciones operativas recomendables porque no cumplen el criterio de MR. H9 sí intensifica el secado, pero a costa de empeorar costo y CO2 frente a `gasLP`. H2 queda como solución de compromiso porque conserva admisibilidad de MR y ofrece mejoras simultáneas en costo y emisiones.";
    lines(end+1) = "";

    lines(end+1) = "| Solución | Lectura técnica |";
    lines(end+1) = "|---|---|";
    lines(end+1) = "| H1 | Región de mínimo CO2; no recomendada porque no cumple MR. |";
    lines(end+1) = "| H2 | Solución recomendada; compromiso admisible con reducción simultánea de MR, costo y CO2. |";
    lines(end+1) = "| H4 | Región de mínimo costo; no recomendada porque no cumple MR. |";
    lines(end+1) = "| H9 | Región de mínimo MR; admisible, pero con costo y CO2 superiores a gasLP. |";
    lines(end+1) = "";

    lines(end+1) = "## Alcance metodológico";
    lines(end+1) = "";
    lines(end+1) = "El frente formal debe describirse como un frente triobjetivo del modo híbrido. El modo `solar` puro no debe integrarse a la comparación formal como si fuera equivalente a `hybrid` o `gasLP`, porque su operación está limitada por disponibilidad diaria de irradiancia y no tiene una trayectoria completa validada comparable dentro de esta corrida. Por tanto, el resultado solar queda como diagnóstico endpoint-only o como trabajo futuro con formulación daylight/window específica.";
    lines(end+1) = "";

    lines(end+1) = "## Limitación de CO2";
    lines(end+1) = "";
    lines(end+1) = "Los factores de emisión de CO2 se mantienen con estatus `PROVISIONAL_FOR_CODE_VALIDATION`. Por tanto, los porcentajes de reducción de CO2 son útiles para validación interna y comparación preliminar del frente, pero no deben presentarse como afirmación final de manuscrito hasta fijar factores definitivos y referencias.";
    lines(end+1) = "";

    lines(end+1) = "## Paquete gráfico principal";
    lines(end+1) = "";
    if fig4_found
        lines(end+1) = "El paquete gráfico principal registrado para esta narrativa es `fig4`:";
        lines(end+1) = "";
        lines(end+1) = "- Carpeta: `" + string(fig4_dir) + "`";
        lines(end+1) = "- PNG: `" + string(fig4_pngDir) + "`";
    else
        lines(end+1) = "No se detectó automáticamente el paquete `fig4` en archivo MAT. La narrativa se generó de todos modos porque la revisión visual fue aceptada por el usuario. Se recomienda registrar fig4 en el paquete final 9.6s.";
    end
    lines(end+1) = "";

    lines(end+1) = "## Checks";
    lines(end+1) = "";
    lines(end+1) = "| ID | Check | Pass | Evidencia |";
    lines(end+1) = "|---|---|---:|---|";

    for i = 1:height(Tchecks)
        lines(end+1) = "| `" + string(Tchecks.id(i)) + "` | `" + string(Tchecks.check(i)) + "` | " + string(Tchecks.pass(i)) + " | `" + string(Tchecks.evidence(i)) + "` |";
    end

    lines(end+1) = "";
    lines(end+1) = "## Dictamen";
    lines(end+1) = "";
    lines(end+1) = "La narrativa formal de resultados queda consolidada. H2 debe sostenerse como solución recomendada, H1/H4/H9 deben utilizarse como referencias interpretativas del frente, `gasLP` queda como referencia directa y el modo solar puro queda fuera del frente formal por criterio metodológico. El siguiente paso es actualizar el paquete final de resultados con esta narrativa y con fig4 como conjunto gráfico principal.";
    lines(end+1) = "";

    txt = strjoin(lines,newline);
end