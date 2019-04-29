function in = nan_to_empty(in)
% NAN_TO_EMPTY replaces NaN in input double array by EMPTY_FLOAT (=-9e40)
%
% A. Merle (SPC-EPFL) - 16.04.2019

EMPTY_FLOAT = -9e40;

mask = isnan(in);
in(mask) = EMPTY_FLOAT;

end