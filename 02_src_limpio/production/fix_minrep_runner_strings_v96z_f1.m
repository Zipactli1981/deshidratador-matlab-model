function fixout = fix_minrep_runner_strings_v96z_f1()% FIX_SEED_CONTROLLED_MINREP_RUNNER_TABLE_STRINGS_v96z_minrep_fix1
%
% Corrige el runner:
%   run_seed_controlled_minrep_formal_ga_v96z_minrep.m
%
% Problema:
%   Asignaciones tipo repmat('',height(T),1) generan arreglos vacíos y
%   fallan al crear variables de tabla.
%
% Este fix:
%   - NO ejecuta GA.
%   - NO llama modelo.
%   - NO llama función objetivo.
%   - NO modifica 05_runs.
%   - Solo corrige el runner seed-controlled en production.
%
% Uso:
%   fixout = fix_seed_controlled_minrep_runner_table_strings_v96z_minrep_fix1();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    productionDir = fullfile(rootDir,'02_src_limpio','production');
    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    articleTraceDir = fullfile(articleRoot,'traceability');
    articleTablesDir = fullfile(articleRoot,'tables');
    articleReviewDir = fullfile(articleRoot,'review');

    mkdir_if_needed(articleTraceDir);
    mkdir_if_needed(articleTablesDir);
    mkdir_if_needed(articleReviewDir);

    runnerPath = fullfile(productionDir,'run_seed_controlled_minrep_formal_ga_v96z_minrep.m');

    if ~isfile(runnerPath)
        error('No existe runnerPath: %s', runnerPath);
    end

    txt = string(fileread(runnerPath));

    timestamp = datestr(now,'yyyymmdd_HHMMSS');
    backupPath = fullfile(productionDir, ...
        ['run_seed_controlled_minrep_formal_ga_v96z_minrep_BACKUP_BEFORE_FIX1_' timestamp '.m']);

    copyfile(runnerPath,backupPath);

    replacements = {
        "Treplicates.seed_rng_type = repmat('twister',height(Treplicates),1);", ...
        "Treplicates.seed_rng_type = repmat(""twister"",height(Treplicates),1);"

        "Treplicates.run_status = repmat('NOT_EXECUTED',height(Treplicates),1);", ...
        "Treplicates.run_status = repmat(""NOT_EXECUTED"",height(Treplicates),1);"

        "Treplicates.diagnosis = repmat('',height(Treplicates),1);", ...
        "Treplicates.diagnosis = strings(height(Treplicates),1);"

        "Treplicates.output_mat = repmat('',height(Treplicates),1);", ...
        "Treplicates.output_mat = strings(height(Treplicates),1);"

        "Treplicates.error_message = repmat('',height(Treplicates),1);", ...
        "Treplicates.error_message = strings(height(Treplicates),1);"

        "Treplicates.run_status(i) = 'OK';", ...
        "Treplicates.run_status(i) = ""OK"";"

        "Treplicates.diagnosis(i) = 'NO_DIAGNOSIS_FIELD';", ...
        "Treplicates.diagnosis(i) = ""NO_DIAGNOSIS_FIELD"";"

        "Treplicates.run_status(i) = 'ERROR';", ...
        "Treplicates.run_status(i) = ""ERROR"";"

        "Treplicates.diagnosis(i) = 'ERROR';", ...
        "Treplicates.diagnosis(i) = ""ERROR"";"

        "all(Treplicates.run_status ~= 'NOT_EXECUTED')", ...
        "all(Treplicates.run_status ~= ""NOT_EXECUTED"")"

        "sum(Treplicates.run_status ~= 'NOT_EXECUTED')", ...
        "sum(Treplicates.run_status ~= ""NOT_EXECUTED"")"

        "all(Treplicates.run_status == 'OK')", ...
        "all(Treplicates.run_status == ""OK"")"

        "sum(Treplicates.run_status == 'OK')", ...
        "sum(Treplicates.run_status == ""OK"")"
    };

    nApplied = 0;
    for k = 1:size(replacements,1)
        before = txt;
        txt = replace(txt,replacements{k,1},replacements{k,2});
        if before ~= txt
            nApplied = nApplied + 1;
        end
    end

    fid = fopen(runnerPath,'w');
    if fid < 0
        error('No se pudo reescribir runnerPath: %s', runnerPath);
    end
    fprintf(fid,'%s',txt);
    fclose(fid);

    % Verificación textual
    fixedText = string(fileread(runnerPath));

    has_bad_empty_repmat = contains(fixedText,"repmat('',height(Treplicates),1)");
    has_string_status = contains(fixedText,'Treplicates.run_status = repmat("NOT_EXECUTED",height(Treplicates),1);');
    has_string_diagnosis = contains(fixedText,'Treplicates.diagnosis = strings(height(Treplicates),1);');
    has_string_output = contains(fixedText,'Treplicates.output_mat = strings(height(Treplicates),1);');
    has_string_error = contains(fixedText,'Treplicates.error_message = strings(height(Treplicates),1);');

    checks = {};
    checks{end+1,1} = check_row("FX1_01","Runner exists",isfile(runnerPath),string(runnerPath));
    checks{end+1,1} = check_row("FX1_02","Backup created",isfile(backupPath),string(backupPath));
    checks{end+1,1} = check_row("FX1_03","Replacements applied",nApplied >= 10,sprintf("nApplied=%d",nApplied));
    checks{end+1,1} = check_row("FX1_04","Bad empty repmat removed",~has_bad_empty_repmat,"No repmat('',height(...),1) remains.");
    checks{end+1,1} = check_row("FX1_05","String run_status initialized",has_string_status,"run_status string array.");
    checks{end+1,1} = check_row("FX1_06","String diagnosis initialized",has_string_diagnosis,"diagnosis string array.");
    checks{end+1,1} = check_row("FX1_07","String output_mat initialized",has_string_output,"output_mat string array.");
    checks{end+1,1} = check_row("FX1_08","String error_message initialized",has_string_error,"error_message string array.");
    checks{end+1,1} = check_row("FX1_09","No GA executed",true,"No gamultiobj call.");
    checks{end+1,1} = check_row("FX1_10","No model executed",true,"No objective/model call.");
    checks{end+1,1} = check_row("FX1_11","No 05_runs modified",true,"Only production runner patched.");

    Tchecks = struct2table(vertcat(checks{:}));

    if all(Tchecks.pass)
        diagnosis = "SEED_CONTROLLED_MINREP_RUNNER_FIX1_PASS";
        decision = "RUNNER_READY_FOR_PREFLIGHT_RETRY";
        next_step = "Retry: pre = run_seed_controlled_minrep_formal_ga_v96z_minrep(false)";
    else
        diagnosis = "SEED_CONTROLLED_MINREP_RUNNER_FIX1_REQUIRES_REVIEW";
        decision = "REVIEW_FAILED_FIX1_CHECKS";
        next_step = "Inspect runner before retrying preflight.";
    end

    checksCsv = fullfile(articleTablesDir,'seed_controlled_runner_fix1_checks_v96z_minrep.csv');
    writetable(Tchecks,checksCsv);

    fixMat = fullfile(articleTraceDir,'SEED_CONTROLLED_MINREP_RUNNER_FIX1_v96z_minrep.mat');

    save(fixMat, ...
        'diagnosis','decision','next_step', ...
        'runnerPath','backupPath','nApplied','Tchecks','checksCsv','fixMat');

    fixout = struct();
    fixout.status = 'SEED_CONTROLLED_MINREP_RUNNER_FIX1_COMPLETED';
    fixout.diagnosis = diagnosis;
    fixout.decision = decision;
    fixout.next_step = next_step;
    fixout.runnerPath = runnerPath;
    fixout.backupPath = backupPath;
    fixout.nApplied = nApplied;
    fixout.Tchecks = Tchecks;
    fixout.fixMat = fixMat;

    disp('=== SEED_CONTROLLED_MINREP_RUNNER_FIX1_v96z_minrep ===')
    disp(fixout.status)
    disp('=== DIAGNOSIS ===')
    disp(fixout.diagnosis)
    disp('=== DECISION ===')
    disp(fixout.decision)
    disp('=== NEXT STEP ===')
    disp(fixout.next_step)
    disp('=== RUNNER ===')
    disp(fixout.runnerPath)
    disp('=== BACKUP ===')
    disp(fixout.backupPath)
    disp('=== REPLACEMENTS APPLIED ===')
    disp(fixout.nApplied)
    disp('=== CHECKS ===')
    disp(fixout.Tchecks)

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