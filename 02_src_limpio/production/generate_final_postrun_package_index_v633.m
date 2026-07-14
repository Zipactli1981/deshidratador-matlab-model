function index = generate_final_postrun_package_index_v633()
% GENERATE_FINAL_POSTRUN_PACKAGE_INDEX_v633
% Micropaso 6.33 — FINAL-POSTRUN-PACKAGE-INDEX-001
%
% Objetivo:
%   Generar un índice maestro de cierre del bloque postrun.
%
% Integra:
%   - corrida productiva v614
%   - solución seleccionada
%   - evidencia de exclusión solar
%   - guardas físicas
%   - comparación final gasLP/hybrid
%   - interpretación tesis/artículo
%   - KNOW técnico consolidado
%
% No modifica:
%   - wrapper v10
%   - objective v611
%   - corrida productiva v614
%
% Uso:
%   index = generate_final_postrun_package_index_v633();

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
    % Archivos clave esperados
    % ---------------------------------------------------------------------
    files = struct();

    % Corrida productiva / selección
    files.selected_solution_csv = fullfile(tablesDir,'SELECTED_SOLUTION_CORRECTED_v614b.csv');
    files.runinfo_mat = fullfile(matDir,'PRODUCTIVE_GA_CORRECTED_v614b_runinfo.mat');

    % Diagnósticos previos relevantes
    files.v625_main_csv = fullfile(tablesDir,'SOLAR_HYBRID_DOMINANCE_TRACE_v625_main.csv');
    files.v625_vars_csv = fullfile(tablesDir,'SOLAR_HYBRID_DOMINANCE_TRACE_v625_variables.csv');
    files.v626_mat = fullfile(matDir,'SOLAR_NONPHYSICAL_STATE_GUARD_v626.mat');
    files.v626_main_csv = fullfile(tablesDir,'SOLAR_NONPHYSICAL_STATE_GUARD_v626_main.csv');
    files.v626_violations_csv = fullfile(tablesDir,'SOLAR_NONPHYSICAL_STATE_GUARD_v626_violations.csv');

    % Diseño e implementación de guardas
    files.v627_mat = fullfile(matDir,'SOLAR_BRANCH_PHYSICAL_GUARD_DESIGN_v627.mat');
    files.v627_rules_csv = fullfile(tablesDir,'SOLAR_BRANCH_PHYSICAL_GUARD_DESIGN_v627_rules.csv');
    files.v627_md = fullfile(logsDir,'SOLAR_BRANCH_PHYSICAL_GUARD_DESIGN_v627.md');

    files.v628b_mat = fullfile(matDir,'IMPLEMENT_NONPHYSICAL_PENALTY_WRAPPER_v628b.mat');
    files.v628b_direct_csv = fullfile(tablesDir,'IMPLEMENT_NONPHYSICAL_PENALTY_WRAPPER_v628b_direct.csv');
    files.v628b_objective_csv = fullfile(tablesDir,'IMPLEMENT_NONPHYSICAL_PENALTY_WRAPPER_v628b_objective.csv');

    % Comparación final con guardas
    files.v629_mat = fullfile(matDir,'POSTRUN_MODE_COMPARISON_WITH_GUARDS_v629.mat');
    files.v629_full_csv = fullfile(tablesDir,'POSTRUN_MODE_COMPARISON_WITH_GUARDS_v629_full.csv');
    files.v629_report_csv = fullfile(tablesDir,'POSTRUN_MODE_COMPARISON_WITH_GUARDS_v629_report.csv');
    files.v629_md = fullfile(logsDir,'POSTRUN_MODE_COMPARISON_WITH_GUARDS_v629.md');

    % Consolidado e interpretación
    files.v630c_mat = fullfile(matDir,'GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630c.mat');
    files.v630c_summary_csv = fullfile(tablesDir,'GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630c_summary.csv');
    files.v630c_md = fullfile(logsDir,'GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630c.md');

    files.v631_mat = fullfile(matDir,'THESIS_ARTICLE_INTERPRETATION_v631.mat');
    files.v631_md = fullfile(logsDir,'THESIS_ARTICLE_INTERPRETATION_v631.md');
    files.v631_txt = fullfile(logsDir,'THESIS_ARTICLE_INTERPRETATION_v631.txt');

    files.v632_mat = fullfile(matDir,'KNOW_06_32_guarded_mode_comparison.mat');
    files.v632_know_md = fullfile(logsDir,'KNOW_06_32_guarded_mode_comparison.md');
    files.v632_summary_txt = fullfile(logsDir,'KNOW_06_32_guarded_mode_comparison_summary.txt');

    % Código protegido / derivados
    files.wrapper_v10 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v10_energy_mode_corrected.m');
    files.objective_v611 = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v611.m');
    files.guard_v628b = fullfile(rootDir,'02_src_limpio','wrappers','nonphysical_guard_eval_v628b.m');
    files.wrapper_v17_guarded = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v17_nonphysical_penalty.m');
    files.objective_v628b_guarded = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v628b_nonphysical_penalty.m');

    % ---------------------------------------------------------------------
    % Tabla de archivos
    % ---------------------------------------------------------------------
    keys = fieldnames(files);
    rows = {};

    for i = 1:numel(keys)
        row = struct();
        row.key = string(keys{i});
        row.path = string(files.(keys{i}));
        row.exists = isfile(files.(keys{i}));

        if row.exists
            info = dir(files.(keys{i}));
            row.bytes = info.bytes;
            row.modified = string(info.date);
        else
            row.bytes = NaN;
            row.modified = "";
        end

        rows{end+1,1} = row; %#ok<AGROW>
    end

    Tfiles = struct2table(vertcat(rows{:}));

    % ---------------------------------------------------------------------
    % Cargar consolidado v630c
    % ---------------------------------------------------------------------
    mat630c = files.v630c_mat;

    if ~isfile(mat630c)
        error('No existe consolidado v630c: %s', mat630c);
    end

    S630 = load(mat630c);

    required630 = {'diagnosis','flags','metrics','x','Tsummary','T629report'};
    for i = 1:numel(required630)
        if ~isfield(S630, required630{i})
            error('El MAT v630c no contiene la variable requerida: %s', required630{i});
        end
    end

    diagnosis = string(S630.diagnosis);
    flags = S630.flags;
    metrics = S630.metrics;
    x = S630.x;
    Tsummary = S630.Tsummary;
    T629report = S630.T629report;

    % ---------------------------------------------------------------------
    % Validaciones de cierre
    % ---------------------------------------------------------------------
    requiredForClose = [
        "selected_solution_csv"
        "v626_mat"
        "v627_rules_csv"
        "v628b_mat"
        "v629_mat"
        "v630c_mat"
        "v631_mat"
        "v632_know_md"
        "wrapper_v10"
        "objective_v611"
        "guard_v628b"
        "wrapper_v17_guarded"
        "objective_v628b_guarded"
    ];

    missingForClose = strings(0,1);

    for i = 1:numel(requiredForClose)
        k = requiredForClose(i);
        idx = strcmp(Tfiles.key,k);
        if ~any(idx) || ~Tfiles.exists(idx)
            missingForClose(end+1,1) = k; %#ok<AGROW>
        end
    end

    closeFlags = struct();
    closeFlags.source_diagnosis_pass = strcmp(diagnosis,"GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_PASS");
    closeFlags.gasLP_valid = flags.gasLP_valid_final;
    closeFlags.hybrid_valid = flags.hybrid_valid_final;
    closeFlags.solar_invalid = flags.solar_invalid_final;
    closeFlags.hybrid_gasLP_comparison_allowed = flags.hybrid_gasLP_comparison_allowed;
    closeFlags.solar_performance_claims_allowed = flags.solar_performance_claims_allowed;
    closeFlags.hybrid_same_drying_time_as_gasLP = flags.hybrid_same_drying_time_as_gasLP;
    closeFlags.hybrid_less_aux_than_gasLP = flags.hybrid_less_aux_than_gasLP;
    closeFlags.hybrid_cheaper_than_gasLP = flags.hybrid_cheaper_than_gasLP;
    closeFlags.no_required_files_missing = isempty(missingForClose);
    closeFlags.do_not_rerun_GA_now = flags.do_not_rerun_GA_now;
    closeFlags.do_not_modify_v10 = flags.do_not_modify_v10;
    closeFlags.do_not_modify_v611 = flags.do_not_modify_v611;
    closeFlags.do_not_overwrite_productive_run = flags.do_not_overwrite_productive_run;

    if closeFlags.source_diagnosis_pass && ...
       closeFlags.gasLP_valid && ...
       closeFlags.hybrid_valid && ...
       closeFlags.solar_invalid && ...
       closeFlags.hybrid_gasLP_comparison_allowed && ...
       ~closeFlags.solar_performance_claims_allowed && ...
       closeFlags.no_required_files_missing

        finalDiagnosis = "FINAL_POSTRUN_PACKAGE_INDEX_PASS";
    else
        finalDiagnosis = "FINAL_POSTRUN_PACKAGE_INDEX_REQUIRES_REVIEW";
    end

    % ---------------------------------------------------------------------
    % Tabla ejecutiva
    % ---------------------------------------------------------------------
    execRows = {};

    row = struct();
    row.item = "final_diagnosis";
    row.value = finalDiagnosis;
    row.note = "Final package index status.";
    execRows{end+1,1} = row;

    row = struct();
    row.item = "source_diagnosis";
    row.value = diagnosis;
    row.note = "Diagnosis from v630c.";
    execRows{end+1,1} = row;

    row = struct();
    row.item = "valid_comparison";
    row.value = "gasLP vs hybrid";
    row.note = "Only defended comparison.";
    execRows{end+1,1} = row;

    row = struct();
    row.item = "invalid_mode";
    row.value = "solar";
    row.note = "Excluded due to nonphysical trajectory.";
    execRows{end+1,1} = row;

    row = struct();
    row.item = "selected_solution";
    row.value = sprintf('m_max=%.12g; T_min=%.12g; r_div2=%.12g; t_rec_ini=%.12g', ...
        x.m_max, x.T_min, x.r_div2, x.t_rec_ini);
    row.note = "Selected decision vector.";
    execRows{end+1,1} = row;

    row = struct();
    row.item = "hybrid_drying_equivalence";
    row.value = sprintf('dry_time gasLP=%.12g h; hybrid=%.12g h; delta_MR=%.12g', ...
        metrics.gasLP_dry_time_h, ...
        metrics.hybrid_dry_time_h, ...
        metrics.delta_MR_hybrid_minus_gasLP);
    row.note = "Hybrid does not materially reduce drying time.";
    execRows{end+1,1} = row;

    row = struct();
    row.item = "hybrid_auxiliary_benefit";
    row.value = sprintf('Q_aux reduction=%.12g; reduction_pct=%.6g%%', ...
        metrics.reduction_Q_aux_hybrid_vs_gasLP_abs, ...
        metrics.reduction_Q_aux_hybrid_vs_gasLP_pct);
    row.note = "Main energy benefit.";
    execRows{end+1,1} = row;

    row = struct();
    row.item = "hybrid_cost_benefit";
    row.value = sprintf('cost reduction=%.12g USD/kgwater; reduction_pct=%.6g%%', ...
        metrics.reduction_cost_hybrid_vs_gasLP_abs, ...
        metrics.reduction_cost_hybrid_vs_gasLP_pct);
    row.note = "Main economic benefit.";
    execRows{end+1,1} = row;

    row = struct();
    row.item = "solar_exclusion";
    row.value = sprintf('%s/%s at i=%.0f, value=%.12g', ...
        metrics.solar_first_violation_variable, ...
        metrics.solar_first_violation_rule, ...
        metrics.solar_first_violation_i, ...
        metrics.solar_first_violation_value);
    row.note = "First nonphysical violation.";
    execRows{end+1,1} = row;

    row = struct();
    row.item = "protected_files_policy";
    row.value = "do not modify v10; do not modify v611; do not overwrite v614";
    row.note = "Traceability control.";
    execRows{end+1,1} = row;

    Texec = struct2table(vertcat(execRows{:}));

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'FINAL_POSTRUN_PACKAGE_INDEX_v633.md');
    outTxt = fullfile(logsDir,'FINAL_POSTRUN_PACKAGE_INDEX_v633.txt');
    outMat = fullfile(matDir,'FINAL_POSTRUN_PACKAGE_INDEX_v633.mat');
    outCsvFiles = fullfile(tablesDir,'FINAL_POSTRUN_PACKAGE_INDEX_v633_files.csv');
    outCsvExec = fullfile(tablesDir,'FINAL_POSTRUN_PACKAGE_INDEX_v633_exec.csv');

    writetable(Tfiles,outCsvFiles);
    writetable(Texec,outCsvExec);

    save(outMat, ...
        'finalDiagnosis','closeFlags','missingForClose','runDir','files','Tfiles','Texec', ...
        'diagnosis','flags','metrics','x','Tsummary','T629report');

    % ---------------------------------------------------------------------
    % Markdown índice
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# FINAL_POSTRUN_PACKAGE_INDEX_v633\n\n');

    fprintf(fid,'## Estado de cierre\n\n');
    fprintf(fid,'Diagnóstico final: `%s`\n\n', finalDiagnosis);
    fprintf(fid,'Diagnóstico fuente v630c: `%s`\n\n', diagnosis);

    fprintf(fid,'## Corrida productiva indexada\n\n');
    fprintf(fid,'`%s`\n\n', runDir);

    fprintf(fid,'## Solución seleccionada\n\n');
    fprintf(fid,'| Variable | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| `m_max` | %.12g |\n', x.m_max);
    fprintf(fid,'| `T_min` | %.12g |\n', x.T_min);
    fprintf(fid,'| `r_div2` | %.12g |\n', x.r_div2);
    fprintf(fid,'| `t_rec_ini` | %.12g |\n\n', x.t_rec_ini);

    fprintf(fid,'## Resultado técnico consolidado\n\n');
    fprintf(fid,'La comparación postrun defendible queda restringida a los modos `gasLP` e `hybrid`. El modo `solar` puro queda excluido de afirmaciones de desempeño por trayectoria no física.\n\n');

    fprintf(fid,'El modo híbrido mantiene desempeño de secado equivalente al modo `gasLP`: ambos presentan tiempo de operación de %.12g h y una diferencia de MR `hybrid - gasLP` de %.12g. La ventaja del modo híbrido es energética y económica, no cinética.\n\n', ...
        metrics.hybrid_dry_time_h, ...
        metrics.delta_MR_hybrid_minus_gasLP);

    fprintf(fid,'## Métricas principales\n\n');
    fprintf(fid,'| Métrica | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| `MR gasLP` | %.12g |\n', metrics.gasLP_MR);
    fprintf(fid,'| `MR hybrid` | %.12g |\n', metrics.hybrid_MR);
    fprintf(fid,'| `delta MR hybrid-gasLP` | %.12g |\n', metrics.delta_MR_hybrid_minus_gasLP);
    fprintf(fid,'| `dry time gasLP [h]` | %.12g |\n', metrics.gasLP_dry_time_h);
    fprintf(fid,'| `dry time hybrid [h]` | %.12g |\n', metrics.hybrid_dry_time_h);
    fprintf(fid,'| `Q_aux gasLP` | %.12g |\n', metrics.gasLP_Q_aux);
    fprintf(fid,'| `Q_aux hybrid` | %.12g |\n', metrics.hybrid_Q_aux);
    fprintf(fid,'| `Q_aux reduction` | %.12g |\n', metrics.reduction_Q_aux_hybrid_vs_gasLP_abs);
    fprintf(fid,'| `Q_aux reduction pct` | %.6g %% |\n', metrics.reduction_Q_aux_hybrid_vs_gasLP_pct);
    fprintf(fid,'| `cost gasLP [USD/kgwater]` | %.12g |\n', metrics.gasLP_cost);
    fprintf(fid,'| `cost hybrid [USD/kgwater]` | %.12g |\n', metrics.hybrid_cost);
    fprintf(fid,'| `cost reduction [USD/kgwater]` | %.12g |\n', metrics.reduction_cost_hybrid_vs_gasLP_abs);
    fprintf(fid,'| `cost reduction pct` | %.6g %% |\n\n', metrics.reduction_cost_hybrid_vs_gasLP_pct);

    fprintf(fid,'## Exclusión solar\n\n');
    fprintf(fid,'El modo `solar` puro fue excluido por la siguiente primera violación física detectada:\n\n');
    fprintf(fid,'| Campo | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| Variable | `%s` |\n', metrics.solar_first_violation_variable);
    fprintf(fid,'| Regla | `%s` |\n', metrics.solar_first_violation_rule);
    fprintf(fid,'| Índice | %.0f |\n', metrics.solar_first_violation_i);
    fprintf(fid,'| Valor | %.12g |\n', metrics.solar_first_violation_value);
    fprintf(fid,'| Índice de terminación auditada | %.0f |\n\n', metrics.solar_break_i_626);

    fprintf(fid,'El valor `MR = 1000` y el costo `1e6` del modo solar son penalizaciones numéricas, no resultados físicos.\n\n');

    fprintf(fid,'## Tabla de resultados final\n\n');
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

    fprintf(fid,'\n');

    fprintf(fid,'## Artefactos principales\n\n');
    fprintf(fid,'| Clave | Existe | Ruta |\n');
    fprintf(fid,'|---|---:|---|\n');
    for r = 1:height(Tfiles)
        fprintf(fid,'| `%s` | %d | `%s` |\n', ...
            string(Tfiles.key(r)), ...
            Tfiles.exists(r), ...
            string(Tfiles.path(r)));
    end
    fprintf(fid,'\n');

    fprintf(fid,'## Archivos faltantes obligatorios\n\n');
    if isempty(missingForClose)
        fprintf(fid,'No se detectaron archivos obligatorios faltantes.\n\n');
    else
        for i = 1:numel(missingForClose)
            fprintf(fid,'- `%s`\n', missingForClose(i));
        end
        fprintf(fid,'\n');
    end

    fprintf(fid,'## Política de protección\n\n');
    fprintf(fid,'- No modificar `opt_tunel_mod2_v10_energy_mode_corrected.m`.\n');
    fprintf(fid,'- No modificar `objective_productive_corrected_v611.m`.\n');
    fprintf(fid,'- No sobrescribir la corrida productiva `v614`.\n');
    fprintf(fid,'- No repetir el AG en esta etapa.\n');
    fprintf(fid,'- Tratar `v628b`, `v629`, `v630c`, `v631`, `v632` y `v633` como artefactos postrun controlados.\n\n');

    fprintf(fid,'## Uso recomendado del paquete\n\n');
    fprintf(fid,'Este índice debe usarse como punto de entrada para redactar resultados, discusión, limitaciones y conclusiones de tesis o artículo. Las afirmaciones permitidas/prohibidas están documentadas en `KNOW_06_32_guarded_mode_comparison.md`.\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % TXT ejecutivo
    % ---------------------------------------------------------------------
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'FINAL-POSTRUN-PACKAGE-INDEX-001\n');
    fprintf(fid,'status: FINAL_POSTRUN_PACKAGE_INDEX_COMPLETED\n');
    fprintf(fid,'finalDiagnosis: %s\n', finalDiagnosis);
    fprintf(fid,'sourceDiagnosis: %s\n', diagnosis);
    fprintf(fid,'runDir: %s\n', runDir);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'VALID COMPARISON: gasLP vs hybrid\n');
    fprintf(fid,'INVALID MODE: solar\n\n');

    fprintf(fid,'SELECTED SOLUTION:\n');
    fprintf(fid,'m_max: %.12g\n', x.m_max);
    fprintf(fid,'T_min: %.12g\n', x.T_min);
    fprintf(fid,'r_div2: %.12g\n', x.r_div2);
    fprintf(fid,'t_rec_ini: %.12g\n\n', x.t_rec_ini);

    fprintf(fid,'KEY METRICS:\n');
    fprintf(fid,'gasLP_MR: %.12g\n', metrics.gasLP_MR);
    fprintf(fid,'hybrid_MR: %.12g\n', metrics.hybrid_MR);
    fprintf(fid,'delta_MR_hybrid_minus_gasLP: %.12g\n', metrics.delta_MR_hybrid_minus_gasLP);
    fprintf(fid,'gasLP_dry_time_h: %.12g\n', metrics.gasLP_dry_time_h);
    fprintf(fid,'hybrid_dry_time_h: %.12g\n', metrics.hybrid_dry_time_h);
    fprintf(fid,'Q_aux_reduction_abs: %.12g\n', metrics.reduction_Q_aux_hybrid_vs_gasLP_abs);
    fprintf(fid,'Q_aux_reduction_pct: %.12g %%\n', metrics.reduction_Q_aux_hybrid_vs_gasLP_pct);
    fprintf(fid,'cost_reduction_abs: %.12g USD/kgwater\n', metrics.reduction_cost_hybrid_vs_gasLP_abs);
    fprintf(fid,'cost_reduction_pct: %.12g %%\n\n', metrics.reduction_cost_hybrid_vs_gasLP_pct);

    fprintf(fid,'SOLAR EXCLUSION:\n');
    fprintf(fid,'variable: %s\n', metrics.solar_first_violation_variable);
    fprintf(fid,'rule: %s\n', metrics.solar_first_violation_rule);
    fprintf(fid,'index: %.0f\n', metrics.solar_first_violation_i);
    fprintf(fid,'value: %.12g\n\n', metrics.solar_first_violation_value);

    fprintf(fid,'MISSING REQUIRED FILES:\n');
    if isempty(missingForClose)
        fprintf(fid,'none\n\n');
    else
        for i = 1:numel(missingForClose)
            fprintf(fid,'%s\n', missingForClose(i));
        end
        fprintf(fid,'\n');
    end

    fprintf(fid,'OUTPUTS:\n');
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'outCsvFiles: %s\n', outCsvFiles);
    fprintf(fid,'outCsvExec: %s\n', outCsvExec);

    fclose(fid);

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    index = struct();
    index.status = 'FINAL_POSTRUN_PACKAGE_INDEX_COMPLETED';
    index.finalDiagnosis = finalDiagnosis;
    index.sourceDiagnosis = diagnosis;
    index.closeFlags = closeFlags;
    index.missingForClose = missingForClose;
    index.runDir = runDir;
    index.files = files;
    index.Tfiles = Tfiles;
    index.Texec = Texec;
    index.metrics = metrics;
    index.flags = flags;
    index.outMd = outMd;
    index.outTxt = outTxt;
    index.outMat = outMat;
    index.outCsvFiles = outCsvFiles;
    index.outCsvExec = outCsvExec;

    disp('=== FINAL_POSTRUN_PACKAGE_INDEX_v633 ===')
    disp(index.status)
    disp('=== FINAL DIAGNOSIS ===')
    disp(index.finalDiagnosis)
    disp('=== SOURCE DIAGNOSIS ===')
    disp(index.sourceDiagnosis)
    disp('=== CLOSE FLAGS ===')
    disp(index.closeFlags)
    disp('=== MISSING REQUIRED FILES ===')
    disp(index.missingForClose)
    disp('=== EXECUTIVE TABLE ===')
    disp(index.Texec)
    disp('=== OUTPUT FILES ===')
    disp(index.outMd)
    disp(index.outTxt)
    disp(index.outMat)
    disp(index.outCsvFiles)
    disp(index.outCsvExec)
end