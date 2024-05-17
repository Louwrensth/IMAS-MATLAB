/** \defgroup interface MEX-interface
 * MEX functions defined in the MEX HLI.
 *  @{
 */

/**
   \file imas_build_uri_from_legacy_parameters.c
   open IMAS database using an URI in MATLAB External Interfaces
   
   This is a MEX file for MATLAB.

   Usage:
   \code{.m} 
   uri = imas_build_uri_from_legacy_parameters(backend_id, pulse, run, user, tokamak, version, options)
   \endcode

   MATLAB help:
   \include matlab/imas_build_uri_from_legacy_parameters.m
 */

/** @}*/

#include "imas_mex_utils.h"

/**
   Entry point to C/C++ MEX function built with C Matrix API
 */
void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{

    /* Check for six or seven input arguments   */
    if (nrhs != 6 && nrhs != 7) {
        mexErrMsgIdAndTxt("IMAS:imas_build_uri_from_legacy_parameters:nargin", "Six or seven inputs required.");
    }
    /* make sure the 1st input argument is scalar */
    if (!mxIsNumeric(prhs[0]) || !mxIsScalar(prhs[0])) {
        mexErrMsgIdAndTxt("IMAS:imas_build_uri_from_legacy_parameters:notScalar", "Input backend_id must be a scalar.");
    }
    /* make sure the 2nd input argument is scalar */
    if (!mxIsNumeric(prhs[1]) || !mxIsScalar(prhs[1])) {
        mexErrMsgIdAndTxt("IMAS:imas_build_uri_from_legacy_parameters:notScalar", "Input pulse must be a scalar.");
    }
    /* make sure the 3nd input argument is scalar */
    if (!mxIsNumeric(prhs[2]) || !mxIsScalar(prhs[2])) {
        mexErrMsgIdAndTxt("IMAS:imas_build_uri_from_legacy_parameters:notScalar", "Input run must be a scalar.");
    }
    /* make sure the 4th input argument is a string */
    if (!mxIsChar(prhs[3])) {
        mexErrMsgIdAndTxt("IMAS:imas_build_uri_from_legacy_parameters:notChar", "Input user must be a string.");
    }
    /* make sure the 5th input argument is a string */
    if (!mxIsChar(prhs[4])) {
        mexErrMsgIdAndTxt("IMAS:imas_build_uri_from_legacy_parameters:notChar", "Input tokamak must be a string.");
    }
    /* make sure the 6th input argument is a string */
    if (!mxIsChar(prhs[5])) {
        mexErrMsgIdAndTxt("IMAS:imas_build_uri_from_legacy_parameters:notChar", "Input version must be a string.");
    }
    /* Check for one output argument */
    if (nlhs > 1) {
        mexErrMsgIdAndTxt("IMAS:imas_build_uri_from_legacy_parameters:nargout", "One output maximum required.");
    }

    /* Get the value of the backend_id */
    int backend_id = (int) mxGetScalar(prhs[0]);
    if (params.verbosity >= 4)
        mexPrintf("The input backend_id is:  %d\n", backend_id);

    /* Get the value of the pulse */
    int pulse = (int) mxGetScalar(prhs[1]);
    if (params.verbosity >= 4)
        mexPrintf("The input pulse is:  %d\n", pulse);

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
    
    /* Get the value of the options */
    char* options = "";
    if (nrhs == 7){ 
        /* make sure the 7nd input argument is a string */
        if (!mxIsChar(prhs[6])) {
            mexErrMsgIdAndTxt("IMAS:imas_build_uri_from_legacy_parameters:notChar", "Input options must be a string.");
        }
        options = mxArrayToString(prhs[6]);
        if (params.verbosity >= 4)
            mexPrintf("The input options is:  %s\n", options);
    } 
    
    char* uri;
    al_status_t status;
    status = al_build_uri_from_legacy_parameters(backend_id, pulse, run, user, tokamak, version, options, &uri);

    if (status.code < 0)
      mexErrMsgIdAndTxt("IMAS:imas_build_uri_from_legacy_parameters:Failed",
      "Error building uri from legacy parameters backend_id %d, pulse %d\n\trun %d, user %s, tokamak %s, version %s, options %s:\n\t%s",
      backend_id, pulse, run, user, tokamak, version, options, status.message);
    /* Prepare the return argument */
    plhs[0] = mxCreateString(uri);
}
