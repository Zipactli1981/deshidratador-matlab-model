function audit = postrun_audit_r1_seedaware_v96z(projectRoot, writeOutputs)
%POSTRUN_AUDIT_R1_SEEDAWARE_V96Z Audit existing R1 evidence without rerunning it.
%
% This function:
%   - only reads existing MAT and text evidence;
%   - never calls the model, gamultiobj, R1, R2, or R3;
%   - does not modify any existing R1 artifact;
%   - optionally writes new Markdown/CSV audit files.
%
% Usage without writing:
%   audit = postrun_audit_r1_seedaware_v96z();
%
% Explicitly write new audit outputs:
%   audit = postrun_audit_r1_seedaware_v96z([], true);

    if nargin < 1 || isempty(projectRoot)
        thisFile = mfilename('fullpath');
        projectRoot = fileparts(fileparts(fileparts(thisFile)));
    end
    if nargin < 2 || isempty(writeOutputs)
        writeOutputs = false;
    end

    projectRoot = char(projectRoot);

    formalDir = fullfile(projectRoot, '05_runs', ...
        'triobjective_formal_ga_v96m', ...
        'TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix_20260727_185506');
    formalMat = fullfile(formalDir, 'mat', ...
        'TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix.mat');
    rawMat = fullfile(formalDir, 'mat', ...
        'TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix_raw.mat');

    r1RunDir = fullfile(projectRoot, '06_manuscript', 'article_Q1', 'runs', ...
        'SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix_20260727_185454');
    r1Mat = fullfile(r1RunDir, 'R1', ...
        'SEEDAWARE_FORMAL_R1_ONLY_seed_61001_output.mat');
    traceMat = fullfile(projectRoot, '06_manuscript', 'article_Q1', ...
        'traceability', 'SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix.mat');

    expectedFormalHash = ...
        'E550F09ED17030F1318ADEC6A4F5F5FA97194E147BAC31132B8123AC6A488170';
    expectedR1Hash = ...
        'A04D1ADCD769CE9D8ED858FA321D7AF6A22E42D1F8A954094084B4B5A2A2ECD0';

    requiredFiles = {formalMat, rawMat, r1Mat, traceMat};
    for k = 1:numel(requiredFiles)
        if ~isfile(requiredFiles{k})
            error('POSTRUN:R1:MissingEvidence', ...
                'Missing required R1 evidence: %s', requiredFiles{k});
        end
    end

    formalHash = sha256_file(formalMat);
    rawHash = sha256_file(rawMat);
    r1Hash = sha256_file(r1Mat);
    traceHash = sha256_file(traceMat);

    S = load(formalMat);
    R = load(rawMat);
    W = load(r1Mat);
    T = load(traceMat);

    checks = {};

    checks{end+1,1} = check_row('A01', 'Formal MAT SHA-256', ...
        formalHash == string(expectedFormalHash), 'REQUIRED', ...
        formalHash, expectedFormalHash);
    checks{end+1,1} = check_row('A02', 'Wrapper R1 MAT SHA-256', ...
        r1Hash == string(expectedR1Hash), 'REQUIRED', ...
        r1Hash, expectedR1Hash);

    checks{end+1,1} = check_row('A03', 'Formal MAT contains X and F', ...
        isfield(S,'X') && isfield(S,'F'), 'REQUIRED', ...
        field_evidence(S, {'X','F'}), 'X and F must exist');
    checks{end+1,1} = check_row('A04', 'Raw MAT contains opts', ...
        isfield(R,'opts'), 'REQUIRED', ...
        field_evidence(R, {'opts'}), 'opts must exist in raw MAT');
    checks{end+1,1} = check_row('A05', 'Formal MAT contains population and scores', ...
        isfield(S,'population') && isfield(S,'scores'), 'REQUIRED', ...
        field_evidence(S, {'population','scores'}), ...
        'population and scores must exist');

    formalShapeOk = isfield(S,'X') && isfield(S,'F') && ...
        isequal(size(S.X), [9 4]) && isequal(size(S.F), [9 3]);
    checks{end+1,1} = check_row('A06', 'Formal X/F dimensions', ...
        formalShapeOk, 'REQUIRED', ...
        shape_evidence(S), 'X=9x4 and F=9x3');

    r1ShapeOk = isfield(W,'X') && isfield(W,'F') && ...
        isequal(size(W.X), [9 4]) && isequal(size(W.F), [9 3]);
    checks{end+1,1} = check_row('A07', 'Wrapper R1 X/F dimensions', ...
        r1ShapeOk, 'REQUIRED', ...
        shape_evidence(W), 'X=9x4 and F=9x3');

    xfConsistent = formalShapeOk && r1ShapeOk && ...
        isequaln(S.X, W.X) && isequaln(S.F, W.F);
    checks{end+1,1} = check_row('A08', 'Formal and wrapper X/F are identical', ...
        xfConsistent, 'REQUIRED', ...
        numeric_diff_evidence(S, W), 'Exact equality expected');

    fHasThreeColumns = isfield(S,'F') && size(S.F,2) == 3;
    nSolutions = safe_size(S, 'F', 1);
    nFiniteRows = count_finite_rows(S);
    nPenaltyRows = count_penalty_rows(S);

    checks{end+1,1} = check_row('A09', 'F has three objectives', ...
        fHasThreeColumns, 'REQUIRED', ...
        sprintf('F columns=%d', safe_size(S,'F',2)), 'F columns=3');
    checks{end+1,1} = check_row('A10', 'Nine solutions are present', ...
        nSolutions == 9, 'REQUIRED', ...
        sprintf('nSolutions=%d', nSolutions), 'nSolutions=9');
    checks{end+1,1} = check_row('A11', 'Nine finite solution rows', ...
        nFiniteRows == 9, 'REQUIRED', ...
        sprintf('nFiniteRows=%d', nFiniteRows), 'nFiniteRows=9');
    checks{end+1,1} = check_row('A12', 'No penalized solution rows', ...
        nPenaltyRows == 0, 'REQUIRED', ...
        sprintf('nPenaltyRows=%d', nPenaltyRows), 'nPenaltyRows=0');

    populationOk = isfield(S,'population') && isequal(size(S.population), [24 4]);
    scoresOk = isfield(S,'scores') && isequal(size(S.scores), [24 3]) && ...
        all(isfinite(S.scores), 'all');
    checks{end+1,1} = check_row('A13', 'Final population dimensions', ...
        populationOk, 'REQUIRED', ...
        matrix_shape_text(S, 'population'), 'population=24x4');
    checks{end+1,1} = check_row('A14', 'Final scores dimensions and finiteness', ...
        scoresOk, 'REQUIRED', ...
        matrix_shape_text(S, 'scores'), 'scores=24x3 and finite');

    popSize = scalar_or_nan(S, 'popSize');
    maxGen = scalar_or_nan(S, 'maxGen');
    checks{end+1,1} = check_row('A15', 'PopulationSize preserved', ...
        popSize == 24, 'REQUIRED', ...
        sprintf('popSize=%g', popSize), 'PopulationSize=24');
    checks{end+1,1} = check_row('A16', 'MaxGenerations preserved', ...
        maxGen == 50, 'REQUIRED', ...
        sprintf('maxGen=%g', maxGen), 'MaxGenerations=50');

    optsPopulationOk = option_equals(R, 'PopulationSize', 24);
    optsGenerationsOk = option_equals(R, 'MaxGenerations', 50);
    checks{end+1,1} = check_row('A17', 'Saved opts preserve GA dimensions', ...
        optsPopulationOk && optsGenerationsOk, 'REQUIRED', ...
        sprintf('opts.PopulationSize=%s; opts.MaxGenerations=%s', ...
            option_text(R,'PopulationSize'), option_text(R,'MaxGenerations')), ...
        '24 and 50');

    hasFormal = isfield(W,'formal') && isstruct(W.formal);
    seedOk = hasFormal && isfield(W.formal,'rngSeed_v96z') && ...
        isequal(double(W.formal.rngSeed_v96z), 61001);
    controlOk = hasFormal && isfield(W.formal,'rngControl_v96z') && ...
        string(W.formal.rngControl_v96z) == "EXTERNAL_SEED_APPLIED";
    providedOk = hasFormal && isfield(W.formal,'rngSeedWasProvided_v96z') && ...
        logical(W.formal.rngSeedWasProvided_v96z);

    checks{end+1,1} = check_row('A18', 'External seed value applied', ...
        seedOk, 'REQUIRED', rng_evidence(W), 'rngSeed_v96z=61001');
    checks{end+1,1} = check_row('A19', 'External seed control marker', ...
        controlOk && providedOk, 'REQUIRED', rng_evidence(W), ...
        'EXTERNAL_SEED_APPLIED and seed provided');

    modeOk = isfield(S,'modeFormal') && string(S.modeFormal) == "hybrid";
    referenceOk = isfield(S,'referenceMode') && string(S.referenceMode) == "gasLP";
    checks{end+1,1} = check_row('A20', 'Formal and reference modes', ...
        modeOk && referenceOk, 'REQUIRED', mode_evidence(S), ...
        'modeFormal=hybrid; referenceMode=gasLP');

    outputOk = isfield(S,'output') && isstruct(S.output) && ...
        isfield(S.output,'generations') && isfield(S.output,'funccount');
    generations = nested_scalar_or_nan(S, 'output', 'generations');
    funccount = nested_scalar_or_nan(S, 'output', 'funccount');
    outputMessage = nested_string_or_empty(S, 'output', 'message');
    checks{end+1,1} = check_row('A21', 'Solver output counters', ...
        outputOk && generations == 50 && funccount == 1200, 'REQUIRED', ...
        sprintf('generations=%g; funccount=%g', generations, funccount), ...
        'generations=50; funccount=1200');

    exitflag = scalar_or_nan(S, 'exitflag');
    maxGenStop = exitflag == 0 && contains(lower(outputMessage), ...
        lower("exceeded options.MaxGenerations"));
    checks{end+1,1} = check_row('A22', 'Exitflag interpretation', ...
        maxGenStop, 'WARNING', ...
        sprintf('exitflag=%g; message=%s', exitflag, outputMessage), ...
        'Expected stop at MaxGenerations; not proof of convergence');

    traceTablesAvailable = all(isfield(T, {'Tsummary','Tchecks','Tplan'}));
    checks{end+1,1} = check_row('A23', 'Traceability tables available in MAT', ...
        traceTablesAvailable, 'REQUIRED', ...
        field_evidence(T, {'Tsummary','Tchecks','Tplan'}), ...
        'Tsummary, Tchecks, and Tplan must exist');

    traceCurrentRun = isfield(T,'runDir') && isfield(T,'repDir') && ...
        string(T.runDir) == string(r1RunDir) && ...
        string(T.repDir) == string(fullfile(r1RunDir,'R1'));
    checks{end+1,1} = check_row('A24', 'Traceability MAT points to current R1', ...
        traceCurrentRun, 'REQUIRED', trace_path_evidence(T), ...
        r1RunDir);

    [noCurrentR2R3, currentR2R3Evidence] = current_run_has_no_r2_r3(r1RunDir);
    checks{end+1,1} = check_row('A25', 'No R2/R3 evidence in current R1 run', ...
        noCurrentR2R3, 'REQUIRED', currentR2R3Evidence, ...
        'No R2/R3 directories, seeds 61002/61003, or R2/R3 files');

    [historicalFound, historicalEvidence] = historical_r2_r3_evidence(projectRoot, r1RunDir);
    checks{end+1,1} = check_row('A26', ...
        'Historical R2/R3 outside current run are segregated', ...
        true, 'INFORMATION', historicalEvidence, ...
        'Historical evidence does not belong to current R1 run');

    objectiveFile = fullfile(projectRoot, '02_src_limpio', 'production', ...
        'objective_productive_corrected_v96j_triobjective_CO2_fix1.m');
    objectiveText = string(fileread(objectiveFile));
    formalFlagProvisional = isfield(S,'formalFlags') && ...
        isfield(S.formalFlags,'emission_factors_provisional') && ...
        logical(S.formalFlags.emission_factors_provisional);
    sourceFlagProvisional = contains(objectiveText, ...
        "PROVISIONAL_FOR_CODE_VALIDATION");
    checks{end+1,1} = check_row('A27', 'CO2 remains explicitly provisional', ...
        formalFlagProvisional && sourceFlagProvisional, 'REQUIRED', ...
        sprintf('formal flag=%d; source marker=%d', ...
            formalFlagProvisional, sourceFlagProvisional), ...
        'Final manuscript CO2 claims remain blocked');

    [legacySummaryFound, legacySummaryEvidence] = stale_global_summary_evidence( ...
        projectRoot, r1RunDir);
    checks{end+1,1} = check_row('A28', ...
        'Global R1 summary is not used as current-run evidence', ...
        true, 'WARNING', legacySummaryEvidence, ...
        'Audit is anchored to exact MAT paths and hashes');

    Tchecks = struct2table(vertcat(checks{:}));

    requiredMask = Tchecks.severity == "REQUIRED";
    requiredPass = all(Tchecks.pass(requiredMask));
    warningCount = sum(Tchecks.severity == "WARNING");

    if requiredPass
        diagnosis = "POSTRUN_AUDIT_R1_SEEDAWARE_v96z_PASS_WITH_WARNINGS";
        decision = "R1_EVIDENCE_CONSISTENT_POSTPROCESS_ONLY_DO_NOT_RUN_R2_R3";
    else
        diagnosis = "POSTRUN_AUDIT_R1_SEEDAWARE_v96z_REQUIRES_REVIEW";
        decision = "DO_NOT_RUN_R2_R3_REVIEW_R1_EVIDENCE";
    end

    minMR = min_col(S, 1);
    minCost = min_col(S, 2);
    minCO2 = min_col(S, 3);

    Tsummary = table( ...
        string(diagnosis), string(decision), 61001, ...
        string("EXTERNAL_SEED_APPLIED"), popSize, maxGen, ...
        string(S.modeFormal), string(S.referenceMode), ...
        nSolutions, nFiniteRows, nPenaltyRows, ...
        minMR, minCost, minCO2, exitflag, generations, funccount, ...
        string(outputMessage), warningCount, historicalFound, legacySummaryFound, ...
        'VariableNames', { ...
        'diagnosis','decision','seed','rngControl','PopulationSize', ...
        'MaxGenerations','modeFormal','referenceMode','nSolutions', ...
        'nFiniteRows','nPenaltyRows','minMR','minCost','minCO2', ...
        'exitflag','generations','funccount','output_message', ...
        'warningCount','historicalR2R3OutsideCurrentRun', ...
        'staleGlobalR1SummaryDetected'});

    Tartifacts = table( ...
        ["formal_runner_mat";"formal_raw_mat";"wrapper_r1_mat";"r1_traceability_mat"], ...
        string({formalMat;rawMat;r1Mat;traceMat}), ...
        [formalHash;rawHash;r1Hash;traceHash], ...
        ["input_evidence";"input_evidence";"input_evidence";"supporting_traceability"], ...
        'VariableNames', {'artifact','path','sha256','role'});

    reviewDir = fullfile(projectRoot, '06_manuscript', 'article_Q1', 'review');
    tablesDir = fullfile(projectRoot, '06_manuscript', 'article_Q1', 'tables');
    reportFile = fullfile(reviewDir, 'POSTRUN_AUDIT_R1_SEEDAWARE_v96z.md');
    checksFile = fullfile(tablesDir, 'POSTRUN_AUDIT_R1_SEEDAWARE_v96z_checks.csv');
    summaryFile = fullfile(tablesDir, 'POSTRUN_AUDIT_R1_SEEDAWARE_v96z_summary.csv');
    artifactsFile = fullfile(tablesDir, 'POSTRUN_AUDIT_R1_SEEDAWARE_v96z_artifacts.csv');

    if writeOutputs
        writetable(Tchecks, checksFile);
        writetable(Tsummary, summaryFile);
        writetable(Tartifacts, artifactsFile);
        write_markdown_report(reportFile, Tsummary, Tchecks, Tartifacts, ...
            expectedFormalHash, expectedR1Hash);
    end

    audit = struct();
    audit.status = "POSTRUN_AUDIT_R1_SEEDAWARE_v96z_COMPLETED";
    audit.diagnosis = diagnosis;
    audit.decision = decision;
    audit.requiredPass = requiredPass;
    audit.writeOutputs = logical(writeOutputs);
    audit.Tsummary = Tsummary;
    audit.Tchecks = Tchecks;
    audit.Tartifacts = Tartifacts;
    audit.reportFile = string(reportFile);
    audit.checksFile = string(checksFile);
    audit.summaryFile = string(summaryFile);
    audit.artifactsFile = string(artifactsFile);
end

function row = check_row(id, name, passValue, severity, evidence, criterion)
    row = struct();
    row.id = string(id);
    row.check = string(name);
    row.pass = logical(passValue);
    row.severity = string(severity);
    row.evidence = string(evidence);
    row.criterion = string(criterion);
end

function hash = sha256_file(filePath)
    md = javaMethod('getInstance', 'java.security.MessageDigest', 'SHA-256');
    stream = javaObject('java.io.FileInputStream', javaObject('java.io.File', filePath));
    digestStream = javaObject('java.security.DigestInputStream', stream, md);
    while digestStream.read() ~= -1
    end
    digestStream.close();
    bytes = typecast(md.digest(), 'uint8');
    hash = string(upper(reshape(dec2hex(bytes,2).',1,[])));
end

function text = field_evidence(S, names)
    parts = strings(1,numel(names));
    for k = 1:numel(names)
        parts(k) = names{k} + "=" + string(isfield(S,names{k}));
    end
    text = strjoin(parts, '; ');
end

function text = shape_evidence(S)
    text = sprintf('X=%s; F=%s', matrix_shape_text(S,'X'), ...
        matrix_shape_text(S,'F'));
end

function text = matrix_shape_text(S, fieldName)
    if ~isfield(S,fieldName)
        text = sprintf('%s=missing', fieldName);
        return
    end
    sz = size(S.(fieldName));
    text = sprintf('%s=%s', fieldName, strjoin(string(sz),'x'));
end

function text = numeric_diff_evidence(A, B)
    if ~all(isfield(A,{'X','F'})) || ~all(isfield(B,{'X','F'}))
        text = 'X or F missing';
        return
    end
    if ~isequal(size(A.X),size(B.X)) || ~isequal(size(A.F),size(B.F))
        text = 'X or F dimensions differ';
        return
    end
    text = sprintf('maxAbsDiffX=%.17g; maxAbsDiffF=%.17g', ...
        max(abs(A.X-B.X),[],'all'), max(abs(A.F-B.F),[],'all'));
end

function n = safe_size(S, fieldName, dimension)
    if isfield(S,fieldName)
        n = size(S.(fieldName),dimension);
    else
        n = 0;
    end
end

function n = count_finite_rows(S)
    if ~isfield(S,'F')
        n = 0;
    else
        n = sum(all(isfinite(S.F),2));
    end
end

function n = count_penalty_rows(S)
    if ~isfield(S,'F') || size(S.F,2) < 3
        n = NaN;
        return
    end
    n = sum(S.F(:,1) >= 999.999 | ...
        S.F(:,2) >= 999999.999 | S.F(:,3) >= 999999.999);
end

function value = scalar_or_nan(S, fieldName)
    if isfield(S,fieldName) && isscalar(S.(fieldName))
        value = double(S.(fieldName));
    else
        value = NaN;
    end
end

function value = nested_scalar_or_nan(S, parent, fieldName)
    if isfield(S,parent) && isstruct(S.(parent)) && ...
            isfield(S.(parent),fieldName) && isscalar(S.(parent).(fieldName))
        value = double(S.(parent).(fieldName));
    else
        value = NaN;
    end
end

function value = nested_string_or_empty(S, parent, fieldName)
    if isfield(S,parent) && isstruct(S.(parent)) && ...
            isfield(S.(parent),fieldName)
        value = string(S.(parent).(fieldName));
    else
        value = "";
    end
end

function tf = option_equals(R, propertyName, expected)
    tf = false;
    if ~isfield(R,'opts')
        return
    end
    try
        if isprop(R.opts,propertyName)
            tf = isequal(double(R.opts.(propertyName)), expected);
        elseif isstruct(R.opts) && isfield(R.opts,propertyName)
            tf = isequal(double(R.opts.(propertyName)), expected);
        end
    catch
        tf = false;
    end
end

function text = option_text(R, propertyName)
    text = "unavailable";
    if ~isfield(R,'opts')
        return
    end
    try
        if isprop(R.opts,propertyName)
            text = string(R.opts.(propertyName));
        elseif isstruct(R.opts) && isfield(R.opts,propertyName)
            text = string(R.opts.(propertyName));
        end
    catch
        text = "unreadable";
    end
end

function text = rng_evidence(W)
    if ~isfield(W,'formal') || ~isstruct(W.formal)
        text = 'formal struct missing';
        return
    end
    seed = NaN;
    control = "";
    provided = false;
    if isfield(W.formal,'rngSeed_v96z')
        seed = double(W.formal.rngSeed_v96z);
    end
    if isfield(W.formal,'rngControl_v96z')
        control = string(W.formal.rngControl_v96z);
    end
    if isfield(W.formal,'rngSeedWasProvided_v96z')
        provided = logical(W.formal.rngSeedWasProvided_v96z);
    end
    text = sprintf('seed=%g; control=%s; provided=%d', seed, control, provided);
end

function text = mode_evidence(S)
    mode = "";
    reference = "";
    if isfield(S,'modeFormal'), mode = string(S.modeFormal); end
    if isfield(S,'referenceMode'), reference = string(S.referenceMode); end
    text = sprintf('modeFormal=%s; referenceMode=%s', mode, reference);
end

function text = trace_path_evidence(T)
    runDir = "";
    repDir = "";
    if isfield(T,'runDir'), runDir = string(T.runDir); end
    if isfield(T,'repDir'), repDir = string(T.repDir); end
    text = sprintf('runDir=%s; repDir=%s', runDir, repDir);
end

function [tf, evidence] = current_run_has_no_r2_r3(runDir)
    r2Dir = isfolder(fullfile(runDir,'R2'));
    r3Dir = isfolder(fullfile(runDir,'R3'));
    files = dir(fullfile(runDir,'**','*'));
    names = string({files(~[files.isdir]).name});
    suspicious = contains(names,"R2",'IgnoreCase',true) | ...
        contains(names,"R3",'IgnoreCase',true) | ...
        contains(names,"61002") | contains(names,"61003");
    tf = ~r2Dir && ~r3Dir && ~any(suspicious);
    evidence = sprintf('R2dir=%d; R3dir=%d; suspiciousFiles=%d', ...
        r2Dir, r3Dir, sum(suspicious));
end

function [found, evidence] = historical_r2_r3_evidence(projectRoot, currentRunDir)
    runsRoot = fullfile(projectRoot,'06_manuscript','article_Q1','runs');
    r2 = dir(fullfile(runsRoot,'**','R2'));
    r3 = dir(fullfile(runsRoot,'**','R3'));
    allFolders = [r2([r2.isdir]); r3([r3.isdir])];
    paths = strings(0,1);
    for k = 1:numel(allFolders)
        candidate = string(fullfile(allFolders(k).folder,allFolders(k).name));
        if ~startsWith(candidate,string(currentRunDir),'IgnoreCase',true)
            paths(end+1,1) = candidate; %#ok<AGROW>
        end
    end
    found = ~isempty(paths);
    if found
        evidence = sprintf('%d historical R2/R3 folder(s) exist outside current R1 run', ...
            numel(paths));
    else
        evidence = 'No historical R2/R3 folders found';
    end
end

function [found, evidence] = stale_global_summary_evidence(projectRoot, currentRunDir)
    summaryCsv = fullfile(projectRoot,'06_manuscript','article_Q1','tables', ...
        'SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix_Tsummary.csv');
    if ~isfile(summaryCsv)
        found = false;
        evidence = 'Global R1 summary CSV is absent';
        return
    end
    text = string(fileread(summaryCsv));
    hasOldPath = contains(text,"C:\Users\PC\MATLAB Drive",'IgnoreCase',true);
    hasCurrentPath = contains(text,string(currentRunDir),'IgnoreCase',true);
    found = hasOldPath || ~hasCurrentPath;
    evidence = sprintf('oldPath=%d; currentRunPath=%d; file=%s', ...
        hasOldPath, hasCurrentPath, summaryCsv);
end

function value = min_col(S, column)
    if isfield(S,'F') && size(S.F,2) >= column
        value = min(S.F(:,column));
    else
        value = NaN;
    end
end

function write_markdown_report(reportFile, Tsummary, Tchecks, Tartifacts, ...
        expectedFormalHash, expectedR1Hash)
    fid = fopen(reportFile,'w');
    if fid < 0
        error('POSTRUN:R1:ReportOpenFailed', ...
            'Could not open report: %s', reportFile);
    end
    cleanup = onCleanup(@() fclose(fid));

    fprintf(fid,'# POSTRUN AUDIT R1 SEEDAWARE v96z\n\n');
    fprintf(fid,'## Scope\n\n');
    fprintf(fid,'Static postrun verification of existing R1 evidence only. ');
    fprintf(fid,'This report does not rerun R1 and does not authorize R2/R3.\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',Tsummary.diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',Tsummary.decision);
    fprintf(fid,'## Summary\n\n');
    fprintf(fid,'| Metric | Value |\n|---|---:|\n');
    fprintf(fid,'| seed | %d |\n',Tsummary.seed);
    fprintf(fid,'| rngControl | `%s` |\n',Tsummary.rngControl);
    fprintf(fid,'| PopulationSize | %g |\n',Tsummary.PopulationSize);
    fprintf(fid,'| MaxGenerations | %g |\n',Tsummary.MaxGenerations);
    fprintf(fid,'| modeFormal | `%s` |\n',Tsummary.modeFormal);
    fprintf(fid,'| referenceMode | `%s` |\n',Tsummary.referenceMode);
    fprintf(fid,'| nSolutions | %d |\n',Tsummary.nSolutions);
    fprintf(fid,'| nFiniteRows | %d |\n',Tsummary.nFiniteRows);
    fprintf(fid,'| nPenaltyRows | %d |\n',Tsummary.nPenaltyRows);
    fprintf(fid,'| minMR | %.15g |\n',Tsummary.minMR);
    fprintf(fid,'| minCost | %.15g |\n',Tsummary.minCost);
    fprintf(fid,'| minCO2 | %.15g |\n',Tsummary.minCO2);
    fprintf(fid,'| exitflag | %g |\n',Tsummary.exitflag);
    fprintf(fid,'| generations | %g |\n',Tsummary.generations);
    fprintf(fid,'| funccount | %g |\n',Tsummary.funccount);
    fprintf(fid,'\nOutput message: `%s`\n\n',Tsummary.output_message);

    fprintf(fid,'## Evidence hashes\n\n');
    fprintf(fid,'Expected formal MAT SHA-256: `%s`\n\n',expectedFormalHash);
    fprintf(fid,'Expected wrapper R1 MAT SHA-256: `%s`\n\n',expectedR1Hash);
    fprintf(fid,'| Artifact | SHA-256 | Role |\n|---|---|---|\n');
    for k = 1:height(Tartifacts)
        fprintf(fid,'| `%s` | `%s` | `%s` |\n', ...
            Tartifacts.artifact(k), Tartifacts.sha256(k), Tartifacts.role(k));
    end

    fprintf(fid,'\n## Checks\n\n');
    fprintf(fid,'| ID | Check | Pass | Severity | Evidence | Criterion |\n');
    fprintf(fid,'|---|---|---:|---|---|---|\n');
    for k = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` | `%s` | %s |\n', ...
            Tchecks.id(k), md_escape(Tchecks.check(k)), Tchecks.pass(k), ...
            Tchecks.severity(k), md_escape(Tchecks.evidence(k)), ...
            md_escape(Tchecks.criterion(k)));
    end

    fprintf(fid,'\n## Interpretation limits\n\n');
    fprintf(fid,'- `exitflag = 0` with a MaxGenerations stop is not proof of convergence.\n');
    fprintf(fid,'- CO2 factors remain provisional and block final manuscript claims.\n');
    fprintf(fid,'- Historical R2/R3 artifacts outside this run do not belong to current R1.\n');
    fprintf(fid,'- No R2/R3 execution is authorized by this audit.\n');
    fprintf(fid,'- The candidate chain remains non-official.\n');
end

function text = md_escape(value)
    text = replace(string(value),'|','\|');
    text = replace(text,newline,' ');
end
