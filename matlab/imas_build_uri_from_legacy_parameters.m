% uri = imas_build_uri_from_legacy_parameters (backend_id, pulse, run, user, database, version [, options])
%
% Creates an URI string from legacy parameters
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
%   database:   Name of IMAS database
%   version:    Major version of the data dictionary, e.g. "3"
%   options:    Deprecated, available for backwards compatibility
%
% Returns:
%   URI
