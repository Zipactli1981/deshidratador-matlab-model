function design = design_guarded_formal_run_v92g()
% DESIGN_GUARDED_FORMAL_RUN_v92g
% 9.2g — GUARDED-FORMAL-RUN-DESIGN-001
%
% Objetivo:
%   Diseñar la corrida formal guardada antes de ejecutarla.
%
% Este micropaso:
%   - No ejecuta gamultiobj.
%   - No modifica el modelo.
%   - No modifica v10 ni v611.
%   - No sobrescribe la corrida productiva v614.
%   - Usa evidencia de 9.1g para estimar tiempo y definir alcance.
%
% Incorpora dos pendientes metodológicos explícitos:
%   A) Revisión posterior de la física de operación del modelo.
%   B) Incorporación formal de estimación de CO2.
%
% Salidas:
%   logs/GUARDED_FORMAL_RUN_DESIGN_v92g.md
%   logs/GUARDED_FORMAL_RUN_DESIGN_v92g.txt
%   tables/GUARDED_FORMAL_RUN_DESIGN_v92g_options.csv
%   tables/GUARDED_FORMAL_RUN_DESIGN_v92g_time_estimates.csv
%   tables/GUARDED_FORMAL_RUN_DESIGN_v92g_pending_methodology.csv
%   mat/GUARDED_FORMAL_RUN_DESIGN_v92g.mat
%
% Uso:
%   design = design_guarded_formal_run_v92g();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Localizar corrida de humo guardada más reciente
    % ---------------------------------------------------------------------
    smokeBaseDir = fullfile(rootDir,'05_runs','guarded_smoke_v91g');

    if ~isfolder(smokeBaseDir)
        error('No existe smokeBaseDir: %s', smokeBaseDir);
    end

    d = dir(smokeBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'GUARDED_SMOKE_GA_v91g_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró corrida de humo GUARDED_SMOKE_GA_v91g_* en %s', smokeBaseDir);
    end

    [~,idxSmoke] = max([d.datenum]);
    smokeRunDir = fullfile(smokeBaseDir,d(idxSmoke).name);
    smokeMat = fullfile(smokeRunDir,'mat','GUARDED_SMOKE_GA_v91g.mat');

    if ~isfile(smokeMat)
        error('No existe MAT de corrida de humo: %s', smokeMat);
    end

    Ssmoke = load(smokeMat);

    if ~isfield(Ssmoke,'diagnosis')
        error('El MAT de humo no contiene diagnosis.');
    end

    if ~strcmp(string(Ssmoke.diagnosis),"GUARDED_SMOKE_GA_PASS")
        error('La corrida de humo no está en PASS. Diagnosis: %s', string(Ssmoke.diagnosis));
    end

    if ~isfield(Ssmoke,'Tga') || ~isfield(Ssmoke,'smokeConfig')
        error('El MAT de humo no contiene Tga o smokeConfig.');
    end

    Tga = Ssmoke.Tga;
    smokeConfig = Ssmoke.smokeConfig;

    % ---------------------------------------------------------------------
    % Localizar paquete postrun cerrado
    % ---------------------------------------------------------------------
    postrunBaseDir = fullfile(rootDir,'05_runs','productive_v614b');

    if ~isfolder(postrunBaseDir)
        error('No existe postrunBaseDir: %s', postrunBaseDir);
    end

    d2 = dir(postrunBaseDir);
    d2 = d2([d2.isdir]);
    d2 = d2(~ismember({d2.name},{'.','..','.MATLABDriveTag'}));

    keep2 = false(size(d2));
    for i = 1:numel(d2)
        keep2(i) = startsWith(d2(i).name,'PRODUCTIVE_GA_CORRECTED_v614_');
    end
    d2 = d2(keep2);

    if isempty(d2)
        error('No se encontró corrida productiva v614 en %s', postrunBaseDir);
    end

    [~,idxPost] = max([d2.datenum]);
    postrunDir = fullfile(postrunBaseDir,d2(idxPost).name);

    mat630 = fullfile(postrunDir,'mat','GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630c.mat');
    mat633 = fullfile(postrunDir,'mat','FINAL_POSTRUN_PACKAGE_INDEX_v633.mat');
    mat634 = fullfile(postrunDir,'mat','MASTER_PLAN_REALIGNMENT_AUDIT_v634.mat');

    if ~isfile(mat630)
        error('No existe v630c: %s', mat630);
    end

    if ~isfile(mat633)
        error('No existe v633: %s', mat633);
    end

    if ~isfile(mat634)
        error('No existe v634: %s', mat634);
    end

    S630 = load(mat630);
    S633 = load(mat633);
    S634 = load(mat634);

    if ~strcmp(string(S633.finalDiagnosis),"FINAL_POSTRUN_PACKAGE_INDEX_PASS")
        error('El paquete postrun final no está en PASS.');
    end

    if ~strcmp(string(S634.diagnosis),"MASTER_PLAN_REALIGNMENT_PASS")
        error('El realineamiento con plan maestro no está en PASS.');
    end

    metrics = S630.metrics;
    flags = S630.flags;

    % ---------------------------------------------------------------------
    % Carpeta de diseño formal
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    designBaseDir = fullfile(rootDir,'05_runs','guarded_formal_design_v92g');
    designDir = fullfile(designBaseDir,['GUARDED_FORMAL_RUN_DESIGN_v92g_' timestamp]);

    logsDir   = fullfile(designDir,'logs');
    tablesDir = fullfile(designDir,'tables');
    matDir    = fullfile(designDir,'mat');

    if ~isfolder(designBaseDir), mkdir(designBaseDir); end
    if ~isfolder(designDir), mkdir(designDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Velocidad observada en smoke
    % ---------------------------------------------------------------------
    gasRow = Tga(strcmp(string(Tga.mode),"gasLP"),:);
    hybRow = Tga(strcmp(string(Tga.mode),"hybrid"),:);

    if isempty(gasRow) || isempty(hybRow)
        error('Tga no contiene filas gasLP e hybrid.');
    end

    gas_eval_count_smoke = smokeConfig.PopulationSize * smokeConfig.MaxGenerations;
    hyb_eval_count_smoke = smokeConfig.PopulationSize * smokeConfig.MaxGenerations;

    % Nota: en gamultiobj el conteo mostrado fue 16 para 8x2.
    % Se usa ese criterio para estimación práctica.
    gas_seconds_per_eval = gasRow.runtime_seconds(1) / gas_eval_count_smoke;
    hyb_seconds_per_eval = hybRow.runtime_seconds(1) / hyb_eval_count_smoke;

    avg_seconds_per_eval = mean([gas_seconds_per_eval, hyb_seconds_per_eval],'omitnan');

    % ---------------------------------------------------------------------
    % Opciones de corrida formal propuestas
    % ---------------------------------------------------------------------
    % Se proponen tres escenarios. Ninguno se ejecuta aquí.
    scenarios = {};

    row = struct();
    row.scenario = "F1_MINIMAL_DEFENSIBLE";
    row.description = "Formal pequeña para obtener frente guardado preliminar defendible, con costo computacional moderado.";
    row.modes = "hybrid_only_plus_postrun_gasLP_reference";
    row.PopulationSize = 20;
    row.MaxGenerations = 40;
    row.estimated_evaluations_per_mode = row.PopulationSize * row.MaxGenerations;
    row.include_gasLP_GA = false;
    row.include_hybrid_GA = true;
    row.include_solar_GA = false;
    row.recommended = true;
    row.risk = "medium";
    row.use_for_article = "possible_if_convergence_and_guards_pass";
    scenarios{end+1,1} = row;

    row = struct();
    row.scenario = "F2_BALANCED";
    row.description = "Formal balanceada para frente híbrido más estable; mayor costo computacional.";
    row.modes = "hybrid_only_plus_postrun_gasLP_reference";
    row.PopulationSize = 30;
    row.MaxGenerations = 80;
    row.estimated_evaluations_per_mode = row.PopulationSize * row.MaxGenerations;
    row.include_gasLP_GA = false;
    row.include_hybrid_GA = true;
    row.include_solar_GA = false;
    row.recommended = false;
    row.risk = "medium_high";
    row.use_for_article = "stronger_if_runtime_available";
    scenarios{end+1,1} = row;

    row = struct();
    row.scenario = "F3_FULL_COMPARATIVE";
    row.description = "Corrida formal separada para gasLP e hybrid; robusta pero computacionalmente costosa.";
    row.modes = "gasLP_and_hybrid";
    row.PopulationSize = 30;
    row.MaxGenerations = 80;
    row.estimated_evaluations_per_mode = row.PopulationSize * row.MaxGenerations;
    row.include_gasLP_GA = true;
    row.include_hybrid_GA = true;
    row.include_solar_GA = false;
    row.recommended = false;
    row.risk = "high_runtime";
    row.use_for_article = "strongest_but_costly";
    scenarios{end+1,1} = row;

    Tscenarios = struct2table(vertcat(scenarios{:}));

    % ---------------------------------------------------------------------
    % Estimación de tiempos
    % ---------------------------------------------------------------------
    timeRows = {};

    for i = 1:height(Tscenarios)
        row = struct();
        row.scenario = Tscenarios.scenario(i);
        row.modes = Tscenarios.modes(i);
        row.PopulationSize = Tscenarios.PopulationSize(i);
        row.MaxGenerations = Tscenarios.MaxGenerations(i);
        row.evaluations_per_mode = Tscenarios.estimated_evaluations_per_mode(i);

        nModes = double(Tscenarios.include_gasLP_GA(i)) + double(Tscenarios.include_hybrid_GA(i)) + double(Tscenarios.include_solar_GA(i));
        row.number_of_GA_modes = nModes;

        row.seconds_per_eval_reference = avg_seconds_per_eval;
        row.estimated_seconds_total = row.evaluations_per_mode * nModes * avg_seconds_per_eval;
        row.estimated_hours_total = row.estimated_seconds_total / 3600;

        % Margen conservador por overhead, variación de ODE, escritura e individuos difíciles.
        row.estimated_hours_with_30pct_margin = row.estimated_hours_total * 1.30;

        timeRows{end+1,1} = row; %#ok<AGROW>
    end

    Ttime = struct2table(vertcat(timeRows{:}));

    % ---------------------------------------------------------------------
    % Diseño recomendado
    % ---------------------------------------------------------------------
    recommendedScenario = Tscenarios(Tscenarios.recommended == true,:);
    recommendedTime = Ttime(strcmp(string(Ttime.scenario), string(recommendedScenario.scenario(1))),:);

    formalDesign = struct();

    formalDesign.scenario = string(recommendedScenario.scenario(1));
    formalDesign.modes = string(recommendedScenario.modes(1));
    formalDesign.PopulationSize = recommendedScenario.PopulationSize(1);
    formalDesign.MaxGenerations = recommendedScenario.MaxGenerations(1);
    formalDesign.estimated_evaluations_per_mode = recommendedScenario.estimated_evaluations_per_mode(1);
    formalDesign.estimated_hours_with_30pct_margin = recommendedTime.estimated_hours_with_30pct_margin(1);

    formalDesign.objective = "objective_productive_corrected_v628b_nonphysical_penalty";
    formalDesign.primary_mode_to_optimize = "hybrid";
    formalDesign.reference_mode = "gasLP";
    formalDesign.excluded_mode = "solar";
    formalDesign.reason_solar_excluded = "Pure solar branch enters nonphysical psychrometric domain under current formulation.";

    formalDesign.rng = "rng(1,'twister')";
    formalDesign.UseParallel = false;
    formalDesign.ParetoFraction = 0.35;
    formalDesign.FunctionTolerance = 1e-4;
    formalDesign.ConstraintTolerance = 1e-6;
    formalDesign.CrossoverFcn = "default_or_current_gamultiobj";
    formalDesign.MutationFcn = "default_or_current_gamultiobj";

    formalDesign.bounds_source = "Use same defended bounded region as guarded smoke unless explicitly widened in next micropaso.";
    formalDesign.not_execute_now = true;

    % ---------------------------------------------------------------------
    % Criterios de aceptación
    % ---------------------------------------------------------------------
    acceptRows = {};

    row = struct();
    row.criterion = "A01_smoke_precondition";
    row.required_state = "GUARDED_SMOKE_GA_PASS";
    row.rationale = "Formal run must only proceed after successful guarded smoke run.";
    acceptRows{end+1,1} = row;

    row = struct();
    row.criterion = "A02_guarded_objective";
    row.required_state = "objective_productive_corrected_v628b_nonphysical_penalty active";
    row.rationale = "All evaluated trajectories must pass physical feasibility or receive penalty.";
    acceptRows{end+1,1} = row;

    row = struct();
    row.criterion = "A03_outputs";
    row.required_state = "population, scores, history, output, runtime, diary, config saved";
    row.rationale = "Reproducibility and traceability are mandatory.";
    acceptRows{end+1,1} = row;

    row = struct();
    row.criterion = "A04_hybrid_physical_validity";
    row.required_state = "selected or reported hybrid solutions must be non-penalized";
    row.rationale = "No physical claim from penalized trajectory.";
    acceptRows{end+1,1} = row;

    row = struct();
    row.criterion = "A05_hybrid_irradiation";
    row.required_state = "Irradiacion > 0 for reported hybrid solution";
    row.rationale = "Hybrid solution must actually use solar input.";
    acceptRows{end+1,1} = row;

    row = struct();
    row.criterion = "A06_no_solar_claim";
    row.required_state = "solar remains excluded unless branch is physically corrected and revalidated";
    row.rationale = "Current solar branch produced nonphysical trajectory.";
    acceptRows{end+1,1} = row;

    row = struct();
    row.criterion = "A07_article_scope";
    row.required_state = "Article claims limited to guarded formal run scope";
    row.rationale = "Avoid overclaiming from selected postrun solution.";
    acceptRows{end+1,1} = row;

    row = struct();
    row.criterion = "A08_CO2_pending";
    row.required_state = "CO2 not claimed as optimized objective until formal CO2 estimation is incorporated";
    row.rationale = "Current guarded objective is MR-cost; CO2 must be integrated explicitly.";
    acceptRows{end+1,1} = row;

    Taccept = struct2table(vertcat(acceptRows{:}));

    % ---------------------------------------------------------------------
    % Pendientes metodológicos obligatorios
    % ---------------------------------------------------------------------
    pendingRows = {};

    row = struct();
    row.id = "M01_physics_operation_review";
    row.item = "Review physical operation of the model";
    row.status = "pending_future_micropaso";
    row.scope = "Review thermal/psychrometric operating logic, recirculation, auxiliary control, saturation handling, drying endpoint, and physical dominance relationships.";
    row.when_to_do = "After guarded formal run design, before final manuscript claims; deeper correction before reintroducing pure solar mode.";
    row.affects_current_run = "not_blocking_hybrid_guarded_formal_run";
    row.affects_article = "must_be_listed_as limitation or future validation if not completed";
    pendingRows{end+1,1} = row;

    row = struct();
    row.id = "M02_CO2_estimation";
    row.item = "Incorporate CO2 estimation";
    row.status = "pending_future_micropaso";
    row.scope = "Define CO2 factors for gas-LP and electricity, compute batch and specific emissions, and decide whether CO2 becomes third objective or postprocess metric.";
    row.when_to_do = "Before claiming CO2 reduction or presenting 3-objective optimization.";
    row.affects_current_run = "blocks_CO2_claims_but_not_MR_cost_guarded_run";
    row.affects_article = "CO2 must remain absent or explicitly pending unless incorporated and validated.";
    pendingRows{end+1,1} = row;

    row = struct();
    row.id = "M03_solar_branch_revalidation";
    row.item = "Correct and revalidate pure solar branch";
    row.status = "pending_future_micropaso";
    row.scope = "Review supersaturation, condensation or saturation bounds, event handling, and trajectory guards.";
    row.when_to_do = "Before any pure solar performance comparison.";
    row.affects_current_run = "solar_excluded";
    row.affects_article = "no pure solar comparative claims.";
    pendingRows{end+1,1} = row;

    Tpending = struct2table(vertcat(pendingRows{:}));

    % ---------------------------------------------------------------------
    % Riesgos
    % ---------------------------------------------------------------------
    riskRows = {};

    row = struct();
    row.risk = "runtime_cost";
    row.level = "high";
    row.description = "Smoke run indicates approximately 16.5 s per objective evaluation.";
    row.mitigation = "Use staged formal strategy; start with F1 instead of full comparative F3.";
    riskRows{end+1,1} = row;

    row = struct();
    row.risk = "overclaiming";
    row.level = "high";
    row.description = "Article drafts 7.1-7.3 were conditional and must not be used as final claims.";
    row.mitigation = "Keep manuscript frozen until formal guarded evidence exists.";
    riskRows{end+1,1} = row;

    row = struct();
    row.risk = "CO2_missing";
    row.level = "medium_high";
    row.description = "Current formal guarded design is MR-cost, not MR-cost-CO2.";
    row.mitigation = "Add CO2 estimation in a separate micropaso before CO2 claims.";
    riskRows{end+1,1} = row;

    row = struct();
    row.risk = "physics_branch_uncertainty";
    row.level = "medium_high";
    row.description = "Pure solar branch generated nonphysical psychrometric state.";
    row.mitigation = "Exclude solar and schedule physics operation review.";
    riskRows{end+1,1} = row;

    Trisks = struct2table(vertcat(riskRows{:}));

    % ---------------------------------------------------------------------
    % Diagnóstico del diseño
    % ---------------------------------------------------------------------
    designFlags = struct();
    designFlags.smoke_pass = strcmp(string(Ssmoke.diagnosis),"GUARDED_SMOKE_GA_PASS");
    designFlags.master_realign_pass = strcmp(string(S634.diagnosis),"MASTER_PLAN_REALIGNMENT_PASS");
    designFlags.postrun_package_pass = strcmp(string(S633.finalDiagnosis),"FINAL_POSTRUN_PACKAGE_INDEX_PASS");
    designFlags.hybrid_gasLP_postrun_valid = flags.hybrid_gasLP_comparison_allowed;
    designFlags.solar_excluded = flags.solar_invalid_final;
    designFlags.formal_run_not_executed_here = true;
    designFlags.CO2_claims_blocked_until_estimation = true;
    designFlags.physics_review_recorded = true;
    designFlags.recommended_scenario_defined = true;

    if designFlags.smoke_pass && ...
       designFlags.master_realign_pass && ...
       designFlags.postrun_package_pass && ...
       designFlags.recommended_scenario_defined && ...
       designFlags.CO2_claims_blocked_until_estimation && ...
       designFlags.physics_review_recorded

        diagnosis = "GUARDED_FORMAL_RUN_DESIGN_PASS";
    else
        diagnosis = "GUARDED_FORMAL_RUN_DESIGN_REQUIRES_REVIEW";
    end

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'GUARDED_FORMAL_RUN_DESIGN_v92g.md');
    outTxt = fullfile(logsDir,'GUARDED_FORMAL_RUN_DESIGN_v92g.txt');
    outMat = fullfile(matDir,'GUARDED_FORMAL_RUN_DESIGN_v92g.mat');

    outScenariosCsv = fullfile(tablesDir,'GUARDED_FORMAL_RUN_DESIGN_v92g_options.csv');
    outTimeCsv = fullfile(tablesDir,'GUARDED_FORMAL_RUN_DESIGN_v92g_time_estimates.csv');
    outAcceptCsv = fullfile(tablesDir,'GUARDED_FORMAL_RUN_DESIGN_v92g_acceptance_criteria.csv');
    outPendingCsv = fullfile(tablesDir,'GUARDED_FORMAL_RUN_DESIGN_v92g_pending_methodology.csv');
    outRisksCsv = fullfile(tablesDir,'GUARDED_FORMAL_RUN_DESIGN_v92g_risks.csv');

    writetable(Tscenarios,outScenariosCsv);
    writetable(Ttime,outTimeCsv);
    writetable(Taccept,outAcceptCsv);
    writetable(Tpending,outPendingCsv);
    writetable(Trisks,outRisksCsv);

    save(outMat, ...
        'diagnosis','designFlags','formalDesign', ...
        'Tscenarios','Ttime','Taccept','Tpending','Trisks', ...
        'metrics','flags','smokeConfig','Tga', ...
        'smokeRunDir','postrunDir','designDir', ...
        'outMd','outTxt','outMat', ...
        'outScenariosCsv','outTimeCsv','outAcceptCsv','outPendingCsv','outRisksCsv');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# GUARDED_FORMAL_RUN_DESIGN_v92g\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Este documento diseña la corrida formal guardada, pero no la ejecuta.\n\n');

    fprintf(fid,'## Evidencia fuente\n\n');
    fprintf(fid,'| Fuente | Estado |\n');
    fprintf(fid,'|---|---|\n');
    fprintf(fid,'| Smoke run 9.1g | `%s` |\n', string(Ssmoke.diagnosis));
    fprintf(fid,'| Master realignment 6.34 | `%s` |\n', string(S634.diagnosis));
    fprintf(fid,'| Final postrun package v633 | `%s` |\n\n', string(S633.finalDiagnosis));

    fprintf(fid,'## Diagnóstico de tiempo de cómputo\n\n');
    fprintf(fid,'La corrida de humo mostró que el costo por evaluación es alto. Se estimó:\n\n');
    fprintf(fid,'| Modo | runtime smoke [s] | eval estimadas | s/eval |\n');
    fprintf(fid,'|---|---:|---:|---:|\n');
    fprintf(fid,'| gasLP | %.6g | %.0f | %.6g |\n', gasRow.runtime_seconds(1), gas_eval_count_smoke, gas_seconds_per_eval);
    fprintf(fid,'| hybrid | %.6g | %.0f | %.6g |\n', hybRow.runtime_seconds(1), hyb_eval_count_smoke, hyb_seconds_per_eval);
    fprintf(fid,'| promedio | — | — | %.6g |\n\n', avg_seconds_per_eval);

    fprintf(fid,'## Escenarios de corrida formal\n\n');
    fprintf(fid,'| Escenario | Modos | PopulationSize | MaxGenerations | Evaluaciones/modo | Recomendado | Riesgo |\n');
    fprintf(fid,'|---|---|---:|---:|---:|---|---|\n');

    for i = 1:height(Tscenarios)
        fprintf(fid,'| `%s` | `%s` | %.0f | %.0f | %.0f | `%d` | `%s` |\n', ...
            string(Tscenarios.scenario(i)), ...
            string(Tscenarios.modes(i)), ...
            Tscenarios.PopulationSize(i), ...
            Tscenarios.MaxGenerations(i), ...
            Tscenarios.estimated_evaluations_per_mode(i), ...
            Tscenarios.recommended(i), ...
            string(Tscenarios.risk(i)));
    end

    fprintf(fid,'\n## Estimación de tiempo\n\n');
    fprintf(fid,'| Escenario | modos GA | horas estimadas | horas con margen 30%% |\n');
    fprintf(fid,'|---|---:|---:|---:|\n');

    for i = 1:height(Ttime)
        fprintf(fid,'| `%s` | %.0f | %.6g | %.6g |\n', ...
            string(Ttime.scenario(i)), ...
            Ttime.number_of_GA_modes(i), ...
            Ttime.estimated_hours_total(i), ...
            Ttime.estimated_hours_with_30pct_margin(i));
    end

    fprintf(fid,'\n## Diseño recomendado\n\n');
    fprintf(fid,'Se recomienda iniciar con:\n\n');
    fprintf(fid,'`%s`\n\n', formalDesign.scenario);
    fprintf(fid,'Alcance: optimizar formalmente el modo `hybrid` con función objetivo guardada y usar `gasLP` como referencia postrun/controlada. No se incluye `solar` puro por trayectoria no física bajo la formulación actual.\n\n');

    fprintf(fid,'Parámetros recomendados:\n\n');
    fprintf(fid,'| Parámetro | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| PopulationSize | %.0f |\n', formalDesign.PopulationSize);
    fprintf(fid,'| MaxGenerations | %.0f |\n', formalDesign.MaxGenerations);
    fprintf(fid,'| Evaluaciones estimadas por modo | %.0f |\n', formalDesign.estimated_evaluations_per_mode);
    fprintf(fid,'| Horas estimadas con margen 30%% | %.6g |\n\n', formalDesign.estimated_hours_with_30pct_margin);

    fprintf(fid,'## Criterios de aceptación\n\n');
    fprintf(fid,'| Criterio | Estado requerido | Justificación |\n');
    fprintf(fid,'|---|---|---|\n');

    for i = 1:height(Taccept)
        fprintf(fid,'| `%s` | %s | %s |\n', ...
            string(Taccept.criterion(i)), ...
            string(Taccept.required_state(i)), ...
            string(Taccept.rationale(i)));
    end

    fprintf(fid,'\n## Pendientes metodológicos obligatorios\n\n');
    fprintf(fid,'| ID | Pendiente | Estado | Alcance | Impacto |\n');
    fprintf(fid,'|---|---|---|---|---|\n');

    for i = 1:height(Tpending)
        fprintf(fid,'| `%s` | %s | `%s` | %s | %s |\n', ...
            string(Tpending.id(i)), ...
            string(Tpending.item(i)), ...
            string(Tpending.status(i)), ...
            string(Tpending.scope(i)), ...
            string(Tpending.affects_article(i)));
    end

    fprintf(fid,'\n## Riesgos\n\n');
    fprintf(fid,'| Riesgo | Nivel | Descripción | Mitigación |\n');
    fprintf(fid,'|---|---|---|---|\n');

    for i = 1:height(Trisks)
        fprintf(fid,'| `%s` | `%s` | %s | %s |\n', ...
            string(Trisks.risk(i)), ...
            string(Trisks.level(i)), ...
            string(Trisks.description(i)), ...
            string(Trisks.mitigation(i)));
    end

    fprintf(fid,'\n## Decisiones explícitas\n\n');
    fprintf(fid,'- No se ejecuta corrida formal en este micropaso.\n');
    fprintf(fid,'- No se usa esta etapa para redactar conclusiones finales.\n');
    fprintf(fid,'- No se hacen afirmaciones sobre CO2 hasta incorporar su estimación formal.\n');
    fprintf(fid,'- No se reintroduce el modo solar puro hasta corregir y revalidar la rama solar.\n');
    fprintf(fid,'- La revisión de la física de operación del modelo queda registrada como pendiente metodológico obligatorio.\n');
    fprintf(fid,'- La estimación de CO2 queda registrada como pendiente metodológico obligatorio.\n\n');

    fprintf(fid,'## Siguiente paso recomendado\n\n');
    fprintf(fid,'`9.3g — GUARDED-FORMAL-RUN-SCRIPT-001`\n\n');
    fprintf(fid,'Propósito: construir el script de corrida formal guardada según el escenario recomendado, pero todavía con confirmación explícita antes de ejecutarlo.\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % TXT ejecutivo
    % ---------------------------------------------------------------------
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'GUARDED-FORMAL-RUN-DESIGN-001\n');
    fprintf(fid,'status: GUARDED_FORMAL_RUN_DESIGN_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'recommended_scenario: %s\n', formalDesign.scenario);
    fprintf(fid,'objective: %s\n', formalDesign.objective);
    fprintf(fid,'primary_mode_to_optimize: %s\n', formalDesign.primary_mode_to_optimize);
    fprintf(fid,'reference_mode: %s\n', formalDesign.reference_mode);
    fprintf(fid,'excluded_mode: %s\n', formalDesign.excluded_mode);
    fprintf(fid,'PopulationSize: %.0f\n', formalDesign.PopulationSize);
    fprintf(fid,'MaxGenerations: %.0f\n', formalDesign.MaxGenerations);
    fprintf(fid,'estimated_hours_with_30pct_margin: %.6g\n', formalDesign.estimated_hours_with_30pct_margin);
    fprintf(fid,'CO2_claims_blocked_until_estimation: %d\n', designFlags.CO2_claims_blocked_until_estimation);
    fprintf(fid,'physics_review_recorded: %d\n', designFlags.physics_review_recorded);
    fprintf(fid,'formal_run_not_executed_here: %d\n', designFlags.formal_run_not_executed_here);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'OUTPUTS:\n');
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'outScenariosCsv: %s\n', outScenariosCsv);
    fprintf(fid,'outTimeCsv: %s\n', outTimeCsv);
    fprintf(fid,'outAcceptCsv: %s\n', outAcceptCsv);
    fprintf(fid,'outPendingCsv: %s\n', outPendingCsv);
    fprintf(fid,'outRisksCsv: %s\n', outRisksCsv);

    fclose(fid);

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    design = struct();
    design.status = 'GUARDED_FORMAL_RUN_DESIGN_COMPLETED';
    design.diagnosis = diagnosis;
    design.formalDesign = formalDesign;
    design.designFlags = designFlags;
    design.Tscenarios = Tscenarios;
    design.Ttime = Ttime;
    design.Taccept = Taccept;
    design.Tpending = Tpending;
    design.Trisks = Trisks;
    design.smokeRunDir = smokeRunDir;
    design.postrunDir = postrunDir;
    design.designDir = designDir;
    design.outMd = outMd;
    design.outTxt = outTxt;
    design.outMat = outMat;
    design.outScenariosCsv = outScenariosCsv;
    design.outTimeCsv = outTimeCsv;
    design.outAcceptCsv = outAcceptCsv;
    design.outPendingCsv = outPendingCsv;
    design.outRisksCsv = outRisksCsv;

    disp('=== GUARDED_FORMAL_RUN_DESIGN_v92g ===')
    disp(design.status)
    disp('=== DIAGNOSIS ===')
    disp(design.diagnosis)
    disp('=== RECOMMENDED FORMAL DESIGN ===')
    disp(design.formalDesign)
    disp('=== TIME ESTIMATES ===')
    disp(design.Ttime)
    disp('=== PENDING METHODOLOGY ===')
    disp(design.Tpending)
    disp('=== ACCEPTANCE CRITERIA ===')
    disp(design.Taccept)
    disp('=== RISKS ===')
    disp(design.Trisks)
    disp('=== OUTPUT FILES ===')
    disp(design.outMd)
    disp(design.outTxt)
    disp(design.outMat)
end