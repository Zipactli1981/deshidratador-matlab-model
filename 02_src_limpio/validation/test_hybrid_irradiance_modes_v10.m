function diag = test_hybrid_irradiance_modes_v10()
%TEST_HYBRID_IRRADIANCE_MODES_V10 A/B test by energy mode.
%
% Consolidated in v1.2-HYBRID-IRR_CONSOLIDADA.
%
% Scope:
%   - single operating point;
%   - no GA;
%   - no cost changes;
%   - no final article results.
%
% Required outputs:
%   mode, I_effective, Irradiacion, Q_aux_tot, dry_time, M, MR
%
% HYBRID-IRR-001:
%   gasLP  -> I_effective = 0
%   hybrid -> I_effective = I_busc
%   solar  -> I_effective = I_busc
%
% MODE-ENERGY-001:
%   gasLP  -> calor_aux = true
%   hybrid -> calor_aux = true
%   solar  -> calor_aux = false
%
% Evidence:
%   06_outputs/logs/HYBRID_IRR_MODE_AB_v10.txt
%   06_outputs/tables/HYBRID_IRR_MODE_AB_v10.csv
%   06_outputs/comparisons/HYBRID_IRR_MODE_AB_v10.mat

    rootDir = setup_v05_paths();

    logsDir = fullfile(rootDir,'06_outputs','logs');
    tablesDir = fullfile(rootDir,'06_outputs','tables');
    comparisonsDir = fullfile(rootDir,'06_outputs','comparisons');

    if ~exist(logsDir,'dir'), mkdir(logsDir); end
    if ~exist(tablesDir,'dir'), mkdir(tablesDir); end
    if ~exist(comparisonsDir,'dir'), mkdir(comparisonsDir); end

    %% Single operating point validated locally
    m_max = 0.12;
    T_min = 50;
    r_div2 = 0;
    t_rec_ini = 0;

    %% Product parameters requested
    W0 = 0.85;
    m_i = 0.87;
    Mi = m_i/(1-m_i);
    mwi = W0*m_i;
    md = mwi/Mi;
    m_f = 0.08;
    m_des = 0.1;
    Mf = m_f/(1-m_f);
    M_des = m_des/(1-m_des);
    mwf = Mf*md;

    %% Historical wrapper
    [Q_aux_h, dry_h, M_h, MR_h, Irr_h] = opt_tunel_mod2_v06_data_controlled( ...
        m_max, T_min, r_div2, t_rec_ini, ...
        W0, m_i, Mi, mwi, md, m_f, Mf, mwf, M_des);

    modes = {'gasLP'; 'hybrid'; 'solar'};
    n = numel(modes) + 1;

    wrapper = cell(n,1);
    mode = cell(n,1);
    I_effective_rule = cell(n,1);
    aux_rule = cell(n,1);
    I_effective = NaN(n,1);
    Irradiacion = NaN(n,1);
    Q_aux_tot = NaN(n,1);
    dry_time = NaN(n,1);
    M = NaN(n,1);
    MR = NaN(n,1);

    wrapper{1} = 'historical_v06_data_controlled';
    mode{1} = 'historical';
    I_effective_rule{1} = 'legacy: no explicit energy mode selector';
    aux_rule{1} = 'legacy: calor_aux fixed in model';
    I_effective(1) = NaN;
    Irradiacion(1) = Irr_h;
    Q_aux_tot(1) = Q_aux_h;
    dry_time(1) = dry_h;
    M(1) = M_h;
    MR(1) = MR_h;

    for k = 1:numel(modes)
        [Q_aux_k, dry_k, M_k, MR_k, Irr_k, irr_diag] = opt_tunel_mod2_v10_energy_mode_corrected( ...
            m_max, T_min, r_div2, t_rec_ini, ...
            W0, m_i, Mi, mwi, md, m_f, Mf, mwf, M_des, modes{k});

        idx = k + 1;
        wrapper{idx} = 'corrected_v10_energy_mode';
        mode{idx} = modes{k};
        I_effective_rule{idx} = char(irr_diag.rule);
        if isfield(irr_diag,'aux_rule')
            aux_rule{idx} = char(irr_diag.aux_rule);
        else
            aux_rule{idx} = 'aux_rule_not_reported';
        end
        I_effective(idx) = irr_diag.I_effective_sum;
        Irradiacion(idx) = Irr_k;
        Q_aux_tot(idx) = Q_aux_k;
        dry_time(idx) = dry_k;
        M(idx) = M_k;
        MR(idx) = MR_k;
    end

    T = table(wrapper, mode, I_effective_rule, aux_rule, I_effective, Irradiacion, ...
        Q_aux_tot, dry_time, M, MR, ...
        'VariableNames', {'wrapper','mode','I_effective_rule','aux_rule', ...
        'I_effective','Irradiacion','Q_aux_tot','dry_time','M','MR'});

    %% Validate selector behavior
    gas_idx = find(strcmp(mode,'gasLP'));
    hybrid_idx = find(strcmp(mode,'hybrid'));
    solar_idx = find(strcmp(mode,'solar'));

    gas_ok = ~isempty(gas_idx) && I_effective(gas_idx) == 0 && ...
        Irradiacion(gas_idx) == 0 && Q_aux_tot(gas_idx) > 0;

    hybrid_ok = ~isempty(hybrid_idx) && I_effective(hybrid_idx) > 0 && ...
        Irradiacion(hybrid_idx) > 0 && Q_aux_tot(hybrid_idx) > 0;

    solar_ok = ~isempty(solar_idx) && I_effective(solar_idx) > 0 && ...
        Irradiacion(solar_idx) > 0 && Q_aux_tot(solar_idx) == 0;

    if gas_ok && hybrid_ok && solar_ok
        selector_status = 'PASS';
    else
        selector_status = 'FAIL';
    end

    txtFile = fullfile(logsDir,'HYBRID_IRR_MODE_AB_v10.txt');
    csvFile = fullfile(tablesDir,'HYBRID_IRR_MODE_AB_v10.csv');
    matFile = fullfile(comparisonsDir,'HYBRID_IRR_MODE_AB_v10.mat');

    writetable(T,csvFile);

    diag = struct();
    diag.created_at = datetime('now');
    diag.created_by_function = 'test_hybrid_irradiance_modes_v10';
    diag.status = selector_status;
    diag.note = 'HYBRID-IRR-001 and MODE-ENERGY-001 corrected in controlled wrapper only; not final article results.';
    diag.gas_ok = gas_ok;
    diag.hybrid_ok = hybrid_ok;
    diag.solar_ok = solar_ok;
    diag.output_txt = txtFile;
    diag.output_csv = csvFile;
    diag.output_mat = matFile;

    save(matFile,'diag','T');

    fid = fopen(txtFile,'w');
    fprintf(fid,'HYBRID_IRR_MODE_AB_v10\n\n');
    fprintf(fid,'status: %s\n', selector_status);
    fprintf(fid,'HYBRID-IRR-001 corrected in controlled wrapper only.\n');
    fprintf(fid,'MODE-ENERGY-001 corrected in controlled wrapper only.\n');
    fprintf(fid,'AUD-HYBRID-B-002 integrated: nargin default fixed from <15 to <14.\n');
    fprintf(fid,'GA not executed.\n');
    fprintf(fid,'Final article results not declared.\n\n');
    fprintf(fid,'Operating point:\n');
    fprintf(fid,'m_max = %.10g\nT_min = %.10g\nr_div2 = %.10g\nt_rec_ini = %.10g\nW0 = %.10g\n\n', ...
        m_max, T_min, r_div2, t_rec_ini, W0);
    fprintf(fid,'Selector checks:\n');
    fprintf(fid,'gas_ok = %d\nhybrid_ok = %d\nsolar_ok = %d\n\n', gas_ok, hybrid_ok, solar_ok);

    for k = 1:height(T)
        fprintf(fid,'--- %s / %s ---\n', T.wrapper{k}, T.mode{k});
        fprintf(fid,'I_effective_rule: %s\n', T.I_effective_rule{k});
        fprintf(fid,'aux_rule: %s\n', T.aux_rule{k});
        fprintf(fid,'I_effective: %.10g\n', T.I_effective(k));
        fprintf(fid,'Irradiacion: %.10g\n', T.Irradiacion(k));
        fprintf(fid,'Q_aux_tot: %.10g\n', T.Q_aux_tot(k));
        fprintf(fid,'dry_time: %.10g\n', T.dry_time(k));
        fprintf(fid,'M: %.10g\n', T.M(k));
        fprintf(fid,'MR: %.10g\n\n', T.MR(k));
    end

    fclose(fid);

    disp('=== HYBRID_IRR_MODE_AB_v10 ===')
    disp(T)
    disp('selector_status:')
    disp(selector_status)
end
