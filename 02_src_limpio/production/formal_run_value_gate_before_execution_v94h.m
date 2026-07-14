function gate = formal_run_value_gate_before_execution_v94h()
% FORMAL_RUN_VALUE_GATE_BEFORE_EXECUTION_v94h
% 9.4h — FORMAL-RUN-VALUE-GATE-BEFORE-EXECUTION-001
%
% Objetivo:
%   Evaluar si conviene ejecutar la corrida formal guardada MR-costo antes
%   de incorporar CO2 y antes de revisar la física de operación del modelo.
%
% Decisión adoptada:
%   CO2 opción A:
%       - CO2 se incorpora como métrica de postproceso.
%       - CO2 no se incorpora todavía como tercer objetivo del AG.
%
% Este micropaso:
%   - NO ejecuta gamultiobj.
%   - NO llama run_guarded_formal_ga_v93g(true).
%   - NO modifica v10 ni v611.
%   - NO modifica la función objetivo guardada v628b.
%   - Genera un gate de valor antes de gastar ~5 h de cómputo.
%
% Salidas:
%   logs/FORMAL_RUN_VALUE_GATE_v94h.md
%   logs/FORMAL_RUN_VALUE_GATE_v94h.txt
%   tables/FORMAL_RUN_VALUE_GATE_v94h_decisions.csv
%   tables/FORMAL_RUN_VALUE_GATE_v94h_CO2_option_A.csv
%   tables/FORMAL_RUN_VALUE_GATE_v94h_prerequisites.csv
%   mat/FORMAL_RUN_VALUE_GATE_v94h.mat
%
% Uso:
%   gate = formal_run_value_gate_before_execution_v94h();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Cargar aprobación v94g
    % ---------------------------------------------------------------------
    approvalBaseDir = fullfile(rootDir,'05_runs','guarded_formal_approval_v94g');

    if ~isfolder(approvalBaseDir)
        error('No existe approvalBaseDir: %s', approvalBaseDir);
    end

    d = dir(approvalBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'GUARDED_FORMAL_RUN_EXECUTION_APPROVAL_v94g_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró aprobación v94g.');
    end

    [~,idxApproval] = max([d.datenum]);
    approvalDir = fullfile(approvalBaseDir,d(idxApproval).name);
    approvalMat = fullfile(approvalDir,'mat','GUARDED_FORMAL_RUN_EXECUTION_APPROVAL_v94g.mat');

    if ~isfile(approvalMat)
        error('No existe MAT de aprobación v94g: %s', approvalMat);
    end

    Sapproval = load(approvalMat);

    if ~isfield(Sapproval,'diagnosis')
        error('v94g no contiene diagnosis.');
    end

    if ~strcmp(string(Sapproval.diagnosis),"GUARDED_FORMAL_RUN_EXECUTION_APPROVAL_PASS")
        error('v94g no está en PASS. Diagnosis: %s', string(Sapproval.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Cargar diseño v92g
    % ---------------------------------------------------------------------
    designBaseDir = fullfile(rootDir,'05_runs','guarded_formal_design_v92g');

    if ~isfolder(designBaseDir)
        error('No existe designBaseDir: %s', designBaseDir);
    end

    d2 = dir(designBaseDir);
    d2 = d2([d2.isdir]);
    d2 = d2(~ismember({d2.name},{'.','..','.MATLABDriveTag'}));

    keep2 = false(size(d2));
    for i = 1:numel(d2)
        keep2(i) = startsWith(d2(i).name,'GUARDED_FORMAL_RUN_DESIGN_v92g_');
    end
    d2 = d2(keep2);

    if isempty(d2)
        error('No se encontró diseño v92g.');
    end

    [~,idxDesign] = max([d2.datenum]);
    designDir = fullfile(designBaseDir,d2(idxDesign).name);
    designMat = fullfile(designDir,'mat','GUARDED_FORMAL_RUN_DESIGN_v92g.mat');

    if ~isfile(designMat)
        error('No existe MAT de diseño v92g: %s', designMat);
    end

    Sdesign = load(designMat);

    if ~strcmp(string(Sdesign.diagnosis),"GUARDED_FORMAL_RUN_DESIGN_PASS")
        error('v92g no está en PASS. Diagnosis: %s', string(Sdesign.diagnosis));
    end

    formalDesign = Sdesign.formalDesign;
    Tpending_v92g = Sdesign.Tpending;

    % ---------------------------------------------------------------------
    % Cargar realineamiento v634 si existe
    % ---------------------------------------------------------------------
    productiveBaseDir = fullfile(rootDir,'05_runs','productive_v614b');
    latestProductiveDir = "";

    if isfolder(productiveBaseDir)
        dp = dir(productiveBaseDir);
        dp = dp([dp.isdir]);
        dp = dp(~ismember({dp.name},{'.','..','.MATLABDriveTag'}));

        keepP = false(size(dp));
        for i = 1:numel(dp)
            keepP(i) = startsWith(dp(i).name,'PRODUCTIVE_GA_CORRECTED_v614_');
        end
        dp = dp(keepP);

        if ~isempty(dp)
            [~,idxP] = max([dp.datenum]);
            latestProductiveDir = string(fullfile(productiveBaseDir,dp(idxP).name));
        end
    end

    mat634 = "";
    masterRealignmentStatus = "NOT_FOUND";

    if strlength(latestProductiveDir) > 0
        candidate634 = fullfile(latestProductiveDir,'mat','MASTER_PLAN_REALIGNMENT_AUDIT_v634.mat');
        if isfile(candidate634)
            mat634 = string(candidate634);
            S634 = load(candidate634);
            if isfield(S634,'diagnosis')
                masterRealignmentStatus = string(S634.diagnosis);
            else
                masterRealignmentStatus = "FOUND_WITHOUT_DIAGNOSIS";
            end
        end
    end

    % ---------------------------------------------------------------------
    % Carpeta de gate
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    gateBaseDir = fullfile(rootDir,'05_runs','formal_value_gate_v94h');
    gateDir = fullfile(gateBaseDir,['FORMAL_RUN_VALUE_GATE_v94h_' timestamp]);

    logsDir = fullfile(gateDir,'logs');
    tablesDir = fullfile(gateDir,'tables');
    matDir = fullfile(gateDir,'mat');

    if ~isfolder(gateBaseDir), mkdir(gateBaseDir); end
    if ~isfolder(gateDir), mkdir(gateDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Datos heredados de aprobación
    % ---------------------------------------------------------------------
    launchCommand = string(Sapproval.launchCommand);
    estimatedHours = Sapproval.estimatedHours;
    PopulationSize = Sapproval.PopulationSize;
    MaxGenerations = Sapproval.MaxGenerations;
    estimatedEvaluations = Sapproval.estimatedEvaluations;
    objectiveName = string(Sapproval.objectiveName);
    modeToRun = string(Sapproval.modeToRun);

    % ---------------------------------------------------------------------
    % Decisiones de valor
    % ---------------------------------------------------------------------
    decisionRows = {};

    row = struct();
    row.id = "D01";
    row.question = "Does the approved MR-cost guarded run have value?";
    row.answer = "YES_WITH_LIMITED_SCOPE";
    row.decision = "Keep run design but pause execution until prerequisites pass.";
    row.rationale = "It can produce a guarded MR-cost Pareto set for hybrid operation, but cannot close CO2 or full physics claims.";
    decisionRows{end+1,1} = row;

    row = struct();
    row.id = "D02";
    row.question = "Should CO2 be added before running as third GA objective?";
    row.answer = "NO_FOR_NOW_OPTION_A_SELECTED";
    row.decision = "Use CO2 as postprocess metric, not as third objective.";
    row.rationale = "This avoids redesigning the GA immediately and allows emissions evaluation over the MR-cost Pareto set.";
    decisionRows{end+1,1} = row;

    row = struct();
    row.id = "D03";
    row.question = "Can article claim MR-cost-CO2 multiobjective optimization after this run?";
    row.answer = "NO";
    row.decision = "Do not claim 3-objective optimization.";
    row.rationale = "CO2 is not part of the objective vector under option A.";
    decisionRows{end+1,1} = row;

    row = struct();
    row.id = "D04";
    row.question = "Can article report CO2 after this run?";
    row.answer = "YES_IF_POSTPROCESS_IS_IMPLEMENTED_AND_VALIDATED";
    row.decision = "Report CO2 only as postprocessed emission metric.";
    row.rationale = "Each Pareto solution can be re-evaluated and assigned CO2 using traceable factors.";
    decisionRows{end+1,1} = row;

    row = struct();
    row.id = "D05";
    row.question = "Can the formal run be launched immediately?";
    row.answer = "NOT_YET";
    row.decision = "Hold execution until 9.5g and 9.6g are completed.";
    row.rationale = "A minimal physics audit and CO2 postprocess design protect the value of the multi-hour run.";
    decisionRows{end+1,1} = row;

    Tdecisions = struct2table(vertcat(decisionRows{:}));

    % ---------------------------------------------------------------------
    % CO2 opción A
    % ---------------------------------------------------------------------
    co2Rows = {};

    row = struct();
    row.item = "CO2_role";
    row.value = "postprocess_metric";
    row.description = "CO2 will be calculated after the MR-cost GA for each selected Pareto solution.";
    row.blocks_execution = false;
    co2Rows{end+1,1} = row;

    row = struct();
    row.item = "CO2_not_objective";
    row.value = "true";
    row.description = "CO2 is not included in f = [MR, cost] for this formal run.";
    row.blocks_execution = false;
    co2Rows{end+1,1} = row;

    row = struct();
    row.item = "CO2_claim_allowed";
    row.value = "only_as_postprocessed_metric_after_validation";
    row.description = "The paper may say emissions were estimated for Pareto candidates, not optimized as a third objective.";
    row.blocks_execution = true;
    co2Rows{end+1,1} = row;

    row = struct();
    row.item = "required_inputs";
    row.value = "Q_aux_tot, electricity use, gas-LP emission factor, electricity emission factor, water removed";
    row.description = "These fields must be extracted or computed from the objective/detail outputs.";
    row.blocks_execution = true;
    co2Rows{end+1,1} = row;

    row = struct();
    row.item = "required_outputs";
    row.value = "CO2_batch, CO2_per_kg_water, CO2_breakdown_GLP_electricity";
    row.description = "CO2 output must be stored in tables and MAT files.";
    row.blocks_execution = true;
    co2Rows{end+1,1} = row;

    row = struct();
    row.item = "next_micropaso";
    row.value = "9.6g_CO2_POSTPROCESS_DESIGN_OPTION_A";
    row.description = "Prepare the CO2 postprocess before launching the formal run or before consolidating its outputs.";
    row.blocks_execution = true;
    co2Rows{end+1,1} = row;

    Tco2 = struct2table(vertcat(co2Rows{:}));

    % ---------------------------------------------------------------------
    % Prerrequisitos antes de ejecutar
    % ---------------------------------------------------------------------
    prereqRows = {};

    row = struct();
    row.id = "P01";
    row.prerequisite = "9.4g execution approval";
    row.required_state = "PASS";
    row.current_state = string(Sapproval.diagnosis);
    row.completed = strcmp(string(Sapproval.diagnosis),"GUARDED_FORMAL_RUN_EXECUTION_APPROVAL_PASS");
    row.blocks_execution = true;
    prereqRows{end+1,1} = row;

    row = struct();
    row.id = "P02";
    row.prerequisite = "Minimal physics operation audit for gasLP/hybrid";
    row.required_state = "PASS";
    row.current_state = "PENDING";
    row.completed = false;
    row.blocks_execution = true;
    prereqRows{end+1,1} = row;

    row = struct();
    row.id = "P03";
    row.prerequisite = "CO2 postprocess design option A";
    row.required_state = "PASS";
    row.current_state = "PENDING";
    row.completed = false;
    row.blocks_execution = true;
    prereqRows{end+1,1} = row;

    row = struct();
    row.id = "P04";
    row.prerequisite = "CO2 claim restriction";
    row.required_state = "ACKNOWLEDGED";
    row.current_state = "ACKNOWLEDGED_OPTION_A";
    row.completed = true;
    row.blocks_execution = false;
    prereqRows{end+1,1} = row;

    row = struct();
    row.id = "P05";
    row.prerequisite = "Solar exclusion";
    row.required_state = "ACKNOWLEDGED";
    row.current_state = "ACKNOWLEDGED_SOLAR_EXCLUDED";
    row.completed = true;
    row.blocks_execution = false;
    prereqRows{end+1,1} = row;

    row = struct();
    row.id = "P06";
    row.prerequisite = "Article finalization restriction";
    row.required_state = "ACKNOWLEDGED";
    row.current_state = "ACKNOWLEDGED_DRAFTS_CONDITIONAL";
    row.completed = true;
    row.blocks_execution = false;
    prereqRows{end+1,1} = row;

    Tprereq = struct2table(vertcat(prereqRows{:}));

    % ---------------------------------------------------------------------
    % Auditoría física mínima requerida antes de gastar 5 h
    % ---------------------------------------------------------------------
    physicsRows = {};

    row = struct();
    row.id = "F01";
    row.check = "hybrid_uses_solar_input";
    row.required_evidence = "Irradiacion > 0 for hybrid preflight and selected solution";
    row.status = "already_supported_but_recheck_in_9.5g";
    physicsRows{end+1,1} = row;

    row = struct();
    row.id = "F02";
    row.check = "gasLP_hybrid_physical_domain";
    row.required_evidence = "No nonphysical guard violations in gasLP/hybrid";
    row.status = "already_supported_but_recheck_in_9.5g";
    physicsRows{end+1,1} = row;

    row = struct();
    row.id = "F03";
    row.check = "auxiliary_control_logic";
    row.required_evidence = "Hybrid auxiliary energy decreases relative to gasLP while drying target remains comparable";
    row.status = "pending_9.5g";
    physicsRows{end+1,1} = row;

    row = struct();
    row.id = "F04";
    row.check = "recirculation_logic";
    row.required_evidence = "r_div2 and t_rec_ini are applied consistently and do not create artificial endpoint";
    row.status = "pending_9.5g";
    physicsRows{end+1,1} = row;

    row = struct();
    row.id = "F05";
    row.check = "drying_endpoint_logic";
    row.required_evidence = "MR and M endpoint are computed from physical final state, not from preallocated/min artifacts";
    row.status = "pending_9.5g";
    physicsRows{end+1,1} = row;

    row = struct();
    row.id = "F06";
    row.check = "solar_branch_not_reintroduced";
    row.required_evidence = "Pure solar remains excluded until branch revalidation";
    row.status = "acknowledged";
    physicsRows{end+1,1} = row;

    Tphysics = struct2table(vertcat(physicsRows{:}));

    % ---------------------------------------------------------------------
    % Gate flags y dictamen
    % ---------------------------------------------------------------------
    gateFlags = struct();
    gateFlags.v94g_approval_pass = strcmp(string(Sapproval.diagnosis),"GUARDED_FORMAL_RUN_EXECUTION_APPROVAL_PASS");
    gateFlags.CO2_option_A_selected = true;
    gateFlags.CO2_as_postprocess_metric = true;
    gateFlags.CO2_as_third_objective = false;
    gateFlags.MR_cost_formal_run_still_useful = true;
    gateFlags.physics_minimal_audit_pending = true;
    gateFlags.CO2_postprocess_design_pending = true;
    gateFlags.execute_formal_now = false;
    gateFlags.hold_execution_until_prerequisites = true;
    gateFlags.article_final_claims_still_blocked = true;

    blockingPrereq = Tprereq.blocks_execution & ~Tprereq.completed;
    gateFlags.blocking_prerequisites_exist = any(blockingPrereq);

    if gateFlags.v94g_approval_pass && ...
       gateFlags.CO2_option_A_selected && ...
       gateFlags.MR_cost_formal_run_still_useful && ...
       gateFlags.hold_execution_until_prerequisites && ...
       gateFlags.blocking_prerequisites_exist

        diagnosis = "FORMAL_RUN_VALUE_GATE_PASS_HOLD_EXECUTION";
    else
        diagnosis = "FORMAL_RUN_VALUE_GATE_REQUIRES_REVIEW";
    end

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'FORMAL_RUN_VALUE_GATE_v94h.md');
    outTxt = fullfile(logsDir,'FORMAL_RUN_VALUE_GATE_v94h.txt');
    outMat = fullfile(matDir,'FORMAL_RUN_VALUE_GATE_v94h.mat');

    outDecisionsCsv = fullfile(tablesDir,'FORMAL_RUN_VALUE_GATE_v94h_decisions.csv');
    outCO2Csv = fullfile(tablesDir,'FORMAL_RUN_VALUE_GATE_v94h_CO2_option_A.csv');
    outPrereqCsv = fullfile(tablesDir,'FORMAL_RUN_VALUE_GATE_v94h_prerequisites.csv');
    outPhysicsCsv = fullfile(tablesDir,'FORMAL_RUN_VALUE_GATE_v94h_minimal_physics_audit_scope.csv');

    writetable(Tdecisions,outDecisionsCsv);
    writetable(Tco2,outCO2Csv);
    writetable(Tprereq,outPrereqCsv);
    writetable(Tphysics,outPhysicsCsv);

    save(outMat, ...
        'diagnosis','gateFlags','launchCommand', ...
        'formalDesign','PopulationSize','MaxGenerations','estimatedEvaluations','estimatedHours', ...
        'objectiveName','modeToRun', ...
        'Tdecisions','Tco2','Tprereq','Tphysics','Tpending_v92g', ...
        'approvalDir','designDir','gateDir','latestProductiveDir','mat634','masterRealignmentStatus', ...
        'outMd','outTxt','outMat','outDecisionsCsv','outCO2Csv','outPrereqCsv','outPhysicsCsv');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# FORMAL_RUN_VALUE_GATE_v94h\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Este gate evalúa si conviene ejecutar ahora la corrida formal guardada aprobada en 9.4g.\n\n');

    fprintf(fid,'## Decisión principal\n\n');
    fprintf(fid,'La corrida formal MR-costo sigue siendo útil, pero la ejecución queda en pausa. Antes de gastar aproximadamente %.6g h, deben cerrarse dos prerrequisitos: auditoría física mínima de gasLP/hybrid y diseño de postproceso CO2 opción A.\n\n', estimatedHours);

    fprintf(fid,'## CO2 opción A\n\n');
    fprintf(fid,'Se adopta CO2 como métrica de postproceso. Esto permite evaluar emisiones sobre las soluciones del Pareto MR-costo, pero no permite afirmar que CO2 fue optimizado como tercer objetivo.\n\n');

    fprintf(fid,'| Item | Valor | Descripción | Bloquea ejecución |\n');
    fprintf(fid,'|---|---|---|---:|\n');

    for i = 1:height(Tco2)
        fprintf(fid,'| `%s` | `%s` | %s | `%d` |\n', ...
            string(Tco2.item(i)), ...
            string(Tco2.value(i)), ...
            string(Tco2.description(i)), ...
            Tco2.blocks_execution(i));
    end

    fprintf(fid,'\n## Decisiones\n\n');
    fprintf(fid,'| ID | Pregunta | Respuesta | Decisión | Justificación |\n');
    fprintf(fid,'|---|---|---|---|---|\n');

    for i = 1:height(Tdecisions)
        fprintf(fid,'| `%s` | %s | `%s` | %s | %s |\n', ...
            string(Tdecisions.id(i)), ...
            string(Tdecisions.question(i)), ...
            string(Tdecisions.answer(i)), ...
            string(Tdecisions.decision(i)), ...
            string(Tdecisions.rationale(i)));
    end

    fprintf(fid,'\n## Prerrequisitos antes de ejecutar\n\n');
    fprintf(fid,'| ID | Prerrequisito | Estado requerido | Estado actual | Completado | Bloquea ejecución |\n');
    fprintf(fid,'|---|---|---|---|---:|---:|\n');

    for i = 1:height(Tprereq)
        fprintf(fid,'| `%s` | %s | `%s` | `%s` | `%d` | `%d` |\n', ...
            string(Tprereq.id(i)), ...
            string(Tprereq.prerequisite(i)), ...
            string(Tprereq.required_state(i)), ...
            string(Tprereq.current_state(i)), ...
            Tprereq.completed(i), ...
            Tprereq.blocks_execution(i));
    end

    fprintf(fid,'\n## Alcance de auditoría física mínima requerida\n\n');
    fprintf(fid,'| ID | Revisión | Evidencia requerida | Estado |\n');
    fprintf(fid,'|---|---|---|---|\n');

    for i = 1:height(Tphysics)
        fprintf(fid,'| `%s` | `%s` | %s | `%s` |\n', ...
            string(Tphysics.id(i)), ...
            string(Tphysics.check(i)), ...
            string(Tphysics.required_evidence(i)), ...
            string(Tphysics.status(i)));
    end

    fprintf(fid,'\n## Configuración formal retenida\n\n');
    fprintf(fid,'| Campo | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| Modo | `%s` |\n', modeToRun);
    fprintf(fid,'| Objetivo | `%s` |\n', objectiveName);
    fprintf(fid,'| PopulationSize | %.0f |\n', PopulationSize);
    fprintf(fid,'| MaxGenerations | %.0f |\n', MaxGenerations);
    fprintf(fid,'| Evaluaciones estimadas | %.0f |\n', estimatedEvaluations);
    fprintf(fid,'| Tiempo estimado con margen [h] | %.6g |\n\n', estimatedHours);

    fprintf(fid,'## Comando retenido, no ejecutar todavía\n\n');
    fprintf(fid,'```matlab\n%s\n```\n\n', launchCommand);

    fprintf(fid,'## Dictamen\n\n');
    fprintf(fid,'No se ejecuta la corrida formal todavía. El diseño queda vivo, pero la ejecución se libera únicamente después de cerrar 9.5g y 9.6g.\n\n');

    fprintf(fid,'## Siguientes micropasos\n\n');
    fprintf(fid,'1. `9.5g — MINIMAL-PHYSICS-OPERATION-AUDIT-BEFORE-FORMAL-RUN-001`\n');
    fprintf(fid,'2. `9.6g — CO2-POSTPROCESS-DESIGN-OPTION-A-001`\n');
    fprintf(fid,'3. `9.7g — FORMAL-RUN-GO-NOGO-AFTER-PHYSICS-CO2-GATE-001`\n\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % TXT ejecutivo
    % ---------------------------------------------------------------------
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'FORMAL-RUN-VALUE-GATE-BEFORE-EXECUTION-001\n');
    fprintf(fid,'status: FORMAL_RUN_VALUE_GATE_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'CO2_option_A_selected: %d\n', gateFlags.CO2_option_A_selected);
    fprintf(fid,'CO2_as_postprocess_metric: %d\n', gateFlags.CO2_as_postprocess_metric);
    fprintf(fid,'CO2_as_third_objective: %d\n', gateFlags.CO2_as_third_objective);
    fprintf(fid,'MR_cost_formal_run_still_useful: %d\n', gateFlags.MR_cost_formal_run_still_useful);
    fprintf(fid,'execute_formal_now: %d\n', gateFlags.execute_formal_now);
    fprintf(fid,'hold_execution_until_prerequisites: %d\n', gateFlags.hold_execution_until_prerequisites);
    fprintf(fid,'blocking_prerequisites_exist: %d\n', gateFlags.blocking_prerequisites_exist);
    fprintf(fid,'launchCommand_retained: %s\n', launchCommand);
    fprintf(fid,'estimatedHours: %.6g\n', estimatedHours);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'NEXT:\n');
    fprintf(fid,'9.5g — MINIMAL-PHYSICS-OPERATION-AUDIT-BEFORE-FORMAL-RUN-001\n');
    fprintf(fid,'9.6g — CO2-POSTPROCESS-DESIGN-OPTION-A-001\n');
    fprintf(fid,'9.7g — FORMAL-RUN-GO-NOGO-AFTER-PHYSICS-CO2-GATE-001\n\n');

    fprintf(fid,'OUTPUTS:\n');
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'outDecisionsCsv: %s\n', outDecisionsCsv);
    fprintf(fid,'outCO2Csv: %s\n', outCO2Csv);
    fprintf(fid,'outPrereqCsv: %s\n', outPrereqCsv);
    fprintf(fid,'outPhysicsCsv: %s\n', outPhysicsCsv);

    fclose(fid);

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    gate = struct();
    gate.status = 'FORMAL_RUN_VALUE_GATE_COMPLETED';
    gate.diagnosis = diagnosis;
    gate.gateFlags = gateFlags;
    gate.launchCommand = launchCommand;
    gate.formalDesign = formalDesign;
    gate.PopulationSize = PopulationSize;
    gate.MaxGenerations = MaxGenerations;
    gate.estimatedEvaluations = estimatedEvaluations;
    gate.estimatedHours = estimatedHours;
    gate.objectiveName = objectiveName;
    gate.modeToRun = modeToRun;
    gate.Tdecisions = Tdecisions;
    gate.Tco2 = Tco2;
    gate.Tprereq = Tprereq;
    gate.Tphysics = Tphysics;
    gate.approvalDir = approvalDir;
    gate.designDir = designDir;
    gate.gateDir = gateDir;
    gate.outMd = outMd;
    gate.outTxt = outTxt;
    gate.outMat = outMat;
    gate.outDecisionsCsv = outDecisionsCsv;
    gate.outCO2Csv = outCO2Csv;
    gate.outPrereqCsv = outPrereqCsv;
    gate.outPhysicsCsv = outPhysicsCsv;

    disp('=== FORMAL_RUN_VALUE_GATE_v94h ===')
    disp(gate.status)
    disp('=== DIAGNOSIS ===')
    disp(gate.diagnosis)
    disp('=== GATE FLAGS ===')
    disp(gate.gateFlags)
    disp('=== CO2 OPTION A ===')
    disp(gate.Tco2)
    disp('=== PREREQUISITES ===')
    disp(gate.Tprereq)
    disp('=== MINIMAL PHYSICS AUDIT SCOPE ===')
    disp(gate.Tphysics)
    disp('=== RETAINED LAUNCH COMMAND, DO NOT EXECUTE YET ===')
    disp(gate.launchCommand)
    disp('=== OUTPUT FILES ===')
    disp(gate.outMd)
    disp(gate.outTxt)
    disp(gate.outMat)
end