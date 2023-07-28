
/*
 * imas_al_bind_plugin.c - binds a C++ plugin to an IMAS field in MATLAB External Interfaces
 *
 *              imas_al_bind_plugin(field_path, plugin_name)
 *
 * This is a MEX file for MATLAB.
 */
#include "imas_mex_utils.h"

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
    /* Check for one input arguments   */
    if (nrhs != 2) {
        mexErrMsgIdAndTxt("IMAS:imas_al_bind_plugin:nargin", "Two inputs required.");
    }
    /* make sure the 1st input argument is a string */
    if (!mxIsChar(prhs[0])) {
        mexErrMsgIdAndTxt("IMAS:imas_al_bind_plugin:notChar", "Field path must be a string.");
    }
    /* make sure the 2nd input argument is a string */
    if (!mxIsChar(prhs[1])) {
        mexErrMsgIdAndTxt("IMAS:imas_al_bind_plugin:notChar", "Plugin name must be a string.");
    }
    /* Check for no output argument */
    if (nlhs > 0) {
        mexErrMsgIdAndTxt("IMAS:imas_al_bind_plugin:nargout", "No output required.");
    }
    /* Get the value of the field path */
    char *field_path = mxArrayToString(prhs[0]);
    if (params.verbosity >= 4)
        mexPrintf("The field path is:  %s\n", field_path);
        
    /* Get the value of the plugin name */
    char *plugin_name = mxArrayToString(prhs[1]);
    if (params.verbosity >= 4)
        mexPrintf("The plugin name is:  %s\n", plugin_name);
        
    al_bind_plugin(field_path, plugin_name);
}
