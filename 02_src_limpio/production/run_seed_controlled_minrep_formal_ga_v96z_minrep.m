function minrepRun = run_seed_controlled_minrep_formal_ga_v96z_minrep(confirm_execute)
% RUN_SEED_CONTROLLED_MINREP_FORMAL_GA_v96z_minrep
% Seed-controlled runner for 3 minimal GA replicates.
%
% Usage:
%   pre = run_seed_controlled_minrep_formal_ga_v96z_minrep(false);
%   run = run_seed_controlled_minrep_formal_ga_v96z_minrep(true);
%
% confirm_execute=false:
%   preflight only, no GA.
%
% confirm_execute=true:
%   executes R1-R3 sequentially. Estimated runtime ~21.39 h.

    if nargin < 1
        confirm_execute = false;
    end

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    productionDir = fullfile(rootDir,'02_src_limpio','production');
    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    articleTraceDir = fullfile(articleRoot,'traceability');
    articleTablesDir = fullfile(articleRoot,'tables');
    articleRunsDir = fullfile(articleRoot,'runs');
    articleLogsDir = fullfile(articleRoot,'logs');

    mkdir_if_needed_local(articleRoot);
    mkdir_if_needed_local(articleTraceDir);
    mkdir_if_needed_local(articleTablesDir);
    mkdir_if_needed_local(articleRunsDir);
    mkdir_if_needed_local(articleLogsDir);

    minrepMat = fullfile(articleTraceDir,'MINIMAL_SEED_REPLICATION_DESIGN_v96z_minrep.mat');
    runprepMat = fullfile(articleTraceDir,'SEED_CONTROLLED_REPLICATION_RUNNER_RUNPREP_v96z_minrep.mat');

    if ~isfile(minrepMat)
        error('No existe minrepMat: %s', minrepMat);
    end

    D = load(minrepMat);

    if ~strcmp(string(D.diagnosis),'MINIMAL_SEED_REPLICATION_DESIGN_PASS')
        error('Diseño minrep no está en PASS. Diagnosis: %s', string(D.diagnosis));
    end

    Rep = D.Rep;
    totalExpectedRuntime_h = D.totalExpectedRuntime_h;

    baseRunner = fullfile(productionDir,'run_guarded_triobjective_formal_ga_v96m.m');

    if ~isfile(baseRunner)
        error('No existe runner base v96m: %s', baseRunner);
    end

    baseText = string(fileread(baseRunner));
    base_has_rng_call = contains(baseText,'rng(');
    base_has_gamultiobj = contains(baseText,'gamultiobj');

    Treplicates = Rep;
    Treplicates.seed_rng_type = repmat("twister",height(Treplicates),1);
    Treplicates.actual_runtime_s = NaN(height(Treplicates),1);
    Treplicates.actual_runtime_h = NaN(height(Treplicates),1);
    Treplicates.run_status = repmat("NOT_EXECUTED",height(Treplicates),1);
    Treplicates.diagnosis = strings(height(Treplicates),1);
    Treplicates.output_mat = strings(height(Treplicates),1);
    Treplicates.error_message = strings(height(Treplicates),1);

    checks = {};
    checks{end+1,1} = check_row_local('PF01','Minrep design loaded',true,string(minrepMat));
    checks{end+1,1} = check_row_local('PF02','Base runner exists',isfile(baseRunner),string(baseRunner));
    checks{end+1,1} = check_row_local('PF03','Base runner has gamultiobj',base_has_gamultiobj,'gamultiobj found.');
    checks{end+1,1} = check_row_local('PF04','Three replicates loaded',height(Rep)==3,sprintf('nReplicates=%d',height(Rep)));
    checks{end+1,1} = check_row_local('PF05','Seeds unique',numel(unique(Rep.seed))==height(Rep),'Seeds unique.');
    checks{end+1,1} = check_row_local('PF06','Same population size',numel(unique(Rep.populationSize))==1,sprintf('PopulationSize=%d',Rep.populationSize(1)));
    checks{end+1,1} = check_row_local('PF07','Same max generations',numel(unique(Rep.maxGenerations))==1,sprintf('MaxGenerations=%d',Rep.maxGenerations(1)));
    checks{end+1,1} = check_row_local('PF08','Total runtime estimated',totalExpectedRuntime_h > 20,sprintf('ExpectedRuntime_h=%.4f',totalExpectedRuntime_h));

    if ~confirm_execute
        checks{end+1,1} = check_row_local('PF09','No GA executed in preflight',true,'confirm_execute=false.');
        checks{end+1,1} = check_row_local('PF10','Execution gated',true,'Run again with true only after approval.');

        Tchecks = struct2table(vertcat(checks{:}));
        preflight_pass = all(Tchecks.pass);

        if preflight_pass
            diagnosis = 'SEED_CONTROLLED_MINREP_PREFLIGHT_PASS';
            decision = 'READY_FOR_MANUAL_EXECUTION_APPROVAL';
            next_step = 'Run approve_seed_controlled_minrep_execution_v96z_minrep, then execute true if accepted.';
        else
            diagnosis = 'SEED_CONTROLLED_MINREP_PREFLIGHT_REQUIRES_REVIEW';
            decision = 'REVIEW_FAILED_PREFLIGHT_CHECKS';
            next_step = 'Review failed checks before execution.';
        end

        minrepRun = struct();
        minrepRun.status = 'SEED_CONTROLLED_MINREP_PREFLIGHT_COMPLETED';
        minrepRun.diagnosis = diagnosis;
        minrepRun.decision = decision;
        minrepRun.next_step = next_step;
        minrepRun.confirm_execute = confirm_execute;
        minrepRun.Treplicates = Treplicates;
        minrepRun.Tchecks = Tchecks;
        minrepRun.base_has_rng_call = base_has_rng_call;
        minrepRun.base_has_gamultiobj = base_has_gamultiobj;

        disp('=== SEED_CONTROLLED_MINREP_PREFLIGHT_v96z_minrep ===')
        disp(minrepRun.status)
        disp('=== DIAGNOSIS ===')
        disp(minrepRun.diagnosis)
        disp('=== DECISION ===')
        disp(minrepRun.decision)
        disp('=== NEXT STEP ===')
        disp(minrepRun.next_step)
        disp('=== BASE HAS RNG CALL ===')
        disp(minrepRun.base_has_rng_call)
        disp('=== REPLICATES ===')
        disp(minrepRun.Treplicates)
        disp('=== CHECKS ===')
        disp(minrepRun.Tchecks)
        return
    end

    % ------------------------------------------------------------------
    % Real execution starts here
    % ------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');
    runDir = fullfile(articleRunsDir,['MINREP_SEED_CONTROLLED_RUN_v96z_' timestamp]);
    mkdir_if_needed_local(runDir);

    globalTimer = tic;

    RepOutputs = cell(height(Rep),1);
    RngBefore = cell(height(Rep),1);
    RngAfter = cell(height(Rep),1);

    for i = 1:height(Rep)
        repID = string(Rep.replicate_id(i));
        seed = Rep.seed(i);
        repDir = fullfile(runDir,repID);
        mkdir_if_needed_local(repDir);

        fprintf('\\n=== STARTING MINREP %s | seed=%d ===\\n',repID,seed);

        try
            rng(seed,'twister');
            RngBefore{i} = rng;

            tRep = tic;
            formal = run_guarded_triobjective_formal_ga_v96m(true);
            elapsed = toc(tRep);

            RngAfter{i} = rng;
            RepOutputs{i} = formal;

            outMat = fullfile(repDir,sprintf('MINREP_%s_seed_%d_formal_output.mat',repID,seed));
            save(outMat,'formal','seed','repID','elapsed','RngBefore','RngAfter');

            Treplicates.actual_runtime_s(i) = elapsed;
            Treplicates.actual_runtime_h(i) = elapsed/3600;
            Treplicates.run_status(i) = "OK";

            if isstruct(formal) && isfield(formal,'diagnosis')
                Treplicates.diagnosis(i) = string(formal.diagnosis);
            else
                Treplicates.diagnosis(i) = "NO_DIAGNOSIS_FIELD";
            end

            Treplicates.output_mat(i) = string(outMat);

        catch ME
            elapsed = toc(tRep);
            RngAfter{i} = rng;

            errMat = fullfile(repDir,sprintf('MINREP_%s_seed_%d_ERROR.mat',repID,seed));
            save(errMat,'ME','seed','repID','elapsed','RngBefore','RngAfter');

            Treplicates.actual_runtime_s(i) = elapsed;
            Treplicates.actual_runtime_h(i) = elapsed/3600;
            Treplicates.run_status(i) = "ERROR";
            Treplicates.diagnosis(i) = "ERROR";
            Treplicates.output_mat(i) = string(errMat);
            Treplicates.error_message(i) = string(ME.message);

            warning('MINREP %s failed: %s',repID,ME.message);
        end
    end

    totalElapsed_s = toc(globalTimer);
    totalElapsed_h = totalElapsed_s/3600;

    checks{end+1,1} = check_row_local('EX01','Execution requested',confirm_execute,'confirm_execute=true.');
    checks{end+1,1} = check_row_local('EX02','All replicates attempted',all(Treplicates.run_status ~= "NOT_EXECUTED"),sprintf('attempted=%d',sum(Treplicates.run_status ~= "NOT_EXECUTED")));
    checks{end+1,1} = check_row_local('EX03','All replicates OK',all(Treplicates.run_status == "OK"),sprintf('ok=%d/%d',sum(Treplicates.run_status == "OK"),height(Treplicates)));
    checks{end+1,1} = check_row_local('EX04','Outputs saved',all(isfile(Treplicates.output_mat)),sprintf('outputs=%d',sum(isfile(Treplicates.output_mat))));
    checks{end+1,1} = check_row_local('EX05','Seed-controlled calls completed',true,'rng(seed,''twister'') called before every replicate.');

    Tchecks = struct2table(vertcat(checks{:}));

    if all(Treplicates.run_status == "OK")
        diagnosis = 'SEED_CONTROLLED_MINREP_EXECUTION_PASS';
        decision = 'MINREP_OUTPUTS_READY_FOR_POSTPROCESSING';
        next_step = '9.6z-minrep-post — POSTPROCESS-SEED-REPLICATIONS-001';
    else
        diagnosis = 'SEED_CONTROLLED_MINREP_EXECUTION_REQUIRES_REVIEW';
        decision = 'REVIEW_FAILED_OR_PARTIAL_MINREP_EXECUTION';
        next_step = 'Review failed replicates before postprocessing.';
    end

    outTable = fullfile(runDir,'MINREP_SEED_CONTROLLED_RUN_v96z_replicates.csv');
    outChecks = fullfile(runDir,'MINREP_SEED_CONTROLLED_RUN_v96z_checks.csv');
    outMat = fullfile(runDir,'MINREP_SEED_CONTROLLED_RUN_v96z.mat');

    writetable(Treplicates,outTable);
    writetable(Tchecks,outChecks);

    save(outMat,'diagnosis','decision','next_step','confirm_execute','runDir','Treplicates','Tchecks','RepOutputs','RngBefore','RngAfter','totalElapsed_s','totalElapsed_h','base_has_rng_call','base_has_gamultiobj');

    minrepRun = struct();
    minrepRun.status = 'SEED_CONTROLLED_MINREP_EXECUTION_COMPLETED';
    minrepRun.diagnosis = diagnosis;
    minrepRun.decision = decision;
    minrepRun.next_step = next_step;
    minrepRun.confirm_execute = confirm_execute;
    minrepRun.runDir = runDir;
    minrepRun.Treplicates = Treplicates;
    minrepRun.Tchecks = Tchecks;
    minrepRun.totalElapsed_s = totalElapsed_s;
    minrepRun.totalElapsed_h = totalElapsed_h;
    minrepRun.outMat = outMat;
    minrepRun.outTable = outTable;
    minrepRun.outChecks = outChecks;

    disp('=== SEED_CONTROLLED_MINREP_EXECUTION_v96z_minrep ===')
    disp(minrepRun.status)
    disp('=== DIAGNOSIS ===')
    disp(minrepRun.diagnosis)
    disp('=== DECISION ===')
    disp(minrepRun.decision)
    disp('=== NEXT STEP ===')
    disp(minrepRun.next_step)
    disp('=== RUN DIR ===')
    disp(minrepRun.runDir)
    disp('=== TOTAL ELAPSED [h] ===')
    disp(minrepRun.totalElapsed_h)
    disp('=== REPLICATES ===')
    disp(minrepRun.Treplicates)
    disp('=== CHECKS ===')
    disp(minrepRun.Tchecks)

end

function mkdir_if_needed_local(folderPath)
    if ~isfolder(folderPath)
        mkdir(folderPath);
    end
end

function row = check_row_local(id, checkName, passVal, evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end