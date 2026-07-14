function conclusions = draft_article_conclusions_section_v730()
% DRAFT_ARTICLE_CONCLUSIONS_SECTION_v730
% 7.3 — ARTICLE-CONCLUSIONS-SECTION-DRAFT-001
%
% Objetivo:
%   Generar un borrador de la sección Conclusions del artículo a partir del
%   paquete postrun cerrado, Results v710 y Discussion v720.
%
% Usa:
%   - FINAL_POSTRUN_PACKAGE_INDEX_v633.mat
%   - GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630c.mat
%   - KNOW_06_32_guarded_mode_comparison.mat
%   - ARTICLE_RESULTS_SECTION_DRAFT_v710.mat
%   - ARTICLE_DISCUSSION_SECTION_DRAFT_v720.mat
%
% No modifica:
%   - wrapper v10
%   - objective v611
%   - corrida productiva v614
%
% Salidas:
%   logs/ARTICLE_CONCLUSIONS_SECTION_DRAFT_v730.md
%   logs/ARTICLE_CONCLUSIONS_SECTION_DRAFT_v730.txt
%   mat/ARTICLE_CONCLUSIONS_SECTION_DRAFT_v730.mat
%
% Uso:
%   conclusions = draft_article_conclusions_section_v730();

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
    mat632 = fullfile(matDir,'KNOW_06_32_guarded_mode_comparison.mat');
    mat710 = fullfile(matDir,'ARTICLE_RESULTS_SECTION_DRAFT_v710.mat');
    mat720 = fullfile(matDir,'ARTICLE_DISCUSSION_SECTION_DRAFT_v720.mat');

    if ~isfile(mat633)
        error('No existe índice final v633: %s', mat633);
    end

    if ~isfile(mat630)
        error('No existe consolidado v630c: %s', mat630);
    end

    if ~isfile(mat632)
        error('No existe KNOW v632: %s', mat632);
    end

    if ~isfile(mat710)
        error('No existe Results v710: %s', mat710);
    end

    if ~isfile(mat720)
        error('No existe Discussion v720: %s', mat720);
    end

    S633 = load(mat633);
    S630 = load(mat630);
    S632 = load(mat632);
    S710 = load(mat710);
    S720 = load(mat720);

    % ---------------------------------------------------------------------
    % Validaciones
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

    if ~isfield(S710,'p_closing')
        error('El MAT v710 no contiene p_closing.');
    end

    if ~isfield(S720,'p_closing')
        error('El MAT v720 no contiene p_closing.');
    end

    metrics = S630.metrics;
    flags   = S630.flags;
    x       = S630.x;
    T629report = S630.T629report;

    if ~flags.hybrid_gasLP_comparison_allowed
        error('La comparación gasLP/hybrid no está permitida según v630c.');
    end

    if flags.solar_performance_claims_allowed
        error('solar_performance_claims_allowed aparece true. Revisar antes de redactar.');
    end

    % ---------------------------------------------------------------------
    % Párrafos de Conclusions
    % ---------------------------------------------------------------------
    c1_objective = sprintf([ ...
        'This work evaluated the selected operating point obtained from the productive ', ...
        'multi-objective optimization of a hybrid solar--gas-LP drying system. The selected ', ...
        'solution was defined by $m_{max}=%.6g$, $T_{min}=%.6g~^{\\circ}\\mathrm{C}$, ', ...
        '$r_{div2}=%.6g$, and $t_{rec,ini}=%.6g~\\mathrm{h}$. A guarded post-run ', ...
        'assessment was used to verify the physical feasibility of the operating modes ', ...
        'before drawing comparative performance conclusions.' ], ...
        x.m_max, x.T_min, x.r_div2, x.t_rec_ini);

    c2_valid_comparison = sprintf([ ...
        'The guarded assessment confirmed that the gas-LP and hybrid operating modes were ', ...
        'valid trajectories for the selected solution. Both modes produced practically ', ...
        'equivalent drying outcomes: the drying time was %.6g h in both cases, and the ', ...
        'difference in final moisture ratio between the hybrid and gas-LP modes was only %.6g. ', ...
        'Therefore, the hybrid mode should not be interpreted as a faster drying strategy ', ...
        'for this operating point.' ], ...
        metrics.hybrid_dry_time_h, metrics.delta_MR_hybrid_minus_gasLP);

    c3_energy_cost = sprintf([ ...
        'The main benefit of the hybrid mode was energetic and economic. Relative to the ', ...
        'gas-LP mode, the hybrid configuration reduced the auxiliary energy demand by %.4g%% ', ...
        'and reduced the specific drying cost by %.4g%%. These reductions were achieved ', ...
        'while preserving the same drying time and nearly the same final moisture ratio, ', ...
        'indicating that the solar contribution primarily substituted auxiliary fuel rather ', ...
        'than modifying the drying kinetics.' ], ...
        metrics.reduction_Q_aux_hybrid_vs_gasLP_pct, ...
        metrics.reduction_cost_hybrid_vs_gasLP_pct);

    c4_solar = sprintf([ ...
        'The pure solar mode was excluded from comparative performance claims because its ', ...
        'simulated trajectory entered a nonphysical psychrometric domain. The first detected ', ...
        'violation occurred in $%s$ at index %.0f, with a value of %.6g under the rule `%s`. ', ...
        'Consequently, the penalized pure solar objective values should be interpreted only ', ...
        'as feasibility penalties and not as physical drying results.' ], ...
        metrics.solar_first_violation_variable, ...
        metrics.solar_first_violation_i, ...
        metrics.solar_first_violation_value, ...
        metrics.solar_first_violation_rule);

    c5_scope = sprintf([ ...
        'The exclusion of the pure solar branch does not invalidate the gas-LP/hybrid ', ...
        'comparison, because both valid modes satisfied the same physical-guard policy. ', ...
        'However, the solar branch requires further physical and numerical revision, ', ...
        'particularly regarding the treatment of psychrometric states near or above saturation, ', ...
        'before it can be included in a three-mode performance comparison.' ]);

    c6_final = sprintf([ ...
        'Overall, the results support the hybrid configuration as an energy-substitution ', ...
        'strategy rather than a drying-time-reduction strategy. For the selected operating ', ...
        'point, hybridization preserved the gas-LP drying outcome while reducing auxiliary ', ...
        'fuel use and specific cost.' ]);

    concise_conclusion = sprintf([ ...
        'The hybrid mode maintained the same drying time and nearly the same final moisture ', ...
        'ratio as the gas-LP mode, while reducing auxiliary energy demand by %.4g%% and ', ...
        'specific drying cost by %.4g%%. Thus, its advantage was energetic and economic, ', ...
        'not kinetic. The pure solar mode was excluded from comparative claims because it ', ...
        'entered a nonphysical psychrometric domain and was penalized under the guarded ', ...
        'feasibility policy.' ], ...
        metrics.reduction_Q_aux_hybrid_vs_gasLP_pct, ...
        metrics.reduction_cost_hybrid_vs_gasLP_pct);

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outMd  = fullfile(logsDir,'ARTICLE_CONCLUSIONS_SECTION_DRAFT_v730.md');
    outTxt = fullfile(logsDir,'ARTICLE_CONCLUSIONS_SECTION_DRAFT_v730.txt');
    outMat = fullfile(matDir,'ARTICLE_CONCLUSIONS_SECTION_DRAFT_v730.mat');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# ARTICLE_CONCLUSIONS_SECTION_DRAFT_v730\n\n');

    fprintf(fid,'## Conclusions\n\n');
    fprintf(fid,'%s\n\n', c1_objective);
    fprintf(fid,'%s\n\n', c2_valid_comparison);
    fprintf(fid,'%s\n\n', c3_energy_cost);
    fprintf(fid,'%s\n\n', c4_solar);
    fprintf(fid,'%s\n\n', c5_scope);
    fprintf(fid,'%s\n\n', c6_final);

    fprintf(fid,'## Short conclusion option\n\n');
    fprintf(fid,'%s\n\n', concise_conclusion);

    fprintf(fid,'## Author control notes\n\n');
    fprintf(fid,'- Do not claim that the hybrid mode shortened the drying time.\n');
    fprintf(fid,'- Emphasize auxiliary fuel substitution and cost reduction.\n');
    fprintf(fid,'- Keep the pure solar mode excluded from performance comparisons.\n');
    fprintf(fid,'- Do not interpret solar penalized MR or cost as physical results.\n');
    fprintf(fid,'- Frame the solar issue as a branch/model limitation requiring future correction, not as invalidation of gas-LP/hybrid results.\n');
    fprintf(fid,'- Source package: `%s`\n', runDir);

    fclose(fid);

    % ---------------------------------------------------------------------
    % TXT
    % ---------------------------------------------------------------------
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'ARTICLE-CONCLUSIONS-SECTION-DRAFT-001\n');
    fprintf(fid,'status: ARTICLE_CONCLUSIONS_SECTION_DRAFT_COMPLETED\n');
    fprintf(fid,'source_finalDiagnosis: %s\n', string(S633.finalDiagnosis));
    fprintf(fid,'runDir: %s\n', runDir);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'--- CONCLUSION 1 OBJECTIVE ---\n%s\n\n', c1_objective);
    fprintf(fid,'--- CONCLUSION 2 VALID COMPARISON ---\n%s\n\n', c2_valid_comparison);
    fprintf(fid,'--- CONCLUSION 3 ENERGY COST ---\n%s\n\n', c3_energy_cost);
    fprintf(fid,'--- CONCLUSION 4 SOLAR EXCLUSION ---\n%s\n\n', c4_solar);
    fprintf(fid,'--- CONCLUSION 5 SCOPE ---\n%s\n\n', c5_scope);
    fprintf(fid,'--- CONCLUSION 6 FINAL ---\n%s\n\n', c6_final);
    fprintf(fid,'--- SHORT OPTION ---\n%s\n\n', concise_conclusion);

    fprintf(fid,'OUTPUTS:\n');
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fclose(fid);

    save(outMat, ...
        'c1_objective', ...
        'c2_valid_comparison', ...
        'c3_energy_cost', ...
        'c4_solar', ...
        'c5_scope', ...
        'c6_final', ...
        'concise_conclusion', ...
        'metrics','flags','x','T629report','runDir', ...
        'mat633','mat630','mat632','mat710','mat720','outMd','outTxt');

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    conclusions = struct();
    conclusions.status = 'ARTICLE_CONCLUSIONS_SECTION_DRAFT_COMPLETED';
    conclusions.source_finalDiagnosis = string(S633.finalDiagnosis);
    conclusions.runDir = runDir;
    conclusions.outMd = outMd;
    conclusions.outTxt = outTxt;
    conclusions.outMat = outMat;
    conclusions.c1_objective = c1_objective;
    conclusions.c2_valid_comparison = c2_valid_comparison;
    conclusions.c3_energy_cost = c3_energy_cost;
    conclusions.c4_solar = c4_solar;
    conclusions.c5_scope = c5_scope;
    conclusions.c6_final = c6_final;
    conclusions.concise_conclusion = concise_conclusion;

    disp('=== ARTICLE_CONCLUSIONS_SECTION_DRAFT_v730 ===')
    disp(conclusions.status)
    disp('=== SOURCE FINAL DIAGNOSIS ===')
    disp(conclusions.source_finalDiagnosis)
    disp('=== CONCLUSION 1 ===')
    disp(conclusions.c1_objective)
    disp('=== CONCLUSION 2 ===')
    disp(conclusions.c2_valid_comparison)
    disp('=== CONCLUSION 3 ===')
    disp(conclusions.c3_energy_cost)
    disp('=== CONCLUSION 4 ===')
    disp(conclusions.c4_solar)
    disp('=== CONCLUSION 5 ===')
    disp(conclusions.c5_scope)
    disp('=== CONCLUSION 6 ===')
    disp(conclusions.c6_final)
    disp('=== SHORT CONCLUSION OPTION ===')
    disp(conclusions.concise_conclusion)
    disp('=== OUTPUT FILES ===')
    disp(conclusions.outMd)
    disp(conclusions.outTxt)
    disp(conclusions.outMat)
end