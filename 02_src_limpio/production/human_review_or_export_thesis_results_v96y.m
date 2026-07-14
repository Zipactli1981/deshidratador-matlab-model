function hy = human_review_or_export_thesis_results_v96y()
% HUMAN_REVIEW_OR_EXPORT_THESIS_RESULTS_v96y
% 9.6y — THESIS-RESULTS-SECTION-HUMAN-REVIEW-OR-EXPORT-001
%
% Objetivo:
%   Preparar la sección de resultados v2 para revisión humana o exportación.
%
% Este paso:
%   - NO ejecuta GA.
%   - NO llama modelo.
%   - NO llama función objetivo.
%   - NO recalcula resultados.
%   - NO modifica 05_runs.
%   - Trabaja únicamente en 06_manuscript/thesis_ES.
%
% Entregables:
%   - checklist de revisión humana;
%   - copia candidata para integración;
%   - manifiesto de figuras/tablas;
%   - decisión recomendada: revisar unidades antes de exportar.
%
% Uso:
%   hy = human_review_or_export_thesis_results_v96y();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Workspace
    % ---------------------------------------------------------------------
    thesisRoot = fullfile(rootDir,'06_manuscript','thesis_ES');

    if ~isfolder(thesisRoot)
        error('No existe thesisRoot: %s', thesisRoot);
    end

    sectionsDir = fullfile(thesisRoot,'sections');
    figuresDir = fullfile(thesisRoot,'figures');
    figuresPngDir = fullfile(figuresDir,'png');
    figuresPdfDir = fullfile(figuresDir,'pdf');
    tablesDir = fullfile(thesisRoot,'tables');
    traceDir = fullfile(thesisRoot,'traceability');
    notesDir = fullfile(thesisRoot,'notes');
    exportDir = fullfile(thesisRoot,'export_candidates');
    reviewDir = fullfile(thesisRoot,'review');

    mkdir_if_needed(sectionsDir);
    mkdir_if_needed(tablesDir);
    mkdir_if_needed(traceDir);
    mkdir_if_needed(notesDir);
    mkdir_if_needed(exportDir);
    mkdir_if_needed(reviewDir);

    % ---------------------------------------------------------------------
    % Entradas
    % ---------------------------------------------------------------------
    editMat = fullfile(traceDir,'EDIT_THESIS_RESULTS_SECTION_WORKSPACE_v96x.mat');
    sectionV2 = fullfile(sectionsDir,'01_resultados_optimizacion_triobjetivo_v2_editado.md');
    sectionV2Txt = fullfile(sectionsDir,'01_resultados_optimizacion_triobjetivo_v2_editado.txt');
    masterV2 = fullfile(thesisRoot,'TESIS_RESULTADOS_MASTER_v2.md');

    if ~isfile(editMat)
        error('No existe editMat v96x: %s', editMat);
    end

    if ~isfile(sectionV2)
        error('No existe sectionV2: %s', sectionV2);
    end

    if ~isfile(masterV2)
        error('No existe masterV2: %s', masterV2);
    end

    E = load(editMat);

    if ~strcmp(string(E.diagnosis),"EDIT_THESIS_RESULTS_SECTION_WORKSPACE_PASS")
        error('El paso v96x no está en PASS. Diagnosis: %s', string(E.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Texto base
    % ---------------------------------------------------------------------
    sectionText = string(fileread(sectionV2));

    % ---------------------------------------------------------------------
    % Crear copia candidata de integración
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    candidateMd = fullfile(exportDir,['RESULTADOS_OPTIMIZACION_TRIOBJETIVO_CANDIDATE_' timestamp '.md']);
    candidateTxt = fullfile(exportDir,['RESULTADOS_OPTIMIZACION_TRIOBJETIVO_CANDIDATE_' timestamp '.txt']);

    copyfile(sectionV2,candidateMd);

    if isfile(sectionV2Txt)
        copyfile(sectionV2Txt,candidateTxt);
    else
        fid = fopen(candidateTxt,'w');
        fprintf(fid,'%s',sectionText);
        fclose(fid);
    end

    % ---------------------------------------------------------------------
    % Manifestar figuras disponibles
    % ---------------------------------------------------------------------
    figPng = local_list_files(figuresPngDir,'*.png');
    figPdf = local_list_files(figuresPdfDir,'*.pdf');

    Tfigures = table();
    Tfigures.kind = [repmat("png",numel(figPng),1); repmat("pdf",numel(figPdf),1)];
    Tfigures.file = [figPng; figPdf];
    Tfigures.exists = false(height(Tfigures),1);
    Tfigures.size_bytes = zeros(height(Tfigures),1);

    for i = 1:height(Tfigures)
        Tfigures.exists(i) = isfile(Tfigures.file(i));
        if Tfigures.exists(i)
            info = dir(Tfigures.file(i));
            if ~isempty(info)
                Tfigures.size_bytes(i) = info.bytes;
            end
        end
    end

    figuresManifestCsv = fullfile(reviewDir,'review_figures_manifest_v96y.csv');
    writetable(Tfigures,figuresManifestCsv);

    % ---------------------------------------------------------------------
    % Manifestar tablas disponibles
    % ---------------------------------------------------------------------
    tableFiles = local_list_files(tablesDir,'*.csv');

    Ttables = table();
    Ttables.file = tableFiles;
    Ttables.exists = false(height(Ttables),1);
    Ttables.size_bytes = zeros(height(Ttables),1);

    for i = 1:height(Ttables)
        Ttables.exists(i) = isfile(Ttables.file(i));
        if Ttables.exists(i)
            info = dir(Ttables.file(i));
            if ~isempty(info)
                Ttables.size_bytes(i) = info.bytes;
            end
        end
    end

    tablesManifestCsv = fullfile(reviewDir,'review_tables_manifest_v96y.csv');
    writetable(Ttables,tablesManifestCsv);

    % ---------------------------------------------------------------------
    % Checklist de revisión humana
    % ---------------------------------------------------------------------
    Review = table();

    Review.item = [ ...
        "Unidades de costo específico"; ...
        "Unidades de CO2 específico"; ...
        "Definición de MR"; ...
        "Definición de m_max"; ...
        "Definición de T_min"; ...
        "Definición de r_div2"; ...
        "Definición de t_rec_ini"; ...
        "Factores de emisión"; ...
        "Caveat solar"; ...
        "Figuras"; ...
        "Tablas"; ...
        "Coherencia con metodología"; ...
        "Coherencia con conclusiones"; ...
        "Decisión de exportación"];

    Review.status = [ ...
        "pendiente"; ...
        "pendiente"; ...
        "pendiente"; ...
        "pendiente"; ...
        "pendiente"; ...
        "pendiente"; ...
        "pendiente"; ...
        "pendiente"; ...
        "revisar redacción"; ...
        "revisar calidad visual"; ...
        "revisar si se numeran formalmente"; ...
        "pendiente"; ...
        "pendiente"; ...
        "pendiente"];

    Review.required_action = [ ...
        "Confirmar si el costo específico está en USD/kg agua removida u otra unidad."; ...
        "Confirmar si CO2 específico está en kgCO2/kg agua removida u otra unidad."; ...
        "Asegurar que MR esté definida en metodología antes de resultados."; ...
        "Definir o traducir m_max en nomenclatura de tesis."; ...
        "Definir o traducir T_min en nomenclatura de tesis."; ...
        "Definir o traducir r_div2 en nomenclatura de tesis."; ...
        "Definir o traducir t_rec_ini en nomenclatura de tesis."; ...
        "Sustituir factores provisionales por factores definitivos y referencias."; ...
        "Mantener como limitación metodológica, no como resultado negativo."; ...
        "Revisar que las figuras se lean bien al insertarlas en Word/LaTeX."; ...
        "Decidir si Tabla 1 y Tabla 2 quedan como tablas formales o como texto."; ...
        "Verificar que la formulación de objetivos coincida con metodología."; ...
        "Alinear el cierre con las conclusiones del capítulo."; ...
        "Elegir: exportar a Word, integrar a LaTeX o continuar en Markdown."];

    Review.priority = [ ...
        "alta"; ...
        "alta"; ...
        "alta"; ...
        "media"; ...
        "media"; ...
        "media"; ...
        "media"; ...
        "alta"; ...
        "alta"; ...
        "media"; ...
        "media"; ...
        "alta"; ...
        "alta"; ...
        "alta"];

    reviewChecklistCsv = fullfile(reviewDir,'human_review_checklist_v96y.csv');
    writetable(Review,reviewChecklistCsv);

    % ---------------------------------------------------------------------
    % Archivo de revisión humana en Markdown
    % ---------------------------------------------------------------------
    reviewMd = fullfile(reviewDir,'HUMAN_REVIEW_RESULTS_SECTION_v96y.md');

    fid = fopen(reviewMd,'w');
    if fid < 0
        error('No se pudo crear reviewMd: %s', reviewMd);
    end

    fprintf(fid,'# HUMAN_REVIEW_RESULTS_SECTION_v96y\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'La sección `v2_editado` está lista para revisión humana. ');
    fprintf(fid,'No se recomienda exportarla todavía a Word/LaTeX hasta revisar unidades, notación y factores de emisión.\n\n');

    fprintf(fid,'## Archivo principal a revisar\n\n');
    fprintf(fid,'`%s`\n\n', sectionV2);

    fprintf(fid,'## Copia candidata para integración\n\n');
    fprintf(fid,'`%s`\n\n', candidateMd);

    fprintf(fid,'## Checklist\n\n');
    fprintf(fid,'| Item | Estado | Acción requerida | Prioridad |\n');
    fprintf(fid,'|---|---|---|---|\n');

    for i = 1:height(Review)
        fprintf(fid,'| %s | %s | %s | %s |\n', ...
            string(Review.item(i)), ...
            string(Review.status(i)), ...
            string(Review.required_action(i)), ...
            string(Review.priority(i)));
    end

    fprintf(fid,'\n## Decisión recomendada\n\n');
    fprintf(fid,'Ruta recomendada: revisar manualmente unidades y notación antes de exportar. ');
    fprintf(fid,'Después de esa revisión, generar una versión `v3_integrable` y entonces exportar.\n\n');

    fprintf(fid,'## Figuras disponibles\n\n');
    fprintf(fid,'- PNG: `%d`\n', sum(Tfigures.kind=="png"));
    fprintf(fid,'- PDF: `%d`\n\n', sum(Tfigures.kind=="pdf"));

    fprintf(fid,'## Tablas disponibles\n\n');
    fprintf(fid,'- CSV: `%d`\n\n', height(Ttables));

    fprintf(fid,'## Regla de trazabilidad\n\n');
    fprintf(fid,'- `05_runs` permanece congelado.\n');
    fprintf(fid,'- `06_manuscript/thesis_ES` es el espacio editable.\n');
    fprintf(fid,'- Esta revisión no recalcula resultados.\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % Decisión automática
    % ---------------------------------------------------------------------
    decisionText = "HUMAN_REVIEW_REQUIRED_BEFORE_EXPORT";

    decisionMd = fullfile(reviewDir,'EXPORT_DECISION_v96y.md');

    fid = fopen(decisionMd,'w');
    if fid < 0
        error('No se pudo crear decisionMd: %s', decisionMd);
    end

    fprintf(fid,'# EXPORT_DECISION_v96y\n\n');
    fprintf(fid,'Decisión: `%s`\n\n', decisionText);
    fprintf(fid,'Motivo: las unidades de costo específico y CO2 específico, así como los factores de emisión, deben revisarse antes de exportar a documento final.\n\n');
    fprintf(fid,'Siguiente paso recomendado:\n\n');
    fprintf(fid,'`9.6z — THESIS-RESULTS-UNITS-NOTATION-REVIEW-001`\n\n');
    fprintf(fid,'Después de eso:\n\n');
    fprintf(fid,'`9.7a — EXPORT-THESIS-RESULTS-SECTION-TO-DOCX-OR-LATEX-001`\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};
    checks{end+1,1} = check_row("Y01","v96x edit loaded",true,string(editMat));
    checks{end+1,1} = check_row("Y02","v96x diagnosis PASS",strcmp(string(E.diagnosis),"EDIT_THESIS_RESULTS_SECTION_WORKSPACE_PASS"),string(E.diagnosis));
    checks{end+1,1} = check_row("Y03","Section v2 exists",isfile(sectionV2),string(sectionV2));
    checks{end+1,1} = check_row("Y04","Candidate MD created",isfile(candidateMd),string(candidateMd));
    checks{end+1,1} = check_row("Y05","Candidate TXT created",isfile(candidateTxt),string(candidateTxt));
    checks{end+1,1} = check_row("Y06","Review checklist created",isfile(reviewChecklistCsv),string(reviewChecklistCsv));
    checks{end+1,1} = check_row("Y07","Review MD created",isfile(reviewMd),string(reviewMd));
    checks{end+1,1} = check_row("Y08","Export decision created",isfile(decisionMd),string(decisionMd));
    checks{end+1,1} = check_row("Y09","Figures manifest created",isfile(figuresManifestCsv),string(figuresManifestCsv));
    checks{end+1,1} = check_row("Y10","Tables manifest created",isfile(tablesManifestCsv),string(tablesManifestCsv));
    checks{end+1,1} = check_row("Y11","Figures available",sum(Tfigures.exists)>=6,sprintf("nFigures=%d",sum(Tfigures.exists)));
    checks{end+1,1} = check_row("Y12","Tables available",height(Ttables)>=4,sprintf("nTables=%d",height(Ttables)));
    checks{end+1,1} = check_row("Y13","Human review required before export",strcmp(decisionText,"HUMAN_REVIEW_REQUIRED_BEFORE_EXPORT"),decisionText);
    checks{end+1,1} = check_row("Y14","No GA executed",true,"No gamultiobj call.");
    checks{end+1,1} = check_row("Y15","No mechanistic rerun",true,"No objective/model call.");
    checks{end+1,1} = check_row("Y16","No 05_runs modified",true,"Only 06_manuscript review/export candidates written.");

    Tchecks = struct2table(vertcat(checks{:}));

    human_review_pass = all(Tchecks.pass);

    if human_review_pass
        diagnosis = "THESIS_RESULTS_SECTION_HUMAN_REVIEW_PACKAGE_PASS";
        decision = "HUMAN_REVIEW_REQUIRED_BEFORE_EXPORT";
        next_step = "9.6z — THESIS-RESULTS-UNITS-NOTATION-REVIEW-001";
    else
        diagnosis = "THESIS_RESULTS_SECTION_HUMAN_REVIEW_PACKAGE_REQUIRES_REVIEW";
        decision = "REVIEW_FAILED_HUMAN_REVIEW_PACKAGE_CHECKS";
        next_step = "Review failed checks before continuing.";
    end

    checksCsv = fullfile(reviewDir,'human_review_package_checks_v96y.csv');
    writetable(Tchecks,checksCsv);

    % ---------------------------------------------------------------------
    % Guardar MAT
    % ---------------------------------------------------------------------
    humanReviewMat = fullfile(traceDir,'HUMAN_REVIEW_OR_EXPORT_THESIS_RESULTS_v96y.mat');

    save(humanReviewMat, ...
        'diagnosis','decision','next_step', ...
        'rootDir','thesisRoot','sectionsDir','figuresDir','figuresPngDir','figuresPdfDir', ...
        'tablesDir','traceDir','notesDir','exportDir','reviewDir', ...
        'editMat','sectionV2','sectionV2Txt','masterV2', ...
        'candidateMd','candidateTxt','reviewMd','decisionMd', ...
        'figuresManifestCsv','tablesManifestCsv','reviewChecklistCsv','checksCsv','humanReviewMat', ...
        'Tfigures','Ttables','Review','Tchecks','sectionText','decisionText');

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    hy = struct();
    hy.status = 'THESIS_RESULTS_SECTION_HUMAN_REVIEW_OR_EXPORT_COMPLETED';
    hy.diagnosis = diagnosis;
    hy.decision = decision;
    hy.next_step = next_step;

    hy.thesisRoot = thesisRoot;
    hy.sectionV2 = sectionV2;
    hy.candidateMd = candidateMd;
    hy.candidateTxt = candidateTxt;
    hy.reviewMd = reviewMd;
    hy.decisionMd = decisionMd;
    hy.reviewChecklistCsv = reviewChecklistCsv;
    hy.humanReviewMat = humanReviewMat;

    hy.Tfigures = Tfigures;
    hy.Ttables = Ttables;
    hy.Review = Review;
    hy.Tchecks = Tchecks;

    disp('=== HUMAN_REVIEW_OR_EXPORT_THESIS_RESULTS_v96y ===')
    disp(hy.status)
    disp('=== DIAGNOSIS ===')
    disp(hy.diagnosis)
    disp('=== DECISION ===')
    disp(hy.decision)
    disp('=== NEXT STEP ===')
    disp(hy.next_step)
    disp('=== SECTION V2 ===')
    disp(hy.sectionV2)
    disp('=== CANDIDATE MD ===')
    disp(hy.candidateMd)
    disp('=== REVIEW MD ===')
    disp(hy.reviewMd)
    disp('=== EXPORT DECISION ===')
    disp(hy.decisionMd)
    disp('=== REVIEW CHECKLIST ===')
    disp(hy.Review)
    disp('=== CHECKS ===')
    disp(hy.Tchecks)

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

function row = check_row(id, checkName, passVal, evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end