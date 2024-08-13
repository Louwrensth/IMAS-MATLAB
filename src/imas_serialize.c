/** \addtogroup interface MEX-interface
 *  @{
 */

/**
   \file imas_serialize.c
   serializing IDS and returns buffer
   
   This is a MEX file for MATLAB.

   Usage:
   \code{.m} 
   data = imas_serialize(ids, ids_name, protocol)
   \endcode

   MATLAB help:
   \include matlab/imas_serialize.m
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
    
    /* Check for 2 or 3 mandatory input argument   */
    if (nrhs != 2 && nrhs != 3) {
        mexErrMsgIdAndTxt("IMAS:imas_serialize:nargin", "At least two inputs required.");
    }
    
    /* make sure ids is scalar struct */
    if( !mxIsStruct(prhs[0]) ||
        !mxIsScalar(prhs[0]) ) {
        mexErrMsgIdAndTxt("IMAS:imas_serialize:notScalar",
                            "Input ids must be a scalar structure.");
    }

    char *IDSName = mxArrayToString(prhs[1]);
    if (params.verbosity >= 4)
        mexPrintf("The input IDSName is:  %s\n", IDSName);

    int protocol;
    /* make sure the 2nd input argument is a integer */
    if (nrhs == 3) {
        if (!mxIsNumeric(prhs[2]) || !mxIsScalar(prhs[2]) ) {
            mexErrMsgIdAndTxt("IMAS:imas_serialize:notScalar", "Protocol should be integer scaler");
        }
        protocol = (int) mxGetScalar(prhs[2]);
        if (params.verbosity >= 4)
            mexPrintf("The input protocol is:  %d\n", protocol);
    }
    else
    {
        protocol = DEFAULT_SERIALIZER_PROTOCOL;
    }

    /* Check for one output argument */
    if (nlhs > 1) {
        mexErrMsgIdAndTxt("IMAS:imas_serialize:nargout", "One output maximum required.");
    }
    if( protocol == ASCII_SERIALIZER_PROTOCOL )
    {
        al_status_t status_begin,status_open, status_end, status_close;
        int _pulseCtx;
        char * tmpfile = generate_tmp_file();
        if(tmpfile == NULL)
        {
            mexErrMsgIdAndTxt("IMAS:imas_serialize:Failed", "Error generating serialization filename");
            return;
        }
        char * tmpfilename = getFilenameFromPath(tmpfile);

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

        status_open = al_begin_dataentry_action(uri, CREATE_PULSE, &idx); 
        free(uri);
        if (status_open.code != 0)
        {
            al_end_action(idx);
            mexErrMsgIdAndTxt("IMAS:imas_serialize:Failed", "Error creating imas pulse %s",  status_open.message);
        }

        // Call ids_put(idx, IDSName, prhs[0]);
        mxArray *ids_put_rhs[2];
        ids_put_rhs[0] = mxCreateDoubleScalar(idx);
        ids_put_rhs[1] = mxCreateString(IDSName);
        ids_put_rhs[2] = prhs[0];
        mxArray * exception = NULL;

        exception = mexCallMATLABWithTrap(0,NULL,3, ids_put_rhs, "ids_put");
        if(exception != NULL) {
            mexErrMsgIdAndTxt("IMAS:imas_serialize:Failed", "Error in ids_put");
            my_exceptionGetReport(exception);
        }
        if (idx != -1) 
        {
            status_close = al_close_pulse(idx, CLOSE_PULSE);
            if (status_close.code >= 0)
                al_end_action(idx);
            else
                mexErrMsgIdAndTxt("IMAS:imas_serialize:Failed", "Error closing pulse %s",  status_close.message);
        }
        mxArray *filename_rhs;
        // Read temporary file using mex function
        mxArray *fileread_lhs;
        filename_rhs = mxCreateString(tmpfile);
        exception = mexCallMATLABWithTrap(1,&fileread_lhs,1, &filename_rhs, "fileread");
        if(exception != NULL) {
            mexErrMsgIdAndTxt("IMAS:imas_serialize:Failed", "Error in reading temporary file");
            my_exceptionGetReport(exception);
        }
        char protocol_string[2];
        protocol_string[0]=(char)ASCII_SERIALIZER_PROTOCOL;
        protocol_string[1] = '\0';
        char *fileread_lhs_cstring = mxArrayToString(fileread_lhs);

        char *output = concat(protocol_string, fileread_lhs_cstring);
        plhs[0] = mxCreateString(output);
        
        //Delete temporary file using mex function
        exception = mexCallMATLABWithTrap(0,NULL,1, &filename_rhs, "delete");
        if(exception != NULL) {
            mexErrMsgIdAndTxt("IMAS:imas_serialize:Failed", "Error in deleting temporary file");
            my_exceptionGetReport(exception);
        }
    }
#ifdef FLEXBUFFERS_SERIALIZER_PROTOCOL
    else if (protocol == FLEXBUFFERS_SERIALIZER_PROTOCOL)
    {
        al_status_t status;
        int idx;
        status = al_begin_dataentry_action("imas:flexbuffers?path=/", CREATE_PULSE, &idx);
        if (status.code != 0) {
            al_end_action(idx);
            mexErrMsgIdAndTxt("IMAS:imas_serialize:Failed", "Error creating imas pulse %s",  status.message);
        }

        // Call ids_put(idx, IDSName, prhs[0]);
        mxArray *ids_put_rhs[2];
        ids_put_rhs[0] = mxCreateDoubleScalar(idx);
        ids_put_rhs[1] = mxCreateString(IDSName);
        ids_put_rhs[2] = prhs[0];
        mxArray * exception = NULL;

        exception = mexCallMATLABWithTrap(0,NULL,3, ids_put_rhs, "ids_put");
        if(exception != NULL) {
            mexErrMsgIdAndTxt("IMAS:imas_serialize:Failed", "Error in ids_put");
            my_exceptionGetReport(exception);
        }

        // Read buffer from the backend
        char *data;
        int size;
        status = al_read_data(idx, "<buffer>", "", (void**)(&data), CHAR_DATA, 1, &size);

        // Create output MEX string
        // N.B. Flexbuffers data contains NULL bytes, so we can't use mxCreateString :(
        mwSize mxsize[2] = {1, size};
        // mxArray *mx_char_array = mxCreateCharArray(2, mxsize);
        mxArray *mx_data = mxCreateNumericArray(2, mxsize, mxUINT8_CLASS, mxREAL);
        if (mx_data == NULL) {
            mexErrMsgIdAndTxt("IMAS:imas_serialize:Failed", "Failed to create MATLAB char array");
        }
        char *mx_data_ptr = mxGetData(mx_data);
        memcpy(mx_data_ptr, data, size);
        free(data);
        plhs[0] = mx_data;

        // cleanup
        if (idx != -1) 
        {
            status = al_close_pulse(idx, CLOSE_PULSE);
            if (status.code >= 0)
                al_end_action(idx);
            else
                mexErrMsgIdAndTxt("IMAS:imas_serialize:Failed", "Error closing pulse %s",  status.message);
        }
    }
#endif // FLEXBUFFERS_SERIALIZER_PROTOCOL
    else
    {
        mexErrMsgIdAndTxt("IMAS:imas_serialize:Failed", "Unrecognized serialization protocol %d",  protocol);
    }
}
