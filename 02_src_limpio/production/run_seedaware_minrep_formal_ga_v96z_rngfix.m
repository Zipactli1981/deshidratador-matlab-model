function minrep = run_seedaware_minrep_formal_ga_v96z_rngfix(confirm_execute)
% Seed-aware 3-replicate runner for v96z rngfix.
% Does not execute unless confirm_execute=true.

    if nargin < 1 || isempty(confirm_execute)
        confirm_execute = false;
    end

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    runsRoot = fullfile(articleRoot,'runs');
    traceDir = fullfile(articleRoot,'traceability');
    if ~isfolder(runsRoot), mkdir(runsRoot); end
    if ~isfolder(traceDir), mkdir(traceDir); end

    seeds = [61001;61002;61003];
    repIDs = ["R1";"R2";"R3"];
    nRep = numel(seeds);

    timestamp = datestr(now,'yyyymmdd_HHMMSS');
    runDir = fullfile(runsRoot,['MINREP_SEEDAWARE_RNGFIX_v96z_' timestamp]);
    mkdir(runDir);

    Treplicates = table();
    Treplicates.replicate_id = repIDs;
    Treplicates.seed = seeds;
    Treplicates.modeFormal = repmat("hybrid",nRep,1);
    Treplicates.referenceMode = repmat("gasLP",nRep,1);
    Treplicates.populationSize = repmat(24,nRep,1);
    Treplicates.maxGenerations = repmat(50,nRep,1);
    Treplicates.expected_funccount = repmat(1200,nRep,1);
    Treplicates.execution_status = repmat("NOT_EXECUTED",nRep,1);
    Treplicates.actual_runtime_s = NaN(nRep,1);
    Treplicates.actual_runtime_h = NaN(nRep,1);
    Treplicates.run_status = repmat("NOT_EXECUTED",nRep,1);
    Treplicates.diagnosis = strings(nRep,1);
    Treplicates.rngControl = strings(nRep,1);
    Treplicates.output_mat = strings(nRep,1);
    Treplicates.error_message = strings(nRep,1);

    RngBefore = cell(nRep,1);
    RngAfter = cell(nRep,1);
    globalTimer = tic;

    if ~confirm_execute
        diagnosis = "SEEDAWARE_MINREP_RUNNER_READY_NO_EXECUTION";
        decision = "AWAIT_EXPLICIT_TRUE_EXECUTION";
    else
        for i = 1:nRep
            repID = repIDs(i);
            seed = seeds(i);
            repDir = fullfile(runDir,repID);
            mkdir(repDir);
            fprintf('\n=== STARTING SEEDAWARE RNGFIX %s | seed=%d ===\n', repID, seed);
            try
                RngBefore{i} = rng;
                tRep = tic;
                formal = run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix(true, seed);
                elapsed = toc(tRep);
                RngAfter{i} = rng;

                outMat = fullfile(repDir,sprintf('SEEDAWARE_RNGFIX_%s_seed_%d_formal_output.mat',repID,seed));
                save(outMat,'formal','repID','seed','elapsed','RngBefore','RngAfter');

                Treplicates.execution_status(i) = "EXECUTED";
                Treplicates.actual_runtime_s(i) = elapsed;
                Treplicates.actual_runtime_h(i) = elapsed/3600;
                Treplicates.output_mat(i) = string(outMat);

                if isfield(formal,'formalFlags') && isfield(formal.formalFlags,'run_status')
                    Treplicates.run_status(i) = string(formal.formalFlags.run_status);
                else
                    Treplicates.run_status(i) = "UNKNOWN";
                end

                if isfield(formal,'diagnosis')
                    Treplicates.diagnosis(i) = string(formal.diagnosis);
                end

                if isfield(formal,'rngControl_v96z')
                    Treplicates.rngControl(i) = string(formal.rngControl_v96z);
                end

            catch ME
                Treplicates.execution_status(i) = "ERROR";
                Treplicates.run_status(i) = "ERROR";
                Treplicates.error_message(i) = string(ME.message);
                warning('Seed-aware replicate %s failed: %s',repID,ME.message);
            end
        end

        if all(Treplicates.run_status == "OK")
            diagnosis = "SEEDAWARE_MINREP_EXECUTION_PASS";
            decision = "SEEDAWARE_OUTPUTS_READY_FOR_POSTPROCESSING";
        else
            diagnosis = "SEEDAWARE_MINREP_EXECUTION_REQUIRES_REVIEW";
            decision = "REVIEW_FAILED_OR_PARTIAL_REPLICATES";
        end
    end

    totalElapsed_s = toc(globalTimer);
    totalElapsed_h = totalElapsed_s/3600;

    outMat = fullfile(runDir,'SEEDAWARE_MINREP_RNGFIX_v96z.mat');
    save(outMat,'diagnosis','decision','confirm_execute','Treplicates','RngBefore','RngAfter','runDir','totalElapsed_s','totalElapsed_h');

    minrep = struct();
    minrep.status = 'SEEDAWARE_MINREP_RNGFIX_v96z_COMPLETED';
    minrep.diagnosis = diagnosis;
    minrep.decision = decision;
    minrep.confirm_execute = confirm_execute;
    minrep.runDir = runDir;
    minrep.Treplicates = Treplicates;
    minrep.totalElapsed_h = totalElapsed_h;
    minrep.outMat = outMat;

    disp('=== SEEDAWARE_MINREP_RNGFIX_v96z ===')
    disp(minrep.status)
    disp('=== DIAGNOSIS ===')
    disp(minrep.diagnosis)
    disp('=== DECISION ===')
    disp(minrep.decision)
    disp('=== RUN DIR ===')
    disp(minrep.runDir)
    disp('=== TOTAL ELAPSED [h] ===')
    disp(minrep.totalElapsed_h)
    disp('=== REPLICATES ===')
    disp(minrep.Treplicates)
end