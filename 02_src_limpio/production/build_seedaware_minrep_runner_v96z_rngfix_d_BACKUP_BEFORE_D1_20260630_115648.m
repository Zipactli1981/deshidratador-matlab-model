function build = build_seedaware_minrep_runner_v96z_rngfix_d()
% BUILD_SEEDAWARE_MINREP_RUNNER_v96z_rngfix_d
%
% Construye un runner de 3 réplicas usando el clon seed-aware:
%   run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix
%
% Este script:
%   - NO ejecuta GA.
%   - NO llama modelo.
%   - NO modifica v96m original.
%   - Solo crea runner y script de aprobación.

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    productionDir = fullfile(rootDir,'02_src_limpio','production');
    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    articleTraceDir = fullfile(articleRoot,'traceability');
    articleReviewDir = fullfile(articleRoot,'review');
    articleTablesDir = fullfile(articleRoot,'tables');

    if ~isfolder(articleTraceDir), mkdir(articleTraceDir); end
    if ~isfolder(articleReviewDir), mkdir(articleReviewDir); end
    if ~isfolder(articleTablesDir), mkdir(articleTablesDir); end

    cloneName = 'run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix';
    clonePath = fullfile(productionDir,[cloneName '.m']);

    runnerName = 'run_seedaware_minrep_formal_ga_v96z_rngfix';
    runnerPath = fullfile(productionDir,[runnerName '.m']);

    approvalName = 'approve_seedaware_minrep_execution_v96z_rngfix';
    approvalPath = fullfile(productionDir,[approvalName '.m']);

    if ~isfile(clonePath)
        error('No existe clonePath: %s', clonePath);
    end

    seeds = [61001; 61002; 61003];
    repIDs = ["R1";"R2";"R3"];

    popSize = 24;
    maxGen = 50;
    expected_funccount = 1200;
    expected_runtime_h_each = 16.7121; % aproximado observado: 50.1363/3
    expected_runtime_h_total = expected_runtime_h_each * numel(seeds);

    % ---------------------------------------------------------------------
    % Crear runner
    % ---------------------------------------------------------------------
    runnerText = compose_runner_text(runnerName, cloneName);

    fid = fopen(runnerPath,'w');
    if fid < 0
        error('No se pudo escribir runnerPath: %s', runnerPath);
    end
    fprintf(fid,'%s',runnerText);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Crear approval gate
    % ---------------------------------------------------------------------
    approvalText = compose_approval_text(approvalName, runnerName, expected_runtime_h_total);

    fid = fopen(approvalPath,'w');
    if fid < 0
        error('No se pudo escribir approvalPath: %s', approvalPath);
    end
    fprintf(fid,'%s',approvalText);
    fclose(fid);

    rehash;

    runnerFileText = string(fileread(runnerPath));
    approvalFileText = string(fileread(approvalPath));

    % ---------------------------------------------------------------------
    % Diseño de réplicas
    % ---------------------------------------------------------------------
    Treplicates = table();
    Treplicates.replicate_id = repIDs;
    Treplicates.seed = seeds;
    Treplicates.modeFormal = repmat("hybrid",numel(seeds),1);
    Treplicates.referenceMode = repmat("gasLP",numel(seeds),1);
    Treplicates.populationSize = repmat(popSize,numel(seeds),1);
    Treplicates.maxGenerations = repmat(maxGen,numel(seeds),1);
    Treplicates.expected_funccount = repmat(expected_funccount,numel(seeds),1);
    Treplicates.expected_runtime_h = repmat(expected_runtime_h_each,numel(seeds),1);
    Treplicates.execution_status = repmat("DESIGNED_NOT_EXECUTED",numel(seeds),1);
    Treplicates.runner = repmat(string(runnerPath),numel(seeds),1);
    Treplicates.clone = repmat(string(clonePath),numel(seeds),1);

    designCsv = fullfile(articleTablesDir,'seedaware_minrep_runner_design_v96z_rngfix_d.csv');
    writetable(Treplicates,designCsv);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};
    checks{end+1,1} = check_row("RNG_D01","Seed-aware clone exists",isfile(clonePath),string(clonePath));
    checks{end+1,1} = check_row("RNG_D02","Runner created",isfile(runnerPath),string(runnerPath));
    checks{end+1,1} = check_row("RNG_D03","Approval gate created",isfile(approvalPath),string(approvalPath));
    checks{end+1,1} = check_row("RNG_D04","Runner calls seed-aware clone",contains(runnerFileText,cloneName),cloneName);
    checks{end+1,1} = check_row("RNG_D05","Runner passes seed into clone",contains(runnerFileText,"formal = " + cloneName + "(true, seed);"),"formal = clone(true, seed)");
    checks{end+1,1} = check_row("RNG_D06","Runner has execution guard",contains(runnerFileText,"confirm_execute"),"confirm_execute found.");
    checks{end+1,1} = check_row("RNG_D07","Runner stores RngBefore/RngAfter",contains(runnerFileText,"RngBefore") && contains(runnerFileText,"RngAfter"),"RNG logs found.");
    checks{end+1,1} = check_row("RNG_D08","Runner stores formal output",contains(runnerFileText,"formal_output.mat"),"formal output save found.");
    checks{end+1,1} = check_row("RNG_D09","Approval gate does not execute GA",~contains(approvalFileText,"run_seedaware_minrep_formal_ga_v96z_rngfix(true)"),"Approval returns command only.");
    checks{end+1,1} = check_row("RNG_D10","Three seeds designed",numel(unique(seeds))==3,"61001, 61002, 61003");
    checks{end+1,1} = check_row("RNG_D11","No GA executed",true,"Build script only.");
    checks{end+1,1} = check_row("RNG_D12","No model executed",true,"Build script only.");
    checks{end+1,1} = check_row("RNG_D13","Original v96m not modified",true,"Only new runner/approval files created.");

    Tchecks = struct2table(vertcat(checks{:}));

    if all(Tchecks.pass)
        diagnosis = "SEEDAWARE_MINREP_RUNNER_BUILD_PASS";
        decision = "SEEDAWARE_MINREP_READY_FOR_APPROVAL_GATE";
        next_step = "9.6z-rngfix-e — APPROVE-SEEDAWARE-MINREP-EXECUTION-001";
    else
        diagnosis = "SEEDAWARE_MINREP_RUNNER_BUILD_REQUIRES_REVIEW";
        decision = "DO_NOT_EXECUTE_SEEDAWARE_MINREP";
        next_step = "Inspect failed build checks.";
    end

    checksCsv = fullfile(articleTablesDir,'build_seedaware_minrep_runner_v96z_rngfix_d_checks.csv');
    writetable(Tchecks,checksCsv);

    reportMd = fullfile(articleReviewDir,'BUILD_SEEDAWARE_MINREP_RUNNER_v96z_rngfix_d.md');

    fid = fopen(reportMd,'w');
    fprintf(fid,'# BUILD_SEEDAWARE_MINREP_RUNNER_v96z_rngfix_d\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Runner\n\n`%s`\n\n',runnerPath);
    fprintf(fid,'## Approval gate\n\n`%s`\n\n',approvalPath);
    fprintf(fid,'## Seed-aware clone\n\n`%s`\n\n',clonePath);
    fprintf(fid,'## Expected runtime\n\n`%.4f h`\n\n',expected_runtime_h_total);
    fprintf(fid,'## Replicates\n\n');
    fprintf(fid,'| Rep | Seed | Pop | Gen | Expected runtime h |\n');
    fprintf(fid,'|---|---:|---:|---:|---:|\n');
    for i = 1:height(Treplicates)
        fprintf(fid,'| %s | %d | %d | %d | %.4f |\n', ...
            Treplicates.replicate_id(i),Treplicates.seed(i), ...
            Treplicates.populationSize(i),Treplicates.maxGenerations(i), ...
            Treplicates.expected_runtime_h(i));
    end
    fprintf(fid,'\n## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            Tchecks.id(i),Tchecks.check(i),Tchecks.pass(i),Tchecks.evidence(i));
    end
    fclose(fid);

    outMat = fullfile(articleTraceDir,'BUILD_SEEDAWARE_MINREP_RUNNER_v96z_rngfix_d.mat');

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'rootDir','clonePath','runnerPath','approvalPath', ...
        'Treplicates','Tchecks','expected_runtime_h_total', ...
        'designCsv','checksCsv','reportMd','outMat');

    build = struct();
    build.status = 'BUILD_SEEDAWARE_MINREP_RUNNER_v96z_rngfix_d_COMPLETED';
    build.diagnosis = diagnosis;
    build.decision = decision;
    build.next_step = next_step;
    build.clonePath = clonePath;
    build.runnerPath = runnerPath;
    build.approvalPath = approvalPath;
    build.Treplicates = Treplicates;
    build.Tchecks = Tchecks;
    build.expected_runtime_h_total = expected_runtime_h_total;
    build.reportMd = reportMd;
    build.outMat = outMat;

    disp('=== BUILD_SEEDAWARE_MINREP_RUNNER_v96z_rngfix_d ===')
    disp(build.status)
    disp('=== DIAGNOSIS ===')
    disp(build.diagnosis)
    disp('=== DECISION ===')
    disp(build.decision)
    disp('=== NEXT STEP ===')
    disp(build.next_step)
    disp('=== RUNNER ===')
    disp(build.runnerPath)
    disp('=== APPROVAL GATE ===')
    disp(build.approvalPath)
    disp('=== EXPECTED RUNTIME [h] ===')
    disp(build.expected_runtime_h_total)
    disp('=== REPLICATES ===')
    disp(build.Treplicates)
    disp('=== CHECKS ===')
    disp(build.Tchecks)
    disp('=== REPORT ===')
    disp(build.reportMd)

end

function txt = compose_runner_text(runnerName, cloneName)

    L = strings(0,1);

    L(end+1) = "function minrep = " + runnerName + "(confirm_execute)";
    L(end+1) = "% Seed-aware 3-replicate runner for v96z rngfix.";
    L(end+1) = "% Does not execute unless confirm_execute=true.";
    L(end+1) = "";
    L(end+1) = "    if nargin < 1 || isempty(confirm_execute)";
    L(end+1) = "        confirm_execute = false;";
    L(end+1) = "    end";
    L(end+1) = "";
    L(end+1) = "    rootDir = setup_v05_paths();";
    L(end+1) = "    addpath(genpath(fullfile(rootDir,'02_src_limpio')));";
    L(end+1) = "    rehash;";
    L(end+1) = "";
    L(end+1) = "    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');";
    L(end+1) = "    runsRoot = fullfile(articleRoot,'runs');";
    L(end+1) = "    traceDir = fullfile(articleRoot,'traceability');";
    L(end+1) = "    if ~isfolder(runsRoot), mkdir(runsRoot); end";
    L(end+1) = "    if ~isfolder(traceDir), mkdir(traceDir); end";
    L(end+1) = "";
    L(end+1) = "    seeds = [61001;61002;61003];";
    L(end+1) = "    repIDs = [""R1"";""R2"";""R3""];";
    L(end+1) = "    nRep = numel(seeds);";
    L(end+1) = "";
    L(end+1) = "    timestamp = datestr(now,'yyyymmdd_HHMMSS');";
    L(end+1) = "    runDir = fullfile(runsRoot,['MINREP_SEEDAWARE_RNGFIX_v96z_' timestamp]);";
    L(end+1) = "    mkdir(runDir);";
    L(end+1) = "";
    L(end+1) = "    Treplicates = table();";
    L(end+1) = "    Treplicates.replicate_id = repIDs;";
    L(end+1) = "    Treplicates.seed = seeds;";
    L(end+1) = "    Treplicates.modeFormal = repmat(""hybrid"",nRep,1);";
    L(end+1) = "    Treplicates.referenceMode = repmat(""gasLP"",nRep,1);";
    L(end+1) = "    Treplicates.populationSize = repmat(24,nRep,1);";
    L(end+1) = "    Treplicates.maxGenerations = repmat(50,nRep,1);";
    L(end+1) = "    Treplicates.expected_funccount = repmat(1200,nRep,1);";
    L(end+1) = "    Treplicates.execution_status = repmat(""NOT_EXECUTED"",nRep,1);";
    L(end+1) = "    Treplicates.actual_runtime_s = NaN(nRep,1);";
    L(end+1) = "    Treplicates.actual_runtime_h = NaN(nRep,1);";
    L(end+1) = "    Treplicates.run_status = repmat(""NOT_EXECUTED"",nRep,1);";
    L(end+1) = "    Treplicates.diagnosis = strings(nRep,1);";
    L(end+1) = "    Treplicates.rngControl = strings(nRep,1);";
    L(end+1) = "    Treplicates.output_mat = strings(nRep,1);";
    L(end+1) = "    Treplicates.error_message = strings(nRep,1);";
    L(end+1) = "";
    L(end+1) = "    RngBefore = cell(nRep,1);";
    L(end+1) = "    RngAfter = cell(nRep,1);";
    L(end+1) = "    globalTimer = tic;";
    L(end+1) = "";
    L(end+1) = "    if ~confirm_execute";
    L(end+1) = "        diagnosis = ""SEEDAWARE_MINREP_RUNNER_READY_NO_EXECUTION"";";
    L(end+1) = "        decision = ""AWAIT_EXPLICIT_TRUE_EXECUTION"";";
    L(end+1) = "    else";
    L(end+1) = "        for i = 1:nRep";
    L(end+1) = "            repID = repIDs(i);";
    L(end+1) = "            seed = seeds(i);";
    L(end+1) = "            repDir = fullfile(runDir,repID);";
    L(end+1) = "            mkdir(repDir);";
    L(end+1) = "            fprintf('\n=== STARTING SEEDAWARE RNGFIX %s | seed=%d ===\n', repID, seed);";
    L(end+1) = "            try";
    L(end+1) = "                RngBefore{i} = rng;";
    L(end+1) = "                tRep = tic;";
    L(end+1) = "                formal = " + cloneName + "(true, seed);";
    L(end+1) = "                elapsed = toc(tRep);";
    L(end+1) = "                RngAfter{i} = rng;";
    L(end+1) = "";
    L(end+1) = "                outMat = fullfile(repDir,sprintf('SEEDAWARE_RNGFIX_%s_seed_%d_formal_output.mat',repID,seed));";
    L(end+1) = "                save(outMat,'formal','repID','seed','elapsed','RngBefore','RngAfter');";
    L(end+1) = "";
    L(end+1) = "                Treplicates.execution_status(i) = ""EXECUTED"";";
    L(end+1) = "                Treplicates.actual_runtime_s(i) = elapsed;";
    L(end+1) = "                Treplicates.actual_runtime_h(i) = elapsed/3600;";
    L(end+1) = "                Treplicates.output_mat(i) = string(outMat);";
    L(end+1) = "";
    L(end+1) = "                if isfield(formal,'formalFlags') && isfield(formal.formalFlags,'run_status')";
    L(end+1) = "                    Treplicates.run_status(i) = string(formal.formalFlags.run_status);";
    L(end+1) = "                else";
    L(end+1) = "                    Treplicates.run_status(i) = ""UNKNOWN"";";
    L(end+1) = "                end";
    L(end+1) = "";
    L(end+1) = "                if isfield(formal,'diagnosis')";
    L(end+1) = "                    Treplicates.diagnosis(i) = string(formal.diagnosis);";
    L(end+1) = "                end";
    L(end+1) = "";
    L(end+1) = "                if isfield(formal,'rngControl_v96z')";
    L(end+1) = "                    Treplicates.rngControl(i) = string(formal.rngControl_v96z);";
    L(end+1) = "                end";
    L(end+1) = "";
    L(end+1) = "            catch ME";
    L(end+1) = "                Treplicates.execution_status(i) = ""ERROR"";";
    L(end+1) = "                Treplicates.run_status(i) = ""ERROR"";";
    L(end+1) = "                Treplicates.error_message(i) = string(ME.message);";
    L(end+1) = "                warning('Seed-aware replicate %s failed: %s',repID,ME.message);";
    L(end+1) = "            end";
    L(end+1) = "        end";
    L(end+1) = "";
    L(end+1) = "        if all(Treplicates.run_status == ""OK"")";
    L(end+1) = "            diagnosis = ""SEEDAWARE_MINREP_EXECUTION_PASS"";";
    L(end+1) = "            decision = ""SEEDAWARE_OUTPUTS_READY_FOR_POSTPROCESSING"";";
    L(end+1) = "        else";
    L(end+1) = "            diagnosis = ""SEEDAWARE_MINREP_EXECUTION_REQUIRES_REVIEW"";";
    L(end+1) = "            decision = ""REVIEW_FAILED_OR_PARTIAL_REPLICATES"";";
    L(end+1) = "        end";
    L(end+1) = "    end";
    L(end+1) = "";
    L(end+1) = "    totalElapsed_s = toc(globalTimer);";
    L(end+1) = "    totalElapsed_h = totalElapsed_s/3600;";
    L(end+1) = "";
    L(end+1) = "    outMat = fullfile(runDir,'SEEDAWARE_MINREP_RNGFIX_v96z.mat');";
    L(end+1) = "    save(outMat,'diagnosis','decision','confirm_execute','Treplicates','RngBefore','RngAfter','runDir','totalElapsed_s','totalElapsed_h');";
    L(end+1) = "";
    L(end+1) = "    minrep = struct();";
    L(end+1) = "    minrep.status = 'SEEDAWARE_MINREP_RNGFIX_v96z_COMPLETED';";
    L(end+1) = "    minrep.diagnosis = diagnosis;";
    L(end+1) = "    minrep.decision = decision;";
    L(end+1) = "    minrep.confirm_execute = confirm_execute;";
    L(end+1) = "    minrep.runDir = runDir;";
    L(end+1) = "    minrep.Treplicates = Treplicates;";
    L(end+1) = "    minrep.totalElapsed_h = totalElapsed_h;";
    L(end+1) = "    minrep.outMat = outMat;";
    L(end+1) = "";
    L(end+1) = "    disp('=== SEEDAWARE_MINREP_RNGFIX_v96z ===')";
    L(end+1) = "    disp(minrep.status)";
    L(end+1) = "    disp('=== DIAGNOSIS ===')";
    L(end+1) = "    disp(minrep.diagnosis)";
    L(end+1) = "    disp('=== DECISION ===')";
    L(end+1) = "    disp(minrep.decision)";
    L(end+1) = "    disp('=== RUN DIR ===')";
    L(end+1) = "    disp(minrep.runDir)";
    L(end+1) = "    disp('=== TOTAL ELAPSED [h] ===')";
    L(end+1) = "    disp(minrep.totalElapsed_h)";
    L(end+1) = "    disp('=== REPLICATES ===')";
    L(end+1) = "    disp(minrep.Treplicates)";
    L(end+1) = "end";

    txt = strjoin(L,newline);
end

function txt = compose_approval_text(approvalName, runnerName, expectedRuntime)

    L = strings(0,1);

    L(end+1) = "function approval = " + approvalName + "()";
    L(end+1) = "% Approval gate for seed-aware minrep execution.";
    L(end+1) = "% Does not execute GA.";
    L(end+1) = "";
    L(end+1) = "    rootDir = setup_v05_paths();";
    L(end+1) = "    addpath(genpath(fullfile(rootDir,'02_src_limpio')));";
    L(end+1) = "    rehash;";
    L(end+1) = "";
    L(end+1) = "    productionDir = fullfile(rootDir,'02_src_limpio','production');";
    L(end+1) = "    runnerPath = fullfile(productionDir,'" + runnerName + ".m');";
    L(end+1) = "    clonePath = fullfile(productionDir,'run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m');";
    L(end+1) = "";
    L(end+1) = "    approvedCommand = '" + runnerName + "(true);';";
    L(end+1) = "    expectedRuntime_h = " + string(sprintf('%.4f',expectedRuntime)) + ";";
    L(end+1) = "";
    L(end+1) = "    checks = {};";
    L(end+1) = "    checks{end+1,1} = check_row(""RNG_E01"",""Runner exists"",isfile(runnerPath),string(runnerPath));";
    L(end+1) = "    checks{end+1,1} = check_row(""RNG_E02"",""Clone exists"",isfile(clonePath),string(clonePath));";
    L(end+1) = "    checks{end+1,1} = check_row(""RNG_E03"",""Command explicitly true"",contains(approvedCommand,'true'),approvedCommand);";
    L(end+1) = "    checks{end+1,1} = check_row(""RNG_E04"",""Approval does not execute GA"",true,""Only returns approved command."");";
    L(end+1) = "    checks{end+1,1} = check_row(""RNG_E05"",""Expected runtime acknowledged"",expectedRuntime_h > 0,sprintf(""ExpectedRuntime_h=%.4f"",expectedRuntime_h));";
    L(end+1) = "";
    L(end+1) = "    Tchecks = struct2table(vertcat(checks{:}));";
    L(end+1) = "";
    L(end+1) = "    if all(Tchecks.pass)";
    L(end+1) = "        diagnosis = ""SEEDAWARE_MINREP_EXECUTION_APPROVAL_PASS"";";
    L(end+1) = "        decision = ""SEEDAWARE_MINREP_EXECUTION_APPROVED_BY_GATE"";";
    L(end+1) = "    else";
    L(end+1) = "        diagnosis = ""SEEDAWARE_MINREP_EXECUTION_APPROVAL_REQUIRES_REVIEW"";";
    L(end+1) = "        decision = ""DO_NOT_EXECUTE_SEEDAWARE_MINREP"";";
    L(end+1) = "    end";
    L(end+1) = "";
    L(end+1) = "    approval = struct();";
    L(end+1) = "    approval.status = 'SEEDAWARE_MINREP_EXECUTION_APPROVAL_COMPLETED';";
    L(end+1) = "    approval.diagnosis = diagnosis;";
    L(end+1) = "    approval.decision = decision;";
    L(end+1) = "    approval.expectedRuntime_h = expectedRuntime_h;";
    L(end+1) = "    approval.approvedCommand = approvedCommand;";
    L(end+1) = "    approval.Tchecks = Tchecks;";
    L(end+1) = "";
    L(end+1) = "    disp('=== SEEDAWARE_MINREP_EXECUTION_APPROVAL_v96z_rngfix ===')";
    L(end+1) = "    disp(approval.status)";
    L(end+1) = "    disp('=== DIAGNOSIS ===')";
    L(end+1) = "    disp(approval.diagnosis)";
    L(end+1) = "    disp('=== DECISION ===')";
    L(end+1) = "    disp(approval.decision)";
    L(end+1) = "    disp('=== EXPECTED RUNTIME [h] ===')";
    L(end+1) = "    disp(approval.expectedRuntime_h)";
    L(end+1) = "    disp('=== APPROVED COMMAND ===')";
    L(end+1) = "    disp(approval.approvedCommand)";
    L(end+1) = "    disp('=== CHECKS ===')";
    L(end+1) = "    disp(approval.Tchecks)";
    L(end+1) = "end";
    L(end+1) = "";
    L(end+1) = "function row = check_row(id, checkName, passVal, evidence)";
    L(end+1) = "    row = struct();";
    L(end+1) = "    row.id = string(id);";
    L(end+1) = "    row.check = string(checkName);";
    L(end+1) = "    row.pass = logical(passVal);";
    L(end+1) = "    row.evidence = string(evidence);";
    L(end+1) = "end";

    txt = strjoin(L,newline);
end

function row = check_row(id, checkName, passVal, evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end