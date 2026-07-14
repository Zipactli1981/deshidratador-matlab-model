function design = solar_branch_physical_guard_design_v627()
% SOLAR_BRANCH_PHYSICAL_GUARD_DESIGN_v627
% Micropaso 6.27 — SOLAR-BRANCH-PHYSICAL-GUARD-DESIGN-001
%
% Objetivo:
%   Diseñar formalmente la política de guardas físicas para el modo solar,
%   sin modificar todavía el wrapper productivo.
%
% Entrada esperada:
%   Resultados de Micropaso 6.26:
%       SOLAR_NONPHYSICAL_STATE_GUARD_v626_main.csv
%       SOLAR_NONPHYSICAL_STATE_GUARD_v626_violations.csv
%
% Salidas:
%   1) CSV con reglas de guarda:
%       SOLAR_BRANCH_PHYSICAL_GUARD_DESIGN_v627_rules.csv
%
%   2) Dictamen de diseño:
%       SOLAR_BRANCH_PHYSICAL_GUARD_DESIGN_v627.md
%
%   3) MAT consolidado:
%       SOLAR_BRANCH_PHYSICAL_GUARD_DESIGN_v627.mat
%
% No corrige el wrapper.
% No repite el AG.
% No modifica v10, v611 ni v614.
%
% Uso:
%   design = solar_branch_physical_guard_design_v627();

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

    main626 = fullfile(tablesDir,'SOLAR_NONPHYSICAL_STATE_GUARD_v626_main.csv');
    viol626 = fullfile(tablesDir,'SOLAR_NONPHYSICAL_STATE_GUARD_v626_violations.csv');

    if ~isfile(main626)
        error('No existe archivo principal de v626: %s', main626);
    end

    if ~isfile(viol626)
        error('No existe archivo de violaciones de v626: %s', viol626);
    end

    Tmain = readtable(main626);
    Tviol = readtable(viol626);

    % ---------------------------------------------------------------------
    % Extraer estado por modo
    % ---------------------------------------------------------------------
    gasRow = strcmp(string(Tmain.mode),"gasLP");
    hybRow = strcmp(string(Tmain.mode),"hybrid");
    solRow = strcmp(string(Tmain.mode),"solar");

    if ~any(gasRow) || ~any(hybRow) || ~any(solRow)
        error('Tmain no contiene las tres filas esperadas: gasLP, hybrid, solar.');
    end

    solar_has_violation = Tmain.num_violations(solRow) > 0;
    gas_has_violation   = Tmain.num_violations(gasRow) > 0;
    hybrid_has_violation = Tmain.num_violations(hybRow) > 0;

    solar_first_i = Tmain.first_violation_i(solRow);
    solar_break_i = Tmain.break_i(solRow);

    solar_first_var = string(Tmain.first_violation_variable(solRow));
    solar_first_rule = string(Tmain.first_violation_rule(solRow));
    solar_first_value = Tmain.first_violation_value_real(solRow);

    solar_Qaux_zero = Tmain.Q_aux_tot(solRow) == 0;
    hybrid_Qaux_positive = Tmain.Q_aux_tot(hybRow) > 0;
    same_irradiance = abs(Tmain.Irradiacion(hybRow) - Tmain.Irradiacion(solRow)) < 1e-6;

    solar_MR_lower_than_hybrid = Tmain.MR(solRow) < Tmain.MR(hybRow);

    % ---------------------------------------------------------------------
    % Tabla de reglas de guarda física
    % ---------------------------------------------------------------------
    rule = {};
    variable_group = {};
    condition = {};
    threshold = {};
    action = {};
    severity = {};
    applies_to = {};
    rationale = {};

    % Regla 1: NaN/Inf
    rule{end+1,1} = 'G01_NAN_INF';
    variable_group{end+1,1} = 'all_state_variables';
    condition{end+1,1} = 'isnan(x) || isinf(x)';
    threshold{end+1,1} = 'none';
    action{end+1,1} = 'mark trajectory invalid; return penalty; save diagnostic';
    severity{end+1,1} = 'critical';
    applies_to{end+1,1} = 'all modes';
    rationale{end+1,1} = 'A NaN or Inf state invalidates thermodynamic and optimization outputs.';

    % Regla 2: complejos
    rule{end+1,1} = 'G02_COMPLEX_STATE';
    variable_group{end+1,1} = 'all_numeric_state_variables';
    condition{end+1,1} = 'abs(imag(x)) > 1e-9';
    threshold{end+1,1} = 'imaginary tolerance = 1e-9';
    action{end+1,1} = 'mark trajectory invalid; return penalty; save diagnostic';
    severity{end+1,1} = 'critical';
    applies_to{end+1,1} = 'all modes';
    rationale{end+1,1} = 'Complex values indicate numerical excursion outside the real physical domain.';

    % Regla 3: temperaturas
    rule{end+1,1} = 'G03_TEMPERATURE_RANGE';
    variable_group{end+1,1} = 'T_HE1_in, T_HE1_out, T_DH_in, T_DH_out, T_prod, T_air, T_amb';
    condition{end+1,1} = 'T < -10 || T > 120';
    threshold{end+1,1} = '-10 <= T <= 120 degC';
    action{end+1,1} = 'mark trajectory invalid; return penalty; save diagnostic';
    severity{end+1,1} = 'critical';
    applies_to{end+1,1} = 'all modes';
    rationale{end+1,1} = 'The v626 solar trace reached nonphysical negative temperatures; this must invalidate the result.';

    % Regla 4: humedad relativa
    rule{end+1,1} = 'G04_RELATIVE_HUMIDITY_DOMAIN';
    variable_group{end+1,1} = 'HR_DH_in, HR_DH_out, HR_amb';
    condition{end+1,1} = 'HR < 0 || HR > 1';
    threshold{end+1,1} = '0 <= HR <= 1';
    action{end+1,1} = 'mark trajectory invalid; return penalty; save diagnostic';
    severity{end+1,1} = 'critical';
    applies_to{end+1,1} = 'all modes';
    rationale{end+1,1} = 'Solar first failed by HR_DH_in > 1 before the final break; saturated or supersaturated states cannot be accepted silently.';

    % Regla 5: razón de humedad
    rule{end+1,1} = 'G05_HUMIDITY_RATIO_NONNEGATIVE';
    variable_group{end+1,1} = 'w_DH_in, w_DH_out';
    condition{end+1,1} = 'w < 0';
    threshold{end+1,1} = 'w >= 0';
    action{end+1,1} = 'mark trajectory invalid; return penalty; save diagnostic';
    severity{end+1,1} = 'critical';
    applies_to{end+1,1} = 'all modes';
    rationale{end+1,1} = 'Negative humidity ratio is physically impossible.';

    % Regla 6: humedad de producto
    rule{end+1,1} = 'G06_PRODUCT_MOISTURE_LOWER_BOUND';
    variable_group{end+1,1} = 'M_prod';
    condition{end+1,1} = 'M_prod < Mf - 1e-8';
    threshold{end+1,1} = 'M_prod >= Mf - 1e-8';
    action{end+1,1} = 'mark trajectory invalid; return penalty; save diagnostic';
    severity{end+1,1} = 'critical';
    applies_to{end+1,1} = 'all modes';
    rationale{end+1,1} = 'The product moisture content cannot be allowed to fall below the equilibrium/final lower bound used for MR.';

    % Regla 7: MR
    rule{end+1,1} = 'G07_MR_DOMAIN';
    variable_group{end+1,1} = 'MR';
    condition{end+1,1} = 'MR < 0 || MR > 1';
    threshold{end+1,1} = '0 <= MR <= 1';
    action{end+1,1} = 'mark trajectory invalid; return penalty; save diagnostic';
    severity{end+1,1} = 'critical';
    applies_to{end+1,1} = 'all modes';
    rationale{end+1,1} = 'Moisture ratio outside [0,1] is outside the normalized drying domain.';

    % Regla 8: dominancia física solar/híbrida
    rule{end+1,1} = 'G08_SOLAR_HYBRID_DOMINANCE_CHECK';
    variable_group{end+1,1} = 'Q_aux_tot, Irradiacion, MR';
    condition{end+1,1} = 'same irradiance AND hybrid Q_aux > 0 AND solar Q_aux = 0 AND solar MR < hybrid MR';
    threshold{end+1,1} = 'dominance consistency';
    action{end+1,1} = 'flag comparison invalid; require trace audit before reporting';
    severity{end+1,1} = 'major';
    applies_to{end+1,1} = 'mode comparison only';
    rationale{end+1,1} = 'Solar without auxiliary should not dominate hybrid when irradiance is identical and hybrid adds positive auxiliary heat.';

    % Regla 9: política de salida
    rule{end+1,1} = 'G09_INVALID_TRAJECTORY_OBJECTIVE_POLICY';
    variable_group{end+1,1} = 'objective outputs';
    condition{end+1,1} = 'any critical guard fails';
    threshold{end+1,1} = 'critical guard count > 0';
    action{end+1,1} = 'return MR penalty = 1000 and cost penalty = 1e6; status = NONPHYSICAL_TRAJECTORY';
    severity{end+1,1} = 'critical';
    applies_to{end+1,1} = 'optimization and postrun evaluation';
    rationale{end+1,1} = 'The optimizer and postrun reports must not select or compare nonphysical trajectories.';

    % Regla 10: política documental
    rule{end+1,1} = 'G10_REPORTING_POLICY';
    variable_group{end+1,1} = 'tables, figures, conclusions';
    condition{end+1,1} = 'mode has nonphysical trajectory';
    threshold{end+1,1} = 'invalid trajectory flag';
    action{end+1,1} = 'exclude from performance claims or report explicitly as invalid/nonviable';
    severity{end+1,1} = 'major';
    applies_to{end+1,1} = 'thesis/article reporting';
    rationale{end+1,1} = 'A mode with invalid thermodynamic states cannot support performance conclusions.';

    Trules = table( ...
        string(rule), ...
        string(variable_group), ...
        string(condition), ...
        string(threshold), ...
        string(action), ...
        string(severity), ...
        string(applies_to), ...
        string(rationale), ...
        'VariableNames', { ...
            'rule', ...
            'variable_group', ...
            'condition', ...
            'threshold', ...
            'action', ...
            'severity', ...
            'applies_to', ...
            'rationale'});

    % ---------------------------------------------------------------------
    % Dictamen
    % ---------------------------------------------------------------------
    flags = struct();
    flags.solar_has_violation = solar_has_violation;
    flags.gas_has_violation = gas_has_violation;
    flags.hybrid_has_violation = hybrid_has_violation;
    flags.solar_first_violation_before_break = solar_first_i < solar_break_i;
    flags.solar_Qaux_zero = solar_Qaux_zero;
    flags.hybrid_Qaux_positive = hybrid_Qaux_positive;
    flags.same_irradiance_hybrid_solar = same_irradiance;
    flags.solar_MR_lower_than_hybrid = solar_MR_lower_than_hybrid;

    flags.route_A_exclusion_required_now = solar_has_violation;
    flags.route_B_guard_implementation_required = solar_has_violation;
    flags.allow_solar_performance_claims = ~solar_has_violation;
    flags.allow_hybrid_gasLP_comparison = ~hybrid_has_violation && ~gas_has_violation;

    if solar_has_violation && ~hybrid_has_violation && ~gas_has_violation
        diagnosis = "DESIGN_APPROVED_SOLAR_GUARDS_REQUIRED_HYBRID_GASLP_RETAINED";
    elseif solar_has_violation
        diagnosis = "DESIGN_APPROVED_SOLAR_GUARDS_REQUIRED_REVIEW_OTHER_MODES";
    else
        diagnosis = "NO_SOLAR_GUARD_TRIGGER_FROM_V626";
    end

    recommendation = struct();
    recommendation.route_A = "Exclude pure solar mode from performance conclusions until its branch is corrected and revalidated.";
    recommendation.route_B = "Implement physical-domain guards in wrapper/objective so nonphysical trajectories return penalty and diagnostic status.";
    recommendation.preferred_policy = "Use Route B in code; use Route A in thesis/article reporting until a corrected solar branch is validated.";
    recommendation.no_GA_rerun_yet = true;
    recommendation.next_micropaso = "6.28 — IMPLEMENT-NONPHYSICAL-PENALTY-WRAPPER-001";

    % ---------------------------------------------------------------------
    % Guardar salidas
    % ---------------------------------------------------------------------
    outRules = fullfile(tablesDir,'SOLAR_BRANCH_PHYSICAL_GUARD_DESIGN_v627_rules.csv');
    outMd    = fullfile(logsDir,'SOLAR_BRANCH_PHYSICAL_GUARD_DESIGN_v627.md');
    outMat   = fullfile(matDir,'SOLAR_BRANCH_PHYSICAL_GUARD_DESIGN_v627.mat');
    outLog   = fullfile(logsDir,'SOLAR_BRANCH_PHYSICAL_GUARD_DESIGN_v627.txt');

    writetable(Trules,outRules);

    save(outMat, ...
        'Tmain','Tviol','Trules','flags','diagnosis','recommendation', ...
        'runDir','main626','viol626','outRules','outMd','outLog');

    % Markdown
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# Micropaso 6.27 — SOLAR-BRANCH-PHYSICAL-GUARD-DESIGN-001\n\n');
    fprintf(fid,'## Estatus\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);

    fprintf(fid,'## Evidencia base\n\n');
    fprintf(fid,'La auditoría 6.26 detectó violaciones físicas exclusivamente en el modo solar.\n\n');
    fprintf(fid,'- gasLP: violaciones = %d\n', Tmain.num_violations(gasRow));
    fprintf(fid,'- hybrid: violaciones = %d\n', Tmain.num_violations(hybRow));
    fprintf(fid,'- solar: violaciones = %d\n\n', Tmain.num_violations(solRow));

    fprintf(fid,'Primera violación solar:\n\n');
    fprintf(fid,'- índice: %.0f\n', solar_first_i);
    fprintf(fid,'- variable: `%s`\n', solar_first_var);
    fprintf(fid,'- regla: `%s`\n', solar_first_rule);
    fprintf(fid,'- valor: %.12g\n', solar_first_value);
    fprintf(fid,'- índice de término solar: %.0f\n\n', solar_break_i);

    fprintf(fid,'## Dictamen técnico\n\n');
    fprintf(fid,'El modo solar puro debe bloquearse como resultado comparativo defendible mientras no exista una corrección y revalidación de su rama física.\n\n');
    fprintf(fid,'La comparación gasLP/hybrid se conserva operativamente defendible para esta solución, porque ambos modos no presentaron violaciones de dominio físico en 6.26.\n\n');

    fprintf(fid,'## Política de implementación\n\n');
    fprintf(fid,'Se recomienda implementar guardas de dominio físico con penalización explícita:\n\n');
    fprintf(fid,'- `MR_penalty = 1000`\n');
    fprintf(fid,'- `cost_penalty = 1e6`\n');
    fprintf(fid,'- `status = NONPHYSICAL_TRAJECTORY`\n');
    fprintf(fid,'- guardar variable, índice y regla que detonó la invalidez\n\n');

    fprintf(fid,'## Política de reporte\n\n');
    fprintf(fid,'Hasta que el modo solar sea corregido y revalidado:\n\n');
    fprintf(fid,'- No reportar solar como superior a híbrido o gasLP.\n');
    fprintf(fid,'- No usar solar para conclusiones de desempeño.\n');
    fprintf(fid,'- Si se menciona, reportarlo como rama no válida/no viable bajo la formulación actual.\n');
    fprintf(fid,'- Mantener gasLP e híbrido como comparaciones principales.\n\n');

    fprintf(fid,'## Reglas diseñadas\n\n');
    for r = 1:height(Trules)
        fprintf(fid,'### %s\n\n', Trules.rule(r));
        fprintf(fid,'- Grupo: `%s`\n', Trules.variable_group(r));
        fprintf(fid,'- Condición: `%s`\n', Trules.condition(r));
        fprintf(fid,'- Umbral: `%s`\n', Trules.threshold(r));
        fprintf(fid,'- Acción: `%s`\n', Trules.action(r));
        fprintf(fid,'- Severidad: `%s`\n', Trules.severity(r));
        fprintf(fid,'- Aplica a: `%s`\n', Trules.applies_to(r));
        fprintf(fid,'- Justificación: %s\n\n', Trules.rationale(r));
    end

    fprintf(fid,'## Siguiente micropaso\n\n');
    fprintf(fid,'`%s`\n\n', recommendation.next_micropaso);
    fclose(fid);

    % TXT resumen
    fid = fopen(outLog,'w');
    fprintf(fid,'SOLAR-BRANCH-PHYSICAL-GUARD-DESIGN-001\n');
    fprintf(fid,'status: SOLAR_BRANCH_PHYSICAL_GUARD_DESIGN_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'runDir: %s\n', runDir);
    fprintf(fid,'main626: %s\n', main626);
    fprintf(fid,'viol626: %s\n', viol626);
    fprintf(fid,'outRules: %s\n', outRules);
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'solar_has_violation: %d\n', flags.solar_has_violation);
    fprintf(fid,'gas_has_violation: %d\n', flags.gas_has_violation);
    fprintf(fid,'hybrid_has_violation: %d\n', flags.hybrid_has_violation);
    fprintf(fid,'solar_first_violation_before_break: %d\n', flags.solar_first_violation_before_break);
    fprintf(fid,'allow_solar_performance_claims: %d\n', flags.allow_solar_performance_claims);
    fprintf(fid,'allow_hybrid_gasLP_comparison: %d\n', flags.allow_hybrid_gasLP_comparison);
    fprintf(fid,'next_micropaso: %s\n', recommendation.next_micropaso);
    fclose(fid);

    % Salida
    design = struct();
    design.status = 'SOLAR_BRANCH_PHYSICAL_GUARD_DESIGN_COMPLETED';
    design.diagnosis = diagnosis;
    design.flags = flags;
    design.recommendation = recommendation;
    design.Tmain = Tmain;
    design.Tviol = Tviol;
    design.Trules = Trules;
    design.runDir = runDir;
    design.outRules = outRules;
    design.outMd = outMd;
    design.outMat = outMat;
    design.outLog = outLog;

    disp('=== SOLAR_BRANCH_PHYSICAL_GUARD_DESIGN_v627 ===')
    disp(design.status)
    disp('=== DIAGNOSIS ===')
    disp(design.diagnosis)
    disp('=== FLAGS ===')
    disp(design.flags)
    disp('=== RECOMMENDATION ===')
    disp(design.recommendation)
    disp('=== GUARD RULES ===')
    disp(design.Trules)
    disp('=== OUTPUT FILES ===')
    disp(design.outRules)
    disp(design.outMd)
    disp(design.outMat)
    disp(design.outLog)
end