/** \addtogroup interface MEX-interface
 *  @{
 */

/**
   \file ids_isdefined.c
   checks if the property ids_properties.homogeneous_time of an IDS is set and has a valid value
   
   This is a MEX file for MATLAB.

   Usage:
   \code{.m} 
   is_defined = ids_isdefined(ids)
   \endcode

   MATLAB help:
   \include matlab/ids_isdefined.m
 */

/** @}*/

#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "imas_mex_utils.h"

/**
   Entry point to C/C++ MEX function built with C Matrix API
 */
void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
    
    /* Check for 1 mandatory input argument   */
    if (nrhs != 1) {
        mexErrMsgIdAndTxt("IMAS:ids_isdefined:nargin", "Only one input is required.");
    }

    /* make sure input argument is scalar struct */
    if( !mxIsStruct(prhs[0]) ||
        !mxIsScalar(prhs[0]) ) {
        mexErrMsgIdAndTxt("IMAS:ids_isdefined:notScalar",
                            "Input ids must be a scalar structure.");
    }

    /* Check for one output argument */
    if (nlhs > 1) {
        mexErrMsgIdAndTxt("IMAS:ids_isdefined:nargout", "One output maximum required.");
    }
    
    mxArray * ids = prhs[0];
    al_status_t status = init_dataTree_write(ids);

    plhs[0] = mxCreateLogicalMatrix(1,1);
    bool *y = mxGetLogicals(plhs[0]); //output

    if (status.code < 0) {
          *y = false;
    } else {

        int homogeneousTime = IDS_TIME_MODE_UNKNOWN;
        status = getHomogeneousTime(&homogeneousTime);

        if (status.code >= 0) {

            if (homogeneousTime != IDS_TIME_MODE_HOMOGENEOUS && homogeneousTime != IDS_TIME_MODE_HETEROGENEOUS && 
            homogeneousTime != IDS_TIME_MODE_INDEPENDENT) {
                *y = false;
            }
            else {
                *y = true;
            }
        }
        else {
            *y = false;
        }
    }
}
