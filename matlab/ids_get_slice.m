% out = ids_get_slice(expIdx, IDSpath[, occurence], time, interp)
% 
% Read a single time slice from an IDS in this Database Entry.
%
% This method fetches the IDS object with all constant/static data filled.
% The dynamic data is interpolated on the requested time slice. This means
% that the size of the time dimension in the returned data is 1.
% 
% Args:
%   expIdx:     Data entry context created with
%               imas_open_uri, imas_open_env, imas_open_env_backend,
%               imas_create_env or imas_create_env_backend.
%   IDSpath:    Name of the IDS to retrieve, e.g. 'core_profiles'.
%   occurence:  Which occurrence of the IDS to read. Defaults to 0.
%   time:       Requested time slice.
%   interp:     interpolation method. Allowed values are:
%               CLOSEST_SAMPLE = 1, PREVIOUS_SAMPLE = 2 or INTERPOLATION = 3
%
% Returns:
%   The loaded IDS.
