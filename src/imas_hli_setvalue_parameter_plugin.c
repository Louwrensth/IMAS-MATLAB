
/*
 * imas_hli_setvalue_parameter_plugin.c - Set the value of a C++ plugin parameter in MATLAB External Interfaces
 *
 *              imas_hli_setvalue_parameter_plugin(parameter_name, data, plugin_name)
 *
 * This is a MEX file for MATLAB.
 */
#include "imas_mex_utils.h"

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
    /* Check for one input arguments   */
    if (nrhs != 3) {
        mexErrMsgIdAndTxt("IMAS:imas_hli_setvalue_parameter_plugin:nargin", "Three inputs required.");
    }
    /* make sure the 1st input argument is a string */
    if (!mxIsChar(prhs[0])) {
        mexErrMsgIdAndTxt("IMAS:imas_hli_setvalue_parameter_plugin:notChar", "Parameter name must be a string.");
    }
    /* make sure the 2nd input argument is a scalar */
    if(!mxIsDouble(prhs[1])) {
        mexErrMsgIdAndTxt("IMAS:imas_hli_setvalue_parameter_plugin:notScalar", "Data must be scalar.");
    }
    /* make sure the 3rd input argument is a string */
    if (!mxIsChar(prhs[2])) {
        mexErrMsgIdAndTxt("IMAS:imas_hli_setvalue_parameter_plugin:notChar", "Plugin name must be a string.");
    }
    /* Check for no output argument */
    if (nlhs > 0) {
        mexErrMsgIdAndTxt("IMAS:imas_hli_setvalue_parameter_plugin:nargout", "No output required.");
    }
    /* Get the value of the parameter_name */
    char *parameter_name = mxArrayToString(prhs[0]);
    if (params.verbosity >= 4)
        mexPrintf("The parameter_name is:  %s\n", parameter_name);
        
    /* Get the value of the plugin name */
    char *plugin_name = mxArrayToString(prhs[2]);
    if (params.verbosity >= 4)
        mexPrintf("The plugin name is:  %s\n", plugin_name);
    
	void * array = NULL;
	int dims[MAXDIM];
	al_status_t status = {0,""};
	struct imas_mex_fieldInfo field;
	
	field.datatype = DOUBLE_DATA;
	field.dim = mxGetNumberOfDimensions(prhs[1]);
	
	if (status.code >= 0) status = data_from_mxArray(field.datatype, field.dim, prhs[1], &array, dims);
	if (status.code >= 0) hli_setvalue_parameter_plugin(parameter_name, field.datatype, field.dim, dims, array, plugin_name);

	/* Clean up memory allocated by data_from_mxArray */
	if (field.datatype == CHAR_DATA) {
		if (array != NULL)
			(field.dim == 1) ? mxFree(array) : free(array);
	} else if (field.datatype == COMPLEX_DATA) {
		if (array != NULL)
			free(array);
	}
    
}
