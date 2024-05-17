% uri = imas_build_uri_from_legacy_parameters (backend_id, pulse, run, user, tokamak, version [, options])
%
% Open the Data Entry defined by the provided parameters.
%
% Args:
%   backend_id: ID of the backend to use. Available options:
%
%               - 11: :ref:`ASCII backend`
%               - 12: :ref:`MDSplus backend`
%               - 13: :ref:`HDF5 backend`
%               - 14: :ref:`Memory backend`
%               - 15: :ref:`UDA backend`
%   pulse:      Pulse number.
%   run:        Run number.
%   user:       User name
%   tokamak:    Tokamak name, also known as Database name
%   version:    Major version of the data dictionary, e.g. "3"
%   options:    Deprecated, available for backwards compatibility
%
% Returns:
%   URI
