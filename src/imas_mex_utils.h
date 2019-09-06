/** \addtogroup utils MEX-utils
 *  @{
 */

/**
   \file src/imas_mex_utils.h
   Headers for interaction with UAL.
 */

/** @}*/

#ifndef IMAS_MEX_UTILS_H

#define IMAS_MEX_UTILS_H

/** \cond */

extern const int EMPTY_INT;
extern const double EMPTY_DOUBLE;
extern const double EMPTY_COMPLEX[2];

extern const int IDS_TIME_MODE_UNKNOWN;
extern const int IDS_TIME_MODE_HETEROGENEOUS;
extern const int IDS_TIME_MODE_HOMOGENEOUS;
extern const int IDS_TIME_MODE_INDEPENDENT;

#include "mex.h"
#include "imas_mex_params.h"
#include "imas_mex_casts.h"
#include "imas_mex_structs.h"
#include "ual_lowlevel.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#ifdef NO_MXISSCALAR
#define mxIsScalar(a) (mxGetNumberOfElements(a)==1)
#endif

#define MAXERRMSGIDSIZE 129
#define MAXERRMSGTXTSIZE 1025
/** \endcond */

/**
   Structure containing information about the current LowLevel context.
 */
struct imas_mex_actionInfo {
  int context; /*!< Index of the Lowlevel context in the global store. */
};

/**
   Structure containing information about the current field.
 */
struct imas_mex_fieldInfo {
  char * fieldPath;    /*!< Path of the field relative to its parent array of structure. */
  char * timebasePath; /*!< Path of the timebase for the current field relative to its parent array of structure. */
  int datatype;        /*!< Type of data in the current field.. */
  int dim;             /*!< Rank of the current field. */
};

/** \cond */
extern const char * mex_errmsgid;
extern char mex_errmsgtxt[MAXERRMSGTXTSIZE];
extern int msglen;

void my_mexErrMsgIdAndTxt(int status, const char * prefix);

void my_exceptionGetReport(mxArray* exception);

int is_field_valid(int datatype, int dim, const mxArray * data);

int mxArray_default_value(int datatype, int dim, mxArray **data);

int getHomogeneousTimeCtx(int ctx, int *homogeneousTime);

int data_to_mxArray(int datatype, int dim, void *array, int *size, mxArray **data);

int data_from_mxArray(int datatype, int dim, const mxArray * data, void **array, int *size);

int my_ual_read_data(struct imas_mex_actionInfo * action, struct imas_mex_fieldInfo * field, mxArray ** data);

int my_ual_write_data(struct imas_mex_actionInfo * action, struct imas_mex_fieldInfo * field, const mxArray * data);
/** \endcond */

#endif
