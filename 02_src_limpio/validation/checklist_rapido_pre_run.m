function status = checklist_rapido_pre_run(params)
%CHECKLIST_RAPIDO_PRE_RUN Conservative pre-run validation.
    status.run_id = string(params.run_id);
    status.mode_operation = string(params.operation.mode_operation);
    status.estado = "APTO";
    status.errores_criticos = {};
    status.advertencias = {};
    status.items_ok = {};
    status = check_mode(params,status);
    status = check_ga(params,status);
    status = check_product(params,status);
    status = check_pending(params,status);
    if ~isempty(status.errores_criticos)
        status.estado = "NO APTO";
    elseif ~isempty(status.advertencias)
        status.estado = "APTO SOLO PARA PRUEBA";
    end
    status.summary.n_errors = numel(status.errores_criticos);
    status.summary.n_warnings = numel(status.advertencias);
    status.summary.timestamp = datetime("now");
end
function status=check_mode(p,status)
    m=string(p.operation.mode_operation);
    if ~any(m==["solar","gasLP","hybrid"]), status=err(status,"Modo inválido."); return; end
    if m=="solar" && p.operation.Q_aux_enabled~=false, status=err(status,"Solar requiere Q_aux_enabled=false."); end
    if (m=="gasLP" || m=="hybrid") && p.operation.Q_aux_enabled~=true, status=err(status,"gasLP/hybrid requieren Q_aux_enabled=true."); end
    if m=="solar", status=warn(status,"Modo solar puede no alcanzar criterio sin gas LP."); end
end
function status=check_ga(p,status)
    if numel(p.ga.lb)~=4 || numel(p.ga.ub)~=4 || any(p.ga.lb>=p.ga.ub), status=err(status,"lb/ub inválidos."); end
end
function status=check_product(p,status)
    if p.product.W0<=0 || p.product.m_i<=p.product.m_f, status=err(status,"Producto/humedad inválidos."); end
end
function status=check_pending(p,status)
    if string(p.model.stop_criterion)=="pending", status=err(status,"model.stop_criterion pendiente."); end
    if isempty(p.model.stop_threshold), status=err(status,"model.stop_threshold pendiente."); end
    if isempty(p.weather.I_column) && any(string(p.operation.mode_operation)==["solar","hybrid"]), status=err(status,"weather.I_column obligatoria para solar/hybrid."); end
    if isempty(p.cost.C_GLP_MXN_per_MJ), status=warn(status,"cost.C_GLP_MXN_per_MJ pendiente."); end
    if isempty(p.cost.exchange_rate_MXN_per_USD), status=warn(status,"cost.exchange_rate_MXN_per_USD pendiente."); end
    if isempty(p.environment.EF_GLP), status=warn(status,"environment.EF_GLP pendiente."); end
    if isempty(p.environment.EF_elec), status=warn(status,"environment.EF_elec pendiente."); end
end
function status=err(status,msg), status.errores_criticos{end+1}=char(msg); end
function status=warn(status,msg), status.advertencias{end+1}=char(msg); end
