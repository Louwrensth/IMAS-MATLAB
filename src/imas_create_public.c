/** \addtogroup interface MEX-interface
 *  @{
 */

/**
   \file imas_open_public.c
   create IMAS database using the UDA backend in MATLAB External Interfaces
   
   This is a MEX file for MATLAB.

   Usage:
   \code{.m} 
   idx = imas_create_public(name, shot, run, refShot, refRun, expName)
   \endcode

   MATLAB help:
   \include matlab/imas_create_public.m
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
        mexErrMsgIdAndTxt("IMAS:imas_create_public:nargin", "Six inputs required.");
    }
    /* make sure the 1st input argument is a string */
    if (!mxIsChar(prhs[0])) {
        mexErrMsgIdAndTxt("IMAS:imas_create_public:notChar", "Input name must be a string.");
    }
    /* make sure the 2nd input argument is scalar */
    if (!mxIsNumeric(prhs[1]) || !mxIsScalar(prhs[1])) {
        mexErrMsgIdAndTxt("IMAS:imas_create_public:notScalar", "Input shot must be a scalar.");
    }
    /* make sure the 3rd input argument is scalar */
    if (!mxIsNumeric(prhs[2]) || !mxIsScalar(prhs[2])) {
        mexErrMsgIdAndTxt("IMAS:imas_create_public:notScalar", "Input run must be a scalar.");
    }
    /* make sure the 4th input argument is scalar */
    if (!mxIsNumeric(prhs[3]) || !mxIsScalar(prhs[3])) {
        mexErrMsgIdAndTxt("IMAS:imas_create_public:notScalar", "Input refShot must be a scalar.");
    }
    /* make sure the 5th input argument is scalar */
    if (!mxIsNumeric(prhs[4]) || !mxIsScalar(prhs[4])) {
        mexErrMsgIdAndTxt("IMAS:imas_create_public:notScalar", "Input refRun must be a scalar.");
    }
    /* make sure the 6th input argument is a string */
    if (!mxIsChar(prhs[5])) {
        mexErrMsgIdAndTxt("IMAS:imas_create_public:notChar", "Input expName must be a string.");
    }
    /* Check for one output argument */
    if (nlhs > 1) {
        mexErrMsgIdAndTxt("IMAS:imas_create_public:nargout", "One output maximum required.");
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

    /* Get the value of the refShot */
    int refShot = (int) mxGetScalar(prhs[3]);
    if (params.verbosity >= 4)
        mexPrintf("The input refShot is:  %d\n", refShot);

    /* Get the value of the refRun */
    int refRun = (int) mxGetScalar(prhs[4]);
    if (params.verbosity >= 4)
        mexPrintf("The input refRun is:  %d\n", refRun);

    /* Get the value of the expName */
    char *expName = mxArrayToString(prhs[5]);
    if (params.verbosity >= 4)
        mexPrintf("The input expName is:  %s\n", expName);

    int idx;
    al_status_t status;

    status = ual_begin_pulse_action(UDA_BACKEND, shot, run, 
				    "", expName, "", &idx); 

    if (status.code >= 0)
      status = ual_open_pulse(idx, FORCE_CREATE_PULSE, "");

    if (status.code != 0)
      mexErrMsgIdAndTxt("IMAS:imas_create_public:Failed", "Error creating imas shot %d, run %d expName %s:\n\t%s", shot, run, expName, status.message);
    /* Prepare the return argument */
    plhs[0] = mxCreateDoubleScalar(idx);

}
