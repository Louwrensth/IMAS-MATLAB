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
#include "ual_lowlevel.h"
#include "imas_mex_params.h"
#include "imas_mex_casts.h"
#include "imas_mex_structs.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>

#ifdef NO_MXISSCALAR
#define mxIsScalar(a) (mxGetNumberOfElements(a)==1)
#endif

#define MAXERRMSGIDSIZE 129
#define MAXERRMSGTXTSIZE 1025

#define HLI_ERR LOWLEVEL_ERR-1

#define ANCESTORS_MAX_COUNT 30
#define NBC_VERSIONS_MAX_COUNT 5
#define ANCESTOR_NAME_MAX_LENGTH 50
#define ANCESTOR_TYPE_MAX_LENGTH 20
#define ANCESTOR_VERSION_MAX_LENGTH 20
#define ANCESTORS_PREVIOUS_NAMES_MAX_LENGTH 250
#define ANCESTORS_VERSIONS_MAX_LENGTH 50
#define IMAS_PATH_MAX_LENGTH 500

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
extern int msg_haspathinfo;

void resetErrMsgIdAndTxt(void);

void my_mexErrMsgIdAndTxt(al_status_t status, const char * prefix);

void my_exceptionGetReport(mxArray* exception);

void addIdsPathInfoToErrMsg(const char * idsPathInfo, int force);

void getFieldRelativePath(char* relativePath, int ancestors_count, char* ancestors_names[], char* ancestors_change_nbc_versions[],
		char* ancestors_change_nbc_previous_names[], char* ancestors_data_types[],  char* dataDictionaryVersion);

void getNodePath(char* path, int ancestors_count, char* ancestors_names[], char* ancestors_change_nbc_versions[],
		char* ancestors_change_nbc_previous_names[], char* dataDictionaryVersion, int k);

int getIndexAfterFirstStructArrayAncestor(char* ancestors_data_types[],  int ancestors_count);

void splitUtil(char* arrayOfCharsPointers[], char* charsToSplit, int charsToSplitLength, int tokenLength, int *tokensCount);

int is_field_valid(int datatype, int dim, const mxArray * data);

al_status_t mxArray_default_value(int datatype, int dim, mxArray **data);

al_status_t getHomogeneousTimeCtx(int ctx, int *homogeneousTime);

al_status_t getDataDictionaryVersion(int ctx, char** data_dictionary, bool *tagged_version);

al_status_t data_to_mxArray(int datatype, int dim, void *array, int *size, mxArray **data);

al_status_t data_from_mxArray(int datatype, int dim, const mxArray * data, void **array, int *size);

al_status_t my_ual_read_data(struct imas_mex_actionInfo * action, struct imas_mex_fieldInfo * field, mxArray ** data);

al_status_t my_ual_write_data(struct imas_mex_actionInfo * action, struct imas_mex_fieldInfo * field, const mxArray * data);
/** \endcond */

#endif
