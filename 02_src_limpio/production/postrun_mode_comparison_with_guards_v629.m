function cmp = postrun_mode_comparison_with_guards_v629()
% POSTRUN_MODE_COMPARISON_WITH_GUARDS_v629
% Micropaso 6.29 — POSTRUN-MODE-COMPARISON-WITH-GUARDS-001
%
% Objetivo:
%   Generar comparación postrun final de modos usando la objective con
%   guardas físicas:
%
%       objective_productive_corrected_v628b_nonphysical_penalty
%
%   Estados esperados:
%       gasLP  -> VALID
%       hybrid -> VALID
%       solar  -> NONPHYSICAL_TRAJECTORY / INVALID
%
% No repite el AG.
% No modifica v10.
% No modifica v611.
% No sustituye archivos productivos originales.
%
% Requiere:
%   Micropaso 6.28b aprobado:
%       objective_productive_corrected_v628b_nonphysical_penalty.m
%       opt_tunel_mod2_v17_nonphysical_penalty.m
%       nonphysical_guard_eval_v628b.m
%
% Uso:
%   cmp = postrun_mode_comparison_with_guards_v629();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    obj628b = which('objective_productive_corrected_v628b_nonphysical_penalty');
    wrap17  = which('opt_tunel_mod2_v17_nonphysical_penalty');
    guardFn = which('nonphysical_guard_eval_v628b');

    if isempty(obj628b)
        error('No se encontró objective_productive_corrected_v628b_nonphysical_penalty. Ejecuta/aprueba primero 6.28b.');
    end

    if isempty(wrap17)
        error('No se encontró opt_tunel_mod2_v17_nonphysical_penalty. Ejecuta/aprueba primero 6.28b.');
    end

    if isempty(guardFn)
        error('No se encontró nonphysical_guard_eval_v628b. Ejecuta/aprueba primero 6.28b.');
    end

    % ---------------------------------------------------------------------
    % Localizar corrida productiva más reciente
    % ---------------------------------------------------------------------
    baseDir = fullfile(rootDir,'05_runs','productive_v614b');

    if ~isfolder(baseDir)
        error('No existe baseDir: %s', baseDir);
    end

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

    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end

    selectedFile = fullfile(tablesDir,'SELECTED_SOLUTION_CORRECTED_v614b.csv');

    if ~isfile(selectedFile)
        error('No existe SELECTED_SOLUTION_CORRECTED_v614b.csv: %s', selectedFile);
    end

    Tsel = readtable(selectedFile);
    x = [Tsel.m_max(1), Tsel.T_min(1), Tsel.r_div2(1), Tsel.t_rec_ini(1)];

    % ---------------------------------------------------------------------
    % Evaluar modos con guardas
    % ---------------------------------------------------------------------
    modes = ["gasLP","hybrid","solar"];

    rows = {};

    for k = 1:numel(modes)
        mode = modes(k);

        row = struct();
        row.mode = mode;

        row.m_max = x(1);
        row.T_min = x(2);
        row.r_div2 = x(3);
        row.t_rec_ini = x(4);

        try
            [f,dout] = objective_productive_corrected_v628b_nonphysical_penalty(x, mode);

            row.eval_status = "OK";
            row.error_message = "";

            row.MR_objective = f(1);
            row.cost_objective = f(2);

            row.detail_status = local_get_text(dout, {'status'}, 'UNKNOWN');
            row.mode_operation = local_get_text(dout, {'mode_operation'}, char(mode));

            row.Q_aux_tot = local_get_numeric(dout, {'outputs.Q_aux_tot','Q_aux_tot'});
            row.Irradiacion = local_get_numeric(dout, {'outputs.Irradiacion','Irradiacion'});
            row.dry_time = local_get_numeric(dout, {'outputs.dry_time','dry_time'});
            row.M = local_get_numeric(dout, {'outputs.M','M'});
            row.MR = local_get_numeric(dout, {'outputs.MR','MR'});

            row.cost_specific_USD_per_kgwater = local_get_numeric(dout, {'cost.cost_specific_USD_per_kgwater'});
            row.total_cost_USD = local_get_numeric(dout, {'cost.total_cost_USD'});
            row.electric_energy_kWh = local_get_numeric(dout, {'cost.electric_energy_kWh'});
            row.LPG_energy_MJ = local_get_numeric(dout, {'cost.LPG_energy_MJ'});
            row.solar_energy_MJ = local_get_numeric(dout, {'cost.solar_energy_MJ'});
            row.water_removed_kg = local_get_numeric(dout, {'cost.water_removed_kg'});

            row.irradiance_rule = local_get_text(dout, {'irradiance.rule'}, '');
            row.auxiliary_rule = local_get_text(dout, {'auxiliary.rule'}, '');

            % La objective v628b clonada puede no propagar irr_diag completo.
            % Por eso usamos estado/costo/f como fuente de clasificación.
            if row.MR_objective >= 1000 || row.cost_objective >= 1e6 || strcmp(string(row.detail_status),"INVALID_COST")
                row.validity = "INVALID";
                row.invalid_reason = "NONPHYSICAL_OR_INVALID_COST_TRAJECTORY";
            else
                row.validity = "VALID";
                row.invalid_reason = "";
            end

        catch ME
            row.eval_status = "ERROR";
            row.error_message = string(ME.message);

            row.MR_objective = NaN;
            row.cost_objective = NaN;

            row.detail_status = "ERROR";
            row.mode_operation = mode;

            row.Q_aux_tot = NaN;
            row.Irradiacion = NaN;
            row.dry_time = NaN;
            row.M = NaN;
            row.MR = NaN;

            row.cost_specific_USD_per_kgwater = NaN;
            row.total_cost_USD = NaN;
            row.electric_energy_kWh = NaN;
            row.LPG_energy_MJ = NaN;
            row.solar_energy_MJ = NaN;
            row.water_removed_kg = NaN;

            row.irradiance_rule = "";
            row.auxiliary_rule = "";

            row.validity = "ERROR";
            row.invalid_reason = "EVALUATION_ERROR";
        end

        rows{end+1,1} = row; %#ok<AGROW>
    end

    T = struct2table(vertcat(rows{:}));

    % ---------------------------------------------------------------------
    % Comparativos válidos
    % ---------------------------------------------------------------------
    gasRow = strcmp(T.mode,"gasLP");
    hybRow = strcmp(T.mode,"hybrid");
    solRow = strcmp(T.mode,"solar");

    validGas = strcmp(T.validity(gasRow),"VALID");
    validHyb = strcmp(T.validity(hybRow),"VALID");
    validSol = strcmp(T.validity(solRow),"VALID");

    metrics = struct();

    if validGas && validHyb
        metrics.delta_Q_aux_hybrid_minus_gasLP = T.Q_aux_tot(hybRow) - T.Q_aux_tot(gasRow);
        metrics.reduction_Q_aux_hybrid_vs_gasLP_abs = T.Q_aux_tot(gasRow) - T.Q_aux_tot(hybRow);
        metrics.reduction_Q_aux_hybrid_vs_gasLP_pct = ...
            100 * (T.Q_aux_tot(gasRow) - T.Q_aux_tot(hybRow)) / T.Q_aux_tot(gasRow);

        metrics.delta_cost_hybrid_minus_gasLP = T.cost_objective(hybRow) - T.cost_objective(gasRow);
        metrics.reduction_cost_hybrid_vs_gasLP_abs = T.cost_objective(gasRow) - T.cost_objective(hybRow);
        metrics.reduction_cost_hybrid_vs_gasLP_pct = ...
            100 * (T.cost_objective(gasRow) - T.cost_objective(hybRow)) / T.cost_objective(gasRow);

        metrics.delta_MR_hybrid_minus_gasLP = T.MR_objective(hybRow) - T.MR_objective(gasRow);

        metrics.hybrid_uses_less_aux_than_gasLP = T.Q_aux_tot(hybRow) < T.Q_aux_tot(gasRow);
        metrics.hybrid_cheaper_than_gasLP = T.cost_objective(hybRow) < T.cost_objective(gasRow);
        metrics.hybrid_MR_similar_to_gasLP = abs(T.MR_objective(hybRow) - T.MR_objective(gasRow)) < 1e-3;
    else
        metrics.delta_Q_aux_hybrid_minus_gasLP = NaN;
        metrics.reduction_Q_aux_hybrid_vs_gasLP_abs = NaN;
        metrics.reduction_Q_aux_hybrid_vs_gasLP_pct = NaN;

        metrics.delta_cost_hybrid_minus_gasLP = NaN;
        metrics.reduction_cost_hybrid_vs_gasLP_abs = NaN;
        metrics.reduction_cost_hybrid_vs_gasLP_pct = NaN;

        metrics.delta_MR_hybrid_minus_gasLP = NaN;

        metrics.hybrid_uses_less_aux_than_gasLP = false;
        metrics.hybrid_cheaper_than_gasLP = false;
        metrics.hybrid_MR_similar_to_gasLP = false;
    end

    % ---------------------------------------------------------------------
    % Dictamen
    % ---------------------------------------------------------------------
    flags = struct();

    flags.all_eval_status_ok = all(strcmp(T.eval_status,"OK"));

    flags.gasLP_valid = validGas;
    flags.hybrid_valid = validHyb;
    flags.solar_valid = validSol;
    flags.solar_invalid = ~validSol;

    flags.solar_penalized = T.MR_objective(solRow) >= 1000 || T.cost_objective(solRow) >= 1e6;
    flags.gasLP_not_penalized = T.MR_objective(gasRow) < 1000 && T.cost_objective(gasRow) < 1e6;
    flags.hybrid_not_penalized = T.MR_objective(hybRow) < 1000 && T.cost_objective(hybRow) < 1e6;

    flags.hybrid_gasLP_comparison_allowed = validGas && validHyb;
    flags.solar_performance_claims_allowed = validSol;

    flags.hybrid_uses_less_aux_than_gasLP = metrics.hybrid_uses_less_aux_than_gasLP;
    flags.hybrid_cheaper_than_gasLP = metrics.hybrid_cheaper_than_gasLP;
    flags.hybrid_MR_similar_to_gasLP = metrics.hybrid_MR_similar_to_gasLP;

    if ~flags.all_eval_status_ok
        diagnosis = "POSTRUN_MODE_COMPARISON_WITH_GUARDS_EVALUATION_ERROR";
    elseif flags.gasLP_valid && flags.hybrid_valid && flags.solar_invalid && flags.solar_penalized
        diagnosis = "POSTRUN_MODE_COMPARISON_WITH_GUARDS_PASS_SOLAR_INVALID";
    elseif flags.gasLP_valid && flags.hybrid_valid && flags.solar_valid
        diagnosis = "POSTRUN_MODE_COMPARISON_WITH_GUARDS_ALL_VALID_REVIEW_SOLAR";
    else
        diagnosis = "POSTRUN_MODE_COMPARISON_WITH_GUARDS_REQUIRES_REVIEW";
    end

    % ---------------------------------------------------------------------
    % Tabla resumida para tesis/artículo
    % ---------------------------------------------------------------------
    Treport = table();
    Treport.mode = T.mode;
    Treport.validity = T.validity;
    Treport.MR = T.MR_objective;
    Treport.cost_USD_per_kgwater = T.cost_objective;
    Treport.Q_aux_tot = T.Q_aux_tot;
    Treport.Irradiacion = T.Irradiacion;
    Treport.dry_time_h = T.dry_time;
    Treport.M_final = T.M;
    Treport.invalid_reason = T.invalid_reason;

    % ---------------------------------------------------------------------
    % Guardar salidas
    % ---------------------------------------------------------------------
    outCsvFull   = fullfile(tablesDir,'POSTRUN_MODE_COMPARISON_WITH_GUARDS_v629_full.csv');
    outCsvReport = fullfile(tablesDir,'POSTRUN_MODE_COMPARISON_WITH_GUARDS_v629_report.csv');
    outMat       = fullfile(matDir,'POSTRUN_MODE_COMPARISON_WITH_GUARDS_v629.mat');
    outMd        = fullfile(logsDir,'POSTRUN_MODE_COMPARISON_WITH_GUARDS_v629.md');
    outLog       = fullfile(logsDir,'POSTRUN_MODE_COMPARISON_WITH_GUARDS_v629.txt');

    writetable(T,outCsvFull);
    writetable(Treport,outCsvReport);

    save(outMat,'T','Treport','flags','metrics','diagnosis','x','runDir','obj628b','wrap17','guardFn');

    % Markdown
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# Micropaso 6.29 — POSTRUN-MODE-COMPARISON-WITH-GUARDS-001\n\n');
    fprintf(fid,'## Estatus\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);

    fprintf(fid,'## Solución evaluada\n\n');
    fprintf(fid,'- `m_max = %.12g`\n', x(1));
    fprintf(fid,'- `T_min = %.12g`\n', x(2));
    fprintf(fid,'- `r_div2 = %.12g`\n', x(3));
    fprintf(fid,'- `t_rec_ini = %.12g`\n\n', x(4));

    fprintf(fid,'## Comparación final con guardas\n\n');
    for r = 1:height(Treport)
        fprintf(fid,'### %s\n\n', Treport.mode(r));
        fprintf(fid,'- Validez: `%s`\n', Treport.validity(r));
        fprintf(fid,'- MR: %.12g\n', Treport.MR(r));
        fprintf(fid,'- Costo específico: %.12g USD/kgwater\n', Treport.cost_USD_per_kgwater(r));
        fprintf(fid,'- Q_aux_tot: %.12g\n', Treport.Q_aux_tot(r));
        fprintf(fid,'- Irradiación: %.12g\n', Treport.Irradiacion(r));
        fprintf(fid,'- Tiempo de secado: %.12g h\n', Treport.dry_time_h(r));
        fprintf(fid,'- M final: %.12g\n', Treport.M_final(r));
        if strlength(string(Treport.invalid_reason(r))) > 0
            fprintf(fid,'- Motivo de invalidez: `%s`\n', Treport.invalid_reason(r));
        end
        fprintf(fid,'\n');
    end

    fprintf(fid,'## Dictamen técnico\n\n');

    if flags.hybrid_gasLP_comparison_allowed
        fprintf(fid,'La comparación gasLP/hybrid se conserva como defendible bajo las guardas físicas implementadas.\n\n');
        fprintf(fid,'El modo híbrido reduce la energía auxiliar respecto a gasLP en %.6g unidades equivalentes, equivalente a %.6g %%.\n\n', ...
            metrics.reduction_Q_aux_hybrid_vs_gasLP_abs, ...
            metrics.reduction_Q_aux_hybrid_vs_gasLP_pct);
        fprintf(fid,'El modo híbrido reduce el costo específico respecto a gasLP en %.6g USD/kgwater, equivalente a %.6g %%.\n\n', ...
            metrics.reduction_cost_hybrid_vs_gasLP_abs, ...
            metrics.reduction_cost_hybrid_vs_gasLP_pct);
        fprintf(fid,'La diferencia de MR entre hybrid y gasLP es %.12g.\n\n', ...
            metrics.delta_MR_hybrid_minus_gasLP);
    else
        fprintf(fid,'La comparación gasLP/hybrid no debe usarse todavía porque al menos uno de los dos modos no quedó válido.\n\n');
    end

    if flags.solar_invalid
        fprintf(fid,'El modo solar puro queda excluido de afirmaciones de desempeño porque fue penalizado como trayectoria inválida/no física.\n\n');
    else
        fprintf(fid,'El modo solar puro quedó válido bajo esta evaluación; requiere revisión antes de restituirlo en conclusiones.\n\n');
    end

    fprintf(fid,'## Política de reporte\n\n');
    fprintf(fid,'- Reportar gasLP e híbrido como modos válidos.\n');
    fprintf(fid,'- Reportar solar puro como inválido/no físico bajo la formulación actual.\n');
    fprintf(fid,'- No afirmar superioridad del modo solar puro.\n');
    fprintf(fid,'- No repetir el AG en esta etapa.\n\n');

    fclose(fid);

    % TXT
    fid = fopen(outLog,'w');
    fprintf(fid,'POSTRUN-MODE-COMPARISON-WITH-GUARDS-001\n');
    fprintf(fid,'status: POSTRUN_MODE_COMPARISON_WITH_GUARDS_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'runDir: %s\n', runDir);
    fprintf(fid,'obj628b: %s\n', obj628b);
    fprintf(fid,'wrap17: %s\n', wrap17);
    fprintf(fid,'guardFn: %s\n', guardFn);
    fprintf(fid,'outCsvFull: %s\n', outCsvFull);
    fprintf(fid,'outCsvReport: %s\n', outCsvReport);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'--- FLAGS ---\n');
    fprintf(fid,'gasLP_valid: %d\n', flags.gasLP_valid);
    fprintf(fid,'hybrid_valid: %d\n', flags.hybrid_valid);
    fprintf(fid,'solar_valid: %d\n', flags.solar_valid);
    fprintf(fid,'solar_invalid: %d\n', flags.solar_invalid);
    fprintf(fid,'solar_penalized: %d\n', flags.solar_penalized);
    fprintf(fid,'hybrid_gasLP_comparison_allowed: %d\n', flags.hybrid_gasLP_comparison_allowed);
    fprintf(fid,'solar_performance_claims_allowed: %d\n\n', flags.solar_performance_claims_allowed);

    fprintf(fid,'--- METRICS ---\n');
    fprintf(fid,'reduction_Q_aux_hybrid_vs_gasLP_abs: %.12g\n', metrics.reduction_Q_aux_hybrid_vs_gasLP_abs);
    fprintf(fid,'reduction_Q_aux_hybrid_vs_gasLP_pct: %.12g\n', metrics.reduction_Q_aux_hybrid_vs_gasLP_pct);
    fprintf(fid,'reduction_cost_hybrid_vs_gasLP_abs: %.12g\n', metrics.reduction_cost_hybrid_vs_gasLP_abs);
    fprintf(fid,'reduction_cost_hybrid_vs_gasLP_pct: %.12g\n', metrics.reduction_cost_hybrid_vs_gasLP_pct);
    fprintf(fid,'delta_MR_hybrid_minus_gasLP: %.12g\n\n', metrics.delta_MR_hybrid_minus_gasLP);

    fprintf(fid,'--- REPORT TABLE ---\n');
    for r = 1:height(Treport)
        fprintf(fid,'mode: %s\n', Treport.mode(r));
        fprintf(fid,'validity: %s\n', Treport.validity(r));
        fprintf(fid,'MR: %.12g\n', Treport.MR(r));
        fprintf(fid,'cost_USD_per_kgwater: %.12g\n', Treport.cost_USD_per_kgwater(r));
        fprintf(fid,'Q_aux_tot: %.12g\n', Treport.Q_aux_tot(r));
        fprintf(fid,'Irradiacion: %.12g\n', Treport.Irradiacion(r));
        fprintf(fid,'dry_time_h: %.12g\n', Treport.dry_time_h(r));
        fprintf(fid,'M_final: %.12g\n', Treport.M_final(r));
        fprintf(fid,'invalid_reason: %s\n\n', Treport.invalid_reason(r));
    end

    fclose(fid);

    cmp = struct();
    cmp.status = 'POSTRUN_MODE_COMPARISON_WITH_GUARDS_COMPLETED';
    cmp.diagnosis = diagnosis;
    cmp.flags = flags;
    cmp.metrics = metrics;
    cmp.T = T;
    cmp.Treport = Treport;
    cmp.x = x;
    cmp.runDir = runDir;
    cmp.obj628b = obj628b;
    cmp.wrap17 = wrap17;
    cmp.guardFn = guardFn;
    cmp.outCsvFull = outCsvFull;
    cmp.outCsvReport = outCsvReport;
    cmp.outMat = outMat;
    cmp.outMd = outMd;
    cmp.outLog = outLog;

    disp('=== POSTRUN_MODE_COMPARISON_WITH_GUARDS_v629 ===')
    disp(cmp.status)
    disp('=== DIAGNOSIS ===')
    disp(cmp.diagnosis)
    disp('=== FLAGS ===')
    disp(cmp.flags)
    disp('=== METRICS ===')
    disp(cmp.metrics)
    disp('=== FULL TABLE ===')
    disp(cmp.T)
    disp('=== REPORT TABLE ===')
    disp(cmp.Treport)
    disp('=== OUTPUT FILES ===')
    disp(cmp.outCsvFull)
    disp(cmp.outCsvReport)
    disp(cmp.outMd)
    disp(cmp.outMat)
    disp(cmp.outLog)
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
    value = string(defaultValue);

    for i = 1:numel(paths)
        [ok,tmp] = local_get_path(s, paths{i});
        if ok && ~isempty(tmp)
            if isstring(tmp)
                value = tmp(1);
                return
            elseif ischar(tmp)
                value = string(tmp);
                return
            elseif iscell(tmp) && ~isempty(tmp)
                value = string(tmp{1});
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