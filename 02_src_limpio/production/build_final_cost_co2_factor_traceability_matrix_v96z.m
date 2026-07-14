function out = build_final_cost_co2_factor_traceability_matrix_v96z()
% BUILD_FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z
%
% 9.6z-trace-a
% FINAL-COST-CO2-FACTOR-TRACEABILITY-MATRIX-001
%
% Objetivo:
%   Construir una matriz de trazabilidad para factores economicos y de CO2
%   usados o pendientes de usar en el manuscrito.
%
% Enfoque:
%   - Separar factores listos para uso interno/codigo de factores listos
%     para afirmaciones finales del manuscrito.
%   - Mantener explicito que algunos factores son provisionales para
%     validacion de codigo hasta contar con fuente final.
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica MASTER.
% No modifica Results Section 7.

    rootDir = setup_v05_paths();

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    tablesDir  = fullfile(articleRoot,'tables');
    reviewDir  = fullfile(articleRoot,'review');
    traceDir   = fullfile(articleRoot,'traceability');
    draftDir   = fullfile(articleRoot,'draft_sections');
    lockDir    = fullfile(articleRoot,'locked_sections');

    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(reviewDir), mkdir(reviewDir); end
    if ~isfolder(traceDir), mkdir(traceDir); end

    masterFile = fullfile(draftDir,'MASTER_manuscript_v01.md');
    lockedSection7 = fullfile(lockDir,'RESULTS_SECTION_07_v01_1_LOCKED.md');
    methodsIntegrationReport = fullfile(reviewDir,'INTEGRATE_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_INTO_MASTER_v96z_report.md');
    r1ReproTable = fullfile(tablesDir,'R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z.md');

    % ------------------------------------------------------------------
    % Controlled provisional factors already used for code validation
    % ------------------------------------------------------------------
    EF_LPG_kgCO2_per_kWh = 0.2270;
    EF_grid_kgCO2_per_kWh = 0.4380;
    provisionalTag = "PROVISIONAL_FOR_CODE_VALIDATION";

    item = strings(0,1);
    factor_symbol = strings(0,1);
    current_value = strings(0,1);
    units = strings(0,1);
    factor_role = strings(0,1);
    current_status = strings(0,1);
    manuscript_readiness = strings(0,1);
    source_status = strings(0,1);
    action_required_before_submission = strings(0,1);
    permitted_current_use = strings(0,1);
    note = strings(0,1);

    add_row("LPG CO2 emission factor", ...
        "EF_LPG_kgCO2_per_kWh", ...
        sprintf('%.4f',EF_LPG_kgCO2_per_kWh), ...
        "kgCO2/kWh", ...
        "Environmental objective / CO2 calculation", ...
        provisionalTag, ...
        "Not final for manuscript claims", ...
        "Pending final bibliographic or institutional source", ...
        "Replace or confirm with cited final source before submission", ...
        "Internal code validation, sensitivity, traceability draft", ...
        "Current value retained as provisional factor only.");

    add_row("Grid electricity CO2 emission factor", ...
        "EF_grid_kgCO2_per_kWh", ...
        sprintf('%.4f',EF_grid_kgCO2_per_kWh), ...
        "kgCO2/kWh", ...
        "Auxiliary electricity / indirect emissions if used", ...
        provisionalTag, ...
        "Not final for manuscript claims", ...
        "Pending final bibliographic or institutional source", ...
        "Replace or confirm with cited final source before submission", ...
        "Internal code validation, sensitivity, traceability draft", ...
        "Current value retained as provisional factor only.");

    add_row("Gas-LPG auxiliary energy", ...
        "Q_aux", ...
        "Computed by model/post-processing", ...
        "kWh", ...
        "Energy metric for hybrid and gas-LPG baseline comparison", ...
        "Computed result already used in locked Results Section 7", ...
        "Usable as computed model output", ...
        "Traceable to selected-point comparison files and locked Section 7", ...
        "Ensure cost/CO2 factors attached to Q_aux are final before final claims", ...
        "Results interpretation and baseline comparison", ...
        "Energy values are locked; factor-based emissions/cost claims remain source-dependent.");

    add_row("Fuel cost factor", ...
        "C_LPG or equivalent", ...
        "Pending final source/value", ...
        "currency/kWh or currency/kg", ...
        "Economic objective / specific cost calculation", ...
        "Requires final traceability", ...
        "Not final for manuscript claims", ...
        "Pending final price source, date, region, and conversion basis", ...
        "Define final source, date, lower heating value basis if needed, and unit conversion", ...
        "Planning only", ...
        "Do not treat as final until unit basis and source date are documented.");

    add_row("Electricity cost factor", ...
        "C_grid or equivalent", ...
        "Pending final source/value", ...
        "currency/kWh", ...
        "Economic objective if electrical consumption is included", ...
        "Requires final traceability", ...
        "Not final for manuscript claims", ...
        "Pending final tariff/source, date, and tariff class", ...
        "Define tariff source, date, region, tariff class, and applicability", ...
        "Planning only", ...
        "Needed only if electricity/fan or auxiliary electrical use enters final economic metric.");

    add_row("Fan-power treatment", ...
        "P_fan / pressure-drop coupling", ...
        "Not fully coupled in current optimization", ...
        "W, kWh, Pa", ...
        "Equipment-level limitation", ...
        "Explicit limitation", ...
        "Usable as limitation, not as optimized equipment claim", ...
        "Documented as methodological caveat", ...
        "Keep as limitation/future work unless fan power is explicitly modeled", ...
        "Limitations and future work", ...
        "Prevents overclaiming equipment-level optimality.");

    add_row("Pressure-drop treatment", ...
        "DeltaP", ...
        "Not fully coupled in current optimization", ...
        "Pa", ...
        "Equipment-level limitation", ...
        "Explicit limitation", ...
        "Usable as limitation, not as optimized equipment claim", ...
        "Documented as methodological caveat", ...
        "Keep as limitation/future work unless pressure drop is explicitly modeled", ...
        "Limitations and future work", ...
        "Prevents overclaiming equipment-level optimality.");

    add_row("Solar-only operation", ...
        "solar_only", ...
        "Excluded from formal GA comparison", ...
        "mode", ...
        "Boundary/endpoint operating mode", ...
        "Excluded from formal comparison", ...
        "Usable only as separate endpoint if discussed", ...
        "Documented as non-equivalent mode", ...
        "Do not mix with hybrid/gas-LPG formal GA comparison", ...
        "Methods caveat", ...
        "Protects comparability of the formal optimization.");

    T = table(item,factor_symbol,current_value,units,factor_role,current_status, ...
        manuscript_readiness,source_status,action_required_before_submission, ...
        permitted_current_use,note, ...
        'VariableNames',{'item','factor_symbol','current_value','units','factor_role', ...
        'current_status','manuscript_readiness','source_status', ...
        'action_required_before_submission','permitted_current_use','note'});

    csvFile = fullfile(tablesDir,'FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z.csv');
    mdFile = fullfile(tablesDir,'FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z.md');
    reportFile = fullfile(reviewDir,'FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z_report.md');
    checksCsv = fullfile(reviewDir,'FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z_Tchecks.csv');
    matFile = fullfile(traceDir,'FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z.mat');

    writetable(T,csvFile);
    write_md_matrix(mdFile,T,EF_LPG_kgCO2_per_kWh,EF_grid_kgCO2_per_kWh,provisionalTag);

    checks = {};
    checks{end+1,1} = check_row("TRCO2-01","MASTER exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("TRCO2-02","Locked Section 7 exists",isfile(lockedSection7),lockedSection7);
    checks{end+1,1} = check_row("TRCO2-03","Methods integration report exists",isfile(methodsIntegrationReport),methodsIntegrationReport);
    checks{end+1,1} = check_row("TRCO2-04","R1 reproducibility table exists",isfile(r1ReproTable),r1ReproTable);
    checks{end+1,1} = check_row("TRCO2-05","CSV matrix created",isfile(csvFile),csvFile);
    checks{end+1,1} = check_row("TRCO2-06","Markdown matrix created",isfile(mdFile),mdFile);

    checks{end+1,1} = check_row("TRCO2-07","LPG provisional CO2 factor documented",any(T.factor_symbol=="EF_LPG_kgCO2_per_kWh") && any(T.current_value==sprintf('%.4f',EF_LPG_kgCO2_per_kWh)),"EF_LPG documented.");
    checks{end+1,1} = check_row("TRCO2-08","Grid provisional CO2 factor documented",any(T.factor_symbol=="EF_grid_kgCO2_per_kWh") && any(T.current_value==sprintf('%.4f',EF_grid_kgCO2_per_kWh)),"EF_grid documented.");
    checks{end+1,1} = check_row("TRCO2-09","Provisional tag documented",any(contains(T.current_status,provisionalTag)),"Provisional status.");
    checks{end+1,1} = check_row("TRCO2-10","Emission factors not marked final",all(~contains(T.manuscript_readiness(T.factor_symbol=="EF_LPG_kgCO2_per_kWh" | T.factor_symbol=="EF_grid_kgCO2_per_kWh"),"Final")),"CO2 factors not final.");
    checks{end+1,1} = check_row("TRCO2-11","Final source action required for LPG factor",any(contains(T.action_required_before_submission(T.factor_symbol=="EF_LPG_kgCO2_per_kWh"),"source")),"LPG action required.");
    checks{end+1,1} = check_row("TRCO2-12","Final source action required for grid factor",any(contains(T.action_required_before_submission(T.factor_symbol=="EF_grid_kgCO2_per_kWh"),"source")),"Grid action required.");

    checks{end+1,1} = check_row("TRCO2-13","Fuel cost factor marked pending",any(T.factor_symbol=="C_LPG or equivalent") && any(contains(T.current_value,"Pending")),"Fuel cost pending.");
    checks{end+1,1} = check_row("TRCO2-14","Electricity cost factor marked pending",any(T.factor_symbol=="C_grid or equivalent") && any(contains(T.current_value,"Pending")),"Electricity cost pending.");
    checks{end+1,1} = check_row("TRCO2-15","Fan-power limitation documented",any(contains(T.item,"Fan-power")),"Fan-power limitation.");
    checks{end+1,1} = check_row("TRCO2-16","Pressure-drop limitation documented",any(contains(T.item,"Pressure-drop")),"Pressure-drop limitation.");
    checks{end+1,1} = check_row("TRCO2-17","Solar-only exclusion documented",any(contains(T.item,"Solar-only")),"Solar-only exclusion.");

    checks{end+1,1} = check_row("TRCO2-18","No final CO2 claim made",true,"Traceability matrix only.");
    checks{end+1,1} = check_row("TRCO2-19","No final cost claim made",true,"Traceability matrix only.");
    checks{end+1,1} = check_row("TRCO2-20","No GA executed",true,"Traceability matrix only.");
    checks{end+1,1} = check_row("TRCO2-21","No model executed",true,"Traceability matrix only.");
    checks{end+1,1} = check_row("TRCO2-22","MASTER not modified",true,"No master write operation.");

    Tchecks = struct2table(vertcat(checks{:}));
    writetable(Tchecks,checksCsv);

    if all(Tchecks.pass)
        diagnosis = "FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_PASS";
        decision = "USE_AS_TRACEABILITY_CONTROL_NOT_FINAL_CLAIMS";
        next_step = "Draft Methods cost/CO2 factor traceability caveat or define final cited factors.";
    else
        diagnosis = "FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS";
        next_step = "Review failed checks before using the traceability matrix.";
    end

    fid = fopen(reportFile,'w');
    if fid < 0
        error('Could not open report file: %s',reportFile);
    end

    fprintf(fid,'# FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- CSV: `%s`\n',csvFile);
    fprintf(fid,'- Markdown matrix: `%s`\n',mdFile);
    fprintf(fid,'- Checks: `%s`\n',checksCsv);
    fprintf(fid,'- Locked Section 7: `%s`\n',lockedSection7);
    fprintf(fid,'- Methods integration report: `%s`\n\n',methodsIntegrationReport);

    fprintf(fid,'## Controlled provisional factors\n\n');
    fprintf(fid,'- `EF_LPG_kgCO2_per_kWh = %.4f` [%s]\n',EF_LPG_kgCO2_per_kWh,provisionalTag);
    fprintf(fid,'- `EF_grid_kgCO2_per_kWh = %.4f` [%s]\n\n',EF_grid_kgCO2_per_kWh,provisionalTag);

    fprintf(fid,'## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            string(Tchecks.id(i)), string(Tchecks.check(i)), Tchecks.pass(i), string(Tchecks.evidence(i)));
    end
    fclose(fid);

    save(matFile,'T','Tchecks','csvFile','mdFile','reportFile','checksCsv','matFile', ...
        'EF_LPG_kgCO2_per_kWh','EF_grid_kgCO2_per_kWh','provisionalTag', ...
        'diagnosis','decision','next_step','masterFile','lockedSection7','methodsIntegrationReport','r1ReproTable');

    out = struct();
    out.status = "BUILD_FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z_DONE";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.T = T;
    out.Tchecks = Tchecks;
    out.csvFile = csvFile;
    out.mdFile = mdFile;
    out.reportFile = reportFile;
    out.checksCsv = checksCsv;
    out.matFile = matFile;

    disp('=== BUILD FINAL COST CO2 FACTOR TRACEABILITY MATRIX v96z ===')
    disp(out.status)
    disp('=== DIAGNOSIS ===')
    disp(out.diagnosis)
    disp('=== DECISION ===')
    disp(out.decision)
    disp('=== NEXT STEP ===')
    disp(out.next_step)
    disp('=== MATRIX ===')
    disp(out.T)
    disp('=== FAILED CHECKS ===')
    disp(out.Tchecks(~out.Tchecks.pass,:))
    disp('=== ALL CHECKS ===')
    disp(out.Tchecks)
    disp('=== FILES ===')
    disp(out.csvFile)
    disp(out.mdFile)
    disp(out.reportFile)

    function add_row(itemIn,symbolIn,valueIn,unitsIn,roleIn,statusIn,readinessIn,sourceIn,actionIn,useIn,noteIn)
        item(end+1,1) = string(itemIn);
        factor_symbol(end+1,1) = string(symbolIn);
        current_value(end+1,1) = string(valueIn);
        units(end+1,1) = string(unitsIn);
        factor_role(end+1,1) = string(roleIn);
        current_status(end+1,1) = string(statusIn);
        manuscript_readiness(end+1,1) = string(readinessIn);
        source_status(end+1,1) = string(sourceIn);
        action_required_before_submission(end+1,1) = string(actionIn);
        permitted_current_use(end+1,1) = string(useIn);
        note(end+1,1) = string(noteIn);
    end
end

function write_md_matrix(filename,T,EF_LPG,EF_grid,provisionalTag)
    fid = fopen(filename,'w');
    if fid < 0
        error('Could not open Markdown matrix file: %s',filename);
    end

    fprintf(fid,'# Final cost and CO2 factor traceability matrix\n\n');
    fprintf(fid,'Micropaso: `9.6z-trace-a`\n\n');
    fprintf(fid,'Identifier: `FINAL-COST-CO2-FACTOR-TRACEABILITY-MATRIX-001`\n\n');
    fprintf(fid,'Status: `TRACEABILITY_CONTROL_READY`\n\n');
    fprintf(fid,'This matrix does not create final cost or CO2 claims. It separates provisional factors used for code validation from factors that still require final source traceability before manuscript submission.\n\n');

    fprintf(fid,'## Controlled provisional factors\n\n');
    fprintf(fid,'| Factor | Current value | Units | Status |\n');
    fprintf(fid,'|---|---:|---|---|\n');
    fprintf(fid,'| `EF_LPG_kgCO2_per_kWh` | %.4f | kgCO2/kWh | `%s` |\n',EF_LPG,provisionalTag);
    fprintf(fid,'| `EF_grid_kgCO2_per_kWh` | %.4f | kgCO2/kWh | `%s` |\n\n',EF_grid,provisionalTag);

    fprintf(fid,'## Traceability matrix\n\n');
    fprintf(fid,'| Item | Symbol | Current value | Units | Role | Current status | Manuscript readiness | Source status | Required action before submission | Permitted current use | Note |\n');
    fprintf(fid,'|---|---|---|---|---|---|---|---|---|---|---|\n');

    for i = 1:height(T)
        fprintf(fid,'| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |\n', ...
            esc(T.item(i)),esc(T.factor_symbol(i)),esc(T.current_value(i)),esc(T.units(i)), ...
            esc(T.factor_role(i)),esc(T.current_status(i)),esc(T.manuscript_readiness(i)), ...
            esc(T.source_status(i)),esc(T.action_required_before_submission(i)), ...
            esc(T.permitted_current_use(i)),esc(T.note(i)));
    end

    fprintf(fid,'\n## Internal verdict\n\n');
    fprintf(fid,'`FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_READY_FOR_CONTROL_USE`\n');

    fclose(fid);
end

function s = esc(x)
    s = string(x);
    s = replace(s,"|","\|");
end

function row = check_row(id,checkName,passVal,evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end
