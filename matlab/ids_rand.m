% ids_rand(IDSname, ntime, slice)
% 
% Generate an IDS structure with a given number of time slices.
% 
% IDSname : name of the IDS to generate.
% ntime   : number of time slices requested.
% slice   : flag requesting that a single time slice be
%           returned. If slice=0 then the full time-dependent array
%           is returned. If slice>0 then the (slice)th time slice
%           is returned. If slice<0 or slice>ntime, an error is triggered.
%
% NOTE: When slice is selected, the full time-dependent arrays for
% each fields are generated to ensure that the RNG will be in the
% same state for each field when slice is selected or not. This
% ensures that when slice is selected we obtain the same data as if
% we had generated the full time array and manually selected the
% first slice. This first slice depends however on the value of
% ntime.