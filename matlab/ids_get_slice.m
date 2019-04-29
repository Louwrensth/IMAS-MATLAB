% Out = ids_get_slice(expIdx, IDSpath[, occurence], time, interp)
% 
% retrieves the IDS slice in the open database corresponding to the
% passed time, based on the selected interpolation mode.
% 
% expIdx   : index to database, returned by imas_open/imas_create.
% IDSpath  : the IDS/occurrence to retrieve.
% occurence: 
% time     : retrieval time.
% interp   : interpolation method. Allowed values are :
%            CLOSEST_SAMPLE = 1, PREVIOUS_SAMPLE = 2 or INTERPOLATION = 3