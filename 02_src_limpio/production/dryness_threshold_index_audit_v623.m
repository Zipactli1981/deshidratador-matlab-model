function audit = dryness_threshold_index_audit_v623()
% DRYNESS_THRESHOLD_INDEX_AUDIT_v623
% Micropaso 6.23 — DRYNESS-THRESHOLD-INDEX-AUDIT-001
%
% Objetivo:
%   Auditar el cruce M_prod <= M_des y revisar consistencia de indices:
%       i-1, i, i+1
%   para M_prod y MR.
%
% No repite AG.
% No modifica archivos productivos.
% No corrige todavía.
%
% Salida:
%   audit.status
%   audit.diagnosis
%   audit.T
%   audit.outCsv
%   audit.outMat
%   audit.outLog

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Crear wrapper instrumentado desde v10
    % ---------------------------------------------------------------------
    wrappersDir   = fullfile(rootDir,'02_src_limpio','wrappers');
    productionDir = fullfile(rootDir,'02_src_limpio','production');

    srcWrapper = fullfile(wrappersDir,'opt_tunel_mod2_v10_energy_mode_corrected.m');
    dstWrapper = fullfile(wrappersDir,'opt_tunel_mod2_v12_index_audit.m');

    if ~isfile(srcWrapper)
        error('No existe wrapper fuente: %s', srcWrapper);
    end

    txt = fileread(srcWrapper);

    oldSignature = ...
        'function [Q_aux_tot, dry_time, M_prod_fin, MR_fin, Irradiacion, irr_diag] = opt_tunel_mod2_v10_energy_mode_corrected(m_max,T_min,r_div2,t_rec_ini, W0, m_i, Mi, mwi, md, m_f, Mf, mwf, M_des, mode_operation)';

    newSignature = ...
        'function [Q_aux_tot, dry_time, M_prod_fin, MR_fin, Irradiacion, irr_diag] = opt_tunel_mod2_v12_index_audit(m_max,T_min,r_div2,t_rec_ini, W0, m_i, Mi, mwi, md, m_f, Mf, mwf, M_des, mode_operation)';

    if ~contains(txt, oldSignature)
        error('No se encontró la firma esperada del wrapper v10.');
    end

    txt = strrep(txt, oldSignature, newSignature);

    % ---------------------------------------------------------------------
    % Instrumentar bloque de cruce por M_prod <= M_des
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
        '        %% DRYNESS-THRESHOLD-INDEX-AUDIT-001\n' ...
        '        if exist(''irr_diag'',''var'')\n' ...
        '            irr_diag.termination_status = "M_DES_REACHED";\n' ...
        '            irr_diag.break_i = i;\n' ...
        '            irr_diag.M_des = M_des;\n' ...
        '            irr_diag.Mi = Mi;\n' ...
        '            irr_diag.Mf = Mf;\n' ...
        '\n' ...
        '            idx_im1 = max(1,i-1);\n' ...
        '            idx_i   = i;\n' ...
        '            idx_ip1 = min(numel(M_prod),i+1);\n' ...
        '\n' ...
        '            irr_diag.idx_im1 = idx_im1;\n' ...
        '            irr_diag.idx_i = idx_i;\n' ...
        '            irr_diag.idx_ip1 = idx_ip1;\n' ...
        '\n' ...
        '            irr_diag.M_prod_im1 = M_prod(idx_im1);\n' ...
        '            irr_diag.M_prod_i   = M_prod(idx_i);\n' ...
        '            irr_diag.M_prod_ip1 = M_prod(idx_ip1);\n' ...
        '\n' ...
        '            irr_diag.MR_im1 = MR(idx_im1);\n' ...
        '            irr_diag.MR_i   = MR(idx_i);\n' ...
        '            irr_diag.MR_ip1 = MR(idx_ip1);\n' ...
        '\n' ...
        '            irr_diag.MR_from_M_im1 = (M_prod(idx_im1)-Mf)/(Mi-Mf);\n' ...
        '            irr_diag.MR_from_M_i   = (M_prod(idx_i)-Mf)/(Mi-Mf);\n' ...
        '            irr_diag.MR_from_M_ip1 = (M_prod(idx_ip1)-Mf)/(Mi-Mf);\n' ...
        '\n' ...
        '            irr_diag.M_prod_fin_original = M_prod_fin;\n' ...
        '            irr_diag.MR_fin_original = MR_fin;\n' ...
        '        end\n' ...
        '\n' ...
        '        break\n' ...
        '    end' ...
    ]);

    [s,e] = regexp(txt, oldDryBlockPattern, 'start', 'end');

    if numel(s) ~= 1
        error('No se encontró exactamente una vez el bloque M_prod<=M_des. Coincidencias: %d', numel(s));
    end

    txt = [txt(1:s-1), newDryBlock, txt(e+1:end)];

    fid = fopen(dstWrapper,'w');
    if fid < 0
        error('No se pudo crear wrapper instrumentado: %s', dstWrapper);
    end
    fwrite(fid,txt);
    fclose(fid);

    rehash;

    % ---------------------------------------------------------------------
    % Crear objective v623 clonada desde v611, solo cambiando wrapper
    % ---------------------------------------------------------------------
    obj611 = which('objective_productive_corrected_v611');
    if isempty(obj611)
        error('No se encontró objective_productive_corrected_v611.');
    end

    obj623 = fullfile(productionDir,'objective_productive_corrected_v623_index_audit.m');

    objTxt = fileread(obj611);

    objTxt = strrep(objTxt, ...
        'objective_productive_corrected_v611', ...
        'objective_productive_corrected_v623_index_audit');

    objTxt = strrep(objTxt, ...
        'opt_tunel_mod2_v10_energy_mode_corrected', ...
        'opt_tunel_mod2_v12_index_audit');

    fid = fopen(obj623,'w');
    if fid < 0
        error('No se pudo crear objective v623: %s', obj623);
    end
    fwrite(fid,objTxt);
    fclose(fid);

    rehash;

    if isempty(which('objective_productive_corrected_v623_index_audit'))
        error('Se creó objective v623, pero MATLAB no lo encuentra en path.');
    end

    % ---------------------------------------------------------------------
    % Localizar corrida productiva y solución seleccionada
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

    selectedFile = fullfile(tablesDir,'SELECTED_SOLUTION_CORRECTED_v614b.csv');

    if ~isfile(selectedFile)
        error('No existe SELECTED_SOLUTION_CORRECTED_v614b.csv: %s', selectedFile);
    end

    Tsel = readtable(selectedFile);
    x = [Tsel.m_max(1), Tsel.T_min(1), Tsel.r_div2(1), Tsel.t_rec_ini(1)];

    modes = ["gasLP","hybrid","solar"];
    rows = {};

    for k = 1:numel(modes)
        mode = modes(k);

        [f,dout] = objective_productive_corrected_v623_index_audit(x, mode);

        row = struct();
        row.mode = mode;
        row.m_max = x(1);
        row.T_min = x(2);
        row.r_div2 = x(3);
        row.t_rec_ini = x(4);

        row.objective_MR = f(1);
        row.objective_cost = f(2);

        row.Q_aux_tot = local_get_numeric(dout, {'Q_aux_tot','outputs.Q_aux_tot'});
        row.Irradiacion = local_get_numeric(dout, {'Irradiacion','outputs.Irradiacion'});
        row.dry_time = local_get_numeric(dout, {'dry_time','outputs.dry_time'});
        row.M = local_get_numeric(dout, {'M','outputs.M'});
        row.MR = local_get_numeric(dout, {'MR','outputs.MR'});

        row.termination_status = string(local_get_text(dout, {'termination_status','irr_diag.termination_status'}, 'UNKNOWN'));

        row.break_i = local_get_numeric(dout, {'irr_diag.break_i'});
        row.idx_im1 = local_get_numeric(dout, {'irr_diag.idx_im1'});
        row.idx_i   = local_get_numeric(dout, {'irr_diag.idx_i'});
        row.idx_ip1 = local_get_numeric(dout, {'irr_diag.idx_ip1'});

        row.M_des = local_get_numeric(dout, {'irr_diag.M_des'});
        row.Mi = local_get_numeric(dout, {'irr_diag.Mi'});
        row.Mf = local_get_numeric(dout, {'irr_diag.Mf'});

        row.M_prod_im1 = local_get_numeric(dout, {'irr_diag.M_prod_im1'});
        row.M_prod_i   = local_get_numeric(dout, {'irr_diag.M_prod_i'});
        row.M_prod_ip1 = local_get_numeric(dout, {'irr_diag.M_prod_ip1'});

        row.MR_im1 = local_get_numeric(dout, {'irr_diag.MR_im1'});
        row.MR_i   = local_get_numeric(dout, {'irr_diag.MR_i'});
        row.MR_ip1 = local_get_numeric(dout, {'irr_diag.MR_ip1'});

        row.MR_from_M_im1 = local_get_numeric(dout, {'irr_diag.MR_from_M_im1'});
        row.MR_from_M_i   = local_get_numeric(dout, {'irr_diag.MR_from_M_i'});
        row.MR_from_M_ip1 = local_get_numeric(dout, {'irr_diag.MR_from_M_ip1'});

        row.MR_error_im1 = row.MR_im1 - row.MR_from_M_im1;
        row.MR_error_i   = row.MR_i   - row.MR_from_M_i;
        row.MR_error_ip1 = row.MR_ip1 - row.MR_from_M_ip1;

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

    flags.solar_termination_mdes = strcmp(T.termination_status(solarRow),"M_DES_REACHED");
    flags.hybrid_termination_mdes = strcmp(T.termination_status(hybridRow),"M_DES_REACHED");
    flags.gas_termination_mdes = strcmp(T.termination_status(gasRow),"M_DES_REACHED");

    flags.solar_MR_near_zero = T.objective_MR(solarRow) < 1e-6;

    flags.solar_MR_i_consistent = abs(T.MR_error_i(solarRow)) < 1e-8;
    flags.solar_MR_ip1_consistent = abs(T.MR_error_ip1(solarRow)) < 1e-8;

    flags.hybrid_MR_i_consistent = abs(T.MR_error_i(hybridRow)) < 1e-8;
    flags.hybrid_MR_ip1_consistent = abs(T.MR_error_ip1(hybridRow)) < 1e-8;

    flags.gas_MR_i_consistent = abs(T.MR_error_i(gasRow)) < 1e-8;
    flags.gas_MR_ip1_consistent = abs(T.MR_error_ip1(gasRow)) < 1e-8;

    flags.solar_M_prod_i_below_Mdes = T.M_prod_i(solarRow) <= T.M_des(solarRow);
    flags.solar_M_prod_ip1_below_Mdes = T.M_prod_ip1(solarRow) <= T.M_des(solarRow);

    if flags.solar_MR_near_zero && ~flags.solar_MR_i_consistent && flags.solar_MR_ip1_consistent
        diagnosis = "OUTPUT_USES_MR_i_BUT_MR_ip1_IS_CONSISTENT";
    elseif flags.solar_MR_near_zero && flags.solar_MR_i_consistent
        diagnosis = "SOLAR_NEAR_ZERO_IS_CONSISTENT_WITH_REPORTED_M";
    elseif flags.solar_MR_near_zero
        diagnosis = "SOLAR_NEAR_ZERO_REQUIRES_STATE_TRACE_AUDIT";
    elseif flags.solar_MR_i_consistent
        diagnosis = "DRYNESS_THRESHOLD_INDEX_AUDIT_PASS_MR_i_CONSISTENT";
    else
        diagnosis = "DRYNESS_THRESHOLD_INDEX_AUDIT_REQUIRES_REVIEW";
    end

    outCsv = fullfile(tablesDir,'DRYNESS_THRESHOLD_INDEX_AUDIT_v623.csv');
    outMat = fullfile(matDir,'DRYNESS_THRESHOLD_INDEX_AUDIT_v623.mat');
    outLog = fullfile(logsDir,'DRYNESS_THRESHOLD_INDEX_AUDIT_v623.txt');

    writetable(T,outCsv);
    save(outMat,'T','flags','diagnosis','x','runDir','dstWrapper','obj623');

    fid = fopen(outLog,'w');
    fprintf(fid,'DRYNESS-THRESHOLD-INDEX-AUDIT-001\n');
    fprintf(fid,'status: DRYNESS_THRESHOLD_INDEX_AUDIT_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'runDir: %s\n', runDir);
    fprintf(fid,'dstWrapper: %s\n', dstWrapper);
    fprintf(fid,'obj623: %s\n', obj623);
    fprintf(fid,'outCsv: %s\n', outCsv);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'--- TABLE ---\n');
    for r = 1:height(T)
        fprintf(fid,'mode: %s\n', T.mode(r));
        fprintf(fid,'termination_status: %s\n', T.termination_status(r));
        fprintf(fid,'objective_MR: %.12g\n', T.objective_MR(r));
        fprintf(fid,'M: %.12g\n', T.M(r));
        fprintf(fid,'MR: %.12g\n', T.MR(r));
        fprintf(fid,'break_i: %.0f\n', T.break_i(r));
        fprintf(fid,'M_des: %.12g\n', T.M_des(r));
        fprintf(fid,'Mi: %.12g\n', T.Mi(r));
        fprintf(fid,'Mf: %.12g\n', T.Mf(r));
        fprintf(fid,'M_prod_im1: %.12g | MR_im1: %.12g | MR_from_M_im1: %.12g | err: %.12g\n', ...
            T.M_prod_im1(r), T.MR_im1(r), T.MR_from_M_im1(r), T.MR_error_im1(r));
        fprintf(fid,'M_prod_i:   %.12g | MR_i:   %.12g | MR_from_M_i:   %.12g | err: %.12g\n', ...
            T.M_prod_i(r), T.MR_i(r), T.MR_from_M_i(r), T.MR_error_i(r));
        fprintf(fid,'M_prod_ip1: %.12g | MR_ip1: %.12g | MR_from_M_ip1: %.12g | err: %.12g\n\n', ...
            T.M_prod_ip1(r), T.MR_ip1(r), T.MR_from_M_ip1(r), T.MR_error_ip1(r));
    end
    fclose(fid);

    audit = struct();
    audit.status = 'DRYNESS_THRESHOLD_INDEX_AUDIT_COMPLETED';
    audit.diagnosis = diagnosis;
    audit.flags = flags;
    audit.T = T;
    audit.runDir = runDir;
    audit.dstWrapper = dstWrapper;
    audit.obj623 = obj623;
    audit.outCsv = outCsv;
    audit.outMat = outMat;
    audit.outLog = outLog;

    disp('=== DRYNESS_THRESHOLD_INDEX_AUDIT_v623 ===')
    disp(audit.status)
    disp('=== DIAGNOSIS ===')
    disp(audit.diagnosis)
    disp('=== FLAGS ===')
    disp(audit.flags)
    disp('=== INDEX AUDIT TABLE ===')
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

function value = local_get_text(s, paths, defaultValue)
    value = defaultValue;
    for i = 1:numel(paths)
        [ok,tmp] = local_get_path(s, paths{i});
        if ok && ~isempty(tmp)
            if isstring(tmp)
                value = char(tmp(1));
                return
            elseif ischar(tmp)
                value = tmp;
                return
            elseif iscell(tmp) && ~isempty(tmp)
                value = char(tmp{1});
                return
            end
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