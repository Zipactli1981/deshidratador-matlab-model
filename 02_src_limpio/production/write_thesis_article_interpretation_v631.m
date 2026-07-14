function interp = write_thesis_article_interpretation_v631()
% WRITE_THESIS_ARTICLE_INTERPRETATION_v631
% Micropaso 6.31 — WRITE-THESIS-ARTICLE-INTERPRETATION-001
%
% Objetivo:
%   Redactar interpretación técnica para tesis/artículo con base en el
%   consolidado 6.30c.
%
% Requiere:
%   mat/GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630c.mat
%
% No modifica:
%   - wrapper v10
%   - objective v611
%   - corrida productiva v614
%
% Salidas:
%   logs/THESIS_ARTICLE_INTERPRETATION_v631.md
%   logs/THESIS_ARTICLE_INTERPRETATION_v631.txt
%   mat/THESIS_ARTICLE_INTERPRETATION_v631.mat
%
% Uso:
%   interp = write_thesis_article_interpretation_v631();

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

    if ~isfile(mat630c)
        error('No existe consolidado v630c: %s', mat630c);
    end

    S = load(mat630c);

    required = {'diagnosis','flags','metrics','x','runDir','Tsummary','T629report'};
    for i = 1:numel(required)
        if ~isfield(S, required{i})
            error('El MAT v630c no contiene la variable requerida: %s', required{i});
        end
    end

    metrics = S.metrics;
    flags   = S.flags;
    x       = S.x;
    Tsummary = S.Tsummary;
    T629report = S.T629report;

    % ---------------------------------------------------------------------
    % Validaciones mínimas
    % ---------------------------------------------------------------------
    if ~flags.hybrid_gasLP_comparison_allowed
        warning('La comparación gasLP/hybrid no aparece como permitida en v630c.');
    end

    if flags.solar_performance_claims_allowed
        warning('solar_performance_claims_allowed aparece como true. Revisar antes de reportar.');
    end

    % ---------------------------------------------------------------------
    % Redacciones base
    % ---------------------------------------------------------------------
    paragraph_results = sprintf([ ...
        'La solución seleccionada por la corrida productiva quedó definida por ', ...
        'm_{max}=%.6g, T_{min}=%.6g °C, r_{div2}=%.6g y t_{rec,ini}=%.6g h. ', ...
        'Bajo la evaluación postrun con guardas físicas, los modos gasLP e híbrido ', ...
        'permanecieron como trayectorias válidas, mientras que el modo solar puro fue ', ...
        'clasificado como inválido por violación de dominio físico. Por tanto, la ', ...
        'comparación de desempeño defendible se restringe a los modos gasLP e híbrido.' ], ...
        x.m_max, x.T_min, x.r_div2, x.t_rec_ini);

    paragraph_hybrid = sprintf([ ...
        'En la comparación válida, el modo híbrido reprodujo prácticamente el mismo ', ...
        'estado final de secado que el modo gasLP. El tiempo de operación fue %.6g h ', ...
        'en ambos casos, y la diferencia de MR entre híbrido y gasLP fue %.6g. ', ...
        'Por esta razón, el resultado no debe interpretarse como una reducción del ', ...
        'tiempo de secado, sino como una operación térmicamente equivalente con menor ', ...
        'demanda de energía auxiliar.' ], ...
        metrics.gasLP_dry_time_h, metrics.delta_MR_hybrid_minus_gasLP);

    paragraph_energy = sprintf([ ...
        'El beneficio principal del modo híbrido se observó en el consumo auxiliar y ', ...
        'en el costo específico. El aporte auxiliar disminuyó de %.6g a %.6g, lo que ', ...
        'representa una reducción absoluta de %.6g y una reducción relativa de %.4g %%. ', ...
        'De forma consistente, el costo específico disminuyó de %.6g a %.6g USD/kgwater, ', ...
        'equivalente a una reducción absoluta de %.6g USD/kgwater y una reducción ', ...
        'relativa de %.4g %%.' ], ...
        metrics.gasLP_Q_aux, metrics.hybrid_Q_aux, ...
        metrics.reduction_Q_aux_hybrid_vs_gasLP_abs, ...
        metrics.reduction_Q_aux_hybrid_vs_gasLP_pct, ...
        metrics.gasLP_cost, metrics.hybrid_cost, ...
        metrics.reduction_cost_hybrid_vs_gasLP_abs, ...
        metrics.reduction_cost_hybrid_vs_gasLP_pct);

    paragraph_solar = sprintf([ ...
        'El modo solar puro no se utilizó para sostener afirmaciones de desempeño, ', ...
        'debido a que su trayectoria entró en una región no física antes de la terminación ', ...
        'de la simulación. La primera violación detectada correspondió a %s bajo la regla ', ...
        '%s en el índice %.0f, con un valor de %.6g. Posteriormente, la política de ', ...
        'guardas físicas penalizó esta trayectoria como NONPHYSICAL_TRAJECTORY. Esta ', ...
        'exclusión no invalida la comparación gasLP/híbrido, ya que ambas trayectorias ', ...
        'permanecieron válidas bajo las mismas reglas de evaluación.' ], ...
        metrics.solar_first_violation_variable, ...
        metrics.solar_first_violation_rule, ...
        metrics.solar_first_violation_i, ...
        metrics.solar_first_violation_value);

    paragraph_limitations = sprintf([ ...
        'Como limitación metodológica, la rama solar pura requiere revisión física y ', ...
        'numérica antes de incorporarse a conclusiones comparativas. En particular, ', ...
        'debe revisarse el tratamiento de estados psicrométricos fuera de dominio, ', ...
        'incluyendo condiciones de sobresaturación. Hasta contar con una rama solar ', ...
        'corregida y revalidada, los resultados del modo solar puro deben reportarse ', ...
        'como no válidos o no comparables bajo la formulación actual.' ]);

    paragraph_conclusion = sprintf([ ...
        'En síntesis, el modo híbrido permite mantener un desempeño de secado equivalente ', ...
        'al modo gasLP, con el mismo tiempo de operación y MR final prácticamente igual, ', ...
        'pero con menor consumo de energía auxiliar y menor costo específico. Por tanto, ', ...
        'la ventaja del modo híbrido es principalmente energética y económica, no cinética.' ]);

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outMd  = fullfile(logsDir,'THESIS_ARTICLE_INTERPRETATION_v631.md');
    outTxt = fullfile(logsDir,'THESIS_ARTICLE_INTERPRETATION_v631.txt');
    outMat = fullfile(matDir,'THESIS_ARTICLE_INTERPRETATION_v631.mat');

    % ---------------------------------------------------------------------
    % Markdown para tesis/artículo
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# Micropaso 6.31 — WRITE-THESIS-ARTICLE-INTERPRETATION-001\n\n');

    fprintf(fid,'## Estatus\n\n');
    fprintf(fid,'Diagnóstico base v630c: `%s`\n\n', S.diagnosis);
    fprintf(fid,'Archivo fuente: `%s`\n\n', mat630c);

    fprintf(fid,'## Tabla de resultados defendibles\n\n');
    fprintf(fid,'| Modo | Validez | MR | Costo específico [USD/kgwater] | Q_aux_tot | Irradiación | Tiempo [h] | M final |\n');
    fprintf(fid,'|---|---:|---:|---:|---:|---:|---:|---:|\n');

    for r = 1:height(T629report)
        fprintf(fid,'| %s | %s | %.6g | %.6g | %.6g | %.6g | %.6g | %.6g |\n', ...
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

    fprintf(fid,'## Resultados\n\n');
    fprintf(fid,'%s\n\n', paragraph_results);
    fprintf(fid,'%s\n\n', paragraph_hybrid);
    fprintf(fid,'%s\n\n', paragraph_energy);

    fprintf(fid,'## Tratamiento del modo solar puro\n\n');
    fprintf(fid,'%s\n\n', paragraph_solar);

    fprintf(fid,'## Limitación metodológica\n\n');
    fprintf(fid,'%s\n\n', paragraph_limitations);

    fprintf(fid,'## Conclusión interpretativa\n\n');
    fprintf(fid,'%s\n\n', paragraph_conclusion);

    fprintf(fid,'## Texto integrado sugerido para tesis/artículo\n\n');
    fprintf(fid,'%s\n\n%s\n\n%s\n\n%s\n\n%s\n\n%s\n\n', ...
        paragraph_results, ...
        paragraph_hybrid, ...
        paragraph_energy, ...
        paragraph_solar, ...
        paragraph_limitations, ...
        paragraph_conclusion);

    fprintf(fid,'## Criterios de uso\n\n');
    fprintf(fid,'- No afirmar que el modo híbrido reduce el tiempo de secado respecto a gasLP.\n');
    fprintf(fid,'- Sí afirmar que el modo híbrido mantiene desempeño de secado equivalente con menor consumo auxiliar.\n');
    fprintf(fid,'- Sí afirmar que el costo específico disminuye bajo el modo híbrido.\n');
    fprintf(fid,'- No usar el modo solar puro como resultado comparativo defendible.\n');
    fprintf(fid,'- Reportar el modo solar puro como trayectoria inválida bajo la formulación actual.\n');
    fprintf(fid,'- No repetir el AG en esta etapa.\n');
    fprintf(fid,'- No modificar v10 ni v611.\n\n');

    fprintf(fid,'## Trazabilidad\n\n');
    fprintf(fid,'- Consolidado base: `GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630c.mat`\n');
    fprintf(fid,'- Corrida productiva: `%s`\n', runDir);
    fprintf(fid,'- Estado de comparación: gasLP/hybrid defendible; solar puro excluido.\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % TXT plano
    % ---------------------------------------------------------------------
    fid = fopen(outTxt,'w');
    fprintf(fid,'WRITE-THESIS-ARTICLE-INTERPRETATION-001\n');
    fprintf(fid,'status: THESIS_ARTICLE_INTERPRETATION_COMPLETED\n');
    fprintf(fid,'source_diagnosis: %s\n', S.diagnosis);
    fprintf(fid,'runDir: %s\n', runDir);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'--- RESULTS PARAGRAPH ---\n%s\n\n', paragraph_results);
    fprintf(fid,'--- HYBRID INTERPRETATION ---\n%s\n\n', paragraph_hybrid);
    fprintf(fid,'--- ENERGY ECONOMIC INTERPRETATION ---\n%s\n\n', paragraph_energy);
    fprintf(fid,'--- SOLAR EXCLUSION ---\n%s\n\n', paragraph_solar);
    fprintf(fid,'--- LIMITATIONS ---\n%s\n\n', paragraph_limitations);
    fprintf(fid,'--- CONCLUSION ---\n%s\n\n', paragraph_conclusion);

    fprintf(fid,'--- OUTPUTS ---\n');
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fclose(fid);

    save(outMat, ...
        'paragraph_results', ...
        'paragraph_hybrid', ...
        'paragraph_energy', ...
        'paragraph_solar', ...
        'paragraph_limitations', ...
        'paragraph_conclusion', ...
        'metrics','flags','x','Tsummary','T629report','runDir','mat630c','outMd','outTxt');

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    interp = struct();
    interp.status = 'THESIS_ARTICLE_INTERPRETATION_COMPLETED';
    interp.source_diagnosis = S.diagnosis;
    interp.paragraph_results = paragraph_results;
    interp.paragraph_hybrid = paragraph_hybrid;
    interp.paragraph_energy = paragraph_energy;
    interp.paragraph_solar = paragraph_solar;
    interp.paragraph_limitations = paragraph_limitations;
    interp.paragraph_conclusion = paragraph_conclusion;
    interp.outMd = outMd;
    interp.outTxt = outTxt;
    interp.outMat = outMat;
    interp.runDir = runDir;

    disp('=== THESIS_ARTICLE_INTERPRETATION_v631 ===')
    disp(interp.status)
    disp('=== SOURCE DIAGNOSIS ===')
    disp(interp.source_diagnosis)
    disp('=== RESULTS ===')
    disp(interp.paragraph_results)
    disp('=== HYBRID INTERPRETATION ===')
    disp(interp.paragraph_hybrid)
    disp('=== ENERGY/ECONOMIC INTERPRETATION ===')
    disp(interp.paragraph_energy)
    disp('=== SOLAR EXCLUSION ===')
    disp(interp.paragraph_solar)
    disp('=== LIMITATIONS ===')
    disp(interp.paragraph_limitations)
    disp('=== CONCLUSION ===')
    disp(interp.paragraph_conclusion)
    disp('=== OUTPUT FILES ===')
    disp(interp.outMd)
    disp(interp.outTxt)
    disp(interp.outMat)
end