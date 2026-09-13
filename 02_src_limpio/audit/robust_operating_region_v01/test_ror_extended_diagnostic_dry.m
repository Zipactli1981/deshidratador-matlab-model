function report=test_ror_extended_diagnostic_dry()
% Synthetic/static MATLAB validation. Never calls gamultiobj/model/objective.
here=fileparts(mfilename('fullpath'));
repoRoot=fileparts(fileparts(fileparts(here)));
cfg=jsondecode(fileread(fullfile(here,'extended_diagnostic_config.json')));
primary=jsondecode(fileread(fullfile(here,'frozen_config.json')));
executionRoot=fullfile(repoRoot,cfg.output_root,cfg.campaign_id);
plan=ror_extended_diagnostic_guards(cfg,primary,repoRoot,executionRoot,[]);
assert(strcmp(plan.status,'PASS'));

bad=cfg; bad.seed=61002;
must_fail(@()ror_extended_diagnostic_guards(bad,primary,repoRoot,executionRoot,[]), ...
    'ROR:DiagnosticSeed');
bad=cfg; bad.options.MaxGenerations=399;
must_fail(@()ror_extended_diagnostic_guards(bad,primary,repoRoot,executionRoot,[]), ...
    'ROR:DiagnosticGenerations');
bad=cfg; bad.options.PopulationSize=25;
must_fail(@()ror_extended_diagnostic_guards(bad,primary,repoRoot,executionRoot,[]), ...
    'ROR:DiagnosticPopulation');
bad=cfg; bad.options.InitialPopulationMatrix=[0.1 50 0 0];
must_fail(@()ror_extended_diagnostic_guards(bad,primary,repoRoot,executionRoot,[]), ...
    'ROR:DiagnosticInitialPopulation');
bad=cfg; bad.options.InitialScoresMatrix=[1 2 3];
must_fail(@()ror_extended_diagnostic_guards(bad,primary,repoRoot,executionRoot,[]), ...
    'ROR:DiagnosticInitialScores');
bad=cfg; bad.options.FunctionTolerance=2e-5;
must_fail(@()ror_extended_diagnostic_guards(bad,primary,repoRoot,executionRoot,[]), ...
    'ROR:DiagnosticScientificDifference');

collision=tempname; mkdir(collision); cleanupCollision=onCleanup(@()rmdir(collision));
must_fail(@()ror_extended_root_guard(collision),'ROR:DiagnosticRootExists');

snapshotRoot=tempname; mkdir(snapshotRoot); cleanupSnapshots=onCleanup(@()rmdir(snapshotRoot,'s'));
context=struct('output_dir',snapshotRoot,'seed',61001, ...
    'campaign_id','ROR_BUDGET_DIAGNOSTIC_61001_G400_V01', ...
    'frozen_config',cfg,'git_head',repmat('a',1,40), ...
    'protocol_sha256',cfg.protocol_sha256,'source_lock',struct(), ...
    'matlab_version',version,'solver_identity',struct('gamultiobj','synthetic'));
options=struct('PopulationSize',24,'MaxGenerations',400, ...
    'OutputFcn','synthetic-passive-test');
state=synthetic_state(50); originalState=state; originalOptions=options;
[returnedState,returnedOptions,optchanged]= ...
    ror_extended_snapshot_outputfcn(options,state,'iter',context);
assert(isequaln(returnedState,originalState));
assert(isequaln(returnedOptions,originalOptions));
assert(isequal(optchanged,false));
assert(strcmp(returnedState.StopFlag,originalState.StopFlag));
assert(isfile(fullfile(snapshotRoot,'G050.mat')) && ...
    isfile(fullfile(snapshotRoot,'G050.sha256')));

for generation=[100 150 200 250 300 350 400]
    s=synthetic_state(generation);
    ror_extended_snapshot_outputfcn(options,s,'iter',context);
    assert(isfile(fullfile(snapshotRoot,sprintf('G%03d.mat',generation))));
end
doneState=synthetic_state(375);
ror_extended_snapshot_outputfcn(options,doneState,'done',context);
assert(isfile(fullfile(snapshotRoot,'FINAL_G375.mat')));

earlyRoot=tempname; mkdir(earlyRoot); cleanupEarly=onCleanup(@()rmdir(earlyRoot,'s'));
earlyContext=context; earlyContext.output_dir=earlyRoot;
ror_extended_snapshot_outputfcn(options,synthetic_state(175),'done',earlyContext);
assert(isfile(fullfile(earlyRoot,'FINAL_G175.mat')) && ...
    ~isfile(fullfile(earlyRoot,'G200.mat')));

opts=optimoptions('gamultiobj');
names=fieldnames(cfg.options);
for j=1:numel(names)
    key=names{j}; value=cfg.options.(key);
    if strcmp(key,'DistanceMeasureFcn'), value={@distancecrowding,'phenotype'};
    elseif strcmp(key,'SelectionFcn'), value={@selectiontournament,2};
    elseif strcmp(key,'MaxTime'), value=Inf;
    elseif strcmp(key,'InitialPopulationRange'), value=[-10;10];
    elseif strcmp(key,'OutputFcn')
        value=@(o,s,f)ror_extended_snapshot_outputfcn(o,s,f,context);
    end
    opts.(key)=value;
end
assert(opts.PopulationSize==24 && opts.MaxGenerations==400 && ~opts.UseParallel);
assert(isempty(opts.InitialPopulationMatrix) && isempty(opts.InitialScoresMatrix));
assert(isa(opts.OutputFcn,'function_handle'));

report=struct('status','PASS','callback_state_unchanged',true, ...
    'callback_options_unchanged',true,'callback_optchanged_false',true, ...
    'callback_stopflag_untouched',true,'snapshot_generations',50:50:400, ...
    'final_snapshot',true,'early_G200','NOT_REACHED', ...
    'GAMULTIOBJ_CALL_COUNT',0,'MODEL_CALL_COUNT',0,'OBJECTIVE_CALL_COUNT',0, ...
    'OPTIMIZATION_RUNS',0);
end

function state=synthetic_state(generation)
state=struct('Generation',generation,'Population',reshape(1:8,2,4), ...
    'Score',reshape(1:6,2,3),'FunEval',generation*24,'isFeas',[true;true], ...
    'Rank',[1;1],'Distance',[0.5;0.5],'Spread',0.2,'StopFlag','');
% C, Ceq and maxLinInfeas intentionally absent: callback must record NOT_AVAILABLE.
end

function must_fail(action,identifier)
try
    action();
catch failure
    assert(strcmp(failure.identifier,identifier), ...
        'ROR:DiagnosticDry','Expected %s, observed %s.',identifier,failure.identifier);
    return
end
error('ROR:DiagnosticDry','Expected guard %s did not fail.',identifier);
end
