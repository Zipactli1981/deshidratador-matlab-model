function co2design = co2_postprocess_design_option_A_v96g()
% CO2_POSTPROCESS_DESIGN_OPTION_A_v96g
% 9.6g — CO2-POSTPROCESS-DESIGN-OPTION-A-001
%
% Objetivo:
%   Diseñar CO2 como métrica de postproceso trazable.
%
% Decisión:
%   CO2 opción A:
%       - CO2 NO será tercer objetivo del AG.
%       - CO2 se calculará después para cada solución Pareto MR-costo.
%       - El artículo podrá reportar emisiones estimadas/postprocesadas,
%         pero NO podrá afirmar optimización triobjetivo MR-costo-CO2.
%
% Este micropaso:
%   - NO ejecuta gamultiobj.
%   - NO modifica v10/v17/v628b.
%   - NO modifica v18/v95j.
%   - NO calcula todavía CO2 definitivo.
%   - NO libera todavía la corrida formal.
%
% Requiere:
%   - 9.4h FORMAL_RUN_VALUE_GATE_PASS_HOLD_EXECUTION
%   - 9.5k MINIMAL_PHYSICS_AUDIT_RECHECK_PASS_WITH_TMAX_CORRECTION
%
% Salidas:
%   logs/CO2_POSTPROCESS_DESIGN_OPTION_A_v96g.md
%   logs/CO2_POSTPROCESS_DESIGN_OPTION_A_v96g.txt
%   tables/CO2_POSTPROCESS_DESIGN_OPTION_A_v96g_method.csv
%   tables/CO2_POSTPROCESS_DESIGN_OPTION_A_v96g_inputs.csv
%   tables/CO2_POSTPROCESS_DESIGN_OPTION_A_v96g_outputs.csv
%   tables/CO2_POSTPROCESS_DESIGN_OPTION_A_v96g_claim_rules.csv
%   tables/CO2_POSTPROCESS_DESIGN_OPTION_A_v96g_validation.csv
%   mat/CO2_POSTPROCESS_DESIGN_OPTION_A_v96g.mat
%
% Uso:
%   co2design = co2_postprocess_design_option_A_v96g();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Cargar value gate v94h
    % ---------------------------------------------------------------------
    gateBaseDir = fullfile(rootDir,'05_runs','formal_value_gate_v94h');

    if ~isfolder(gateBaseDir)
        error('No existe gateBaseDir: %s', gateBaseDir);
    end

    dg = dir(gateBaseDir);
    dg = dg([dg.isdir]);
    dg = dg(~ismember({dg.name},{'.','..','.MATLABDriveTag'}));

    keepG = false(size(dg));
    for i = 1:numel(dg)
        keepG(i) = startsWith(dg(i).name,'FORMAL_RUN_VALUE_GATE_v94h_');
    end
    dg = dg(keepG);

    if isempty(dg)
        error('No se encontró value gate v94h.');
    end

    [~,idxGate] = max([dg.datenum]);
    gateDir = fullfile(gateBaseDir,dg(idxGate).name);
    gateMat = fullfile(gateDir,'mat','FORMAL_RUN_VALUE_GATE_v94h.mat');

    if ~isfile(gateMat)
        error('No existe MAT v94h: %s', gateMat);
    end

    Sgate = load(gateMat);

    if ~strcmp(string(Sgate.diagnosis),"FORMAL_RUN_VALUE_GATE_PASS_HOLD_EXECUTION")
        error('v94h no está en PASS_HOLD_EXECUTION. Diagnosis: %s', string(Sgate.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Cargar recheck físico v95k
    % ---------------------------------------------------------------------
    recheckBaseDir = fullfile(rootDir,'05_runs','minimal_physics_recheck_v95k');

    if ~isfolder(recheckBaseDir)
        error('No existe recheckBaseDir: %s', recheckBaseDir);
    end

    dr = dir(recheckBaseDir);
    dr = dr([dr.isdir]);
    dr = dr(~ismember({dr.name},{'.','..','.MATLABDriveTag'}));

    keepR = false(size(dr));
    for i = 1:numel(dr)
        keepR(i) = startsWith(dr(i).name,'MINIMAL_PHYSICS_AUDIT_RECHECK_v95k_');
    end
    dr = dr(keepR);

    if isempty(dr)
        error('No se encontró recheck v95k.');
    end

    [~,idxRecheck] = max([dr.datenum]);
    recheckDir = fullfile(recheckBaseDir,dr(idxRecheck).name);
    recheckMat = fullfile(recheckDir,'mat','MINIMAL_PHYSICS_AUDIT_RECHECK_v95k.mat');

    if ~isfile(recheckMat)
        error('No existe MAT v95k: %s', recheckMat);
    end

    S95k = load(recheckMat);

    if ~strcmp(string(S95k.diagnosis),"MINIMAL_PHYSICS_AUDIT_RECHECK_PASS_WITH_TMAX_CORRECTION")
        error('v95k no está en PASS. Diagnosis: %s', string(S95k.diagnosis));
    end

    objectiveCandidate = string(S95k.recheckFlags.objective_for_formal_run_candidate);

    if objectiveCandidate ~= "objective_productive_corrected_v95j_endpoint_TMAX_corrected"
        error('La función objetivo candidata no es v95j. Valor: %s', objectiveCandidate);
    end

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    designBaseDir = fullfile(rootDir,'05_runs','co2_postprocess_design_v96g');
    designDir = fullfile(designBaseDir,['CO2_POSTPROCESS_DESIGN_OPTION_A_v96g_' timestamp]);

    logsDir = fullfile(designDir,'logs');
    tablesDir = fullfile(designDir,'tables');
    matDir = fullfile(designDir,'mat');

    if ~isfolder(designBaseDir), mkdir(designBaseDir); end
    if ~isfolder(designDir), mkdir(designDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Factores de emisión: placeholders trazables
    % ---------------------------------------------------------------------
    % Estos factores NO se fijan como definitivos aquí.
    % Deben confirmarse en el micropaso de implementación o en la etapa de
    % referencias del manuscrito.
    %
    % Unidades propuestas:
    %   factor_LPG_kgCO2_per_kWh_LHV
    %   factor_electricity_kgCO2_per_kWh
    %
    % Para GLP, Q_aux_tot ya está en kWh térmicos en la lógica de costo.
    % Para electricidad, se requiere identificar/confirmar el campo eléctrico
    % disponible en detail/cost. Si no hay campo directo, se postprocesa con
    % la misma lógica usada por cost.total_cost_USD/electric component.

    defaultFactors = struct();
    defaultFactors.factor_LPG_kgCO2_per_kWh = NaN;
    defaultFactors.factor_electricity_kgCO2_per_kWh = NaN;
    defaultFactors.factor_status = "PENDING_REFERENCE_CONFIRMATION";
    defaultFactors.factor_policy = "Do not hard-code final factors until source/reference is selected.";

    % ---------------------------------------------------------------------
    % Método CO2
    % ---------------------------------------------------------------------
    methodRows = {};

    row = struct();
    row.id = "M01";
    row.component = "LPG_combustion";
    row.formula = "CO2_LPG_kg = Q_aux_tot_kWh * EF_LPG_kgCO2_per_kWh";
    row.unit_basis = "Q_aux_tot in kWh thermal; EF_LPG in kgCO2/kWh";
    row.required = true;
    row.note = "Applies to gasLP and hybrid. Solar remains excluded.";
    methodRows{end+1,1} = row;

    row = struct();
    row.id = "M02";
    row.component = "Electricity";
    row.formula = "CO2_electricity_kg = E_electricity_kWh * EF_grid_kgCO2_per_kWh";
    row.unit_basis = "E_electricity in kWh; EF_grid in kgCO2/kWh";
    row.required = true;
    row.note = "Electricity term must be extracted from detail/cost or reconstructed from the existing cost model.";
    methodRows{end+1,1} = row;

    row = struct();
    row.id = "M03";
    row.component = "Total_batch";
    row.formula = "CO2_total_kg = CO2_LPG_kg + CO2_electricity_kg";
    row.unit_basis = "kgCO2 per batch";
    row.required = true;
    row.note = "Batch basis corresponds to the same W0/product basis used in the objective.";
    methodRows{end+1,1} = row;

    row = struct();
    row.id = "M04";
    row.component = "Specific_emissions_water_removed";
    row.formula = "CO2_specific_kg_per_kgwater = CO2_total_kg / water_removed_kg";
    row.unit_basis = "kgCO2/kg water removed";
    row.required = true;
    row.note = "Preferred normalized indicator for comparison with cost_specific.";
    methodRows{end+1,1} = row;

    row = struct();
    row.id = "M05";
    row.component = "Specific_emissions_dry_product_optional";
    row.formula = "CO2_specific_kg_per_kgdry = CO2_total_kg / md_kg";
    row.unit_basis = "kgCO2/kg dry product";
    row.required = false;
    row.note = "Optional secondary metric if useful for article tables.";
    methodRows{end+1,1} = row;

    row = struct();
    row.id = "M06";
    row.component = "Relative_reduction";
    row.formula = "reduction_CO2_pct = 100*(CO2_gasLP - CO2_hybrid)/CO2_gasLP";
    row.unit_basis = "percent";
    row.required = true;
    row.note = "Only valid for paired postprocess comparison, not as GA objective.";
    methodRows{end+1,1} = row;

    Tmethod = struct2table(vertcat(methodRows{:}));

    % ---------------------------------------------------------------------
    % Inputs requeridos
    % ---------------------------------------------------------------------
    inputRows = {};

    inputRows{end+1,1} = local_input_row_v96g("I01","mode","gasLP/hybrid","string","Objective evaluation mode.",true,"from formal/postrun evaluation");
    inputRows{end+1,1} = local_input_row_v96g("I02","x","[m_max,T_min,r_div2,t_rec_ini]","numeric vector","Decision vector for each Pareto solution.",true,"from GA output");
    inputRows{end+1,1} = local_input_row_v96g("I03","MR","dimensionless","numeric","Final moisture ratio from corrected objective.",true,"detail.outputs.MR or f(1)");
    inputRows{end+1,1} = local_input_row_v96g("I04","cost_specific_USD_per_kgwater","USD/kgwater","numeric","Existing objective cost.",true,"f(2) or detail.cost");
    inputRows{end+1,1} = local_input_row_v96g("I05","Q_aux_tot","kWh thermal","numeric","Auxiliary thermal energy from GLP.",true,"detail.outputs.Q_aux_tot");
    inputRows{end+1,1} = local_input_row_v96g("I06","E_electricity","kWh electric","numeric","Electricity consumption for fan/control/equipment.",true,"detail.cost or reconstructed");
    inputRows{end+1,1} = local_input_row_v96g("I07","water_removed","kg water","numeric","Water removed in batch.",true,"detail.product.mwi - detail.product.mwf or equivalent");
    inputRows{end+1,1} = local_input_row_v96g("I08","md","kg dry matter","numeric","Dry matter basis.",false,"detail.product.md");
    inputRows{end+1,1} = local_input_row_v96g("I09","EF_LPG","kgCO2/kWh","numeric","GLP emission factor.",true,"external/reference-confirmed");
    inputRows{end+1,1} = local_input_row_v96g("I10","EF_grid","kgCO2/kWh","numeric","Electric grid emission factor.",true,"external/reference-confirmed");
    inputRows{end+1,1} = local_input_row_v96g("I11","detail_status","OK/INVALID_COST","string","Validity flag from corrected objective.",true,"detail.status");
    inputRows{end+1,1} = local_input_row_v96g("I12","solar_exclusion_flag","boolean","logical","Solar excluded from claims.",true,"guard/result policy");

    Tinputs = struct2table(vertcat(inputRows{:}));

    % ---------------------------------------------------------------------
    % Outputs requeridos
    % ---------------------------------------------------------------------
    outputRows = {};

    outputRows{end+1,1} = local_output_row_v96g("O01","CO2_LPG_kg","kgCO2/batch","CO2 from auxiliary GLP.");
    outputRows{end+1,1} = local_output_row_v96g("O02","CO2_electricity_kg","kgCO2/batch","CO2 from electricity.");
    outputRows{end+1,1} = local_output_row_v96g("O03","CO2_total_kg","kgCO2/batch","Total postprocessed emissions.");
    outputRows{end+1,1} = local_output_row_v96g("O04","CO2_specific_kg_per_kgwater","kgCO2/kgwater","Normalized emissions by removed water.");
    outputRows{end+1,1} = local_output_row_v96g("O05","CO2_specific_kg_per_kgdry_optional","kgCO2/kgdry","Optional normalized emissions by dry matter.");
    outputRows{end+1,1} = local_output_row_v96g("O06","CO2_reduction_vs_gasLP_pct","percent","Relative reduction when paired with gasLP reference.");
    outputRows{end+1,1} = local_output_row_v96g("O07","CO2_factor_source_status","string","Whether emission factors are confirmed or pending.");
    outputRows{end+1,1} = local_output_row_v96g("O08","CO2_claim_scope","string","Allowed claim scope for manuscript.");

    Toutputs = struct2table(vertcat(outputRows{:}));

    % ---------------------------------------------------------------------
    % Reglas de afirmación para artículo
    % ---------------------------------------------------------------------
    claimRows = {};

    claimRows{end+1,1} = local_claim_row_v96g( ...
        "C01", ...
        "Allowed", ...
        "Emissions were estimated as a postprocessed metric for Pareto candidates.", ...
        "Use after CO2 implementation and factor validation.");

    claimRows{end+1,1} = local_claim_row_v96g( ...
        "C02", ...
        "Allowed", ...
        "Hybrid candidates showed lower estimated CO2 than gasLP reference if postprocess confirms it.", ...
        "Use only with computed values and reference factors.");

    claimRows{end+1,1} = local_claim_row_v96g( ...
        "C03", ...
        "Not allowed", ...
        "The genetic algorithm optimized MR, cost and CO2 simultaneously.", ...
        "CO2 is not in f=[MR,cost] under option A.");

    claimRows{end+1,1} = local_claim_row_v96g( ...
        "C04", ...
        "Not allowed", ...
        "The result is a triobjective Pareto front.", ...
        "Only MR-cost Pareto front with CO2 overlay/postprocess is allowed.");

    claimRows{end+1,1} = local_claim_row_v96g( ...
        "C05", ...
        "Allowed with wording control", ...
        "A CO2-colored MR-cost Pareto map was produced.", ...
        "Allowed if figures color or annotate Pareto candidates by postprocessed CO2.");

    claimRows{end+1,1} = local_claim_row_v96g( ...
        "C06", ...
        "Not allowed", ...
        "Pure solar mode is environmentally superior.", ...
        "Solar branch remains invalid/excluded.");

    Tclaims = struct2table(vertcat(claimRows{:}));

    % ---------------------------------------------------------------------
    % Validación requerida para implementar CO2
    % ---------------------------------------------------------------------
    validationRows = {};

    validationRows{end+1,1} = local_validation_row_v96g("V01","Objective route","Use objective_productive_corrected_v95j_endpoint_TMAX_corrected only.",true);
    validationRows{end+1,1} = local_validation_row_v96g("V02","Mode validity","gasLP/hybrid detail_status OK; solar excluded.",true);
    validationRows{end+1,1} = local_validation_row_v96g("V03","Energy units","Confirm Q_aux_tot is kWh thermal and E_electricity is kWh electric.",true);
    validationRows{end+1,1} = local_validation_row_v96g("V04","Emission factors","Emission factors must be explicitly set and cited before manuscript use.",true);
    validationRows{end+1,1} = local_validation_row_v96g("V05","Water basis","water_removed must match objective/product basis.",true);
    validationRows{end+1,1} = local_validation_row_v96g("V06","No triobjective claim","CO2 remains postprocess unless objective vector is redesigned.",true);
    validationRows{end+1,1} = local_validation_row_v96g("V07","Storage","CO2 outputs must be stored in table and MAT files.",true);
    validationRows{end+1,1} = local_validation_row_v96g("V08","Formal script update","Formal GA script must use v95j objective before execution.",true);

    Tvalidation = struct2table(vertcat(validationRows{:}));

    % ---------------------------------------------------------------------
    % Diseño de función futura de postproceso
    % ---------------------------------------------------------------------
    functionPlan = struct();
    functionPlan.name = "postprocess_CO2_option_A_v96h";
    functionPlan.file = fullfile(rootDir,'02_src_limpio','production','postprocess_CO2_option_A_v96h.m');
    functionPlan.input_type = "GA Pareto table or explicit X matrix plus mode/reference evaluation";
    functionPlan.primary_objective = "Evaluate each Pareto candidate with v95j detail and compute CO2 metrics.";
    functionPlan.expected_outputs = [
        "tables/CO2_POSTPROCESS_OPTION_A_v96h_candidates.csv"
        "tables/CO2_POSTPROCESS_OPTION_A_v96h_reference_comparison.csv"
        "mat/CO2_POSTPROCESS_OPTION_A_v96h.mat"
    ];

    % ---------------------------------------------------------------------
    % Estado y flags
    % ---------------------------------------------------------------------
    designFlags = struct();
    designFlags.v94h_gate_pass = strcmp(string(Sgate.diagnosis),"FORMAL_RUN_VALUE_GATE_PASS_HOLD_EXECUTION");
    designFlags.v95k_physics_recheck_pass = strcmp(string(S95k.diagnosis),"MINIMAL_PHYSICS_AUDIT_RECHECK_PASS_WITH_TMAX_CORRECTION");
    designFlags.CO2_option_A_selected = true;
    designFlags.CO2_as_postprocess_metric = true;
    designFlags.CO2_as_third_objective = false;
    designFlags.triobjective_claim_allowed = false;
    designFlags.MR_cost_formal_run_still_valid = true;
    designFlags.objective_candidate_is_v95j = objectiveCandidate == "objective_productive_corrected_v95j_endpoint_TMAX_corrected";
    designFlags.formal_script_update_required = true;
    designFlags.emission_factors_pending_reference = true;
    designFlags.CO2_implementation_pending = true;
    designFlags.no_GA_executed = true;
    designFlags.formal_run_still_on_hold = true;

    if designFlags.v94h_gate_pass && ...
       designFlags.v95k_physics_recheck_pass && ...
       designFlags.CO2_option_A_selected && ...
       designFlags.CO2_as_postprocess_metric && ...
       ~designFlags.CO2_as_third_objective && ...
       designFlags.objective_candidate_is_v95j

        diagnosis = "CO2_POSTPROCESS_DESIGN_OPTION_A_PASS";
    else
        diagnosis = "CO2_POSTPROCESS_DESIGN_OPTION_A_REQUIRES_REVIEW";
    end

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'CO2_POSTPROCESS_DESIGN_OPTION_A_v96g.md');
    outTxt = fullfile(logsDir,'CO2_POSTPROCESS_DESIGN_OPTION_A_v96g.txt');
    outMat = fullfile(matDir,'CO2_POSTPROCESS_DESIGN_OPTION_A_v96g.mat');

    outMethodCsv = fullfile(tablesDir,'CO2_POSTPROCESS_DESIGN_OPTION_A_v96g_method.csv');
    outInputsCsv = fullfile(tablesDir,'CO2_POSTPROCESS_DESIGN_OPTION_A_v96g_inputs.csv');
    outOutputsCsv = fullfile(tablesDir,'CO2_POSTPROCESS_DESIGN_OPTION_A_v96g_outputs.csv');
    outClaimsCsv = fullfile(tablesDir,'CO2_POSTPROCESS_DESIGN_OPTION_A_v96g_claim_rules.csv');
    outValidationCsv = fullfile(tablesDir,'CO2_POSTPROCESS_DESIGN_OPTION_A_v96g_validation.csv');

    writetable(Tmethod,outMethodCsv);
    writetable(Tinputs,outInputsCsv);
    writetable(Toutputs,outOutputsCsv);
    writetable(Tclaims,outClaimsCsv);
    writetable(Tvalidation,outValidationCsv);

    save(outMat, ...
        'diagnosis','designFlags','defaultFactors','functionPlan', ...
        'Tmethod','Tinputs','Toutputs','Tclaims','Tvalidation', ...
        'objectiveCandidate','gateDir','recheckDir','designDir', ...
        'outMd','outTxt','outMat','outMethodCsv','outInputsCsv','outOutputsCsv','outClaimsCsv','outValidationCsv');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# CO2_POSTPROCESS_DESIGN_OPTION_A_v96g\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'CO2 se define como métrica de postproceso para soluciones Pareto MR-costo. No se incorpora como tercer objetivo del algoritmo genético.\n\n');

    fprintf(fid,'## Función objetivo candidata\n\n');
    fprintf(fid,'La corrida formal deberá usar:\n\n');
    fprintf(fid,'```text\n%s\n```\n\n', objectiveCandidate);

    fprintf(fid,'## Método propuesto\n\n');
    fprintf(fid,'| ID | Componente | Fórmula | Base de unidades | Requerido | Nota |\n');
    fprintf(fid,'|---|---|---|---|---:|---|\n');
    for i = 1:height(Tmethod)
        fprintf(fid,'| `%s` | %s | `%s` | %s | `%d` | %s |\n', ...
            string(Tmethod.id(i)), ...
            string(Tmethod.component(i)), ...
            string(Tmethod.formula(i)), ...
            string(Tmethod.unit_basis(i)), ...
            Tmethod.required(i), ...
            string(Tmethod.note(i)));
    end

    fprintf(fid,'\n## Inputs requeridos\n\n');
    fprintf(fid,'| ID | Variable | Unidad | Tipo | Descripción | Requerido | Fuente |\n');
    fprintf(fid,'|---|---|---|---|---|---:|---|\n');
    for i = 1:height(Tinputs)
        fprintf(fid,'| `%s` | `%s` | %s | `%s` | %s | `%d` | %s |\n', ...
            string(Tinputs.id(i)), ...
            string(Tinputs.variable(i)), ...
            string(Tinputs.unit(i)), ...
            string(Tinputs.type(i)), ...
            string(Tinputs.description(i)), ...
            Tinputs.required(i), ...
            string(Tinputs.source(i)));
    end

    fprintf(fid,'\n## Outputs requeridos\n\n');
    fprintf(fid,'| ID | Variable | Unidad | Descripción |\n');
    fprintf(fid,'|---|---|---|---|\n');
    for i = 1:height(Toutputs)
        fprintf(fid,'| `%s` | `%s` | %s | %s |\n', ...
            string(Toutputs.id(i)), ...
            string(Toutputs.variable(i)), ...
            string(Toutputs.unit(i)), ...
            string(Toutputs.description(i)));
    end

    fprintf(fid,'\n## Reglas de afirmación para artículo\n\n');
    fprintf(fid,'| ID | Estado | Afirmación | Condición |\n');
    fprintf(fid,'|---|---|---|---|\n');
    for i = 1:height(Tclaims)
        fprintf(fid,'| `%s` | `%s` | %s | %s |\n', ...
            string(Tclaims.id(i)), ...
            string(Tclaims.status(i)), ...
            string(Tclaims.claim(i)), ...
            string(Tclaims.condition(i)));
    end

    fprintf(fid,'\n## Validación requerida\n\n');
    fprintf(fid,'| ID | Validación | Resultado requerido | Bloquea uso formal |\n');
    fprintf(fid,'|---|---|---|---:|\n');
    for i = 1:height(Tvalidation)
        fprintf(fid,'| `%s` | %s | %s | `%d` |\n', ...
            string(Tvalidation.id(i)), ...
            string(Tvalidation.validation(i)), ...
            string(Tvalidation.required_result(i)), ...
            Tvalidation.blocks_formal_use(i));
    end

    fprintf(fid,'\n## Factores de emisión\n\n');
    fprintf(fid,'Los factores quedan pendientes de confirmación documental. No deben fijarse como definitivos en este diseño.\n\n');
    fprintf(fid,'| Factor | Estado |\n');
    fprintf(fid,'|---|---|\n');
    fprintf(fid,'| EF_LPG_kgCO2_per_kWh | `%s` |\n', defaultFactors.factor_status);
    fprintf(fid,'| EF_grid_kgCO2_per_kWh | `%s` |\n\n', defaultFactors.factor_status);

    fprintf(fid,'## Función futura de implementación\n\n');
    fprintf(fid,'| Campo | Valor |\n');
    fprintf(fid,'|---|---|\n');
    fprintf(fid,'| Nombre | `%s` |\n', functionPlan.name);
    fprintf(fid,'| Archivo | `%s` |\n', functionPlan.file);
    fprintf(fid,'| Entrada | %s |\n', functionPlan.input_type);
    fprintf(fid,'| Objetivo | %s |\n\n', functionPlan.primary_objective);

    fprintf(fid,'## Dictamen\n\n');
    if strcmp(diagnosis,"CO2_POSTPROCESS_DESIGN_OPTION_A_PASS")
        fprintf(fid,'El diseño CO2 opción A queda aprobado. La corrida formal MR-costo sigue metodológicamente válida, pero debe actualizarse el script formal para usar `objective_productive_corrected_v95j_endpoint_TMAX_corrected`. La implementación de CO2 queda para el siguiente micropaso.\n\n');
    else
        fprintf(fid,'El diseño CO2 opción A requiere revisión. No debe liberarse la corrida formal.\n\n');
    end

    fprintf(fid,'## Restricciones activas\n\n');
    fprintf(fid,'- No se ejecutó `gamultiobj`.\n');
    fprintf(fid,'- CO2 no es tercer objetivo.\n');
    fprintf(fid,'- No se permite afirmar optimización triobjetivo.\n');
    fprintf(fid,'- Solar puro sigue excluido.\n');
    fprintf(fid,'- El script formal previo debe actualizarse para usar la función objetivo corregida `v95j`.\n\n');

    fprintf(fid,'## Siguiente paso\n\n');
    fprintf(fid,'`9.6h — CO2-POSTPROCESS-IMPLEMENTATION-OPTION-A-001`\n\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % TXT ejecutivo
    % ---------------------------------------------------------------------
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'CO2-POSTPROCESS-DESIGN-OPTION-A-001\n');
    fprintf(fid,'status: CO2_POSTPROCESS_DESIGN_OPTION_A_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'v94h_gate_pass: %d\n', designFlags.v94h_gate_pass);
    fprintf(fid,'v95k_physics_recheck_pass: %d\n', designFlags.v95k_physics_recheck_pass);
    fprintf(fid,'CO2_option_A_selected: %d\n', designFlags.CO2_option_A_selected);
    fprintf(fid,'CO2_as_postprocess_metric: %d\n', designFlags.CO2_as_postprocess_metric);
    fprintf(fid,'CO2_as_third_objective: %d\n', designFlags.CO2_as_third_objective);
    fprintf(fid,'triobjective_claim_allowed: %d\n', designFlags.triobjective_claim_allowed);
    fprintf(fid,'MR_cost_formal_run_still_valid: %d\n', designFlags.MR_cost_formal_run_still_valid);
    fprintf(fid,'objective_candidate_is_v95j: %d\n', designFlags.objective_candidate_is_v95j);
    fprintf(fid,'formal_script_update_required: %d\n', designFlags.formal_script_update_required);
    fprintf(fid,'emission_factors_pending_reference: %d\n', designFlags.emission_factors_pending_reference);
    fprintf(fid,'CO2_implementation_pending: %d\n', designFlags.CO2_implementation_pending);
    fprintf(fid,'no_GA_executed: %d\n', designFlags.no_GA_executed);
    fprintf(fid,'formal_run_still_on_hold: %d\n', designFlags.formal_run_still_on_hold);
    fprintf(fid,'objectiveCandidate: %s\n', objectiveCandidate);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'NEXT FUNCTION PLAN:\n');
    fprintf(fid,'name: %s\n', functionPlan.name);
    fprintf(fid,'file: %s\n\n', functionPlan.file);

    fprintf(fid,'OUTPUTS:\n');
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'outMethodCsv: %s\n', outMethodCsv);
    fprintf(fid,'outInputsCsv: %s\n', outInputsCsv);
    fprintf(fid,'outOutputsCsv: %s\n', outOutputsCsv);
    fprintf(fid,'outClaimsCsv: %s\n', outClaimsCsv);
    fprintf(fid,'outValidationCsv: %s\n', outValidationCsv);

    fclose(fid);

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    co2design = struct();
    co2design.status = 'CO2_POSTPROCESS_DESIGN_OPTION_A_COMPLETED';
    co2design.diagnosis = diagnosis;
    co2design.designFlags = designFlags;
    co2design.defaultFactors = defaultFactors;
    co2design.functionPlan = functionPlan;
    co2design.Tmethod = Tmethod;
    co2design.Tinputs = Tinputs;
    co2design.Toutputs = Toutputs;
    co2design.Tclaims = Tclaims;
    co2design.Tvalidation = Tvalidation;
    co2design.objectiveCandidate = objectiveCandidate;
    co2design.gateDir = gateDir;
    co2design.recheckDir = recheckDir;
    co2design.designDir = designDir;
    co2design.outMd = outMd;
    co2design.outTxt = outTxt;
    co2design.outMat = outMat;
    co2design.outMethodCsv = outMethodCsv;
    co2design.outInputsCsv = outInputsCsv;
    co2design.outOutputsCsv = outOutputsCsv;
    co2design.outClaimsCsv = outClaimsCsv;
    co2design.outValidationCsv = outValidationCsv;

    disp('=== CO2_POSTPROCESS_DESIGN_OPTION_A_v96g ===')
    disp(co2design.status)
    disp('=== DIAGNOSIS ===')
    disp(co2design.diagnosis)
    disp('=== DESIGN FLAGS ===')
    disp(co2design.designFlags)
    disp('=== METHOD ===')
    disp(co2design.Tmethod)
    disp('=== INPUTS ===')
    disp(co2design.Tinputs)
    disp('=== OUTPUTS ===')
    disp(co2design.Toutputs)
    disp('=== CLAIM RULES ===')
    disp(co2design.Tclaims)
    disp('=== VALIDATION ===')
    disp(co2design.Tvalidation)
    disp('=== OBJECTIVE CANDIDATE ===')
    disp(co2design.objectiveCandidate)
    disp('=== OUTPUT FILES ===')
    disp(co2design.outMd)
    disp(co2design.outTxt)
    disp(co2design.outMat)

end

% =========================================================================
% Funciones locales auxiliares
% =========================================================================

function row = local_input_row_v96g(id, variable, unit, type, description, required, source)
    row = struct();
    row.id = string(id);
    row.variable = string(variable);
    row.unit = string(unit);
    row.type = string(type);
    row.description = string(description);
    row.required = logical(required);
    row.source = string(source);
end

function row = local_output_row_v96g(id, variable, unit, description)
    row = struct();
    row.id = string(id);
    row.variable = string(variable);
    row.unit = string(unit);
    row.description = string(description);
end

function row = local_claim_row_v96g(id, status, claim, condition)
    row = struct();
    row.id = string(id);
    row.status = string(status);
    row.claim = string(claim);
    row.condition = string(condition);
end

function row = local_validation_row_v96g(id, validation, required_result, blocks_formal_use)
    row = struct();
    row.id = string(id);
    row.validation = string(validation);
    row.required_result = string(required_result);
    row.blocks_formal_use = logical(blocks_formal_use);
end