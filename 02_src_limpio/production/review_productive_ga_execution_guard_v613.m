function review = review_productive_ga_execution_guard_v613()
%REVIEW_PRODUCTIVE_GA_EXECUTION_GUARD_V613 Review GA execution guard.
%
% Micropaso 6.13 — PRODUCTIVE-GA-EXECUTION-GUARD-REVIEW
%
% Scope:
%   - Inspect run_productive_ga_corrected_v612.m.
%   - Confirm EXECUTE_GA remains false.
%   - Identify the exact line that would enable GA execution later.
%   - Confirm mandatory output contract before first real productive GA.
%
% This function does not execute gamultiobj.
% This function does not modify run_productive_ga_corrected_v612.m.
% This function does not recalculate Fig. 20 or Fig. 21.

    rootDir = setup_v05_paths();

    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    logDir  = fullfile(rootDir,'06_outputs','logs');
    tabDir  = fullfile(rootDir,'06_outputs','tables');
    compDir = fullfile(rootDir,'06_outputs','comparisons');

    if ~exist(logDir,'dir'), mkdir(logDir); end
    if ~exist(tabDir,'dir'), mkdir(tabDir); end
    if ~exist(compDir,'dir'), mkdir(compDir); end

    %% Target dry-run script
    scriptFile = fullfile(rootDir, ...
        '02_src_limpio','production','run_productive_ga_corrected_v612.m');

    txt = fileread(scriptFile);
    lines = regexp(txt,'\r\n|\n|\r','split');

    %% Locate execution guard
    guard_pattern = 'EXECUTE_GA = false;';
    forbidden_pattern = 'EXECUTE_GA = true;';

    guard_line = NaN;
    forbidden_line = NaN;

    for k = 1:numel(lines)
        if contains(lines{k},guard_pattern)
            guard_line = k;
        end

        if contains(lines{k},forbidden_pattern)
            forbidden_line = k;
        end
    end

    guard_present = ~isnan(guard_line);
    forbidden_true_absent = isnan(forbidden_line);

    %% Locate hard error block
    hard_error_present = contains(txt,'PRODUCTIVE-GA-DRYRUN-INTEGRATION-001 blocks GA execution');

    %% Confirm objective and output contract references
    objective_reference_present = contains(txt,'objective_productive_corrected_v611');
    output_contract_present = contains(txt,'GA_HISTORY_CORRECTED_v612_REQUIRED.mat') && ...
                              contains(txt,'GA_FINAL_POPULATION_CORRECTED_v612_REQUIRED.csv') && ...
                              contains(txt,'GA_FINAL_SCORES_CORRECTED_v612_REQUIRED.csv') && ...
                              contains(txt,'PARETO_CORRECTED_v612_REQUIRED.csv') && ...
                              contains(txt,'SELECTED_SOLUTION_CORRECTED_v612_REQUIRED.csv') && ...
                              contains(txt,'MODE_COMPARISON_CORRECTED_v612_REQUIRED.csv') && ...
                              contains(txt,'FIG20_SOURCE_CORRECTED_v612_REQUIRED.csv') && ...
                              contains(txt,'FIG21_SOURCE_CORRECTED_v612_REQUIRED.csv');

    %% Confirm no direct gamultiobj call is active
    gamultiobj_mentions = false(numel(lines),1);
    active_gamultiobj_lines = {};

    for k = 1:numel(lines)
        line_k = strtrim(lines{k});
        if contains(line_k,'gamultiobj')
            gamultiobj_mentions(k) = true;

            is_comment = startsWith(line_k,'%');
            is_text = contains(line_k,'gamultiobj not executed') || ...
                      contains(line_k,'gamultiobj_available') || ...
                      contains(line_k,'''gamultiobj''') || ...
                      contains(line_k,'gamultiobj in Micropaso');

            if ~is_comment && ~is_text
                active_gamultiobj_lines{end+1,1} = sprintf('%d: %s',k,line_k);
            end
        end
    end

    active_gamultiobj_absent = isempty(active_gamultiobj_lines);

    %% Check dry-run by executing v612 once
    runinfo = run_productive_ga_corrected_v612();

    dryrun_status_ok = strcmp(runinfo.status,'PRODUCTIVE_GA_DRYRUN_INTEGRATION_READY_NO_GA');
    execute_ga_false_ok = isequal(runinfo.execute_ga,false);
    execution_not_executed_ok = strcmp(runinfo.execution_status,'NOT_EXECUTED');

    %% Review table
    item = {
        'script_file_exists'
        'guard_execute_ga_false_present'
        'guard_execute_ga_true_absent'
        'hard_error_block_present'
        'objective_reference_present'
        'output_contract_present'
        'active_gamultiobj_call_absent'
        'v612_dryrun_status_ok'
        'v612_execute_ga_false_ok'
        'v612_execution_not_executed_ok'
    };

    value = [
        isfile(scriptFile)
        guard_present
        forbidden_true_absent
        hard_error_present
        objective_reference_present
        output_contract_present
        active_gamultiobj_absent
        dryrun_status_ok
        execute_ga_false_ok
        execution_not_executed_ok
    ];

    status = cell(numel(item),1);

    for k = 1:numel(item)
        if value(k)
            status{k} = 'PASS';
        else
            status{k} = 'FAIL';
        end
    end

    T_review = table(item,value,status, ...
        'VariableNames', {'item','value','status'});

    %% Future activation table
    activation_item = {
        'line_to_change'
        'current_line'
        'future_line'
        'required_before_activation'
        'first_real_run_policy'
        'forbidden_before_activation'
    };

    activation_value = {
        sprintf('line %g in run_productive_ga_corrected_v612.m',guard_line)
        'EXECUTE_GA = false;'
        'EXECUTE_GA = true;'
        'Create execution version v614 or later; do not modify v612 in place.'
        'Run one controlled GA only after output capture code is implemented.'
        'Do not run GA before final population, scores, history, Pareto, selected solution, Fig20 source and Fig21 source are saved.'
    };

    T_activation = table(activation_item,activation_value, ...
        'VariableNames', {'item','value'});

    %% Mandatory first real GA outputs
    required_output = {
        'GA history MAT'
        'Final population CSV'
        'Final scores CSV'
        'Pareto corrected CSV'
        'Selected solution CSV'
        'Corrected mode comparison CSV'
        'Fig. 20 source CSV'
        'Fig. 21 source CSV'
        'Run log TXT'
        'Configuration MAT'
    };

    required_reason = {
        'Convergence cannot be reconstructed after run'
        'Required for reproducibility'
        'Required for objective verification'
        'Required for Pareto analysis'
        'Required for selected operating point'
        'Required for gasLP/hybrid/solar comparison'
        'Required to recalculate Fig. 20'
        'Required to recalculate Fig. 21'
        'Required for audit trail'
        'Required for reproducibility'
    };

    required_status = repmat({'REQUIRED_BEFORE_REAL_GA'},numel(required_output),1);

    T_required = table(required_output,required_reason,required_status, ...
        'VariableNames', {'output','reason','status'});

    %% Final status
    review_ok = all(strcmp(T_review.status,'PASS'));

    review = struct();
    review.created_at = datetime('now');
    review.created_by_function = 'review_productive_ga_execution_guard_v613';
    review.scriptFile = scriptFile;
    review.guard_line = guard_line;
    review.active_gamultiobj_lines = active_gamultiobj_lines;
    review.runinfo_v612 = runinfo;

    if review_ok
        review.status = 'EXECUTION_GUARD_REVIEW_PASS_GA_STILL_BLOCKED';
    else
        review.status = 'EXECUTION_GUARD_REVIEW_FAIL';
    end

    %% Write evidence
    txtFile = fullfile(logDir,'PRODUCTIVE_GA_EXECUTION_GUARD_REVIEW_v613.txt');
    csvReview = fullfile(tabDir,'PRODUCTIVE_GA_EXECUTION_GUARD_REVIEW_v613.csv');
    csvActivation = fullfile(tabDir,'PRODUCTIVE_GA_EXECUTION_ACTIVATION_PLAN_v613.csv');
    csvRequired = fullfile(tabDir,'PRODUCTIVE_GA_FIRST_RUN_REQUIRED_OUTPUTS_v613.csv');
    matFile = fullfile(compDir,'PRODUCTIVE_GA_EXECUTION_GUARD_REVIEW_v613.mat');

    writetable(T_review,csvReview);
    writetable(T_activation,csvActivation);
    writetable(T_required,csvRequired);

    review.txtFile = txtFile;
    review.csvReview = csvReview;
    review.csvActivation = csvActivation;
    review.csvRequired = csvRequired;
    review.matFile = matFile;

    save(matFile,'review','T_review','T_activation','T_required','runinfo');

    fid = fopen(txtFile,'w');

    fprintf(fid,'PRODUCTIVE_GA_EXECUTION_GUARD_REVIEW_v613\n\n');
    fprintf(fid,'status: %s\n\n',review.status);

    fprintf(fid,'Scope:\n');
    fprintf(fid,'Execution guard review only.\n');
    fprintf(fid,'GA not executed.\n');
    fprintf(fid,'run_productive_ga_corrected_v612.m not modified.\n');
    fprintf(fid,'Fig. 20 not recalculated.\n');
    fprintf(fid,'Fig. 21 not recalculated.\n\n');

    fprintf(fid,'Script reviewed:\n%s\n\n',scriptFile);

    fprintf(fid,'Guard:\n');
    fprintf(fid,'line: %g\n',guard_line);
    fprintf(fid,'current: EXECUTE_GA = false;\n');
    fprintf(fid,'future activation: EXECUTE_GA = true;\n\n');

    fprintf(fid,'Activation rule:\n');
    fprintf(fid,'Do not modify v612 in place.\n');
    fprintf(fid,'Create a new execution version v614 or later.\n');
    fprintf(fid,'Before activation, implement output capture for GA history, final population, final scores, Pareto, selected solution, mode comparison, Fig20 source and Fig21 source.\n\n');

    fprintf(fid,'v612 dry-run confirmation:\n');
    fprintf(fid,'status: %s\n',runinfo.status);
    fprintf(fid,'execute_ga: %d\n',runinfo.execute_ga);
    fprintf(fid,'execution_status: %s\n\n',runinfo.execution_status);

    fprintf(fid,'First real GA required outputs:\n');
    for k = 1:height(T_required)
        fprintf(fid,'- %s | %s\n',T_required.output{k},T_required.reason{k});
    end

    fprintf(fid,'\nTraceability rule:\n');
    fprintf(fid,'Do not mix historical GA outputs with corrected productive outputs.\n');
    fprintf(fid,'Do not use historical Fig. 20 or Fig. 21 as final.\n');

    fclose(fid);

    disp('=== PRODUCTIVE_GA_EXECUTION_GUARD_REVIEW_v613 ===')
    disp(review.status)

    disp('=== REVIEW CHECKS ===')
    disp(T_review)

    disp('=== ACTIVATION PLAN ===')
    disp(T_activation)

    disp('=== FIRST REAL GA REQUIRED OUTPUTS ===')
    disp(T_required)
end