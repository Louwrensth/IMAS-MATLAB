
/*
 * imas_get_mex_params.c - get parameters for IMAS MEX interface
 *
 *              params = imas_get_mex_params()
 *
 * This is a MEX file for MATLAB.
 */
#include "imas_mex_utils.h"

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
  int ifield;
  int value;

  // Check for Zero input arguments  
  if (nrhs != 0) {
    mexErrMsgIdAndTxt("IMAS:imas_mex_get_params:nargin", "Zero inputs required.");
  }
  // Check for one output argument
  if (nlhs > 1) {
    mexErrMsgIdAndTxt("IMAS:imas_mex_get_params:nargout", "One output maximum required.");
  }

  // Prepare the return argument
  plhs[0] = mxCreateStructMatrix(1,1, 0, NULL);

  // params.get_int_as_double
  ifield = mxAddField(plhs[0], "get_int_as_double");
  if (ifield < 0)
    mexErrMsgIdAndTxt("IMAS:imas_mex_get_params:internal","Unable to create structure params");
  mxSetFieldByNumber(plhs[0], 0, ifield, mxCreateLogicalScalar((mxLogical) params.get_int_as_double));

  // params.put_int_from_double
  ifield = mxAddField(plhs[0], "put_int_from_double");
  if (ifield < 0)
    mexErrMsgIdAndTxt("IMAS:imas_mex_get_params:internal","Unable to create structure params");
  mxSetFieldByNumber(plhs[0], 0, ifield, mxCreateLogicalScalar((mxLogical) params.put_int_from_double));

  // params.get_empty_as_nan
  ifield = mxAddField(plhs[0], "get_empty_as_nan");
  if (ifield < 0)
    mexErrMsgIdAndTxt("IMAS:imas_mex_get_params:internal","Unable to create structure params");
  mxSetFieldByNumber(plhs[0], 0, ifield, mxCreateLogicalScalar((mxLogical) params.get_empty_as_nan));

  // params.put_empty_from_nan
  ifield = mxAddField(plhs[0], "put_empty_from_nan");
  if (ifield < 0)
    mexErrMsgIdAndTxt("IMAS:imas_mex_get_params:internal","Unable to create structure params");
  mxSetFieldByNumber(plhs[0], 0, ifield, mxCreateLogicalScalar((mxLogical) params.put_empty_from_nan));

  // params.use_cell_array_for_array_of_structures
  ifield = mxAddField(plhs[0], "use_cell_array_for_array_of_structures");
  if (ifield < 0)
    mexErrMsgIdAndTxt("IMAS:imas_mex_get_params:internal","Unable to create structure params");
  mxSetFieldByNumber(plhs[0], 0, ifield, mxCreateLogicalScalar((mxLogical) params.use_cell_array_for_array_of_structures));

  // params.convert_whole_ids
  ifield = mxAddField(plhs[0], "convert_whole_ids");
  if (ifield < 0)
    mexErrMsgIdAndTxt("IMAS:imas_mex_get_params:internal","Unable to create structure params");
  mxSetFieldByNumber(plhs[0], 0, ifield, mxCreateDoubleScalar((double) params.convert_whole_ids));

  // params.error_on_missing_field
  ifield = mxAddField(plhs[0], "error_on_missing_field");
  if (ifield < 0)
    mexErrMsgIdAndTxt("IMAS:imas_mex_get_params:internal","Unable to create structure params");
  mxSetFieldByNumber(plhs[0], 0, ifield, mxCreateLogicalScalar((mxLogical) params.error_on_missing_field));

  // params.verbosity
  ifield = mxAddField(plhs[0], "verbosity");
  if (ifield < 0)
    mexErrMsgIdAndTxt("IMAS:imas_mex_get_params:internal","Unable to create structure params");
  mxSetFieldByNumber(plhs[0], 0, ifield, mxCreateDoubleScalar((double) params.verbosity));    

  return;
}
