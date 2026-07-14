function params_mode = build_mode_params(params_base, mode_operation)
%BUILD_MODE_PARAMS Derive mode-specific params from params_base.
    mode_operation = string(mode_operation);
    if ~any(mode_operation == ["solar","gasLP","hybrid"])
        error("Invalid mode_operation. Use solar, gasLP or hybrid.");
    end
    params_mode = params_base;
    params_mode.operation.mode_operation = mode_operation;
    switch mode_operation
        case "solar"
            params_mode.operation.irradiance_rule = "use_raw";
            params_mode.operation.auxiliary_rule = "disable_auxiliary";
            params_mode.operation.Q_aux_enabled = false;
            params_mode.model.allow_incomplete_drying = true;
        case "gasLP"
            params_mode.operation.irradiance_rule = "force_zero";
            params_mode.operation.auxiliary_rule = "allow_auxiliary";
            params_mode.operation.Q_aux_enabled = true;
            params_mode.model.allow_incomplete_drying = false;
        case "hybrid"
            params_mode.operation.irradiance_rule = "use_raw";
            params_mode.operation.auxiliary_rule = "allow_auxiliary";
            params_mode.operation.Q_aux_enabled = true;
            params_mode.model.allow_incomplete_drying = false;
    end
    timestamp = datestr(now,"yyyymmdd_HHMMSS");
    params_mode.run_id = sprintf("%s_%s_%s_%s", params_base.project.product_label, mode_operation, params_base.project.version, timestamp);
    params_mode.project.run_id = params_mode.run_id;
    params_mode.project.timestamp = timestamp;
    if isfield(params_base,"campaign") && isfield(params_base.campaign,"root_folder")
        params_mode.outputs.output_folder = fullfile(params_base.campaign.root_folder, mode_operation);
    else
        params_mode.outputs.output_folder = fullfile(params_base.outputs.root_folder, params_mode.run_id);
    end
    params_mode.meta.created_by_function = "build_mode_params";
    params_mode.meta.created_at = datetime("now");
end
