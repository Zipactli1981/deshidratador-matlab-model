function dom = solar_hybrid_dominance_trace_v625()
% SOLAR_HYBRID_DOMINANCE_TRACE_v625
% Micropaso 6.25 — SOLAR-HYBRID-DOMINANCE-TRACE-001
%
% Objetivo:
%   Comparar directamente gasLP, hybrid y solar en el wrapper, sin pasar por
%   una objective clonada.
%
%   El wrapper instrumentado guarda el workspace interno completo justo antes
%   del break por:
%       1) M_prod <= M_des
%       2) t_max alcanzado
%
%   Esto permite revisar por qué solar aparenta dominar a hybrid.
%
% No repite el AG.
% No modifica v10.
% No modifica v611.
% No corrige todavía.
%
% Crea:
%   opt_tunel_mod2_v14_full_workspace_trace.m
%
% Guarda:
%   05_runs/productive_v614b/<run_id>/trace_v625/

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    wrappersDir = fullfile(rootDir,'02_src_limpio','wrappers');

    srcWrapper = fullfile(wrappersDir,'opt_tunel_mod2_v10_energy_mode_corrected.m');
    dstWrapper = fullfile(wrappersDir,'opt_tunel_mod2_v14_full_workspace_trace.m');

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
    traceDir  = fullfile(runDir,'trace_v625');

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
    m_des = 0.1000;

    Mi    = 6.6923;
    Mf    = 0.0870;
    M_des = 0.1111;

    md    = 26.0000;
    mwi   = 174.0000;
    mwf   = 2.2609;

    % ---------------------------------------------------------------------
    % Crear wrapper v14 instrumentado desde v10
    % ---------------------------------------------------------------------
    txt = fileread(srcWrapper);

    oldSignature = ...
        'function [Q_aux_tot, dry_time, M_prod_fin, MR_fin, Irradiacion, irr_diag] = opt_tunel_mod2_v10_energy_mode_corrected(m_max,T_min,r_div2,t_rec_ini, W0, m_i, Mi, mwi, md, m_f, Mf, mwf, M_des, mode_operation)';

    newSignature = ...
        'function [Q_aux_tot, dry_time, M_prod_fin, MR_fin, Irradiacion, irr_diag] = opt_tunel_mod2_v14_full_workspace_trace(m_max,T_min,r_div2,t_rec_ini, W0, m_i, Mi, mwi, md, m_f, Mf, mwf, M_des, mode_operation)';

    if ~contains(txt, oldSignature)
        error('No se encontró la firma esperada de v10.');
    end

    txt = strrep(txt, oldSignature, newSignature);

    % Insertar globals de traza inmediatamente después de la firma.
    globalBlock = sprintf([ ...
        '\n' ...
        '    global TRACE_V625_DIR TRACE_V625_MODE TRACE_V625_TAG\n' ...
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
        '        %% SOLAR-HYBRID-DOMINANCE-TRACE-001\n' ...
        '        termination_status_v625 = "M_DES_REACHED";\n' ...
        '        break_i_v625 = i;\n' ...
        '        if ~isempty(TRACE_V625_DIR)\n' ...
        '            if ~isfolder(TRACE_V625_DIR), mkdir(TRACE_V625_DIR); end\n' ...
        '            safeMode_v625 = char(string(TRACE_V625_MODE));\n' ...
        '            safeMode_v625 = regexprep(safeMode_v625,''[^a-zA-Z0-9_]'',''_'');\n' ...
        '            safeTag_v625 = char(string(TRACE_V625_TAG));\n' ...
        '            safeTag_v625 = regexprep(safeTag_v625,''[^a-zA-Z0-9_]'',''_'');\n' ...
        '            trace_file_v625 = fullfile(TRACE_V625_DIR, sprintf(''TRACE_v625_%%s_%%s_workspace.mat'', safeMode_v625, safeTag_v625));\n' ...
        '            save(trace_file_v625);\n' ...
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
        '        %% SOLAR-HYBRID-DOMINANCE-TRACE-001\n' ...
        '        termination_status_v625 = "TMAX_REACHED";\n' ...
        '        break_i_v625 = i;\n' ...
        '        if ~isempty(TRACE_V625_DIR)\n' ...
        '            if ~isfolder(TRACE_V625_DIR), mkdir(TRACE_V625_DIR); end\n' ...
        '            safeMode_v625 = char(string(TRACE_V625_MODE));\n' ...
        '            safeMode_v625 = regexprep(safeMode_v625,''[^a-zA-Z0-9_]'',''_'');\n' ...
        '            safeTag_v625 = char(string(TRACE_V625_TAG));\n' ...
        '            safeTag_v625 = regexprep(safeTag_v625,''[^a-zA-Z0-9_]'',''_'');\n' ...
        '            trace_file_v625 = fullfile(TRACE_V625_DIR, sprintf(''TRACE_v625_%%s_%%s_workspace.mat'', safeMode_v625, safeTag_v625));\n' ...
        '            save(trace_file_v625);\n' ...
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
        error('No se pudo crear wrapper v14: %s', dstWrapper);
    end
    fwrite(fid,txt);
    fclose(fid);

    clear opt_tunel_mod2_v14_full_workspace_trace
    rehash;

    if isempty(which('opt_tunel_mod2_v14_full_workspace_trace'))
        error('Se creó v14, pero MATLAB no lo encuentra en path.');
    end

    % ---------------------------------------------------------------------
    % Ejecutar wrapper directo por modo
    % ---------------------------------------------------------------------
    global TRACE_V625_DIR TRACE_V625_MODE TRACE_V625_TAG

    modes = ["gasLP","hybrid","solar"];
    rows = {};
    traceRows = {};

    for k = 1:numel(modes)
        mode = modes(k);

        TRACE_V625_DIR = traceDir;
        TRACE_V625_MODE = mode;
        TRACE_V625_TAG = "selected_solution";

        traceFile = fullfile(traceDir, sprintf('TRACE_v625_%s_selected_solution_workspace.mat', char(mode)));

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
                opt_tunel_mod2_v14_full_workspace_trace( ...
                    x(1), x(2), x(3), x(4), ...
                    W0, m_i, Mi, mwi, md, m_f, Mf, mwf, M_des, mode);

            row.status = "OK";
            row.error_message = "";
            row.Q_aux_tot = Q_aux_tot;
            row.Irradiacion = Irradiacion;
            row.dry_time = dry_time;
            row.M = M;
            row.MR = MR;
            row.cost_proxy = NaN;
            row.trace_exists = isfile(traceFile);
            row.trace_file = string(traceFile);

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
            row.cost_proxy = NaN;
            row.trace_exists = isfile(traceFile);
            row.trace_file = string(traceFile);
            row.irr_diag_isstruct = false;
        end

        if isfile(traceFile)
            S = load(traceFile);
            tr = local_summarize_workspace_trace(S, mode);

            row.termination_status = tr.termination_status;
            row.break_i = tr.break_i;
            row.M_des_trace = tr.M_des;
            row.Mi_trace = tr.Mi;
            row.Mf_trace = tr.Mf;
            row.M_prod_fin_trace = tr.M_prod_fin;
            row.MR_fin_trace = tr.MR_fin;
            row.MR_from_M_fin_trace = tr.MR_from_M_fin;
            row.MR_fin_error_trace = tr.MR_fin_error;
            row.M_prod_min_all = tr.M_prod_min_all;
            row.MR_min_all = tr.MR_min_all;

            traceRows = [traceRows; local_variable_rows(S, mode)]; %#ok<AGROW>
        else
            row.termination_status = "TRACE_NOT_FOUND";
            row.break_i = NaN;
            row.M_des_trace = NaN;
            row.Mi_trace = NaN;
            row.Mf_trace = NaN;
            row.M_prod_fin_trace = NaN;
            row.MR_fin_trace = NaN;
            row.MR_from_M_fin_trace = NaN;
            row.MR_fin_error_trace = NaN;
            row.M_prod_min_all = NaN;
            row.MR_min_all = NaN;
        end

        rows{end+1,1} = row; %#ok<AGROW>
    end

    T = struct2table(vertcat(rows{:}));

    if isempty(traceRows)
        Ttrace = table();
    else
        Ttrace = struct2table(vertcat(traceRows{:}));
    end

    % ---------------------------------------------------------------------
    % Diagnóstico de dominancia
    % ---------------------------------------------------------------------
    flags = struct();

    gasRow = strcmp(T.mode,"gasLP");
    hybRow = strcmp(T.mode,"hybrid");
    solRow = strcmp(T.mode,"solar");

    flags.all_status_ok = all(strcmp(T.status,"OK"));
    flags.all_traces_found = all(T.trace_exists);
    flags.solar_trace_found = T.trace_exists(solRow);
    flags.hybrid_trace_found = T.trace_exists(hybRow);

    flags.hybrid_Qaux_positive = T.Q_aux_tot(hybRow) > 0;
    flags.solar_Qaux_zero = T.Q_aux_tot(solRow) == 0;
    flags.same_irradiance_hybrid_solar = abs(T.Irradiacion(hybRow) - T.Irradiacion(solRow)) < 1e-6;

    flags.solar_MR_lower_than_hybrid = T.MR(solRow) < T.MR(hybRow);
    flags.solar_M_lower_than_hybrid = T.M(solRow) < T.M(hybRow);

    flags.dominance_violation_confirmed = ...
        flags.all_status_ok && ...
        flags.solar_Qaux_zero && ...
        flags.hybrid_Qaux_positive && ...
        flags.same_irradiance_hybrid_solar && ...
        flags.solar_MR_lower_than_hybrid;

    if ~flags.all_status_ok
        diagnosis = "DIRECT_WRAPPER_TRACE_HAS_ERRORS";
    elseif ~flags.all_traces_found
        diagnosis = "DIRECT_WRAPPER_OUTPUT_OK_BUT_TRACE_MISSING";
    elseif flags.dominance_violation_confirmed
        diagnosis = "SOLAR_HYBRID_DOMINANCE_VIOLATION_CONFIRMED";
    elseif flags.solar_MR_lower_than_hybrid
        diagnosis = "SOLAR_DRIER_THAN_HYBRID_REQUIRES_THERMO_TRACE_REVIEW";
    else
        diagnosis = "NO_SOLAR_DOMINANCE_IN_DIRECT_WRAPPER_TRACE";
    end

    outCsvMain  = fullfile(tablesDir,'SOLAR_HYBRID_DOMINANCE_TRACE_v625_main.csv');
    outCsvTrace = fullfile(tablesDir,'SOLAR_HYBRID_DOMINANCE_TRACE_v625_variables.csv');
    outMat      = fullfile(matDir,'SOLAR_HYBRID_DOMINANCE_TRACE_v625.mat');
    outLog      = fullfile(logsDir,'SOLAR_HYBRID_DOMINANCE_TRACE_v625.txt');

    writetable(T,outCsvMain);

    if ~isempty(Ttrace)
        writetable(Ttrace,outCsvTrace);
    end

    save(outMat,'T','Ttrace','flags','diagnosis','x','runDir','traceDir','dstWrapper');

    fid = fopen(outLog,'w');
    fprintf(fid,'SOLAR-HYBRID-DOMINANCE-TRACE-001\n');
    fprintf(fid,'status: SOLAR_HYBRID_DOMINANCE_TRACE_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'runDir: %s\n', runDir);
    fprintf(fid,'traceDir: %s\n', traceDir);
    fprintf(fid,'dstWrapper: %s\n', dstWrapper);
    fprintf(fid,'outCsvMain: %s\n', outCsvMain);
    fprintf(fid,'outCsvTrace: %s\n', outCsvTrace);
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
        fprintf(fid,'M_prod_fin_trace: %.12g\n', T.M_prod_fin_trace(r));
        fprintf(fid,'MR_fin_trace: %.12g\n', T.MR_fin_trace(r));
        fprintf(fid,'MR_from_M_fin_trace: %.12g\n', T.MR_from_M_fin_trace(r));
        fprintf(fid,'MR_fin_error_trace: %.12g\n\n', T.MR_fin_error_trace(r));
    end

    if ~isempty(Ttrace)
        fprintf(fid,'--- VARIABLE TRACE TABLE ---\n');
        for r = 1:height(Ttrace)
            fprintf(fid,'%s | %s | final=%.12g | mean_valid=%.12g | max_valid=%.12g | min_valid=%.12g | n_valid=%d\n', ...
                Ttrace.mode(r), Ttrace.variable(r), Ttrace.final_value(r), ...
                Ttrace.mean_valid(r), Ttrace.max_valid(r), Ttrace.min_valid(r), Ttrace.n_valid(r));
        end
    end

    fclose(fid);

    dom = struct();
    dom.status = 'SOLAR_HYBRID_DOMINANCE_TRACE_COMPLETED';
    dom.diagnosis = diagnosis;
    dom.flags = flags;
    dom.T = T;
    dom.Ttrace = Ttrace;
    dom.runDir = runDir;
    dom.traceDir = traceDir;
    dom.dstWrapper = dstWrapper;
    dom.outCsvMain = outCsvMain;
    dom.outCsvTrace = outCsvTrace;
    dom.outMat = outMat;
    dom.outLog = outLog;

    disp('=== SOLAR_HYBRID_DOMINANCE_TRACE_v625 ===')
    disp(dom.status)
    disp('=== DIAGNOSIS ===')
    disp(dom.diagnosis)
    disp('=== FLAGS ===')
    disp(dom.flags)
    disp('=== MAIN TABLE ===')
    disp(T)
    disp('=== VARIABLE TRACE TABLE ===')
    disp(Ttrace)
end

function tr = local_summarize_workspace_trace(S, mode)

    tr = struct();

    tr.mode = mode;

    tr.termination_status = local_get_string(S,'termination_status_v625',"UNKNOWN");
    tr.break_i = local_get_num(S,'break_i_v625');

    tr.M_des = local_get_num(S,'M_des');
    tr.Mi = local_get_num(S,'Mi');
    tr.Mf = local_get_num(S,'Mf');

    tr.M_prod_fin = local_get_num(S,'M_prod_fin');
    tr.MR_fin = local_get_num(S,'MR_fin');

    if isfield(S,'M_prod')
        M_prod = S.M_prod;
        tr.M_prod_min_all = min(M_prod(:));
    else
        tr.M_prod_min_all = NaN;
    end

    if isfield(S,'MR')
        MR = S.MR;
        tr.MR_min_all = min(MR(:));
    else
        tr.MR_min_all = NaN;
    end

    if ~isnan(tr.M_prod_fin) && ~isnan(tr.Mi) && ~isnan(tr.Mf)
        tr.MR_from_M_fin = (tr.M_prod_fin - tr.Mf) / (tr.Mi - tr.Mf);
        tr.MR_fin_error = tr.MR_fin - tr.MR_from_M_fin;
    else
        tr.MR_from_M_fin = NaN;
        tr.MR_fin_error = NaN;
    end
end

function rows = local_variable_rows(S, mode)

    candidates = { ...
        'T_HE1_in', 'T_HE1_out', ...
        'T_DH_in', 'T_DH_out', ...
        'HR_DH_in', 'HR_DH_out', ...
        'w_DH_in', 'w_DH_out', ...
        'M_prod', 'MR', ...
        'Q_aux', 'I', ...
        'k', ...
        'T_prod', 'T_air', ...
        'T_amb', 'HR_amb', ...
        'r_rec', 'Rrec', ...
        'm_punto', 'm_dot', ...
        'T_busc', 'I_busc', ...
        'calor_aux'};

    rows = {};

    for c = 1:numel(candidates)
        name = candidates{c};

        if ~isfield(S,name)
            continue
        end

        v = S.(name);

        row = struct();
        row.mode = string(mode);
        row.variable = string(name);

        if isnumeric(v) || islogical(v)
            vv = double(v(:));
            vv_valid = vv(isfinite(vv));

            if isempty(vv_valid)
                row.final_value = NaN;
                row.mean_valid = NaN;
                row.max_valid = NaN;
                row.min_valid = NaN;
                row.n_valid = 0;
                row.numel_total = numel(vv);
            else
                lastIdx = find(isfinite(vv),1,'last');
                row.final_value = vv(lastIdx);
                row.mean_valid = mean(vv_valid);
                row.max_valid = max(vv_valid);
                row.min_valid = min(vv_valid);
                row.n_valid = numel(vv_valid);
                row.numel_total = numel(vv);
            end

            row.class = string(class(v));
            row.size_text = string(mat2str(size(v)));

        elseif isstring(v) || ischar(v)
            row.final_value = NaN;
            row.mean_valid = NaN;
            row.max_valid = NaN;
            row.min_valid = NaN;
            row.n_valid = 0;
            row.numel_total = numel(v);
            row.class = string(class(v));
            row.size_text = string(mat2str(size(v)));
        else
            row.final_value = NaN;
            row.mean_valid = NaN;
            row.max_valid = NaN;
            row.min_valid = NaN;
            row.n_valid = 0;
            row.numel_total = numel(v);
            row.class = string(class(v));
            row.size_text = string(mat2str(size(v)));
        end

        rows{end+1,1} = row; %#ok<AGROW>
    end
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