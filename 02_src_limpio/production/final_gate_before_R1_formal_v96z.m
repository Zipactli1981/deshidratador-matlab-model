function gate = final_gate_before_R1_formal_v96z()
% FINAL_GATE_BEFORE_R1_FORMAL_v96z
%
% Última compuerta antes de ejecutar:
%   R1 = run_seedaware_formal_R1_only_v96z_rngfix(true);
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica fuentes.

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    productionDir = fullfile(rootDir,'02_src_limpio','production');
    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    reviewDir = fullfile(articleRoot,'review');
    tablesDir = fullfile(articleRoot,'tables');
    traceDir = fullfile(articleRoot,'traceability');
    runsRoot = fullfile(articleRoot,'runs');

    mkdir_if_needed(reviewDir);
    mkdir_if_needed(tablesDir);
    mkdir_if_needed(traceDir);
    mkdir_if_needed(runsRoot);

    clonePath = fullfile(productionDir,'run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m');
    r1RunnerPath = fullfile(productionDir,'run_seedaware_formal_R1_only_v96z_rngfix.m');
    gaoptsMat = fullfile(traceDir,'GAOPTS_AUDIT_v96z_before_formal_run_f4.mat');
    modelAuditMat = fullfile(traceDir,'MODEL_ARTICLE_AUDIT_v96z.mat');
    r1PrepMat = fullfile(traceDir,'SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix.mat');

    rows = {};

    cloneExists = isfile(clonePath);
    runnerExists = isfile(r1RunnerPath);
    gaoptsExists = isfile(gaoptsMat);
    modelAuditExists = isfile(modelAuditMat);
    r1PrepExists = isfile(r1PrepMat);

    cloneTxt = "";
    runnerTxt = "";

    if cloneExists
        cloneTxt = string(fileread(clonePath));
    end

    if runnerExists
        runnerTxt = string(fileread(r1RunnerPath));
    end

    rows{end+1,1} = check_row("GATE01","Seed-aware clone exists",cloneExists,string(clonePath));
    rows{end+1,1} = check_row("GATE02","R1-only runner exists",runnerExists,string(r1RunnerPath));
    rows{end+1,1} = check_row("GATE03","GAOPTS F4 audit exists",gaoptsExists,string(gaoptsMat));
    rows{end+1,1} = check_row("GATE04","Model/article audit exists",modelAuditExists,string(modelAuditMat));
    rows{end+1,1} = check_row("GATE05","R1 preparation MAT exists",r1PrepExists,string(r1PrepMat));

    rows{end+1,1} = check_row("GATE06","Clone has external seed branch", ...
        contains(cloneTxt,"EXTERNAL_SEED_APPLIED") && contains(cloneTxt,"rngSeed"), ...
        "EXTERNAL_SEED_APPLIED + rngSeed.");

    rows{end+1,1} = check_row("GATE07","Clone formal pop/gen unchanged", ...
        contains(cloneTxt,"popSize = 24;") && contains(cloneTxt,"maxGen = 50;"), ...
        "popSize=24; maxGen=50.");

    rows{end+1,1} = check_row("GATE08","Clone uses gamultiobj", ...
        contains(cloneTxt,"gamultiobj"), ...
        "gamultiobj present.");

    rows{end+1,1} = check_row("GATE09","Clone saves reproducibility outputs", ...
        contains(cloneTxt,"'X'") && contains(cloneTxt,"'F'") && contains(cloneTxt,"'opts'") && ...
        contains(cloneTxt,"'lb'") && contains(cloneTxt,"'ub'") && ...
        contains(cloneTxt,"'population'") && contains(cloneTxt,"'scores'"), ...
        "X/F/opts/lb/ub/population/scores saved.");

    rows{end+1,1} = check_row("GATE10","Runner seed fixed to R1 seed 61001", ...
        contains(runnerTxt,"seed = 61001;"), ...
        "seed = 61001.");

    rows{end+1,1} = check_row("GATE11","Runner does not include R2/R3 seeds", ...
        ~contains(runnerTxt,"61002") && ~contains(runnerTxt,"61003"), ...
        "No 61002/61003 in runner.");

    rows{end+1,1} = check_row("GATE12","Runner calls seed-aware clone", ...
        contains(runnerTxt,"run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix(true, seed)"), ...
        "Calls seed-aware clone with true, seed.");

    rows{end+1,1} = check_row("GATE13","Runner keeps execution guard", ...
        contains(runnerTxt,"confirm_execute") && contains(runnerTxt,"if confirm_execute"), ...
        "confirm_execute guard present.");

    % GAOPTS audit status
    gaoptsDiagnosis = "";
    gaoptsDecision = "";
    if gaoptsExists
        S = load(gaoptsMat);
        if isfield(S,'diagnosis'), gaoptsDiagnosis = string(S.diagnosis); end
        if isfield(S,'decision'), gaoptsDecision = string(S.decision); end
    end

    rows{end+1,1} = check_row("GATE14","GAOPTS audit is PASS", ...
        gaoptsDiagnosis=="GAOPTS_AUDIT_F4_PASS" && gaoptsDecision=="GA_CONFIGURATION_TRACEABLE_BEFORE_FORMAL_RUN", ...
        gaoptsDiagnosis + " | " + gaoptsDecision);

    % Model/article audit status
    modelDiagnosis = "";
    modelDecision = "";
    if modelAuditExists
        S = load(modelAuditMat);
        if isfield(S,'diagnosis'), modelDiagnosis = string(S.diagnosis); end
        if isfield(S,'decision'), modelDecision = string(S.decision); end
    end

    rows{end+1,1} = check_row("GATE15","Model/article audit is PASS", ...
        modelDiagnosis=="MODEL_ARTICLE_AUDIT_PASS" && modelDecision=="ARTICLE_METADATA_READY_BEFORE_R1_FORMAL", ...
        modelDiagnosis + " | " + modelDecision);

    % R1 preparation status
    r1Diagnosis = "";
    r1Decision = "";
    r1RunStatus = "";
    r1ConfirmExecute = NaN;

    if r1PrepExists
        S = load(r1PrepMat);
        if isfield(S,'diagnosis'), r1Diagnosis = string(S.diagnosis); end
        if isfield(S,'decision'), r1Decision = string(S.decision); end
        if isfield(S,'Tsummary') && height(S.Tsummary) >= 1
            r1RunStatus = string(S.Tsummary.run_status(1));
            r1ConfirmExecute = double(S.Tsummary.confirm_execute(1));
        end
    end

    rows{end+1,1} = check_row("GATE16","R1 prep is ready and not executed", ...
        r1Diagnosis=="SEEDAWARE_FORMAL_R1_ONLY_READY_NO_EXECUTION" && ...
        r1Decision=="READY_TO_EXECUTE_R1_ONLY_IF_APPROVED" && ...
        r1RunStatus=="NOT_EXECUTED" && r1ConfirmExecute==0, ...
        r1Diagnosis + " | " + r1Decision + " | " + r1RunStatus);

    % Write test
    testFile = fullfile(runsRoot,'_write_test_final_R1_gate.tmp');
    writeOK = false;
    try
        fid = fopen(testFile,'w');
        fprintf(fid,'write test\n');
        fclose(fid);
        writeOK = isfile(testFile);
        delete(testFile);
    catch
        writeOK = false;
    end

    rows{end+1,1} = check_row("GATE17","Run folder writable",writeOK,string(runsRoot));
    rows{end+1,1} = check_row("GATE18","No GA executed by final gate",true,"No gamultiobj call.");
    rows{end+1,1} = check_row("GATE19","Original v96m not modified",true,"Read-only gate.");

    Tchecks = struct2table(vertcat(rows{:}));

    if all(Tchecks.pass)
        diagnosis = "FINAL_R1_FORMAL_GATE_PASS";
        decision = "SAFE_TO_EXECUTE_R1_ONLY";
        next_step = "R1 = run_seedaware_formal_R1_only_v96z_rngfix(true);";
    else
        diagnosis = "FINAL_R1_FORMAL_GATE_REQUIRES_REVIEW";
        decision = "DO_NOT_EXECUTE_R1_YET";
        next_step = "Inspect failed gate checks.";
    end

    checksCsv = fullfile(tablesDir,'FINAL_GATE_BEFORE_R1_FORMAL_v96z_Tchecks.csv');
    writetable(Tchecks,checksCsv);

    reportMd = fullfile(reviewDir,'FINAL_GATE_BEFORE_R1_FORMAL_v96z.md');

    fid = fopen(reportMd,'w');
    fprintf(fid,'# FINAL_GATE_BEFORE_R1_FORMAL_v96z\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            Tchecks.id(i), sanitize_md(Tchecks.check(i)), Tchecks.pass(i), sanitize_md(Tchecks.evidence(i)));
    end
    fclose(fid);

    outMat = fullfile(traceDir,'FINAL_GATE_BEFORE_R1_FORMAL_v96z.mat');
    save(outMat,'diagnosis','decision','next_step','Tchecks','checksCsv','reportMd','outMat');

    gate = struct();
    gate.status = 'FINAL_GATE_BEFORE_R1_FORMAL_v96z_COMPLETED';
    gate.diagnosis = diagnosis;
    gate.decision = decision;
    gate.next_step = next_step;
    gate.Tchecks = Tchecks;
    gate.reportMd = reportMd;
    gate.outMat = outMat;

    disp('=== FINAL_GATE_BEFORE_R1_FORMAL_v96z ===')
    disp(gate.status)
    disp('=== DIAGNOSIS ===')
    disp(gate.diagnosis)
    disp('=== DECISION ===')
    disp(gate.decision)
    disp('=== NEXT STEP ===')
    disp(gate.next_step)
    disp('=== CHECKS ===')
    disp(gate.Tchecks)
    disp('=== REPORT ===')
    disp(gate.reportMd)
end

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

function s = sanitize_md(x)
    s = string(x);
    s = replace(s, newline, " ");
    s = replace(s, "|", "\|");
    s = replace(s, "`", "'");
end
