% ids = ids_init(IDSname)
% 
% Generate an IDS of specified type with default field values.
% 
% Args:
%   IDSname: name of the IDS to generate.
%
% Returns:
%   Empty IDS of the requested type.
%
% NOTE: The array of structures in the resulting IDS will be
% empty. This is not as in ids_gen where they are all of size 1. Use
% ids_allocate to fill the array of structures.
%
% See also: ids_allocate
