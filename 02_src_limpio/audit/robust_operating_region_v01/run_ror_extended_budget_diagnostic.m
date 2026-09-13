function result=run_ror_extended_budget_diagnostic(confirm_execute,authorization)
% Dedicated nonproductive runner. Never invoke during infrastructure validation.
if nargin<1 || ~isequal(confirm_execute,true)
    error('ROR:DiagnosticExecutionLocked','Explicit future execution authorization required.');
end
if nargin~=2 || ~isstruct(authorization)
    error('ROR:DiagnosticAuthorization','Authorization record required.');
end
required={'approved','gate','campaign_id','protocol_sha256','expected_head','record'};
assert(all(isfield(authorization,required)) && isequal(authorization.approved,true), ...
    'ROR:DiagnosticAuthorization','Incomplete or unapproved authorization.');
assert(strcmp(authorization.gate,'ROR_EXTENDED_BUDGET_DIAGNOSTIC_EXECUTION') && ...
    strcmp(authorization.campaign_id,'ROR_BUDGET_DIAGNOSTIC_61001_G400_V01') && ...
    ~isempty(authorization.record), ...
    'ROR:DiagnosticAuthorization','Wrong execution gate or campaign.');

here=fileparts(mfilename('fullpath'));
repoRoot=fileparts(fileparts(fileparts(here)));
assert(strcmpi(pwd,repoRoot),'ROR:DiagnosticPath','Start from repository root.');
cfg=jsondecode(fileread(fullfile(here,'extended_diagnostic_config.json')));
primaryCfg=jsondecode(fileread(fullfile(here,'frozen_config.json')));
assert(strcmp(authorization.protocol_sha256,cfg.protocol_sha256), ...
    'ROR:DiagnosticAuthorization','Protocol authorization mismatch.');
executionRoot=fullfile(repoRoot,cfg.output_root,cfg.campaign_id);
plan=ror_extended_diagnostic_guards(cfg,primaryCfg,repoRoot,executionRoot,[]);
lock=jsondecode(fileread(fullfile(here,'extended_diagnostic_source_lock.json')));
verify_lock(repoRoot,lock);

[gitStatus,observedHead]=system('git rev-parse HEAD');
assert(gitStatus==0 && strcmpi(strtrim(observedHead),authorization.expected_head), ...
    'ROR:DiagnosticGit','Observed HEAD differs from authorization.');
observedHead=strtrim(observedHead);
addpath(fullfile(repoRoot,'02_src_limpio','main'));
assert(strcmpi(which('setup_v05_paths'),fullfile(repoRoot,'02_src_limpio','main','setup_v05_paths.m')), ...
    'ROR:DiagnosticShadow','setup_v05_paths shadowed.');
setup_v05_paths();
addpath(genpath(fullfile(repoRoot,'02_src_limpio')));
verify_lock(repoRoot,lock);

opts=optimoptions('gamultiobj');
names=fieldnames(cfg.options);
for j=1:numel(names)
    key=names{j}; value=cfg.options.(key);
    if strcmp(key,'DistanceMeasureFcn'), value={@distancecrowding,'phenotype'};
    elseif strcmp(key,'SelectionFcn'), value={@selectiontournament,2};
    elseif strcmp(key,'MaxTime'), value=Inf;
    elseif strcmp(key,'InitialPopulationRange'), value=[-10;10];
    elseif strcmp(key,'OutputFcn'), continue
    end
    opts.(key)=value;
end
solverNames={'gamultiobj','gacreationuniform','crossoverintermediate', ...
    'mutationadaptfeasible','distancecrowding','selectiontournament'};
solverIdentity=struct();
for j=1:numel(solverNames)
    resolved=which(solverNames{j});
    assert(startsWith(lower(resolved),lower(matlabroot)), ...
        'ROR:DiagnosticShadow','Solver function shadowed.');
    solverIdentity.(solverNames{j})=struct('path',resolved,'sha256',file_hash(resolved));
end

ror_extended_root_guard(executionRoot,'reserve');
snapshotDir=fullfile(executionRoot,'snapshots'); mkdir(snapshotDir);
diaryPath=fullfile(executionRoot,'SOLVER_DIARY.txt');
context=struct('output_dir',snapshotDir,'seed',cfg.seed,'campaign_id',cfg.campaign_id, ...
    'frozen_config',cfg,'git_head',observedHead,'protocol_sha256',cfg.protocol_sha256, ...
    'source_lock',lock,'matlab_version',version,'solver_identity',solverIdentity);
opts.OutputFcn=@(options,state,flag)ror_extended_snapshot_outputfcn(options,state,flag,context);
observedOptions=option_snapshot(opts);
expectedOptions=cfg.options;
[same,~,~]=ror_options_equivalent(expectedOptions,observedOptions);
assert(same,'ROR:DiagnosticOptions','Effective option mismatch.');

startStamp=utc_stamp();
manifest=struct('schema',1,'status','RUNNING','campaign_id',cfg.campaign_id, ...
    'role',cfg.role,'seed',cfg.seed,'protocol_sha256',cfg.protocol_sha256, ...
    'git_head',observedHead,'start_timestamp',startStamp,'end_timestamp',[], ...
    'output_root',executionRoot,'authorization',authorization,'guard_plan',plan, ...
    'solver_options',observedOptions,'source_lock',lock);
write_json_once(fullfile(executionRoot,'FROZEN_CONFIG.json'),cfg);
write_json_once(fullfile(executionRoot,'PROVENANCE.json'), ...
    struct('git_head',observedHead,'protocol_sha256',cfg.protocol_sha256, ...
    'source_lock',lock,'solver_identity',solverIdentity,'matlab',version,'platform',computer));
write_json_replace(fullfile(executionRoot,'EXECUTION_MANIFEST.json'),manifest);

diary(diaryPath); diary on;
fprintf('ROR_EXTENDED_DIAGNOSTIC_START 61001\n');
timer=tic;
try
    rng(cfg.seed,cfg.rng); rngInitial=rng;
    objective=@(x)objective_productive_corrected_v96j_triobjective_CO2_fix1(x,cfg.mode);
    [X,F,exitflag,output,population,scores]=gamultiobj(objective,cfg.nvars, ...
        [],[],[],[],cfg.lb(:)',cfg.ub(:)',opts);
    rngFinal=rng; elapsedSeconds=toc(timer);
    assert((exitflag==0 && output.generations==400) || exitflag==1, ...
        'ROR:DiagnosticStop','Invalid/interrupted solver termination.');
    verify_lock(repoRoot,lock);
    metadata=struct('seed',cfg.seed,'campaign_id',cfg.campaign_id, ...
        'protocol_sha256',cfg.protocol_sha256,'git_head',observedHead, ...
        'start_timestamp',startStamp,'end_timestamp',utc_stamp(), ...
        'elapsed_seconds',elapsedSeconds,'exitflag',exitflag,'output',output, ...
        'internal_termination_valid',exitflag==1 && output.generations<400, ...
        'termination_source','SOLVER_ONLY_CALLBACK_PASSIVE', ...
        'rng_initial',rngInitial,'rng_final',rngFinal,'solver_options',observedOptions);
    save(fullfile(executionRoot,'EXTENDED_FINAL.mat'),'X','F','population','scores', ...
        'exitflag','output','rngInitial','rngFinal','opts','metadata','-v7');
    write_candidates(fullfile(executionRoot,'FINAL_CANDIDATES.csv'),X,F,population,scores);
    fprintf('ROR_EXTENDED_DIAGNOSTIC_COMPLETE 61001\n'); diary off;
    inventoryNames={'EXTENDED_FINAL.mat','FINAL_CANDIDATES.csv', ...
        'SOLVER_DIARY.txt','FROZEN_CONFIG.json','PROVENANCE.json'};
    snapshotFiles=dir(fullfile(snapshotDir,'*'));
    for k=1:numel(snapshotFiles)
        if ~snapshotFiles(k).isdir
            inventoryNames{end+1}=fullfile('snapshots',snapshotFiles(k).name); %#ok<AGROW>
        end
    end
    inventory=make_inventory(executionRoot,inventoryNames);
    write_json_once(fullfile(executionRoot,'SHA256_INVENTORY.json'),inventory);
    manifest.status='COMPLETED_PENDING_POSTRUN'; manifest.end_timestamp=utc_stamp();
    manifest.exitflag=exitflag; manifest.generations=output.generations;
    write_json_replace(fullfile(executionRoot,'EXECUTION_MANIFEST.json'),manifest);
    result=manifest;
catch failure
    fprintf('ROR_EXTENDED_DIAGNOSTIC_FAILED 61001 %s\n',failure.message); diary off;
    manifest.status='FAILED_NO_AUTORETRY'; manifest.end_timestamp=utc_stamp();
    manifest.error=getReport(failure,'extended','hyperlinks','off');
    write_json_replace(fullfile(executionRoot,'EXECUTION_MANIFEST.json'),manifest);
    rethrow(failure);
end
end

function verify_lock(root,lock)
for k=1:numel(lock)
    path=fullfile(root,lock(k).path);
    assert(strcmp(file_hash(path),lock(k).sha256), ...
        'ROR:DiagnosticSourceLock','Source/reference hash mismatch: %s',lock(k).path);
end
end

function s=option_snapshot(opts)
s=struct();
names={'PopulationSize','MaxGenerations','UseParallel','FunctionTolerance', ...
    'ConstraintTolerance','Display','PlotFcn','OutputFcn','InitialPopulationMatrix', ...
    'InitialScoresMatrix','InitialPopulationRange','PopulationType','ParetoFraction', ...
    'DistanceMeasureFcn','SelectionFcn','CreationFcn','CrossoverFcn','MutationFcn', ...
    'CrossoverFraction','MigrationDirection','MigrationFraction','MigrationInterval', ...
    'MaxStallGenerations','HybridFcn','PlotInterval','MaxTime','UseVectorized','IntegerTolerance'};
for k=1:numel(names)
    key=names{k}; value=opts.(key);
    if strcmp(key,'OutputFcn'), value='ror_extended_snapshot_outputfcn';
    elseif strcmp(key,'MaxTime') && isinf(value), value='Inf';
    elseif iscell(value)
        for q=1:numel(value)
            if isa(value{q},'function_handle'), value{q}=func2str(value{q}); end
        end
    end
    s.(key)=value;
end
s=jsondecode(jsonencode(s));
end

function write_candidates(path,X,F,population,scores)
assert(~isfile(path),'ROR:DiagnosticExists','Candidate file exists.');
tmp=[tempname(fileparts(path)) '.csv'];
fid=fopen(tmp,'w'); assert(fid>=0,'ROR:DiagnosticIO','Cannot create candidates.');
c=onCleanup(@()fclose(fid)); fprintf(fid,'source,row,x1,x2,x3,x4,f1,f2,f3\n');
xx={X,population}; ff={F,scores}; labels={'returned','population'};
for s=1:2
    for k=1:size(xx{s},1)
        fprintf(fid,'%s,%d',labels{s},k); fprintf(fid,',%.17g',[xx{s}(k,:) ff{s}(k,:)]); fprintf(fid,'\n');
    end
end
clear c
[ok,message]=movefile(tmp,path); assert(ok,'ROR:DiagnosticIO','Candidate publish failed: %s',message);
end

function inventory=make_inventory(root,names)
inventory=struct();
for k=1:numel(names)
    info=dir(fullfile(root,names{k}));
    inventory.(matlab.lang.makeValidName(names{k}))=struct( ...
        'path',names{k},'sha256',file_hash(fullfile(root,names{k})),'size',info.bytes);
end
end

function write_json_once(path,value)
assert(~isfile(path),'ROR:DiagnosticExists','File exists: %s',path);
tmp=[tempname(fileparts(path)) '.json'];
fid=fopen(tmp,'w','n','UTF-8'); assert(fid>=0,'ROR:DiagnosticIO','Cannot create JSON.');
fprintf(fid,'%s\n',jsonencode(value)); fclose(fid);
[ok,message]=movefile(tmp,path); assert(ok,'ROR:DiagnosticIO','JSON publish failed: %s',message);
end

function write_json_replace(path,value)
tmp=[tempname(fileparts(path)) '.json'];
fid=fopen(tmp,'w','n','UTF-8'); assert(fid>=0,'ROR:DiagnosticIO','Cannot write JSON.');
fprintf(fid,'%s\n',jsonencode(value)); fclose(fid);
[ok,message]=movefile(tmp,path,'f'); assert(ok,'ROR:DiagnosticIO','Manifest publish failed: %s',message);
end

function stamp=utc_stamp()
stamp=char(datetime('now','TimeZone','UTC','Format',"yyyy-MM-dd'T'HH:mm:ss.SSSXXX"));
end

function h=file_hash(path)
fid=fopen(path,'rb'); assert(fid>=0,'ROR:DiagnosticFile','Cannot read %s',path);
c=onCleanup(@()fclose(fid)); md=java.security.MessageDigest.getInstance('SHA-256');
while ~feof(fid), md.update(fread(fid,1048576,'*uint8')); end
h=upper(reshape(dec2hex(typecast(md.digest(),'uint8'),2)',1,[]));
end
