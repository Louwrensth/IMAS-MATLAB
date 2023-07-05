% ids_put(expIdx, IDSpath[, occurence], IDS)
%
% Write the contents of an IDS into this Database Entry.
%
% The IDS is written entirely, with all time slices it may contain.
%
% The IDS object can have none or many empty fields, empty fields are ignored
% and remain empty in the data entry. Some fields are required to be filled
% before calling this method, see :ref:`Default values`.
%
% .. caution::
%   The put method deletes any previously existing data within the target IDS
%   occurrence in the Database Entry.
%
% Args:
%   expIdx:     Data entry context created with
%               imas_open_uri, imas_open_env, imas_open_env_backend,
%               imas_create_env or imas_create_env_backend.
%   IDSpath:    Name of the IDS to store, e.g. 'core_profiles'.
%   occurence:  Which occurrence of the IDS to read. Defaults to 0.
%   IDS:        The IDS to store.
