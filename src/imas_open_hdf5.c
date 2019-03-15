
/*
 * imas_open_hdf5.c - open IMAS database in MATLAB External Interfaces
 *
 *              idx = imas_open_hdf5(name, shot, run)
 *
 * This is a MEX file for MATLAB.
 */
#include "mex.h"
#include "ual_low_level.h"
#include <string.h>

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
    // Check for three input arguments  
    if (nrhs != 3) {
        mexErrMsgIdAndTxt("IMAS:imas_open_hdf5:nargin", "Three inputs required.");
    }
    // make sure the 1st input argument is a string
    if (!mxIsChar(prhs[0])) {
        mexErrMsgIdAndTxt("IMAS:imas_open_hdf5:notChar", "Input name must be a string.");
    }
    // make sure the 2nd input argument is scalar
    if (!mxIsNumeric(prhs[1]) || !mxIsScalar(prhs[1])) {
        mexErrMsgIdAndTxt("IMAS:imas_open_hdf5:notScalar", "Input shot must be a scalar.");
    }
    // make sure the 3rd input argument is scalar
    if (!mxIsNumeric(prhs[2]) || !mxIsScalar(prhs[2])) {
        mexErrMsgIdAndTxt("IMAS:imas_open_hdf5:notScalar", "Input run must be a scalar.");
    }
    // Check for one output argument
    if (nlhs != 1) {
        mexErrMsgIdAndTxt("IMAS:imas_open_hdf5:nargout", "One output required.");
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

    int idx;
    int status = imas_open_hdf5("ids", shot, run, &idx);
    if (status != 0) {
        mexErrMsgIdAndTxt("IMAS:imas_open_hdf5:Failed", "Error opening imas shot %d, run %d: %s", shot, run, imas_last_errmsg());
    }
    // Prepare the return argument
    plhs[0] = mxCreateDoubleScalar(idx);

}
