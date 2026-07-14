function minrep = design_minimal_seed_replication_v96z_minrep()
% DESIGN_MINIMAL_SEED_REPLICATION_v96z_minrep
% 9.6z-minrep — OPTIONAL-MINIMAL-SEED-REPLICATION-DESIGN-001
%
% Objetivo:
%   Diseñar réplicas mínimas con distintas semillas para robustecer la
%   corrida triobjetivo formal del modo híbrido.
%
% Contexto:
%   - Para tesis: resultados suficientes con alcance condicionado.
%   - Para artículo Q1: se requiere validación adicional mínima.
%
% Este script:
%   - NO ejecuta GA.
%   - NO llama modelo mecanístico.
%   - NO llama función objetivo.
%   - NO recalcula resultados.
%   - NO modifica 05_runs.
%   - Escribe el diseño en 06_manuscript/article_Q1 y 06_manuscript/thesis_ES.
%
% Uso:
%   minrep = design_minimal_seed_replication_v96z_minrep();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Rutas
    % ---------------------------------------------------------------------
    manuscriptRoot = fullfile(rootDir,'06_manuscript');
    thesisRoot = fullfile(manuscriptRoot,'thesis_ES');
    articleRoot = fullfile(manuscriptRoot,'article_Q1');

    articleReviewDir = fullfile(articleRoot,'review');
    articleTablesDir = fullfile(articleRoot,'tables');
    articleTraceDir = fullfile(articleRoot,'traceability');
    articleProtocolsDir = fullfile(articleRoot,'protocols');

    thesisReviewDir = fullfile(thesisRoot,'review');
    thesisTraceDir = fullfile(thesisRoot,'traceability');

    mkdir_if_needed(manuscriptRoot);
    mkdir_if_needed(articleRoot);
    mkdir_if_needed(articleReviewDir);
    mkdir_if_needed(articleTablesDir);
    mkdir_if_needed(articleTraceDir);
    mkdir_if_needed(articleProtocolsDir);

    % ---------------------------------------------------------------------
    % Entrada principal: auditoría GA v96z
    % ---------------------------------------------------------------------
    gauditMat = fullfile(thesisTraceDir,'GA_SUFFICIENCY_AND_CONVERGENCE_AUDIT_v96z.mat');

    if ~isfile(gauditMat)
        error('No existe GA audit MAT v96z: %s', gauditMat);
    end

    G = load(gauditMat);

    if ~strcmp(string(G.diagnosis),"GA_SUFFICIENCY_AND_CONVERGENCE_AUDIT_PASS")
        error('La auditoría GA v96z no está en PASS. Diagnosis: %s', string(G.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Diseño de réplicas
    % ---------------------------------------------------------------------
    basePopulationSize = G.GA.populationSize;
    baseMaxGenerations = G.GA.maxGenerations;
    baseFunccount = G.GA.funccount;
    baseRuntime_h = G.GA.runtime_h;

    % Para artículo Q1: 3 réplicas mínimas adicionales.
    % Mantienen la misma configuración para aislar efecto semilla.
    replicateSeeds = [61001; 61002; 61003];

    nReplicates = numel(replicateSeeds);

    Rep = table();
    Rep.replicate_id = ["R1";"R2";"R3"];
    Rep.seed = replicateSeeds;
    Rep.modeFormal = repmat("hybrid",nReplicates,1);
    Rep.referenceMode = repmat("gasLP",nReplicates,1);
    Rep.populationSize = repmat(basePopulationSize,nReplicates,1);
    Rep.maxGenerations = repmat(baseMaxGenerations,nReplicates,1);
    Rep.expected_funccount = repmat(baseFunccount,nReplicates,1);
    Rep.expected_runtime_h = repmat(baseRuntime_h,nReplicates,1);
    Rep.execution_status = repmat("DESIGNED_NOT_EXECUTED",nReplicates,1);
    Rep.purpose = repmat("Seed robustness of formal hybrid triobjective GA",nReplicates,1);

    totalExpectedRuntime_h = sum(Rep.expected_runtime_h);

    % ---------------------------------------------------------------------
    % Criterios de aceptación para Q1
    % ---------------------------------------------------------------------
    Criteria = table();

    Criteria.id = [ ...
        "C1"; ...
        "C2"; ...
        "C3"; ...
        "C4"; ...
        "C5"; ...
        "C6"; ...
        "C7"; ...
        "C8"];

    Criteria.criterion = [ ...
        "Cada réplica debe completar sin error."; ...
        "Cada réplica debe producir filas finitas."; ...
        "Debe existir al menos una solución admisible por MR en cada réplica."; ...
        "Debe aparecer una solución tipo H2 o equivalente en al menos 2 de 3 réplicas."; ...
        "La solución tipo H2 debe reducir costo específico frente a gas LP."; ...
        "La solución tipo H2 debe reducir CO2 específico frente a gas LP."; ...
        "La solución tipo H2 debe cumplir MR < 0.1."; ...
        "No se debe afirmar óptimo global aunque las réplicas sean consistentes."];

    Criteria.acceptance_rule = [ ...
        "run_status == OK"; ...
        "nFiniteRows > 0"; ...
        "any(MR < 0.1)"; ...
        "at least 2/3 replicates with admissible compromise solution"; ...
        "cost_reduction_pct_vs_gasLP > 0"; ...
        "CO2_reduction_pct_vs_gasLP > 0"; ...
        "MR < 0.1"; ...
        "Use robust compromise wording, not global optimum wording."];

    Criteria.importance = [ ...
        "critical"; ...
        "critical"; ...
        "critical"; ...
        "critical"; ...
        "high"; ...
        "high"; ...
        "critical"; ...
        "critical"];

    % ---------------------------------------------------------------------
    % Definición de solución tipo H2
    % ---------------------------------------------------------------------
    H2type = table();

    H2type.metric = [ ...
        "MR"; ...
        "cost_specific"; ...
        "CO2_specific"; ...
        "dominance_vs_gasLP"; ...
        "role_in_front"; ...
        "selection_basis"];

    H2type.definition = [ ...
        "Must satisfy MR < 0.1."; ...
        "Must be lower than gasLP reference, or within accepted trade-off if CO2/MR strongly improve."; ...
        "Must be lower than gasLP reference while CO2 factors remain fixed."; ...
        "Preferred: simultaneous improvement in MR, cost and CO2 vs gasLP."; ...
        "Compromise solution, not necessarily minMR, minCost or minCO2."; ...
        "Selected from admissible front by normalized balance score or equivalent compromise criterion."];

    % ---------------------------------------------------------------------
    % Decisión metodológica
    % ---------------------------------------------------------------------
    DesignDecision = table();

    DesignDecision.item = [ ...
        "Current Q1 readiness"; ...
        "Minimum required action"; ...
        "Execution cost"; ...
        "Main risk"; ...
        "Recommended claim after successful replication"; ...
        "Still forbidden after successful replication"; ...
        "If replication fails"; ...
        "CO2 dependency"];

    DesignDecision.value = [ ...
        "Current results are a valid base but not sufficient for a strong Q1 article."; ...
        "Run three additional seed replicates with same GA configuration."; ...
        sprintf("Expected total additional runtime: %.2f h", totalExpectedRuntime_h); ...
        "Equivalent compromise solution may shift due to stochastic GA behavior."; ...
        "H2-like compromise behavior is robust across independent seeds."; ...
        "Do not claim global optimum or full convergence proof."; ...
        "Report current result as preliminary and redesign GA parameter sensitivity."; ...
        "CO2 claims remain dependent on definitive emission factors."];

    % ---------------------------------------------------------------------
    % Protocolo de ejecución posterior
    % ---------------------------------------------------------------------
    protocolText = compose_minrep_protocol_text(Rep,Criteria,H2type,totalExpectedRuntime_h);

    protocolMd = fullfile(articleProtocolsDir,'MINIMAL_SEED_REPLICATION_PROTOCOL_v96z_minrep.md');
    protocolTxt = fullfile(articleProtocolsDir,'MINIMAL_SEED_REPLICATION_PROTOCOL_v96z_minrep.txt');

    fid = fopen(protocolMd,'w');
    if fid < 0
        error('No se pudo crear protocolMd: %s', protocolMd);
    end
    fprintf(fid,'%s',protocolText);
    fclose(fid);

    fid = fopen(protocolTxt,'w');
    if fid < 0
        error('No se pudo crear protocolTxt: %s', protocolTxt);
    end
    fprintf(fid,'%s',protocolText);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Tablas
    % ---------------------------------------------------------------------
    repCsv = fullfile(articleTablesDir,'minimal_seed_replication_design_v96z_minrep.csv');
    criteriaCsv = fullfile(articleTablesDir,'minimal_seed_replication_acceptance_criteria_v96z_minrep.csv');
    h2typeCsv = fullfile(articleTablesDir,'h2_equivalent_solution_definition_v96z_minrep.csv');
    decisionCsv = fullfile(articleTablesDir,'q1_replication_design_decision_v96z_minrep.csv');

    writetable(Rep,repCsv);
    writetable(Criteria,criteriaCsv);
    writetable(H2type,h2typeCsv);
    writetable(DesignDecision,decisionCsv);

    % ---------------------------------------------------------------------
    % Reporte de diseño
    % ---------------------------------------------------------------------
    reportText = compose_minrep_design_report( ...
        G, Rep, Criteria, H2type, DesignDecision, totalExpectedRuntime_h);

    reportMd = fullfile(articleReviewDir,'MINIMAL_SEED_REPLICATION_DESIGN_v96z_minrep.md');
    reportTxt = fullfile(articleReviewDir,'MINIMAL_SEED_REPLICATION_DESIGN_v96z_minrep.txt');

    fid = fopen(reportMd,'w');
    if fid < 0
        error('No se pudo crear reportMd: %s', reportMd);
    end
    fprintf(fid,'%s',reportText);
    fclose(fid);

    fid = fopen(reportTxt,'w');
    if fid < 0
        error('No se pudo crear reportTxt: %s', reportTxt);
    end
    fprintf(fid,'%s',reportText);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Crear stub de ejecución, pero sin correrlo
    % ---------------------------------------------------------------------
    runStubPath = fullfile(articleProtocolsDir,'RUN_COMMANDS_MINREP_v96z_minrep_DO_NOT_RUN_YET.md');

    fid = fopen(runStubPath,'w');
    if fid < 0
        error('No se pudo crear runStubPath: %s', runStubPath);
    end

    fprintf(fid,'# RUN_COMMANDS_MINREP_v96z_minrep_DO_NOT_RUN_YET\n\n');
    fprintf(fid,'Estos comandos son solo el diseño. No ejecutar hasta aprobar `9.6z-minrep-run`.\n\n');
    fprintf(fid,'```matlab\n');
    fprintf(fid,'%% Pendiente: crear wrapper formal con semilla explícita antes de ejecutar.\n');
    fprintf(fid,'%% Replicas propuestas:\n');

    for i = 1:height(Rep)
        fprintf(fid,'%% %s: rng(%d); formal_%s = run_guarded_triobjective_formal_ga_v96m(true);\n', ...
            Rep.replicate_id(i), Rep.seed(i), lower(Rep.replicate_id(i)));
    end

    fprintf(fid,'```\n\n');
    fprintf(fid,'Advertencia: el script actual v96m debe verificarse para asegurar control explícito de semilla antes de correr réplicas.\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};
    checks{end+1,1} = check_row("MR01","GA audit v96z loaded",true,string(gauditMat));
    checks{end+1,1} = check_row("MR02","GA audit v96z PASS",strcmp(string(G.diagnosis),"GA_SUFFICIENCY_AND_CONVERGENCE_AUDIT_PASS"),string(G.diagnosis));
    checks{end+1,1} = check_row("MR03","Article Q1 workspace created",isfolder(articleRoot),string(articleRoot));
    checks{end+1,1} = check_row("MR04","Three seed replicates designed",height(Rep)==3,sprintf("nReplicates=%d",height(Rep)));
    checks{end+1,1} = check_row("MR05","Seeds unique",numel(unique(Rep.seed))==height(Rep),"Seeds are unique.");
    checks{end+1,1} = check_row("MR06","Same GA configuration preserved",all(Rep.populationSize==basePopulationSize) && all(Rep.maxGenerations==baseMaxGenerations),"Same pop/gen in all replicates.");
    checks{end+1,1} = check_row("MR07","Acceptance criteria created",height(Criteria)>=8,string(criteriaCsv));
    checks{end+1,1} = check_row("MR08","H2-equivalent definition created",height(H2type)>=6,string(h2typeCsv));
    checks{end+1,1} = check_row("MR09","Design report created",isfile(reportMd),string(reportMd));
    checks{end+1,1} = check_row("MR10","Protocol created",isfile(protocolMd),string(protocolMd));
    checks{end+1,1} = check_row("MR11","Run stub created but not executed",isfile(runStubPath),string(runStubPath));
    checks{end+1,1} = check_row("MR12","No GA executed",true,"No gamultiobj call.");
    checks{end+1,1} = check_row("MR13","No model executed",true,"No objective/model call.");
    checks{end+1,1} = check_row("MR14","No 05_runs modified",true,"Only 06_manuscript/article_Q1 files written.");
    checks{end+1,1} = check_row("MR15","Q1 need acknowledged",true,"Replication treated as minimum necessary for strong Q1 article.");

    Tchecks = struct2table(vertcat(checks{:}));

    design_pass = all(Tchecks.pass);

    if design_pass
        diagnosis = "MINIMAL_SEED_REPLICATION_DESIGN_PASS";
        decision = "MINREP_READY_FOR_EXECUTION_APPROVAL";
        next_step = "9.6z-minrep-runprep — CREATE-SEED-CONTROLLED-REPLICATION-RUNNER-001";
    else
        diagnosis = "MINIMAL_SEED_REPLICATION_DESIGN_REQUIRES_REVIEW";
        decision = "REVIEW_FAILED_MINREP_DESIGN_CHECKS";
        next_step = "Review failed checks before creating runner.";
    end

    checksCsv = fullfile(articleTablesDir,'minimal_seed_replication_design_checks_v96z_minrep.csv');
    writetable(Tchecks,checksCsv);

    % ---------------------------------------------------------------------
    % Guardar MAT
    % ---------------------------------------------------------------------
    minrepMat = fullfile(articleTraceDir,'MINIMAL_SEED_REPLICATION_DESIGN_v96z_minrep.mat');

    save(minrepMat, ...
        'diagnosis','decision','next_step', ...
        'rootDir','manuscriptRoot','thesisRoot','articleRoot', ...
        'articleReviewDir','articleTablesDir','articleTraceDir','articleProtocolsDir', ...
        'gauditMat','G', ...
        'basePopulationSize','baseMaxGenerations','baseFunccount','baseRuntime_h', ...
        'Rep','Criteria','H2type','DesignDecision','Tchecks', ...
        'totalExpectedRuntime_h', ...
        'repCsv','criteriaCsv','h2typeCsv','decisionCsv','checksCsv', ...
        'reportMd','reportTxt','protocolMd','protocolTxt','runStubPath','minrepMat');

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    minrep = struct();
    minrep.status = 'MINIMAL_SEED_REPLICATION_DESIGN_COMPLETED';
    minrep.diagnosis = diagnosis;
    minrep.decision = decision;
    minrep.next_step = next_step;

    minrep.articleRoot = articleRoot;
    minrep.Rep = Rep;
    minrep.Criteria = Criteria;
    minrep.H2type = H2type;
    minrep.DesignDecision = DesignDecision;
    minrep.Tchecks = Tchecks;

    minrep.totalExpectedRuntime_h = totalExpectedRuntime_h;
    minrep.reportMd = reportMd;
    minrep.protocolMd = protocolMd;
    minrep.runStubPath = runStubPath;
    minrep.minrepMat = minrepMat;

    disp('=== MINIMAL_SEED_REPLICATION_DESIGN_v96z_minrep ===')
    disp(minrep.status)
    disp('=== DIAGNOSIS ===')
    disp(minrep.diagnosis)
    disp('=== DECISION ===')
    disp(minrep.decision)
    disp('=== NEXT STEP ===')
    disp(minrep.next_step)
    disp('=== ARTICLE Q1 WORKSPACE ===')
    disp(minrep.articleRoot)
    disp('=== REPLICATES ===')
    disp(minrep.Rep)
    disp('=== TOTAL EXPECTED RUNTIME [h] ===')
    disp(minrep.totalExpectedRuntime_h)
    disp('=== ACCEPTANCE CRITERIA ===')
    disp(minrep.Criteria)
    disp('=== H2-EQUIVALENT DEFINITION ===')
    disp(minrep.H2type)
    disp('=== DESIGN DECISION ===')
    disp(minrep.DesignDecision)
    disp('=== CHECKS ===')
    disp(minrep.Tchecks)
    disp('=== REPORT MD ===')
    disp(minrep.reportMd)
    disp('=== PROTOCOL MD ===')
    disp(minrep.protocolMd)
    disp('=== RUN STUB ===')
    disp(minrep.runStubPath)

end

% =========================================================================
% Text composition
% =========================================================================

function txt = compose_minrep_protocol_text(Rep,Criteria,H2type,totalExpectedRuntime_h)

    lines = strings(0,1);

    lines(end+1) = "# MINIMAL_SEED_REPLICATION_PROTOCOL_v96z_minrep";
    lines(end+1) = "";
    lines(end+1) = "## Purpose";
    lines(end+1) = "";
    lines(end+1) = "Design a minimal independent-seed replication protocol for the formal hybrid triobjective GA. This is required to strengthen the robustness of the optimization results for a Q1 journal article.";
    lines(end+1) = "";

    lines(end+1) = "## Replicate design";
    lines(end+1) = "";
    lines(end+1) = "| Replicate | Seed | Mode | PopulationSize | MaxGenerations | Expected runtime [h] |";
    lines(end+1) = "|---|---:|---|---:|---:|---:|";

    for i = 1:height(Rep)
        lines(end+1) = "| " + string(Rep.replicate_id(i)) + " | " + string(Rep.seed(i)) + " | " + string(Rep.modeFormal(i)) + " | " + string(Rep.populationSize(i)) + " | " + string(Rep.maxGenerations(i)) + " | " + string(sprintf('%.4g',Rep.expected_runtime_h(i))) + " |";
    end

    lines(end+1) = "";
    lines(end+1) = "Expected total runtime: `" + string(sprintf('%.4g',totalExpectedRuntime_h)) + " h`.";
    lines(end+1) = "";

    lines(end+1) = "## Acceptance criteria";
    lines(end+1) = "";
    lines(end+1) = "| ID | Criterion | Acceptance rule | Importance |";
    lines(end+1) = "|---|---|---|---|";

    for i = 1:height(Criteria)
        lines(end+1) = "| " + string(Criteria.id(i)) + " | " + string(Criteria.criterion(i)) + " | `" + string(Criteria.acceptance_rule(i)) + "` | " + string(Criteria.importance(i)) + " |";
    end

    lines(end+1) = "";
    lines(end+1) = "## H2-equivalent solution";
    lines(end+1) = "";
    lines(end+1) = "| Metric | Definition |";
    lines(end+1) = "|---|---|";

    for i = 1:height(H2type)
        lines(end+1) = "| " + string(H2type.metric(i)) + " | " + string(H2type.definition(i)) + " |";
    end

    lines(end+1) = "";
    lines(end+1) = "## Execution rule";
    lines(end+1) = "";
    lines(end+1) = "Do not execute these replicates until a seed-controlled runner is created and approved. The existing formal runner must be checked to guarantee that each replicate uses the intended random seed.";
    lines(end+1) = "";

    txt = strjoin(lines,newline);
end

function txt = compose_minrep_design_report(G, Rep, Criteria, H2type, DesignDecision, totalExpectedRuntime_h)

    lines = strings(0,1);

    lines(end+1) = "# MINIMAL_SEED_REPLICATION_DESIGN_v96z_minrep";
    lines(end+1) = "";
    lines(end+1) = "## Dictamen";
    lines(end+1) = "";
    lines(end+1) = "El artículo Q1 requiere validación adicional. La corrida formal actual se conserva como corrida base, pero no debe usarse sola para sostener afirmaciones fuertes de robustez algorítmica.";
    lines(end+1) = "";
    lines(end+1) = "La auditoría previa determinó: `" + string(G.decision) + "`. En particular, permitió reportar H2 como solución de compromiso dentro del frente obtenido, pero bloqueó afirmar óptimo global o convergencia plena.";
    lines(end+1) = "";

    lines(end+1) = "## Diseño de réplicas";
    lines(end+1) = "";
    lines(end+1) = "| Réplica | Semilla | PopulationSize | MaxGenerations | Runtime esperado [h] |";
    lines(end+1) = "|---|---:|---:|---:|---:|";

    for i = 1:height(Rep)
        lines(end+1) = "| " + string(Rep.replicate_id(i)) + " | " + string(Rep.seed(i)) + " | " + string(Rep.populationSize(i)) + " | " + string(Rep.maxGenerations(i)) + " | " + string(sprintf('%.4g',Rep.expected_runtime_h(i))) + " |";
    end

    lines(end+1) = "";
    lines(end+1) = "Tiempo adicional estimado: `" + string(sprintf('%.4g',totalExpectedRuntime_h)) + " h`.";
    lines(end+1) = "";

    lines(end+1) = "## Criterios de aceptación";
    lines(end+1) = "";
    lines(end+1) = "| ID | Criterio | Regla | Importancia |";
    lines(end+1) = "|---|---|---|---|";

    for i = 1:height(Criteria)
        lines(end+1) = "| " + string(Criteria.id(i)) + " | " + string(Criteria.criterion(i)) + " | `" + string(Criteria.acceptance_rule(i)) + "` | " + string(Criteria.importance(i)) + " |";
    end

    lines(end+1) = "";
    lines(end+1) = "## Solución equivalente a H2";
    lines(end+1) = "";
    lines(end+1) = "| Métrica | Definición |";
    lines(end+1) = "|---|---|";

    for i = 1:height(H2type)
        lines(end+1) = "| " + string(H2type.metric(i)) + " | " + string(H2type.definition(i)) + " |";
    end

    lines(end+1) = "";
    lines(end+1) = "## Decisiones";
    lines(end+1) = "";
    lines(end+1) = "| Item | Valor |";
    lines(end+1) = "|---|---|";

    for i = 1:height(DesignDecision)
        lines(end+1) = "| " + string(DesignDecision.item(i)) + " | " + string(DesignDecision.value(i)) + " |";
    end

    lines(end+1) = "";
    lines(end+1) = "## Siguiente paso";
    lines(end+1) = "";
    lines(end+1) = "`9.6z-minrep-runprep — CREATE-SEED-CONTROLLED-REPLICATION-RUNNER-001`";
    lines(end+1) = "";
    lines(end+1) = "Ese paso debe crear un corredor de réplicas con semilla explícita y modo seguro, todavía sin ejecución automática hasta aprobación.";
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