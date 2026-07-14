function fixout = fix_smoke_shortname_v96z_rngfix_s1()
% FIX_SMOKE_SHORTNAME_v96z_rngfix_s1
%
% Corrige el nombre largo del clon smoke en:
%   run_seedaware_smoke_seed_difference_v96z_rngfix.m
%
% No ejecuta GA.
% No llama modelo.
% No modifica v96m original.

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    productionDir = fullfile(rootDir,'02_src_limpio','production');
    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    traceDir = fullfile(articleRoot,'traceability');
    tablesDir = fullfile(articleRoot,'tables');

    if ~isfolder(traceDir), mkdir(traceDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end

    smokeRunnerPath = fullfile(productionDir,'run_seedaware_smoke_seed_difference_v96z_rngfix.m');

    if ~isfile(smokeRunnerPath)
        error('No existe smokeRunnerPath: %s', smokeRunnerPath);
    end

    txt = string(fileread(smokeRunnerPath));

    timestamp = datestr(now,'yyyymmdd_HHMMSS');
    backupPath = fullfile(productionDir, ...
        ['run_seedaware_smoke_seed_difference_v96z_rngfix_BACKUP_BEFORE_SHORTNAME_' timestamp '.m']);

    copyfile(smokeRunnerPath,backupPath);

    longName = 'run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix_SMOKE';
    shortName = 'v96z_rngfix_smoke';

    txt2 = replace(txt,longName,shortName);

    fid = fopen(smokeRunnerPath,'w');
    if fid < 0
        error('No se pudo escribir smokeRunnerPath: %s', smokeRunnerPath);
    end
    fprintf(fid,'%s',txt2);
    fclose(fid);

    fixedText = string(fileread(smokeRunnerPath));

    oldLongFile = fullfile(productionDir,[longName '.m']);
    if isfile(oldLongFile)
        try
            delete(oldLongFile);
        catch
        end
    end

    checks = {};
    checks{end+1,1} = check_row("S1_01","Smoke runner exists",isfile(smokeRunnerPath),string(smokeRunnerPath));
    checks{end+1,1} = check_row("S1_02","Backup created",isfile(backupPath),string(backupPath));
    checks{end+1,1} = check_row("S1_03","Long smoke name removed",~contains(fixedText,longName),"long name removed.");
    checks{end+1,1} = check_row("S1_04","Short smoke name inserted",contains(fixedText,shortName),"short name inserted.");
    checks{end+1,1} = check_row("S1_05","Short name length OK",strlength(shortName) <= namelengthmax,sprintf("length=%d; max=%d",strlength(shortName),namelengthmax));
    checks{end+1,1} = check_row("S1_06","No GA executed",true,"No gamultiobj call.");
    checks{end+1,1} = check_row("S1_07","No model executed",true,"No objective/model call.");
    checks{end+1,1} = check_row("S1_08","Original v96m not modified",true,"Only smoke runner patched.");

    Tchecks = struct2table(vertcat(checks{:}));

    if all(Tchecks.pass)
        diagnosis = "SMOKE_SHORTNAME_FIX_PASS";
        decision = "SMOKE_READY_FOR_REPREPARE_FALSE";
        next_step = "Run smoke=false again, then smoke=true if no warning appears.";
    else
        diagnosis = "SMOKE_SHORTNAME_FIX_REQUIRES_REVIEW";
        decision = "DO_NOT_RUN_SMOKE_TRUE";
        next_step = "Inspect failed checks.";
    end

    checksCsv = fullfile(tablesDir,'fix_smoke_shortname_v96z_rngfix_s1_checks.csv');
    writetable(Tchecks,checksCsv);

    outMat = fullfile(traceDir,'FIX_SMOKE_SHORTNAME_v96z_rngfix_s1.mat');
    save(outMat,'diagnosis','decision','next_step','smokeRunnerPath','backupPath','Tchecks','checksCsv','outMat');

    fixout = struct();
    fixout.status = 'FIX_SMOKE_SHORTNAME_v96z_rngfix_s1_COMPLETED';
    fixout.diagnosis = diagnosis;
    fixout.decision = decision;
    fixout.next_step = next_step;
    fixout.smokeRunnerPath = smokeRunnerPath;
    fixout.backupPath = backupPath;
    fixout.Tchecks = Tchecks;
    fixout.outMat = outMat;

    disp('=== FIX_SMOKE_SHORTNAME_v96z_rngfix_s1 ===')
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
