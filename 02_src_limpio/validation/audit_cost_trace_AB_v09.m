function audit = audit_cost_trace_AB_v09()
%AUDIT_COST_TRACE_AB_V09 A/B audit of historical formula vs cost breakdown.
%
% AUD-COST-AB-001
%
% This audit does NOT run the physical model and does NOT run the GA.
% It compares:
%
%   f_old = (W_comp*dry_time*C_kWh + ...
%            Q_aux_tot*C_esp_GLP + ...
%            Irradiacion*C_solar) / ((Mi-M)*md)
%
% against:
%
%   f_trace = calc_cost_breakdown(...).cost_specific_USD_per_kgwater
%
% PASS criterion:
%   max relative error <= 1e-10
%
% Evidence:
%   06_outputs/logs/AUD_COST_TRACE_AB_v09.txt
%   06_outputs/tables/AUD_COST_TRACE_AB_v09.csv
%   06_outputs/comparisons/AUD_COST_TRACE_AB_v09.mat

    rootDir = setup_v05_paths();
    params_cost = build_cost_params_historical();

    logsDir = fullfile(rootDir, "06_outputs", "logs");
    tablesDir = fullfile(rootDir, "06_outputs", "tables");
    comparisonsDir = fullfile(rootDir, "06_outputs", "comparisons");

    if ~exist(logsDir, "dir"), mkdir(logsDir); end
    if ~exist(tablesDir, "dir"), mkdir(tablesDir); end
    if ~exist(comparisonsDir, "dir"), mkdir(comparisonsDir); end

    %% Product parameters used in the manual minimal test
    W0 = 200;
    m_i = 0.87;
    Mi = m_i/(1-m_i);
    mwi = W0*m_i;
    md = mwi/Mi;

    %% A/B cases
    %
    % Case 1 uses the manually reported v0.8 minimal test output:
    %   Q_aux_tot  = 1234.608652
    %   dry_time   = 19.9
    %   M          = 2.439033823
    %   MR         = 0.3578232197
    %   Irradiacion= 0
    %
    % Additional cases perturb the same algebraic inputs. They do not
    % represent new model runs or article results; they only stress-test the
    % algebraic equivalence between f_old and f_trace.

    case_id = ["manual_v08_minimal"; "synthetic_low_aux"; "synthetic_solar_term"; "synthetic_high_aux"];

    dry_time = [19.9; 10.0; 8.5; 15.0];
    Q_aux_tot = [1234.608652; 250.0; 100.0; 1500.0];
    M = [2.439033823; 2.0; 1.5; 0.9];
    Irradiacion = [0.0; 0.0; 350.0; 50.0];

    n = numel(case_id);

    C_kWh = params_cost.C_kWh_internal;
    C_esp_GLP = params_cost.C_esp_GLP_internal;
    C_solar = params_cost.C_solar_internal;
    W_comp = params_cost.W_comp_kW;

    electric_energy_kWh = NaN(n,1);
    electric_cost_USD = NaN(n,1);
    LPG_energy_MJ = NaN(n,1);
    LPG_cost_USD = NaN(n,1);
    solar_energy_MJ = NaN(n,1);
    solar_cost_USD = NaN(n,1);
    total_cost_USD = NaN(n,1);
    water_removed_kg = NaN(n,1);
    f_old = NaN(n,1);
    f_trace = NaN(n,1);
    relative_error = NaN(n,1);

    for k = 1:n
        f_old(k) = (W_comp*dry_time(k)*C_kWh + ...
                    Q_aux_tot(k)*C_esp_GLP + ...
                    Irradiacion(k)*C_solar) / ((Mi-M(k))*md);

        cost = calc_cost_breakdown(dry_time(k), Q_aux_tot(k), Irradiacion(k), ...
                                   Mi, M(k), md, params_cost);

        electric_energy_kWh(k) = cost.electric_energy_kWh;
        electric_cost_USD(k) = cost.electric_cost_USD;
        LPG_energy_MJ(k) = cost.LPG_energy_MJ;
        LPG_cost_USD(k) = cost.LPG_cost_USD;
        solar_energy_MJ(k) = cost.solar_energy_MJ;
        solar_cost_USD(k) = cost.solar_cost_USD;
        total_cost_USD(k) = cost.total_cost_USD;
        water_removed_kg(k) = cost.water_removed_kg;
        f_trace(k) = cost.cost_specific_USD_per_kgwater;

        relative_error(k) = abs(f_trace(k) - f_old(k)) / max(abs(f_old(k)), eps);
    end

    T = table(case_id, dry_time, Q_aux_tot, Irradiacion, Mi*ones(n,1), M, md*ones(n,1), ...
        electric_energy_kWh, electric_cost_USD, LPG_energy_MJ, LPG_cost_USD, ...
        solar_energy_MJ, solar_cost_USD, total_cost_USD, water_removed_kg, ...
        f_old, f_trace, relative_error, ...
        "VariableNames", ["case_id", "dry_time_h", "Q_aux_tot_MJ", "Irradiacion_MJ", ...
        "Mi_db", "M_db", "md_kg_dry_solid", ...
        "electric_energy_kWh", "electric_cost_USD", ...
        "LPG_energy_MJ", "LPG_cost_USD", ...
        "solar_energy_MJ", "solar_cost_USD", ...
        "total_cost_USD", "water_removed_kg", ...
        "f_old_USD_per_kgwater", "f_trace_USD_per_kgwater", ...
        "relative_error"]);

    max_relative_error = max(relative_error);
    tolerance = 1e-10;

    if max_relative_error <= tolerance
        dictamen = "PASS";
    else
        dictamen = "FAIL";
    end

    audit.created_at = datetime("now");
    audit.created_by_function = "audit_cost_trace_AB_v09";
    audit.status = dictamen;
    audit.tolerance = tolerance;
    audit.max_relative_error = max_relative_error;
    audit.internal_cost_unit = "USD";
    audit.denominator = "(Mi - M) * md";
    audit.denominator_units = "kg water";
    audit.exchange_rate_MXN_per_USD = params_cost.exchange_rate_MXN_per_USD;
    audit.C_kWh = C_kWh;
    audit.C_esp_GLP = C_esp_GLP;
    audit.C_solar = C_solar;
    audit.C_kWh_units = params_cost.units.C_kWh_internal;
    audit.C_esp_GLP_units = params_cost.units.C_esp_GLP_internal;
    audit.C_solar_units = params_cost.units.C_solar_internal;
    audit.W_comp_kW = W_comp;

    txtFile = fullfile(logsDir, "AUD_COST_TRACE_AB_v09.txt");
    csvFile = fullfile(tablesDir, "AUD_COST_TRACE_AB_v09.csv");
    matFile = fullfile(comparisonsDir, "AUD_COST_TRACE_AB_v09.mat");

    writetable(T, csvFile);
    save(matFile, "audit", "params_cost", "T");

    fid = fopen(txtFile, "w");
    fprintf(fid, "AUD_COST_TRACE_AB_v09\n\n");
    fprintf(fid, "dictamen: %s\n", dictamen);
    fprintf(fid, "tolerance: %.3e\n", tolerance);
    fprintf(fid, "max_relative_error: %.16e\n\n", max_relative_error);

    fprintf(fid, "INTERNAL COST UNITS\n");
    fprintf(fid, "C_kWh: %.16g [%s]\n", C_kWh, audit.C_kWh_units);
    fprintf(fid, "C_esp_GLP: %.16g [%s]\n", C_esp_GLP, audit.C_esp_GLP_units);
    fprintf(fid, "C_solar: %.16g [%s]\n", C_solar, audit.C_solar_units);
    fprintf(fid, "exchange_rate_MXN_per_USD: %.16g\n", audit.exchange_rate_MXN_per_USD);
    fprintf(fid, "W_comp: %.16g [kW]\n\n", W_comp);

    fprintf(fid, "DENOMINATOR\n");
    fprintf(fid, "water_removed_kg = %s\n", audit.denominator);
    fprintf(fid, "denominator_units: %s\n\n", audit.denominator_units);

    fprintf(fid, "HISTORICAL FORMULA\n");
    fprintf(fid, "f_old = (W_comp*dry_time*C_kWh + Q_aux_tot*C_esp_GLP + Irradiacion*C_solar) / ((Mi-M)*md)\n\n");

    fprintf(fid, "OUTPUT FILES\n");
    fprintf(fid, "CSV: %s\n", csvFile);
    fprintf(fid, "MAT: %s\n", matFile);
    fclose(fid);

    audit.output_txt = string(txtFile);
    audit.output_csv = string(csvFile);
    audit.output_mat = string(matFile);
end
