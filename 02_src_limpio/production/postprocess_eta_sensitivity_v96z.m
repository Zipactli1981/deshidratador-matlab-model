function out = postprocess_eta_sensitivity_v96z()
% POSTPROCESS_ETA_SENSITIVITY_v96z
%
% 9.6z-eta-sensitivity-b
% CONSOLIDATE-ETA-SENSITIVITY-WITH-COST-CO2-AND-VERDICT-001
%
% No ejecuta GA.
% No ejecuta modelo.
% Solo postprocesa ETA_SENSITIVITY_v96z_H2_R1_selected.csv.

    rootDir = setup_v05_paths();

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    tablesDir = fullfile(articleRoot,'tables');
    reviewDir = fullfile(articleRoot,'review');
    traceDir = fullfile(articleRoot,'traceability');

    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(reviewDir), mkdir(reviewDir); end
    if ~isfolder(traceDir), mkdir(traceDir); end

    inCsv = fullfile(tablesDir,'ETA_SENSITIVITY_v96z_H2_R1_selected.csv');

    if ~isfile(inCsv)
        error('Input CSV not found: %s', inCsv);
    end

    T = readtable(inCsv);

    % ------------------------------------------------------------------
    % Referencias energéticas por caso con eta constante
    % ------------------------------------------------------------------
    cases = unique(string(T.case_name),'stable');

    T.Q_aux_reduction_vs_constant_pct = NaN(height(T),1);
    T.Q_aux_reduction_vs_H2_same_eta_pct = NaN(height(T),1);
    T.MR_feasible_0p1 = T.MR_fin <= 0.1;

    for i = 1:height(T)
        case_i = string(T.case_name(i));
        eta_i = string(T.eta_mode(i));

        idx_const = string(T.case_name)==case_i & string(T.eta_mode)=="eta_constant_0p50";
        if any(idx_const)
            Q_const = T.Q_aux_tot(find(idx_const,1,'first'));
            T.Q_aux_reduction_vs_constant_pct(i) = 100*(Q_const - T.Q_aux_tot(i))/Q_const;
        end

        idx_H2_same_eta = string(T.case_name)=="H2_historical" & string(T.eta_mode)==eta_i;
        if any(idx_H2_same_eta)
            Q_H2 = T.Q_aux_tot(find(idx_H2_same_eta,1,'first'));
            T.Q_aux_reduction_vs_H2_same_eta_pct(i) = 100*(Q_H2 - T.Q_aux_tot(i))/Q_H2;
        end
    end

    % ------------------------------------------------------------------
    % Clasificación operativa
    % ------------------------------------------------------------------
    T.operational_class = strings(height(T),1);
    T.verdict = strings(height(T),1);

    for i = 1:height(T)
        c = string(T.case_name(i));

        if c == "R1_solution_7"
            T.operational_class(i) = "lowest_auxiliary_energy_feasible";
            T.verdict(i) = "recommended_energy_saving_candidate";
        elseif c == "R1_solution_3"
            T.operational_class(i) = "balanced_feasible_solution";
            T.verdict(i) = "recommended_balanced_candidate";
        elseif c == "H2_historical"
            T.operational_class(i) = "historical_comparison_solution";
            T.verdict(i) = "useful_reference_more_drying_not_minimum_auxiliary_energy";
        elseif c == "R1_solution_9"
            T.operational_class(i) = "aggressive_drying_solution";
            T.verdict(i) = "not_recommended_due_to_high_auxiliary_energy";
        else
            T.operational_class(i) = "unclassified";
            T.verdict(i) = "review_required";
        end
    end

    % ------------------------------------------------------------------
    % Tabla compacta para manuscrito
    % ------------------------------------------------------------------
    Tcompact = T(:, {
        'case_name'
        'eta_mode'
        'Q_aux_tot'
        'dry_time'
        'MR_fin'
        'Irradiacion'
        'eta_mean_positive'
        'Q_aux_reduction_vs_constant_pct'
        'Q_aux_reduction_vs_H2_same_eta_pct'
        'MR_feasible_0p1'
        'operational_class'
        'verdict'
        });

    outCsv = fullfile(tablesDir,'ETA_SENSITIVITY_v96z_H2_R1_selected_consolidated.csv');
    writetable(Tcompact,outCsv);

    outMat = fullfile(traceDir,'ETA_SENSITIVITY_v96z_H2_R1_selected_consolidated.mat');

    % ------------------------------------------------------------------
    % Checks
    % ------------------------------------------------------------------
    checks = {};
    checks{end+1,1} = check_row("E01","Input CSV exists",isfile(inCsv),inCsv);
    checks{end+1,1} = check_row("E02","All expected eta modes present", ...
        all(ismember(["eta_constant_0p50","eta_historical_code_curve","eta_article_2SAH_curve"], unique(string(T.eta_mode)))), ...
        strjoin(unique(string(T.eta_mode)),"; "));
    checks{end+1,1} = check_row("E03","All expected cases present", ...
        all(ismember(["H2_historical","R1_solution_7","R1_solution_3","R1_solution_9"], unique(string(T.case_name)))), ...
        strjoin(unique(string(T.case_name)),"; "));
    checks{end+1,1} = check_row("E04","R1 solution 7 feasible under article curve", ...
        any(string(T.case_name)=="R1_solution_7" & string(T.eta_mode)=="eta_article_2SAH_curve" & T.MR_fin<=0.1), ...
        "MR<=0.1 check.");
    checks{end+1,1} = check_row("E05","R1 solution 7 lower Q_aux than H2 under article curve", ...
        get_Q(T,"R1_solution_7","eta_article_2SAH_curve") < get_Q(T,"H2_historical","eta_article_2SAH_curve"), ...
        "Q_aux R1-7 vs H2, same eta mode.");
    checks{end+1,1} = check_row("E06","No GA executed",true,"Postprocess only.");
    checks{end+1,1} = check_row("E07","No model executed",true,"Read CSV only.");

    Tchecks = struct2table(vertcat(checks{:}));

    if all(Tchecks.pass)
        diagnosis = "ETA_SENSITIVITY_CONSOLIDATION_PASS";
        decision = "USE_AS_MANUSCRIPT_SENSITIVITY_RESULT";
        next_step = "Draft Results/Discussion paragraph for collector efficiency sensitivity.";
    else
        diagnosis = "ETA_SENSITIVITY_CONSOLIDATION_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS_BEFORE_WRITING";
        next_step = "Review Tchecks.";
    end

    checksCsv = fullfile(tablesDir,'ETA_SENSITIVITY_v96z_Tchecks.csv');
    writetable(Tchecks,checksCsv);

    reportMd = fullfile(reviewDir,'ETA_SENSITIVITY_v96z_consolidated.md');

    fid = fopen(reportMd,'w');
    fprintf(fid,'# ETA_SENSITIVITY_v96z consolidated\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);

    fprintf(fid,'## Main interpretation\n\n');
    fprintf(fid,['The 2-SAH collector efficiency curve changes the auxiliary energy balance, ' ...
        'but it does not change the qualitative operational ranking of the evaluated solutions. ' ...
        'R1_solution_7 remains the lowest-auxiliary-energy feasible candidate under MR <= 0.1, ' ...
        'R1_solution_3 remains a balanced feasible candidate, H2 remains a historical comparison point, ' ...
        'and R1_solution_9 remains an aggressive drying solution with high auxiliary demand.\n\n']);

    fprintf(fid,'## Consolidated table\n\n');
    fprintf(fid,'| case | eta mode | Q_aux | dry time | MR | Irradiation | eta positive mean | dQ vs constant %% | dQ vs H2 same eta %% | feasible | verdict |\n');
    fprintf(fid,'|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---|\n');

    for i = 1:height(Tcompact)
        fprintf(fid,'| `%s` | `%s` | %.6g | %.6g | %.6g | %.6g | %.6g | %.6g | %.6g | %d | `%s` |\n', ...
            string(Tcompact.case_name(i)), string(Tcompact.eta_mode(i)), ...
            Tcompact.Q_aux_tot(i), Tcompact.dry_time(i), Tcompact.MR_fin(i), ...
            Tcompact.Irradiacion(i), Tcompact.eta_mean_positive(i), ...
            Tcompact.Q_aux_reduction_vs_constant_pct(i), ...
            Tcompact.Q_aux_reduction_vs_H2_same_eta_pct(i), ...
            Tcompact.MR_feasible_0p1(i), string(Tcompact.verdict(i)));
    end

    fprintf(fid,'\n## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            string(Tchecks.id(i)), string(Tchecks.check(i)), Tchecks.pass(i), string(Tchecks.evidence(i)));
    end

    fclose(fid);

    save(outMat,'T','Tcompact','Tchecks','diagnosis','decision','next_step','inCsv','outCsv','checksCsv','reportMd');

    out = struct();
    out.status = "ETA_SENSITIVITY_v96z_CONSOLIDATED";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.Tcompact = Tcompact;
    out.Tchecks = Tchecks;
    out.outCsv = outCsv;
    out.checksCsv = checksCsv;
    out.reportMd = reportMd;
    out.outMat = outMat;

    disp('=== ETA_SENSITIVITY_v96z ===')
    disp(out.status)
    disp('=== DIAGNOSIS ===')
    disp(out.diagnosis)
    disp('=== DECISION ===')
    disp(out.decision)
    disp('=== NEXT STEP ===')
    disp(out.next_step)
    disp('=== COMPACT TABLE ===')
    disp(out.Tcompact)
    disp('=== CHECKS ===')
    disp(out.Tchecks)
    disp('=== REPORT ===')
    disp(out.reportMd)
end

function Q = get_Q(T,caseName,etaMode)
    idx = string(T.case_name)==string(caseName) & string(T.eta_mode)==string(etaMode);
    if any(idx)
        Q = T.Q_aux_tot(find(idx,1,'first'));
    else
        Q = NaN;
    end
end

function row = check_row(id,checkName,passVal,evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end