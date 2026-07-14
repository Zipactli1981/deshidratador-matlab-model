function sanity = final_state_and_cost_sanity_v622()
% FINAL_STATE_AND_COST_SANITY_v622
% Micropaso 6.22 — FINAL-STATE-AND-COST-SANITY-001
%
% Objetivo:
%   1) Crear una función objetivo v622 clonada desde objective_productive_corrected_v611.
%   2) Preservar todos los parámetros reales de v611.
%   3) Cambiar únicamente el wrapper:
%        opt_tunel_mod2_v10_energy_mode_corrected
%        ->
%        opt_tunel_mod2_v11_solar_tmax_closure_fixed
%   4) Comparar v611 vs v622 para gasLP, hybrid y solar.
%   5) Revisar si el costo deja de salir NaN.
%
% No repite el AG.
% No modifica v611.
% No modifica v10.
% No usa parámetros hardcodeados externos.

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    productionDir = fullfile(rootDir,'02_src_limpio','production');

    obj611 = which('objective_productive_corrected_v611');
    wrapperV11 = which('opt_tunel_mod2_v11_solar_tmax_closure_fixed');

    if isempty(obj611)
        error('No se encontró objective_productive_corrected_v611 en el path.');
    end

    if isempty(wrapperV11)
        error('No se encontró opt_tunel_mod2_v11_solar_tmax_closure_fixed. Ejecuta primero create_solar_tmax_fix_v621.');
    end

    obj622 = fullfile(productionDir,'objective_productive_corrected_v622_solarfix_from_v611.m');

    txt = fileread(obj611);

    if ~contains(txt,'objective_productive_corrected_v611')
        error('El archivo v611 no contiene el nombre esperado de función.');
    end

    if ~contains(txt,'opt_tunel_mod2_v10_energy_mode_corrected')
        error('La función v611 no llama explícitamente a opt_tunel_mod2_v10_energy_mode_corrected. Revisar manualmente.');
    end

    txt = strrep(txt, ...
        'objective_productive_corrected_v611', ...
        'objective_productive_corrected_v622_solarfix_from_v611');

    txt = strrep(txt, ...
        'opt_tunel_mod2_v10_energy_mode_corrected', ...
        'opt_tunel_mod2_v11_solar_tmax_closure_fixed');

    fid = fopen(obj622,'w');
    if fid < 0
        error('No se pudo crear objective v622: %s', obj622);
    end
    fwrite(fid,txt);
    fclose(fid);

    rehash;

    if isempty(which('objective_productive_corrected_v622_solarfix_from_v611'))
        error('Se creó el archivo v622, pero MATLAB no lo encuentra en el path.');
    end

    % ---------------------------------------------------------------------
    % Localizar corrida productiva más reciente
    % ---------------------------------------------------------------------
    baseDir = fullfile(rootDir,'05_runs','productive_v614b');
    d = dir(baseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'PRODUCTIVE_GA_CORRECTED_v614_');
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
        error('No existe SELECTED_SOLUTION_CORRECTED_v614b.csv en %s', tablesDir);
    end

    Tsel = readtable(selectedFile);
    x = [Tsel.m_max(1), Tsel.T_min(1), Tsel.r_div2(1), Tsel.t_rec_ini(1)];

    modes = ["gasLP","hybrid","solar"];

    rows = {};

    for k = 1:numel(modes)
        mode = modes(k);

        [f611,d611] = objective_productive_corrected_v611(x, mode);
        [f622,d622] = objective_productive_corrected_v622_solarfix_from_v611(x, mode);

        row = struct();
        row.mode = mode;

        row.m_max = x(1);
        row.T_min = x(2);
        row.r_div2 = x(3);
        row.t_rec_ini = x(4);

        row.MR_v611 = f611(1);
        row.cost_v611 = f611(2);
        row.Q_aux_v611 = local_get_numeric(d611, {'Q_aux_tot','outputs.Q_aux_tot'});
        row.Irr_v611 = local_get_numeric(d611, {'Irradiacion','outputs.Irradiacion'});
        row.dry_time_v611 = local_get_numeric(d611, {'dry_time','outputs.dry_time'});
        row.M_v611 = local_get_numeric(d611, {'M','outputs.M'});
        row.detail_MR_v611 = local_get_numeric(d611, {'MR','outputs.MR'});
        row.termination_v611 = string(local_get_text(d611, {'termination_status','irr_diag.termination_status'}, 'UNKNOWN'));

        row.MR_v622 = f622(1);
        row.cost_v622 = f622(2);
        row.Q_aux_v622 = local_get_numeric(d622, {'Q_aux_tot','outputs.Q_aux_tot'});
        row.Irr_v622 = local_get_numeric(d622, {'Irradiacion','outputs.Irradiacion'});
        row.dry_time_v622 = local_get_numeric(d622, {'dry_time','outputs.dry_time'});
        row.M_v622 = local_get_numeric(d622, {'M','outputs.M'});
        row.detail_MR_v622 = local_get_numeric(d622, {'MR','outputs.MR'});
        row.termination_v622 = string(local_get_text(d622, {'termination_status','irr_diag.termination_status'}, 'UNKNOWN'));

        row.delta_MR = row.MR_v622 - row.MR_v611;
        row.delta_cost = row.cost_v622 - row.cost_v611;
        row.delta_M = row.M_v622 - row.M_v611;
        row.delta_Q_aux = row.Q_aux_v622 - row.Q_aux_v611;

        rows{end+1,1} = row; %#ok<AGROW>
    end

    T = struct2table(vertcat(rows{:}));

    flags = struct();

    flags.any_cost_nan_v611 = any(isnan(T.cost_v611));
    flags.any_cost_nan_v622 = any(isnan(T.cost_v622));

    flags.solar_MR_near_zero_v611 = any(T.MR_v611(strcmp(T.mode,"solar")) < 1e-6);
    flags.solar_MR_near_zero_v622 = any(T.MR_v622(strcmp(T.mode,"solar")) < 1e-6);

    flags.solar_MR_increased_after_fix = T.MR_v622(strcmp(T.mode,"solar")) > T.MR_v611(strcmp(T.mode,"solar"));

    flags.gasLP_large_MR_change = abs(T.delta_MR(strcmp(T.mode,"gasLP"))) > 1e-3;
    flags.hybrid_large_MR_change = abs(T.delta_MR(strcmp(T.mode,"hybrid"))) > 1e-3;
    flags.solar_large_MR_change = abs(T.delta_MR(strcmp(T.mode,"solar"))) > 1e-3;

    flags.hybrid_Qaux_lower_than_gasLP_v622 = ...
        T.Q_aux_v622(strcmp(T.mode,"hybrid")) < T.Q_aux_v622(strcmp(T.mode,"gasLP"));

    flags.solar_Qaux_zero_v622 = ...
        T.Q_aux_v622(strcmp(T.mode,"solar")) == 0;

    flags.solar_MR_higher_than_hybrid_v622 = ...
        T.MR_v622(strcmp(T.mode,"solar")) > T.MR_v622(strcmp(T.mode,"hybrid"));

    if flags.any_cost_nan_v622
        diagnosis = "COST_REMAINS_NAN_REQUIRES_COST_AUDIT";
    elseif flags.solar_MR_near_zero_v622
        diagnosis = "SOLAR_FIX_FAILED_MR_STILL_NEAR_ZERO";
    elseif flags.gasLP_large_MR_change || flags.hybrid_large_MR_change
        diagnosis = "TMAX_FIX_ALTERS_AUXILIARY_MODES_REQUIRES_FINAL_INDEX_AUDIT";
    elseif flags.solar_MR_higher_than_hybrid_v622 && flags.hybrid_Qaux_lower_than_gasLP_v622 && flags.solar_Qaux_zero_v622
        diagnosis = "FINAL_STATE_AND_COST_SANITY_PASS";
    else
        diagnosis = "FINAL_STATE_AND_COST_SANITY_REQUIRES_REVIEW";
    end

    outCsv = fullfile(tablesDir,'FINAL_STATE_AND_COST_SANITY_v622.csv');
    outMat = fullfile(matDir,'FINAL_STATE_AND_COST_SANITY_v622.mat');
    outLog = fullfile(logsDir,'FINAL_STATE_AND_COST_SANITY_v622.txt');

    writetable(T,outCsv);
    save(outMat,'T','flags','diagnosis','x','runDir','obj611','obj622','wrapperV11');

    fid = fopen(outLog,'w');
    fprintf(fid,'FINAL-STATE-AND-COST-SANITY-001\n');
    fprintf(fid,'status: FINAL_STATE_AND_COST_SANITY_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'runDir: %s\n', runDir);
    fprintf(fid,'obj611: %s\n', obj611);
    fprintf(fid,'obj622: %s\n', obj622);
    fprintf(fid,'wrapperV11: %s\n', wrapperV11);
    fprintf(fid,'any_cost_nan_v611: %d\n', flags.any_cost_nan_v611);
    fprintf(fid,'any_cost_nan_v622: %d\n', flags.any_cost_nan_v622);
    fprintf(fid,'solar_MR_near_zero_v611: %d\n', flags.solar_MR_near_zero_v611);
    fprintf(fid,'solar_MR_near_zero_v622: %d\n', flags.solar_MR_near_zero_v622);
    fprintf(fid,'gasLP_large_MR_change: %d\n', flags.gasLP_large_MR_change);
    fprintf(fid,'hybrid_large_MR_change: %d\n', flags.hybrid_large_MR_change);
    fprintf(fid,'solar_large_MR_change: %d\n', flags.solar_large_MR_change);
    fprintf(fid,'hybrid_Qaux_lower_than_gasLP_v622: %d\n', flags.hybrid_Qaux_lower_than_gasLP_v622);
    fprintf(fid,'solar_Qaux_zero_v622: %d\n', flags.solar_Qaux_zero_v622);
    fprintf(fid,'solar_MR_higher_than_hybrid_v622: %d\n', flags.solar_MR_higher_than_hybrid_v622);
    fprintf(fid,'outCsv: %s\n', outCsv);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'timestamp: %s\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));
    fclose(fid);

    sanity = struct();
    sanity.status = 'FINAL_STATE_AND_COST_SANITY_COMPLETED';
    sanity.diagnosis = diagnosis;
    sanity.flags = flags;
    sanity.T = T;
    sanity.runDir = runDir;
    sanity.obj611 = obj611;
    sanity.obj622 = obj622;
    sanity.wrapperV11 = wrapperV11;
    sanity.outCsv = outCsv;
    sanity.outMat = outMat;
    sanity.outLog = outLog;

    disp('=== FINAL_STATE_AND_COST_SANITY_v622 ===')
    disp(sanity.status)
    disp('=== DIAGNOSIS ===')
    disp(sanity.diagnosis)
    disp('=== FLAGS ===')
    disp(sanity.flags)
    disp('=== COMPARISON TABLE ===')
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