
/*
 * imas_al_unregister_plugin.c - unregisters a C++ plugin in MATLAB External Interfaces
 *
 *              imas_al_unregister_plugin(plugin_name)
 *
 * This is a MEX file for MATLAB.
 */
#include "imas_mex_utils.h"

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
    /* Check for one input arguments   */
    if (nrhs != 1) {
        mexErrMsgIdAndTxt("IMAS:imas_al_unregister_plugin:nargin", "One input required.");
    }
    /* make sure the 1st input argument is a string */
    if (!mxIsChar(prhs[0])) {
        mexErrMsgIdAndTxt("IMAS:imas_al_unregister_plugin:notChar", "Plugin name must be a string.");
    }
    /* Check for no output argument */
    if (nlhs > 0) {
        mexErrMsgIdAndTxt("IMAS:imas_al_unregister_plugin:nargout", "No output required.");
    }
    /* Get the value of the plugin name */
    char *plugin_name = mxArrayToString(prhs[0]);
    if (params.verbosity >= 4)
        mexPrintf("The plugin name is:  %s\n", plugin_name);
        
    al_unregister_plugin(plugin_name);
}
