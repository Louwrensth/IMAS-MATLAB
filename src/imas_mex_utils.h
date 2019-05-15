
#ifndef IMAS_MEX_UTILS_H

#define IMAS_MEX_UTILS_H

#define NON_TIMED   0
#define TIMED       1
#define TIMED_CLEAR 2

const char EMPTY_CHAR;
const int EMPTY_INT;
const double EMPTY_DOUBLE;

#include "mex.h"
#include "imas_mex_params.h"
#include "imas_mex_casts.h"
#include "imas_mex_structs.h"
#include "ual_lowlevel.h"
#include "ual_low_level.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#define MAXPATHSIZE 1025
#define MAXERRMSGIDSIZE 129
#define MAXERRMSGTXTSIZE 1025

struct imas_mex_actionInfo {
  int context;
};

struct imas_mex_fieldInfo {
  char fieldPath[MAXPATHSIZE];
  char timebasePath[MAXPATHSIZE];
  int datatype;
  int dim;
};

extern char mex_errmsgid[MAXERRMSGIDSIZE];
extern char mex_errmsgtxt[MAXERRMSGTXTSIZE];
extern int msglen;

char *ual_last_errmsg();

void my_mexErrMsgIdAndTxt(int status, const char * prefix);

void my_exceptionGetReport(mxArray* exception);

int getHomogeneousTime2(int ctx, int *homogeneousTime);

int data_to_mxArray(int datatype, int dim, void *array, int *size, mxArray **data);

int data_from_mxArray(int datatype, int dim, const mxArray * data, void **array, int *size);

int my_ual_read_data(struct imas_mex_actionInfo * action, struct imas_mex_fieldInfo * field, mxArray ** data);

int my_ual_write_data(struct imas_mex_actionInfo * action, struct imas_mex_fieldInfo * field, const mxArray * data);

#endif
