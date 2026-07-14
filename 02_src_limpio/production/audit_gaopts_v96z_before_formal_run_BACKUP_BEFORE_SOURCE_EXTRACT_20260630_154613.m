function audit = audit_gaopts_v96z_before_formal_run()
% AUDIT_GAOPTS_v96z_BEFORE_FORMAL_RUN
%
% Consolida parámetros del algoritmo genético multiobjetivo antes de
% cualquier corrida formal seed-aware larga.
%
% No ejecuta GA.
% No ejecuta el modelo.
% No modifica v96m original.
% No modifica el clon seed-aware formal.
%
% Salidas:
%   - Tabla metodológica de parámetros GA.
%   - Tabla de límites de variables.
%   - Tabla de control de semillas.
%   - Reporte Markdown.
%   - MAT de trazabilidad.

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

    formalOriginalPath = fullfile(productionDir,'run_guarded_triobjective_formal_ga_v96m.m');
    seedawarePath = fullfile(productionDir,'run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m');
    smokeRunnerPath = fullfile(productionDir,'run_seedaware_smoke_seed_difference_v96z_rngfix.m');
    smokeClonePath = fullfile(productionDir,'v96z_rngfix_smoke.m');

    if ~isfile(formalOriginalPath)
        error('No existe formalOriginalPath: %s',formalOriginalPath);
    end

    if ~isfile(seedawarePath)
        error('No existe seedawarePath: %s',seedawarePath);
    end

    originalTxt = string(fileread(formalOriginalPath));
    seedawareTxt = string(fileread(seedawarePath));

    if isfile(smokeRunnerPath)
        smokeRunnerTxt = string(fileread(smokeRunnerPath));
    else
        smokeRunnerTxt = "";
    end

    if isfile(smokeClonePath)
        smokeCloneTxt = string(fileread(smokeClonePath));
    else
        smokeCloneTxt = "";
    end

    % ---------------------------------------------------------------------
    % Extraer valores explícitos por texto
    % ---------------------------------------------------------------------
    popOriginal = extract_numeric_assignment(originalTxt,"popSize");
    genOriginal = extract_numeric_assignment(originalTxt,"maxGen");

    popSeedaware = extract_numeric_assignment(seedawareTxt,"popSize");
    genSeedaware = extract_numeric_assignment(seedawareTxt,"maxGen");

    popSmoke = extract_numeric_assignment(smokeCloneTxt,"popSize");
    genSmoke = extract_numeric_assignment(smokeCloneTxt,"maxGen");

    hasGamultiobjOriginal = contains(originalTxt,"gamultiobj");
    hasGamultiobjSeedaware = contains(seedawareTxt,"gamultiobj");
    hasOptimoptionsSeedaware = contains(seedawareTxt,"optimoptions") && contains(seedawareTxt,"gamultiobj");

    hasLegacyFixedSeedOriginal = contains(originalTxt,"rng(614960,'twister')") || contains(originalTxt,'rng(614960,"twister")');
    hasLegacySeedInSeedaware = contains(seedawareTxt,"rng(614960,'twister')") || contains(seedawareTxt,'rng(614960,"twister")');
    hasExternalSeedBranch = contains(seedawareTxt,"EXTERNAL_SEED_APPLIED") && contains(seedawareTxt,"rngSeed");
    hasSeedMetadata = contains(seedawareTxt,"rngSeed_v96z") && contains(seedawareTxt,"rngControl_v96z");

    savesOpts = contains(seedawareTxt,"'opts'") || contains(seedawareTxt,'"opts"');
    savesX = contains(seedawareTxt,"'X'") || contains(seedawareTxt,'"X"');
    savesF = contains(seedawareTxt,"'F'") || contains(seedawareTxt,'"F"');
    savesOutput = contains(seedawareTxt,"'output'") || contains(seedawareTxt,'"output"');
    savesPopulation = contains(seedawareTxt,"'population'") || contains(seedawareTxt,'"population"');
    savesScores = contains(seedawareTxt,"'scores'") || contains(seedawareTxt,'"scores"');
    savesLbUb = contains(seedawareTxt,"'lb'") && contains(seedawareTxt,"'ub'");

    % ---------------------------------------------------------------------
    % Obtener opts/lb/ub/nvars sin ejecutar GA
    % Llamar confirm_execute=false solo si el clon ya fue validado como guardado.
    % Esta llamada puede hacer preflight interno, pero no gamultiobj.
    % ---------------------------------------------------------------------
    formalPreview = [];
    previewStatus = "NOT_EXECUTED";
    previewError = "";
    opts = [];
    lb = [];
    ub = [];
    nvars = NaN;
    modeFormal = "";
    formalFlags = struct();

    try
        formalPreview = run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix(false, 61001);
        previewStatus = "OK";

        if isfield(formalPreview,'opts')
            opts = formalPreview.opts;
        end

        if isfield(formalPreview,'lb')
            lb = formalPreview.lb;
        end

        if isfield(formalPreview,'ub')
            ub = formalPreview.ub;
        end

        if isfield(formalPreview,'nvars')
            nvars = formalPreview.nvars;
        elseif ~isempty(lb)
            nvars = numel(lb);
        end

        if isfield(formalPreview,'modeFormal')
            modeFormal = string(formalPreview.modeFormal);
        end

        if isfield(formalPreview,'formalFlags')
            formalFlags = formalPreview.formalFlags;
        end

    catch ME
        previewStatus = "ERROR";
        previewError = string(ME.message);
    end

    % ---------------------------------------------------------------------
    % Consolidar parámetros de optimoptions si existen
    % ---------------------------------------------------------------------
    gaRows = {};

    add_ga_row("algorithm","gamultiobj","Solver used for multiobjective genetic algorithm.");
    add_ga_row("objective_count","3","Objectives: MR, specific cost, specific CO2.");
    add_ga_row("decision_variables","4","m_max, T_min, r_div2, t_rec_ini.");
    add_ga_row("modeFormal",safe_string(modeFormal),"Formal mode optimized.");
    add_ga_row("referenceMode","gasLP","Reference mode for comparative interpretation.");
    add_ga_row("popSize_original_v96m",num_to_text(popOriginal),"Explicit value found in original v96m.");
    add_ga_row("maxGen_original_v96m",num_to_text(genOriginal),"Explicit value found in original v96m.");
    add_ga_row("popSize_seedaware_formal",num_to_text(popSeedaware),"Explicit value found in seed-aware formal clone.");
    add_ga_row("maxGen_seedaware_formal",num_to_text(genSeedaware),"Explicit value found in seed-aware formal clone.");
    add_ga_row("popSize_smoke",num_to_text(popSmoke),"Smoke-only reduced population.");
    add_ga_row("maxGen_smoke",num_to_text(genSmoke),"Smoke-only reduced generations.");
    add_ga_row("confirm_execute_policy","Required true for GA execution","Guarded execution policy.");
    add_ga_row("rng_original_v96m","Internal fixed rng(614960,''twister'')","Detected in original v96m; reason for rngfix.");
    add_ga_row("rng_seedaware","External rngSeed if provided; legacy seed only if omitted","Seed-aware clone behavior.");
    add_ga_row("rng_type","twister","RNG type used in seed control.");
    add_ga_row("seeds_smoke","61001, 61002","Used for seed-aware smoke.");
    add_ga_row("seeds_formal_planned","61001, 61002, 61003","Planned formal independent-seed replicates.");
    add_ga_row("emission_factors_status","PROVISIONAL_FOR_CODE_VALIDATION","CO2 factors not final for manuscript claims.");

    if ~isempty(opts)
        add_opt_if_exists("PopulationSize",opts);
        add_opt_if_exists("MaxGenerations",opts);
        add_opt_if_exists("ParetoFraction",opts);
        add_opt_if_exists("CrossoverFraction",opts);
        add_opt_if_exists("FunctionTolerance",opts);
        add_opt_if_exists("ConstraintTolerance",opts);
        add_opt_if_exists("UseParallel",opts);
        add_opt_if_exists("UseVectorized",opts);
        add_opt_if_exists("Display",opts);
        add_opt_if_exists("PlotFcn",opts);
        add_opt_if_exists("OutputFcn",opts);
        add_opt_if_exists("CreationFcn",opts);
        add_opt_if_exists("CrossoverFcn",opts);
        add_opt_if_exists("MutationFcn",opts);
        add_opt_if_exists("SelectionFcn",opts);
        add_opt_if_exists("DistanceMeasureFcn",opts);
        add_opt_if_exists("InitialPopulationMatrix",opts);
        add_opt_if_exists("InitialScoresMatrix",opts);
        add_opt_if_exists("PopulationType",opts);
        add_opt_if_exists("MaxStallGenerations",opts);
        add_opt_if_exists("MaxTime",opts);
        add_opt_if_exists("StallTest",opts);
    else
        add_ga_row("opts_status","NOT_AVAILABLE","Could not extract opts from confirm_execute=false preview.");
    end

    Tgaopts = struct2table(vertcat(gaRows{:}));

    % ---------------------------------------------------------------------
    % Límites de variables
    % ---------------------------------------------------------------------
    varNames = ["m_max"; "T_min"; "r_div2"; "t_rec_ini"];

    if isempty(lb) || isempty(ub)
        Tbounds = table();
        Tbounds.variable = varNames;
        Tbounds.lb = NaN(4,1);
        Tbounds.ub = NaN(4,1);
        Tbounds.units_or_comment = [
            "Air mass flow or control variable used by model";
            "Minimum temperature setpoint";
            "Recirculation fraction divided/encoded as in model";
            "Initial recirculation time"
        ];
    else
        lb = lb(:);
        ub = ub(:);

        n = min([numel(lb),numel(ub),numel(varNames)]);
        Tbounds = table();
        Tbounds.variable = varNames(1:n);
        Tbounds.lb = lb(1:n);
        Tbounds.ub = ub(1:n);
        Tbounds.units_or_comment = [
            "Air mass flow or control variable used by model";
            "Minimum temperature setpoint";
            "Recirculation fraction divided/encoded as in model";
            "Initial recirculation time"
        ];
        Tbounds.units_or_comment = Tbounds.units_or_comment(1:n);
    end

    % ---------------------------------------------------------------------
    % Tabla de control de semillas
    % ---------------------------------------------------------------------
    Tseed = table();
    Tseed.context = [
        "original_v96m";
        "seedaware_formal_clone_with_rngSeed";
        "seedaware_formal_clone_without_rngSeed";
        "seedaware_smoke_S1";
        "seedaware_smoke_S2";
        "planned_formal_R1";
        "planned_formal_R2";
        "planned_formal_R3"
    ];
    Tseed.seed = [
        614960;
        NaN;
        614960;
        61001;
        61002;
        61001;
        61002;
        61003
    ];
    Tseed.rng_control = [
        "INTERNAL_FIXED_SEED";
        "EXTERNAL_SEED_APPLIED";
        "LEGACY_INTERNAL_SEED_614960_APPLIED";
        "EXTERNAL_SEED_APPLIED";
        "EXTERNAL_SEED_APPLIED";
        "EXTERNAL_SEED_APPLIED";
        "EXTERNAL_SEED_APPLIED";
        "EXTERNAL_SEED_APPLIED"
    ];
    Tseed.valid_for_independent_replication = [
        false;
        true;
        false;
        true;
        true;
        true;
        true;
        true
    ];

    % ---------------------------------------------------------------------
    % Tabla de archivos fuente y preservación
    % ---------------------------------------------------------------------
    Tfiles = table();
    Tfiles.file_role = [
        "original_formal_runner";
        "seedaware_formal_clone";
        "seedaware_smoke_runner";
        "seedaware_smoke_clone"
    ];
    Tfiles.path = [
        string(formalOriginalPath);
        string(seedawarePath);
        string(smokeRunnerPath);
        string(smokeClonePath)
    ];
    Tfiles.exists = [
        isfile(formalOriginalPath);
        isfile(seedawarePath);
        isfile(smokeRunnerPath);
        isfile(smokeClonePath)
    ];
    Tfiles.modified_by_this_audit = false(height(Tfiles),1);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};
    checks{end+1,1} = check_row("GA01","Original formal runner exists",isfile(formalOriginalPath),string(formalOriginalPath));
    checks{end+1,1} = check_row("GA02","Seed-aware formal clone exists",isfile(seedawarePath),string(seedawarePath));
    checks{end+1,1} = check_row("GA03","Original has gamultiobj",hasGamultiobjOriginal,"gamultiobj found in original.");
    checks{end+1,1} = check_row("GA04","Seed-aware clone has gamultiobj",hasGamultiobjSeedaware,"gamultiobj found in seed-aware clone.");
    checks{end+1,1} = check_row("GA05","Seed-aware clone has optimoptions",hasOptimoptionsSeedaware,"optimoptions/gamultiobj found.");
    checks{end+1,1} = check_row("GA06","Original fixed seed documented",hasLegacyFixedSeedOriginal,"rng(614960,'twister') detected in original.");
    checks{end+1,1} = check_row("GA07","Seed-aware external branch present",hasExternalSeedBranch,"rngSeed + EXTERNAL_SEED_APPLIED present.");
    checks{end+1,1} = check_row("GA08","Seed metadata present",hasSeedMetadata,"rngSeed_v96z and rngControl_v96z present.");
    checks{end+1,1} = check_row("GA09","Formal popSize detected",~isnan(popSeedaware),num_to_text(popSeedaware));
    checks{end+1,1} = check_row("GA10","Formal maxGen detected",~isnan(genSeedaware),num_to_text(genSeedaware));
    checks{end+1,1} = check_row("GA11","Smoke popSize detected",~isnan(popSmoke),num_to_text(popSmoke));
    checks{end+1,1} = check_row("GA12","Smoke maxGen detected",~isnan(genSmoke),num_to_text(genSmoke));
    checks{end+1,1} = check_row("GA13","Preview call did not execute GA",previewStatus=="OK" && isfield(formalFlags,'formal_run_executed') && formalFlags.formal_run_executed==0,previewStatus + " " + previewError);
    checks{end+1,1} = check_row("GA14","opts saved by formal clone",savesOpts,"save list contains opts.");
    checks{end+1,1} = check_row("GA15","X/F saved by formal clone",savesX && savesF,"save list contains X and F.");
    checks{end+1,1} = check_row("GA16","output/population/scores saved",savesOutput && savesPopulation && savesScores,"save list contains output, population, scores.");
    checks{end+1,1} = check_row("GA17","lb/ub saved",savesLbUb,"save list contains lb and ub.");
    checks{end+1,1} = check_row("GA18","Bounds available",height(Tbounds) >= 4 && all(isfinite(Tbounds.lb)) && all(isfinite(Tbounds.ub)),"lb/ub extracted.");
    checks{end+1,1} = check_row("GA19","No GA executed by audit",true,"No gamultiobj call from this audit.");
    checks{end+1,1} = check_row("GA20","Protected original not modified",true,"Audit read-only for v96m.");

    Tchecks = struct2table(vertcat(checks{:}));

    if all(Tchecks.pass)
        diagnosis = "GAOPTS_AUDIT_PASS";
        decision = "GA_CONFIGURATION_TRACEABLE_BEFORE_FORMAL_RUN";
        next_step = "Review GA parameter table; then decide formal seed-aware run scope.";
    else
        diagnosis = "GAOPTS_AUDIT_REQUIRES_REVIEW";
        decision = "DO_NOT_RUN_LONG_FORMAL_REPLICATIONS";
        next_step = "Inspect failed GA checks before any formal run.";
    end

    % ---------------------------------------------------------------------
    % Guardar tablas y reporte
    % ---------------------------------------------------------------------
    gaoptsCsv = fullfile(tablesDir,'GAOPTS_AUDIT_v96z_before_formal_run_Tgaopts.csv');
    boundsCsv = fullfile(tablesDir,'GAOPTS_AUDIT_v96z_before_formal_run_Tbounds.csv');
    seedsCsv = fullfile(tablesDir,'GAOPTS_AUDIT_v96z_before_formal_run_Tseed.csv');
    filesCsv = fullfile(tablesDir,'GAOPTS_AUDIT_v96z_before_formal_run_Tfiles.csv');
    checksCsv = fullfile(tablesDir,'GAOPTS_AUDIT_v96z_before_formal_run_Tchecks.csv');

    writetable(Tgaopts,gaoptsCsv);
    writetable(Tbounds,boundsCsv);
    writetable(Tseed,seedsCsv);
    writetable(Tfiles,filesCsv);
    writetable(Tchecks,checksCsv);

    reportMd = fullfile(reviewDir,'GAOPTS_AUDIT_v96z_before_formal_run.md');

    fid = fopen(reportMd,'w');
    fprintf(fid,'# GAOPTS_AUDIT_v96z_before_formal_run\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);

    fprintf(fid,'## Core GA configuration\n\n');
    fprintf(fid,'| parameter | value | source/comment |\n');
    fprintf(fid,'|---|---|---|\n');
    for i = 1:height(Tgaopts)
        fprintf(fid,'| `%s` | `%s` | %s |\n', ...
            Tgaopts.parameter(i), Tgaopts.value(i), Tgaopts.source_or_comment(i));
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
            Tchecks.id(i), Tchecks.check(i), Tchecks.pass(i), Tchecks.evidence(i));
    end

    fprintf(fid,'\n## Methodological note\n\n');
    fprintf(fid,'This audit consolidates the genetic algorithm configuration before formal seed-aware runs. ');
    fprintf(fid,'The smoke test validated that external seed control changes X/F fronts, but smoke results are not used as final optimization results.\n');
    fclose(fid);

    outMat = fullfile(traceDir,'GAOPTS_AUDIT_v96z_before_formal_run.mat');

    matlabInfo = struct();
    matlabInfo.version = version;
    matlabInfo.computer = computer;
    matlabInfo.namelengthmax = namelengthmax;

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'rootDir','productionDir','articleRoot', ...
        'formalOriginalPath','seedawarePath','smokeRunnerPath','smokeClonePath', ...
        'Tgaopts','Tbounds','Tseed','Tfiles','Tchecks', ...
        'gaoptsCsv','boundsCsv','seedsCsv','filesCsv','checksCsv','reportMd','outMat', ...
        'matlabInfo','formalPreview','previewStatus','previewError');

    audit = struct();
    audit.status = 'GAOPTS_AUDIT_v96z_BEFORE_FORMAL_RUN_COMPLETED';
    audit.diagnosis = diagnosis;
    audit.decision = decision;
    audit.next_step = next_step;
    audit.Tgaopts = Tgaopts;
    audit.Tbounds = Tbounds;
    audit.Tseed = Tseed;
    audit.Tfiles = Tfiles;
    audit.Tchecks = Tchecks;
    audit.reportMd = reportMd;
    audit.outMat = outMat;

    disp('=== GAOPTS_AUDIT_v96z_BEFORE_FORMAL_RUN ===')
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

    % ---------------------------------------------------------------------
    % Nested helper: add row
    % ---------------------------------------------------------------------
    function add_ga_row(parameter,value,source_or_comment)
        row = struct();
        row.parameter = string(parameter);
        row.value = string(value);
        row.source_or_comment = string(source_or_comment);
        gaRows{end+1,1} = row;
    end

    function add_opt_if_exists(optName,optsLocal)
        try
            val = optsLocal.(optName);
            add_ga_row(optName,value_to_string(val),"Extracted from optimoptions object.");
        catch
            add_ga_row(optName,"<not available>","Property not available in this MATLAB/options object.");
        end
    end
end

function x = extract_numeric_assignment(txt,varName)
    x = NaN;
    pat = varName + "\s*=\s*([0-9]+(?:\.[0-9]+)?)\s*;";
    tok = regexp(txt,pat,'tokens','once');
    if ~isempty(tok)
        x = str2double(tok{1});
    end
end

function s = value_to_string(v)
    try
        if isempty(v)
            s = "<empty>";
        elseif isnumeric(v) || islogical(v)
            if isscalar(v)
                s = string(num2str(v,15));
            else
                sz = size(v);
                if numel(v) <= 10
                    s = string(mat2str(v,6));
                else
                    s = sprintf("<%s %dx%d>",class(v),sz(1),sz(2));
                end
            end
        elseif ischar(v)
            s = string(v);
        elseif isstring(v)
            if isscalar(v)
                s = v;
            else
                s = strjoin(v,", ");
            end
        elseif isa(v,'function_handle')
            s = string(func2str(v));
        elseif iscell(v)
            if isempty(v)
                s = "<empty cell>";
            else
                parts = strings(numel(v),1);
                for k = 1:numel(v)
                    parts(k) = value_to_string(v{k});
                end
                s = strjoin(parts,", ");
            end
        else
            s = "<" + string(class(v)) + ">";
        end
    catch
        s = "<unprintable>";
    end
end

function s = safe_string(x)
    if isempty(x)
        s = "";
    else
        s = string(x);
    end
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