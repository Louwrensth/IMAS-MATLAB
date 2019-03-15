
/*
 * imas_open_env.c - open IMAS database in MATLAB External Interfaces
 *
 *              idx = imas_open_env(name, shot, run, user, tokamak, version)
 *
 * This is a MEX file for MATLAB.
 */
#include "mex.h"
#include "imas_mex_utils.h"
#include "ual_low_level.h"
#include <string.h>

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
    // Check for six input arguments  
    if (nrhs != 6) {
        mexErrMsgIdAndTxt("IMAS:imas_open_env:nargin", "Six inputs required.");
    }
    // make sure the 1st input argument is a string
    if (!mxIsChar(prhs[0])) {
        mexErrMsgIdAndTxt("IMAS:imas_open_env:notChar", "Input name must be a string.");
    }
    // make sure the 2nd input argument is scalar
    if (!mxIsNumeric(prhs[1]) || !mxIsScalar(prhs[1])) {
        mexErrMsgIdAndTxt("IMAS:imas_open_env:notScalar", "Input shot must be a scalar.");
    }
    // make sure the 3rd input argument is scalar
    if (!mxIsNumeric(prhs[2]) || !mxIsScalar(prhs[2])) {
        mexErrMsgIdAndTxt("IMAS:imas_open_env:notScalar", "Input run must be a scalar.");
    }
    // make sure the 4th input argument is a string
    if (!mxIsChar(prhs[3])) {
        mexErrMsgIdAndTxt("IMAS:imas_open_env:notChar", "Input user must be a string.");
    }
    // make sure the 5th input argument is a string
    if (!mxIsChar(prhs[4])) {
        mexErrMsgIdAndTxt("IMAS:imas_open_env:notChar", "Input tokamak must be a string.");
    }
    // make sure the 6th input argument is a string
    if (!mxIsChar(prhs[5])) {
        mexErrMsgIdAndTxt("IMAS:imas_open_env:notChar", "Input version must be a string.");
    }
    // Check for one output argument
    if (nlhs != 1) {
        mexErrMsgIdAndTxt("IMAS:imas_open_env:nargout", "One output required.");
    }
    // Get the value of the name
    char *name = mxArrayToString(prhs[0]);
#ifdef MEX_DEBUG
    mexPrintf("The input name is:  %s\n", name);
#endif

    // Get the value of the shot
    int shot = (int) mxGetScalar(prhs[1]);
#ifdef MEX_DEBUG
    mexPrintf("The input shot is:  %d\n", shot);
#endif

    // Get the value of the run
    int run = (int) mxGetScalar(prhs[2]);
#ifdef MEX_DEBUG
    mexPrintf("The input run is:  %d\n", run);
#endif

    // Get the value of the user
    char *user = mxArrayToString(prhs[3]);
#ifdef MEX_DEBUG
    mexPrintf("The input user is:  %s\n", user);
#endif

    // Get the value of the tokamak
    char *tokamak = mxArrayToString(prhs[4]);
#ifdef MEX_DEBUG
    mexPrintf("The input tokamak is:  %s\n", tokamak);
#endif

    // Get the value of the version
    char *version = mxArrayToString(prhs[5]);
#ifdef MEX_DEBUG
    mexPrintf("The input version is:  %s\n", version);
#endif

    int idx;
    int status = ual_open_env("ids", shot, run, &idx, user, tokamak, version);
    if (status != 0) {
        mexErrMsgIdAndTxt("IMAS:imas_open_env:Failed", "Error opening imas shot %d, run %d\n\tuser %s, tokamak %s, version %s: %s", shot, run, user, tokamak, version, ual_last_errmsg());
    }
    // Prepare the return argument
    plhs[0] = mxCreateDoubleScalar(idx);

}
