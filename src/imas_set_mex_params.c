
/*
 * imas_set_mex_params.c - set parameters for IMAS MEX interface
 *
 *              imas_set_mex_params(name, value, ...)
 *              imas_set_mex_params(struct)
 *
 * This is a MEX file for MATLAB.
 */
#include "imas_mex_utils.h"

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
  int ifield;
  int nfields;
  const char *name;
  const mxArray *data;

  /* Check for One or an even number of input arguments   */
  if (nrhs != 1 && nrhs % 2 != 0) {
    mexErrMsgIdAndTxt("IMAS:imas_mex_set_params:nargin", "One or an even number of inputs required.");
  }
  /* Check for no output argument */
  if (nlhs > 0) {
    mexErrMsgIdAndTxt("IMAS:imas_mex_set_params:nargout", "No output required.");
  }

  if (nrhs == 1) {
    if (!mxIsStruct(prhs[0]) || !mxIsScalar(prhs[0]))
      mexErrMsgIdAndTxt("IMAS:imas_mex_set_params:input",
			"If a single input is given, it must be a scalar structure");
    nfields = mxGetNumberOfFields(prhs[0]);
  } else {
    nfields = (nrhs / 2);
  }
  
  for (ifield = 0; ifield < nfields; ifield++) {
    if (nrhs == 1) {
      name = mxGetFieldNameByNumber(prhs[0],ifield);
      data = mxGetFieldByNumber(prhs[0], 0, ifield);
    } else {
      if (!mxIsChar(prhs[ifield*2]))
	mexErrMsgIdAndTxt("IMAS:imas_mex_set_params:input",
			  "Parameter names must be strings");
      name = mxArrayToString(prhs[ifield*2]);
      data = prhs[ifield*2+1];
    }
    if ( (!mxIsNumeric(data) || !mxIsScalar(data)) && !mxIsLogicalScalar(data))
	mexErrMsgIdAndTxt("IMAS:imas_mex_set_params:input",
			  "Parameter values must be numeric or logical scalars.");
    /* get_int_as_double */
    if (!strcmp(name, "get_int_as_double")) {
      params.get_int_as_double = (int) mxGetScalar(data) != 0;
      continue;
    /* put_int_from_double */
    } else if (!strcmp(name, "put_int_from_double")) {
      params.put_int_from_double = (int) mxGetScalar(data) != 0;
      continue;
    /* get_empty_as_nan */
    } else if (!strcmp(name, "get_empty_as_nan")) {
      params.get_empty_as_nan = (int) mxGetScalar(data) != 0;
      continue;
    /* put_empty_from_nan */
    } else if (!strcmp(name, "put_empty_from_nan")) {
      params.put_empty_from_nan = (int) mxGetScalar(data) != 0;
      continue;
    /* use_cell_array_for_array_of_structures */
    } else if (!strcmp(name, "use_cell_array_for_array_of_structures")) {
      params.use_cell_array_for_array_of_structures = (int) mxGetScalar(data) != 0;
      continue;
    /* convert_whole_ids */
    } else if (!strcmp(name, "convert_whole_ids")) {
      params.convert_whole_ids = (int) mxGetScalar(data);
      continue;
    /* error_on_missing_field */
    } else if (!strcmp(name, "error_on_missing_field")) {
      params.error_on_missing_field = (int) mxGetScalar(data) != 0;
      continue;
    /* verbosity */
    } else if (!strcmp(name, "verbosity")) {
      params.verbosity = (int) mxGetScalar(data);
      continue;
    }
    /* Warning if unknown field */
    mexWarnMsgIdAndTxt("IMAS:imas_mex_set_params:unknown_parameter",
		      "String %s is not recognised as a valid parameter", name);
  }

  return;
}
