function mw = create_manuscript_integration_workspace_v96w()
% CREATE_MANUSCRIPT_INTEGRATION_WORKSPACE_v96w
% 9.6w — MANUSCRIPT-INTEGRATION-WORKSPACE-001
%
% Objetivo:
%   Crear una carpeta limpia de integración de manuscrito para tesis:
%
%       06_manuscript/thesis_ES/
%
%   Copia ahí:
%     - sección final en español para tesis;
%     - figuras finales PNG/PDF;
%     - tablas mínimas;
%     - reporte de trazabilidad;
%     - README operativo.
%
% Este script:
%   - NO ejecuta GA.
%   - NO llama modelo.
%   - NO llama función objetivo.
%   - NO recalcula resultados.
%   - NO modifica fuentes protegidas.
%
% Regla:
%   05_runs       = evidencia/trazabilidad computacional.
%   06_manuscript = escritura final editable.
%
% Uso:
%   mw = create_manuscript_integration_workspace_v96w();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Localizar sección final v96v_ES más reciente
    % ---------------------------------------------------------------------
    finalBaseDir = fullfile(rootDir,'05_runs','final_spanish_thesis_results_section_v96v_ES');

    if ~isfolder(finalBaseDir)
        error('No existe finalBaseDir: %s', finalBaseDir);
    end

    d = dir(finalBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró sección final v96v_ES.');
    end

    [~,idxFinal] = max([d.datenum]);
    finalDir = fullfile(finalBaseDir,d(idxFinal).name);

    finalMat = fullfile(finalDir,'mat','FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES.mat');
    finalMd  = fullfile(finalDir,'md','FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES.md');
    finalTxt = fullfile(finalDir,'txt','FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES.txt');
    closeMd  = fullfile(finalDir,'logs','FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES_CLOSE_REPORT.md');

    if ~isfile(finalMat)
        error('No existe MAT final v96v_ES: %s', finalMat);
    end

    if ~isfile(finalMd)
        error('No existe MD final v96v_ES: %s', finalMd);
    end

    F = load(finalMat);

    if ~strcmp(string(F.diagnosis),"FINAL_SPANISH_THESIS_RESULTS_SECTION_PASS")
        error('La sección final v96v_ES no está en PASS. Diagnosis: %s', string(F.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Crear workspace limpio de manuscrito
    % ---------------------------------------------------------------------
    manuscriptRoot = fullfile(rootDir,'06_manuscript');
    thesisRoot = fullfile(manuscriptRoot,'thesis_ES');

    sectionsDir = fullfile(thesisRoot,'sections');
    figuresDir = fullfile(thesisRoot,'figures');
    figuresPngDir = fullfile(figuresDir,'png');
    figuresPdfDir = fullfile(figuresDir,'pdf');
    tablesDir = fullfile(thesisRoot,'tables');
    traceDir = fullfile(thesisRoot,'traceability');
    refsDir = fullfile(thesisRoot,'refs');
    notesDir = fullfile(thesisRoot,'notes');

    mkdir_if_needed(manuscriptRoot);
    mkdir_if_needed(thesisRoot);
    mkdir_if_needed(sectionsDir);
    mkdir_if_needed(figuresDir);
    mkdir_if_needed(figuresPngDir);
    mkdir_if_needed(figuresPdfDir);
    mkdir_if_needed(tablesDir);
    mkdir_if_needed(traceDir);
    mkdir_if_needed(refsDir);
    mkdir_if_needed(notesDir);

    % ---------------------------------------------------------------------
    % Copiar sección final editable
    % ---------------------------------------------------------------------
    sectionMdOut = fullfile(sectionsDir,'01_resultados_optimizacion_triobjetivo_v1.md');
    sectionTxtOut = fullfile(sectionsDir,'01_resultados_optimizacion_triobjetivo_v1.txt');

    copyfile(finalMd,sectionMdOut);
    copyfile(finalTxt,sectionTxtOut);

    % ---------------------------------------------------------------------
    % Copiar figuras finales con nombres de tesis
    % ---------------------------------------------------------------------
    Tfig = F.TfinalFigures;

    figCopyRows = {};

    for i = 1:height(Tfig)
        label = string(Tfig.final_label(i));

        switch label
            case "Figura 1"
                baseName = "Figura_1_frente_triobjetivo_hibrido";
            case "Figura 2"
                baseName = "Figura_2_gasLP_vs_H2";
            case "Figura 3"
                baseName = "Figura_3_espacio_operativo_hibrido";
            otherwise
                baseName = "Figura_" + string(i);
        end

        srcPng = string(Tfig.png_file(i));
        srcPdf = string(Tfig.pdf_file(i));

        dstPng = fullfile(figuresPngDir,baseName + ".png");
        dstPdf = fullfile(figuresPdfDir,baseName + ".pdf");

        pngCopied = false;
        pdfCopied = false;

        if isfile(srcPng)
            copyfile(srcPng,dstPng);
            pngCopied = isfile(dstPng);
        end

        if isfile(srcPdf)
            copyfile(srcPdf,dstPdf);
            pdfCopied = isfile(dstPdf);
        end

        row = struct();
        row.final_label = label;
        row.source_png = srcPng;
        row.source_pdf = srcPdf;
        row.dest_png = string(dstPng);
        row.dest_pdf = string(dstPdf);
        row.png_copied = pngCopied;
        row.pdf_copied = pdfCopied;
        row.caption = string(Tfig.caption(i));

        figCopyRows{end+1,1} = row; %#ok<AGROW>
    end

    TfigureCopies = struct2table(vertcat(figCopyRows{:}));

    figureCopiesCsv = fullfile(tablesDir,'figure_copy_manifest.csv');
    writetable(TfigureCopies,figureCopiesCsv);

    % ---------------------------------------------------------------------
    % Copiar tablas mínimas desde v96v_ES
    % ---------------------------------------------------------------------
    srcTablesDir = fullfile(finalDir,'tables');

    tableFilesWanted = [ ...
        "FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES_values.csv"; ...
        "FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES_figures.csv"; ...
        "FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES_key_solutions.csv"; ...
        "FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES_checks.csv"];

    tableManifestRows = {};

    for i = 1:numel(tableFilesWanted)
        src = fullfile(srcTablesDir,tableFilesWanted(i));

        switch tableFilesWanted(i)
            case "FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES_values.csv"
                dstName = "resultados_valores_principales.csv";
            case "FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES_figures.csv"
                dstName = "figuras_finales.csv";
            case "FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES_key_solutions.csv"
                dstName = "soluciones_clave_H1_H2_H4_H9.csv";
            case "FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES_checks.csv"
                dstName = "checks_seccion_resultados.csv";
            otherwise
                dstName = tableFilesWanted(i);
        end

        dst = fullfile(tablesDir,dstName);

        copied = false;

        if isfile(src)
            copyfile(src,dst);
            copied = isfile(dst);
        end

        row = struct();
        row.source_file = string(src);
        row.dest_file = string(dst);
        row.copied = copied;

        tableManifestRows{end+1,1} = row; %#ok<AGROW>
    end

    TtableCopies = struct2table(vertcat(tableManifestRows{:}));

    tableCopiesCsv = fullfile(tablesDir,'table_copy_manifest.csv');
    writetable(TtableCopies,tableCopiesCsv);

    % ---------------------------------------------------------------------
    % Copiar trazabilidad
    % ---------------------------------------------------------------------
    traceFinalMat = fullfile(traceDir,'FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES.mat');
    traceCloseMd = fullfile(traceDir,'FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES_CLOSE_REPORT.md');

    copyfile(finalMat,traceFinalMat);

    if isfile(closeMd)
        copyfile(closeMd,traceCloseMd);
    end

    % ---------------------------------------------------------------------
    % Crear notas editoriales
    % ---------------------------------------------------------------------
    editingNotesMd = fullfile(notesDir,'NOTAS_EDICION_RESULTADOS.md');

    fid = fopen(editingNotesMd,'w');
    if fid < 0
        error('No se pudo crear notas editoriales: %s', editingNotesMd);
    end

    fprintf(fid,'# Notas de edición — Resultados de optimización triobjetivo\n\n');
    fprintf(fid,'## Archivo editable principal\n\n');
    fprintf(fid,'Editar este archivo:\n\n');
    fprintf(fid,'`sections/01_resultados_optimizacion_triobjetivo_v1.md`\n\n');

    fprintf(fid,'## Reglas editoriales\n\n');
    fprintf(fid,'- Mantener `gas LP` en narrativa.\n');
    fprintf(fid,'- Mantener `gasLP` solo como etiqueta de código o referencia interna si es necesario.\n');
    fprintf(fid,'- Mantener H2 como solución de compromiso, no como óptimo universal.\n');
    fprintf(fid,'- No afirmar conclusiones finales de CO2 hasta fijar factores de emisión con referencias.\n');
    fprintf(fid,'- Mantener la exclusión solar como limitación metodológica, no como desventaja tecnológica.\n');
    fprintf(fid,'- Usar Figura 1, Figura 2 y Figura 3 en tesis.\n\n');

    fprintf(fid,'## Pendientes antes de integrar al documento completo\n\n');
    fprintf(fid,'1. Revisar unidades de costo específico y CO2 específico.\n');
    fprintf(fid,'2. Homologar notación con la sección de metodología.\n');
    fprintf(fid,'3. Insertar figuras en el formato final de tesis.\n');
    fprintf(fid,'4. Confirmar factores de emisión definitivos.\n');
    fprintf(fid,'5. Revisar si la tabla comparativa gas LP vs H2 se queda en texto o como tabla formal numerada.\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % README del workspace
    % ---------------------------------------------------------------------
    readmeMd = fullfile(thesisRoot,'README_THESIS_ES_WORKSPACE.md');

    fid = fopen(readmeMd,'w');
    if fid < 0
        error('No se pudo crear README: %s', readmeMd);
    end

    fprintf(fid,'# Workspace de manuscrito — tesis ES\n\n');

    fprintf(fid,'## Propósito\n\n');
    fprintf(fid,'Esta carpeta contiene la versión editable de la sección de resultados para tesis. ');
    fprintf(fid,'La evidencia computacional original permanece en `05_runs`.\n\n');

    fprintf(fid,'## Regla de uso\n\n');
    fprintf(fid,'- `05_runs` = evidencia, trazabilidad, resultados congelados.\n');
    fprintf(fid,'- `06_manuscript/thesis_ES` = escritura final editable.\n');
    fprintf(fid,'- `02_src_limpio/production` = scripts, no manuscrito.\n\n');

    fprintf(fid,'## Archivo principal a editar\n\n');
    fprintf(fid,'`sections/01_resultados_optimizacion_triobjetivo_v1.md`\n\n');

    fprintf(fid,'## Figuras\n\n');
    fprintf(fid,'- `figures/png/Figura_1_frente_triobjetivo_hibrido.png`\n');
    fprintf(fid,'- `figures/png/Figura_2_gasLP_vs_H2.png`\n');
    fprintf(fid,'- `figures/png/Figura_3_espacio_operativo_hibrido.png`\n');
    fprintf(fid,'- También están disponibles en PDF dentro de `figures/pdf/`.\n\n');

    fprintf(fid,'## Tablas\n\n');
    fprintf(fid,'- `tables/resultados_valores_principales.csv`\n');
    fprintf(fid,'- `tables/figuras_finales.csv`\n');
    fprintf(fid,'- `tables/soluciones_clave_H1_H2_H4_H9.csv`\n');
    fprintf(fid,'- `tables/checks_seccion_resultados.csv`\n\n');

    fprintf(fid,'## Trazabilidad\n\n');
    fprintf(fid,'La carpeta `traceability/` contiene el MAT y reporte de cierre del paso `9.6v-ES`.\n\n');

    fprintf(fid,'## Resultado principal\n\n');
    fprintf(fid,'Solución recomendada: H2.\n\n');
    fprintf(fid,'- MR H2: %.12g\n', F.TfinalValues.H2_MR(1));
    fprintf(fid,'- Costo específico H2: %.12g\n', F.TfinalValues.H2_cost_specific(1));
    fprintf(fid,'- CO2 específico H2: %.12g\n', F.TfinalValues.H2_CO2_specific(1));
    fprintf(fid,'- Reducción MR vs gas LP: %.12g %%\n', F.TfinalValues.MR_reduction_pct_vs_gasLP(1));
    fprintf(fid,'- Reducción costo vs gas LP: %.12g %%\n', F.TfinalValues.cost_reduction_pct_vs_gasLP(1));
    fprintf(fid,'- Reducción CO2 vs gas LP: %.12g %%\n\n', F.TfinalValues.CO2_reduction_pct_vs_gasLP(1));

    fprintf(fid,'## Advertencias metodológicas\n\n');
    fprintf(fid,'- CO2 sigue como comparación preliminar hasta fijar factores de emisión definitivos.\n');
    fprintf(fid,'- El modo solar puro queda fuera del frente formal y requiere formulación de ventana solar.\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % Crear índice maestro simple
    % ---------------------------------------------------------------------
    masterMd = fullfile(thesisRoot,'TESIS_RESULTADOS_MASTER.md');

    fid = fopen(masterMd,'w');
    if fid < 0
        error('No se pudo crear master MD: %s', masterMd);
    end

    fprintf(fid,'# Resultados — tesis\n\n');
    fprintf(fid,'> Archivo maestro de integración. Puede usarse como punto de partida para copiar a Word, LaTeX o el documento principal.\n\n');
    fprintf(fid,'<!-- INCLUDE: sections/01_resultados_optimizacion_triobjetivo_v1.md -->\n\n');

    sectionText = fileread(sectionMdOut);
    fprintf(fid,'%s\n',sectionText);

    fclose(fid);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};
    checks{end+1,1} = check_row("W01","v96v_ES loaded",true,string(finalMat));
    checks{end+1,1} = check_row("W02","v96v_ES diagnosis PASS",strcmp(string(F.diagnosis),"FINAL_SPANISH_THESIS_RESULTS_SECTION_PASS"),string(F.diagnosis));
    checks{end+1,1} = check_row("W03","Manuscript root created",isfolder(manuscriptRoot),string(manuscriptRoot));
    checks{end+1,1} = check_row("W04","Thesis workspace created",isfolder(thesisRoot),string(thesisRoot));
    checks{end+1,1} = check_row("W05","Editable MD copied",isfile(sectionMdOut),string(sectionMdOut));
    checks{end+1,1} = check_row("W06","Editable TXT copied",isfile(sectionTxtOut),string(sectionTxtOut));
    checks{end+1,1} = check_row("W07","All PNG figures copied",all(TfigureCopies.png_copied),sprintf("nPNG=%d",sum(TfigureCopies.png_copied)));
    checks{end+1,1} = check_row("W08","All PDF figures copied",all(TfigureCopies.pdf_copied),sprintf("nPDF=%d",sum(TfigureCopies.pdf_copied)));
    checks{end+1,1} = check_row("W09","Required tables copied",all(TtableCopies.copied),sprintf("nTables=%d",sum(TtableCopies.copied)));
    checks{end+1,1} = check_row("W10","Traceability MAT copied",isfile(traceFinalMat),string(traceFinalMat));
    checks{end+1,1} = check_row("W11","Traceability close report copied",isfile(traceCloseMd),string(traceCloseMd));
    checks{end+1,1} = check_row("W12","README created",isfile(readmeMd),string(readmeMd));
    checks{end+1,1} = check_row("W13","Editing notes created",isfile(editingNotesMd),string(editingNotesMd));
    checks{end+1,1} = check_row("W14","Master MD created",isfile(masterMd),string(masterMd));
    checks{end+1,1} = check_row("W15","No GA executed",true,"No gamultiobj call.");
    checks{end+1,1} = check_row("W16","No mechanistic rerun",true,"No objective/model call.");
    checks{end+1,1} = check_row("W17","No source files modified",true,"Only 06_manuscript written.");

    Tchecks = struct2table(vertcat(checks{:}));

    workspace_pass = all(Tchecks.pass);

    if workspace_pass
        diagnosis = "MANUSCRIPT_INTEGRATION_WORKSPACE_PASS";
        decision = "THESIS_ES_WORKSPACE_READY";
        next_step = "9.6x — EDIT-THESIS-RESULTS-SECTION-IN-WORKSPACE-001";
    else
        diagnosis = "MANUSCRIPT_INTEGRATION_WORKSPACE_REQUIRES_REVIEW";
        decision = "REVIEW_FAILED_WORKSPACE_CHECKS";
        next_step = "Review failed checks before editing thesis workspace.";
    end

    checksCsv = fullfile(thesisRoot,'workspace_checks.csv');
    writetable(Tchecks,checksCsv);

    % ---------------------------------------------------------------------
    % Guardar MAT de workspace
    % ---------------------------------------------------------------------
    workspaceMat = fullfile(traceDir,'MANUSCRIPT_INTEGRATION_WORKSPACE_v96w.mat');

    save(workspaceMat, ...
        'diagnosis','decision','next_step', ...
        'rootDir','finalDir','finalMat','finalMd','finalTxt','closeMd', ...
        'manuscriptRoot','thesisRoot','sectionsDir','figuresDir','figuresPngDir','figuresPdfDir', ...
        'tablesDir','traceDir','refsDir','notesDir', ...
        'sectionMdOut','sectionTxtOut','readmeMd','editingNotesMd','masterMd', ...
        'TfigureCopies','TtableCopies','Tchecks', ...
        'figureCopiesCsv','tableCopiesCsv','checksCsv','traceFinalMat','traceCloseMd','workspaceMat');

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    mw = struct();
    mw.status = 'MANUSCRIPT_INTEGRATION_WORKSPACE_COMPLETED';
    mw.diagnosis = diagnosis;
    mw.decision = decision;
    mw.next_step = next_step;

    mw.manuscriptRoot = manuscriptRoot;
    mw.thesisRoot = thesisRoot;
    mw.sectionMdOut = sectionMdOut;
    mw.sectionTxtOut = sectionTxtOut;
    mw.masterMd = masterMd;
    mw.readmeMd = readmeMd;
    mw.editingNotesMd = editingNotesMd;
    mw.workspaceMat = workspaceMat;

    mw.TfigureCopies = TfigureCopies;
    mw.TtableCopies = TtableCopies;
    mw.Tchecks = Tchecks;

    disp('=== MANUSCRIPT_INTEGRATION_WORKSPACE_v96w ===')
    disp(mw.status)
    disp('=== DIAGNOSIS ===')
    disp(mw.diagnosis)
    disp('=== DECISION ===')
    disp(mw.decision)
    disp('=== NEXT STEP ===')
    disp(mw.next_step)
    disp('=== THESIS WORKSPACE ===')
    disp(mw.thesisRoot)
    disp('=== EDITABLE SECTION ===')
    disp(mw.sectionMdOut)
    disp('=== MASTER MD ===')
    disp(mw.masterMd)
    disp('=== README ===')
    disp(mw.readmeMd)
    disp('=== FIGURE COPIES ===')
    disp(mw.TfigureCopies)
    disp('=== TABLE COPIES ===')
    disp(mw.TtableCopies)
    disp('=== CHECKS ===')
    disp(mw.Tchecks)

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