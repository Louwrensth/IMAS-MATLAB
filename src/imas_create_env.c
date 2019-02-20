
/*
 * imas_create_env.c - create IMAS database in MATLAB External Interfaces
 *
 *              idx = imas_create_env(name, shot, run, refShot, refRun, user, tokamak, version)
 *
 * This is a MEX file for MATLAB.
 */
#include "mex.h"
#include "ual_low_level.h"
#include <string.h>

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
    // Check for six input arguments  
    if (nrhs != 8) {
        mexErrMsgIdAndTxt("IMAS:imas_create_env:nargin", "Eight inputs required.");
    }
    // make sure the 1st input argument is a string
    if (!mxIsChar(prhs[0])) {
        mexErrMsgIdAndTxt("IMAS:imas_create_env:notChar", "Input name must be a string.");
    }
    // make sure the 2nd input argument is scalar
    if (!mxIsNumeric(prhs[1]) || !mxIsScalar(prhs[1])) {
        mexErrMsgIdAndTxt("IMAS:imas_create_env:notScalar", "Input shot must be a scalar.");
    }
    // make sure the 3rd input argument is scalar
    if (!mxIsNumeric(prhs[2]) || !mxIsScalar(prhs[2])) {
        mexErrMsgIdAndTxt("IMAS:imas_create_env:notScalar", "Input run must be a scalar.");
    }
    // make sure the 4th input argument is scalar
    if (!mxIsNumeric(prhs[3]) || !mxIsScalar(prhs[3])) {
        mexErrMsgIdAndTxt("IMAS:imas_create:notScalar", "Input refShot must be a scalar.");
    }
    // make sure the 5th input argument is scalar
    if (!mxIsNumeric(prhs[4]) || !mxIsScalar(prhs[4])) {
        mexErrMsgIdAndTxt("IMAS:imas_create:notScalar", "Input refRun must be a scalar.");
    }
    // make sure the 6th input argument is a string
    if (!mxIsChar(prhs[5])) {
        mexErrMsgIdAndTxt("IMAS:imas_create_env:notChar", "Input user must be a string.");
    }
    // make sure the 7th input argument is a string
    if (!mxIsChar(prhs[6])) {
        mexErrMsgIdAndTxt("IMAS:imas_create_env:notChar", "Input tokamak must be a string.");
    }
    // make sure the 8th input argument is a string
    if (!mxIsChar(prhs[7])) {
        mexErrMsgIdAndTxt("IMAS:imas_create_env:notChar", "Input version must be a string.");
    }
    // Check for one output argument
    if (nlhs != 1) {
        mexErrMsgIdAndTxt("IMAS:imas_create_env:nargout", "One output required.");
    }
    // Get the value of the name
    char *name = mxArrayToString(prhs[0]);
#ifndef NDEBUG
    mexPrintf("The input name is:  %s\n", name);
#endif

    // Get the value of the shot
    int shot = (int) mxGetScalar(prhs[1]);
#ifndef NDEBUG
    mexPrintf("The input shot is:  %d\n", shot);
#endif

    // Get the value of the run
    int run = (int) mxGetScalar(prhs[2]);
#ifndef NDEBUG
    mexPrintf("The input run is:  %d\n", run);
#endif

    // Get the value of the refShot
    int refShot = (int) mxGetScalar(prhs[3]);
#ifndef NDEBUG
    mexPrintf("The input refShot is:  %d\n", refShot);
#endif

    // Get the value of the refRun
    int refRun = (int) mxGetScalar(prhs[4]);
#ifndef NDEBUG
    mexPrintf("The input refRun is:  %d\n", refRun);
#endif

    // Get the value of the user
    char *user = mxArrayToString(prhs[5]);
#ifndef NDEBUG
    mexPrintf("The input user is:  %s\n", user);
#endif

    // Get the value of the tokamak
    char *tokamak = mxArrayToString(prhs[6]);
#ifndef NDEBUG
    mexPrintf("The input tokamak is:  %s\n", tokamak);
#endif

    // Get the value of the version
    char *version = mxArrayToString(prhs[7]);
#ifndef NDEBUG
    mexPrintf("The input version is:  %s\n", version);
#endif

    int idx;
    int status = imas_create_env("ids", shot, run, refShot, refRun, &idx, user, tokamak, version);
    if (status != 0) {
        mexErrMsgIdAndTxt("IMAS:imas_create_env:Failed", "Error creating imas shot %d, run %d\n\tuser %s, tokamak %s, version %s: %s", shot, run, user, tokamak, version, imas_last_errmsg());
    }
    // Prepare the return argument
    plhs[0] = mxCreateDoubleScalar(idx);

}
