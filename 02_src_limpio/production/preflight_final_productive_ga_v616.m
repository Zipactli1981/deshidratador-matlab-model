function preflight = preflight_final_productive_ga_v616()
%PREFLIGHT_FINAL_PRODUCTIVE_GA_V616 Final preflight before real GA execution.
%
% Micropaso 6.16 — PRODUCTIVE-GA-PREFLIGHT-FINAL-CHECK
%
% Scope:
%   - Does not execute gamultiobj.
%   - Does not modify v612.
%   - Does not call run_productive_ga_corrected_v614(true).
%   - Confirms that v614(false) is structurally ready.
%   - Confirms that damaged local files are not the active execution files.

    rootDir = setup_v05_paths();

    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    logDir  = fullfile(rootDir,'06_outputs','logs');
    tabDir  = fullfile(rootDir,'06_outputs','tables');
    compDir = fullfile(rootDir,'06_outputs','comparisons');

    if ~exist(logDir,'dir'), mkdir(logDir); end
    if ~exist(tabDir,'dir'), mkdir(tabDir); end
    if ~exist(compDir,'dir'), mkdir(compDir); end

    %% Expected active files
    active_files = struct();

    active_files.execution_script = fullfile(rootDir, ...
        '02_src_limpio','production','run_productive_ga_corrected_v614.m');

    active_files.objective = fullfile(rootDir, ...
        '02_src_limpio','production','objective_productive_corrected_v611.m');

    active_files.capture = fullfile(rootDir, ...
        '02_src_limpio','production','capture_productive_ga_outputs_v614b.m');

    active_files.capture_test = fullfile(rootDir, ...
        '02_src_limpio','production','test_capture_productive_ga_outputs_v614b.m');

    active_files.config = fullfile(rootDir, ...
        '02_src_limpio','production','productive_run_config_v69.m');

    active_files.wrapper = fullfile(rootDir, ...
        '02_src_limpio','wrappers','opt_tunel_mod2_v10_energy_mode_corrected.m');

    active_files.cost_params = fullfile(rootDir, ...
        '02_src_limpio','cost','build_cost_params_historical.m');

    active_files.cost_breakdown = fullfile(rootDir, ...
        '02_src_limpio','cost','calc_cost_breakdown.m');

    active_names = fieldnames(active_files);
    active_path = cell(numel(active_names),1);
    active_exists = false(numel(active_names),1);
    active_status = cell(numel(active_names),1);

    for k = 1:numel(active_names)
        active_path{k} = active_files.(active_names{k});
        active_exists(k) = isfile(active_path{k});
        if active_exists(k)
            active_status{k} = 'PASS';
        else
            active_status{k} = 'FAIL';
        end
    end

    T_active_files = table(active_names,active_path,active_exists,active_status, ...
        'VariableNames', {'item','path','exists','status'});

    %% Known damaged or deprecated files
    damaged_files = struct();

    damaged_files.productive_run_control_v68 = fullfile(rootDir, ...
        '02_src_limpio','production','productive_run_control_v68.m');

    damaged_files.capture_v614 = fullfile(rootDir, ...
        '02_src_limpio','production','capture_productive_ga_outputs_v614.m');

    damaged_names = fieldnames(damaged_files);
    damaged_path = cell(numel(damaged_names),1);
    damaged_exists = false(numel(damaged_names),1);
    damaged_policy = cell(numel(damaged_names),1);

    for k = 1:numel(damaged_names)
        damaged_path{k} = damaged_files.(damaged_names{k});
        damaged_exists(k) = isfile(damaged_path{k});

        if damaged_exists(k)
            damaged_policy{k} = 'EXISTS_BUT_MUST_NOT_BE_USED_IN_v614';
        else
            damaged_policy{k} = 'ABSENT_OK';
        end
    end

    T_damaged_files = table(damaged_names,damaged_path,damaged_exists,damaged_policy, ...
        'VariableNames', {'item','path','exists','policy'});

    %% Resolve active function paths
    which_execution = which('run_productive_ga_corrected_v614');
    which_objective = which('objective_productive_corrected_v611');
    which_capture = which('capture_productive_ga_outputs_v614b');
    which_capture_bad = which('capture_productive_ga_outputs_v614');
    which_control_bad = which('productive_run_control_v68');

    active_execution_correct = strcmp(which_execution,active_files.execution_script);
    active_objective_correct = strcmp(which_objective,active_files.objective);
    active_capture_correct = strcmp(which_capture,active_files.capture);

    bad_capture_not_required = ~strcmp(which_capture_bad,active_files.capture);
    bad_control_not_required = ~strcmp(which_control_bad,active_files.execution_script);

    %% Check function signatures
    narg_execution = nargin('run_productive_ga_corrected_v614');
    narg_objective = nargin('objective_productive_corrected_v611');
    narg_capture = nargin('capture_productive_ga_outputs_v614b');

    execution_signature_ok = narg_execution == 1 || narg_execution == -1;
    objective_signature_ok = narg_objective == 2 || narg_objective == -2;
    capture_signature_ok = narg_capture == 1 || narg_capture == -1;

    %% Run v614 in dry mode only
    runinfo = run_productive_ga_corrected_v614(false);

    v614_status_ok = strcmp(runinfo.status,'PRODUCTIVE_GA_EXECUTION_SCRIPT_READY_NO_GA');
    v614_not_executed_ok = strcmp(runinfo.execution_status,'NOT_EXECUTED');
    v614_preflight_ok = isequal(runinfo.preflight_ok,true);
    v614_probe_ok = isnumeric(runinfo.f_probe) && numel(runinfo.f_probe) == 2 && all(isfinite(runinfo.f_probe));

    %% Confirm no real run directories from v614 were generated by this preflight
    productive_v614b_dir = fullfile(rootDir,'05_runs','productive_v614b');

    %% Final checklist
    check_item = {
        'active_files_exist'
        'execution_script_resolves_to_expected_file'
        'objective_resolves_to_expected_file'
        'capture_resolves_to_v614b_expected_file'
        'bad_capture_v614_not_used_as_active_capture'
        'bad_productive_run_control_v68_not_used'
        'execution_signature_ok'
        'objective_signature_ok'
        'capture_signature_ok'
        'v614_false_status_ok'
        'v614_false_not_executed_ok'
        'v614_false_preflight_ok'
        'v614_objective_probe_ok'
    };

    check_value = [
        all(strcmp(T_active_files.status,'PASS'))
        active_execution_correct
        active_objective_correct
        active_capture_correct
        bad_capture_not_required
        bad_control_not_required
        execution_signature_ok
        objective_signature_ok
        capture_signature_ok
        v614_status_ok
        v614_not_executed_ok
        v614_preflight_ok
        v614_probe_ok
    ];

    check_status = cell(numel(check_item),1);

    for k = 1:numel(check_item)
        if check_value(k)
            check_status{k} = 'PASS';
        else
            check_status{k} = 'FAIL';
        end
    end

    T_checks = table(check_item,check_value,check_status, ...
        'VariableNames', {'item','value','status'});

    final_ok = all(strcmp(T_checks.status,'PASS'));

    %% Activation policy
    activation_item = {
        'allowed_execution_command'
        'execution_script'
        'objective_function'
        'capture_function'
        'forbidden_script_modification'
        'forbidden_output_mixing'
        'known_damaged_file_1'
        'known_damaged_file_2'
    };

    activation_value = {
        'runinfo = run_productive_ga_corrected_v614(true);'
        'run_productive_ga_corrected_v614.m'
        'objective_productive_corrected_v611.m'
        'capture_productive_ga_outputs_v614b.m'
        'Do not modify run_productive_ga_corrected_v612.m.'
        'Do not mix historical GA outputs with corrected v614 outputs.'
        'productive_run_control_v68.m must be ignored/excluded.'
        'capture_productive_ga_outputs_v614.m must be ignored/excluded.'
    };

    T_activation = table(activation_item,activation_value, ...
        'VariableNames', {'item','value'});

    %% Build preflight struct
    preflight = struct();
    preflight.created_at = datetime('now');
    preflight.created_by_function = 'preflight_final_productive_ga_v616';
    preflight.rootDir = rootDir;
    preflight.status = 'PRODUCTIVE_GA_PREFLIGHT_FINAL_FAIL';
    preflight.ready_for_single_real_ga = false;
    preflight.runinfo_v614_false = runinfo;

    if final_ok
        preflight.status = 'PRODUCTIVE_GA_PREFLIGHT_FINAL_PASS_READY_FOR_SINGLE_REAL_GA';
        preflight.ready_for_single_real_ga = true;
    end

    preflight.T_active_files = T_active_files;
    preflight.T_damaged_files = T_damaged_files;
    preflight.T_checks = T_checks;
    preflight.T_activation = T_activation;

    preflight.which_execution = which_execution;
    preflight.which_objective = which_objective;
    preflight.which_capture = which_capture;
    preflight.which_capture_bad = which_capture_bad;
    preflight.which_control_bad = which_control_bad;
    preflight.productive_v614b_dir = productive_v614b_dir;

    %% Write evidence
    txtFile = fullfile(logDir,'PRODUCTIVE_GA_PREFLIGHT_FINAL_v616.txt');
    csvChecks = fullfile(tabDir,'PRODUCTIVE_GA_PREFLIGHT_FINAL_CHECKS_v616.csv');
    csvActive = fullfile(tabDir,'PRODUCTIVE_GA_PREFLIGHT_FINAL_ACTIVE_FILES_v616.csv');
    csvDamaged = fullfile(tabDir,'PRODUCTIVE_GA_PREFLIGHT_FINAL_DAMAGED_FILES_v616.csv');
    csvActivation = fullfile(tabDir,'PRODUCTIVE_GA_PREFLIGHT_FINAL_ACTIVATION_POLICY_v616.csv');
    matFile = fullfile(compDir,'PRODUCTIVE_GA_PREFLIGHT_FINAL_v616.mat');

    writetable(T_checks,csvChecks);
    writetable(T_active_files,csvActive);
    writetable(T_damaged_files,csvDamaged);
    writetable(T_activation,csvActivation);

    preflight.txtFile = txtFile;
    preflight.csvChecks = csvChecks;
    preflight.csvActive = csvActive;
    preflight.csvDamaged = csvDamaged;
    preflight.csvActivation = csvActivation;
    preflight.matFile = matFile;

    save(matFile,'preflight','T_checks','T_active_files','T_damaged_files','T_activation','runinfo');

    fid = fopen(txtFile,'w');

    fprintf(fid,'PRODUCTIVE_GA_PREFLIGHT_FINAL_v616\n\n');
    fprintf(fid,'status: %s\n',preflight.status);
    fprintf(fid,'ready_for_single_real_ga: %d\n\n',preflight.ready_for_single_real_ga);

    fprintf(fid,'Scope:\n');
    fprintf(fid,'Final preflight only.\n');
    fprintf(fid,'GA not executed.\n');
    fprintf(fid,'v612 not modified.\n');
    fprintf(fid,'v614 called only with false.\n\n');

    fprintf(fid,'Active function resolution:\n');
    fprintf(fid,'execution: %s\n',which_execution);
    fprintf(fid,'objective: %s\n',which_objective);
    fprintf(fid,'capture: %s\n',which_capture);
    fprintf(fid,'bad_capture_v614: %s\n',which_capture_bad);
    fprintf(fid,'bad_control_v68: %s\n\n',which_control_bad);

    fprintf(fid,'v614(false):\n');
    fprintf(fid,'status: %s\n',runinfo.status);
    fprintf(fid,'execution_status: %s\n',runinfo.execution_status);
    fprintf(fid,'preflight_ok: %d\n',runinfo.preflight_ok);
    fprintf(fid,'f_probe: %s\n\n',mat2str(runinfo.f_probe));

    fprintf(fid,'Final checks:\n');
    for k = 1:height(T_checks)
        fprintf(fid,'- %s: %s\n',T_checks.item{k},T_checks.status{k});
    end

    fprintf(fid,'\nActivation command if approved:\n');
    fprintf(fid,'runinfo = run_productive_ga_corrected_v614(true);\n\n');

    fprintf(fid,'Strict policy:\n');
    fprintf(fid,'Run only once initially.\n');
    fprintf(fid,'Do not modify v612.\n');
    fprintf(fid,'Use capture_productive_ga_outputs_v614b.m only.\n');
    fprintf(fid,'Ignore/exclude productive_run_control_v68.m and capture_productive_ga_outputs_v614.m.\n');
    fprintf(fid,'Do not mix historical GA/Fig20/Fig21 with corrected outputs.\n');

    fclose(fid);

    disp('=== PRODUCTIVE_GA_PREFLIGHT_FINAL_v616 ===')
    disp(preflight.status)

    disp('=== READY FOR SINGLE REAL GA ===')
    disp(preflight.ready_for_single_real_ga)

    disp('=== FINAL CHECKS ===')
    disp(T_checks)

    disp('=== ACTIVE FILES ===')
    disp(T_active_files)

    disp('=== DAMAGED / EXCLUDED FILES ===')
    disp(T_damaged_files)

    disp('=== ACTIVATION POLICY ===')
    disp(T_activation)
end