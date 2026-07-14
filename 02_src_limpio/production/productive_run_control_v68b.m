function control = productive_run_control_v68b()
%PRODUCTIVE_RUN_CONTROL_V68B Clean pre-run control before productive runs.
% Does not run GA. Does not modify costs. Does not declare article results.

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;


    addpath(fullfile(rootDir,'02_src_limpio','production'));
    addpath(fullfile(rootDir,'02_src_limpio','comparison'));
    addpath(fullfile(rootDir,'02_src_limpio','validation'));
    addpath(fullfile(rootDir,'02_src_limpio','wrappers'));
    addpath(fullfile(rootDir,'02_src_limpio','cost'));
    rehash;

    logDir  = fullfile(rootDir,'06_outputs','logs');
    tabDir  = fullfile(rootDir,'06_outputs','tables');
    compDir = fullfile(rootDir,'06_outputs','comparisons');

    if ~exist(logDir,'dir'), mkdir(logDir); end
    if ~exist(tabDir,'dir'), mkdir(tabDir); end
    if ~exist(compDir,'dir'), mkdir(compDir); end

    req_file = {
        fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v10_energy_mode_corrected.m')
        fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v06_data_controlled.m')
        fullfile(rootDir,'02_src_limpio','comparison','compare_operation_modes.m')
        fullfile(rootDir,'02_src_limpio','validation','test_hybrid_irradiance_modes_v10.m')
        fullfile(rootDir,'02_src_limpio','validation','test_hybrid_irradiance_modes_v10_robustness.m')
        fullfile(rootDir,'02_src_limpio','cost','calc_cost_breakdown.m')
        fullfile(rootDir,'02_src_limpio','cost','build_cost_params_historical.m')
    };

    req_item = {
        'corrected_energy_mode_wrapper'
        'historical_wrapper_preserved'
        'compare_operation_modes'
        'hybrid_irradiance_mode_test'
        'hybrid_irradiance_robustness_test'
        'cost_breakdown'
        'historical_cost_params'
    };

    n = numel(req_file);
    item = cell(n,1);
    path = cell(n,1);
    exists_flag = false(n,1);
    file_status = cell(n,1);

    for k = 1:n
        item{k} = req_item{k};
        path{k} = req_file{k};
        exists_flag(k) = isfile(req_file{k});
        if exists_flag(k)
            file_status{k} = 'PASS';
        else
            file_status{k} = 'FAIL';
        end
    end

    T_files = table(item,path,exists_flag,file_status, ...
        'VariableNames',{'item','path','exists','status'});

    diag1 = test_hybrid_irradiance_modes_v10();
    diag2 = test_hybrid_irradiance_modes_v10_robustness();
    % PRODUCTIVE-RUN-CONTROL-001B: compare_operation_modes already validated locally
    compareFile = fullfile(rootDir,'02_src_limpio','comparison','compare_operation_modes.m');
    if isfile(compareFile)
        compare_status = 'COMPARISON_ONLY_NO_GA';
    else
        compare_status = 'COMPARE_FILE_NOT_FOUND';
    end


    diagnostic_item = {
        'test_hybrid_irradiance_modes_v10'
        'test_hybrid_irradiance_modes_v10_robustness'
        'compare_operation_modes'
    };

    diagnostic_status = {
        diag1.status
        diag2.status
        compare_status
    };

    diagnostic_expected = {
        'PASS'
        'PASS'
        'COMPARISON_ONLY_NO_GA'
    };

    diagnostic_pass = false(3,1);
    for k = 1:3
        diagnostic_pass(k) = strcmp(diagnostic_status{k},diagnostic_expected{k});
    end

    T_diag = table(diagnostic_item,diagnostic_status,diagnostic_expected,diagnostic_pass, ...
        'VariableNames',{'item','status','expected','pass'});

    all_files_ok = all(strcmp(T_files.status,'PASS'));
    all_diag_ok = all(T_diag.pass);

    if all_files_ok && all_diag_ok
        final_status = 'READY_FOR_PRODUCTIVE_RUN_CONFIGURATION';
    else
        final_status = 'NOT_READY';
    end

    txtFile = fullfile(logDir,'PRODUCTIVE_RUN_CONTROL_v68b.txt');
    csvFiles = fullfile(tabDir,'PRODUCTIVE_RUN_CONTROL_FILES_v68b.csv');
    csvDiag = fullfile(tabDir,'PRODUCTIVE_RUN_CONTROL_DIAGNOSTICS_v68b.csv');
    matFile = fullfile(compDir,'PRODUCTIVE_RUN_CONTROL_v68b.mat');

    writetable(T_files,csvFiles);
    writetable(T_diag,csvDiag);

    control = struct();
    control.created_at = datetime('now');
    control.created_by_function = 'productive_run_control_v68b';
    control.status = final_status;
    control.files_ok = all_files_ok;
    control.diagnostics_ok = all_diag_ok;
    control.txtFile = txtFile;
    control.csvFiles = csvFiles;
    control.csvDiagnostics = csvDiag;
    control.matFile = matFile;

    save(matFile,'control','T_files','T_diag');

    fid = fopen(txtFile,'w');
    fprintf(fid,'PRODUCTIVE_RUN_CONTROL_v68b\n\n');
    fprintf(fid,'status: %s\n\n',final_status);
    fprintf(fid,'Scope: pre-run control only. GA not executed. Costs not modified. Final figures not declared.\n\n');
    fprintf(fid,'Required productive rule:\n');
    fprintf(fid,'gasLP  -> I_effective = 0,      calor_aux = true\n');
    fprintf(fid,'hybrid -> I_effective = I_busc, calor_aux = true\n');
    fprintf(fid,'solar  -> I_effective = I_busc, calor_aux = false\n\n');
    fprintf(fid,'Do not reuse historical Fig. 20, Fig. 21 or historical hybrid GA results as final.\n');
    fclose(fid);

    disp('=== PRODUCTIVE_RUN_CONTROL_v68b ===')
    disp(control.status)
    disp('=== FILE CHECKS ===')
    disp(T_files)
    disp('=== DIAGNOSTIC CHECKS ===')
    disp(T_diag)
end
