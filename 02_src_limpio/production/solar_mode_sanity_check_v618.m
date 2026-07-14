function check = solar_mode_sanity_check_v618(runDir)
% SOLAR_MODE_SANITY_CHECK_v618
% Revisión de sanidad del modo solar después de la corrida productiva v614.
% No repite el AG. No modifica outputs originales.
%
% Uso:
%   check = solar_mode_sanity_check_v618();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    if nargin < 1 || isempty(runDir)
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
    end

    tablesDir = fullfile(runDir,'tables');
    matDir    = fullfile(runDir,'mat');
    logsDir   = fullfile(runDir,'logs');

    selectedFile = fullfile(tablesDir,'SELECTED_SOLUTION_CORRECTED_v614b.csv');
    if ~isfile(selectedFile)
        error('No existe SELECTED_SOLUTION_CORRECTED_v614b.csv: %s', selectedFile);
    end

    Tsel = readtable(selectedFile);
    x_selected = [Tsel.m_max(1), Tsel.T_min(1), Tsel.r_div2(1), Tsel.t_rec_ini(1)];

    % Puntos de prueba: solución seleccionada + perturbaciones razonables
    X = [
        x_selected
        0.074077   45.0   0.67225   11.652
        0.074077   55.0   0.67225   11.652
        0.074077   70.0   0.67225   11.652
        0.110000   62.683 0.67225   11.652
        0.074077   62.683 0.00000   11.652
        0.074077   62.683 0.99000   11.652
        0.074077   62.683 0.67225   0.000
        0.074077   62.683 0.67225   19.000
    ];

    case_label = [
        "selected_solution"
        "selected_low_Tmin_45"
        "selected_mid_Tmin_55"
        "selected_high_Tmin_70"
        "selected_higher_mdot"
        "selected_no_recirc"
        "selected_max_recirc"
        "selected_recirc_start_0"
        "selected_recirc_start_19"
    ];

    modes = ["gasLP","hybrid","solar"];

    rows = {};

    for i = 1:size(X,1)
        x = X(i,:);

        for j = 1:numel(modes)
            mode = char(modes(j));

            [f, detail] = objective_productive_corrected_v611(x, mode);

            row = struct();
            row.case_label = case_label(i);
            row.mode = string(mode);

            row.m_max = x(1);
            row.T_min = x(2);
            row.r_div2 = x(3);
            row.t_rec_ini = x(4);

            row.objective_MR = f(1);
            row.objective_cost_USD_per_kgwater = f(2);

            row.Q_aux_tot   = local_get_numeric(detail, {'Q_aux_tot','outputs.Q_aux_tot','raw.Q_aux_tot'});
            row.Irradiacion = local_get_numeric(detail, {'Irradiacion','outputs.Irradiacion','raw.Irradiacion'});
            row.dry_time    = local_get_numeric(detail, {'dry_time','outputs.dry_time','raw.dry_time'});
            row.M           = local_get_numeric(detail, {'M','outputs.M','raw.M'});
            row.MR          = local_get_numeric(detail, {'MR','outputs.MR','raw.MR'});

            row.detail_status = string(local_get_text(detail, {'status','detail_status','outputs.status'}, 'UNKNOWN'));

            rows{end+1,1} = row; %#ok<AGROW>
        end
    end

    Tcheck = struct2table(vertcat(rows{:}));

    % Banderas de revisión
    solarRows = strcmp(Tcheck.mode,"solar");
    hybridRows = strcmp(Tcheck.mode,"hybrid");
    gasRows = strcmp(Tcheck.mode,"gasLP");

    flags = struct();
    flags.any_solar_Qaux_positive = any(Tcheck.Q_aux_tot(solarRows) > 0);
    flags.any_solar_irradiacion_zero_or_nan = any(Tcheck.Irradiacion(solarRows) <= 0 | isnan(Tcheck.Irradiacion(solarRows)));
    flags.any_solar_MR_near_zero = any(Tcheck.objective_MR(solarRows) < 1e-6);
    flags.any_solar_cost_very_low = any(Tcheck.objective_cost_USD_per_kgwater(solarRows) < 0.05);
    flags.hybrid_has_irradiation = all(Tcheck.Irradiacion(hybridRows) > 0);
    flags.gas_has_zero_irradiation = all(Tcheck.Irradiacion(gasRows) == 0);

    if flags.any_solar_MR_near_zero
        preliminary_diagnosis = "SOLAR_MODE_REQUIRES_AUDIT_MR_NEAR_ZERO";
    elseif flags.any_solar_irradiacion_zero_or_nan
        preliminary_diagnosis = "SOLAR_MODE_REQUIRES_AUDIT_IRRADIATION";
    elseif flags.any_solar_Qaux_positive
        preliminary_diagnosis = "SOLAR_MODE_REQUIRES_AUDIT_QAUX";
    else
        preliminary_diagnosis = "SOLAR_MODE_NUMERICALLY_PLAUSIBLE_IN_THIS_CHECK";
    end

    outCsv = fullfile(tablesDir,'SOLAR_MODE_SANITY_CHECK_v618.csv');
    writetable(Tcheck,outCsv);

    outMat = fullfile(matDir,'SOLAR_MODE_SANITY_CHECK_v618.mat');
    save(outMat,'Tcheck','flags','preliminary_diagnosis','x_selected','runDir');

    outLog = fullfile(logsDir,'SOLAR_MODE_SANITY_CHECK_v618.txt');
    fid = fopen(outLog,'w');
    fprintf(fid,'SOLAR-MODE-SANITY-CHECK-001\n');
    fprintf(fid,'status: SOLAR_MODE_SANITY_CHECK_COMPLETED\n');
    fprintf(fid,'runDir: %s\n', runDir);
    fprintf(fid,'diagnosis: %s\n', preliminary_diagnosis);
    fprintf(fid,'any_solar_Qaux_positive: %d\n', flags.any_solar_Qaux_positive);
    fprintf(fid,'any_solar_irradiacion_zero_or_nan: %d\n', flags.any_solar_irradiacion_zero_or_nan);
    fprintf(fid,'any_solar_MR_near_zero: %d\n', flags.any_solar_MR_near_zero);
    fprintf(fid,'any_solar_cost_very_low: %d\n', flags.any_solar_cost_very_low);
    fprintf(fid,'hybrid_has_irradiation: %d\n', flags.hybrid_has_irradiation);
    fprintf(fid,'gas_has_zero_irradiation: %d\n', flags.gas_has_zero_irradiation);
    fprintf(fid,'outCsv: %s\n', outCsv);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'timestamp: %s\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));
    fclose(fid);

    check = struct();
    check.status = 'SOLAR_MODE_SANITY_CHECK_COMPLETED';
    check.runDir = runDir;
    check.Tcheck = Tcheck;
    check.flags = flags;
    check.preliminary_diagnosis = preliminary_diagnosis;
    check.outCsv = outCsv;
    check.outMat = outMat;
    check.outLog = outLog;

    disp('=== SOLAR_MODE_SANITY_CHECK_v618 ===')
    disp(check.status)
    disp('=== PRELIMINARY DIAGNOSIS ===')
    disp(check.preliminary_diagnosis)
    disp('=== FLAGS ===')
    disp(check.flags)
    disp('=== CHECK TABLE ===')
    disp(Tcheck)
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