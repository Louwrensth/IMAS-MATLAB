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
    char *data_ptr = mxGetData(prhs[0]);
    int protocol = data_ptr[0];

    if (params.verbosity >= 4)
        mexPrintf("Protocol retrieved:  %d\n", protocol);

    char *IDSName = mxArrayToString(prhs[1]);
    if (params.verbosity >= 4)
        mexPrintf("The input IDSName is:  %s\n", IDSName);

    /* Check for one output argument */
    if (nlhs > 1) {
        mexErrMsgIdAndTxt("IMAS:imas_serialize:nargout", "One output maximum required.");
    }

    if( protocol == ASCII_SERIALIZER_PROTOCOL )
    {
        char *data = mxArrayToString(prhs[0]);
        //Skip one byte as we have protocol stored there
        data++;
        al_status_t status_begin,status_open, status_end, status_close;
        int _pulseCtx;
        char * tmpfile = generate_tmp_file();
        if(tmpfile == NULL)
        {
            mexErrMsgIdAndTxt("IMAS:imas_deserialize:Failed", "Error generating serialization filename");
            return;
        }
        char * tmpfilename = getFilenameFromPath(tmpfile);
        FILE *fptr;
        fptr = fopen(tmpfile,"w");
        if(fptr == NULL)
        {
            mexErrMsgIdAndTxt("IMAS:imas_deserialize:Failed", "Error while creating file %s", tmpfile);
        }
        fprintf(fptr,"%s",data);
        fclose(fptr);
        int idx;
        char * options = concat(";filename=", tmpfilename);
        char *uri;
        const char* IMAS_AL_SERIALIZER_TMP_DIR = getenv("IMAS_AL_SERIALIZER_TMP_DIR");
        if(IMAS_AL_SERIALIZER_TMP_DIR != NULL)
        {
            uri = concat("imas:ascii?path=", IMAS_AL_SERIALIZER_TMP_DIR);
            if(uri[strlen(uri)-1] != '/')
            {
                char slash = '/';
                strncat(uri, &slash, 1);
            }
        }
        else
        {
            uri = concat("imas:ascii?path=", SERIALIZE_TEMPORARY_DIRECTORY);
        }
        uri = concat(uri, options);
        status_begin = al_begin_dataentry_action(uri, CREATE_PULSE, &idx);


        status_open = al_begin_dataentry_action(uri, CREATE_PULSE, &idx);
        free(uri);
        if (status_open.code != 0)
        {
            al_end_action(idx);
            mexErrMsgIdAndTxt("IMAS:imas_deserialize:Failed", "Error creating imas pulse %s",  status_open.message);
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
            status_close = al_close_pulse(idx, CLOSE_PULSE);
            if (status_close.code >= 0)
                al_end_action(idx);
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
#ifdef FLEXBUFFERS_SERIALIZER_PROTOCOL
    else if (protocol == FLEXBUFFERS_SERIALIZER_PROTOCOL)
    {
        // sanity check input argument:
        if (mxGetNumberOfDimensions(prhs[0]) != 2 || mxGetClassID(prhs[0]) != mxUINT8_CLASS) {
            mexErrMsgIdAndTxt("IMAS:imas_deserialize:Failed", "Unexpected input type. Should be a uint8 with 2 dimensions.");
        }
        al_status_t status;
        int idx;
        status = al_begin_dataentry_action("imas:serialize?path=/", OPEN_PULSE, &idx);
        if (status.code != 0) {
            al_end_action(idx);
            mexErrMsgIdAndTxt("IMAS:imas_deserialize:Failed", "Error creating imas pulse %s",  status.message);
        }

        // Write buffer to the backend
        int size = mxGetDimensions(prhs[0])[1];
        status = al_write_data(idx, "<buffer>", "", data_ptr, CHAR_DATA, 1, &size);
        if (status.code != 0) {
            al_end_action(idx);
            mexErrMsgIdAndTxt("IMAS:imas_deserialize:Failed", "Error writing buffer %s",  status.message);
        }

        //Call ids_get function
        mxArray *ids_get_rhs[2];
        mxArray *ids_get_lhs[1];
        ids_get_rhs[0] = mxCreateDoubleScalar(idx);
        ids_get_rhs[1] = mxCreateString(IDSName);

        mexCallMATLAB(1,ids_get_lhs,2, ids_get_rhs, "ids_get");
        plhs[0] = ids_get_lhs[0];
        if (idx != -1) 
        {
            status = al_close_pulse(idx, CLOSE_PULSE);
            if (status.code >= 0)
                al_end_action(idx);
            else
                mexErrMsgIdAndTxt("IMAS:imas_deserialize:Failed", "Error closing pulse %s",  status.message);
        }
    }
#endif // FLEXBUFFERS_SERIALIZER_PROTOCOL
    else
    {
        mexErrMsgIdAndTxt("IMAS:imas_deserialize:Failed", "Unrecognized serialization protocol %d",  protocol);
    }
}
