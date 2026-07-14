function discussion = draft_article_discussion_section_v720()
% DRAFT_ARTICLE_DISCUSSION_SECTION_v720
% 7.2 — ARTICLE-DISCUSSION-SECTION-DRAFT-001
%
% Objetivo:
%   Generar un borrador de la sección Discussion del artículo a partir del
%   paquete postrun cerrado y del borrador de Results.
%
% Usa:
%   - FINAL_POSTRUN_PACKAGE_INDEX_v633.mat
%   - GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630c.mat
%   - THESIS_ARTICLE_INTERPRETATION_v631.mat
%   - KNOW_06_32_guarded_mode_comparison.mat
%   - ARTICLE_RESULTS_SECTION_DRAFT_v710.mat
%
% No modifica:
%   - wrapper v10
%   - objective v611
%   - corrida productiva v614
%
% Salidas:
%   logs/ARTICLE_DISCUSSION_SECTION_DRAFT_v720.md
%   logs/ARTICLE_DISCUSSION_SECTION_DRAFT_v720.txt
%   mat/ARTICLE_DISCUSSION_SECTION_DRAFT_v720.mat
%
% Uso:
%   discussion = draft_article_discussion_section_v720();

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
    mat710 = fullfile(matDir,'ARTICLE_RESULTS_SECTION_DRAFT_v710.mat');

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

    if ~isfile(mat710)
        error('No existe borrador Results v710: %s', mat710);
    end

    S633 = load(mat633);
    S630 = load(mat630);
    S631 = load(mat631);
    S632 = load(mat632);
    S710 = load(mat710);

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

    if ~isfield(S710,'p_intro') || ~isfield(S710,'p_closing')
        error('El MAT v710 no contiene p_intro o p_closing.');
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
    % Párrafos de Discussion
    % ---------------------------------------------------------------------
    p_opening = sprintf([ ...
        'The guarded post-run assessment indicates that the hybrid configuration should ', ...
        'not be interpreted as a faster drying strategy for the selected operating point. ', ...
        'Both valid modes reached the same drying time of %.6g h and nearly identical final ', ...
        'moisture ratios, with a difference of only %.6g in MR. This result is consistent ', ...
        'with the operating logic of the hybrid and gas-LP modes: both trajectories maintain ', ...
        'similar effective drying temperatures, and therefore the drying kinetics remain ', ...
        'practically unchanged.' ], ...
        metrics.hybrid_dry_time_h, ...
        metrics.delta_MR_hybrid_minus_gasLP);

    p_physical_interpretation = sprintf([ ...
        'The physical implication is that the solar contribution in the hybrid mode does ', ...
        'not primarily intensify the drying process; instead, it substitutes part of the ', ...
        'auxiliary fuel required to sustain the same thermal condition. In the gas-LP case, ', ...
        'the target thermal condition is maintained exclusively by auxiliary energy input. ', ...
        'In the hybrid case, part of that thermal load is supplied by solar irradiation, ', ...
        'while the auxiliary system compensates the remaining demand. As a result, the ', ...
        'temperature-driven moisture removal process remains comparable, but the fuel ', ...
        'requirement decreases.' ]);

    p_energy_discussion = sprintf([ ...
        'This interpretation is supported by the auxiliary energy reduction obtained in ', ...
        'the post-run comparison. The hybrid mode reduced the auxiliary energy requirement ', ...
        'from %.6g to %.6g, equivalent to a %.4g%% reduction. Since the final MR and drying ', ...
        'time remained practically unchanged, this reduction represents a true substitution ', ...
        'of auxiliary fuel rather than a change in the drying endpoint or process duration.' ], ...
        metrics.gasLP_Q_aux, ...
        metrics.hybrid_Q_aux, ...
        metrics.reduction_Q_aux_hybrid_vs_gasLP_pct);

    p_cost_discussion = sprintf([ ...
        'The economic response follows the same pattern. The specific drying cost decreased ', ...
        'from %.6g to %.6g USD kg$_{water}^{-1}$, corresponding to a %.4g%% reduction. ', ...
        'This decrease is not explained by producing a less demanding drying result, since ', ...
        'the moisture ratio and drying time remained equivalent. Instead, it is explained ', ...
        'by the lower auxiliary fuel contribution required under hybrid operation.' ], ...
        metrics.gasLP_cost, ...
        metrics.hybrid_cost, ...
        metrics.reduction_cost_hybrid_vs_gasLP_pct);

    p_solar_discussion = sprintf([ ...
        'The pure solar case requires a different interpretation. The guarded evaluation ', ...
        'identified a nonphysical trajectory before the solar simulation reached its reported ', ...
        'termination. The first violation occurred in $%s$ at index %.0f, where the value ', ...
        'reached %.6g under the domain rule `%s`. This indicates that the pure solar branch, ', ...
        'as currently formulated, can enter an invalid psychrometric region. Therefore, the ', ...
        'pure solar case was excluded from comparative performance claims and its penalized ', ...
        'objective values must not be interpreted as physical drying results.' ], ...
        metrics.solar_first_violation_variable, ...
        metrics.solar_first_violation_i, ...
        metrics.solar_first_violation_value, ...
        metrics.solar_first_violation_rule);

    p_scope = sprintf([ ...
        'This exclusion does not invalidate the comparison between gas-LP and hybrid modes. ', ...
        'The gas-LP and hybrid trajectories remained physically valid under the same guard ', ...
        'policy, while the pure solar trajectory did not. The comparison therefore remains ', ...
        'methodologically consistent as long as the interpretation is restricted to the two ', ...
        'valid modes and the solar result is reported only as an invalid trajectory under ', ...
        'the current model formulation.' ]);

    p_limitation = sprintf([ ...
        'A methodological limitation of the present analysis is that the pure solar branch ', ...
        'requires further physical and numerical revision before it can be incorporated into ', ...
        'a full three-mode comparison. In particular, the treatment of psychrometric states ', ...
        'near or above saturation should be reviewed, because the first detected violation ', ...
        'was associated with relative humidity exceeding the valid domain. A corrected solar ', ...
        'branch would need to be revalidated before any statement about pure solar performance ', ...
        'could be supported.' ]);

    p_implication = sprintf([ ...
        'For the selected operating point, the main practical implication is that hybridization ', ...
        'can reduce fuel consumption and specific cost without compromising the drying endpoint. ', ...
        'This is relevant for solar-assisted drying systems in which the operational target ', ...
        'is not necessarily to shorten the process, but to maintain product drying performance ', ...
        'while reducing dependence on auxiliary fuel.' ]);

    p_closing = sprintf([ ...
        'Accordingly, the central finding is not that the hybrid mode improves drying kinetics, ', ...
        'but that it preserves the gas-LP drying outcome with lower auxiliary energy demand. ', ...
        'The hybrid strategy should therefore be evaluated as an energy-substitution and cost-reduction ', ...
        'strategy rather than as a time-reduction strategy for this selected solution.' ]);

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outMd  = fullfile(logsDir,'ARTICLE_DISCUSSION_SECTION_DRAFT_v720.md');
    outTxt = fullfile(logsDir,'ARTICLE_DISCUSSION_SECTION_DRAFT_v720.txt');
    outMat = fullfile(matDir,'ARTICLE_DISCUSSION_SECTION_DRAFT_v720.mat');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# ARTICLE_DISCUSSION_SECTION_DRAFT_v720\n\n');

    fprintf(fid,'## Discussion\n\n');
    fprintf(fid,'%s\n\n', p_opening);
    fprintf(fid,'%s\n\n', p_physical_interpretation);
    fprintf(fid,'%s\n\n', p_energy_discussion);
    fprintf(fid,'%s\n\n', p_cost_discussion);
    fprintf(fid,'%s\n\n', p_solar_discussion);
    fprintf(fid,'%s\n\n', p_scope);
    fprintf(fid,'%s\n\n', p_limitation);
    fprintf(fid,'%s\n\n', p_implication);
    fprintf(fid,'%s\n\n', p_closing);

    fprintf(fid,'## Author control notes\n\n');
    fprintf(fid,'- The discussion must not claim that the hybrid mode accelerates drying.\n');
    fprintf(fid,'- The discussion must frame the hybrid benefit as fuel substitution and cost reduction.\n');
    fprintf(fid,'- The solar mode must remain excluded from comparative claims.\n');
    fprintf(fid,'- The solar penalization must not be presented as a physical cost or physical MR.\n');
    fprintf(fid,'- The limitation should be framed as a model-branch limitation, not as invalidation of gas-LP/hybrid results.\n');
    fprintf(fid,'- Source package: `%s`\n', runDir);

    fclose(fid);

    % ---------------------------------------------------------------------
    % TXT
    % ---------------------------------------------------------------------
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'ARTICLE-DISCUSSION-SECTION-DRAFT-001\n');
    fprintf(fid,'status: ARTICLE_DISCUSSION_SECTION_DRAFT_COMPLETED\n');
    fprintf(fid,'source_finalDiagnosis: %s\n', string(S633.finalDiagnosis));
    fprintf(fid,'runDir: %s\n', runDir);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'--- OPENING ---\n%s\n\n', p_opening);
    fprintf(fid,'--- PHYSICAL INTERPRETATION ---\n%s\n\n', p_physical_interpretation);
    fprintf(fid,'--- ENERGY DISCUSSION ---\n%s\n\n', p_energy_discussion);
    fprintf(fid,'--- COST DISCUSSION ---\n%s\n\n', p_cost_discussion);
    fprintf(fid,'--- SOLAR DISCUSSION ---\n%s\n\n', p_solar_discussion);
    fprintf(fid,'--- SCOPE ---\n%s\n\n', p_scope);
    fprintf(fid,'--- LIMITATION ---\n%s\n\n', p_limitation);
    fprintf(fid,'--- IMPLICATION ---\n%s\n\n', p_implication);
    fprintf(fid,'--- CLOSING ---\n%s\n\n', p_closing);

    fprintf(fid,'OUTPUTS:\n');
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fclose(fid);

    save(outMat, ...
        'p_opening', ...
        'p_physical_interpretation', ...
        'p_energy_discussion', ...
        'p_cost_discussion', ...
        'p_solar_discussion', ...
        'p_scope', ...
        'p_limitation', ...
        'p_implication', ...
        'p_closing', ...
        'metrics','flags','x','T629report','runDir', ...
        'mat633','mat630','mat631','mat632','mat710','outMd','outTxt');

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    discussion = struct();
    discussion.status = 'ARTICLE_DISCUSSION_SECTION_DRAFT_COMPLETED';
    discussion.source_finalDiagnosis = string(S633.finalDiagnosis);
    discussion.runDir = runDir;
    discussion.outMd = outMd;
    discussion.outTxt = outTxt;
    discussion.outMat = outMat;
    discussion.p_opening = p_opening;
    discussion.p_physical_interpretation = p_physical_interpretation;
    discussion.p_energy_discussion = p_energy_discussion;
    discussion.p_cost_discussion = p_cost_discussion;
    discussion.p_solar_discussion = p_solar_discussion;
    discussion.p_scope = p_scope;
    discussion.p_limitation = p_limitation;
    discussion.p_implication = p_implication;
    discussion.p_closing = p_closing;

    disp('=== ARTICLE_DISCUSSION_SECTION_DRAFT_v720 ===')
    disp(discussion.status)
    disp('=== SOURCE FINAL DIAGNOSIS ===')
    disp(discussion.source_finalDiagnosis)
    disp('=== OPENING ===')
    disp(discussion.p_opening)
    disp('=== PHYSICAL INTERPRETATION ===')
    disp(discussion.p_physical_interpretation)
    disp('=== ENERGY DISCUSSION ===')
    disp(discussion.p_energy_discussion)
    disp('=== COST DISCUSSION ===')
    disp(discussion.p_cost_discussion)
    disp('=== SOLAR DISCUSSION ===')
    disp(discussion.p_solar_discussion)
    disp('=== SCOPE ===')
    disp(discussion.p_scope)
    disp('=== LIMITATION ===')
    disp(discussion.p_limitation)
    disp('=== IMPLICATION ===')
    disp(discussion.p_implication)
    disp('=== CLOSING ===')
    disp(discussion.p_closing)
    disp('=== OUTPUT FILES ===')
    disp(discussion.outMd)
    disp(discussion.outTxt)
    disp(discussion.outMat)
end