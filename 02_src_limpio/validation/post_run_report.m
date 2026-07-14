function post_status = post_run_report(params, results)
%POST_RUN_REPORT Conservative post-run validation.
    post_status.run_id=string(params.run_id); post_status.mode_operation=string(params.operation.mode_operation);
    post_status.estado="APTO PARA ANALISIS"; post_status.errors={}; post_status.warnings={}; post_status.items_ok={};
    post_status.flags.is_valid_for_article=false; post_status.flags.valid_for_comparison=false; post_status.flags.valid_for_progress_analysis=false; post_status.flags.stop_criterion_reached=false; post_status.flags.incomplete_drying=false;
    if ~isfield(results,"meta") || string(results.meta.run_id)~=string(params.run_id), post_status=err(post_status,"run_id inconsistente."); end
    if isempty(results.ga.x), post_status=warn(post_status,"results.ga.x vacío."); end
    if isempty(results.ga.fval), post_status=warn(post_status,"results.ga.fval vacío."); end
    if isempty(results.energy.dry_time), post_status=warn(post_status,"dry_time vacío."); elseif results.energy.dry_time<=0, post_status=err(post_status,"dry_time debe ser positivo."); end
    if isempty(results.moisture.M_final), post_status=warn(post_status,"M_final vacío."); elseif results.moisture.M_final<0, post_status=err(post_status,"M_final negativo."); end
    if isfield(results.moisture,"stop_criterion_reached") && results.moisture.stop_criterion_reached
        post_status.flags.stop_criterion_reached=true;
    elseif string(params.operation.mode_operation)=="solar" && string(results.moisture.stop_reason)=="time_horizon_reached" && results.moisture.allow_incomplete_drying
        post_status.flags.incomplete_drying=true; post_status.flags.valid_for_progress_analysis=true; post_status=warn(post_status,"Solar truncado por horizonte.");
    else
        post_status=warn(post_status,"Criterio de paro no alcanzado.");
    end
    if ~isempty(post_status.errors), post_status.estado="NO VALIDO";
    elseif post_status.flags.incomplete_drying, post_status.estado="APTO CON SECADO INCOMPLETO"; post_status.flags.is_valid_for_article=true; post_status.flags.valid_for_comparison=true;
    elseif ~post_status.flags.stop_criterion_reached, post_status.estado="APTO SOLO PARA DIAGNOSTICO";
    elseif ~isempty(post_status.warnings), post_status.estado="APTO CON ADVERTENCIAS"; post_status.flags.is_valid_for_article=true; post_status.flags.valid_for_comparison=true;
    else, post_status.estado="APTO PARA ANALISIS"; post_status.flags.is_valid_for_article=true; post_status.flags.valid_for_comparison=true; end
    post_status.report_file=write_report(params,results,post_status);
end
function s=err(s,msg), s.errors{end+1}=char(msg); end
function s=warn(s,msg), s.warnings{end+1}=char(msg); end
function file=write_report(params,results,s)
    folder=fullfile(params.outputs.output_folder,"04_logs"); if ~exist(folder,"dir"), mkdir(folder); end
    file=fullfile(folder,string(params.run_id)+"_post_run_report.md");
    fid=fopen(file,"w"); fprintf(fid,"# Post-run report\n\n- run_id: %s\n- estado: %s\n",string(params.run_id),string(s.estado)); fclose(fid);
end
