% is_defined = ids_isdefined(ids)
%
%
% Verifies if given IDS is 'defined' by checking if its field `ids_properties.homogeneous_time` is set to a valid value
%
% Args:
%   ids:        IDS to check.
%
% Example:
%   .. code-block:: matlab
%
%       magnetics_ids = ids_gen('magnetics')
%       is_defined = ids_isdefined(magnetics_ids) %false
%       % set the ids_properties.homogeneous_time field
%       magnetics_ids.ids_properties.homogeneous_time = 1
%       is_defined = ids_isdefined(magnetics_ids) %true
%