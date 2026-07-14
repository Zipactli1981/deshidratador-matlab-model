function audit = master_plan_realignment_audit_v634()
% MASTER_PLAN_REALIGNMENT_AUDIT_v634
% Micropaso 6.34 — MASTER-PLAN-REALIGNMENT-AUDIT-001
%
% Objetivo:
%   Realinear el flujo actual con el plan maestro.
%
% Diagnóstico esperado:
%   - El bloque postrun v630c-v633 sigue siendo válido.
%   - 7.1, 7.2 y 7.3 se reclasifican como borradores condicionados.
%   - No se continúa a Abstract ni manuscrito integrado.
%   - Se recomienda volver a corridas controladas:
%       9.1g — GUARDED-SMOKE-RUN-001
%       9.2g/9.3g — corrida formal guardada según decisión.
%
% No modifica:
%   - wrapper v10
%   - objective v611
%   - corrida productiva v614
%   - scripts v710/v720/v730
%
% Salidas:
%   logs/MASTER_PLAN_REALIGNMENT_AUDIT_v634.md
%   logs/MASTER_PLAN_REALIGNMENT_AUDIT_v634.txt
%   tables/MASTER_PLAN_REALIGNMENT_AUDIT_v634_status.csv
%   mat/MASTER_PLAN_REALIGNMENT_AUDIT_v634.mat
%
% Uso:
%   audit = master_plan_realignment_audit_v634();

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

    % ---------------------------------------------------------------------
    % Artefactos ya generados
    % ---------------------------------------------------------------------
    files = struct();

    files.v630c_mat = fullfile(matDir,'GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630c.mat');
    files.v631_mat  = fullfile(matDir,'THESIS_ARTICLE_INTERPRETATION_v631.mat');
    files.v632_mat  = fullfile(matDir,'KNOW_06_32_guarded_mode_comparison.mat');
    files.v633_mat  = fullfile(matDir,'FINAL_POSTRUN_PACKAGE_INDEX_v633.mat');

    files.v710_mat  = fullfile(matDir,'ARTICLE_RESULTS_SECTION_DRAFT_v710.mat');
    files.v720_mat  = fullfile(matDir,'ARTICLE_DISCUSSION_SECTION_DRAFT_v720.mat');
    files.v730_mat  = fullfile(matDir,'ARTICLE_CONCLUSIONS_SECTION_DRAFT_v730.mat');

    files.v710_md  = fullfile(logsDir,'ARTICLE_RESULTS_SECTION_DRAFT_v710.md');
    files.v720_md  = fullfile(logsDir,'ARTICLE_DISCUSSION_SECTION_DRAFT_v720.md');
    files.v730_md  = fullfile(logsDir,'ARTICLE_CONCLUSIONS_SECTION_DRAFT_v730.md');

    files.objective_guarded_v628b = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v628b_nonphysical_penalty.m');
    files.wrapper_guarded_v17     = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v17_nonphysical_penalty.m');
    files.guard_eval_v628b        = fullfile(rootDir,'02_src_limpio','wrappers','nonphysical_guard_eval_v628b.m');

    files.wrapper_v10_original    = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v10_energy_mode_corrected.m');
    files.objective_v611_original = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v611.m');

    keys = fieldnames(files);
    fileRows = {};

    for i = 1:numel(keys)
        row = struct();
        row.key = string(keys{i});
        row.path = string(files.(keys{i}));
        row.exists = isfile(files.(keys{i}));

        if row.exists
            info = dir(files.(keys{i}));
            row.bytes = info.bytes;
            row.modified = string(info.date);
        else
            row.bytes = NaN;
            row.modified = "";
        end

        fileRows{end+1,1} = row; %#ok<AGROW>
    end

    Tfiles = struct2table(vertcat(fileRows{:}));

    % ---------------------------------------------------------------------
    % Validar paquete postrun
    % ---------------------------------------------------------------------
    if ~isfile(files.v633_mat)
        error('No existe v633. Ejecutar antes FINAL_POSTRUN_PACKAGE_INDEX_v633.');
    end

    if ~isfile(files.v630c_mat)
        error('No existe v630c. Ejecutar antes GUARDED_POSTRUN_EVIDENCE_CONSOLIDATED_v630c.');
    end

    S633 = load(files.v633_mat);
    S630 = load(files.v630c_mat);

    if ~isfield(S633,'finalDiagnosis')
        error('v633 no contiene finalDiagnosis.');
    end

    if ~isfield(S630,'metrics') || ~isfield(S630,'flags')
        error('v630c no contiene metrics/flags.');
    end

    finalDiagnosis633 = string(S633.finalDiagnosis);
    metrics = S630.metrics;
    flags = S630.flags;

    % ---------------------------------------------------------------------
    % Evaluar estado de borradores 7.1-7.3
    % ---------------------------------------------------------------------
    articleDraftsExist = ...
        isfile(files.v710_mat) && ...
        isfile(files.v720_mat) && ...
        isfile(files.v730_mat);

    % Los borradores existen, pero se degradan por criterio metodológico.
    articleDraftStatus = "DRAFT_CONDITIONAL_ON_SELECTED_POSTRUN_SOLUTION";

    % ---------------------------------------------------------------------
    % Controles del plan maestro
    % ---------------------------------------------------------------------
    controls = struct();

    controls.postrun_package_closed = strcmp(finalDiagnosis633,"FINAL_POSTRUN_PACKAGE_INDEX_PASS");
    controls.selected_solution_postrun_validated = ...
        flags.hybrid_gasLP_comparison_allowed && ...
        flags.gasLP_valid_final && ...
        flags.hybrid_valid_final && ...
        flags.solar_invalid_final;

    controls.guarded_objective_exists = isfile(files.objective_guarded_v628b);
    controls.guarded_wrapper_exists = isfile(files.wrapper_guarded_v17);
    controls.guard_eval_exists = isfile(files.guard_eval_v628b);

    controls.article_results_draft_exists = isfile(files.v710_mat);
    controls.article_discussion_draft_exists = isfile(files.v720_mat);
    controls.article_conclusions_draft_exists = isfile(files.v730_mat);

    controls.article_drafts_are_final = false;
    controls.abstract_allowed_now = false;
    controls.integrated_manuscript_allowed_now = false;

    controls.formal_guarded_GA_completed = false;
    controls.guarded_smoke_run_completed = false;

    controls.return_to_controlled_runs_required = true;
    controls.no_modify_v10 = true;
    controls.no_modify_v611 = true;
    controls.no_overwrite_v614 = true;

    % ---------------------------------------------------------------------
    % Dictamen
    % ---------------------------------------------------------------------
    if controls.postrun_package_closed && ...
       controls.selected_solution_postrun_validated && ...
       controls.guarded_objective_exists && ...
       controls.guarded_wrapper_exists && ...
       controls.guard_eval_exists && ...
       articleDraftsExist

        diagnosis = "MASTER_PLAN_REALIGNMENT_PASS";
    else
        diagnosis = "MASTER_PLAN_REALIGNMENT_REQUIRES_REVIEW";
    end

    % ---------------------------------------------------------------------
    % Tabla de estado
    % ---------------------------------------------------------------------
    rows = {};

    row = struct();
    row.item = "postrun_package";
    row.status = string(finalDiagnosis633);
    row.interpretation = "Postrun package remains valid for the selected solution.";
    row.action = "Keep as selected-solution postrun evidence.";
    rows{end+1,1} = row;

    row = struct();
    row.item = "selected_solution_claim";
    row.status = "VALID_FOR_SELECTED_SOLUTION_ONLY";
    row.interpretation = "gasLP/hybrid comparison is valid only as postrun validation of the selected v614 solution.";
    row.action = "Do not present as final guarded optimization optimum.";
    rows{end+1,1} = row;

    row = struct();
    row.item = "article_results_v710";
    row.status = articleDraftStatus;
    row.interpretation = "Useful draft, but conditional on selected postrun solution.";
    row.action = "Freeze as conditional draft.";
    rows{end+1,1} = row;

    row = struct();
    row.item = "article_discussion_v720";
    row.status = articleDraftStatus;
    row.interpretation = "Useful draft, but conditional on selected postrun solution.";
    row.action = "Freeze as conditional draft.";
    rows{end+1,1} = row;

    row = struct();
    row.item = "article_conclusions_v730";
    row.status = articleDraftStatus;
    row.interpretation = "Useful draft, but too early for final manuscript conclusion.";
    row.action = "Freeze as conditional draft.";
    rows{end+1,1} = row;

    row = struct();
    row.item = "abstract";
    row.status = "NOT_ALLOWED_YET";
    row.interpretation = "Abstract should not be drafted as final before guarded controlled run decision.";
    row.action = "Do not continue to 7.4.";
    rows{end+1,1} = row;

    row = struct();
    row.item = "guarded_GA_rerun";
    row.status = "DECISION_REQUIRED";
    row.interpretation = "A full guarded GA is required if the paper claims final multiobjective optimization.";
    row.action = "Proceed to guarded smoke run before any formal rerun.";
    rows{end+1,1} = row;

    row = struct();
    row.item = "next_step";
    row.status = "9.1g_GUARDED_SMOKE_RUN_RECOMMENDED";
    row.interpretation = "Master plan requires smoke run before formal controlled run.";
    row.action = "Prepare small PopulationSize/MaxGenerations guarded run.";
    rows{end+1,1} = row;

    Tstatus = struct2table(vertcat(rows{:}));

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outMd  = fullfile(logsDir,'MASTER_PLAN_REALIGNMENT_AUDIT_v634.md');
    outTxt = fullfile(logsDir,'MASTER_PLAN_REALIGNMENT_AUDIT_v634.txt');
    outMat = fullfile(matDir,'MASTER_PLAN_REALIGNMENT_AUDIT_v634.mat');
    outCsv = fullfile(tablesDir,'MASTER_PLAN_REALIGNMENT_AUDIT_v634_status.csv');
    outFilesCsv = fullfile(tablesDir,'MASTER_PLAN_REALIGNMENT_AUDIT_v634_files.csv');

    writetable(Tstatus,outCsv);
    writetable(Tfiles,outFilesCsv);

    save(outMat, ...
        'diagnosis','controls','articleDraftStatus','finalDiagnosis633', ...
        'metrics','flags','runDir','files','Tstatus','Tfiles', ...
        'outMd','outTxt','outMat','outCsv','outFilesCsv');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# MASTER_PLAN_REALIGNMENT_AUDIT_v634\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Paquete postrun fuente: `%s`\n\n', finalDiagnosis633);
    fprintf(fid,'Corrida base: `%s`\n\n', runDir);

    fprintf(fid,'## Corrección de rumbo\n\n');
    fprintf(fid,'La escritura de las secciones `Results`, `Discussion` y `Conclusions` avanzó antes de completar una nueva corrida formal físicamente guardada. Estos archivos se conservan como borradores técnicos útiles, pero su estatus se reclasifica como:\n\n');
    fprintf(fid,'`%s`\n\n', articleDraftStatus);

    fprintf(fid,'Esto significa que los textos 7.1–7.3 solo son válidos como redacción preliminar basada en la evaluación postrun de la solución seleccionada de la corrida v614. No deben presentarse como resultados finales de una optimización multiobjetivo físicamente guardada.\n\n');

    fprintf(fid,'## Qué sí está cerrado\n\n');
    fprintf(fid,'- La corrida productiva v614 existe y tiene una solución seleccionada.\n');
    fprintf(fid,'- La solución seleccionada fue evaluada postrun con guardas físicas.\n');
    fprintf(fid,'- Para esa solución, `gasLP` e `hybrid` son trayectorias válidas.\n');
    fprintf(fid,'- Para esa solución, `solar` puro es una trayectoria inválida.\n');
    fprintf(fid,'- La comparación `gasLP`/`hybrid` es defendible como validación postrun de la solución seleccionada.\n');
    fprintf(fid,'- Los artefactos v630c, v631, v632 y v633 conservan trazabilidad.\n\n');

    fprintf(fid,'## Qué no está cerrado\n\n');
    fprintf(fid,'- No existe todavía una corrida AG formal completa ejecutada desde el inicio con la función objetivo guardada `objective_productive_corrected_v628b_nonphysical_penalty`.\n');
    fprintf(fid,'- No se debe afirmar todavía que la solución sea el óptimo final de una optimización físicamente guardada.\n');
    fprintf(fid,'- No debe continuar la escritura hacia Abstract o manuscrito integrado como si la optimización final estuviera cerrada.\n');
    fprintf(fid,'- No debe usarse 7.1–7.3 como versión final del artículo.\n\n');

    fprintf(fid,'## Métricas que permanecen válidas solo para la solución seleccionada\n\n');
    fprintf(fid,'| Métrica | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| `MR gasLP` | %.12g |\n', metrics.gasLP_MR);
    fprintf(fid,'| `MR hybrid` | %.12g |\n', metrics.hybrid_MR);
    fprintf(fid,'| `delta MR hybrid-gasLP` | %.12g |\n', metrics.delta_MR_hybrid_minus_gasLP);
    fprintf(fid,'| `dry time gasLP [h]` | %.12g |\n', metrics.gasLP_dry_time_h);
    fprintf(fid,'| `dry time hybrid [h]` | %.12g |\n', metrics.hybrid_dry_time_h);
    fprintf(fid,'| `Q_aux reduction [%]` | %.6g |\n', metrics.reduction_Q_aux_hybrid_vs_gasLP_pct);
    fprintf(fid,'| `cost reduction [%]` | %.6g |\n\n', metrics.reduction_cost_hybrid_vs_gasLP_pct);

    fprintf(fid,'## Estatus de borradores de artículo\n\n');
    fprintf(fid,'| Archivo | Nuevo estatus |\n');
    fprintf(fid,'|---|---|\n');
    fprintf(fid,'| `ARTICLE_RESULTS_SECTION_DRAFT_v710.md` | `%s` |\n', articleDraftStatus);
    fprintf(fid,'| `ARTICLE_DISCUSSION_SECTION_DRAFT_v720.md` | `%s` |\n', articleDraftStatus);
    fprintf(fid,'| `ARTICLE_CONCLUSIONS_SECTION_DRAFT_v730.md` | `%s` |\n\n', articleDraftStatus);

    fprintf(fid,'## Decisión metodológica pendiente\n\n');
    fprintf(fid,'Si el artículo va a sostener una optimización multiobjetivo final, debe ejecutarse una nueva campaña de optimización con guardas físicas desde la función objetivo. Antes de esa corrida formal, corresponde una corrida de humo guardada.\n\n');

    fprintf(fid,'## Siguiente paso recomendado\n\n');
    fprintf(fid,'`9.1g — GUARDED-SMOKE-RUN-001`\n\n');
    fprintf(fid,'Propósito: ejecutar una corrida corta con la función objetivo guardada para verificar que el flujo completo corre, penaliza trayectorias no físicas, conserva `gasLP`/`hybrid` válidos y guarda outputs con trazabilidad.\n\n');

    fprintf(fid,'## Política de protección\n\n');
    fprintf(fid,'- No modificar `opt_tunel_mod2_v10_energy_mode_corrected.m`.\n');
    fprintf(fid,'- No modificar `objective_productive_corrected_v611.m`.\n');
    fprintf(fid,'- No sobrescribir la corrida productiva v614.\n');
    fprintf(fid,'- No continuar a Abstract antes de resolver la decisión de corrida guardada.\n');
    fprintf(fid,'- No presentar 7.1–7.3 como secciones finales.\n\n');

    fprintf(fid,'## Tabla de realineamiento\n\n');
    fprintf(fid,'| Item | Estado | Interpretación | Acción |\n');
    fprintf(fid,'|---|---|---|---|\n');

    for r = 1:height(Tstatus)
        fprintf(fid,'| `%s` | `%s` | %s | %s |\n', ...
            string(Tstatus.item(r)), ...
            string(Tstatus.status(r)), ...
            string(Tstatus.interpretation(r)), ...
            string(Tstatus.action(r)));
    end

    fclose(fid);

    % ---------------------------------------------------------------------
    % TXT ejecutivo
    % ---------------------------------------------------------------------
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'MASTER-PLAN-REALIGNMENT-AUDIT-001\n');
    fprintf(fid,'status: MASTER_PLAN_REALIGNMENT_AUDIT_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'source_postrun_diagnosis: %s\n', finalDiagnosis633);
    fprintf(fid,'articleDraftStatus: %s\n', articleDraftStatus);
    fprintf(fid,'runDir: %s\n', runDir);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'CLOSED:\n');
    fprintf(fid,'selected solution postrun validation: true\n');
    fprintf(fid,'gasLP/hybrid valid for selected solution: true\n');
    fprintf(fid,'solar invalid for selected solution: true\n\n');

    fprintf(fid,'NOT CLOSED:\n');
    fprintf(fid,'formal guarded GA optimization: false\n');
    fprintf(fid,'final article results: false\n');
    fprintf(fid,'abstract: false\n\n');

    fprintf(fid,'RECLASSIFIED DRAFTS:\n');
    fprintf(fid,'v710 results: %s\n', articleDraftStatus);
    fprintf(fid,'v720 discussion: %s\n', articleDraftStatus);
    fprintf(fid,'v730 conclusions: %s\n\n', articleDraftStatus);

    fprintf(fid,'NEXT RECOMMENDED STEP:\n');
    fprintf(fid,'9.1g — GUARDED-SMOKE-RUN-001\n\n');

    fprintf(fid,'OUTPUTS:\n');
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'outCsv: %s\n', outCsv);
    fprintf(fid,'outFilesCsv: %s\n', outFilesCsv);

    fclose(fid);

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    audit = struct();
    audit.status = 'MASTER_PLAN_REALIGNMENT_AUDIT_COMPLETED';
    audit.diagnosis = diagnosis;
    audit.sourcePostrunDiagnosis = finalDiagnosis633;
    audit.articleDraftStatus = articleDraftStatus;
    audit.controls = controls;
    audit.metrics = metrics;
    audit.flags = flags;
    audit.runDir = runDir;
    audit.Tstatus = Tstatus;
    audit.Tfiles = Tfiles;
    audit.outMd = outMd;
    audit.outTxt = outTxt;
    audit.outMat = outMat;
    audit.outCsv = outCsv;
    audit.outFilesCsv = outFilesCsv;

    disp('=== MASTER_PLAN_REALIGNMENT_AUDIT_v634 ===')
    disp(audit.status)
    disp('=== DIAGNOSIS ===')
    disp(audit.diagnosis)
    disp('=== SOURCE POSTRUN DIAGNOSIS ===')
    disp(audit.sourcePostrunDiagnosis)
    disp('=== ARTICLE DRAFT STATUS ===')
    disp(audit.articleDraftStatus)
    disp('=== CONTROLS ===')
    disp(audit.controls)
    disp('=== REALIGNMENT TABLE ===')
    disp(audit.Tstatus)
    disp('=== OUTPUT FILES ===')
    disp(audit.outMd)
    disp(audit.outTxt)
    disp(audit.outMat)
    disp(audit.outCsv)
    disp(audit.outFilesCsv)
end