% data = imas_serialize(ids, ids_name[, protocol])
%
% Serialize the contents of this IDS into binary data.
%
% While it is by design allowed to specify various serialization
% protocols, it currently implements only a serialization through usage of
% the ASCII backend (simpler but less efficient) which is de-facto the
% default serializer protocol. The ID of the used serializer protocol is
% kept in the serialized buffer, such that specifying the protocol is not
% necessary when deserializing.
%
% Args:
%   ids:        IDS to serialize.
%   ids_name:   Name of the ids.
%   protocol:   Protocol type (default: ASCII_SERIALIZER_PROTOCOL = 60)
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

ASCII_SERIALIZER_PROTOCOL= 60;
