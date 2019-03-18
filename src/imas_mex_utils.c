
#include "imas_mex_utils.h"

const int EMPTY_INT = -999999999;
const float EMPTY_FLOAT = -9.0E35;
const double EMPTY_DOUBLE = -9.0E40;

char *ual_last_errmsg()
{
  return "ual_last_errmsg_dummy";
}

int getHomogeneousTime(int ctx, int *homogeneousTime)
{
    int status = 0;
    char* fieldPath = "ids_properties/homogeneous_time";
    char* timebasePath = "";

    status = getInt(ctx, fieldPath, timebasePath, homogeneousTime);
    
    return status;
}
