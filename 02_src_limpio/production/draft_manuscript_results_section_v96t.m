function draft = draft_manuscript_results_section_v96t()
% DRAFT_MANUSCRIPT_RESULTS_SECTION_v96t
% 9.6t — MANUSCRIPT-RESULTS-SECTION-DRAFT-001
%
% Objetivo:
%   Redactar una primera versión de la sección de resultados para
%   tesis/artículo a partir del paquete final v96s validado con fig4.
%
% Este script:
%   - NO ejecuta gamultiobj.
%   - NO llama la función objetivo.
%   - NO llama el modelo mecanístico.
%   - NO recalcula resultados.
%   - NO modifica fuentes protegidas.
%   - Usa el paquete final v96s y el ZIP reparado fix2.
%
% Entregables:
%   - Manuscript results section en MD.
%   - Manuscript results section en TXT.
%   - Tabla de correspondencia figura-texto.
%   - Tabla de valores principales.
%   - MAT de trazabilidad.
%
% Uso:
%   draft = draft_manuscript_results_section_v96t();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    MR_acceptance = 0.10;

    % ---------------------------------------------------------------------
    % Localizar paquete final v96s más reciente
    % ---------------------------------------------------------------------
    pkgBaseDir = fullfile(rootDir,'05_runs','final_results_package_with_fig4_v96s');

    if ~isfolder(pkgBaseDir)
        error('No existe pkgBaseDir: %s', pkgBaseDir);
    end

    d = dir(pkgBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'FINAL_RESULTS_PACKAGE_WITH_FIG4_v96s_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró paquete final v96s.');
    end

    [~,idxPkg] = max([d.datenum]);
    pkgDir = fullfile(pkgBaseDir,d(idxPkg).name);

    pkgMat = fullfile(pkgDir,'mat','FINAL_RESULTS_PACKAGE_WITH_FIG4_v96s.mat');

    if ~isfile(pkgMat)
        error('No existe MAT v96s: %s', pkgMat);
    end

    P = load(pkgMat);

    if ~strcmp(string(P.diagnosis),"FINAL_RESULTS_PACKAGE_WITH_FIG4_PASS")
        error('El paquete v96s no está en PASS. Diagnosis: %s', string(P.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Localizar ZIP reparado fix2 más reciente
    % ---------------------------------------------------------------------
    fix2BaseDir = fullfile(pkgDir,'package','zip_repair_fix2');

    fix2_found = false;
    fix2_zip = "";
    fix2_mat = "";
    fix2_diagnosis = "";
    fix2_zip_size = NaN;

    if isfolder(fix2BaseDir)
        fix2MatCandidate = fullfile(fix2BaseDir,'FINAL_RESULTS_PACKAGE_ZIP_REPAIR_v96s_fix2.mat');

        if isfile(fix2MatCandidate)
            Z = load(fix2MatCandidate);
            fix2_mat = string(fix2MatCandidate);
            fix2_diagnosis = string(Z.diagnosis);

            if isfield(Z,'finalZipPath')
                fix2_zip = string(Z.finalZipPath);
            end

            if isfield(Z,'finalZipSizeBytes')
                fix2_zip_size = Z.finalZipSizeBytes;
            end

            fix2_found = strcmp(fix2_diagnosis,"FINAL_RESULTS_PACKAGE_ZIP_REPAIR_FIX2_PASS") && isfile(fix2_zip);
        end
    end

    if ~fix2_found
        warning('No se encontró ZIP fix2 PASS. Se redactará con el paquete v96s, pero debe revisarse el empaquetado.');
    end

    % ---------------------------------------------------------------------
    % Extraer datos principales
    % ---------------------------------------------------------------------
    T = P.T;
    Tkey = P.Tkey;
    Trecommended = P.Trecommended;
    Tsummary = P.Tsummary;
    TfinalSummary = P.TfinalSummary;

    recID = string(Trecommended.solution_id(1));

    if recID ~= "H2"
        warning('La solución recomendada no es H2. Recomendación actual: %s', recID);
    end

    H2 = Trecommended;

    idxH1 = find(string(Tkey.solution_id)=="H1",1,'first');
    idxH2 = find(string(Tkey.solution_id)=="H2",1,'first');
    idxH4 = find(string(Tkey.solution_id)=="H4",1,'first');
    idxH9 = find(string(Tkey.solution_id)=="H9",1,'first');

    H1 = local_row_or_empty(Tkey,idxH1);
    H4 = local_row_or_empty(Tkey,idxH4);
    H9 = local_row_or_empty(Tkey,idxH9);

    gasMR = local_get_scalar(Tsummary,'gasLP_MR');
    gasCost = local_get_scalar(Tsummary,'gasLP_cost');
    gasCO2 = local_get_scalar(Tsummary,'gasLP_CO2');

    MRred = H2.reduction_MR_pct_vs_gasLP(1);
    CostRed = H2.reduction_cost_pct_vs_gasLP(1);
    CO2Red = H2.reduction_CO2_pct_vs_gasLP(1);

    % ---------------------------------------------------------------------
    % Figuras principales fig4 copiadas dentro del paquete v96s
    % ---------------------------------------------------------------------
    figuresPngDir = fullfile(pkgDir,'figures','png');
    figuresPdfDir = fullfile(pkgDir,'figures','pdf');

    figA_png = fullfile(figuresPngDir,'FIG_A_final_triobjective_front_MR_cost_CO2size.png');
    figB_png = fullfile(figuresPngDir,'FIG_B_final_gasLP_vs_H2_percent_reductions.png');
    figC_png = fullfile(figuresPngDir,'FIG_C_final_operating_space_3D_Tmin_rdiv2_trecini.png');

    figA_pdf = fullfile(figuresPdfDir,'FIG_A_final_triobjective_front_MR_cost_CO2size.pdf');
    figB_pdf = fullfile(figuresPdfDir,'FIG_B_final_gasLP_vs_H2_percent_reductions.pdf');
    figC_pdf = fullfile(figuresPdfDir,'FIG_C_final_operating_space_3D_Tmin_rdiv2_trecini.pdf');

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    outBaseDir = fullfile(rootDir,'05_runs','manuscript_results_section_draft_v96t');
    outDir = fullfile(outBaseDir,['MANUSCRIPT_RESULTS_SECTION_DRAFT_v96t_' timestamp]);

    mdDir = fullfile(outDir,'md');
    txtDir = fullfile(outDir,'txt');
    tablesDir = fullfile(outDir,'tables');
    matDir = fullfile(outDir,'mat');
    logsDir = fullfile(outDir,'logs');

    mkdir_if_needed(outBaseDir);
    mkdir_if_needed(outDir);
    mkdir_if_needed(mdDir);
    mkdir_if_needed(txtDir);
    mkdir_if_needed(tablesDir);
    mkdir_if_needed(matDir);
    mkdir_if_needed(logsDir);

    % ---------------------------------------------------------------------
    % Tabla principal para manuscrito
    % ---------------------------------------------------------------------
    manuscriptValues = struct();

    manuscriptValues.solution_id = recID;
    manuscriptValues.m_max = H2.m_max(1);
    manuscriptValues.T_min = H2.T_min(1);
    manuscriptValues.r_div2 = H2.r_div2(1);
    manuscriptValues.t_rec_ini = H2.t_rec_ini(1);

    manuscriptValues.H2_MR = H2.MR(1);
    manuscriptValues.H2_cost_specific = H2.cost_specific(1);
    manuscriptValues.H2_CO2_specific = H2.CO2_specific(1);

    manuscriptValues.gasLP_MR = gasMR;
    manuscriptValues.gasLP_cost_specific = gasCost;
    manuscriptValues.gasLP_CO2_specific = gasCO2;

    manuscriptValues.MR_reduction_pct_vs_gasLP = MRred;
    manuscriptValues.cost_reduction_pct_vs_gasLP = CostRed;
    manuscriptValues.CO2_reduction_pct_vs_gasLP = CO2Red;

    manuscriptValues.MR_acceptance = MR_acceptance;
    manuscriptValues.H2_admissible = H2.MR(1) < MR_acceptance;

    manuscriptValues.CO2_factor_status = "PROVISIONAL_FOR_CODE_VALIDATION";
    manuscriptValues.solar_status = "Excluded from formal Pareto front; endpoint-only diagnostic.";
    manuscriptValues.zip_fix2_verified = fix2_found;
    manuscriptValues.zip_fix2_path = fix2_zip;
    manuscriptValues.zip_fix2_size_bytes = fix2_zip_size;

    TmanuscriptValues = struct2table(manuscriptValues);

    outValuesCsv = fullfile(tablesDir,'MANUSCRIPT_RESULTS_SECTION_v96t_main_values.csv');
    writetable(TmanuscriptValues,outValuesCsv);

    % ---------------------------------------------------------------------
    % Tabla de figuras
    % ---------------------------------------------------------------------
    Tfigures = table();
    Tfigures.figure_id = ["Figure A";"Figure B";"Figure C"];
    Tfigures.proposed_caption = [ ...
        "Triobjective front of the hybrid operating mode. Final moisture ratio and specific cost are shown on the axes, while marker size encodes specific CO2 emissions."; ...
        "Comparison between the direct gasLP reference and the recommended H2 hybrid solution for moisture ratio, specific cost and specific CO2 emissions."; ...
        "Operating decision-space of the formal hybrid solutions using T_min, r_div2 and t_rec_ini. H2 is highlighted as the recommended compromise."];
    Tfigures.png_file = [string(figA_png); string(figB_png); string(figC_png)];
    Tfigures.pdf_file = [string(figA_pdf); string(figB_pdf); string(figC_pdf)];
    Tfigures.exists_png = [isfile(figA_png); isfile(figB_png); isfile(figC_png)];
    Tfigures.exists_pdf = [isfile(figA_pdf); isfile(figB_pdf); isfile(figC_pdf)];

    outFiguresCsv = fullfile(tablesDir,'MANUSCRIPT_RESULTS_SECTION_v96t_figures.csv');
    writetable(Tfigures,outFiguresCsv);

    % ---------------------------------------------------------------------
    % Redactar sección de resultados
    % ---------------------------------------------------------------------
    mdText = compose_results_section_md( ...
        H2,H1,H4,H9,Tkey, ...
        gasMR,gasCost,gasCO2, ...
        MR_acceptance,MRred,CostRed,CO2Red, ...
        Tfigures,fix2_found,fix2_zip,fix2_zip_size);

    outMd = fullfile(mdDir,'MANUSCRIPT_RESULTS_SECTION_DRAFT_v96t.md');

    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end
    fprintf(fid,'%s',mdText);
    fclose(fid);

    outTxt = fullfile(txtDir,'MANUSCRIPT_RESULTS_SECTION_DRAFT_v96t.txt');

    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end
    fprintf(fid,'%s',mdText);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};
    checks{end+1,1} = check_row("T01","v96s package loaded",true,string(pkgMat));
    checks{end+1,1} = check_row("T02","v96s diagnosis PASS",strcmp(string(P.diagnosis),"FINAL_RESULTS_PACKAGE_WITH_FIG4_PASS"),string(P.diagnosis));
    checks{end+1,1} = check_row("T03","fix2 ZIP verified",fix2_found,string(fix2_zip));
    checks{end+1,1} = check_row("T04","Recommended solution preserved",recID=="H2",sprintf("recommended=%s",recID));
    checks{end+1,1} = check_row("T05","H2 admissible by MR",H2.MR(1)<MR_acceptance,sprintf("MR=%.12g",H2.MR(1)));
    checks{end+1,1} = check_row("T06","H2 cost reduction positive",CostRed>0,sprintf("costReduction=%.12g%%",CostRed));
    checks{end+1,1} = check_row("T07","H2 CO2 reduction positive",CO2Red>0,sprintf("CO2Reduction=%.12g%%",CO2Red));
    checks{end+1,1} = check_row("T08","H2 MR reduction positive",MRred>0,sprintf("MRReduction=%.12g%%",MRred));
    checks{end+1,1} = check_row("T09","Figure A exists",isfile(figA_png),string(figA_png));
    checks{end+1,1} = check_row("T10","Figure B exists",isfile(figB_png),string(figB_png));
    checks{end+1,1} = check_row("T11","Figure C exists",isfile(figC_png),string(figC_png));
    checks{end+1,1} = check_row("T12","Manuscript MD created",isfile(outMd),string(outMd));
    checks{end+1,1} = check_row("T13","Manuscript TXT created",isfile(outTxt),string(outTxt));
    checks{end+1,1} = check_row("T14","Main values CSV created",isfile(outValuesCsv),string(outValuesCsv));
    checks{end+1,1} = check_row("T15","Figure table CSV created",isfile(outFiguresCsv),string(outFiguresCsv));
    checks{end+1,1} = check_row("T16","CO2 caveat included",contains(mdText,"PROVISIONAL_FOR_CODE_VALIDATION"),"CO2 caveat found in manuscript text.");
    checks{end+1,1} = check_row("T17","Solar caveat included",contains(mdText,"solar"),"Solar caveat found in manuscript text.");
    checks{end+1,1} = check_row("T18","No GA executed",true,"No gamultiobj call.");
    checks{end+1,1} = check_row("T19","No mechanistic rerun",true,"No objective/model call.");

    Tchecks = struct2table(vertcat(checks{:}));

    draft_pass = all(Tchecks.pass);

    if draft_pass
        diagnosis = "MANUSCRIPT_RESULTS_SECTION_DRAFT_PASS";
        decision = "RESULTS_SECTION_DRAFT_READY_FOR_REVIEW";
        next_step = "Review wording, figure captions and manuscript caveats.";
    else
        diagnosis = "MANUSCRIPT_RESULTS_SECTION_DRAFT_REQUIRES_REVIEW";
        decision = "REVIEW_FAILED_DRAFT_CHECKS";
        next_step = "Review failed checks before using the draft.";
    end

    outChecksCsv = fullfile(tablesDir,'MANUSCRIPT_RESULTS_SECTION_v96t_checks.csv');
    writetable(Tchecks,outChecksCsv);

    % ---------------------------------------------------------------------
    % Guardar MAT
    % ---------------------------------------------------------------------
    outMat = fullfile(matDir,'MANUSCRIPT_RESULTS_SECTION_DRAFT_v96t.mat');

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'T','Tkey','Trecommended','Tsummary','TfinalSummary', ...
        'TmanuscriptValues','Tfigures','Tchecks', ...
        'pkgDir','pkgMat','fix2_found','fix2_zip','fix2_zip_size', ...
        'outDir','mdDir','txtDir','tablesDir','matDir','logsDir', ...
        'outMd','outTxt','outValuesCsv','outFiguresCsv','outChecksCsv');

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    draft = struct();
    draft.status = 'MANUSCRIPT_RESULTS_SECTION_DRAFT_COMPLETED';
    draft.diagnosis = diagnosis;
    draft.decision = decision;
    draft.next_step = next_step;

    draft.pkgDir = pkgDir;
    draft.fix2_found = fix2_found;
    draft.fix2_zip = fix2_zip;
    draft.fix2_zip_size = fix2_zip_size;

    draft.outDir = outDir;
    draft.outMd = outMd;
    draft.outTxt = outTxt;
    draft.outMat = outMat;

    draft.TmanuscriptValues = TmanuscriptValues;
    draft.Tfigures = Tfigures;
    draft.Tchecks = Tchecks;

    disp('=== MANUSCRIPT_RESULTS_SECTION_DRAFT_v96t ===')
    disp(draft.status)
    disp('=== DIAGNOSIS ===')
    disp(draft.diagnosis)
    disp('=== DECISION ===')
    disp(draft.decision)
    disp('=== NEXT STEP ===')
    disp(draft.next_step)
    disp('=== MAIN VALUES ===')
    disp(draft.TmanuscriptValues)
    disp('=== FIGURES ===')
    disp(draft.Tfigures)
    disp('=== CHECKS ===')
    disp(draft.Tchecks)
    disp('=== OUTPUT MD ===')
    disp(draft.outMd)

end

% =========================================================================
% Composition
% =========================================================================

function md = compose_results_section_md( ...
    H2,H1,H4,H9,Tkey, ...
    gasMR,gasCost,gasCO2, ...
    MR_acceptance,MRred,CostRed,CO2Red, ...
    Tfigures,fix2_found,fix2_zip,fix2_zip_size)

    lines = strings(0,1);

    lines(end+1) = "# Results";
    lines(end+1) = "";
    lines(end+1) = "> Draft generated from the validated formal triobjective package. This text is intended as a first manuscript-ready results section and still requires editorial harmonization with the final article or thesis style.";
    lines(end+1) = "";

    lines(end+1) = "## Formal triobjective optimization scope";
    lines(end+1) = "";
    lines(end+1) = "The formal optimization was consolidated for the hybrid operating mode using three objective functions: final moisture ratio (`MR`), specific cost, and specific CO2 emissions. The `gasLP` case was retained as the direct reference case for comparison. The pure solar mode was not incorporated into the formal Pareto-front comparison because its operation is constrained by daily irradiance availability and it was only available as an endpoint diagnostic in the current computational workflow. Therefore, the formal comparison reported in this section is restricted to the hybrid front and the `gasLP` reference.";
    lines(end+1) = "";

    lines(end+1) = "## Pareto-front structure and recommended solution";
    lines(end+1) = "";
    lines(end+1) = "The formal hybrid front contained nine non-penalized solutions. The final selection was not based on a single-objective extreme, but on the admissibility of the drying result and the simultaneous improvement of the economic and environmental indicators. The recommended solution was H2, with the following decision variables:";
    lines(end+1) = "";
    lines(end+1) = "| Variable | Value |";
    lines(end+1) = "|---|---:|";
    lines(end+1) = "| `m_max` | " + string(sprintf('%.6g',H2.m_max(1))) + " |";
    lines(end+1) = "| `T_min` | " + string(sprintf('%.6g',H2.T_min(1))) + " |";
    lines(end+1) = "| `r_div2` | " + string(sprintf('%.6g',H2.r_div2(1))) + " |";
    lines(end+1) = "| `t_rec_ini` | " + string(sprintf('%.6g',H2.t_rec_ini(1))) + " |";
    lines(end+1) = "";
    lines(end+1) = "H2 reached `MR = " + string(sprintf('%.6g',H2.MR(1))) + "`, which is below the admissibility threshold of `MR < " + string(sprintf('%.3g',MR_acceptance)) + "`. Relative to the `gasLP` reference, H2 reduced the final moisture ratio by `" + string(sprintf('%.4g',MRred)) + " %`, the specific cost by `" + string(sprintf('%.4g',CostRed)) + " %`, and the specific CO2 emissions by `" + string(sprintf('%.4g',CO2Red)) + " %`.";
    lines(end+1) = "";

    lines(end+1) = "## Comparison with the gasLP reference";
    lines(end+1) = "";
    lines(end+1) = "The `gasLP` reference produced `MR = " + string(sprintf('%.6g',gasMR)) + "`, a specific cost of `" + string(sprintf('%.6g',gasCost)) + "`, and specific CO2 emissions of `" + string(sprintf('%.6g',gasCO2)) + "`. In contrast, H2 produced `MR = " + string(sprintf('%.6g',H2.MR(1))) + "`, specific cost of `" + string(sprintf('%.6g',H2.cost_specific(1))) + "`, and specific CO2 emissions of `" + string(sprintf('%.6g',H2.CO2_specific(1))) + "`. Thus, H2 provided a simultaneous improvement in drying performance, cost, and CO2 emissions with respect to the direct `gasLP` reference.";
    lines(end+1) = "";
    lines(end+1) = "| Metric | gasLP reference | H2 recommended | Relative change in H2 |";
    lines(end+1) = "|---|---:|---:|---:|";
    lines(end+1) = "| `MR` | " + string(sprintf('%.6g',gasMR)) + " | " + string(sprintf('%.6g',H2.MR(1))) + " | -" + string(sprintf('%.4g',MRred)) + " % |";
    lines(end+1) = "| Specific cost | " + string(sprintf('%.6g',gasCost)) + " | " + string(sprintf('%.6g',H2.cost_specific(1))) + " | -" + string(sprintf('%.4g',CostRed)) + " % |";
    lines(end+1) = "| Specific CO2 | " + string(sprintf('%.6g',gasCO2)) + " | " + string(sprintf('%.6g',H2.CO2_specific(1))) + " | -" + string(sprintf('%.4g',CO2Red)) + " % |";
    lines(end+1) = "";

    lines(end+1) = "## Interpretation of representative solutions";
    lines(end+1) = "";
    lines(end+1) = "The representative solutions show the structure of the trade-off. H1 corresponds to the region of minimum CO2 emissions, but it is not operationally recommended because it does not meet the `MR < 0.1` criterion. H4 corresponds to the minimum-cost region, but it also remains inadmissible by moisture ratio. H9 corresponds to the minimum-MR region; however, although it improves drying intensity, it worsens both specific cost and specific CO2 emissions relative to `gasLP`. H2 is therefore the most defensible compromise because it remains admissible by moisture ratio and improves the three evaluated metrics simultaneously.";
    lines(end+1) = "";
    lines(end+1) = "| Solution | Technical interpretation |";
    lines(end+1) = "|---|---|";

    for i = 1:height(Tkey)
        lines(end+1) = "| `" + string(Tkey.solution_id(i)) + "` | " + string(Tkey.interpretation(i)) + " |";
    end

    lines(end+1) = "";

    lines(end+1) = "## Graphical interpretation";
    lines(end+1) = "";
    lines(end+1) = "Figure A presents the hybrid triobjective front using `MR` and specific cost as the primary axes, with marker size proportional to the specific CO2 emissions. This representation allows the environmental objective to remain visible without overloading the figure with a full three-dimensional objective-space projection. Figure B compares `gasLP` and H2 directly and highlights the percentage reductions in `MR`, specific cost, and specific CO2. Figure C shows the location of the formal solutions in the operating decision-space defined by `T_min`, `r_div2`, and `t_rec_ini`; this figure should be interpreted as a decision-space visualization, not as a response surface.";
    lines(end+1) = "";
    lines(end+1) = "| Figure | Proposed caption |";
    lines(end+1) = "|---|---|";

    for i = 1:height(Tfigures)
        lines(end+1) = "| " + string(Tfigures.figure_id(i)) + " | " + string(Tfigures.proposed_caption(i)) + " |";
    end

    lines(end+1) = "";

    lines(end+1) = "## Methodological limitations";
    lines(end+1) = "";
    lines(end+1) = "The solar-only mode should not be interpreted as part of the same formal Pareto comparison. In the present workflow, solar-only behavior was limited to an endpoint diagnostic and lacked the complete trajectory instrumentation needed for an equivalent daylight-window performance analysis. A dedicated solar analysis would require a separate formulation focused on the finite daily irradiance window and the moisture ratio achieved during that window.";
    lines(end+1) = "";
    lines(end+1) = "The CO2 results retain the status `PROVISIONAL_FOR_CODE_VALIDATION`. Consequently, the CO2 reductions are appropriate for internal comparison of the computational front and for methodological discussion, but final manuscript-level claims require definitive emission factors and corresponding references.";
    lines(end+1) = "";

    lines(end+1) = "## Results-section conclusion";
    lines(end+1) = "";
    lines(end+1) = "The formal triobjective optimization supports H2 as the recommended hybrid operating condition. H2 is not an extreme point of the front; rather, it is the admissible compromise that simultaneously improves drying, cost, and CO2 indicators relative to the `gasLP` reference. H1 and H4 define attractive but moisture-inadmissible economic/environmental extremes, whereas H9 defines the strongest drying point at the expense of cost and emissions. This structure supports the selection of H2 as the operationally balanced solution of the formal hybrid front.";
    lines(end+1) = "";

    lines(end+1) = "## Package traceability";
    lines(end+1) = "";
    if fix2_found
        lines(end+1) = "The validated package ZIP used for this draft was verified by the fix2 repair step:";
        lines(end+1) = "";
        lines(end+1) = "- ZIP: `" + string(fix2_zip) + "`";
        lines(end+1) = "- ZIP size: `" + string(sprintf('%.0f',fix2_zip_size)) + "` bytes";
    else
        lines(end+1) = "Warning: the validated fix2 ZIP was not detected automatically. The text was drafted from the v96s package, but package traceability should be reviewed.";
    end
    lines(end+1) = "";

    md = strjoin(lines,newline);
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

function val = local_get_scalar(T,fieldName)
    if istable(T)
        if ismember(fieldName,T.Properties.VariableNames)
            val = T.(fieldName)(1);
        else
            error('Campo no encontrado en tabla: %s', fieldName);
        end
    elseif isstruct(T)
        if isfield(T,fieldName)
            v = T.(fieldName);
            val = v(1);
        else
            error('Campo no encontrado en struct: %s', fieldName);
        end
    else
        error('Tipo no soportado para local_get_scalar.');
    end
end