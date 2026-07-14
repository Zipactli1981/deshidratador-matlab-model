function article = draft_article_results_section_v710()
% DRAFT_ARTICLE_RESULTS_SECTION_v710
% 7.1 — ARTICLE-RESULTS-SECTION-DRAFT-001
%
% Objetivo:
%   Generar un borrador de la sección Results del artículo a partir del
%   paquete postrun cerrado:
%       - FINAL_POSTRUN_PACKAGE_INDEX_v633.mat
%       - GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630c.mat
%       - THESIS_ARTICLE_INTERPRETATION_v631.mat
%       - KNOW_06_32_guarded_mode_comparison.mat
%
% No modifica:
%   - wrapper v10
%   - objective v611
%   - corrida productiva v614
%
% Salidas:
%   logs/ARTICLE_RESULTS_SECTION_DRAFT_v710.md
%   logs/ARTICLE_RESULTS_SECTION_DRAFT_v710.txt
%   mat/ARTICLE_RESULTS_SECTION_DRAFT_v710.mat
%
% Uso:
%   article = draft_article_results_section_v710();

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

    % ---------------------------------------------------------------------
    % Archivos base
    % ---------------------------------------------------------------------
    mat633 = fullfile(matDir,'FINAL_POSTRUN_PACKAGE_INDEX_v633.mat');
    mat630 = fullfile(matDir,'GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630c.mat');
    mat631 = fullfile(matDir,'THESIS_ARTICLE_INTERPRETATION_v631.mat');
    mat632 = fullfile(matDir,'KNOW_06_32_guarded_mode_comparison.mat');

    if ~isfile(mat633)
        error('No existe índice final v633: %s', mat633);
    end

    if ~isfile(mat630)
        error('No existe consolidado v630c: %s', mat630);
    end

    if ~isfile(mat631)
        error('No existe interpretación v631: %s', mat631);
    end

    if ~isfile(mat632)
        error('No existe KNOW v632: %s', mat632);
    end

    S633 = load(mat633);
    S630 = load(mat630);
    S631 = load(mat631);
    S632 = load(mat632);

    % ---------------------------------------------------------------------
    % Validaciones mínimas
    % ---------------------------------------------------------------------
    if ~isfield(S633,'finalDiagnosis')
        error('El MAT v633 no contiene finalDiagnosis.');
    end

    if ~strcmp(string(S633.finalDiagnosis),"FINAL_POSTRUN_PACKAGE_INDEX_PASS")
        error('El paquete postrun no está en PASS. Diagnóstico: %s', string(S633.finalDiagnosis));
    end

    if ~isfield(S630,'metrics') || ~isfield(S630,'flags') || ~isfield(S630,'x') || ~isfield(S630,'T629report')
        error('El MAT v630c no contiene metrics, flags, x o T629report.');
    end

    if ~isfield(S631,'paragraph_results') || ...
       ~isfield(S631,'paragraph_hybrid') || ...
       ~isfield(S631,'paragraph_energy') || ...
       ~isfield(S631,'paragraph_solar') || ...
       ~isfield(S631,'paragraph_limitations') || ...
       ~isfield(S631,'paragraph_conclusion')
        error('El MAT v631 no contiene los párrafos requeridos.');
    end

    metrics = S630.metrics;
    flags = S630.flags;
    x = S630.x;
    T629report = S630.T629report;

    if ~flags.hybrid_gasLP_comparison_allowed
        error('La comparación gasLP/hybrid no está permitida según v630c.');
    end

    if flags.solar_performance_claims_allowed
        error('solar_performance_claims_allowed aparece true. Revisar antes de redactar.');
    end

    % ---------------------------------------------------------------------
    % Extraer tabla por modos
    % ---------------------------------------------------------------------
    T629report.mode = string(T629report.mode);
    T629report.validity = string(T629report.validity);

    gas = T629report(strcmp(T629report.mode,"gasLP"),:);
    hyb = T629report(strcmp(T629report.mode,"hybrid"),:);
    sol = T629report(strcmp(T629report.mode,"solar"),:);

    if isempty(gas) || isempty(hyb) || isempty(sol)
        error('T629report no contiene gasLP, hybrid y solar.');
    end

    % ---------------------------------------------------------------------
    % Párrafos de Results
    % ---------------------------------------------------------------------
    p_intro = sprintf([ ...
        'The post-run assessment was performed on the selected solution obtained from the ', ...
        'productive multi-objective optimization. The selected decision vector was ', ...
        '$m_{max}=%.6g$, $T_{min}=%.6g~^{\\circ}\\mathrm{C}$, ', ...
        '$r_{div2}=%.6g$, and $t_{rec,ini}=%.6g~\\mathrm{h}$. ', ...
        'The guarded post-run evaluation classified the gas-LP and hybrid operating modes ', ...
        'as valid trajectories, whereas the pure solar mode was classified as invalid due ', ...
        'to a nonphysical trajectory. Consequently, the defensible performance comparison ', ...
        'was restricted to the gas-LP and hybrid modes.' ], ...
        x.m_max, x.T_min, x.r_div2, x.t_rec_ini);

    p_table = sprintf([ ...
        'Table 1 summarizes the guarded post-run results. The gas-LP and hybrid cases ', ...
        'reached practically equivalent final drying conditions. The gas-LP case reached ', ...
        '$MR=%.6g$ after %.6g h, whereas the hybrid case reached $MR=%.6g$ after %.6g h. ', ...
        'The difference in moisture ratio between the hybrid and gas-LP cases was only %.6g, ', ...
        'which indicates that both modes produced an equivalent drying outcome for the selected solution.' ], ...
        metrics.gasLP_MR, metrics.gasLP_dry_time_h, ...
        metrics.hybrid_MR, metrics.hybrid_dry_time_h, ...
        metrics.delta_MR_hybrid_minus_gasLP);

    p_energy = sprintf([ ...
        'The main difference between both valid modes was not associated with drying time, ', ...
        'but with auxiliary energy demand. The auxiliary energy requirement decreased from ', ...
        '%.6g in the gas-LP mode to %.6g in the hybrid mode. This represents an absolute ', ...
        'reduction of %.6g and a relative reduction of %.4g%%. Therefore, the hybrid mode ', ...
        'maintained an equivalent drying performance while partially replacing auxiliary ', ...
        'fuel demand with available solar energy.' ], ...
        metrics.gasLP_Q_aux, metrics.hybrid_Q_aux, ...
        metrics.reduction_Q_aux_hybrid_vs_gasLP_abs, ...
        metrics.reduction_Q_aux_hybrid_vs_gasLP_pct);

    p_cost = sprintf([ ...
        'The reduction in auxiliary energy demand was reflected in the specific drying cost. ', ...
        'The specific cost decreased from %.6g USD kg$_{water}^{-1}$ in the gas-LP mode ', ...
        'to %.6g USD kg$_{water}^{-1}$ in the hybrid mode. This corresponds to an absolute ', ...
        'reduction of %.6g USD kg$_{water}^{-1}$ and a relative reduction of %.4g%%.' ], ...
        metrics.gasLP_cost, metrics.hybrid_cost, ...
        metrics.reduction_cost_hybrid_vs_gasLP_abs, ...
        metrics.reduction_cost_hybrid_vs_gasLP_pct);

    p_solar = sprintf([ ...
        'The pure solar mode was not used to support comparative performance claims. ', ...
        'The guarded evaluation detected a nonphysical condition before trajectory termination. ', ...
        'The first violation occurred in $%s$ under the rule `%s` at index %.0f, with a value ', ...
        'of %.6g. The pure solar trajectory was therefore penalized as `NONPHYSICAL_TRAJECTORY`. ', ...
        'The penalized values assigned to the pure solar case must be interpreted only as ', ...
        'numerical feasibility penalties, not as physical drying results.' ], ...
        metrics.solar_first_violation_variable, ...
        metrics.solar_first_violation_rule, ...
        metrics.solar_first_violation_i, ...
        metrics.solar_first_violation_value);

    p_closing = sprintf([ ...
        'Overall, the hybrid configuration did not provide a kinetic advantage over the gas-LP ', ...
        'configuration for the selected solution, since both modes produced the same drying time ', ...
        'and nearly identical final moisture ratio. Its advantage was primarily energetic and ', ...
        'economic: the hybrid mode reduced auxiliary energy use by %.4g%% and specific cost by %.4g%% ', ...
        'while maintaining equivalent drying performance.' ], ...
        metrics.reduction_Q_aux_hybrid_vs_gasLP_pct, ...
        metrics.reduction_cost_hybrid_vs_gasLP_pct);

    % ---------------------------------------------------------------------
    % Caption propuesta
    % ---------------------------------------------------------------------
    table_caption = sprintf([ ...
        'Table 1. Guarded post-run comparison of the selected gas-LP, hybrid, and pure solar ', ...
        'operating modes. The pure solar case was classified as invalid due to a nonphysical ', ...
        'trajectory and is shown only for traceability of the feasibility policy.' ]);

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outMd  = fullfile(logsDir,'ARTICLE_RESULTS_SECTION_DRAFT_v710.md');
    outTxt = fullfile(logsDir,'ARTICLE_RESULTS_SECTION_DRAFT_v710.txt');
    outMat = fullfile(matDir,'ARTICLE_RESULTS_SECTION_DRAFT_v710.mat');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# ARTICLE_RESULTS_SECTION_DRAFT_v710\n\n');

    fprintf(fid,'## Results\n\n');
    fprintf(fid,'%s\n\n', p_intro);
    fprintf(fid,'%s\n\n', p_table);

    fprintf(fid,'**%s**\n\n', table_caption);
    fprintf(fid,'| Operating mode | Validity | MR | Specific cost [USD kg_water^-1] | Q_aux_tot | Solar irradiation | Drying time [h] | Final M |\n');
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

    fprintf(fid,'\n%s\n\n', p_energy);
    fprintf(fid,'%s\n\n', p_cost);
    fprintf(fid,'%s\n\n', p_solar);
    fprintf(fid,'%s\n\n', p_closing);

    fprintf(fid,'## Author control notes\n\n');
    fprintf(fid,'- Do not state that the hybrid mode dries faster than gas-LP.\n');
    fprintf(fid,'- Do state that the hybrid mode maintains equivalent drying performance with lower auxiliary energy demand.\n');
    fprintf(fid,'- Do state that the benefit is energetic and economic, not kinetic.\n');
    fprintf(fid,'- Do not use the pure solar penalized MR or cost as physical results.\n');
    fprintf(fid,'- Keep the pure solar result as an invalid trajectory under the guarded feasibility policy.\n');
    fprintf(fid,'- Source package: `%s`\n', runDir);

    fclose(fid);

    % ---------------------------------------------------------------------
    % TXT
    % ---------------------------------------------------------------------
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'ARTICLE-RESULTS-SECTION-DRAFT-001\n');
    fprintf(fid,'status: ARTICLE_RESULTS_SECTION_DRAFT_COMPLETED\n');
    fprintf(fid,'source_finalDiagnosis: %s\n', string(S633.finalDiagnosis));
    fprintf(fid,'runDir: %s\n', runDir);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'--- RESULTS INTRO ---\n%s\n\n', p_intro);
    fprintf(fid,'--- RESULTS TABLE DISCUSSION ---\n%s\n\n', p_table);
    fprintf(fid,'--- ENERGY RESULT ---\n%s\n\n', p_energy);
    fprintf(fid,'--- COST RESULT ---\n%s\n\n', p_cost);
    fprintf(fid,'--- SOLAR EXCLUSION ---\n%s\n\n', p_solar);
    fprintf(fid,'--- CLOSING RESULT ---\n%s\n\n', p_closing);

    fprintf(fid,'OUTPUTS:\n');
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fclose(fid);

    save(outMat, ...
        'p_intro','p_table','p_energy','p_cost','p_solar','p_closing', ...
        'table_caption','metrics','flags','x','T629report','runDir', ...
        'mat633','mat630','mat631','mat632','outMd','outTxt');

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    article = struct();
    article.status = 'ARTICLE_RESULTS_SECTION_DRAFT_COMPLETED';
    article.source_finalDiagnosis = string(S633.finalDiagnosis);
    article.runDir = runDir;
    article.outMd = outMd;
    article.outTxt = outTxt;
    article.outMat = outMat;
    article.p_intro = p_intro;
    article.p_table = p_table;
    article.p_energy = p_energy;
    article.p_cost = p_cost;
    article.p_solar = p_solar;
    article.p_closing = p_closing;

    disp('=== ARTICLE_RESULTS_SECTION_DRAFT_v710 ===')
    disp(article.status)
    disp('=== SOURCE FINAL DIAGNOSIS ===')
    disp(article.source_finalDiagnosis)
    disp('=== RESULTS INTRO ===')
    disp(article.p_intro)
    disp('=== RESULTS TABLE DISCUSSION ===')
    disp(article.p_table)
    disp('=== ENERGY RESULT ===')
    disp(article.p_energy)
    disp('=== COST RESULT ===')
    disp(article.p_cost)
    disp('=== SOLAR EXCLUSION ===')
    disp(article.p_solar)
    disp('=== CLOSING RESULT ===')
    disp(article.p_closing)
    disp('=== OUTPUT FILES ===')
    disp(article.outMd)
    disp(article.outTxt)
    disp(article.outMat)
end