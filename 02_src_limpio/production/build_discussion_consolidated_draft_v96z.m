function out = build_discussion_consolidated_draft_v96z()
% BUILD_DISCUSSION_CONSOLIDATED_DRAFT_v96z
%
% 9.6z-discussion-a
% BUILD-DISCUSSION-CONSOLIDATED-DRAFT-001
%
% Objetivo:
%   Redactar y auditar una seccion Discussion consolidada para el manuscrito,
%   sin repetir numericamente la Seccion 7 y manteniendo las cautelas ya
%   auditadas.
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica MASTER.
% No modifica Section 7.

    rootDir = setup_v05_paths();

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    draftDir   = fullfile(articleRoot,'draft_sections');
    reviewDir  = fullfile(articleRoot,'review');
    traceDir   = fullfile(articleRoot,'traceability');
    lockDir    = fullfile(articleRoot,'locked_sections');
    tablesDir  = fullfile(articleRoot,'tables');

    if ~isfolder(draftDir), mkdir(draftDir); end
    if ~isfolder(reviewDir), mkdir(reviewDir); end
    if ~isfolder(traceDir), mkdir(traceDir); end

    masterFile = fullfile(draftDir,'MASTER_manuscript_v01.md');
    lockedSection7 = fullfile(lockDir,'RESULTS_SECTION_07_v01_1_LOCKED.md');
    masterAuditReport = fullfile(reviewDir,'MASTER_MANUSCRIPT_CONSISTENCY_AUDIT_v96z_report.md');
    r1Table = fullfile(tablesDir,'R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z.md');
    etaTable = fullfile(tablesDir,'MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md');
    hybridBaseline = fullfile(tablesDir,'SELECTED_POINTS_HYBRID_vs_GASLP_v96z_summary.md');
    limitationsBlock = fullfile(draftDir,'SEC_LIMITATIONS_CONSOLIDATED_BLOCK_v96z.md');
    costCo2Caveat = fullfile(draftDir,'SEC_METHODS_COST_CO2_FACTOR_TRACEABILITY_CAVEAT_v96z.md');

    secFile = fullfile(draftDir,'SEC_DISCUSSION_CONSOLIDATED_DRAFT_v96z.md');
    reportFile = fullfile(reviewDir,'SEC_DISCUSSION_CONSOLIDATED_DRAFT_v96z_report.md');
    checksCsv = fullfile(reviewDir,'SEC_DISCUSSION_CONSOLIDATED_DRAFT_v96z_Tchecks.csv');
    matFile = fullfile(traceDir,'SEC_DISCUSSION_CONSOLIDATED_DRAFT_v96z.mat');

    L = strings(0,1);

    add("# SEC_DISCUSSION_CONSOLIDATED_DRAFT_v96z");
    add("");
    add("## Status");
    add("");
    add("`DRAFT_READY_FOR_REVIEW`");
    add("");
    add("## Micropaso");
    add("");
    add("`9.6z-discussion-a`");
    add("");
    add("## Identifier");
    add("");
    add("`BUILD-DISCUSSION-CONSOLIDATED-DRAFT-001`");
    add("");
    add("## Intended master location");
    add("");
    add("Discussion section, after Results and before Limitations/Conclusions.");
    add("");
    add("## Source controls");
    add("");
    add("- `RESULTS_SECTION_07_v01_1_LOCKED.md`");
    add("- `MASTER_MANUSCRIPT_CONSISTENCY_AUDIT_v96z_report.md`");
    add("- `R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z.md`");
    add("- `MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md`");
    add("- `SELECTED_POINTS_HYBRID_vs_GASLP_v96z_summary.md`");
    add("- `SEC_LIMITATIONS_CONSOLIDATED_BLOCK_v96z.md`");
    add("- `SEC_METHODS_COST_CO2_FACTOR_TRACEABILITY_CAVEAT_v96z.md`");
    add("");
    add("## Manuscript text -- English");
    add("");
    add("### Discussion");
    add("");
    add("The formal R1 optimization and the subsequent sensitivity and baseline analyses indicate that the most relevant operating region is not defined by a single extreme drying condition, but by a trade-off between final moisture reduction, auxiliary energy demand, and the imposed process constraints. Within the computed nondominated set, R1_solution_7 represents the most energy-conservative feasible candidate among the selected R1 points, whereas R1_solution_3 provides a more balanced compromise between drying intensity and energy use. By contrast, R1_solution_9 illustrates the expected penalty of pursuing deeper drying through a more aggressive thermal strategy. This separation is useful because it avoids treating all feasible low-moisture solutions as operationally equivalent.");
    add("");
    add("The comparison with the historical H2 operating point also clarifies the interpretation of the optimization results. H2 remains a useful reference because it reflects a previously identified low-moisture operating condition and provides continuity with earlier analysis. However, it should not be interpreted as a newly optimized R1 solution. The R1 candidates instead show that comparable feasibility can be reached with operating strategies that shift the balance toward lower auxiliary energy demand. This is particularly relevant for process operation, where the preferred condition is not necessarily the one producing the lowest final moisture ratio, but the one satisfying the drying target with the lowest practical energy penalty.");
    add("");
    add("The collector-efficiency sensitivity analysis supports the qualitative stability of this interpretation. Using the 2-SAH efficiency curve, which is consistent with the physical arrangement of two solar air heaters in series per battery, changed the magnitude of the auxiliary-energy requirement but did not overturn the selected-point ranking. This suggests that the main operational conclusion is not solely an artifact of assuming a fixed collector efficiency. Nevertheless, the collector treatment remains a sensitivity model rather than a fully coupled dynamic collector simulation. The result should therefore be read as evidence of ranking stability under a more physically consistent efficiency assumption, not as complete collector-level validation.");
    add("");
    add("The hybrid versus gas-LPG baseline comparison further shows that the hybrid configuration reduces the auxiliary-energy requirement for the selected feasible operating points. The reduction is mainly attributable to solar substitution rather than to a relaxation of the drying requirement, because the compared cases preserve feasible final moisture-ratio behavior. This reinforces the practical value of the hybrid system: the solar contribution can reduce fuel demand while maintaining drying feasibility. At the same time, the magnitude of any final economic or CO2 benefit remains conditional on the final fuel-price, electricity-tariff, emission-factor, date, region, unit-basis, and conversion assumptions.");
    add("");
    add("From an operational standpoint, the results favor a moderate-to-low airflow range combined with high recirculation and an intermediate-late onset of recirculation for the feasible energy-saving candidates. This trend is physically plausible because recirculation can retain useful thermal energy in the drying loop while avoiding excessive fresh-air heating demand. However, this interpretation is bounded by the implemented model structure and by the absence of a fully coupled fan-power and pressure-drop formulation. Future optimization should therefore include airflow-distribution, fan-power, and pressure-drop penalties before making equipment-level design recommendations.");
    add("");
    add("Overall, the computed results support the hybrid dryer as an energy-saving operating strategy under the modeled conditions, with R1_solution_7 as the main energy-conservative candidate and R1_solution_3 as a balanced alternative. The discussion should not be interpreted as evidence of statistical robustness across independent seeds, proof of complete convergence of the search space, or complete equipment-level optimality. Rather, it establishes a controlled, reproducible, and traceable basis for selecting candidate operating points for further validation and for future coupled techno-economic and environmental assessment.");
    add("");
    add("## Version tecnica de control -- Espanol");
    add("");
    add("### Discusion");
    add("");
    add("La optimizacion formal R1 y los analisis posteriores de sensibilidad y comparacion de lineas base indican que la region operativa mas relevante no esta definida por una unica condicion extrema de secado, sino por un compromiso entre reduccion de humedad final, demanda de energia auxiliar y restricciones de proceso. Dentro del conjunto no dominado computado, R1_solution_7 representa el candidato factible mas conservador energeticamente entre los puntos R1 seleccionados, mientras que R1_solution_3 ofrece un compromiso mas balanceado entre intensidad de secado y uso de energia. En contraste, R1_solution_9 ilustra la penalizacion esperada al buscar secado mas profundo mediante una estrategia termica mas agresiva. Esta separacion es util porque evita tratar todas las soluciones factibles de baja humedad como operacionalmente equivalentes.");
    add("");
    add("La comparacion con el punto historico H2 tambien aclara la interpretacion de los resultados de optimizacion. H2 sigue siendo una referencia util porque refleja una condicion operativa de baja humedad identificada previamente y da continuidad al analisis anterior. Sin embargo, no debe interpretarse como una solucion R1 nuevamente optimizada. Los candidatos R1 muestran, en cambio, que puede alcanzarse factibilidad comparable con estrategias operativas que desplazan el balance hacia menor demanda de energia auxiliar. Esto es relevante para la operacion del proceso, donde la condicion preferida no necesariamente es la que produce la humedad final mas baja, sino la que satisface el objetivo de secado con la menor penalizacion energetica practica.");
    add("");
    add("El analisis de sensibilidad de eficiencia del colector respalda la estabilidad cualitativa de esta interpretacion. El uso de la curva 2-SAH, consistente con la configuracion fisica de dos calentadores solares de aire en serie por bateria, modifico la magnitud de la demanda de energia auxiliar, pero no invirtio el ordenamiento de los puntos seleccionados. Esto sugiere que la conclusion operativa principal no depende exclusivamente de asumir una eficiencia fija del colector. No obstante, el tratamiento del colector sigue siendo un modelo de sensibilidad y no una simulacion dinamica de colector completamente acoplada. Por tanto, el resultado debe leerse como evidencia de estabilidad del ordenamiento bajo una suposicion de eficiencia fisicamente mas consistente, no como validacion completa a nivel de colector.");
    add("");
    add("La comparacion hibrido contra linea base gas LP muestra ademas que la configuracion hibrida reduce la demanda de energia auxiliar para los puntos operativos factibles seleccionados. La reduccion se atribuye principalmente a sustitucion solar y no a una relajacion del requisito de secado, porque los casos comparados preservan comportamiento factible de razon de humedad final. Esto refuerza el valor practico del sistema hibrido: la contribucion solar puede reducir la demanda de combustible mientras mantiene la factibilidad de secado. Al mismo tiempo, la magnitud de cualquier beneficio economico o de CO2 final permanece condicionada por los supuestos definitivos de precio de combustible, tarifa electrica, factor de emision, fecha, region, base de unidades y conversion.");
    add("");
    add("Desde el punto de vista operativo, los resultados favorecen un intervalo de flujo de aire moderado a bajo, combinado con alta recirculacion y un inicio intermedio-tardio de recirculacion para los candidatos factibles de ahorro energetico. Esta tendencia es fisicamente plausible porque la recirculacion puede retener energia termica util en el circuito de secado y evitar una demanda excesiva de calentamiento de aire fresco. Sin embargo, esta interpretacion esta acotada por la estructura del modelo implementado y por la ausencia de una formulacion completamente acoplada de potencia de ventiladores y caida de presion. Por ello, una optimizacion futura deberia incluir distribucion de flujo, potencia de ventiladores y penalizaciones por caida de presion antes de formular recomendaciones de diseno a nivel de equipo.");
    add("");
    add("En conjunto, los resultados computados respaldan al secador hibrido como una estrategia operativa de ahorro energetico bajo las condiciones modeladas, con R1_solution_7 como principal candidato conservador energeticamente y R1_solution_3 como alternativa balanceada. La discusion no debe interpretarse como evidencia de robustez estadistica entre semillas independientes, prueba de convergencia completa del espacio de busqueda ni optimalidad completa a nivel de equipo. Mas bien, establece una base controlada, reproducible y trazable para seleccionar puntos operativos candidatos para validacion posterior y para una futura evaluacion tecnoeconomica y ambiental acoplada.");
    add("");
    add("## Discussion anchors");
    add("");
    add("| Anchor | Required interpretation |");
    add("|---|---|");
    add("| R1_solution_7 | energy-conservative feasible candidate |");
    add("| R1_solution_3 | balanced alternative |");
    add("| R1_solution_9 | aggressive drying / high energy penalty |");
    add("| H2 | historical reference, not new R1 solution |");
    add("| 2-SAH | sensitivity evidence, not fully coupled collector validation |");
    add("| Hybrid vs gas-LPG | auxiliary-energy reduction through solar substitution |");
    add("| Cost/CO2 | conditional on final cited factors |");
    add("| Fan power / pressure drop | future coupled optimization requirement |");
    add("| Robustness | no statistical robustness claim |");
    add("");
    add("## Internal verdict");
    add("");
    add("`SEC_DISCUSSION_CONSOLIDATED_DRAFT_v96z_READY_FOR_DISCUSSION_INTEGRATION`");

    fid = fopen(secFile,'w');
    if fid < 0
        error('Could not open Discussion section file: %s',secFile);
    end
    for i = 1:numel(L)
        fprintf(fid,'%s\n',L(i));
    end
    fclose(fid);

    txt = fileread(secFile);
    low = lower(string(txt));

    checks = {};
    checks{end+1,1} = check_row("DISC-01","MASTER exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("DISC-02","Locked Section 7 exists",isfile(lockedSection7),lockedSection7);
    checks{end+1,1} = check_row("DISC-03","MASTER audit report exists",isfile(masterAuditReport),masterAuditReport);
    checks{end+1,1} = check_row("DISC-04","R1 reproducibility table exists",isfile(r1Table),r1Table);
    checks{end+1,1} = check_row("DISC-05","ETA 2-SAH table exists",isfile(etaTable),etaTable);
    checks{end+1,1} = check_row("DISC-06","Hybrid baseline summary exists",isfile(hybridBaseline),hybridBaseline);
    checks{end+1,1} = check_row("DISC-07","Limitations block exists",isfile(limitationsBlock),limitationsBlock);
    checks{end+1,1} = check_row("DISC-08","Cost/CO2 caveat exists",isfile(costCo2Caveat),costCo2Caveat);
    checks{end+1,1} = check_row("DISC-09","Discussion draft file created",isfile(secFile),secFile);

    checks{end+1,1} = check_row("DISC-10","English manuscript block present",contains(txt,"## Manuscript text -- English"),"English block.");
    checks{end+1,1} = check_row("DISC-11","Spanish control block present",contains(txt,"## Version tecnica de control -- Espanol"),"Spanish block.");

    checks{end+1,1} = check_row("DISC-12","R1_solution_7 interpretation present",contains(txt,"R1_solution_7") && contains(low,"energy-conservative"),"R1_solution_7.");
    checks{end+1,1} = check_row("DISC-13","R1_solution_3 interpretation present",contains(txt,"R1_solution_3") && contains(low,"balanced"),"R1_solution_3.");
    checks{end+1,1} = check_row("DISC-14","R1_solution_9 interpretation present",contains(txt,"R1_solution_9") && contains(low,"aggressive"),"R1_solution_9.");
    checks{end+1,1} = check_row("DISC-15","H2 historical reference present",contains(txt,"H2") && contains(low,"historical reference"),"H2.");
    checks{end+1,1} = check_row("DISC-16","H2 not new R1 solution caveat present",contains(low,"not be interpreted as a newly optimized r1 solution") || contains(low,"no debe interpretarse como una solucion r1"),"H2 caveat.");

    checks{end+1,1} = check_row("DISC-17","Computed nondominated set wording present",contains(low,"computed nondominated set"),"Computed nondominated set.");
    checks{end+1,1} = check_row("DISC-18","No prohibited global optimum wording",~contains(low,"global optimum") && ~contains(low,"globally optimal"),"No prohibited wording.");
    checks{end+1,1} = check_row("DISC-19","No prohibited global Pareto front wording",~contains(low,"global pareto front"),"No prohibited wording.");
    checks{end+1,1} = check_row("DISC-20","No statistical robustness claim",~contains(low,"statistically robust") && ~contains(low,"robust across seeds"),"No robustness overclaim.");
    checks{end+1,1} = check_row("DISC-21","Statistical robustness caveat present",contains(low,"not be interpreted as evidence of statistical robustness") || contains(low,"no debe interpretarse como evidencia de robustez estadistica"),"Robustness caveat.");

    checks{end+1,1} = check_row("DISC-22","2-SAH sensitivity discussion present",contains(low,"2-sah") && contains(low,"sensitivity"),"2-SAH.");
    checks{end+1,1} = check_row("DISC-23","Not fully coupled collector caveat present",contains(low,"fully coupled dynamic collector simulation") || contains(low,"simulacion dinamica de colector completamente acoplada"),"Collector caveat.");
    checks{end+1,1} = check_row("DISC-24","Hybrid vs gas-LPG discussion present",contains(low,"hybrid versus gas-lpg") || contains(low,"hibrido contra linea base gas lp"),"Hybrid baseline.");
    checks{end+1,1} = check_row("DISC-25","Solar substitution interpretation present",contains(low,"solar substitution") || contains(low,"sustitucion solar"),"Solar substitution.");
    checks{end+1,1} = check_row("DISC-26","Cost/CO2 conditionality present",contains(low,"conditional on") && contains(low,"emission-factor"),"Cost/CO2 conditionality.");
    checks{end+1,1} = check_row("DISC-27","Fan-power limitation present",contains(low,"fan-power") || contains(low,"ventiladores"),"Fan-power.");
    checks{end+1,1} = check_row("DISC-28","Pressure-drop limitation present",contains(low,"pressure-drop") || contains(low,"caida de presion"),"Pressure-drop.");

    checks{end+1,1} = check_row("DISC-29","No final CO2 claim introduced",~contains(low,"final co2 reduction") && ~contains(low,"final emission reduction") && ~contains(low,"definitive emission reduction"),"No final CO2 claim.");
    checks{end+1,1} = check_row("DISC-30","No final cost claim introduced",~contains(low,"final cost reduction") && ~contains(low,"final economic saving") && ~contains(low,"definitive economic saving"),"No final cost claim.");
    checks{end+1,1} = check_row("DISC-31","No excessive numeric repetition",~contains(txt,"656.23") && ~contains(txt,"723.36") && ~contains(txt,"1218.4") && ~contains(txt,"747.00"),"Avoids repeating Section 7 numeric table.");
    checks{end+1,1} = check_row("DISC-32","No GA executed",true,"Text generation only.");
    checks{end+1,1} = check_row("DISC-33","No model executed",true,"Text generation only.");
    checks{end+1,1} = check_row("DISC-34","MASTER not modified",true,"No master write operation.");

    Tchecks = struct2table(vertcat(checks{:}));
    writetable(Tchecks,checksCsv);

    if all(Tchecks.pass)
        diagnosis = "SEC_DISCUSSION_CONSOLIDATED_DRAFT_PASS";
        decision = "READY_FOR_DISCUSSION_INTEGRATION";
        next_step = "Integrate Discussion consolidated draft into MASTER.";
    else
        diagnosis = "SEC_DISCUSSION_CONSOLIDATED_DRAFT_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS";
        next_step = "Review failed checks before Discussion integration.";
    end

    fid = fopen(reportFile,'w');
    if fid < 0
        error('Could not open Discussion report file: %s',reportFile);
    end

    fprintf(fid,'# SEC_DISCUSSION_CONSOLIDATED_DRAFT_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- Discussion section: `%s`\n',secFile);
    fprintf(fid,'- Checks: `%s`\n',checksCsv);
    fprintf(fid,'- Locked Section 7: `%s`\n',lockedSection7);
    fprintf(fid,'- MASTER audit report: `%s`\n',masterAuditReport);
    fprintf(fid,'- Limitations block: `%s`\n\n',limitationsBlock);

    fprintf(fid,'## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            string(Tchecks.id(i)), string(Tchecks.check(i)), Tchecks.pass(i), string(Tchecks.evidence(i)));
    end
    fclose(fid);

    save(matFile,'secFile','reportFile','checksCsv','matFile','lockedSection7','masterAuditReport','r1Table','etaTable','hybridBaseline','limitationsBlock','costCo2Caveat','Tchecks','diagnosis','decision','next_step');

    out = struct();
    out.status = "BUILD_DISCUSSION_CONSOLIDATED_DRAFT_v96z_DONE";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.secFile = secFile;
    out.reportFile = reportFile;
    out.checksCsv = checksCsv;
    out.matFile = matFile;
    out.Tchecks = Tchecks;

    disp('=== BUILD DISCUSSION CONSOLIDATED DRAFT v96z ===')
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
