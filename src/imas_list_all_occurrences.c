
/*
 * imas_list_all_occurrences.c - list all non-empty occurrences of IDSname in the dataset, and optionnally return the content of a descriptive node path in MATLAB External Interfaces 
 *
 *           imas_list_all_occurrences(idx, ids_name, node_path)
 *
 * This is a MEX file for MATLAB.
 */
#include "imas_mex_utils.h"

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
    /* Check for one input arguments   */
    if (nrhs != 3) {
        mexErrMsgIdAndTxt("IMAS:imas_list_all_occurrences:nargin", "Three inputs required.");
    }
    /* make sure idx is scalar */
    if( !mxIsNumeric(prhs[0]) ||
      !mxIsScalar(prhs[0]) ) {
      mexErrMsgIdAndTxt("IMAS:imas_list_all_occurrences:notScalar",
                        "Input idx must be a scalar.");
    }
    /* Get the value of idx */
    int idx = (int) mxGetScalar(prhs[0]);
    if (params.verbosity >= 4)
        mexPrintf("The input idx is:  %d\n", idx);

    /* make sure the 2nd input argument is a string */
    if (!mxIsChar(prhs[1])) {
        mexErrMsgIdAndTxt("IMAS:imas_list_all_occurrences:notChar", "IDS name must be a string.");
    }
    /* make sure the 3rd input argument is a string */
    if (!mxIsChar(prhs[2])) {
        mexErrMsgIdAndTxt("IMAS:imas_list_all_occurrences:notChar", "Node path must be a string.");
    }
    
    /* Get the value of the IDS name */
    char *ids_name = mxArrayToString(prhs[1]);
    if (params.verbosity >= 4)
        mexPrintf("The IDS name is:  %s\n", ids_name);
        
    /* Get the value of the node path */
    char *node_path = mxArrayToString(prhs[2]);
    if (params.verbosity >= 4)
        mexPrintf("The node path is:  %s\n", node_path);
    
    int* occurrences_list;
    int size;
    al_status_t status = al_get_occurrences(idx, ids_name, &occurrences_list, &size);

    if (status.code < 0) {
      mexErrMsgIdAndTxt("IMAS:imas_list_all_occurrences:Failed", "Error calling al_get_occurrences for IDS name %s (idx=%d):\n\t%s", ids_name, idx, status.message);
      return;
    }
    /*mexPrintf("size=%d\n", size);
    for (int i = 0; i < size; i++) {
        mexPrintf("occurrences_list[%d]=%d\n", i, occurrences_list[i]);
    }*/

    mwSize m_size[1];
    m_size[0] = (mwSize) size;

    plhs[0] = mxCreateNumericArray(1, m_size, mxINT32_CLASS, mxREAL);
    int* intArray = mxGetData(plhs[0]);
    for (int i = 0; i < size; i++)
        intArray[i] = occurrences_list[i];

    int opCtx = -1;

    if (node_path && strlen(node_path) > 0) {

            char** replies = (char**) malloc(size*sizeof(char*));
            char** idsFullNames = (char**) malloc(size*sizeof(char*));
            int n_max = 0;
            for (int i = 0; i < size; i++) {

                idsFullNames[i] = malloc(strlen(ids_name) + 10);
                if (occurrences_list[i] > 0) {
                    strcpy(idsFullNames[i], ids_name);
                    size_t pathlen = strlen(idsFullNames[i]);
                    char* c = idsFullNames[i];
                    snprintf(&c[pathlen], 5, "/%d", occurrences_list[i]);  
                }
                else {
                    strcpy(idsFullNames[i], ids_name);
                }
                char* idsFullName = idsFullNames[i];
                status = al_begin_global_action(idx, idsFullName, "", READ_OP, &opCtx);
                if (status.code < 0) {
                    mexErrMsgIdAndTxt("IMAS:imas_list_all_occurrences:Failed", "Error calling al_begin_global_action %s",  status.message);
                    free(*replies);
                    mxFree(idsFullName);
                    return;
                }

                replies[i] = NULL;
                int retSize[MAXDIM] = { 0 };

                status = al_read_data(opCtx, node_path, "", (void**)&replies[i], CHAR_DATA, 1, &retSize[0]);
                if (status.code < 0) {
                    mexErrMsgIdAndTxt("IMAS:imas_list_all_occurrences:Failed", "Error calling al_read_data %s",  status.message);
                    free(*replies);
                    mxFree(idsFullName);
                    return;
                }

                if (replies[i] == NULL) {
                    mexErrMsgIdAndTxt("IMAS:imas_list_all_occurrences:Failed", "Error with request (check that the requested node exists and has a string type):%s", node_path);
                    free(*replies);
                    mxFree(idsFullName);
                    return;
                }

                status = al_end_action(opCtx);
                if (status.code < 0) {
                    mexErrMsgIdAndTxt("IMAS:imas_list_all_occurrences:Failed", "Error calling al_end_action %s",  status.message);
                    free(*replies);
                    mxFree(idsFullName);
                    return;
                }

                if (retSize[0] > n_max)
                    n_max = retSize[0];

            }

            //for (int i = 0; i < size; i++)
            //    mexPrintf("reply[%d]=%s\n", i, replies[i]);

            // Create an mxArray with 1 rows and size columns
            plhs[1] = mxCreateCellMatrix(1, size);

            // Fill plhs[1] with data from replies
            for (int i = 0; i < size; i++)
                mxSetCell(plhs[1], i, mxCreateString(replies[i]));
            
            free(replies);
            free(idsFullNames);
    }

}
