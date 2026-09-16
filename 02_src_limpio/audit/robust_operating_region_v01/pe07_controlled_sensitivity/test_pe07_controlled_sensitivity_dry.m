function report=test_pe07_controlled_sensitivity_dry()
% Infrastructure-only validation. Never calls production objective/model.
here=fileparts(mfilename('fullpath'));
repoRoot=fileparts(fileparts(fileparts(fileparts(here))));
cfg=jsondecode(fileread(fullfile(here,'pe07_controlled_sensitivity_config.json')));
realRoot=fullfile(repoRoot,cfg.execution_root);
assert(~isfolder(realRoot) && ~isfile(realRoot),'PE07:DryRealRoot', ...
    'Real PE07 execution root must remain absent.');

plan=pe07_execution_guard('validate_config',cfg,repoRoot,realRoot);
assert(strcmp(plan.status,'PASS') && plan.anchors_full_precision_verified && ...
    plan.structural_conditions==48 && plan.out_of_domain_conditions==1 && ...
    plan.valid_perturbations==47 && plan.max_executable_evaluations==50);

assert(numel(cfg.conditions)==48 && numel(unique({cfg.conditions.condition_id}))==48);
assert(isequal([cfg.conditions.execution_order],1:48));
assert(sum([cfg.conditions.evaluate])==47);
oob=cfg.conditions(~[cfg.conditions.evaluate]);
assert(numel(oob)==1 && strcmp(oob.condition_id,'P001_N21_m_max_minus_large') && ...
    strcmp(oob.domain_status,'OUT_OF_DOMAIN_PREDEFINED_PERTURBATION'));
assert(cfg.budget.baseline_replays+cfg.budget.valid_perturbations==50 && ...
    cfg.budget.max_executable==50 && cfg.budget.absolute_structural_cap==51);

passGate=pe07_execution_guard('baseline_gate',[true true true],47);
assert(passGate.all_pass && passGate.baseline_pass_count==3 && ...
    passGate.perturbation_evaluations_authorized==47 && ...
    strcmp(passGate.status,'BASELINE_REPLAY_PASS'));
for mismatch={[true true false],[true false false],[false false false]}
    blocked=pe07_execution_guard('baseline_gate',mismatch{1},47);
    assert(~blocked.all_pass && blocked.perturbation_evaluations_authorized==0 && ...
        strcmp(blocked.status,'BASELINE_REPLAY_MISMATCH'));
end

good=synthetic_record(cfg.anchors(1).x,[1 2 3],'OK','OK',false);
classification=pe07_execution_guard('classify_result',good,cfg);
assert(~classification.invalid && classification.eligible_for_finite_difference && ...
    classification.retained_in_audit);
penalty=good; penalty.f=[1000 1e6 1e6];
classification=pe07_execution_guard('classify_result',penalty,cfg);
assert(classification.invalid && ~classification.eligible_for_finite_difference && ...
    any(strcmp(classification.reasons,'PENALTY_VECTOR')));
badStatus=good; badStatus.execution_status='PENALIZED_INVALID_CO2';
classification=pe07_execution_guard('classify_result',badStatus,cfg);
assert(classification.invalid && classification.retained_in_audit);
badResponse=good; badResponse.responses.W=Inf;
classification=pe07_execution_guard('classify_result',badResponse,cfg);
assert(classification.invalid && ~classification.eligible_for_finite_difference);
oobRecord=good; oobRecord.x(1)=0.069;
classification=pe07_execution_guard('classify_result',oobRecord,cfg);
assert(classification.invalid && any(strcmp(classification.reasons,'OUT_OF_BOUNDS')));

absentBase=tempname; absentRoot=fullfile(absentBase,'parent','campaign');
cleanupAbsent=onCleanup(@()remove_tree(absentBase));
pe07_execution_guard('reserve_root',absentRoot);
assert(isfolder(absentRoot));
must_fail(@()pe07_execution_guard('reserve_root',absentRoot),'PE07:RootExists');

presentBase=tempname; mkdir(presentBase); cleanupPresent=onCleanup(@()remove_tree(presentBase));
presentParent=fullfile(presentBase,'parent'); mkdir(presentParent);
presentRoot=fullfile(presentParent,'campaign');
pe07_execution_guard('reserve_root',presentRoot); assert(isfolder(presentRoot));
must_fail(@()pe07_execution_guard('reserve_root',presentRoot),'PE07:RootExists');

collision=tempname; mkdir(collision); cleanupCollision=onCleanup(@()remove_tree(collision));
must_fail(@()pe07_execution_guard('reserve_root',collision),'PE07:RootExists');

fileParent=tempname; mkdir(fileParent); cleanupFile=onCleanup(@()remove_tree(fileParent));
blockedParent=fullfile(fileParent,'parent'); fid=fopen(blockedParent,'w');
assert(fid>=0); fclose(fid);
must_fail(@()pe07_execution_guard('reserve_root',fullfile(blockedParent,'campaign')), ...
    'PE07:ParentCreate');

writeBase=tempname; mkdir(writeBase); cleanupWrite=onCleanup(@()remove_tree(writeBase));
oncePath=fullfile(writeBase,'once.json');
pe07_execution_guard('write_json_once',oncePath,struct('status','PASS'));
must_fail(@()pe07_execution_guard('write_json_once',oncePath,struct('status','FAIL')), ...
    'PE07:NoOverwrite');

lock=jsondecode(fileread(fullfile(here,'pe07_execution_source_lock.json')));
lockResult=pe07_execution_guard('verify_lock',repoRoot,lock);
assert(strcmp(lockResult.status,'PASS') && lockResult.entries>=7);

runnerText=fileread(fullfile(here,'run_pe07_controlled_sensitivity.m'));
assert(contains(runnerText,'BASELINE_REPLAY_MISMATCH') && ...
    contains(runnerText,'perturbation_evaluations'',0') && ...
    contains(runnerText,'objective_productive_corrected_v96j_triobjective_CO2_fix1') && ...
    ~contains(runnerText,'gamultiobj('));
must_fail(@()run_pe07_controlled_sensitivity(false,struct()),'PE07:ExecutionLocked');
assert(~isfolder(realRoot) && ~isfile(realRoot),'PE07:DryRealRoot', ...
    'Dry validation created the real execution root.');

report=struct('status','PASS','config_schema','PASS', ...
    'anchors_full_precision_identity','PASS','structural_conditions',48, ...
    'preclassified_out_of_domain',1,'valid_perturbations',47, ...
    'max_executable_evaluations',50,'baseline_3_of_3_gate','PASS', ...
    'baseline_mismatch_blocks_perturbations','PASS', ...
    'invalid_retained_excluded','PASS','no_clipping_or_substitution','PASS', ...
    'root_parent_absent','PASS','root_parent_present','PASS', ...
    'root_collision','PASS','root_double_reservation','PASS', ...
    'no_overwrite','PASS','deterministic_condition_ids_order','PASS', ...
    'source_lock_validation','PASS','real_execution_root_created',false, ...
    'GAMULTIOBJ_CALL_COUNT',0,'MODEL_CALL_COUNT',0,'OBJECTIVE_CALL_COUNT',0);
end

function record=synthetic_record(x,f,status,executionStatus,withError)
record=struct('x',double(x(:)'),'f',f,'status',status, ...
    'execution_status',executionStatus,'error_identifier','', ...
    'responses',struct('MR',0.1,'W',100,'Q_aux_useful_MJ',780, ...
    'LPG_fuel_input_MJ',1000,'f1',f(1),'f2',f(2),'f3',f(3)));
if withError, record.error_identifier='PE07:Synthetic'; end
end

function remove_tree(path)
if isfolder(path), rmdir(path,'s'); elseif isfile(path), delete(path); end
end

function must_fail(action,identifier)
try
    action();
catch failure
    assert(strcmp(failure.identifier,identifier), ...
        'PE07:Dry','Expected %s, observed %s.',identifier,failure.identifier);
    return
end
error('PE07:Dry','Expected guard %s did not fail.',identifier);
end
