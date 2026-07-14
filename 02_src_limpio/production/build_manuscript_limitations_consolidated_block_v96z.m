function out = build_manuscript_limitations_consolidated_block_v96z()
% BUILD_MANUSCRIPT_LIMITATIONS_CONSOLIDATED_BLOCK_v96z
%
% 9.6z-limitations-a
% BUILD-MANUSCRIPT-LIMITATIONS-CONSOLIDATED-BLOCK-001
%
% Objetivo:
%   Construir y auditar un bloque consolidado de Limitations para el
%   manuscrito, con base en los controles ya cerrados:
%   - Results Section 7 v01.1 locked
%   - Methods GA reproducibility integrated
%   - Cost/CO2 traceability caveat integrated
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

    methodsGaIntegrationReport = fullfile(reviewDir,'INTEGRATE_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_INTO_MASTER_v96z_report.md');
    costCo2IntegrationReport = fullfile(reviewDir,'INTEGRATE_COST_CO2_TRACEABILITY_CAVEAT_INTO_MASTER_v96z_report.md');
    traceMatrixMd = fullfile(tablesDir,'FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z.md');
    r1ReproTableMd = fullfile(tablesDir,'R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z.md');

    secFile = fullfile(draftDir,'SEC_LIMITATIONS_CONSOLIDATED_BLOCK_v96z.md');
    reportFile = fullfile(reviewDir,'SEC_LIMITATIONS_CONSOLIDATED_BLOCK_v96z_report.md');
    checksCsv = fullfile(reviewDir,'SEC_LIMITATIONS_CONSOLIDATED_BLOCK_v96z_Tchecks.csv');
    matFile = fullfile(traceDir,'SEC_LIMITATIONS_CONSOLIDATED_BLOCK_v96z.mat');

    L = strings(0,1);

    add("# SEC_LIMITATIONS_CONSOLIDATED_BLOCK_v96z");
    add("");
    add("## Status");
    add("");
    add("`DRAFT_READY_FOR_REVIEW`");
    add("");
    add("## Micropaso");
    add("");
    add("`9.6z-limitations-a`");
    add("");
    add("## Identifier");
    add("");
    add("`BUILD-MANUSCRIPT-LIMITATIONS-CONSOLIDATED-BLOCK-001`");
    add("");
    add("## Intended master location");
    add("");
    add("Limitations section, or final paragraph of Discussion if the journal format does not include a separate Limitations section.");
    add("");
    add("## Source controls");
    add("");
    add("- `RESULTS_SECTION_07_v01_1_LOCKED.md`");
    add("- `R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z.md`");
    add("- `INTEGRATE_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_INTO_MASTER_v96z_report.md`");
    add("- `FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z.md`");
    add("- `INTEGRATE_COST_CO2_TRACEABILITY_CAVEAT_INTO_MASTER_v96z_report.md`");
    add("");
    add("## Manuscript text -- English");
    add("");
    add("### Limitations");
    add("");
    add("Several limitations must be considered when interpreting the optimization and baseline-comparison results. First, the formal multiobjective analysis was based on a single controlled seed-aware R1 execution of MATLAB's `gamultiobj` algorithm. Although this run produced a computed nondominated set under the specified configuration, it does not establish statistical robustness across independent random seeds, nor does it constitute proof of complete convergence of the search space. Additional independent seed replications would be required to quantify the sensitivity of the selected candidates to stochastic initialization and evolutionary-search variability.");
    add("");
    add("Second, the collector-efficiency analysis was implemented as a sensitivity assessment rather than as a fully coupled dynamic collector model. The 2-SAH efficiency curve was used because it is consistent with the physical arrangement of two solar air heaters in series per battery; however, this treatment does not replace a fully coupled collector, airflow, pressure-drop, and thermal-network simulation. Consequently, the observed stability of the selected operating-point ranking across collector-efficiency assumptions should be interpreted as sensitivity evidence, not as complete equipment-level validation.");
    add("");
    add("Third, fan-power consumption and pressure-drop effects were not fully coupled as optimization objectives. The current optimization therefore focuses on process-level drying performance, auxiliary energy demand, cost, and CO2 indicators as represented in the implemented model, but it should not be interpreted as a complete equipment-level optimum. A future coupled formulation should include fan power, pressure drop, and airflow-distribution effects to refine the techno-economic and environmental assessment.");
    add("");
    add("Fourth, economic and CO2 indicators depend on external factors such as fuel price, electricity tariff, emission factor, source year, region, unit basis, and conversion assumptions. The provisional CO2 factors `EF_LPG_kgCO2_per_kWh = 0.2270` and `EF_grid_kgCO2_per_kWh = 0.4380` were retained only for code validation and internal traceability under the tag `PROVISIONAL_FOR_CODE_VALIDATION`. Final cost or CO2 claims require definitive cited sources and locked conversion bases before submission. Until those factors are finalized, the most robust interpretation is based on energy-demand trends and relative comparisons.");
    add("");
    add("Finally, solar-only operation was excluded from the formal multiobjective comparison because it represents a non-equivalent operating mode relative to the hybrid and gas-LPG baseline cases. Likewise, the H2 point was retained as a historical reference and not treated as a newly optimized R1 solution. These distinctions were maintained to avoid mixing non-equivalent operating modes or historical references with the formal R1 candidate set.");
    add("");
    add("## Version tecnica de control -- Espanol");
    add("");
    add("### Limitaciones");
    add("");
    add("Deben considerarse varias limitaciones al interpretar los resultados de optimizacion y comparacion de lineas base. Primero, el analisis multiobjetivo formal se baso en una sola ejecucion R1 controlada con semilla fija del algoritmo `gamultiobj` de MATLAB. Aunque esta corrida produjo un conjunto no dominado computado bajo la configuracion especificada, no establece robustez estadistica entre semillas aleatorias independientes ni constituye prueba de convergencia completa del espacio de busqueda. Serian necesarias replicas independientes con semillas adicionales para cuantificar la sensibilidad de los candidatos seleccionados a la inicializacion estocastica y a la variabilidad del algoritmo evolutivo.");
    add("");
    add("Segundo, el analisis de eficiencia del colector se implemento como una evaluacion de sensibilidad y no como un modelo dinamico de colector completamente acoplado. La curva 2-SAH se uso porque es consistente con la configuracion fisica de dos calentadores solares de aire en serie por bateria; sin embargo, este tratamiento no sustituye una simulacion completamente acoplada de colector, flujo de aire, caida de presion y red termica. Por tanto, la estabilidad observada del ordenamiento de puntos operativos ante diferentes supuestos de eficiencia del colector debe interpretarse como evidencia de sensibilidad, no como validacion completa a nivel de equipo.");
    add("");
    add("Tercero, el consumo electrico de ventiladores y los efectos de caida de presion no se acoplaron completamente como objetivos de optimizacion. La optimizacion actual se enfoca en el desempeno de secado a nivel de proceso, demanda de energia auxiliar, costo e indicadores de CO2 segun el modelo implementado, pero no debe interpretarse como una optimalidad completa a nivel de equipo. Una formulacion futura acoplada deberia incluir potencia de ventiladores, caida de presion y efectos de distribucion de flujo para refinar la evaluacion tecnoeconomica y ambiental.");
    add("");
    add("Cuarto, los indicadores economicos y de CO2 dependen de factores externos como precio de combustible, tarifa electrica, factor de emision, ano de la fuente, region, base de unidades y supuestos de conversion. Los factores provisionales de CO2 `EF_LPG_kgCO2_per_kWh = 0.2270` y `EF_grid_kgCO2_per_kWh = 0.4380` se conservaron solamente para validacion de codigo y trazabilidad interna bajo la etiqueta `PROVISIONAL_FOR_CODE_VALIDATION`. Las afirmaciones finales de costo o CO2 requieren fuentes definitivas citadas y bases de conversion bloqueadas antes del envio. Hasta cerrar esos factores, la interpretacion mas robusta debe basarse en tendencias de demanda energetica y comparaciones relativas.");
    add("");
    add("Finalmente, la operacion solo solar se excluyo de la comparacion multiobjetivo formal porque representa un modo operativo no equivalente respecto a los casos hibrido y gas LP. Asimismo, el punto H2 se conservo como referencia historica y no se trato como una solucion R1 recientemente optimizada. Estas distinciones se mantuvieron para evitar mezclar modos operativos no equivalentes o referencias historicas con el conjunto formal de candidatos R1.");
    add("");
    add("## Limitation anchors");
    add("");
    add("| Limitation | Required wording/control |");
    add("|---|---|");
    add("| Single R1 formal run | no statistical robustness claim |");
    add("| Search-space convergence | no complete/global convergence proof |");
    add("| Collector model | 2-SAH sensitivity, not fully coupled dynamic collector model |");
    add("| Equipment effects | fan power and pressure drop not fully coupled as objectives |");
    add("| Economic/CO2 factors | provisional factors require final cited sources before final claims |");
    add("| Solar-only mode | excluded from formal GA comparison as non-equivalent mode |");
    add("| H2 | historical reference, not newly optimized R1 solution |");
    add("");
    add("## Internal verdict");
    add("");
    add("`SEC_LIMITATIONS_CONSOLIDATED_BLOCK_v96z_READY_FOR_LIMITATIONS_INTEGRATION`");

    fid = fopen(secFile,'w');
    if fid < 0
        error('Could not open limitations section file: %s',secFile);
    end
    for i = 1:numel(L)
        fprintf(fid,'%s\n',L(i));
    end
    fclose(fid);

    txt = fileread(secFile);
    low = lower(string(txt));

    checks = {};
    checks{end+1,1} = check_row("LIM-01","MASTER exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("LIM-02","Locked Section 7 exists",isfile(lockedSection7),lockedSection7);
    checks{end+1,1} = check_row("LIM-03","Methods GA integration report exists",isfile(methodsGaIntegrationReport),methodsGaIntegrationReport);
    checks{end+1,1} = check_row("LIM-04","Cost/CO2 integration report exists",isfile(costCo2IntegrationReport),costCo2IntegrationReport);
    checks{end+1,1} = check_row("LIM-05","Cost/CO2 traceability matrix exists",isfile(traceMatrixMd),traceMatrixMd);
    checks{end+1,1} = check_row("LIM-06","R1 reproducibility table exists",isfile(r1ReproTableMd),r1ReproTableMd);
    checks{end+1,1} = check_row("LIM-07","Limitations section file created",isfile(secFile),secFile);

    checks{end+1,1} = check_row("LIM-08","English manuscript block present",contains(txt,"## Manuscript text -- English"),"English block.");
    checks{end+1,1} = check_row("LIM-09","Spanish control block present",contains(txt,"## Version tecnica de control -- Espanol"),"Spanish block.");

    checks{end+1,1} = check_row("LIM-10","Single R1 limitation present",contains(low,"single controlled seed-aware r1") || contains(low,"sola ejecucion r1"),"Single-run limitation.");
    checks{end+1,1} = check_row("LIM-11","No statistical robustness caveat present",contains(low,"does not establish statistical robustness") || contains(low,"no establece robustez estadistica"),"Statistical robustness caveat.");
    checks{end+1,1} = check_row("LIM-12","Computed nondominated set wording present",contains(low,"computed nondominated set"),"Computed nondominated set.");
    checks{end+1,1} = check_row("LIM-13","No prohibited global optimum phrase",~contains(low,"global optimum") && ~contains(low,"globally optimal"),"Avoids prohibited global optimum wording.");
    checks{end+1,1} = check_row("LIM-14","No prohibited global Pareto front phrase",~contains(low,"global pareto front"),"Avoids prohibited global Pareto wording.");

    checks{end+1,1} = check_row("LIM-15","2-SAH sensitivity limitation present",contains(low,"2-sah") && contains(low,"sensitivity"),"2-SAH sensitivity.");
    checks{end+1,1} = check_row("LIM-16","Fully coupled collector caveat present",contains(low,"fully coupled dynamic collector model") || contains(low,"modelo dinamico de colector completamente acoplado"),"Collector caveat.");
    checks{end+1,1} = check_row("LIM-17","Fan-power limitation present",contains(low,"fan-power") || contains(low,"ventiladores"),"Fan power.");
    checks{end+1,1} = check_row("LIM-18","Pressure-drop limitation present",contains(low,"pressure-drop") || contains(low,"caida de presion"),"Pressure drop.");

    checks{end+1,1} = check_row("LIM-19","CO2 provisional factors present",contains(txt,"EF_LPG_kgCO2_per_kWh = 0.2270") && contains(txt,"EF_grid_kgCO2_per_kWh = 0.4380"),"CO2 factors.");
    checks{end+1,1} = check_row("LIM-20","Provisional tag present",contains(txt,"PROVISIONAL_FOR_CODE_VALIDATION"),"Provisional tag.");
    checks{end+1,1} = check_row("LIM-21","Final source requirement present",contains(low,"definitive cited sources") || contains(low,"fuentes definitivas citadas"),"Final source requirement.");
    checks{end+1,1} = check_row("LIM-22","Energy-demand relative interpretation present",contains(low,"energy-demand trends") || contains(low,"tendencias de demanda energetica"),"Energy-demand interpretation.");

    checks{end+1,1} = check_row("LIM-23","Solar-only exclusion present",contains(low,"solar-only operation was excluded") || contains(low,"operacion solo solar se excluyo"),"Solar-only exclusion.");
    checks{end+1,1} = check_row("LIM-24","H2 historical reference present",contains(txt,"H2") && contains(low,"historical reference"),"H2 historical reference.");
    checks{end+1,1} = check_row("LIM-25","No GA executed",true,"Text generation only.");
    checks{end+1,1} = check_row("LIM-26","No model executed",true,"Text generation only.");
    checks{end+1,1} = check_row("LIM-27","MASTER not modified",true,"No master write operation.");

    Tchecks = struct2table(vertcat(checks{:}));
    writetable(Tchecks,checksCsv);

    if all(Tchecks.pass)
        diagnosis = "SEC_LIMITATIONS_CONSOLIDATED_BLOCK_PASS";
        decision = "READY_FOR_LIMITATIONS_INTEGRATION";
        next_step = "Integrate consolidated Limitations block into MASTER.";
    else
        diagnosis = "SEC_LIMITATIONS_CONSOLIDATED_BLOCK_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS";
        next_step = "Review failed checks before integration.";
    end

    fid = fopen(reportFile,'w');
    if fid < 0
        error('Could not open limitations report file: %s',reportFile);
    end

    fprintf(fid,'# SEC_LIMITATIONS_CONSOLIDATED_BLOCK_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- Limitations section: `%s`\n',secFile);
    fprintf(fid,'- Checks: `%s`\n',checksCsv);
    fprintf(fid,'- Locked Section 7: `%s`\n',lockedSection7);
    fprintf(fid,'- Methods GA integration report: `%s`\n',methodsGaIntegrationReport);
    fprintf(fid,'- Cost/CO2 integration report: `%s`\n\n',costCo2IntegrationReport);

    fprintf(fid,'## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            string(Tchecks.id(i)), string(Tchecks.check(i)), Tchecks.pass(i), string(Tchecks.evidence(i)));
    end
    fclose(fid);

    save(matFile,'secFile','reportFile','checksCsv','matFile','lockedSection7','methodsGaIntegrationReport','costCo2IntegrationReport','traceMatrixMd','r1ReproTableMd','Tchecks','diagnosis','decision','next_step');

    out = struct();
    out.status = "BUILD_MANUSCRIPT_LIMITATIONS_CONSOLIDATED_BLOCK_v96z_DONE";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.secFile = secFile;
    out.reportFile = reportFile;
    out.checksCsv = checksCsv;
    out.matFile = matFile;
    out.Tchecks = Tchecks;

    disp('=== BUILD MANUSCRIPT LIMITATIONS CONSOLIDATED BLOCK v96z ===')
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
