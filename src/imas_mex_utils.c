
#include "imas_mex_utils.h"

const int EMPTY_INT = -999999999;
const float EMPTY_FLOAT = -9.0E35;
const double EMPTY_DOUBLE = -9.0E40;

char *ual_last_errmsg()
{
  return "ual_last_errmsg_dummy";
}

void checkStatus(int status)
{
    if (status)
        printf("%s\n", ual_last_errmsg());
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

int getHomogeneousTime(int ctx, int *homogeneousTime)
{
    int status = 0;
    char* fieldPath = "ids_properties/homogeneous_time";
    char* timebasePath = "";

    status = getInt(ctx, fieldPath, timebasePath, homogeneousTime);
    
    return status;
}
