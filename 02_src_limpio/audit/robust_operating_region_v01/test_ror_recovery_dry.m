function report=test_ror_recovery_dry()
% MATLAB dry validation only: guards and optimoptions; never calls solver/model/objective.
here=fileparts(mfilename('fullpath'));
cfg=jsondecode(fileread(fullfile(here,'frozen_config.json')));
plan=ror_recovery_guards(cfg,[61003 61004 61005],[]);
assert(isequal(plan.final_primary_seed_set,61001:61005));
must_fail(@()ror_recovery_guards(cfg,[61001 61003 61004],[]),'ROR:RecoveryOriginalSeed');
must_fail(@()ror_recovery_guards(cfg,[61002 61004 61005],[]),'ROR:RecoveryOriginalSeed');
must_fail(@()ror_recovery_guards(cfg,[61003 61004 61006],[]),'ROR:RecoveryUnknownSeed');
must_fail(@()ror_recovery_guards(cfg,[61003 61003 61005],[]),'ROR:RecoveryDuplicateSeed');
must_fail(@()ror_recovery_guards(cfg,[61003 61004 61005],'partial_61003'), ...
    'ROR:RecoveryWarmStart');
bad=cfg; bad.options.InitialPopulationMatrix=[0.1 50 0 0];
must_fail(@()ror_recovery_guards(bad,[61003 61004 61005],[]),'ROR:RecoveryWarmStart');

opts=optimoptions('gamultiobj'); names=fieldnames(cfg.options);
for j=1:numel(names)
    key=names{j}; value=cfg.options.(key);
    if strcmp(key,'DistanceMeasureFcn'), value={@distancecrowding,'phenotype'};
    elseif strcmp(key,'SelectionFcn'), value={@selectiontournament,2};
    elseif strcmp(key,'MaxTime'), value=Inf;
    elseif strcmp(key,'InitialPopulationRange'), value=[-10;10];
    end
    opts.(key)=value;
end
assert(opts.PopulationSize==24 && opts.MaxGenerations==200 && ~opts.UseParallel);
assert(isempty(opts.InitialPopulationMatrix) && isempty(opts.InitialScoresMatrix));
assert(strcmpi(opts.PopulationType,'doublevector'));
report=struct('status','PASS','original_valid_seeds',plan.original_valid_seeds, ...
    'recovery_seeds',plan.recovery_seeds,'final_primary_seed_set',plan.final_primary_seed_set, ...
    'GAMULTIOBJ_CALL_COUNT',0,'MODEL_CALL_COUNT',0,'OBJECTIVE_CALL_COUNT',0, ...
    'OPTIMIZATION_RUNS',0);
end

function must_fail(f,expected)
try
    f();
catch failure
    assert(strcmp(failure.identifier,expected), ...
        'ROR:RecoveryDry','Expected %s, observed %s.',expected,failure.identifier);
    return
end
error('ROR:RecoveryDry','Expected guard %s did not fail.',expected);
end
