function [state, options, optchanged] = ga_history_output_controlado(options, state, flag, params)
%GA_HISTORY_OUTPUT_CONTROLADO Passive OutputFcn for gamultiobj.
    persistent history
    optchanged = false;
    switch string(flag)
        case "init"
            history = init_history(params);
        case "iter"
            if isempty(history), history = init_history(params); end
            history = append_history(history,state,params);
        case "done"
            if isempty(history), history = init_history(params); end
            history = append_history(history,state,params);
            save_history(history,params);
    end
end
function h=init_history(params)
    h.meta.run_id=string(params.run_id); h.meta.mode_operation=string(params.operation.mode_operation); h.meta.created_at=datetime("now");
    h.generation=[]; h.timestamp=strings(0,1); h.population={}; h.scores={}; h.summary=table();
end
function h=append_history(h,state,params)
    gen=state.Generation;
    if ~isempty(h.generation) && h.generation(end)==gen, return; end
    pop=state.Population; scores=state.Score;
    n_nan=sum(isnan(scores),"all"); n_inf=sum(isinf(scores),"all");
    min_obj=colstat(scores,"min"); mean_obj=colstat(scores,"mean"); max_obj=colstat(scores,"max");
    h.generation(end+1,1)=gen; h.timestamp(end+1,1)=string(datetime("now"));
    h.population{end+1,1}=pop; h.scores{end+1,1}=scores;
    row=table(gen,string(datetime("now")),size(pop,1),size(pop,2),size(scores,2),n_nan,n_inf,{min_obj},{mean_obj},{max_obj},'VariableNames',["generation","timestamp","n_population","n_variables","n_objectives","n_nan_scores","n_inf_scores","min_objective","mean_objective","max_objective"]);
    h.summary=[h.summary;row];
end
function out=colstat(X,kind)
    if isempty(X), out=[]; return; end
    out=nan(1,size(X,2));
    for j=1:size(X,2)
        c=X(:,j); c=c(~isnan(c));
        if isempty(c), out(j)=NaN; elseif kind=="min", out(j)=min(c); elseif kind=="mean", out(j)=mean(c); else, out(j)=max(c); end
    end
end
function save_history(h,params)
    folder=fullfile(params.outputs.output_folder,"01_ga_outputs"); if ~exist(folder,"dir"), mkdir(folder); end
    save(fullfile(folder,string(params.run_id)+"_ga_history.mat"),"h");
    writetable(h.summary,fullfile(folder,string(params.run_id)+"_convergence_summary.csv"));
end
