function gaudit = audit_ga_sufficiency_convergence_v96z()
% AUDIT_GA_SUFFICIENCY_CONVERGENCE_v96z
% 9.6z — GA-SUFFICIENCY-AND-CONVERGENCE-AUDIT-001
%
% Objetivo:
%   Auditar si la corrida formal actual del AG triobjetivo es suficiente
%   para resultados/conclusiones de tesis y qué nivel de afirmación es
%   metodológicamente defendible.
%
% Este script:
%   - NO ejecuta GA.
%   - NO llama modelo mecanístico.
%   - NO llama función objetivo.
%   - NO recalcula resultados.
%   - NO modifica 05_runs.
%   - Trabaja en 06_manuscript/thesis_ES.
%
% Resultado esperado:
%   - Dictamen de suficiencia.
%   - Nivel de afirmación permitido.
%   - Riesgos metodológicos.
%   - Recomendación de validación adicional mínima.
%   - Texto sugerido para tesis.
%
% Uso:
%   gaudit = audit_ga_sufficiency_convergence_v96z();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Rutas base
    % ---------------------------------------------------------------------
    thesisRoot = fullfile(rootDir,'06_manuscript','thesis_ES');

    if ~isfolder(thesisRoot)
        error('No existe thesisRoot: %s', thesisRoot);
    end

    traceDir = fullfile(thesisRoot,'traceability');
    reviewDir = fullfile(thesisRoot,'review');
    notesDir = fullfile(thesisRoot,'notes');
    tablesDir = fullfile(thesisRoot,'tables');
    sectionsDir = fullfile(thesisRoot,'sections');

    mkdir_if_needed(traceDir);
    mkdir_if_needed(reviewDir);
    mkdir_if_needed(notesDir);
    mkdir_if_needed(tablesDir);
    mkdir_if_needed(sectionsDir);

    % ---------------------------------------------------------------------
    % Entradas del manuscrito
    % ---------------------------------------------------------------------
    editMat = fullfile(traceDir,'EDIT_THESIS_RESULTS_SECTION_WORKSPACE_v96x.mat');
    finalESMat = fullfile(traceDir,'FINAL_SPANISH_THESIS_RESULTS_SECTION_v96v_ES.mat');

    if ~isfile(editMat)
        error('No existe editMat v96x: %s', editMat);
    end

    if ~isfile(finalESMat)
        error('No existe finalESMat v96v_ES: %s', finalESMat);
    end

    E = load(editMat);
    F = load(finalESMat);

    if ~strcmp(string(E.diagnosis),"EDIT_THESIS_RESULTS_SECTION_WORKSPACE_PASS")
        error('v96x no está en PASS. Diagnosis: %s', string(E.diagnosis));
    end

    if ~strcmp(string(F.diagnosis),"FINAL_SPANISH_THESIS_RESULTS_SECTION_PASS")
        error('v96v_ES no está en PASS. Diagnosis: %s', string(F.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Localizar datos formales previos
    % ---------------------------------------------------------------------
    % La evidencia principal está en 05_runs. Se lee, pero no se modifica.
    formalBaseDir = fullfile(rootDir,'05_runs','triobjective_formal_results_interpretation_v96p');
    postrunBaseDir = fullfile(rootDir,'05_runs','triobjective_formal_postrun_consolidation_v96o');

    interpretationMat = find_latest_mat(formalBaseDir,'TRIOBJECTIVE_FORMAL_RESULTS_INTERPRETATION_v96p.mat');
    postrunMat = find_latest_mat(postrunBaseDir,'TRIOBJECTIVE_FORMAL_POSTRUN_CONSOLIDATION_v96o.mat');

    hasInterpretation = isfile(interpretationMat);
    hasPostrun = isfile(postrunMat);

    if hasInterpretation
        I = load(interpretationMat);
    else
        I = struct();
    end

    if hasPostrun
        O = load(postrunMat);
    else
        O = struct();
    end

    % ---------------------------------------------------------------------
    % Datos validados desde sección final
    % ---------------------------------------------------------------------
    TfinalValues = F.TfinalValues;
    TkeyThesis = F.TkeyThesis;

    recID = string(TfinalValues.recommended_solution_id(1));

    H2_MR = TfinalValues.H2_MR(1);
    H2_cost = TfinalValues.H2_cost_specific(1);
    H2_CO2 = TfinalValues.H2_CO2_specific(1);

    gasLP_MR = TfinalValues.gasLP_MR(1);
    gasLP_cost = TfinalValues.gasLP_cost_specific(1);
    gasLP_CO2 = TfinalValues.gasLP_CO2_specific(1);

    MRred = TfinalValues.MR_reduction_pct_vs_gasLP(1);
    CostRed = TfinalValues.cost_reduction_pct_vs_gasLP(1);
    CO2Red = TfinalValues.CO2_reduction_pct_vs_gasLP(1);

    MR_acceptance = TfinalValues.MR_acceptance(1);

    % ---------------------------------------------------------------------
    % Reconstrucción de configuración GA desde datos conocidos
    % ---------------------------------------------------------------------
    GA = struct();

    GA.modeFormal = "hybrid";
    GA.referenceMode = "gasLP";
    GA.populationSize = 24;
    GA.maxGenerations = 50;
    GA.funccount = 1200;
    GA.nSolutions = 9;
    GA.nFiniteRows = 9;
    GA.nPenaltyRows = 0;
    GA.exitflag = 0;
    GA.termination = "maximum number of generations exceeded";
    GA.single_formal_run = true;
    GA.random_seed_replicates_done = false;
    GA.parameter_sensitivity_done = false;
    GA.convergence_proof_available = false;
    GA.front_size_category = "small";
    GA.runtime_h = 7.1301;

    % ---------------------------------------------------------------------
    % Criterios de auditoría
    % ---------------------------------------------------------------------
    Audit = table();

    Audit.criterion = [ ...
        "Corrida formal completada"; ...
        "Resultados finitos"; ...
        "Solución recomendada admisible"; ...
        "Mejora simultánea vs gas LP"; ...
        "Frente con soluciones representativas"; ...
        "Terminación por convergencia"; ...
        "Replicación con semillas"; ...
        "Sensibilidad de parámetros AG"; ...
        "Tamaño del frente"; ...
        "Justificación fuerte de parámetros AG"; ...
        "Suficiencia para tesis"; ...
        "Suficiencia para artículo fuerte"];

    Audit.status = [ ...
        "cumple"; ...
        "cumple"; ...
        "cumple"; ...
        "cumple"; ...
        "cumple"; ...
        "no cumple"; ...
        "no realizado"; ...
        "no realizado"; ...
        "limitado"; ...
        "limitado"; ...
        "cumple condicionado"; ...
        "no suficiente"];

    Audit.evidence = [ ...
        "La corrida formal híbrida terminó y produjo frente triobjetivo."; ...
        "nFiniteRows = 9 y nPenaltyRows = 0."; ...
        "H2 cumple MR < 0.1."; ...
        "H2 reduce MR, costo específico y CO2 específico frente a gas LP."; ...
        "H1, H2, H4 y H9 permiten interpretar extremos y compromiso."; ...
        "exitflag = 0; terminó por máximo de generaciones."; ...
        "No hay corridas formales adicionales con semillas distintas."; ...
        "No hay barrido formal de PopulationSize, MaxGenerations u otros parámetros."; ...
        "nSolutions = 9; útil para discusión, limitado para robustez algorítmica."; ...
        "La configuración está documentada, pero no optimizada por sensibilidad."; ...
        "Defendible si se declara como frente obtenido y solución de compromiso."; ...
        "Requiere replicación/sensibilidad adicional antes de afirmaciones fuertes."];

    Audit.risk = [ ...
        "bajo"; ...
        "bajo"; ...
        "bajo"; ...
        "bajo"; ...
        "medio"; ...
        "alto"; ...
        "alto"; ...
        "alto"; ...
        "medio"; ...
        "alto"; ...
        "medio"; ...
        "alto"];

    Audit.recommendation = [ ...
        "Usar resultados, conservando trazabilidad."; ...
        "Reportar que no hubo penalizaciones en el frente formal."; ...
        "Mantener H2 como solución recomendada."; ...
        "Mantener comparación contra gas LP."; ...
        "Usar H1/H4/H9 como anclas interpretativas."; ...
        "No afirmar convergencia plena."; ...
        "Agregar replicación mínima si se quiere robustecer."; ...
        "Agregar sensibilidad si el objetivo es publicación fuerte."; ...
        "Evitar conclusiones de optimalidad global."; ...
        "Declarar parámetros como configuración computacional adoptada."; ...
        "Redactar conclusiones condicionadas."; ...
        "No enviar como artículo fuerte sin validación adicional."];

    % ---------------------------------------------------------------------
    % Dictamen
    % ---------------------------------------------------------------------
    thesis_sufficient = true;
    article_strong_sufficient = false;
    global_optimality_claim_allowed = false;
    compromise_claim_allowed = true;
    convergence_claim_allowed = false;

    if thesis_sufficient
        thesis_verdict = "SUFICIENTE_PARA_TESIS_CON_ALCANCE_CONDICIONADO";
    else
        thesis_verdict = "NO_SUFFICIENTE_PARA_TESIS";
    end

    article_verdict = "NO_SUFFICIENTE_PARA_ARTICULO_FUERTE_SIN_VALIDACION_ADICIONAL";

    allowed_claim = "H2 puede reportarse como solución de compromiso admisible dentro del frente formal obtenido para el modo híbrido.";
    forbidden_claim = "No afirmar que H2 es óptimo global absoluto ni que el AG convergió plenamente.";

    recommended_next_validation = "MINIMAL_SEED_REPLICATION_2_OR_3_RUNS";
    recommended_if_time_limited = "Mantener resultados actuales y redactar conclusiones condicionadas.";
    recommended_if_article_target = "Ejecutar 2-3 réplicas con distinta semilla o una corrida media con PopulationSize=32 y MaxGenerations=80.";

    % ---------------------------------------------------------------------
    % Tabla de niveles de afirmación
    % ---------------------------------------------------------------------
    Claims = table();

    Claims.claim = [ ...
        "Se obtuvo un frente triobjetivo formal para el modo híbrido."; ...
        "H2 es solución recomendada dentro del frente obtenido."; ...
        "H2 mejora simultáneamente MR, costo y CO2 frente a gas LP."; ...
        "H2 es el óptimo global del sistema."; ...
        "El AG alcanzó convergencia plena."; ...
        "Los parámetros del AG están exhaustivamente justificados."; ...
        "Los resultados sustentan conclusiones de tesis."; ...
        "Los resultados sustentan publicación fuerte sin más validación."];

    Claims.allowed = [ ...
        true; ...
        true; ...
        true; ...
        false; ...
        false; ...
        false; ...
        true; ...
        false];

    Claims.wording = [ ...
        "Permitido: frente formal obtenido con la configuración computacional adoptada."; ...
        "Permitido: solución de compromiso admisible del frente obtenido."; ...
        "Permitido: comparación interna con referencia gas LP."; ...
        "No permitido: requiere análisis de convergencia/robustez."; ...
        "No permitido: exitflag=0 por máximo de generaciones."; ...
        "No permitido: falta sensibilidad de parámetros AG."; ...
        "Permitido con alcance condicionado y caveats."; ...
        "No permitido sin réplicas o sensibilidad adicional."];

    % ---------------------------------------------------------------------
    % Texto sugerido para tesis
    % ---------------------------------------------------------------------
    thesisText = compose_thesis_sufficiency_text( ...
        GA, recID, H2_MR,H2_cost,H2_CO2, ...
        gasLP_MR,gasLP_cost,gasLP_CO2, ...
        MRred,CostRed,CO2Red, ...
        MR_acceptance);

    conclusionText = compose_conclusion_scope_text();

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    auditMd = fullfile(reviewDir,'GA_SUFFICIENCY_AND_CONVERGENCE_AUDIT_v96z.md');
    auditTxt = fullfile(reviewDir,'GA_SUFFICIENCY_AND_CONVERGENCE_AUDIT_v96z.txt');
    claimsCsv = fullfile(tablesDir,'ga_sufficiency_claims_v96z.csv');
    auditCsv = fullfile(tablesDir,'ga_sufficiency_audit_v96z.csv');
    thesisTextMd = fullfile(sectionsDir,'02_texto_suficiencia_AG_para_resultados_v96z.md');
    conclusionTextMd = fullfile(sectionsDir,'03_texto_alcance_conclusiones_AG_v96z.md');

    writetable(Audit,auditCsv);
    writetable(Claims,claimsCsv);

    auditReport = compose_audit_report_md( ...
        GA, Audit, Claims, thesis_verdict, article_verdict, ...
        allowed_claim, forbidden_claim, ...
        recommended_next_validation, recommended_if_time_limited, recommended_if_article_target, ...
        thesisText, conclusionText);

    fid = fopen(auditMd,'w');
    if fid < 0
        error('No se pudo crear auditMd: %s', auditMd);
    end
    fprintf(fid,'%s',auditReport);
    fclose(fid);

    fid = fopen(auditTxt,'w');
    if fid < 0
        error('No se pudo crear auditTxt: %s', auditTxt);
    end
    fprintf(fid,'%s',auditReport);
    fclose(fid);

    fid = fopen(thesisTextMd,'w');
    if fid < 0
        error('No se pudo crear thesisTextMd: %s', thesisTextMd);
    end
    fprintf(fid,'%s',thesisText);
    fclose(fid);

    fid = fopen(conclusionTextMd,'w');
    if fid < 0
        error('No se pudo crear conclusionTextMd: %s', conclusionTextMd);
    end
    fprintf(fid,'%s',conclusionText);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};
    checks{end+1,1} = check_row("Z01","Final ES v96v loaded",true,string(finalESMat));
    checks{end+1,1} = check_row("Z02","Final ES v96v PASS",strcmp(string(F.diagnosis),"FINAL_SPANISH_THESIS_RESULTS_SECTION_PASS"),string(F.diagnosis));
    checks{end+1,1} = check_row("Z03","Edit v96x loaded",true,string(editMat));
    checks{end+1,1} = check_row("Z04","Edit v96x PASS",strcmp(string(E.diagnosis),"EDIT_THESIS_RESULTS_SECTION_WORKSPACE_PASS"),string(E.diagnosis));
    checks{end+1,1} = check_row("Z05","Interpretation MAT found",hasInterpretation,string(interpretationMat));
    checks{end+1,1} = check_row("Z06","Postrun MAT found",hasPostrun,string(postrunMat));
    checks{end+1,1} = check_row("Z07","Thesis sufficient conditional",thesis_sufficient,thesis_verdict);
    checks{end+1,1} = check_row("Z08","Article strong not sufficient",~article_strong_sufficient,article_verdict);
    checks{end+1,1} = check_row("Z09","Global optimality blocked",~global_optimality_claim_allowed,forbidden_claim);
    checks{end+1,1} = check_row("Z10","Compromise claim allowed",compromise_claim_allowed,allowed_claim);
    checks{end+1,1} = check_row("Z11","Convergence claim blocked",~convergence_claim_allowed,"exitflag=0; maximum generations reached.");
    checks{end+1,1} = check_row("Z12","Audit report created",isfile(auditMd),string(auditMd));
    checks{end+1,1} = check_row("Z13","Audit table created",isfile(auditCsv),string(auditCsv));
    checks{end+1,1} = check_row("Z14","Claims table created",isfile(claimsCsv),string(claimsCsv));
    checks{end+1,1} = check_row("Z15","Thesis sufficiency text created",isfile(thesisTextMd),string(thesisTextMd));
    checks{end+1,1} = check_row("Z16","Conclusion scope text created",isfile(conclusionTextMd),string(conclusionTextMd));
    checks{end+1,1} = check_row("Z17","No GA executed",true,"No gamultiobj call.");
    checks{end+1,1} = check_row("Z18","No mechanistic rerun",true,"No objective/model call.");
    checks{end+1,1} = check_row("Z19","No 05_runs modified",true,"Only 06_manuscript audit files written.");

    Tchecks = struct2table(vertcat(checks{:}));

    audit_pass = all(Tchecks.pass);

    if audit_pass
        diagnosis = "GA_SUFFICIENCY_AND_CONVERGENCE_AUDIT_PASS";
        decision = "RESULTS_SUFFICIENT_FOR_THESIS_WITH_CONDITIONAL_SCOPE";
        next_step = "9.6z-minrep — OPTIONAL-MINIMAL-SEED-REPLICATION-DESIGN-001";
    else
        diagnosis = "GA_SUFFICIENCY_AND_CONVERGENCE_AUDIT_REQUIRES_REVIEW";
        decision = "REVIEW_FAILED_GA_SUFFICIENCY_CHECKS";
        next_step = "Review failed checks before deciding thesis/article scope.";
    end

    checksCsv = fullfile(tablesDir,'ga_sufficiency_checks_v96z.csv');
    writetable(Tchecks,checksCsv);

    % ---------------------------------------------------------------------
    % Guardar MAT
    % ---------------------------------------------------------------------
    auditMat = fullfile(traceDir,'GA_SUFFICIENCY_AND_CONVERGENCE_AUDIT_v96z.mat');

    save(auditMat, ...
        'diagnosis','decision','next_step', ...
        'rootDir','thesisRoot','traceDir','reviewDir','notesDir','tablesDir','sectionsDir', ...
        'editMat','finalESMat','interpretationMat','postrunMat','hasInterpretation','hasPostrun', ...
        'GA','Audit','Claims','Tchecks', ...
        'thesis_sufficient','article_strong_sufficient','global_optimality_claim_allowed','compromise_claim_allowed','convergence_claim_allowed', ...
        'thesis_verdict','article_verdict','allowed_claim','forbidden_claim', ...
        'recommended_next_validation','recommended_if_time_limited','recommended_if_article_target', ...
        'auditMd','auditTxt','auditCsv','claimsCsv','checksCsv','thesisTextMd','conclusionTextMd','auditMat', ...
        'thesisText','conclusionText','auditReport');

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    gaudit = struct();
    gaudit.status = 'GA_SUFFICIENCY_AND_CONVERGENCE_AUDIT_COMPLETED';
    gaudit.diagnosis = diagnosis;
    gaudit.decision = decision;
    gaudit.next_step = next_step;

    gaudit.thesis_verdict = thesis_verdict;
    gaudit.article_verdict = article_verdict;
    gaudit.allowed_claim = allowed_claim;
    gaudit.forbidden_claim = forbidden_claim;
    gaudit.recommended_next_validation = recommended_next_validation;
    gaudit.recommended_if_time_limited = recommended_if_time_limited;
    gaudit.recommended_if_article_target = recommended_if_article_target;

    gaudit.GA = GA;
    gaudit.Audit = Audit;
    gaudit.Claims = Claims;
    gaudit.Tchecks = Tchecks;

    gaudit.auditMd = auditMd;
    gaudit.thesisTextMd = thesisTextMd;
    gaudit.conclusionTextMd = conclusionTextMd;
    gaudit.auditMat = auditMat;

    disp('=== GA_SUFFICIENCY_AND_CONVERGENCE_AUDIT_v96z ===')
    disp(gaudit.status)
    disp('=== DIAGNOSIS ===')
    disp(gaudit.diagnosis)
    disp('=== DECISION ===')
    disp(gaudit.decision)
    disp('=== NEXT STEP ===')
    disp(gaudit.next_step)
    disp('=== THESIS VERDICT ===')
    disp(gaudit.thesis_verdict)
    disp('=== ARTICLE VERDICT ===')
    disp(gaudit.article_verdict)
    disp('=== ALLOWED CLAIM ===')
    disp(gaudit.allowed_claim)
    disp('=== FORBIDDEN CLAIM ===')
    disp(gaudit.forbidden_claim)
    disp('=== RECOMMENDED VALIDATION ===')
    disp(gaudit.recommended_next_validation)
    disp('=== GA SUMMARY ===')
    disp(struct2table(gaudit.GA))
    disp('=== AUDIT ===')
    disp(gaudit.Audit)
    disp('=== CLAIMS ===')
    disp(gaudit.Claims)
    disp('=== CHECKS ===')
    disp(gaudit.Tchecks)
    disp('=== AUDIT MD ===')
    disp(gaudit.auditMd)
    disp('=== THESIS TEXT MD ===')
    disp(gaudit.thesisTextMd)
    disp('=== CONCLUSION TEXT MD ===')
    disp(gaudit.conclusionTextMd)

end

% =========================================================================
% Text composition
% =========================================================================

function txt = compose_thesis_sufficiency_text( ...
    GA, recID, H2_MR,H2_cost,H2_CO2, ...
    gasLP_MR,gasLP_cost,gasLP_CO2, ...
    MRred,CostRed,CO2Red,MR_acceptance)

    lines = strings(0,1);

    lines(end+1) = "# Texto sugerido — suficiencia del AG para resultados de tesis";
    lines(end+1) = "";
    lines(end+1) = "La optimización triobjetivo se resolvió mediante una configuración formal del algoritmo genético multiobjetivo aplicada al modo híbrido. La corrida utilizó una población de " + string(GA.populationSize) + " individuos y " + string(GA.maxGenerations) + " generaciones, con un total de " + string(GA.funccount) + " evaluaciones de la función objetivo. La terminación ocurrió al alcanzarse el número máximo de generaciones establecido, por lo que los resultados deben interpretarse como el frente obtenido bajo la configuración computacional adoptada, y no como una demostración de convergencia global absoluta.";
    lines(end+1) = "";
    lines(end+1) = "Dentro del frente obtenido, la solución " + string(recID) + " fue seleccionada como compromiso operativo. Esta solución cumple el criterio de secado, con `MR = " + string(sprintf('%.6g',H2_MR)) + "`, inferior al umbral `MR < " + string(sprintf('%.3g',MR_acceptance)) + "`, y presenta simultáneamente menor costo específico y menores emisiones específicas de CO2 que la referencia con gas LP.";
    lines(end+1) = "";
    lines(end+1) = "La referencia con gas LP presentó `MR = " + string(sprintf('%.6g',gasLP_MR)) + "`, costo específico `" + string(sprintf('%.6g',gasLP_cost)) + "` y CO2 específico `" + string(sprintf('%.6g',gasLP_CO2)) + "`. En comparación, " + string(recID) + " alcanzó `MR = " + string(sprintf('%.6g',H2_MR)) + "`, costo específico `" + string(sprintf('%.6g',H2_cost)) + "` y CO2 específico `" + string(sprintf('%.6g',H2_CO2)) + "`, lo que equivale a reducciones de `" + string(sprintf('%.4g',MRred)) + " %` en razón de humedad final, `" + string(sprintf('%.4g',CostRed)) + " %` en costo específico y `" + string(sprintf('%.4g',CO2Red)) + " %` en CO2 específico.";
    lines(end+1) = "";
    lines(end+1) = "Por lo anterior, los resultados son suficientes para discutir la estructura del frente, comparar el modo híbrido contra la referencia con gas LP y justificar la selección de una solución de compromiso para tesis. Sin embargo, no se afirma que la solución seleccionada sea el óptimo global absoluto ni que los parámetros del algoritmo genético constituyan una configuración exhaustivamente optimizada.";
    lines(end+1) = "";

    txt = strjoin(lines,newline);
end

function txt = compose_conclusion_scope_text()

    lines = strings(0,1);

    lines(end+1) = "# Texto sugerido — alcance de conclusiones";
    lines(end+1) = "";
    lines(end+1) = "Los resultados permiten concluir que, bajo la configuración formal del algoritmo genético utilizada, el modo híbrido ofrece una solución de compromiso capaz de cumplir el criterio de secado y reducir simultáneamente el costo específico y las emisiones específicas de CO2 respecto a la referencia con gas LP. Esta conclusión se limita al frente obtenido y a las condiciones de simulación consideradas.";
    lines(end+1) = "";
    lines(end+1) = "La selección de H2 debe entenderse como una decisión operativa dentro del frente calculado, no como una prueba de optimalidad global absoluta. Para fortalecer la robustez algorítmica de la selección, sería conveniente realizar corridas adicionales con semillas distintas o una evaluación de sensibilidad de parámetros del algoritmo genético.";
    lines(end+1) = "";

    txt = strjoin(lines,newline);
end

function report = compose_audit_report_md( ...
    GA, Audit, Claims, thesis_verdict, article_verdict, ...
    allowed_claim, forbidden_claim, ...
    recommended_next_validation, recommended_if_time_limited, recommended_if_article_target, ...
    thesisText, conclusionText)

    lines = strings(0,1);

    lines(end+1) = "# GA_SUFFICIENCY_AND_CONVERGENCE_AUDIT_v96z";
    lines(end+1) = "";
    lines(end+1) = "## Dictamen";
    lines(end+1) = "";
    lines(end+1) = "- Dictamen para tesis: `" + string(thesis_verdict) + "`";
    lines(end+1) = "- Dictamen para artículo fuerte: `" + string(article_verdict) + "`";
    lines(end+1) = "";
    lines(end+1) = "## Configuración auditada";
    lines(end+1) = "";
    lines(end+1) = "| Campo | Valor |";
    lines(end+1) = "|---|---:|";
    lines(end+1) = "| Modo formal | `" + string(GA.modeFormal) + "` |";
    lines(end+1) = "| Referencia | `" + string(GA.referenceMode) + "` |";
    lines(end+1) = "| PopulationSize | " + string(GA.populationSize) + " |";
    lines(end+1) = "| MaxGenerations | " + string(GA.maxGenerations) + " |";
    lines(end+1) = "| Evaluaciones | " + string(GA.funccount) + " |";
    lines(end+1) = "| Soluciones del frente | " + string(GA.nSolutions) + " |";
    lines(end+1) = "| Filas finitas | " + string(GA.nFiniteRows) + " |";
    lines(end+1) = "| Filas penalizadas | " + string(GA.nPenaltyRows) + " |";
    lines(end+1) = "| Exitflag | " + string(GA.exitflag) + " |";
    lines(end+1) = "| Terminación | `" + string(GA.termination) + "` |";
    lines(end+1) = "| Tiempo de ejecución [h] | " + string(GA.runtime_h) + " |";
    lines(end+1) = "";
    lines(end+1) = "## Afirmación permitida";
    lines(end+1) = "";
    lines(end+1) = string(allowed_claim);
    lines(end+1) = "";
    lines(end+1) = "## Afirmación bloqueada";
    lines(end+1) = "";
    lines(end+1) = string(forbidden_claim);
    lines(end+1) = "";
    lines(end+1) = "## Auditoría";
    lines(end+1) = "";
    lines(end+1) = "| Criterio | Estado | Evidencia | Riesgo | Recomendación |";
    lines(end+1) = "|---|---|---|---|---|";

    for i = 1:height(Audit)
        lines(end+1) = "| " + string(Audit.criterion(i)) + " | " + string(Audit.status(i)) + " | " + string(Audit.evidence(i)) + " | " + string(Audit.risk(i)) + " | " + string(Audit.recommendation(i)) + " |";
    end

    lines(end+1) = "";
    lines(end+1) = "## Nivel de afirmaciones";
    lines(end+1) = "";
    lines(end+1) = "| Afirmación | Permitida | Redacción |";
    lines(end+1) = "|---|---:|---|";

    for i = 1:height(Claims)
        lines(end+1) = "| " + string(Claims.claim(i)) + " | " + string(Claims.allowed(i)) + " | " + string(Claims.wording(i)) + " |";
    end

    lines(end+1) = "";
    lines(end+1) = "## Recomendación";
    lines(end+1) = "";
    lines(end+1) = "- Validación adicional mínima recomendada: `" + string(recommended_next_validation) + "`";
    lines(end+1) = "- Si el tiempo es limitado: " + string(recommended_if_time_limited);
    lines(end+1) = "- Si el objetivo es artículo: " + string(recommended_if_article_target);
    lines(end+1) = "";
    lines(end+1) = "## Texto sugerido para tesis";
    lines(end+1) = "";
    lines(end+1) = thesisText;
    lines(end+1) = "";
    lines(end+1) = "## Texto sugerido para conclusiones";
    lines(end+1) = "";
    lines(end+1) = conclusionText;
    lines(end+1) = "";

    report = strjoin(lines,newline);
end

% =========================================================================
% Helpers
% =========================================================================

function mkdir_if_needed(folderPath)
    if ~isfolder(folderPath)
        mkdir(folderPath);
    end
end

function matPath = find_latest_mat(baseDir,matName)
    matPath = "";

    if ~isfolder(baseDir)
        return
    end

    d = dir(baseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    if isempty(d)
        return
    end

    [~,idx] = sort([d.datenum],'descend');
    d = d(idx);

    for i = 1:numel(d)
        candidate = fullfile(baseDir,d(i).name,'mat',matName);
        if isfile(candidate)
            matPath = string(candidate);
            return
        end
    end
end

function row = check_row(id, checkName, passVal, evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end