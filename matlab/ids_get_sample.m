% out = ids_get_sample(expIdx, IDSpath[, occurence], tmin, tmax, dtime, interp)
% 
% Read the contents of an IDS over a specific time range into memory.
%
% This method fetches an IDS with all time slices in a time range between tmin and tmax.
%
% 1. In case of no interpolation in the time range, interp must be set to 0 and dtime = [].
%
%    This mode returns an IDS object with all constant/static data filled. The
%    dynamic data is retrieved for the provided time range [tmin, tmax].
%
% 2. The method can interpolate time slices in the time range, if interp is not set to 0 and dtime = [step] (double list of size equals 1) where 'step' is the constant time between two slices. 
%
%    This mode will generate an IDS with a homogeneous time vector [tmin, tmin + dtime, tmin + 2*dtime, ...] up to tmax. The chosen interpolation
%    method will have no effect on the time vector, but may have an impact on the other dynamic values. 
%    The returned IDS always has 'ids_properties.homogeneous_time = 1'.
%    
% 3. Interpolation of dynamic data on an explicit time base. This method is selected when dtime and interp are provided. dtime must be a double list of size larger than 1.
%
%    This mode will generate an IDS with a homogeneous time vector equal to dtime. tmin and tmax are ignored in this mode.
%    The chosen interpolation method will have no effect on the time vector, but may have an impact on the other dynamic values. The returned IDS always has
%    'ids_properties.homogeneous_time = 1'.
%
% Empty fields within the IDS in the Data Entry are returned with default values.
% 
% Args:
%   expIdx:     Data entry context created with
%               imas_open_uri, imas_open_env, imas_open_env_backend,
%               imas_create_env or imas_create_env_backend.
%   IDSpath:    Name of the IDS to retrieve, e.g. 'core_profiles'.
%   occurence:  Which occurrence of the IDS to read. Defaults to 0.
%   tmin:       Lower bound of the requested time range
%   tmax:       Upper bound of the requested time range, must be larger than or equal to tmin
%   dtime:      Interval to use when interpolating, must be a list
%               containing an explicit time base to interpolate.
%   interp:     interpolation method. Allowed values are:
%               CLOSEST_SAMPLE = 1, PREVIOUS_SAMPLE = 2 or INTERPOLATION = 3
%
% Returns:
%   The loaded IDS.
