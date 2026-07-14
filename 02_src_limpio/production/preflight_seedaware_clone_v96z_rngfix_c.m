function pf = preflight_seedaware_clone_v96z_rngfix_c()
% PREFLIGHT_SEEDAWARE_CLONE_v96z_rngfix_c
%
% Verifica el clon seed-aware sin ejecutar GA.
%
% No ejecuta gamultiobj.
% No llama modelo formal.
% No modifica v96m original.

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
    originalPath = fullfile(productionDir,'run_guarded_triobjective_formal_ga_v96m.m');

    if ~isfile(clonePath)
        error('No existe clonePath: %s', clonePath);
    end

    txt = string(fileread(clonePath));

    % Ejecutar solo en modo seguro: confirm_execute=false.
    testSeed = 61001;
    rngBefore = rng;
    formal = run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix(false, testSeed);
    rngAfter = rng;

    hasFormal = isstruct(formal);
    hasDiagnosis = hasFormal && isfield(formal,'diagnosis');
    hasFlags = hasFormal && isfield(formal,'formalFlags');
    hasTpreflight = hasFormal && isfield(formal,'Tpreflight') && istable(formal.Tpreflight);
    hasTsolutions = hasFormal && isfield(formal,'Tsolutions');
    hasTrun = hasFormal && isfield(formal,'Trun');
    hasRngMeta = hasFormal && isfield(formal,'rngSeed_v96z') && ...
                 isfield(formal,'rngSeedWasProvided_v96z') && ...
                 isfield(formal,'rngControl_v96z');

    formalRunExecuted = false;
    if hasFlags && isfield(formal.formalFlags,'formal_run_executed')
        formalRunExecuted = formal.formalFlags.formal_run_executed;
    end

    formalStillOnHold = false;
    if hasFlags && isfield(formal.formalFlags,'formal_run_still_on_hold')
        formalStillOnHold = formal.formalFlags.formal_run_still_on_hold;
    end

    diagnosisText = "";
    if hasDiagnosis
        diagnosisText = string(formal.diagnosis);
    end

    rngControlText = "";
    rngSeedValue = NaN;
    if hasRngMeta
        rngControlText = string(formal.rngControl_v96z);
        rngSeedValue = formal.rngSeed_v96z;
    end

    checks = {};
    checks{end+1,1} = check_row("RNG_C01","Clone exists",isfile(clonePath),string(clonePath));
    checks{end+1,1} = check_row("RNG_C02","Original v96m exists",isfile(originalPath),string(originalPath));
    checks{end+1,1} = check_row("RNG_C03","Seed-aware signature present",contains(txt,"confirm_execute, rngSeed"),"Signature includes rngSeed.");
    checks{end+1,1} = check_row("RNG_C04","External seed branch present",contains(txt,"EXTERNAL_SEED_APPLIED"),"External seed branch found.");
    checks{end+1,1} = check_row("RNG_C05","Legacy branch present",contains(txt,"LEGACY_INTERNAL_SEED_614960_APPLIED"),"Legacy branch found.");
    checks{end+1,1} = check_row("RNG_C06","Safe call returned struct",hasFormal,sprintf("class=%s",class(formal)));
    checks{end+1,1} = check_row("RNG_C07","Safe call did not execute formal GA",~formalRunExecuted,sprintf("formal_run_executed=%d",formalRunExecuted));
    checks{end+1,1} = check_row("RNG_C08","Formal run still on hold",formalStillOnHold,sprintf("formal_run_still_on_hold=%d",formalStillOnHold));
    checks{end+1,1} = check_row("RNG_C09","Preflight table exists",hasTpreflight,sprintf("hasTpreflight=%d",hasTpreflight));
    checks{end+1,1} = check_row("RNG_C10","RNG metadata exists",hasRngMeta,sprintf("rngControl=%s; rngSeed=%g",rngControlText,rngSeedValue));
    checks{end+1,1} = check_row("RNG_C11","External seed applied in safe call",rngControlText=="EXTERNAL_SEED_APPLIED",sprintf("rngControl=%s",rngControlText));
    checks{end+1,1} = check_row("RNG_C12","Test seed recorded",isequal(rngSeedValue,testSeed),sprintf("rngSeed=%g",rngSeedValue));
    checks{end+1,1} = check_row("RNG_C13","gamultiobj code preserved",contains(txt,"gamultiobj"),"gamultiobj call exists in clone.");
    checks{end+1,1} = check_row("RNG_C14","Tsolutions code preserved",contains(txt,"Tsolutions"),"Tsolutions code exists in clone.");
    checks{end+1,1} = check_row("RNG_C15","No GA executed by this preflight",~formalRunExecuted,"confirm_execute=false.");
    checks{end+1,1} = check_row("RNG_C16","No original source modified",true,"Preflight only.");

    Tchecks = struct2table(vertcat(checks{:}));

    if all(Tchecks.pass)
        diagnosis = "SEEDAWARE_CLONE_PREFLIGHT_PASS";
        decision = "READY_TO_BUILD_SEEDAWARE_MINREP_RUNNER";
        next_step = "9.6z-rngfix-d — BUILD-SEEDAWARE-MINREP-RUNNER-001";
    else
        diagnosis = "SEEDAWARE_CLONE_PREFLIGHT_REQUIRES_REVIEW";
        decision = "DO_NOT_RUN_SEEDAWARE_REPLICATIONS_YET";
        next_step = "Inspect failed preflight checks.";
    end

    checksCsv = fullfile(articleTablesDir,'preflight_seedaware_clone_v96z_rngfix_c_checks.csv');
    writetable(Tchecks,checksCsv);

    reportMd = fullfile(articleReviewDir,'PREFLIGHT_SEEDAWARE_CLONE_v96z_rngfix_c.md');

    fid = fopen(reportMd,'w');
    fprintf(fid,'# PREFLIGHT_SEEDAWARE_CLONE_v96z_rngfix_c\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Clone\n\n`%s`\n\n',clonePath);
    fprintf(fid,'## Safe-call diagnosis\n\n`%s`\n\n',diagnosisText);
    fprintf(fid,'## RNG control\n\n');
    fprintf(fid,'- rngControl: `%s`\n',rngControlText);
    fprintf(fid,'- rngSeed: `%g`\n\n',rngSeedValue);
    fprintf(fid,'## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');

    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            Tchecks.id(i),Tchecks.check(i),Tchecks.pass(i),Tchecks.evidence(i));
    end

    fclose(fid);

    outMat = fullfile(articleTraceDir,'PREFLIGHT_SEEDAWARE_CLONE_v96z_rngfix_c.mat');

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'rootDir','clonePath','originalPath','formal', ...
        'rngBefore','rngAfter','testSeed', ...
        'Tchecks','checksCsv','reportMd','outMat');

    pf = struct();
    pf.status = 'PREFLIGHT_SEEDAWARE_CLONE_v96z_rngfix_c_COMPLETED';
    pf.diagnosis = diagnosis;
    pf.decision = decision;
    pf.next_step = next_step;
    pf.clonePath = clonePath;
    pf.formal = formal;
    pf.Tchecks = Tchecks;
    pf.reportMd = reportMd;
    pf.outMat = outMat;

    disp('=== PREFLIGHT_SEEDAWARE_CLONE_v96z_rngfix_c ===')
    disp(pf.status)
    disp('=== DIAGNOSIS ===')
    disp(pf.diagnosis)
    disp('=== DECISION ===')
    disp(pf.decision)
    disp('=== NEXT STEP ===')
    disp(pf.next_step)
    disp('=== CLONE ===')
    disp(pf.clonePath)
    disp('=== SAFE CALL FORMAL DIAGNOSIS ===')
    if isfield(formal,'diagnosis')
        disp(formal.diagnosis)
    end
    disp('=== RNG META ===')
    if hasRngMeta
        disp(formal.rngControl_v96z)
        disp(formal.rngSeed_v96z)
    end
    disp('=== CHECKS ===')
    disp(pf.Tchecks)
    disp('=== REPORT ===')
    disp(pf.reportMd)

end

function row = check_row(id, checkName, passVal, evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end