
/*
 * imas_open_public.c - open IMAS database in MATLAB External Interfaces
 *
 *              idx = imas_open_public(name, shot, run, expName)
 *
 * This is a MEX file for MATLAB.
 */
#include "imas_mex_utils.h"

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
    // Check for six input arguments  
    if (nrhs != 4) {
        mexErrMsgIdAndTxt("IMAS:imas_open_public:nargin", "Four inputs required.");
    }
    // make sure the 1st input argument is a string
    if (!mxIsChar(prhs[0])) {
        mexErrMsgIdAndTxt("IMAS:imas_open_public:notChar", "Input name must be a string.");
    }
    // make sure the 2nd input argument is scalar
    if (!mxIsNumeric(prhs[1]) || !mxIsScalar(prhs[1])) {
        mexErrMsgIdAndTxt("IMAS:imas_open_public:notScalar", "Input shot must be a scalar.");
    }
    // make sure the 3rd input argument is scalar
    if (!mxIsNumeric(prhs[2]) || !mxIsScalar(prhs[2])) {
        mexErrMsgIdAndTxt("IMAS:imas_open_public:notScalar", "Input run must be a scalar.");
    }
    // make sure the 4th input argument is a string
    if (!mxIsChar(prhs[3])) {
        mexErrMsgIdAndTxt("IMAS:imas_open_public:notChar", "Input expName must be a string.");
    }
    // Check for one output argument
    if (nlhs > 1) {
        mexErrMsgIdAndTxt("IMAS:imas_open_public:nargout", "One output maximum required.");
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

    // Get the value of the expName
    char *expName = mxArrayToString(prhs[3]);
    if (params.verbosity >= 4)
        mexPrintf("The input expName is:  %s\n", expName);

    int idx;
    int status;

    idx = ual_begin_pulse_action(UDA_BACKEND, shot, run, 
				 "", "", ""); 

    if (idx < 0)
      status = idx;
    else
      status = ual_open_pulse(idx, OPEN_PULSE, "");

    if (status != 0) {
        mexErrMsgIdAndTxt("IMAS:imas_open_public:Failed", "Error opening imas shot %d, run %d expName %s", shot, run, expName);
    }
    // Prepare the return argument
    plhs[0] = mxCreateDoubleScalar(idx);

}
