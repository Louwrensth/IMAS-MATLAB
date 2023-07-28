/** \defgroup interface MEX-interface
 * MEX functions defined in the MEX HLI.
 *  @{
 */

/**
   \file imas_open.c
   open IMAS database using an URI in MATLAB External Interfaces
   
   This is a MEX file for MATLAB.

   Usage:
   \code{.m} 
   idx = imas_open(uri, mode)
   \endcode

   MATLAB help:
   \include matlab/imas_open.m
 */

/** @}*/

#include "imas_mex_utils.h"

/**
   Entry point to C/C++ MEX function built with C Matrix API
 */
void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
    /* Check for one or two input arguments   */
    if (nrhs != 1 && nrhs != 2) {
        mexErrMsgIdAndTxt("IMAS:imas_open:nargin", "One or two inputs required.");
    }
    /* make sure the 1st input argument is a string */
    if (!mxIsChar(prhs[0])) {
        mexErrMsgIdAndTxt("IMAS:imas_open:notChar", "URI must be a string.");
    }
    
    /* Check for one output argument */
    if (nlhs > 1) {
        mexErrMsgIdAndTxt("IMAS:imas_open:nargout", "One output maximum required.");
    }
    /* Get the value of the name */
    char *uri = mxArrayToString(prhs[0]);
    if (params.verbosity >= 4)
        mexPrintf("The URI is:  %s\n", uri);

    /* Get the value of the mode */
    int mode = OPEN_PULSE;
    if (nrhs == 2){ 
        /* make sure the 2nd input argument is scalar */
        if (!mxIsNumeric(prhs[1]) || !mxIsScalar(prhs[1])) {
            mexErrMsgIdAndTxt("IMAS:imas_open:notScalar", "File access mode must be a scalar.");
        }
        mode = (int) mxGetScalar(prhs[1]);
        if (params.verbosity >= 4)
            mexPrintf("The mode is:  %d\n", mode);
    } 

    int idx;
    al_status_t status;
    
    status = al_begin_dataentry_action(uri, mode, &idx);

    if (status.code < 0)
      mexErrMsgIdAndTxt("IMAS:imas_open:Failed", "Error opening imas URI %s with mode %d:\n\t%s", uri, mode, status.message);
    /* Prepare the return argument */
    plhs[0] = mxCreateDoubleScalar(idx);

}
