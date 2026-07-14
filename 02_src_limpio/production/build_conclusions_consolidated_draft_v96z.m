function out = build_conclusions_consolidated_draft_v96z()
% BUILD_CONCLUSIONS_CONSOLIDATED_DRAFT_v96z
%
% 9.6z-conclusions-a
% BUILD-CONCLUSIONS-CONSOLIDATED-DRAFT-001
%
% Objetivo:
%   Redactar y auditar una seccion Conclusions consolidada para el manuscrito,
%   sin sobreprometer y manteniendo las cautelas ya auditadas.
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
    afterDiscussionAudit = fullfile(reviewDir,'MASTER_MANUSCRIPT_CONSISTENCY_AFTER_DISCUSSION_v96z_report.md');
    discussionIntegrationReport = fullfile(reviewDir,'INTEGRATE_DISCUSSION_CONSOLIDATED_DRAFT_INTO_MASTER_v96z_report.md');
    limitationsIntegrationReport = fullfile(reviewDir,'INTEGRATE_LIMITATIONS_CONSOLIDATED_BLOCK_INTO_MASTER_v96z_report.md');
    costCo2Matrix = fullfile(tablesDir,'FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z.md');
    r1ReproTable = fullfile(tablesDir,'R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z.md');

    secFile = fullfile(draftDir,'SEC_CONCLUSIONS_CONSOLIDATED_DRAFT_v96z.md');
    reportFile = fullfile(reviewDir,'SEC_CONCLUSIONS_CONSOLIDATED_DRAFT_v96z_report.md');
    checksCsv = fullfile(reviewDir,'SEC_CONCLUSIONS_CONSOLIDATED_DRAFT_v96z_Tchecks.csv');
    matFile = fullfile(traceDir,'SEC_CONCLUSIONS_CONSOLIDATED_DRAFT_v96z.mat');

    L = strings(0,1);

    add("# SEC_CONCLUSIONS_CONSOLIDATED_DRAFT_v96z");
    add("");
    add("## Status");
    add("");
    add("`DRAFT_READY_FOR_REVIEW`");
    add("");
    add("## Micropaso");
    add("");
    add("`9.6z-conclusions-a`");
    add("");
    add("## Identifier");
    add("");
    add("`BUILD-CONCLUSIONS-CONSOLIDATED-DRAFT-001`");
    add("");
    add("## Intended master location");
    add("");
    add("Conclusions section, after Discussion/Limitations and before References.");
    add("");
    add("## Source controls");
    add("");
    add("- `RESULTS_SECTION_07_v01_1_LOCKED.md`");
    add("- `MASTER_MANUSCRIPT_CONSISTENCY_AFTER_DISCUSSION_v96z_report.md`");
    add("- `INTEGRATE_DISCUSSION_CONSOLIDATED_DRAFT_INTO_MASTER_v96z_report.md`");
    add("- `INTEGRATE_LIMITATIONS_CONSOLIDATED_BLOCK_INTO_MASTER_v96z_report.md`");
    add("- `R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z.md`");
    add("- `FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z.md`");
    add("");
    add("## Manuscript text -- English");
    add("");
    add("### Conclusions");
    add("");
    add("This study developed a controlled multiobjective optimization and post-processing workflow for a hybrid solar--gas-LPG tunnel dryer, with explicit traceability between the formal R1 optimization, collector-efficiency sensitivity, and hybrid versus gas-LPG baseline comparison. Under the modeled conditions, the hybrid configuration showed a consistent ability to reduce auxiliary-energy demand while preserving feasible drying performance for the selected operating points.");
    add("");
    add("Within the computed nondominated set, R1_solution_7 emerged as the main energy-conservative feasible candidate, whereas R1_solution_3 provided a balanced alternative between drying intensity and energy use. R1_solution_9 represented a more aggressive drying strategy with a larger energy penalty, and H2 was retained only as a historical reference rather than as a newly optimized R1 solution. This distinction supports an operational interpretation based on feasible trade-offs instead of selecting the deepest-drying point by default.");
    add("");
    add("The collector-efficiency sensitivity analysis, particularly the 2-SAH curve consistent with the physical series arrangement of the solar air heaters, did not alter the qualitative ranking of the selected candidates. This supports the stability of the main operational interpretation under a more physically consistent collector-efficiency assumption. However, the collector treatment remains a sensitivity representation and not a fully coupled dynamic collector model.");
    add("");
    add("The hybrid versus gas-LPG comparison indicated that the solar contribution can reduce auxiliary-energy demand mainly through fuel substitution, not by relaxing the drying requirement. Consequently, the hybrid system should be interpreted as a promising energy-saving operating strategy under the current model assumptions. Final economic or CO2 claims should remain conditional until fuel-price, electricity-tariff, emission-factor, date, region, unit-basis, and conversion assumptions are definitively sourced and locked.");
    add("");
    add("The main methodological limitations are associated with the use of a single formal R1 seed-aware run, the absence of independent seed replications, the sensitivity-level collector treatment, and the lack of fully coupled fan-power and pressure-drop objectives. Future work should therefore evaluate additional random seeds, implement a coupled collector and airflow-network formulation, include fan-power and pressure-drop penalties, and finalize the economic and emission factors before making publication-grade cost or CO2 claims.");
    add("");
    add("Overall, the results provide a reproducible and traceable basis for selecting candidate operating points for subsequent experimental or high-fidelity numerical validation. The conclusions should not be interpreted as proof of complete search-space convergence, statistical robustness across seeds, or complete equipment-level optimality.");
    add("");
    add("## Version tecnica de control -- Espanol");
    add("");
    add("### Conclusiones");
    add("");
    add("Este estudio desarrollo un flujo controlado de optimizacion multiobjetivo y postprocesamiento para un secador de tunel hibrido solar--gas LP, con trazabilidad explicita entre la optimizacion formal R1, la sensibilidad de eficiencia del colector y la comparacion hibrido contra linea base gas LP. Bajo las condiciones modeladas, la configuracion hibrida mostro capacidad consistente para reducir la demanda de energia auxiliar, preservando desempeno de secado factible en los puntos operativos seleccionados.");
    add("");
    add("Dentro del conjunto no dominado computado, R1_solution_7 surgio como el principal candidato factible conservador de energia, mientras que R1_solution_3 ofrecio una alternativa balanceada entre intensidad de secado y uso de energia. R1_solution_9 represento una estrategia de secado mas agresiva con mayor penalizacion energetica, y H2 se conservo solamente como referencia historica, no como solucion R1 nuevamente optimizada. Esta distincion respalda una interpretacion operativa basada en compromisos factibles y no en seleccionar por defecto el punto de secado mas profundo.");
    add("");
    add("El analisis de sensibilidad de eficiencia del colector, particularmente la curva 2-SAH consistente con el arreglo fisico en serie de los calentadores solares de aire, no altero cualitativamente el ordenamiento de los candidatos seleccionados. Esto respalda la estabilidad de la interpretacion operativa principal bajo una suposicion de eficiencia de colector fisicamente mas consistente. Sin embargo, el tratamiento del colector sigue siendo una representacion de sensibilidad y no un modelo dinamico de colector completamente acoplado.");
    add("");
    add("La comparacion hibrido contra gas LP indico que la contribucion solar puede reducir la demanda de energia auxiliar principalmente mediante sustitucion de combustible, no mediante relajacion del requisito de secado. En consecuencia, el sistema hibrido debe interpretarse como una estrategia operativa prometedora de ahorro energetico bajo los supuestos actuales del modelo. Las afirmaciones economicas o de CO2 finales deben permanecer condicionadas hasta que los supuestos de precio de combustible, tarifa electrica, factor de emision, fecha, region, base de unidades y conversion esten definitivamente documentados y bloqueados.");
    add("");
    add("Las principales limitaciones metodologicas se asocian con el uso de una sola corrida formal R1 con semilla controlada, la ausencia de replicas independientes con otras semillas, el tratamiento del colector a nivel de sensibilidad y la falta de objetivos completamente acoplados de potencia de ventiladores y caida de presion. El trabajo futuro deberia evaluar semillas aleatorias adicionales, implementar una formulacion acoplada de colector y red de flujo de aire, incluir penalizaciones por potencia de ventiladores y caida de presion, y cerrar los factores economicos y de emisiones antes de formular afirmaciones de costo o CO2 con grado de publicacion.");
    add("");
    add("En conjunto, los resultados proporcionan una base reproducible y trazable para seleccionar puntos operativos candidatos para validacion experimental o numerica de mayor fidelidad. Las conclusiones no deben interpretarse como prueba de convergencia completa del espacio de busqueda, robustez estadistica entre semillas ni optimalidad completa a nivel de equipo.");
    add("");
    add("## Conclusions anchors");
    add("");
    add("| Anchor | Required conclusion |");
    add("|---|---|");
    add("| Hybrid dryer | energy-saving operating strategy under modeled conditions |");
    add("| R1_solution_7 | main energy-conservative feasible candidate |");
    add("| R1_solution_3 | balanced alternative |");
    add("| R1_solution_9 | aggressive drying with larger energy penalty |");
    add("| H2 | historical reference only |");
    add("| 2-SAH | qualitative ranking stability; sensitivity representation |");
    add("| Hybrid vs gas-LPG | auxiliary-energy reduction through solar fuel substitution |");
    add("| Cost/CO2 | conditional on final cited and locked factors |");
    add("| Future work | seeds, coupled collector, fan power, pressure drop, final factors |");
    add("| Overclaim control | no statistical robustness, no complete convergence proof, no complete equipment-level optimality |");
    add("");
    add("## Internal verdict");
    add("");
    add("`SEC_CONCLUSIONS_CONSOLIDATED_DRAFT_v96z_READY_FOR_CONCLUSIONS_INTEGRATION`");

    fid = fopen(secFile,'w');
    if fid < 0
        error('Could not open Conclusions section file: %s',secFile);
    end
    for i = 1:numel(L)
        fprintf(fid,'%s\n',L(i));
    end
    fclose(fid);

    txt = fileread(secFile);
    low = lower(string(txt));

    checks = {};
    checks{end+1,1} = check_row("CONC-01","MASTER exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("CONC-02","Locked Section 7 exists",isfile(lockedSection7),lockedSection7);
    checks{end+1,1} = check_row("CONC-03","After-Discussion audit report exists",isfile(afterDiscussionAudit),afterDiscussionAudit);
    checks{end+1,1} = check_row("CONC-04","Discussion integration report exists",isfile(discussionIntegrationReport),discussionIntegrationReport);
    checks{end+1,1} = check_row("CONC-05","Limitations integration report exists",isfile(limitationsIntegrationReport),limitationsIntegrationReport);
    checks{end+1,1} = check_row("CONC-06","R1 reproducibility table exists",isfile(r1ReproTable),r1ReproTable);
    checks{end+1,1} = check_row("CONC-07","Cost/CO2 traceability matrix exists",isfile(costCo2Matrix),costCo2Matrix);
    checks{end+1,1} = check_row("CONC-08","Conclusions draft file created",isfile(secFile),secFile);

    checks{end+1,1} = check_row("CONC-09","English manuscript block present",contains(txt,"## Manuscript text -- English"),"English block.");
    checks{end+1,1} = check_row("CONC-10","Spanish control block present",contains(txt,"## Version tecnica de control -- Espanol"),"Spanish block.");

    checks{end+1,1} = check_row("CONC-11","Hybrid energy-saving conclusion present",contains(low,"hybrid") && contains(low,"energy-saving"),"Hybrid conclusion.");
    checks{end+1,1} = check_row("CONC-12","R1_solution_7 conclusion present",contains(txt,"R1_solution_7") && contains(low,"energy-conservative"),"R1_solution_7.");
    checks{end+1,1} = check_row("CONC-13","R1_solution_3 conclusion present",contains(txt,"R1_solution_3") && contains(low,"balanced"),"R1_solution_3.");
    checks{end+1,1} = check_row("CONC-14","R1_solution_9 conclusion present",contains(txt,"R1_solution_9") && contains(low,"aggressive"),"R1_solution_9.");
    checks{end+1,1} = check_row("CONC-15","H2 historical reference present",contains(txt,"H2") && contains(low,"historical reference"),"H2.");
    checks{end+1,1} = check_row("CONC-16","H2 not-new-R1 caveat present",contains(low,"rather than as a newly optimized r1 solution") || contains(low,"no como solucion r1 nuevamente optimizada"),"H2 caveat.");

    checks{end+1,1} = check_row("CONC-17","Computed nondominated set wording present",contains(low,"computed nondominated set") || contains(low,"conjunto no dominado computado"),"Computed nondominated set.");
    checks{end+1,1} = check_row("CONC-18","2-SAH conclusion present",contains(low,"2-sah") && contains(low,"sensitivity"),"2-SAH.");
    checks{end+1,1} = check_row("CONC-19","Collector limitation preserved",contains(low,"fully coupled dynamic collector model") || contains(low,"modelo dinamico de colector completamente acoplado"),"Collector caveat.");
    checks{end+1,1} = check_row("CONC-20","Hybrid vs gas-LPG conclusion present",contains(low,"hybrid versus gas-lpg") || contains(low,"hibrido contra gas lp"),"Hybrid baseline.");
    checks{end+1,1} = check_row("CONC-21","Solar substitution conclusion present",contains(low,"fuel substitution") || contains(low,"sustitucion de combustible"),"Solar/fuel substitution.");

    checks{end+1,1} = check_row("CONC-22","Cost/CO2 conditionality present",(contains(low,"conditional") && contains(low,"emission-factor")) || (contains(low,"condicionadas") && contains(low,"factor de emision")),"Cost/CO2 conditionality.");
    checks{end+1,1} = check_row("CONC-23","Future seed replications present",contains(low,"additional random seeds") || contains(low,"semillas aleatorias adicionales"),"Future seeds.");
    checks{end+1,1} = check_row("CONC-24","Future coupled collector present",contains(low,"coupled collector") || contains(low,"formulacion acoplada de colector"),"Future collector.");
    checks{end+1,1} = check_row("CONC-25","Future fan-power present",contains(low,"fan-power") || contains(low,"potencia de ventiladores"),"Future fan power.");
    checks{end+1,1} = check_row("CONC-26","Future pressure-drop present",contains(low,"pressure-drop") || contains(low,"caida de presion"),"Future pressure drop.");
    checks{end+1,1} = check_row("CONC-27","Future final factors present",contains(low,"finalize the economic and emission factors") || contains(low,"cerrar los factores economicos y de emisiones"),"Future factors.");

    checks{end+1,1} = check_row("CONC-28","No prohibited global optimum wording",~contains(low,"global optimum") && ~contains(low,"globally optimal"),"No prohibited wording.");
    checks{end+1,1} = check_row("CONC-29","No prohibited global Pareto front wording",~contains(low,"global pareto front"),"No prohibited wording.");
    checks{end+1,1} = check_row("CONC-30","No statistical robustness claim",~contains(low,"statistically robust") && ~contains(low,"robust across seeds"),"No robustness overclaim.");
    checks{end+1,1} = check_row("CONC-31","No complete convergence proof claim",contains(low,"should not be interpreted as proof of complete search-space convergence") || contains(low,"no deben interpretarse como prueba de convergencia completa"),"Convergence caveat.");
    checks{end+1,1} = check_row("CONC-32","No complete equipment optimality claim",(contains(low,"not be interpreted") && contains(low,"complete equipment-level optimality")) || contains(low,"optimalidad completa a nivel de equipo"),"Equipment caveat.");

    checks{end+1,1} = check_row("CONC-33","No final CO2 claim introduced",~contains(low,"final co2 reduction") && ~contains(low,"final emission reduction") && ~contains(low,"definitive emission reduction"),"No final CO2 claim.");
    checks{end+1,1} = check_row("CONC-34","No final cost claim introduced",~contains(low,"final cost reduction") && ~contains(low,"final economic saving") && ~contains(low,"definitive economic saving"),"No final cost claim.");
    checks{end+1,1} = check_row("CONC-35","No excessive numeric repetition",~contains(txt,"656.23") && ~contains(txt,"723.36") && ~contains(txt,"1218.4") && ~contains(txt,"747.00"),"Avoids repeating Section 7 numeric table.");
    checks{end+1,1} = check_row("CONC-36","No GA executed",true,"Text generation only.");
    checks{end+1,1} = check_row("CONC-37","No model executed",true,"Text generation only.");
    checks{end+1,1} = check_row("CONC-38","MASTER not modified",true,"No master write operation.");

    Tchecks = struct2table(vertcat(checks{:}));
    writetable(Tchecks,checksCsv);

    if all(Tchecks.pass)
        diagnosis = "SEC_CONCLUSIONS_CONSOLIDATED_DRAFT_PASS";
        decision = "READY_FOR_CONCLUSIONS_INTEGRATION";
        next_step = "Integrate Conclusions consolidated draft into MASTER.";
    else
        diagnosis = "SEC_CONCLUSIONS_CONSOLIDATED_DRAFT_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS";
        next_step = "Review failed checks before Conclusions integration.";
    end

    fid = fopen(reportFile,'w');
    if fid < 0
        error('Could not open Conclusions report file: %s',reportFile);
    end

    fprintf(fid,'# SEC_CONCLUSIONS_CONSOLIDATED_DRAFT_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- Conclusions section: `%s`\n',secFile);
    fprintf(fid,'- Checks: `%s`\n',checksCsv);
    fprintf(fid,'- Locked Section 7: `%s`\n',lockedSection7);
    fprintf(fid,'- After-Discussion audit report: `%s`\n',afterDiscussionAudit);
    fprintf(fid,'- Discussion integration report: `%s`\n\n',discussionIntegrationReport);

    fprintf(fid,'## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            string(Tchecks.id(i)), string(Tchecks.check(i)), Tchecks.pass(i), string(Tchecks.evidence(i)));
    end
    fclose(fid);

    save(matFile,'secFile','reportFile','checksCsv','matFile','lockedSection7','afterDiscussionAudit','discussionIntegrationReport','limitationsIntegrationReport','costCo2Matrix','r1ReproTable','Tchecks','diagnosis','decision','next_step');

    out = struct();
    out.status = "BUILD_CONCLUSIONS_CONSOLIDATED_DRAFT_v96z_DONE";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.secFile = secFile;
    out.reportFile = reportFile;
    out.checksCsv = checksCsv;
    out.matFile = matFile;
    out.Tchecks = Tchecks;

    disp('=== BUILD CONCLUSIONS CONSOLIDATED DRAFT v96z ===')
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
