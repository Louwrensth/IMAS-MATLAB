/** \addtogroup utils MEX-utils
 *  @{
 */

/**
   \file src/imas_mex_params.c
   Session-wide parameters for IMAS MEX-files.
 */

/** @}*/

#include "imas_mex_utils.h"

#define DEFAULTPARAMS { 0, 1, 0, 0, 1, 0, 1, 0} /*!< Macro definition for the default parameters */

/**
   Default values for the IMAS MEX-files parameters.
   - Get methods do not return double values for integer fields.
   - Put methods accept double values for integer fields.
   - Get methods do not replace EMPTY_DOUBLE values by NaNs for double fields.
   - Put methods do not replace NaNs by EMPTY_DOUBLE for double fields.
   - Array of structures are represented using cell arrays.
   - Conversion of fields is done just before writing or just after reading.
   - Put methods will trigger errors when a field is missing.
   - Verbosity is set to its minimum value.
 */
const struct imas_mex_params defaultParams = DEFAULTPARAMS;
/**
   Global values for the IMAS MEX-files parameters.
   This is a global variable shared by all MEX-files through the shared library libimas_mex.so.x.y. It is initialised to the default parameters.
 */
struct imas_mex_params params = DEFAULTPARAMS;

/**
   Restore default values for the IMAS MEX-files parameters.
   @returns error status.
 */
int setDefaultParams(void)
{

  params = defaultParams;

  return 0;
}
