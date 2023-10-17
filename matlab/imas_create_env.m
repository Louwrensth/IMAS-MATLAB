% idx = imas_create_env(name, pulse, run, refpulse, refrun, user, tokamak, version)
%
% Create a new database entry.
%
% .. caution::
%   This method erases the previous entry if it existed!
%
% Args:
%   name:       Name of the database (by convention 'ids').
%   pulse:      Pulse number.
%   run:        Run number.
%   refpulse:   `not used`
%   refrun:     `not used`
%   user:       User name
%   tokamak:    Tokamak name, also known as Database name
%   version:    Major version of the data dictionary, e.g. "3"
%
% Returns:
%   Data Entry index
