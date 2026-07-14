function repair = postrun_repair_mode_comparison_v617(runDir)
% POSTRUN_REPAIR_MODE_COMPARISON_v617
% Repara la comparación gasLP / hybrid / solar para una corrida productiva ya terminada.
% No repite el algoritmo genético.
% No modifica population, scores, pareto ni selected_solution.
%
% Uso:
%   repair = postrun_repair_mode_comparison_v617();
%   repair = postrun_repair_mode_comparison_v617(runDir);

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
            error('No se encontró ninguna corrida PRODUCTIVE_GA_CORRECTED_v614_* en %s', baseDir);
        end

        [~,idx] = max([d.datenum]);
        runDir = fullfile(baseDir,d(idx).name);
    end

    tablesDir = fullfile(runDir,'tables');
    matDir    = fullfile(runDir,'mat');
    logsDir   = fullfile(runDir,'logs');

    if ~isfolder(tablesDir)
        error('No existe tablesDir: %s', tablesDir);
    end

    selectedFile = fullfile(tablesDir,'SELECTED_SOLUTION_CORRECTED_v614b.csv');

    if ~isfile(selectedFile)
        error('No existe SELECTED_SOLUTION_CORRECTED_v614b.csv en: %s', tablesDir);
    end

    Tsel = readtable(selectedFile);

    requiredVars = {'m_max','T_min','r_div2','t_rec_ini'};
    for k = 1:numel(requiredVars)
        if ~ismember(requiredVars{k}, Tsel.Properties.VariableNames)
            error('Falta la columna %s en SELECTED_SOLUTION_CORRECTED_v614b.csv', requiredVars{k});
        end
    end

    x = [Tsel.m_max(1), Tsel.T_min(1), Tsel.r_div2(1), Tsel.t_rec_ini(1)];

    modes = {'gasLP'; 'hybrid'; 'solar'};
    rows = cell(numel(modes),1);

    for i = 1:numel(modes)
        mode = modes{i};

        [f, detail] = objective_productive_corrected_v611(x, mode);

        row = struct();
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
        row.irradiance_rule = string(local_get_text(detail, {'irradiance_rule','rules.irradiance_rule','outputs.irradiance_rule'}, 'UNKNOWN'));
        row.aux_rule = string(local_get_text(detail, {'aux_rule','rules.aux_rule','outputs.aux_rule'}, 'UNKNOWN'));

        rows{i} = row;
    end

    Tmode = struct2table(vertcat(rows{:}));

    repairedFile = fullfile(tablesDir,'MODE_COMPARISON_REPAIRED_v617.csv');
    writetable(Tmode, repairedFile);

    matFile = fullfile(matDir,'POSTRUN_MODE_COMPARISON_REPAIR_v617.mat');
    save(matFile,'Tmode','Tsel','x','runDir','repairedFile');

    logFile = fullfile(logsDir,'POSTRUN_MODE_COMPARISON_REPAIR_v617.txt');
    fid = fopen(logFile,'w');
    fprintf(fid,'POSTRUN-MODE-COMPARISON-REPAIR-001\n');
    fprintf(fid,'status: POSTRUN_MODE_COMPARISON_REPAIR_COMPLETED\n');
    fprintf(fid,'runDir: %s\n', runDir);
    fprintf(fid,'selectedFile: %s\n', selectedFile);
    fprintf(fid,'repairedFile: %s\n', repairedFile);
    fprintf(fid,'matFile: %s\n', matFile);
    fprintf(fid,'timestamp: %s\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));
    fclose(fid);

    repair = struct();
    repair.status = 'POSTRUN_MODE_COMPARISON_REPAIR_COMPLETED';
    repair.runDir = runDir;
    repair.selectedFile = selectedFile;
    repair.repairedFile = repairedFile;
    repair.matFile = matFile;
    repair.logFile = logFile;
    repair.Tmode = Tmode;

    disp('=== POSTRUN_MODE_COMPARISON_REPAIR_v617 ===')
    disp(repair.status)
    disp('=== REPAIRED MODE COMPARISON ===')
    disp(Tmode)
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