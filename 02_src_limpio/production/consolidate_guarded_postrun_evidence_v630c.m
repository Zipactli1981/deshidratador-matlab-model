function cons = consolidate_guarded_postrun_evidence_v630c()
% CONSOLIDATE_GUARDED_POSTRUN_EVIDENCE_v630c
% Micropaso 6.30c — consolidado robusto usando MAT, no CSV.
%
% Corrige los errores de v630/v630b asociados a lectura de CSV.
%
% Usa:
%   mat/SOLAR_NONPHYSICAL_STATE_GUARD_v626.mat
%   mat/IMPLEMENT_NONPHYSICAL_PENALTY_WRAPPER_v628b.mat
%   mat/POSTRUN_MODE_COMPARISON_WITH_GUARDS_v629.mat
%
% No modifica:
%   - v10
%   - v611
%   - corrida productiva original
%
% Uso:
%   cons = consolidate_guarded_postrun_evidence_v630c();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

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
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'PRODUCTIVE_GA_CORRECTED_v614_');
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

    % ---------------------------------------------------------------------
    % MAT requeridos
    % ---------------------------------------------------------------------
    mat626  = fullfile(matDir,'SOLAR_NONPHYSICAL_STATE_GUARD_v626.mat');
    mat628b = fullfile(matDir,'IMPLEMENT_NONPHYSICAL_PENALTY_WRAPPER_v628b.mat');
    mat629  = fullfile(matDir,'POSTRUN_MODE_COMPARISON_WITH_GUARDS_v629.mat');

    if ~isfile(mat626)
        error('No existe MAT v626: %s', mat626);
    end

    if ~isfile(mat628b)
        error('No existe MAT v628b: %s', mat628b);
    end

    if ~isfile(mat629)
        error('No existe MAT v629: %s', mat629);
    end

    S626  = load(mat626);
    S628b = load(mat628b);
    S629  = load(mat629);

    % ---------------------------------------------------------------------
    % Validar variables internas esperadas
    % ---------------------------------------------------------------------
    if ~isfield(S626,'T')
        error('El MAT v626 no contiene T.');
    end

    if ~isfield(S626,'Tviol')
        error('El MAT v626 no contiene Tviol.');
    end

    if ~isfield(S628b,'Tdirect')
        error('El MAT v628b no contiene Tdirect.');
    end

    if ~isfield(S628b,'Tobj')
        error('El MAT v628b no contiene Tobj.');
    end

    if ~isfield(S629,'Treport')
        error('El MAT v629 no contiene Treport.');
    end

    if ~isfield(S629,'T')
        error('El MAT v629 no contiene T.');
    end

    T626main   = S626.T;
    T626viol   = S626.Tviol;
    T628direct = S628b.Tdirect;
    T628obj    = S628b.Tobj;
    T629full   = S629.T;
    T629report = S629.Treport;

    % ---------------------------------------------------------------------
    % Normalizar columna mode si fuera necesario
    % ---------------------------------------------------------------------
    T626main   = local_force_mode_string_v630c(T626main,   'T626main');
    T628direct = local_force_mode_string_v630c(T628direct, 'T628direct');
    T628obj    = local_force_mode_string_v630c(T628obj,    'T628obj');
    T629full   = local_force_mode_string_v630c(T629full,   'T629full');
    T629report = local_force_mode_string_v630c(T629report, 'T629report');

    % ---------------------------------------------------------------------
    % Vector solución
    % ---------------------------------------------------------------------
    if isfield(S629,'x')
        xvec = S629.x;
    elseif isfield(S628b,'x')
        xvec = S628b.x;
    else
        error('No se encontró vector x en MAT v629 ni v628b.');
    end

    x = struct();
    x.m_max = xvec(1);
    x.T_min = xvec(2);
    x.r_div2 = xvec(3);
    x.t_rec_ini = xvec(4);

    % ---------------------------------------------------------------------
    % Filas por modo
    % ---------------------------------------------------------------------
    gas629 = T629report(strcmp(string(T629report.mode),"gasLP"),:);
    hyb629 = T629report(strcmp(string(T629report.mode),"hybrid"),:);
    sol629 = T629report(strcmp(string(T629report.mode),"solar"),:);

    gas626 = T626main(strcmp(string(T626main.mode),"gasLP"),:);
    hyb626 = T626main(strcmp(string(T626main.mode),"hybrid"),:);
    sol626 = T626main(strcmp(string(T626main.mode),"solar"),:);

    gas628 = T628direct(strcmp(string(T628direct.mode),"gasLP"),:);
    hyb628 = T628direct(strcmp(string(T628direct.mode),"hybrid"),:);
    sol628 = T628direct(strcmp(string(T628direct.mode),"solar"),:);

    if isempty(gas629) || isempty(hyb629) || isempty(sol629)
        disp(T629report)
        error('T629report no contiene gasLP, hybrid y solar.');
    end

    if isempty(gas626) || isempty(hyb626) || isempty(sol626)
        disp(T626main)
        error('T626main no contiene gasLP, hybrid y solar.');
    end

    if isempty(gas628) || isempty(hyb628) || isempty(sol628)
        disp(T628direct)
        error('T628direct no contiene gasLP, hybrid y solar.');
    end

    % ---------------------------------------------------------------------
    % Métricas consolidadas
    % ---------------------------------------------------------------------
    metrics = struct();

    metrics.gasLP_MR = gas629.MR(1);
    metrics.hybrid_MR = hyb629.MR(1);
    metrics.solar_MR = sol629.MR(1);

    metrics.gasLP_cost = gas629.cost_USD_per_kgwater(1);
    metrics.hybrid_cost = hyb629.cost_USD_per_kgwater(1);
    metrics.solar_cost = sol629.cost_USD_per_kgwater(1);

    metrics.gasLP_Q_aux = gas629.Q_aux_tot(1);
    metrics.hybrid_Q_aux = hyb629.Q_aux_tot(1);
    metrics.solar_Q_aux = sol629.Q_aux_tot(1);

    metrics.gasLP_Irradiacion = gas629.Irradiacion(1);
    metrics.hybrid_Irradiacion = hyb629.Irradiacion(1);
    metrics.solar_Irradiacion = sol629.Irradiacion(1);

    metrics.gasLP_dry_time_h = gas629.dry_time_h(1);
    metrics.hybrid_dry_time_h = hyb629.dry_time_h(1);
    metrics.solar_dry_time_h = sol629.dry_time_h(1);

    metrics.gasLP_M_final = gas629.M_final(1);
    metrics.hybrid_M_final = hyb629.M_final(1);
    metrics.solar_M_final = sol629.M_final(1);

    metrics.delta_MR_hybrid_minus_gasLP = metrics.hybrid_MR - metrics.gasLP_MR;
    metrics.delta_dry_time_hybrid_minus_gasLP = metrics.hybrid_dry_time_h - metrics.gasLP_dry_time_h;
    metrics.delta_M_final_hybrid_minus_gasLP = metrics.hybrid_M_final - metrics.gasLP_M_final;

    metrics.reduction_Q_aux_hybrid_vs_gasLP_abs = metrics.gasLP_Q_aux - metrics.hybrid_Q_aux;
    metrics.reduction_Q_aux_hybrid_vs_gasLP_pct = ...
        100 * metrics.reduction_Q_aux_hybrid_vs_gasLP_abs / metrics.gasLP_Q_aux;

    metrics.reduction_cost_hybrid_vs_gasLP_abs = metrics.gasLP_cost - metrics.hybrid_cost;
    metrics.reduction_cost_hybrid_vs_gasLP_pct = ...
        100 * metrics.reduction_cost_hybrid_vs_gasLP_abs / metrics.gasLP_cost;

    metrics.solar_first_violation_i = sol626.first_violation_i(1);
    metrics.solar_first_violation_variable = string(sol626.first_violation_variable(1));
    metrics.solar_first_violation_rule = string(sol626.first_violation_rule(1));
    metrics.solar_first_violation_value = sol626.first_violation_value_real(1);
    metrics.solar_break_i_626 = sol626.break_i(1);

    metrics.solar_penalty_guard_i = sol628.guard_i(1);
    metrics.solar_penalty_guard_variable = string(sol628.guard_variable(1));
    metrics.solar_penalty_guard_rule = string(sol628.guard_rule(1));
    metrics.solar_penalty_guard_value = sol628.guard_value_real(1);

    % ---------------------------------------------------------------------
    % Flags consolidados
    % ---------------------------------------------------------------------
    flags = struct();

    flags.gasLP_valid_final = strcmp(string(gas629.validity(1)),"VALID");
    flags.hybrid_valid_final = strcmp(string(hyb629.validity(1)),"VALID");
    flags.solar_invalid_final = strcmp(string(sol629.validity(1)),"INVALID");

    flags.gasLP_no_physical_violation_626 = gas626.num_violations(1) == 0;
    flags.hybrid_no_physical_violation_626 = hyb626.num_violations(1) == 0;
    flags.solar_physical_violation_626 = sol626.num_violations(1) > 0;

    flags.solar_violation_before_break_626 = sol626.first_violation_i(1) < sol626.break_i(1);

    flags.gasLP_not_penalized_628b = strcmp(string(gas628.irr_status(1)),"OK");
    flags.hybrid_not_penalized_628b = strcmp(string(hyb628.irr_status(1)),"OK");
    flags.solar_penalized_628b = strcmp(string(sol628.irr_status(1)),"NONPHYSICAL_TRAJECTORY");

    flags.hybrid_gasLP_comparison_allowed = ...
        flags.gasLP_valid_final && flags.hybrid_valid_final && ...
        flags.gasLP_no_physical_violation_626 && flags.hybrid_no_physical_violation_626;

    flags.solar_performance_claims_allowed = false;

    flags.hybrid_same_drying_time_as_gasLP = abs(metrics.delta_dry_time_hybrid_minus_gasLP) < 1e-9;
    flags.hybrid_equivalent_MR_to_gasLP = abs(metrics.delta_MR_hybrid_minus_gasLP) < 1e-3;
    flags.hybrid_less_aux_than_gasLP = metrics.hybrid_Q_aux < metrics.gasLP_Q_aux;
    flags.hybrid_cheaper_than_gasLP = metrics.hybrid_cost < metrics.gasLP_cost;

    flags.do_not_rerun_GA_now = true;
    flags.do_not_modify_v10 = true;
    flags.do_not_modify_v611 = true;
    flags.do_not_overwrite_productive_run = true;

    if flags.hybrid_gasLP_comparison_allowed && flags.solar_invalid_final && flags.solar_penalized_628b
        diagnosis = "GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_PASS";
    else
        diagnosis = "GUARDED_POSTRUN_EVIDENCE_REQUIRES_REVIEW";
    end

    % ---------------------------------------------------------------------
    % Tabla resumen
    % ---------------------------------------------------------------------
    summaryRows = {};

    row = struct();
    row.item = "selected_solution";
    row.value = sprintf('m_max=%.12g; T_min=%.12g; r_div2=%.12g; t_rec_ini=%.12g', ...
        x.m_max, x.T_min, x.r_div2, x.t_rec_ini);
    row.interpretation = "Decision vector selected from productive GA run.";
    summaryRows{end+1,1} = row;

    row = struct();
    row.item = "final_valid_modes";
    row.value = "gasLP=VALID; hybrid=VALID; solar=INVALID";
    row.interpretation = "Only gasLP and hybrid are valid for defended mode comparison.";
    summaryRows{end+1,1} = row;

    row = struct();
    row.item = "solar_exclusion";
    row.value = sprintf('first violation: %s/%s at i=%.0f, value=%.12g', ...
        metrics.solar_first_violation_variable, ...
        metrics.solar_first_violation_rule, ...
        metrics.solar_first_violation_i, ...
        metrics.solar_first_violation_value);
    row.interpretation = "Pure solar branch entered nonphysical domain before termination and must not support performance claims.";
    summaryRows{end+1,1} = row;

    row = struct();
    row.item = "hybrid_vs_gasLP_drying";
    row.value = sprintf('dry_time gasLP=%.12g h; hybrid=%.12g h; delta=%.12g h; deltaMR=%.12g', ...
        metrics.gasLP_dry_time_h, ...
        metrics.hybrid_dry_time_h, ...
        metrics.delta_dry_time_hybrid_minus_gasLP, ...
        metrics.delta_MR_hybrid_minus_gasLP);
    row.interpretation = "Hybrid does not materially reduce drying time; it maintains equivalent drying state.";
    summaryRows{end+1,1} = row;

    row = struct();
    row.item = "hybrid_auxiliary_reduction";
    row.value = sprintf('Q_aux gasLP=%.12g; hybrid=%.12g; reduction=%.12g; reduction_pct=%.6g%%', ...
        metrics.gasLP_Q_aux, ...
        metrics.hybrid_Q_aux, ...
        metrics.reduction_Q_aux_hybrid_vs_gasLP_abs, ...
        metrics.reduction_Q_aux_hybrid_vs_gasLP_pct);
    row.interpretation = "The main hybrid benefit is reduction of auxiliary LPG energy demand.";
    summaryRows{end+1,1} = row;

    row = struct();
    row.item = "hybrid_cost_reduction";
    row.value = sprintf('cost gasLP=%.12g; hybrid=%.12g; reduction=%.12g; reduction_pct=%.6g%%', ...
        metrics.gasLP_cost, ...
        metrics.hybrid_cost, ...
        metrics.reduction_cost_hybrid_vs_gasLP_abs, ...
        metrics.reduction_cost_hybrid_vs_gasLP_pct);
    row.interpretation = "The hybrid mode reduces specific cost while preserving comparable drying performance.";
    summaryRows{end+1,1} = row;

    row = struct();
    row.item = "protected_files";
    row.value = "v10 wrapper, v611 objective, productive v614 run";
    row.interpretation = "Original productive artifacts remain untouched; guarded variants are postrun/control artifacts.";
    summaryRows{end+1,1} = row;

    Tsummary = struct2table(vertcat(summaryRows{:}));

    % ---------------------------------------------------------------------
    % Tabla de archivos
    % ---------------------------------------------------------------------
    files = struct();
    files.mat626 = mat626;
    files.mat628b = mat628b;
    files.mat629 = mat629;

    fileKeys = fieldnames(files);
    fileRows = {};
    for i = 1:numel(fileKeys)
        frow = struct();
        frow.key = string(fileKeys{i});
        frow.path = string(files.(fileKeys{i}));
        frow.exists = isfile(files.(fileKeys{i}));
        fileRows{end+1,1} = frow; %#ok<AGROW>
    end
    Tfiles = struct2table(vertcat(fileRows{:}));

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outCsvSummary = fullfile(tablesDir,'GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630c_summary.csv');
    outCsvFiles   = fullfile(tablesDir,'GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630c_files.csv');
    outMat        = fullfile(matDir,'GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630c.mat');
    outMd         = fullfile(logsDir,'GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630c.md');
    outTxt        = fullfile(logsDir,'GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630c.txt');

    writetable(Tsummary,outCsvSummary);
    writetable(Tfiles,outCsvFiles);

    save(outMat, ...
        'diagnosis','flags','metrics','x','runDir','files','Tfiles','Tsummary', ...
        'T626main','T626viol','T628direct','T628obj','T629full','T629report');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# Micropaso 6.30c — CONSOLIDATE-GUARDED-POSTRUN-EVIDENCE-001\n\n');
    fprintf(fid,'## Estatus\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);

    fprintf(fid,'## Corrida consolidada\n\n');
    fprintf(fid,'`%s`\n\n', runDir);

    fprintf(fid,'## Solución seleccionada\n\n');
    fprintf(fid,'- `m_max = %.12g`\n', x.m_max);
    fprintf(fid,'- `T_min = %.12g`\n', x.T_min);
    fprintf(fid,'- `r_div2 = %.12g`\n', x.r_div2);
    fprintf(fid,'- `t_rec_ini = %.12g`\n\n', x.t_rec_ini);

    fprintf(fid,'## Dictamen técnico final\n\n');
    fprintf(fid,'La evidencia postrun con guardas físicas permite conservar como defendible la comparación entre los modos `gasLP` e `hybrid`. Ambos modos permanecen como trayectorias válidas, sin violaciones de dominio físico detectadas en la auditoría 6.26 y sin penalización en la implementación 6.28b.\n\n');

    fprintf(fid,'El modo `solar` puro queda excluido de afirmaciones de desempeño. La rama solar presentó una violación de dominio físico antes de su terminación: `%s` bajo la regla `%s` en el índice %.0f, con valor %.12g. Posteriormente, la política de guardas implementada en 6.28b clasificó la trayectoria solar como `NONPHYSICAL_TRAJECTORY`.\n\n', ...
        metrics.solar_first_violation_variable, ...
        metrics.solar_first_violation_rule, ...
        metrics.solar_first_violation_i, ...
        metrics.solar_first_violation_value);

    fprintf(fid,'## Comparación defendible gasLP vs híbrido\n\n');
    fprintf(fid,'| Modo | Validez | MR | Costo específico [USD/kgwater] | Q_aux_tot | Irradiación | Tiempo [h] | M final |\n');
    fprintf(fid,'|---|---:|---:|---:|---:|---:|---:|---:|\n');

    for r = 1:height(T629report)
        fprintf(fid,'| %s | %s | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g |\n', ...
            string(T629report.mode(r)), ...
            string(T629report.validity(r)), ...
            T629report.MR(r), ...
            T629report.cost_USD_per_kgwater(r), ...
            T629report.Q_aux_tot(r), ...
            T629report.Irradiacion(r), ...
            T629report.dry_time_h(r), ...
            T629report.M_final(r));
    end

    fprintf(fid,'\n## Interpretación física correcta\n\n');
    fprintf(fid,'El modo híbrido no debe interpretarse como una mejora sustantiva del tiempo de secado respecto al modo gasLP. En la solución seleccionada ambos modos mantienen tiempos de operación equivalentes: `gasLP = %.12g h` e `hybrid = %.12g h`. También alcanzan un estado final prácticamente equivalente, con una diferencia de MR de `%.12g`.\n\n', ...
        metrics.gasLP_dry_time_h, ...
        metrics.hybrid_dry_time_h, ...
        metrics.delta_MR_hybrid_minus_gasLP);

    fprintf(fid,'La ventaja del modo híbrido se expresa principalmente en la reducción del consumo auxiliar de combustible y del costo específico. El aporte solar permite mantener condiciones térmicas equivalentes con menor demanda de energía auxiliar.\n\n');

    fprintf(fid,'## Beneficio energético y económico del modo híbrido\n\n');
    fprintf(fid,'- Reducción absoluta de energía auxiliar: `%.12g`\n', metrics.reduction_Q_aux_hybrid_vs_gasLP_abs);
    fprintf(fid,'- Reducción relativa de energía auxiliar: `%.6g %%`\n', metrics.reduction_Q_aux_hybrid_vs_gasLP_pct);
    fprintf(fid,'- Reducción absoluta de costo específico: `%.12g USD/kgwater`\n', metrics.reduction_cost_hybrid_vs_gasLP_abs);
    fprintf(fid,'- Reducción relativa de costo específico: `%.6g %%`\n\n', metrics.reduction_cost_hybrid_vs_gasLP_pct);

    fprintf(fid,'## Criterio formal de exclusión solar\n\n');
    fprintf(fid,'El modo solar puro no debe usarse para comparar desempeño ni para sostener afirmaciones de superioridad energética o económica, porque su trayectoria entra en dominio no físico. La exclusión no invalida automáticamente la comparación `gasLP`/`hybrid`, ya que ambos modos resultaron válidos bajo las mismas guardas.\n\n');

    fprintf(fid,'## Política para tesis/artículo\n\n');
    fprintf(fid,'> Bajo la política de guardas físicas, los modos gasLP e híbrido permanecen como trayectorias válidas. El modo solar puro fue clasificado como trayectoria inválida debido a violaciones de dominio físico en la rama solar, por lo que no se utiliza para sostener afirmaciones de desempeño. La comparación defendible se restringe a gasLP e híbrido. En dicha comparación, el modo híbrido mantiene un tiempo de secado y un MR final equivalentes al modo gasLP, pero reduce el aporte auxiliar en aproximadamente %.2f %% y el costo específico en aproximadamente %.2f %%.\n\n', ...
        metrics.reduction_Q_aux_hybrid_vs_gasLP_pct, ...
        metrics.reduction_cost_hybrid_vs_gasLP_pct);

    fprintf(fid,'## Estado de archivos protegidos\n\n');
    fprintf(fid,'- `opt_tunel_mod2_v10_energy_mode_corrected.m`: no modificar.\n');
    fprintf(fid,'- `objective_productive_corrected_v611.m`: no modificar.\n');
    fprintf(fid,'- Corrida productiva `v614`: no sobrescribir.\n');
    fprintf(fid,'- Variantes `v628b` y `v629`: usar solo como artefactos controlados de postrun/evaluación.\n\n');

    fprintf(fid,'## Siguiente paso recomendado\n\n');
    fprintf(fid,'`Micropaso 6.31 — WRITE-THESIS-ARTICLE-INTERPRETATION-001`\n\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % TXT ejecutivo
    % ---------------------------------------------------------------------
    fid = fopen(outTxt,'w');
    fprintf(fid,'CONSOLIDATE-GUARDED-POSTRUN-EVIDENCE-001\n');
    fprintf(fid,'status: GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'runDir: %s\n', runDir);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'gasLP_valid_final: %d\n', flags.gasLP_valid_final);
    fprintf(fid,'hybrid_valid_final: %d\n', flags.hybrid_valid_final);
    fprintf(fid,'solar_invalid_final: %d\n', flags.solar_invalid_final);
    fprintf(fid,'hybrid_gasLP_comparison_allowed: %d\n', flags.hybrid_gasLP_comparison_allowed);
    fprintf(fid,'solar_performance_claims_allowed: %d\n\n', flags.solar_performance_claims_allowed);

    fprintf(fid,'m_max: %.12g\n', x.m_max);
    fprintf(fid,'T_min: %.12g\n', x.T_min);
    fprintf(fid,'r_div2: %.12g\n', x.r_div2);
    fprintf(fid,'t_rec_ini: %.12g\n\n', x.t_rec_ini);

    fprintf(fid,'gasLP_MR: %.12g\n', metrics.gasLP_MR);
    fprintf(fid,'hybrid_MR: %.12g\n', metrics.hybrid_MR);
    fprintf(fid,'delta_MR_hybrid_minus_gasLP: %.12g\n', metrics.delta_MR_hybrid_minus_gasLP);
    fprintf(fid,'gasLP_dry_time_h: %.12g\n', metrics.gasLP_dry_time_h);
    fprintf(fid,'hybrid_dry_time_h: %.12g\n', metrics.hybrid_dry_time_h);
    fprintf(fid,'delta_dry_time_hybrid_minus_gasLP: %.12g\n', metrics.delta_dry_time_hybrid_minus_gasLP);
    fprintf(fid,'gasLP_Q_aux: %.12g\n', metrics.gasLP_Q_aux);
    fprintf(fid,'hybrid_Q_aux: %.12g\n', metrics.hybrid_Q_aux);
    fprintf(fid,'reduction_Q_aux_hybrid_vs_gasLP_abs: %.12g\n', metrics.reduction_Q_aux_hybrid_vs_gasLP_abs);
    fprintf(fid,'reduction_Q_aux_hybrid_vs_gasLP_pct: %.12g\n', metrics.reduction_Q_aux_hybrid_vs_gasLP_pct);
    fprintf(fid,'gasLP_cost: %.12g\n', metrics.gasLP_cost);
    fprintf(fid,'hybrid_cost: %.12g\n', metrics.hybrid_cost);
    fprintf(fid,'reduction_cost_hybrid_vs_gasLP_abs: %.12g\n', metrics.reduction_cost_hybrid_vs_gasLP_abs);
    fprintf(fid,'reduction_cost_hybrid_vs_gasLP_pct: %.12g\n\n', metrics.reduction_cost_hybrid_vs_gasLP_pct);

    fprintf(fid,'solar_first_violation_i: %.0f\n', metrics.solar_first_violation_i);
    fprintf(fid,'solar_first_violation_variable: %s\n', metrics.solar_first_violation_variable);
    fprintf(fid,'solar_first_violation_rule: %s\n', metrics.solar_first_violation_rule);
    fprintf(fid,'solar_first_violation_value: %.12g\n', metrics.solar_first_violation_value);
    fprintf(fid,'solar_penalty_guard_i: %.0f\n', metrics.solar_penalty_guard_i);
    fprintf(fid,'solar_penalty_guard_variable: %s\n', metrics.solar_penalty_guard_variable);
    fprintf(fid,'solar_penalty_guard_rule: %s\n', metrics.solar_penalty_guard_rule);
    fprintf(fid,'solar_penalty_guard_value: %.12g\n\n', metrics.solar_penalty_guard_value);

    fprintf(fid,'outCsvSummary: %s\n', outCsvSummary);
    fprintf(fid,'outCsvFiles: %s\n', outCsvFiles);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fclose(fid);

    cons = struct();
    cons.status = 'GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_COMPLETED';
    cons.diagnosis = diagnosis;
    cons.flags = flags;
    cons.metrics = metrics;
    cons.x = x;
    cons.runDir = runDir;
    cons.Tsummary = Tsummary;
    cons.Tfiles = Tfiles;
    cons.T629report = T629report;
    cons.outCsvSummary = outCsvSummary;
    cons.outCsvFiles = outCsvFiles;
    cons.outMat = outMat;
    cons.outMd = outMd;
    cons.outTxt = outTxt;

    disp('=== GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630c ===')
    disp(cons.status)
    disp('=== DIAGNOSIS ===')
    disp(cons.diagnosis)
    disp('=== FLAGS ===')
    disp(cons.flags)
    disp('=== METRICS ===')
    disp(cons.metrics)
    disp('=== SUMMARY TABLE ===')
    disp(cons.Tsummary)
    disp('=== FILES TABLE ===')
    disp(cons.Tfiles)
    disp('=== OUTPUT FILES ===')
    disp(cons.outCsvSummary)
    disp(cons.outCsvFiles)
    disp(cons.outMd)
    disp(cons.outMat)
    disp(cons.outTxt)
end

function T = local_force_mode_string_v630c(T, tableName)
    if ~ismember('mode', T.Properties.VariableNames)
        disp("=== Variable names in " + string(tableName) + " ===")
        disp(T.Properties.VariableNames)
        error('La tabla %s no contiene columna mode.', tableName);
    end

    T.mode = string(T.mode);
    T.mode = erase(T.mode,'"');
    T.mode = strtrim(T.mode);
end