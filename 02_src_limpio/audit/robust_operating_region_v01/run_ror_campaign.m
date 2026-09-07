function result = run_ror_campaign(confirm_execute, campaign_id, authorization)
% Nonproductive orchestration. Never call during implementation/audit.
% No-argument/default invocation fails BEFORE path setup, RNG, IO or objective.
if nargin < 1 || ~isequal(confirm_execute,true)
    error('ROR:ExecutionLocked','Explicit future execution authorization required.');
end
if nargin ~= 3 || ~isstruct(authorization)
    error('ROR:Authorization','Explicit campaign id and authorization record required.');
end
here = fileparts(mfilename('fullpath'));
root = fileparts(fileparts(fileparts(here)));
protocolHash = '7259B0855CF2F835851EE46FF8B8845FCAA0A1E07852419C76731F7F82A82599';
configHash = '5131DA361C7C8688D755C724F2830C057980F7F2444DDC3B8983CCEEF4DCFE47';
lockHash = '5F528E34A97BB279478BDD0FF5CF1D3A78EF7864D392CCC545162DAF0E2765EB';
required = {'approved','gate','record','protocol_sha256','implementation_audit_pass', ...
    'campaign_id','expected_head'};
assert(all(isfield(authorization,required)),'ROR:Authorization','Incomplete authorization.');
assert(isequal(authorization.approved,true) && isequal(authorization.implementation_audit_pass,true), ...
    'ROR:Authorization','Separate implementation audit and execution approval required.');
assert(strcmp(authorization.gate,'ROBUST_OPERATING_REGION_EXECUTION') && ...
    strcmp(authorization.protocol_sha256,protocolHash) && ~isempty(authorization.record), ...
    'ROR:Authorization','Wrong gate/hash or missing author record.');
campaign_id = char(campaign_id);
assert(~isempty(regexp(campaign_id,'^[A-Za-z0-9][A-Za-z0-9_-]{0,79}$','once')), ...
    'ROR:Path','Invalid campaign identifier.');
assert(strcmp(authorization.campaign_id,campaign_id),'ROR:Authorization','Campaign mismatch.');
expectedHead=char(authorization.expected_head);
assert(~isempty(regexp(expectedHead,'^[0-9a-fA-F]{40}$','once')), ...
    'ROR:Authorization','Expected Git HEAD must be an exact commit SHA.');
assert(strcmpi(pwd,root),'ROR:Path','Start from repository root to prevent current-folder shadowing.');
assert(strcmp(ror_hash(fullfile(here,'frozen_config.json')),configHash),'ROR:Hash','Config changed.');
assert(strcmp(ror_hash(fullfile(here,'source_lock.json')),lockHash),'ROR:Hash','Source lock changed.');
cfg = jsondecode(fileread(fullfile(here,'frozen_config.json')));
assert(strcmp(ror_hash(fullfile(root,cfg.protocol_path)),protocolHash),'ROR:Hash','Protocol changed.');
assert(contains(fileread(fullfile(root,cfg.protocol_path)), ...
    'NEXT_GATE = ROBUST_OPERATING_REGION_IMPLEMENTATION'),'ROR:Gate','Protocol gate changed.');
assert(isequal(cfg.seeds(:)',61001:61005) && cfg.primary_run_count==5 && cfg.nvars==4, ...
    'ROR:Freeze','Seed/config mismatch.');
assert(~cfg.HB200_INITIALIZATION && ~cfg.C_INITIALIZATION && ~cfg.execution_authorized, ...
    'ROR:Freeze','Warm starts/default execution prohibited.');
lock = jsondecode(fileread(fullfile(here,'source_lock.json')));
ror_verify_sources(root,lock,false);
assert(strcmp(version,cfg.environment.matlab),'ROR:Environment','MATLAB build mismatch.');
v = ver('globaloptim');
assert(numel(v)==1 && strcmp(v.Version,cfg.environment.globaloptim), ...
    'ROR:Environment','Global Optimization Toolbox mismatch.');
assert(strcmp(computer,cfg.environment.platform),'ROR:Environment','Platform mismatch.');
% Reproduce the productive path setup WITHOUT any preflight/model call.
addpath(fullfile(root,'02_src_limpio','main'));
assert(strcmpi(which('setup_v05_paths'),fullfile(root,'02_src_limpio','main','setup_v05_paths.m')), ...
    'ROR:Shadow','setup path shadowed.');
setup_v05_paths();
addpath(genpath(fullfile(root,'02_src_limpio')));
ror_verify_sources(root,lock,true);
global TRACE_V628B_DIR TRACE_V628B_MODE TRACE_V628B_TAG
TRACE_V628B_DIR = []; TRACE_V628B_MODE = []; TRACE_V628B_TAG = [];
opts = optimoptions('gamultiobj');
names = fieldnames(cfg.options);
for j = 1:numel(names)
    key = names{j}; expected = cfg.options.(key);
    value = expected;
    if strcmp(key,'DistanceMeasureFcn')
        value = {@distancecrowding,'phenotype'};
    elseif strcmp(key,'SelectionFcn')
        value = {@selectiontournament,2};
    elseif strcmp(key,'MaxTime')
        value = Inf;
    elseif strcmp(key,'InitialPopulationRange')
        value = [-10;10];
    end
    opts.(key) = value;
end
observed_options = ror_options(opts);
assert(isequaln(observed_options,cfg.options),'ROR:Options','Effective stored option mismatch.');
% Dynamic default resolution is release-specific; names are provenance expectations,
% not an assertion that private solver validation has already executed.
effective_functions_expected = cfg.effective_functions;
solver_names = {'gamultiobj','gacreationuniform','crossoverintermediate', ...
    'mutationadaptfeasible','distancecrowding','selectiontournament'};
solver_identity = struct();
for j=1:numel(solver_names)
    name=solver_names{j}; resolved=which(name);
    assert(startsWith(lower(resolved),lower(matlabroot)),'ROR:Shadow','Solver shadowed.');
    solver_identity.(name)=struct('path',resolved,'sha256',ror_hash(resolved));
end
[gitStatus,head]=system('git rev-parse HEAD');
assert(gitStatus==0,'ROR:Git','HEAD capture failed.');
observedHead=strtrim(head);
assert(strcmpi(observedHead,expectedHead),'ROR:Git','Observed HEAD differs from authorized HEAD.');
campaignStart=ror_timestamp();
outBase=fullfile(root,'05_runs','robust_operating_region_v01');
if ~isfolder(outBase), mkdir(outBase); end
runDir=fullfile(outBase,campaign_id);
reservation=java.io.File(runDir);
assert(reservation.mkdir(),'ROR:Exists','Campaign directory exists; no restart/overwrite.');
for name={'audit','tables','numeric','figures'}, mkdir(fullfile(runDir,name{1})); end
manifest=struct('schema',1,'status','RUNNING','campaign_id',campaign_id, ...
    'protocol_sha256',protocolHash,'config_sha256',configHash,'source_lock_sha256',lockHash, ...
    'expected_git_head',expectedHead,'observed_git_head',observedHead, ...
    'start_timestamp',campaignStart,'end_timestamp',[], ...
    'exact_output_directory',runDir,'seeds',cfg.seeds,'authorization',authorization, ...
    'solver_options',observed_options,'matlab',version,'globaloptim',v.Version,'platform',computer);
manifest.productive_dependency_hashes=lock;
ror_json(fullfile(runDir,'CAMPAIGN_MANIFEST.json'),manifest);
ror_json(fullfile(runDir,'audit','SOFTWARE_IDENTITY.json'), ...
    struct('sources',lock,'solver',solver_identity,'source_lock_sha256',lockHash));
for seed = cfg.seeds(:)'
    seedDir=fullfile(runDir,sprintf('seed_%d',seed)); mkdir(seedDir);
    primaryOutputPath=fullfile(seedDir,'PRIMARY_OUTPUT.mat');
    evaluationDetailsPath=fullfile(seedDir,'EVALUATION_DETAILS.mat');
    frozenConfigPath=fullfile(seedDir,'FROZEN_CONFIG.json');
    candidateCsvPath=fullfile(seedDir,'FINAL_CANDIDATES.csv');
    diaryPath=fullfile(seedDir,'SOLVER_DIARY.txt');
    seedHashPath=fullfile(seedDir,'SEED_SHA256.json');
    exactPrimaryPaths=struct('PRIMARY_OUTPUT_mat',primaryOutputPath, ...
        'EVALUATION_DETAILS_mat',evaluationDetailsPath, ...
        'FROZEN_CONFIG_json',frozenConfigPath, ...
        'FINAL_CANDIDATES_csv',candidateCsvPath, ...
        'SOLVER_DIARY_txt',diaryPath,'SEED_SHA256_json',seedHashPath);
    seedConfig=struct('seed',seed,'config',cfg,'observed_options',observed_options, ...
        'effective_functions_expected',{effective_functions_expected});
    ror_json(frozenConfigPath,seedConfig);
    callX=zeros(0,4); callF=zeros(0,3); callObjectiveF=zeros(0,3); details_json=cell(0,1);
    diary(diaryPath); diary on;
    fprintf('ROR_SEED_START %d\n',seed);
    seedStart=ror_timestamp();
    timer=tic;
    try
        objective=@capture;
        rng(seed,'twister');
        rng_initial=rng;
        [X,F,exitflag,output,population,scores]=gamultiobj( ...
            objective,cfg.nvars,[],[],[],[],cfg.lb(:)',cfg.ub(:)',opts);
        rng_final=rng;
        elapsedTimeSeconds=toc(timer);
        seedEnd=ror_timestamp();
        assert(output.funccount==size(callX,1),'ROR:Count','Funccount/capture mismatch.');
        assert((exitflag==0 && output.generations==200) || exitflag==1, ...
            'ROR:Stop','Abnormal/interrupted termination.');
        ror_verify_sources(root,lock,true);
        meta=struct('seed',seed,'config_sha256',configHash,'protocol_sha256',protocolHash, ...
            'source_lock_sha256',lockHash,'status','COMPLETED','errors',[], ...
            'generations',output.generations,'funccount',output.funccount, ...
            'exitflag',exitflag,'message',output.message, ...
            'start_timestamp',seedStart,'end_timestamp',seedEnd, ...
            'elapsed_time_seconds',elapsedTimeSeconds,'runtime_seconds',elapsedTimeSeconds, ...
            'exact_output_directory',seedDir, ...
            'expected_git_head',expectedHead,'observed_git_head',observedHead, ...
            'matlab',version,'globaloptim',v.Version,'platform',computer, ...
            'observed_options',observed_options,'rng_type',rng_initial.Type, ...
            'rng_seed',rng_initial.Seed);
        meta.exact_primary_output_paths=exactPrimaryPaths;
        meta.solver_options=observed_options;
        meta.solver_output=output;
        meta.productive_dependency_hashes=lock;
        metadata_json=jsonencode(meta);
        save(primaryOutputPath,'X','F','population','scores', ...
            'exitflag','output','rng_initial','rng_final','opts','metadata_json','-v7');
        save(evaluationDetailsPath,'callX','callF','callObjectiveF','details_json','-v7');
        ror_csv(candidateCsvPath,X,F,population,scores);
        fprintf('ROR_SEED_COMPLETE %d\n',seed);
        diary off;
        files={'PRIMARY_OUTPUT.mat','EVALUATION_DETAILS.mat','FROZEN_CONFIG.json', ...
            'FINAL_CANDIDATES.csv','SOLVER_DIARY.txt'};
        inventory=struct();
        for j=1:numel(files)
            info=dir(fullfile(seedDir,files{j}));
            inventory.(matlab.lang.makeValidName(files{j}))= ...
                struct('path',files{j},'sha256',ror_hash(fullfile(seedDir,files{j})),'size',info.bytes);
        end
        ror_json(seedHashPath,inventory);
    catch failure
        fprintf('ROR_SEED_FAILED %d %s\n',seed,failure.message); diary off;
        save(fullfile(seedDir,'FAILED_PARTIAL.mat'),'callX','callF','callObjectiveF','details_json','-v7');
        manifest.status='FAILED_NO_AUTORETRY'; manifest.failed_seed=seed;
        manifest.end_timestamp=ror_timestamp();
        manifest.error=getReport(failure,'extended','hyperlinks','off');
        ror_json(fullfile(runDir,'CAMPAIGN_MANIFEST.json'),manifest);
        rethrow(failure);
    end
end
manifest.status='COMPLETED_PENDING_POSTRUN';
manifest.end_timestamp=ror_timestamp();
ror_json(fullfile(runDir,'CAMPAIGN_MANIFEST.json'),manifest);
result=manifest;
% No postrun/model replay/gasLP reference evaluations are invoked here.
    function f=capture(x)
        [f,d]=objective_productive_corrected_v96j_triobjective_CO2_fix1(x,'hybrid');
        assert(isreal(f) && numel(f)==3,'ROR:Objective','Malformed objective output.');
        callX(end+1,:)=double(x(:)');
        callF(end+1,:)=double(f(:)');
        callObjectiveF(end+1,:)=NaN(1,3);
        if isfield(d,'objectives') && all(isfield(d.objectives, ...
                {'MR_final','cost_specific_USD_per_kgwater','CO2_specific_kgCO2_per_kgwater'}))
            callObjectiveF(end,:)=[d.objectives.MR_final, ...
                d.objectives.cost_specific_USD_per_kgwater, ...
                d.objectives.CO2_specific_kgCO2_per_kgwater];
        end
        details_json{end+1,1}=jsonencode(d);
    end
end

function stamp=ror_timestamp()
stamp=char(datetime('now','TimeZone','UTC','Format',"yyyy-MM-dd'T'HH:mm:ss.SSSXXX"));
end

function ror_verify_sources(root,lock,check_resolution)
for j=1:numel(lock)
    p=fullfile(root,lock(j).path);
    assert(strcmp(ror_hash(p),lock(j).sha256),'ROR:Source','Source/data bytes changed: %s',p);
    if check_resolution
        [~,name,ext]=fileparts(p);
        if ismember(ext,{'.m','.mlx'})
            assert(strcmpi(which(name),p),'ROR:Shadow','Source resolution mismatch: %s',name);
        end
    end
end
end

function snapshot=ror_options(opts)
snapshot=struct();
names={'PopulationSize','MaxGenerations','UseParallel','FunctionTolerance', ...
    'ConstraintTolerance','Display','PlotFcn','OutputFcn','InitialPopulationMatrix', ...
    'InitialScoresMatrix','InitialPopulationRange','PopulationType','ParetoFraction', ...
    'DistanceMeasureFcn','SelectionFcn','CreationFcn','CrossoverFcn','MutationFcn', ...
    'CrossoverFraction','MigrationDirection','MigrationFraction','MigrationInterval', ...
    'MaxStallGenerations','HybridFcn','PlotInterval','MaxTime','UseVectorized','IntegerTolerance'};
for j=1:numel(names)
    key=names{j}; val=opts.(key);
    if strcmp(key,'MaxTime') && isinf(val), val='Inf'; end
    if iscell(val)
        for k=1:numel(val)
            if isa(val{k},'function_handle'), val{k}=func2str(val{k}); end
        end
    end
    snapshot.(key)=val;
end
% JSON roundtrip aligns column/cell layout with jsondecode of frozen JSON.
snapshot=jsondecode(jsonencode(snapshot));
end

function h=ror_hash(p)
fid=fopen(p,'rb'); assert(fid>=0,'ROR:File','Cannot read %s',p);
cleanup=onCleanup(@()fclose(fid));
md=java.security.MessageDigest.getInstance('SHA-256');
while ~feof(fid)
    bytes=fread(fid,1048576,'*uint8');
    md.update(bytes);
end
h=upper(reshape(dec2hex(typecast(md.digest(),'uint8'),2)',1,[]));
end

function ror_json(p,s)
fid=fopen(p,'w','n','UTF-8'); assert(fid>=0,'ROR:IO','Cannot write manifest.');
cleanup=onCleanup(@()fclose(fid));
fprintf(fid,'%s\n',jsonencode(s));
end

function ror_csv(p,X,F,population,scores)
fid=fopen(p,'w'); assert(fid>=0,'ROR:IO','Cannot write CSV.');
cleanup=onCleanup(@()fclose(fid));
fprintf(fid,'source,row,x1,x2,x3,x4,f1,f2,f3\n');
xs={X,population}; fs={F,scores}; labels={'returned','population'};
for s=1:2
    for i=1:size(xs{s},1)
        fprintf(fid,'%s,%d',labels{s},i);
        fprintf(fid,',%.17g',[xs{s}(i,:) fs{s}(i,:)]);
        fprintf(fid,'\n');
    end
end
end
