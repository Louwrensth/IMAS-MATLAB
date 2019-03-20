
#define NON_TIMED   0
#define TIMED       1
#define TIMED_CLEAR 2

const char EMPTY_CHAR;
const int EMPTY_INT;
const double EMPTY_DOUBLE;

#include "mex.h"
#include "ual_low_level.h"
#include "ual_lowlevel.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

char *ual_last_errmsg();

int read_data_to_mxArray(int ctx, const char *fieldpath, const char *timebasepath, int datatype, int dim, mxArray ** data);

int write_data_from_mxArray(int ctx, const char *fieldPath, const char *timebasePath, int datatype, int dim, const mxArray *data);

int getHomogeneousTime(int ctx, int *homogeneousTime);
