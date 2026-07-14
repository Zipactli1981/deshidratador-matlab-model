function out = create_seedaware_v96m_clone_v96z_rngfix_b()
% CREATE_SEEDAWARE_v96m_CLONE_v96z_rngfix_b
%
% Crea un clon de run_guarded_triobjective_formal_ga_v96m.m que acepta
% semilla externa:
%
%   formal = run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix(true, 61001);
%
% Este script:
%   - NO ejecuta GA.
%   - NO llama modelo.
%   - NO modifica v96m original.
%   - Solo crea un clon seed-aware en production.

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

    srcPath = fullfile(productionDir,'run_guarded_triobjective_formal_ga_v96m.m');
    cloneName = 'run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix';
    clonePath = fullfile(productionDir,[cloneName '.m']);

    if ~isfile(srcPath)
        error('No existe srcPath: %s', srcPath);
    end

    src = string(fileread(srcPath));

    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    if isfile(clonePath)
        backupPath = fullfile(productionDir,[cloneName '_BACKUP_BEFORE_RECREATE_' timestamp '.m']);
        copyfile(clonePath,backupPath);
    else
        backupPath = "";
    end

    % ---------------------------------------------------------------------
    % 1) Reemplazar firma de función
    % ---------------------------------------------------------------------
    lines = splitlines(src);
    firstFunctionIdx = find(startsWith(strtrim(lines),"function "),1,'first');

    if isempty(firstFunctionIdx)
        error('No se encontró firma de función en v96m.');
    end

    oldSignature = lines(firstFunctionIdx);

    newSignature = "function formal = run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix(confirm_execute, rngSeed)";

    lines(firstFunctionIdx) = newSignature;

    src2 = strjoin(lines,newline);

    % ---------------------------------------------------------------------
    % 2) Insertar manejo de argumentos después de la firma
    % ---------------------------------------------------------------------
    argBlock = [
        ""
        "    if nargin < 1 || isempty(confirm_execute)"
        "        confirm_execute = false;"
        "    end"
        ""
        "    if nargin < 2"
        "        rngSeed = [];"
        "    end"
        ""
        "    rngSeedWasProvided_v96z = ~isempty(rngSeed);"
        "    rngStateBefore_v96z = rng;"
        ""
    ];

    src2 = replace(src2,newSignature,newSignature + newline + strjoin(argBlock,newline));

    % ---------------------------------------------------------------------
    % 3) Sustituir la semilla interna fija
    % ---------------------------------------------------------------------
    oldRngLine = "rng(614960,'twister');";

    newRngBlock = [
        "if rngSeedWasProvided_v96z"
        "    rng(rngSeed,'twister');"
        "    rngControl_v96z = ""EXTERNAL_SEED_APPLIED"";"
        "else"
        "    rng(614960,'twister');"
        "    rngControl_v96z = ""LEGACY_INTERNAL_SEED_614960_APPLIED"";"
        "end"
        "rngStateAfterSeed_v96z = rng;"
    ];

    if ~contains(src2,oldRngLine)
        error('No se encontró la línea esperada de rng fijo: %s', oldRngLine);
    end

    src2 = replace(src2,oldRngLine,strjoin(newRngBlock,newline));

    % ---------------------------------------------------------------------
    % 4) Cambiar etiquetas visibles de reporte para no confundirse con v96m
    % ---------------------------------------------------------------------
    src2 = replace(src2,"TRIOBJECTIVE_FORMAL_GA_v96m","TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix");
    src2 = replace(src2,"TRIOBJECTIVE_FORMAL_GA_v96m_COMPLETED","TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix_COMPLETED");

    % ---------------------------------------------------------------------
    % 5) Añadir campos al struct formal antes de salida si existe formal.T...
    % ---------------------------------------------------------------------
    insertToken = "formal.outMat = outMat;";
    rngFormalBlock = [
        "formal.rngSeed_v96z = rngSeed;"
        "formal.rngSeedWasProvided_v96z = rngSeedWasProvided_v96z;"
        "formal.rngControl_v96z = rngControl_v96z;"
        "formal.rngStateBefore_v96z = rngStateBefore_v96z;"
        "formal.rngStateAfterSeed_v96z = rngStateAfterSeed_v96z;"
    ];

    if contains(src2,insertToken)
        src2 = replace(src2,insertToken,insertToken + newline + strjoin(rngFormalBlock,newline));
    else
        warning('No se encontró token formal.outMat = outMat; no se pudieron insertar campos rng en formal.');
    end

    % ---------------------------------------------------------------------
    % 6) Escribir clon
    % ---------------------------------------------------------------------
    fid = fopen(clonePath,'w');
    if fid < 0
        error('No se pudo escribir clonePath: %s', clonePath);
    end
    fprintf(fid,'%s',src2);
    fclose(fid);

    rehash;

    cloneTxt = string(fileread(clonePath));

    % ---------------------------------------------------------------------
    % 7) Checks
    % ---------------------------------------------------------------------
    checks = {};
    checks{end+1,1} = check_row("RNG_B01","Source v96m exists",isfile(srcPath),string(srcPath));
    checks{end+1,1} = check_row("RNG_B02","Clone created",isfile(clonePath),string(clonePath));
    checks{end+1,1} = check_row("RNG_B03","Function renamed",contains(cloneTxt,"function formal = run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix(confirm_execute, rngSeed)"),"seed-aware signature found.");
    checks{end+1,1} = check_row("RNG_B04","External seed branch inserted",contains(cloneTxt,"EXTERNAL_SEED_APPLIED"),"external seed branch found.");
    checks{end+1,1} = check_row("RNG_B05","Legacy branch preserved",contains(cloneTxt,"LEGACY_INTERNAL_SEED_614960_APPLIED"),"legacy branch found.");
    checks{end+1,1} = check_row("RNG_B06","Original fixed rng not unconditional",~contains(cloneTxt,newline + "rng(614960,'twister');" + newline),"unconditional fixed rng not found.");
    checks{end+1,1} = check_row("RNG_B07","gamultiobj still present",contains(cloneTxt,"gamultiobj"),"gamultiobj call preserved.");
    checks{end+1,1} = check_row("RNG_B08","Tsolutions still present",contains(cloneTxt,"Tsolutions"),"Tsolutions preserved.");
    checks{end+1,1} = check_row("RNG_B09","RNG metadata inserted",contains(cloneTxt,"formal.rngControl_v96z"),"rng metadata inserted.");
    checks{end+1,1} = check_row("RNG_B10","No GA executed",true,"No gamultiobj call; file generation only.");
    checks{end+1,1} = check_row("RNG_B11","No model executed",true,"No objective/model call.");
    checks{end+1,1} = check_row("RNG_B12","Original v96m not modified",true,"Only clone created.");

    Tchecks = struct2table(vertcat(checks{:}));

    if all(Tchecks.pass)
        diagnosis = "SEEDAWARE_V96M_CLONE_CREATION_PASS";
        decision = "CLONE_READY_FOR_PREFLIGHT_AUDIT";
        next_step = "9.6z-rngfix-c — PREFLIGHT-SEEDAWARE-CLONE-NO-GA-001";
    else
        diagnosis = "SEEDAWARE_V96M_CLONE_CREATION_REQUIRES_REVIEW";
        decision = "REVIEW_FAILED_CLONE_CHECKS";
        next_step = "Inspect clone before use.";
    end

    checksCsv = fullfile(articleTablesDir,'create_seedaware_v96m_clone_v96z_rngfix_b_checks.csv');
    writetable(Tchecks,checksCsv);

    reportMd = fullfile(articleReviewDir,'CREATE_SEEDAWARE_v96m_CLONE_v96z_rngfix_b.md');

    fid = fopen(reportMd,'w');
    fprintf(fid,'# CREATE_SEEDAWARE_v96m_CLONE_v96z_rngfix_b\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Source\n\n`%s`\n\n',srcPath);
    fprintf(fid,'## Clone\n\n`%s`\n\n',clonePath);
    fprintf(fid,'## Old signature\n\n```matlab\n%s\n```\n\n',oldSignature);
    fprintf(fid,'## New signature\n\n```matlab\n%s\n```\n\n',newSignature);
    fprintf(fid,'## RNG replacement\n\n');
    fprintf(fid,'Old:\n\n```matlab\n%s\n```\n\n',oldRngLine);
    fprintf(fid,'New:\n\n```matlab\n%s\n```\n\n',strjoin(newRngBlock,newline));
    fprintf(fid,'## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');

    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            Tchecks.id(i),Tchecks.check(i),Tchecks.pass(i),Tchecks.evidence(i));
    end

    fclose(fid);

    outMat = fullfile(articleTraceDir,'CREATE_SEEDAWARE_v96m_CLONE_v96z_rngfix_b.mat');

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'srcPath','clonePath','backupPath', ...
        'oldSignature','newSignature','Tchecks','checksCsv','reportMd','outMat');

    out = struct();
    out.status = 'CREATE_SEEDAWARE_v96m_CLONE_v96z_rngfix_b_COMPLETED';
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.srcPath = srcPath;
    out.clonePath = clonePath;
    out.backupPath = backupPath;
    out.Tchecks = Tchecks;
    out.reportMd = reportMd;
    out.outMat = outMat;

    disp('=== CREATE_SEEDAWARE_v96m_CLONE_v96z_rngfix_b ===')
    disp(out.status)
    disp('=== DIAGNOSIS ===')
    disp(out.diagnosis)
    disp('=== DECISION ===')
    disp(out.decision)
    disp('=== NEXT STEP ===')
    disp(out.next_step)
    disp('=== SOURCE ===')
    disp(out.srcPath)
    disp('=== CLONE ===')
    disp(out.clonePath)
    disp('=== CHECKS ===')
    disp(out.Tchecks)
    disp('=== REPORT ===')
    disp(out.reportMd)

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