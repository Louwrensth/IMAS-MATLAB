
/*
 * imas_get_backendID.c - get backend from opened context in MATLAB External Interfaces
 *
 *              backendID = imas_get_backendID(idx)
 *
 * This is a MEX file for MATLAB.
 */
#include "imas_mex_utils.h"

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
    /* Check for three input arguments   */
    if (nrhs != 1) {
        mexErrMsgIdAndTxt("IMAS:imas_get_backendID:nargin", "One input required.");
    }
    /* make sure the 1st input argument is scalar */
    if (!mxIsNumeric(prhs[0]) || !mxIsScalar(prhs[0])) {
        mexErrMsgIdAndTxt("IMAS:imas_get_backendID:notScalar", "Input idx must be a scalar.");
    }
    /* Check for one output argument */
    if (nlhs > 1) {
        mexErrMsgIdAndTxt("IMAS:imas_get_backendID:nargout", "One output maximum required.");
    }
    /* Get the value of the index */
    int idx = (int) mxGetScalar(prhs[0]);
    if (params.verbosity >= 4)
        mexPrintf("The input idx is:  %d\n", idx);

    plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
    if (idx != -1)
      *(int *)mxGetData(plhs[0]) = ual_get_backendID(idx);

}
