
#include "imas_mex_utils.h"

#define DEFAULTPARAMS { 0, 1, 0, 0, 1, 0, 1, 0}
const struct imas_mex_params defaultParams = DEFAULTPARAMS;
struct imas_mex_params params = DEFAULTPARAMS;

int setDefaultParams(void)
{

  params = defaultParams;

  return 0;
}
