
#define NON_TIMED   0
#define TIMED       1
#define TIMED_CLEAR 2

const int EMPTY_INT;
const float EMPTY_FLOAT;
const double EMPTY_DOUBLE;

#include "mex.h"
#include "ual_low_level.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

char *ual_last_errmsg();

void checkStatus(int status);

void checkObject(void *obj);

const mxArray *getSimpleFieldStruct(const mxArray * AosParent, char *path);

int getHomogeneousTime(int ctx, int *homogeneousTime);
