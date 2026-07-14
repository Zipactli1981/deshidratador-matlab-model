function audit = audit_solar_mode_wrapper_v619()
% AUDIT_SOLAR_MODE_WRAPPER_v619
% Auditoría estática + dinámica ligera del modo solar.
% No repite el AG.
% No modifica archivos productivos.
% No corrige todavía: solo diagnostica.

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    wrapperFile = which('opt_tunel_mod2_v10_energy_mode_corrected');
    objFile     = which('objective_productive_corrected_v611');

    if isempty(wrapperFile)
        error('No se encontró opt_tunel_mod2_v10_energy_mode_corrected.m en el path.');
    end

    if isempty(objFile)
        error('No se encontró objective_productive_corrected_v611.m en el path.');
    end

    wrapperText = fileread(wrapperFile);
    objText     = fileread(objFile);

    audit = struct();
    audit.status = 'SOLAR_MODE_WRAPPER_AUDIT_COMPLETED';
    audit.wrapperFile = wrapperFile;
    audit.objectiveFile = objFile;

    % --- Auditoría estática del wrapper
    static = struct();

    static.has_mode_solar_text       = contains(wrapperText,'''solar''') || contains(wrapperText,'"solar"') || contains(wrapperText,'solar');
    static.has_mode_hybrid_text      = contains(wrapperText,'''hybrid''') || contains(wrapperText,'"hybrid"') || contains(wrapperText,'hybrid');
    static.has_mode_gasLP_text       = contains(wrapperText,'''gasLP''') || contains(wrapperText,'"gasLP"') || contains(wrapperText,'gasLP');

    static.has_calor_aux             = contains(wrapperText,'calor_aux');
    static.has_calor_aux_false       = contains(wrapperText,'calor_aux=false') || contains(wrapperText,'calor_aux = false');
    static.has_calor_aux_true        = contains(wrapperText,'calor_aux=true')  || contains(wrapperText,'calor_aux = true');

    static.has_I_effective           = contains(wrapperText,'I_effective');
    static.has_I_equals_zero         = contains(wrapperText,'I(i)=0') || contains(wrapperText,'I(i) = 0');
    static.has_I_busc                = contains(wrapperText,'I_busc');

    static.has_try_catch             = contains(wrapperText,'try') && contains(wrapperText,'catch');
    static.has_ode23tb               = contains(wrapperText,'ode23tb') || contains(fileread(which('tunel_mod2')),'ode23tb');

    static.has_MR_assignment         = contains(wrapperText,'MR');
    static.has_M_assignment          = contains(wrapperText,'M');
    static.has_dry_time_assignment   = contains(wrapperText,'dry_time');
    static.has_Irradiacion_assignment= contains(wrapperText,'Irradiacion');
    static.has_Q_aux_tot_assignment  = contains(wrapperText,'Q_aux_tot');

    % --- Auditoría estática de la función objetivo
    objstatic = struct();

    objstatic.has_mode_input         = contains(objText,'mode');
    objstatic.has_objective_MR       = contains(objText,'f(1)') && contains(objText,'MR');
    objstatic.has_objective_cost     = contains(objText,'f(2)') && contains(objText,'cost');
    objstatic.has_detail             = contains(objText,'detail');
    objstatic.has_penalty_or_nan     = contains(objText,'NaN') || contains(objText,'Inf') || contains(objText,'penalty');

    % --- Evaluación dinámica focalizada
    % Usar solución seleccionada si existe
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

    selectedFile = fullfile(runDir,'tables','SELECTED_SOLUTION_CORRECTED_v614b.csv');
    if ~isfile(selectedFile)
        error('No existe selected solution: %s', selectedFile);
    end

    Tsel = readtable(selectedFile);
    x_selected = [Tsel.m_max(1), Tsel.T_min(1), Tsel.r_div2(1), Tsel.t_rec_ini(1)];

    modes = {'gasLP','hybrid','solar'};
    rows = cell(numel(modes),1);

    for i = 1:numel(modes)
        mode = modes{i};

        lastwarn('');
        warnState = warning;
        warning('on','all');

        try
            [f, detail] = objective_productive_corrected_v611(x_selected, mode);
            [warnMsg, warnId] = lastwarn;

            row = struct();
            row.mode = string(mode);
            row.eval_status = "OK";
            row.warning_id = string(warnId);
            row.warning_msg = string(warnMsg);

            row.m_max = x_selected(1);
            row.T_min = x_selected(2);
            row.r_div2 = x_selected(3);
            row.t_rec_ini = x_selected(4);

            row.objective_MR = f(1);
            row.objective_cost_USD_per_kgwater = f(2);

            row.Q_aux_tot   = local_get_numeric(detail, {'Q_aux_tot','outputs.Q_aux_tot','raw.Q_aux_tot'});
            row.Irradiacion = local_get_numeric(detail, {'Irradiacion','outputs.Irradiacion','raw.Irradiacion'});
            row.dry_time    = local_get_numeric(detail, {'dry_time','outputs.dry_time','raw.dry_time'});
            row.M           = local_get_numeric(detail, {'M','outputs.M','raw.M'});
            row.MR          = local_get_numeric(detail, {'MR','outputs.MR','raw.MR'});

            row.detail_status = string(local_get_text(detail, {'status','detail_status','outputs.status'}, 'UNKNOWN'));

        catch ME
            row = struct();
            row.mode = string(mode);
            row.eval_status = "ERROR";
            row.warning_id = "";
            row.warning_msg = "";
            row.m_max = x_selected(1);
            row.T_min = x_selected(2);
            row.r_div2 = x_selected(3);
            row.t_rec_ini = x_selected(4);
            row.objective_MR = NaN;
            row.objective_cost_USD_per_kgwater = NaN;
            row.Q_aux_tot = NaN;
            row.Irradiacion = NaN;
            row.dry_time = NaN;
            row.M = NaN;
            row.MR = NaN;
            row.detail_status = string(ME.message);
        end

        warning(warnState);
        rows{i} = row;
    end

    Tdynamic = struct2table(vertcat(rows{:}));

    % --- Diagnóstico lógico
    flags = struct();

    solarRow  = strcmp(Tdynamic.mode,'solar');
    hybridRow = strcmp(Tdynamic.mode,'hybrid');
    gasRow    = strcmp(Tdynamic.mode,'gasLP');

    flags.wrapper_has_solar_branch = static.has_mode_solar_text;
    flags.wrapper_uses_calor_aux   = static.has_calor_aux;
    flags.wrapper_has_I_equals_zero = static.has_I_equals_zero;

    flags.gas_irradiacion_zero = all(Tdynamic.Irradiacion(gasRow) == 0);
    flags.hybrid_irradiacion_positive = all(Tdynamic.Irradiacion(hybridRow) > 0);
    flags.solar_irradiacion_positive = all(Tdynamic.Irradiacion(solarRow) > 0);

    flags.solar_Qaux_zero = all(Tdynamic.Q_aux_tot(solarRow) == 0);
    flags.solar_MR_near_zero = any(Tdynamic.objective_MR(solarRow) < 1e-6);
    flags.solar_cost_very_low = any(Tdynamic.objective_cost_USD_per_kgwater(solarRow) < 0.05);
    flags.solar_warning_present = strlength(Tdynamic.warning_msg(solarRow)) > 0;

    if flags.solar_MR_near_zero && flags.solar_warning_present
        diagnosis = "SOLAR_BRANCH_NUMERICALLY_UNSTABLE_AND_MR_NEAR_ZERO";
    elseif flags.solar_MR_near_zero
        diagnosis = "SOLAR_BRANCH_MR_NEAR_ZERO_REQUIRES_LOGIC_AUDIT";
    elseif flags.solar_warning_present
        diagnosis = "SOLAR_BRANCH_NUMERICALLY_UNSTABLE";
    elseif ~flags.solar_irradiacion_positive
        diagnosis = "SOLAR_BRANCH_IRRADIATION_NOT_POSITIVE";
    else
        diagnosis = "SOLAR_BRANCH_STATIC_DYNAMIC_AUDIT_PASSED_PRELIMINARY";
    end

    audit.static_wrapper = static;
    audit.static_objective = objstatic;
    audit.runDir = runDir;
    audit.selectedFile = selectedFile;
    audit.x_selected = x_selected;
    audit.Tdynamic = Tdynamic;
    audit.flags = flags;
    audit.diagnosis = diagnosis;

    tablesDir = fullfile(runDir,'tables');
    matDir    = fullfile(runDir,'mat');
    logsDir   = fullfile(runDir,'logs');

    outCsv = fullfile(tablesDir,'SOLAR_MODE_WRAPPER_AUDIT_v619.csv');
    outMat = fullfile(matDir,'SOLAR_MODE_WRAPPER_AUDIT_v619.mat');
    outLog = fullfile(logsDir,'SOLAR_MODE_WRAPPER_AUDIT_v619.txt');

    writetable(Tdynamic,outCsv);
    save(outMat,'audit');

    fid = fopen(outLog,'w');
    fprintf(fid,'SOLAR-MODE-WRAPPER-AUDIT-001\n');
    fprintf(fid,'status: %s\n', audit.status);
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'wrapperFile: %s\n', wrapperFile);
    fprintf(fid,'objectiveFile: %s\n', objFile);
    fprintf(fid,'runDir: %s\n', runDir);
    fprintf(fid,'selectedFile: %s\n', selectedFile);
    fprintf(fid,'wrapper_has_solar_branch: %d\n', flags.wrapper_has_solar_branch);
    fprintf(fid,'wrapper_uses_calor_aux: %d\n', flags.wrapper_uses_calor_aux);
    fprintf(fid,'wrapper_has_I_equals_zero: %d\n', flags.wrapper_has_I_equals_zero);
    fprintf(fid,'gas_irradiacion_zero: %d\n', flags.gas_irradiacion_zero);
    fprintf(fid,'hybrid_irradiacion_positive: %d\n', flags.hybrid_irradiacion_positive);
    fprintf(fid,'solar_irradiacion_positive: %d\n', flags.solar_irradiacion_positive);
    fprintf(fid,'solar_Qaux_zero: %d\n', flags.solar_Qaux_zero);
    fprintf(fid,'solar_MR_near_zero: %d\n', flags.solar_MR_near_zero);
    fprintf(fid,'solar_cost_very_low: %d\n', flags.solar_cost_very_low);
    fprintf(fid,'solar_warning_present: %d\n', flags.solar_warning_present);
    fprintf(fid,'outCsv: %s\n', outCsv);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'timestamp: %s\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));
    fclose(fid);

    audit.outCsv = outCsv;
    audit.outMat = outMat;
    audit.outLog = outLog;

    disp('=== SOLAR_MODE_WRAPPER_AUDIT_v619 ===')
    disp(audit.status)
    disp('=== DIAGNOSIS ===')
    disp(audit.diagnosis)
    disp('=== FLAGS ===')
    disp(audit.flags)
    disp('=== DYNAMIC MODE CHECK ===')
    disp(Tdynamic)
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