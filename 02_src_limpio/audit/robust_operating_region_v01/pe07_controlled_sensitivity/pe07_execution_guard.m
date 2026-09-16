function out=pe07_execution_guard(action,varargin)
% Fail-closed guards and write primitives for PE07. No model calls occur here.
assert(ischar(action) || (isstring(action) && isscalar(action)), ...
    'PE07:GuardAction','Guard action must be scalar text.');
switch char(action)
    case 'validate_config'
        out=validate_config(varargin{:});
    case 'reserve_root'
        out=reserve_root(varargin{:});
    case 'baseline_gate'
        out=baseline_gate(varargin{:});
    case 'classify_result'
        out=classify_result(varargin{:});
    case 'write_json_once'
        write_json_once(varargin{:}); out=true;
    case 'write_text_once'
        write_text_once(varargin{:}); out=true;
    case 'verify_lock'
        out=verify_lock(varargin{:});
    case 'file_hash'
        out=file_hash(varargin{:});
    otherwise
        error('PE07:GuardAction','Unsupported guard action: %s',char(action));
end
end

function plan=validate_config(cfg,repoRoot,executionRoot)
assert(isstruct(cfg),'PE07:Config','Decoded config struct required.');
assert(strcmp(cfg.design_version,'v1.1') && ...
    strcmp(cfg.campaign_id,'ROR_PE07_CONTROLLED_SENSITIVITY_V01') && ...
    strcmp(cfg.role,'CONTROLLED_LOCAL_MODEL_SENSITIVITY') && ...
    strcmp(cfg.method,'ONE_FACTOR_AT_A_TIME'), ...
    'PE07:Identity','Wrong PE07 identity.');
assert(strcmp(cfg.objective_entry_point, ...
    'objective_productive_corrected_v96j_triobjective_CO2_fix1') && ...
    strcmp(cfg.mode_operation,'hybrid'),'PE07:EntryPoint','Wrong entry point.');
assert(strcmp(cfg.upstream_canonical_baseline_head, ...
    '17cc812780a92bb073bffbfab288c0f51986dea1'), ...
    'PE07:UpstreamHead','Wrong upstream canonical baseline.');
assert(strcmp(cfg.runtime_head_policy, ...
    'FINAL_AUTHORIZED_INFRASTRUCTURE_HEAD_FROM_EXECUTION_AUTHORIZATION'), ...
    'PE07:RuntimeHead','Runtime HEAD must not be hardcoded to upstream baseline.');

names={cfg.variables.name};
assert(isequal(names,{'m_max','T_min','r_div2','t_rec_ini'}), ...
    'PE07:Variables','Variable order mismatch.');
lb=[cfg.variables.lower]; ub=[cfg.variables.upper];
small=[cfg.variables.delta_small]; large=[cfg.variables.delta_large];
assert(isequal(lb,[0.07 45 0 0]) && isequal(ub,[0.20 70 0.99 19]) && ...
    isequal(small,[0.00325 0.625 0.02475 0.475]) && ...
    isequal(large,[0.00650 1.25 0.04950 0.950]), ...
    'PE07:Variables','Bounds or perturbations mismatch.');

assert(numel(cfg.anchors)==3 && ...
    isequal({cfg.anchors.anchor_id},{'N21','N11','N19'}) && ...
    isequal([cfg.anchors.baseline_order],[1 2 3]), ...
    'PE07:Anchors','Anchor identity/order mismatch.');
assert(numel(cfg.conditions)==48 && cfg.budget.structural_perturbations==48 && ...
    cfg.budget.preclassified_out_of_domain==1 && ...
    cfg.budget.valid_perturbations==47 && cfg.budget.baseline_replays==3 && ...
    cfg.budget.max_executable==50 && cfg.budget.absolute_structural_cap==51, ...
    'PE07:Budget','Frozen budget mismatch.');
assert(cfg.budget.baseline_replays+cfg.budget.valid_perturbations<= ...
    cfg.budget.max_executable && cfg.budget.max_executable<= ...
    cfg.budget.absolute_structural_cap,'PE07:Budget','Budget cap violated.');

levels={{'minus','large',-1},{'minus','small',-1}, ...
    {'plus','small',1},{'plus','large',1}};
outCount=0; validCount=0; seen=cell(1,48); k=0;
for a=1:3
    for v=1:4
        for q=1:4
            k=k+1; c=cfg.conditions(k); level=levels{q};
            expectedId=sprintf('P%03d_%s_%s_%s_%s',k, ...
                cfg.anchors(a).anchor_id,names{v},level{1},level{2});
            magnitude=small(v); if strcmp(level{2},'large'), magnitude=large(v); end
            delta=level{3}*magnitude;
            expected=cfg.anchors(a).x(v)+delta;
            inDomain=expected>=lb(v) && expected<=ub(v);
            assert(c.execution_order==k && strcmp(c.condition_id,expectedId) && ...
                strcmp(c.anchor_id,cfg.anchors(a).anchor_id) && ...
                strcmp(c.variable,names{v}) && strcmp(c.direction,level{1}) && ...
                strcmp(c.magnitude,level{2}) && isequal(c.delta,delta) && ...
                isequal(c.proposed_value,expected) && isequal(c.evaluate,inDomain), ...
                'PE07:ConditionMatrix','Condition mismatch at order %d.',k);
            if inDomain
                assert(strcmp(c.domain_status,'VALID'),'PE07:Domain','Wrong valid status.');
                validCount=validCount+1;
            else
                assert(strcmp(c.domain_status,'OUT_OF_DOMAIN_PREDEFINED_PERTURBATION'), ...
                    'PE07:Domain','Wrong OOB status.'); outCount=outCount+1;
            end
            seen{k}=c.condition_id;
        end
    end
end
assert(numel(unique(seen))==48 && outCount==1 && validCount==47, ...
    'PE07:ConditionMatrix','Condition counts/IDs mismatch.');
oob=cfg.conditions(~[cfg.conditions.evaluate]);
assert(numel(oob)==1 && strcmp(oob.condition_id,'P001_N21_m_max_minus_large') && ...
    isequal(oob.proposed_value,0.06756347508351872), ...
    'PE07:Domain','Unexpected predefined OOB condition.');

assert(strcmp(file_hash(fullfile(repoRoot,cfg.protocol_path)),cfg.protocol_sha256), ...
    'PE07:ProtocolHash','Protocol hash mismatch.');
assert(strcmp(file_hash(fullfile(repoRoot,cfg.productive_source_lock_path)), ...
    cfg.productive_source_lock_sha256),'PE07:ProductiveLock','Productive lock mismatch.');
assert(strcmp(file_hash(fullfile(repoRoot,cfg.primary_n_pool.path)), ...
    cfg.primary_n_pool.sha256),'PE07:PrimaryHash','N_POOL hash mismatch.');
verify_anchors(cfg,repoRoot);

expectedRoot=fullfile(repoRoot,cfg.execution_root);
assert(strcmpi(canonical(executionRoot),canonical(expectedRoot)), ...
    'PE07:Root','Execution root differs from frozen path.');
primaryRoot=fullfile(repoRoot,'05_runs','robust_operating_region_v01', ...
    'ROR_PRIMARY_20260907_REAUTHORIZED');
assert(~startsWith([lower(canonical(executionRoot)) filesep], ...
    [lower(canonical(primaryRoot)) filesep]), ...
    'PE07:PrimaryWrite','Execution under PRIMARY is prohibited.');
assert(~isfolder(executionRoot) && ~isfile(executionRoot), ...
    'PE07:RootExists','Execution root already exists; fail closed.');

plan=struct('status','PASS','campaign_id',cfg.campaign_id, ...
    'anchors_full_precision_verified',true,'structural_conditions',48, ...
    'out_of_domain_conditions',1,'valid_perturbations',47, ...
    'max_executable_evaluations',50,'execution_root',executionRoot);
end

function verify_anchors(cfg,repoRoot)
stored=load(fullfile(repoRoot,cfg.primary_n_pool.path),'X','F','provenance_json');
provenance=jsondecode(stored.provenance_json);
for k=1:numel(cfg.anchors)
    a=cfg.anchors(k); row=a.n_pool_row; p=provenance(row);
    assert(isequal(stored.X(row,:),double(a.x(:)')) && ...
        isequal(stored.F(row,:),double(a.f(:)')) && p.seed==a.seed && ...
        p.row==a.source_row && strcmp(p.source,a.source), ...
        'PE07:AnchorIdentity','Stored anchor mismatch: %s',a.anchor_id);
    observed=[p.detail.objectives.MR_final,p.detail.cost.water_removed_kg, ...
        p.detail.cost.Q_aux_useful_MJ,p.detail.cost.LPG_fuel_input_MJ, ...
        stored.F(row,1),stored.F(row,2),stored.F(row,3)];
    expected=[a.expected.MR,a.expected.W,a.expected.Q_aux_useful_MJ, ...
        a.expected.LPG_fuel_input_MJ,a.expected.f1,a.expected.f2,a.expected.f3];
    assert(isequal(observed,expected),'PE07:AnchorDetail', ...
        'Stored decomposition mismatch: %s',a.anchor_id);
    assert(strcmp(file_hash(fullfile(repoRoot,a.primary_output_path)), ...
        a.primary_output_sha256) && ...
        strcmp(file_hash(fullfile(repoRoot,a.evaluation_details_path)), ...
        a.evaluation_details_sha256),'PE07:AnchorHash', ...
        'Anchor source hash mismatch: %s',a.anchor_id);
end
end

function result=reserve_root(path)
assert(~isfolder(path) && ~isfile(path),'PE07:RootExists', ...
    'Execution root already exists; fail closed.');
parent=fileparts(path);
assert(~isfile(parent),'PE07:ParentCreate','Execution-root parent is a file.');
if ~isfolder(parent)
    [created,message]=mkdir(parent);
    assert(created && isfolder(parent),'PE07:ParentCreate', ...
        'Cannot create parent %s: %s',parent,message);
end
reservation=java.io.File(path);
assert(reservation.mkdir(),'PE07:RootReservation', ...
    'Cannot exclusively reserve execution root: %s',path);
result=struct('status','RESERVED','path',path);
end

function gate=baseline_gate(matches,validPerturbations)
assert(islogical(matches) && isequal(size(matches),[1 3]), ...
    'PE07:BaselineGate','Exactly three logical baseline results required.');
assert(validPerturbations==47,'PE07:Budget','Valid perturbation count mismatch.');
gate=struct('baseline_pass_count',sum(matches),'all_pass',all(matches), ...
    'perturbation_evaluations_authorized',0,'status','BASELINE_REPLAY_MISMATCH');
if all(matches)
    gate.perturbation_evaluations_authorized=47;
    gate.status='BASELINE_REPLAY_PASS';
end
end

function classification=classify_result(record,cfg)
reasons={};
if isfield(record,'error_identifier') && ~isempty(record.error_identifier)
    reasons{end+1}='CAUGHT_EVALUATION_ERROR'; %#ok<AGROW>
end
if ~isfield(record,'x') || numel(record.x)~=4 || ...
        ~isreal(record.x) || any(~isfinite(record.x))
    reasons{end+1}='INVALID_INPUT_VECTOR'; %#ok<AGROW>
else
    lb=[cfg.variables.lower]; ub=[cfg.variables.upper];
    if any(record.x(:)'<lb) || any(record.x(:)'>ub)
        reasons{end+1}='OUT_OF_BOUNDS'; %#ok<AGROW>
    end
end
if isfield(record,'f') && isequal(double(record.f(:)'),double(cfg.penalty_vector(:)'))
    reasons{end+1}='PENALTY_VECTOR'; %#ok<AGROW>
end
statusFields={'status','execution_status'};
for k=1:numel(statusFields)
    if isfield(record,statusFields{k})
        value=char(string(record.(statusFields{k})));
        if any(strcmp(value,cellstr(string(cfg.invalid_statuses))))
            reasons{end+1}=['STATUS_' value]; %#ok<AGROW>
        end
    end
end
required={'MR','W','Q_aux_useful_MJ','LPG_fuel_input_MJ','f1','f2','f3'};
if ~isfield(record,'responses')
    reasons{end+1}='REQUIRED_RESPONSES_MISSING'; %#ok<AGROW>
else
    for k=1:numel(required)
        if ~isfield(record.responses,required{k})
            reasons{end+1}=['MISSING_' required{k}]; %#ok<AGROW>
        else
            value=record.responses.(required{k});
            if ~(isnumeric(value) && isscalar(value) && isreal(value) && isfinite(value))
                reasons{end+1}=['NONFINITE_OR_NONREAL_' required{k}]; %#ok<AGROW>
            end
        end
    end
end
reasons=unique(reasons,'stable');
classification=struct('invalid',~isempty(reasons),'reasons',{reasons}, ...
    'retained_in_audit',true,'eligible_for_finite_difference',isempty(reasons));
end

function result=verify_lock(root,lock)
assert(isstruct(lock) && ~isempty(lock),'PE07:SourceLock','Source lock required.');
for k=1:numel(lock)
    path=fullfile(root,lock(k).path);
    assert(isfile(path) && strcmp(file_hash(path),lock(k).sha256), ...
        'PE07:SourceLock','Source-lock mismatch: %s',lock(k).path);
end
result=struct('status','PASS','entries',numel(lock));
end

function write_json_once(path,value)
assert(~isfile(path),'PE07:NoOverwrite','File already exists: %s',path);
parent=fileparts(path); assert(isfolder(parent),'PE07:WriteParent','Parent missing.');
tmp=[tempname(parent) '.json'];
fid=fopen(tmp,'w','n','UTF-8'); assert(fid>=0,'PE07:Write','Cannot create temp JSON.');
cleanup=onCleanup(@()close_if_open(fid));
fprintf(fid,'%s\n',jsonencode(value)); fclose(fid); fid=-1;
[ok,message]=movefile(tmp,path); assert(ok,'PE07:Write','Atomic publish failed: %s',message);
clear cleanup
end

function write_text_once(path,value)
assert(~isfile(path),'PE07:NoOverwrite','File already exists: %s',path);
parent=fileparts(path); assert(isfolder(parent),'PE07:WriteParent','Parent missing.');
tmp=[tempname(parent) '.txt'];
fid=fopen(tmp,'w','n','UTF-8'); assert(fid>=0,'PE07:Write','Cannot create temp text.');
cleanup=onCleanup(@()close_if_open(fid));
fprintf(fid,'%s',value); fclose(fid); fid=-1;
[ok,message]=movefile(tmp,path); assert(ok,'PE07:Write','Atomic publish failed: %s',message);
clear cleanup
end

function close_if_open(fid)
if fid>=0, try fclose(fid); catch, end, end
end

function value=canonical(path)
value=char(java.io.File(path).getCanonicalPath());
end

function h=file_hash(path)
fid=fopen(path,'rb'); assert(fid>=0,'PE07:File','Cannot read %s',path);
cleanup=onCleanup(@()fclose(fid));
md=java.security.MessageDigest.getInstance('SHA-256');
while ~feof(fid), md.update(fread(fid,1048576,'*uint8')); end
h=upper(reshape(dec2hex(typecast(md.digest(),'uint8'),2)',1,[]));
end
