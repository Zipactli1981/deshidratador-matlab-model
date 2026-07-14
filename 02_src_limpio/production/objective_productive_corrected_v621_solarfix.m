function [f, detail] = objective_productive_corrected_v621_solarfix(x, mode_operation)
% OBJECTIVE_PRODUCTIVE_CORRECTED_v621_SOLARFIX
% Igual que objective_productive_corrected_v611, pero llama al wrapper v11.
% Uso exclusivo para validar SOLAR-TMAX-CLOSURE-FIX-001.
% No usar para repetir AG todavía.

    if nargin < 2 || isempty(mode_operation)
        mode_operation = "hybrid";
    end

    mode_operation = string(mode_operation);

    W0  = 0.75;
    m_i = 20;
    Mi  = 6.55;
    mwi = 17.35;
    md  = 2.65;
    m_f = 2.913;
    Mf  = 0.10;
    mwf = 0.263;
    M_des = 0.10;

    m_max     = x(1);
    T_min     = x(2);
    r_div2    = x(3);
    t_rec_ini = x(4);

    [Q_aux_tot, dry_time, M, MR, Irradiacion, irr_diag] = ...
        opt_tunel_mod2_v11_solar_tmax_closure_fixed( ...
            m_max,T_min,r_div2,t_rec_ini, ...
            W0,m_i,Mi,mwi,md,m_f,Mf,mwf,M_des,mode_operation);

    cost_params = build_cost_params_historical();
    cost = calc_cost_breakdown(Q_aux_tot, Irradiacion, dry_time, md, Mi, M, cost_params);

    f = [MR, cost.cost_specific_USD_per_kgwater];

    detail = struct();
    detail.status = 'OK';
    detail.mode_operation = char(mode_operation);
    detail.Q_aux_tot = Q_aux_tot;
    detail.Irradiacion = Irradiacion;
    detail.dry_time = dry_time;
    detail.M = M;
    detail.MR = MR;
    detail.cost = cost;
    detail.irr_diag = irr_diag;

    if isfield(irr_diag,'rule')
        detail.irradiance_rule = irr_diag.rule;
    end

    if isfield(irr_diag,'aux_rule')
        detail.aux_rule = irr_diag.aux_rule;
    end

    if isfield(irr_diag,'termination_status')
        detail.termination_status = irr_diag.termination_status;
    else
        detail.termination_status = "UNKNOWN";
    end
end
