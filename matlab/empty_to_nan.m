function in = empty_to_nan(in)
% EMPTY_TO_NAN replaces EMPTY_FLOAT values in input double array by NaNs
%
% A. Merle (SPC-EPFL) - 16.04.2019

EMPTY_FLOAT = -9e40;

mask = (in == EMPTY_FLOAT);
in(mask) = NaN;

end