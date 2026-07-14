function test_status = test_case_base_v05()
%TEST_CASE_BASE_V05 Integration test for the legacy base script.
%
% This test runs run_opt_tunel_mod2.mlx. It may be slow because that script
% sweeps multiple temperatures and recirculation ratios.
%
% TEST-B-002:
%   Robustly initializes test_status.errors before any catch/append.
%
% This test does NOT run run_opt_GA.mlx.

    rootDir = setup_v05_paths();

    test_status = struct();
    test_status.created_at = datetime("now");
    test_status.created_by_function = "test_case_base_v05";
    test_status.rootDir = string(rootDir);
    test_status.status = "NOT_RUN";
    test_status.errors = {};
    test_status.warnings = {};
    test_status.required_variables = ["Q_aux_tot","dry_time","M","MR","Irradiacion"];

    logsDir = fullfile(rootDir, "06_outputs", "logs");
    if ~exist(logsDir, "dir")
        mkdir(logsDir);
    end

    diaryFile = fullfile(logsDir, ...
        "TEST_CASE_BASE_V05_" + string(datestr(now,"yyyymmdd_HHMMSS")) + ".txt");

    diary(diaryFile);

    try
        disp("=== PATH CHECK ===")
        which opt_tunel_mod2 -all
        which tunel_mod2 -all
        which preallocating -all
        which humrat_AirH2O -all
        which Mapeo4_temp100621.txt -all

        disp("=== RUN LEGACY BASE SCRIPT ===")
        run(fullfile(rootDir,'03_original_model','01_active_original','run_opt_tunel_mod2.mlx'));

        missing = strings(0,1);

        for k = 1:numel(test_status.required_variables)
            varname = test_status.required_variables(k);
            existsFlag = evalin("base", "exist('" + varname + "','var')");
            if ~existsFlag
                missing(end+1,1) = varname;
            end
        end

        if isempty(missing)
            test_status.status = "PASS";
        else
            test_status.status = "FAIL";
            test_status.errors{end+1} = char("Missing required variables: " + strjoin(missing,", "));
        end

    catch ME
        test_status.status = "FAIL";
        test_status.errors{end+1} = getReport(ME, "extended", "hyperlinks", "off");
    end

    test_status.diaryFile = string(diaryFile);
    diary off

    save(fullfile(logsDir, ...
        "TEST_CASE_BASE_V05_" + string(datestr(now,"yyyymmdd_HHMMSS")) + ".mat"), ...
        "test_status");
end
