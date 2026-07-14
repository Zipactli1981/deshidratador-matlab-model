function smoke = run_seedaware_smoke_seed_difference_v96z_rngfix(confirm_execute)
% RUN_SEEDAWARE_SMOKE_SEED_DIFFERENCE_v96z_rngfix
%
% Smoke seed-aware con dos semillas.
%
% Objetivo:
%   Verificar si el clon seed-aware realmente produce frentes distintos
%   cuando cambia la semilla.
%
% Este smoke:
%   - Usa una copia temporal del clon seed-aware.
%   - Reduce PopulationSize y MaxGenerations.
%   - Ejecuta solo si confirm_execute=true.
%   - NO modifica v96m original.
%   - NO modifica el clon seed-aware formal.
%
% Uso:
%   smoke = run_seedaware_smoke_seed_difference_v96z_rngfix(false);  % solo preparar
%   smoke = run_seedaware_smoke_seed_difference_v96z_rngfix(true);   % ejecutar smoke

    if nargin < 1 || isempty(confirm_execute)
        confirm_execute = false;
    end

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    productionDir = fullfile(rootDir,'02_src_limpio','production');
    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    runsRoot = fullfile(articleRoot,'runs');
    traceDir = fullfile(articleRoot,'traceability');
    reviewDir = fullfile(articleRoot,'review');
    tablesDir = fullfile(articleRoot,'tables');

    mkdir_if_needed(runsRoot);
    mkdir_if_needed(traceDir);
    mkdir_if_needed(reviewDir);
    mkdir_if_needed(tablesDir);

    formalCloneName = 'run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix';
    formalClonePath = fullfile(productionDir,[formalCloneName '.m']);

    smokeCloneName = 'v96z_rngfix_smoke';
    smokeClonePath = fullfile(productionDir,[smokeCloneName '.m']);

    if ~isfile(formalClonePath)
        error('No existe formalClonePath: %s', formalClonePath);
    end

    seeds = [61001; 61002];
    repIDs = ["S1"; "S2"];

    smokePop = 8;
    smokeGen = 5;

    timestamp = datestr(now,'yyyymmdd_HHMMSS');
    runDir = fullfile(runsRoot,['SEEDAWARE_SMOKE_SEED_DIFF_v96z_rngfix_' timestamp]);
    mkdir(runDir);

    % ---------------------------------------------------------------------
    % Crear clon SMOKE desde el clon seed-aware formal
    % ---------------------------------------------------------------------
    src = string(fileread(formalClonePath));

    src = replace(src, ...
        "function formal = run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix(confirm_execute, rngSeed)", ...
        "function formal = v96z_rngfix_smoke(confirm_execute, rngSeed)");

    src = replace(src, ...
        "TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix", ...
        "TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix_SMOKE");

    % Reemplazos prudentes de parámetros formales.
    % Si no encuentra estos textos exactos, el check fallará.
    src2 = src;
    src2 = replace(src2, "popSize = 24;", "popSize = 8;");
    src2 = replace(src2, "maxGen = 50;", "maxGen = 5;");

    fid = fopen(smokeClonePath,'w');
    if fid < 0
        error('No se pudo escribir smokeClonePath: %s', smokeClonePath);
    end
    fprintf(fid,'%s',src2);
    fclose(fid);

    rehash;

    smokeTxt = string(fileread(smokeClonePath));

    hasPop8 = contains(smokeTxt,"popSize = 8;");
    hasGen5 = contains(smokeTxt,"maxGen = 5;");
    hasSeedArg = contains(smokeTxt,"confirm_execute, rngSeed");
    hasExternalSeed = contains(smokeTxt,"EXTERNAL_SEED_APPLIED");
    hasGamultiobj = contains(smokeTxt,"gamultiobj");

    % ---------------------------------------------------------------------
    % Tabla de réplicas smoke
    % ---------------------------------------------------------------------
    Tsmoke = table();
    Tsmoke.replicate_id = repIDs;
    Tsmoke.seed = seeds;
    Tsmoke.populationSize = repmat(smokePop,2,1);
    Tsmoke.maxGenerations = repmat(smokeGen,2,1);
    Tsmoke.confirm_execute = repmat(confirm_execute,2,1);
    Tsmoke.run_status = repmat("NOT_EXECUTED",2,1);
    Tsmoke.rngControl = strings(2,1);
    Tsmoke.runtime_s = NaN(2,1);
    Tsmoke.runtime_h = NaN(2,1);
    Tsmoke.nSolutions = NaN(2,1);
    Tsmoke.nFiniteRows = NaN(2,1);
    Tsmoke.minMR = NaN(2,1);
    Tsmoke.minCost = NaN(2,1);
    Tsmoke.minCO2 = NaN(2,1);
    Tsmoke.output_mat = strings(2,1);
    Tsmoke.error_message = strings(2,1);

    allX = cell(2,1);
    allF = cell(2,1);
    allFormal = cell(2,1);

    % ---------------------------------------------------------------------
    % Ejecución smoke
    % ---------------------------------------------------------------------
    if confirm_execute
        for i = 1:2
            repID = repIDs(i);
            seed = seeds(i);
            repDir = fullfile(runDir,repID);
            mkdir(repDir);

            fprintf('\n=== STARTING SEEDAWARE SMOKE %s | seed=%d | pop=%d | gen=%d ===\n', ...
                repID, seed, smokePop, smokeGen);

            try
                tRep = tic;
                formal = v96z_rngfix_smoke(true, seed);
                elapsed = toc(tRep);

                allFormal{i} = formal;

                [X,F] = extract_XF_from_formal_Tsolutions(formal);
                allX{i} = X;
                allF{i} = F;

                outMat = fullfile(repDir,sprintf('SEEDAWARE_SMOKE_%s_seed_%d_output.mat',repID,seed));
                save(outMat,'formal','X','F','repID','seed','elapsed');

                Tsmoke.run_status(i) = string(formal.formalFlags.run_status);
                Tsmoke.runtime_s(i) = elapsed;
                Tsmoke.runtime_h(i) = elapsed/3600;
                Tsmoke.nSolutions(i) = size(F,1);
                Tsmoke.nFiniteRows(i) = sum(all(isfinite(F),2));
                Tsmoke.minMR(i) = min(F(:,1),[],'omitnan');
                Tsmoke.minCost(i) = min(F(:,2),[],'omitnan');
                Tsmoke.minCO2(i) = min(F(:,3),[],'omitnan');
                Tsmoke.output_mat(i) = string(outMat);

                if isfield(formal,'rngControl_v96z')
                    Tsmoke.rngControl(i) = string(formal.rngControl_v96z);
                end

            catch ME
                Tsmoke.run_status(i) = "ERROR";
                Tsmoke.error_message(i) = string(ME.message);
                warning('Smoke %s failed: %s',repID,ME.message);
            end
        end
    end

    % ---------------------------------------------------------------------
    % Comparación de frentes
    % ---------------------------------------------------------------------
    Pairwise = table();
    if confirm_execute && ~isempty(allF{1}) && ~isempty(allF{2})
        F1 = allF{1};
        F2 = allF{2};
        X1 = allX{1};
        X2 = allX{2};

        Pairwise.pair = "S1_vs_S2";
        Pairwise.same_size_F = isequal(size(F1),size(F2));
        Pairwise.same_size_X = isequal(size(X1),size(X2));

        if Pairwise.same_size_F
            Pairwise.F_identical_12digits = isequaln(round(F1,12),round(F2,12));
            Pairwise.maxAbsFDiff = max(abs(F1(:)-F2(:)),[],'omitnan');
        else
            Pairwise.F_identical_12digits = false;
            Pairwise.maxAbsFDiff = NaN;
        end

        if Pairwise.same_size_X
            Pairwise.X_identical_12digits = isequaln(round(X1,12),round(X2,12));
            Pairwise.maxAbsXDiff = max(abs(X1(:)-X2(:)),[],'omitnan');
        else
            Pairwise.X_identical_12digits = false;
            Pairwise.maxAbsXDiff = NaN;
        end
    else
        Pairwise.pair = "S1_vs_S2";
        Pairwise.same_size_F = false;
        Pairwise.same_size_X = false;
        Pairwise.F_identical_12digits = false;
        Pairwise.X_identical_12digits = false;
        Pairwise.maxAbsFDiff = NaN;
        Pairwise.maxAbsXDiff = NaN;
    end

    % ---------------------------------------------------------------------
    % Checks y dictamen
    % ---------------------------------------------------------------------
    checks = {};
    checks{end+1,1} = check_row("SMK01","Formal seed-aware clone exists",isfile(formalClonePath),string(formalClonePath));
    checks{end+1,1} = check_row("SMK02","Smoke clone created",isfile(smokeClonePath),string(smokeClonePath));
    checks{end+1,1} = check_row("SMK03","Smoke population reduced",hasPop8,"popSize = 8");
    checks{end+1,1} = check_row("SMK04","Smoke generations reduced",hasGen5,"maxGen = 5");
    checks{end+1,1} = check_row("SMK05","Seed-aware argument present",hasSeedArg,"rngSeed argument present");
    checks{end+1,1} = check_row("SMK06","External seed branch present",hasExternalSeed,"EXTERNAL_SEED_APPLIED");
    checks{end+1,1} = check_row("SMK07","gamultiobj preserved",hasGamultiobj,"gamultiobj exists in smoke clone");
    checks{end+1,1} = check_row("SMK08","Execution explicitly controlled",true,sprintf("confirm_execute=%d",confirm_execute));

    if confirm_execute
        checks{end+1,1} = check_row("SMK09","Both smoke runs OK",all(Tsmoke.run_status=="OK"),sprintf("statuses=%s,%s",Tsmoke.run_status(1),Tsmoke.run_status(2)));
        checks{end+1,1} = check_row("SMK10","Both smoke runs used external seed",all(Tsmoke.rngControl=="EXTERNAL_SEED_APPLIED"),sprintf("rng=%s,%s",Tsmoke.rngControl(1),Tsmoke.rngControl(2)));
        checks{end+1,1} = check_row("SMK11","Smoke fronts compared",height(Pairwise)==1,"S1_vs_S2");
        checks{end+1,1} = check_row("SMK12","Smoke fronts differ",~Pairwise.F_identical_12digits || ~Pairwise.X_identical_12digits, ...
            sprintf("F_identical=%d; X_identical=%d",Pairwise.F_identical_12digits,Pairwise.X_identical_12digits));
    else
        checks{end+1,1} = check_row("SMK09","No smoke GA executed",true,"confirm_execute=false");
    end

    checks{end+1,1} = check_row("SMK13","Original v96m not modified",true,"Only smoke clone created.");
    checks{end+1,1} = check_row("SMK14","Formal seed-aware clone not modified",true,"Smoke clone is separate.");

    Tchecks = struct2table(vertcat(checks{:}));

    if ~confirm_execute
        diagnosis = "SEEDAWARE_SMOKE_READY_NO_EXECUTION";
        decision = "RUN_WITH_TRUE_TO_TEST_SEED_DIFFERENCE";
        next_step = "smoke = run_seedaware_smoke_seed_difference_v96z_rngfix(true)";
    elseif all(Tsmoke.run_status=="OK") && (~Pairwise.F_identical_12digits || ~Pairwise.X_identical_12digits)
        diagnosis = "SEEDAWARE_SMOKE_PASS_SEEDS_PRODUCE_DIFFERENT_FRONTS";
        decision = "RNGFIX_VALIDATED_FOR_SEED_DIFFERENCE";
        next_step = "Decide whether to run formal seed-aware R1/R2/R3.";
    elseif all(Tsmoke.run_status=="OK") && Pairwise.F_identical_12digits && Pairwise.X_identical_12digits
        diagnosis = "SEEDAWARE_SMOKE_WARNING_FRONTS_STILL_IDENTICAL";
        decision = "DO_NOT_RUN_LONG_FORMAL_REPLICATIONS";
        next_step = "Audit remaining deterministic controls before any long run.";
    else
        diagnosis = "SEEDAWARE_SMOKE_REQUIRES_REVIEW";
        decision = "DO_NOT_RUN_LONG_FORMAL_REPLICATIONS";
        next_step = "Inspect smoke errors.";
    end

    % ---------------------------------------------------------------------
    % Guardar salidas
    % ---------------------------------------------------------------------
    smokeCsv = fullfile(tablesDir,'seedaware_smoke_seed_difference_v96z_rngfix_Tsmoke.csv');
    pairCsv = fullfile(tablesDir,'seedaware_smoke_seed_difference_v96z_rngfix_pairwise.csv');
    checksCsv = fullfile(tablesDir,'seedaware_smoke_seed_difference_v96z_rngfix_checks.csv');

    writetable(Tsmoke,smokeCsv);
    writetable(Pairwise,pairCsv);
    writetable(Tchecks,checksCsv);

    reportMd = fullfile(reviewDir,'SEEDAWARE_SMOKE_SEED_DIFFERENCE_v96z_rngfix.md');

    fid = fopen(reportMd,'w');
    fprintf(fid,'# SEEDAWARE_SMOKE_SEED_DIFFERENCE_v96z_rngfix\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Smoke parameters\n\n');
    fprintf(fid,'- PopulationSize: `%d`\n',smokePop);
    fprintf(fid,'- MaxGenerations: `%d`\n',smokeGen);
    fprintf(fid,'- Seeds: `61001, 61002`\n\n');

    fprintf(fid,'## Pairwise comparison\n\n');
    fprintf(fid,'| pair | F identical | X identical | maxAbsFDiff | maxAbsXDiff |\n');
    fprintf(fid,'|---|---:|---:|---:|---:|\n');
    fprintf(fid,'| %s | %d | %d | %g | %g |\n', ...
        Pairwise.pair(1), Pairwise.F_identical_12digits(1), Pairwise.X_identical_12digits(1), ...
        Pairwise.maxAbsFDiff(1), Pairwise.maxAbsXDiff(1));

    fprintf(fid,'\n## Smoke summary\n\n');
    fprintf(fid,'| rep | seed | status | rngControl | nSolutions | minMR | minCost | minCO2 | runtime h |\n');
    fprintf(fid,'|---|---:|---|---|---:|---:|---:|---:|---:|\n');
    for i = 1:height(Tsmoke)
        fprintf(fid,'| %s | %d | %s | %s | %g | %g | %g | %g | %g |\n', ...
            Tsmoke.replicate_id(i), Tsmoke.seed(i), Tsmoke.run_status(i), Tsmoke.rngControl(i), ...
            Tsmoke.nSolutions(i), Tsmoke.minMR(i), Tsmoke.minCost(i), Tsmoke.minCO2(i), Tsmoke.runtime_h(i));
    end

    fprintf(fid,'\n## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            Tchecks.id(i), Tchecks.check(i), Tchecks.pass(i), Tchecks.evidence(i));
    end
    fclose(fid);

    outMat = fullfile(traceDir,'SEEDAWARE_SMOKE_SEED_DIFFERENCE_v96z_rngfix.mat');

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'rootDir','runDir','formalClonePath','smokeClonePath', ...
        'Tsmoke','Pairwise','Tchecks','allX','allF','allFormal', ...
        'smokeCsv','pairCsv','checksCsv','reportMd','outMat');

    smoke = struct();
    smoke.status = 'SEEDAWARE_SMOKE_SEED_DIFFERENCE_v96z_rngfix_COMPLETED';
    smoke.diagnosis = diagnosis;
    smoke.decision = decision;
    smoke.next_step = next_step;
    smoke.runDir = runDir;
    smoke.Tsmoke = Tsmoke;
    smoke.Pairwise = Pairwise;
    smoke.Tchecks = Tchecks;
    smoke.reportMd = reportMd;
    smoke.outMat = outMat;

    disp('=== SEEDAWARE_SMOKE_SEED_DIFFERENCE_v96z_rngfix ===')
    disp(smoke.status)
    disp('=== DIAGNOSIS ===')
    disp(smoke.diagnosis)
    disp('=== DECISION ===')
    disp(smoke.decision)
    disp('=== NEXT STEP ===')
    disp(smoke.next_step)
    disp('=== RUN DIR ===')
    disp(smoke.runDir)
    disp('=== SMOKE SUMMARY ===')
    disp(smoke.Tsmoke)
    disp('=== PAIRWISE ===')
    disp(smoke.Pairwise)
    disp('=== CHECKS ===')
    disp(smoke.Tchecks)
    disp('=== REPORT ===')
    disp(smoke.reportMd)

end

function [X,F] = extract_XF_from_formal_Tsolutions(formal)
    if ~isstruct(formal) || ~isfield(formal,'Tsolutions') || ~istable(formal.Tsolutions)
        error('formal.Tsolutions no existe o no es tabla.');
    end

    T = formal.Tsolutions;

    reqX = {'m_max','T_min','r_div2','t_rec_ini'};
    reqF = {'MR','cost_specific_USD_per_kgwater','CO2_specific_kgCO2_per_kgwater'};

    if ~all(ismember(reqX,T.Properties.VariableNames))
        error('Tsolutions no contiene todas las columnas X requeridas.');
    end

    if ~all(ismember(reqF,T.Properties.VariableNames))
        error('Tsolutions no contiene todas las columnas F requeridas.');
    end

    X = [T.m_max, T.T_min, T.r_div2, T.t_rec_ini];
    F = [T.MR, T.cost_specific_USD_per_kgwater, T.CO2_specific_kgCO2_per_kgwater];
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