/** \defgroup interface MEX-interface
 * MEX functions defined in the MEX HLI.
 *  @{
 */

/**
   \file imas_open_env.c
   open IMAS database using the MDSplus backend in MATLAB External Interfaces
   
   This is a MEX file for MATLAB.

   Usage:
   \code{.m} 
   idx = imas_open_env(name, shot, run, user, tokamak, version)
   \endcode

   MATLAB help:
   \include matlab/imas_open_env.m
 */

/** @}*/

#include "imas_mex_utils.h"

/**
   Entry point to C/C++ MEX function built with C Matrix API
 */
void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
    /* Check for six input arguments   */
    if (nrhs != 6) {
        mexErrMsgIdAndTxt("IMAS:imas_open_env:nargin", "Six inputs required.");
    }
    /* make sure the 1st input argument is a string */
    if (!mxIsChar(prhs[0])) {
        mexErrMsgIdAndTxt("IMAS:imas_open_env:notChar", "Input name must be a string.");
    }
    /* make sure the 2nd input argument is scalar */
    if (!mxIsNumeric(prhs[1]) || !mxIsScalar(prhs[1])) {
        mexErrMsgIdAndTxt("IMAS:imas_open_env:notScalar", "Input shot must be a scalar.");
    }
    /* make sure the 3rd input argument is scalar */
    if (!mxIsNumeric(prhs[2]) || !mxIsScalar(prhs[2])) {
        mexErrMsgIdAndTxt("IMAS:imas_open_env:notScalar", "Input run must be a scalar.");
    }
    /* make sure the 4th input argument is a string */
    if (!mxIsChar(prhs[3])) {
        mexErrMsgIdAndTxt("IMAS:imas_open_env:notChar", "Input user must be a string.");
    }
    /* make sure the 5th input argument is a string */
    if (!mxIsChar(prhs[4])) {
        mexErrMsgIdAndTxt("IMAS:imas_open_env:notChar", "Input tokamak must be a string.");
    }
    /* make sure the 6th input argument is a string */
    if (!mxIsChar(prhs[5])) {
        mexErrMsgIdAndTxt("IMAS:imas_open_env:notChar", "Input version must be a string.");
    }
    /* Check for one output argument */
    if (nlhs > 1) {
        mexErrMsgIdAndTxt("IMAS:imas_open_env:nargout", "One output maximum required.");
    }
    /* Get the value of the name */
    char *name = mxArrayToString(prhs[0]);
    if (params.verbosity >= 4)
        mexPrintf("The input name is:  %s\n", name);

    /* Get the value of the shot */
    int shot = (int) mxGetScalar(prhs[1]);
    if (params.verbosity >= 4)
        mexPrintf("The input shot is:  %d\n", shot);

    /* Get the value of the run */
    int run = (int) mxGetScalar(prhs[2]);
    if (params.verbosity >= 4)
        mexPrintf("The input run is:  %d\n", run);

    /* Get the value of the user */
    char *user = mxArrayToString(prhs[3]);
    if (params.verbosity >= 4)
        mexPrintf("The input user is:  %s\n", user);

    /* Get the value of the tokamak */
    char *tokamak = mxArrayToString(prhs[4]);
    if (params.verbosity >= 4)
        mexPrintf("The input tokamak is:  %s\n", tokamak);

    /* Get the value of the version */
    char *version = mxArrayToString(prhs[5]);
    if (params.verbosity >= 4)
        mexPrintf("The input version is:  %s\n", version);

    int idx;
    al_status_t status;

    status = ual_begin_pulse_action(MDSPLUS_BACKEND, shot, run, 
				 user, tokamak, version, &idx); 

    if (status.code >= 0)
      status = ual_open_pulse(idx, OPEN_PULSE, "");

    if (status.code < 0)
      mexErrMsgIdAndTxt("IMAS:imas_open_env:Failed", "Error opening imas shot %d, run %d\n\tuser %s, tokamak %s, version %s:\n\t%s", shot, run, user, tokamak, version, status.message);
    /* Prepare the return argument */
    plhs[0] = mxCreateDoubleScalar(idx);

}
