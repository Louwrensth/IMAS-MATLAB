% ids_put_slice(expIdx, IDSpath[, occurence], IDS)
%
% Append a time slice of the provided IDS to the Database Entry.
%
% Time slices must be appended in strictly increasing time order, since the
% Access Layer is not reordering time arrays. Doing otherwise will result in
% non-monotonic time arrays, which will create confusion and make subsequent
% get_slice() commands to fail.
%
% Although being put progressively time slice by time slice, the final IDS must
% be compliant with the data dictionary. A typical error when constructing IDS
% variables time slice by time slice is to change the size of the IDS fields
% during the time loop, which is not allowed but for the children of an array
% of structure which has time as its coordinate.
%
% The put_slice() command is appending data, so does not modify previously
% existing data within the target IDS occurrence in the Data Entry.
%
% It is possible possible to append several time slices to a node of the IDS
% in one put_slice() call, however the user must ensure that the size of the
% time dimension of the node remains consistent with the size of its timebase.
%
% Args:
%   expIdx:     Data entry context created with
%               imas_open_uri, imas_open_env, imas_open_env_backend,
%               imas_create_env or imas_create_env_backend.
%   IDSpath:    Name of the IDS to store, e.g. 'core_profiles'.
%   occurence:  Which occurrence of the IDS to read. Defaults to 0.
%   IDS:        The IDS to store.
