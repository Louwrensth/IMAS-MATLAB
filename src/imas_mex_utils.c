
#include "imas_mex_utils.h"

void checkStatus(int status)
{
    if (status)
        printf("%s\n", imas_last_errmsg());
}

void checkObject(void *obj)
{
    if (!obj)
        printf("Problem with array of structure allocation\n");
}

const mxArray *getSimpleFieldStruct(const mxArray * AosParent, char *path)
{
    /* Extracts field from structure AosParent following '/'-separated path */
    char *token;
    char *relative_path;
    const mxArray *data = AosParent;
    // Extract path after last closing bracket
    token = strtok(path, ")");
    while (token != NULL) {
        relative_path = token;
        token = strtok(NULL, ")");
    }
    // Structure unroll
    token = strtok(path, "/");
    while (token != NULL || data != NULL) {
        data = mxGetField(AosParent, (mwIndex) 0, token);
        if (data == NULL)
            mexErrMsgIdAndTxt("IMAS:imas_mex_utils:invalid_field", "Unable to retrieve field %s from structure", token);
        token = strtok(NULL, "/");
    }
    return data;
}
