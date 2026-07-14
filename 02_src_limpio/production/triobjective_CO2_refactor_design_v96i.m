function design = triobjective_CO2_refactor_design_v96i()
% TRIOBJECTIVE_CO2_REFACTOR_DESIGN_v96i
% 9.6i — TRI_OBJECTIVE_CO2_REFACTOR_DESIGN-001
%
% Objetivo:
%   Diseñar la reintegración formal de CO2 como tercera función objetivo:
%
%       f(1) = MR_final
%       f(2) = cost_specific_USD_per_kgwater
%       f(3) = CO2_specific_kgCO2_per_kgwater
%
% Contexto:
%   9.5k aprobó física mínima con v95j.
%   9.6g diseñó CO2 como postproceso.
%   9.6g-bis confirmó que la ruta actual es de 2 objetivos y que
%   la ruta triobjetivo requiere refactor.
%   El usuario seleccionó Ruta B.
%
% Este micropaso:
%   - NO modifica v10/v17/v628b/v18/v95j.
%   - NO crea todavía la función objetivo triobjetivo.
%   - NO ejecuta gamultiobj.
%   - NO libera corrida formal.
%   - Diseña la arquitectura para v96j/v96k.
%
% Salidas:
%   logs/TRIOBJECTIVE_CO2_REFACTOR_DESIGN_v96i.md
%   logs/TRIOBJECTIVE_CO2_REFACTOR_DESIGN_v96i.txt
%   tables/TRIOBJECTIVE_CO2_REFACTOR_DESIGN_v96i_objectives.csv
%   tables/TRIOBJECTIVE_CO2_REFACTOR_DESIGN_v96i_inputs.csv
%   tables/TRIOBJECTIVE_CO2_REFACTOR_DESIGN_v96i_requirements.csv
%   tables/TRIOBJECTIVE_CO2_REFACTOR_DESIGN_v96i_validation.csv
%   mat/TRIOBJECTIVE_CO2_REFACTOR_DESIGN_v96i.mat
%
% Uso:
%   design = triobjective_CO2_refactor_design_v96i();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Cargar gate 9.6g-bis
    % ---------------------------------------------------------------------
    gateBaseDir = fullfile(rootDir,'05_runs','co2_objective_reintegration_gate_v96gbis');

    if ~isfolder(gateBaseDir)
        error('No existe gateBaseDir: %s', gateBaseDir);
    end

    d = dir(gateBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'CO2_OBJECTIVE_REINTEGRATION_DECISION_GATE_v96gbis_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró gate v96gbis.');
    end

    [~,idxGate] = max([d.datenum]);
    gateDir = fullfile(gateBaseDir,d(idxGate).name);
    gateMat = fullfile(gateDir,'mat','CO2_OBJECTIVE_REINTEGRATION_DECISION_GATE_v96gbis.mat');

    if ~isfile(gateMat)
        error('No existe MAT v96gbis: %s', gateMat);
    end

    Sgate = load(gateMat);

    if ~strcmp(string(Sgate.diagnosis),"CO2_OBJECTIVE_REINTEGRATION_GATE_PASS_ROUTE_A_RECOMMENDED")
        error('Gate v96gbis no está en estado esperado. Diagnosis: %s', string(Sgate.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Cargar 9.5k
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

    % ---------------------------------------------------------------------
    % Rutas fuente
    % ---------------------------------------------------------------------
    objective_v95j = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v95j_endpoint_TMAX_corrected.m');
    wrapper_v18 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v18_endpoint_TMAX_corrected.m');

    proposed_objective_v96j = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v96j_triobjective_CO2.m');
    proposed_smoke_v96k = fullfile(rootDir,'02_src_limpio','production','run_guarded_triobjective_smoke_ga_v96k.m');
    proposed_formal_v96m = fullfile(rootDir,'02_src_limpio','production','run_guarded_triobjective_formal_ga_v96m.m');

    if ~isfile(objective_v95j)
        error('No existe objective v95j: %s', objective_v95j);
    end

    if ~isfile(wrapper_v18)
        error('No existe wrapper v18: %s', wrapper_v18);
    end

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    designBaseDir = fullfile(rootDir,'05_runs','triobjective_CO2_refactor_design_v96i');
    designDir = fullfile(designBaseDir,['TRIOBJECTIVE_CO2_REFACTOR_DESIGN_v96i_' timestamp]);

    logsDir = fullfile(designDir,'logs');
    tablesDir = fullfile(designDir,'tables');
    matDir = fullfile(designDir,'mat');

    if ~isfolder(designBaseDir), mkdir(designBaseDir); end
    if ~isfolder(designDir), mkdir(designDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Objetivos propuestos
    % ---------------------------------------------------------------------
    objRows = {};

    objRows{end+1,1} = local_objective_row( ...
        "F01", ...
        "MR_final", ...
        "dimensionless", ...
        "minimize", ...
        "f(1)=MR_final", ...
        "detail.outputs.MR or current f(1)", ...
        true, ...
        "Technical drying endpoint / product moisture performance.");

    objRows{end+1,1} = local_objective_row( ...
        "F02", ...
        "cost_specific_USD_per_kgwater", ...
        "USD/kg water removed", ...
        "minimize", ...
        "f(2)=cost_specific_USD_per_kgwater", ...
        "current f(2) from v95j", ...
        true, ...
        "Economic performance normalized by process service.");

    objRows{end+1,1} = local_objective_row( ...
        "F03", ...
        "CO2_specific_kgCO2_per_kgwater", ...
        "kgCO2/kg water removed", ...
        "minimize", ...
        "f(3)=CO2_total_kg/water_removed_kg", ...
        "new CO2 calculation inside objective v96j", ...
        true, ...
        "Environmental performance normalized by same service basis as cost.");

    Tobjectives = struct2table(vertcat(objRows{:}));

    % ---------------------------------------------------------------------
    % Inputs requeridos para CO2
    % ---------------------------------------------------------------------
    inputRows = {};

    inputRows{end+1,1} = local_input_row("I01","Q_aux_tot","kWh thermal","detail.outputs.Q_aux_tot","Required for LPG CO2.",true);
    inputRows{end+1,1} = local_input_row("I02","E_electricity_kWh","kWh electric","detail.cost or reconstructed from cost model","Required for electricity CO2.",true);
    inputRows{end+1,1} = local_input_row("I03","water_removed_kg","kg","mwi - mwf or detail.product equivalent","Normalization basis.",true);
    inputRows{end+1,1} = local_input_row("I04","EF_LPG_kgCO2_per_kWh","kgCO2/kWh thermal","reference-confirmed parameter","Emission factor for LPG.",true);
    inputRows{end+1,1} = local_input_row("I05","EF_grid_kgCO2_per_kWh","kgCO2/kWh electric","reference-confirmed parameter","Emission factor for electricity.",true);
    inputRows{end+1,1} = local_input_row("I06","mode_operation","gasLP/hybrid/solar","objective input","Solar remains penalized/excluded.",true);
    inputRows{end+1,1} = local_input_row("I07","detail_status","OK/INVALID_COST","v95j/v18 guard output","Only OK gasLP/hybrid accepted.",true);
    inputRows{end+1,1} = local_input_row("I08","penalty policy","numeric","existing objective penalty policy","Invalid CO2 must penalize f(3) consistently.",true);

    Tinputs = struct2table(vertcat(inputRows{:}));

    % ---------------------------------------------------------------------
    % Arquitectura requerida
    % ---------------------------------------------------------------------
    reqRows = {};

    reqRows{end+1,1} = local_req_row("R01","Clone v95j objective to v96j triobjective.",true,false,"Preserve v95j as validated 2-objective reference.");
    reqRows{end+1,1} = local_req_row("R02","Keep wrapper v18 unchanged.",true,true,"Endpoint TMAX and nonphysical guard are already validated.");
    reqRows{end+1,1} = local_req_row("R03","Add CO2 calculation inside objective, not only detail.",true,false,"CO2 must be returned in f(3).");
    reqRows{end+1,1} = local_req_row("R04","Return f as 1x3 numeric finite vector for valid gasLP/hybrid.",true,false,"gamultiobj must see three objectives.");
    reqRows{end+1,1} = local_req_row("R05","Return penalty vector [1000,1e6,1e6] or equivalent for invalid cases.",true,false,"Solar/invalid trajectories must remain blocked.");
    reqRows{end+1,1} = local_req_row("R06","Store detail.objectives.CO2_specific_kgCO2_per_kgwater.",true,false,"Required for traceability.");
    reqRows{end+1,1} = local_req_row("R07","Store detail.CO2 breakdown LPG/electricity/total.",true,false,"Required for article tables.");
    reqRows{end+1,1} = local_req_row("R08","Create triobjective direct audit before smoke GA.",true,false,"Validate gasLP/hybrid/solar and f size=3.");
    reqRows{end+1,1} = local_req_row("R09","Create triobjective smoke GA.",true,false,"Existing smoke validates only two objectives.");
    reqRows{end+1,1} = local_req_row("R10","Update formal run design and command.",true,false,"Formal command must use v96j objective and 3-objective storage.");

    Trequirements = struct2table(vertcat(reqRows{:}));

    % ---------------------------------------------------------------------
    % Validación obligatoria
    % ---------------------------------------------------------------------
    valRows = {};

    valRows{end+1,1} = local_val_row("V01","Direct f size","gasLP/hybrid return numel(f)=3; solar penalized.",true);
    valRows{end+1,1} = local_val_row("V02","MR consistency","f(1) matches MR and MR=(M-Mf)/(Mi-Mf).",true);
    valRows{end+1,1} = local_val_row("V03","Cost consistency","f(2) matches current v95j cost for same x/mode within tolerance.",true);
    valRows{end+1,1} = local_val_row("V04","CO2 finite positive","f(3) finite and nonnegative for gasLP/hybrid.",true);
    valRows{end+1,1} = local_val_row("V05","CO2 reduction sanity","For selected x, hybrid CO2 should be lower than gasLP if LPG dominates and electricity terms are comparable.",true);
    valRows{end+1,1} = local_val_row("V06","Solar exclusion","Solar remains INVALID_COST/NONPHYSICAL or penalized vector.",true);
    valRows{end+1,1} = local_val_row("V07","No source overwrite","v10/v17/v628b/v18/v95j preserved.",true);
    valRows{end+1,1} = local_val_row("V08","Smoke GA triobjective","Short gamultiobj smoke produces F with 3 columns and no unhandled penalty for gasLP/hybrid.",true);
    valRows{end+1,1} = local_val_row("V09","History/output compatibility","GA history, tables and reports accept 3 objective columns.",true);
    valRows{end+1,1} = local_val_row("V10","Claim package update","Article wording permits triobjective only after formal v96j run is consolidated.",true);

    Tvalidation = struct2table(vertcat(valRows{:}));

    % ---------------------------------------------------------------------
    % Factores de emisión provisionales: no definitivos
    % ---------------------------------------------------------------------
    factorPolicy = struct();
    factorPolicy.EF_LPG_kgCO2_per_kWh = NaN;
    factorPolicy.EF_grid_kgCO2_per_kWh = NaN;
    factorPolicy.status = "PENDING_REFERENCE_CONFIRMATION";
    factorPolicy.rule = "Do not run formal triobjective GA until factors are explicitly selected and logged.";
    factorPolicy.note = "9.6j should either set provisional factors for code validation or require user-approved factors before smoke.";

    % ---------------------------------------------------------------------
    % Decisión de diseño
    % ---------------------------------------------------------------------
    designFlags = struct();
    designFlags.route_B_selected_by_user = true;
    designFlags.v95k_pass = strcmp(string(S95k.diagnosis),"MINIMAL_PHYSICS_AUDIT_RECHECK_PASS_WITH_TMAX_CORRECTION");
    designFlags.v96gbis_confirms_current_two_objective = Sgate.gateFlags.current_objective_is_two_objective;
    designFlags.triobjective_refactor_required = true;
    designFlags.CO2_must_be_f3 = true;
    designFlags.CO2_postprocess_route_paused = true;
    designFlags.objective_v96j_required = true;
    designFlags.triobjective_smoke_required = true;
    designFlags.formal_script_update_required = true;
    designFlags.emission_factor_selection_required = true;
    designFlags.no_GA_executed = true;
    designFlags.formal_run_still_on_hold = true;

    if designFlags.route_B_selected_by_user && ...
       designFlags.v95k_pass && ...
       designFlags.v96gbis_confirms_current_two_objective && ...
       designFlags.triobjective_refactor_required

        diagnosis = "TRIOBJECTIVE_CO2_REFACTOR_DESIGN_PASS";
    else
        diagnosis = "TRIOBJECTIVE_CO2_REFACTOR_DESIGN_REQUIRES_REVIEW";
    end

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'TRIOBJECTIVE_CO2_REFACTOR_DESIGN_v96i.md');
    outTxt = fullfile(logsDir,'TRIOBJECTIVE_CO2_REFACTOR_DESIGN_v96i.txt');
    outMat = fullfile(matDir,'TRIOBJECTIVE_CO2_REFACTOR_DESIGN_v96i.mat');

    outObjectivesCsv = fullfile(tablesDir,'TRIOBJECTIVE_CO2_REFACTOR_DESIGN_v96i_objectives.csv');
    outInputsCsv = fullfile(tablesDir,'TRIOBJECTIVE_CO2_REFACTOR_DESIGN_v96i_inputs.csv');
    outReqCsv = fullfile(tablesDir,'TRIOBJECTIVE_CO2_REFACTOR_DESIGN_v96i_requirements.csv');
    outValCsv = fullfile(tablesDir,'TRIOBJECTIVE_CO2_REFACTOR_DESIGN_v96i_validation.csv');

    writetable(Tobjectives,outObjectivesCsv);
    writetable(Tinputs,outInputsCsv);
    writetable(Trequirements,outReqCsv);
    writetable(Tvalidation,outValCsv);

    save(outMat, ...
        'diagnosis','designFlags','factorPolicy', ...
        'Tobjectives','Tinputs','Trequirements','Tvalidation', ...
        'objective_v95j','wrapper_v18','proposed_objective_v96j','proposed_smoke_v96k','proposed_formal_v96m', ...
        'gateDir','recheckDir','designDir', ...
        'outMd','outTxt','outMat','outObjectivesCsv','outInputsCsv','outReqCsv','outValCsv');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# TRIOBJECTIVE_CO2_REFACTOR_DESIGN_v96i\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Ruta seleccionada: `B — MR-costo-CO2 triobjetivo`\n\n');

    fprintf(fid,'## Vector objetivo propuesto\n\n');
    fprintf(fid,'```matlab\n');
    fprintf(fid,'f(1) = MR_final;\n');
    fprintf(fid,'f(2) = cost_specific_USD_per_kgwater;\n');
    fprintf(fid,'f(3) = CO2_specific_kgCO2_per_kgwater;\n');
    fprintf(fid,'```\n\n');

    fprintf(fid,'## Objetivos\n\n');
    fprintf(fid,'| ID | Nombre | Unidad | Sentido | Fórmula | Fuente | Requerido | Justificación |\n');
    fprintf(fid,'|---|---|---|---|---|---|---:|---|\n');
    for i = 1:height(Tobjectives)
        fprintf(fid,'| `%s` | `%s` | %s | `%s` | `%s` | %s | `%d` | %s |\n', ...
            string(Tobjectives.id(i)), ...
            string(Tobjectives.name(i)), ...
            string(Tobjectives.unit(i)), ...
            string(Tobjectives.direction(i)), ...
            string(Tobjectives.formula(i)), ...
            string(Tobjectives.source(i)), ...
            Tobjectives.required(i), ...
            string(Tobjectives.justification(i)));
    end

    fprintf(fid,'\n## Inputs CO2 requeridos\n\n');
    fprintf(fid,'| ID | Variable | Unidad | Fuente | Descripción | Requerido |\n');
    fprintf(fid,'|---|---|---|---|---|---:|\n');
    for i = 1:height(Tinputs)
        fprintf(fid,'| `%s` | `%s` | %s | %s | %s | `%d` |\n', ...
            string(Tinputs.id(i)), ...
            string(Tinputs.variable(i)), ...
            string(Tinputs.unit(i)), ...
            string(Tinputs.source(i)), ...
            string(Tinputs.description(i)), ...
            Tinputs.required(i));
    end

    fprintf(fid,'\n## Requisitos de refactor\n\n');
    fprintf(fid,'| ID | Requisito | Obligatorio | Ya satisfecho | Nota |\n');
    fprintf(fid,'|---|---|---:|---:|---|\n');
    for i = 1:height(Trequirements)
        fprintf(fid,'| `%s` | %s | `%d` | `%d` | %s |\n', ...
            string(Trequirements.id(i)), ...
            string(Trequirements.requirement(i)), ...
            Trequirements.required(i), ...
            Trequirements.already_satisfied(i), ...
            string(Trequirements.note(i)));
    end

    fprintf(fid,'\n## Validación obligatoria\n\n');
    fprintf(fid,'| ID | Validación | Resultado requerido | Bloquea formal |\n');
    fprintf(fid,'|---|---|---|---:|\n');
    for i = 1:height(Tvalidation)
        fprintf(fid,'| `%s` | %s | %s | `%d` |\n', ...
            string(Tvalidation.id(i)), ...
            string(Tvalidation.validation(i)), ...
            string(Tvalidation.required_result(i)), ...
            Tvalidation.blocks_formal_run(i));
    end

    fprintf(fid,'\n## Archivos propuestos\n\n');
    fprintf(fid,'| Archivo | Ruta |\n');
    fprintf(fid,'|---|---|\n');
    fprintf(fid,'| Objective triobjetivo | `%s` |\n', proposed_objective_v96j);
    fprintf(fid,'| Smoke triobjetivo | `%s` |\n', proposed_smoke_v96k);
    fprintf(fid,'| Formal triobjetivo | `%s` |\n\n', proposed_formal_v96m);

    fprintf(fid,'## Política de factores de emisión\n\n');
    fprintf(fid,'Estado: `%s`\n\n', factorPolicy.status);
    fprintf(fid,'%s\n\n', factorPolicy.rule);

    fprintf(fid,'## Dictamen\n\n');
    if strcmp(diagnosis,"TRIOBJECTIVE_CO2_REFACTOR_DESIGN_PASS")
        fprintf(fid,'Se aprueba el diseño de refactor triobjetivo. La ruta CO2 como postproceso queda pausada. El siguiente paso debe crear la función objetivo `v96j` con `f(3)=CO2_specific_kgCO2_per_kgwater` y auditarla por evaluación directa antes de cualquier smoke GA.\n\n');
    else
        fprintf(fid,'El diseño requiere revisión. No debe implementarse objetivo triobjetivo todavía.\n\n');
    end

    fprintf(fid,'## Restricciones activas\n\n');
    fprintf(fid,'- No se ejecutó `gamultiobj`.\n');
    fprintf(fid,'- La corrida formal sigue detenida.\n');
    fprintf(fid,'- No se permite afirmar optimización triobjetivo hasta ejecutar y consolidar la corrida formal triobjetivo.\n');
    fprintf(fid,'- Solar puro sigue excluido.\n\n');

    fprintf(fid,'## Siguiente paso\n\n');
    fprintf(fid,'`9.6j — IMPLEMENT-TRIOBJECTIVE-CO2-OBJECTIVE-v96j-001`\n\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % TXT ejecutivo
    % ---------------------------------------------------------------------
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'TRI_OBJECTIVE_CO2_REFACTOR_DESIGN-001\n');
    fprintf(fid,'status: TRIOBJECTIVE_CO2_REFACTOR_DESIGN_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'route_B_selected_by_user: %d\n', designFlags.route_B_selected_by_user);
    fprintf(fid,'v95k_pass: %d\n', designFlags.v95k_pass);
    fprintf(fid,'v96gbis_confirms_current_two_objective: %d\n', designFlags.v96gbis_confirms_current_two_objective);
    fprintf(fid,'triobjective_refactor_required: %d\n', designFlags.triobjective_refactor_required);
    fprintf(fid,'CO2_must_be_f3: %d\n', designFlags.CO2_must_be_f3);
    fprintf(fid,'CO2_postprocess_route_paused: %d\n', designFlags.CO2_postprocess_route_paused);
    fprintf(fid,'objective_v96j_required: %d\n', designFlags.objective_v96j_required);
    fprintf(fid,'triobjective_smoke_required: %d\n', designFlags.triobjective_smoke_required);
    fprintf(fid,'formal_script_update_required: %d\n', designFlags.formal_script_update_required);
    fprintf(fid,'emission_factor_selection_required: %d\n', designFlags.emission_factor_selection_required);
    fprintf(fid,'no_GA_executed: %d\n', designFlags.no_GA_executed);
    fprintf(fid,'formal_run_still_on_hold: %d\n', designFlags.formal_run_still_on_hold);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'PROPOSED OBJECTIVE VECTOR:\n');
    fprintf(fid,'f(1) = MR_final\n');
    fprintf(fid,'f(2) = cost_specific_USD_per_kgwater\n');
    fprintf(fid,'f(3) = CO2_specific_kgCO2_per_kgwater\n\n');

    fprintf(fid,'PROPOSED FILES:\n');
    fprintf(fid,'objective_v96j: %s\n', proposed_objective_v96j);
    fprintf(fid,'smoke_v96k: %s\n', proposed_smoke_v96k);
    fprintf(fid,'formal_v96m: %s\n\n', proposed_formal_v96m);

    fprintf(fid,'OUTPUTS:\n');
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'outObjectivesCsv: %s\n', outObjectivesCsv);
    fprintf(fid,'outInputsCsv: %s\n', outInputsCsv);
    fprintf(fid,'outReqCsv: %s\n', outReqCsv);
    fprintf(fid,'outValCsv: %s\n', outValCsv);

    fclose(fid);

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    design = struct();
    design.status = 'TRIOBJECTIVE_CO2_REFACTOR_DESIGN_COMPLETED';
    design.diagnosis = diagnosis;
    design.designFlags = designFlags;
    design.factorPolicy = factorPolicy;
    design.Tobjectives = Tobjectives;
    design.Tinputs = Tinputs;
    design.Trequirements = Trequirements;
    design.Tvalidation = Tvalidation;
    design.objective_v95j = objective_v95j;
    design.wrapper_v18 = wrapper_v18;
    design.proposed_objective_v96j = proposed_objective_v96j;
    design.proposed_smoke_v96k = proposed_smoke_v96k;
    design.proposed_formal_v96m = proposed_formal_v96m;
    design.gateDir = gateDir;
    design.recheckDir = recheckDir;
    design.designDir = designDir;
    design.outMd = outMd;
    design.outTxt = outTxt;
    design.outMat = outMat;
    design.outObjectivesCsv = outObjectivesCsv;
    design.outInputsCsv = outInputsCsv;
    design.outReqCsv = outReqCsv;
    design.outValCsv = outValCsv;

    disp('=== TRIOBJECTIVE_CO2_REFACTOR_DESIGN_v96i ===')
    disp(design.status)
    disp('=== DIAGNOSIS ===')
    disp(design.diagnosis)
    disp('=== DESIGN FLAGS ===')
    disp(design.designFlags)
    disp('=== OBJECTIVES ===')
    disp(design.Tobjectives)
    disp('=== INPUTS ===')
    disp(design.Tinputs)
    disp('=== REQUIREMENTS ===')
    disp(design.Trequirements)
    disp('=== VALIDATION ===')
    disp(design.Tvalidation)
    disp('=== PROPOSED FILES ===')
    disp(design.proposed_objective_v96j)
    disp(design.proposed_smoke_v96k)
    disp(design.proposed_formal_v96m)
    disp('=== OUTPUT FILES ===')
    disp(design.outMd)
    disp(design.outTxt)
    disp(design.outMat)

end

% =========================================================================
% Local helpers
% =========================================================================

function row = local_objective_row(id, name, unit, direction, formula, source, required, justification)
    row = struct();
    row.id = string(id);
    row.name = string(name);
    row.unit = string(unit);
    row.direction = string(direction);
    row.formula = string(formula);
    row.source = string(source);
    row.required = logical(required);
    row.justification = string(justification);
end

function row = local_input_row(id, variable, unit, source, description, required)
    row = struct();
    row.id = string(id);
    row.variable = string(variable);
    row.unit = string(unit);
    row.source = string(source);
    row.description = string(description);
    row.required = logical(required);
end

function row = local_req_row(id, requirement, required, already_satisfied, note)
    row = struct();
    row.id = string(id);
    row.requirement = string(requirement);
    row.required = logical(required);
    row.already_satisfied = logical(already_satisfied);
    row.note = string(note);
end

function row = local_val_row(id, validation, required_result, blocks_formal_run)
    row = struct();
    row.id = string(id);
    row.validation = string(validation);
    row.required_result = string(required_result);
    row.blocks_formal_run = logical(blocks_formal_run);
end