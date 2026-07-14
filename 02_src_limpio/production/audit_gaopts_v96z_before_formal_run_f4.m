function audit = audit_gaopts_v96z_before_formal_run_f4()
% AUDIT_GAOPTS_v96z_BEFORE_FORMAL_RUN_f4
%
% Auditoría definitiva de configuración GA antes de corrida formal seed-aware.
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica fuentes protegidas.
%
% Consolida:
%   - gamultiobj
%   - PopulationSize / MaxGenerations
%   - opciones de optimoptions
%   - control de semilla
%   - origen de límites desde design_triobjective_formal_run_v96l.m
%   - lb_formal / ub_formal usados por v96m / seed-aware clone

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
    designPath = fullfile(productionDir,'design_triobjective_formal_run_v96l.m');
    smokeClonePath = fullfile(productionDir,'v96z_rngfix_smoke.m');

    originalTxt = fileread(originalPath);
    seedawareTxt = fileread(seedawarePath);
    designTxt = fileread(designPath);

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

    [x_selected, x_selected_raw] = extract_multiline_vector_assignment(designTxt,'x_selected');
    [lb_global, lb_global_raw] = extract_vector_assignment(designTxt,'lb_global');
    [ub_global, ub_global_raw] = extract_vector_assignment(designTxt,'ub_global');
    [delta_formal, delta_formal_raw] = extract_vector_assignment(designTxt,'delta_formal');

    lb_formal = max(lb_global, x_selected - delta_formal);
    ub_formal = min(ub_global, x_selected + delta_formal);
    nvars = 4;

    optsRaw = extract_optimoptions_block(seedawareTxt);
    if strlength(optsRaw) == 0
        optsRaw = extract_optimoptions_block(originalTxt);
    end

    modeFormal = extract_string_assignment(seedawareTxt,'modeFormal');
    if strlength(modeFormal) == 0
        modeFormal = "hybrid";
    end

    hasGamultiobjOriginal = contains(originalTxt,'gamultiobj');
    hasGamultiobjSeedaware = contains(seedawareTxt,'gamultiobj');
    hasOptimoptions = contains(seedawareTxt,'optimoptions') && contains(seedawareTxt,'gamultiobj');
    hasLegacyFixedSeedOriginal = contains(originalTxt, 'rng(614960,''twister'')') || contains(originalTxt, 'rng(614960,"twister")');
    hasExternalSeedBranch = contains(seedawareTxt,'EXTERNAL_SEED_APPLIED') && contains(seedawareTxt,'rngSeed');
    hasSeedMetadata = contains(seedawareTxt,'rngSeed_v96z') && contains(seedawareTxt,'rngControl_v96z');

    usesSdesignBounds = contains(seedawareTxt,'lb = Sdesign.lb_formal') && contains(seedawareTxt,'ub = Sdesign.ub_formal');
    designSavesBounds = contains(designTxt,'''lb_global''') && contains(designTxt,'''ub_global''') && ...
                         contains(designTxt,'''delta_formal''') && contains(designTxt,'''lb_formal''') && ...
                         contains(designTxt,'''ub_formal''') && contains(designTxt,'''nvars''');

    savesOpts = contains(seedawareTxt,'''opts''') || contains(seedawareTxt,'"opts"');
    savesX = contains(seedawareTxt,'''X''') || contains(seedawareTxt,'"X"');
    savesF = contains(seedawareTxt,'''F''') || contains(seedawareTxt,'"F"');
    savesOutput = contains(seedawareTxt,'''output''') || contains(seedawareTxt,'"output"');
    savesPopulation = contains(seedawareTxt,'''population''') || contains(seedawareTxt,'"population"');
    savesScores = contains(seedawareTxt,'''scores''') || contains(seedawareTxt,'"scores"');
    savesLbUb = (contains(seedawareTxt,'''lb''') || contains(seedawareTxt,'"lb"')) && ...
                (contains(seedawareTxt,'''ub''') || contains(seedawareTxt,'"ub"'));

    % ------------------------------------------------------------------
    % Tabla GA
    % ------------------------------------------------------------------
    P = {};
    V = {};
    C = {};

    addrow('algorithm','gamultiobj','Solver used for multiobjective genetic algorithm.');
    addrow('objective_count','3','Objectives: MR, specific cost, specific CO2.');
    addrow('decision_variables','4','m_max, T_min, r_div2, t_rec_ini.');
    addrow('modeFormal',modeFormal,'Formal optimization mode.');
    addrow('referenceMode','gasLP','Reference mode for comparative interpretation.');

    addrow('popSize_seedaware_formal',num_to_text(popSeedaware),'Explicit assignment in seed-aware formal clone.');
    addrow('maxGen_seedaware_formal',num_to_text(genSeedaware),'Explicit assignment in seed-aware formal clone.');
    addrow('popSize_original_v96m',num_to_text(popOriginal),'Explicit assignment in original v96m.');
    addrow('maxGen_original_v96m',num_to_text(genOriginal),'Explicit assignment in original v96m.');
    addrow('popSize_smoke',num_to_text(popSmoke),'Smoke-only reduced population.');
    addrow('maxGen_smoke',num_to_text(genSmoke),'Smoke-only reduced generations.');

    addrow('rng_original_v96m','Internal fixed rng(614960,''twister'')','Reason for rngfix.');
    addrow('rng_seedaware','External rngSeed if provided; legacy seed only if omitted','Seed-aware clone behavior.');
    addrow('rng_type','twister','RNG type used in seed control.');
    addrow('seeds_smoke','61001, 61002','Used for seed-aware smoke.');
    addrow('seeds_formal_planned','61001, 61002, 61003','Planned formal independent-seed replicates.');

    addrow('confirm_execute_policy','Required true for GA execution','Guarded execution policy.');
    addrow('emission_factors_status','PROVISIONAL_FOR_CODE_VALIDATION','CO2 factors not final for manuscript claims.');

    addrow('x_selected_raw',x_selected_raw,'From design_triobjective_formal_run_v96l.m.');
    addrow('lb_global_raw',lb_global_raw,'From design_triobjective_formal_run_v96l.m.');
    addrow('ub_global_raw',ub_global_raw,'From design_triobjective_formal_run_v96l.m.');
    addrow('delta_formal_raw',delta_formal_raw,'From design_triobjective_formal_run_v96l.m.');
    addrow('lb_formal_formula','max(lb_global, x_selected - delta_formal)','Formal lower-bound formula.');
    addrow('ub_formal_formula','min(ub_global, x_selected + delta_formal)','Formal upper-bound formula.');
    addrow('optimoptions_raw',optsRaw,'Raw optimoptions block extracted from seed-aware clone.');

    Tgaopts = table(string(P(:)), string(V(:)), string(C(:)), ...
        'VariableNames', {'parameter','value','source_or_comment'});

    % ------------------------------------------------------------------
    % Tabla bounds
    % ------------------------------------------------------------------
    variable = ["m_max"; "T_min"; "r_div2"; "t_rec_ini"];

    Tbounds = table();
    Tbounds.variable = variable;
    Tbounds.x_selected = x_selected(:);
    Tbounds.lb_global = lb_global(:);
    Tbounds.ub_global = ub_global(:);
    Tbounds.delta_formal = delta_formal(:);
    Tbounds.lb_formal = lb_formal(:);
    Tbounds.ub_formal = ub_formal(:);
    Tbounds.bound_formula = repmat("lb=max(lb_global,x_selected-delta); ub=min(ub_global,x_selected+delta)",4,1);

    % ------------------------------------------------------------------
    % Tabla seed control
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
    rows{end+1,1} = check_row("F4_01","Original formal runner exists",isfile(originalPath),string(originalPath));
    rows{end+1,1} = check_row("F4_02","Seed-aware formal clone exists",isfile(seedawarePath),string(seedawarePath));
    rows{end+1,1} = check_row("F4_03","Design v96l exists",isfile(designPath),string(designPath));
    rows{end+1,1} = check_row("F4_04","Original has gamultiobj",hasGamultiobjOriginal,"gamultiobj found in original.");
    rows{end+1,1} = check_row("F4_05","Seed-aware has gamultiobj",hasGamultiobjSeedaware,"gamultiobj found in seed-aware clone.");
    rows{end+1,1} = check_row("F4_06","Seed-aware has optimoptions",hasOptimoptions,"optimoptions/gamultiobj found.");
    rows{end+1,1} = check_row("F4_07","Original fixed seed documented",hasLegacyFixedSeedOriginal,"rng(614960,'twister') detected in original.");
    rows{end+1,1} = check_row("F4_08","Seed-aware external branch present",hasExternalSeedBranch,"rngSeed + EXTERNAL_SEED_APPLIED present.");
    rows{end+1,1} = check_row("F4_09","Seed metadata present",hasSeedMetadata,"rngSeed_v96z and rngControl_v96z present.");
    rows{end+1,1} = check_row("F4_10","Formal popSize detected",~isnan(popSeedaware),num_to_text(popSeedaware));
    rows{end+1,1} = check_row("F4_11","Formal maxGen detected",~isnan(genSeedaware),num_to_text(genSeedaware));
    rows{end+1,1} = check_row("F4_12","x_selected extracted",numel(x_selected)==4,mat2str(x_selected,12));
    rows{end+1,1} = check_row("F4_13","lb_global extracted",numel(lb_global)==4,mat2str(lb_global,12));
    rows{end+1,1} = check_row("F4_14","ub_global extracted",numel(ub_global)==4,mat2str(ub_global,12));
    rows{end+1,1} = check_row("F4_15","delta_formal extracted",numel(delta_formal)==4,mat2str(delta_formal,12));
    rows{end+1,1} = check_row("F4_16","lb_formal computed",numel(lb_formal)==4 && all(isfinite(lb_formal)),mat2str(lb_formal,12));
    rows{end+1,1} = check_row("F4_17","ub_formal computed",numel(ub_formal)==4 && all(isfinite(ub_formal)),mat2str(ub_formal,12));
    rows{end+1,1} = check_row("F4_18","Bounds table complete",height(Tbounds)==4 && all(isfinite(Tbounds.lb_formal)) && all(isfinite(Tbounds.ub_formal)),"Tbounds finite.");
    rows{end+1,1} = check_row("F4_19","Runner uses Sdesign bounds",usesSdesignBounds,"lb/ub loaded from Sdesign.");
    rows{end+1,1} = check_row("F4_20","Design saves bounds",designSavesBounds,"v96l saves x_selected/lb_global/ub_global/delta/lb_formal/ub_formal/nvars.");
    rows{end+1,1} = check_row("F4_21","optimoptions block extracted",strlength(optsRaw)>0,"optimoptions block captured.");
    rows{end+1,1} = check_row("F4_22","opts saved by formal clone",savesOpts,"save list contains opts.");
    rows{end+1,1} = check_row("F4_23","X/F saved by formal clone",savesX && savesF,"save list contains X and F.");
    rows{end+1,1} = check_row("F4_24","output/population/scores saved",savesOutput && savesPopulation && savesScores,"save list contains output, population, scores.");
    rows{end+1,1} = check_row("F4_25","lb/ub saved",savesLbUb,"save list contains lb and ub.");
    rows{end+1,1} = check_row("F4_26","No GA executed by audit",true,"Source-only audit; no gamultiobj call.");
    rows{end+1,1} = check_row("F4_27","Protected original not modified",true,"Audit read-only for v96m.");

    Tchecks = struct2table(vertcat(rows{:}));

    if all(Tchecks.pass)
        diagnosis = "GAOPTS_AUDIT_F4_PASS";
        decision = "GA_CONFIGURATION_TRACEABLE_BEFORE_FORMAL_RUN";
        next_step = "Decide formal seed-aware run scope: R1-only or R1/R2/R3.";
    else
        diagnosis = "GAOPTS_AUDIT_F4_REQUIRES_REVIEW";
        decision = "DO_NOT_RUN_LONG_FORMAL_REPLICATIONS";
        next_step = "Inspect failed F4 checks.";
    end

    % ------------------------------------------------------------------
    % Guardar
    % ------------------------------------------------------------------
    gaoptsCsv = fullfile(tablesDir,'GAOPTS_AUDIT_v96z_before_formal_run_f4_Tgaopts.csv');
    boundsCsv = fullfile(tablesDir,'GAOPTS_AUDIT_v96z_before_formal_run_f4_Tbounds.csv');
    seedsCsv = fullfile(tablesDir,'GAOPTS_AUDIT_v96z_before_formal_run_f4_Tseed.csv');
    checksCsv = fullfile(tablesDir,'GAOPTS_AUDIT_v96z_before_formal_run_f4_Tchecks.csv');

    writetable(Tgaopts,gaoptsCsv);
    writetable(Tbounds,boundsCsv);
    writetable(Tseed,seedsCsv);
    writetable(Tchecks,checksCsv);

    reportMd = fullfile(reviewDir,'GAOPTS_AUDIT_v96z_before_formal_run_f4.md');

    fid = fopen(reportMd,'w');
    fprintf(fid,'# GAOPTS_AUDIT_v96z_before_formal_run_f4\n\n');
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
    fprintf(fid,'| variable | x_selected | lb_global | ub_global | delta_formal | lb_formal | ub_formal |\n');
    fprintf(fid,'|---|---:|---:|---:|---:|---:|---:|\n');
    for i = 1:height(Tbounds)
        fprintf(fid,'| `%s` | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g |\n', ...
            Tbounds.variable(i), Tbounds.x_selected(i), Tbounds.lb_global(i), Tbounds.ub_global(i), ...
            Tbounds.delta_formal(i), Tbounds.lb_formal(i), Tbounds.ub_formal(i));
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

    outMat = fullfile(traceDir,'GAOPTS_AUDIT_v96z_before_formal_run_f4.mat');

    matlabInfo = struct();
    matlabInfo.version = version;
    matlabInfo.computer = computer;
    matlabInfo.namelengthmax = namelengthmax;

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'rootDir','productionDir','articleRoot', ...
        'originalPath','seedawarePath','designPath','smokeClonePath', ...
        'Tgaopts','Tbounds','Tseed','Tchecks', ...
        'gaoptsCsv','boundsCsv','seedsCsv','checksCsv','reportMd','outMat', ...
        'matlabInfo','x_selected','lb_global','ub_global','delta_formal','lb_formal','ub_formal','optsRaw');

    audit = struct();
    audit.status = 'GAOPTS_AUDIT_v96z_BEFORE_FORMAL_RUN_F4_COMPLETED';
    audit.diagnosis = diagnosis;
    audit.decision = decision;
    audit.next_step = next_step;
    audit.Tgaopts = Tgaopts;
    audit.Tbounds = Tbounds;
    audit.Tseed = Tseed;
    audit.Tchecks = Tchecks;
    audit.reportMd = reportMd;
    audit.outMat = outMat;

    disp('=== GAOPTS_AUDIT_v96z_BEFORE_FORMAL_RUN_F4 ===')
    disp(audit.status)
    disp('=== DIAGNOSIS ===')
    disp(audit.diagnosis)
    disp('=== DECISION ===')
    disp(audit.decision)
    disp('=== NEXT STEP ===')
    disp(audit.next_step)
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
    v = str2double(nums);
end

function [v, raw] = extract_multiline_vector_assignment(txt,varName)
    v = [];
    raw = "";
    pat = [varName '\s*=\s*\[(.*?)\]\s*;'];
    tok = regexp(txt,pat,'tokens','once');
    if isempty(tok)
        return;
    end
    raw = string(strtrim(tok{1}));
    nums = regexp(tok{1},'[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?','match');
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