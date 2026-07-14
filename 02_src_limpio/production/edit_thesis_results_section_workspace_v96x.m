function editout = edit_thesis_results_section_workspace_v96x()
% EDIT_THESIS_RESULTS_SECTION_WORKSPACE_v96x
% 9.6x — EDIT-THESIS-RESULTS-SECTION-IN-WORKSPACE-001
%
% Objetivo:
%   Editar la sección viva de resultados dentro de:
%
%       06_manuscript/thesis_ES/sections/
%
%   Este paso NO recalcula resultados. Solo genera una versión editorial
%   refinada v2 de la sección de resultados para tesis.
%
% Este script:
%   - NO ejecuta GA.
%   - NO llama modelo.
%   - NO llama función objetivo.
%   - NO modifica 05_runs.
%   - NO modifica fuentes protegidas.
%   - Lee v1 y genera v2 editable en 06_manuscript.
%
% Uso:
%   editout = edit_thesis_results_section_workspace_v96x();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Localizar workspace de tesis
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

    mkdir_if_needed(sectionsDir);
    mkdir_if_needed(notesDir);

    % ---------------------------------------------------------------------
    % Archivos de entrada del workspace
    % ---------------------------------------------------------------------
    sectionV1 = fullfile(sectionsDir,'01_resultados_optimizacion_triobjetivo_v1.md');
    workspaceMat = fullfile(traceDir,'MANUSCRIPT_INTEGRATION_WORKSPACE_v96w.mat');
    finalESMat = fullfile(traceDir,'FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES.mat');
    readmeMd = fullfile(thesisRoot,'README_THESIS_ES_WORKSPACE.md');

    if ~isfile(sectionV1)
        error('No existe sección editable v1: %s', sectionV1);
    end

    if ~isfile(workspaceMat)
        error('No existe workspace MAT v96w: %s', workspaceMat);
    end

    if ~isfile(finalESMat)
        error('No existe MAT final ES v96v: %s', finalESMat);
    end

    W = load(workspaceMat);
    F = load(finalESMat);

    if ~strcmp(string(W.diagnosis),"MANUSCRIPT_INTEGRATION_WORKSPACE_PASS")
        error('El workspace v96w no está en PASS. Diagnosis: %s', string(W.diagnosis));
    end

    if ~strcmp(string(F.diagnosis),"FINAL_SPANISH_THESIS_RESULTS_SECTION_PASS")
        error('La sección final v96v_ES no está en PASS. Diagnosis: %s', string(F.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Datos validados
    % ---------------------------------------------------------------------
    TfinalValues = F.TfinalValues;
    TfinalFigures = F.TfinalFigures;
    TkeyThesis = F.TkeyThesis;

    H2_MR = TfinalValues.H2_MR(1);
    H2_cost = TfinalValues.H2_cost_specific(1);
    H2_CO2 = TfinalValues.H2_CO2_specific(1);

    gasLP_MR = TfinalValues.gasLP_MR(1);
    gasLP_cost = TfinalValues.gasLP_cost_specific(1);
    gasLP_CO2 = TfinalValues.gasLP_CO2_specific(1);

    MRred = TfinalValues.MR_reduction_pct_vs_gasLP(1);
    CostRed = TfinalValues.cost_reduction_pct_vs_gasLP(1);
    CO2Red = TfinalValues.CO2_reduction_pct_vs_gasLP(1);

    m_max = TfinalValues.m_max(1);
    T_min = TfinalValues.T_min(1);
    r_div2 = TfinalValues.r_div2(1);
    t_rec_ini = TfinalValues.t_rec_ini(1);

    MR_acceptance = TfinalValues.MR_acceptance(1);

    % ---------------------------------------------------------------------
    % Crear versión refinada v2
    % ---------------------------------------------------------------------
    sectionV2 = fullfile(sectionsDir,'01_resultados_optimizacion_triobjetivo_v2_editado.md');
    sectionV2Txt = fullfile(sectionsDir,'01_resultados_optimizacion_triobjetivo_v2_editado.txt');

    editedText = compose_edited_results_section_v2( ...
        m_max,T_min,r_div2,t_rec_ini, ...
        H2_MR,H2_cost,H2_CO2, ...
        gasLP_MR,gasLP_cost,gasLP_CO2, ...
        MR_acceptance,MRred,CostRed,CO2Red, ...
        TkeyThesis,TfinalFigures);

    fid = fopen(sectionV2,'w');
    if fid < 0
        error('No se pudo crear sectionV2: %s', sectionV2);
    end
    fprintf(fid,'%s',editedText);
    fclose(fid);

    fid = fopen(sectionV2Txt,'w');
    if fid < 0
        error('No se pudo crear sectionV2Txt: %s', sectionV2Txt);
    end
    fprintf(fid,'%s',editedText);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Crear archivo de comparación editorial
    % ---------------------------------------------------------------------
    originalText = string(fileread(sectionV1));

    editorialNotes = compose_editorial_notes_v96x(sectionV1,sectionV2);

    notesMd = fullfile(notesDir,'NOTAS_CAMBIOS_v96x_RESULTADOS.md');

    fid = fopen(notesMd,'w');
    if fid < 0
        error('No se pudo crear notesMd: %s', notesMd);
    end
    fprintf(fid,'%s',editorialNotes);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Actualizar master MD sin destruir v1
    % ---------------------------------------------------------------------
    masterV2 = fullfile(thesisRoot,'TESIS_RESULTADOS_MASTER_v2.md');

    fid = fopen(masterV2,'w');
    if fid < 0
        error('No se pudo crear masterV2: %s', masterV2);
    end

    fprintf(fid,'# Resultados — tesis\n\n');
    fprintf(fid,'> Archivo maestro v2 generado por 9.6x. Fuente editable: `sections/01_resultados_optimizacion_triobjetivo_v2_editado.md`.\n\n');
    fprintf(fid,'%s\n',editedText);

    fclose(fid);

    % ---------------------------------------------------------------------
    % Tabla de cambios editoriales
    % ---------------------------------------------------------------------
    Tchanges = table();
    Tchanges.item = [ ...
        "Estructura"; ...
        "Tono"; ...
        "gas LP"; ...
        "H2"; ...
        "CO2"; ...
        "Solar"; ...
        "Figuras"; ...
        "Tabla comparativa"; ...
        "Variables"; ...
        "Cierre"];
    Tchanges.change_applied = [ ...
        "Se mantuvo una estructura de resultados por alcance, solución, comparación, interpretación, figuras, limitaciones y síntesis."; ...
        "Se ajustó a tono de tesis: técnico, sobrio, sin declarar óptimo universal."; ...
        "Se conserva gas LP en narrativa y gasLP solo como referencia de código cuando sea necesario."; ...
        "Se presenta H2 como solución de compromiso admisible del frente híbrido."; ...
        "Se mantiene caveat de comparación preliminar por factores de emisión pendientes."; ...
        "Se mantiene exclusión solar como decisión metodológica por necesidad de ventana solar."; ...
        "Se conserva numeración Figura 1, Figura 2 y Figura 3."; ...
        "Se conserva tabla gas LP vs H2 como síntesis numérica."; ...
        "Se preservan variables m_max, T_min, r_div2 y t_rec_ini con notación de código."; ...
        "Se cierra con lógica de trade-off H1/H4/H9/H2."];
    Tchanges.priority = [ ...
        "high"; ...
        "high"; ...
        "medium"; ...
        "high"; ...
        "high"; ...
        "high"; ...
        "medium"; ...
        "medium"; ...
        "medium"; ...
        "high"];

    changesCsv = fullfile(tablesDir,'edicion_resultados_v96x_cambios.csv');
    writetable(Tchanges,changesCsv);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};
    checks{end+1,1} = check_row("X01","Workspace v96w loaded",true,string(workspaceMat));
    checks{end+1,1} = check_row("X02","Workspace v96w PASS",strcmp(string(W.diagnosis),"MANUSCRIPT_INTEGRATION_WORKSPACE_PASS"),string(W.diagnosis));
    checks{end+1,1} = check_row("X03","Final ES v96v loaded",true,string(finalESMat));
    checks{end+1,1} = check_row("X04","Final ES v96v PASS",strcmp(string(F.diagnosis),"FINAL_SPANISH_THESIS_RESULTS_SECTION_PASS"),string(F.diagnosis));
    checks{end+1,1} = check_row("X05","Section v1 exists",isfile(sectionV1),string(sectionV1));
    checks{end+1,1} = check_row("X06","Section v2 MD created",isfile(sectionV2),string(sectionV2));
    checks{end+1,1} = check_row("X07","Section v2 TXT created",isfile(sectionV2Txt),string(sectionV2Txt));
    checks{end+1,1} = check_row("X08","Master v2 created",isfile(masterV2),string(masterV2));
    checks{end+1,1} = check_row("X09","Editorial notes created",isfile(notesMd),string(notesMd));
    checks{end+1,1} = check_row("X10","Changes table created",isfile(changesCsv),string(changesCsv));
    checks{end+1,1} = check_row("X11","H2 values preserved",contains(editedText,string(sprintf('%.6g',H2_MR))) && contains(editedText,string(sprintf('%.6g',H2_cost))),"H2 MR and cost found.");
    checks{end+1,1} = check_row("X12","gas LP prose retained",contains(editedText,"gas LP"),"gas LP found.");
    checks{end+1,1} = check_row("X13","CO2 caveat retained",contains(editedText,"factores de emisión"),"CO2 caveat found.");
    checks{end+1,1} = check_row("X14","Solar caveat retained",contains(editedText,"ventana solar"),"Solar caveat found.");
    checks{end+1,1} = check_row("X15","Figure numbering retained",contains(editedText,"Figura 1") && contains(editedText,"Figura 2") && contains(editedText,"Figura 3"),"Figures 1-3 found.");
    checks{end+1,1} = check_row("X16","No GA executed",true,"No gamultiobj call.");
    checks{end+1,1} = check_row("X17","No mechanistic rerun",true,"No objective/model call.");
    checks{end+1,1} = check_row("X18","No 05_runs modified",true,"Only 06_manuscript edited.");

    Tchecks = struct2table(vertcat(checks{:}));

    edit_pass = all(Tchecks.pass);

    if edit_pass
        diagnosis = "EDIT_THESIS_RESULTS_SECTION_WORKSPACE_PASS";
        decision = "THESIS_RESULTS_SECTION_V2_READY_FOR_HUMAN_REVIEW";
        next_step = "9.6y — THESIS-RESULTS-SECTION-HUMAN-REVIEW-OR-EXPORT-001";
    else
        diagnosis = "EDIT_THESIS_RESULTS_SECTION_WORKSPACE_REQUIRES_REVIEW";
        decision = "REVIEW_FAILED_EDIT_CHECKS";
        next_step = "Review failed checks before using v2.";
    end

    checksCsv = fullfile(tablesDir,'edicion_resultados_v96x_checks.csv');
    writetable(Tchecks,checksCsv);

    % ---------------------------------------------------------------------
    % Guardar MAT
    % ---------------------------------------------------------------------
    editMat = fullfile(traceDir,'EDIT_THESIS_RESULTS_SECTION_WORKSPACE_v96x.mat');

    save(editMat, ...
        'diagnosis','decision','next_step', ...
        'rootDir','thesisRoot','sectionsDir','tablesDir','traceDir','notesDir', ...
        'workspaceMat','finalESMat','sectionV1','sectionV2','sectionV2Txt','masterV2','notesMd','changesCsv','checksCsv','editMat', ...
        'TfinalValues','TfinalFigures','TkeyThesis','Tchanges','Tchecks', ...
        'originalText','editedText');

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    editout = struct();
    editout.status = 'EDIT_THESIS_RESULTS_SECTION_WORKSPACE_COMPLETED';
    editout.diagnosis = diagnosis;
    editout.decision = decision;
    editout.next_step = next_step;

    editout.thesisRoot = thesisRoot;
    editout.sectionV1 = sectionV1;
    editout.sectionV2 = sectionV2;
    editout.sectionV2Txt = sectionV2Txt;
    editout.masterV2 = masterV2;
    editout.notesMd = notesMd;
    editout.changesCsv = changesCsv;
    editout.checksCsv = checksCsv;
    editout.editMat = editMat;

    editout.Tchanges = Tchanges;
    editout.Tchecks = Tchecks;

    disp('=== EDIT_THESIS_RESULTS_SECTION_WORKSPACE_v96x ===')
    disp(editout.status)
    disp('=== DIAGNOSIS ===')
    disp(editout.diagnosis)
    disp('=== DECISION ===')
    disp(editout.decision)
    disp('=== NEXT STEP ===')
    disp(editout.next_step)
    disp('=== SECTION V1 ===')
    disp(editout.sectionV1)
    disp('=== SECTION V2 ===')
    disp(editout.sectionV2)
    disp('=== MASTER V2 ===')
    disp(editout.masterV2)
    disp('=== NOTES ===')
    disp(editout.notesMd)
    disp('=== CHANGES ===')
    disp(editout.Tchanges)
    disp('=== CHECKS ===')
    disp(editout.Tchecks)

end

% =========================================================================
% Text composition
% =========================================================================

function txt = compose_edited_results_section_v2( ...
    m_max,T_min,r_div2,t_rec_ini, ...
    H2_MR,H2_cost,H2_CO2, ...
    gasLP_MR,gasLP_cost,gasLP_CO2, ...
    MR_acceptance,MRred,CostRed,CO2Red, ...
    TkeyThesis,TfinalFigures)

    lines = strings(0,1);

    lines(end+1) = "# Resultados de la optimización triobjetivo";
    lines(end+1) = "";

    lines(end+1) = "## Alcance de los resultados";
    lines(end+1) = "";
    lines(end+1) = "En esta sección se presentan los resultados de la optimización triobjetivo aplicada al modo de operación híbrido del túnel de deshidratación. La evaluación considera tres indicadores: la razón de humedad final (`MR`), el costo específico y las emisiones específicas de CO2. El modo con gas LP se utiliza como referencia directa de comparación, ya que permite contrastar el desempeño de la solución híbrida seleccionada con una operación basada exclusivamente en aporte auxiliar.";
    lines(end+1) = "";
    lines(end+1) = "El modo solar puro no se incluye dentro del frente formal de Pareto. Esta decisión responde a una restricción metodológica: la operación solar está condicionada por la disponibilidad finita de irradiancia durante el día, por lo que requiere una formulación específica basada en una ventana solar. En consecuencia, su comparación directa con los modos híbrido y gas LP no sería equivalente dentro de la misma formulación de optimización.";
    lines(end+1) = "";

    lines(end+1) = "## Solución híbrida recomendada";
    lines(end+1) = "";
    lines(end+1) = "La solución seleccionada dentro del frente híbrido fue H2. Esta solución debe interpretarse como un compromiso operativo, no como un óptimo absoluto de una sola función objetivo. Su relevancia se debe a que cumple el criterio de secado y, simultáneamente, mejora los indicadores de costo y emisiones respecto a la referencia con gas LP.";
    lines(end+1) = "";
    lines(end+1) = "Las variables de decisión asociadas con H2 fueron `m_max = " + string(sprintf('%.6g',m_max)) + "`, `T_min = " + string(sprintf('%.6g',T_min)) + "`, `r_div2 = " + string(sprintf('%.6g',r_div2)) + "` y `t_rec_ini = " + string(sprintf('%.6g',t_rec_ini)) + "`. Con esta configuración se obtuvo una razón de humedad final `MR = " + string(sprintf('%.6g',H2_MR)) + "`, menor que el umbral de aceptación establecido (`MR < " + string(sprintf('%.3g',MR_acceptance)) + "`).";
    lines(end+1) = "";
    lines(end+1) = "Además, H2 presentó un costo específico de `" + string(sprintf('%.6g',H2_cost)) + "` y emisiones específicas de CO2 de `" + string(sprintf('%.6g',H2_CO2)) + "`. Estos valores permiten considerar la solución como operativamente admisible y, al mismo tiempo, favorable frente al modo de referencia.";
    lines(end+1) = "";

    lines(end+1) = "## Comparación contra la referencia con gas LP";
    lines(end+1) = "";
    lines(end+1) = "La referencia con gas LP produjo `MR = " + string(sprintf('%.6g',gasLP_MR)) + "`, costo específico de `" + string(sprintf('%.6g',gasLP_cost)) + "` y emisiones específicas de CO2 de `" + string(sprintf('%.6g',gasLP_CO2)) + "`. En comparación, H2 redujo la razón de humedad final en `" + string(sprintf('%.4g',MRred)) + " %`, el costo específico en `" + string(sprintf('%.4g',CostRed)) + " %` y las emisiones específicas de CO2 en `" + string(sprintf('%.4g',CO2Red)) + " %`.";
    lines(end+1) = "";
    lines(end+1) = "La comparación se resume en la Tabla 1. Esta tabla concentra el resultado cuantitativo principal de la optimización formal, ya que muestra que la solución híbrida recomendada mejora simultáneamente los tres indicadores respecto al caso de gas LP.";
    lines(end+1) = "";
    lines(end+1) = "**Tabla 1. Comparación entre la referencia con gas LP y la solución híbrida H2.**";
    lines(end+1) = "";
    lines(end+1) = "| Indicador | Referencia gas LP | Solución H2 | Cambio relativo de H2 |";
    lines(end+1) = "|---|---:|---:|---:|";
    lines(end+1) = "| Razón de humedad final, `MR` | " + string(sprintf('%.6g',gasLP_MR)) + " | " + string(sprintf('%.6g',H2_MR)) + " | -" + string(sprintf('%.4g',MRred)) + " % |";
    lines(end+1) = "| Costo específico | " + string(sprintf('%.6g',gasLP_cost)) + " | " + string(sprintf('%.6g',H2_cost)) + " | -" + string(sprintf('%.4g',CostRed)) + " % |";
    lines(end+1) = "| Emisiones específicas de CO2 | " + string(sprintf('%.6g',gasLP_CO2)) + " | " + string(sprintf('%.6g',H2_CO2)) + " | -" + string(sprintf('%.4g',CO2Red)) + " % |";
    lines(end+1) = "";

    lines(end+1) = "## Interpretación de soluciones representativas";
    lines(end+1) = "";
    lines(end+1) = "La estructura del frente triobjetivo muestra que las soluciones extremas no son necesariamente las más convenientes para operación. H1 se ubica en la región de menor CO2 específico, pero no cumple el criterio de humedad. H4 corresponde a la región de menor costo específico, aunque también resulta inadmisible por humedad. H9 alcanza la menor razón de humedad final; sin embargo, esta mejora de secado se obtiene con mayor costo específico y mayores emisiones específicas de CO2 que la referencia con gas LP.";
    lines(end+1) = "";
    lines(end+1) = "Por ello, H2 es la opción más defendible dentro del frente formal: no minimiza individualmente todos los objetivos, pero sí ofrece una condición admisible de secado con reducciones simultáneas de costo y CO2 respecto a la referencia.";
    lines(end+1) = "";
    lines(end+1) = "**Tabla 2. Interpretación de soluciones representativas del frente híbrido.**";
    lines(end+1) = "";
    lines(end+1) = "| Solución | Interpretación |";
    lines(end+1) = "|---|---|";

    for i = 1:height(TkeyThesis)
        lines(end+1) = "| `" + string(TkeyThesis.solution_id(i)) + "` | " + string(TkeyThesis.interpretacion_tesis(i)) + " |";
    end

    lines(end+1) = "";

    lines(end+1) = "## Interpretación gráfica";
    lines(end+1) = "";
    lines(end+1) = "La Figura 1 presenta el frente triobjetivo del modo híbrido. En esta representación, la razón de humedad final y el costo específico se muestran en los ejes, mientras que las emisiones específicas de CO2 se incorporan mediante el tamaño del marcador. Esto permite comparar, en una sola gráfica, la condición de secado, el costo y la tendencia ambiental de las soluciones formales.";
    lines(end+1) = "";
    lines(end+1) = "La Figura 2 compara la referencia con gas LP y la solución H2. Esta figura sintetiza el resultado más importante: la solución híbrida recomendada reduce simultáneamente `MR`, costo específico y emisiones específicas de CO2.";
    lines(end+1) = "";
    lines(end+1) = "La Figura 3 muestra la ubicación de las soluciones en el espacio de variables de decisión definido por `T_min`, `r_div2` y `t_rec_ini`. Esta gráfica no debe leerse como una superficie de respuesta, sino como una representación del espacio operativo explorado por la optimización formal.";
    lines(end+1) = "";
    lines(end+1) = "**Pies de figura sugeridos:**";
    lines(end+1) = "";
    lines(end+1) = "| Figura | Pie de figura |";
    lines(end+1) = "|---|---|";

    for i = 1:height(TfinalFigures)
        lines(end+1) = "| " + string(TfinalFigures.final_label(i)) + " | " + string(TfinalFigures.caption(i)) + " |";
    end

    lines(end+1) = "";

    lines(end+1) = "## Limitaciones";
    lines(end+1) = "";
    lines(end+1) = "Los resultados de CO2 deben interpretarse como una comparación preliminar mientras los factores de emisión permanezcan pendientes de fijación bibliográfica definitiva. Por tanto, los porcentajes de reducción de CO2 son adecuados para comparar internamente las soluciones del frente y discutir la metodología, pero no deben presentarse como afirmaciones finales sin respaldar los factores de emisión empleados.";
    lines(end+1) = "";
    lines(end+1) = "Asimismo, la exclusión del modo solar puro debe mantenerse como una limitación metodológica explícita. Su evaluación requiere una formulación específica basada en la ventana solar diaria, la irradiancia disponible y la humedad alcanzada durante ese intervalo.";
    lines(end+1) = "";

    lines(end+1) = "## Síntesis";
    lines(end+1) = "";
    lines(end+1) = "La optimización triobjetivo permitió identificar H2 como la solución híbrida recomendada. Esta solución cumple el criterio de secado y reduce simultáneamente la razón de humedad final, el costo específico y las emisiones específicas de CO2 respecto a la referencia con gas LP. El análisis de las soluciones representativas confirma que H1 y H4 corresponden a extremos no admisibles por humedad, mientras que H9 intensifica el secado a costa de mayores costo y emisiones. En conjunto, estos resultados justifican seleccionar H2 como compromiso operativo del sistema híbrido.";
    lines(end+1) = "";

    txt = strjoin(lines,newline);
end

function notes = compose_editorial_notes_v96x(sectionV1,sectionV2)

    lines = strings(0,1);

    lines(end+1) = "# NOTAS_CAMBIOS_v96x_RESULTADOS";
    lines(end+1) = "";
    lines(end+1) = "## Archivos";
    lines(end+1) = "";
    lines(end+1) = "- Versión base: `" + string(sectionV1) + "`";
    lines(end+1) = "- Versión editada: `" + string(sectionV2) + "`";
    lines(end+1) = "";

    lines(end+1) = "## Cambios aplicados";
    lines(end+1) = "";
    lines(end+1) = "- Se refinó el tono para tesis.";
    lines(end+1) = "- Se evitó presentar H2 como óptimo universal.";
    lines(end+1) = "- Se reforzó que H2 es solución de compromiso.";
    lines(end+1) = "- Se conservaron los valores numéricos validados.";
    lines(end+1) = "- Se mantuvo la distinción entre `gas LP` en narrativa y `gasLP` como etiqueta de código.";
    lines(end+1) = "- Se mantuvo el caveat de CO2 por factores de emisión pendientes.";
    lines(end+1) = "- Se mantuvo el caveat solar como restricción metodológica.";
    lines(end+1) = "- Se propusieron Tabla 1 y Tabla 2 como tablas formales de tesis.";
    lines(end+1) = "- Se conservaron Figura 1, Figura 2 y Figura 3.";
    lines(end+1) = "";

    lines(end+1) = "## Pendiente humano";
    lines(end+1) = "";
    lines(end+1) = "Revisar unidades exactas de costo específico y CO2 específico antes de integrar al documento completo.";
    lines(end+1) = "";

    notes = strjoin(lines,newline);
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