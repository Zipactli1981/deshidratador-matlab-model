function [state_out,options_out,optchanged] = ror_extended_snapshot_outputfcn(options,state,flag,context)
% Passive diagnostic OutputFcn. It never changes solver state or options.
state_out=state;
options_out=options;
optchanged=false;

if nargin<4 || isempty(context)
    error('ROR:DiagnosticContext','Frozen diagnostic snapshot context required.');
end
required={'output_dir','seed','campaign_id','frozen_config','git_head', ...
    'protocol_sha256','source_lock','matlab_version','solver_identity'};
assert(isstruct(context) && all(isfield(context,required)), ...
    'ROR:DiagnosticContext','Incomplete diagnostic snapshot context.');
assert(context.seed==61001 && strcmp(context.campaign_id, ...
    'ROR_BUDGET_DIAGNOSTIC_61001_G400_V01'), ...
    'ROR:DiagnosticContext','Wrong diagnostic identity.');

generation=get_or_na(state,'Generation');
isDone=strcmp(flag,'done');
checkpoints=[50 100 150 200 250 300 350 400];
atCheckpoint=isnumeric(generation) && isscalar(generation) && ...
    isfinite(generation) && ismember(double(generation),checkpoints);
if ~(isDone || (strcmp(flag,'iter') && atCheckpoint))
    return
end

outDir=char(context.output_dir);
assert(isfolder(outDir),'ROR:DiagnosticSnapshotPath','Snapshot directory not reserved.');
if isDone
    label=sprintf('FINAL_G%s',generation_label(generation));
else
    label=sprintf('G%03d',double(generation));
end
target=fullfile(outDir,[label '.mat']);
hashTarget=fullfile(outDir,[label '.sha256']);
assert(~isfile(target) && ~isfile(hashTarget), ...
    'ROR:DiagnosticSnapshotExists','Snapshot already exists; overwrite prohibited.');

names={'Generation','Population','Score','FunEval','isFeas','C','Ceq', ...
    'maxLinInfeas','Rank','Distance','Spread','StopFlag'};
snapshot=struct();
for k=1:numel(names)
    snapshot.(names{k})=get_or_na(state,names{k});
end
snapshot.flag=char(flag);
snapshot.rng_state=rng; % observational read only
snapshot.utc_timestamp=char(datetime('now','TimeZone','UTC', ...
    'Format',"yyyy-MM-dd'T'HH:mm:ss.SSSXXX"));
snapshot.seed=context.seed;
snapshot.campaign_id=context.campaign_id;
snapshot.frozen_config=context.frozen_config;
snapshot.git_head=context.git_head;
snapshot.protocol_sha256=context.protocol_sha256;
snapshot.source_lock=context.source_lock;
snapshot.matlab_version=context.matlab_version;
snapshot.solver_identity=context.solver_identity;
snapshot.complete=true;

tempPath=[tempname(outDir) '.mat'];
cleanup=onCleanup(@()delete_if_present(tempPath));
save(tempPath,'snapshot','-v7');
check=load(tempPath,'snapshot');
assert(isfield(check,'snapshot') && isfield(check.snapshot,'complete') && ...
    isequal(check.snapshot.complete,true), ...
    'ROR:DiagnosticSnapshotIncomplete','Temporary snapshot validation failed.');
digest=ror_extended_hash(tempPath);
[ok,message]=movefile(tempPath,target);
assert(ok,'ROR:DiagnosticSnapshotPublish','Atomic-directory publish failed: %s',message);
write_once(hashTarget,sprintf('%s  %s\n',digest,[label '.mat']));
end

function value=get_or_na(s,name)
if isstruct(s) && isfield(s,name)
    value=s.(name);
else
    value='NOT_AVAILABLE';
end
end

function label=generation_label(value)
if isnumeric(value) && isscalar(value) && isfinite(value)
    label=sprintf('%03d',double(value));
else
    label='NOT_AVAILABLE';
end
end

function write_once(path,content)
assert(~isfile(path),'ROR:DiagnosticSnapshotExists','Hash sidecar exists.');
tmp=[tempname(fileparts(path)) '.txt'];
cleanup=onCleanup(@()delete_if_present(tmp));
fid=fopen(tmp,'w','n','UTF-8');
assert(fid>=0,'ROR:DiagnosticSnapshotIO','Cannot create temporary hash file.');
c=onCleanup(@()fclose(fid));
fprintf(fid,'%s',content);
clear c
[ok,message]=movefile(tmp,path);
assert(ok,'ROR:DiagnosticSnapshotPublish','Hash publish failed: %s',message);
end

function delete_if_present(path)
if isfile(path), delete(path); end
end

function h=ror_extended_hash(path)
fid=fopen(path,'rb'); assert(fid>=0,'ROR:DiagnosticSnapshotIO','Cannot hash snapshot.');
cleanup=onCleanup(@()fclose(fid));
md=java.security.MessageDigest.getInstance('SHA-256');
while ~feof(fid), md.update(fread(fid,1048576,'*uint8')); end
h=upper(reshape(dec2hex(typecast(md.digest(),'uint8'),2)',1,[]));
end
