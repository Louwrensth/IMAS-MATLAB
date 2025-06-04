% out = imas_partial_get(expIdx, IDSname, occurence, includes, excludes [, debug])
% 
% Read the partial contents of an IDS into memory.
%
% This method fetches partially the IDS according to 'includes' and 'excludes' queries.

% Returned data have paths included in a set of paths defined by the "includes" 
% minus the paths explicitly removed by the "excludes" queries. 
% An IDS field is returned only if its path matches at least one
% include query and does not match any exclude query.
%
% Empty fields within the IDS in the Data Entry are returned with the
% default values indicated in :ref:`Default values`.
% 
% Args:
%   expIdx:     Data entry context created with
%               imas_open_uri, imas_open_env, imas_open_env_backend,
%               imas_create_env or imas_create_env_backend.
%   IDSname:    Name of the IDS to retrieve, e.g. 'core_profiles'.
%   occurence:  Which occurence of the IDS to read. 
%   includes:   A semicolon separated list of 'include' queries. See partial-get plugin documentation for more details.
%   excludes:   A semicolon separated list of 'exclude' queries. See partial-get plugin documentation for more details.
%   debug:      Optional flag for debugging purposes 
%
% Returns:
%   The loaded IDS.
