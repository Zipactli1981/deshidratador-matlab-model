function post = postprocess_seed_replications_v96z_minrep_post()
% POSTPROCESS_SEED_REPLICATIONS_v96z_minrep_post
% 9.6z-minrep-post — POSTPROCESS-SEED-REPLICATIONS-001
%
% Objetivo:
%   Postprocesar las tres réplicas seed-controlled del AG triobjetivo.
%
% Este script:
%   - NO ejecuta GA.
%   - NO llama modelo.
%   - NO llama función objetivo.
%   - NO recalcula resultados.
%   - Lee los .mat de R1-R3.
%   - Audita reproducibilidad, independencia aparente y solución tipo H2.
%
% Uso:
%   post = postprocess_seed_replications_v96z_minrep_post();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    articleRunsDir = fullfile(articleRoot,'runs');
    articleTraceDir = fullfile(articleRoot,'traceability');
    articleTablesDir = fullfile(articleRoot,'tables');
    articleReviewDir = fullfile(articleRoot,'review');
    articleSectionsDir = fullfile(articleRoot,'sections');

    mkdir_if_needed(articleTraceDir);
    mkdir_if_needed(articleTablesDir);
    mkdir_if_needed(articleReviewDir);
    mkdir_if_needed(articleSectionsDir);

    % ---------------------------------------------------------------------
    % Localizar corrida MINREP más reciente
    % ---------------------------------------------------------------------
    runDir = find_latest_minrep_run_dir(articleRunsDir);

    if strlength(runDir) == 0
        error('No se encontró carpeta MINREP_SEED_CONTROLLED_RUN_v96z_* en: %s', articleRunsDir);
    end

    runMat = fullfile(runDir,'MINREP_SEED_CONTROLLED_RUN_v96z.mat');

    if ~isfile(runMat)
        error('No existe runMat: %s', runMat);
    end

    R = load(runMat);

    if ~strcmp(string(R.diagnosis),"SEED_CONTROLLED_MINREP_EXECUTION_PASS")
        error('La ejecución minrep no está en PASS. Diagnosis: %s', string(R.diagnosis));
    end

    Treplicates = R.Treplicates;

    % ---------------------------------------------------------------------
    % Cargar salidas de cada réplica
    % ---------------------------------------------------------------------
    nRep = height(Treplicates);

    RepSummary = table();
    RepSummary.replicate_id = strings(nRep,1);
    RepSummary.seed = NaN(nRep,1);
    RepSummary.run_status = strings(nRep,1);
    RepSummary.diagnosis = strings(nRep,1);
    RepSummary.runtime_h_runner = NaN(nRep,1);
    RepSummary.runtime_h_formal = NaN(nRep,1);
    RepSummary.exitflag = NaN(nRep,1);
    RepSummary.nSolutions = NaN(nRep,1);
    RepSummary.nFiniteRows = NaN(nRep,1);
    RepSummary.nPenaltyRows = NaN(nRep,1);
    RepSummary.minMR = NaN(nRep,1);
    RepSummary.minCost = NaN(nRep,1);
    RepSummary.minCO2 = NaN(nRep,1);
    RepSummary.has_admissible_MR = false(nRep,1);
    RepSummary.best_compromise_index = NaN(nRep,1);
    RepSummary.best_compromise_MR = NaN(nRep,1);
    RepSummary.best_compromise_cost = NaN(nRep,1);
    RepSummary.best_compromise_CO2 = NaN(nRep,1);
    RepSummary.best_compromise_score = NaN(nRep,1);
    RepSummary.H2_like = false(nRep,1);
    RepSummary.output_mat = strings(nRep,1);

    allX = cell(nRep,1);
    allF = cell(nRep,1);
    allFormal = cell(nRep,1);
    rngBeforeSeed = NaN(nRep,1);
    rngAfterSeed = NaN(nRep,1);

    for i = 1:nRep
        repID = string(Treplicates.replicate_id(i));
        outMat = string(Treplicates.output_mat(i));

        if ~isfile(outMat)
            error('No existe output_mat para %s: %s', repID, outMat);
        end

        S = load(outMat);

        if ~isfield(S,'formal')
            error('El archivo %s no contiene variable formal.', outMat);
        end

        formal = S.formal;
        allFormal{i} = formal;

        [X,F] = extract_XF_from_formal(formal);

        allX{i} = X;
        allF{i} = F;

        RepSummary.replicate_id(i) = repID;
        RepSummary.seed(i) = Treplicates.seed(i);
        RepSummary.run_status(i) = string(Treplicates.run_status(i));
        RepSummary.diagnosis(i) = string(Treplicates.diagnosis(i));
        RepSummary.runtime_h_runner(i) = Treplicates.actual_runtime_h(i);
        RepSummary.output_mat(i) = outMat;

        if isstruct(formal) && isfield(formal,'runSummary')
            rs = formal.runSummary;
            RepSummary.runtime_h_formal(i) = safe_table_value(rs,'runtime_h',1,NaN);
            RepSummary.exitflag(i) = safe_table_value(rs,'exitflag',1,NaN);
            RepSummary.nSolutions(i) = safe_table_value(rs,'nSolutions',1,NaN);
            RepSummary.nFiniteRows(i) = safe_table_value(rs,'nFiniteRows',1,NaN);
            RepSummary.nPenaltyRows(i) = safe_table_value(rs,'nPenaltyRows',1,NaN);
            RepSummary.minMR(i) = safe_table_value(rs,'minMR',1,NaN);
            RepSummary.minCost(i) = safe_table_value(rs,'minCost',1,NaN);
            RepSummary.minCO2(i) = safe_table_value(rs,'minCO2',1,NaN);
        else
            if ~isempty(F)
                finiteRows = all(isfinite(F),2);
                Ff = F(finiteRows,:);
                RepSummary.nSolutions(i) = size(F,1);
                RepSummary.nFiniteRows(i) = size(Ff,1);
                RepSummary.nPenaltyRows(i) = sum(~finiteRows | F(:,1)>=1000 | F(:,2)>=1e6 | F(:,3)>=1e6);
                if ~isempty(Ff)
                    RepSummary.minMR(i) = min(Ff(:,1));
                    RepSummary.minCost(i) = min(Ff(:,2));
                    RepSummary.minCO2(i) = min(Ff(:,3));
                end
            end
        end

        if isstruct(S) && isfield(S,'RngBefore') && numel(S.RngBefore) >= i && ~isempty(S.RngBefore{i})
            try
                rngBeforeSeed(i) = S.RngBefore{i}.Seed;
            catch
                rngBeforeSeed(i) = NaN;
            end
        end

        if isstruct(S) && isfield(S,'RngAfter') && numel(S.RngAfter) >= i && ~isempty(S.RngAfter{i})
            try
                rngAfterSeed(i) = S.RngAfter{i}.Seed;
            catch
                rngAfterSeed(i) = NaN;
            end
        end

        [bestIdx,bestScore,H2like] = select_H2_like_solution(F);

        RepSummary.has_admissible_MR(i) = any(F(:,1) < 0.1 & all(isfinite(F),2));

        if ~isnan(bestIdx)
            RepSummary.best_compromise_index(i) = bestIdx;
            RepSummary.best_compromise_MR(i) = F(bestIdx,1);
            RepSummary.best_compromise_cost(i) = F(bestIdx,2);
            RepSummary.best_compromise_CO2(i) = F(bestIdx,3);
            RepSummary.best_compromise_score(i) = bestScore;
            RepSummary.H2_like(i) = H2like;
        end
    end

    % ---------------------------------------------------------------------
    % Comparar frentes
    % ---------------------------------------------------------------------
    Pairwise = table();
    pairRows = {};
    p = 0;

    for i = 1:nRep
        for j = i+1:nRep
            p = p + 1;
            Fi = allF{i};
            Fj = allF{j};
            Xi = allX{i};
            Xj = allX{j};

            fIdentical = isequaln(round(Fi,12),round(Fj,12));
            xIdentical = isequaln(round(Xi,12),round(Xj,12));

            maxAbsFDiff = NaN;
            maxAbsXDiff = NaN;

            if isequal(size(Fi),size(Fj))
                maxAbsFDiff = max(abs(Fi(:)-Fj(:)),[],'omitnan');
            end

            if isequal(size(Xi),size(Xj))
                maxAbsXDiff = max(abs(Xi(:)-Xj(:)),[],'omitnan');
            end

            row = struct();
            row.pair = string(sprintf('%s_vs_%s',RepSummary.replicate_id(i),RepSummary.replicate_id(j)));
            row.F_identical_12digits = fIdentical;
            row.X_identical_12digits = xIdentical;
            row.maxAbsFDiff = maxAbsFDiff;
            row.maxAbsXDiff = maxAbsXDiff;
            row.same_size_F = isequal(size(Fi),size(Fj));
            row.same_size_X = isequal(size(Xi),size(Xj));
            pairRows{p,1} = row; %#ok<AGROW>
        end
    end

    Pairwise = struct2table(vertcat(pairRows{:}));

    all_F_identical = all(Pairwise.F_identical_12digits);
    all_X_identical = all(Pairwise.X_identical_12digits);
    at_least_some_variation = ~(all_F_identical && all_X_identical);

    % ---------------------------------------------------------------------
    % Criterios de aceptación
    % ---------------------------------------------------------------------
    nOK = sum(RepSummary.run_status == "OK");
    nAdmissible = sum(RepSummary.has_admissible_MR);
    nH2like = sum(RepSummary.H2_like);

    C = table();
    C.id = ["C1";"C2";"C3";"C4";"C5";"C6";"C7";"C8";"C9"];
    C.criterion = [ ...
        "All replicates completed without error"; ...
        "All replicates produced finite rows"; ...
        "Each replicate has at least one MR-admissible solution"; ...
        "H2-like solution appears in at least 2 of 3 replicates"; ...
        "H2-like solution reduces cost vs gasLP"; ...
        "H2-like solution reduces CO2 vs gasLP"; ...
        "H2-like solution satisfies MR < 0.1"; ...
        "Do not claim global optimum"; ...
        "Seed independence not contradicted by identical fronts"];
    C.pass = false(height(C),1);
    C.evidence = strings(height(C),1);

    C.pass(1) = nOK == nRep;
    C.evidence(1) = sprintf('OK=%d/%d',nOK,nRep);

    C.pass(2) = all(RepSummary.nFiniteRows > 0);
    C.evidence(2) = sprintf('min nFiniteRows=%g',min(RepSummary.nFiniteRows));

    C.pass(3) = nAdmissible == nRep;
    C.evidence(3) = sprintf('admissible=%d/%d',nAdmissible,nRep);

    C.pass(4) = nH2like >= 2;
    C.evidence(4) = sprintf('H2_like=%d/%d',nH2like,nRep);

    C.pass(5) = all(RepSummary.best_compromise_cost(RepSummary.H2_like) < 0.37788);
    C.evidence(5) = sprintf('cost values: %s',join(string(RepSummary.best_compromise_cost'),', '));

    C.pass(6) = all(RepSummary.best_compromise_CO2(RepSummary.H2_like) < 1.681);
    C.evidence(6) = sprintf('CO2 values: %s',join(string(RepSummary.best_compromise_CO2'),', '));

    C.pass(7) = all(RepSummary.best_compromise_MR(RepSummary.H2_like) < 0.1);
    C.evidence(7) = sprintf('MR values: %s',join(string(RepSummary.best_compromise_MR'),', '));

    C.pass(8) = true;
    C.evidence(8) = 'Global optimum claim remains blocked.';

    C.pass(9) = at_least_some_variation;
    if at_least_some_variation
        C.evidence(9) = 'Replicate fronts differ at rounded numerical comparison.';
    else
        C.evidence(9) = 'Replicate fronts are identical at rounded numerical comparison; base runner likely resets RNG internally.';
    end

    % ---------------------------------------------------------------------
    % Dictamen
    % ---------------------------------------------------------------------
    core_pass = all(C.pass(1:8));
    independence_pass = C.pass(9);

    if core_pass && independence_pass
        diagnosis = "MINREP_POSTPROCESS_PASS";
        decision = "SEED_REPLICATION_SUPPORTS_Q1_RESULTS";
        robustness_statement = "H2-like compromise behavior was reproduced across independent seed-controlled runs.";
        next_step = "9.6z-co2ref — FIX-DEFINITIVE-CO2-FACTORS-AND-REFERENCES-001";
    elseif core_pass && ~independence_pass
        diagnosis = "MINREP_POSTPROCESS_PASS_WITH_RNG_INDEPENDENCE_WARNING";
        decision = "H2_LIKE_RESULT_REPRODUCED_BUT_SEED_INDEPENDENCE_NOT_DEMONSTRATED";
        robustness_statement = "The H2-like result is reproducible under repeated executions, but independent seed influence is not demonstrated because the fronts appear identical.";
        next_step = "9.6z-rngfix — AUDIT-AND-FIX-INTERNAL-RNG-RESET-IN-v96m-001";
    else
        diagnosis = "MINREP_POSTPROCESS_REQUIRES_REVIEW";
        decision = "MINREP_DOES_NOT_YET_SUPPORT_Q1_RESULTS";
        robustness_statement = "The seed replication criteria were not fully satisfied.";
        next_step = "Review failed criteria before article claims.";
    end

    % ---------------------------------------------------------------------
    % Exportar tablas
    % ---------------------------------------------------------------------
    repCsv = fullfile(articleTablesDir,'minrep_post_replicate_summary_v96z.csv');
    pairCsv = fullfile(articleTablesDir,'minrep_post_pairwise_front_comparison_v96z.csv');
    criteriaCsv = fullfile(articleTablesDir,'minrep_post_acceptance_criteria_v96z.csv');

    writetable(RepSummary,repCsv);
    writetable(Pairwise,pairCsv);
    writetable(C,criteriaCsv);

    % ---------------------------------------------------------------------
    % Reporte
    % ---------------------------------------------------------------------
    reportText = compose_post_report( ...
        runDir,RepSummary,Pairwise,C,diagnosis,decision,robustness_statement,next_step);

    reportMd = fullfile(articleReviewDir,'MINREP_POSTPROCESS_SEED_REPLICATIONS_v96z.md');
    reportTxt = fullfile(articleReviewDir,'MINREP_POSTPROCESS_SEED_REPLICATIONS_v96z.txt');

    fid = fopen(reportMd,'w');
    if fid < 0
        error('No se pudo crear reportMd: %s', reportMd);
    end
    fprintf(fid,'%s',reportText);
    fclose(fid);

    fid = fopen(reportTxt,'w');
    if fid < 0
        error('No se pudo crear reportTxt: %s', reportTxt);
    end
    fprintf(fid,'%s',reportText);
    fclose(fid);

    articleText = compose_article_claim_text(diagnosis,decision,robustness_statement);

    articleTextMd = fullfile(articleSectionsDir,'01_seed_replication_robustness_statement_v96z.md');

    fid = fopen(articleTextMd,'w');
    if fid < 0
        error('No se pudo crear articleTextMd: %s', articleTextMd);
    end
    fprintf(fid,'%s',articleText);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Checks finales
    % ---------------------------------------------------------------------
    checks = {};
    checks{end+1,1} = check_row("POST01","Minrep execution loaded",true,string(runMat));
    checks{end+1,1} = check_row("POST02","Minrep execution PASS",strcmp(string(R.diagnosis),"SEED_CONTROLLED_MINREP_EXECUTION_PASS"),string(R.diagnosis));
    checks{end+1,1} = check_row("POST03","Three outputs loaded",nRep==3,sprintf("nRep=%d",nRep));
    checks{end+1,1} = check_row("POST04","All replicates OK",nOK==3,sprintf("OK=%d/3",nOK));
    checks{end+1,1} = check_row("POST05","All finite fronts",all(RepSummary.nFiniteRows>0),sprintf("minFinite=%g",min(RepSummary.nFiniteRows)));
    checks{end+1,1} = check_row("POST06","At least 2 H2-like",nH2like>=2,sprintf("H2_like=%d/3",nH2like));
    checks{end+1,1} = check_row("POST07","Pairwise comparison created",height(Pairwise)==3,sprintf("pairs=%d",height(Pairwise)));
    checks{end+1,1} = check_row("POST08","Independence warning assessed",true,sprintf("at_least_some_variation=%d",at_least_some_variation));
    checks{end+1,1} = check_row("POST09","Report created",isfile(reportMd),string(reportMd));
    checks{end+1,1} = check_row("POST10","Article text created",isfile(articleTextMd),string(articleTextMd));
    checks{end+1,1} = check_row("POST11","No GA executed",true,"No gamultiobj call.");
    checks{end+1,1} = check_row("POST12","No model executed",true,"No objective/model call.");

    Tchecks = struct2table(vertcat(checks{:}));

    checksCsv = fullfile(articleTablesDir,'minrep_post_checks_v96z.csv');
    writetable(Tchecks,checksCsv);

    % ---------------------------------------------------------------------
    % Guardar MAT
    % ---------------------------------------------------------------------
    postMat = fullfile(articleTraceDir,'MINREP_POSTPROCESS_SEED_REPLICATIONS_v96z.mat');

    save(postMat, ...
        'diagnosis','decision','next_step','robustness_statement', ...
        'rootDir','articleRoot','runDir','runMat', ...
        'Treplicates','RepSummary','Pairwise','C','Tchecks', ...
        'allX','allF','allFormal','rngBeforeSeed','rngAfterSeed', ...
        'nOK','nAdmissible','nH2like','all_F_identical','all_X_identical','at_least_some_variation', ...
        'repCsv','pairCsv','criteriaCsv','checksCsv','reportMd','reportTxt','articleTextMd','postMat');

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    post = struct();
    post.status = 'MINREP_POSTPROCESS_SEED_REPLICATIONS_COMPLETED';
    post.diagnosis = diagnosis;
    post.decision = decision;
    post.next_step = next_step;
    post.robustness_statement = robustness_statement;

    post.runDir = runDir;
    post.RepSummary = RepSummary;
    post.Pairwise = Pairwise;
    post.Criteria = C;
    post.Tchecks = Tchecks;

    post.nH2like = nH2like;
    post.at_least_some_variation = at_least_some_variation;
    post.all_F_identical = all_F_identical;
    post.all_X_identical = all_X_identical;

    post.reportMd = reportMd;
    post.articleTextMd = articleTextMd;
    post.postMat = postMat;

    disp('=== MINREP_POSTPROCESS_SEED_REPLICATIONS_v96z ===')
    disp(post.status)
    disp('=== DIAGNOSIS ===')
    disp(post.diagnosis)
    disp('=== DECISION ===')
    disp(post.decision)
    disp('=== NEXT STEP ===')
    disp(post.next_step)
    disp('=== ROBUSTNESS STATEMENT ===')
    disp(post.robustness_statement)
    disp('=== RUN DIR ===')
    disp(post.runDir)
    disp('=== REPLICATE SUMMARY ===')
    disp(post.RepSummary)
    disp('=== PAIRWISE FRONT COMPARISON ===')
    disp(post.Pairwise)
    disp('=== ACCEPTANCE CRITERIA ===')
    disp(post.Criteria)
    disp('=== CHECKS ===')
    disp(post.Tchecks)
    disp('=== REPORT MD ===')
    disp(post.reportMd)
    disp('=== ARTICLE TEXT MD ===')
    disp(post.articleTextMd)

end

% =========================================================================
% Helpers de extracción
% =========================================================================

function [X,F] = extract_XF_from_formal(formal)
    X = [];
    F = [];

    % Formato real v96m:
    % formal.Tsolutions contiene:
    %   m_max, T_min, r_div2, t_rec_ini, MR,
    %   cost_specific_USD_per_kgwater, CO2_specific_kgCO2_per_kgwater

    if isstruct(formal) && isfield(formal,'Tsolutions') && istable(formal.Tsolutions)
        T = formal.Tsolutions;

        reqX = {'m_max','T_min','r_div2','t_rec_ini'};
        reqF = {'MR','cost_specific_USD_per_kgwater','CO2_specific_kgCO2_per_kgwater'};

        hasX = all(ismember(reqX,T.Properties.VariableNames));
        hasF = all(ismember(reqF,T.Properties.VariableNames));

        if hasX
            X = [T.m_max, T.T_min, T.r_div2, T.t_rec_ini];
        end

        if hasF
            F = [T.MR, T.cost_specific_USD_per_kgwater, T.CO2_specific_kgCO2_per_kgwater];
        end

        if ~isempty(F)
            return
        end
    end

    % Respaldo: campos directos si existieran en otra versión.
    candidateX = ["X","x","population","Xformal","Xout","xPareto","Xpareto"];
    candidateF = ["F","fval","Fformal","Fout","scores","fPareto","Fpareto"];

    for k = 1:numel(candidateX)
        name = candidateX(k);
        if isstruct(formal) && isfield(formal,name)
            X = formal.(name);
            break
        end
    end

    for k = 1:numel(candidateF)
        name = candidateF(k);
        if isstruct(formal) && isfield(formal,name)
            F = formal.(name);
            break
        end
    end

    if istable(F)
        F = table2array(F(:,vartype('numeric')));
    end

    if istable(X)
        X = table2array(X(:,vartype('numeric')));
    end

    if isempty(F)
        error('No se pudo extraer F. Se esperaba formal.Tsolutions con columnas MR, cost_specific_USD_per_kgwater y CO2_specific_kgCO2_per_kgwater.');
    end

    if size(F,2) ~= 3 && size(F,1) == 3
        F = F.';
    end

    if size(F,2) ~= 3
        error('F extraída no tiene 3 columnas. size(F)=[%d %d]',size(F,1),size(F,2));
    end

    if isempty(X)
        X = NaN(size(F,1),4);
    end

    if size(X,2) ~= 4 && size(X,1) == 4
        X = X.';
    end

    if size(X,1) ~= size(F,1)
        X = NaN(size(F,1),4);
    end
end

function val = safe_table_value(T,varName,rowIdx,defaultVal)
    val = defaultVal;

    try
        if istable(T) && any(strcmp(T.Properties.VariableNames,varName))
            tmp = T.(varName);
            if numel(tmp) >= rowIdx
                val = tmp(rowIdx);
            end
        end
    catch
        val = defaultVal;
    end
end

function runDir = find_latest_minrep_run_dir(articleRunsDir)
    runDir = "";

    if ~isfolder(articleRunsDir)
        return
    end

    d = dir(fullfile(articleRunsDir,'MINREP_SEED_CONTROLLED_RUN_v96z_*'));
    d = d([d.isdir]);

    if isempty(d)
        return
    end

    [~,idx] = sort([d.datenum],'descend');
    d = d(idx);

    for i = 1:numel(d)
        candidate = fullfile(articleRunsDir,d(i).name);
        if isfile(fullfile(candidate,'MINREP_SEED_CONTROLLED_RUN_v96z.mat'))
            runDir = string(candidate);
            return
        end
    end
end

function report = compose_post_report(runDir,RepSummary,Pairwise,C,diagnosis,decision,robustness_statement,next_step)

    lines = strings(0,1);

    lines(end+1) = "# MINREP_POSTPROCESS_SEED_REPLICATIONS_v96z";
    lines(end+1) = "";
    lines(end+1) = "## Diagnosis";
    lines(end+1) = "";
    lines(end+1) = "`" + string(diagnosis) + "`";
    lines(end+1) = "";
    lines(end+1) = "## Decision";
    lines(end+1) = "";
    lines(end+1) = "`" + string(decision) + "`";
    lines(end+1) = "";
    lines(end+1) = "## Robustness statement";
    lines(end+1) = "";
    lines(end+1) = string(robustness_statement);
    lines(end+1) = "";
    lines(end+1) = "## Run directory";
    lines(end+1) = "";
    lines(end+1) = "`" + string(runDir) + "`";
    lines(end+1) = "";

    lines(end+1) = "## Replicate summary";
    lines(end+1) = "";
    lines(end+1) = "| Rep | Seed | Status | Runtime h | nFinite | minMR | minCost | minCO2 | H2-like |";
    lines(end+1) = "|---|---:|---|---:|---:|---:|---:|---:|---|";

    for i = 1:height(RepSummary)
        lines(end+1) = "| " + string(RepSummary.replicate_id(i)) + ...
            " | " + string(RepSummary.seed(i)) + ...
            " | " + string(RepSummary.run_status(i)) + ...
            " | " + string(sprintf('%.4f',RepSummary.runtime_h_runner(i))) + ...
            " | " + string(RepSummary.nFiniteRows(i)) + ...
            " | " + string(sprintf('%.6g',RepSummary.minMR(i))) + ...
            " | " + string(sprintf('%.6g',RepSummary.minCost(i))) + ...
            " | " + string(sprintf('%.6g',RepSummary.minCO2(i))) + ...
            " | " + string(RepSummary.H2_like(i)) + " |";
    end

    lines(end+1) = "";
    lines(end+1) = "## Pairwise comparison";
    lines(end+1) = "";
    lines(end+1) = "| Pair | F identical 12 digits | X identical 12 digits | maxAbsFDiff | maxAbsXDiff |";
    lines(end+1) = "|---|---:|---:|---:|---:|";

    for i = 1:height(Pairwise)
        lines(end+1) = "| " + string(Pairwise.pair(i)) + ...
            " | " + string(Pairwise.F_identical_12digits(i)) + ...
            " | " + string(Pairwise.X_identical_12digits(i)) + ...
            " | " + string(Pairwise.maxAbsFDiff(i)) + ...
            " | " + string(Pairwise.maxAbsXDiff(i)) + " |";
    end

    lines(end+1) = "";
    lines(end+1) = "## Acceptance criteria";
    lines(end+1) = "";
    lines(end+1) = "| ID | Criterion | Pass | Evidence |";
    lines(end+1) = "|---|---|---:|---|";

    for i = 1:height(C)
        lines(end+1) = "| " + string(C.id(i)) + " | " + string(C.criterion(i)) + " | " + string(C.pass(i)) + " | " + string(C.evidence(i)) + " |";
    end

    lines(end+1) = "";
    lines(end+1) = "## Next step";
    lines(end+1) = "";
    lines(end+1) = "`" + string(next_step) + "`";
    lines(end+1) = "";

    report = strjoin(lines,newline);
end

function txt = compose_article_claim_text(diagnosis,decision,robustness_statement)

    lines = strings(0,1);

    lines(end+1) = "# Seed-replication robustness statement for article";
    lines(end+1) = "";
    lines(end+1) = "Diagnosis: `" + string(diagnosis) + "`";
    lines(end+1) = "";
    lines(end+1) = "Decision: `" + string(decision) + "`";
    lines(end+1) = "";
    lines(end+1) = "Statement:";
    lines(end+1) = "";
    lines(end+1) = string(robustness_statement);
    lines(end+1) = "";
    lines(end+1) = "Caveat:";
    lines(end+1) = "";
    lines(end+1) = "The result must still be formulated as a robust compromise solution within the computed fronts, not as a proof of global optimality. Final CO2 claims remain dependent on definitive emission factors and references.";
    lines(end+1) = "";

    txt = strjoin(lines,newline);
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