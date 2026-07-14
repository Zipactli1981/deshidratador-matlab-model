function approval = approve_seed_controlled_minrep_execution_v96z_minrep()
% APPROVE_SEED_CONTROLLED_MINREP_EXECUTION_v96z_minrep
% Approval gate for actual seed-controlled minimal replication execution.
% This script does NOT execute GA.

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    articleTraceDir = fullfile(rootDir,'06_manuscript','article_Q1','traceability');
    runprepMat = fullfile(articleTraceDir,'SEED_CONTROLLED_REPLICATION_RUNNER_RUNPREP_v96z_minrep.mat');
    runnerPath = fullfile(rootDir,'02_src_limpio','production','run_seed_controlled_minrep_formal_ga_v96z_minrep.m');

    if ~isfile(runprepMat)
        error('No existe runprepMat: %s', runprepMat);
    end

    if ~isfile(runnerPath)
        error('No existe runnerPath: %s', runnerPath);
    end

    R = load(runprepMat);

    checks = {};
    checks{end+1,1} = check_row_local('AP01','Runprep loaded',true,string(runprepMat));
    checks{end+1,1} = check_row_local('AP02','Runprep PASS',strcmp(string(R.diagnosis),'SEED_CONTROLLED_REPLICATION_RUNNER_RUNPREP_PASS'),string(R.diagnosis));
    checks{end+1,1} = check_row_local('AP03','Runner exists',isfile(runnerPath),string(runnerPath));
    checks{end+1,1} = check_row_local('AP04','Expected runtime acknowledged',R.totalExpectedRuntime_h > 20,sprintf('ExpectedRuntime_h=%.4f',R.totalExpectedRuntime_h));
    checks{end+1,1} = check_row_local('AP05','Execution command explicitly true',true,'run_seed_controlled_minrep_formal_ga_v96z_minrep(true)');
    checks{end+1,1} = check_row_local('AP06','Approval script does not execute GA',true,'Only returns approved command.');

    Tchecks = struct2table(vertcat(checks{:}));
    approval_pass = all(Tchecks.pass);

    if approval_pass
        diagnosis = 'SEED_CONTROLLED_MINREP_EXECUTION_APPROVAL_PASS';
        decision = 'MINREP_EXECUTION_APPROVED_BY_GATE';
        approved_command = 'minrepRun = run_seed_controlled_minrep_formal_ga_v96z_minrep(true);';
    else
        diagnosis = 'SEED_CONTROLLED_MINREP_EXECUTION_APPROVAL_REQUIRES_REVIEW';
        decision = 'REVIEW_FAILED_APPROVAL_CHECKS';
        approved_command = '';
    end

    approval = struct();
    approval.status = 'SEED_CONTROLLED_MINREP_EXECUTION_APPROVAL_COMPLETED';
    approval.diagnosis = diagnosis;
    approval.decision = decision;
    approval.approved_command = approved_command;
    approval.expected_runtime_h = R.totalExpectedRuntime_h;
    approval.Tchecks = Tchecks;

    disp('=== SEED_CONTROLLED_MINREP_EXECUTION_APPROVAL_v96z_minrep ===')
    disp(approval.status)
    disp('=== DIAGNOSIS ===')
    disp(approval.diagnosis)
    disp('=== DECISION ===')
    disp(approval.decision)
    disp('=== EXPECTED RUNTIME [h] ===')
    disp(approval.expected_runtime_h)
    disp('=== APPROVED COMMAND ===')
    disp(approval.approved_command)
    disp('=== CHECKS ===')
    disp(approval.Tchecks)

end

function row = check_row_local(id, checkName, passVal, evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end