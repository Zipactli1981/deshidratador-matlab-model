function ror_extended_root_guard(path,mode)
% Check or exclusively reserve a diagnostic campaign execution root.
if nargin<2
    mode='check';
end
assert(ischar(mode) || (isstring(mode) && isscalar(mode)), ...
    'ROR:DiagnosticRootMode','Root guard mode must be scalar text.');
mode=char(mode);
assert(ismember(mode,{'check','reserve'}), ...
    'ROR:DiagnosticRootMode','Unsupported root guard mode: %s',mode);
assert(~isfolder(path) && ~isfile(path), ...
    'ROR:DiagnosticRootExists','Execution root already exists; fail closed.');
if strcmp(mode,'check')
    return
end

parent=fileparts(path);
assert(~isfile(parent),'ROR:DiagnosticParentCreate', ...
    'Execution-root parent is a file and cannot be created: %s',parent);
if ~isfolder(parent)
    [created,message]=mkdir(parent);
    assert(created && isfolder(parent),'ROR:DiagnosticParentCreate', ...
        'Cannot create execution-root parent %s: %s',parent,message);
end

reservation=java.io.File(path);
assert(reservation.mkdir(),'ROR:DiagnosticRootReservation', ...
    'Cannot exclusively reserve execution root: %s',path);
end
