% data = imas_serialize(ids, ids_name[, protocol])
%
% Serialize the contents of this IDS into binary data.
%
% There are currently two different serialization protocols. The ASCII protocol
% serializes the data though the ASCII backend. This is a simpler human readable
% protocol, but it's also less efficient than the (newer) Flexbuffers protocol.
% The latter is the default and should be preferred.
%
% The ID of the used serializer protocol is kept in the header of the serialized
% buffer, such that specifying the protocol is not necessary when deserializing.
%
% Args:
%   ids:        IDS to serialize.
%   ids_name:   Name of the ids.
%   protocol:   Protocol type (default: DEFAULT_SERIALIZER_PROTOCOL)
%
% Example:
%   .. code-block:: matlab
%
%       ids = ids_init('pf_active')
%       % populate the IDS
%       % ...
%       data = imas_serialize(ids, 'pf_active')
%
%       % move the binary data around, for example to another process using
%       % memory communication, then deserialize
%       pf_active2 = imas_deserialize(data, 'pf_active')

ASCII_SERIALIZER_PROTOCOL = 60;
FLEXBUFFERS_SERIALIZER_PROTOCOL = 61;
DEFAULT_SERIALIZER_PROTOCOL = 61
