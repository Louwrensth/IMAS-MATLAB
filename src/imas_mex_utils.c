
#include "imas_mex_utils.h"

void checkStatus(int status)
{
    if (status)
        printf("%s\n", imas_last_errmsg());
}
