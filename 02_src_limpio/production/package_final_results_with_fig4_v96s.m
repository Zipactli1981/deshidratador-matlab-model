function pkg = package_final_results_with_fig4_v96s()
% PACKAGE_FINAL_RESULTS_WITH_FIG4_v96s
% 9.6s — FINAL-RESULTS-PACKAGE-WITH-FIG4-001
%
% Objetivo:
%   Generar paquete final de resultados con:
%     - Narrativa formal v96r.
%     - Figuras fig4 como paquete gráfico principal.
%     - Tabla de soluciones clave H1/H2/H4/H9.
%     - Resumen ejecutivo de H2.
%     - Dictamen técnico final del frente triobjetivo.
%     - Caveat de CO2 provisional.
%     - Caveat metodológico del modo solar puro.
%
% Este script:
%   - NO ejecuta gamultiobj.
%   - NO llama la función objetivo.
%   - NO llama el modelo mecanístico.
%   - NO modifica fuentes protegidas.
%   - Solo consolida/copía resultados ya generados.
%
% Uso:
%   pkg = package_final_results_with_fig4_v96s();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Localizar narrativa v96r más reciente
    % ---------------------------------------------------------------------
    narrBaseDir = fullfile(rootDir,'05_runs','formal_results_narrative_v96r');

    if ~isfolder(narrBaseDir)
        error('No existe narrBaseDir: %s', narrBaseDir);
    end

    dn = dir(narrBaseDir);
    dn = dn([dn.isdir]);
    dn = dn(~ismember({dn.name},{'.','..','.MATLABDriveTag'}));

    keepN = false(size(dn));
    for i = 1:numel(dn)
        keepN(i) = startsWith(dn(i).name,'FORMAL_RESULTS_NARRATIVE_v96r_');
    end
    dn = dn(keepN);

    if isempty(dn)
        error('No se encontró narrativa v96r.');
    end

    [~,idxNarr] = max([dn.datenum]);
    narrDir = fullfile(narrBaseDir,dn(idxNarr).name);
    narrMat = fullfile(narrDir,'mat','FORMAL_RESULTS_NARRATIVE_v96r.mat');

    if ~isfile(narrMat)
        error('No existe MAT v96r: %s', narrMat);
    end

    N = load(narrMat);

    if ~strcmp(string(N.diagnosis),"FORMAL_RESULTS_NARRATIVE_CONSOLIDATION_PASS")
        error('La narrativa v96r no está en PASS. Diagnosis: %s', string(N.diagnosis));
    end

    T = N.T;
    Trecommended = N.Trecommended;
    Tsummary = N.Tsummary;
    Tkey = N.Tkey;
    TnarrSummary = N.TnarrSummary;
    TnarrChecks = N.Tchecks;

    narrMd = string(N.outMd);
    narrTxt = string(N.outTxt);

    if ~isfile(narrMd)
        error('No existe narrativa MD: %s', narrMd);
    end

    if ~isfile(narrTxt)
        error('No existe narrativa TXT: %s', narrTxt);
    end

    % ---------------------------------------------------------------------
    % Localizar fig4
    % ---------------------------------------------------------------------
    fig4_found = false;
    fig4Dir = "";
    fig4PngDir = "";
    fig4PdfDir = "";
    fig4FigDir = "";
    fig4Mat = "";
    fig4Diagnosis = "";

    fig4BaseDir = fullfile(rootDir,'05_runs','final_clean_triobjective_figures_v96q_fig4');

    if isfolder(fig4BaseDir)
        df = dir(fig4BaseDir);
        df = df([df.isdir]);
        df = df(~ismember({df.name},{'.','..','.MATLABDriveTag'}));

        keepF = false(size(df));
        for i = 1:numel(df)
            keepF(i) = startsWith(df(i).name,'FINAL_CLEAN_TRIOBJECTIVE_FIGURES_v96q_fig4_');
        end
        df = df(keepF);

        if ~isempty(df)
            [~,idxF] = max([df.datenum]);
            fig4Dir = string(fullfile(fig4BaseDir,df(idxF).name));
            fig4Mat = string(fullfile(fig4Dir,'mat','FINAL_CLEAN_TRIOBJECTIVE_FIGURES_v96q_fig4.mat'));

            if isfile(fig4Mat)
                F4 = load(fig4Mat);
                fig4_found = true;
                fig4Diagnosis = string(F4.diagnosis);

                if isfield(F4,'pngDir')
                    fig4PngDir = string(F4.pngDir);
                else
                    fig4PngDir = string(fullfile(fig4Dir,'png'));
                end

                if isfield(F4,'pdfDir')
                    fig4PdfDir = string(F4.pdfDir);
                else
                    fig4PdfDir = string(fullfile(fig4Dir,'pdf'));
                end

                if isfield(F4,'figNativeDir')
                    fig4FigDir = string(F4.figNativeDir);
                else
                    fig4FigDir = string(fullfile(fig4Dir,'fig'));
                end
            end
        end
    end

    if ~fig4_found
        error('No se encontró fig4 MAT válido. Ejecuta primero plot_final_clean_triobjective_figures_v96q_fig4.');
    end

    if ~strcmp(fig4Diagnosis,"FINAL_CLEAN_TRIOBJECTIVE_FIGURES_PASS")
        error('fig4 no está en PASS. Diagnosis: %s', fig4Diagnosis);
    end

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    outBaseDir = fullfile(rootDir,'05_runs','final_results_package_with_fig4_v96s');
    outDir = fullfile(outBaseDir,['FINAL_RESULTS_PACKAGE_WITH_FIG4_v96s_' timestamp]);

    mdDir = fullfile(outDir,'md');
    txtDir = fullfile(outDir,'txt');
    matDir = fullfile(outDir,'mat');
    tablesDir = fullfile(outDir,'tables');
    figuresDir = fullfile(outDir,'figures');
    figuresPngDir = fullfile(figuresDir,'png');
    figuresPdfDir = fullfile(figuresDir,'pdf');
    figuresNativeDir = fullfile(figuresDir,'fig');
    logsDir = fullfile(outDir,'logs');
    packageDir = fullfile(outDir,'package');
    payloadDir = fullfile(packageDir,'payload');
    zipDir = fullfile(packageDir,'zip');

    mkdir_if_needed(outBaseDir);
    mkdir_if_needed(outDir);
    mkdir_if_needed(mdDir);
    mkdir_if_needed(txtDir);
    mkdir_if_needed(matDir);
    mkdir_if_needed(tablesDir);
    mkdir_if_needed(figuresDir);
    mkdir_if_needed(figuresPngDir);
    mkdir_if_needed(figuresPdfDir);
    mkdir_if_needed(figuresNativeDir);
    mkdir_if_needed(logsDir);
    mkdir_if_needed(packageDir);
    mkdir_if_needed(payloadDir);
    mkdir_if_needed(zipDir);

    % ---------------------------------------------------------------------
    % Copiar figuras fig4
    % ---------------------------------------------------------------------
    pngFilesSrc = local_list_files(string(fig4PngDir),'*.png');
    pdfFilesSrc = local_list_files(string(fig4PdfDir),'*.pdf');
    figFilesSrc = local_list_files(string(fig4FigDir),'*.fig');

    copiedPng = strings(0,1);
    copiedPdf = strings(0,1);
    copiedFig = strings(0,1);

    for i = 1:numel(pngFilesSrc)
        dst = fullfile(figuresPngDir,local_filename(pngFilesSrc(i)));
        copyfile(pngFilesSrc(i),dst);
        copiedPng(end+1,1) = string(dst); %#ok<AGROW>
    end

    for i = 1:numel(pdfFilesSrc)
        dst = fullfile(figuresPdfDir,local_filename(pdfFilesSrc(i)));
        copyfile(pdfFilesSrc(i),dst);
        copiedPdf(end+1,1) = string(dst); %#ok<AGROW>
    end

    for i = 1:numel(figFilesSrc)
        dst = fullfile(figuresNativeDir,local_filename(figFilesSrc(i)));
        copyfile(figFilesSrc(i),dst);
        copiedFig(end+1,1) = string(dst); %#ok<AGROW>
    end

    % ---------------------------------------------------------------------
    % Tablas finales
    % ---------------------------------------------------------------------
    outAllSolutionsCsv = fullfile(tablesDir,'FINAL_RESULTS_PACKAGE_v96s_all_formal_solutions.csv');
    outKeySolutionsCsv = fullfile(tablesDir,'FINAL_RESULTS_PACKAGE_v96s_key_solutions_H1_H2_H4_H9.csv');
    outNarrSummaryCsv = fullfile(tablesDir,'FINAL_RESULTS_PACKAGE_v96s_narrative_summary.csv');
    outNarrChecksCsv = fullfile(tablesDir,'FINAL_RESULTS_PACKAGE_v96s_narrative_checks.csv');

    writetable(T,outAllSolutionsCsv);
    writetable(Tkey,outKeySolutionsCsv);
    writetable(TnarrSummary,outNarrSummaryCsv);
    writetable(TnarrChecks,outNarrChecksCsv);

    % ---------------------------------------------------------------------
    % Resumen ejecutivo final
    % ---------------------------------------------------------------------
    recID = string(Trecommended.solution_id(1));

    finalSummary = struct();
    finalSummary.step = "9.6s";
    finalSummary.package_status = "final results package with fig4";
    finalSummary.formal_mode = "hybrid";
    finalSummary.reference_mode = "gasLP";
    finalSummary.recommended_solution_id = recID;

    finalSummary.H2_m_max = Trecommended.m_max(1);
    finalSummary.H2_T_min = Trecommended.T_min(1);
    finalSummary.H2_r_div2 = Trecommended.r_div2(1);
    finalSummary.H2_t_rec_ini = Trecommended.t_rec_ini(1);

    finalSummary.H2_MR = Trecommended.MR(1);
    finalSummary.H2_cost_specific = Trecommended.cost_specific(1);
    finalSummary.H2_CO2_specific = Trecommended.CO2_specific(1);

    finalSummary.gasLP_MR = Tsummary.gasLP_MR(1);
    finalSummary.gasLP_cost_specific = Tsummary.gasLP_cost(1);
    finalSummary.gasLP_CO2_specific = Tsummary.gasLP_CO2(1);

    finalSummary.H2_MR_reduction_pct_vs_gasLP = Trecommended.reduction_MR_pct_vs_gasLP(1);
    finalSummary.H2_cost_reduction_pct_vs_gasLP = Trecommended.reduction_cost_pct_vs_gasLP(1);
    finalSummary.H2_CO2_reduction_pct_vs_gasLP = Trecommended.reduction_CO2_pct_vs_gasLP(1);

    finalSummary.MR_acceptance = 0.10;
    finalSummary.H2_admissible = Trecommended.MR(1) < 0.10;

    finalSummary.n_formal_solutions = height(T);
    finalSummary.n_key_solutions = height(Tkey);

    finalSummary.fig4_diagnosis = fig4Diagnosis;
    finalSummary.fig4_source_dir = string(fig4Dir);
    finalSummary.n_png_figures = numel(copiedPng);
    finalSummary.n_pdf_figures = numel(copiedPdf);
    finalSummary.n_fig_native_files = numel(copiedFig);

    finalSummary.solar_status = "excluded_from_formal_GA; endpoint-only diagnostic; no formal Pareto comparison";
    finalSummary.CO2_factor_status = "PROVISIONAL_FOR_CODE_VALIDATION";
    finalSummary.manuscript_final_CO2_claims_blocked = true;

    TfinalSummary = struct2table(finalSummary);

    outFinalSummaryCsv = fullfile(tablesDir,'FINAL_RESULTS_PACKAGE_v96s_final_summary.csv');
    writetable(TfinalSummary,outFinalSummaryCsv);

    % ---------------------------------------------------------------------
    % Dictamen técnico final
    % ---------------------------------------------------------------------
    dictumMd = compose_final_dictum_md(Trecommended,Tsummary,Tkey,fig4Diagnosis,copiedPng);
    outDictumMd = fullfile(mdDir,'FINAL_RESULTS_PACKAGE_v96s_TECHNICAL_DICTUM.md');

    fid = fopen(outDictumMd,'w');
    if fid < 0
        error('No se pudo crear dictamen MD: %s', outDictumMd);
    end
    fprintf(fid,'%s',dictumMd);
    fclose(fid);

    outDictumTxt = fullfile(txtDir,'FINAL_RESULTS_PACKAGE_v96s_TECHNICAL_DICTUM.txt');
    fid = fopen(outDictumTxt,'w');
    if fid < 0
        error('No se pudo crear dictamen TXT: %s', outDictumTxt);
    end
    fprintf(fid,'%s',dictumMd);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Copiar narrativa v96r al paquete
    % ---------------------------------------------------------------------
    outNarrMd = fullfile(mdDir,'FORMAL_RESULTS_NARRATIVE_v96r.md');
    outNarrTxt = fullfile(txtDir,'FORMAL_RESULTS_NARRATIVE_v96r.txt');

    copyfile(narrMd,outNarrMd);
    copyfile(narrTxt,outNarrTxt);

    % ---------------------------------------------------------------------
    % Readme del paquete
    % ---------------------------------------------------------------------
    readmeMd = compose_readme_md( ...
        TfinalSummary, ...
        outDictumMd, ...
        outNarrMd, ...
        outAllSolutionsCsv, ...
        outKeySolutionsCsv, ...
        copiedPng, ...
        copiedPdf);

    outReadmeMd = fullfile(mdDir,'README_FINAL_RESULTS_PACKAGE_v96s.md');

    fid = fopen(outReadmeMd,'w');
    if fid < 0
        error('No se pudo crear README MD: %s', outReadmeMd);
    end
    fprintf(fid,'%s',readmeMd);
    fclose(fid);

    outReadmeTxt = fullfile(txtDir,'README_FINAL_RESULTS_PACKAGE_v96s.txt');

    fid = fopen(outReadmeTxt,'w');
    if fid < 0
        error('No se pudo crear README TXT: %s', outReadmeTxt);
    end
    fprintf(fid,'%s',readmeMd);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};
    checks{end+1,1} = check_row("S01","v96r narrative loaded",true,string(narrMat));
    checks{end+1,1} = check_row("S02","v96r diagnosis PASS",strcmp(string(N.diagnosis),"FORMAL_RESULTS_NARRATIVE_CONSOLIDATION_PASS"),string(N.diagnosis));
    checks{end+1,1} = check_row("S03","fig4 package loaded",fig4_found,string(fig4Mat));
    checks{end+1,1} = check_row("S04","fig4 diagnosis PASS",strcmp(fig4Diagnosis,"FINAL_CLEAN_TRIOBJECTIVE_FIGURES_PASS"),fig4Diagnosis);
    checks{end+1,1} = check_row("S05","PNG figures copied",numel(copiedPng)>=3,sprintf("nPNG=%d",numel(copiedPng)));
    checks{end+1,1} = check_row("S06","PDF figures copied",numel(copiedPdf)>=3,sprintf("nPDF=%d",numel(copiedPdf)));
    checks{end+1,1} = check_row("S07","Key solution table exported",isfile(outKeySolutionsCsv),outKeySolutionsCsv);
    checks{end+1,1} = check_row("S08","All formal solutions table exported",isfile(outAllSolutionsCsv),outAllSolutionsCsv);
    checks{end+1,1} = check_row("S09","Final summary exported",isfile(outFinalSummaryCsv),outFinalSummaryCsv);
    checks{end+1,1} = check_row("S10","Technical dictum created",isfile(outDictumMd),outDictumMd);
    checks{end+1,1} = check_row("S11","README created",isfile(outReadmeMd),outReadmeMd);
    checks{end+1,1} = check_row("S12","H2 preserved",recID=="H2",sprintf("recommended=%s",recID));
    checks{end+1,1} = check_row("S13","H2 admissible",Trecommended.MR(1)<0.10,sprintf("MR=%.12g",Trecommended.MR(1)));
    checks{end+1,1} = check_row("S14","CO2 caveat preserved",true,"CO2 factors remain provisional.");
    checks{end+1,1} = check_row("S15","Solar caveat preserved",true,"Solar pure excluded from formal GA front.");
    checks{end+1,1} = check_row("S16","No GA executed",true,"No gamultiobj call.");
    checks{end+1,1} = check_row("S17","No mechanistic rerun",true,"No objective/model call.");

    Tchecks = struct2table(vertcat(checks{:}));

    package_pass = all(Tchecks.pass);

    if package_pass
        diagnosis = "FINAL_RESULTS_PACKAGE_WITH_FIG4_PASS";
        decision = "FINAL_RESULTS_PACKAGE_READY";
        next_step = "9.6t — MANUSCRIPT-RESULTS-SECTION-DRAFT-001";
    else
        diagnosis = "FINAL_RESULTS_PACKAGE_WITH_FIG4_REQUIRES_REVIEW";
        decision = "REVIEW_FAILED_PACKAGE_CHECKS";
        next_step = "Review failed checks before manuscript drafting.";
    end

    outChecksCsv = fullfile(tablesDir,'FINAL_RESULTS_PACKAGE_v96s_checks.csv');
    writetable(Tchecks,outChecksCsv);

    % ---------------------------------------------------------------------
    % Guardar MAT preliminar
    % ---------------------------------------------------------------------
    outMat = fullfile(matDir,'FINAL_RESULTS_PACKAGE_WITH_FIG4_v96s.mat');

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'T','Trecommended','Tsummary','Tkey','TnarrSummary','TfinalSummary','Tchecks', ...
        'narrDir','narrMat','fig4Dir','fig4Mat','fig4Diagnosis', ...
        'copiedPng','copiedPdf','copiedFig', ...
        'outDir','mdDir','txtDir','matDir','tablesDir','figuresDir','packageDir','payloadDir','zipDir', ...
        'outDictumMd','outDictumTxt','outNarrMd','outNarrTxt','outReadmeMd','outReadmeTxt', ...
        'outAllSolutionsCsv','outKeySolutionsCsv','outFinalSummaryCsv','outNarrSummaryCsv','outNarrChecksCsv','outChecksCsv');

    % ---------------------------------------------------------------------
    % Construir payload para ZIP
    % ---------------------------------------------------------------------
    payloadMdDir = fullfile(payloadDir,'md');
    payloadTxtDir = fullfile(payloadDir,'txt');
    payloadTablesDir = fullfile(payloadDir,'tables');
    payloadFiguresDir = fullfile(payloadDir,'figures');
    payloadPngDir = fullfile(payloadFiguresDir,'png');
    payloadPdfDir = fullfile(payloadFiguresDir,'pdf');
    payloadFigDir = fullfile(payloadFiguresDir,'fig');
    payloadMatDir = fullfile(payloadDir,'mat');

    mkdir_if_needed(payloadMdDir);
    mkdir_if_needed(payloadTxtDir);
    mkdir_if_needed(payloadTablesDir);
    mkdir_if_needed(payloadFiguresDir);
    mkdir_if_needed(payloadPngDir);
    mkdir_if_needed(payloadPdfDir);
    mkdir_if_needed(payloadFigDir);
    mkdir_if_needed(payloadMatDir);

    payloadFiles = strings(0,1);

    payloadFiles = local_copy_and_track(outReadmeMd,payloadMdDir,payloadFiles);
    payloadFiles = local_copy_and_track(outDictumMd,payloadMdDir,payloadFiles);
    payloadFiles = local_copy_and_track(outNarrMd,payloadMdDir,payloadFiles);

    payloadFiles = local_copy_and_track(outReadmeTxt,payloadTxtDir,payloadFiles);
    payloadFiles = local_copy_and_track(outDictumTxt,payloadTxtDir,payloadFiles);
    payloadFiles = local_copy_and_track(outNarrTxt,payloadTxtDir,payloadFiles);

    payloadFiles = local_copy_and_track(outAllSolutionsCsv,payloadTablesDir,payloadFiles);
    payloadFiles = local_copy_and_track(outKeySolutionsCsv,payloadTablesDir,payloadFiles);
    payloadFiles = local_copy_and_track(outNarrSummaryCsv,payloadTablesDir,payloadFiles);
    payloadFiles = local_copy_and_track(outNarrChecksCsv,payloadTablesDir,payloadFiles);
    payloadFiles = local_copy_and_track(outFinalSummaryCsv,payloadTablesDir,payloadFiles);
    payloadFiles = local_copy_and_track(outChecksCsv,payloadTablesDir,payloadFiles);

    payloadFiles = local_copy_and_track(outMat,payloadMatDir,payloadFiles);

    for i = 1:numel(copiedPng)
        payloadFiles = local_copy_and_track(copiedPng(i),payloadPngDir,payloadFiles);
    end

    for i = 1:numel(copiedPdf)
        payloadFiles = local_copy_and_track(copiedPdf(i),payloadPdfDir,payloadFiles);
    end

    for i = 1:numel(copiedFig)
        payloadFiles = local_copy_and_track(copiedFig(i),payloadFigDir,payloadFiles);
    end

    % ---------------------------------------------------------------------
    % ZIP robusto desde carpeta payload
    % ---------------------------------------------------------------------
    zipName = ['FINAL_RESULTS_PACKAGE_WITH_FIG4_v96s_' timestamp '.zip'];
    zipPath = fullfile(zipDir,zipName);

    oldPwd = pwd;
    cleanupObj = onCleanup(@() cd(oldPwd));

    cd(payloadDir);

    relFiles = local_relative_payload_files(payloadDir);

    zip(zipPath,relFiles);

    cd(oldPwd);

    zip_created = isfile(zipPath);

    % Verificar ZIP básico por existencia y tamaño
    zipInfo = dir(zipPath);
    if isempty(zipInfo)
        zipSizeBytes = 0;
    else
        zipSizeBytes = zipInfo.bytes;
    end

    zip_verified = zip_created && zipSizeBytes > 0;

    % ---------------------------------------------------------------------
    % Checks finales ZIP
    % ---------------------------------------------------------------------
    checks2 = Tchecks;
    extra = {};
    extra{end+1,1} = check_row("S18","Payload files prepared",numel(payloadFiles)>=20,sprintf("nPayload=%d",numel(payloadFiles)));
    extra{end+1,1} = check_row("S19","ZIP created",zip_created,zipPath);
    extra{end+1,1} = check_row("S20","ZIP nonempty",zip_verified,sprintf("zipSizeBytes=%d",zipSizeBytes));

    Textra = struct2table(vertcat(extra{:}));
    TchecksFinal = [checks2; Textra];

    package_pass_final = all(TchecksFinal.pass);

    if package_pass_final
        diagnosis = "FINAL_RESULTS_PACKAGE_WITH_FIG4_PASS";
        decision = "FINAL_RESULTS_PACKAGE_READY";
        next_step = "9.6t — MANUSCRIPT-RESULTS-SECTION-DRAFT-001";
    else
        diagnosis = "FINAL_RESULTS_PACKAGE_WITH_FIG4_REQUIRES_REVIEW";
        decision = "REVIEW_FAILED_PACKAGE_CHECKS";
        next_step = "Review failed checks before manuscript drafting.";
    end

    outChecksFinalCsv = fullfile(tablesDir,'FINAL_RESULTS_PACKAGE_v96s_checks_FINAL.csv');
    writetable(TchecksFinal,outChecksFinalCsv);

    % Guardar MAT final con ZIP
    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'T','Trecommended','Tsummary','Tkey','TnarrSummary','TfinalSummary','TchecksFinal', ...
        'narrDir','narrMat','fig4Dir','fig4Mat','fig4Diagnosis', ...
        'copiedPng','copiedPdf','copiedFig', ...
        'outDir','mdDir','txtDir','matDir','tablesDir','figuresDir','packageDir','payloadDir','zipDir', ...
        'outDictumMd','outDictumTxt','outNarrMd','outNarrTxt','outReadmeMd','outReadmeTxt', ...
        'outAllSolutionsCsv','outKeySolutionsCsv','outFinalSummaryCsv','outNarrSummaryCsv','outNarrChecksCsv','outChecksCsv','outChecksFinalCsv', ...
        'payloadFiles','zipPath','zip_created','zipSizeBytes','zip_verified');

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    pkg = struct();
    pkg.status = 'FINAL_RESULTS_PACKAGE_WITH_FIG4_COMPLETED';
    pkg.diagnosis = diagnosis;
    pkg.decision = decision;
    pkg.next_step = next_step;

    pkg.TfinalSummary = TfinalSummary;
    pkg.Tchecks = TchecksFinal;

    pkg.outDir = outDir;
    pkg.mdDir = mdDir;
    pkg.txtDir = txtDir;
    pkg.tablesDir = tablesDir;
    pkg.figuresDir = figuresDir;
    pkg.figuresPngDir = figuresPngDir;
    pkg.figuresPdfDir = figuresPdfDir;
    pkg.figuresNativeDir = figuresNativeDir;

    pkg.outReadmeMd = outReadmeMd;
    pkg.outDictumMd = outDictumMd;
    pkg.outNarrMd = outNarrMd;
    pkg.outMat = outMat;

    pkg.packageDir = packageDir;
    pkg.payloadDir = payloadDir;
    pkg.zipDir = zipDir;
    pkg.zipPath = zipPath;
    pkg.zipSizeBytes = zipSizeBytes;

    disp('=== FINAL_RESULTS_PACKAGE_WITH_FIG4_v96s ===')
    disp(pkg.status)
    disp('=== DIAGNOSIS ===')
    disp(pkg.diagnosis)
    disp('=== DECISION ===')
    disp(pkg.decision)
    disp('=== NEXT STEP ===')
    disp(pkg.next_step)
    disp('=== FINAL SUMMARY ===')
    disp(pkg.TfinalSummary)
    disp('=== CHECKS ===')
    disp(pkg.Tchecks)
    disp('=== OUTPUT DIR ===')
    disp(pkg.outDir)
    disp('=== README ===')
    disp(pkg.outReadmeMd)
    disp('=== TECHNICAL DICTUM ===')
    disp(pkg.outDictumMd)
    disp('=== ZIP ===')
    disp(pkg.zipPath)

end

% =========================================================================
% Helpers
% =========================================================================

function mkdir_if_needed(folderPath)
    if ~isfolder(folderPath)
        mkdir(folderPath);
    end
end

function files = local_list_files(folderPath,pattern)
    files = strings(0,1);

    if ~isfolder(folderPath)
        return
    end

    d = dir(fullfile(folderPath,pattern));
    d = d(~[d.isdir]);

    for i = 1:numel(d)
        files(end+1,1) = string(fullfile(folderPath,d(i).name)); %#ok<AGROW>
    end
end

function name = local_filename(filePath)
    [~,n,e] = fileparts(char(filePath));
    name = [n e];
end

function row = check_row(id, checkName, passVal, evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end

function payloadFiles = local_copy_and_track(srcFile,dstDir,payloadFiles)
    if ~isfile(srcFile)
        error('No existe archivo para payload: %s', srcFile);
    end

    mkdir_if_needed(dstDir);

    dst = fullfile(dstDir,local_filename(srcFile));
    copyfile(srcFile,dst);

    payloadFiles(end+1,1) = string(dst);
end

function relFiles = local_relative_payload_files(payloadDir)
    allFiles = local_recursive_files(payloadDir);
    relFiles = strings(size(allFiles));

    payloadDirChar = char(payloadDir);
    if ~endsWith(payloadDirChar,filesep)
        payloadDirChar = [payloadDirChar filesep];
    end

    for i = 1:numel(allFiles)
        f = char(allFiles(i));
        rel = erase(f,payloadDirChar);
        relFiles(i) = string(rel);
    end
end

function files = local_recursive_files(folderPath)
    files = strings(0,1);

    d = dir(folderPath);

    for i = 1:numel(d)
        name = d(i).name;

        if strcmp(name,'.') || strcmp(name,'..') || strcmp(name,'.MATLABDriveTag')
            continue
        end

        p = fullfile(folderPath,name);

        if d(i).isdir
            sub = local_recursive_files(p);
            files = [files; sub]; %#ok<AGROW>
        else
            files(end+1,1) = string(p); %#ok<AGROW>
        end
    end
end

function md = compose_final_dictum_md(Trecommended,Tsummary,Tkey,fig4Diagnosis,copiedPng)

    recID = string(Trecommended.solution_id(1));

    lines = strings(0,1);

    lines(end+1) = "# FINAL_RESULTS_PACKAGE_v96s — TECHNICAL_DICTUM";
    lines(end+1) = "";
    lines(end+1) = "## Dictamen técnico";
    lines(end+1) = "";
    lines(end+1) = "La corrida formal triobjetivo queda consolidada para el modo híbrido, con `gasLP` como referencia directa. La solución recomendada es `" + recID + "`.";
    lines(end+1) = "";

    lines(end+1) = "H2 es la alternativa operativa más defendible porque cumple simultáneamente tres condiciones: alcanza el criterio de secado, reduce el costo específico y reduce el CO2 específico frente a la referencia `gasLP`.";
    lines(end+1) = "";

    lines(end+1) = "## Solución recomendada H2";
    lines(end+1) = "";
    lines(end+1) = "| Variable/Métrica | Valor |";
    lines(end+1) = "|---|---:|";
    lines(end+1) = "| `m_max` | " + string(sprintf('%.12g',Trecommended.m_max(1))) + " |";
    lines(end+1) = "| `T_min` | " + string(sprintf('%.12g',Trecommended.T_min(1))) + " |";
    lines(end+1) = "| `r_div2` | " + string(sprintf('%.12g',Trecommended.r_div2(1))) + " |";
    lines(end+1) = "| `t_rec_ini` | " + string(sprintf('%.12g',Trecommended.t_rec_ini(1))) + " |";
    lines(end+1) = "| `MR` | " + string(sprintf('%.12g',Trecommended.MR(1))) + " |";
    lines(end+1) = "| `cost_specific` | " + string(sprintf('%.12g',Trecommended.cost_specific(1))) + " |";
    lines(end+1) = "| `CO2_specific` | " + string(sprintf('%.12g',Trecommended.CO2_specific(1))) + " |";
    lines(end+1) = "| `MR_reduction_pct_vs_gasLP` | " + string(sprintf('%.12g',Trecommended.reduction_MR_pct_vs_gasLP(1))) + " |";
    lines(end+1) = "| `cost_reduction_pct_vs_gasLP` | " + string(sprintf('%.12g',Trecommended.reduction_cost_pct_vs_gasLP(1))) + " |";
    lines(end+1) = "| `CO2_reduction_pct_vs_gasLP` | " + string(sprintf('%.12g',Trecommended.reduction_CO2_pct_vs_gasLP(1))) + " |";
    lines(end+1) = "";

    lines(end+1) = "## Referencia gasLP";
    lines(end+1) = "";
    lines(end+1) = "| Métrica | gasLP | H2 |";
    lines(end+1) = "|---|---:|---:|";
    lines(end+1) = "| `MR` | " + string(sprintf('%.12g',Tsummary.gasLP_MR(1))) + " | " + string(sprintf('%.12g',Trecommended.MR(1))) + " |";
    lines(end+1) = "| `cost_specific` | " + string(sprintf('%.12g',Tsummary.gasLP_cost(1))) + " | " + string(sprintf('%.12g',Trecommended.cost_specific(1))) + " |";
    lines(end+1) = "| `CO2_specific` | " + string(sprintf('%.12g',Tsummary.gasLP_CO2(1))) + " | " + string(sprintf('%.12g',Trecommended.CO2_specific(1))) + " |";
    lines(end+1) = "";

    lines(end+1) = "## Interpretación de soluciones clave";
    lines(end+1) = "";
    lines(end+1) = "| Solución | Interpretación |";
    lines(end+1) = "|---|---|";

    for i = 1:height(Tkey)
        lines(end+1) = "| `" + string(Tkey.solution_id(i)) + "` | " + string(Tkey.interpretation(i)) + " |";
    end

    lines(end+1) = "";
    lines(end+1) = "## Figuras principales";
    lines(end+1) = "";
    lines(end+1) = "Paquete gráfico principal: `" + string(fig4Diagnosis) + "`.";
    lines(end+1) = "";

    for i = 1:numel(copiedPng)
        lines(end+1) = "- `" + string(copiedPng(i)) + "`";
    end

    lines(end+1) = "";
    lines(end+1) = "## Restricciones de interpretación";
    lines(end+1) = "";
    lines(end+1) = "El modo solar puro no se integra al frente formal porque no es metodológicamente equivalente a los modos `hybrid` y `gasLP` bajo la formulación formal ejecutada. Su análisis queda como diagnóstico endpoint-only o como trabajo posterior con formulación específica de ventana solar.";
    lines(end+1) = "";
    lines(end+1) = "Los factores de CO2 se mantienen como `PROVISIONAL_FOR_CODE_VALIDATION`. Por ello, los resultados de CO2 son válidos para comparación interna del código y del frente, pero las afirmaciones finales de manuscrito requieren factores definitivos y referencias.";
    lines(end+1) = "";
    lines(end+1) = "## Conclusión";
    lines(end+1) = "";
    lines(end+1) = "H2 debe sostenerse como solución recomendada del frente formal triobjetivo híbrido. H1 y H4 explican extremos ambiental/económico no admisibles por humedad; H9 explica el extremo de secado, pero con penalización económica y ambiental. La comparación principal defendible es H2 frente a `gasLP`.";
    lines(end+1) = "";

    md = strjoin(lines,newline);
end

function md = compose_readme_md(TfinalSummary,outDictumMd,outNarrMd,outAllSolutionsCsv,outKeySolutionsCsv,copiedPng,copiedPdf)

    s = TfinalSummary;

    lines = strings(0,1);

    lines(end+1) = "# FINAL_RESULTS_PACKAGE_WITH_FIG4_v96s";
    lines(end+1) = "";
    lines(end+1) = "## Contenido";
    lines(end+1) = "";
    lines(end+1) = "Este paquete consolida los resultados finales de la corrida formal triobjetivo con el paquete gráfico `fig4` como conjunto principal.";
    lines(end+1) = "";

    lines(end+1) = "## Resultado principal";
    lines(end+1) = "";
    lines(end+1) = "| Campo | Valor |";
    lines(end+1) = "|---|---:|";
    lines(end+1) = "| Solución recomendada | `" + string(s.recommended_solution_id(1)) + "` |";
    lines(end+1) = "| `MR` H2 | " + string(sprintf('%.12g',s.H2_MR(1))) + " |";
    lines(end+1) = "| `cost_specific` H2 | " + string(sprintf('%.12g',s.H2_cost_specific(1))) + " |";
    lines(end+1) = "| `CO2_specific` H2 | " + string(sprintf('%.12g',s.H2_CO2_specific(1))) + " |";
    lines(end+1) = "| Reducción MR vs gasLP (%) | " + string(sprintf('%.12g',s.H2_MR_reduction_pct_vs_gasLP(1))) + " |";
    lines(end+1) = "| Reducción costo vs gasLP (%) | " + string(sprintf('%.12g',s.H2_cost_reduction_pct_vs_gasLP(1))) + " |";
    lines(end+1) = "| Reducción CO2 vs gasLP (%) | " + string(sprintf('%.12g',s.H2_CO2_reduction_pct_vs_gasLP(1))) + " |";
    lines(end+1) = "";

    lines(end+1) = "## Archivos principales";
    lines(end+1) = "";
    lines(end+1) = "- Dictamen técnico: `" + string(outDictumMd) + "`";
    lines(end+1) = "- Narrativa formal v96r: `" + string(outNarrMd) + "`";
    lines(end+1) = "- Tabla completa de soluciones: `" + string(outAllSolutionsCsv) + "`";
    lines(end+1) = "- Tabla de soluciones clave H1/H2/H4/H9: `" + string(outKeySolutionsCsv) + "`";
    lines(end+1) = "";

    lines(end+1) = "## Figuras PNG principales";
    lines(end+1) = "";

    for i = 1:numel(copiedPng)
        lines(end+1) = "- `" + string(copiedPng(i)) + "`";
    end

    lines(end+1) = "";
    lines(end+1) = "## Figuras PDF principales";
    lines(end+1) = "";

    for i = 1:numel(copiedPdf)
        lines(end+1) = "- `" + string(copiedPdf(i)) + "`";
    end

    lines(end+1) = "";
    lines(end+1) = "## Caveats";
    lines(end+1) = "";
    lines(end+1) = "- El modo solar puro queda excluido del frente formal.";
    lines(end+1) = "- Los factores de CO2 siguen como `PROVISIONAL_FOR_CODE_VALIDATION`.";
    lines(end+1) = "- No se ejecutó GA ni simulación mecanística en este paso.";
    lines(end+1) = "";

    md = strjoin(lines,newline);
end