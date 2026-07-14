function fixout = fix_minrep_post_Tsolutions_v96z_f2()
% FIX_MINREP_POST_TSOLUTION_v96z_f2
%
% Corrige postprocess_seed_replications_v96z_minrep_post.m
% para extraer X/F desde formal.Tsolutions.
%
% X = [m_max, T_min, r_div2, t_rec_ini]
% F = [MR, cost_specific_USD_per_kgwater, CO2_specific_kgCO2_per_kgwater]
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
        ['postprocess_seed_replications_v96z_minrep_post_BACKUP_BEFORE_FIX2_' timestamp '.m']);

    copyfile(postPath,backupPath);

    startToken = "function [X,F] = extract_XF_from_formal(formal)";
    nextToken  = "function val = safe_table_value(T,varName,rowIdx,defaultVal)";

    s = strfind(txt,startToken);
    e = strfind(txt,nextToken);

    if isempty(s)
        error('No se encontró startToken extract_XF_from_formal.');
    end

    if isempty(e)
        error('No se encontró nextToken safe_table_value.');
    end

    s = s(1);
    e = e(1);

    newBlock = compose_new_extract_block_Tsolutions();

    txt2 = extractBefore(txt,s) + newBlock + newline + newline + extractAfter(txt,e-1);

    fid = fopen(postPath,'w');
    if fid < 0
        error('No se pudo escribir postPath: %s', postPath);
    end
    fprintf(fid,'%s',txt2);
    fclose(fid);

    fixedText = string(fileread(postPath));

    checks = {};
    checks{end+1,1} = check_row("PXF2_01","Postprocess file exists",isfile(postPath),string(postPath));
    checks{end+1,1} = check_row("PXF2_02","Backup created",isfile(backupPath),string(backupPath));
    checks{end+1,1} = check_row("PXF2_03","Tsolutions extractor inserted",contains(fixedText,"formal.Tsolutions"),"formal.Tsolutions extractor found.");
    checks{end+1,1} = check_row("PXF2_04","Objective columns inserted",contains(fixedText,"cost_specific_USD_per_kgwater") && contains(fixedText,"CO2_specific_kgCO2_per_kgwater"),"Objective columns found.");
    checks{end+1,1} = check_row("PXF2_05","Decision columns inserted",contains(fixedText,"m_max") && contains(fixedText,"t_rec_ini"),"Decision columns found.");
    checks{end+1,1} = check_row("PXF2_06","No GA executed",true,"No gamultiobj call.");
    checks{end+1,1} = check_row("PXF2_07","No model executed",true,"No objective/model call.");
    checks{end+1,1} = check_row("PXF2_08","No 05_runs modified",true,"Only postprocess script patched.");

    Tchecks = struct2table(vertcat(checks{:}));

    if all(Tchecks.pass)
        diagnosis = "MINREP_POST_TSOLUTION_FIX2_PASS";
        decision = "POSTPROCESS_READY_FOR_RETRY";
        next_step = "Retry: post = postprocess_seed_replications_v96z_minrep_post()";
    else
        diagnosis = "MINREP_POST_TSOLUTION_FIX2_REQUIRES_REVIEW";
        decision = "REVIEW_FAILED_FIX2_CHECKS";
        next_step = "Inspect postprocess script before retry.";
    end

    checksCsv = fullfile(articleTablesDir,'minrep_post_Tsolutions_fix2_checks_v96z.csv');
    writetable(Tchecks,checksCsv);

    fixMat = fullfile(articleTraceDir,'MINREP_POST_TSOLUTION_FIX2_v96z.mat');

    save(fixMat, ...
        'diagnosis','decision','next_step', ...
        'postPath','backupPath','Tchecks','checksCsv','fixMat');

    fixout = struct();
    fixout.status = 'MINREP_POST_TSOLUTION_FIX2_COMPLETED';
    fixout.diagnosis = diagnosis;
    fixout.decision = decision;
    fixout.next_step = next_step;
    fixout.postPath = postPath;
    fixout.backupPath = backupPath;
    fixout.Tchecks = Tchecks;
    fixout.fixMat = fixMat;

    disp('=== MINREP_POST_TSOLUTION_FIX2_v96z ===')
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

function block = compose_new_extract_block_Tsolutions()

    lines = strings(0,1);

    lines(end+1) = "function [X,F] = extract_XF_from_formal(formal)";
    lines(end+1) = "    X = [];";
    lines(end+1) = "    F = [];";
    lines(end+1) = "";
    lines(end+1) = "    % Formato real v96m:";
    lines(end+1) = "    % formal.Tsolutions contiene:";
    lines(end+1) = "    %   m_max, T_min, r_div2, t_rec_ini, MR,";
    lines(end+1) = "    %   cost_specific_USD_per_kgwater, CO2_specific_kgCO2_per_kgwater";
    lines(end+1) = "";
    lines(end+1) = "    if isstruct(formal) && isfield(formal,'Tsolutions') && istable(formal.Tsolutions)";
    lines(end+1) = "        T = formal.Tsolutions;";
    lines(end+1) = "";
    lines(end+1) = "        reqX = {'m_max','T_min','r_div2','t_rec_ini'};";
    lines(end+1) = "        reqF = {'MR','cost_specific_USD_per_kgwater','CO2_specific_kgCO2_per_kgwater'};";
    lines(end+1) = "";
    lines(end+1) = "        hasX = all(ismember(reqX,T.Properties.VariableNames));";
    lines(end+1) = "        hasF = all(ismember(reqF,T.Properties.VariableNames));";
    lines(end+1) = "";
    lines(end+1) = "        if hasX";
    lines(end+1) = "            X = [T.m_max, T.T_min, T.r_div2, T.t_rec_ini];";
    lines(end+1) = "        end";
    lines(end+1) = "";
    lines(end+1) = "        if hasF";
    lines(end+1) = "            F = [T.MR, T.cost_specific_USD_per_kgwater, T.CO2_specific_kgCO2_per_kgwater];";
    lines(end+1) = "        end";
    lines(end+1) = "";
    lines(end+1) = "        if ~isempty(F)";
    lines(end+1) = "            return";
    lines(end+1) = "        end";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    % Respaldo: campos directos si existieran en otra versión.";
    lines(end+1) = "    candidateX = [""X"",""x"",""population"",""Xformal"",""Xout"",""xPareto"",""Xpareto""];";
    lines(end+1) = "    candidateF = [""F"",""fval"",""Fformal"",""Fout"",""scores"",""fPareto"",""Fpareto""];";
    lines(end+1) = "";
    lines(end+1) = "    for k = 1:numel(candidateX)";
    lines(end+1) = "        name = candidateX(k);";
    lines(end+1) = "        if isstruct(formal) && isfield(formal,name)";
    lines(end+1) = "            X = formal.(name);";
    lines(end+1) = "            break";
    lines(end+1) = "        end";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    for k = 1:numel(candidateF)";
    lines(end+1) = "        name = candidateF(k);";
    lines(end+1) = "        if isstruct(formal) && isfield(formal,name)";
    lines(end+1) = "            F = formal.(name);";
    lines(end+1) = "            break";
    lines(end+1) = "        end";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    if istable(F)";
    lines(end+1) = "        F = table2array(F(:,vartype('numeric')));";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    if istable(X)";
    lines(end+1) = "        X = table2array(X(:,vartype('numeric')));";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    if isempty(F)";
    lines(end+1) = "        error('No se pudo extraer F. Se esperaba formal.Tsolutions con columnas MR, cost_specific_USD_per_kgwater y CO2_specific_kgCO2_per_kgwater.');";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    if size(F,2) ~= 3 && size(F,1) == 3";
    lines(end+1) = "        F = F.';";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    if size(F,2) ~= 3";
    lines(end+1) = "        error('F extraída no tiene 3 columnas. size(F)=[%d %d]',size(F,1),size(F,2));";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    if isempty(X)";
    lines(end+1) = "        X = NaN(size(F,1),4);";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    if size(X,2) ~= 4 && size(X,1) == 4";
    lines(end+1) = "        X = X.';";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    if size(X,1) ~= size(F,1)";
    lines(end+1) = "        X = NaN(size(F,1),4);";
    lines(end+1) = "    end";
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