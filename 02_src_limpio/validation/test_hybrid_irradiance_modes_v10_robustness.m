function diag2 = test_hybrid_irradiance_modes_v10_robustness()
%TEST_HYBRID_IRRADIANCE_MODES_V10_ROBUSTNESS Second-point robustness test.
%
% Does not run GA.
% Does not change cost.
% Does not declare final article results.

    rootDir = setup_v05_paths();

    logsDir = fullfile(rootDir,'06_outputs','logs');
    tablesDir = fullfile(rootDir,'06_outputs','tables');
    comparisonsDir = fullfile(rootDir,'06_outputs','comparisons');

    if ~exist(logsDir,'dir'), mkdir(logsDir); end
    if ~exist(tablesDir,'dir'), mkdir(tablesDir); end
    if ~exist(comparisonsDir,'dir'), mkdir(comparisonsDir); end

    %% Second point validated locally
    m_max = 0.11;
    T_min = 55;
    r_div2 = 0.5;
    t_rec_ini = 3;
    W0 = 200;

    %% Product parameters
    m_i = 0.87;
    Mi = m_i/(1-m_i);
    mwi = W0*m_i;
    md = mwi/Mi;

    m_f = 0.08;
    m_des = 0.1;
    Mf = m_f/(1-m_f);
    M_des = m_des/(1-m_des);
    mwf = Mf*md;

    modes = {'gasLP'; 'hybrid'; 'solar'};
    n = numel(modes);

    mode = cell(n,1);
    I_effective_rule = cell(n,1);
    aux_rule = cell(n,1);
    I_effective = NaN(n,1);
    Irradiacion = NaN(n,1);
    Q_aux_tot = NaN(n,1);
    dry_time = NaN(n,1);
    M = NaN(n,1);
    MR = NaN(n,1);

    for k = 1:n
        [Q_aux_k, dry_k, M_k, MR_k, Irr_k, irr_diag] = opt_tunel_mod2_v10_energy_mode_corrected( ...
            m_max, T_min, r_div2, t_rec_ini, ...
            W0, m_i, Mi, mwi, md, m_f, Mf, mwf, M_des, modes{k});

        mode{k} = modes{k};
        I_effective_rule{k} = char(irr_diag.rule);
        if isfield(irr_diag,'aux_rule')
            aux_rule{k} = char(irr_diag.aux_rule);
        else
            aux_rule{k} = 'aux_rule_not_reported';
        end
        I_effective(k) = irr_diag.I_effective_sum;
        Irradiacion(k) = Irr_k;
        Q_aux_tot(k) = Q_aux_k;
        dry_time(k) = dry_k;
        M(k) = M_k;
        MR(k) = MR_k;
    end

    T2 = table(mode, I_effective_rule, aux_rule, I_effective, Irradiacion, ...
        Q_aux_tot, dry_time, M, MR, ...
        'VariableNames', {'mode','I_effective_rule','aux_rule','I_effective', ...
        'Irradiacion','Q_aux_tot','dry_time','M','MR'});

    gas_idx = strcmp(T2.mode,'gasLP');
    hybrid_idx = strcmp(T2.mode,'hybrid');
    solar_idx = strcmp(T2.mode,'solar');

    gas_ok = T2.Irradiacion(gas_idx) == 0 && T2.Q_aux_tot(gas_idx) > 0;
    hybrid_ok = T2.Irradiacion(hybrid_idx) > 0 && T2.Q_aux_tot(hybrid_idx) > 0;
    solar_ok = T2.Irradiacion(solar_idx) > 0 && T2.Q_aux_tot(solar_idx) == 0;

    if gas_ok && hybrid_ok && solar_ok
        status = 'PASS';
    else
        status = 'FAIL';
    end

    txtFile = fullfile(logsDir,'HYBRID_IRR_MODE_AB_v10_ROBUSTNESS.txt');
    csvFile = fullfile(tablesDir,'HYBRID_IRR_MODE_AB_v10_ROBUSTNESS.csv');
    matFile = fullfile(comparisonsDir,'HYBRID_IRR_MODE_AB_v10_ROBUSTNESS.mat');

    writetable(T2,csvFile);

    diag2 = struct();
    diag2.created_at = datetime('now');
    diag2.created_by_function = 'test_hybrid_irradiance_modes_v10_robustness';
    diag2.status = status;
    diag2.gas_ok = gas_ok;
    diag2.hybrid_ok = hybrid_ok;
    diag2.solar_ok = solar_ok;
    diag2.output_txt = txtFile;
    diag2.output_csv = csvFile;
    diag2.output_mat = matFile;

    save(matFile,'diag2','T2');

    fid = fopen(txtFile,'w');
    fprintf(fid,'HYBRID_IRR_MODE_AB_v10_ROBUSTNESS\n\n');
    fprintf(fid,'status: %s\n', status);
    fprintf(fid,'GA not executed.\n');
    fprintf(fid,'Final article results not declared.\n\n');
    fprintf(fid,'Operating point:\n');
    fprintf(fid,'m_max = %.10g\nT_min = %.10g\nr_div2 = %.10g\nt_rec_ini = %.10g\nW0 = %.10g\n\n', ...
        m_max, T_min, r_div2, t_rec_ini, W0);

    fprintf(fid,'Selector checks:\n');
    fprintf(fid,'gas_ok = %d\nhybrid_ok = %d\nsolar_ok = %d\n\n', gas_ok, hybrid_ok, solar_ok);

    for k = 1:height(T2)
        fprintf(fid,'--- %s ---\n', T2.mode{k});
        fprintf(fid,'I_effective_rule: %s\n', T2.I_effective_rule{k});
        fprintf(fid,'aux_rule: %s\n', T2.aux_rule{k});
        fprintf(fid,'I_effective: %.10g\n', T2.I_effective(k));
        fprintf(fid,'Irradiacion: %.10g\n', T2.Irradiacion(k));
        fprintf(fid,'Q_aux_tot: %.10g\n', T2.Q_aux_tot(k));
        fprintf(fid,'dry_time: %.10g\n', T2.dry_time(k));
        fprintf(fid,'M: %.10g\n', T2.M(k));
        fprintf(fid,'MR: %.10g\n\n', T2.MR(k));
    end
    fclose(fid);

    disp('=== MICROPRUEBA 2 MODE-ENERGY-001 ===')
    disp(T2)
    disp('selector_status:')
    disp(status)
end
