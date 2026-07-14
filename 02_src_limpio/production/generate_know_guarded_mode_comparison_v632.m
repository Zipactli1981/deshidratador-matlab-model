function know = generate_know_guarded_mode_comparison_v632()
% GENERATE_KNOW_GUARDED_MODE_COMPARISON_v632
% Micropaso 6.32 — KNOW-GUARDED-MODE-COMPARISON-001
%
% Objetivo:
%   Generar un archivo Markdown de conocimiento técnico consolidado:
%       KNOW_06_32_guarded_mode_comparison.md
%
% Base:
%   mat/GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630c.mat
%   mat/THESIS_ARTICLE_INTERPRETATION_v631.mat
%
% No modifica:
%   - wrapper v10
%   - objective v611
%   - corrida productiva v614
%
% Uso:
%   know = generate_know_guarded_mode_comparison_v632();

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

    matDir  = fullfile(runDir,'mat');
    logsDir = fullfile(runDir,'logs');

    if ~isfolder(matDir), mkdir(matDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end

    mat630c = fullfile(matDir,'GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630c.mat');
    mat631  = fullfile(matDir,'THESIS_ARTICLE_INTERPRETATION_v631.mat');

    if ~isfile(mat630c)
        error('No existe consolidado v630c: %s', mat630c);
    end

    if ~isfile(mat631)
        error('No existe interpretación v631: %s', mat631);
    end

    S630 = load(mat630c);
    S631 = load(mat631);

    required630 = {'diagnosis','flags','metrics','x','T629report'};
    for i = 1:numel(required630)
        if ~isfield(S630, required630{i})
            error('El MAT v630c no contiene la variable requerida: %s', required630{i});
        end
    end

    required631 = {'paragraph_results','paragraph_hybrid','paragraph_energy','paragraph_solar','paragraph_limitations','paragraph_conclusion'};
    for i = 1:numel(required631)
        if ~isfield(S631, required631{i})
            error('El MAT v631 no contiene la variable requerida: %s', required631{i});
        end
    end

    metrics = S630.metrics;
    flags   = S630.flags;
    x       = S630.x;
    T629report = S630.T629report;

    if ~strcmp(string(S630.diagnosis),"GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_PASS")
        warning('El diagnóstico v630c no es PASS. Revisar antes de usar el KNOW.');
    end

    if ~flags.hybrid_gasLP_comparison_allowed
        warning('La comparación gasLP/hybrid no aparece como permitida.');
    end

    if flags.solar_performance_claims_allowed
        warning('solar_performance_claims_allowed aparece como true. Revisar.');
    end

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outKnow = fullfile(logsDir,'KNOW_06_32_guarded_mode_comparison.md');
    outTxt  = fullfile(logsDir,'KNOW_06_32_guarded_mode_comparison_summary.txt');
    outMat  = fullfile(matDir,'KNOW_06_32_guarded_mode_comparison.mat');

    % ---------------------------------------------------------------------
    % Markdown de conocimiento
    % ---------------------------------------------------------------------
    fid = fopen(outKnow,'w');
    if fid < 0
        error('No se pudo crear KNOW: %s', outKnow);
    end

    fprintf(fid,'# KNOW_06_32_guarded_mode_comparison\n\n');

    fprintf(fid,'## Propósito\n\n');
    fprintf(fid,'Este archivo fija el criterio técnico consolidado para interpretar la comparación postrun entre modos de operación en la solución seleccionada de la corrida productiva `v614`. Su función es preservar la trazabilidad de los resultados defendibles y evitar afirmaciones no sustentadas sobre el modo solar puro.\n\n');

    fprintf(fid,'## Corrida válida\n\n');
    fprintf(fid,'La corrida productiva válida es:\n\n');
    fprintf(fid,'`%s`\n\n', runDir);

    fprintf(fid,'El análisis postrun consolidado proviene de:\n\n');
    fprintf(fid,'- `GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630c.mat`\n');
    fprintf(fid,'- `THESIS_ARTICLE_INTERPRETATION_v631.mat`\n\n');

    fprintf(fid,'## Solución seleccionada\n\n');
    fprintf(fid,'La solución seleccionada queda definida por:\n\n');
    fprintf(fid,'| Variable | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| `m_max` | %.12g |\n', x.m_max);
    fprintf(fid,'| `T_min` | %.12g |\n', x.T_min);
    fprintf(fid,'| `r_div2` | %.12g |\n', x.r_div2);
    fprintf(fid,'| `t_rec_ini` | %.12g |\n\n', x.t_rec_ini);

    fprintf(fid,'## Estado de validez por modo\n\n');
    fprintf(fid,'Bajo la política de guardas físicas, el estado de validez es:\n\n');
    fprintf(fid,'| Modo | Estado | Uso permitido |\n');
    fprintf(fid,'|---|---|---|\n');
    fprintf(fid,'| `gasLP` | Válido | Comparación defendible |\n');
    fprintf(fid,'| `hybrid` | Válido | Comparación defendible |\n');
    fprintf(fid,'| `solar` | Inválido | No usar para afirmaciones de desempeño |\n\n');

    fprintf(fid,'La comparación técnicamente defendible queda restringida a `gasLP` contra `hybrid`.\n\n');

    fprintf(fid,'## Resultados reportables\n\n');
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

    fprintf(fid,'## Comparación gasLP vs híbrido\n\n');
    fprintf(fid,'La comparación válida indica que el modo híbrido mantiene un desempeño de secado equivalente al modo `gasLP`:\n\n');
    fprintf(fid,'- Tiempo de secado `gasLP`: %.12g h\n', metrics.gasLP_dry_time_h);
    fprintf(fid,'- Tiempo de secado `hybrid`: %.12g h\n', metrics.hybrid_dry_time_h);
    fprintf(fid,'- Diferencia de tiempo `hybrid - gasLP`: %.12g h\n', metrics.delta_dry_time_hybrid_minus_gasLP);
    fprintf(fid,'- MR `gasLP`: %.12g\n', metrics.gasLP_MR);
    fprintf(fid,'- MR `hybrid`: %.12g\n', metrics.hybrid_MR);
    fprintf(fid,'- Diferencia de MR `hybrid - gasLP`: %.12g\n\n', metrics.delta_MR_hybrid_minus_gasLP);

    fprintf(fid,'Por tanto, el modo híbrido no debe interpretarse como una estrategia que reduzca el tiempo de secado en esta solución. La interpretación correcta es que mantiene una condición térmica/de secado equivalente con menor demanda de energía auxiliar.\n\n');

    fprintf(fid,'## Beneficio energético y económico del híbrido\n\n');
    fprintf(fid,'El beneficio principal del modo híbrido está en la sustitución parcial de energía auxiliar por aporte solar:\n\n');
    fprintf(fid,'- `Q_aux_tot gasLP`: %.12g\n', metrics.gasLP_Q_aux);
    fprintf(fid,'- `Q_aux_tot hybrid`: %.12g\n', metrics.hybrid_Q_aux);
    fprintf(fid,'- Reducción absoluta de energía auxiliar: %.12g\n', metrics.reduction_Q_aux_hybrid_vs_gasLP_abs);
    fprintf(fid,'- Reducción relativa de energía auxiliar: %.6g %%\n\n', metrics.reduction_Q_aux_hybrid_vs_gasLP_pct);

    fprintf(fid,'El efecto económico asociado es:\n\n');
    fprintf(fid,'- Costo específico `gasLP`: %.12g USD/kgwater\n', metrics.gasLP_cost);
    fprintf(fid,'- Costo específico `hybrid`: %.12g USD/kgwater\n', metrics.hybrid_cost);
    fprintf(fid,'- Reducción absoluta de costo específico: %.12g USD/kgwater\n', metrics.reduction_cost_hybrid_vs_gasLP_abs);
    fprintf(fid,'- Reducción relativa de costo específico: %.6g %%\n\n', metrics.reduction_cost_hybrid_vs_gasLP_pct);

    fprintf(fid,'## Exclusión del modo solar puro\n\n');
    fprintf(fid,'El modo solar puro queda excluido como resultado comparativo defendible porque la trayectoria simulada entró en una región no física antes de su terminación. La primera violación detectada fue:\n\n');
    fprintf(fid,'- Variable: `%s`\n', metrics.solar_first_violation_variable);
    fprintf(fid,'- Regla: `%s`\n', metrics.solar_first_violation_rule);
    fprintf(fid,'- Índice de primera violación: %.0f\n', metrics.solar_first_violation_i);
    fprintf(fid,'- Valor de primera violación: %.12g\n', metrics.solar_first_violation_value);
    fprintf(fid,'- Índice de terminación solar auditada: %.0f\n\n', metrics.solar_break_i_626);

    fprintf(fid,'La trayectoria solar fue penalizada posteriormente como `NONPHYSICAL_TRAJECTORY`. Esta exclusión no invalida la comparación `gasLP`/`hybrid`, porque esos modos permanecieron válidos bajo las mismas guardas físicas.\n\n');

    fprintf(fid,'## Afirmaciones permitidas\n\n');
    fprintf(fid,'Las siguientes afirmaciones son técnicamente permitidas:\n\n');
    fprintf(fid,'- El modo `hybrid` mantiene un desempeño de secado equivalente al modo `gasLP` para la solución seleccionada.\n');
    fprintf(fid,'- El modo `hybrid` alcanza prácticamente el mismo tiempo de operación que `gasLP`.\n');
    fprintf(fid,'- El modo `hybrid` alcanza un MR final prácticamente equivalente al de `gasLP`.\n');
    fprintf(fid,'- El modo `hybrid` reduce la energía auxiliar respecto a `gasLP` en aproximadamente %.2f %%.\n', metrics.reduction_Q_aux_hybrid_vs_gasLP_pct);
    fprintf(fid,'- El modo `hybrid` reduce el costo específico respecto a `gasLP` en aproximadamente %.2f %%.\n', metrics.reduction_cost_hybrid_vs_gasLP_pct);
    fprintf(fid,'- La ventaja del modo `hybrid` es principalmente energética y económica, no cinética.\n');
    fprintf(fid,'- El modo `solar` puro debe reportarse como inválido o no comparable bajo la formulación actual.\n\n');

    fprintf(fid,'## Afirmaciones prohibidas o no defendibles\n\n');
    fprintf(fid,'Las siguientes afirmaciones no deben usarse:\n\n');
    fprintf(fid,'- No afirmar que el modo `hybrid` seca más rápido que `gasLP` en esta solución.\n');
    fprintf(fid,'- No afirmar que el modo `solar` puro supera a `hybrid` o `gasLP`.\n');
    fprintf(fid,'- No usar el costo penalizado del modo `solar` como costo físico real.\n');
    fprintf(fid,'- No usar `MR = 1000` del modo `solar` como resultado físico; es una penalización numérica.\n');
    fprintf(fid,'- No afirmar desempeño energético, económico o cinético del modo `solar` puro hasta corregir y revalidar su rama física.\n');
    fprintf(fid,'- No presentar la exclusión solar como invalidación de los resultados `gasLP`/`hybrid`.\n\n');

    fprintf(fid,'## Texto interpretativo consolidado\n\n');
    fprintf(fid,'%s\n\n', S631.paragraph_results);
    fprintf(fid,'%s\n\n', S631.paragraph_hybrid);
    fprintf(fid,'%s\n\n', S631.paragraph_energy);
    fprintf(fid,'%s\n\n', S631.paragraph_solar);
    fprintf(fid,'%s\n\n', S631.paragraph_limitations);
    fprintf(fid,'%s\n\n', S631.paragraph_conclusion);

    fprintf(fid,'## Archivos protegidos\n\n');
    fprintf(fid,'Los siguientes archivos deben conservarse sin modificación como referencia de trazabilidad:\n\n');
    fprintf(fid,'- `opt_tunel_mod2_v10_energy_mode_corrected.m`\n');
    fprintf(fid,'- `objective_productive_corrected_v611.m`\n');
    fprintf(fid,'- Corrida productiva `PRODUCTIVE_GA_CORRECTED_v614_20260626_175217`\n\n');

    fprintf(fid,'Las variantes con guardas (`v628b`, `v629`, `v630c`, `v631`) deben tratarse como artefactos controlados de evaluación postrun, no como reemplazo silencioso del modelo original.\n\n');

    fprintf(fid,'## Estado metodológico\n\n');
    fprintf(fid,'El análisis no requiere repetir el algoritmo genético en esta etapa. La evidencia actual permite defender la comparación `gasLP`/`hybrid` para la solución seleccionada. Una nueva corrida con guardas solo sería necesaria si se decide formular una nueva campaña de optimización bajo una política de factibilidad física explícita.\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % TXT resumen
    % ---------------------------------------------------------------------
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'KNOW-GUARDED-MODE-COMPARISON-001\n');
    fprintf(fid,'status: KNOW_GUARDED_MODE_COMPARISON_COMPLETED\n');
    fprintf(fid,'source_diagnosis: %s\n', S630.diagnosis);
    fprintf(fid,'runDir: %s\n', runDir);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'VALID MODES:\n');
    fprintf(fid,'gasLP: VALID\n');
    fprintf(fid,'hybrid: VALID\n');
    fprintf(fid,'solar: INVALID\n\n');

    fprintf(fid,'DEFENSIBLE COMPARISON:\n');
    fprintf(fid,'gasLP vs hybrid\n\n');

    fprintf(fid,'KEY RESULTS:\n');
    fprintf(fid,'gasLP dry_time: %.12g h\n', metrics.gasLP_dry_time_h);
    fprintf(fid,'hybrid dry_time: %.12g h\n', metrics.hybrid_dry_time_h);
    fprintf(fid,'delta MR hybrid-gasLP: %.12g\n', metrics.delta_MR_hybrid_minus_gasLP);
    fprintf(fid,'Q_aux reduction abs: %.12g\n', metrics.reduction_Q_aux_hybrid_vs_gasLP_abs);
    fprintf(fid,'Q_aux reduction pct: %.12g %%\n', metrics.reduction_Q_aux_hybrid_vs_gasLP_pct);
    fprintf(fid,'cost reduction abs: %.12g USD/kgwater\n', metrics.reduction_cost_hybrid_vs_gasLP_abs);
    fprintf(fid,'cost reduction pct: %.12g %%\n\n', metrics.reduction_cost_hybrid_vs_gasLP_pct);

    fprintf(fid,'SOLAR EXCLUSION:\n');
    fprintf(fid,'first variable: %s\n', metrics.solar_first_violation_variable);
    fprintf(fid,'rule: %s\n', metrics.solar_first_violation_rule);
    fprintf(fid,'index: %.0f\n', metrics.solar_first_violation_i);
    fprintf(fid,'value: %.12g\n\n', metrics.solar_first_violation_value);

    fprintf(fid,'OUTPUT KNOW:\n%s\n', outKnow);
    fclose(fid);

    % ---------------------------------------------------------------------
    % MAT
    % ---------------------------------------------------------------------
    save(outMat, ...
        'runDir','mat630c','mat631','outKnow','outTxt','metrics','flags','x', ...
        'T629report','S630','S631');

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    know = struct();
    know.status = 'KNOW_GUARDED_MODE_COMPARISON_COMPLETED';
    know.source_diagnosis = S630.diagnosis;
    know.outKnow = outKnow;
    know.outTxt = outTxt;
    know.outMat = outMat;
    know.runDir = runDir;
    know.metrics = metrics;
    know.flags = flags;

    disp('=== KNOW_GUARDED_MODE_COMPARISON_v632 ===')
    disp(know.status)
    disp('=== SOURCE DIAGNOSIS ===')
    disp(know.source_diagnosis)
    disp('=== OUTPUT KNOW ===')
    disp(know.outKnow)
    disp('=== SUMMARY OUTPUT ===')
    disp(know.outTxt)
    disp('=== MAT OUTPUT ===')
    disp(know.outMat)
    disp('=== CORE FLAGS ===')
    disp(know.flags)
end