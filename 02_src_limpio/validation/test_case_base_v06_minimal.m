function test_status = test_case_base_v06_minimal()
%TEST_CASE_BASE_V06_MINIMAL Minimal direct test of the controlled model.
%
% Purpose:
%   Execute one single base combination, not the full sweep in
%   run_opt_tunel_mod2.mlx and not the GA.
%
% DATA-B-001 strict:
%   This test calls opt_tunel_mod2_v06_data_controlled(), not the original
%   opt_tunel_mod2.mlx. The controlled function loads environmental data by
%   project-relative path through load_environmental_data_original().
%
% Combination:
%   m_max = 0.11
%   T_min = 50 °C
%   r_div2 = 0
%   t_rec_ini = 3 h
%
% Expected outputs:
%   Q_aux_tot, dry_time, M, MR, Irradiacion
%
% This test does not modify physical model, kinetics, cost formula or
% HYBRID-IRR-001.

    rootDir = setup_v05_paths();

    test_status = struct();
    test_status.created_at = datetime("now");
    test_status.created_by_function = "test_case_base_v06_minimal";
    test_status.rootDir = string(rootDir);
    test_status.status = "NOT_RUN";
    test_status.errors = {};
    test_status.warnings = {};

    logsDir = fullfile(rootDir, "06_outputs", "logs");
    if ~exist(logsDir, "dir")
        mkdir(logsDir);
    end

    diaryFile = fullfile(logsDir, ...
        "TEST_CASE_BASE_V06_MINIMAL_" + string(datestr(now,"yyyymmdd_HHMMSS")) + ".txt");

    diary(diaryFile);

    try
        disp("=== PATH CHECK ===")
        which opt_tunel_mod2_v06_data_controlled -all
        which opt_tunel_mod2 -all
        which tunel_mod2 -all
        which preallocating -all
        which humrat_AirH2O -all
        which load_environmental_data_original -all
        which Mapeo4_temp100621.txt -all

        disp("=== DEFINE BASE PRODUCT PARAMETERS ===")
        W0 = 200;
        m_i = 0.87;
        Mi = m_i/(1-m_i);
        mwi = W0*m_i;
        md = mwi/Mi;
        m_f = 0.08;
        m_des = 0.1;
        Mf = m_f/(1-m_f);
        M_des = m_des/(1-m_des);
        mwf = Mf*md;

        disp("=== DEFINE MINIMAL OPERATING POINT ===")
        m_max = 0.11;
        T_min = 50;
        r_div2 = 0;
        t_rec_ini = 3;

        disp("=== CALL controlled opt_tunel_mod2 ONCE ===")
        [Q_aux_tot, dry_time, M, MR, Irradiacion] = opt_tunel_mod2_v06_data_controlled( ...
            m_max, T_min, r_div2, t_rec_ini, ...
            W0, m_i, Mi, mwi, md, m_f, Mf, mwf, M_des);

        test_status.outputs.Q_aux_tot = Q_aux_tot;
        test_status.outputs.dry_time = dry_time;
        test_status.outputs.M = M;
        test_status.outputs.MR = MR;
        test_status.outputs.Irradiacion = Irradiacion;

        fprintf("\nQ_aux_tot: %.10g\n", Q_aux_tot);
        fprintf("dry_time: %.10g\n", dry_time);
        fprintf("M: %.10g\n", M);
        fprintf("MR: %.10g\n", MR);
        fprintf("Irradiacion: %.10g\n", Irradiacion);

        values = [Q_aux_tot, dry_time, M, MR, Irradiacion];

        if any(isnan(values)) || any(isinf(values))
            test_status.status = "FAIL";
            test_status.errors{end+1} = "At least one output is NaN or Inf.";
        else
            test_status.status = "PASS";
        end

    catch ME
        test_status.status = "FAIL";
        test_status.errors{end+1} = getReport(ME, "extended", "hyperlinks", "off");
    end

    test_status.diaryFile = string(diaryFile);
    diary off

    save(fullfile(logsDir, ...
        "TEST_CASE_BASE_V06_MINIMAL_" + string(datestr(now,"yyyymmdd_HHMMSS")) + ".mat"), ...
        "test_status");
end
