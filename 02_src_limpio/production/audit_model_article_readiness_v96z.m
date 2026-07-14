function audit = audit_model_article_readiness_v96z()
% AUDIT_MODEL_ARTICLE_READINESS_v96z
%
% 9.6z-model-article-audit
% COLLECT-MODEL-METADATA-AND-ARTICLE-READY-VARIABLES-001
%
% Objetivo:
%   Recuperar información del modelo y de las salidas existentes que sea
%   útil para el artículo antes de ejecutar R1 formal seed-aware.
%
% No ejecuta GA.
% No ejecuta gamultiobj.
% No modifica archivos fuente.
% Puede cargar MAT existentes e inspeccionar variables.

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    productionDir = fullfile(rootDir,'02_src_limpio','production');
    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    runsRoot = fullfile(articleRoot,'runs');
    reviewDir = fullfile(articleRoot,'review');
    tablesDir = fullfile(articleRoot,'tables');
    traceDir = fullfile(articleRoot,'traceability');

    mkdir_if_needed(articleRoot);
    mkdir_if_needed(runsRoot);
    mkdir_if_needed(reviewDir);
    mkdir_if_needed(tablesDir);
    mkdir_if_needed(traceDir);

    % ------------------------------------------------------------------
    % Archivos fuente clave
    % ------------------------------------------------------------------
    sourceNames = [
        "objective_productive_corrected_v96j_triobjective_CO2_fix1.m"
        "objective_productive_corrected_v95j_endpoint_TMAX_corrected.m"
        "design_triobjective_formal_run_v96l.m"
        "run_guarded_triobjective_formal_ga_v96m.m"
        "run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m"
        "run_seedaware_formal_R1_only_v96z_rngfix.m"
        "audit_gaopts_v96z_before_formal_run_f4.m"
        "run_seedaware_smoke_seed_difference_v96z_rngfix.m"
        "v96z_rngfix_smoke.m"
    ];

    sourcePaths = strings(numel(sourceNames),1);
    sourceExists = false(numel(sourceNames),1);
    sourceRole = strings(numel(sourceNames),1);

    for i = 1:numel(sourceNames)
        sourcePaths(i) = string(fullfile(productionDir,sourceNames(i)));
        sourceExists(i) = isfile(sourcePaths(i));
    end

    sourceRole(1) = "Triobjective wrapper: MR, specific cost, specific CO2.";
    sourceRole(2) = "Endpoint/Tmax corrected objective/model dependency.";
    sourceRole(3) = "Formal design source: x_selected, bounds, nvars, runtime estimate.";
    sourceRole(4) = "Original formal triobjective GA runner; contains legacy fixed seed.";
    sourceRole(5) = "Seed-aware formal clone; receives external rngSeed.";
    sourceRole(6) = "R1-only formal seed-aware runner.";
    sourceRole(7) = "GA options and bounds audit F4.";
    sourceRole(8) = "Smoke seed-difference runner.";
    sourceRole(9) = "Reduced smoke clone.";

    Tsource = table(sourceNames(:), sourceExists(:), sourcePaths(:), sourceRole(:), ...
        'VariableNames', {'source_file','exists','path','role'});

    % ------------------------------------------------------------------
    % Recuperar información de auditoría GA F4
    % ------------------------------------------------------------------
    gaAuditMat = fullfile(traceDir,'GAOPTS_AUDIT_v96z_before_formal_run_f4.mat');

    Tbounds = table();
    Tseed = table();
    Tgaopts = table();
    gaAuditStatus = "NOT_FOUND";

    if isfile(gaAuditMat)
        Sga = load(gaAuditMat);
        gaAuditStatus = "FOUND";

        if isfield(Sga,'Tbounds'), Tbounds = Sga.Tbounds; end
        if isfield(Sga,'Tseed'), Tseed = Sga.Tseed; end
        if isfield(Sga,'Tgaopts'), Tgaopts = Sga.Tgaopts; end
    end

    % ------------------------------------------------------------------
    % Parámetros del modelo / caso base desde diseño v96l
    % ------------------------------------------------------------------
    designPath = fullfile(productionDir,'design_triobjective_formal_run_v96l.m');
    designTxt = "";
    if isfile(designPath)
        designTxt = string(fileread(designPath));
    end

    [x_selected, x_selected_raw] = extract_multiline_vector_assignment(char(designTxt),'x_selected');
    [lb_global, lb_global_raw] = extract_vector_assignment(char(designTxt),'lb_global');
    [ub_global, ub_global_raw] = extract_vector_assignment(char(designTxt),'ub_global');
    [delta_formal, delta_formal_raw] = extract_vector_assignment(char(designTxt),'delta_formal');

    if numel(x_selected)==4 && numel(lb_global)==4 && numel(ub_global)==4 && numel(delta_formal)==4
        lb_formal = max(lb_global, x_selected - delta_formal);
        ub_formal = min(ub_global, x_selected + delta_formal);
    else
        lb_formal = NaN(1,4);
        ub_formal = NaN(1,4);
    end

    variable = ["m_max"; "T_min"; "r_div2"; "t_rec_ini"];
    description = [
        "Decision variable 1; air-flow/control variable as used by model."
        "Decision variable 2; minimum/target temperature control variable."
        "Decision variable 3; recirculation fraction/control encoding."
        "Decision variable 4; initial recirculation time/control variable."
    ];

    Tmodel_parameters = table();
    Tmodel_parameters.variable = variable;
    Tmodel_parameters.description = description;
    Tmodel_parameters.x_selected = x_selected(:);
    Tmodel_parameters.lb_global = lb_global(:);
    Tmodel_parameters.ub_global = ub_global(:);
    Tmodel_parameters.delta_formal = delta_formal(:);
    Tmodel_parameters.lb_formal = lb_formal(:);
    Tmodel_parameters.ub_formal = ub_formal(:);

    % ------------------------------------------------------------------
    % Definición de objetivos y métricas rastreables
    % ------------------------------------------------------------------
    objectiveRows = {};
    objectiveRows{end+1,1} = obj_row("f1","MR","Final moisture ratio / drying target objective.","Minimize","Primary quality/drying endpoint metric.");
    objectiveRows{end+1,1} = obj_row("f2","cost_specific_USD_per_kgwater","Specific drying cost per kg water removed.","Minimize","Economic objective.");
    objectiveRows{end+1,1} = obj_row("f3","CO2_specific_kgCO2_per_kgwater","Specific CO2 emissions per kg water removed.","Minimize","Environmental objective; factors provisional.");
    objectiveRows{end+1,1} = obj_row("detail","Q_aux_tot","Auxiliary energy requirement.","Interpret","Energy-basis variable for hybrid/gasLP comparison.");
    objectiveRows{end+1,1} = obj_row("detail","Irradiacion","Solar irradiation contribution recorded by model.","Interpret","Used to distinguish hybrid/solar contribution.");
    objectiveRows{end+1,1} = obj_row("detail","dry_time","Drying time reported by model.","Interpret","Operational performance variable.");
    objectiveRows{end+1,1} = obj_row("detail","M","Water removed / mass basis used for specific indicators.","Interpret","Denominator for specific cost and emissions.");
    objectiveRows{end+1,1} = obj_row("detail","CO2_total_kg","Total CO2 emissions.","Interpret","Environmental total before specific normalization.");
    objectiveRows{end+1,1} = obj_row("status","solar_INVALID_COST","Solar pure is penalized in this formal comparison.","Exclude from formal GA comparison","Avoids non-equivalent continuous-time comparison.");

    Tobjective_definitions = struct2table(vertcat(objectiveRows{:}));

    % ------------------------------------------------------------------
    % Evaluación directa de referencia conocida desde preflight
    % ------------------------------------------------------------------
    mode = ["gasLP"; "hybrid"; "solar"];
    status = ["OK"; "OK"; "INVALID_COST"];
    MR = [0.096008649173; 0.0959172010556; 1000];
    cost_specific = [0.37787758471; 0.265706336789; 1e6];
    CO2_specific = [1.681; 1.0584; 1e6];
    Q_aux_tot = [1185.9; 714.84; NaN];
    Irradiacion = [0; 487.28; NaN];
    dry_time = [19.9; 19.9; NaN];
    M = [0.72113; 0.72052; NaN];
    CO2_total_kg = [288.7; 181.78; NaN];
    emission_factor_status = repmat("PROVISIONAL_FOR_CODE_VALIDATION",3,1);

    Treference_preflight = table(mode,status,MR,cost_specific,CO2_specific,Q_aux_tot, ...
        Irradiacion,dry_time,M,CO2_total_kg,emission_factor_status);

    % ------------------------------------------------------------------
    % Inventario de MAT existentes
    % ------------------------------------------------------------------
    matRoots = [
        string(fullfile(rootDir,'05_runs'))
        string(fullfile(rootDir,'06_manuscript','article_Q1'))
    ];

    matRows = {};
    for r = 1:numel(matRoots)
        if ~isfolder(matRoots(r)), continue; end

        mats = dir(fullfile(matRoots(r),'**','*.mat'));
        for k = 1:numel(mats)
            matPath = fullfile(mats(k).folder,mats(k).name);

            row = struct();
            row.file = string(mats(k).name);
            row.folder = string(mats(k).folder);
            row.path = string(matPath);
            row.bytes = double(mats(k).bytes);
            row.modified = string(mats(k).date);

            try
                info = whos('-file',matPath);
                row.nVariables = numel(info);
                row.variable_names = strjoin(string({info.name}),", ");
                row.has_formal = any(strcmp({info.name},'formal'));
                row.has_X = any(strcmp({info.name},'X'));
                row.has_F = any(strcmp({info.name},'F'));
                row.has_Tsolutions = any(strcmp({info.name},'Tsolutions'));
                row.has_Tsummary = any(strcmp({info.name},'Tsummary'));
                row.has_Tbounds = any(strcmp({info.name},'Tbounds'));
                row.has_Tgaopts = any(strcmp({info.name},'Tgaopts'));
                row.has_population_scores = any(strcmp({info.name},'population')) || any(strcmp({info.name},'scores'));
                row.load_status = "OK";
                row.error_message = "";
            catch ME
                row.nVariables = NaN;
                row.variable_names = "";
                row.has_formal = false;
                row.has_X = false;
                row.has_F = false;
                row.has_Tsolutions = false;
                row.has_Tsummary = false;
                row.has_Tbounds = false;
                row.has_Tgaopts = false;
                row.has_population_scores = false;
                row.load_status = "ERROR";
                row.error_message = string(ME.message);
            end

            row.article_value = classify_mat_value(row.file,row.variable_names);

            matRows{end+1,1} = row; %#ok<AGROW>
        end
    end

    if isempty(matRows)
        Tavailable_outputs = table();
    else
        Tavailable_outputs = struct2table(vertcat(matRows{:}));
        Tavailable_outputs = sortrows(Tavailable_outputs, {'modified','file'}, {'descend','ascend'});
    end

    % ------------------------------------------------------------------
    % Figuras/tablas candidatas para artículo
    % ------------------------------------------------------------------
    figRows = {};
    figRows{end+1,1} = fig_row("Table 1","Decision variables and bounds","Use Tmodel_parameters / Tbounds","Ready","Methods.");
    figRows{end+1,1} = fig_row("Table 2","GA configuration and seed control","Use Tgaopts / Tseed","Ready","Methods / reproducibility.");
    figRows{end+1,1} = fig_row("Table 3","Reference mode evaluation","Use Treference_preflight","Ready with provisional CO2 caveat","Results baseline.");
    figRows{end+1,1} = fig_row("Figure 1","Model/workflow schematic","Use source audit + narrative","Requires drawing","Methods.");
    figRows{end+1,1} = fig_row("Figure 2","Pareto front projections","Requires formal R1 or full R1/R2/R3","Pending formal run","Results.");
    figRows{end+1,1} = fig_row("Figure 3","Hybrid vs gasLP reductions","Use reference + formal selected solution","Partly ready","Results/discussion.");
    figRows{end+1,1} = fig_row("Figure 4","Seed sensitivity / robustness","Requires R1/R2/R3 or at least R1 vs legacy","Pending formal run","Robustness.");
    figRows{end+1,1} = fig_row("Supplementary Table S1","Available MAT files and variables","Use Tavailable_outputs","Ready","Reproducibility supplement.");

    Tarticle_assets = struct2table(vertcat(figRows{:}));

    % ------------------------------------------------------------------
    % Checks
    % ------------------------------------------------------------------
    checks = {};
    checks{end+1,1} = check_row("MA01","Production directory exists",isfolder(productionDir),string(productionDir));
    checks{end+1,1} = check_row("MA02","Article directory exists",isfolder(articleRoot),string(articleRoot));
    checks{end+1,1} = check_row("MA03","Triobjective objective source exists",Tsource.exists(1),Tsource.path(1));
    checks{end+1,1} = check_row("MA04","Design v96l source exists",isfile(designPath),string(designPath));
    checks{end+1,1} = check_row("MA05","GAOPTS F4 audit found",gaAuditStatus=="FOUND",string(gaAuditMat));
    checks{end+1,1} = check_row("MA06","x_selected extracted",numel(x_selected)==4,mat2str(x_selected,12));
    checks{end+1,1} = check_row("MA07","Formal bounds finite",all(isfinite(lb_formal)) && all(isfinite(ub_formal)), ...
        "lb_formal/ub_formal computed.");
    checks{end+1,1} = check_row("MA08","Objective definitions consolidated",height(Tobjective_definitions)>=3,string(height(Tobjective_definitions)));
    checks{end+1,1} = check_row("MA09","Reference preflight table available",height(Treference_preflight)==3,"gasLP/hybrid/solar rows.");
    checks{end+1,1} = check_row("MA10","Available outputs inventoried",height(Tavailable_outputs)>0,string(height(Tavailable_outputs)));
    checks{end+1,1} = check_row("MA11","Article assets proposed",height(Tarticle_assets)>=5,string(height(Tarticle_assets)));
    checks{end+1,1} = check_row("MA12","No GA executed",true,"No gamultiobj call.");
    checks{end+1,1} = check_row("MA13","No source modified",true,"Read-only audit.");

    Tchecks = struct2table(vertcat(checks{:}));

    if all(Tchecks.pass)
        diagnosis = "MODEL_ARTICLE_AUDIT_PASS";
        decision = "ARTICLE_METADATA_READY_BEFORE_R1_FORMAL";
        next_step = "Proceed to R1 formal only, then postprocess R1 vs legacy.";
    else
        diagnosis = "MODEL_ARTICLE_AUDIT_REQUIRES_REVIEW";
        decision = "DO_NOT_RUN_FORMAL_R1_YET";
        next_step = "Inspect failed model-article checks.";
    end

    % ------------------------------------------------------------------
    % Guardar CSV
    % ------------------------------------------------------------------
    sourceCsv = fullfile(tablesDir,'MODEL_ARTICLE_AUDIT_v96z_Tsource.csv');
    modelCsv = fullfile(tablesDir,'MODEL_ARTICLE_AUDIT_v96z_Tmodel_parameters.csv');
    objCsv = fullfile(tablesDir,'MODEL_ARTICLE_AUDIT_v96z_Tobjective_definitions.csv');
    refCsv = fullfile(tablesDir,'MODEL_ARTICLE_AUDIT_v96z_Treference_preflight.csv');
    outputsCsv = fullfile(tablesDir,'MODEL_ARTICLE_AUDIT_v96z_Tavailable_outputs.csv');
    assetsCsv = fullfile(tablesDir,'MODEL_ARTICLE_AUDIT_v96z_Tarticle_assets.csv');
    checksCsv = fullfile(tablesDir,'MODEL_ARTICLE_AUDIT_v96z_Tchecks.csv');

    writetable(Tsource,sourceCsv);
    writetable(Tmodel_parameters,modelCsv);
    writetable(Tobjective_definitions,objCsv);
    writetable(Treference_preflight,refCsv);
    writetable(Tavailable_outputs,outputsCsv);
    writetable(Tarticle_assets,assetsCsv);
    writetable(Tchecks,checksCsv);

    % ------------------------------------------------------------------
    % Reporte Markdown
    % ------------------------------------------------------------------
    reportMd = fullfile(reviewDir,'MODEL_ARTICLE_AUDIT_v96z.md');

    fid = fopen(reportMd,'w');
    fprintf(fid,'# MODEL_ARTICLE_AUDIT_v96z\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);

    fprintf(fid,'## Model decision variables and formal bounds\n\n');
    fprintf(fid,'| variable | x_selected | lb_global | ub_global | delta_formal | lb_formal | ub_formal |\n');
    fprintf(fid,'|---|---:|---:|---:|---:|---:|---:|\n');
    for i = 1:height(Tmodel_parameters)
        fprintf(fid,'| `%s` | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g |\n', ...
            Tmodel_parameters.variable(i), Tmodel_parameters.x_selected(i), ...
            Tmodel_parameters.lb_global(i), Tmodel_parameters.ub_global(i), ...
            Tmodel_parameters.delta_formal(i), Tmodel_parameters.lb_formal(i), ...
            Tmodel_parameters.ub_formal(i));
    end

    fprintf(fid,'\n## Objective definitions\n\n');
    fprintf(fid,'| id | name | direction | article role |\n');
    fprintf(fid,'|---|---|---|---|\n');
    for i = 1:height(Tobjective_definitions)
        fprintf(fid,'| `%s` | `%s` | `%s` | %s |\n', ...
            Tobjective_definitions.id(i), Tobjective_definitions.name(i), ...
            Tobjective_definitions.direction(i), sanitize_md(Tobjective_definitions.article_role(i)));
    end

    fprintf(fid,'\n## Reference preflight evaluation\n\n');
    fprintf(fid,'| mode | status | MR | cost specific | CO2 specific | Q_aux_tot | Irradiacion | dry_time | M | CO2_total |\n');
    fprintf(fid,'|---|---|---:|---:|---:|---:|---:|---:|---:|---:|\n');
    for i = 1:height(Treference_preflight)
        fprintf(fid,'| `%s` | `%s` | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g |\n', ...
            Treference_preflight.mode(i), Treference_preflight.status(i), ...
            Treference_preflight.MR(i), Treference_preflight.cost_specific(i), ...
            Treference_preflight.CO2_specific(i), Treference_preflight.Q_aux_tot(i), ...
            Treference_preflight.Irradiacion(i), Treference_preflight.dry_time(i), ...
            Treference_preflight.M(i), Treference_preflight.CO2_total_kg(i));
    end

    fprintf(fid,'\n## Candidate article assets\n\n');
    fprintf(fid,'| item | title | data source | status | manuscript section |\n');
    fprintf(fid,'|---|---|---|---|---|\n');
    for i = 1:height(Tarticle_assets)
        fprintf(fid,'| `%s` | %s | %s | `%s` | %s |\n', ...
            Tarticle_assets.item(i), sanitize_md(Tarticle_assets.title(i)), ...
            sanitize_md(Tarticle_assets.data_source(i)), Tarticle_assets.status(i), ...
            sanitize_md(Tarticle_assets.manuscript_section(i)));
    end

    fprintf(fid,'\n## Available MAT outputs\n\n');
    fprintf(fid,'| file | variables | article value |\n');
    fprintf(fid,'|---|---|---|\n');

    nShow = min(40,height(Tavailable_outputs));
    for i = 1:nShow
        fprintf(fid,'| `%s` | `%s` | %s |\n', ...
            sanitize_md(Tavailable_outputs.file(i)), ...
            sanitize_md(Tavailable_outputs.variable_names(i)), ...
            sanitize_md(Tavailable_outputs.article_value(i)));
    end

    fprintf(fid,'\n## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            Tchecks.id(i), sanitize_md(Tchecks.check(i)), ...
            Tchecks.pass(i), sanitize_md(Tchecks.evidence(i)));
    end

    fprintf(fid,'\n## Methodological note\n\n');
    fprintf(fid,'This audit is read-only and does not execute gamultiobj. ');
    fprintf(fid,'It prepares article-facing metadata before the formal R1 seed-aware run.\n');
    fclose(fid);

    outMat = fullfile(traceDir,'MODEL_ARTICLE_AUDIT_v96z.mat');

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'rootDir','productionDir','articleRoot','runsRoot', ...
        'Tsource','Tmodel_parameters','Tobjective_definitions','Treference_preflight', ...
        'Tavailable_outputs','Tarticle_assets','Tchecks','Tbounds','Tseed','Tgaopts', ...
        'sourceCsv','modelCsv','objCsv','refCsv','outputsCsv','assetsCsv','checksCsv', ...
        'reportMd','outMat', ...
        'x_selected_raw','lb_global_raw','ub_global_raw','delta_formal_raw');

    audit = struct();
    audit.status = 'MODEL_ARTICLE_AUDIT_v96z_COMPLETED';
    audit.diagnosis = diagnosis;
    audit.decision = decision;
    audit.next_step = next_step;
    audit.Tsource = Tsource;
    audit.Tmodel_parameters = Tmodel_parameters;
    audit.Tobjective_definitions = Tobjective_definitions;
    audit.Treference_preflight = Treference_preflight;
    audit.Tavailable_outputs = Tavailable_outputs;
    audit.Tarticle_assets = Tarticle_assets;
    audit.Tchecks = Tchecks;
    audit.reportMd = reportMd;
    audit.outMat = outMat;

    disp('=== MODEL_ARTICLE_AUDIT_v96z ===')
    disp(audit.status)
    disp('=== DIAGNOSIS ===')
    disp(audit.diagnosis)
    disp('=== DECISION ===')
    disp(audit.decision)
    disp('=== NEXT STEP ===')
    disp(audit.next_step)
    disp('=== MODEL PARAMETERS ===')
    disp(audit.Tmodel_parameters)
    disp('=== OBJECTIVE DEFINITIONS ===')
    disp(audit.Tobjective_definitions)
    disp('=== REFERENCE PREFLIGHT ===')
    disp(audit.Treference_preflight)
    disp('=== ARTICLE ASSETS ===')
    disp(audit.Tarticle_assets)
    disp('=== AVAILABLE OUTPUTS, FIRST 20 ===')
    if height(audit.Tavailable_outputs) > 0
        disp(audit.Tavailable_outputs(1:min(20,height(audit.Tavailable_outputs)),:))
    else
        disp(audit.Tavailable_outputs)
    end
    disp('=== CHECKS ===')
    disp(audit.Tchecks)
    disp('=== REPORT ===')
    disp(audit.reportMd)

end

function row = obj_row(id,name,definition,direction,article_role)
    row = struct();
    row.id = string(id);
    row.name = string(name);
    row.definition = string(definition);
    row.direction = string(direction);
    row.article_role = string(article_role);
end

function row = fig_row(item,title,data_source,status,manuscript_section)
    row = struct();
    row.item = string(item);
    row.title = string(title);
    row.data_source = string(data_source);
    row.status = string(status);
    row.manuscript_section = string(manuscript_section);
end

function value = classify_mat_value(fileName, variableNames)
    f = lower(string(fileName));
    vars = lower(string(variableNames));

    if contains(f,"gaopts_audit")
        value = "GA configuration / reproducibility.";
    elseif contains(f,"model_article_audit")
        value = "Article metadata audit.";
    elseif contains(f,"seedaware_smoke") || contains(f,"smoke")
        value = "Seed-control smoke validation; not final optimization result.";
    elseif contains(f,"formal_r1_only")
        value = "Formal R1-only candidate output.";
    elseif contains(f,"minrep") || contains(f,"seed_controlled")
        value = "Seed replication / robustness trace.";
    elseif contains(vars,"tsolutions") || contains(vars,"x") || contains(vars,"f")
        value = "Optimization/front data candidate.";
    else
        value = "Traceability / supporting output.";
    end
end

function [v, raw] = extract_vector_assignment(txt,varName)
    v = [];
    raw = "";
    pat = [varName '\s*=\s*\[([^\]]+)\]\s*;'];
    tok = regexp(txt,pat,'tokens','once');
    if isempty(tok)
        return;
    end
    raw = string(strtrim(tok{1}));
    nums = regexp(tok{1},'[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?','match');
    v = str2double(nums);
end

function [v, raw] = extract_multiline_vector_assignment(txt,varName)
    v = [];
    raw = "";
    pat = [varName '\s*=\s*\[(.*?)\]\s*;'];
    tok = regexp(txt,pat,'tokens','once');
    if isempty(tok)
        return;
    end
    raw = string(strtrim(tok{1}));
    nums = regexp(tok{1},'[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?','match');
    v = str2double(nums);
end

function mkdir_if_needed(folderPath)
    if ~isfolder(folderPath)
        mkdir(folderPath);
    end
end

function row = check_row(id, checkName, passVal, evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end

function s = sanitize_md(x)
    s = string(x);
    s = replace(s, newline, " ");
    s = replace(s, "|", "\|");
    s = replace(s, "`", "'");
end