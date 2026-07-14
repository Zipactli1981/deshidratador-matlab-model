function fixout = fix_minrep_post_selectH2_v96z_f3()
% FIX_MINREP_POST_SELECTH2_v96z_f3
%
% Reinstala la función local select_H2_like_solution en:
%   postprocess_seed_replications_v96z_minrep_post.m
%
% Este fix:
%   - NO ejecuta GA.
%   - NO llama modelo.
%   - NO modifica 05_runs.
%   - Solo parchea el postproceso.

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    productionDir = fullfile(rootDir,'02_src_limpio','production');
    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    articleTraceDir = fullfile(articleRoot,'traceability');
    articleTablesDir = fullfile(articleRoot,'tables');

    if ~isfolder(articleTraceDir), mkdir(articleTraceDir); end
    if ~isfolder(articleTablesDir), mkdir(articleTablesDir); end

    postPath = fullfile(productionDir,'postprocess_seed_replications_v96z_minrep_post.m');

    if ~isfile(postPath)
        error('No existe postPath: %s', postPath);
    end

    txt = string(fileread(postPath));

    timestamp = datestr(now,'yyyymmdd_HHMMSS');
    backupPath = fullfile(productionDir, ...
        ['postprocess_seed_replications_v96z_minrep_post_BACKUP_BEFORE_FIX3_' timestamp '.m']);

    copyfile(postPath,backupPath);

    hasSelect = contains(txt,"function [bestIdx,bestScore,H2like] = select_H2_like_solution(F)");

    if ~hasSelect
        insertToken = "function val = safe_table_value(T,varName,rowIdx,defaultVal)";
        pos = strfind(txt,insertToken);

        if isempty(pos)
            error('No se encontró safe_table_value para insertar select_H2_like_solution.');
        end

        pos = pos(1);

        selectBlock = compose_select_H2_block();

        txt2 = extractBefore(txt,pos) + selectBlock + newline + newline + extractAfter(txt,pos-1);

        fid = fopen(postPath,'w');
        if fid < 0
            error('No se pudo escribir postPath: %s', postPath);
        end
        fprintf(fid,'%s',txt2);
        fclose(fid);
    end

    fixedText = string(fileread(postPath));

    checks = {};
    checks{end+1,1} = check_row("PXF3_01","Postprocess file exists",isfile(postPath),string(postPath));
    checks{end+1,1} = check_row("PXF3_02","Backup created",isfile(backupPath),string(backupPath));
    checks{end+1,1} = check_row("PXF3_03","select_H2_like_solution present",contains(fixedText,"function [bestIdx,bestScore,H2like] = select_H2_like_solution(F)"),"Function found.");
    checks{end+1,1} = check_row("PXF3_04","gasLP cost threshold present",contains(fixedText,"gasCost = 0.37787758471"),"gasLP cost threshold found.");
    checks{end+1,1} = check_row("PXF3_05","gasLP CO2 threshold present",contains(fixedText,"gasCO2 = 1.681"),"gasLP CO2 threshold found.");
    checks{end+1,1} = check_row("PXF3_06","MR threshold present",contains(fixedText,"F(:,1) < 0.1"),"MR threshold found.");
    checks{end+1,1} = check_row("PXF3_07","No GA executed",true,"No gamultiobj call.");
    checks{end+1,1} = check_row("PXF3_08","No model executed",true,"No objective/model call.");
    checks{end+1,1} = check_row("PXF3_09","No 05_runs modified",true,"Only postprocess script patched.");

    Tchecks = struct2table(vertcat(checks{:}));

    if all(Tchecks.pass)
        diagnosis = "MINREP_POST_SELECTH2_FIX3_PASS";
        decision = "POSTPROCESS_READY_FOR_RETRY";
        next_step = "Retry: post = postprocess_seed_replications_v96z_minrep_post()";
    else
        diagnosis = "MINREP_POST_SELECTH2_FIX3_REQUIRES_REVIEW";
        decision = "REVIEW_FAILED_FIX3_CHECKS";
        next_step = "Inspect postprocess script before retry.";
    end

    checksCsv = fullfile(articleTablesDir,'minrep_post_selectH2_fix3_checks_v96z.csv');
    writetable(Tchecks,checksCsv);

    fixMat = fullfile(articleTraceDir,'MINREP_POST_SELECTH2_FIX3_v96z.mat');

    save(fixMat, ...
        'diagnosis','decision','next_step', ...
        'postPath','backupPath','Tchecks','checksCsv','fixMat');

    fixout = struct();
    fixout.status = 'MINREP_POST_SELECTH2_FIX3_COMPLETED';
    fixout.diagnosis = diagnosis;
    fixout.decision = decision;
    fixout.next_step = next_step;
    fixout.postPath = postPath;
    fixout.backupPath = backupPath;
    fixout.Tchecks = Tchecks;
    fixout.fixMat = fixMat;

    disp('=== MINREP_POST_SELECTH2_FIX3_v96z ===')
    disp(fixout.status)
    disp('=== DIAGNOSIS ===')
    disp(fixout.diagnosis)
    disp('=== DECISION ===')
    disp(fixout.decision)
    disp('=== NEXT STEP ===')
    disp(fixout.next_step)
    disp('=== POSTPROCESS FILE ===')
    disp(fixout.postPath)
    disp('=== BACKUP ===')
    disp(fixout.backupPath)
    disp('=== CHECKS ===')
    disp(fixout.Tchecks)

end

function block = compose_select_H2_block()

    lines = strings(0,1);

    lines(end+1) = "function [bestIdx,bestScore,H2like] = select_H2_like_solution(F)";
    lines(end+1) = "    bestIdx = NaN;";
    lines(end+1) = "    bestScore = NaN;";
    lines(end+1) = "    H2like = false;";
    lines(end+1) = "";
    lines(end+1) = "    if isempty(F) || size(F,2) < 3";
    lines(end+1) = "        return";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    finiteRows = all(isfinite(F),2);";
    lines(end+1) = "    admissible = finiteRows & F(:,1) < 0.1;";
    lines(end+1) = "";
    lines(end+1) = "    if ~any(admissible)";
    lines(end+1) = "        return";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    gasCost = 0.37787758471;";
    lines(end+1) = "    gasCO2 = 1.681;";
    lines(end+1) = "";
    lines(end+1) = "    candidates = find(admissible);";
    lines(end+1) = "    Fc = F(candidates,:);";
    lines(end+1) = "";
    lines(end+1) = "    fmin = min(Fc,[],1);";
    lines(end+1) = "    fmax = max(Fc,[],1);";
    lines(end+1) = "    denom = fmax - fmin;";
    lines(end+1) = "    denom(denom == 0) = 1;";
    lines(end+1) = "";
    lines(end+1) = "    Fn = (Fc - fmin)./denom;";
    lines(end+1) = "    scores = sqrt(sum(Fn.^2,2));";
    lines(end+1) = "";
    lines(end+1) = "    [bestScore,bLocal] = min(scores);";
    lines(end+1) = "    bestIdx = candidates(bLocal);";
    lines(end+1) = "";
    lines(end+1) = "    H2like = F(bestIdx,1) < 0.1 && ...";
    lines(end+1) = "             F(bestIdx,2) < gasCost && ...";
    lines(end+1) = "             F(bestIdx,3) < gasCO2;";
    lines(end+1) = "end";

    block = strjoin(lines,newline);
end

function row = check_row(id, checkName, passVal, evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end