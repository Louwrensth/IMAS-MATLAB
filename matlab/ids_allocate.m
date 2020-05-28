% ids_allocate(IDSname, AOSpath, size)
% 
% Allocate the desired array of structure to the requested size.
% 
% IDSname : the name of the IDS to modify.
% AOSpath : path to the desired array of structure in the IDS ('/' separated following DD
%   convention)
% size    : desired size.
%
% Example:
%    eq = ids_init('equilibrium');
%    eq.time_slice = ids_allocate('equilibrium','time_slice',5);
%    eq.time_slice{1}.profiles_2d = ids_allocate('equilibrium','time_slice/profiles_2d',1);
%
% See also : ids_init
