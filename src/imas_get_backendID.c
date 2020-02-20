/** \addtogroup interface MEX-interface
 *  @{
 */

/**
   \file imas_get_backendID.c
   get backend from opened context in MATLAB External Interfaces
   
   This is a MEX file for MATLAB.

   Usage:
   \code{.m} 
   backendID = imas_get_backendID(idx)
   \endcode

   MATLAB help:
   \include matlab/imas_get_backendID.m
 */

/** @}*/

#include "imas_mex_utils.h"

/**
   Entry point to C/C++ MEX function built with C Matrix API
 */
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

    al_status_t status = {0,""};

    plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
    if (idx != -1)
      status = ual_get_backendID(idx, (int *)mxGetData(plhs[0]));

    if (status.code < 0)
      mexErrMsgIdAndTxt("IMAS:imas_get_backendID:Failed", "Error getting backend ID for context %d:\n\t%s", idx, status.message);

}
