function ror_extended_root_guard(path)
% Independently testable no-overwrite reservation precondition.
assert(~isfolder(path) && ~isfile(path), ...
    'ROR:DiagnosticRootExists','Execution root already exists; fail closed.');
end
