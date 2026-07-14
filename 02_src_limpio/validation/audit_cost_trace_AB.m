function audit = audit_cost_trace_AB()
%AUDIT_COST_TRACE_AB Template for local A/B test against historical opt_fun.
%
% Requires local MATLAB execution and the original opt_fun call signature.
% Does not modify opt_fun and does not change results.
%
% Acceptance criterion:
%   relative error <= 1e-10

    rootDir = setup_v05_paths();
    params_cost = build_cost_params_historical();

    audit.created_at = datetime("now");
    audit.created_by_function = "audit_cost_trace_AB";
    audit.status = "NOT_EXECUTED_TEMPLATE";
    audit.mode = "REQUIRES_LOCAL_MATLAB_EXECUTION";
    audit.relative_error_tolerance = 1e-10;

    audit.internal_cost_unit = "USD";
    audit.denominator = "(Mi - M) * md";
    audit.exchange_rate_MXN_per_USD = params_cost.exchange_rate_MXN_per_USD;
    audit.C_electricity_USD_per_kWh = params_cost.C_electricity_USD_per_kWh;
    audit.C_GLP_USD_per_MJ = params_cost.C_GLP_USD_per_MJ;
    audit.C_solar_USD_per_MJ = params_cost.C_solar_USD_per_MJ;

    logsDir = fullfile(rootDir,"06_outputs","logs");
    tablesDir = fullfile(rootDir,"06_outputs","tables");
    comparisonsDir = fullfile(rootDir,"06_outputs","comparisons");

    if ~exist(logsDir,"dir"), mkdir(logsDir); end
    if ~exist(tablesDir,"dir"), mkdir(tablesDir); end
    if ~exist(comparisonsDir,"dir"), mkdir(comparisonsDir); end

    stamp = string(datestr(now,"yyyymmdd"));

    txtFile = fullfile(logsDir, "AUD_COST_TRACE_AB_" + stamp + ".txt");
    csvFile = fullfile(tablesDir, "AUD_COST_TRACE_AB_" + stamp + ".csv");
    matFile = fullfile(comparisonsDir, "AUD_COST_TRACE_AB_" + stamp + ".mat");

    T = table("NOT_EXECUTED_TEMPLATE", NaN, NaN, NaN, ...
        "VariableNames", ["dictamen","f_old","f_trace","relative_error"]);

    writetable(T, csvFile);
    save(matFile, "audit", "params_cost", "T");

    fid = fopen(txtFile, "w");
    fprintf(fid, "AUD_COST_TRACE_AB\n\n");
    fprintf(fid, "status: %s\n", audit.status);
    fprintf(fid, "mode: %s\n", audit.mode);
    fprintf(fid, "internal_cost_unit: %s\n", audit.internal_cost_unit);
    fprintf(fid, "denominator: %s\n", audit.denominator);
    fprintf(fid, "exchange_rate_MXN_per_USD: %.10f\n", audit.exchange_rate_MXN_per_USD);
    fprintf(fid, "C_electricity_USD_per_kWh: %.10f\n", audit.C_electricity_USD_per_kWh);
    fprintf(fid, "C_GLP_USD_per_MJ: %.10f\n", audit.C_GLP_USD_per_MJ);
    fprintf(fid, "C_solar_USD_per_MJ: %.10f\n", audit.C_solar_USD_per_MJ);
    fprintf(fid, "max_relative_error: NaN\n");
    fprintf(fid, "dictamen: NOT_EXECUTED_TEMPLATE\n");
    fprintf(fid, "\nTo complete this audit, implement the historical opt_fun calls for several O cases.\n");
    fclose(fid);

    audit.output_txt = string(txtFile);
    audit.output_csv = string(csvFile);
    audit.output_mat = string(matFile);
end
