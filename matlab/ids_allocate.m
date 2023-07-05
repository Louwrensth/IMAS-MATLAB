% ids_allocate(IDSname, AOSpath, size)
% 
% Allocate the desired array of structure to the requested size.
% 
% Args:
%   IDSname:    The name of the IDS to modify.
%   AOSpath:    Path to the desired array of structure in the IDS
%               ('/' separated following DD convention)
%   size:       Desired size.
%
% Example:
%   .. code-block:: matlab
%
%       eq = ids_init('equilibrium');
%       eq.time_slice = ids_allocate('equilibrium','time_slice',5);
%       eq.time_slice{1}.profiles_2d = ...
%           ids_allocate('equilibrium','time_slice/profiles_2d',1);
%
% See also : ids_init
