function audit = audit_internal_rng_v96m_v96z_rngfix()
% AUDIT_INTERNAL_RNG_v96m_v96z_rngfix
% 9.6z-rngfix — AUDIT-AND-FIX-INTERNAL-RNG-RESET-IN-v96m-001
%
% Objetivo:
%   Auditar si run_guarded_triobjective_formal_ga_v96m.m contiene
%   reinicialización interna de rng que anula las semillas externas.
%
% Este script:
%   - NO ejecuta GA.
%   - NO llama gamultiobj.
%   - NO llama modelo.
%   - NO modifica v96m.
%   - Solo lee código fuente y genera reporte.

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    productionDir = fullfile(rootDir,'02_src_limpio','production');
    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    articleTraceDir = fullfile(articleRoot,'traceability');
    articleReviewDir = fullfile(articleRoot,'review');
    articleTablesDir = fullfile(articleRoot,'tables');

    mkdir_if_needed(articleTraceDir);
    mkdir_if_needed(articleReviewDir);
    mkdir_if_needed(articleTablesDir);

    v96mPath = fullfile(productionDir,'run_guarded_triobjective_formal_ga_v96m.m');

    if ~isfile(v96mPath)
        error('No existe v96mPath: %s', v96mPath);
    end

    txt = string(fileread(v96mPath));
    rawLines = splitlines(txt);
    nLines = numel(rawLines);

    patterns = [ ...
        "rng("; ...
        "rng ("; ...
        "RandStream"; ...
        "gamultiobj"; ...
        "optimoptions"; ...
        "UseParallel"; ...
        "InitialPopulationMatrix"; ...
        "PopulationSize"; ...
        "MaxGenerations"; ...
        "save("; ...
        "Tsolutions"; ...
        "Tpreflight"; ...
        "Trun" ...
    ];

    hits = table();
    hitPath = strings(0,1);
    hitLine = zeros(0,1);
    hitPattern = strings(0,1);
    hitText = strings(0,1);
    hitContext = strings(0,1);

    for p = 1:numel(patterns)
        pat = patterns(p);

        for i = 1:nLines
            lineText = rawLines(i);

            if contains(lineText,pat)
                hitPath(end+1,1) = string(v96mPath); %#ok<AGROW>
                hitLine(end+1,1) = i; %#ok<AGROW>
                hitPattern(end+1,1) = pat; %#ok<AGROW>
                hitText(end+1,1) = strtrim(lineText); %#ok<AGROW>

                lo = max(1,i-3);
                hi = min(nLines,i+3);
                ctx = strings(0,1);

                for j = lo:hi
                    prefix = "    ";
                    if j == i
                        prefix = ">>> ";
                    end
                    ctx(end+1,1) = prefix + string(j) + ": " + rawLines(j); %#ok<AGROW>
                end

                hitContext(end+1,1) = strjoin(ctx,newline); %#ok<AGROW>
            end
        end
    end

    hits.path = hitPath;
    hits.line = hitLine;
    hits.pattern = hitPattern;
    hits.text = hitText;
    hits.context = hitContext;

    has_rng = any(contains(hits.pattern,"rng"));
    n_rng_hits = sum(contains(hits.pattern,"rng"));
    has_gamultiobj = any(hits.pattern == "gamultiobj");
    has_optimoptions = any(hits.pattern == "optimoptions");
    has_Tsolutions = any(hits.pattern == "Tsolutions");

    % Clasificación preliminar
    if has_rng
        diagnosis = "V96M_INTERNAL_RNG_AUDIT_FOUND_RNG_CALL";
        decision = "CREATE_SEED_AWARE_CLONE_REQUIRED";
        next_step = "9.6z-rngfix-b — CREATE-SEED-AWARE-v96m-CLONE-001";
    else
        diagnosis = "V96M_INTERNAL_RNG_AUDIT_NO_RNG_CALL_FOUND";
        decision = "CHECK_OTHER_RANDOMNESS_SOURCES_OR_RUNNER_LOGIC";
        next_step = "Inspect runner and gamultiobj options.";
    end

    % Checks
    checks = {};
    checks{end+1,1} = check_row("RNG_A01","v96m file exists",isfile(v96mPath),string(v96mPath));
    checks{end+1,1} = check_row("RNG_A02","v96m read successfully",strlength(txt)>0,sprintf("nLines=%d",nLines));
    checks{end+1,1} = check_row("RNG_A03","rng audit performed",true,sprintf("rng_hits=%d",n_rng_hits));
    checks{end+1,1} = check_row("RNG_A04","gamultiobj located",has_gamultiobj,sprintf("has_gamultiobj=%d",has_gamultiobj));
    checks{end+1,1} = check_row("RNG_A05","optimoptions located",has_optimoptions,sprintf("has_optimoptions=%d",has_optimoptions));
    checks{end+1,1} = check_row("RNG_A06","Tsolutions located",has_Tsolutions,sprintf("has_Tsolutions=%d",has_Tsolutions));
    checks{end+1,1} = check_row("RNG_A07","No GA executed",true,"No gamultiobj call; only text scan.");
    checks{end+1,1} = check_row("RNG_A08","No model executed",true,"No objective/model call.");
    checks{end+1,1} = check_row("RNG_A09","No source modified",true,"Audit only.");

    Tchecks = struct2table(vertcat(checks{:}));

    hitsCsv = fullfile(articleTablesDir,'audit_internal_rng_v96m_v96z_rngfix_hits.csv');
    checksCsv = fullfile(articleTablesDir,'audit_internal_rng_v96m_v96z_rngfix_checks.csv');

    writetable(hits,hitsCsv);
    writetable(Tchecks,checksCsv);

    reportMd = fullfile(articleReviewDir,'AUDIT_INTERNAL_RNG_v96m_v96z_rngfix.md');

    fid = fopen(reportMd,'w');
    if fid < 0
        error('No se pudo crear reportMd: %s',reportMd);
    end

    fprintf(fid,'# AUDIT_INTERNAL_RNG_v96m_v96z_rngfix\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Source audited\n\n`%s`\n\n',v96mPath);
    fprintf(fid,'## Summary\n\n');
    fprintf(fid,'- rng hits: `%d`\n',n_rng_hits);
    fprintf(fid,'- gamultiobj found: `%d`\n',has_gamultiobj);
    fprintf(fid,'- optimoptions found: `%d`\n',has_optimoptions);
    fprintf(fid,'- Tsolutions found: `%d`\n\n',has_Tsolutions);

    fprintf(fid,'## Hits\n\n');
    fprintf(fid,'| line | pattern | text |\n');
    fprintf(fid,'|---:|---|---|\n');

    for i = 1:height(hits)
        safeText = strrep(string(hits.text(i)),'|','\|');
        fprintf(fid,'| %d | `%s` | `%s` |\n',hits.line(i),hits.pattern(i),safeText);
    end

    fprintf(fid,'\n## Context\n\n');

    for i = 1:height(hits)
        fprintf(fid,'### Hit %d — line %d — `%s`\n\n',i,hits.line(i),hits.pattern(i));
        fprintf(fid,'```matlab\n%s\n```\n\n',hits.context(i));
    end

    fprintf(fid,'## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');

    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            Tchecks.id(i),Tchecks.check(i),Tchecks.pass(i),Tchecks.evidence(i));
    end

    fclose(fid);

    auditMat = fullfile(articleTraceDir,'AUDIT_INTERNAL_RNG_v96m_v96z_rngfix.mat');

    save(auditMat, ...
        'diagnosis','decision','next_step', ...
        'rootDir','v96mPath','hits','Tchecks', ...
        'has_rng','n_rng_hits','has_gamultiobj','has_optimoptions','has_Tsolutions', ...
        'hitsCsv','checksCsv','reportMd','auditMat');

    audit = struct();
    audit.status = 'AUDIT_INTERNAL_RNG_v96m_v96z_rngfix_COMPLETED';
    audit.diagnosis = diagnosis;
    audit.decision = decision;
    audit.next_step = next_step;
    audit.v96mPath = v96mPath;
    audit.hits = hits;
    audit.Tchecks = Tchecks;
    audit.reportMd = reportMd;
    audit.auditMat = auditMat;

    disp('=== AUDIT_INTERNAL_RNG_v96m_v96z_rngfix ===')
    disp(audit.status)
    disp('=== DIAGNOSIS ===')
    disp(audit.diagnosis)
    disp('=== DECISION ===')
    disp(audit.decision)
    disp('=== NEXT STEP ===')
    disp(audit.next_step)
    disp('=== v96m PATH ===')
    disp(audit.v96mPath)
    disp('=== HITS ===')
    disp(audit.hits(:,{'line','pattern','text'}))
    disp('=== CHECKS ===')
    disp(audit.Tchecks)
    disp('=== REPORT ===')
    disp(audit.reportMd)

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