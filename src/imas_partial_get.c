/** \addtogroup interface MEX-interface
 *  @{
 */

/**
   \file imas_partial_get.c
   
   This is a MEX file for MATLAB.

   Usage:
   \code{.m} 
   data = imas_partial_get(idx, IDSName, occurrence, includes, excludes, debug)
   \endcode

   MATLAB help:
   \include matlab/imas_partial_get.m
 */

/** @}*/

#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include "mex.h"
#include "imas_mex_utils.h"

/**
   Entry point to C MEX function built with C Matrix API
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Check for 5 or 6 input arguments (argument 'debug' is optional) */
    if (nrhs < 5 || nrhs > 6) {
        mexErrMsgIdAndTxt("IMAS:imas_partial_get:nargin", "Five or six inputs required.");
    }
    
    /* Make sure idx is scalar numeric */
    if (!mxIsNumeric(prhs[0]) || !mxIsScalar(prhs[0])) {
        mexErrMsgIdAndTxt("IMAS:imas_partial_get:notScalar",
                          "Input idx must be a scalar numeric value.");
    }

    /* Get the value of idx */
    int idx = (int)mxGetScalar(prhs[0]);
    if (params.verbosity >= 4)
        mexPrintf("The input idx is: %d\n", idx);

    /* Convert IDSName to C string */
    char *IDSName = mxArrayToString(prhs[1]);
    if (IDSName == NULL) {
        mexErrMsgIdAndTxt("IMAS:imas_partial_get:invalidIDSName",
                          "Input IDSName must be a string.");
    }
    if (params.verbosity >= 4)
        mexPrintf("The input IDSName is: %s\n", IDSName);

    /* Get the value of occurrence */
    int occurrence = (int)mxGetScalar(prhs[2]);
    if (params.verbosity >= 4)
        mexPrintf("The IDS occurrence is: %d\n", occurrence);

    /* Convert includes (prhs[3]) to char* */
    if (!mxIsChar(prhs[3])) {
        mxFree(IDSName);
        mexErrMsgIdAndTxt("IMAS:imas_partial_get:invalidIncludes",
                          "Input includes must be a string.");
    }
    char *includes = mxArrayToString(prhs[3]);
    if (includes == NULL) {
        mxFree(IDSName);
        mexErrMsgIdAndTxt("IMAS:imas_partial_get:invalidIncludes",
                          "Failed to convert includes to string.");
    }
    if (params.verbosity >= 4)
        mexPrintf("The input includes is: %s\n", includes);

    /* Convert excludes (prhs[4]) to char* */
    if (!mxIsChar(prhs[4])) {
        mxFree(IDSName);
        mxFree(includes);
        mexErrMsgIdAndTxt("IMAS:imas_partial_get:invalidExcludes",
                          "Input excludes must be a string.");
    }
    char *excludes = mxArrayToString(prhs[4]);
    if (excludes == NULL) {
        mxFree(IDSName);
        mxFree(includes);
        mexErrMsgIdAndTxt("IMAS:imas_partial_get:invalidExcludes",
                          "Failed to convert excludes to string.");
    }
    if (params.verbosity >= 4)
        mexPrintf("The input excludes is: %s\n", excludes);

    /* Handle optional debug argument (prhs[5]) */
    int debug = 0; // Default value if not provided
    if (nrhs == 6) {
        if (!mxIsLogical(prhs[5]) || !mxIsScalar(prhs[5])) {
            mxFree(IDSName);
            mxFree(includes);
            mxFree(excludes);
            mexErrMsgIdAndTxt("IMAS:imas_partial_get:invalidIsDebug",
                              "Input debug must be a scalar logical.");
        }
        debug = mxGetScalar(prhs[5]) != 0;
    }

    /* Use debug if needed */
    if (debug) {
        mexPrintf("Debug mode enabled.\n");
    }

    const char* PARTIAL_GET = "partial_get";

    /* Construct idsFullName */
    char *idsFullName;
    if (occurrence != 0) {
        /* Allocate enough space for IDSName + "/" + occurrence + null terminator */
        int len = strlen(IDSName) + 1 + 11 + 1; // 11 for max int digits
        idsFullName = (char *)malloc(len * sizeof(char));
        if (idsFullName == NULL) {
            mxFree(IDSName);
            mxFree(includes);
            mxFree(excludes);
            mexErrMsgIdAndTxt("IMAS:imas_partial_get:memoryError",
                              "Failed to allocate memory for idsFullName.");
        }
        snprintf(idsFullName, len, "%s/%d", IDSName, occurrence);
    } else {
        idsFullName = strdup(IDSName);
        if (idsFullName == NULL) {
            mxFree(IDSName);
            mxFree(includes);
            mxFree(excludes);
            mexErrMsgIdAndTxt("IMAS:imas_partial_get:memoryError",
                              "Failed to allocate memory for idsFullName.");
        }
    }

    /* Construct nodes as IDSName + occurrence + "/*" */
    char *nodes;
    if (occurrence > 0) {
        int len = strlen(IDSName) + 1 + 11 + 2 + 1; /* IDSName + ":" + occurrence (max 11 digits) + "/*" + null terminator */
        nodes = (char *)malloc(len * sizeof(char));
        if (nodes == NULL) {
            mxFree(IDSName);
            mxFree(includes);
            mxFree(excludes);
            free(idsFullName);
            mexErrMsgIdAndTxt("IMAS:imas_partial_get:memoryError",
                              "Failed to allocate memory for nodes.");
        }
        snprintf(nodes, len, "%s:%d/*", IDSName, occurrence);
    } else {
        int len = strlen(IDSName) + 5; /* IDSName + ":" + occurrence (1 digit) + "/*" + null terminator */
        nodes = (char *)malloc(len * sizeof(char));
        if (nodes == NULL) {
            mxFree(IDSName);
            mxFree(includes);
            mxFree(excludes);
            free(idsFullName);
            mexErrMsgIdAndTxt("IMAS:imas_partial_get:memoryError",
                              "Failed to allocate memory for nodes.");
        }
        snprintf(nodes, len, "%s:%d/*", IDSName, occurrence);
    }

    /* Plugin registration and parameter setting */
    bool is_registered;
    al_status_t al_status;
    al_is_plugin_registered(PARTIAL_GET, &is_registered);
    if (!is_registered) {
        al_status = al_register_plugin(PARTIAL_GET);
        if (al_status.code < 0) {
            mxFree(IDSName);
            mxFree(includes);
            mxFree(excludes);
            free(idsFullName);
            free(nodes);
            mexErrMsgIdAndTxt("IMAS:imas_partial_get:pluginRegistrationError",
                              al_status.message);
        }
    }

    /* Pass includes as a single string */
    int includesSize = 1; /* Single string */
    al_status = al_setvalue_parameter_plugin("includes", CHAR_DATA, 1, &includesSize, (void *) includes, PARTIAL_GET);
    if (al_status.code < 0) {
        mxFree(IDSName);
        mxFree(includes);
        mxFree(excludes);
        free(idsFullName);
        free(nodes);
        mexErrMsgIdAndTxt("IMAS:imas_partial_get:settingIncludesParameterError",
                          al_status.message);
    }

    /* Pass excludes as a single string */
    int excludesSize = 1; /* Single string */
    al_status = al_setvalue_parameter_plugin("excludes", CHAR_DATA, 1, &excludesSize, (void *) excludes, PARTIAL_GET);
    if (al_status.code < 0) {
        mxFree(IDSName);
        mxFree(includes);
        mxFree(excludes);
        free(idsFullName);
        free(nodes);
        mexErrMsgIdAndTxt("IMAS:imas_partial_get:settingExcludesParameterError",
                          al_status.message);
    }

    /* Use for debugging purposes only */
    if (debug) {
        al_status = al_setvalue_int_scalar_parameter_plugin("debug", 1, PARTIAL_GET);
        if (al_status.code < 0) {
            mxFree(IDSName);
            mxFree(includes);
            mxFree(excludes);
            free(idsFullName);
            free(nodes);
            mexErrMsgIdAndTxt("IMAS:imas_partial_get:settingDebugParameterError",
                              al_status.message);
        }
        al_status = al_setvalue_int_scalar_parameter_plugin("debug_read_requests_only", 1, PARTIAL_GET);
        if (al_status.code < 0) {
            mxFree(IDSName);
            mxFree(includes);
            mxFree(excludes);
            free(idsFullName);
            free(nodes);
            mexErrMsgIdAndTxt("IMAS:imas_partial_get:settingDebugParameterError",
                              al_status.message);
        }
    }

    /* Bind plugin with nodes */

    al_status = al_bind_plugin(nodes, PARTIAL_GET);
    if (al_status.code < 0) {
        mxFree(IDSName);
        mxFree(includes);
        mxFree(excludes);
        free(idsFullName);
        free(nodes);
        mexErrMsgIdAndTxt("IMAS:imas_partial_get:bindPluginError",
                          al_status.message);
    }

    /* Free nodes */
    free(nodes);

    /* Call ids_get(idx, IDSName, occurrence) */
    mxArray *ids_get_rhs[3];
    ids_get_rhs[0] = (mxArray *)prhs[0];
    ids_get_rhs[1] = (mxArray *)prhs[1];
    ids_get_rhs[2] = (mxArray *)prhs[2];
    mxArray *exception = NULL;

    exception = mexCallMATLABWithTrap(1, plhs, 3, ids_get_rhs, "ids_get");
    if (exception != NULL) {
        mxFree(IDSName);
        mxFree(includes);
        mxFree(excludes);
        free(idsFullName);
        mexErrMsgIdAndTxt("IMAS:partial_get:Failed", "Error in ids_get");
        /* Assuming my_exceptionGetReport is defined elsewhere */
        my_exceptionGetReport(exception);
    }

    al_status = al_unregister_plugin(PARTIAL_GET);
    if (al_status.code < 0) {
        mxFree(IDSName);
        mxFree(includes);
        mxFree(excludes);
        free(idsFullName);
        mexErrMsgIdAndTxt("IMAS:imas_partial_get:unregisterPluginError",
                          al_status.message);
    }

    /* Free allocated memory */
    mxFree(IDSName);
    mxFree(includes);
    mxFree(excludes);
    free(idsFullName);
}