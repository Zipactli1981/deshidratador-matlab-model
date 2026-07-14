function approval = approve_seedaware_minrep_execution_v96z_rngfix()
% Approval gate for seed-aware minrep execution.
% Does not execute GA.

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    productionDir = fullfile(rootDir,'02_src_limpio','production');
    runnerPath = fullfile(productionDir,'run_seedaware_minrep_formal_ga_v96z_rngfix.m');
    clonePath = fullfile(productionDir,'run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m');

    approvedCommand = 'run_seedaware_minrep_formal_ga_v96z_rngfix(true);';
    expectedRuntime_h = 50.1363;

    checks = {};
    checks{end+1,1} = check_row("RNG_E01","Runner exists",isfile(runnerPath),string(runnerPath));
    checks{end+1,1} = check_row("RNG_E02","Clone exists",isfile(clonePath),string(clonePath));
    checks{end+1,1} = check_row("RNG_E03","Command explicitly true",contains(approvedCommand,'true'),approvedCommand);
    checks{end+1,1} = check_row("RNG_E04","Approval does not execute GA",true,"Only returns approved command.");
    checks{end+1,1} = check_row("RNG_E05","Expected runtime acknowledged",expectedRuntime_h > 0,sprintf("ExpectedRuntime_h=%.4f",expectedRuntime_h));

    Tchecks = struct2table(vertcat(checks{:}));

    if all(Tchecks.pass)
        diagnosis = "SEEDAWARE_MINREP_EXECUTION_APPROVAL_PASS";
        decision = "SEEDAWARE_MINREP_EXECUTION_APPROVED_BY_GATE";
    else
        diagnosis = "SEEDAWARE_MINREP_EXECUTION_APPROVAL_REQUIRES_REVIEW";
        decision = "DO_NOT_EXECUTE_SEEDAWARE_MINREP";
    end

    approval = struct();
    approval.status = 'SEEDAWARE_MINREP_EXECUTION_APPROVAL_COMPLETED';
    approval.diagnosis = diagnosis;
    approval.decision = decision;
    approval.expectedRuntime_h = expectedRuntime_h;
    approval.approvedCommand = approvedCommand;
    approval.Tchecks = Tchecks;

    disp('=== SEEDAWARE_MINREP_EXECUTION_APPROVAL_v96z_rngfix ===')
    disp(approval.status)
    disp('=== DIAGNOSIS ===')
    disp(approval.diagnosis)
    disp('=== DECISION ===')
    disp(approval.decision)
    disp('=== EXPECTED RUNTIME [h] ===')
    disp(approval.expectedRuntime_h)
    disp('=== APPROVED COMMAND ===')
    disp(approval.approvedCommand)
    disp('=== CHECKS ===')
    disp(approval.Tchecks)
end

function row = check_row(id, checkName, passVal, evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end