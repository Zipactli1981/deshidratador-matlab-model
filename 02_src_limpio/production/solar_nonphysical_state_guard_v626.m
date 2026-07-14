function guard = solar_nonphysical_state_guard_v626()
% SOLAR_NONPHYSICAL_STATE_GUARD_v626
% Micropaso 6.26 — SOLAR-NONPHYSICAL-STATE-GUARD-001
%
% Objetivo:
%   Auditar, sin corregir todavía, dónde aparece por primera vez un estado
%   no físico en gasLP, hybrid y solar.
%
% Criterios auditados:
%   - Temperaturas fuera de rango razonable
%   - HR < 0 o HR > 1
%   - w < 0
%   - M_prod < Mf
%   - MR < 0
%   - valores complejos
%   - NaN / Inf
%
% No repite el AG.
% No modifica v10.
% No modifica v611.
% Crea wrapper instrumentado:
%   opt_tunel_mod2_v15_nonphysical_guard.m
%
% Guarda:
%   05_runs/productive_v614b/<run_id>/trace_v626/

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    wrappersDir = fullfile(rootDir,'02_src_limpio','wrappers');

    srcWrapper = fullfile(wrappersDir,'opt_tunel_mod2_v10_energy_mode_corrected.m');
    dstWrapper = fullfile(wrappersDir,'opt_tunel_mod2_v15_nonphysical_guard.m');

    if ~isfile(srcWrapper)
        error('No existe wrapper fuente: %s', srcWrapper);
    end

    % ---------------------------------------------------------------------
    % Localizar corrida productiva
    % ---------------------------------------------------------------------
    baseDir = fullfile(rootDir,'05_runs','productive_v614b');
    d = dir(baseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for ii = 1:numel(d)
        keep(ii) = startsWith(d(ii).name,'PRODUCTIVE_GA_CORRECTED_v614_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró corrida PRODUCTIVE_GA_CORRECTED_v614_* en %s', baseDir);
    end

    [~,idxRun] = max([d.datenum]);
    runDir = fullfile(baseDir,d(idxRun).name);

    tablesDir = fullfile(runDir,'tables');
    matDir    = fullfile(runDir,'mat');
    logsDir   = fullfile(runDir,'logs');
    traceDir  = fullfile(runDir,'trace_v626');

    if ~isfolder(traceDir)
        mkdir(traceDir);
    end

    selectedFile = fullfile(tablesDir,'SELECTED_SOLUTION_CORRECTED_v614b.csv');
    if ~isfile(selectedFile)
        error('No existe SELECTED_SOLUTION_CORRECTED_v614b.csv: %s', selectedFile);
    end

    Tsel = readtable(selectedFile);
    x = [Tsel.m_max(1), Tsel.T_min(1), Tsel.r_div2(1), Tsel.t_rec_ini(1)];

    % ---------------------------------------------------------------------
    % Parámetros reales confirmados desde objective_productive_corrected_v611
    % ---------------------------------------------------------------------
    W0    = 200;
    m_i   = 0.8700;
    m_f   = 0.0800;

    Mi    = 6.6923;
    Mf    = 0.0870;
    M_des = 0.1111;

    md    = 26.0000;
    mwi   = 174.0000;
    mwf   = 2.2609;

    % ---------------------------------------------------------------------
    % Crear wrapper v15 instrumentado desde v10
    % ---------------------------------------------------------------------
    txt = fileread(srcWrapper);

    oldSignature = ...
        'function [Q_aux_tot, dry_time, M_prod_fin, MR_fin, Irradiacion, irr_diag] = opt_tunel_mod2_v10_energy_mode_corrected(m_max,T_min,r_div2,t_rec_ini, W0, m_i, Mi, mwi, md, m_f, Mf, mwf, M_des, mode_operation)';

    newSignature = ...
        'function [Q_aux_tot, dry_time, M_prod_fin, MR_fin, Irradiacion, irr_diag] = opt_tunel_mod2_v15_nonphysical_guard(m_max,T_min,r_div2,t_rec_ini, W0, m_i, Mi, mwi, md, m_f, Mf, mwf, M_des, mode_operation)';

    if ~contains(txt, oldSignature)
        error('No se encontró la firma esperada de v10.');
    end

    txt = strrep(txt, oldSignature, newSignature);

    globalBlock = sprintf([ ...
        '\n' ...
        '    global TRACE_V626_DIR TRACE_V626_MODE TRACE_V626_TAG\n' ...
        '\n' ...
    ]);

    txt = strrep(txt, newSignature, [newSignature, globalBlock]);

    % ---------------------------------------------------------------------
    % Instrumentar break por M_prod <= M_des
    % ---------------------------------------------------------------------
    oldDryBlockPattern = [
        '    if M_prod\(i\)<=M_des\s*' ...
        'Q_aux_tot=sum\(Q_aux\*t_step\*3600\)/1000;\s*' ...
        'Irradiacion=sum\(I\*t_step\*3600\*A_cap\*8\*mean\(ETHA_capt\)\)/1e6;\s*' ...
        'dry_time=t\(i\)/3600-t_ini;\s*' ...
        'M_prod_fin=M_prod\(i\);\s*' ...
        'MR_fin=MR\(i\);\s*' ...
        'break\s*' ...
        'end'
    ];

    newDryBlock = sprintf([ ...
        '    if M_prod(i)<=M_des\n' ...
        '        Q_aux_tot=sum(Q_aux*t_step*3600)/1000;\n' ...
        '        Irradiacion=sum(I*t_step*3600*A_cap*8*mean(ETHA_capt))/1e6;\n' ...
        '        dry_time=t(i)/3600-t_ini;\n' ...
        '        M_prod_fin=M_prod(i);\n' ...
        '        MR_fin=MR(i);\n' ...
        '\n' ...
        '        termination_status_v626 = "M_DES_REACHED";\n' ...
        '        break_i_v626 = i;\n' ...
        '        if ~isempty(TRACE_V626_DIR)\n' ...
        '            if ~isfolder(TRACE_V626_DIR), mkdir(TRACE_V626_DIR); end\n' ...
        '            safeMode_v626 = char(string(TRACE_V626_MODE));\n' ...
        '            safeMode_v626 = regexprep(safeMode_v626,''[^a-zA-Z0-9_]'',''_'');\n' ...
        '            safeTag_v626 = char(string(TRACE_V626_TAG));\n' ...
        '            safeTag_v626 = regexprep(safeTag_v626,''[^a-zA-Z0-9_]'',''_'');\n' ...
        '            trace_file_v626 = fullfile(TRACE_V626_DIR, sprintf(''TRACE_v626_%%s_%%s_workspace.mat'', safeMode_v626, safeTag_v626));\n' ...
        '            save(trace_file_v626);\n' ...
        '        end\n' ...
        '\n' ...
        '        break\n' ...
        '    end' ...
    ]);

    [s1,e1] = regexp(txt, oldDryBlockPattern, 'start', 'end');

    if numel(s1) ~= 1
        error('No se encontró exactamente una vez el bloque M_prod<=M_des. Coincidencias: %d', numel(s1));
    end

    txt = [txt(1:s1-1), newDryBlock, txt(e1+1:end)];

    % ---------------------------------------------------------------------
    % Instrumentar break por t_max
    % ---------------------------------------------------------------------
    oldTmaxBlockPattern = [
        '    if t\(i\)>=\(t_max-t_step\)\*3600\s*' ...
        'Q_aux_tot=sum\(Q_aux\*t_step\*3600\)/1000;\s*' ...
        'Irradiacion=sum\(I\*t_step\*3600\*A_cap\*8\*mean\(ETHA_capt\)\)/1e6;\s*' ...
        'dry_time=t\(i\)/3600-t_ini;\s*' ...
        'M_prod_fin=min\(M_prod\);\s*' ...
        'MR_fin=MR\(end-1\);\s*' ...
        'break\s*' ...
        'end'
    ];

    newTmaxBlock = sprintf([ ...
        '    if t(i)>=(t_max-t_step)*3600\n' ...
        '        Q_aux_tot=sum(Q_aux*t_step*3600)/1000;\n' ...
        '        Irradiacion=sum(I*t_step*3600*A_cap*8*mean(ETHA_capt))/1e6;\n' ...
        '        dry_time=t(i)/3600-t_ini;\n' ...
        '        M_prod_fin=min(M_prod);\n' ...
        '        MR_fin=MR(end-1);\n' ...
        '\n' ...
        '        termination_status_v626 = "TMAX_REACHED";\n' ...
        '        break_i_v626 = i;\n' ...
        '        if ~isempty(TRACE_V626_DIR)\n' ...
        '            if ~isfolder(TRACE_V626_DIR), mkdir(TRACE_V626_DIR); end\n' ...
        '            safeMode_v626 = char(string(TRACE_V626_MODE));\n' ...
        '            safeMode_v626 = regexprep(safeMode_v626,''[^a-zA-Z0-9_]'',''_'');\n' ...
        '            safeTag_v626 = char(string(TRACE_V626_TAG));\n' ...
        '            safeTag_v626 = regexprep(safeTag_v626,''[^a-zA-Z0-9_]'',''_'');\n' ...
        '            trace_file_v626 = fullfile(TRACE_V626_DIR, sprintf(''TRACE_v626_%%s_%%s_workspace.mat'', safeMode_v626, safeTag_v626));\n' ...
        '            save(trace_file_v626);\n' ...
        '        end\n' ...
        '\n' ...
        '        break\n' ...
        '    end' ...
    ]);

    [s2,e2] = regexp(txt, oldTmaxBlockPattern, 'start', 'end');

    if numel(s2) ~= 1
        error('No se encontró exactamente una vez el bloque t_max. Coincidencias: %d', numel(s2));
    end

    txt = [txt(1:s2-1), newTmaxBlock, txt(e2+1:end)];

    fid = fopen(dstWrapper,'w');
    if fid < 0
        error('No se pudo crear wrapper v15: %s', dstWrapper);
    end
    fwrite(fid,txt);
    fclose(fid);

    clear opt_tunel_mod2_v15_nonphysical_guard
    rehash;

    if isempty(which('opt_tunel_mod2_v15_nonphysical_guard'))
        error('Se creó v15, pero MATLAB no lo encuentra en path.');
    end

    % ---------------------------------------------------------------------
    % Ejecutar wrapper directo por modo
    % ---------------------------------------------------------------------
    global TRACE_V626_DIR TRACE_V626_MODE TRACE_V626_TAG

    modes = ["gasLP","hybrid","solar"];
    rows = {};
    violationRows = {};

    for k = 1:numel(modes)
        mode = modes(k);

        TRACE_V626_DIR = traceDir;
        TRACE_V626_MODE = mode;
        TRACE_V626_TAG = "selected_solution";

        traceFile = fullfile(traceDir, sprintf('TRACE_v626_%s_selected_solution_workspace.mat', char(mode)));

        if isfile(traceFile)
            delete(traceFile);
        end

        row = struct();
        row.mode = mode;
        row.m_max = x(1);
        row.T_min = x(2);
        row.r_div2 = x(3);
        row.t_rec_ini = x(4);

        try
            [Q_aux_tot, dry_time, M, MR, Irradiacion, irr_diag] = ...
                opt_tunel_mod2_v15_nonphysical_guard( ...
                    x(1), x(2), x(3), x(4), ...
                    W0, m_i, Mi, mwi, md, m_f, Mf, mwf, M_des, mode);

            row.status = "OK";
            row.error_message = "";
            row.Q_aux_tot = Q_aux_tot;
            row.Irradiacion = Irradiacion;
            row.dry_time = dry_time;
            row.M = M;
            row.MR = MR;
            row.trace_exists = isfile(traceFile);

            if exist('irr_diag','var') && isstruct(irr_diag)
                row.irr_diag_isstruct = true;
            else
                row.irr_diag_isstruct = false;
            end

        catch ME
            row.status = "ERROR";
            row.error_message = string(ME.message);
            row.Q_aux_tot = NaN;
            row.Irradiacion = NaN;
            row.dry_time = NaN;
            row.M = NaN;
            row.MR = NaN;
            row.trace_exists = isfile(traceFile);
            row.irr_diag_isstruct = false;
        end

        row.trace_file = string(traceFile);

        if isfile(traceFile)
            S = load(traceFile);

            summary = local_trace_summary_v626(S);

            row.termination_status = summary.termination_status;
            row.break_i = summary.break_i;
            row.first_violation_i = summary.first_violation_i;
            row.first_violation_variable = summary.first_violation_variable;
            row.first_violation_rule = summary.first_violation_rule;
            row.first_violation_value_real = summary.first_violation_value_real;
            row.first_violation_value_imag = summary.first_violation_value_imag;
            row.num_violations = summary.num_violations;
            row.has_complex = summary.has_complex;
            row.has_temperature_violation = summary.has_temperature_violation;
            row.has_HR_violation = summary.has_HR_violation;
            row.has_w_violation = summary.has_w_violation;
            row.has_M_violation = summary.has_M_violation;
            row.has_MR_violation = summary.has_MR_violation;
            row.has_naninf_violation = summary.has_naninf_violation;

            theseRows = local_violation_rows_v626(S, mode);
            violationRows = [violationRows; theseRows]; %#ok<AGROW>
        else
            row.termination_status = "TRACE_NOT_FOUND";
            row.break_i = NaN;
            row.first_violation_i = NaN;
            row.first_violation_variable = "";
            row.first_violation_rule = "";
            row.first_violation_value_real = NaN;
            row.first_violation_value_imag = NaN;
            row.num_violations = NaN;
            row.has_complex = false;
            row.has_temperature_violation = false;
            row.has_HR_violation = false;
            row.has_w_violation = false;
            row.has_M_violation = false;
            row.has_MR_violation = false;
            row.has_naninf_violation = false;
        end

        rows{end+1,1} = row; %#ok<AGROW>
    end

    T = struct2table(vertcat(rows{:}));

    if isempty(violationRows)
        Tviol = table();
    else
        Tviol = struct2table(vertcat(violationRows{:}));
        Tviol = sortrows(Tviol, {'mode','first_i','priority'});
    end

    % ---------------------------------------------------------------------
    % Diagnóstico
    % ---------------------------------------------------------------------
    flags = struct();

    gasRow = strcmp(T.mode,"gasLP");
    hybRow = strcmp(T.mode,"hybrid");
    solRow = strcmp(T.mode,"solar");

    flags.all_status_ok = all(strcmp(T.status,"OK"));
    flags.all_traces_found = all(T.trace_exists);
    flags.solar_trace_found = T.trace_exists(solRow);

    flags.gas_has_violation = T.num_violations(gasRow) > 0;
    flags.hybrid_has_violation = T.num_violations(hybRow) > 0;
    flags.solar_has_violation = T.num_violations(solRow) > 0;

    flags.solar_has_temperature_violation = T.has_temperature_violation(solRow);
    flags.solar_has_HR_violation = T.has_HR_violation(solRow);
    flags.solar_has_complex = T.has_complex(solRow);
    flags.solar_has_M_violation = T.has_M_violation(solRow);
    flags.solar_has_MR_violation = T.has_MR_violation(solRow);

    flags.solar_violation_before_break = ...
        T.first_violation_i(solRow) < T.break_i(solRow);

    flags.solar_Qaux_zero = T.Q_aux_tot(solRow) == 0;
    flags.hybrid_Qaux_positive = T.Q_aux_tot(hybRow) > 0;
    flags.same_irradiance_hybrid_solar = ...
        abs(T.Irradiacion(hybRow) - T.Irradiacion(solRow)) < 1e-6;

    if ~flags.all_status_ok
        diagnosis = "NONPHYSICAL_GUARD_EXECUTION_ERROR";
    elseif ~flags.all_traces_found
        diagnosis = "NONPHYSICAL_GUARD_TRACE_MISSING";
    elseif flags.solar_has_violation && ~flags.hybrid_has_violation
        diagnosis = "SOLAR_ONLY_NONPHYSICAL_STATE_DETECTED";
    elseif flags.solar_has_violation && flags.hybrid_has_violation
        diagnosis = "SOLAR_AND_HYBRID_HAVE_NONPHYSICAL_STATES_REVIEW_THRESHOLDS";
    elseif flags.solar_has_violation
        diagnosis = "SOLAR_NONPHYSICAL_STATE_DETECTED";
    else
        diagnosis = "NO_NONPHYSICAL_STATE_DETECTED_BY_GUARD";
    end

    outCsvMain = fullfile(tablesDir,'SOLAR_NONPHYSICAL_STATE_GUARD_v626_main.csv');
    outCsvViol = fullfile(tablesDir,'SOLAR_NONPHYSICAL_STATE_GUARD_v626_violations.csv');
    outMat     = fullfile(matDir,'SOLAR_NONPHYSICAL_STATE_GUARD_v626.mat');
    outLog     = fullfile(logsDir,'SOLAR_NONPHYSICAL_STATE_GUARD_v626.txt');

    writetable(T,outCsvMain);

    if ~isempty(Tviol)
        writetable(Tviol,outCsvViol);
    end

    save(outMat,'T','Tviol','flags','diagnosis','x','runDir','traceDir','dstWrapper');

    fid = fopen(outLog,'w');
    fprintf(fid,'SOLAR-NONPHYSICAL-STATE-GUARD-001\n');
    fprintf(fid,'status: SOLAR_NONPHYSICAL_STATE_GUARD_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'runDir: %s\n', runDir);
    fprintf(fid,'traceDir: %s\n', traceDir);
    fprintf(fid,'dstWrapper: %s\n', dstWrapper);
    fprintf(fid,'outCsvMain: %s\n', outCsvMain);
    fprintf(fid,'outCsvViol: %s\n', outCsvViol);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'--- MAIN TABLE ---\n');
    for r = 1:height(T)
        fprintf(fid,'mode: %s\n', T.mode(r));
        fprintf(fid,'status: %s\n', T.status(r));
        fprintf(fid,'termination_status: %s\n', T.termination_status(r));
        fprintf(fid,'Q_aux_tot: %.12g\n', T.Q_aux_tot(r));
        fprintf(fid,'Irradiacion: %.12g\n', T.Irradiacion(r));
        fprintf(fid,'dry_time: %.12g\n', T.dry_time(r));
        fprintf(fid,'M: %.12g\n', T.M(r));
        fprintf(fid,'MR: %.12g\n', T.MR(r));
        fprintf(fid,'break_i: %.0f\n', T.break_i(r));
        fprintf(fid,'first_violation_i: %.0f\n', T.first_violation_i(r));
        fprintf(fid,'first_violation_variable: %s\n', T.first_violation_variable(r));
        fprintf(fid,'first_violation_rule: %s\n', T.first_violation_rule(r));
        fprintf(fid,'first_violation_value_real: %.12g\n', T.first_violation_value_real(r));
        fprintf(fid,'first_violation_value_imag: %.12g\n', T.first_violation_value_imag(r));
        fprintf(fid,'num_violations: %.0f\n\n', T.num_violations(r));
    end

    if ~isempty(Tviol)
        fprintf(fid,'--- FIRST VIOLATIONS BY VARIABLE ---\n');
        for r = 1:height(Tviol)
            fprintf(fid,'%s | %s | first_i=%g | rule=%s | value=%g%+gi | priority=%g\n', ...
                Tviol.mode(r), Tviol.variable(r), Tviol.first_i(r), Tviol.rule(r), ...
                Tviol.value_real(r), Tviol.value_imag(r), Tviol.priority(r));
        end
    end

    fclose(fid);

    guard = struct();
    guard.status = 'SOLAR_NONPHYSICAL_STATE_GUARD_COMPLETED';
    guard.diagnosis = diagnosis;
    guard.flags = flags;
    guard.T = T;
    guard.Tviol = Tviol;
    guard.runDir = runDir;
    guard.traceDir = traceDir;
    guard.dstWrapper = dstWrapper;
    guard.outCsvMain = outCsvMain;
    guard.outCsvViol = outCsvViol;
    guard.outMat = outMat;
    guard.outLog = outLog;

    disp('=== SOLAR_NONPHYSICAL_STATE_GUARD_v626 ===')
    disp(guard.status)
    disp('=== DIAGNOSIS ===')
    disp(guard.diagnosis)
    disp('=== FLAGS ===')
    disp(guard.flags)
    disp('=== MAIN TABLE ===')
    disp(T)
    disp('=== VIOLATION TABLE ===')
    disp(Tviol)
end

function summary = local_trace_summary_v626(S)

    Tviol = local_violation_table_from_workspace_v626(S, "summary");

    summary = struct();

    summary.termination_status = local_get_string(S,'termination_status_v626',"UNKNOWN");
    summary.break_i = local_get_num(S,'break_i_v626');

    if isempty(Tviol)
        summary.first_violation_i = NaN;
        summary.first_violation_variable = "";
        summary.first_violation_rule = "";
        summary.first_violation_value_real = NaN;
        summary.first_violation_value_imag = NaN;
        summary.num_violations = 0;
    else
        Tviol = sortrows(Tviol, {'first_i','priority'});
        summary.first_violation_i = Tviol.first_i(1);
        summary.first_violation_variable = Tviol.variable(1);
        summary.first_violation_rule = Tviol.rule(1);
        summary.first_violation_value_real = Tviol.value_real(1);
        summary.first_violation_value_imag = Tviol.value_imag(1);
        summary.num_violations = height(Tviol);
    end

    if isempty(Tviol)
        summary.has_complex = false;
        summary.has_temperature_violation = false;
        summary.has_HR_violation = false;
        summary.has_w_violation = false;
        summary.has_M_violation = false;
        summary.has_MR_violation = false;
        summary.has_naninf_violation = false;
    else
        summary.has_complex = any(contains(Tviol.rule,"complex"));
        summary.has_temperature_violation = any(contains(Tviol.rule,"temperature"));
        summary.has_HR_violation = any(contains(Tviol.rule,"relative_humidity"));
        summary.has_w_violation = any(contains(Tviol.rule,"humidity_ratio"));
        summary.has_M_violation = any(contains(Tviol.rule,"moisture_content"));
        summary.has_MR_violation = any(contains(Tviol.rule,"MR"));
        summary.has_naninf_violation = any(contains(Tviol.rule,"nan_or_inf"));
    end
end

function rows = local_violation_rows_v626(S, mode)

    Tviol = local_violation_table_from_workspace_v626(S, mode);

    rows = {};

    if isempty(Tviol)
        return
    end

    for r = 1:height(Tviol)
        row = table2struct(Tviol(r,:));
        rows{end+1,1} = row; %#ok<AGROW>
    end
end

function Tviol = local_violation_table_from_workspace_v626(S, mode)

    rows = {};

    specs = {};

    specs{end+1} = local_spec('T_HE1_in',  'temperature_low_high', -10, 120, 10);
    specs{end+1} = local_spec('T_HE1_out', 'temperature_low_high', -10, 120, 10);
    specs{end+1} = local_spec('T_DH_in',   'temperature_low_high', -10, 120, 10);
    specs{end+1} = local_spec('T_DH_out',  'temperature_low_high', -10, 120, 10);
    specs{end+1} = local_spec('T_prod',    'temperature_low_high', -10, 120, 10);
    specs{end+1} = local_spec('T_air',     'temperature_low_high', -10, 120, 10);
    specs{end+1} = local_spec('T_amb',     'temperature_low_high', -10, 120, 10);

    specs{end+1} = local_spec('HR_DH_in',  'relative_humidity_0_1', 0, 1, 20);
    specs{end+1} = local_spec('HR_DH_out', 'relative_humidity_0_1', 0, 1, 20);
    specs{end+1} = local_spec('HR_amb',    'relative_humidity_0_1', 0, 1, 20);

    specs{end+1} = local_spec('w_DH_in',   'humidity_ratio_nonnegative', 0, Inf, 30);
    specs{end+1} = local_spec('w_DH_out',  'humidity_ratio_nonnegative', 0, Inf, 30);

    specs{end+1} = local_spec('M_prod',    'moisture_content_ge_Mf', NaN, Inf, 40);
    specs{end+1} = local_spec('MR',        'MR_0_1', 0, 1, 50);

    specs{end+1} = local_spec('Q_aux',     'energy_aux_nonnegative', 0, Inf, 60);
    specs{end+1} = local_spec('I',         'irradiance_nonnegative', 0, Inf, 60);

    Mf = local_get_num(S,'Mf');

    for s = 1:numel(specs)
        spec = specs{s};

        if ~isfield(S,spec.name)
            continue
        end

        v = S.(spec.name);

        if ~(isnumeric(v) || islogical(v))
            continue
        end

        vv = double(v(:));

        row = local_first_violation_for_vector(vv, spec, Mf, string(mode));

        if ~isempty(row)
            rows{end+1,1} = row; %#ok<AGROW>
        end
    end

    if isempty(rows)
        Tviol = table();
    else
        Tviol = struct2table(vertcat(rows{:}));
    end
end

function spec = local_spec(name, rule, lower, upper, priority)
    spec = struct();
    spec.name = name;
    spec.rule = rule;
    spec.lower = lower;
    spec.upper = upper;
    spec.priority = priority;
end

function row = local_first_violation_for_vector(vv, spec, Mf, mode)

    row = [];

    if isempty(vv)
        return
    end

    bad = false(size(vv));
    rule = string(spec.rule);

    % NaN / Inf
    bad_naninf = isnan(real(vv)) | isinf(real(vv)) | isnan(imag(vv)) | isinf(imag(vv));

    % Complejos no triviales
    bad_complex = abs(imag(vv)) > 1e-9;

    % Reglas por variable
    realv = real(vv);

    switch spec.rule
        case 'temperature_low_high'
            bad_rule = realv < spec.lower | realv > spec.upper;
        case 'relative_humidity_0_1'
            bad_rule = realv < spec.lower | realv > spec.upper;
        case 'humidity_ratio_nonnegative'
            bad_rule = realv < spec.lower;
        case 'moisture_content_ge_Mf'
            if isnan(Mf)
                bad_rule = false(size(vv));
            else
                bad_rule = realv < (Mf - 1e-8);
            end
        case 'MR_0_1'
            bad_rule = realv < spec.lower | realv > spec.upper;
        case 'energy_aux_nonnegative'
            bad_rule = realv < spec.lower;
        case 'irradiance_nonnegative'
            bad_rule = realv < spec.lower;
        otherwise
            bad_rule = false(size(vv));
    end

    bad = bad_naninf | bad_complex | bad_rule;

    idx = find(bad,1,'first');

    if isempty(idx)
        return
    end

    if bad_naninf(idx)
        finalRule = string(spec.rule) + "_nan_or_inf";
        priority = spec.priority - 2;
    elseif bad_complex(idx)
        finalRule = string(spec.rule) + "_complex";
        priority = spec.priority - 1;
    else
        finalRule = string(spec.rule);
        priority = spec.priority;
    end

    row = struct();
    row.mode = string(mode);
    row.variable = string(spec.name);
    row.rule = finalRule;
    row.first_i = idx;
    row.value_real = real(vv(idx));
    row.value_imag = imag(vv(idx));
    row.priority = priority;
    row.n_total = numel(vv);
end

function value = local_get_num(S, name)
    if isfield(S,name) && isnumeric(S.(name)) && ~isempty(S.(name))
        tmp = S.(name);
        value = tmp(1);
    else
        value = NaN;
    end
end

function value = local_get_string(S, name, defaultValue)
    value = defaultValue;

    if ~isfield(S,name)
        return
    end

    tmp = S.(name);

    if isstring(tmp)
        value = tmp(1);
    elseif ischar(tmp)
        value = string(tmp);
    elseif iscell(tmp) && ~isempty(tmp)
        value = string(tmp{1});
    end
end