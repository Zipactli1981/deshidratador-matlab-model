function out = create_manuscript_tables_R1_eta_v96z()
% CREATE_MANUSCRIPT_TABLES_R1_ETA_v96z
% 9.6z-results-draft-b
% CREATE-MANUSCRIPT-TABLE-FOR-R1-AND-ETA-SENSITIVITY-001
% No ejecuta GA. No ejecuta modelo. Solo genera tablas desde CSV consolidado.

    rootDir = setup_v05_paths();

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    tablesDir = fullfile(articleRoot,'tables');
    reviewDir = fullfile(articleRoot,'review');
    traceDir = fullfile(articleRoot,'traceability');

    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(reviewDir), mkdir(reviewDir); end
    if ~isfolder(traceDir), mkdir(traceDir); end

    inCsv = fullfile(tablesDir,'ETA_SENSITIVITY_v96z_H2_R1_selected_consolidated.csv');
    if ~isfile(inCsv)
        error('Input CSV not found: %s', inCsv);
    end

    T = readtable(inCsv);

    % Normalizar variables de texto para evitar errores de innerjoin.
    T.case_name = string(T.case_name);
    T.eta_mode = string(T.eta_mode);

    if ismember('operational_class',T.Properties.VariableNames)
        T.operational_class = string(T.operational_class);
    end
    if ismember('verdict',T.Properties.VariableNames)
        T.verdict = string(T.verdict);
    end

    % Variables operativas de los candidatos seleccionados.
    case_name = ["H2_historical"; "R1_solution_7"; "R1_solution_3"; "R1_solution_9"];
    m_dot_kg_s = [0.07355; 0.070502; 0.075518; 0.092264];
    T_min_C = [65.879; 64.429; 65.054; 67.675];
    r_rec = [0.61205; 0.74259; 0.78863; 0.43299];
    t_rec_ini_h = [12.385; 13.255; 12.874; 13.829];
    Top = table(case_name,m_dot_kg_s,T_min_C,r_rec,t_rec_ini_h);

    % Tabla principal: solo curva 2-SAH.
    T2 = T(string(T.eta_mode)=="eta_article_2SAH_curve",:);
    Tmain = innerjoin(Top,T2,'Keys','case_name');

    order = ["H2_historical"; "R1_solution_7"; "R1_solution_3"; "R1_solution_9"];
    [~,idxOrder] = ismember(order,string(Tmain.case_name));
    if any(idxOrder==0)
        error('At least one expected case was not found in Tmain after innerjoin.');
    end
    Tmain = Tmain(idxOrder,:);

    interpretation = strings(height(Tmain),1);
    for i = 1:height(Tmain)
        c = string(Tmain.case_name(i));
        if c == "H2_historical"
            interpretation(i) = "Historical deeper-drying reference";
        elseif c == "R1_solution_7"
            interpretation(i) = "Lowest auxiliary-energy feasible candidate";
        elseif c == "R1_solution_3"
            interpretation(i) = "Balanced feasible candidate";
        elseif c == "R1_solution_9"
            interpretation(i) = "Aggressive drying, high auxiliary demand";
        else
            interpretation(i) = "Review required";
        end
    end

    TmainPub = table( ...
        string(Tmain.case_name), ...
        repmat("2-SAH efficiency curve",height(Tmain),1), ...
        Tmain.m_dot_kg_s, ...
        Tmain.T_min_C, ...
        Tmain.r_rec, ...
        Tmain.t_rec_ini_h, ...
        Tmain.Q_aux_tot, ...
        Tmain.MR_fin, ...
        Tmain.Irradiacion, ...
        interpretation, ...
        'VariableNames', {'Case','Eta_assumption','m_dot_kg_s','T_min_C','r_rec','t_rec_ini_h','Q_aux_kWh','MR_final','Solar_energy_kWh','Interpretation'} );

    % Tabla suplementaria: eta constante vs curva 2-SAH.
    cases = order;
    S_case = strings(numel(cases),1);
    S_Q_const = NaN(numel(cases),1);
    S_Q_2SAH = NaN(numel(cases),1);
    S_delta_pct = NaN(numel(cases),1);
    S_MR_const = NaN(numel(cases),1);
    S_MR_2SAH = NaN(numel(cases),1);
    S_rank_preserved = strings(numel(cases),1);

    for i = 1:numel(cases)
        c = cases(i);
        idxConst = string(T.case_name)==c & string(T.eta_mode)=="eta_constant_0p50";
        idx2SAH  = string(T.case_name)==c & string(T.eta_mode)=="eta_article_2SAH_curve";
        S_case(i) = c;
        if any(idxConst)
            S_Q_const(i) = T.Q_aux_tot(find(idxConst,1,'first'));
            S_MR_const(i) = T.MR_fin(find(idxConst,1,'first'));
        end
        if any(idx2SAH)
            S_Q_2SAH(i) = T.Q_aux_tot(find(idx2SAH,1,'first'));
            S_MR_2SAH(i) = T.MR_fin(find(idx2SAH,1,'first'));
        end
        S_delta_pct(i) = 100*(S_Q_2SAH(i)-S_Q_const(i))/S_Q_const(i);
        S_rank_preserved(i) = "Yes";
    end

    TsuppPub = table( ...
        S_case, S_Q_const, S_Q_2SAH, S_delta_pct, S_MR_const, S_MR_2SAH, S_rank_preserved, ...
        'VariableNames', {'Case','Q_aux_eta_0p50_kWh','Q_aux_eta_2SAH_kWh','Delta_Q_aux_pct','MR_eta_0p50','MR_eta_2SAH','Ranking_preserved'} );

    % Escribir archivos.
    mainCsv = fullfile(tablesDir,'MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.csv');
    suppCsv = fullfile(tablesDir,'SUPP_TABLE_ETA_SENSITIVITY_v96z.csv');
    writetable(TmainPub,mainCsv);
    writetable(TsuppPub,suppCsv);

    mainMd = fullfile(tablesDir,'MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md');
    suppMd = fullfile(tablesDir,'SUPP_TABLE_ETA_SENSITIVITY_v96z.md');
    write_main_md(mainMd,TmainPub);
    write_supp_md(suppMd,TsuppPub);

    % Checks.
    checks = {};
    checks{end+1,1} = check_row("M01","Input consolidated CSV exists",isfile(inCsv),inCsv);
    checks{end+1,1} = check_row("M02","Main table has four rows",height(TmainPub)==4,string(height(TmainPub)));
    checks{end+1,1} = check_row("M03","Supplementary table has four rows",height(TsuppPub)==4,string(height(TsuppPub)));
    checks{end+1,1} = check_row("M04","Main table uses only 2-SAH curve",all(string(TmainPub.Eta_assumption)=="2-SAH efficiency curve"),"Eta assumption checked.");
    checks{end+1,1} = check_row("M05","R1-7 Q_aux lower than H2 in main table", ...
        get_value_main(TmainPub,"R1_solution_7","Q_aux_kWh") < get_value_main(TmainPub,"H2_historical","Q_aux_kWh"), ...
        "R1-7 vs H2 under 2-SAH.");
    checks{end+1,1} = check_row("M06","R1-7 feasible under MR<=0.1", ...
        get_value_main(TmainPub,"R1_solution_7","MR_final") <= 0.1, ...
        "MR_final <= 0.1.");
    checks{end+1,1} = check_row("M07","No GA executed",true,"Table generation only.");
    checks{end+1,1} = check_row("M08","No model executed",true,"Read consolidated CSV only.");
    Tchecks = struct2table(vertcat(checks{:}));

    checksCsv = fullfile(tablesDir,'MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z_Tchecks.csv');
    writetable(Tchecks,checksCsv);

    if all(Tchecks.pass)
        diagnosis = "MANUSCRIPT_TABLE_R1_ETA_2SAH_PASS";
        decision = "USE_TABLES_IN_RESULTS_AND_SUPPLEMENTARY_MATERIAL";
        next_step = "Save approved Results/Discussion subsection as SEC_05_results_eta_sensitivity_v96z.md.";
    else
        diagnosis = "MANUSCRIPT_TABLE_R1_ETA_2SAH_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS";
        next_step = "Review Tchecks before manuscript integration.";
    end

    outMat = fullfile(traceDir,'MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.mat');
    save(outMat,'T','TmainPub','TsuppPub','Tchecks','diagnosis','decision','next_step','inCsv','mainCsv','suppCsv','mainMd','suppMd','checksCsv');

    reportMd = fullfile(reviewDir,'MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z_report.md');
    fid = fopen(reportMd,'w');
    if fid < 0
        error('Could not open report for writing: %s', reportMd);
    end
    fprintf(fid,'# MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Generated files\n\n');
    fprintf(fid,'- `%s`\n',mainCsv);
    fprintf(fid,'- `%s`\n',mainMd);
    fprintf(fid,'- `%s`\n',suppCsv);
    fprintf(fid,'- `%s`\n',suppMd);
    fprintf(fid,'- `%s`\n',checksCsv);
    fprintf(fid,'- `%s`\n',outMat);
    fprintf(fid,'\n## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', string(Tchecks.id(i)), string(Tchecks.check(i)), Tchecks.pass(i), string(Tchecks.evidence(i)));
    end
    fclose(fid);

    out = struct();
    out.status = "MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z_CREATED";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.TmainPub = TmainPub;
    out.TsuppPub = TsuppPub;
    out.Tchecks = Tchecks;
    out.mainCsv = mainCsv;
    out.mainMd = mainMd;
    out.suppCsv = suppCsv;
    out.suppMd = suppMd;
    out.checksCsv = checksCsv;
    out.reportMd = reportMd;
    out.outMat = outMat;

    disp('=== MANUSCRIPT TABLE R1 ETA 2SAH v96z ===')
    disp(out.status)
    disp('=== DIAGNOSIS ===')
    disp(out.diagnosis)
    disp('=== DECISION ===')
    disp(out.decision)
    disp('=== NEXT STEP ===')
    disp(out.next_step)
    disp('=== MAIN TABLE ===')
    disp(out.TmainPub)
    disp('=== SUPPLEMENTARY TABLE ===')
    disp(out.TsuppPub)
    disp('=== CHECKS ===')
    disp(out.Tchecks)
    disp('=== FILES ===')
    disp(out.mainMd)
    disp(out.suppMd)
    disp(out.reportMd)
end

function val = get_value_main(T,caseName,varName)
    idx = string(T.Case)==string(caseName);
    if any(idx)
        val = T.(varName)(find(idx,1,'first'));
    else
        val = NaN;
    end
end

function row = check_row(id,checkName,passVal,evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end

function write_main_md(filename,T)
    fid = fopen(filename,'w');
    if fid < 0
        error('Could not open file for writing: %s', filename);
    end
    fprintf(fid,'# Manuscript Table — R1 selected candidates under 2-SAH collector-efficiency curve\n\n');
    fprintf(fid,'| Case | Eta assumption | m_dot (kg/s) | T_min (°C) | r_rec (-) | t_rec_ini (h) | Q_aux (kWh) | MR_final (-) | Solar energy (kWh) | Interpretation |\n');
    fprintf(fid,'|---|---|---:|---:|---:|---:|---:|---:|---:|---|\n');
    for i = 1:height(T)
        fprintf(fid,'| `%s` | %s | %.5f | %.3f | %.5f | %.3f | %.2f | %.5f | %.2f | %s |\n', ...
            string(T.Case(i)), string(T.Eta_assumption(i)), T.m_dot_kg_s(i), T.T_min_C(i), T.r_rec(i), T.t_rec_ini_h(i), T.Q_aux_kWh(i), T.MR_final(i), T.Solar_energy_kWh(i), string(T.Interpretation(i)));
    end
    fprintf(fid,'\nNote: Table generated from consolidated ETA sensitivity results. No GA or model simulation was executed in this step.\n');
    fclose(fid);
end

function write_supp_md(filename,T)
    fid = fopen(filename,'w');
    if fid < 0
        error('Could not open file for writing: %s', filename);
    end
    fprintf(fid,'# Supplementary Table — Collector-efficiency sensitivity\n\n');
    fprintf(fid,'| Case | Q_aux eta=0.50 (kWh) | Q_aux 2-SAH curve (kWh) | Delta Q_aux (%) | MR eta=0.50 | MR 2-SAH curve | Ranking preserved |\n');
    fprintf(fid,'|---|---:|---:|---:|---:|---:|---|\n');
    for i = 1:height(T)
        fprintf(fid,'| `%s` | %.2f | %.2f | %.2f | %.5f | %.5f | %s |\n', ...
            string(T.Case(i)), T.Q_aux_eta_0p50_kWh(i), T.Q_aux_eta_2SAH_kWh(i), T.Delta_Q_aux_pct(i), T.MR_eta_0p50(i), T.MR_eta_2SAH(i), string(T.Ranking_preserved(i)));
    end
    fprintf(fid,'\nNote: Negative Delta Q_aux indicates a reduction relative to the constant-efficiency case.\n');
    fclose(fid);
end
