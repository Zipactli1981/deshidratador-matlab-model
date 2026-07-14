function trace = wrapper_internal_state_trace_v624()
% WRAPPER_INTERNAL_STATE_TRACE_v624
% Micropaso 6.24 — WRAPPER-INTERNAL-STATE-TRACE-001
%
% Objetivo:
%   Crear un wrapper instrumentado que guarde directamente el estado interno
%   al momento del break, sin depender de que objective_productive_corrected_v611
%   propague irr_diag.
%
% No repite el AG.
% No modifica v10.
% No modifica v611.
% No corrige todavía.
%
% Crea:
%   1) opt_tunel_mod2_v13_internal_state_trace.m
%   2) objective_productive_corrected_v624_state_trace.m
%
% Ejecuta la solución seleccionada en gasLP, hybrid y solar.
% Guarda trazas en:
%   05_runs/productive_v614b/<run_id>/trace_v624/

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    wrappersDir   = fullfile(rootDir,'02_src_limpio','wrappers');
    productionDir = fullfile(rootDir,'02_src_limpio','production');

    srcWrapper = fullfile(wrappersDir,'opt_tunel_mod2_v10_energy_mode_corrected.m');
    dstWrapper = fullfile(wrappersDir,'opt_tunel_mod2_v13_internal_state_trace.m');

    if ~isfile(srcWrapper)
        error('No existe wrapper fuente: %s', srcWrapper);
    end

    % ---------------------------------------------------------------------
    % Localizar corrida productiva más reciente
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

    [~,idx] = max([d.datenum]);
    runDir = fullfile(baseDir,d(idx).name);

    tablesDir = fullfile(runDir,'tables');
    matDir    = fullfile(runDir,'mat');
    logsDir   = fullfile(runDir,'logs');
    traceDir  = fullfile(runDir,'trace_v624');

    if ~isfolder(traceDir)
        mkdir(traceDir);
    end

    selectedFile = fullfile(tablesDir,'SELECTED_SOLUTION_CORRECTED_v614b.csv');

    if ~isfile(selectedFile)
        error('No existe selected solution: %s', selectedFile);
    end

    Tsel = readtable(selectedFile);
    x = [Tsel.m_max(1), Tsel.T_min(1), Tsel.r_div2(1), Tsel.t_rec_ini(1)];

    % ---------------------------------------------------------------------
    % Crear wrapper v13 desde v10
    % ---------------------------------------------------------------------
    txt = fileread(srcWrapper);

    oldSignature = ...
        'function [Q_aux_tot, dry_time, M_prod_fin, MR_fin, Irradiacion, irr_diag] = opt_tunel_mod2_v10_energy_mode_corrected(m_max,T_min,r_div2,t_rec_ini, W0, m_i, Mi, mwi, md, m_f, Mf, mwf, M_des, mode_operation)';

    newSignature = ...
        'function [Q_aux_tot, dry_time, M_prod_fin, MR_fin, Irradiacion, irr_diag] = opt_tunel_mod2_v13_internal_state_trace(m_max,T_min,r_div2,t_rec_ini, W0, m_i, Mi, mwi, md, m_f, Mf, mwf, M_des, mode_operation)';

    if ~contains(txt, oldSignature)
        error('No se encontró la firma esperada de v10 en el wrapper.');
    end

    txt = strrep(txt, oldSignature, newSignature);

    % Insertar directorio global de trazas después de globals principales.
    anchorGlobal = 'global  A_sec t_step P_amb';

    insertGlobal = sprintf([ ...
        'global  A_sec t_step P_amb\n' ...
        'global TRACE_V624_DIR TRACE_V624_MODE TRACE_V624_TAG\n' ...
    ]);

    if ~contains(txt, anchorGlobal)
        error('No se encontró anchor global esperado: %s', anchorGlobal);
    end

    txt = strrep(txt, anchorGlobal, insertGlobal);

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
        '        %% WRAPPER-INTERNAL-STATE-TRACE-001\n' ...
        '        local_save_trace_v624("M_DES_REACHED", i, mode_operation, TRACE_V624_DIR, TRACE_V624_MODE, TRACE_V624_TAG, ...\n' ...
        '            Q_aux_tot, Irradiacion, dry_time, M_prod_fin, MR_fin, ...\n' ...
        '            M_prod, MR, M_des, Mi, Mf, t, Q_aux, I, t_step, A_cap, ETHA_capt);\n' ...
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
        '        %% WRAPPER-INTERNAL-STATE-TRACE-001\n' ...
        '        local_save_trace_v624("TMAX_REACHED", i, mode_operation, TRACE_V624_DIR, TRACE_V624_MODE, TRACE_V624_TAG, ...\n' ...
        '            Q_aux_tot, Irradiacion, dry_time, M_prod_fin, MR_fin, ...\n' ...
        '            M_prod, MR, M_des, Mi, Mf, t, Q_aux, I, t_step, A_cap, ETHA_capt);\n' ...
        '\n' ...
        '        break\n' ...
        '    end' ...
    ]);

    [s2,e2] = regexp(txt, oldTmaxBlockPattern, 'start', 'end');

    if numel(s2) ~= 1
        error('No se encontró exactamente una vez el bloque t_max. Coincidencias: %d', numel(s2));
    end

    txt = [txt(1:s2-1), newTmaxBlock, txt(e2+1:end)];

    % ---------------------------------------------------------------------
    % Agregar función local de guardado al final del wrapper
    % ---------------------------------------------------------------------
    helperText = sprintf([ ...
        '\n\n' ...
        'function local_save_trace_v624(termination_status, i, mode_operation, traceDir, traceMode, traceTag, ...\n' ...
        '    Q_aux_tot, Irradiacion, dry_time, M_prod_fin, MR_fin, ...\n' ...
        '    M_prod, MR, M_des, Mi, Mf, t, Q_aux, I, t_step, A_cap, ETHA_capt)\n' ...
        '%% LOCAL_SAVE_TRACE_v624\n' ...
        '%% Guarda estado interno del wrapper en el momento del break.\n' ...
        '\n' ...
        '    if isempty(traceDir)\n' ...
        '        traceDir = pwd;\n' ...
        '    end\n' ...
        '\n' ...
        '    if ~isfolder(traceDir)\n' ...
        '        mkdir(traceDir);\n' ...
        '    end\n' ...
        '\n' ...
        '    if isempty(traceMode)\n' ...
        '        traceMode = string(mode_operation);\n' ...
        '    end\n' ...
        '\n' ...
        '    if isempty(traceTag)\n' ...
        '        traceTag = "trace";\n' ...
        '    end\n' ...
        '\n' ...
        '    nM = numel(M_prod);\n' ...
        '    nR = numel(MR);\n' ...
        '\n' ...
        '    idx_im2 = max(1,i-2);\n' ...
        '    idx_im1 = max(1,i-1);\n' ...
        '    idx_i   = min(nM,i);\n' ...
        '    idx_ip1 = min(nM,i+1);\n' ...
        '    idx_ip2 = min(nM,i+2);\n' ...
        '\n' ...
        '    trace = struct();\n' ...
        '    trace.status = "WRAPPER_INTERNAL_STATE_TRACE_CAPTURED";\n' ...
        '    trace.termination_status = string(termination_status);\n' ...
        '    trace.mode_operation = string(mode_operation);\n' ...
        '    trace.traceMode = string(traceMode);\n' ...
        '    trace.traceTag = string(traceTag);\n' ...
        '    trace.i = i;\n' ...
        '    trace.idx = [idx_im2 idx_im1 idx_i idx_ip1 idx_ip2];\n' ...
        '    trace.M_des = M_des;\n' ...
        '    trace.Mi = Mi;\n' ...
        '    trace.Mf = Mf;\n' ...
        '    trace.Q_aux_tot = Q_aux_tot;\n' ...
        '    trace.Irradiacion = Irradiacion;\n' ...
        '    trace.dry_time = dry_time;\n' ...
        '    trace.M_prod_fin = M_prod_fin;\n' ...
        '    trace.MR_fin = MR_fin;\n' ...
        '\n' ...
        '    trace.M_prod_window = M_prod(trace.idx);\n' ...
        '    trace.MR_window = MR(min(trace.idx,nR));\n' ...
        '    trace.MR_from_M_window = (trace.M_prod_window - Mf) ./ (Mi - Mf);\n' ...
        '    trace.MR_error_window = trace.MR_window - trace.MR_from_M_window;\n' ...
        '\n' ...
        '    trace.M_prod_min_all = min(M_prod);\n' ...
        '    trace.MR_min_all = min(MR);\n' ...
        '    trace.M_prod_endminus1 = M_prod(max(1,nM-1));\n' ...
        '    trace.MR_endminus1 = MR(max(1,nR-1));\n' ...
        '    trace.MR_from_M_fin = (M_prod_fin - Mf) ./ (Mi - Mf);\n' ...
        '    trace.MR_fin_error = MR_fin - trace.MR_from_M_fin;\n' ...
        '\n' ...
        '    trace.nonzero_M_prod_count = nnz(M_prod);\n' ...
        '    trace.nonzero_MR_count = nnz(MR);\n' ...
        '    trace.numel_M_prod = numel(M_prod);\n' ...
        '    trace.numel_MR = numel(MR);\n' ...
        '\n' ...
        '    trace.sum_Q_aux = sum(Q_aux*t_step*3600)/1000;\n' ...
        '    trace.sum_Irr = sum(I*t_step*3600*A_cap*8*mean(ETHA_capt))/1e6;\n' ...
        '\n' ...
        '    safeMode = char(string(traceMode));\n' ...
        '    safeMode = regexprep(safeMode,''[^a-zA-Z0-9_]'' , ''_'');\n' ...
        '    safeTag = char(string(traceTag));\n' ...
        '    safeTag = regexprep(safeTag,''[^a-zA-Z0-9_]'' , ''_'');\n' ...
        '\n' ...
        '    matFile = fullfile(traceDir, sprintf(''TRACE_v624_%%s_%%s.mat'', safeMode, safeTag));\n' ...
        '    txtFile = fullfile(traceDir, sprintf(''TRACE_v624_%%s_%%s.txt'', safeMode, safeTag));\n' ...
        '\n' ...
        '    save(matFile,''trace'');\n' ...
        '\n' ...
        '    fid = fopen(txtFile,''w'');\n' ...
        '    fprintf(fid,''WRAPPER-INTERNAL-STATE-TRACE-001\\n'');\n' ...
        '    fprintf(fid,''status: %%s\\n'', trace.status);\n' ...
        '    fprintf(fid,''termination_status: %%s\\n'', trace.termination_status);\n' ...
        '    fprintf(fid,''mode_operation: %%s\\n'', trace.mode_operation);\n' ...
        '    fprintf(fid,''i: %%d\\n'', trace.i);\n' ...
        '    fprintf(fid,''M_des: %%.12g\\n'', trace.M_des);\n' ...
        '    fprintf(fid,''Mi: %%.12g\\n'', trace.Mi);\n' ...
        '    fprintf(fid,''Mf: %%.12g\\n'', trace.Mf);\n' ...
        '    fprintf(fid,''Q_aux_tot: %%.12g\\n'', trace.Q_aux_tot);\n' ...
        '    fprintf(fid,''Irradiacion: %%.12g\\n'', trace.Irradiacion);\n' ...
        '    fprintf(fid,''dry_time: %%.12g\\n'', trace.dry_time);\n' ...
        '    fprintf(fid,''M_prod_fin: %%.12g\\n'', trace.M_prod_fin);\n' ...
        '    fprintf(fid,''MR_fin: %%.12g\\n'', trace.MR_fin);\n' ...
        '    fprintf(fid,''MR_from_M_fin: %%.12g\\n'', trace.MR_from_M_fin);\n' ...
        '    fprintf(fid,''MR_fin_error: %%.12g\\n'', trace.MR_fin_error);\n' ...
        '    fprintf(fid,''M_prod_min_all: %%.12g\\n'', trace.M_prod_min_all);\n' ...
        '    fprintf(fid,''MR_min_all: %%.12g\\n'', trace.MR_min_all);\n' ...
        '    fprintf(fid,''nonzero_M_prod_count: %%d\\n'', trace.nonzero_M_prod_count);\n' ...
        '    fprintf(fid,''nonzero_MR_count: %%d\\n'', trace.nonzero_MR_count);\n' ...
        '    fprintf(fid,''numel_M_prod: %%d\\n'', trace.numel_M_prod);\n' ...
        '    fprintf(fid,''numel_MR: %%d\\n'', trace.numel_MR);\n' ...
        '    fprintf(fid,''\\n--- WINDOW ---\\n'');\n' ...
        '    for kk = 1:numel(trace.idx)\n' ...
        '        fprintf(fid,''idx: %%d | M_prod: %%.12g | MR: %%.12g | MR_from_M: %%.12g | err: %%.12g\\n'', ...\n' ...
        '            trace.idx(kk), trace.M_prod_window(kk), trace.MR_window(kk), trace.MR_from_M_window(kk), trace.MR_error_window(kk));\n' ...
        '    end\n' ...
        '    fclose(fid);\n' ...
        'end\n' ...
    ]);

    txt = [txt, helperText];

    fid = fopen(dstWrapper,'w');
    if fid < 0
        error('No se pudo crear wrapper v13: %s', dstWrapper);
    end
    fwrite(fid,txt);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Crear objective v624 clonada desde v611, solo cambiando wrapper
    % ---------------------------------------------------------------------
    obj611 = which('objective_productive_corrected_v611');

    if isempty(obj611)
        error('No se encontró objective_productive_corrected_v611.');
    end

    obj624 = fullfile(productionDir,'objective_productive_corrected_v624_state_trace.m');

    objTxt = fileread(obj611);

    objTxt = strrep(objTxt, ...
        'objective_productive_corrected_v611', ...
        'objective_productive_corrected_v624_state_trace');

    objTxt = strrep(objTxt, ...
        'opt_tunel_mod2_v10_energy_mode_corrected', ...
        'opt_tunel_mod2_v13_internal_state_trace');

    fid = fopen(obj624,'w');
    if fid < 0
        error('No se pudo crear objective v624: %s', obj624);
    end
    fwrite(fid,objTxt);
    fclose(fid);

    rehash;

    if isempty(which('objective_productive_corrected_v624_state_trace'))
        error('Se creó objective v624, pero MATLAB no la encuentra en path.');
    end

    % ---------------------------------------------------------------------
    % Ejecutar trazas por modo
    % ---------------------------------------------------------------------
    global TRACE_V624_DIR TRACE_V624_MODE TRACE_V624_TAG

    modes = ["gasLP","hybrid","solar"];
    rows = {};

    for k = 1:numel(modes)
        mode = modes(k);

        TRACE_V624_DIR = traceDir;
        TRACE_V624_MODE = mode;
        TRACE_V624_TAG = "selected_solution";

        [f,dout] = objective_productive_corrected_v624_state_trace(x, mode);

        matFile = fullfile(traceDir, sprintf('TRACE_v624_%s_selected_solution.mat', char(mode)));
        txtFile = fullfile(traceDir, sprintf('TRACE_v624_%s_selected_solution.txt', char(mode)));

        row = struct();
        row.mode = mode;
        row.objective_MR = f(1);
        row.objective_cost = f(2);
        row.Q_aux_tot = local_get_numeric(dout, {'Q_aux_tot','outputs.Q_aux_tot'});
        row.Irradiacion = local_get_numeric(dout, {'Irradiacion','outputs.Irradiacion'});
        row.dry_time = local_get_numeric(dout, {'dry_time','outputs.dry_time'});
        row.M = local_get_numeric(dout, {'M','outputs.M'});
        row.MR = local_get_numeric(dout, {'MR','outputs.MR'});
        row.trace_mat_exists = isfile(matFile);
        row.trace_txt_exists = isfile(txtFile);
        row.trace_mat_file = string(matFile);
        row.trace_txt_file = string(txtFile);

        if isfile(matFile)
            S = load(matFile,'trace');
            tr = S.trace;

            row.termination_status = string(tr.termination_status);
            row.break_i = tr.i;
            row.M_des = tr.M_des;
            row.Mi = tr.Mi;
            row.Mf = tr.Mf;
            row.M_prod_fin = tr.M_prod_fin;
            row.MR_fin = tr.MR_fin;
            row.MR_from_M_fin = tr.MR_from_M_fin;
            row.MR_fin_error = tr.MR_fin_error;
            row.M_prod_min_all = tr.M_prod_min_all;
            row.MR_min_all = tr.MR_min_all;
            row.nonzero_M_prod_count = tr.nonzero_M_prod_count;
            row.nonzero_MR_count = tr.nonzero_MR_count;
            row.numel_M_prod = tr.numel_M_prod;
            row.numel_MR = tr.numel_MR;

            row.idx_1 = tr.idx(1);
            row.idx_2 = tr.idx(2);
            row.idx_3 = tr.idx(3);
            row.idx_4 = tr.idx(4);
            row.idx_5 = tr.idx(5);

            row.M_prod_1 = tr.M_prod_window(1);
            row.M_prod_2 = tr.M_prod_window(2);
            row.M_prod_3 = tr.M_prod_window(3);
            row.M_prod_4 = tr.M_prod_window(4);
            row.M_prod_5 = tr.M_prod_window(5);

            row.MR_1 = tr.MR_window(1);
            row.MR_2 = tr.MR_window(2);
            row.MR_3 = tr.MR_window(3);
            row.MR_4 = tr.MR_window(4);
            row.MR_5 = tr.MR_window(5);

            row.MR_from_M_1 = tr.MR_from_M_window(1);
            row.MR_from_M_2 = tr.MR_from_M_window(2);
            row.MR_from_M_3 = tr.MR_from_M_window(3);
            row.MR_from_M_4 = tr.MR_from_M_window(4);
            row.MR_from_M_5 = tr.MR_from_M_window(5);

            row.MR_error_1 = tr.MR_error_window(1);
            row.MR_error_2 = tr.MR_error_window(2);
            row.MR_error_3 = tr.MR_error_window(3);
            row.MR_error_4 = tr.MR_error_window(4);
            row.MR_error_5 = tr.MR_error_window(5);
        else
            row.termination_status = "TRACE_NOT_FOUND";
            row.break_i = NaN;
            row.M_des = NaN;
            row.Mi = NaN;
            row.Mf = NaN;
            row.M_prod_fin = NaN;
            row.MR_fin = NaN;
            row.MR_from_M_fin = NaN;
            row.MR_fin_error = NaN;
            row.M_prod_min_all = NaN;
            row.MR_min_all = NaN;
            row.nonzero_M_prod_count = NaN;
            row.nonzero_MR_count = NaN;
            row.numel_M_prod = NaN;
            row.numel_MR = NaN;

            row.idx_1 = NaN; row.idx_2 = NaN; row.idx_3 = NaN; row.idx_4 = NaN; row.idx_5 = NaN;
            row.M_prod_1 = NaN; row.M_prod_2 = NaN; row.M_prod_3 = NaN; row.M_prod_4 = NaN; row.M_prod_5 = NaN;
            row.MR_1 = NaN; row.MR_2 = NaN; row.MR_3 = NaN; row.MR_4 = NaN; row.MR_5 = NaN;
            row.MR_from_M_1 = NaN; row.MR_from_M_2 = NaN; row.MR_from_M_3 = NaN; row.MR_from_M_4 = NaN; row.MR_from_M_5 = NaN;
            row.MR_error_1 = NaN; row.MR_error_2 = NaN; row.MR_error_3 = NaN; row.MR_error_4 = NaN; row.MR_error_5 = NaN;
        end

        rows{end+1,1} = row; %#ok<AGROW>
    end

    T = struct2table(vertcat(rows{:}));

    % ---------------------------------------------------------------------
    % Diagnóstico
    % ---------------------------------------------------------------------
    flags = struct();

    solarRow = strcmp(T.mode,"solar");
    hybridRow = strcmp(T.mode,"hybrid");
    gasRow = strcmp(T.mode,"gasLP");

    flags.all_traces_found = all(T.trace_mat_exists);
    flags.solar_trace_found = T.trace_mat_exists(solarRow);
    flags.solar_MR_near_zero = T.objective_MR(solarRow) < 1e-6;
    flags.solar_MR_fin_matches_M = abs(T.MR_fin_error(solarRow)) < 1e-8;
    flags.solar_M_prod_fin_below_Mdes = T.M_prod_fin(solarRow) <= T.M_des(solarRow);

    flags.hybrid_MR_fin_matches_M = abs(T.MR_fin_error(hybridRow)) < 1e-8;
    flags.gas_MR_fin_matches_M = abs(T.MR_fin_error(gasRow)) < 1e-8;

    flags.solar_Qaux_zero = T.Q_aux_tot(solarRow) == 0;
    flags.hybrid_Qaux_lower_than_gas = T.Q_aux_tot(hybridRow) < T.Q_aux_tot(gasRow);

    if ~flags.solar_trace_found
        diagnosis = "SOLAR_TRACE_NOT_FOUND";
    elseif flags.solar_MR_near_zero && flags.solar_MR_fin_matches_M && flags.solar_M_prod_fin_below_Mdes
        diagnosis = "SOLAR_NEAR_ZERO_IS_INTERNAL_MODEL_RESULT";
    elseif flags.solar_MR_near_zero && ~flags.solar_MR_fin_matches_M
        diagnosis = "SOLAR_NEAR_ZERO_IS_OUTPUT_INCONSISTENCY";
    elseif flags.solar_M_prod_fin_below_Mdes && flags.solar_MR_fin_matches_M
        diagnosis = "SOLAR_REACHES_MDES_WITH_CONSISTENT_MR";
    else
        diagnosis = "WRAPPER_INTERNAL_STATE_TRACE_REQUIRES_REVIEW";
    end

    outCsv = fullfile(tablesDir,'WRAPPER_INTERNAL_STATE_TRACE_v624.csv');
    outMat = fullfile(matDir,'WRAPPER_INTERNAL_STATE_TRACE_v624.mat');
    outLog = fullfile(logsDir,'WRAPPER_INTERNAL_STATE_TRACE_v624.txt');

    writetable(T,outCsv);
    save(outMat,'T','flags','diagnosis','x','runDir','traceDir','dstWrapper','obj624');

    fid = fopen(outLog,'w');
    fprintf(fid,'WRAPPER-INTERNAL-STATE-TRACE-001\n');
    fprintf(fid,'status: WRAPPER_INTERNAL_STATE_TRACE_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'runDir: %s\n', runDir);
    fprintf(fid,'traceDir: %s\n', traceDir);
    fprintf(fid,'dstWrapper: %s\n', dstWrapper);
    fprintf(fid,'obj624: %s\n', obj624);
    fprintf(fid,'outCsv: %s\n', outCsv);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    for r = 1:height(T)
        fprintf(fid,'============================================================\n');
        fprintf(fid,'mode: %s\n', T.mode(r));
        fprintf(fid,'termination_status: %s\n', T.termination_status(r));
        fprintf(fid,'objective_MR: %.12g\n', T.objective_MR(r));
        fprintf(fid,'objective_cost: %.12g\n', T.objective_cost(r));
        fprintf(fid,'Q_aux_tot: %.12g\n', T.Q_aux_tot(r));
        fprintf(fid,'Irradiacion: %.12g\n', T.Irradiacion(r));
        fprintf(fid,'dry_time: %.12g\n', T.dry_time(r));
        fprintf(fid,'M: %.12g\n', T.M(r));
        fprintf(fid,'MR: %.12g\n', T.MR(r));
        fprintf(fid,'break_i: %.0f\n', T.break_i(r));
        fprintf(fid,'M_des: %.12g\n', T.M_des(r));
        fprintf(fid,'Mi: %.12g\n', T.Mi(r));
        fprintf(fid,'Mf: %.12g\n', T.Mf(r));
        fprintf(fid,'M_prod_fin: %.12g\n', T.M_prod_fin(r));
        fprintf(fid,'MR_fin: %.12g\n', T.MR_fin(r));
        fprintf(fid,'MR_from_M_fin: %.12g\n', T.MR_from_M_fin(r));
        fprintf(fid,'MR_fin_error: %.12g\n', T.MR_fin_error(r));
        fprintf(fid,'M_prod_min_all: %.12g\n', T.M_prod_min_all(r));
        fprintf(fid,'MR_min_all: %.12g\n', T.MR_min_all(r));
        fprintf(fid,'trace_txt_file: %s\n\n', T.trace_txt_file(r));
    end

    fclose(fid);

    trace = struct();
    trace.status = 'WRAPPER_INTERNAL_STATE_TRACE_COMPLETED';
    trace.diagnosis = diagnosis;
    trace.flags = flags;
    trace.T = T;
    trace.runDir = runDir;
    trace.traceDir = traceDir;
    trace.dstWrapper = dstWrapper;
    trace.obj624 = obj624;
    trace.outCsv = outCsv;
    trace.outMat = outMat;
    trace.outLog = outLog;

    disp('=== WRAPPER_INTERNAL_STATE_TRACE_v624 ===')
    disp(trace.status)
    disp('=== DIAGNOSIS ===')
    disp(trace.diagnosis)
    disp('=== FLAGS ===')
    disp(trace.flags)
    disp('=== TRACE TABLE ===')
    disp(T)
end

function value = local_get_numeric(s, paths)
    value = NaN;
    for i = 1:numel(paths)
        [ok,tmp] = local_get_path(s, paths{i});
        if ok && isnumeric(tmp) && ~isempty(tmp)
            value = tmp(1);
            return
        end
    end
end

function [ok,value] = local_get_path(s, pathstr)
    ok = false;
    value = [];

    parts = strsplit(pathstr,'.');
    value = s;

    for i = 1:numel(parts)
        p = parts{i};
        if isstruct(value) && isfield(value,p)
            value = value.(p);
        else
            ok = false;
            value = [];
            return
        end
    end

    ok = true;
end