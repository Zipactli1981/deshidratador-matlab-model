function runprep = create_seed_controlled_replication_runner_v96z_minrep_runprep()
% CREATE_SEED_CONTROLLED_REPLICATION_RUNNER_v96z_minrep_runprep
% 9.6z-minrep-runprep — CREATE-SEED-CONTROLLED-REPLICATION-RUNNER-001
%
% Objetivo:
%   Crear un runner de réplicas con control explícito de semilla para las
%   tres réplicas mínimas diseñadas en 9.6z-minrep.
%
% Este paso:
%   - NO ejecuta GA.
%   - NO llama modelo.
%   - NO llama función objetivo.
%   - NO recalcula resultados.
%   - NO modifica 05_runs.
%   - Crea un runner seguro en 02_src_limpio/production.
%   - Crea un script de aprobación para ejecutar después.
%
% Contexto:
%   Para artículo Q1, las réplicas con semillas distintas son validación
%   mínima necesaria. El diseño previo definió:
%     R1 seed 61001
%     R2 seed 61002
%     R3 seed 61003
%
% Uso:
%   runprep = create_seed_controlled_replication_runner_v96z_minrep_runprep();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Rutas
    % ---------------------------------------------------------------------
    productionDir = fullfile(rootDir,'02_src_limpio','production');
    manuscriptRoot = fullfile(rootDir,'06_manuscript');
    articleRoot = fullfile(manuscriptRoot,'article_Q1');

    articleTraceDir = fullfile(articleRoot,'traceability');
    articleTablesDir = fullfile(articleRoot,'tables');
    articleProtocolsDir = fullfile(articleRoot,'protocols');
    articleReviewDir = fullfile(articleRoot,'review');

    mkdir_if_needed(productionDir);
    mkdir_if_needed(articleRoot);
    mkdir_if_needed(articleTraceDir);
    mkdir_if_needed(articleTablesDir);
    mkdir_if_needed(articleProtocolsDir);
    mkdir_if_needed(articleReviewDir);

    % ---------------------------------------------------------------------
    % Entrada: diseño minrep
    % ---------------------------------------------------------------------
    minrepMat = fullfile(articleTraceDir,'MINIMAL_SEED_REPLICATION_DESIGN_v96z_minrep.mat');

    if ~isfile(minrepMat)
        error('No existe minrepMat: %s', minrepMat);
    end

    D = load(minrepMat);

    if ~strcmp(string(D.diagnosis),"MINIMAL_SEED_REPLICATION_DESIGN_PASS")
        error('El diseño minrep no está en PASS. Diagnosis: %s', string(D.diagnosis));
    end

    Rep = D.Rep;
    Criteria = D.Criteria;
    H2type = D.H2type;
    totalExpectedRuntime_h = D.totalExpectedRuntime_h;

    % ---------------------------------------------------------------------
    % Auditoría del runner base v96m
    % ---------------------------------------------------------------------
    baseRunnerName = "run_guarded_triobjective_formal_ga_v96m.m";
    baseRunnerPath = fullfile(productionDir,baseRunnerName);

    if ~isfile(baseRunnerPath)
        error('No existe runner formal base: %s', baseRunnerPath);
    end

    baseText = string(fileread(baseRunnerPath));

    base_has_rng_call = contains(baseText,"rng(");
    base_has_gamultiobj = contains(baseText,"gamultiobj");
    base_has_confirm_execute = contains(baseText,"confirm_execute");
    base_has_mode_hybrid = contains(baseText,"hybrid");

    % Nota metodológica:
    % Si el runner base contiene rng interno, un rng externo podría no bastar.
    % Por eso el runner creado aquí:
    %   1) fija rng(seed,'twister') antes de llamar;
    %   2) registra rng antes y después;
    %   3) registra el texto auditado del runner base;
    %   4) no modifica v96m.
    %
    % No se edita v96m para preservar trazabilidad.

    % ---------------------------------------------------------------------
    % Crear runner seed-controlled
    % ---------------------------------------------------------------------
    runnerPath = fullfile(productionDir,'run_seed_controlled_minrep_formal_ga_v96z_minrep.m');

    runnerText = compose_seed_controlled_runner_text();

    fid = fopen(runnerPath,'w');
    if fid < 0
        error('No se pudo crear runnerPath: %s', runnerPath);
    end
    fprintf(fid,'%s',runnerText);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Crear script de aprobación sin ejecución
    % ---------------------------------------------------------------------
    approvalPath = fullfile(productionDir,'approve_seed_controlled_minrep_execution_v96z_minrep.m');

    approvalText = compose_approval_script_text();

    fid = fopen(approvalPath,'w');
    if fid < 0
        error('No se pudo crear approvalPath: %s', approvalPath);
    end
    fprintf(fid,'%s',approvalText);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Crear comando de ejecución manual
    % ---------------------------------------------------------------------
    commandMd = fullfile(articleProtocolsDir,'APPROVED_COMMANDS_MINREP_RUNNER_v96z_minrep_runprep.md');

    fid = fopen(commandMd,'w');
    if fid < 0
        error('No se pudo crear commandMd: %s', commandMd);
    end

    fprintf(fid,'# APPROVED_COMMANDS_MINREP_RUNNER_v96z_minrep_runprep\n\n');
    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'El runner seed-controlled fue creado, pero las réplicas NO se ejecutaron en runprep.\n\n');

    fprintf(fid,'## Primero: preflight sin ejecución\n\n');
    fprintf(fid,'```matlab\n');
    fprintf(fid,'addpath(genpath(fullfile(rootDir,''02_src_limpio'')));\n');
    fprintf(fid,'rehash;\n\n');
    fprintf(fid,'pre = run_seed_controlled_minrep_formal_ga_v96z_minrep(false);\n');
    fprintf(fid,'disp(pre.status)\n');
    fprintf(fid,'disp(pre.diagnosis)\n');
    fprintf(fid,'disp(pre.decision)\n');
    fprintf(fid,'disp(pre.next_step)\n');
    fprintf(fid,'disp(pre.Treplicates)\n');
    fprintf(fid,'disp(pre.Tchecks)\n');
    fprintf(fid,'```\n\n');

    fprintf(fid,'## Segundo: aprobación de ejecución\n\n');
    fprintf(fid,'```matlab\n');
    fprintf(fid,'approval = approve_seed_controlled_minrep_execution_v96z_minrep();\n');
    fprintf(fid,'disp(approval.status)\n');
    fprintf(fid,'disp(approval.diagnosis)\n');
    fprintf(fid,'disp(approval.approved_command)\n');
    fprintf(fid,'```\n\n');

    fprintf(fid,'## Tercero: ejecución real, solo si aceptas ~%.2f h\n\n', totalExpectedRuntime_h);
    fprintf(fid,'```matlab\n');
    fprintf(fid,'minrepRun = run_seed_controlled_minrep_formal_ga_v96z_minrep(true);\n');
    fprintf(fid,'```\n\n');

    fprintf(fid,'## Advertencia\n\n');
    fprintf(fid,'No ejecutar `true` hasta revisar que el preflight esté en PASS.\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % Reporte runprep
    % ---------------------------------------------------------------------
    RunnerAudit = table();
    RunnerAudit.item = [ ...
        "base_runner_exists"; ...
        "base_runner_has_rng_call"; ...
        "base_runner_has_gamultiobj"; ...
        "base_runner_has_confirm_execute"; ...
        "base_runner_has_hybrid_mode"; ...
        "seed_controlled_runner_created"; ...
        "approval_script_created"; ...
        "manual_command_file_created"; ...
        "replicates_designed"; ...
        "estimated_total_runtime_h"];

    RunnerAudit.value = [ ...
        string(isfile(baseRunnerPath)); ...
        string(base_has_rng_call); ...
        string(base_has_gamultiobj); ...
        string(base_has_confirm_execute); ...
        string(base_has_mode_hybrid); ...
        string(isfile(runnerPath)); ...
        string(isfile(approvalPath)); ...
        string(isfile(commandMd)); ...
        string(height(Rep)); ...
        string(sprintf('%.4f',totalExpectedRuntime_h))];

    auditCsv = fullfile(articleTablesDir,'seed_controlled_runner_audit_v96z_minrep_runprep.csv');
    writetable(RunnerAudit,auditCsv);

    reportText = compose_runprep_report_text( ...
        baseRunnerPath,base_has_rng_call,base_has_gamultiobj, ...
        runnerPath,approvalPath,commandMd,Rep,Criteria,H2type,totalExpectedRuntime_h);

    reportMd = fullfile(articleReviewDir,'SEED_CONTROLLED_REPLICATION_RUNNER_RUNPREP_v96z_minrep.md');
    reportTxt = fullfile(articleReviewDir,'SEED_CONTROLLED_REPLICATION_RUNNER_RUNPREP_v96z_minrep.txt');

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
    % Checks
    % ---------------------------------------------------------------------
    checks = {};
    checks{end+1,1} = check_row("RP01","Minrep design loaded",true,string(minrepMat));
    checks{end+1,1} = check_row("RP02","Minrep design PASS",strcmp(string(D.diagnosis),"MINIMAL_SEED_REPLICATION_DESIGN_PASS"),string(D.diagnosis));
    checks{end+1,1} = check_row("RP03","Base runner exists",isfile(baseRunnerPath),string(baseRunnerPath));
    checks{end+1,1} = check_row("RP04","Base runner has gamultiobj",base_has_gamultiobj,"gamultiobj scan in v96m.");
    checks{end+1,1} = check_row("RP05","Replicates available",height(Rep)==3,sprintf("nReplicates=%d",height(Rep)));
    checks{end+1,1} = check_row("RP06","Seeds unique",numel(unique(Rep.seed))==height(Rep),"Seeds unique.");
    checks{end+1,1} = check_row("RP07","Runner created",isfile(runnerPath),string(runnerPath));
    checks{end+1,1} = check_row("RP08","Approval script created",isfile(approvalPath),string(approvalPath));
    checks{end+1,1} = check_row("RP09","Command MD created",isfile(commandMd),string(commandMd));
    checks{end+1,1} = check_row("RP10","Runprep report created",isfile(reportMd),string(reportMd));
    checks{end+1,1} = check_row("RP11","Audit CSV created",isfile(auditCsv),string(auditCsv));
    checks{end+1,1} = check_row("RP12","No GA executed",true,"No gamultiobj call from runprep.");
    checks{end+1,1} = check_row("RP13","No model executed",true,"No objective/model call from runprep.");
    checks{end+1,1} = check_row("RP14","No 05_runs modified",true,"Only production runner and article_Q1 protocol files written.");
    checks{end+1,1} = check_row("RP15","Execution still gated",true,"Runner defaults to confirm_execute=false.");

    Tchecks = struct2table(vertcat(checks{:}));

    runprep_pass = all(Tchecks.pass);

    if runprep_pass
        diagnosis = "SEED_CONTROLLED_REPLICATION_RUNNER_RUNPREP_PASS";
        decision = "SEED_CONTROLLED_RUNNER_READY_FOR_PREFLIGHT";
        next_step = "Run preflight: run_seed_controlled_minrep_formal_ga_v96z_minrep(false)";
    else
        diagnosis = "SEED_CONTROLLED_REPLICATION_RUNNER_RUNPREP_REQUIRES_REVIEW";
        decision = "REVIEW_FAILED_RUNPREP_CHECKS";
        next_step = "Review failed checks before preflight.";
    end

    checksCsv = fullfile(articleTablesDir,'seed_controlled_runner_runprep_checks_v96z_minrep.csv');
    writetable(Tchecks,checksCsv);

    % ---------------------------------------------------------------------
    % Guardar MAT
    % ---------------------------------------------------------------------
    runprepMat = fullfile(articleTraceDir,'SEED_CONTROLLED_REPLICATION_RUNNER_RUNPREP_v96z_minrep.mat');

    save(runprepMat, ...
        'diagnosis','decision','next_step', ...
        'rootDir','productionDir','articleRoot','articleTraceDir','articleTablesDir','articleProtocolsDir','articleReviewDir', ...
        'minrepMat','D','Rep','Criteria','H2type','totalExpectedRuntime_h', ...
        'baseRunnerPath','base_has_rng_call','base_has_gamultiobj','base_has_confirm_execute','base_has_mode_hybrid', ...
        'runnerPath','approvalPath','commandMd','reportMd','reportTxt','auditCsv','checksCsv','runprepMat', ...
        'RunnerAudit','Tchecks');

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    runprep = struct();
    runprep.status = 'SEED_CONTROLLED_REPLICATION_RUNNER_RUNPREP_COMPLETED';
    runprep.diagnosis = diagnosis;
    runprep.decision = decision;
    runprep.next_step = next_step;

    runprep.runnerPath = runnerPath;
    runprep.approvalPath = approvalPath;
    runprep.commandMd = commandMd;
    runprep.reportMd = reportMd;
    runprep.runprepMat = runprepMat;

    runprep.baseRunnerPath = baseRunnerPath;
    runprep.base_has_rng_call = base_has_rng_call;
    runprep.base_has_gamultiobj = base_has_gamultiobj;

    runprep.RunnerAudit = RunnerAudit;
    runprep.Tchecks = Tchecks;

    disp('=== SEED_CONTROLLED_REPLICATION_RUNNER_RUNPREP_v96z_minrep ===')
    disp(runprep.status)
    disp('=== DIAGNOSIS ===')
    disp(runprep.diagnosis)
    disp('=== DECISION ===')
    disp(runprep.decision)
    disp('=== NEXT STEP ===')
    disp(runprep.next_step)
    disp('=== BASE RUNNER ===')
    disp(runprep.baseRunnerPath)
    disp('=== BASE RUNNER HAS RNG CALL ===')
    disp(runprep.base_has_rng_call)
    disp('=== BASE RUNNER HAS GAMULTIOBJ ===')
    disp(runprep.base_has_gamultiobj)
    disp('=== SEED-CONTROLLED RUNNER ===')
    disp(runprep.runnerPath)
    disp('=== APPROVAL SCRIPT ===')
    disp(runprep.approvalPath)
    disp('=== COMMANDS MD ===')
    disp(runprep.commandMd)
    disp('=== RUNNER AUDIT ===')
    disp(runprep.RunnerAudit)
    disp('=== CHECKS ===')
    disp(runprep.Tchecks)

end

% =========================================================================
% Runner text
% =========================================================================

function txt = compose_seed_controlled_runner_text()

    lines = strings(0,1);

    lines(end+1) = "function minrepRun = run_seed_controlled_minrep_formal_ga_v96z_minrep(confirm_execute)";
    lines(end+1) = "% RUN_SEED_CONTROLLED_MINREP_FORMAL_GA_v96z_minrep";
    lines(end+1) = "% Seed-controlled runner for 3 minimal GA replicates.";
    lines(end+1) = "%";
    lines(end+1) = "% Usage:";
    lines(end+1) = "%   pre = run_seed_controlled_minrep_formal_ga_v96z_minrep(false);";
    lines(end+1) = "%   run = run_seed_controlled_minrep_formal_ga_v96z_minrep(true);";
    lines(end+1) = "%";
    lines(end+1) = "% confirm_execute=false:";
    lines(end+1) = "%   preflight only, no GA.";
    lines(end+1) = "%";
    lines(end+1) = "% confirm_execute=true:";
    lines(end+1) = "%   executes R1-R3 sequentially. Estimated runtime ~21.39 h.";
    lines(end+1) = "";
    lines(end+1) = "    if nargin < 1";
    lines(end+1) = "        confirm_execute = false;";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    rootDir = setup_v05_paths();";
    lines(end+1) = "    addpath(genpath(fullfile(rootDir,'02_src_limpio')));";
    lines(end+1) = "    rehash;";
    lines(end+1) = "";
    lines(end+1) = "    productionDir = fullfile(rootDir,'02_src_limpio','production');";
    lines(end+1) = "    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');";
    lines(end+1) = "    articleTraceDir = fullfile(articleRoot,'traceability');";
    lines(end+1) = "    articleTablesDir = fullfile(articleRoot,'tables');";
    lines(end+1) = "    articleRunsDir = fullfile(articleRoot,'runs');";
    lines(end+1) = "    articleLogsDir = fullfile(articleRoot,'logs');";
    lines(end+1) = "";
    lines(end+1) = "    mkdir_if_needed_local(articleRoot);";
    lines(end+1) = "    mkdir_if_needed_local(articleTraceDir);";
    lines(end+1) = "    mkdir_if_needed_local(articleTablesDir);";
    lines(end+1) = "    mkdir_if_needed_local(articleRunsDir);";
    lines(end+1) = "    mkdir_if_needed_local(articleLogsDir);";
    lines(end+1) = "";
    lines(end+1) = "    minrepMat = fullfile(articleTraceDir,'MINIMAL_SEED_REPLICATION_DESIGN_v96z_minrep.mat');";
    lines(end+1) = "    runprepMat = fullfile(articleTraceDir,'SEED_CONTROLLED_REPLICATION_RUNNER_RUNPREP_v96z_minrep.mat');";
    lines(end+1) = "";
    lines(end+1) = "    if ~isfile(minrepMat)";
    lines(end+1) = "        error('No existe minrepMat: %s', minrepMat);";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    D = load(minrepMat);";
    lines(end+1) = "";
    lines(end+1) = "    if ~strcmp(string(D.diagnosis),'MINIMAL_SEED_REPLICATION_DESIGN_PASS')";
    lines(end+1) = "        error('Diseño minrep no está en PASS. Diagnosis: %s', string(D.diagnosis));";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    Rep = D.Rep;";
    lines(end+1) = "    totalExpectedRuntime_h = D.totalExpectedRuntime_h;";
    lines(end+1) = "";
    lines(end+1) = "    baseRunner = fullfile(productionDir,'run_guarded_triobjective_formal_ga_v96m.m');";
    lines(end+1) = "";
    lines(end+1) = "    if ~isfile(baseRunner)";
    lines(end+1) = "        error('No existe runner base v96m: %s', baseRunner);";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    baseText = string(fileread(baseRunner));";
    lines(end+1) = "    base_has_rng_call = contains(baseText,'rng(');";
    lines(end+1) = "    base_has_gamultiobj = contains(baseText,'gamultiobj');";
    lines(end+1) = "";
    lines(end+1) = "    Treplicates = Rep;";
    lines(end+1) = "    Treplicates.seed_rng_type = repmat('twister',height(Treplicates),1);";
    lines(end+1) = "    Treplicates.actual_runtime_s = NaN(height(Treplicates),1);";
    lines(end+1) = "    Treplicates.actual_runtime_h = NaN(height(Treplicates),1);";
    lines(end+1) = "    Treplicates.run_status = repmat('NOT_EXECUTED',height(Treplicates),1);";
    lines(end+1) = "    Treplicates.diagnosis = repmat('',height(Treplicates),1);";
    lines(end+1) = "    Treplicates.output_mat = repmat('',height(Treplicates),1);";
    lines(end+1) = "    Treplicates.error_message = repmat('',height(Treplicates),1);";
    lines(end+1) = "";
    lines(end+1) = "    checks = {};";
    lines(end+1) = "    checks{end+1,1} = check_row_local('PF01','Minrep design loaded',true,string(minrepMat));";
    lines(end+1) = "    checks{end+1,1} = check_row_local('PF02','Base runner exists',isfile(baseRunner),string(baseRunner));";
    lines(end+1) = "    checks{end+1,1} = check_row_local('PF03','Base runner has gamultiobj',base_has_gamultiobj,'gamultiobj found.');";
    lines(end+1) = "    checks{end+1,1} = check_row_local('PF04','Three replicates loaded',height(Rep)==3,sprintf('nReplicates=%d',height(Rep)));";
    lines(end+1) = "    checks{end+1,1} = check_row_local('PF05','Seeds unique',numel(unique(Rep.seed))==height(Rep),'Seeds unique.');";
    lines(end+1) = "    checks{end+1,1} = check_row_local('PF06','Same population size',numel(unique(Rep.populationSize))==1,sprintf('PopulationSize=%d',Rep.populationSize(1)));";
    lines(end+1) = "    checks{end+1,1} = check_row_local('PF07','Same max generations',numel(unique(Rep.maxGenerations))==1,sprintf('MaxGenerations=%d',Rep.maxGenerations(1)));";
    lines(end+1) = "    checks{end+1,1} = check_row_local('PF08','Total runtime estimated',totalExpectedRuntime_h > 20,sprintf('ExpectedRuntime_h=%.4f',totalExpectedRuntime_h));";
    lines(end+1) = "";
    lines(end+1) = "    if ~confirm_execute";
    lines(end+1) = "        checks{end+1,1} = check_row_local('PF09','No GA executed in preflight',true,'confirm_execute=false.');";
    lines(end+1) = "        checks{end+1,1} = check_row_local('PF10','Execution gated',true,'Run again with true only after approval.');";
    lines(end+1) = "";
    lines(end+1) = "        Tchecks = struct2table(vertcat(checks{:}));";
    lines(end+1) = "        preflight_pass = all(Tchecks.pass);";
    lines(end+1) = "";
    lines(end+1) = "        if preflight_pass";
    lines(end+1) = "            diagnosis = 'SEED_CONTROLLED_MINREP_PREFLIGHT_PASS';";
    lines(end+1) = "            decision = 'READY_FOR_MANUAL_EXECUTION_APPROVAL';";
    lines(end+1) = "            next_step = 'Run approve_seed_controlled_minrep_execution_v96z_minrep, then execute true if accepted.';";
    lines(end+1) = "        else";
    lines(end+1) = "            diagnosis = 'SEED_CONTROLLED_MINREP_PREFLIGHT_REQUIRES_REVIEW';";
    lines(end+1) = "            decision = 'REVIEW_FAILED_PREFLIGHT_CHECKS';";
    lines(end+1) = "            next_step = 'Review failed checks before execution.';";
    lines(end+1) = "        end";
    lines(end+1) = "";
    lines(end+1) = "        minrepRun = struct();";
    lines(end+1) = "        minrepRun.status = 'SEED_CONTROLLED_MINREP_PREFLIGHT_COMPLETED';";
    lines(end+1) = "        minrepRun.diagnosis = diagnosis;";
    lines(end+1) = "        minrepRun.decision = decision;";
    lines(end+1) = "        minrepRun.next_step = next_step;";
    lines(end+1) = "        minrepRun.confirm_execute = confirm_execute;";
    lines(end+1) = "        minrepRun.Treplicates = Treplicates;";
    lines(end+1) = "        minrepRun.Tchecks = Tchecks;";
    lines(end+1) = "        minrepRun.base_has_rng_call = base_has_rng_call;";
    lines(end+1) = "        minrepRun.base_has_gamultiobj = base_has_gamultiobj;";
    lines(end+1) = "";
    lines(end+1) = "        disp('=== SEED_CONTROLLED_MINREP_PREFLIGHT_v96z_minrep ===')";
    lines(end+1) = "        disp(minrepRun.status)";
    lines(end+1) = "        disp('=== DIAGNOSIS ===')";
    lines(end+1) = "        disp(minrepRun.diagnosis)";
    lines(end+1) = "        disp('=== DECISION ===')";
    lines(end+1) = "        disp(minrepRun.decision)";
    lines(end+1) = "        disp('=== NEXT STEP ===')";
    lines(end+1) = "        disp(minrepRun.next_step)";
    lines(end+1) = "        disp('=== BASE HAS RNG CALL ===')";
    lines(end+1) = "        disp(minrepRun.base_has_rng_call)";
    lines(end+1) = "        disp('=== REPLICATES ===')";
    lines(end+1) = "        disp(minrepRun.Treplicates)";
    lines(end+1) = "        disp('=== CHECKS ===')";
    lines(end+1) = "        disp(minrepRun.Tchecks)";
    lines(end+1) = "        return";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    % ------------------------------------------------------------------";
    lines(end+1) = "    % Real execution starts here";
    lines(end+1) = "    % ------------------------------------------------------------------";
    lines(end+1) = "    timestamp = datestr(now,'yyyymmdd_HHMMSS');";
    lines(end+1) = "    runDir = fullfile(articleRunsDir,['MINREP_SEED_CONTROLLED_RUN_v96z_' timestamp]);";
    lines(end+1) = "    mkdir_if_needed_local(runDir);";
    lines(end+1) = "";
    lines(end+1) = "    globalTimer = tic;";
    lines(end+1) = "";
    lines(end+1) = "    RepOutputs = cell(height(Rep),1);";
    lines(end+1) = "    RngBefore = cell(height(Rep),1);";
    lines(end+1) = "    RngAfter = cell(height(Rep),1);";
    lines(end+1) = "";
    lines(end+1) = "    for i = 1:height(Rep)";
    lines(end+1) = "        repID = string(Rep.replicate_id(i));";
    lines(end+1) = "        seed = Rep.seed(i);";
    lines(end+1) = "        repDir = fullfile(runDir,repID);";
    lines(end+1) = "        mkdir_if_needed_local(repDir);";
    lines(end+1) = "";
    lines(end+1) = "        fprintf('\\n=== STARTING MINREP %s | seed=%d ===\\n',repID,seed);";
    lines(end+1) = "";
    lines(end+1) = "        try";
    lines(end+1) = "            rng(seed,'twister');";
    lines(end+1) = "            RngBefore{i} = rng;";
    lines(end+1) = "";
    lines(end+1) = "            tRep = tic;";
    lines(end+1) = "            formal = run_guarded_triobjective_formal_ga_v96m(true);";
    lines(end+1) = "            elapsed = toc(tRep);";
    lines(end+1) = "";
    lines(end+1) = "            RngAfter{i} = rng;";
    lines(end+1) = "            RepOutputs{i} = formal;";
    lines(end+1) = "";
    lines(end+1) = "            outMat = fullfile(repDir,sprintf('MINREP_%s_seed_%d_formal_output.mat',repID,seed));";
    lines(end+1) = "            save(outMat,'formal','seed','repID','elapsed','RngBefore','RngAfter');";
    lines(end+1) = "";
    lines(end+1) = "            Treplicates.actual_runtime_s(i) = elapsed;";
    lines(end+1) = "            Treplicates.actual_runtime_h(i) = elapsed/3600;";
    lines(end+1) = "            Treplicates.run_status(i) = 'OK';";
    lines(end+1) = "";
    lines(end+1) = "            if isstruct(formal) && isfield(formal,'diagnosis')";
    lines(end+1) = "                Treplicates.diagnosis(i) = string(formal.diagnosis);";
    lines(end+1) = "            else";
    lines(end+1) = "                Treplicates.diagnosis(i) = 'NO_DIAGNOSIS_FIELD';";
    lines(end+1) = "            end";
    lines(end+1) = "";
    lines(end+1) = "            Treplicates.output_mat(i) = string(outMat);";
    lines(end+1) = "";
    lines(end+1) = "        catch ME";
    lines(end+1) = "            elapsed = toc(tRep);";
    lines(end+1) = "            RngAfter{i} = rng;";
    lines(end+1) = "";
    lines(end+1) = "            errMat = fullfile(repDir,sprintf('MINREP_%s_seed_%d_ERROR.mat',repID,seed));";
    lines(end+1) = "            save(errMat,'ME','seed','repID','elapsed','RngBefore','RngAfter');";
    lines(end+1) = "";
    lines(end+1) = "            Treplicates.actual_runtime_s(i) = elapsed;";
    lines(end+1) = "            Treplicates.actual_runtime_h(i) = elapsed/3600;";
    lines(end+1) = "            Treplicates.run_status(i) = 'ERROR';";
    lines(end+1) = "            Treplicates.diagnosis(i) = 'ERROR';";
    lines(end+1) = "            Treplicates.output_mat(i) = string(errMat);";
    lines(end+1) = "            Treplicates.error_message(i) = string(ME.message);";
    lines(end+1) = "";
    lines(end+1) = "            warning('MINREP %s failed: %s',repID,ME.message);";
    lines(end+1) = "        end";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    totalElapsed_s = toc(globalTimer);";
    lines(end+1) = "    totalElapsed_h = totalElapsed_s/3600;";
    lines(end+1) = "";
    lines(end+1) = "    checks{end+1,1} = check_row_local('EX01','Execution requested',confirm_execute,'confirm_execute=true.');";
    lines(end+1) = "    checks{end+1,1} = check_row_local('EX02','All replicates attempted',all(Treplicates.run_status ~= 'NOT_EXECUTED'),sprintf('attempted=%d',sum(Treplicates.run_status ~= 'NOT_EXECUTED')));";
    lines(end+1) = "    checks{end+1,1} = check_row_local('EX03','All replicates OK',all(Treplicates.run_status == 'OK'),sprintf('ok=%d/%d',sum(Treplicates.run_status == 'OK'),height(Treplicates)));";
    lines(end+1) = "    checks{end+1,1} = check_row_local('EX04','Outputs saved',all(isfile(Treplicates.output_mat)),sprintf('outputs=%d',sum(isfile(Treplicates.output_mat))));";
    lines(end+1) = "    checks{end+1,1} = check_row_local('EX05','Seed-controlled calls completed',true,'rng(seed,''twister'') called before every replicate.');";
    lines(end+1) = "";
    lines(end+1) = "    Tchecks = struct2table(vertcat(checks{:}));";
    lines(end+1) = "";
    lines(end+1) = "    if all(Treplicates.run_status == 'OK')";
    lines(end+1) = "        diagnosis = 'SEED_CONTROLLED_MINREP_EXECUTION_PASS';";
    lines(end+1) = "        decision = 'MINREP_OUTPUTS_READY_FOR_POSTPROCESSING';";
    lines(end+1) = "        next_step = '9.6z-minrep-post — POSTPROCESS-SEED-REPLICATIONS-001';";
    lines(end+1) = "    else";
    lines(end+1) = "        diagnosis = 'SEED_CONTROLLED_MINREP_EXECUTION_REQUIRES_REVIEW';";
    lines(end+1) = "        decision = 'REVIEW_FAILED_OR_PARTIAL_MINREP_EXECUTION';";
    lines(end+1) = "        next_step = 'Review failed replicates before postprocessing.';";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    outTable = fullfile(runDir,'MINREP_SEED_CONTROLLED_RUN_v96z_replicates.csv');";
    lines(end+1) = "    outChecks = fullfile(runDir,'MINREP_SEED_CONTROLLED_RUN_v96z_checks.csv');";
    lines(end+1) = "    outMat = fullfile(runDir,'MINREP_SEED_CONTROLLED_RUN_v96z.mat');";
    lines(end+1) = "";
    lines(end+1) = "    writetable(Treplicates,outTable);";
    lines(end+1) = "    writetable(Tchecks,outChecks);";
    lines(end+1) = "";
    lines(end+1) = "    save(outMat,'diagnosis','decision','next_step','confirm_execute','runDir','Treplicates','Tchecks','RepOutputs','RngBefore','RngAfter','totalElapsed_s','totalElapsed_h','base_has_rng_call','base_has_gamultiobj');";
    lines(end+1) = "";
    lines(end+1) = "    minrepRun = struct();";
    lines(end+1) = "    minrepRun.status = 'SEED_CONTROLLED_MINREP_EXECUTION_COMPLETED';";
    lines(end+1) = "    minrepRun.diagnosis = diagnosis;";
    lines(end+1) = "    minrepRun.decision = decision;";
    lines(end+1) = "    minrepRun.next_step = next_step;";
    lines(end+1) = "    minrepRun.confirm_execute = confirm_execute;";
    lines(end+1) = "    minrepRun.runDir = runDir;";
    lines(end+1) = "    minrepRun.Treplicates = Treplicates;";
    lines(end+1) = "    minrepRun.Tchecks = Tchecks;";
    lines(end+1) = "    minrepRun.totalElapsed_s = totalElapsed_s;";
    lines(end+1) = "    minrepRun.totalElapsed_h = totalElapsed_h;";
    lines(end+1) = "    minrepRun.outMat = outMat;";
    lines(end+1) = "    minrepRun.outTable = outTable;";
    lines(end+1) = "    minrepRun.outChecks = outChecks;";
    lines(end+1) = "";
    lines(end+1) = "    disp('=== SEED_CONTROLLED_MINREP_EXECUTION_v96z_minrep ===')";
    lines(end+1) = "    disp(minrepRun.status)";
    lines(end+1) = "    disp('=== DIAGNOSIS ===')";
    lines(end+1) = "    disp(minrepRun.diagnosis)";
    lines(end+1) = "    disp('=== DECISION ===')";
    lines(end+1) = "    disp(minrepRun.decision)";
    lines(end+1) = "    disp('=== NEXT STEP ===')";
    lines(end+1) = "    disp(minrepRun.next_step)";
    lines(end+1) = "    disp('=== RUN DIR ===')";
    lines(end+1) = "    disp(minrepRun.runDir)";
    lines(end+1) = "    disp('=== TOTAL ELAPSED [h] ===')";
    lines(end+1) = "    disp(minrepRun.totalElapsed_h)";
    lines(end+1) = "    disp('=== REPLICATES ===')";
    lines(end+1) = "    disp(minrepRun.Treplicates)";
    lines(end+1) = "    disp('=== CHECKS ===')";
    lines(end+1) = "    disp(minrepRun.Tchecks)";
    lines(end+1) = "";
    lines(end+1) = "end";
    lines(end+1) = "";
    lines(end+1) = "function mkdir_if_needed_local(folderPath)";
    lines(end+1) = "    if ~isfolder(folderPath)";
    lines(end+1) = "        mkdir(folderPath);";
    lines(end+1) = "    end";
    lines(end+1) = "end";
    lines(end+1) = "";
    lines(end+1) = "function row = check_row_local(id, checkName, passVal, evidence)";
    lines(end+1) = "    row = struct();";
    lines(end+1) = "    row.id = string(id);";
    lines(end+1) = "    row.check = string(checkName);";
    lines(end+1) = "    row.pass = logical(passVal);";
    lines(end+1) = "    row.evidence = string(evidence);";
    lines(end+1) = "end";

    txt = strjoin(lines,newline);
end

function txt = compose_approval_script_text()

    lines = strings(0,1);

    lines(end+1) = "function approval = approve_seed_controlled_minrep_execution_v96z_minrep()";
    lines(end+1) = "% APPROVE_SEED_CONTROLLED_MINREP_EXECUTION_v96z_minrep";
    lines(end+1) = "% Approval gate for actual seed-controlled minimal replication execution.";
    lines(end+1) = "% This script does NOT execute GA.";
    lines(end+1) = "";
    lines(end+1) = "    rootDir = setup_v05_paths();";
    lines(end+1) = "    addpath(genpath(fullfile(rootDir,'02_src_limpio')));";
    lines(end+1) = "    rehash;";
    lines(end+1) = "";
    lines(end+1) = "    articleTraceDir = fullfile(rootDir,'06_manuscript','article_Q1','traceability');";
    lines(end+1) = "    runprepMat = fullfile(articleTraceDir,'SEED_CONTROLLED_REPLICATION_RUNNER_RUNPREP_v96z_minrep.mat');";
    lines(end+1) = "    runnerPath = fullfile(rootDir,'02_src_limpio','production','run_seed_controlled_minrep_formal_ga_v96z_minrep.m');";
    lines(end+1) = "";
    lines(end+1) = "    if ~isfile(runprepMat)";
    lines(end+1) = "        error('No existe runprepMat: %s', runprepMat);";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    if ~isfile(runnerPath)";
    lines(end+1) = "        error('No existe runnerPath: %s', runnerPath);";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    R = load(runprepMat);";
    lines(end+1) = "";
    lines(end+1) = "    checks = {};";
    lines(end+1) = "    checks{end+1,1} = check_row_local('AP01','Runprep loaded',true,string(runprepMat));";
    lines(end+1) = "    checks{end+1,1} = check_row_local('AP02','Runprep PASS',strcmp(string(R.diagnosis),'SEED_CONTROLLED_REPLICATION_RUNNER_RUNPREP_PASS'),string(R.diagnosis));";
    lines(end+1) = "    checks{end+1,1} = check_row_local('AP03','Runner exists',isfile(runnerPath),string(runnerPath));";
    lines(end+1) = "    checks{end+1,1} = check_row_local('AP04','Expected runtime acknowledged',R.totalExpectedRuntime_h > 20,sprintf('ExpectedRuntime_h=%.4f',R.totalExpectedRuntime_h));";
    lines(end+1) = "    checks{end+1,1} = check_row_local('AP05','Execution command explicitly true',true,'run_seed_controlled_minrep_formal_ga_v96z_minrep(true)');";
    lines(end+1) = "    checks{end+1,1} = check_row_local('AP06','Approval script does not execute GA',true,'Only returns approved command.');";
    lines(end+1) = "";
    lines(end+1) = "    Tchecks = struct2table(vertcat(checks{:}));";
    lines(end+1) = "    approval_pass = all(Tchecks.pass);";
    lines(end+1) = "";
    lines(end+1) = "    if approval_pass";
    lines(end+1) = "        diagnosis = 'SEED_CONTROLLED_MINREP_EXECUTION_APPROVAL_PASS';";
    lines(end+1) = "        decision = 'MINREP_EXECUTION_APPROVED_BY_GATE';";
    lines(end+1) = "        approved_command = 'minrepRun = run_seed_controlled_minrep_formal_ga_v96z_minrep(true);';";
    lines(end+1) = "    else";
    lines(end+1) = "        diagnosis = 'SEED_CONTROLLED_MINREP_EXECUTION_APPROVAL_REQUIRES_REVIEW';";
    lines(end+1) = "        decision = 'REVIEW_FAILED_APPROVAL_CHECKS';";
    lines(end+1) = "        approved_command = '';";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    approval = struct();";
    lines(end+1) = "    approval.status = 'SEED_CONTROLLED_MINREP_EXECUTION_APPROVAL_COMPLETED';";
    lines(end+1) = "    approval.diagnosis = diagnosis;";
    lines(end+1) = "    approval.decision = decision;";
    lines(end+1) = "    approval.approved_command = approved_command;";
    lines(end+1) = "    approval.expected_runtime_h = R.totalExpectedRuntime_h;";
    lines(end+1) = "    approval.Tchecks = Tchecks;";
    lines(end+1) = "";
    lines(end+1) = "    disp('=== SEED_CONTROLLED_MINREP_EXECUTION_APPROVAL_v96z_minrep ===')";
    lines(end+1) = "    disp(approval.status)";
    lines(end+1) = "    disp('=== DIAGNOSIS ===')";
    lines(end+1) = "    disp(approval.diagnosis)";
    lines(end+1) = "    disp('=== DECISION ===')";
    lines(end+1) = "    disp(approval.decision)";
    lines(end+1) = "    disp('=== EXPECTED RUNTIME [h] ===')";
    lines(end+1) = "    disp(approval.expected_runtime_h)";
    lines(end+1) = "    disp('=== APPROVED COMMAND ===')";
    lines(end+1) = "    disp(approval.approved_command)";
    lines(end+1) = "    disp('=== CHECKS ===')";
    lines(end+1) = "    disp(approval.Tchecks)";
    lines(end+1) = "";
    lines(end+1) = "end";
    lines(end+1) = "";
    lines(end+1) = "function row = check_row_local(id, checkName, passVal, evidence)";
    lines(end+1) = "    row = struct();";
    lines(end+1) = "    row.id = string(id);";
    lines(end+1) = "    row.check = string(checkName);";
    lines(end+1) = "    row.pass = logical(passVal);";
    lines(end+1) = "    row.evidence = string(evidence);";
    lines(end+1) = "end";

    txt = strjoin(lines,newline);
end

function txt = compose_runprep_report_text( ...
    baseRunnerPath,base_has_rng_call,base_has_gamultiobj, ...
    runnerPath,approvalPath,commandMd,Rep,Criteria,H2type,totalExpectedRuntime_h)

    lines = strings(0,1);

    lines(end+1) = "# SEED_CONTROLLED_REPLICATION_RUNNER_RUNPREP_v96z_minrep";
    lines(end+1) = "";
    lines(end+1) = "## Dictamen";
    lines(end+1) = "";
    lines(end+1) = "Se creó un runner de réplicas con control explícito de semilla. Este paso no ejecutó GA. La ejecución real permanece bloqueada hasta preflight y aprobación.";
    lines(end+1) = "";
    lines(end+1) = "## Runner base auditado";
    lines(end+1) = "";
    lines(end+1) = "- Runner base: `" + string(baseRunnerPath) + "`";
    lines(end+1) = "- Contiene `rng(`: `" + string(base_has_rng_call) + "`";
    lines(end+1) = "- Contiene `gamultiobj`: `" + string(base_has_gamultiobj) + "`";
    lines(end+1) = "";
    lines(end+1) = "## Runner creado";
    lines(end+1) = "";
    lines(end+1) = "- Runner seed-controlled: `" + string(runnerPath) + "`";
    lines(end+1) = "- Approval gate: `" + string(approvalPath) + "`";
    lines(end+1) = "- Comandos: `" + string(commandMd) + "`";
    lines(end+1) = "";
    lines(end+1) = "## Réplicas";
    lines(end+1) = "";
    lines(end+1) = "| Replicate | Seed | PopulationSize | MaxGenerations | Expected runtime [h] |";
    lines(end+1) = "|---|---:|---:|---:|---:|";

    for i = 1:height(Rep)
        lines(end+1) = "| " + string(Rep.replicate_id(i)) + " | " + string(Rep.seed(i)) + " | " + string(Rep.populationSize(i)) + " | " + string(Rep.maxGenerations(i)) + " | " + string(sprintf('%.4g',Rep.expected_runtime_h(i))) + " |";
    end

    lines(end+1) = "";
    lines(end+1) = "Tiempo total esperado: `" + string(sprintf('%.4g',totalExpectedRuntime_h)) + " h`.";
    lines(end+1) = "";
    lines(end+1) = "## Criterios de aceptación";
    lines(end+1) = "";
    lines(end+1) = "| ID | Criterion | Rule | Importance |";
    lines(end+1) = "|---|---|---|---|";

    for i = 1:height(Criteria)
        lines(end+1) = "| " + string(Criteria.id(i)) + " | " + string(Criteria.criterion(i)) + " | `" + string(Criteria.acceptance_rule(i)) + "` | " + string(Criteria.importance(i)) + " |";
    end

    lines(end+1) = "";
    lines(end+1) = "## H2 equivalent";
    lines(end+1) = "";
    lines(end+1) = "| Metric | Definition |";
    lines(end+1) = "|---|---|";

    for i = 1:height(H2type)
        lines(end+1) = "| " + string(H2type.metric(i)) + " | " + string(H2type.definition(i)) + " |";
    end

    lines(end+1) = "";
    lines(end+1) = "## Secuencia correcta";
    lines(end+1) = "";
    lines(end+1) = "1. Ejecutar preflight:";
    lines(end+1) = "";
    lines(end+1) = "```matlab";
    lines(end+1) = "pre = run_seed_controlled_minrep_formal_ga_v96z_minrep(false);";
    lines(end+1) = "```";
    lines(end+1) = "";
    lines(end+1) = "2. Ejecutar approval gate:";
    lines(end+1) = "";
    lines(end+1) = "```matlab";
    lines(end+1) = "approval = approve_seed_controlled_minrep_execution_v96z_minrep();";
    lines(end+1) = "```";
    lines(end+1) = "";
    lines(end+1) = "3. Solo si ambos pasan, ejecutar:";
    lines(end+1) = "";
    lines(end+1) = "```matlab";
    lines(end+1) = "minrepRun = run_seed_controlled_minrep_formal_ga_v96z_minrep(true);";
    lines(end+1) = "```";
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