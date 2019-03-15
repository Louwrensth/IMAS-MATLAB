
/*
 * imas_close.c - close IMAS database in MATLAB External Interfaces
 *
 *              idx = imas_close(idx)
 *
 * This is a MEX file for MATLAB.
 */
#include "mex.h"
#include "ual_low_level.h"
#include <string.h>

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
    // Check for three input arguments  
    if (nrhs != 1) {
        mexErrMsgIdAndTxt("IMAS:imas_close:nargin", "One input required.");
    }
    // make sure the 1st input argument is scalar
    if (!mxIsNumeric(prhs[0]) || !mxIsScalar(prhs[0])) {
        mexErrMsgIdAndTxt("IMAS:imas_close:notScalar", "Input idx must be a scalar.");
    }
    // Check for no output argument
    if (nlhs != 0) {
        mexErrMsgIdAndTxt("IMAS:imas_create:nargout", "Zero output required.");
    }
    // Get the value of the index
    int idx = (int) mxGetScalar(prhs[0]);
#ifdef MEX_DEBUG
    mexPrintf("The input idx is:  %d\n", idx);
#endif

    if (idx != -1)
        imas_close(idx);

}
