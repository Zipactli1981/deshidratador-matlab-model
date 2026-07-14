function audit = audit_gaopts_v96z_before_formal_run_f2()
% AUDIT_GAOPTS_v96z_BEFORE_FORMAL_RUN_f2
%
% Auditoría GAOPTS por lectura directa de código fuente.
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica v96m original.
% No modifica clon seed-aware.

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    productionDir = fullfile(rootDir,'02_src_limpio','production');
    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    reviewDir = fullfile(articleRoot,'review');
    tablesDir = fullfile(articleRoot,'tables');
    traceDir = fullfile(articleRoot,'traceability');

    mkdir_if_needed(reviewDir);
    mkdir_if_needed(tablesDir);
    mkdir_if_needed(traceDir);

    originalPath = fullfile(productionDir,'run_guarded_triobjective_formal_ga_v96m.m');
    seedawarePath = fullfile(productionDir,'run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m');
    smokeClonePath = fullfile(productionDir,'v96z_rngfix_smoke.m');

    if ~isfile(originalPath)
        error('No existe originalPath: %s', originalPath);
    end
    if ~isfile(seedawarePath)
        error('No existe seedawarePath: %s', seedawarePath);
    end

    originalTxt = fileread(originalPath);
    seedawareTxt = fileread(seedawarePath);

    if isfile(smokeClonePath)
        smokeTxt = fileread(smokeClonePath);
    else
        smokeTxt = '';
    end

    popOriginal = extract_numeric_assignment(originalTxt,'popSize');
    genOriginal = extract_numeric_assignment(originalTxt,'maxGen');

    popSeedaware = extract_numeric_assignment(seedawareTxt,'popSize');
    genSeedaware = extract_numeric_assignment(seedawareTxt,'maxGen');

    popSmoke = extract_numeric_assignment(smokeTxt,'popSize');
    genSmoke = extract_numeric_assignment(smokeTxt,'maxGen');

    [lb, lbRaw] = extract_vector_assignment(seedawareTxt,'lb');
    [ub, ubRaw] = extract_vector_assignment(seedawareTxt,'ub');

    if isempty(lb)
        [lb, lbRaw] = extract_vector_assignment(originalTxt,'lb');
    end
    if isempty(ub)
        [ub, ubRaw] = extract_vector_assignment(originalTxt,'ub');
    end

    nvars = numel(lb);

    modeFormal = extract_string_assignment(seedawareTxt,'modeFormal');
    if strlength(modeFormal) == 0
        modeFormal = extract_string_assignment(originalTxt,'modeFormal');
    end

    optsRaw = extract_optimoptions_block(seedawareTxt);
    if strlength(optsRaw) == 0
        optsRaw = extract_optimoptions_block(originalTxt);
    end

    hasGamultiobjOriginal = contains(originalTxt,'gamultiobj');
    hasGamultiobjSeedaware = contains(seedawareTxt,'gamultiobj');
    hasOptimoptions = contains(seedawareTxt,'optimoptions') && contains(seedawareTxt,'gamultiobj');
    hasLegacyFixedSeedOriginal = contains(originalTxt, 'rng(614960,''twister'')') || contains(originalTxt, 'rng(614960,"twister")');
    hasExternalSeedBranch = contains(seedawareTxt,'EXTERNAL_SEED_APPLIED') && contains(seedawareTxt,'rngSeed');
    hasSeedMetadata = contains(seedawareTxt,'rngSeed_v96z') && contains(seedawareTxt,'rngControl_v96z');

    savesOpts = contains(seedawareTxt,'''opts''') || contains(seedawareTxt,'"opts"');
    savesX = contains(seedawareTxt,'''X''') || contains(seedawareTxt,'"X"');
    savesF = contains(seedawareTxt,'''F''') || contains(seedawareTxt,'"F"');
    savesOutput = contains(seedawareTxt,'''output''') || contains(seedawareTxt,'"output"');
    savesPopulation = contains(seedawareTxt,'''population''') || contains(seedawareTxt,'"population"');
    savesScores = contains(seedawareTxt,'''scores''') || contains(seedawareTxt,'"scores"');
    savesLb = contains(seedawareTxt,'''lb''') || contains(seedawareTxt,'"lb"');
    savesUb = contains(seedawareTxt,'''ub''') || contains(seedawareTxt,'"ub"');

    % ------------------------------------------------------------------
    % Tabla GA
    % ------------------------------------------------------------------
    P = {};
    V = {};
    C = {};

    addrow('algorithm','gamultiobj','Solver used for multiobjective genetic algorithm.');
    addrow('objective_count','3','Objectives: MR, specific cost, specific CO2.');
    addrow('decision_variables','4','m_max, T_min, r_div2, t_rec_ini.');
    addrow('modeFormal',string(modeFormal),'Extracted from source when available.');
    addrow('referenceMode','gasLP','Reference mode for comparative interpretation.');
    addrow('popSize_original_v96m',num_to_text(popOriginal),'Explicit assignment in original v96m.');
    addrow('maxGen_original_v96m',num_to_text(genOriginal),'Explicit assignment in original v96m.');
    addrow('popSize_seedaware_formal',num_to_text(popSeedaware),'Explicit assignment in seed-aware formal clone.');
    addrow('maxGen_seedaware_formal',num_to_text(genSeedaware),'Explicit assignment in seed-aware formal clone.');
    addrow('popSize_smoke',num_to_text(popSmoke),'Smoke-only reduced population.');
    addrow('maxGen_smoke',num_to_text(genSmoke),'Smoke-only reduced generations.');
    addrow('rng_original_v96m','Internal fixed rng(614960,''twister'')','Detected in original v96m.');
    addrow('rng_seedaware','External rngSeed if provided; legacy seed only if omitted','Seed-aware clone behavior.');
    addrow('rng_type','twister','RNG type used in seed control.');
    addrow('seeds_smoke','61001, 61002','Used for seed-aware smoke.');
    addrow('seeds_formal_planned','61001, 61002, 61003','Planned formal independent-seed replicates.');
    addrow('confirm_execute_policy','Required true for GA execution','Guarded execution policy.');
    addrow('emission_factors_status','PROVISIONAL_FOR_CODE_VALIDATION','CO2 factors not final for manuscript claims.');
    addrow('lb_raw',string(lbRaw),'Raw lb assignment extracted from source.');
    addrow('ub_raw',string(ubRaw),'Raw ub assignment extracted from source.');
    addrow('optimoptions_raw',string(optsRaw),'Raw optimoptions block extracted from source.');

    Tgaopts = table(string(P(:)), string(V(:)), string(C(:)), ...
        'VariableNames', {'parameter','value','source_or_comment'});

    % ------------------------------------------------------------------
    % Tabla bounds
    % ------------------------------------------------------------------
    varNames = ["m_max"; "T_min"; "r_div2"; "t_rec_ini"];
    comments = [
        "Air mass flow or control variable used by model";
        "Minimum temperature setpoint";
        "Recirculation fraction divided/encoded as in model";
        "Initial recirculation time"
    ];

    if numel(lb) == 4 && numel(ub) == 4
        Tbounds = table(varNames, lb(:), ub(:), comments, ...
            'VariableNames', {'variable','lb','ub','units_or_comment'});
    else
        Tbounds = table(varNames, NaN(4,1), NaN(4,1), comments, ...
            'VariableNames', {'variable','lb','ub','units_or_comment'});
    end

    % ------------------------------------------------------------------
    % Tabla semillas
    % ------------------------------------------------------------------
    context = [
        "original_v96m";
        "seedaware_formal_clone_with_rngSeed";
        "seedaware_formal_clone_without_rngSeed";
        "seedaware_smoke_S1";
        "seedaware_smoke_S2";
        "planned_formal_R1";
        "planned_formal_R2";
        "planned_formal_R3"
    ];

    seed = [
        614960;
        NaN;
        614960;
        61001;
        61002;
        61001;
        61002;
        61003
    ];

    rng_control = [
        "INTERNAL_FIXED_SEED";
        "EXTERNAL_SEED_APPLIED";
        "LEGACY_INTERNAL_SEED_614960_APPLIED";
        "EXTERNAL_SEED_APPLIED";
        "EXTERNAL_SEED_APPLIED";
        "EXTERNAL_SEED_APPLIED";
        "EXTERNAL_SEED_APPLIED";
        "EXTERNAL_SEED_APPLIED"
    ];

    valid_for_independent_replication = [
        false;
        true;
        false;
        true;
        true;
        true;
        true;
        true
    ];

    Tseed = table(context, seed, rng_control, valid_for_independent_replication);

    % ------------------------------------------------------------------
    % Checks
    % ------------------------------------------------------------------
    rows = {};
    rows{end+1,1} = check_row("F2_01","Original formal runner exists",isfile(originalPath),string(originalPath));
    rows{end+1,1} = check_row("F2_02","Seed-aware formal clone exists",isfile(seedawarePath),string(seedawarePath));
    rows{end+1,1} = check_row("F2_03","Original has gamultiobj",hasGamultiobjOriginal,"gamultiobj found in original.");
    rows{end+1,1} = check_row("F2_04","Seed-aware has gamultiobj",hasGamultiobjSeedaware,"gamultiobj found in seed-aware clone.");
    rows{end+1,1} = check_row("F2_05","Seed-aware has optimoptions",hasOptimoptions,"optimoptions/gamultiobj found.");
    rows{end+1,1} = check_row("F2_06","Original fixed seed documented",hasLegacyFixedSeedOriginal,"rng(614960,'twister') detected in original.");
    rows{end+1,1} = check_row("F2_07","Seed-aware external branch present",hasExternalSeedBranch,"rngSeed + EXTERNAL_SEED_APPLIED present.");
    rows{end+1,1} = check_row("F2_08","Seed metadata present",hasSeedMetadata,"rngSeed_v96z and rngControl_v96z present.");
    rows{end+1,1} = check_row("F2_09","Formal popSize detected",~isnan(popSeedaware),num_to_text(popSeedaware));
    rows{end+1,1} = check_row("F2_10","Formal maxGen detected",~isnan(genSeedaware),num_to_text(genSeedaware));
    rows{end+1,1} = check_row("F2_11","Smoke popSize detected",~isnan(popSmoke),num_to_text(popSmoke));
    rows{end+1,1} = check_row("F2_12","Smoke maxGen detected",~isnan(genSmoke),num_to_text(genSmoke));
    rows{end+1,1} = check_row("F2_13","lb extracted",numel(lb)==4,string(lbRaw));
    rows{end+1,1} = check_row("F2_14","ub extracted",numel(ub)==4,string(ubRaw));
    rows{end+1,1} = check_row("F2_15","Bounds table complete",height(Tbounds)==4 && all(isfinite(Tbounds.lb)) && all(isfinite(Tbounds.ub)),"Tbounds finite.");
    rows{end+1,1} = check_row("F2_16","optimoptions block extracted",strlength(optsRaw)>0,"optimoptions block captured.");
    rows{end+1,1} = check_row("F2_17","opts saved by formal clone",savesOpts,"save list contains opts.");
    rows{end+1,1} = check_row("F2_18","X/F saved by formal clone",savesX && savesF,"save list contains X and F.");
    rows{end+1,1} = check_row("F2_19","output/population/scores saved",savesOutput && savesPopulation && savesScores,"save list contains output, population, scores.");
    rows{end+1,1} = check_row("F2_20","lb/ub saved",savesLb && savesUb,"save list contains lb and ub.");
    rows{end+1,1} = check_row("F2_21","No GA executed by audit",true,"Source-only audit; no gamultiobj call.");
    rows{end+1,1} = check_row("F2_22","Protected original not modified",true,"Audit read-only for v96m.");

    Tchecks = struct2table(vertcat(rows{:}));

    if all(Tchecks.pass)
        diagnosis = "GAOPTS_AUDIT_F2_PASS";
        decision = "GA_CONFIGURATION_TRACEABLE_BEFORE_FORMAL_RUN";
        next_step = "Review GA configuration table; then choose formal run scope.";
    else
        diagnosis = "GAOPTS_AUDIT_F2_REQUIRES_REVIEW";
        decision = "DO_NOT_RUN_LONG_FORMAL_REPLICATIONS";
        next_step = "Inspect failed F2 checks.";
    end

    % ------------------------------------------------------------------
    % Guardar salidas
    % ------------------------------------------------------------------
    gaoptsCsv = fullfile(tablesDir,'GAOPTS_AUDIT_v96z_before_formal_run_f2_Tgaopts.csv');
    boundsCsv = fullfile(tablesDir,'GAOPTS_AUDIT_v96z_before_formal_run_f2_Tbounds.csv');
    seedsCsv = fullfile(tablesDir,'GAOPTS_AUDIT_v96z_before_formal_run_f2_Tseed.csv');
    checksCsv = fullfile(tablesDir,'GAOPTS_AUDIT_v96z_before_formal_run_f2_Tchecks.csv');

    writetable(Tgaopts,gaoptsCsv);
    writetable(Tbounds,boundsCsv);
    writetable(Tseed,seedsCsv);
    writetable(Tchecks,checksCsv);

    reportMd = fullfile(reviewDir,'GAOPTS_AUDIT_v96z_before_formal_run_f2.md');

    fid = fopen(reportMd,'w');
    fprintf(fid,'# GAOPTS_AUDIT_v96z_before_formal_run_f2\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);

    fprintf(fid,'## GA configuration\n\n');
    fprintf(fid,'| parameter | value | source/comment |\n');
    fprintf(fid,'|---|---|---|\n');
    for i = 1:height(Tgaopts)
        fprintf(fid,'| `%s` | `%s` | %s |\n', ...
            Tgaopts.parameter(i), sanitize_md(Tgaopts.value(i)), sanitize_md(Tgaopts.source_or_comment(i)));
    end

    fprintf(fid,'\n## Decision-variable bounds\n\n');
    fprintf(fid,'| variable | lb | ub | comment |\n');
    fprintf(fid,'|---|---:|---:|---|\n');
    for i = 1:height(Tbounds)
        fprintf(fid,'| `%s` | %.12g | %.12g | %s |\n', ...
            Tbounds.variable(i), Tbounds.lb(i), Tbounds.ub(i), Tbounds.units_or_comment(i));
    end

    fprintf(fid,'\n## Seed control\n\n');
    fprintf(fid,'| context | seed | rng control | valid independent replication |\n');
    fprintf(fid,'|---|---:|---|---:|\n');
    for i = 1:height(Tseed)
        fprintf(fid,'| `%s` | %.0f | `%s` | %d |\n', ...
            Tseed.context(i), Tseed.seed(i), Tseed.rng_control(i), Tseed.valid_for_independent_replication(i));
    end

    fprintf(fid,'\n## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            Tchecks.id(i), sanitize_md(Tchecks.check(i)), Tchecks.pass(i), sanitize_md(Tchecks.evidence(i)));
    end

    fclose(fid);

    outMat = fullfile(traceDir,'GAOPTS_AUDIT_v96z_before_formal_run_f2.mat');

    matlabInfo = struct();
    matlabInfo.version = version;
    matlabInfo.computer = computer;
    matlabInfo.namelengthmax = namelengthmax;

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'rootDir','productionDir','articleRoot', ...
        'originalPath','seedawarePath','smokeClonePath', ...
        'Tgaopts','Tbounds','Tseed','Tchecks', ...
        'gaoptsCsv','boundsCsv','seedsCsv','checksCsv','reportMd','outMat', ...
        'matlabInfo','lbRaw','ubRaw','optsRaw');

    audit = struct();
    audit.status = 'GAOPTS_AUDIT_v96z_BEFORE_FORMAL_RUN_F2_COMPLETED';
    audit.diagnosis = diagnosis;
    audit.decision = decision;
    audit.next_step = next_step;
    audit.Tgaopts = Tgaopts;
    audit.Tbounds = Tbounds;
    audit.Tseed = Tseed;
    audit.Tchecks = Tchecks;
    audit.reportMd = reportMd;
    audit.outMat = outMat;

    disp('=== GAOPTS_AUDIT_v96z_BEFORE_FORMAL_RUN_F2 ===')
    disp(audit.status)
    disp('=== DIAGNOSIS ===')
    disp(audit.diagnosis)
    disp('=== DECISION ===')
    disp(audit.decision)
    disp('=== NEXT STEP ===')
    disp(audit.next_step)
    disp('=== GA OPTIONS ===')
    disp(audit.Tgaopts)
    disp('=== BOUNDS ===')
    disp(audit.Tbounds)
    disp('=== SEED CONTROL ===')
    disp(audit.Tseed)
    disp('=== CHECKS ===')
    disp(audit.Tchecks)
    disp('=== REPORT ===')
    disp(audit.reportMd)

    function addrow(p,v,c)
        P{end+1,1} = char(string(p));
        V{end+1,1} = char(string(v));
        C{end+1,1} = char(string(c));
    end
end

function x = extract_numeric_assignment(txt,varName)
    x = NaN;
    pat = [varName '\s*=\s*([0-9]+(?:\.[0-9]+)?)\s*;'];
    tok = regexp(txt,pat,'tokens','once');
    if ~isempty(tok)
        x = str2double(tok{1});
    end
end

function [v, raw] = extract_vector_assignment(txt,varName)
    v = [];
    raw = "";
    pat = [varName '\s*=\s*\[([^\]]+)\]\s*;'];
    tok = regexp(txt,pat,'tokens','once');
    if isempty(tok)
        return;
    end
    raw = string(strtrim(tok{1}));
    nums = regexp(tok{1},'[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?','match');
    if isempty(nums)
        return;
    end
    v = str2double(nums);
end

function s = extract_string_assignment(txt,varName)
    s = "";
    pat1 = [varName '\s*=\s*"([^"]+)"\s*;'];
    tok = regexp(txt,pat1,'tokens','once');
    if ~isempty(tok)
        s = string(tok{1});
        return;
    end

    pat2 = [varName '\s*=\s*''([^'']+)''\s*;'];
    tok = regexp(txt,pat2,'tokens','once');
    if ~isempty(tok)
        s = string(tok{1});
    end
end

function block = extract_optimoptions_block(txt)
    block = "";
    idx = regexp(txt,'opts\s*=\s*optimoptions\s*\(\s*''gamultiobj''','once');
    if isempty(idx)
        idx = regexp(txt,'opts\s*=\s*optimoptions\s*\(\s*"gamultiobj"','once');
    end
    if isempty(idx)
        return;
    end

    stopIdx = regexp(txt(idx:end),'\);\s*','once');
    if isempty(stopIdx)
        return;
    end

    blockChar = txt(idx:idx+stopIdx);
    block = string(strtrim(blockChar));
end

function s = num_to_text(x)
    if isnan(x)
        s = "NaN";
    else
        s = string(num2str(x,15));
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