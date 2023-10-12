% idx = imas_create_env_backend(pulse, run, user, tokamak, version, backend_id)
%
% Create a new database entry.
%
% .. caution::
%   This method erases the previous entry if it existed!
%
% Args:
%   pulse:      Pulse number.
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
