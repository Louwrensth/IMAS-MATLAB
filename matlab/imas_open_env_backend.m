% idx = imas_open_env_backend (shot, run, user, tokamak, version, backend_id)
%
% Open the Data Entry defined by the provided parameters.
%
% Args:
%   shot:       Shot number.
%   run:        Run number.
%   user:       User name
%   tokamak:    Tokamak name, also known as Database name
%   version:    Major version of the data dictionary, e.g. "3"
%   backend_id: ID of the backend to use. Available options:
%
%               - 11: :ref:`ASCII backend`
%               - 12: :ref:`MDSplus backend`
%               - 13: :ref:`HDF5 backend`
%               - 14: :ref:`Memory backend`
%               - 15: :ref:`UDA backend`
%
% Returns:
%   Data Entry index
