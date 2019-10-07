/** \defgroup utils MEX-utils
 *  Utility functions for IMAS MEX-files.
 *  @{
 */

/**
   \file src/imas_mex_utils.c
   Interaction with UAL
 */

/** @}*/

#include "imas_mex_utils.h"

const int EMPTY_INT = -999999999;                   /*!< default value for integer scalars */
const double EMPTY_DOUBLE = -9.0E40;                /*!< default value for double scalars */
const double EMPTY_COMPLEX[2] = {-9.0E40, -9.0E40}; /*!< default value for complex scalars */

const int IDS_TIME_MODE_UNKNOWN = -999999999;       /*!< IDS time mode unset */
const int IDS_TIME_MODE_HETEROGENEOUS = 0;          /*!< IDS in heterogeneous time mode */
const int IDS_TIME_MODE_HOMOGENEOUS = 1;            /*!< IDS in homogeneous time mode  */
const int IDS_TIME_MODE_INDEPENDENT = 2;            /*!< IDS with time independent data only */

const char * mex_errmsgid;                          /*!< MATLAB message identifier for errors */
char mex_errmsgtxt[MAXERRMSGTXTSIZE];               /*!< Error message */
int msglen = 0;                                     /*!< Length of the mex_errmsgtxt string */
int msg_haspathinfo = 0;

/**
   Reset global variables for error message
 */
void resetErrMsgIdAndTxt(void)
{
  mex_errmsgid = NULL;
  mex_errmsgtxt[0] = '\000';
  msglen = 0;
  msg_haspathinfo = 0;
}

/**
   Assembles text and identifier for an error message then throws it.
   When the global mex_errmsgid variable is not an empty string, this function assembles the error message identifier from the prefix given in input and the content of the mex_errmsgid global variable. The text of the error message is then taken from the mex_errmsgtxt global variable. If mex_errmsgid was an empty string, the identifier and text are the default ones and contain the error code provided by the status parameter.
   @param[in] status error code
   @param[in] prefix string containing the prefix to the MATLAB error message identifier
 */
void my_mexErrMsgIdAndTxt(int status, const char * prefix)
{
  char msgid[MAXERRMSGIDSIZE];

  strncpy(msgid, prefix, strnlen(prefix, MAXERRMSGIDSIZE-1)+1);
  if (mex_errmsgid != NULL && strnlen(mex_errmsgid, MAXERRMSGIDSIZE-1)) {
    strncat(msgid, mex_errmsgid, MAXERRMSGIDSIZE - strnlen(msgid, MAXERRMSGIDSIZE-1));
    mexErrMsgIdAndTxt(msgid,mex_errmsgtxt);
  } else {
    strncat(msgid, "internal_error", MAXERRMSGIDSIZE - strnlen(msgid, MAXERRMSGIDSIZE-1));
    mexErrMsgIdAndTxt(msgid,"internal error occured with error code %d", status);
  }
}

/**
   Appends MException message to global error message text
   Typically called if an exception occurs during a call to a MATLAB function in a MEX-file, this function will add the message of the corresponding MException object to the mex_errmsgtxt global variable.
   @param[in] exception pointer to an mxArray of class MException
 */
void my_exceptionGetReport(mxArray* exception)
{
  mxArray * report;
  char * reportTxt;
  
  if (exception == NULL)
    return;

  report = mxGetProperty(exception, (mwIndex) 0, "message");
  reportTxt = mxArrayToString(report);
  msglen = strnlen(reportTxt, MAXERRMSGTXTSIZE-1)+1;
  strncpy(mex_errmsgtxt, reportTxt, msglen);
  mxFree(reportTxt);
  mxDestroyArray(report);

  strncat(mex_errmsgtxt, "\n----------\n", (12 < MAXERRMSGTXTSIZE-1-msglen) ? 12 : MAXERRMSGTXTSIZE-1-msglen);
  msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);

}

/**
   Appends IDS path information to global error message text
   Called after an error status is found when processing a certain field/aos/structure in one of the HLI functions. Because of the nested nature of these functions, one portion of the path could be added multiple times. To avoid this a global variable stores the status of the error message, and the path information is only added if this global status variable is not yet set. The additional argument force allows to disable this check.
   @param[in] pathInfo String containing the path information to be added to the error message
   @param[in] force flag which forces to add the path information if non-zero 
 */
void addIdsPathInfoToErrMsg(const char * pathInfo, int force)
{
  if (force || !msg_haspathinfo) {
    strncat(mex_errmsgtxt, pathInfo, MAXERRMSGTXTSIZE-1-msglen);
    msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
    msg_haspathinfo = 1;
  }
}

/**
   Checks if field has a different value than the default.
   This routine is used for put and put_slice methods before calling ual_write_data, if it returns 0 (false) then ual_write_data will be skipped.
   @param[in] datatype type of data in the current field.
   @param[in] dim rank of the current field.
   @param[in] data mxArray containing the data.
   @result 1 if field value is not the default, 0 otherwise.

   @note Note that this will be checked again after necessary casts, so integer fields with double values will be declared valid even if their (double) value matches EMPTY_INT.
 */
int is_field_valid(int datatype, int dim, const mxArray * data)
{
  return (data != NULL && !mxIsEmpty(data) && 
	  (dim != 0 || 
	   (mxIsScalar(data) && 
	    (
	     (datatype == INTEGER_DATA && (!mxIsInt32(data) || ((int *)    mxGetData(data))[0] != EMPTY_INT)) ||
	     (datatype == DOUBLE_DATA  && (mxIsDouble(data) && ((double *) mxGetData(data))[0] != EMPTY_DOUBLE)) ||
	     (datatype == COMPLEX_DATA && (mxIsDouble(data) && (((double *) mxGetData(data))[0] != EMPTY_DOUBLE || ((double *) mxGetImagData(data))[0] != EMPTY_DOUBLE)))
	     )
	    )
	   )
	  );
}

/**
   Gets data characteristics from datatype and dimension.
   From the input datatype (i.e. INTEGER_DATA, DOUBLE_DATA, CHAR_DATA or COMPLEX_DATA), assigns the basic class for the mxArray objects, the complexity flag (i.e. complex or real), and the size of the basic type. These quantities will be later used when creating mxArray objects.
   @param[in] datatype type of data in the current field.
   @param[in] dim rank of the current field.
   @param[out] classid class to be used in MATLAB for the data.
   @param[out] ComplexFlag complexity flag to be used in MATLAB for the data.
   @param[out] dsize size of an element of the underlying MATLAB type.
   @param[out] pdefault [deprecated].
   @result error status.

   @note Should we use a unique error status?
 */
int get_data_info(int datatype, int dim, mxClassID * classid, mxComplexity * ComplexFlag, size_t * dsize, void ** pdefault)
{
  if (datatype == INTEGER_DATA) {
    *classid = mxINT32_CLASS;
    *ComplexFlag = mxREAL;
    *dsize = sizeof(int);
  } else if (datatype == DOUBLE_DATA) {
    *classid = mxDOUBLE_CLASS;
    *ComplexFlag = mxREAL;
    *dsize = sizeof(double);
  } else if (datatype == CHAR_DATA) {
    *classid = mxCHAR_CLASS;
    *ComplexFlag = mxREAL;
    *dsize = 2*sizeof(char);
  } else if (datatype == COMPLEX_DATA) {
    *classid = mxDOUBLE_CLASS;
    *ComplexFlag = mxCOMPLEX;
    *dsize = sizeof(double);
  } else 
    return -1; /* TODO: Should we use a unique error status? */
  return 0;
}

/**
   Stores data read by the UAL in an mxArray object.
   This function creates an mxArray to store the data read by the UAL in a previous call. The array pointer contains the data and the parameters datatype and dim indicate the nature and rank of the data. data_to_mxArray performs a copy of the data. If the UAL read action was unsuccessful (read_status was negative) then the default value is assigned to data.
   @param[in] datatype type of data in the current field.
   @param[in] dim rank of the current field.
   @param[in] array pointer to the data returned by the UAL read action.
   @param[in] size pointer containing the dimensions of the data as returned by the UAL read action.
   @param[out] data mxArray containing the data.
   @result error status.
 */
int data_to_mxArray(int datatype, int dim, void *array, int *size, mxArray **data)
{
  int status = 0;
  mxClassID classid;
  mxComplexity ComplexFlag;
  size_t dsize;
  mwSize ndims;
  mwSize dims[MAXDIM];
  mwSize numel = 1;
  mxChar * chararray;
  int i, j;
  double *pr, *pi;

  status = get_data_info(datatype, dim, &classid, &ComplexFlag, &dsize, &array);
  if (status < 0)
    return status;
  if (dim == 0 || (size != NULL && size[0] > 0)) {
    if (datatype != CHAR_DATA) {
      /*           **** NUMERIC DATA **** */
      /* Avoid creating empty arrays for scalars */
      ndims = (dim > 0) ? dim : 1;
      dims[0] = 1;
      /* Convert array size and compute total number of elements */
      for (i = 0; i < dim; i++) {
	dims[i] = (mwSize) size[i];
	numel = numel * dims[i];
      }
      if (!numel) ndims=0; /* True empty arrays */
      *data = mxCreateNumericArray(ndims, dims, classid, ComplexFlag);
      if (datatype != COMPLEX_DATA)
	/* integer and double data map directly to MATLAB types */
	memcpy(mxGetData(*data), array, numel * dsize);
      else {
#if MX_HAS_INTERLEAVED_COMPLEX
#error IMAS_MEX builds with interleaved complex API is not supported yet
	memcpy(mxGetData(*data), array, numel * dsize * 2);
#else
	/* MATLAB complex data has two separate pointers for real and imaginary data (separate API) */
	pr = mxGetData(*data);
	pi = mxGetImagData(*data);
	for (i = 0; i < numel; i++) {
	  pr[i] = ((double *) array)[2*i];
	  pi[i] = ((double *) array)[2*i+1];
	}
#endif
      }
    } else {
      /*           **** CHAR DATA **** */
      if (dim == 1) {
	dims[0] = 1;
	dims[1] = size[0];
      } else {
	/* Size is [nb of strings, string length] (???) */
	dims[0] = (mwSize) size[0];
	dims[1] = (mwSize) size[1];
      }
      *data = mxCreateCharArray(2, dims);
      /* We need to transpose the character array */
      chararray = mxGetData(*data);
      for (i = 0; i < dims[0]; i++)
	for (j = 0; j < dims[1]; j++)
	  chararray[j*dims[0]+i] = (mxChar) ((char *) array)[i*dims[1]+j];
    }
  } else {
    if (datatype == CHAR_DATA) {
      /* Create an empty string (0x0 char array) */
      *data = mxCreateCharArray(0, NULL);
    }
    else
      /* Create an empty array of correct class */
      *data = mxCreateNumericArray(0, NULL, classid, ComplexFlag);
  }
  
  return status;
}

/**
   Extracts data and size information from an mxArray object.
   This function extracts the data pointer and computes the dimensions of the data from an mxArray object based on its type given by datatype and rank given by dim. It performs the reverse operation of data_to_mxArray.
   @param[in] datatype type of data in the current field.
   @param[in] dim rank of the current field.
   @param[in] data mxArray containing the data.
   @param[out] array pointer to the data to be used by the UAL write action.
   @param[out] size pointer containing the dimensions of the data.
   @result error status.
 */
int data_from_mxArray(int datatype, int dim, const mxArray * data, void **array, int *size)
{
  int status = 0;
  mxChar *chararray;
  int ndims;
  const mwSize *dims;
  mwSize numel = 1;
  int i,j;
  double *pr, *pi;

  ndims = mxGetNumberOfDimensions(data);
  dims = mxGetDimensions(data);
  /* Convert array size and compute total number of elements */
  for (i = 0; i < dim; i++) {
    size[i] = ndims > i ? (int) dims[i] : 1;
    numel = numel * size[i];
  }
  /* Allow for 1D row vectors  */
  if (dim == 1 && dims[0] == 1) {
    size[0] = dims[1];
    numel = dims[1];
  }
  /* Get pointer to data */
  if (datatype != CHAR_DATA) {
    /*           **** NUMERIC DATA **** */
    if (datatype != COMPLEX_DATA)
      /* integer and double data map directly to MATLAB types */
      *array = mxGetData(data);
    else {
#if MX_HAS_INTERLEAVED_COMPLEX
#error IMAS_MEX builds with interleaved complex API is not supported yet
      *array = mxGetData(data);
#else
      /* MATLAB complex data has two separate pointers for real and imaginary data (separate API) */
      *array = malloc(numel*2*sizeof(double));
      pr = mxGetData(data);
      pi = mxGetImagData(data);
      for (i = 0; i < numel; i++) {
	((double *) *array)[2*i] = pr[i];
	((double *) *array)[2*i+1] = pi[i];
      }
#endif
    }
  } else {
    /*           **** CHAR DATA **** */
    /* MATLAB uses mxChar (uint16) to represent char arrays */
    if (dim == 1)
      *array = mxArrayToString(data);
    else {
      /* Size is [nb of strings, string length] (???) */
      /* We need to transpose the character array */
      chararray = (mxChar *) mxGetChars(data);
      *array = malloc(numel*sizeof(char));
      for (i = 0; i < size[1]; i++)
	for (j = 0; j < size[0]; j++)
	  ((char *) *array)[j*size[1]+i] = (char) chararray[i*size[0]+j];
    }
  }
  return status;
}

/**
   Returns an mxArray containing the default value for the specified type and rank.
   @param[in] datatype type of data in the current field.
   @param[in] dim rank of the current field.
   @param[out] data mxArray containing the data.
   @result error status.
 */
int mxArray_default_value(int datatype, int dim, mxArray **data)
{
  int status = 0;
  void * array = NULL;
  mxArray * data_old;

  if (dim == 0) {
    if (datatype == INTEGER_DATA)
      array = (int *) &EMPTY_INT;
    else if (datatype == DOUBLE_DATA)
      array = (int *) &EMPTY_DOUBLE;
    else if (datatype == COMPLEX_DATA)
      array = (int *) &EMPTY_COMPLEX[0];
  }

  status = data_to_mxArray(datatype, dim, array, NULL, data);
  
  if (datatype == CHAR_DATA && dim == 2) {
    /* For STR_1D cast to cell array of strings */
    data_old = *data;
    if (status >= 0) status = castCharToCell(data);
    if (status >= 0) mxDestroyArray(data_old);
  }

  return status;
}

/**
   Reads the integer field ids_properties/homogeneous_time.
   For a given context (which must correspond to the root of an open IDS object), this function reads the integer field ids_properties/homogeneous_time.
   @param[in] ctx Current operation context.
   @param[out] homogeneousTime Value of ids_properties/homogeneous_time.
   @result error status.
 */
int getHomogeneousTimeCtx(int ctx, int *homogeneousTime)
{
  int status = 0;
  char *fieldPath = "ids_properties/homogeneous_time";
  char *timebasePath = "";
  int retSize[MAXDIM];

  status = ual_read_data(ctx, fieldPath, timebasePath, (void**)&homogeneousTime, 
			 INTEGER_DATA, 0, &retSize[0]);

  return status;
}

/**
   Reads a field and stores it in an mxArray object.
   Combines the reading of the field data by the UAL, its encapsulation in an mxArray and its conversion (if needed).
   @param[in] action Information about the current operation.
   @param[in] field Information about the current field.
   @param[out] data mxArray containing the data.
   @result error status.
 */
int my_ual_read_data(struct imas_mex_actionInfo * action, struct imas_mex_fieldInfo * field, mxArray ** data)
{

  int status = 0;

  mxArray * data_old;
  void * array = NULL;
  int dims[MAXDIM];

  int i;
  double retTime;

  if (field->dim == 0) {
    if (field->datatype == INTEGER_DATA)
      array = malloc(sizeof(int));
    else if (field->datatype == DOUBLE_DATA)
      array = malloc(sizeof(double));
    else if (field->datatype == COMPLEX_DATA)
      array = malloc(sizeof(double _Complex));
  }

  status = ual_read_data(action->context, field->fieldPath, field->timebasePath, &array, field->datatype, field->dim, &dims[0]);

  if (status >= 0) status = data_to_mxArray(field->datatype, field->dim, array, dims, data);

  /* Free arrays  */
  if (array) free(array);

#ifndef NO_LOCAL_CONVERSION
  if (!params.convert_whole_ids) {
    if (params.get_int_as_double)
      if (field->datatype == INTEGER_DATA) {
	data_old = *data;
	if (status >= 0) status = castInt32ToDouble(data);
	if (status >= 0) mxDestroyArray(data_old);
      }

    if (params.get_empty_as_nan)
      if (field->datatype == DOUBLE_DATA) {
	data_old = *data;
	if (status >= 0) status = castEmptyToNaN(data);
	if (status >= 0) mxDestroyArray(data_old);
      }
  }
#endif
  
  if (field->datatype == CHAR_DATA && field->dim == 2) {
    /* For STR_1D cast to cell array of strings */
    data_old = *data;
    if (status >= 0) status = castCharToCell(data);
    if (status >= 0) mxDestroyArray(data_old);
  }

  return status;
}

/**
   Writes a field from an mxArray object.
   Combines the conversion of the data stored in the MATLAB array (if needed), its conversion into a basic type and the writing action by the UAL.
   @param[in] action Information about the current operation.
   @param[in] field Information about the current field.
   @param[in] data mxArray containing the data.
   @result error status.
 */
int my_ual_write_data(struct imas_mex_actionInfo * action, struct imas_mex_fieldInfo * field, const mxArray * data)
{

  int status = 0;
  int cast_status = -1; /* Necessary flag in case a cast was made and clean-up is required */

  const mxArray * ptime;
  void * array = NULL;
  int dims[MAXDIM];

  int i;

#ifndef NO_LOCAL_CONVERSION
  if (!params.convert_whole_ids) {
    if (params.put_int_from_double)
      if (field->datatype == INTEGER_DATA) {
	if (mxIsNumeric(data) && mxIsDouble(data)) {
	  if (status >= 0) status = cast_status = castDoubleToInt32((mxArray **) &data);
	  /* Check again field validity */
	  if (status >= 0 && !is_field_valid(field->datatype, field->dim, data))
	    return 0;
	}
      }
    
    if (params.put_empty_from_nan)
      if (field->datatype == DOUBLE_DATA) {
	if (mxIsNumeric(data) && mxIsDouble(data)) {
	  if (status >= 0) status = cast_status = castNaNToEmpty((mxArray **) &data);
	  /* Check again field validity */
	  if (status >= 0 &&!is_field_valid(field->datatype, field->dim, data))
	    return 0;
	}
      }
  }
#endif
  
  if (field->datatype == CHAR_DATA && field->dim == 2) {
    if (mxIsCell(data)) {
      if (status >= 0) status = cast_status = castCellToChar((mxArray **) &data);
    }
  }
  
  if (status >= 0) status = data_from_mxArray(field->datatype, field->dim, data, &array, dims);
  
  if (status >= 0) status = ual_write_data(action->context, field->fieldPath, field->timebasePath, array, field->datatype, field->dim, &dims[0]);
  
  /* Clean up memory allocated by data_from_mxArray */
  if (field->datatype == CHAR_DATA) {
    if (array != NULL)
      (field->dim == 1) ? mxFree(array) : free(array);
  } else if (field->datatype == COMPLEX_DATA) {
    if (array != NULL)
      free(array);
  }
  
  /* Clean up data created by cast operation */
  if (cast_status == 0)
    mxDestroyArray((mxArray *) data);

  return status;
}
