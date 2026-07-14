function diag1 = inspect_minrep_formal_struct_v96z_diag1()
% INSPECT_MINREP_FORMAL_STRUCT_v96z_diag1
% Diagnostica dónde están X/F, o si v96m no los guarda.
%
% No ejecuta GA. No llama modelo. No modifica 05_runs.

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    articleRunsDir = fullfile(articleRoot,'runs');
    articleTraceDir = fullfile(articleRoot,'traceability');
    articleTablesDir = fullfile(articleRoot,'tables');
    articleReviewDir = fullfile(articleRoot,'review');

    if ~isfolder(articleTraceDir), mkdir(articleTraceDir); end
    if ~isfolder(articleTablesDir), mkdir(articleTablesDir); end
    if ~isfolder(articleReviewDir), mkdir(articleReviewDir); end

    runDir = find_latest_minrep_run_dir(articleRunsDir);
    if strlength(runDir) == 0
        error('No se encontró carpeta MINREP.');
    end

    runMat = fullfile(runDir,'MINREP_SEED_CONTROLLED_RUN_v96z.mat');
    R = load(runMat);

    Trep = R.Treplicates;
    outMat = string(Trep.output_mat(1));

    if ~isfile(outMat)
        error('No existe output_mat R1: %s', outMat);
    end

    S = load(outMat);

    fprintf('\n=== VARIABLES IN R1 OUTPUT MAT ===\n');
    disp(fieldnames(S))

    if isfield(S,'formal')
        formal = S.formal;
    else
        error('No existe variable formal en R1 output.');
    end

    fprintf('\n=== FORMAL TOP-LEVEL FIELDS ===\n');
    if isstruct(formal)
        disp(fieldnames(formal))
    else
        disp(class(formal))
        disp(size(formal))
    end

    Rows = {};
    Rows = scan_object(Rows,"formal",formal,0,5);

    Tscan = struct2table(vertcat(Rows{:}));

    scanCsv = fullfile(articleTablesDir,'inspect_minrep_formal_struct_v96z_diag1_scan.csv');
    writetable(Tscan,scanCsv);

    reportMd = fullfile(articleReviewDir,'INSPECT_MINREP_FORMAL_STRUCT_v96z_diag1.md');

    fid = fopen(reportMd,'w');
    fprintf(fid,'# INSPECT_MINREP_FORMAL_STRUCT_v96z_diag1\n\n');
    fprintf(fid,'Run dir:\n\n`%s`\n\n',runDir);
    fprintf(fid,'R1 output:\n\n`%s`\n\n',outMat);
    fprintf(fid,'## Top-level variables in R1 output MAT\n\n');
    fS = fieldnames(S);
    for i = 1:numel(fS)
        fprintf(fid,'- `%s`\n',fS{i});
    end
    fprintf(fid,'\n## Formal scan\n\n');
    fprintf(fid,'| path | class | size | numeric | table | candidateF | candidateX |\n');
    fprintf(fid,'|---|---|---:|---:|---:|---:|---:|\n');

    for i = 1:height(Tscan)
        fprintf(fid,'| `%s` | `%s` | `%s` | %d | %d | %d | %d |\n', ...
            Tscan.path(i), Tscan.class(i), Tscan.size_str(i), ...
            Tscan.is_numeric(i), Tscan.is_table(i), ...
            Tscan.candidate_F(i), Tscan.candidate_X(i));
    end

    fclose(fid);

    hasCandidateF = any(Tscan.candidate_F);
    hasCandidateX = any(Tscan.candidate_X);

    checks = {};
    checks{end+1,1} = check_row("D1_01","Run MAT loaded",isfile(runMat),string(runMat));
    checks{end+1,1} = check_row("D1_02","R1 output loaded",isfile(outMat),outMat);
    checks{end+1,1} = check_row("D1_03","formal variable exists",isfield(S,'formal'),"formal present in R1 output.");
    checks{end+1,1} = check_row("D1_04","scan table created",isfile(scanCsv),string(scanCsv));
    checks{end+1,1} = check_row("D1_05","report created",isfile(reportMd),string(reportMd));
    checks{end+1,1} = check_row("D1_06","candidate F found",hasCandidateF,sprintf("candidateF=%d",hasCandidateF));
    checks{end+1,1} = check_row("D1_07","candidate X found",hasCandidateX,sprintf("candidateX=%d",hasCandidateX));
    checks{end+1,1} = check_row("D1_08","No GA executed",true,"No gamultiobj call.");

    Tchecks = struct2table(vertcat(checks{:}));

    if hasCandidateF
        diagnosis = "MINREP_FORMAL_STRUCT_DIAG1_FOUND_F_CANDIDATE";
        decision = "PATCH_POSTPROCESS_WITH_DISCOVERED_PATH";
        next_step = "Paste Tscan rows with candidate_F=true.";
    else
        diagnosis = "MINREP_FORMAL_STRUCT_DIAG1_NO_F_CANDIDATE";
        decision = "v96m_MAY_NOT_SAVE_FRONT_MATRIX";
        next_step = "Inspect v96m save contents or recover from latest 05_runs MAT.";
    end

    checksCsv = fullfile(articleTablesDir,'inspect_minrep_formal_struct_v96z_diag1_checks.csv');
    writetable(Tchecks,checksCsv);

    diagMat = fullfile(articleTraceDir,'INSPECT_MINREP_FORMAL_STRUCT_v96z_diag1.mat');
    save(diagMat,'diagnosis','decision','next_step','runDir','runMat','outMat','Tscan','Tchecks','scanCsv','reportMd','diagMat');

    diag1 = struct();
    diag1.status = 'MINREP_FORMAL_STRUCT_DIAG1_COMPLETED';
    diag1.diagnosis = diagnosis;
    diag1.decision = decision;
    diag1.next_step = next_step;
    diag1.runDir = runDir;
    diag1.outMat = outMat;
    diag1.Tscan = Tscan;
    diag1.Tchecks = Tchecks;
    diag1.reportMd = reportMd;
    diag1.scanCsv = scanCsv;

    disp('=== MINREP_FORMAL_STRUCT_DIAG1 ===')
    disp(diag1.status)
    disp('=== DIAGNOSIS ===')
    disp(diag1.diagnosis)
    disp('=== DECISION ===')
    disp(diag1.decision)
    disp('=== NEXT STEP ===')
    disp(diag1.next_step)
    disp('=== R1 OUTPUT MAT ===')
    disp(diag1.outMat)
    disp('=== SCAN CANDIDATES ===')
    disp(diag1.Tscan(:,{'path','class','size_str','is_numeric','is_table','candidate_F','candidate_X'}))
    disp('=== CHECKS ===')
    disp(diag1.Tchecks)
    disp('=== REPORT ===')
    disp(diag1.reportMd)

end

function Rows = scan_object(Rows,path,obj,depth,maxDepth)

    if depth > maxDepth
        return
    end

    row = struct();
    row.path = string(path);
    row.class = string(class(obj));
    row.size_str = string(mat2str(size(obj)));
    row.is_numeric = isnumeric(obj);
    row.is_table = istable(obj);
    row.is_struct = isstruct(obj);
    row.is_cell = iscell(obj);
    row.candidate_F = false;
    row.candidate_X = false;

    if isnumeric(obj) && ismatrix(obj)
        row.candidate_F = size(obj,2)==3 && size(obj,1)>=1;
        row.candidate_X = size(obj,2)==4 && size(obj,1)>=1;
    end

    if istable(obj)
        try
            A = table2array(obj(:,vartype('numeric')));
            row.candidate_F = isnumeric(A) && size(A,2)==3 && size(A,1)>=1;
            row.candidate_X = isnumeric(A) && size(A,2)==4 && size(A,1)>=1;
        catch
        end
    end

    Rows{end+1,1} = row;

    if isstruct(obj)
        fns = fieldnames(obj);
        for i = 1:numel(fns)
            try
                Rows = scan_object(Rows,path + "." + string(fns{i}),obj.(fns{i}),depth+1,maxDepth);
            catch
            end
        end
    elseif iscell(obj)
        for i = 1:min(numel(obj),20)
            try
                Rows = scan_object(Rows,path + "{" + string(i) + "}",obj{i},depth+1,maxDepth);
            catch
            end
        end
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

function row = check_row(id, checkName, passVal, evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end