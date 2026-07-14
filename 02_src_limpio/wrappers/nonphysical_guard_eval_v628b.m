function [bad, diag] = nonphysical_guard_eval_v628b(i, Mf, ...
    T_HE1_in, T_HE1_out, T_DH_in, T_DH_out, T_prod, T_amb, ...
    HR_DH_in, HR_DH_out, HR_amb, ...
    w_DH_in, w_DH_out, ...
    M_prod, MR, Q_aux, I)
% NONPHYSICAL_GUARD_EVAL_v628b
% Guarda externa para evaluar dominio fisico en el indice i.

    bad = false;
    diag = struct();
    diag.status = "OK";
    diag.first_i = NaN;
    diag.variable = "";
    diag.rule = "";
    diag.value_real = NaN;
    diag.value_imag = NaN;
    diag.priority = NaN;
    diag.Mf = Mf;

    violations = {};

    violations = local_check(violations, i, "T_HE1_in",  T_HE1_in,  "temperature_low_high", -10, 120, 10);
    violations = local_check(violations, i, "T_HE1_out", T_HE1_out, "temperature_low_high", -10, 120, 10);
    violations = local_check(violations, i, "T_DH_in",   T_DH_in,   "temperature_low_high", -10, 120, 10);
    violations = local_check(violations, i, "T_DH_out",  T_DH_out,  "temperature_low_high", -10, 120, 10);
    violations = local_check(violations, i, "T_prod",    T_prod,    "temperature_low_high", -10, 120, 10);
    violations = local_check(violations, i, "T_amb",     T_amb,     "temperature_low_high", -10, 120, 10);

    violations = local_check(violations, i, "HR_DH_in",  HR_DH_in,  "relative_humidity_0_1", 0, 1, 20);
    violations = local_check(violations, i, "HR_DH_out", HR_DH_out, "relative_humidity_0_1", 0, 1, 20);
    violations = local_check(violations, i, "HR_amb",    HR_amb,    "relative_humidity_0_1", 0, 1, 20);

    violations = local_check(violations, i, "w_DH_in",   w_DH_in,   "humidity_ratio_nonnegative", 0, Inf, 30);
    violations = local_check(violations, i, "w_DH_out",  w_DH_out,  "humidity_ratio_nonnegative", 0, Inf, 30);

    violations = local_check(violations, i, "M_prod",    M_prod,    "moisture_content_ge_Mf", Mf, Inf, 40);
    violations = local_check(violations, i, "MR",        MR,        "MR_0_1", 0, 1, 50);
    violations = local_check(violations, i, "Q_aux",     Q_aux,     "energy_aux_nonnegative", 0, Inf, 60);
    violations = local_check(violations, i, "I",         I,         "irradiance_nonnegative", 0, Inf, 60);

    if isempty(violations)
        return
    end

    bad = true;
    D = struct2table(vertcat(violations{:}));
    D = sortrows(D,{'priority','variable'});

    diag.status = "NONPHYSICAL_TRAJECTORY";
    diag.first_i = i;
    diag.variable = string(D.variable(1));
    diag.rule = string(D.rule(1));
    diag.value_real = D.value_real(1);
    diag.value_imag = D.value_imag(1);
    diag.priority = D.priority(1);
    diag.all_violations = D;
end

function violations = local_check(violations, i, name, vec, rule, lower, upper, priority)
    if isempty(vec)
        return
    end

    idx = min(max(1,i),numel(vec));
    val = double(vec(idx));
    rv = real(val);
    iv = imag(val);

    bad_naninf = isnan(rv) || isinf(rv) || isnan(iv) || isinf(iv);
    bad_complex = abs(iv) > 1e-9;

    switch char(rule)
        case 'temperature_low_high'
            bad_rule = rv < lower || rv > upper;
        case 'relative_humidity_0_1'
            bad_rule = rv < lower || rv > upper;
        case 'humidity_ratio_nonnegative'
            bad_rule = rv < lower;
        case 'moisture_content_ge_Mf'
            bad_rule = rv < (lower - 1e-8);
        case 'MR_0_1'
            bad_rule = rv < lower || rv > upper;
        case 'energy_aux_nonnegative'
            bad_rule = rv < lower;
        case 'irradiance_nonnegative'
            bad_rule = rv < lower;
        otherwise
            bad_rule = false;
    end

    if ~(bad_naninf || bad_complex || bad_rule)
        return
    end

    if bad_naninf
        finalRule = string(rule) + "_nan_or_inf";
        finalPriority = priority - 2;
    elseif bad_complex
        finalRule = string(rule) + "_complex";
        finalPriority = priority - 1;
    else
        finalRule = string(rule);
        finalPriority = priority;
    end

    one = struct();
    one.variable = string(name);
    one.rule = string(finalRule);
    one.i = i;
    one.value_real = rv;
    one.value_imag = iv;
    one.priority = finalPriority;

    violations{end+1,1} = one;
end
