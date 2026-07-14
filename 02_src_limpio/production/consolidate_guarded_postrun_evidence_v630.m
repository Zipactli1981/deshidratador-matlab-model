function cons = consolidate_guarded_postrun_evidence_v630()
% CONSOLIDATE_GUARDED_POSTRUN_EVIDENCE_v630
% Micropaso 6.30 — CONSOLIDATE-GUARDED-POSTRUN-EVIDENCE-001
%
% Objetivo:
%   Consolidar evidencia técnica de los micropasos 6.17–6.29:
%       - Comparación original de modos.
%       - Detección de anomalía solar.
%       - Confirmación de estado no físico.
%       - Diseño de guardas.
%       - Implementación de penalización.
%       - Comparación final defendible con guardas.
%
% No modifica:
%   - opt_tunel_mod2_v10_energy_mode_corrected.m
%   - objective_productive_corrected_v611.m
%   - corrida productiva original
%
% Salidas:
%   logs/GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630.md
%   logs/GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630.txt
%   tables/GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630_summary.csv
%   tables/GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630_files.csv
%   mat/GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630.mat
%
% Uso:
%   cons = consolidate_guarded_postrun_evidence_v630();

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
    % Archivos esperados
    % ---------------------------------------------------------------------
    files = struct();

    files.selected_solution = fullfile(tablesDir,'SELECTED_SOLUTION_CORRECTED_v614b.csv');

    files.v625_main = fullfile(tablesDir,'SOLAR_HYBRID_DOMINANCE_TRACE_v625_main.csv');
    files.v625_vars = fullfile(tablesDir,'SOLAR_HYBRID_DOMINANCE_TRACE_v625_variables.csv');

    files.v626_main = fullfile(tablesDir,'SOLAR_NONPHYSICAL_STATE_GUARD_v626_main.csv');
    files.v626_viol = fullfile(tablesDir,'SOLAR_NONPHYSICAL_STATE_GUARD_v626_violations.csv');

    files.v627_rules = fullfile(tablesDir,'SOLAR_BRANCH_PHYSICAL_GUARD_DESIGN_v627_rules.csv');
    files.v627_md    = fullfile(logsDir,'SOLAR_BRANCH_PHYSICAL_GUARD_DESIGN_v627.md');

    files.v628b_direct = fullfile(tablesDir,'IMPLEMENT_NONPHYSICAL_PENALTY_WRAPPER_v628b_direct.csv');
    files.v628b_obj    = fullfile(tablesDir,'IMPLEMENT_NONPHYSICAL_PENALTY_WRAPPER_v628b_objective.csv');

    files.v629_full   = fullfile(tablesDir,'POSTRUN_MODE_COMPARISON_WITH_GUARDS_v629_full.csv');
    files.v629_report = fullfile(tablesDir,'POSTRUN_MODE_COMPARISON_WITH_GUARDS_v629_report.csv');
    files.v629_md     = fullfile(logsDir,'POSTRUN_MODE_COMPARISON_WITH_GUARDS_v629.md');

    names = fieldnames(files);

    fileRows = {};
    for i = 1:numel(names)
        row = struct();
        row.key = string(names{i});
        row.path = string(files.(names{i}));
        row.exists = isfile(files.(names{i}));
        fileRows{end+1,1} = row; %#ok<AGROW>
    end

    Tfiles = struct2table(vertcat(fileRows{:}));

    % Archivos mínimos indispensables para consolidar 6.30
    requiredKeys = ["selected_solution","v626_main","v626_viol","v627_rules","v628b_direct","v628b_obj","v629_full","v629_report"];
    missingRequired = strings(0,1);

    for i = 1:numel(requiredKeys)
        k = requiredKeys(i);
        idx = strcmp(Tfiles.key,k);
        if ~any(idx) || ~Tfiles.exists(idx)
            missingRequired(end+1,1) = k; %#ok<AGROW>
        end
    end

    if ~isempty(missingRequired)
        disp(Tfiles)
        error('Faltan archivos indispensables para consolidar v630: %s', strjoin(missingRequired,", "));
    end

    % ---------------------------------------------------------------------
    % Cargar tablas
    % ---------------------------------------------------------------------
    Tsel       = readtable(files.selected_solution);
    T626main   = readtable(files.v626_main);
    T626viol   = readtable(files.v626_viol);
    T627rules  = readtable(files.v627_rules);
    T628direct = readtable(files.v628b_direct);
    T628obj    = readtable(files.v628b_obj);
    T629full   = readtable(files.v629_full);
    T629report = readtable(files.v629_report);

    % Opcionales
    if isfile(files.v625_main)
        T625main = readtable(files.v625_main);
    else
        T625main = table();
    end

    if isfile(files.v625_vars)
        T625vars = readtable(files.v625_vars);
    else
        T625vars = table();
    end

    % ---------------------------------------------------------------------
    % Extraer solución seleccionada
    % ---------------------------------------------------------------------
    x = struct();
    x.m_max = Tsel.m_max(1);
    x.T_min = Tsel.T_min(1);
    x.r_div2 = Tsel.r_div2(1);
    x.t_rec_ini = Tsel.t_rec_ini(1);

    % ---------------------------------------------------------------------
    % Extraer filas finales
    % ---------------------------------------------------------------------
    gas629 = T629report(strcmp(string(T629report.mode),"gasLP"),:);
    hyb629 = T629report(strcmp(string(T629report.mode),"hybrid"),:);
    sol629 = T629report(strcmp(string(T629report.mode),"solar"),:);

    if isempty(gas629) || isempty(hyb629) || isempty(sol629)
        error('T629report no contiene gasLP, hybrid y solar.');
    end

    solar626 = T626main(strcmp(string(T626main.mode),"solar"),:);
    gas626   = T626main(strcmp(string(T626main.mode),"gasLP"),:);
    hyb626   = T626main(strcmp(string(T626main.mode),"hybrid"),:);

    solar628 = T628direct(strcmp(string(T628direct.mode),"solar"),:);
    gas628   = T628direct(strcmp(string(T628direct.mode),"gasLP"),:);
    hyb628   = T628direct(strcmp(string(T628direct.mode),"hybrid"),:);

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

    % Solar nonphysical evidence
    metrics.solar_first_violation_i = solar626.first_violation_i(1);
    metrics.solar_first_violation_variable = string(solar626.first_violation_variable(1));
    metrics.solar_first_violation_rule = string(solar626.first_violation_rule(1));
    metrics.solar_first_violation_value = solar626.first_violation_value_real(1);
    metrics.solar_break_i_626 = solar626.break_i(1);

    metrics.solar_penalty_guard_i = solar628.guard_i(1);
    metrics.solar_penalty_guard_variable = string(solar628.guard_variable(1));
    metrics.solar_penalty_guard_rule = string(solar628.guard_rule(1));
    metrics.solar_penalty_guard_value = solar628.guard_value_real(1);

    % ---------------------------------------------------------------------
    % Flags consolidados
    % ---------------------------------------------------------------------
    flags = struct();

    flags.gasLP_valid_final = strcmp(string(gas629.validity(1)),"VALID");
    flags.hybrid_valid_final = strcmp(string(hyb629.validity(1)),"VALID");
    flags.solar_invalid_final = strcmp(string(sol629.validity(1)),"INVALID");

    flags.gasLP_no_physical_violation_626 = gas626.num_violations(1) == 0;
    flags.hybrid_no_physical_violation_626 = hyb626.num_violations(1) == 0;
    flags.solar_physical_violation_626 = solar626.num_violations(1) > 0;

    flags.solar_violation_before_break_626 = solar626.first_violation_i(1) < solar626.break_i(1);

    flags.gasLP_not_penalized_628b = strcmp(string(gas628.irr_status(1)),"OK");
    flags.hybrid_not_penalized_628b = strcmp(string(hyb628.irr_status(1)),"OK");
    flags.solar_penalized_628b = strcmp(string(solar628.irr_status(1)),"NONPHYSICAL_TRAJECTORY");

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
    % Tabla resumen consolidada
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
        metrics.gasLP_dry_time_h, metrics.hybrid_dry_time_h, ...
        metrics.delta_dry_time_hybrid_minus_gasLP, ...
        metrics.delta_MR_hybrid_minus_gasLP);
    row.interpretation = "Hybrid does not materially reduce drying time; it maintains equivalent drying state.";
    summaryRows{end+1,1} = row;

    row = struct();
    row.item = "hybrid_auxiliary_reduction";
    row.value = sprintf('Q_aux gasLP=%.12g; hybrid=%.12g; reduction=%.12g; reduction_pct=%.6g%%', ...
        metrics.gasLP_Q_aux, metrics.hybrid_Q_aux, ...
        metrics.reduction_Q_aux_hybrid_vs_gasLP_abs, ...
        metrics.reduction_Q_aux_hybrid_vs_gasLP_pct);
    row.interpretation = "The main hybrid benefit is reduction of auxiliary LPG energy demand.";
    summaryRows{end+1,1} = row;

    row = struct();
    row.item = "hybrid_cost_reduction";
    row.value = sprintf('cost gasLP=%.12g; hybrid=%.12g; reduction=%.12g; reduction_pct=%.6g%%', ...
        metrics.gasLP_cost, metrics.hybrid_cost, ...
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
    % Salidas
    % ---------------------------------------------------------------------
    outCsvSummary = fullfile(tablesDir,'GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630_summary.csv');
    outCsvFiles   = fullfile(tablesDir,'GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630_files.csv');
    outMat        = fullfile(matDir,'GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630.mat');
    outMd         = fullfile(logsDir,'GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630.md');
    outTxt        = fullfile(logsDir,'GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630.txt');

    writetable(Tsummary,outCsvSummary);
    writetable(Tfiles,outCsvFiles);

    save(outMat, ...
        'diagnosis','flags','metrics','x','runDir','files','Tfiles','Tsummary', ...
        'Tsel','T625main','T625vars','T626main','T626viol','T627rules', ...
        'T628direct','T628obj','T629full','T629report');

    % ---------------------------------------------------------------------
    % Markdown consolidado
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# Micropaso 6.30 — CONSOLIDATE-GUARDED-POSTRUN-EVIDENCE-001\n\n');

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
            T629report.mode(r), ...
            T629report.validity(r), ...
            T629report.MR(r), ...
            T629report.cost_USD_per_kgwater(r), ...
            T629report.Q_aux_tot(r), ...
            T629report.Irradiacion(r), ...
            T629report.dry_time_h(r), ...
            T629report.M_final(r));
    end

    fprintf(fid,'\n');

    fprintf(fid,'## Interpretación física correcta\n\n');
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
    fprintf(fid,'Texto técnico recomendado:\n\n');
    fprintf(fid,'> Bajo la política de guardas físicas, los modos gasLP e híbrido permanecen como trayectorias válidas. El modo solar puro fue clasificado como trayectoria inválida debido a violaciones de dominio físico en la rama solar, por lo que no se utiliza para sostener afirmaciones de desempeño. La comparación defendible se restringe a gasLP e híbrido. En dicha comparación, el modo híbrido mantiene un tiempo de secado y un MR final equivalentes al modo gasLP, pero reduce el aporte auxiliar en aproximadamente %.2f %% y el costo específico en aproximadamente %.2f %%.\n\n', ...
        metrics.reduction_Q_aux_hybrid_vs_gasLP_pct, ...
        metrics.reduction_cost_hybrid_vs_gasLP_pct);

    fprintf(fid,'## Estado de archivos protegidos\n\n');
    fprintf(fid,'- `opt_tunel_mod2_v10_energy_mode_corrected.m`: no modificar.\n');
    fprintf(fid,'- `objective_productive_corrected_v611.m`: no modificar.\n');
    fprintf(fid,'- Corrida productiva `v614`: no sobrescribir.\n');
    fprintf(fid,'- Variantes `v628b` y `v629`: usar solo como artefactos controlados de postrun/evaluación.\n\n');

    fprintf(fid,'## Archivos consolidados\n\n');
    for r = 1:height(Tfiles)
        fprintf(fid,'- `%s`: `%s` — exists = `%d`\n', Tfiles.key(r), Tfiles.path(r), Tfiles.exists(r));
    end

    fprintf(fid,'\n## Siguiente paso recomendado\n\n');
    fprintf(fid,'`Micropaso 6.31 — WRITE-THESIS-ARTICLE-INTERPRETATION-001`\n\n');
    fprintf(fid,'Propósito: redactar la interpretación formal para tesis/artículo sin alterar el código.\n');

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

    fprintf(fid,'--- FINAL VALIDITY ---\n');
    fprintf(fid,'gasLP_valid_final: %d\n', flags.gasLP_valid_final);
    fprintf(fid,'hybrid_valid_final: %d\n', flags.hybrid_valid_final);
    fprintf(fid,'solar_invalid_final: %d\n', flags.solar_invalid_final);
    fprintf(fid,'hybrid_gasLP_comparison_allowed: %d\n', flags.hybrid_gasLP_comparison_allowed);
    fprintf(fid,'solar_performance_claims_allowed: %d\n\n', flags.solar_performance_claims_allowed);

    fprintf(fid,'--- SELECTED SOLUTION ---\n');
    fprintf(fid,'m_max: %.12g\n', x.m_max);
    fprintf(fid,'T_min: %.12g\n', x.T_min);
    fprintf(fid,'r_div2: %.12g\n', x.r_div2);
    fprintf(fid,'t_rec_ini: %.12g\n\n', x.t_rec_ini);

    fprintf(fid,'--- DEFENSIBLE COMPARISON ---\n');
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

    fprintf(fid,'--- SOLAR EXCLUSION ---\n');
    fprintf(fid,'solar_first_violation_i: %.0f\n', metrics.solar_first_violation_i);
    fprintf(fid,'solar_first_violation_variable: %s\n', metrics.solar_first_violation_variable);
    fprintf(fid,'solar_first_violation_rule: %s\n', metrics.solar_first_violation_rule);
    fprintf(fid,'solar_first_violation_value: %.12g\n', metrics.solar_first_violation_value);
    fprintf(fid,'solar_penalty_guard_i: %.0f\n', metrics.solar_penalty_guard_i);
    fprintf(fid,'solar_penalty_guard_variable: %s\n', metrics.solar_penalty_guard_variable);
    fprintf(fid,'solar_penalty_guard_rule: %s\n', metrics.solar_penalty_guard_rule);
    fprintf(fid,'solar_penalty_guard_value: %.12g\n\n', metrics.solar_penalty_guard_value);

    fprintf(fid,'--- OUTPUTS ---\n');
    fprintf(fid,'outCsvSummary: %s\n', outCsvSummary);
    fprintf(fid,'outCsvFiles: %s\n', outCsvFiles);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    cons = struct();
    cons.status = 'GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_COMPLETED';
    cons.diagnosis = diagnosis;
    cons.flags = flags;
    cons.metrics = metrics;
    cons.x = x;
    cons.runDir = runDir;
    cons.files = files;
    cons.Tfiles = Tfiles;
    cons.Tsummary = Tsummary;
    cons.T629report = T629report;
    cons.outCsvSummary = outCsvSummary;
    cons.outCsvFiles = outCsvFiles;
    cons.outMat = outMat;
    cons.outMd = outMd;
    cons.outTxt = outTxt;

    disp('=== GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630 ===')
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