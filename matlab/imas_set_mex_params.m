% imas_set_mex_params(name, value, ...)
% imas_set_mex_params(struct)
% Set parameters for IMAS MEX interface
%
% name, value: list of parameter name/value pairs
% struct: structure with fields corresponding to parameter names
%
% List of current valid parameters:
%   - get_int_as_double
%   - put_int_from_double
%   - get_empty_as_nan
%   - put_empty_from_nan
%   - use_cell_array_for_array_of_structures
%   - convert_whole_ids [OBSOLETE: value will be ignored, the present behavior
%                        corresponds to the old default value (false)]
%   - error_on_missing_field
%   - verbosity
%
% A. Merle (SPC-EPFL) - 16.04.2019