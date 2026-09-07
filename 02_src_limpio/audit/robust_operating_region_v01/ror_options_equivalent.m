function [is_equivalent, canonical_expected, canonical_observed] = ...
        ror_options_equivalent(expected_options, observed_options)
%ROR_OPTIONS_EQUIVALENT Compare frozen and observed options fail-closed.
% MATLAB R2026a normalizes PopulationType "doubleVector" to
% "doublevector"; comparison canonicalization is restricted to this
% enumerated option representation.

canonical_expected = expected_options;
canonical_observed = observed_options;
canonical_expected.PopulationType = canonical_population_type( ...
    canonical_expected.PopulationType);
canonical_observed.PopulationType = canonical_population_type( ...
    canonical_observed.PopulationType);
is_equivalent = isequaln(canonical_observed, canonical_expected);
end

function value = canonical_population_type(value)
if (ischar(value) && (strcmp(value,'doubleVector') || strcmp(value,'doublevector'))) || ...
        (isstring(value) && isscalar(value) && ...
        (value == "doubleVector" || value == "doublevector"))
    value = 'doublevector';
end
end
