/** \addtogroup interface MEX-interface
 *  @{
 */

/**
   \file imas_deserialize.c
   deserializes data and returns IDS.
   
   This is a MEX file for MATLAB.

   Usage:
   \code{.m} 
   ids = imas_deserialize(data, ids_name)
   \endcode

   MATLAB help:
   \include matlab/imas_deserialize.m
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
    
    /* Check for 2 mandatory input argument   */
    if (nrhs != 2) {
        mexErrMsgIdAndTxt("IMAS:imas_deserialize:nargin", "At least two inputs required.");
    }

    char *data = mxArrayToString(prhs[0]);

    
    char protocol_string[3];
    strncpy(protocol_string, data, 2);
    int protocol = atoi(protocol_string);
    if (params.verbosity >= 4)
        mexPrintf("Protocol retrieved:  %d\n", protocol);

    //Skip two bytes as we have protocol stored there
    data++;
    data++;
    char *IDSName = mxArrayToString(prhs[1]);
    if (params.verbosity >= 4)
        mexPrintf("The input IDSName is:  %s\n", IDSName);

    /* Check for one output argument */
    if (nlhs > 1) {
        mexErrMsgIdAndTxt("IMAS:imas_serialize:nargout", "One output maximum required.");
    }

    if( protocol == ASCII_SERIALIZER_PROTOCOL )
    {
        al_status_t status_begin,status_open, status_end, status_close;
        int _pulseCtx;
        char * tmpfile = generate_tmp_file();
        if(strcmp(tmpfile, "")==0)
        {
            mexErrMsgIdAndTxt("IMAS:imas_deserialize:Failed", "Error generating serialization filename %s", tmpfile);
            return;
        }
        FILE *fptr;
        fptr = fopen(tmpfile,"w");
        if(fptr == NULL)
        {
            mexErrMsgIdAndTxt("IMAS:imas_deserialize:Failed", "Error while creating file %s", tmpfile);
        }
        fprintf(fptr,"%s",data);
        fclose(fptr);
        int idx;
        char * options = concat("-fullpath ", tmpfile);
        char *uri = (char*) malloc(500);
        status_begin = ual_build_uri_from_legacy_parameters(ASCII_BACKEND, 0, 0, "serialize", "serialize", "3", options, &uri);
        if (status_begin.code != 0)
        {
            mexErrMsgIdAndTxt("IMAS:imas_serialize:Failed", "Error creating uri, %s",  status_begin.message);
        }

        status_open = ual_begin_dataentry_action(uri, CREATE_PULSE, &idx);
        free(uri);
        if (status_open.code != 0)
        {
            hli_end_action(idx);
            mexErrMsgIdAndTxt("IMAS:imas_deserialize:Failed", "Error creating imas shot %s",  status_open.message);
        }

        //Call ids_get function
        mxArray *ids_get_rhs[2];
        mxArray *ids_get_lhs[1];
        ids_get_rhs[0] = mxCreateDoubleScalar(idx);
        ids_get_rhs[1] = mxCreateString(IDSName);
        mxArray * exception = NULL;

        exception = mexCallMATLABWithTrap(1,ids_get_lhs,2, ids_get_rhs, "ids_get");
        if(exception != NULL) {
            mexErrMsgIdAndTxt("IMAS:imas_deserialize:Failed", "Error in ids_get");
            my_exceptionGetReport(exception);
        }
        if (idx != -1) 
        {
            status_close = ual_close_pulse(idx, CLOSE_PULSE, "");
            if (status_close.code >= 0)
                hli_end_action(idx);
            else
                mexErrMsgIdAndTxt("IMAS:imas_deserialize:Failed", "Error closing pulse %s",  status_close.message);
        }
        plhs[0] = ids_get_lhs[0];

        mxArray *filename_rhs;
        filename_rhs = mxCreateString(tmpfile);
        // Delete temporary file using mex function
        exception = mexCallMATLABWithTrap(0,NULL,1, &filename_rhs, "delete");
        if(exception != NULL) {
            mexErrMsgIdAndTxt("IMAS:imas_deserialize:Failed", "Error in deleting temporary file");
            my_exceptionGetReport(exception);
        }
    }
    else
    {
        mexErrMsgIdAndTxt("IMAS:imas_deserialize:Failed", "Unrecognized serialization protocol %d",  protocol);
    }
}
