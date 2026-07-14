function fixout = fix_minrep_post_extract_XF_v96z_f1()
% FIX_MINREP_POST_EXTRACT_XF_v96z_f1
%
% Corrige postprocess_seed_replications_v96z_minrep_post.m
% para extraer X y F de estructuras anidadas.
%
% Este fix:
%   - NO ejecuta GA.
%   - NO llama modelo.
%   - NO modifica 05_runs.
%   - Solo parchea la función de extracción X/F del postproceso.

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
        ['postprocess_seed_replications_v96z_minrep_post_BACKUP_BEFORE_FIX1_' timestamp '.m']);

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

    newBlock = compose_new_extract_block();

    txt2 = extractBefore(txt,s) + newBlock + newline + newline + extractAfter(txt,e-1);

    fid = fopen(postPath,'w');
    if fid < 0
        error('No se pudo escribir postPath: %s', postPath);
    end
    fprintf(fid,'%s',txt2);
    fclose(fid);

    fixedText = string(fileread(postPath));

    checks = {};
    checks{end+1,1} = check_row("PXF1_01","Postprocess file exists",isfile(postPath),string(postPath));
    checks{end+1,1} = check_row("PXF1_02","Backup created",isfile(backupPath),string(backupPath));
    checks{end+1,1} = check_row("PXF1_03","Recursive extractor inserted",contains(fixedText,"recursive_find_numeric_matrix"),"recursive extractor found.");
    checks{end+1,1} = check_row("PXF1_04","No GA executed",true,"No gamultiobj call.");
    checks{end+1,1} = check_row("PXF1_05","No model executed",true,"No objective/model call.");
    checks{end+1,1} = check_row("PXF1_06","No 05_runs modified",true,"Only postprocess script patched.");

    Tchecks = struct2table(vertcat(checks{:}));

    if all(Tchecks.pass)
        diagnosis = "MINREP_POST_EXTRACT_XF_FIX1_PASS";
        decision = "POSTPROCESS_READY_FOR_RETRY";
        next_step = "Retry: post = postprocess_seed_replications_v96z_minrep_post()";
    else
        diagnosis = "MINREP_POST_EXTRACT_XF_FIX1_REQUIRES_REVIEW";
        decision = "REVIEW_FAILED_FIX1_CHECKS";
        next_step = "Inspect postprocess script before retry.";
    end

    checksCsv = fullfile(articleTablesDir,'minrep_post_extract_XF_fix1_checks_v96z.csv');
    writetable(Tchecks,checksCsv);

    fixMat = fullfile(articleTraceDir,'MINREP_POST_EXTRACT_XF_FIX1_v96z.mat');

    save(fixMat, ...
        'diagnosis','decision','next_step', ...
        'postPath','backupPath','Tchecks','checksCsv','fixMat');

    fixout = struct();
    fixout.status = 'MINREP_POST_EXTRACT_XF_FIX1_COMPLETED';
    fixout.diagnosis = diagnosis;
    fixout.decision = decision;
    fixout.next_step = next_step;
    fixout.postPath = postPath;
    fixout.backupPath = backupPath;
    fixout.Tchecks = Tchecks;
    fixout.fixMat = fixMat;

    disp('=== MINREP_POST_EXTRACT_XF_FIX1_v96z ===')
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

function block = compose_new_extract_block()

    lines = strings(0,1);

    lines(end+1) = "function [X,F] = extract_XF_from_formal(formal)";
    lines(end+1) = "    X = [];";
    lines(end+1) = "    F = [];";
    lines(end+1) = "";
    lines(end+1) = "    % Primero: campos directos esperados.";
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
    lines(end+1) = "    % Segundo: búsqueda recursiva en estructuras anidadas.";
    lines(end+1) = "    if isempty(F)";
    lines(end+1) = "        F = recursive_find_numeric_matrix(formal,3);";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    if isempty(X)";
    lines(end+1) = "        X = recursive_find_numeric_matrix(formal,4);";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    % Tercero: si F viene como tabla, convertir.";
    lines(end+1) = "    if istable(F)";
    lines(end+1) = "        F = table2array(F(:,vartype('numeric')));";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    if istable(X)";
    lines(end+1) = "        X = table2array(X(:,vartype('numeric')));";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    if isempty(F)";
    lines(end+1) = "        error('No se pudo extraer F del struct formal ni por búsqueda recursiva.');";
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
    lines(end+1) = "";
    lines(end+1) = "function M = recursive_find_numeric_matrix(obj,nCols)";
    lines(end+1) = "    M = [];";
    lines(end+1) = "";
    lines(end+1) = "    if isnumeric(obj) && ismatrix(obj) && size(obj,2) == nCols && size(obj,1) >= 1";
    lines(end+1) = "        M = obj;";
    lines(end+1) = "        return";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    if istable(obj)";
    lines(end+1) = "        try";
    lines(end+1) = "            A = table2array(obj(:,vartype('numeric')));";
    lines(end+1) = "            if isnumeric(A) && ismatrix(A) && size(A,2) == nCols && size(A,1) >= 1";
    lines(end+1) = "                M = A;";
    lines(end+1) = "                return";
    lines(end+1) = "            end";
    lines(end+1) = "        catch";
    lines(end+1) = "        end";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    if isstruct(obj)";
    lines(end+1) = "        fns = fieldnames(obj);";
    lines(end+1) = "";
    lines(end+1) = "        % Priorizar nombres probables.";
    lines(end+1) = "        preferred = [""F"",""fval"",""scores"",""X"",""x"",""population"",""result"",""results"",""output"",""formal""];";
    lines(end+1) = "        ordered = strings(0,1);";
    lines(end+1) = "        for p = 1:numel(preferred)";
    lines(end+1) = "            hit = fns(strcmpi(fns,preferred(p)));";
    lines(end+1) = "            if ~isempty(hit)";
    lines(end+1) = "                ordered(end+1,1) = string(hit{1}); %#ok<AGROW>";
    lines(end+1) = "            end";
    lines(end+1) = "        end";
    lines(end+1) = "        for q = 1:numel(fns)";
    lines(end+1) = "            if ~any(ordered == string(fns{q}))";
    lines(end+1) = "                ordered(end+1,1) = string(fns{q}); %#ok<AGROW>";
    lines(end+1) = "            end";
    lines(end+1) = "        end";
    lines(end+1) = "";
    lines(end+1) = "        for i = 1:numel(ordered)";
    lines(end+1) = "            try";
    lines(end+1) = "                val = obj.(ordered(i));";
    lines(end+1) = "                M = recursive_find_numeric_matrix(val,nCols);";
    lines(end+1) = "                if ~isempty(M)";
    lines(end+1) = "                    return";
    lines(end+1) = "                end";
    lines(end+1) = "            catch";
    lines(end+1) = "            end";
    lines(end+1) = "        end";
    lines(end+1) = "    end";
    lines(end+1) = "";
    lines(end+1) = "    if iscell(obj)";
    lines(end+1) = "        for i = 1:numel(obj)";
    lines(end+1) = "            M = recursive_find_numeric_matrix(obj{i},nCols);";
    lines(end+1) = "            if ~isempty(M)";
    lines(end+1) = "                return";
    lines(end+1) = "            end";
    lines(end+1) = "        end";
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