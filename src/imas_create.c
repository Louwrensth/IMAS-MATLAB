
/*
 * imas_create.c - create IMAS database in MATLAB External Interfaces
 *
 *              idx = imas_create(name, shot, run, refShot, refRun)
 *
 * This is a MEX file for MATLAB.
 */
#include "imas_mex_utils.h"

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
    // Check for three input arguments  
    if (nrhs != 5) {
        mexErrMsgIdAndTxt("IMAS:imas_create:nargin", "Five inputs required.");
    }
    // make sure the 1st input argument is a string
    if (!mxIsChar(prhs[0])) {
        mexErrMsgIdAndTxt("IMAS:imas_create:notChar", "Input name must be a string.");
    }
    // make sure the 2nd input argument is scalar
    if (!mxIsNumeric(prhs[1]) || !mxIsScalar(prhs[1])) {
        mexErrMsgIdAndTxt("IMAS:imas_create:notScalar", "Input shot must be a scalar.");
    }
    // make sure the 3rd input argument is scalar
    if (!mxIsNumeric(prhs[2]) || !mxIsScalar(prhs[2])) {
        mexErrMsgIdAndTxt("IMAS:imas_create:notScalar", "Input run must be a scalar.");
    }
    // make sure the 4th input argument is scalar
    if (!mxIsNumeric(prhs[3]) || !mxIsScalar(prhs[3])) {
        mexErrMsgIdAndTxt("IMAS:imas_create:notScalar", "Input refShot must be a scalar.");
    }
    // make sure the 5th input argument is scalar
    if (!mxIsNumeric(prhs[4]) || !mxIsScalar(prhs[4])) {
        mexErrMsgIdAndTxt("IMAS:imas_create:notScalar", "Input refRun must be a scalar.");
    }
    // Check for one output argument
    if (nlhs > 1) {
        mexErrMsgIdAndTxt("IMAS:imas_create:nargout", "One output mximum required.");
    }
    // Get the value of the name
    char *name = mxArrayToString(prhs[0]);
    if (params.verbosity >= 4)
        mexPrintf("The input name is:  %s\n", name);

    // Get the value of the shot
    int shot = (int) mxGetScalar(prhs[1]);
    if (params.verbosity >= 4)
        mexPrintf("The input shot is:  %d\n", shot);

    // Get the value of the run
    int run = (int) mxGetScalar(prhs[2]);
    if (params.verbosity >= 4)
        mexPrintf("The input run is:  %d\n", run);

    // Get the value of the refShot
    int refShot = (int) mxGetScalar(prhs[3]);
    if (params.verbosity >= 4)
        mexPrintf("The input refShot is:  %d\n", refShot);

    // Get the value of the refRun
    int refRun = (int) mxGetScalar(prhs[4]);
    if (params.verbosity >= 4)
        mexPrintf("The input refRun is:  %d\n", refRun);

    int idx;
    int status;

    idx = ual_begin_pulse_action(MDSPLUS_BACKEND, shot, run, 
				 "", "", ""); 

    if (idx < 0)
      status = idx;
    else
      status = ual_open_pulse(idx, FORCE_CREATE_PULSE, "");

    if (status != 0) {
        mexErrMsgIdAndTxt("IMAS:imas_create:Failed", "Error creating imas shot %d, run %d", shot, run);
    }
    // Prepare the return argument
    plhs[0] = mxCreateDoubleScalar(idx);

}
