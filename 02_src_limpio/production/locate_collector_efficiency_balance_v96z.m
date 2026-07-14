function loc = locate_collector_efficiency_balance_v96z()
% LOCATE_COLLECTOR_EFFICIENCY_BALANCE_v96z
%
% 9.6z-eta-locate-a
% LOCATE-FIXED-COLLECTOR-EFFICIENCY-AND-SOLAR-BALANCE-001
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica fuentes.
%
% Busca:
%   1) eficiencia fija del colector, eta_col ~ 0.5
%   2) cálculo de energía solar Q_AH, Q_solar, Q_col
%   3) variables de temperatura de entrada/salida de colector
%   4) irradiancia
%   5) flujo másico/volumétrico
%   6) cp del aire
%   7) posibles puntos quirúrgicos de inserción

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    srcRoot = fullfile(rootDir,'02_src_limpio');
    productionDir = fullfile(srcRoot,'production');

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    reviewDir = fullfile(articleRoot,'review');
    tablesDir = fullfile(articleRoot,'tables');
    traceDir = fullfile(articleRoot,'traceability');

    mkdir_if_needed(reviewDir);
    mkdir_if_needed(tablesDir);
    mkdir_if_needed(traceDir);

    mFiles = dir(fullfile(srcRoot,'**','*.m'));

    % ------------------------------------------------------------------
    % Patrones de búsqueda
    % ------------------------------------------------------------------
    patterns_eta = [
        "eta_col"
        "etha_col"
        "etaCollector"
        "eta_collector"
        "eta_solar"
        "etaSAH"
        "eta_AH"
        "eta = 0.5"
        "eta=0.5"
        "0.5"
        "50%"
        "eficiencia"
        "efficiency"
    ];

    patterns_Qsolar = [
        "Q_AH"
        "QAH"
        "Q_solar"
        "Qsolar"
        "Q_col"
        "Qcol"
        "Q_colector"
        "Qcolector"
        "Irradiacion"
        "irradiacion"
        "irradiance"
        "radiacion"
        "G "
        "G="
        "G*"
        "I*A"
        "A_col"
        "Acolector"
    ];

    patterns_temperature = [
        "T_in"
        "Tin"
        "T_in_col"
        "Tin_col"
        "T_out"
        "Tout"
        "T_out_col"
        "Tout_col"
        "T_amb"
        "Tamb"
        "T_aire"
        "Tair"
        "T_col"
        "Tcolector"
        "T_solar"
        "Tsec"
    ];

    patterns_flow_cp = [
        "m_dot"
        "mdot"
        "m_max"
        "flujo"
        "caudal"
        "flow"
        "Qv"
        "Vdot"
        "cp"
        "Cp"
        "Cpa"
        "rho"
        "dens"
    ];

    Teta = search_patterns_with_context(mFiles,patterns_eta,4);
    Tqsolar = search_patterns_with_context(mFiles,patterns_Qsolar,4);
    Ttemp = search_patterns_with_context(mFiles,patterns_temperature,3);
    Tflowcp = search_patterns_with_context(mFiles,patterns_flow_cp,3);

    % ------------------------------------------------------------------
    % Ranking heurístico de archivos candidatos
    % ------------------------------------------------------------------
    allFiles = unique(string({mFiles.name}'));
    allPaths = unique(string(fullfile({mFiles.folder}',{mFiles.name}')));

    score_file = strings(0,1);
    score_path = strings(0,1);
    n_eta = [];
    n_Qsolar = [];
    n_temp = [];
    n_flowcp = [];
    total_score = [];

    for i = 1:numel(allPaths)
        p = allPaths(i);

        ne = sum(string(Teta.file_path)==p);
        nq = sum(string(Tqsolar.file_path)==p);
        nt = sum(string(Ttemp.file_path)==p);
        nf = sum(string(Tflowcp.file_path)==p);

        if ne+nq+nt+nf > 0
            score_file(end+1,1) = string(get_file_name(p)); %#ok<AGROW>
            score_path(end+1,1) = p; %#ok<AGROW>
            n_eta(end+1,1) = ne; %#ok<AGROW>
            n_Qsolar(end+1,1) = nq; %#ok<AGROW>
            n_temp(end+1,1) = nt; %#ok<AGROW>
            n_flowcp(end+1,1) = nf; %#ok<AGROW>

            % Peso más alto para archivos que combinan eta + Qsolar + temperatura
            total_score(end+1,1) = 5*ne + 4*nq + 2*nt + 2*nf; %#ok<AGROW>
        end
    end

    Tscore = table(score_file,score_path,n_eta,n_Qsolar,n_temp,n_flowcp,total_score);
    if height(Tscore) > 0
        Tscore = sortrows(Tscore,'total_score','descend');
    end

    % ------------------------------------------------------------------
    % Extraer contexto amplio de los 10 archivos más probables
    % ------------------------------------------------------------------
    TtopContext = table();

    nTop = min(10,height(Tscore));
    for i = 1:nTop
        p = Tscore.score_path(i);
        Tctx = extract_file_context(p,120);
        Tctx.rank = repmat(i,height(Tctx),1);
        Tctx.total_score = repmat(Tscore.total_score(i),height(Tctx),1);
        Tctx = movevars(Tctx,{'rank','total_score'},'Before',1);
        TtopContext = [TtopContext; Tctx]; %#ok<AGROW>
    end

    % ------------------------------------------------------------------
    % Checks
    % ------------------------------------------------------------------
    checks = {};
    checks{end+1,1} = check_row("L01","MATLAB source files found",numel(mFiles)>0,string(numel(mFiles)));
    checks{end+1,1} = check_row("L02","Efficiency-pattern hits found",height(Teta)>0,string(height(Teta)));
    checks{end+1,1} = check_row("L03","Solar-energy-pattern hits found",height(Tqsolar)>0,string(height(Tqsolar)));
    checks{end+1,1} = check_row("L04","Temperature-pattern hits found",height(Ttemp)>0,string(height(Ttemp)));
    checks{end+1,1} = check_row("L05","Flow/Cp-pattern hits found",height(Tflowcp)>0,string(height(Tflowcp)));
    checks{end+1,1} = check_row("L06","Ranked candidate files available",height(Tscore)>0,string(height(Tscore)));
    checks{end+1,1} = check_row("L07","Top context extracted",height(TtopContext)>0,string(height(TtopContext)));
    checks{end+1,1} = check_row("L08","No GA executed",true,"Static code inspection only.");
    checks{end+1,1} = check_row("L09","No source modified",true,"Read-only audit.");

    Tchecks = struct2table(vertcat(checks{:}));

    if Tchecks.pass(Tchecks.id=="L02") && Tchecks.pass(Tchecks.id=="L03")
        diagnosis = "COLLECTOR_EFFICIENCY_AND_SOLAR_BALANCE_CANDIDATES_FOUND";
        decision = "INSPECT_TOP_FILES_BEFORE_SURGICAL_MODIFICATION";
        next_step = "Open top-ranked files and identify exact eta_col/Qsolar/Tin/Tout/Tamb/G/mdot/cp variables.";
    else
        diagnosis = "COLLECTOR_EFFICIENCY_LOCATION_INCOMPLETE";
        decision = "DO_NOT_MODIFY_MODEL_YET";
        next_step = "Use broader manual search or provide likely model file.";
    end

    % ------------------------------------------------------------------
    % Guardar tablas
    % ------------------------------------------------------------------
    etaCsv = fullfile(tablesDir,'LOCATE_COLLECTOR_v96z_eta_hits.csv');
    qsolarCsv = fullfile(tablesDir,'LOCATE_COLLECTOR_v96z_Qsolar_hits.csv');
    tempCsv = fullfile(tablesDir,'LOCATE_COLLECTOR_v96z_temperature_hits.csv');
    flowcpCsv = fullfile(tablesDir,'LOCATE_COLLECTOR_v96z_flow_cp_hits.csv');
    scoreCsv = fullfile(tablesDir,'LOCATE_COLLECTOR_v96z_ranked_candidate_files.csv');
    contextCsv = fullfile(tablesDir,'LOCATE_COLLECTOR_v96z_top_context.csv');
    checksCsv = fullfile(tablesDir,'LOCATE_COLLECTOR_v96z_Tchecks.csv');

    writetable(Teta,etaCsv);
    writetable(Tqsolar,qsolarCsv);
    writetable(Ttemp,tempCsv);
    writetable(Tflowcp,flowcpCsv);
    writetable(Tscore,scoreCsv);
    writetable(TtopContext,contextCsv);
    writetable(Tchecks,checksCsv);

    % ------------------------------------------------------------------
    % Reporte Markdown
    % ------------------------------------------------------------------
    reportMd = fullfile(reviewDir,'LOCATE_COLLECTOR_EFFICIENCY_BALANCE_v96z.md');

    fid = fopen(reportMd,'w');
    fprintf(fid,'# LOCATE_COLLECTOR_EFFICIENCY_BALANCE_v96z\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);

    fprintf(fid,'## Top candidate files\n\n');
    fprintf(fid,'| rank | file | n_eta | n_Qsolar | n_temp | n_flowcp | score |\n');
    fprintf(fid,'|---:|---|---:|---:|---:|---:|---:|\n');

    for i = 1:min(20,height(Tscore))
        fprintf(fid,'| %d | `%s` | %d | %d | %d | %d | %d |\n', ...
            i, sanitize_md(Tscore.score_path(i)), Tscore.n_eta(i), Tscore.n_Qsolar(i), ...
            Tscore.n_temp(i), Tscore.n_flowcp(i), Tscore.total_score(i));
    end

    fprintf(fid,'\n## Efficiency hits sample\n\n');
    write_hits_md(fid,Teta,25);

    fprintf(fid,'\n## Solar-energy hits sample\n\n');
    write_hits_md(fid,Tqsolar,25);

    fprintf(fid,'\n## Temperature hits sample\n\n');
    write_hits_md(fid,Ttemp,25);

    fprintf(fid,'\n## Flow/Cp hits sample\n\n');
    write_hits_md(fid,Tflowcp,25);

    fprintf(fid,'\n## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');

    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            Tchecks.id(i), sanitize_md(Tchecks.check(i)), Tchecks.pass(i), sanitize_md(Tchecks.evidence(i)));
    end

    fprintf(fid,'\n## Interpretation\n\n');
    fprintf(fid,'This audit only locates candidate code blocks. ');
    fprintf(fid,'Do not modify the model until the exact algebraic solar balance has been identified.\n');

    fclose(fid);

    % ------------------------------------------------------------------
    % Guardar MAT
    % ------------------------------------------------------------------
    outMat = fullfile(traceDir,'LOCATE_COLLECTOR_EFFICIENCY_BALANCE_v96z.mat');

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'Teta','Tqsolar','Ttemp','Tflowcp','Tscore','TtopContext','Tchecks', ...
        'etaCsv','qsolarCsv','tempCsv','flowcpCsv','scoreCsv','contextCsv','checksCsv', ...
        'reportMd','outMat');

    loc = struct();
    loc.status = 'LOCATE_COLLECTOR_EFFICIENCY_BALANCE_v96z_COMPLETED';
    loc.diagnosis = diagnosis;
    loc.decision = decision;
    loc.next_step = next_step;
    loc.Teta = Teta;
    loc.Tqsolar = Tqsolar;
    loc.Ttemp = Ttemp;
    loc.Tflowcp = Tflowcp;
    loc.Tscore = Tscore;
    loc.TtopContext = TtopContext;
    loc.Tchecks = Tchecks;
    loc.reportMd = reportMd;
    loc.outMat = outMat;

    disp('=== LOCATE_COLLECTOR_EFFICIENCY_BALANCE_v96z ===')
    disp(loc.status)
    disp('=== DIAGNOSIS ===')
    disp(loc.diagnosis)
    disp('=== DECISION ===')
    disp(loc.decision)
    disp('=== NEXT STEP ===')
    disp(loc.next_step)

    disp('=== TOP CANDIDATE FILES ===')
    disp(head_safe(loc.Tscore,20))

    disp('=== ETA HITS SAMPLE ===')
    disp(head_safe(loc.Teta,30))

    disp('=== QSOLAR HITS SAMPLE ===')
    disp(head_safe(loc.Tqsolar,30))

    disp('=== TEMPERATURE HITS SAMPLE ===')
    disp(head_safe(loc.Ttemp,30))

    disp('=== FLOW/CP HITS SAMPLE ===')
    disp(head_safe(loc.Tflowcp,30))

    disp('=== CHECKS ===')
    disp(loc.Tchecks)

    disp('=== REPORT ===')
    disp(loc.reportMd)
end

function T = search_patterns_with_context(mFiles,patterns,contextRadius)
    file_name = strings(0,1);
    file_path = strings(0,1);
    line_number = zeros(0,1);
    pattern = strings(0,1);
    line_text = strings(0,1);
    context_before = strings(0,1);
    context_after = strings(0,1);

    for k = 1:numel(mFiles)
        path = fullfile(mFiles(k).folder,mFiles(k).name);

        try
            txt = string(fileread(path));
        catch
            continue;
        end

        lines = splitlines(txt);

        for i = 1:numel(lines)
            thisLineLow = lower(lines(i));

            for p = 1:numel(patterns)
                pat = lower(patterns(p));

                if contains(thisLineLow,pat)
                    i1 = max(1,i-contextRadius);
                    i2 = min(numel(lines),i+contextRadius);

                    beforeLines = lines(i1:max(i-1,i1));
                    afterLines = lines(min(i+1,i2):i2);

                    file_name(end+1,1) = string(mFiles(k).name); %#ok<AGROW>
                    file_path(end+1,1) = string(path); %#ok<AGROW>
                    line_number(end+1,1) = i; %#ok<AGROW>
                    pattern(end+1,1) = string(patterns(p)); %#ok<AGROW>
                    line_text(end+1,1) = strtrim(lines(i)); %#ok<AGROW>
                    context_before(end+1,1) = strjoin(strtrim(beforeLines)," | "); %#ok<AGROW>
                    context_after(end+1,1) = strjoin(strtrim(afterLines)," | "); %#ok<AGROW>
                end
            end
        end
    end

    T = table(file_name,file_path,line_number,pattern,line_text,context_before,context_after);
end

function Tctx = extract_file_context(filePath,maxLines)
    try
        txt = string(fileread(filePath));
    catch
        Tctx = table();
        return;
    end

    lines = splitlines(txt);
    n = min(maxLines,numel(lines));

    file_path = repmat(string(filePath),n,1);
    line_number = (1:n)';
    line_text = strings(n,1);

    for i = 1:n
        line_text(i) = strtrim(lines(i));
    end

    Tctx = table(file_path,line_number,line_text);
end

function write_hits_md(fid,T,n)
    if isempty(T) || height(T)==0
        fprintf(fid,'No hits found.\n\n');
        return;
    end

    fprintf(fid,'| file | line | pattern | text |\n');
    fprintf(fid,'|---|---:|---|---|\n');

    for i = 1:min(n,height(T))
        fprintf(fid,'| `%s` | %d | `%s` | `%s` |\n', ...
            sanitize_md(T.file_name(i)), T.line_number(i), ...
            sanitize_md(T.pattern(i)), sanitize_md(T.line_text(i)));
    end
end

function row = check_row(id,checkName,passVal,evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end

function mkdir_if_needed(folderPath)
    if ~isfolder(folderPath)
        mkdir(folderPath);
    end
end

function s = sanitize_md(x)
    s = string(x);
    s = replace(s,newline," ");
    s = replace(s,"|","\|");
    s = replace(s,"`","'");
end

function T = head_safe(Tin,n)
    if isempty(Tin) || height(Tin)==0
        T = Tin;
    else
        T = Tin(1:min(n,height(Tin)),:);
    end
end

function name = get_file_name(pathStr)
    [~,name,ext] = fileparts(char(pathStr));
    name = string([name ext]);
end