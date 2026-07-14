function out = compare_selected_points_hybrid_vs_gasLP_v96z()
% COMPARE_SELECTED_POINTS_HYBRID_vs_GASLP_v96z
%
% 9.6z-sim-lite-a
% SELECTED-POINTS-HYBRID-vs-GASLP-COMPARISON-001
%
% Objetivo:
%   Comparar puntos seleccionados H2, R1_solution_7, R1_solution_3
%   y R1_solution_9 bajo operación hybrid y gasLP.
%
% No ejecuta GA.
% Solo evalúa puntos fijos ya seleccionados.
%
% Wrapper:
%   opt_tunel_mod2_v19_eta_sensitivity
%
% Eta mode:
%   eta_article_2SAH_curve
%
% Salidas:
%   SELECTED_POINTS_HYBRID_vs_GASLP_v96z.csv
%   SELECTED_POINTS_HYBRID_vs_GASLP_v96z_summary.csv
%   SELECTED_POINTS_HYBRID_vs_GASLP_v96z.md
%   SELECTED_POINTS_HYBRID_vs_GASLP_v96z_Tchecks.csv

    rootDir = setup_v05_paths();

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    tablesDir = fullfile(articleRoot,'tables');
    reviewDir = fullfile(articleRoot,'review');
    traceDir = fullfile(articleRoot,'traceability');

    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(reviewDir), mkdir(reviewDir); end
    if ~isfolder(traceDir), mkdir(traceDir); end

    % ---------------------------------------------------------------
    % Confirm wrapper availability
    % ---------------------------------------------------------------
    wrapperName = 'opt_tunel_mod2_v19_eta_sensitivity';

    if isempty(which(wrapperName))
        error('Wrapper not found in MATLAB path: %s', wrapperName);
    end

    % ---------------------------------------------------------------
    % Product/base parameters
    % Same controlled parameters used in previous pointwise evaluations.
    % ---------------------------------------------------------------
    W0 = 200;
    m_i = 0.85;
    Mi = 5.6666666667;
    mwi = W0*m_i;
    md = W0*(1-m_i);
    m_f = 0.1;
    Mf = m_f/(1-m_f);
    mwf = md*Mf;
    M_des = Mf;

    etaMode = "eta_article_2SAH_curve";

    % ---------------------------------------------------------------
    % Selected candidate points
    % ---------------------------------------------------------------
    cases = table( ...
        ["H2_historical"; "R1_solution_7"; "R1_solution_3"; "R1_solution_9"], ...
        [0.07355; 0.070502; 0.075518; 0.092264], ...
        [65.879; 64.429; 65.054; 67.675], ...
        [0.61205; 0.74259; 0.78863; 0.43299], ...
        [12.385; 13.255; 12.874; 13.829], ...
        'VariableNames', {'case_name','m_dot_kg_s','T_min_C','r_rec','t_rec_ini_h'} );

    operationModes = ["hybrid"; "gasLP"];

    out_case = strings(0,1);
    out_mode = strings(0,1);
    out_eta_mode = strings(0,1);

    out_m_dot = [];
    out_T_min = [];
    out_r_rec = [];
    out_t_rec = [];

    out_Q_aux = [];
    out_dry_time = [];
    out_M_prod = [];
    out_MR = [];
    out_Irr = [];

    out_eta_mean_positive = [];
    out_eta_mean_all = [];
    out_eta_min = [];
    out_eta_max = [];

    % ---------------------------------------------------------------
    % Evaluate fixed points
    % ---------------------------------------------------------------
    for c = 1:height(cases)
        for k = 1:numel(operationModes)

            modeOperation = operationModes(k);

            [Q_aux_tot, dry_time, M_prod_fin, MR_fin, Irradiacion, irr_diag] = ...
                opt_tunel_mod2_v19_eta_sensitivity( ...
                cases.m_dot_kg_s(c), cases.T_min_C(c), cases.r_rec(c), cases.t_rec_ini_h(c), ...
                W0, m_i, Mi, mwi, md, m_f, Mf, mwf, M_des, ...
                modeOperation, etaMode);

            etaVals = irr_diag.ETHA_capt_values;

            if isempty(etaVals)
                etaMeanAll = NaN;
                etaMeanPositive = NaN;
                etaMin = NaN;
                etaMax = NaN;
            else
                etaMeanAll = mean(etaVals,'omitnan');
                etaPositive = etaVals(etaVals > 0);
                if isempty(etaPositive)
                    etaMeanPositive = NaN;
                else
                    etaMeanPositive = mean(etaPositive,'omitnan');
                end
                etaMin = min(etaVals);
                etaMax = max(etaVals);
            end

            out_case(end+1,1) = cases.case_name(c);
            out_mode(end+1,1) = modeOperation;
            out_eta_mode(end+1,1) = etaMode;

            out_m_dot(end+1,1) = cases.m_dot_kg_s(c);
            out_T_min(end+1,1) = cases.T_min_C(c);
            out_r_rec(end+1,1) = cases.r_rec(c);
            out_t_rec(end+1,1) = cases.t_rec_ini_h(c);

            out_Q_aux(end+1,1) = Q_aux_tot;
            out_dry_time(end+1,1) = dry_time;
            out_M_prod(end+1,1) = M_prod_fin;
            out_MR(end+1,1) = MR_fin;
            out_Irr(end+1,1) = Irradiacion;

            out_eta_mean_all(end+1,1) = etaMeanAll;
            out_eta_mean_positive(end+1,1) = etaMeanPositive;
            out_eta_min(end+1,1) = etaMin;
            out_eta_max(end+1,1) = etaMax;
        end
    end

    Tfull = table( ...
        out_case, ...
        out_mode, ...
        out_eta_mode, ...
        out_m_dot, ...
        out_T_min, ...
        out_r_rec, ...
        out_t_rec, ...
        out_Q_aux, ...
        out_dry_time, ...
        out_M_prod, ...
        out_MR, ...
        out_Irr, ...
        out_eta_mean_all, ...
        out_eta_mean_positive, ...
        out_eta_min, ...
        out_eta_max, ...
        'VariableNames', { ...
            'case_name', ...
            'operation_mode', ...
            'eta_mode', ...
            'm_dot_kg_s', ...
            'T_min_C', ...
            'r_rec', ...
            't_rec_ini_h', ...
            'Q_aux_kWh', ...
            'dry_time_h', ...
            'M_prod_fin', ...
            'MR_fin', ...
            'Solar_energy_kWh', ...
            'eta_mean_all', ...
            'eta_mean_positive', ...
            'eta_min', ...
            'eta_max'} );

    % ---------------------------------------------------------------
    % Build summary hybrid vs gasLP
    % ---------------------------------------------------------------
    S_case = strings(height(cases),1);
    S_Q_hybrid = NaN(height(cases),1);
    S_Q_gasLP = NaN(height(cases),1);
    S_Q_reduction_kWh = NaN(height(cases),1);
    S_Q_reduction_pct = NaN(height(cases),1);

    S_MR_hybrid = NaN(height(cases),1);
    S_MR_gasLP = NaN(height(cases),1);
    S_MR_delta = NaN(height(cases),1);

    S_Irr_hybrid = NaN(height(cases),1);
    S_Irr_gasLP = NaN(height(cases),1);

    S_feasible_hybrid = false(height(cases),1);
    S_feasible_gasLP = false(height(cases),1);

    S_interpretation = strings(height(cases),1);

    for c = 1:height(cases)
        caseName = string(cases.case_name(c));

        idxH = string(Tfull.case_name)==caseName & string(Tfull.operation_mode)=="hybrid";
        idxG = string(Tfull.case_name)==caseName & string(Tfull.operation_mode)=="gasLP";

        S_case(c) = caseName;

        if any(idxH)
            iH = find(idxH,1,'first');
            S_Q_hybrid(c) = Tfull.Q_aux_kWh(iH);
            S_MR_hybrid(c) = Tfull.MR_fin(iH);
            S_Irr_hybrid(c) = Tfull.Solar_energy_kWh(iH);
            S_feasible_hybrid(c) = Tfull.MR_fin(iH) <= 0.1;
        end

        if any(idxG)
            iG = find(idxG,1,'first');
            S_Q_gasLP(c) = Tfull.Q_aux_kWh(iG);
            S_MR_gasLP(c) = Tfull.MR_fin(iG);
            S_Irr_gasLP(c) = Tfull.Solar_energy_kWh(iG);
            S_feasible_gasLP(c) = Tfull.MR_fin(iG) <= 0.1;
        end

        S_Q_reduction_kWh(c) = S_Q_gasLP(c) - S_Q_hybrid(c);
        S_Q_reduction_pct(c) = 100*(S_Q_gasLP(c) - S_Q_hybrid(c))/S_Q_gasLP(c);

        S_MR_delta(c) = S_MR_hybrid(c) - S_MR_gasLP(c);

        if caseName == "R1_solution_7"
            S_interpretation(c) = "Energy-saving feasible candidate";
        elseif caseName == "R1_solution_3"
            S_interpretation(c) = "Balanced feasible candidate";
        elseif caseName == "H2_historical"
            S_interpretation(c) = "Historical deeper-drying reference";
        elseif caseName == "R1_solution_9"
            S_interpretation(c) = "Aggressive drying boundary case";
        else
            S_interpretation(c) = "Review required";
        end
    end

    Tsummary = table( ...
        S_case, ...
        S_Q_hybrid, ...
        S_Q_gasLP, ...
        S_Q_reduction_kWh, ...
        S_Q_reduction_pct, ...
        S_MR_hybrid, ...
        S_MR_gasLP, ...
        S_MR_delta, ...
        S_Irr_hybrid, ...
        S_Irr_gasLP, ...
        S_feasible_hybrid, ...
        S_feasible_gasLP, ...
        S_interpretation, ...
        'VariableNames', { ...
            'case_name', ...
            'Q_aux_hybrid_kWh', ...
            'Q_aux_gasLP_kWh', ...
            'Q_aux_reduction_kWh', ...
            'Q_aux_reduction_pct', ...
            'MR_hybrid', ...
            'MR_gasLP', ...
            'MR_delta_hybrid_minus_gasLP', ...
            'Solar_energy_hybrid_kWh', ...
            'Solar_energy_gasLP_kWh', ...
            'MR_feasible_hybrid', ...
            'MR_feasible_gasLP', ...
            'interpretation'} );

    % ---------------------------------------------------------------
    % Write tables
    % ---------------------------------------------------------------
    fullCsv = fullfile(tablesDir,'SELECTED_POINTS_HYBRID_vs_GASLP_v96z.csv');
    summaryCsv = fullfile(tablesDir,'SELECTED_POINTS_HYBRID_vs_GASLP_v96z_summary.csv');
    summaryMd = fullfile(tablesDir,'SELECTED_POINTS_HYBRID_vs_GASLP_v96z_summary.md');

    writetable(Tfull,fullCsv);
    writetable(Tsummary,summaryCsv);
    write_summary_md(summaryMd,Tsummary);

    % ---------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------
    checks = {};

    checks{end+1,1} = check_row("HG-01","Wrapper found",~isempty(which(wrapperName)),which(wrapperName));
    checks{end+1,1} = check_row("HG-02","Full table has eight rows",height(Tfull)==8,string(height(Tfull)));
    checks{end+1,1} = check_row("HG-03","Summary table has four rows",height(Tsummary)==4,string(height(Tsummary)));
    checks{end+1,1} = check_row("HG-04","All hybrid rows present",sum(string(Tfull.operation_mode)=="hybrid")==4,"hybrid row count.");
    checks{end+1,1} = check_row("HG-05","All gasLP rows present",sum(string(Tfull.operation_mode)=="gasLP")==4,"gasLP row count.");
    checks{end+1,1} = check_row("HG-06","All hybrid points feasible MR<=0.1",all(Tsummary.MR_feasible_hybrid),"Hybrid feasibility.");
    checks{end+1,1} = check_row("HG-07","All gasLP points feasible MR<=0.1",all(Tsummary.MR_feasible_gasLP),"gasLP feasibility.");
    checks{end+1,1} = check_row("HG-08","Hybrid Q_aux lower than gasLP for all points",all(Tsummary.Q_aux_hybrid_kWh < Tsummary.Q_aux_gasLP_kWh),"Hybrid energy reduction.");
    checks{end+1,1} = check_row("HG-09","R1-7 remains lowest hybrid Q_aux", ...
        get_Q_summary(Tsummary,"R1_solution_7","Q_aux_hybrid_kWh") == min(Tsummary.Q_aux_hybrid_kWh), ...
        "R1-7 hybrid Q_aux minimum.");
    checks{end+1,1} = check_row("HG-10","Output full CSV created",isfile(fullCsv),fullCsv);
    checks{end+1,1} = check_row("HG-11","Output summary CSV created",isfile(summaryCsv),summaryCsv);
    checks{end+1,1} = check_row("HG-12","Output summary MD created",isfile(summaryMd),summaryMd);
    checks{end+1,1} = check_row("HG-13","No GA executed",true,"Fixed-point comparison only.");
    checks{end+1,1} = check_row("HG-14","No optimization executed",true,"Fixed-point comparison only.");

    Tchecks = struct2table(vertcat(checks{:}));

    checksCsv = fullfile(reviewDir,'SELECTED_POINTS_HYBRID_vs_GASLP_v96z_Tchecks.csv');
    writetable(Tchecks,checksCsv);

    if all(Tchecks.pass)
        diagnosis = "SELECTED_POINTS_HYBRID_vs_GASLP_PASS";
        decision = "USE_AS_BASELINE_COMPARISON_FOR_MANUSCRIPT";
        next_step = "Draft baseline comparison paragraph or integrate table into Results/Supplementary Material.";
    else
        diagnosis = "SELECTED_POINTS_HYBRID_vs_GASLP_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS";
        next_step = "Review failed checks before manuscript use.";
    end

    % ---------------------------------------------------------------
    % Report
    % ---------------------------------------------------------------
    reportMd = fullfile(reviewDir,'SELECTED_POINTS_HYBRID_vs_GASLP_v96z_report.md');

    fid = fopen(reportMd,'w');
    if fid < 0
        error('Could not open report for writing: %s', reportMd);
    end

    fprintf(fid,'# SELECTED_POINTS_HYBRID_vs_GASLP_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);

    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- Full CSV: `%s`\n',fullCsv);
    fprintf(fid,'- Summary CSV: `%s`\n',summaryCsv);
    fprintf(fid,'- Summary MD: `%s`\n',summaryMd);
    fprintf(fid,'- Checks CSV: `%s`\n',checksCsv);

    fprintf(fid,'\n## Summary table\n\n');
    fprintf(fid,'| case | Q hybrid kWh | Q gasLP kWh | reduction kWh | reduction %% | MR hybrid | MR gasLP | interpretation |\n');
    fprintf(fid,'|---|---:|---:|---:|---:|---:|---:|---|\n');

    for i = 1:height(Tsummary)
        fprintf(fid,'| `%s` | %.6g | %.6g | %.6g | %.6g | %.6g | %.6g | %s |\n', ...
            string(Tsummary.case_name(i)), ...
            Tsummary.Q_aux_hybrid_kWh(i), ...
            Tsummary.Q_aux_gasLP_kWh(i), ...
            Tsummary.Q_aux_reduction_kWh(i), ...
            Tsummary.Q_aux_reduction_pct(i), ...
            Tsummary.MR_hybrid(i), ...
            Tsummary.MR_gasLP(i), ...
            string(Tsummary.interpretation(i)));
    end

    fprintf(fid,'\n## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');

    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            string(Tchecks.id(i)), string(Tchecks.check(i)), Tchecks.pass(i), string(Tchecks.evidence(i)));
    end

    fclose(fid);

    outMat = fullfile(traceDir,'SELECTED_POINTS_HYBRID_vs_GASLP_v96z.mat');

    save(outMat, ...
        'Tfull','Tsummary','Tchecks','diagnosis','decision','next_step', ...
        'fullCsv','summaryCsv','summaryMd','checksCsv','reportMd','outMat');

    out = struct();
    out.status = "SELECTED_POINTS_HYBRID_vs_GASLP_v96z_DONE";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.Tfull = Tfull;
    out.Tsummary = Tsummary;
    out.Tchecks = Tchecks;
    out.fullCsv = fullCsv;
    out.summaryCsv = summaryCsv;
    out.summaryMd = summaryMd;
    out.checksCsv = checksCsv;
    out.reportMd = reportMd;
    out.outMat = outMat;

    disp('=== SELECTED POINTS HYBRID vs GASLP v96z ===')
    disp(out.status)
    disp('=== DIAGNOSIS ===')
    disp(out.diagnosis)
    disp('=== DECISION ===')
    disp(out.decision)
    disp('=== NEXT STEP ===')
    disp(out.next_step)
    disp('=== SUMMARY TABLE ===')
    disp(out.Tsummary)
    disp('=== FAILED CHECKS ===')
    disp(out.Tchecks(~out.Tchecks.pass,:))
    disp('=== ALL CHECKS ===')
    disp(out.Tchecks)
    disp('=== FILES ===')
    disp(out.summaryMd)
    disp(out.reportMd)
end

function val = get_Q_summary(T,caseName,varName)
    idx = string(T.case_name)==string(caseName);
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

function write_summary_md(filename,T)
    fid = fopen(filename,'w');
    if fid < 0
        error('Could not open summary MD for writing: %s', filename);
    end

    fprintf(fid,'# Selected points — Hybrid vs gas-LPG comparison\n\n');
    fprintf(fid,'Micropaso: `9.6z-sim-lite-a`\n\n');
    fprintf(fid,'Identifier: `SELECTED-POINTS-HYBRID-vs-GASLP-COMPARISON-001`\n\n');
    fprintf(fid,'Wrapper: `opt_tunel_mod2_v19_eta_sensitivity`\n\n');
    fprintf(fid,'Eta mode: `eta_article_2SAH_curve`\n\n');
    fprintf(fid,'No GA was executed. No optimization was executed. Only fixed selected points were evaluated.\n\n');

    fprintf(fid,'| Case | Q_aux hybrid (kWh) | Q_aux gas-LPG (kWh) | Reduction (kWh) | Reduction (%) | MR hybrid | MR gas-LPG | Interpretation |\n');
    fprintf(fid,'|---|---:|---:|---:|---:|---:|---:|---|\n');

    for i = 1:height(T)
        fprintf(fid,'| `%s` | %.2f | %.2f | %.2f | %.2f | %.5f | %.5f | %s |\n', ...
            string(T.case_name(i)), ...
            T.Q_aux_hybrid_kWh(i), ...
            T.Q_aux_gasLP_kWh(i), ...
            T.Q_aux_reduction_kWh(i), ...
            T.Q_aux_reduction_pct(i), ...
            T.MR_hybrid(i), ...
            T.MR_gasLP(i), ...
            string(T.interpretation(i)));
    end

    fprintf(fid,'\n## Interpretation note\n\n');
    fprintf(fid,['This table compares the selected operating points under hybrid operation and gas-LPG-only operation. ' ...
        'The comparison is pointwise and does not imply a new optimization run. ' ...
        'The result should be used as a baseline energy comparison for the selected candidates.\n']);

    fclose(fid);
end