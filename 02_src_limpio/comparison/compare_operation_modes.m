function report = compare_operation_modes()
%COMPARE_OPERATION_MODES Compare gasLP, hybrid and solar without GA.
%
% Micropaso 6.7. Consolidated in v1.3-HYBRID-IRR_COMPARE_CONSOLIDADA.
%
% Uses opt_tunel_mod2_v10_energy_mode_corrected.m.
% Does not run GA, modify costs, or declare final article results.

    rootDir = setup_v05_paths();

    compDir = fullfile(rootDir,'06_outputs','comparisons');
    tabDir  = fullfile(rootDir,'06_outputs','tables');
    logDir  = fullfile(rootDir,'06_outputs','logs');

    if ~exist(compDir,'dir'), mkdir(compDir); end
    if ~exist(tabDir,'dir'), mkdir(tabDir); end
    if ~exist(logDir,'dir'), mkdir(logDir); end

    cases = table( ...
        {'case_01_validated'; 'case_02_robustness'}, ...
        [0.12; 0.11], ...
        [50; 55], ...
        [0; 0.5], ...
        [0; 3], ...
        [0.85; 200], ...
        'VariableNames', {'case_id','m_max','T_min','r_div2','t_rec_ini','W0'} );

    modes = {'gasLP'; 'hybrid'; 'solar'};

    out_case_id = {};
    out_mode = {};
    out_I_rule = {};
    out_aux_rule = {};
    out_I_effective = [];
    out_Irradiacion = [];
    out_Q_aux_tot = [];
    out_dry_time = [];
    out_M = [];
    out_MR = [];
    out_status = {};

    for c = 1:height(cases)
        m_max = cases.m_max(c);
        T_min = cases.T_min(c);
        r_div2 = cases.r_div2(c);
        t_rec_ini = cases.t_rec_ini(c);
        W0 = cases.W0(c);

        m_i = 0.87;
        Mi = m_i/(1-m_i);
        mwi = W0*m_i;
        md = mwi/Mi;
        m_f = 0.08;
        m_des = 0.1;
        Mf = m_f/(1-m_f);
        M_des = m_des/(1-m_des);
        mwf = Mf*md;

        for k = 1:numel(modes)
            mode_k = modes{k};

            [Q_aux_tot, dry_time, M, MR, Irradiacion, irr_diag] = ...
                opt_tunel_mod2_v10_energy_mode_corrected( ...
                    m_max, T_min, r_div2, t_rec_ini, ...
                    W0, m_i, Mi, mwi, md, m_f, Mf, mwf, M_des, mode_k);

            if MR <= 0.1
                status_k = 'SECADO_COMPLETO';
            else
                status_k = 'SECADO_INCOMPLETO';
            end

            out_case_id{end+1,1} = char(cases.case_id{c});
            out_mode{end+1,1} = char(mode_k);
            out_I_rule{end+1,1} = char(irr_diag.rule);
            if isfield(irr_diag,'aux_rule')
                out_aux_rule{end+1,1} = char(irr_diag.aux_rule);
            else
                out_aux_rule{end+1,1} = 'aux_rule_not_reported';
            end
            out_I_effective(end+1,1) = irr_diag.I_effective_sum;
            out_Irradiacion(end+1,1) = Irradiacion;
            out_Q_aux_tot(end+1,1) = Q_aux_tot;
            out_dry_time(end+1,1) = dry_time;
            out_M(end+1,1) = M;
            out_MR(end+1,1) = MR;
            out_status{end+1,1} = status_k;
        end
    end

    T = table(out_case_id, out_mode, out_I_rule, out_aux_rule, out_I_effective, ...
        out_Irradiacion, out_Q_aux_tot, out_dry_time, out_M, out_MR, out_status, ...
        'VariableNames', {'case_id','mode','I_effective_rule','aux_rule','I_effective', ...
        'Irradiacion','Q_aux_tot','dry_time','M','MR','drying_status'} );

    csvFile = fullfile(tabDir,'COMPARE_OPERATION_MODES_v67.csv');
    matFile = fullfile(compDir,'COMPARE_OPERATION_MODES_v67.mat');
    txtFile = fullfile(logDir,'COMPARE_OPERATION_MODES_v67.txt');

    writetable(T,csvFile);

    report = struct();
    report.created_at = datetime('now');
    report.created_by_function = 'compare_operation_modes';
    report.status = 'COMPARISON_ONLY_NO_GA';
    report.csvFile = csvFile;
    report.matFile = matFile;
    report.txtFile = txtFile;

    save(matFile,'report','T','cases');

    fid = fopen(txtFile,'w');
    fprintf(fid,'COMPARE_OPERATION_MODES_v67\n\n');
    fprintf(fid,'status: COMPARISON_ONLY_NO_GA\n');
    fprintf(fid,'GA not executed.\n');
    fprintf(fid,'Costs not modified.\n');
    fprintf(fid,'Final article figures not declared.\n\n');
    fprintf(fid,'Rules:\n');
    fprintf(fid,'gasLP  -> I_effective = 0,      calor_aux = true\n');
    fprintf(fid,'hybrid -> I_effective = I_busc, calor_aux = true\n');
    fprintf(fid,'solar  -> I_effective = I_busc, calor_aux = false\n\n');
    fprintf(fid,'Drying criterion used only for diagnostic classification:\n');
    fprintf(fid,'MR <= 0.1 -> SECADO_COMPLETO\n');
    fprintf(fid,'MR > 0.1  -> SECADO_INCOMPLETO\n\n');
    fprintf(fid,'Important:\n');
    fprintf(fid,'Fig. 20, Fig. 21 and productive hybrid results must be recalculated before article use.\n\n');
    fclose(fid);

    disp('=== COMPARE_OPERATION_MODES_v67 ===')
    disp(T)
end
