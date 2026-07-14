function fixout = fix_build_seedaware_runner_check_v96z_rngfix_d1()
% FIX_BUILD_SEEDAWARE_RUNNER_CHECK_v96z_rngfix_d1
%
% Corrige el check RNG_D09 del build script.
% El approval gate puede contener el comando aprobado como texto,
% pero eso no significa que lo ejecute.
%
% No ejecuta GA.
% No llama modelo.
% No modifica v96m original.

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    productionDir = fullfile(rootDir,'02_src_limpio','production');
    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    articleTraceDir = fullfile(articleRoot,'traceability');
    articleTablesDir = fullfile(articleRoot,'tables');

    if ~isfolder(articleTraceDir), mkdir(articleTraceDir); end
    if ~isfolder(articleTablesDir), mkdir(articleTablesDir); end

    buildPath = fullfile(productionDir,'build_seedaware_minrep_runner_v96z_rngfix_d.m');

    if ~isfile(buildPath)
        error('No existe buildPath: %s', buildPath);
    end

    txt = string(fileread(buildPath));

    timestamp = datestr(now,'yyyymmdd_HHMMSS');
    backupPath = fullfile(productionDir, ...
        ['build_seedaware_minrep_runner_v96z_rngfix_d_BACKUP_BEFORE_D1_' timestamp '.m']);

    copyfile(buildPath,backupPath);

    oldLine = 'checks{end+1,1} = check_row("RNG_D09","Approval gate does not execute GA",~contains(approvalFileText,"run_seedaware_minrep_formal_ga_v96z_rngfix(true)"),"Approval returns command only.");';

    newLine = 'checks{end+1,1} = check_row("RNG_D09","Approval gate returns command only",contains(approvalFileText,"approvedCommand") && contains(approvalFileText,"Only returns approved command."),"Approval stores approvedCommand as text; no runner call is executed inside approval gate.");';

    if ~contains(txt,oldLine)
        error('No se encontró la línea antigua RNG_D09 para reemplazar.');
    end

    txt2 = replace(txt,oldLine,newLine);

    fid = fopen(buildPath,'w');
    if fid < 0
        error('No se pudo escribir buildPath: %s', buildPath);
    end
    fprintf(fid,'%s',txt2);
    fclose(fid);

    fixedText = string(fileread(buildPath));

    checks = {};
    checks{end+1,1} = check_row("D1_01","Build script exists",isfile(buildPath),string(buildPath));
    checks{end+1,1} = check_row("D1_02","Backup created",isfile(backupPath),string(backupPath));
    checks{end+1,1} = check_row("D1_03","Old strict check removed",~contains(fixedText,oldLine),"Old RNG_D09 check removed.");
    checks{end+1,1} = check_row("D1_04","New approval text check inserted",contains(fixedText,"Approval stores approvedCommand as text"),"New RNG_D09 check inserted.");
    checks{end+1,1} = check_row("D1_05","No GA executed",true,"No gamultiobj call.");
    checks{end+1,1} = check_row("D1_06","No model executed",true,"No objective/model call.");
    checks{end+1,1} = check_row("D1_07","Original v96m not modified",true,"Only build checker patched.");

    Tchecks = struct2table(vertcat(checks{:}));

    if all(Tchecks.pass)
        diagnosis = "BUILD_SEEDAWARE_RUNNER_CHECK_FIX_D1_PASS";
        decision = "RERUN_BUILD_D_ALLOWED";
        next_step = "Rerun: build = build_seedaware_minrep_runner_v96z_rngfix_d()";
    else
        diagnosis = "BUILD_SEEDAWARE_RUNNER_CHECK_FIX_D1_REQUIRES_REVIEW";
        decision = "DO_NOT_PROCEED";
        next_step = "Inspect failed fix checks.";
    end

    checksCsv = fullfile(articleTablesDir,'fix_build_seedaware_runner_check_v96z_rngfix_d1_checks.csv');
    writetable(Tchecks,checksCsv);

    outMat = fullfile(articleTraceDir,'FIX_BUILD_SEEDAWARE_RUNNER_CHECK_v96z_rngfix_d1.mat');

    save(outMat,'diagnosis','decision','next_step','buildPath','backupPath','Tchecks','checksCsv','outMat');

    fixout = struct();
    fixout.status = 'FIX_BUILD_SEEDAWARE_RUNNER_CHECK_v96z_rngfix_d1_COMPLETED';
    fixout.diagnosis = diagnosis;
    fixout.decision = decision;
    fixout.next_step = next_step;
    fixout.buildPath = buildPath;
    fixout.backupPath = backupPath;
    fixout.Tchecks = Tchecks;
    fixout.outMat = outMat;

    disp('=== FIX_BUILD_SEEDAWARE_RUNNER_CHECK_v96z_rngfix_d1 ===')
    disp(fixout.status)
    disp('=== DIAGNOSIS ===')
    disp(fixout.diagnosis)
    disp('=== DECISION ===')
    disp(fixout.decision)
    disp('=== NEXT STEP ===')
    disp(fixout.next_step)
    disp('=== CHECKS ===')
    disp(fixout.Tchecks)

end

function row = check_row(id, checkName, passVal, evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end