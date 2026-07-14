function out = draft_cost_co2_factor_traceability_caveat_v96z()
% DRAFT_COST_CO2_FACTOR_TRACEABILITY_CAVEAT_v96z
%
% 9.6z-trace-b
% DRAFT-COST-CO2-FACTOR-TRACEABILITY-CAVEAT-001
%
% Objetivo:
%   Crear y auditar un bloque de texto para Methods/Limitations sobre la
%   trazabilidad de factores economicos y de CO2.
%
% Principio:
%   No convertir factores provisionales en afirmaciones finales.
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica MASTER.
% No modifica Section 7.

    rootDir = setup_v05_paths();

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    draftDir   = fullfile(articleRoot,'draft_sections');
    tablesDir  = fullfile(articleRoot,'tables');
    reviewDir  = fullfile(articleRoot,'review');
    traceDir   = fullfile(articleRoot,'traceability');

    if ~isfolder(draftDir), mkdir(draftDir); end
    if ~isfolder(reviewDir), mkdir(reviewDir); end
    if ~isfolder(traceDir), mkdir(traceDir); end

    traceMatrixMd = fullfile(tablesDir,'FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z.md');
    traceMatrixCsv = fullfile(tablesDir,'FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z.csv');
    traceMatrixReport = fullfile(reviewDir,'FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z_report.md');

    secFile = fullfile(draftDir,'SEC_METHODS_COST_CO2_FACTOR_TRACEABILITY_CAVEAT_v96z.md');
    reportFile = fullfile(reviewDir,'SEC_METHODS_COST_CO2_FACTOR_TRACEABILITY_CAVEAT_v96z_report.md');
    checksCsv = fullfile(reviewDir,'SEC_METHODS_COST_CO2_FACTOR_TRACEABILITY_CAVEAT_v96z_Tchecks.csv');
    matFile = fullfile(traceDir,'SEC_METHODS_COST_CO2_FACTOR_TRACEABILITY_CAVEAT_v96z.mat');

    EF_LPG_kgCO2_per_kWh = 0.2270;
    EF_grid_kgCO2_per_kWh = 0.4380;
    provisionalTag = "PROVISIONAL_FOR_CODE_VALIDATION";

    L = strings(0,1);

    add("# SEC_METHODS_COST_CO2_FACTOR_TRACEABILITY_CAVEAT_v96z");
    add("");
    add("## Status");
    add("");
    add("`DRAFT_READY_FOR_REVIEW`");
    add("");
    add("## Micropaso");
    add("");
    add("`9.6z-trace-b`");
    add("");
    add("## Identifier");
    add("");
    add("`DRAFT-COST-CO2-FACTOR-TRACEABILITY-CAVEAT-001`");
    add("");
    add("## Intended master location");
    add("");
    add("Methods or Limitations, after the description of economic and environmental objectives.");
    add("");
    add("## Source traceability matrix");
    add("");
    add("- `FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z.md`");
    add("- `FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z.csv`");
    add("- `FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z_report.md`");
    add("");
    add("## Manuscript text -- English");
    add("");
    add("### Traceability of economic and CO2 factors");
    add("");
    add("Economic and environmental indicators were handled through a separate factor-traceability matrix in order to distinguish computed model outputs from source-dependent conversion factors. The auxiliary energy values reported for the selected operating points are treated as computed outputs of the drying model and post-processing workflow. In contrast, cost and CO2 indicators depend on external factors such as fuel price, electricity tariff, emission factor, source year, region, unit basis, and conversion assumptions.");
    add("");
    add("For code validation and internal traceability control, the provisional CO2 factors `EF_LPG_kgCO2_per_kWh = 0.2270` and `EF_grid_kgCO2_per_kWh = 0.4380` were retained under the tag `PROVISIONAL_FOR_CODE_VALIDATION`. These factors are not treated as final manuscript-grade emission factors. Before submission, each final cost or CO2 claim must be linked to a definitive source, date, unit basis, and conversion procedure. Therefore, the present results should be interpreted primarily through the reported energy demand and relative comparisons unless the corresponding final economic and emission factors are explicitly cited and locked.");
    add("");
    add("The same traceability control applies to equipment-level effects. Fan-power consumption and pressure-drop coupling were not fully included as optimization objectives; consequently, the present economic and environmental indicators should not be interpreted as complete equipment-level optimality claims. These effects are retained as methodological limitations and as future-work requirements for a fully coupled techno-economic and environmental assessment.");
    add("");
    add("## Version tecnica de control -- Espanol");
    add("");
    add("### Trazabilidad de factores economicos y de CO2");
    add("");
    add("Los indicadores economicos y ambientales se manejaron mediante una matriz separada de trazabilidad de factores, con el fin de distinguir las salidas computadas del modelo de secado de los factores de conversion dependientes de fuentes externas. Los valores de energia auxiliar reportados para los puntos operativos seleccionados se tratan como salidas computadas del modelo y del flujo de postprocesamiento. En cambio, los indicadores de costo y CO2 dependen de factores externos como precio de combustible, tarifa electrica, factor de emision, ano de la fuente, region, base de unidades y supuestos de conversion.");
    add("");
    add("Para validacion de codigo y control interno de trazabilidad, se conservaron los factores provisionales de CO2 `EF_LPG_kgCO2_per_kWh = 0.2270` y `EF_grid_kgCO2_per_kWh = 0.4380` bajo la etiqueta `PROVISIONAL_FOR_CODE_VALIDATION`. Estos factores no se tratan como factores de emision finales para afirmaciones definitivas del manuscrito. Antes del envio, toda afirmacion final de costo o CO2 debe estar vinculada a una fuente definitiva, fecha, base de unidades y procedimiento de conversion. Por tanto, los resultados actuales deben interpretarse principalmente mediante la demanda energetica reportada y las comparaciones relativas, salvo que los factores economicos y de emision finales correspondientes esten explicitamente citados y bloqueados.");
    add("");
    add("El mismo control de trazabilidad aplica a los efectos a nivel de equipo. El consumo electrico de ventiladores y el acoplamiento con caida de presion no se incluyeron completamente como objetivos de optimizacion; en consecuencia, los indicadores economicos y ambientales actuales no deben interpretarse como afirmaciones de optimalidad completa a nivel de equipo. Estos efectos se conservan como limitaciones metodologicas y como requerimientos de trabajo futuro para una evaluacion tecnoeconomica y ambiental completamente acoplada.");
    add("");
    add("## Traceability anchors");
    add("");
    add("| Item | Value | Status |");
    add("|---|---:|---|");
    add("| `EF_LPG_kgCO2_per_kWh` | 0.2270 | `PROVISIONAL_FOR_CODE_VALIDATION` |");
    add("| `EF_grid_kgCO2_per_kWh` | 0.4380 | `PROVISIONAL_FOR_CODE_VALIDATION` |");
    add("| Fuel cost factor | pending final source/value | not final for manuscript claims |");
    add("| Electricity cost factor | pending final source/value | not final for manuscript claims |");
    add("| Fan-power coupling | not fully coupled | limitation/future work |");
    add("| Pressure-drop coupling | not fully coupled | limitation/future work |");
    add("");
    add("## Internal verdict");
    add("");
    add("`SEC_METHODS_COST_CO2_FACTOR_TRACEABILITY_CAVEAT_v96z_READY_FOR_REVIEW`");

    fid = fopen(secFile,'w');
    if fid < 0
        error('Could not open caveat section file: %s',secFile);
    end
    for i = 1:numel(L)
        fprintf(fid,'%s\n',L(i));
    end
    fclose(fid);

    txt = fileread(secFile);
    low = lower(string(txt));

    checks = {};
    checks{end+1,1} = check_row("TRCB-01","Traceability matrix MD exists",isfile(traceMatrixMd),traceMatrixMd);
    checks{end+1,1} = check_row("TRCB-02","Traceability matrix CSV exists",isfile(traceMatrixCsv),traceMatrixCsv);
    checks{end+1,1} = check_row("TRCB-03","Traceability matrix report exists",isfile(traceMatrixReport),traceMatrixReport);
    checks{end+1,1} = check_row("TRCB-04","Caveat section file created",isfile(secFile),secFile);
    checks{end+1,1} = check_row("TRCB-05","English manuscript text present",contains(txt,"## Manuscript text -- English"),"English block.");
    checks{end+1,1} = check_row("TRCB-06","Spanish control text present",contains(txt,"## Version tecnica de control -- Espanol"),"Spanish block.");
    checks{end+1,1} = check_row("TRCB-07","LPG factor documented",contains(txt,"EF_LPG_kgCO2_per_kWh = 0.2270"),"LPG factor.");
    checks{end+1,1} = check_row("TRCB-08","Grid factor documented",contains(txt,"EF_grid_kgCO2_per_kWh = 0.4380"),"Grid factor.");
    checks{end+1,1} = check_row("TRCB-09","Provisional tag documented",contains(txt,provisionalTag),"Provisional tag.");
    checks{end+1,1} = check_row("TRCB-10","Not final manuscript-grade caveat present",contains(low,"not treated as final") || contains(low,"not final"),"Not final caveat.");
    checks{end+1,1} = check_row("TRCB-11","Final source requirement present",contains(low,"definitive source") || contains(low,"fuente definitiva"),"Source requirement.");
    checks{end+1,1} = check_row("TRCB-12","Date requirement present",contains(low,"date") || contains(low,"fecha"),"Date requirement.");
    checks{end+1,1} = check_row("TRCB-13","Unit-basis requirement present",contains(low,"unit basis") || contains(low,"base de unidades"),"Unit basis requirement.");
    checks{end+1,1} = check_row("TRCB-14","Conversion-procedure requirement present",contains(low,"conversion procedure") || contains(low,"procedimiento de conversion"),"Conversion procedure.");
    checks{end+1,1} = check_row("TRCB-15","Energy-demand-first interpretation present",contains(low,"energy demand") || contains(low,"demanda energetica"),"Energy interpretation.");
    checks{end+1,1} = check_row("TRCB-16","Fan-power limitation present",contains(low,"fan-power") || contains(low,"ventiladores"),"Fan-power limitation.");
    checks{end+1,1} = check_row("TRCB-17","Pressure-drop limitation present",contains(low,"pressure-drop") || contains(low,"caida de presion"),"Pressure-drop limitation.");
    checks{end+1,1} = check_row("TRCB-18","No final CO2 claim made",~contains(low,"final co2 reduction") && ~contains(low,"final emission reduction"),"No final CO2 claim.");
    checks{end+1,1} = check_row("TRCB-19","No final cost claim made",~contains(low,"final cost reduction") && ~contains(low,"final economic saving"),"No final cost claim.");
    checks{end+1,1} = check_row("TRCB-20","No GA executed",true,"Text generation only.");
    checks{end+1,1} = check_row("TRCB-21","No model executed",true,"Text generation only.");
    checks{end+1,1} = check_row("TRCB-22","MASTER not modified",true,"No master write operation.");

    Tchecks = struct2table(vertcat(checks{:}));
    writetable(Tchecks,checksCsv);

    if all(Tchecks.pass)
        diagnosis = "SEC_METHODS_COST_CO2_FACTOR_TRACEABILITY_CAVEAT_PASS";
        decision = "READY_FOR_METHODS_OR_LIMITATIONS_INTEGRATION";
        next_step = "Integrate cost/CO2 traceability caveat into MASTER or define final cited factors.";
    else
        diagnosis = "SEC_METHODS_COST_CO2_FACTOR_TRACEABILITY_CAVEAT_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS";
        next_step = "Review failed checks before integration.";
    end

    fid = fopen(reportFile,'w');
    if fid < 0
        error('Could not open caveat report file: %s',reportFile);
    end

    fprintf(fid,'# SEC_METHODS_COST_CO2_FACTOR_TRACEABILITY_CAVEAT_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- Caveat section: `%s`\n',secFile);
    fprintf(fid,'- Checks: `%s`\n',checksCsv);
    fprintf(fid,'- Source traceability matrix MD: `%s`\n',traceMatrixMd);
    fprintf(fid,'- Source traceability matrix report: `%s`\n\n',traceMatrixReport);

    fprintf(fid,'## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            string(Tchecks.id(i)), string(Tchecks.check(i)), Tchecks.pass(i), string(Tchecks.evidence(i)));
    end
    fclose(fid);

    save(matFile,'secFile','reportFile','checksCsv','matFile','traceMatrixMd','traceMatrixCsv','traceMatrixReport','Tchecks','diagnosis','decision','next_step','EF_LPG_kgCO2_per_kWh','EF_grid_kgCO2_per_kWh','provisionalTag');

    out = struct();
    out.status = "DRAFT_COST_CO2_FACTOR_TRACEABILITY_CAVEAT_v96z_DONE";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.secFile = secFile;
    out.reportFile = reportFile;
    out.checksCsv = checksCsv;
    out.matFile = matFile;
    out.Tchecks = Tchecks;

    disp('=== DRAFT COST CO2 FACTOR TRACEABILITY CAVEAT v96z ===')
    disp(out.status)
    disp('=== DIAGNOSIS ===')
    disp(out.diagnosis)
    disp('=== DECISION ===')
    disp(out.decision)
    disp('=== NEXT STEP ===')
    disp(out.next_step)
    disp('=== FAILED CHECKS ===')
    disp(out.Tchecks(~out.Tchecks.pass,:))
    disp('=== ALL CHECKS ===')
    disp(out.Tchecks)
    disp('=== FILES ===')
    disp(out.secFile)
    disp(out.reportFile)
    disp(out.checksCsv)

    function add(s)
        L(end+1,1) = string(s);
    end
end

function row = check_row(id,checkName,passVal,evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end
