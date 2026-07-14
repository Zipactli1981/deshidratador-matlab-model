function gate = co2_objective_reintegration_decision_gate_v96gbis()
% CO2_OBJECTIVE_REINTEGRATION_DECISION_GATE_v96gbis
% 9.6g-bis — CO2-OBJECTIVE-REINTEGRATION-DECISION-GATE-001
%
% Objetivo:
%   Decidir si CO2 debe permanecer como postproceso o reintegrarse como
%   tercera función objetivo f(3) antes de la corrida formal.
%
% Contexto:
%   9.5k aprobó física mínima con objetivo corregido v95j.
%   9.6g aprobó CO2 opción A como postproceso, no como tercer objetivo.
%   El usuario recuerda que el planteamiento original contemplaba 3 objetivos.
%
% Este micropaso:
%   - NO ejecuta gamultiobj.
%   - NO modifica v10/v17/v628b/v18/v95j.
%   - NO implementa CO2.
%   - NO libera corrida formal.
%   - Decide ruta metodológica:
%       Ruta A: MR-costo + CO2 postproceso.
%       Ruta B: MR-costo-CO2 como optimización triobjetivo.
%
% Salidas:
%   logs/CO2_OBJECTIVE_REINTEGRATION_DECISION_GATE_v96gbis.md
%   logs/CO2_OBJECTIVE_REINTEGRATION_DECISION_GATE_v96gbis.txt
%   tables/CO2_OBJECTIVE_REINTEGRATION_DECISION_GATE_v96gbis_routes.csv
%   tables/CO2_OBJECTIVE_REINTEGRATION_DECISION_GATE_v96gbis_requirements.csv
%   tables/CO2_OBJECTIVE_REINTEGRATION_DECISION_GATE_v96gbis_claims.csv
%   mat/CO2_OBJECTIVE_REINTEGRATION_DECISION_GATE_v96gbis.mat
%
% Uso:
%   gate = co2_objective_reintegration_decision_gate_v96gbis();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

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
    % Cargar 9.6g
    % ---------------------------------------------------------------------
    co2DesignBaseDir = fullfile(rootDir,'05_runs','co2_postprocess_design_v96g');

    if ~isfolder(co2DesignBaseDir)
        error('No existe co2DesignBaseDir: %s', co2DesignBaseDir);
    end

    dc = dir(co2DesignBaseDir);
    dc = dc([dc.isdir]);
    dc = dc(~ismember({dc.name},{'.','..','.MATLABDriveTag'}));

    keepC = false(size(dc));
    for i = 1:numel(dc)
        keepC(i) = startsWith(dc(i).name,'CO2_POSTPROCESS_DESIGN_OPTION_A_v96g_');
    end
    dc = dc(keepC);

    if isempty(dc)
        error('No se encontró diseño CO2 v96g.');
    end

    [~,idxCO2] = max([dc.datenum]);
    co2DesignDir = fullfile(co2DesignBaseDir,dc(idxCO2).name);
    co2DesignMat = fullfile(co2DesignDir,'mat','CO2_POSTPROCESS_DESIGN_OPTION_A_v96g.mat');

    if ~isfile(co2DesignMat)
        error('No existe MAT v96g: %s', co2DesignMat);
    end

    S96g = load(co2DesignMat);

    if ~strcmp(string(S96g.diagnosis),"CO2_POSTPROCESS_DESIGN_OPTION_A_PASS")
        error('v96g no está en PASS. Diagnosis: %s', string(S96g.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Archivos relevantes
    % ---------------------------------------------------------------------
    objective_v95j = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v95j_endpoint_TMAX_corrected.m');
    wrapper_v18 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v18_endpoint_TMAX_corrected.m');

    if ~isfile(objective_v95j)
        error('No existe objective v95j: %s', objective_v95j);
    end

    if ~isfile(wrapper_v18)
        error('No existe wrapper v18: %s', wrapper_v18);
    end

    txtObj = fileread(objective_v95j);

    has_two_objective_signature = contains(txtObj,'f = [') || contains(txtObj,'f(1)') || contains(txtObj,'f(2)');
    has_explicit_f3 = contains(txtObj,'f(3)') || contains(txtObj,'CO2') || contains(txtObj,'co2');

    % Nota: has_explicit_f3 puede detectar texto de comentarios/metadatos si existiera.
    % El dictamen se basa en el diseño formal v96g y en el vector objetivo auditado,
    % no solo en búsqueda textual.

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    gateBaseDir = fullfile(rootDir,'05_runs','co2_objective_reintegration_gate_v96gbis');
    gateDir = fullfile(gateBaseDir,['CO2_OBJECTIVE_REINTEGRATION_DECISION_GATE_v96gbis_' timestamp]);

    logsDir = fullfile(gateDir,'logs');
    tablesDir = fullfile(gateDir,'tables');
    matDir = fullfile(gateDir,'mat');

    if ~isfolder(gateBaseDir), mkdir(gateBaseDir); end
    if ~isfolder(gateDir), mkdir(gateDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Evaluar solución seleccionada para verificar tamaño de f actual
    % ---------------------------------------------------------------------
    x_selected = [ ...
        0.0740767982118, ...
        62.6832965028, ...
        0.672252618341, ...
        11.6517528081];

    [f_hybrid, d_hybrid] = objective_productive_corrected_v95j_endpoint_TMAX_corrected(x_selected,"hybrid");
    [f_gas, d_gas] = objective_productive_corrected_v95j_endpoint_TMAX_corrected(x_selected,"gasLP");

    f_hybrid = double(f_hybrid(:))';
    f_gas = double(f_gas(:))';

    current_nobj_hybrid = numel(f_hybrid);
    current_nobj_gas = numel(f_gas);

    current_objective_is_two_objective = current_nobj_hybrid == 2 && current_nobj_gas == 2;
    current_objective_is_three_objective = current_nobj_hybrid == 3 && current_nobj_gas == 3;

    % ---------------------------------------------------------------------
    % Tabla de rutas
    % ---------------------------------------------------------------------
    routeRows = {};

    row = struct();
    row.route = "A";
    row.name = "MR_cost_with_CO2_postprocess";
    row.objective_vector = "f=[MR,cost]";
    row.CO2_role = "postprocess_metric";
    row.methodological_status = "already_supported_by_v95k_and_v96g";
    row.requires_new_objective = false;
    row.requires_new_smoke_GA = false;
    row.requires_new_formal_script = true;
    row.expected_runtime_risk = "low_to_medium";
    row.claim_allowed = "MR-cost optimization with postprocessed CO2 assessment.";
    row.claim_not_allowed = "Triobjective MR-cost-CO2 optimization.";
    row.recommendation = "safe_conservative_route";
    routeRows{end+1,1} = row;

    row = struct();
    row.route = "B";
    row.name = "MR_cost_CO2_triobjective";
    row.objective_vector = "f=[MR,cost,CO2]";
    row.CO2_role = "third_objective";
    row.methodological_status = "not_yet_supported_by_current_guarded_route";
    row.requires_new_objective = true;
    row.requires_new_smoke_GA = true;
    row.requires_new_formal_script = true;
    row.expected_runtime_risk = "medium_to_high";
    row.claim_allowed = "Triobjective optimization only after full re-audit.";
    row.claim_not_allowed = "Use current v95j/v96g evidence as if it were triobjective.";
    row.recommendation = "only_if_article_requires_CO2_as_optimization_objective";
    routeRows{end+1,1} = row;

    Troutes = struct2table(vertcat(routeRows{:}));

    % ---------------------------------------------------------------------
    % Requisitos por ruta
    % ---------------------------------------------------------------------
    reqRows = {};

    reqRows{end+1,1} = local_req_row("A01","Route A","Keep objective v95j",true,true,"Use objective_productive_corrected_v95j_endpoint_TMAX_corrected.");
    reqRows{end+1,1} = local_req_row("A02","Route A","Implement CO2 postprocess",true,false,"Compute CO2 after objective evaluation.");
    reqRows{end+1,1} = local_req_row("A03","Route A","Update formal GA script to v95j",true,false,"Current formal script still points to previous objective route.");
    reqRows{end+1,1} = local_req_row("A04","Route A","No triobjective claim",true,true,"Article wording must state postprocessed CO2.");
    reqRows{end+1,1} = local_req_row("A05","Route A","Emission factors referenced",true,false,"Needed before manuscript claims.");

    reqRows{end+1,1} = local_req_row("B01","Route B","Create objective v96h or later with f(3)=CO2",true,false,"Requires explicit CO2 computation inside objective.");
    reqRows{end+1,1} = local_req_row("B02","Route B","Audit units and factors before GA",true,false,"CO2 objective must be numerically stable and documented.");
    reqRows{end+1,1} = local_req_row("B03","Route B","Update all GA storage/history for 3 objectives",true,false,"Tables, plots, history and selection logic must handle 3 columns.");
    reqRows{end+1,1} = local_req_row("B04","Route B","Run new preflight and smoke GA",true,false,"Existing smoke validates 2-objective route only.");
    reqRows{end+1,1} = local_req_row("B05","Route B","Redesign formal run estimates",true,false,"Triobjective GA may require different population/generations.");
    reqRows{end+1,1} = local_req_row("B06","Route B","Rebuild article claim package",true,false,"Only then can triobjective claims be allowed.");

    Trequirements = struct2table(vertcat(reqRows{:}));

    % ---------------------------------------------------------------------
    % Reglas de afirmación
    % ---------------------------------------------------------------------
    claimRows = {};

    claimRows{end+1,1} = local_claim_row("CL01","Current evidence","Allowed","The corrected model supports MR-cost optimization with CO2 postprocessing.");
    claimRows{end+1,1} = local_claim_row("CL02","Current evidence","Not allowed","The current formal route supports triobjective optimization.");
    claimRows{end+1,1} = local_claim_row("CL03","Route A","Allowed","CO2 may be reported as estimated emissions for Pareto candidates.");
    claimRows{end+1,1} = local_claim_row("CL04","Route A","Not allowed","Do not call the MR-cost front a CO2 Pareto front.");
    claimRows{end+1,1} = local_claim_row("CL05","Route B","Conditionally allowed","Triobjective claims require new objective, smoke, formal run and consolidation.");
    claimRows{end+1,1} = local_claim_row("CL06","All routes","Not allowed","Pure solar environmental superiority remains blocked until solar branch revalidation.");

    Tclaims = struct2table(vertcat(claimRows{:}));

    % ---------------------------------------------------------------------
    % Decisión recomendada
    % ---------------------------------------------------------------------
    % Regla de decisión:
    %   Si el objetivo actual es de 2 componentes y v96g ya aprobó CO2 como
    %   postproceso, se recomienda Ruta A salvo que el usuario exija que el
    %   artículo sostenga optimización triobjetivo.
    %
    % Este gate NO decide por preferencia estética, sino por seguridad
    % metodológica y costo de reabrir controles.

    gateFlags = struct();
    gateFlags.v95k_pass = strcmp(string(S95k.diagnosis),"MINIMAL_PHYSICS_AUDIT_RECHECK_PASS_WITH_TMAX_CORRECTION");
    gateFlags.v96g_pass = strcmp(string(S96g.diagnosis),"CO2_POSTPROCESS_DESIGN_OPTION_A_PASS");
    gateFlags.current_objective_is_two_objective = current_objective_is_two_objective;
    gateFlags.current_objective_is_three_objective = current_objective_is_three_objective;
    gateFlags.current_objective_hybrid_nobj = current_nobj_hybrid;
    gateFlags.current_objective_gasLP_nobj = current_nobj_gas;
    gateFlags.CO2_already_supported_as_postprocess = S96g.designFlags.CO2_as_postprocess_metric;
    gateFlags.CO2_not_supported_as_third_objective_yet = ~S96g.designFlags.CO2_as_third_objective;
    gateFlags.triobjective_claim_currently_blocked = ~S96g.designFlags.triobjective_claim_allowed;
    gateFlags.route_A_available_now = gateFlags.v95k_pass && gateFlags.v96g_pass && current_objective_is_two_objective;
    gateFlags.route_B_requires_refactor = true;
    gateFlags.no_GA_executed = true;
    gateFlags.formal_run_still_on_hold = true;

    if gateFlags.route_A_available_now && gateFlags.route_B_requires_refactor
        recommendedRoute = "A";
        decision = "KEEP_CO2_AS_POSTPROCESS_UNLESS_USER_EXPLICITLY_SELECTS_TRIOBJECTIVE_REFACTOR";
        diagnosis = "CO2_OBJECTIVE_REINTEGRATION_GATE_PASS_ROUTE_A_RECOMMENDED";
    else
        recommendedRoute = "REVIEW";
        decision = "REQUIRES_REVIEW";
        diagnosis = "CO2_OBJECTIVE_REINTEGRATION_GATE_REQUIRES_REVIEW";
    end

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'CO2_OBJECTIVE_REINTEGRATION_DECISION_GATE_v96gbis.md');
    outTxt = fullfile(logsDir,'CO2_OBJECTIVE_REINTEGRATION_DECISION_GATE_v96gbis.txt');
    outMat = fullfile(matDir,'CO2_OBJECTIVE_REINTEGRATION_DECISION_GATE_v96gbis.mat');

    outRoutesCsv = fullfile(tablesDir,'CO2_OBJECTIVE_REINTEGRATION_DECISION_GATE_v96gbis_routes.csv');
    outReqCsv = fullfile(tablesDir,'CO2_OBJECTIVE_REINTEGRATION_DECISION_GATE_v96gbis_requirements.csv');
    outClaimsCsv = fullfile(tablesDir,'CO2_OBJECTIVE_REINTEGRATION_DECISION_GATE_v96gbis_claims.csv');

    writetable(Troutes,outRoutesCsv);
    writetable(Trequirements,outReqCsv);
    writetable(Tclaims,outClaimsCsv);

    save(outMat, ...
        'diagnosis','decision','recommendedRoute','gateFlags', ...
        'Troutes','Trequirements','Tclaims', ...
        'x_selected','f_hybrid','f_gas','d_hybrid','d_gas', ...
        'current_nobj_hybrid','current_nobj_gas', ...
        'objective_v95j','wrapper_v18','recheckDir','co2DesignDir','gateDir', ...
        'outMd','outTxt','outMat','outRoutesCsv','outReqCsv','outClaimsCsv');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# CO2_OBJECTIVE_REINTEGRATION_DECISION_GATE_v96gbis\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Decisión: `%s`\n\n', decision);
    fprintf(fid,'Ruta recomendada: `%s`\n\n', recommendedRoute);

    fprintf(fid,'## Hallazgo central\n\n');
    fprintf(fid,'La ruta auditada actual usa una función objetivo de %d componentes para `hybrid` y %d componentes para `gasLP`.\n\n', ...
        current_nobj_hybrid, current_nobj_gas);

    fprintf(fid,'Por tanto, la evidencia actual soporta una optimización MR-costo con evaluación CO2 de postproceso. No soporta todavía una optimización triobjetivo.\n\n');

    fprintf(fid,'## Rutas metodológicas\n\n');
    fprintf(fid,'| Ruta | Nombre | Vector objetivo | Rol de CO2 | Estado metodológico | Requiere nueva función objetivo | Requiere nuevo smoke GA | Recomendación |\n');
    fprintf(fid,'|---|---|---|---|---|---:|---:|---|\n');

    for i = 1:height(Troutes)
        fprintf(fid,'| `%s` | `%s` | `%s` | `%s` | `%s` | `%d` | `%d` | `%s` |\n', ...
            string(Troutes.route(i)), ...
            string(Troutes.name(i)), ...
            string(Troutes.objective_vector(i)), ...
            string(Troutes.CO2_role(i)), ...
            string(Troutes.methodological_status(i)), ...
            Troutes.requires_new_objective(i), ...
            Troutes.requires_new_smoke_GA(i), ...
            string(Troutes.recommendation(i)));
    end

    fprintf(fid,'\n## Requisitos\n\n');
    fprintf(fid,'| ID | Ruta | Requisito | Obligatorio | Ya satisfecho | Nota |\n');
    fprintf(fid,'|---|---|---|---:|---:|---|\n');

    for i = 1:height(Trequirements)
        fprintf(fid,'| `%s` | `%s` | %s | `%d` | `%d` | %s |\n', ...
            string(Trequirements.id(i)), ...
            string(Trequirements.route(i)), ...
            string(Trequirements.requirement(i)), ...
            Trequirements.required(i), ...
            Trequirements.already_satisfied(i), ...
            string(Trequirements.note(i)));
    end

    fprintf(fid,'\n## Reglas de afirmación\n\n');
    fprintf(fid,'| ID | Alcance | Estado | Afirmación |\n');
    fprintf(fid,'|---|---|---|---|\n');

    for i = 1:height(Tclaims)
        fprintf(fid,'| `%s` | `%s` | `%s` | %s |\n', ...
            string(Tclaims.id(i)), ...
            string(Tclaims.scope(i)), ...
            string(Tclaims.status(i)), ...
            string(Tclaims.claim(i)));
    end

    fprintf(fid,'\n## Dictamen operativo\n\n');

    if recommendedRoute == "A"
        fprintf(fid,'Se recomienda mantener CO2 como postproceso si el objetivo inmediato es liberar una corrida formal defendible. Esta ruta permite sostener optimización MR-costo con análisis posterior de emisiones, pero no permite afirmar optimización triobjetivo.\n\n');
        fprintf(fid,'Si se requiere afirmar optimización MR-costo-CO2, debe abrirse una rama de refactor triobjetivo antes de cualquier corrida formal.\n\n');
    else
        fprintf(fid,'No hay una ruta recomendada automática. Revisar los flags del gate.\n\n');
    end

    fprintf(fid,'## Restricciones activas\n\n');
    fprintf(fid,'- No se ejecutó `gamultiobj`.\n');
    fprintf(fid,'- La corrida formal sigue detenida.\n');
    fprintf(fid,'- CO2 como tercer objetivo sigue bloqueado salvo refactor explícito.\n');
    fprintf(fid,'- Solar puro sigue excluido.\n\n');

    fprintf(fid,'## Siguiente paso según ruta\n\n');
    fprintf(fid,'- Ruta A: `9.6h — CO2-POSTPROCESS-IMPLEMENTATION-OPTION-A-001`.\n');
    fprintf(fid,'- Ruta B: `9.6i — TRI_OBJECTIVE_CO2_REFACTOR_DESIGN-001`.\n\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % TXT ejecutivo
    % ---------------------------------------------------------------------
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'CO2-OBJECTIVE-REINTEGRATION-DECISION-GATE-001\n');
    fprintf(fid,'status: CO2_OBJECTIVE_REINTEGRATION_DECISION_GATE_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'decision: %s\n', decision);
    fprintf(fid,'recommendedRoute: %s\n', recommendedRoute);
    fprintf(fid,'v95k_pass: %d\n', gateFlags.v95k_pass);
    fprintf(fid,'v96g_pass: %d\n', gateFlags.v96g_pass);
    fprintf(fid,'current_objective_is_two_objective: %d\n', gateFlags.current_objective_is_two_objective);
    fprintf(fid,'current_objective_is_three_objective: %d\n', gateFlags.current_objective_is_three_objective);
    fprintf(fid,'current_objective_hybrid_nobj: %d\n', gateFlags.current_objective_hybrid_nobj);
    fprintf(fid,'current_objective_gasLP_nobj: %d\n', gateFlags.current_objective_gasLP_nobj);
    fprintf(fid,'CO2_already_supported_as_postprocess: %d\n', gateFlags.CO2_already_supported_as_postprocess);
    fprintf(fid,'CO2_not_supported_as_third_objective_yet: %d\n', gateFlags.CO2_not_supported_as_third_objective_yet);
    fprintf(fid,'triobjective_claim_currently_blocked: %d\n', gateFlags.triobjective_claim_currently_blocked);
    fprintf(fid,'route_A_available_now: %d\n', gateFlags.route_A_available_now);
    fprintf(fid,'route_B_requires_refactor: %d\n', gateFlags.route_B_requires_refactor);
    fprintf(fid,'no_GA_executed: %d\n', gateFlags.no_GA_executed);
    fprintf(fid,'formal_run_still_on_hold: %d\n', gateFlags.formal_run_still_on_hold);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'OUTPUTS:\n');
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'outRoutesCsv: %s\n', outRoutesCsv);
    fprintf(fid,'outReqCsv: %s\n', outReqCsv);
    fprintf(fid,'outClaimsCsv: %s\n', outClaimsCsv);

    fclose(fid);

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    gate = struct();
    gate.status = 'CO2_OBJECTIVE_REINTEGRATION_DECISION_GATE_COMPLETED';
    gate.diagnosis = diagnosis;
    gate.decision = decision;
    gate.recommendedRoute = recommendedRoute;
    gate.gateFlags = gateFlags;
    gate.Troutes = Troutes;
    gate.Trequirements = Trequirements;
    gate.Tclaims = Tclaims;
    gate.x_selected = x_selected;
    gate.f_hybrid = f_hybrid;
    gate.f_gas = f_gas;
    gate.current_nobj_hybrid = current_nobj_hybrid;
    gate.current_nobj_gas = current_nobj_gas;
    gate.objective_v95j = objective_v95j;
    gate.wrapper_v18 = wrapper_v18;
    gate.recheckDir = recheckDir;
    gate.co2DesignDir = co2DesignDir;
    gate.gateDir = gateDir;
    gate.outMd = outMd;
    gate.outTxt = outTxt;
    gate.outMat = outMat;
    gate.outRoutesCsv = outRoutesCsv;
    gate.outReqCsv = outReqCsv;
    gate.outClaimsCsv = outClaimsCsv;

    disp('=== CO2_OBJECTIVE_REINTEGRATION_DECISION_GATE_v96gbis ===')
    disp(gate.status)
    disp('=== DIAGNOSIS ===')
    disp(gate.diagnosis)
    disp('=== DECISION ===')
    disp(gate.decision)
    disp('=== RECOMMENDED ROUTE ===')
    disp(gate.recommendedRoute)
    disp('=== GATE FLAGS ===')
    disp(gate.gateFlags)
    disp('=== CURRENT OBJECTIVE VALUES ===')
    fprintf('hybrid f size = %d, f = [', gate.current_nobj_hybrid);
    fprintf(' %.12g', gate.f_hybrid);
    fprintf(' ]\n');
    fprintf('gasLP f size = %d, f = [', gate.current_nobj_gas);
    fprintf(' %.12g', gate.f_gas);
    fprintf(' ]\n');
    disp('=== ROUTES ===')
    disp(gate.Troutes)
    disp('=== REQUIREMENTS ===')
    disp(gate.Trequirements)
    disp('=== CLAIM RULES ===')
    disp(gate.Tclaims)
    disp('=== OUTPUT FILES ===')
    disp(gate.outMd)
    disp(gate.outTxt)
    disp(gate.outMat)

end

% =========================================================================
% Local helpers
% =========================================================================

function row = local_req_row(id, route, requirement, required, already_satisfied, note)
    row = struct();
    row.id = string(id);
    row.route = string(route);
    row.requirement = string(requirement);
    row.required = logical(required);
    row.already_satisfied = logical(already_satisfied);
    row.note = string(note);
end

function row = local_claim_row(id, scope, status, claim)
    row = struct();
    row.id = string(id);
    row.scope = string(scope);
    row.status = string(status);
    row.claim = string(claim);
end