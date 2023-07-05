% idx = imas_open_uri ( uri [, mode] )
%
% Open or create the Data Entry at the provided URI.
%
% Args:
%   uri:    URI
%   mode:   Low level IMAS pulse file access mode. Available options:
%
%           - 40: ``OPEN_PULSE`` (default).
%             Opens the access to the data only if the Data Entry exists,
%             returns error otherwise.
%           - 41: ``FORCE_OPEN_PULSE``.
%             Opens access to the data, creates the Data Entry if it does not
%             exists yet.
%           - 42: ``CREATE_PULSE``.
%             Creates a new empty Data Entry (returns error if Data Entry
%             already exists) and opens it at the same time.
%           - 43: ``FORCE_CREATE_PULSE``.
%             Creates an empty Data Entry (overwrites if Data Entry already
%             exists) and opens it at the same time.
%
% Returns:
%   Data Entry index
