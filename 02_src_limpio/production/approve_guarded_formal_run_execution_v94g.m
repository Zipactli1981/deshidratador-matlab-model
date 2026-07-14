function approval = approve_guarded_formal_run_execution_v94g()
% APPROVE_GUARDED_FORMAL_RUN_EXECUTION_v94g
% 9.4g — GUARDED-FORMAL-RUN-EXECUTION-APPROVAL-001
%
% Objetivo:
%   Emitir aprobación operativa para ejecutar la corrida formal guardada.
%
% Este micropaso:
%   - NO ejecuta gamultiobj.
%   - NO llama run_guarded_formal_ga_v93g(true).
%   - Genera documento de aprobación.
%   - Define comando único de lanzamiento.
%   - Define condiciones de monitoreo e interrupción.
%
% Requiere:
%   - 9.1g smoke PASS
%   - 9.2g design PASS
%   - 9.3g script ready no execution
%
% Salidas:
%   logs/GUARDED_FORMAL_RUN_EXECUTION_APPROVAL_v94g.md
%   logs/GUARDED_FORMAL_RUN_EXECUTION_APPROVAL_v94g.txt
%   tables/GUARDED_FORMAL_RUN_EXECUTION_APPROVAL_v94g_checklist.csv
%   mat/GUARDED_FORMAL_RUN_EXECUTION_APPROVAL_v94g.mat
%
% Uso:
%   approval = approve_guarded_formal_run_execution_v94g();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Validar existencia del script formal v93g
    % ---------------------------------------------------------------------
    formalScript = fullfile(rootDir,'02_src_limpio','production','run_guarded_formal_ga_v93g.m');

    if ~isfile(formalScript)
        error('No existe script formal v93g: %s', formalScript);
    end

    if exist('run_guarded_formal_ga_v93g','file') ~= 2
        error('run_guarded_formal_ga_v93g no está en path.');
    end

    % ---------------------------------------------------------------------
    % Cargar último diseño v92g
    % ---------------------------------------------------------------------
    designBaseDir = fullfile(rootDir,'05_runs','guarded_formal_design_v92g');

    if ~isfolder(designBaseDir)
        error('No existe designBaseDir: %s', designBaseDir);
    end

    d = dir(designBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'GUARDED_FORMAL_RUN_DESIGN_v92g_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró diseño v92g.');
    end

    [~,idxDesign] = max([d.datenum]);
    designDir = fullfile(designBaseDir,d(idxDesign).name);
    designMat = fullfile(designDir,'mat','GUARDED_FORMAL_RUN_DESIGN_v92g.mat');

    if ~isfile(designMat)
        error('No existe MAT de diseño v92g: %s', designMat);
    end

    Sdesign = load(designMat);

    if ~isfield(Sdesign,'diagnosis')
        error('v92g no contiene diagnosis.');
    end

    if ~strcmp(string(Sdesign.diagnosis),"GUARDED_FORMAL_RUN_DESIGN_PASS")
        error('v92g no está en PASS. Diagnosis: %s', string(Sdesign.diagnosis));
    end

    formalDesign = Sdesign.formalDesign;
    Ttime = Sdesign.Ttime;
    Tpending = Sdesign.Tpending;

    % ---------------------------------------------------------------------
    % Cargar última prueba segura v93g
    % ---------------------------------------------------------------------
    formalBaseDir = fullfile(rootDir,'05_runs','guarded_formal_v93g');

    if ~isfolder(formalBaseDir)
        error('No existe formalBaseDir. Ejecutar primero v93g en modo seguro.');
    end

    d2 = dir(formalBaseDir);
    d2 = d2([d2.isdir]);
    d2 = d2(~ismember({d2.name},{'.','..','.MATLABDriveTag'}));

    keep2 = false(size(d2));
    for i = 1:numel(d2)
        keep2(i) = startsWith(d2(i).name,'GUARDED_FORMAL_GA_v93g_');
    end
    d2 = d2(keep2);

    if isempty(d2)
        error('No se encontró carpeta v93g. Ejecutar primero run_guarded_formal_ga_v93g(false).');
    end

    [~,idxFormal] = max([d2.datenum]);
    formalSafeDir = fullfile(formalBaseDir,d2(idxFormal).name);
    formalSafeMat = fullfile(formalSafeDir,'mat','GUARDED_FORMAL_GA_v93g.mat');

    if ~isfile(formalSafeMat)
        error('No existe MAT v93g seguro: %s', formalSafeMat);
    end

    Sformal = load(formalSafeMat);

    if ~isfield(Sformal,'diagnosis') || ~isfield(Sformal,'executionStatus')
        error('v93g seguro no contiene diagnosis/executionStatus.');
    end

    if ~strcmp(string(Sformal.diagnosis),"GUARDED_FORMAL_GA_SCRIPT_READY_NO_EXECUTION")
        error('v93g no está en SCRIPT_READY_NO_EXECUTION. Diagnosis: %s', string(Sformal.diagnosis));
    end

    if ~strcmp(string(Sformal.executionStatus),"CONFIG_READY_NO_EXECUTION")
        error('v93g no está en CONFIG_READY_NO_EXECUTION. executionStatus: %s', string(Sformal.executionStatus));
    end

    if ~isfield(Sformal,'preflightFlags')
        error('v93g no contiene preflightFlags.');
    end

    preflightFlags = Sformal.preflightFlags;

    if ~preflightFlags.preflight_pass
        error('El preflight de v93g no está en PASS.');
    end

    % ---------------------------------------------------------------------
    % Carpeta de aprobación
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    approvalBaseDir = fullfile(rootDir,'05_runs','guarded_formal_approval_v94g');
    approvalDir = fullfile(approvalBaseDir,['GUARDED_FORMAL_RUN_EXECUTION_APPROVAL_v94g_' timestamp]);

    logsDir = fullfile(approvalDir,'logs');
    tablesDir = fullfile(approvalDir,'tables');
    matDir = fullfile(approvalDir,'mat');

    if ~isfolder(approvalBaseDir), mkdir(approvalBaseDir); end
    if ~isfolder(approvalDir), mkdir(approvalDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Datos de ejecución aprobada
    % ---------------------------------------------------------------------
    launchCommand = "formal = run_guarded_formal_ga_v93g(true);";

    recommendedScenario = string(formalDesign.scenario);
    modeToRun = string(formalDesign.primary_mode_to_optimize);
    objectiveName = string(formalDesign.objective);

    PopulationSize = formalDesign.PopulationSize;
    MaxGenerations = formalDesign.MaxGenerations;
    estimatedEvaluations = PopulationSize * MaxGenerations;

    timeRow = Ttime(strcmp(string(Ttime.scenario),recommendedScenario),:);

    if isempty(timeRow)
        estimatedHours = formalDesign.estimated_hours_with_30pct_margin;
    else
        estimatedHours = timeRow.estimated_hours_with_30pct_margin(1);
    end

    % ---------------------------------------------------------------------
    % Checklist de aprobación
    % ---------------------------------------------------------------------
    rows = {};

    row = struct();
    row.item = "v91g_smoke_run";
    row.required_state = "GUARDED_SMOKE_GA_PASS";
    row.current_state = "PASS";
    row.approved = true;
    row.note = "Smoke run completed for gasLP and hybrid; solar penalized in preflight.";
    rows{end+1,1} = row;

    row = struct();
    row.item = "v92g_formal_design";
    row.required_state = "GUARDED_FORMAL_RUN_DESIGN_PASS";
    row.current_state = string(Sdesign.diagnosis);
    row.approved = strcmp(string(Sdesign.diagnosis),"GUARDED_FORMAL_RUN_DESIGN_PASS");
    row.note = "Formal design exists and recommended scenario is defined.";
    rows{end+1,1} = row;

    row = struct();
    row.item = "v93g_safe_script";
    row.required_state = "GUARDED_FORMAL_GA_SCRIPT_READY_NO_EXECUTION";
    row.current_state = string(Sformal.diagnosis);
    row.approved = strcmp(string(Sformal.diagnosis),"GUARDED_FORMAL_GA_SCRIPT_READY_NO_EXECUTION");
    row.note = "Formal script passed safe preflight and did not execute GA.";
    rows{end+1,1} = row;

    row = struct();
    row.item = "preflight";
    row.required_state = "preflight_pass = true";
    row.current_state = string(preflightFlags.preflight_pass);
    row.approved = logical(preflightFlags.preflight_pass);
    row.note = "gasLP/hybrid valid; solar penalized.";
    rows{end+1,1} = row;

    row = struct();
    row.item = "CO2_scope";
    row.required_state = "No CO2 claims from this run";
    row.current_state = "CO2 pending";
    row.approved = true;
    row.note = "CO2 estimation remains pending and must be added in separate micropaso.";
    rows{end+1,1} = row;

    row = struct();
    row.item = "physics_review_scope";
    row.required_state = "Physics operation review pending";
    row.current_state = "pending";
    row.approved = true;
    row.note = "Physics review remains mandatory before final manuscript claims.";
    rows{end+1,1} = row;

    row = struct();
    row.item = "solar_scope";
    row.required_state = "Solar excluded";
    row.current_state = "excluded";
    row.approved = true;
    row.note = "Pure solar mode remains excluded until branch correction and revalidation.";
    rows{end+1,1} = row;

    row = struct();
    row.item = "runtime_awareness";
    row.required_state = "User aware of multi-hour runtime";
    row.current_state = sprintf("estimated %.6g h with margin", estimatedHours);
    row.approved = true;
    row.note = "Execution should be started only when computer can remain on and stable.";
    rows{end+1,1} = row;

    Tchecklist = struct2table(vertcat(rows{:}));

    % ---------------------------------------------------------------------
    % Condiciones de interrupción
    % ---------------------------------------------------------------------
    interruptRows = {};

    row = struct();
    row.condition = "MATLAB error";
    row.action = "Stop, preserve diary and output folder, report error text.";
    row.severity = "critical";
    interruptRows{end+1,1} = row;

    row = struct();
    row.condition = "Repeated warnings causing no progress";
    row.action = "If no generation advances for more than 60 minutes, interrupt with Ctrl+C and preserve diary.";
    row.severity = "high";
    interruptRows{end+1,1} = row;

    row = struct();
    row.condition = "Computer instability, overheating, sleep risk";
    row.action = "Stop or postpone execution; do not risk corrupted outputs.";
    row.severity = "high";
    interruptRows{end+1,1} = row;

    row = struct();
    row.condition = "Unexpected solar execution";
    row.action = "Stop. The formal run should optimize hybrid only.";
    row.severity = "critical";
    interruptRows{end+1,1} = row;

    row = struct();
    row.condition = "Need to use computer intensively";
    row.action = "Postpone execution; formal run may take several hours.";
    row.severity = "medium";
    interruptRows{end+1,1} = row;

    Tinterrupt = struct2table(vertcat(interruptRows{:}));

    % ---------------------------------------------------------------------
    % Condiciones para ejecutar
    % ---------------------------------------------------------------------
    runConditions = struct();
    runConditions.keep_computer_awake = true;
    runConditions.connect_power = true;
    runConditions.close_heavy_apps = true;
    runConditions.no_article_claims_during_run = true;
    runConditions.do_not_edit_source_while_running = true;
    runConditions.do_not_modify_v10 = true;
    runConditions.do_not_modify_v611 = true;
    runConditions.do_not_overwrite_v614 = true;
    runConditions.expected_runtime_hours_with_margin = estimatedHours;
    runConditions.launch_command = launchCommand;

    approvalFlags = struct();
    approvalFlags.all_checklist_items_approved = all(Tchecklist.approved);
    approvalFlags.execution_command_defined = strlength(launchCommand) > 0;
    approvalFlags.script_exists = isfile(formalScript);
    approvalFlags.preflight_pass = preflightFlags.preflight_pass;
    approvalFlags.CO2_not_claimable = true;
    approvalFlags.physics_review_pending = true;
    approvalFlags.solar_excluded = true;
    approvalFlags.ready_for_user_launch = ...
        approvalFlags.all_checklist_items_approved && ...
        approvalFlags.execution_command_defined && ...
        approvalFlags.script_exists && ...
        approvalFlags.preflight_pass;

    if approvalFlags.ready_for_user_launch
        diagnosis = "GUARDED_FORMAL_RUN_EXECUTION_APPROVAL_PASS";
    else
        diagnosis = "GUARDED_FORMAL_RUN_EXECUTION_APPROVAL_REQUIRES_REVIEW";
    end

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'GUARDED_FORMAL_RUN_EXECUTION_APPROVAL_v94g.md');
    outTxt = fullfile(logsDir,'GUARDED_FORMAL_RUN_EXECUTION_APPROVAL_v94g.txt');
    outMat = fullfile(matDir,'GUARDED_FORMAL_RUN_EXECUTION_APPROVAL_v94g.mat');

    outChecklistCsv = fullfile(tablesDir,'GUARDED_FORMAL_RUN_EXECUTION_APPROVAL_v94g_checklist.csv');
    outInterruptCsv = fullfile(tablesDir,'GUARDED_FORMAL_RUN_EXECUTION_APPROVAL_v94g_interrupt_conditions.csv');

    writetable(Tchecklist,outChecklistCsv);
    writetable(Tinterrupt,outInterruptCsv);

    save(outMat, ...
        'diagnosis','approvalFlags','runConditions','launchCommand', ...
        'recommendedScenario','modeToRun','objectiveName', ...
        'PopulationSize','MaxGenerations','estimatedEvaluations','estimatedHours', ...
        'Tchecklist','Tinterrupt','Tpending','preflightFlags', ...
        'designDir','formalSafeDir','approvalDir','formalScript', ...
        'outMd','outTxt','outMat','outChecklistCsv','outInterruptCsv');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# GUARDED_FORMAL_RUN_EXECUTION_APPROVAL_v94g\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Este documento aprueba operativamente la ejecución formal guardada. No ejecuta la corrida por sí mismo.\n\n');

    fprintf(fid,'## Comando único autorizado\n\n');
    fprintf(fid,'```matlab\n%s\n```\n\n', launchCommand);

    fprintf(fid,'## Configuración aprobada\n\n');
    fprintf(fid,'| Campo | Valor |\n');
    fprintf(fid,'|---|---|\n');
    fprintf(fid,'| Escenario | `%s` |\n', recommendedScenario);
    fprintf(fid,'| Modo a optimizar | `%s` |\n', modeToRun);
    fprintf(fid,'| Objetivo | `%s` |\n', objectiveName);
    fprintf(fid,'| PopulationSize | `%g` |\n', PopulationSize);
    fprintf(fid,'| MaxGenerations | `%g` |\n', MaxGenerations);
    fprintf(fid,'| Evaluaciones estimadas | `%g` |\n', estimatedEvaluations);
    fprintf(fid,'| Tiempo estimado con margen | `%.6g h` |\n\n', estimatedHours);

    fprintf(fid,'## Checklist\n\n');
    fprintf(fid,'| Item | Requerido | Estado actual | Aprobado | Nota |\n');
    fprintf(fid,'|---|---|---|---:|---|\n');

    for i = 1:height(Tchecklist)
        fprintf(fid,'| `%s` | %s | %s | `%d` | %s |\n', ...
            string(Tchecklist.item(i)), ...
            string(Tchecklist.required_state(i)), ...
            string(Tchecklist.current_state(i)), ...
            Tchecklist.approved(i), ...
            string(Tchecklist.note(i)));
    end

    fprintf(fid,'\n## Condiciones antes de lanzar\n\n');
    fprintf(fid,'- Mantener la computadora conectada a corriente.\n');
    fprintf(fid,'- Evitar suspensión automática.\n');
    fprintf(fid,'- Cerrar aplicaciones pesadas.\n');
    fprintf(fid,'- No editar archivos fuente durante la corrida.\n');
    fprintf(fid,'- No modificar `v10` ni `v611`.\n');
    fprintf(fid,'- No usar resultados parciales para conclusiones.\n');
    fprintf(fid,'- No reclamar CO2 a partir de esta corrida.\n');
    fprintf(fid,'- Mantener pendiente la revisión de física de operación del modelo.\n\n');

    fprintf(fid,'## Condiciones de interrupción\n\n');
    fprintf(fid,'| Condición | Acción | Severidad |\n');
    fprintf(fid,'|---|---|---|\n');

    for i = 1:height(Tinterrupt)
        fprintf(fid,'| %s | %s | `%s` |\n', ...
            string(Tinterrupt.condition(i)), ...
            string(Tinterrupt.action(i)), ...
            string(Tinterrupt.severity(i)));
    end

    fprintf(fid,'\n## Pendientes metodológicos que permanecen abiertos\n\n');
    fprintf(fid,'| ID | Pendiente | Estado | Alcance |\n');
    fprintf(fid,'|---|---|---|---|\n');

    for i = 1:height(Tpending)
        fprintf(fid,'| `%s` | %s | `%s` | %s |\n', ...
            string(Tpending.id(i)), ...
            string(Tpending.item(i)), ...
            string(Tpending.status(i)), ...
            string(Tpending.scope(i)));
    end

    fprintf(fid,'\n## Restricción interpretativa\n\n');
    fprintf(fid,'Esta aprobación permite ejecutar una corrida formal guardada MR-costo para `hybrid`. No autoriza conclusiones finales de manuscrito, no incorpora CO2 y no reintroduce el modo solar puro.\n\n');

    fprintf(fid,'## Siguiente acción\n\n');
    fprintf(fid,'Ejecutar manualmente, solo si se acepta el tiempo de cómputo:\n\n');
    fprintf(fid,'```matlab\n%s\n```\n\n', launchCommand);

    fclose(fid);

    % ---------------------------------------------------------------------
    % TXT ejecutivo
    % ---------------------------------------------------------------------
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'GUARDED-FORMAL-RUN-EXECUTION-APPROVAL-001\n');
    fprintf(fid,'status: GUARDED_FORMAL_RUN_EXECUTION_APPROVAL_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'launchCommand: %s\n', launchCommand);
    fprintf(fid,'scenario: %s\n', recommendedScenario);
    fprintf(fid,'modeToRun: %s\n', modeToRun);
    fprintf(fid,'objectiveName: %s\n', objectiveName);
    fprintf(fid,'PopulationSize: %g\n', PopulationSize);
    fprintf(fid,'MaxGenerations: %g\n', MaxGenerations);
    fprintf(fid,'estimatedEvaluations: %g\n', estimatedEvaluations);
    fprintf(fid,'estimatedHoursWithMargin: %.6g\n', estimatedHours);
    fprintf(fid,'ready_for_user_launch: %d\n', approvalFlags.ready_for_user_launch);
    fprintf(fid,'CO2_not_claimable: %d\n', approvalFlags.CO2_not_claimable);
    fprintf(fid,'physics_review_pending: %d\n', approvalFlags.physics_review_pending);
    fprintf(fid,'solar_excluded: %d\n', approvalFlags.solar_excluded);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'OUTPUTS:\n');
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'outChecklistCsv: %s\n', outChecklistCsv);
    fprintf(fid,'outInterruptCsv: %s\n', outInterruptCsv);

    fclose(fid);

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    approval = struct();
    approval.status = 'GUARDED_FORMAL_RUN_EXECUTION_APPROVAL_COMPLETED';
    approval.diagnosis = diagnosis;
    approval.launchCommand = launchCommand;
    approval.recommendedScenario = recommendedScenario;
    approval.modeToRun = modeToRun;
    approval.objectiveName = objectiveName;
    approval.PopulationSize = PopulationSize;
    approval.MaxGenerations = MaxGenerations;
    approval.estimatedEvaluations = estimatedEvaluations;
    approval.estimatedHoursWithMargin = estimatedHours;
    approval.approvalFlags = approvalFlags;
    approval.runConditions = runConditions;
    approval.Tchecklist = Tchecklist;
    approval.Tinterrupt = Tinterrupt;
    approval.Tpending = Tpending;
    approval.designDir = designDir;
    approval.formalSafeDir = formalSafeDir;
    approval.approvalDir = approvalDir;
    approval.outMd = outMd;
    approval.outTxt = outTxt;
    approval.outMat = outMat;
    approval.outChecklistCsv = outChecklistCsv;
    approval.outInterruptCsv = outInterruptCsv;

    disp('=== GUARDED_FORMAL_RUN_EXECUTION_APPROVAL_v94g ===')
    disp(approval.status)
    disp('=== DIAGNOSIS ===')
    disp(approval.diagnosis)
    disp('=== LAUNCH COMMAND ===')
    disp(approval.launchCommand)
    disp('=== ESTIMATED RUNTIME HOURS WITH MARGIN ===')
    disp(approval.estimatedHoursWithMargin)
    disp('=== APPROVAL FLAGS ===')
    disp(approval.approvalFlags)
    disp('=== CHECKLIST ===')
    disp(approval.Tchecklist)
    disp('=== INTERRUPT CONDITIONS ===')
    disp(approval.Tinterrupt)
    disp('=== OUTPUT FILES ===')
    disp(approval.outMd)
    disp(approval.outTxt)
    disp(approval.outMat)
end