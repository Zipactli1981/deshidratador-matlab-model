function result = run_ror_recovery_campaign(confirm_execute,campaign_id,authorization)
% Recovery-only orchestration for fresh seeds 61003:61005.
% No-argument/default invocation fails before path setup, RNG, IO or objective.
if nargin < 1 || ~isequal(confirm_execute,true)
    error('ROR:RecoveryExecutionLocked','Explicit future recovery execution authorization required.');
end
if nargin ~= 3 || ~isstruct(authorization)
    error('ROR:RecoveryAuthorization','Explicit campaign id and authorization record required.');
end
here=fileparts(mfilename('fullpath'));
root=fileparts(fileparts(fileparts(here)));
protocolHash='7259B0855CF2F835851EE46FF8B8845FCAA0A1E07852419C76731F7F82A82599';
configHash='5131DA361C7C8688D755C724F2830C057980F7F2444DDC3B8983CCEEF4DCFE47';
lockHash='5F528E34A97BB279478BDD0FF5CF1D3A78EF7864D392CCC545162DAF0E2765EB';
originalCampaignId='ROR_PRIMARY_20260907_REAUTHORIZED';
requiredCampaignId='ROR_PRIMARY_20260907_RECOVERY_FROM_61003_A1';
recoverySeeds=[61003 61004 61005];
required={'approved','gate','record','protocol_sha256','implementation_audit_pass', ...
    'campaign_id','expected_head','recovery_seeds','warm_start', ...
    'initial_population_matrix','initial_scores_matrix'};
assert(all(isfield(authorization,required)),'ROR:RecoveryAuthorization','Incomplete authorization.');
assert(isequal(authorization.approved,true) && ...
    isequal(authorization.implementation_audit_pass,true), ...
    'ROR:RecoveryAuthorization','Separate implementation audit and execution approval required.');
assert(strcmp(authorization.gate,'ROR_RECOVERY_EXECUTION') && ...
    strcmp(authorization.protocol_sha256,protocolHash) && ~isempty(authorization.record), ...
    'ROR:RecoveryAuthorization','Wrong gate/hash or missing authorization record.');
campaign_id=char(campaign_id);
assert(strcmp(campaign_id,requiredCampaignId) && ...
    strcmp(authorization.campaign_id,campaign_id), ...
    'ROR:RecoveryAuthorization','Recovery campaign identifier mismatch.');
assert(isequal(double(authorization.recovery_seeds(:)'),recoverySeeds), ...
    'ROR:RecoverySubset','Authorized recovery seeds must be exactly 61003:61005.');
assert(isempty(authorization.warm_start) && ...
    isempty(authorization.initial_population_matrix) && ...
    isempty(authorization.initial_scores_matrix), ...
    'ROR:RecoveryWarmStart','Warm start and initial population/scores are prohibited.');
expectedHead=char(authorization.expected_head);
assert(~isempty(regexp(expectedHead,'^[0-9a-fA-F]{40}$','once')), ...
    'ROR:RecoveryAuthorization','Expected Git HEAD must be an exact commit SHA.');
assert(strcmpi(pwd,root),'ROR:RecoveryPath','Start from repository root.');
assert(strcmp(ror_hash(fullfile(here,'frozen_config.json')),configHash), ...
    'ROR:RecoveryHash','Config changed.');
assert(strcmp(ror_hash(fullfile(here,'source_lock.json')),lockHash), ...
    'ROR:RecoveryHash','Source lock changed.');
cfg=jsondecode(fileread(fullfile(here,'frozen_config.json')));
plan=ror_recovery_guards(cfg,recoverySeeds,[]);
assert(strcmp(ror_hash(fullfile(root,cfg.protocol_path)),protocolHash), ...
    'ROR:RecoveryProtocol','Protocol changed.');
lock=jsondecode(fileread(fullfile(here,'source_lock.json')));
ror_verify_sources(root,lock,false);

outBase=fullfile(root,'05_runs','robust_operating_region_v01');
originalRoot=fullfile(outBase,originalCampaignId);
assert(isfolder(originalRoot),'ROR:RecoveryOriginal','Original campaign root missing.');
originalManifest=jsondecode(fileread(fullfile(originalRoot,'CAMPAIGN_MANIFEST.json')));
assert(strcmp(originalManifest.campaign_id,originalCampaignId) && ...
    strcmp(originalManifest.protocol_sha256,protocolHash) && ...
    strcmp(originalManifest.config_sha256,configHash), ...
    'ROR:RecoveryOriginal','Original campaign provenance mismatch.');
originalIntegrity=struct([]);
for seed=plan.original_valid_seeds
    item=ror_verify_original_seed(fullfile(originalRoot,sprintf('seed_%d',seed)),seed,cfg);
    if isempty(originalIntegrity), originalIntegrity=item; else, originalIntegrity(end+1)=item; end %#ok<AGROW>
end
interruptedDir=fullfile(originalRoot,'seed_61003');
interruptedConfigPath=fullfile(interruptedDir,'FROZEN_CONFIG.json');
interruptedDiaryPath=fullfile(interruptedDir,'SOLVER_DIARY.txt');
assert(isfile(interruptedConfigPath) && isfile(interruptedDiaryPath), ...
    'ROR:RecoveryInterrupted','Interrupted evidence is missing.');
interruptedConfig=jsondecode(fileread(interruptedConfigPath));
assert(interruptedConfig.seed==61003 && isequaln(interruptedConfig.config,cfg), ...
    'ROR:RecoveryInterrupted','Interrupted config does not match the frozen configuration.');
interruptedHashes=struct('FROZEN_CONFIG_json',ror_hash(interruptedConfigPath), ...
    'SOLVER_DIARY_txt',ror_hash(interruptedDiaryPath));

assert(strcmp(version,cfg.environment.matlab),'ROR:RecoveryEnvironment','MATLAB build mismatch.');
v=ver('globaloptim');
assert(isscalar(v) && strcmp(v.Version,cfg.environment.globaloptim), ...
    'ROR:RecoveryEnvironment','Global Optimization Toolbox mismatch.');
assert(strcmp(computer,cfg.environment.platform),'ROR:RecoveryEnvironment','Platform mismatch.');
addpath(fullfile(root,'02_src_limpio','main'));
assert(strcmpi(which('setup_v05_paths'),fullfile(root,'02_src_limpio','main','setup_v05_paths.m')), ...
    'ROR:RecoveryShadow','setup path shadowed.');
setup_v05_paths();
addpath(genpath(fullfile(root,'02_src_limpio')));
ror_verify_sources(root,lock,true);
global TRACE_V628B_DIR TRACE_V628B_MODE TRACE_V628B_TAG %#ok<GVMIS>
TRACE_V628B_DIR=[]; TRACE_V628B_MODE=[]; TRACE_V628B_TAG=[];
opts=optimoptions('gamultiobj');
names=fieldnames(cfg.options);
for j=1:numel(names)
    key=names{j}; value=cfg.options.(key);
    if strcmp(key,'DistanceMeasureFcn')
        value={@distancecrowding,'phenotype'};
    elseif strcmp(key,'SelectionFcn')
        value={@selectiontournament,2};
    elseif strcmp(key,'MaxTime')
        value=Inf;
    elseif strcmp(key,'InitialPopulationRange')
        value=[-10;10];
    end
    opts.(key)=value;
end
observedOptions=ror_options(opts);
assert(ror_options_equivalent(cfg.options,observedOptions), ...
    'ROR:RecoveryOptions','Effective stored option mismatch.');
assert(isempty(opts.InitialPopulationMatrix) && isempty(opts.InitialScoresMatrix), ...
    'ROR:RecoveryWarmStart','Effective initial population/scores must be empty.');
solverNames={'gamultiobj','gacreationuniform','crossoverintermediate', ...
    'mutationadaptfeasible','distancecrowding','selectiontournament'};
solverIdentity=struct();
for j=1:numel(solverNames)
    name=solverNames{j}; resolved=which(name);
    assert(startsWith(lower(resolved),lower(matlabroot)),'ROR:RecoveryShadow','Solver shadowed.');
    solverIdentity.(name)=struct('path',resolved,'sha256',ror_hash(resolved));
end
[gitStatus,head]=system('git rev-parse HEAD');
assert(gitStatus==0,'ROR:RecoveryGit','HEAD capture failed.');
observedHead=strtrim(head);
assert(strcmpi(observedHead,expectedHead),'ROR:RecoveryGit','Observed HEAD differs from authorized HEAD.');

runDir=fullfile(outBase,campaign_id);
reservation=java.io.File(runDir);
assert(reservation.mkdir(),'ROR:RecoveryExists','Recovery campaign directory exists; no restart/overwrite.');
cleanupReservation=onCleanup(@()ror_leave_reserved_root(runDir));
campaignStart=ror_timestamp();
for name={'audit','tables','numeric','figures'}, mkdir(fullfile(runDir,name{1})); end
sources=repmat(struct('seed',0,'source_campaign_id','','source_path','','role',''),1,5);
for j=1:5
    seed=plan.final_primary_seed_set(j);
    if ismember(seed,plan.original_valid_seeds)
        sources(j)=struct('seed',seed,'source_campaign_id',originalCampaignId, ...
            'source_path',fullfile(originalRoot,sprintf('seed_%d',seed)), ...
            'role','ORIGINAL_VALID_PRIMARY');
    else
        sources(j)=struct('seed',seed,'source_campaign_id',campaign_id, ...
            'source_path',fullfile(runDir,sprintf('seed_%d',seed)), ...
            'role','RECOVERY_PRIMARY');
    end
end
manifest=struct('schema',1,'status','RUNNING', ...
    'RECOVERY_CAMPAIGN_ID',campaign_id,'ORIGINAL_CAMPAIGN_ID',originalCampaignId, ...
    'PROTOCOL_SHA256',protocolHash,'CONFIG_SHA256',configHash,'SOURCE_LOCK_SHA256',lockHash, ...
    'GIT_HEAD',observedHead,'EXPECTED_GIT_HEAD',expectedHead, ...
    'INTERRUPTION_CAUSE','EXTERNAL_WINDOWS_UPDATE_REBOOT','INTERRUPTED_SEED',61003, ...
    'INTERRUPTED_ATTEMPT_PATH',interruptedDir, ...
    'INTERRUPTED_ATTEMPT_CLASS','INTERRUPTED_ATTEMPT_EVIDENCE', ...
    'INTERRUPTED_ATTEMPT_HASHES',interruptedHashes, ...
    'VALID_ORIGINAL_SEEDS',plan.original_valid_seeds,'RECOVERY_SEEDS',recoverySeeds, ...
    'FINAL_PRIMARY_SEED_SET',plan.final_primary_seed_set,'FINAL_PRIMARY_SEED_COUNT',5, ...
    'FINAL_PRIMARY_SOURCES',sources,'ORIGINAL_SEED_INTEGRITY',originalIntegrity, ...
    'start_timestamp',campaignStart,'end_timestamp',[], ...
    'exact_output_directory',runDir,'authorization',authorization, ...
    'solver_options',observedOptions,'matlab',version,'globaloptim',v.Version,'platform',computer);
manifest.productive_dependency_hashes=lock;
ror_json(fullfile(runDir,'RECOVERY_MANIFEST.json'),manifest);
ror_json(fullfile(runDir,'audit','SOFTWARE_IDENTITY.json'), ...
    struct('sources',lock,'solver',solverIdentity,'source_lock_sha256',lockHash));

% The following seed block mirrors run_ror_campaign scientific logic. It is
% intentionally local so the frozen primary runner and source lock remain unchanged.
for seed=recoverySeeds
    seedDir=fullfile(runDir,sprintf('seed_%d',seed)); mkdir(seedDir);
    primaryOutputPath=fullfile(seedDir,'PRIMARY_OUTPUT.mat');
    evaluationDetailsPath=fullfile(seedDir,'EVALUATION_DETAILS.mat');
    frozenConfigPath=fullfile(seedDir,'FROZEN_CONFIG.json');
    candidateCsvPath=fullfile(seedDir,'FINAL_CANDIDATES.csv');
    diaryPath=fullfile(seedDir,'SOLVER_DIARY.txt');
    seedHashPath=fullfile(seedDir,'SEED_SHA256.json');
    exactPrimaryPaths=struct('PRIMARY_OUTPUT_mat',primaryOutputPath, ...
        'EVALUATION_DETAILS_mat',evaluationDetailsPath,'FROZEN_CONFIG_json',frozenConfigPath, ...
        'FINAL_CANDIDATES_csv',candidateCsvPath,'SOLVER_DIARY_txt',diaryPath, ...
        'SEED_SHA256_json',seedHashPath);
    seedConfig=struct('seed',seed,'config',cfg,'observed_options',observedOptions, ...
        'effective_functions_expected',{cfg.effective_functions}, ...
        'recovery_campaign_id',campaign_id,'original_campaign_id',originalCampaignId, ...
        'recovery_role','RECOVERY_PRIMARY_FRESH_START');
    ror_json(frozenConfigPath,seedConfig);
    callX=zeros(0,4); callF=zeros(0,3); callObjectiveF=zeros(0,3); details_json=cell(0,1);
    diary(diaryPath); diary on;
    fprintf('ROR_RECOVERY_SEED_START %d\n',seed);
    seedStart=ror_timestamp(); timer=tic;
    try
        objective=@capture;
        rng(seed,'twister');
        rng_initial=rng;
        [X,F,exitflag,output,population,scores]=gamultiobj( ...
            objective,cfg.nvars,[],[],[],[],cfg.lb(:)',cfg.ub(:)',opts);
        rng_final=rng;
        elapsedTimeSeconds=toc(timer); seedEnd=ror_timestamp();
        assert(output.funccount==size(callX,1),'ROR:RecoveryCount','Funccount/capture mismatch.');
        assert((exitflag==0 && output.generations==200) || exitflag==1, ...
            'ROR:RecoveryStop','Abnormal/interrupted termination.');
        ror_verify_sources(root,lock,true);
        meta=struct('seed',seed,'config_sha256',configHash,'protocol_sha256',protocolHash, ...
            'source_lock_sha256',lockHash,'status','COMPLETED','errors',[], ...
            'generations',output.generations,'funccount',output.funccount, ...
            'exitflag',exitflag,'message',output.message,'start_timestamp',seedStart, ...
            'end_timestamp',seedEnd,'elapsed_time_seconds',elapsedTimeSeconds, ...
            'runtime_seconds',elapsedTimeSeconds,'exact_output_directory',seedDir, ...
            'expected_git_head',expectedHead,'observed_git_head',observedHead, ...
            'matlab',version,'globaloptim',v.Version,'platform',computer, ...
            'observed_options',observedOptions,'rng_type',rng_initial.Type,'rng_seed',rng_initial.Seed, ...
            'recovery_campaign_id',campaign_id,'original_campaign_id',originalCampaignId, ...
            'recovery_role','RECOVERY_PRIMARY_FRESH_START','warm_start_used',false);
        meta.exact_primary_output_paths=exactPrimaryPaths;
        meta.solver_options=observedOptions; meta.solver_output=output;
        meta.productive_dependency_hashes=lock;
        metadata_json=jsonencode(meta);
        save(primaryOutputPath,'X','F','population','scores','exitflag','output', ...
            'rng_initial','rng_final','opts','metadata_json','-v7');
        save(evaluationDetailsPath,'callX','callF','callObjectiveF','details_json','-v7');
        ror_csv(candidateCsvPath,X,F,population,scores);
        fprintf('ROR_RECOVERY_SEED_COMPLETE %d\n',seed); diary off;
        files={'PRIMARY_OUTPUT.mat','EVALUATION_DETAILS.mat','FROZEN_CONFIG.json', ...
            'FINAL_CANDIDATES.csv','SOLVER_DIARY.txt'};
        inventory=struct();
        for j=1:numel(files)
            info=dir(fullfile(seedDir,files{j}));
            inventory.(matlab.lang.makeValidName(files{j}))=struct( ...
                'path',files{j},'sha256',ror_hash(fullfile(seedDir,files{j})),'size',info.bytes);
        end
        ror_json(seedHashPath,inventory);
    catch failure
        fprintf('ROR_RECOVERY_SEED_FAILED %d %s\n',seed,failure.message); diary off;
        save(fullfile(seedDir,'FAILED_PARTIAL.mat'),'callX','callF','callObjectiveF','details_json','-v7');
        manifest.status='FAILED_NO_AUTORETRY'; manifest.failed_seed=seed;
        manifest.end_timestamp=ror_timestamp();
        manifest.error=getReport(failure,'extended','hyperlinks','off');
        ror_json(fullfile(runDir,'RECOVERY_MANIFEST.json'),manifest);
        rethrow(failure);
    end
end
manifest.status='COMPLETED_RECOVERY_PENDING_COMPOSITE_AUDIT';
manifest.end_timestamp=ror_timestamp();
ror_json(fullfile(runDir,'RECOVERY_MANIFEST.json'),manifest);
result=manifest;

    function f=capture(x)
        [f,d]=objective_productive_corrected_v96j_triobjective_CO2_fix1(x,'hybrid');
        assert(isreal(f) && numel(f)==3,'ROR:RecoveryObjective','Malformed objective output.');
        callX(end+1,:)=double(x(:)'); callF(end+1,:)=double(f(:)');
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

function item=ror_verify_original_seed(seedDir,seed,cfg)
required={'PRIMARY_OUTPUT.mat','EVALUATION_DETAILS.mat','FROZEN_CONFIG.json', ...
    'FINAL_CANDIDATES.csv','SOLVER_DIARY.txt'};
inventoryPath=fullfile(seedDir,'SEED_SHA256.json');
assert(isfile(inventoryPath),'ROR:RecoveryOriginal','Original seed inventory missing.');
inventory=jsondecode(fileread(inventoryPath)); fields=fieldnames(inventory);
assert(numel(fields)==numel(required),'ROR:RecoveryOriginal','Original inventory count mismatch.');
fileHashes=struct(); seen=cell(1,numel(fields));
for j=1:numel(fields)
    entry=inventory.(fields{j}); seen{j}=entry.path;
    path=fullfile(seedDir,entry.path); info=dir(path);
    assert(isscalar(info) && info.bytes==entry.size && strcmp(ror_hash(path),entry.sha256), ...
        'ROR:RecoveryOriginal','Original seed hash/size mismatch: %s',entry.path);
    fileHashes.(matlab.lang.makeValidName(entry.path))=entry.sha256;
end
assert(isequal(sort(seen),sort(required)),'ROR:RecoveryOriginal','Original inventory paths mismatch.');
seedCfg=jsondecode(fileread(fullfile(seedDir,'FROZEN_CONFIG.json')));
assert(seedCfg.seed==seed && isequaln(seedCfg.config,cfg), ...
    'ROR:RecoveryOriginal','Original source/config mismatch.');
item=struct('seed',seed,'seed_sha256',ror_hash(inventoryPath),'files',fileHashes);
end

function stamp=ror_timestamp()
stamp=char(datetime('now','TimeZone','UTC','Format',"yyyy-MM-dd'T'HH:mm:ss.SSSXXX"));
end

function ror_verify_sources(root,lock,check_resolution)
for j=1:numel(lock)
    p=fullfile(root,lock(j).path);
    assert(strcmp(ror_hash(p),lock(j).sha256),'ROR:RecoverySource','Source/data bytes changed: %s',p);
    if check_resolution
        [~,name,ext]=fileparts(p);
        if ismember(ext,{'.m','.mlx'})
            assert(strcmpi(which(name),p),'ROR:RecoveryShadow','Source resolution mismatch: %s',name);
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
snapshot=jsondecode(jsonencode(snapshot));
end

function h=ror_hash(p)
fid=fopen(p,'rb'); assert(fid>=0,'ROR:RecoveryFile','Cannot read %s',p);
cleanup=onCleanup(@()fclose(fid));
md=java.security.MessageDigest.getInstance('SHA-256');
while ~feof(fid), md.update(fread(fid,1048576,'*uint8')); end
h=upper(reshape(dec2hex(typecast(md.digest(),'uint8'),2)',1,[]));
end

function ror_json(p,s)
fid=fopen(p,'w','n','UTF-8'); assert(fid>=0,'ROR:RecoveryIO','Cannot write JSON.');
cleanup=onCleanup(@()fclose(fid)); fprintf(fid,'%s\n',jsonencode(s));
end

function ror_csv(p,X,F,population,scores)
fid=fopen(p,'w'); assert(fid>=0,'ROR:RecoveryIO','Cannot write CSV.');
cleanup=onCleanup(@()fclose(fid));
fprintf(fid,'source,row,x1,x2,x3,x4,f1,f2,f3\n');
xs={X,population}; fs={F,scores}; labels={'returned','population'};
for s=1:2
    for i=1:size(xs{s},1)
        fprintf(fid,'%s,%d',labels{s},i); fprintf(fid,',%.17g',[xs{s}(i,:) fs{s}(i,:)]); fprintf(fid,'\n');
    end
end
end

function ror_leave_reserved_root(~)
% Deliberately no cleanup: reservation and any failure evidence are preserved.
end
