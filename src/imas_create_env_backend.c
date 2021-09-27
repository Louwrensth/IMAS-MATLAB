/** \addtogroup interface MEX-interface
 *  @{
 */

/**
   \file imas_create_env_backend.c
   create IMAS database using the specified backend id in MATLAB External Interfaces
   
   This is a MEX file for MATLAB.

   Usage:
   \code{.m} 
   idx = imas_create_env_backend(shot, run, user, tokamak, version, backend_id)
   \endcode

   MATLAB help:
   \include matlab/imas_create_env_backend.m
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
        mexErrMsgIdAndTxt("IMAS:imas_create_env_backend:nargin", "Six inputs required.");
    }
    /* make sure the 1st input argument is scalar */
    if (!mxIsNumeric(prhs[0]) || !mxIsScalar(prhs[0])) {
        mexErrMsgIdAndTxt("IMAS:imas_create_env_backend:notScalar", "Input shot must be a scalar.");
    }
    /* make sure the 2nd input argument is scalar */
    if (!mxIsNumeric(prhs[1]) || !mxIsScalar(prhs[1])) {
        mexErrMsgIdAndTxt("IMAS:imas_create_env_backend:notScalar", "Input run must be a scalar.");
    }
    /* make sure the 3rd input argument is a string */
    if (!mxIsChar(prhs[2])) {
        mexErrMsgIdAndTxt("IMAS:imas_create_env_backend:notChar", "Input user must be a string.");
    }
    /* make sure the 4th input argument is a string */
    if (!mxIsChar(prhs[3])) {
        mexErrMsgIdAndTxt("IMAS:imas_create_env_backend:notChar", "Input tokamak must be a string.");
    }
    /* make sure the 5th input argument is a string */
    if (!mxIsChar(prhs[4])) {
        mexErrMsgIdAndTxt("IMAS:imas_create_env_backend:notChar", "Input version must be a string.");
    }
    /* make sure the 6th input argument is scalar */
    if (!mxIsNumeric(prhs[5]) || !mxIsScalar(prhs[5])) {
        mexErrMsgIdAndTxt("IMAS:imas_create_env_backend:notScalar", "Input backend_id must be a scalar.");
    }
    /* Check for one output argument */
    if (nlhs > 1) {
        mexErrMsgIdAndTxt("IMAS:imas_create_env:nargout", "One output maximum required.");
    }

    /* Get the value of the shot */
    int shot = (int) mxGetScalar(prhs[0]);
    if (params.verbosity >= 4)
        mexPrintf("The input shot is:  %d\n", shot);

    /* Get the value of the run */
    int run = (int) mxGetScalar(prhs[1]);
    if (params.verbosity >= 4)
        mexPrintf("The input run is:  %d\n", run);

    /* Get the value of the user */
    char *user = mxArrayToString(prhs[2]);
    if (params.verbosity >= 4)
        mexPrintf("The input user is:  %s\n", user);

    /* Get the value of the tokamak */
    char *tokamak = mxArrayToString(prhs[3]);
    if (params.verbosity >= 4)
        mexPrintf("The input tokamak is:  %s\n", tokamak);

    /* Get the value of the version */
    char *version = mxArrayToString(prhs[4]);
    if (params.verbosity >= 4)
        mexPrintf("The input version is:  %s\n", version);
    
    /* Get the value of the backend */
    int backend_id = (int) mxGetScalar(prhs[5]);
    if (params.verbosity >= 4)
        mexPrintf("The input backend id is:  %d\n", backend_id);

    int idx;
    al_status_t status;

    char* uri;
    ual_build_uri_from_legacy_parameters(backend_id, shot, run, user, tokamak, version, &uri);
    status = ual_begin_dataentry_action(uri, FORCE_CREATE_PULSE, &idx);

    if (status.code != 0)
      mexErrMsgIdAndTxt("IMAS:imas_create_env_backend:Failed", "Error creating imas shot %d, run %d\n\tuser %s, tokamak %s, version %s, backend_id %d:\n\t%s", shot, run, user, tokamak, version, backend_id, status.message);
    /* Prepare the return argument */
    plhs[0] = mxCreateDoubleScalar(idx);

}
