function audit = audit_cost_trace_AB(project_root)
%AUDIT_COST_TRACE_AB Template for local A/B test against historical opt_fun.
    if nargin<1, project_root=pwd; end
    addpath(genpath(fullfile(project_root,"02_src_limpio")));
    audit.mode="REQUIRES_LOCAL_MATLAB_EXECUTION";
    audit.status="NOT_EXECUTED_TEMPLATE";
    audit.relative_error_tolerance=1e-10;
    audit.params_cost=build_cost_params_historical();
    logs=fullfile(project_root,"06_outputs","logs"); if ~exist(logs,"dir"), mkdir(logs); end
    stamp=datestr(now,"yyyymmdd");
    audit.output_txt=fullfile(logs,"AUD_COST_TRACE_AB_"+stamp+".txt");
    fid=fopen(audit.output_txt,"w");
    fprintf(fid,"AUD_COST_TRACE_AB\nstatus: NOT_EXECUTED_TEMPLATE\nNo PASS/FAIL because opt_fun was not executed.\n");
    fprintf(fid,"exchange_rate_MXN_per_USD: %.6f\n",audit.params_cost.exchange_rate_MXN_per_USD);
    fprintf(fid,"denominator: %s\n",audit.params_cost.denominator_definition);
    fclose(fid);
end
