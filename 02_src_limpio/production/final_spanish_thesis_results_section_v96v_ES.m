function finalES = final_spanish_thesis_results_section_v96v_ES()
% FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES
% 9.6v-ES — FINAL-SPANISH-THESIS-RESULTS-SECTION-001
%
% Objetivo:
%   Generar la versión final en español para tesis de la sección de
%   resultados de la optimización triobjetivo formal.
%
% Este script:
%   - NO ejecuta GA.
%   - NO llama modelo mecanístico.
%   - NO llama función objetivo.
%   - NO recalcula resultados.
%   - NO modifica fuentes protegidas.
%   - Usa el paquete v96s, el borrador v96t y la revisión editorial v96u.
%
% Entregables:
%   - Sección final en español para tesis en MD.
%   - Sección final en español para tesis en TXT.
%   - Tabla de figuras finales.
%   - Tabla de valores principales.
%   - Tabla de checks.
%   - MAT de trazabilidad.
%
% Uso:
%   finalES = final_spanish_thesis_results_section_v96v_ES();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    MR_acceptance = 0.10;

    % ---------------------------------------------------------------------
    % Localizar revisión editorial v96u más reciente
    % ---------------------------------------------------------------------
    reviewBaseDir = fullfile(rootDir,'05_runs','editorial_results_section_review_v96u');

    if ~isfolder(reviewBaseDir)
        error('No existe reviewBaseDir: %s', reviewBaseDir);
    end

    d = dir(reviewBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'EDITORIAL_RESULTS_SECTION_REVIEW_v96u_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró revisión editorial v96u.');
    end

    [~,idxReview] = max([d.datenum]);
    reviewDir = fullfile(reviewBaseDir,d(idxReview).name);

    reviewMat = fullfile(reviewDir,'mat','EDITORIAL_RESULTS_SECTION_REVIEW_v96u.mat');

    if ~isfile(reviewMat)
        error('No existe MAT v96u: %s', reviewMat);
    end

    R = load(reviewMat);

    if ~strcmp(string(R.diagnosis),"EDITORIAL_RESULTS_SECTION_REVIEW_PASS")
        error('La revisión editorial v96u no está en PASS. Diagnosis: %s', string(R.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Localizar paquete final v96s
    % ---------------------------------------------------------------------
    if isfield(R,'draftDir')
        % draftDir está dentro de 05_runs; el pkgDir viene del MAT del draft.
        draftMat = fullfile(string(R.draftDir),'mat','MANUSCRIPT_RESULTS_SECTION_DRAFT_v96t.mat');
    else
        error('El MAT v96u no contiene draftDir.');
    end

    if ~isfile(draftMat)
        error('No existe MAT del borrador v96t: %s', draftMat);
    end

    D = load(draftMat);

    if ~isfield(D,'pkgDir')
        error('El MAT v96t no contiene pkgDir.');
    end

    pkgDir = string(D.pkgDir);
    pkgMat = fullfile(pkgDir,'mat','FINAL_RESULTS_PACKAGE_WITH_FIG4_v96s.mat');

    if ~isfile(pkgMat)
        error('No existe MAT del paquete v96s: %s', pkgMat);
    end

    P = load(pkgMat);

    if ~strcmp(string(P.diagnosis),"FINAL_RESULTS_PACKAGE_WITH_FIG4_PASS")
        error('El paquete v96s no está en PASS. Diagnosis: %s', string(P.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Datos principales
    % ---------------------------------------------------------------------
    T = P.T;
    Tkey = P.Tkey;
    Trecommended = P.Trecommended;
    Tsummary = P.Tsummary;
    TfinalSummary = P.TfinalSummary;

    Tcaptions = R.Tcaptions;
    TeditorialDecisions = R.TeditorialDecisions;
    Tchanges = R.Tchanges;

    recID = string(Trecommended.solution_id(1));

    if recID ~= "H2"
        warning('La solución recomendada no es H2. Recomendación actual: %s', recID);
    end

    H2 = Trecommended;

    gasMR = Tsummary.gasLP_MR(1);
    gasCost = Tsummary.gasLP_cost(1);
    gasCO2 = Tsummary.gasLP_CO2(1);

    MRred = H2.reduction_MR_pct_vs_gasLP(1);
    CostRed = H2.reduction_cost_pct_vs_gasLP(1);
    CO2Red = H2.reduction_CO2_pct_vs_gasLP(1);

    % ---------------------------------------------------------------------
    % Figuras finales
    % ---------------------------------------------------------------------
    figuresPngDir = fullfile(pkgDir,'figures','png');
    figuresPdfDir = fullfile(pkgDir,'figures','pdf');

    fig1_png = fullfile(figuresPngDir,'FIG_A_final_triobjective_front_MR_cost_CO2size.png');
    fig2_png = fullfile(figuresPngDir,'FIG_B_final_gasLP_vs_H2_percent_reductions.png');
    fig3_png = fullfile(figuresPngDir,'FIG_C_final_operating_space_3D_Tmin_rdiv2_trecini.png');

    fig1_pdf = fullfile(figuresPdfDir,'FIG_A_final_triobjective_front_MR_cost_CO2size.pdf');
    fig2_pdf = fullfile(figuresPdfDir,'FIG_B_final_gasLP_vs_H2_percent_reductions.pdf');
    fig3_pdf = fullfile(figuresPdfDir,'FIG_C_final_operating_space_3D_Tmin_rdiv2_trecini.pdf');

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    outBaseDir = fullfile(rootDir,'05_runs','final_spanish_thesis_results_section_v96v_ES');
    outDir = fullfile(outBaseDir,['FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES_' timestamp]);

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
    % Tabla de valores finales
    % ---------------------------------------------------------------------
    finalValues = struct();

    finalValues.section_version = "v96v_ES";
    finalValues.target = "Spanish thesis results section";
    finalValues.formal_mode = "hybrid";
    finalValues.reference_mode_prose = "gas LP";
    finalValues.reference_mode_code = "gasLP";
    finalValues.recommended_solution_id = recID;

    finalValues.m_max = H2.m_max(1);
    finalValues.T_min = H2.T_min(1);
    finalValues.r_div2 = H2.r_div2(1);
    finalValues.t_rec_ini = H2.t_rec_ini(1);

    finalValues.H2_MR = H2.MR(1);
    finalValues.H2_cost_specific = H2.cost_specific(1);
    finalValues.H2_CO2_specific = H2.CO2_specific(1);

    finalValues.gasLP_MR = gasMR;
    finalValues.gasLP_cost_specific = gasCost;
    finalValues.gasLP_CO2_specific = gasCO2;

    finalValues.MR_acceptance = MR_acceptance;
    finalValues.H2_admissible = H2.MR(1) < MR_acceptance;

    finalValues.MR_reduction_pct_vs_gasLP = MRred;
    finalValues.cost_reduction_pct_vs_gasLP = CostRed;
    finalValues.CO2_reduction_pct_vs_gasLP = CO2Red;

    finalValues.CO2_status = "comparacion preliminar; factores de emision pendientes de fijacion bibliografica";
    finalValues.solar_status = "excluido del frente formal; requiere formulacion de ventana solar";

    TfinalValues = struct2table(finalValues);

    outFinalValuesCsv = fullfile(tablesDir,'FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES_values.csv');
    writetable(TfinalValues,outFinalValuesCsv);

    % ---------------------------------------------------------------------
    % Tabla de figuras finales para tesis
    % ---------------------------------------------------------------------
    TfinalFigures = table();

    TfinalFigures.final_label = ["Figura 1";"Figura 2";"Figura 3"];
    TfinalFigures.internal_label = ["Figure A";"Figure B";"Figure C"];

    TfinalFigures.caption = [ ...
        "Frente triobjetivo del modo híbrido. La razón de humedad final y el costo específico se muestran en los ejes, mientras que el tamaño del marcador representa las emisiones específicas de CO2."; ...
        "Comparación entre la referencia con gas LP y la solución híbrida recomendada H2. Se muestran la razón de humedad final, el costo específico y las emisiones específicas de CO2."; ...
        "Espacio operativo de las soluciones formales del modo híbrido en función de T_min, r_div2 y t_rec_ini. La solución H2 se destaca como compromiso operativo recomendado."];

    TfinalFigures.png_file = [string(fig1_png); string(fig2_png); string(fig3_png)];
    TfinalFigures.pdf_file = [string(fig1_pdf); string(fig2_pdf); string(fig3_pdf)];
    TfinalFigures.exists_png = [isfile(fig1_png); isfile(fig2_png); isfile(fig3_png)];
    TfinalFigures.exists_pdf = [isfile(fig1_pdf); isfile(fig2_pdf); isfile(fig3_pdf)];

    outFinalFiguresCsv = fullfile(tablesDir,'FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES_figures.csv');
    writetable(TfinalFigures,outFinalFiguresCsv);

    % ---------------------------------------------------------------------
    % Tabla de soluciones clave para tesis
    % ---------------------------------------------------------------------
    TkeyThesis = Tkey;
    TkeyThesis.interpretacion_tesis = strings(height(TkeyThesis),1);

    for i = 1:height(TkeyThesis)
        sid = string(TkeyThesis.solution_id(i));

        switch sid
            case "H1"
                TkeyThesis.interpretacion_tesis(i) = "Región de menor CO2 específico; no recomendada porque no cumple el criterio MR < 0.1.";
            case "H2"
                TkeyThesis.interpretacion_tesis(i) = "Solución recomendada; compromiso admisible con reducción simultánea de MR, costo específico y CO2 específico frente a gas LP.";
            case "H4"
                TkeyThesis.interpretacion_tesis(i) = "Región de menor costo específico; no recomendada porque no cumple el criterio MR < 0.1.";
            case "H9"
                TkeyThesis.interpretacion_tesis(i) = "Región de menor MR; admisible por secado, pero con mayor costo específico y mayor CO2 específico que gas LP.";
            otherwise
                TkeyThesis.interpretacion_tesis(i) = "";
        end
    end

    outKeyThesisCsv = fullfile(tablesDir,'FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES_key_solutions.csv');
    writetable(TkeyThesis,outKeyThesisCsv);

    % ---------------------------------------------------------------------
    % Componer texto final
    % ---------------------------------------------------------------------
    finalText = compose_final_spanish_thesis_text( ...
        H2,TkeyThesis, ...
        gasMR,gasCost,gasCO2, ...
        MR_acceptance,MRred,CostRed,CO2Red, ...
        TfinalFigures);

    outFinalMd = fullfile(mdDir,'FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES.md');

    fid = fopen(outFinalMd,'w');
    if fid < 0
        error('No se pudo crear MD final: %s', outFinalMd);
    end
    fprintf(fid,'%s',finalText);
    fclose(fid);

    outFinalTxt = fullfile(txtDir,'FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES.txt');

    fid = fopen(outFinalTxt,'w');
    if fid < 0
        error('No se pudo crear TXT final: %s', outFinalTxt);
    end
    fprintf(fid,'%s',finalText);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Reporte de cierre
    % ---------------------------------------------------------------------
    closeMd = compose_close_report_md( ...
        reviewMat,pkgMat,outFinalMd,outFinalTxt, ...
        TfinalValues,TfinalFigures,TkeyThesis);

    outCloseMd = fullfile(logsDir,'FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES_CLOSE_REPORT.md');

    fid = fopen(outCloseMd,'w');
    if fid < 0
        error('No se pudo crear reporte de cierre: %s', outCloseMd);
    end
    fprintf(fid,'%s',closeMd);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};
    checks{end+1,1} = check_row("VES01","v96u editorial review loaded",true,string(reviewMat));
    checks{end+1,1} = check_row("VES02","v96u diagnosis PASS",strcmp(string(R.diagnosis),"EDITORIAL_RESULTS_SECTION_REVIEW_PASS"),string(R.diagnosis));
    checks{end+1,1} = check_row("VES03","v96s package loaded",true,string(pkgMat));
    checks{end+1,1} = check_row("VES04","v96s package diagnosis PASS",strcmp(string(P.diagnosis),"FINAL_RESULTS_PACKAGE_WITH_FIG4_PASS"),string(P.diagnosis));
    checks{end+1,1} = check_row("VES05","Recommended solution is H2",recID=="H2",sprintf("recommended=%s",recID));
    checks{end+1,1} = check_row("VES06","H2 admissible by MR",H2.MR(1)<MR_acceptance,sprintf("MR=%.12g",H2.MR(1)));
    checks{end+1,1} = check_row("VES07","Positive cost reduction",CostRed>0,sprintf("costReduction=%.12g%%",CostRed));
    checks{end+1,1} = check_row("VES08","Positive CO2 reduction",CO2Red>0,sprintf("CO2Reduction=%.12g%%",CO2Red));
    checks{end+1,1} = check_row("VES09","Positive MR reduction",MRred>0,sprintf("MRReduction=%.12g%%",MRred));
    checks{end+1,1} = check_row("VES10","Final MD created",isfile(outFinalMd),string(outFinalMd));
    checks{end+1,1} = check_row("VES11","Final TXT created",isfile(outFinalTxt),string(outFinalTxt));
    checks{end+1,1} = check_row("VES12","Final values CSV created",isfile(outFinalValuesCsv),string(outFinalValuesCsv));
    checks{end+1,1} = check_row("VES13","Final figures table created",isfile(outFinalFiguresCsv),string(outFinalFiguresCsv));
    checks{end+1,1} = check_row("VES14","Key solutions table created",isfile(outKeyThesisCsv),string(outKeyThesisCsv));
    checks{end+1,1} = check_row("VES15","All final figure PNG/PDF exist",all(TfinalFigures.exists_png) && all(TfinalFigures.exists_pdf),"Figures 1-3 available as PNG/PDF.");
    checks{end+1,1} = check_row("VES16","Uses gas LP in prose",contains(finalText,"gas LP"),"gas LP found in final text.");
    checks{end+1,1} = check_row("VES17","CO2 caveat retained",contains(finalText,"preliminar") && contains(finalText,"factores de emisión"),"CO2 caveat found.");
    checks{end+1,1} = check_row("VES18","Solar caveat retained",contains(finalText,"ventana solar"),"Solar caveat found.");
    checks{end+1,1} = check_row("VES19","Figure numbering converted",contains(finalText,"Figura 1") && contains(finalText,"Figura 2") && contains(finalText,"Figura 3"),"Figures 1-3 found.");
    checks{end+1,1} = check_row("VES20","No GA executed",true,"No gamultiobj call.");
    checks{end+1,1} = check_row("VES21","No mechanistic rerun",true,"No objective/model call.");

    Tchecks = struct2table(vertcat(checks{:}));

    final_pass = all(Tchecks.pass);

    if final_pass
        diagnosis = "FINAL_SPANISH_THESIS_RESULTS_SECTION_PASS";
        decision = "FINAL_SPANISH_THESIS_RESULTS_SECTION_READY";
        next_step = "9.6w — INTEGRATION-OR-ARTICLE-ADAPTATION-DECISION-001";
    else
        diagnosis = "FINAL_SPANISH_THESIS_RESULTS_SECTION_REQUIRES_REVIEW";
        decision = "REVIEW_FAILED_FINAL_ES_CHECKS";
        next_step = "Review failed checks before thesis integration.";
    end

    outChecksCsv = fullfile(tablesDir,'FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES_checks.csv');
    writetable(Tchecks,outChecksCsv);

    % ---------------------------------------------------------------------
    % Guardar MAT
    % ---------------------------------------------------------------------
    outMat = fullfile(matDir,'FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES.mat');

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'reviewDir','reviewMat','pkgDir','pkgMat', ...
        'T','Tkey','TkeyThesis','Trecommended','Tsummary','TfinalSummary', ...
        'Tcaptions','TeditorialDecisions','Tchanges', ...
        'TfinalValues','TfinalFigures','Tchecks', ...
        'finalText','closeMd', ...
        'outDir','mdDir','txtDir','tablesDir','matDir','logsDir', ...
        'outFinalMd','outFinalTxt','outFinalValuesCsv','outFinalFiguresCsv','outKeyThesisCsv','outChecksCsv','outCloseMd','outMat');

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    finalES = struct();
    finalES.status = 'FINAL_SPANISH_THESIS_RESULTS_SECTION_COMPLETED';
    finalES.diagnosis = diagnosis;
    finalES.decision = decision;
    finalES.next_step = next_step;

    finalES.outDir = outDir;
    finalES.outFinalMd = outFinalMd;
    finalES.outFinalTxt = outFinalTxt;
    finalES.outCloseMd = outCloseMd;
    finalES.outMat = outMat;

    finalES.TfinalValues = TfinalValues;
    finalES.TfinalFigures = TfinalFigures;
    finalES.TkeyThesis = TkeyThesis;
    finalES.Tchecks = Tchecks;

    disp('=== FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES ===')
    disp(finalES.status)
    disp('=== DIAGNOSIS ===')
    disp(finalES.diagnosis)
    disp('=== DECISION ===')
    disp(finalES.decision)
    disp('=== NEXT STEP ===')
    disp(finalES.next_step)
    disp('=== FINAL VALUES ===')
    disp(finalES.TfinalValues)
    disp('=== FIGURES ===')
    disp(finalES.TfinalFigures)
    disp('=== KEY SOLUTIONS ===')
    disp(finalES.TkeyThesis)
    disp('=== CHECKS ===')
    disp(finalES.Tchecks)
    disp('=== FINAL MD ===')
    disp(finalES.outFinalMd)
    disp('=== CLOSE REPORT ===')
    disp(finalES.outCloseMd)

end

% =========================================================================
% Text composition
% =========================================================================

function txt = compose_final_spanish_thesis_text( ...
    H2,TkeyThesis, ...
    gasMR,gasCost,gasCO2, ...
    MR_acceptance,MRred,CostRed,CO2Red, ...
    TfinalFigures)

    lines = strings(0,1);

    lines(end+1) = "# Resultados de la optimización triobjetivo";
    lines(end+1) = "";

    lines(end+1) = "## Alcance de la corrida formal";
    lines(end+1) = "";
    lines(end+1) = "La corrida formal de optimización se consolidó para el modo de operación híbrido del túnel de deshidratación. La formulación consideró tres funciones objetivo: razón de humedad final (`MR`), costo específico y emisiones específicas de CO2. El caso de operación con gas LP se utilizó como referencia directa para comparar el desempeño de la solución híbrida recomendada.";
    lines(end+1) = "";
    lines(end+1) = "El modo solar puro no se integró al frente formal de Pareto. Esta exclusión no representa una descalificación técnica del recurso solar, sino una decisión metodológica. La operación solar está limitada por la disponibilidad diaria de irradiancia y requiere una formulación específica de ventana solar para que la comparación sea equivalente con los modos híbrido y gas LP.";
    lines(end+1) = "";

    lines(end+1) = "## Solución recomendada del frente híbrido";
    lines(end+1) = "";
    lines(end+1) = "La solución seleccionada fue H2. Esta alternativa no corresponde a un extremo individual del frente de Pareto, sino a una solución de compromiso que cumple el criterio de secado y mejora simultáneamente los indicadores económico y ambiental frente a la referencia con gas LP.";
    lines(end+1) = "";
    lines(end+1) = "Las variables de decisión de H2 fueron `m_max = " + string(sprintf('%.6g',H2.m_max(1))) + "`, `T_min = " + string(sprintf('%.6g',H2.T_min(1))) + "`, `r_div2 = " + string(sprintf('%.6g',H2.r_div2(1))) + "` y `t_rec_ini = " + string(sprintf('%.6g',H2.t_rec_ini(1))) + "`. Con esta combinación se obtuvo `MR = " + string(sprintf('%.6g',H2.MR(1))) + "`, valor inferior al criterio de aceptación `MR < " + string(sprintf('%.3g',MR_acceptance)) + "`.";
    lines(end+1) = "";
    lines(end+1) = "El costo específico de H2 fue `" + string(sprintf('%.6g',H2.cost_specific(1))) + "` y las emisiones específicas de CO2 fueron `" + string(sprintf('%.6g',H2.CO2_specific(1))) + "`. En comparación con la referencia con gas LP, la solución H2 redujo la razón de humedad final en `" + string(sprintf('%.4g',MRred)) + " %`, el costo específico en `" + string(sprintf('%.4g',CostRed)) + " %` y las emisiones específicas de CO2 en `" + string(sprintf('%.4g',CO2Red)) + " %`.";
    lines(end+1) = "";

    lines(end+1) = "## Comparación con la referencia de gas LP";
    lines(end+1) = "";
    lines(end+1) = "La referencia con gas LP presentó `MR = " + string(sprintf('%.6g',gasMR)) + "`, costo específico de `" + string(sprintf('%.6g',gasCost)) + "` y emisiones específicas de CO2 de `" + string(sprintf('%.6g',gasCO2)) + "`. Frente a estos valores, H2 mostró una mejora simultánea en los tres indicadores evaluados.";
    lines(end+1) = "";
    lines(end+1) = "| Indicador | Referencia gas LP | Solución H2 | Cambio relativo de H2 |";
    lines(end+1) = "|---|---:|---:|---:|";
    lines(end+1) = "| Razón de humedad final, `MR` | " + string(sprintf('%.6g',gasMR)) + " | " + string(sprintf('%.6g',H2.MR(1))) + " | -" + string(sprintf('%.4g',MRred)) + " % |";
    lines(end+1) = "| Costo específico | " + string(sprintf('%.6g',gasCost)) + " | " + string(sprintf('%.6g',H2.cost_specific(1))) + " | -" + string(sprintf('%.4g',CostRed)) + " % |";
    lines(end+1) = "| Emisiones específicas de CO2 | " + string(sprintf('%.6g',gasCO2)) + " | " + string(sprintf('%.6g',H2.CO2_specific(1))) + " | -" + string(sprintf('%.4g',CO2Red)) + " % |";
    lines(end+1) = "";

    lines(end+1) = "## Lectura de las soluciones representativas";
    lines(end+1) = "";
    lines(end+1) = "La selección de H2 se entiende con mayor claridad al comparar las soluciones representativas del frente. Las soluciones H1 y H4 describen regiones atractivas desde el punto de vista ambiental y económico, respectivamente, pero no cumplen el criterio de secado. H9 alcanza la menor razón de humedad final, por lo que intensifica el secado, pero lo hace con mayor costo específico y mayores emisiones específicas de CO2 que la referencia con gas LP.";
    lines(end+1) = "";
    lines(end+1) = "Por tanto, H2 representa el compromiso operativo más defendible: cumple el criterio de humedad y, al mismo tiempo, reduce costo específico y emisiones específicas de CO2 frente al caso de gas LP.";
    lines(end+1) = "";
    lines(end+1) = "| Solución | Interpretación para tesis |";
    lines(end+1) = "|---|---|";

    for i = 1:height(TkeyThesis)
        lines(end+1) = "| `" + string(TkeyThesis.solution_id(i)) + "` | " + string(TkeyThesis.interpretacion_tesis(i)) + " |";
    end

    lines(end+1) = "";

    lines(end+1) = "## Interpretación gráfica";
    lines(end+1) = "";
    lines(end+1) = "La Figura 1 muestra el frente triobjetivo del modo híbrido. La razón de humedad final y el costo específico se presentan como ejes principales, mientras que el tamaño del marcador incorpora la información de emisiones específicas de CO2. Esta representación permite observar simultáneamente la condición de secado, el desempeño económico y la tendencia ambiental del frente.";
    lines(end+1) = "";
    lines(end+1) = "La Figura 2 compara directamente la referencia con gas LP y la solución H2. Esta comparación resume el resultado principal de la optimización: H2 mejora la razón de humedad final, reduce el costo específico y disminuye las emisiones específicas de CO2 respecto a la referencia.";
    lines(end+1) = "";
    lines(end+1) = "La Figura 3 muestra el espacio operativo de las soluciones formales del modo híbrido en función de `T_min`, `r_div2` y `t_rec_ini`. Esta figura no debe interpretarse como una superficie de respuesta, sino como una representación de la ubicación de las soluciones en el espacio de variables de decisión.";
    lines(end+1) = "";
    lines(end+1) = "| Figura | Pie de figura sugerido |";
    lines(end+1) = "|---|---|";

    for i = 1:height(TfinalFigures)
        lines(end+1) = "| " + string(TfinalFigures.final_label(i)) + " | " + string(TfinalFigures.caption(i)) + " |";
    end

    lines(end+1) = "";

    lines(end+1) = "## Limitaciones de interpretación";
    lines(end+1) = "";
    lines(end+1) = "Los resultados asociados con CO2 deben interpretarse como una comparación preliminar mientras los factores de emisión permanezcan en condición provisional. Antes de utilizar estos porcentajes como afirmaciones finales, los factores de emisión deberán fijarse con referencias bibliográficas definitivas.";
    lines(end+1) = "";
    lines(end+1) = "La exclusión del modo solar puro del frente formal también debe conservarse como una limitación metodológica explícita. Para evaluar adecuadamente dicho modo se requiere una formulación específica basada en la ventana solar diaria, la irradiancia disponible y la razón de humedad alcanzada durante ese intervalo.";
    lines(end+1) = "";

    lines(end+1) = "## Síntesis de resultados";
    lines(end+1) = "";
    lines(end+1) = "Los resultados de la optimización triobjetivo respaldan la selección de H2 como condición de operación híbrida recomendada. H2 no es un óptimo extremo, sino una solución balanceada que cumple el criterio de secado y mejora simultáneamente costo específico y emisiones específicas de CO2 respecto a la referencia con gas LP. Las soluciones H1 y H4 delimitan extremos no admisibles por humedad, mientras que H9 representa el extremo de secado con penalización económica y ambiental. Esta estructura del frente justifica la selección de H2 como compromiso operativo del sistema híbrido.";
    lines(end+1) = "";

    txt = strjoin(lines,newline);
end

function md = compose_close_report_md( ...
    reviewMat,pkgMat,outFinalMd,outFinalTxt, ...
    TfinalValues,TfinalFigures,TkeyThesis)

    lines = strings(0,1);

    lines(end+1) = "# FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES_CLOSE_REPORT";
    lines(end+1) = "";

    lines(end+1) = "## Entradas";
    lines(end+1) = "";
    lines(end+1) = "- Revisión editorial v96u: `" + string(reviewMat) + "`";
    lines(end+1) = "- Paquete final v96s: `" + string(pkgMat) + "`";
    lines(end+1) = "";

    lines(end+1) = "## Salidas";
    lines(end+1) = "";
    lines(end+1) = "- Sección final MD: `" + string(outFinalMd) + "`";
    lines(end+1) = "- Sección final TXT: `" + string(outFinalTxt) + "`";
    lines(end+1) = "";

    lines(end+1) = "## Resultado principal";
    lines(end+1) = "";
    lines(end+1) = "| Campo | Valor |";
    lines(end+1) = "|---|---:|";
    lines(end+1) = "| Solución recomendada | `" + string(TfinalValues.recommended_solution_id(1)) + "` |";
    lines(end+1) = "| MR H2 | " + string(sprintf('%.12g',TfinalValues.H2_MR(1))) + " |";
    lines(end+1) = "| Costo específico H2 | " + string(sprintf('%.12g',TfinalValues.H2_cost_specific(1))) + " |";
    lines(end+1) = "| CO2 específico H2 | " + string(sprintf('%.12g',TfinalValues.H2_CO2_specific(1))) + " |";
    lines(end+1) = "| Reducción MR vs gas LP (%) | " + string(sprintf('%.12g',TfinalValues.MR_reduction_pct_vs_gasLP(1))) + " |";
    lines(end+1) = "| Reducción costo vs gas LP (%) | " + string(sprintf('%.12g',TfinalValues.cost_reduction_pct_vs_gasLP(1))) + " |";
    lines(end+1) = "| Reducción CO2 vs gas LP (%) | " + string(sprintf('%.12g',TfinalValues.CO2_reduction_pct_vs_gasLP(1))) + " |";
    lines(end+1) = "";

    lines(end+1) = "## Figuras";
    lines(end+1) = "";
    lines(end+1) = "| Figura | Caption |";
    lines(end+1) = "|---|---|";

    for i = 1:height(TfinalFigures)
        lines(end+1) = "| " + string(TfinalFigures.final_label(i)) + " | " + string(TfinalFigures.caption(i)) + " |";
    end

    lines(end+1) = "";

    lines(end+1) = "## Soluciones clave";
    lines(end+1) = "";
    lines(end+1) = "| Solución | Interpretación |";
    lines(end+1) = "|---|---|";

    for i = 1:height(TkeyThesis)
        lines(end+1) = "| `" + string(TkeyThesis.solution_id(i)) + "` | " + string(TkeyThesis.interpretacion_tesis(i)) + " |";
    end

    lines(end+1) = "";

    lines(end+1) = "## Dictamen";
    lines(end+1) = "";
    lines(end+1) = "La versión final en español para tesis queda lista para revisión humana e integración al documento. No se ejecutó GA ni simulación mecanística en este paso.";
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