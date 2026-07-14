function edrev = editorial_review_results_section_v96u()
% EDITORIAL_REVIEW_RESULTS_SECTION_v96u
% 9.6u — EDITORIAL-RESULTS-SECTION-REVIEW-001
%
% Objetivo:
%   Revisar editorialmente el borrador de resultados v96t:
%     - idioma final;
%     - estilo tesis/artículo;
%     - numeración de figuras;
%     - captions definitivos;
%     - uso de gasLP vs gas LP;
%     - caveat de CO2;
%     - caveat solar;
%     - recomendaciones de mejora antes de integrar al manuscrito.
%
% Este script:
%   - NO ejecuta GA.
%   - NO llama modelo.
%   - NO llama función objetivo.
%   - NO recalcula resultados.
%   - NO modifica fuentes protegidas.
%   - Lee el borrador v96t y genera revisión editorial.
%
% Uso:
%   edrev = editorial_review_results_section_v96u();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Localizar borrador v96t más reciente
    % ---------------------------------------------------------------------
    draftBaseDir = fullfile(rootDir,'05_runs','manuscript_results_section_draft_v96t');

    if ~isfolder(draftBaseDir)
        error('No existe draftBaseDir: %s', draftBaseDir);
    end

    d = dir(draftBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'MANUSCRIPT_RESULTS_SECTION_DRAFT_v96t_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró borrador v96t.');
    end

    [~,idxDraft] = max([d.datenum]);
    draftDir = fullfile(draftBaseDir,d(idxDraft).name);

    draftMat = fullfile(draftDir,'mat','MANUSCRIPT_RESULTS_SECTION_DRAFT_v96t.mat');
    draftMd = fullfile(draftDir,'md','MANUSCRIPT_RESULTS_SECTION_DRAFT_v96t.md');
    draftTxt = fullfile(draftDir,'txt','MANUSCRIPT_RESULTS_SECTION_DRAFT_v96t.txt');

    if ~isfile(draftMat)
        error('No existe MAT v96t: %s', draftMat);
    end

    if ~isfile(draftMd)
        error('No existe MD v96t: %s', draftMd);
    end

    D = load(draftMat);

    % ---------------------------------------------------------------------
    % Localizar cierre fix2 de v96t
    % ---------------------------------------------------------------------
    fix2Mat = fullfile(draftDir,'traceability_fix2','mat','MANUSCRIPT_RESULTS_SECTION_DRAFT_v96t_fix2.mat');

    fix2_found = false;
    fix2_diagnosis = "";

    if isfile(fix2Mat)
        F2 = load(fix2Mat);
        fix2_found = true;
        fix2_diagnosis = string(F2.diagnosis);
    end

    % ---------------------------------------------------------------------
    % Cargar texto del borrador
    % ---------------------------------------------------------------------
    manuscriptText = string(fileread(draftMd));

    % ---------------------------------------------------------------------
    % Extraer valores principales
    % ---------------------------------------------------------------------
    TmanuscriptValues = D.TmanuscriptValues;
    Tfigures = D.Tfigures;
    TchecksDraft = D.Tchecks;

    H2_MR = TmanuscriptValues.H2_MR(1);
    H2_cost = TmanuscriptValues.H2_cost_specific(1);
    H2_CO2 = TmanuscriptValues.H2_CO2_specific(1);

    gasLP_MR = TmanuscriptValues.gasLP_MR(1);
    gasLP_cost = TmanuscriptValues.gasLP_cost_specific(1);
    gasLP_CO2 = TmanuscriptValues.gasLP_CO2_specific(1);

    MRred = TmanuscriptValues.MR_reduction_pct_vs_gasLP(1);
    CostRed = TmanuscriptValues.cost_reduction_pct_vs_gasLP(1);
    CO2Red = TmanuscriptValues.CO2_reduction_pct_vs_gasLP(1);

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    outBaseDir = fullfile(rootDir,'05_runs','editorial_results_section_review_v96u');
    outDir = fullfile(outBaseDir,['EDITORIAL_RESULTS_SECTION_REVIEW_v96u_' timestamp]);

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
    % Decisiones editoriales recomendadas
    % ---------------------------------------------------------------------
    editorialDecisions = struct();

    editorialDecisions.language_recommendation = "Spanish for thesis; English only if the immediate target is an article.";
    editorialDecisions.style_recommendation = "Thesis-style technical prose with article-compatible captions.";
    editorialDecisions.figure_numbering_recommendation = "Use Figure 1, Figure 2, Figure 3 in final manuscript; keep Figure A/B/C only as internal package identifiers.";
    editorialDecisions.gasLP_recommendation = "Use 'gas LP' in prose and reserve 'gasLP' only for code labels/tables if needed.";
    editorialDecisions.CO2_caveat_recommendation = "Keep CO2 reductions as preliminary/provisional until emission factors are replaced by final referenced factors.";
    editorialDecisions.solar_caveat_recommendation = "State that solar-only mode was excluded from the formal Pareto comparison because it requires a separate daylight-window formulation.";
    editorialDecisions.H2_framing_recommendation = "Frame H2 as a compromise solution, not as a global absolute optimum.";
    editorialDecisions.extreme_solutions_recommendation = "Use H1/H4/H9 as interpretive anchors of the Pareto trade-off, not as recommended operating points.";

    TeditorialDecisions = struct2table(editorialDecisions);

    outEditorialDecisionsCsv = fullfile(tablesDir,'EDITORIAL_RESULTS_SECTION_v96u_editorial_decisions.csv');
    writetable(TeditorialDecisions,outEditorialDecisionsCsv);

    % ---------------------------------------------------------------------
    % Tabla de cambios sugeridos
    % ---------------------------------------------------------------------
    Tchanges = table();

    Tchanges.item = [ ...
        "Language"; ...
        "Figure numbering"; ...
        "gasLP nomenclature"; ...
        "CO2 caveat"; ...
        "Solar caveat"; ...
        "H2 framing"; ...
        "Caption style"; ...
        "Units and symbols"; ...
        "Results conclusion"];

    Tchanges.current_issue = [ ...
        "Current draft is in English and reads as article-ready prose."; ...
        "Figures are labeled Figure A/B/C."; ...
        "gasLP appears as a code-like label in prose."; ...
        "CO2 caveat is present but should be worded carefully."; ...
        "Solar caveat is present but should remain methodological, not negative."; ...
        "H2 must not be described as a universal optimum."; ...
        "Captions are technically correct but need final numbering."; ...
        "Some variables are code-oriented and need manuscript notation decisions."; ...
        "Conclusion is correct but should be adapted to thesis/article target."];

    Tchanges.recommendation = [ ...
        "Prepare a Spanish thesis version first, then translate/adapt for article if needed."; ...
        "Convert to Figure 1, Figure 2 and Figure 3 in final manuscript."; ...
        "Use 'gas LP' in narrative; keep 'gasLP' in tables only if it is a mode identifier."; ...
        "Use 'preliminary CO2-specific comparison' until final emission factors are cited."; ...
        "State that solar-only requires a separate daylight-window analysis."; ...
        "State that H2 is the selected compromise solution of the formal hybrid Pareto front."; ...
        "Use concise captions with one sentence for content and one sentence for interpretation."; ...
        "Define MR, specific cost, specific CO2, m_max, T_min, r_div2 and t_rec_ini before or in caption/table."; ...
        "Conclude with trade-off logic: H1/H4 inadmissible, H9 costly/high CO2, H2 balanced."];

    Tchanges.priority = [ ...
        "high"; ...
        "high"; ...
        "medium"; ...
        "high"; ...
        "high"; ...
        "high"; ...
        "medium"; ...
        "medium"; ...
        "high"];

    outChangesCsv = fullfile(tablesDir,'EDITORIAL_RESULTS_SECTION_v96u_suggested_changes.csv');
    writetable(Tchanges,outChangesCsv);

    % ---------------------------------------------------------------------
    % Captions recomendados
    % ---------------------------------------------------------------------
    Tcaptions = table();

    Tcaptions.internal_id = ["Figure A";"Figure B";"Figure C"];
    Tcaptions.final_label_thesis_es = ["Figura 1";"Figura 2";"Figura 3"];
    Tcaptions.final_label_article_en = ["Figure 1";"Figure 2";"Figure 3"];

    Tcaptions.caption_es = [ ...
        "Frente triobjetivo del modo híbrido. La razón de humedad final y el costo específico se muestran en los ejes, mientras que el tamaño del marcador representa las emisiones específicas de CO2."; ...
        "Comparación entre la referencia con gas LP y la solución híbrida recomendada H2. Se muestran la razón de humedad final, el costo específico y las emisiones específicas de CO2."; ...
        "Espacio operativo de las soluciones formales del modo híbrido en función de T_min, r_div2 y t_rec_ini. La solución H2 se destaca como compromiso operativo recomendado."];

    Tcaptions.caption_en = [ ...
        "Triobjective front of the hybrid operating mode. Final moisture ratio and specific cost are shown on the axes, while marker size represents specific CO2 emissions."; ...
        "Comparison between the gas LP reference and the recommended hybrid solution H2. Final moisture ratio, specific cost and specific CO2 emissions are shown."; ...
        "Operating decision-space of the formal hybrid solutions as a function of T_min, r_div2 and t_rec_ini. H2 is highlighted as the recommended operating compromise."];

    Tcaptions.source_png = Tfigures.png_file;
    Tcaptions.source_pdf = Tfigures.pdf_file;
    Tcaptions.exists_png = Tfigures.exists_png;
    Tcaptions.exists_pdf = Tfigures.exists_pdf;

    outCaptionsCsv = fullfile(tablesDir,'EDITORIAL_RESULTS_SECTION_v96u_captions.csv');
    writetable(Tcaptions,outCaptionsCsv);

    % ---------------------------------------------------------------------
    % Redacción editorial recomendada en español
    % ---------------------------------------------------------------------
    spanishText = compose_spanish_editorial_results_section( ...
        H2_MR,H2_cost,H2_CO2, ...
        gasLP_MR,gasLP_cost,gasLP_CO2, ...
        MRred,CostRed,CO2Red);

    outSpanishMd = fullfile(mdDir,'RESULTS_SECTION_EDITORIAL_REVIEW_v96u_SPANISH_THESIS_VERSION.md');

    fid = fopen(outSpanishMd,'w');
    if fid < 0
        error('No se pudo crear versión española: %s', outSpanishMd);
    end
    fprintf(fid,'%s',spanishText);
    fclose(fid);

    outSpanishTxt = fullfile(txtDir,'RESULTS_SECTION_EDITORIAL_REVIEW_v96u_SPANISH_THESIS_VERSION.txt');

    fid = fopen(outSpanishTxt,'w');
    if fid < 0
        error('No se pudo crear versión española TXT: %s', outSpanishTxt);
    end
    fprintf(fid,'%s',spanishText);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Reporte editorial
    % ---------------------------------------------------------------------
    reviewMd = compose_editorial_review_md( ...
        draftMd,fix2_found,fix2_diagnosis, ...
        TeditorialDecisions,Tchanges,Tcaptions, ...
        outSpanishMd);

    outReviewMd = fullfile(mdDir,'EDITORIAL_RESULTS_SECTION_REVIEW_v96u.md');

    fid = fopen(outReviewMd,'w');
    if fid < 0
        error('No se pudo crear review MD: %s', outReviewMd);
    end
    fprintf(fid,'%s',reviewMd);
    fclose(fid);

    outReviewTxt = fullfile(txtDir,'EDITORIAL_RESULTS_SECTION_REVIEW_v96u.txt');

    fid = fopen(outReviewTxt,'w');
    if fid < 0
        error('No se pudo crear review TXT: %s', outReviewTxt);
    end
    fprintf(fid,'%s',reviewMd);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};
    checks{end+1,1} = check_row("U01","v96t draft loaded",true,string(draftMat));
    checks{end+1,1} = check_row("U02","v96t fix2 closure found",fix2_found,string(fix2Mat));
    checks{end+1,1} = check_row("U03","v96t fix2 diagnosis PASS",strcmp(fix2_diagnosis,"MANUSCRIPT_RESULTS_SECTION_DRAFT_PASS"),fix2_diagnosis);
    checks{end+1,1} = check_row("U04","Editorial decisions table created",isfile(outEditorialDecisionsCsv),outEditorialDecisionsCsv);
    checks{end+1,1} = check_row("U05","Suggested changes table created",isfile(outChangesCsv),outChangesCsv);
    checks{end+1,1} = check_row("U06","Captions table created",isfile(outCaptionsCsv),outCaptionsCsv);
    checks{end+1,1} = check_row("U07","Spanish thesis version created",isfile(outSpanishMd),outSpanishMd);
    checks{end+1,1} = check_row("U08","Editorial review created",isfile(outReviewMd),outReviewMd);
    checks{end+1,1} = check_row("U09","Figure files still exist",all(Tcaptions.exists_png) && all(Tcaptions.exists_pdf),"All fig4 PNG/PDF files registered.");
    checks{end+1,1} = check_row("U10","CO2 caveat retained",contains(spanishText,"provisional") || contains(spanishText,"preliminar"),"CO2 caveat retained in Spanish text.");
    checks{end+1,1} = check_row("U11","Solar caveat retained",contains(spanishText,"solar"),"Solar caveat retained in Spanish text.");
    checks{end+1,1} = check_row("U12","No GA executed",true,"No gamultiobj call.");
    checks{end+1,1} = check_row("U13","No mechanistic rerun",true,"No objective/model call.");

    Tchecks = struct2table(vertcat(checks{:}));

    review_pass = all(Tchecks.pass);

    if review_pass
        diagnosis = "EDITORIAL_RESULTS_SECTION_REVIEW_PASS";
        decision = "EDITORIAL_REVIEW_READY_FOR_USER_SELECTION";
        next_step = "User selects final language/style: Spanish thesis, English article, or bilingual package.";
    else
        diagnosis = "EDITORIAL_RESULTS_SECTION_REVIEW_REQUIRES_REVIEW";
        decision = "REVIEW_FAILED_EDITORIAL_CHECKS";
        next_step = "Review failed checks before selecting final manuscript style.";
    end

    outChecksCsv = fullfile(tablesDir,'EDITORIAL_RESULTS_SECTION_v96u_checks.csv');
    writetable(Tchecks,outChecksCsv);

    % ---------------------------------------------------------------------
    % Guardar MAT
    % ---------------------------------------------------------------------
    outMat = fullfile(matDir,'EDITORIAL_RESULTS_SECTION_REVIEW_v96u.mat');

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'draftDir','draftMat','draftMd','draftTxt','fix2_found','fix2_diagnosis','fix2Mat', ...
        'manuscriptText','TmanuscriptValues','Tfigures','TchecksDraft', ...
        'TeditorialDecisions','Tchanges','Tcaptions','Tchecks', ...
        'outDir','mdDir','txtDir','tablesDir','matDir','logsDir', ...
        'outEditorialDecisionsCsv','outChangesCsv','outCaptionsCsv','outChecksCsv', ...
        'outSpanishMd','outSpanishTxt','outReviewMd','outReviewTxt','outMat');

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    edrev = struct();
    edrev.status = 'EDITORIAL_RESULTS_SECTION_REVIEW_COMPLETED';
    edrev.diagnosis = diagnosis;
    edrev.decision = decision;
    edrev.next_step = next_step;

    edrev.draftDir = draftDir;
    edrev.draftMd = draftMd;
    edrev.fix2_found = fix2_found;
    edrev.fix2_diagnosis = fix2_diagnosis;

    edrev.outDir = outDir;
    edrev.outReviewMd = outReviewMd;
    edrev.outSpanishMd = outSpanishMd;
    edrev.outMat = outMat;

    edrev.TeditorialDecisions = TeditorialDecisions;
    edrev.Tchanges = Tchanges;
    edrev.Tcaptions = Tcaptions;
    edrev.Tchecks = Tchecks;

    disp('=== EDITORIAL_RESULTS_SECTION_REVIEW_v96u ===')
    disp(edrev.status)
    disp('=== DIAGNOSIS ===')
    disp(edrev.diagnosis)
    disp('=== DECISION ===')
    disp(edrev.decision)
    disp('=== NEXT STEP ===')
    disp(edrev.next_step)
    disp('=== EDITORIAL DECISIONS ===')
    disp(edrev.TeditorialDecisions)
    disp('=== SUGGESTED CHANGES ===')
    disp(edrev.Tchanges)
    disp('=== CAPTIONS ===')
    disp(edrev.Tcaptions)
    disp('=== CHECKS ===')
    disp(edrev.Tchecks)
    disp('=== REVIEW MD ===')
    disp(edrev.outReviewMd)
    disp('=== SPANISH VERSION MD ===')
    disp(edrev.outSpanishMd)

end

% =========================================================================
% Text composition
% =========================================================================

function txt = compose_spanish_editorial_results_section( ...
    H2_MR,H2_cost,H2_CO2, ...
    gasLP_MR,gasLP_cost,gasLP_CO2, ...
    MRred,CostRed,CO2Red)

    lines = strings(0,1);

    lines(end+1) = "# Sección de resultados — versión editorial preliminar en español";
    lines(end+1) = "";
    lines(end+1) = "## Alcance de la optimización formal";
    lines(end+1) = "";
    lines(end+1) = "La optimización formal se consolidó para el modo de operación híbrido, considerando tres funciones objetivo: razón de humedad final, costo específico y emisiones específicas de CO2. El caso de operación con gas LP se utilizó como referencia directa de comparación. El modo solar puro no se incorporó al frente formal de Pareto, debido a que su operación está condicionada por la disponibilidad finita de irradiancia diaria y requiere una formulación específica de ventana solar para que la comparación sea metodológicamente equivalente.";
    lines(end+1) = "";
    lines(end+1) = "## Solución recomendada";
    lines(end+1) = "";
    lines(end+1) = "La solución seleccionada fue H2. Esta solución no corresponde a un extremo individual del frente, sino a un compromiso operativo que cumple el criterio de secado y mejora simultáneamente los indicadores económico y ambiental respecto a la referencia con gas LP.";
    lines(end+1) = "";
    lines(end+1) = "Para H2 se obtuvo una razón de humedad final `MR = " + string(sprintf('%.6g',H2_MR)) + "`, inferior al criterio de aceptación `MR < 0.1`. El costo específico fue `" + string(sprintf('%.6g',H2_cost)) + "` y las emisiones específicas de CO2 fueron `" + string(sprintf('%.6g',H2_CO2)) + "`.";
    lines(end+1) = "";
    lines(end+1) = "En comparación con la referencia con gas LP, que presentó `MR = " + string(sprintf('%.6g',gasLP_MR)) + "`, costo específico de `" + string(sprintf('%.6g',gasLP_cost)) + "` y emisiones específicas de CO2 de `" + string(sprintf('%.6g',gasLP_CO2)) + "`, la solución H2 redujo la razón de humedad final en `" + string(sprintf('%.4g',MRred)) + " %`, el costo específico en `" + string(sprintf('%.4g',CostRed)) + " %` y las emisiones específicas de CO2 en `" + string(sprintf('%.4g',CO2Red)) + " %`.";
    lines(end+1) = "";
    lines(end+1) = "## Interpretación del frente triobjetivo";
    lines(end+1) = "";
    lines(end+1) = "La estructura del frente muestra que las soluciones extremas no son necesariamente las más convenientes desde el punto de vista operativo. La solución H1 representa una región de bajas emisiones específicas de CO2, pero no cumple el criterio de razón de humedad final. La solución H4 representa una región de bajo costo específico, aunque también resulta inadmisible por humedad. Por su parte, H9 intensifica el secado y alcanza la menor razón de humedad, pero lo hace con mayor costo específico y mayores emisiones específicas de CO2 que la referencia con gas LP.";
    lines(end+1) = "";
    lines(end+1) = "En este contexto, H2 constituye la alternativa más defendible porque mantiene la admisibilidad del producto seco y, al mismo tiempo, reduce costo y emisiones específicas frente a la operación con gas LP.";
    lines(end+1) = "";
    lines(end+1) = "## Figuras sugeridas";
    lines(end+1) = "";
    lines(end+1) = "La Figura 1 debe presentar el frente triobjetivo del modo híbrido, usando la razón de humedad final y el costo específico en los ejes, e incorporando las emisiones específicas de CO2 mediante el tamaño del marcador. La Figura 2 debe comparar directamente la referencia con gas LP y la solución H2. La Figura 3 debe mostrar el espacio operativo de las soluciones formales en función de `T_min`, `r_div2` y `t_rec_ini`.";
    lines(end+1) = "";
    lines(end+1) = "## Limitaciones de interpretación";
    lines(end+1) = "";
    lines(end+1) = "Las reducciones de CO2 deben considerarse preliminares mientras los factores de emisión permanezcan con estatus provisional para validación de código. Antes de usar estos valores como afirmaciones finales de manuscrito, deberán sustituirse por factores definitivos y referencias documentadas.";
    lines(end+1) = "";
    lines(end+1) = "Asimismo, la exclusión del modo solar puro no debe interpretarse como una desventaja del recurso solar, sino como una decisión metodológica. Su evaluación requiere una formulación específica centrada en la ventana diaria de irradiancia y en la humedad alcanzada durante dicha ventana.";
    lines(end+1) = "";
    lines(end+1) = "## Cierre de resultados";
    lines(end+1) = "";
    lines(end+1) = "Los resultados de la optimización triobjetivo respaldan la selección de H2 como condición de operación híbrida recomendada. Esta solución representa un balance entre desempeño de secado, costo específico y emisiones específicas de CO2, y mejora simultáneamente los tres indicadores frente a la referencia con gas LP.";
    lines(end+1) = "";

    txt = strjoin(lines,newline);
end

function txt = compose_editorial_review_md( ...
    draftMd,fix2_found,fix2_diagnosis, ...
    TeditorialDecisions,Tchanges,Tcaptions, ...
    outSpanishMd)

    lines = strings(0,1);

    lines(end+1) = "# EDITORIAL_RESULTS_SECTION_REVIEW_v96u";
    lines(end+1) = "";
    lines(end+1) = "## Estado de entrada";
    lines(end+1) = "";
    lines(end+1) = "- Borrador base: `" + string(draftMd) + "`";
    lines(end+1) = "- Fix2 encontrado: `" + string(fix2_found) + "`";
    lines(end+1) = "- Diagnóstico fix2: `" + string(fix2_diagnosis) + "`";
    lines(end+1) = "";

    lines(end+1) = "## Dictamen editorial";
    lines(end+1) = "";
    lines(end+1) = "El borrador de resultados ya es técnicamente utilizable. La edición necesaria es de forma, no de fondo. Se recomienda preparar primero una versión en español para tesis, con estilo técnico sobrio, y conservar una versión en inglés como base de artículo.";
    lines(end+1) = "";

    lines(end+1) = "## Decisiones editoriales recomendadas";
    lines(end+1) = "";
    lines(end+1) = "| Criterio | Recomendación |";
    lines(end+1) = "|---|---|";

    names = TeditorialDecisions.Properties.VariableNames;
    for i = 1:numel(names)
        lines(end+1) = "| `" + string(names{i}) + "` | " + string(TeditorialDecisions.(names{i})(1)) + " |";
    end

    lines(end+1) = "";
    lines(end+1) = "## Cambios sugeridos";
    lines(end+1) = "";
    lines(end+1) = "| Item | Problema actual | Recomendación | Prioridad |";
    lines(end+1) = "|---|---|---|---|";

    for i = 1:height(Tchanges)
        lines(end+1) = "| " + string(Tchanges.item(i)) + " | " + string(Tchanges.current_issue(i)) + " | " + string(Tchanges.recommendation(i)) + " | " + string(Tchanges.priority(i)) + " |";
    end

    lines(end+1) = "";
    lines(end+1) = "## Captions sugeridos";
    lines(end+1) = "";
    lines(end+1) = "| Interno | Tesis ES | Caption ES | Artículo EN | Caption EN |";
    lines(end+1) = "|---|---|---|---|---|";

    for i = 1:height(Tcaptions)
        lines(end+1) = "| " + string(Tcaptions.internal_id(i)) + " | " + string(Tcaptions.final_label_thesis_es(i)) + " | " + string(Tcaptions.caption_es(i)) + " | " + string(Tcaptions.final_label_article_en(i)) + " | " + string(Tcaptions.caption_en(i)) + " |";
    end

    lines(end+1) = "";
    lines(end+1) = "## Versión editorial en español";
    lines(end+1) = "";
    lines(end+1) = "Se generó una versión preliminar en español para tesis:";
    lines(end+1) = "";
    lines(end+1) = "- `" + string(outSpanishMd) + "`";
    lines(end+1) = "";

    lines(end+1) = "## Recomendación de siguiente paso";
    lines(end+1) = "";
    lines(end+1) = "Seleccionar una ruta editorial:";
    lines(end+1) = "";
    lines(end+1) = "1. `9.6v-ES` — convertir a versión final en español para tesis.";
    lines(end+1) = "2. `9.6v-EN` — pulir como sección de artículo en inglés.";
    lines(end+1) = "3. `9.6v-BI` — mantener paquete bilingüe tesis/artículo.";
    lines(end+1) = "";

    txt = strjoin(lines,newline);
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