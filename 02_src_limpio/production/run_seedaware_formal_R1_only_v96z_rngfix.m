function R1 = run_seedaware_formal_R1_only_v96z_rngfix(confirm_execute)
% RUN_SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix
%
% Ejecuta una sola corrida formal seed-aware:
%   R1
%   seed = 61001
%   PopulationSize = 24
%   MaxGenerations = 50
%
% No ejecuta R2/R3.
% No modifica v96m original.
% No modifica el clon seed-aware formal.
%
% Uso:
%   R1 = run_seedaware_formal_R1_only_v96z_rngfix(false);  % preparación
%   R1 = run_seedaware_formal_R1_only_v96z_rngfix(true);   % ejecución formal R1

    if nargin < 1 || isempty(confirm_execute)
        confirm_execute = false;
    end

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    productionDir = fullfile(rootDir,'02_src_limpio','production');
    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    runsRoot = fullfile(articleRoot,'runs');
    reviewDir = fullfile(articleRoot,'review');
    tablesDir = fullfile(articleRoot,'tables');
    traceDir = fullfile(articleRoot,'traceability');

    mkdir_if_needed(runsRoot);
    mkdir_if_needed(reviewDir);
    mkdir_if_needed(tablesDir);
    mkdir_if_needed(traceDir);

    seedawarePath = fullfile(productionDir,'run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m');
    gaAuditPath = fullfile(traceDir,'GAOPTS_AUDIT_v96z_before_formal_run_f4.mat');

    seed = 61001;
    repID = "R1";
    popSize_expected = 24;
    maxGen_expected = 50;

    timestamp = datestr(now,'yyyymmdd_HHMMSS');
    runDir = fullfile(runsRoot,['SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix_' timestamp]);
    mkdir(runDir);

    repDir = fullfile(runDir,'R1');
    mkdir(repDir);

    txt = string(fileread(seedawarePath));

    hasSeedawareClone = isfile(seedawarePath);
    hasExternalSeed = contains(txt,"EXTERNAL_SEED_APPLIED") && contains(txt,"rngSeed");
    hasPop24 = contains(txt,"popSize = 24;");
    hasGen50 = contains(txt,"maxGen = 50;");
    hasGamultiobj = contains(txt,"gamultiobj");
    hasSaveXF = contains(txt,"'X'") && contains(txt,"'F'");
    hasSaveOpts = contains(txt,"'opts'");
    hasSaveLbUb = contains(txt,"'lb'") && contains(txt,"'ub'");

    auditF4Available = isfile(gaAuditPath);

    Tplan = table();
    Tplan.repID = repID;
    Tplan.seed = seed;
    Tplan.populationSize_expected = popSize_expected;
    Tplan.maxGenerations_expected = maxGen_expected;
    Tplan.confirm_execute = logical(confirm_execute);
    Tplan.clone = string(seedawarePath);
    Tplan.runDir = string(runDir);
    Tplan.repDir = string(repDir);

    formal = [];
    X = [];
    F = [];
    elapsed = NaN;
    run_status = "NOT_EXECUTED";
    error_message = "";
    outMatRep = "";

    if confirm_execute
        fprintf('\n=== STARTING SEEDAWARE FORMAL R1 ONLY | seed=%d | pop=%d | gen=%d ===\n', ...
            seed, popSize_expected, maxGen_expected);

        try
            t0 = tic;
            formal = run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix(true, seed);
            elapsed = toc(t0);

            [X,F] = extract_XF_from_formal_Tsolutions(formal);

            outMatRep = fullfile(repDir,sprintf('SEEDAWARE_FORMAL_R1_ONLY_seed_%d_output.mat',seed));
            save(outMatRep,'formal','X','F','seed','repID','elapsed');

            if isfield(formal,'formalFlags') && isfield(formal.formalFlags,'run_status')
                run_status = string(formal.formalFlags.run_status);
            else
                run_status = "OK";
            end

        catch ME
            run_status = "ERROR";
            error_message = string(ME.message);
        end
    end

    Tsummary = table();
    Tsummary.repID = repID;
    Tsummary.seed = seed;
    Tsummary.confirm_execute = logical(confirm_execute);
    Tsummary.run_status = run_status;
    Tsummary.error_message = error_message;
    Tsummary.runtime_s = elapsed;
    Tsummary.runtime_h = elapsed/3600;
    Tsummary.nSolutions = size(F,1);
    Tsummary.nFiniteRows = sum(all(isfinite(F),2));
    Tsummary.nPenaltyRows = sum(any(F >= 1e6,2));
    Tsummary.minMR = local_min_col(F,1);
    Tsummary.minCost = local_min_col(F,2);
    Tsummary.minCO2 = local_min_col(F,3);
    Tsummary.output_mat = string(outMatRep);

    if ~isempty(formal) && isstruct(formal)
        if isfield(formal,'rngControl_v96z')
            Tsummary.rngControl = string(formal.rngControl_v96z);
        else
            Tsummary.rngControl = "";
        end

        if isfield(formal,'rngSeed_v96z')
            Tsummary.rngSeed_v96z = formal.rngSeed_v96z;
        else
            Tsummary.rngSeed_v96z = NaN;
        end
    else
        Tsummary.rngControl = "";
        Tsummary.rngSeed_v96z = NaN;
    end

    checks = {};
    checks{end+1,1} = check_row("R1_01","Seed-aware clone exists",hasSeedawareClone,string(seedawarePath));
    checks{end+1,1} = check_row("R1_02","External seed branch present",hasExternalSeed,"rngSeed + EXTERNAL_SEED_APPLIED.");
    checks{end+1,1} = check_row("R1_03","Formal PopulationSize remains 24",hasPop24,"popSize = 24.");
    checks{end+1,1} = check_row("R1_04","Formal MaxGenerations remains 50",hasGen50,"maxGen = 50.");
    checks{end+1,1} = check_row("R1_05","gamultiobj present",hasGamultiobj,"gamultiobj found.");
    checks{end+1,1} = check_row("R1_06","X/F saved by clone",hasSaveXF,"save list contains X and F.");
    checks{end+1,1} = check_row("R1_07","opts saved by clone",hasSaveOpts,"save list contains opts.");
    checks{end+1,1} = check_row("R1_08","lb/ub saved by clone",hasSaveLbUb,"save list contains lb and ub.");
    checks{end+1,1} = check_row("R1_09","GAOPTS F4 audit available",auditF4Available,string(gaAuditPath));
    checks{end+1,1} = check_row("R1_10","Runner limited to R1 only",true,"No loop over R2/R3.");
    checks{end+1,1} = check_row("R1_11","Execution explicitly controlled",true,sprintf("confirm_execute=%d",confirm_execute));
    checks{end+1,1} = check_row("R1_12","Original v96m not modified",true,"Only calls seed-aware clone.");

    if confirm_execute
        checks{end+1,1} = check_row("R1_13","R1 formal run completed",run_status=="OK",run_status + " " + error_message);
        checks{end+1,1} = check_row("R1_14","External seed applied",Tsummary.rngControl=="EXTERNAL_SEED_APPLIED",Tsummary.rngControl);
        checks{end+1,1} = check_row("R1_15","Seed is 61001",Tsummary.rngSeed_v96z==61001,string(Tsummary.rngSeed_v96z));
        checks{end+1,1} = check_row("R1_16","F has finite rows",Tsummary.nFiniteRows > 0,string(Tsummary.nFiniteRows));
        checks{end+1,1} = check_row("R1_17","Not all penalized",Tsummary.nPenaltyRows < Tsummary.nSolutions, ...
            sprintf("nPenaltyRows=%d; nSolutions=%d",Tsummary.nPenaltyRows,Tsummary.nSolutions));
    else
        checks{end+1,1} = check_row("R1_13","No GA executed in preparation",true,"confirm_execute=false.");
    end

    Tchecks = struct2table(vertcat(checks{:}));

    if ~confirm_execute && all(Tchecks.pass)
        diagnosis = "SEEDAWARE_FORMAL_R1_ONLY_READY_NO_EXECUTION";
        decision = "READY_TO_EXECUTE_R1_ONLY_IF_APPROVED";
        next_step = "R1 = run_seedaware_formal_R1_only_v96z_rngfix(true);";
    elseif confirm_execute && all(Tchecks.pass)
        diagnosis = "SEEDAWARE_FORMAL_R1_ONLY_PASS";
        decision = "POSTPROCESS_R1_VS_LEGACY_BEFORE_R2_R3";
        next_step = "Run postprocess R1-only comparison.";
    else
        diagnosis = "SEEDAWARE_FORMAL_R1_ONLY_REQUIRES_REVIEW";
        decision = "DO_NOT_RUN_R2_R3";
        next_step = "Inspect failed R1 checks.";
    end

    summaryCsv = fullfile(tablesDir,'SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix_Tsummary.csv');
    checksCsv = fullfile(tablesDir,'SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix_Tchecks.csv');
    planCsv = fullfile(tablesDir,'SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix_Tplan.csv');

    writetable(Tsummary,summaryCsv);
    writetable(Tchecks,checksCsv);
    writetable(Tplan,planCsv);

    reportMd = fullfile(reviewDir,'SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix.md');

    fid = fopen(reportMd,'w');
    fprintf(fid,'# SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);

    fprintf(fid,'## Plan\n\n');
    fprintf(fid,'| rep | seed | PopulationSize | MaxGenerations | confirm_execute |\n');
    fprintf(fid,'|---|---:|---:|---:|---:|\n');
    fprintf(fid,'| %s | %d | %d | %d | %d |\n', repID, seed, popSize_expected, maxGen_expected, confirm_execute);

    fprintf(fid,'\n## Summary\n\n');
    fprintf(fid,'| rep | seed | status | rngControl | nSolutions | finite | penalized | minMR | minCost | minCO2 | runtime h |\n');
    fprintf(fid,'|---|---:|---|---|---:|---:|---:|---:|---:|---:|---:|\n');
    fprintf(fid,'| %s | %d | %s | %s | %d | %d | %d | %.12g | %.12g | %.12g | %.12g |\n', ...
        Tsummary.repID, Tsummary.seed, Tsummary.run_status, Tsummary.rngControl, ...
        Tsummary.nSolutions, Tsummary.nFiniteRows, Tsummary.nPenaltyRows, ...
        Tsummary.minMR, Tsummary.minCost, Tsummary.minCO2, Tsummary.runtime_h);

    fprintf(fid,'\n## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            Tchecks.id(i), sanitize_md(Tchecks.check(i)), Tchecks.pass(i), sanitize_md(Tchecks.evidence(i)));
    end
    fclose(fid);

    outMat = fullfile(traceDir,'SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix.mat');
    save(outMat,'diagnosis','decision','next_step', ...
        'rootDir','runDir','repDir','seedawarePath','gaAuditPath', ...
        'Tplan','Tsummary','Tchecks','formal','X','F', ...
        'summaryCsv','checksCsv','planCsv','reportMd','outMat');

    R1 = struct();
    R1.status = 'SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix_COMPLETED';
    R1.diagnosis = diagnosis;
    R1.decision = decision;
    R1.next_step = next_step;
    R1.runDir = runDir;
    R1.repDir = repDir;
    R1.Tplan = Tplan;
    R1.Tsummary = Tsummary;
    R1.Tchecks = Tchecks;
    R1.reportMd = reportMd;
    R1.outMat = outMat;

    disp('=== SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix ===')
    disp(R1.status)
    disp('=== DIAGNOSIS ===')
    disp(R1.diagnosis)
    disp('=== DECISION ===')
    disp(R1.decision)
    disp('=== NEXT STEP ===')
    disp(R1.next_step)
    disp('=== PLAN ===')
    disp(R1.Tplan)
    disp('=== SUMMARY ===')
    disp(R1.Tsummary)
    disp('=== CHECKS ===')
    disp(R1.Tchecks)
    disp('=== REPORT ===')
    disp(R1.reportMd)

end

function [X,F] = extract_XF_from_formal_Tsolutions(formal)
    if ~isstruct(formal) || ~isfield(formal,'Tsolutions') || ~istable(formal.Tsolutions)
        error('formal.Tsolutions no existe o no es tabla.');
    end

    T = formal.Tsolutions;

    reqX = {'m_max','T_min','r_div2','t_rec_ini'};
    reqF = {'MR','cost_specific_USD_per_kgwater','CO2_specific_kgCO2_per_kgwater'};

    if ~all(ismember(reqX,T.Properties.VariableNames))
        error('Tsolutions no contiene columnas X requeridas.');
    end

    if ~all(ismember(reqF,T.Properties.VariableNames))
        error('Tsolutions no contiene columnas F requeridas.');
    end

    X = [T.m_max, T.T_min, T.r_div2, T.t_rec_ini];
    F = [T.MR, T.cost_specific_USD_per_kgwater, T.CO2_specific_kgCO2_per_kgwater];
end

function x = local_min_col(F,j)
    if isempty(F) || size(F,2) < j
        x = NaN;
    else
        x = min(F(:,j),[],'omitnan');
    end
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