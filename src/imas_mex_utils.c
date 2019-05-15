
#include "imas_mex_utils.h"

const char EMPTY_CHAR = '\0';
const int EMPTY_INT = -999999999;
const double EMPTY_DOUBLE = -9.0E40;

char mex_errmsgid[MAXERRMSGIDSIZE];
char mex_errmsgtxt[MAXERRMSGTXTSIZE];
int msglen = 0;

char *ual_last_errmsg()
{
    return "ual_last_errmsg_dummy";
}

void my_mexErrMsgIdAndTxt(int status, const char * prefix)
{
  char msgid[MAXERRMSGIDSIZE];

  strncpy(msgid, prefix, strnlen(prefix, MAXERRMSGIDSIZE-1)+1);
  if (strnlen(mex_errmsgid, MAXERRMSGIDSIZE-1)) {
    strncat(msgid, mex_errmsgid, MAXERRMSGIDSIZE - strnlen(msgid, MAXERRMSGIDSIZE-1));
    mexErrMsgIdAndTxt(msgid,mex_errmsgtxt);
  } else {
    strncat(msgid, "internal_error", MAXERRMSGIDSIZE - strnlen(msgid, MAXERRMSGIDSIZE-1));
    mexErrMsgIdAndTxt(msgid,"internal error occured with error code %d", status);
  }
}

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

int get_data_info(int datatype, int dim, mxClassID * classid, mxComplexity * ComplexFlag, size_t * dsize, void ** pdefault)
{
  if (datatype == INTEGER_DATA) {
    *classid = mxINT32_CLASS;
    *ComplexFlag = mxREAL;
    *dsize = sizeof(int);
    return 0;
  }
  if (datatype == DOUBLE_DATA) {
    *classid = mxDOUBLE_CLASS;
    *ComplexFlag = mxREAL;
    *dsize = sizeof(double);
    return 0;
  }
  if (datatype == CHAR_DATA) {
    *classid = mxCHAR_CLASS;
    *ComplexFlag = mxREAL;
    *dsize = 2*sizeof(char);
    return 0;
  }
  /*
    if (datatype == COMPLEX_DATA) {
    *classid = mxDOUBLE_CLASS;
    *ComplexFlag = mxCOMPLEX;
    *dsize = sizeof(double);
    return 0;
    }
  */
  return -1; // TODO: Should we use a unique status ID?
}

int data_to_mxArray(int datatype, int dim, void *array, int *size, mxArray **data)
{
  int status = -1;
  mxClassID classid;
  mxComplexity ComplexFlag;
  size_t dsize;
  mwSize ndims;
  mwSize dims[MAXDIM];
  mwSize numel = 1;
  mxChar * chararray;
  int i, j;

  status = get_data_info(datatype, dim, &classid, &ComplexFlag, &dsize, &array);
  if (status < 0)
    return status;
  if (dim == 0 || size == NULL || size[0] > 0) {
    if (datatype != CHAR_DATA) {
      //           **** NUMERIC DATA ****
      // Avoid creating empty arrays for scalars
      ndims = (dim > 0) ? dim : 1;
      dims[0] = 1;
      // Convert array size and compute total number of elements
      for (i = 0; i < dim; i++) {
	dims[i] = (mwSize) size[i];
	numel = numel * dims[i];
      }
      if (!numel) ndims=0; // True empty arrays
      *data = mxCreateNumericArray(ndims, dims, classid, ComplexFlag);
      // integer and double data map directly to MATLAB types
      memcpy(mxGetData(*data), array, numel * dsize);
    } else {
      //           **** CHAR DATA ****
      if (dim == 1)
	*data = mxCreateString((const char *) array);
      else {
	// Size is [nb of strings, string length] (???)
	dims[0] = (mwSize) size[0];
	dims[1] = (mwSize) size[1];
        *data = mxCreateCharArray(2, dims);
	// We need to transpose the character array
	chararray = mxGetData(*data);
	for (i = 0; i < dims[0]; i++)
	  for (j = 0; j < dims[1]; j++)
	    chararray[j*dims[0]+i] = (mxChar) ((char *) array)[i*dims[1]+j];
      }
    }
  } else {
      if (datatype == CHAR_DATA) {
	// Create an empty string (0x0 char array)
        *data = mxCreateCharArray(0, NULL);
      }
      else if (datatype == INTEGER_DATA || datatype == DOUBLE_DATA || datatype == COMPLEX_DATA)
	// Create an empty array of correct class
	*data = mxCreateNumericArray(0, NULL, classid, ComplexFlag);
  }

  return 0;
}

int data_from_mxArray(int datatype, int dim, const mxArray * data, void **array, int *size)
{
  int status;
  mxChar *chararray;
  int ndims;
  const mwSize *dims;
  mwSize numel = 1;
  int i,j;

  ndims = mxGetNumberOfDimensions(data);
  dims = mxGetDimensions(data);
  // Convert array size and compute total number of elements
  for (i = 0; i < dim; i++) {
    size[i] = ndims > i ? (int) dims[i] : 1;
    numel = numel * size[i];
  }
  // Allow for 1D row vectors 
  if (dim == 1 && dims[0] == 1) {
    size[0] = dims[1];
    numel = dims[1];
  }
  // Get pointer to data
  if (datatype != CHAR_DATA) {
    //           **** NUMERIC DATA ****
    // integer and double data map directly to MATLAB types
    *array = mxGetData(data);
  } else {
    //           **** CHAR DATA ****
    // MATLAB uses mxChar (uint16) to represent char arrays
    if (dim == 1)
      *array = mxArrayToString(data);
    else {
      // Size is [nb of strings, string length] (???)
      // We need to transpose the character array
      chararray = (mxChar *) mxGetChars(data);
      *array = malloc(numel*sizeof(char));
      for (i = 0; i < size[1]; i++)
	for (j = 0; j < size[0]; j++)
	  ((char *) *array)[j*size[1]+i] = (char) chararray[i*size[0]+j];
    }
  }
  status = 0;
  return status;
}

int getHomogeneousTime2(int ctx, int *homogeneousTime)
{
  int status = 0;
  char *fieldPath = "ids_properties/homogeneous_time";
  char *timebasePath = "";

  status = getInt(ctx, fieldPath, timebasePath, homogeneousTime);

  return status;
}

int my_ual_read_data(struct imas_mex_actionInfo * action, struct imas_mex_fieldInfo * field, mxArray ** data)
{

  int status = -1;
  int read_status = -1;
  int cast_status = -1;

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
    /*
    else if (field->datatype == COMPLEX_DATA)
      array = malloc(sizeof(Complex));
    */
  }

  read_status = ual_read_data(action->context, field->fieldPath, field->timebasePath, &array, field->datatype, field->dim, &dims[0]);

  status = data_to_mxArray(field->datatype, field->dim, array, dims, data);

  if (read_status < 0)
    return 0;

  // Free arrays 
  if (!read_status)
    free(array);

#ifndef NO_LOCAL_CONVERSION
  if (!params.convert_whole_ids) {
    if (params.get_int_as_double)
      if (field->datatype == INTEGER_DATA) {
	data_old = *data;
	cast_status = castInt32ToDouble(data);
	if (cast_status < 0) {
	  strncpy(mex_errmsgid,"cast_failed",12);
	  snprintf(&mex_errmsgtxt[msglen], MAXERRMSGTXTSIZE-msglen, "Unable to cast field %s to double", field->fieldPath);
	  return -1;
	}
	mxDestroyArray(data_old);
      }

    if (params.get_empty_as_nan)
      if (field->datatype == DOUBLE_DATA) {
	data_old = *data;
	cast_status = castEmptyToNaN(data);
	if (cast_status < 0) {
	  strncpy(mex_errmsgid,"cast_failed",12);
	  snprintf(&mex_errmsgtxt[msglen], MAXERRMSGTXTSIZE-msglen, "Unable to replace EMPTY_FLOATs by NaNs for field %s", field->fieldPath);
	  return -1;
	}
	mxDestroyArray(data_old);
      }
  }
#endif
  
  if (field->datatype == CHAR_DATA && field->dim == 2) {
    // For STR_1D cast to cell array of strings
    data_old = *data;
    cast_status = castCharToCell(data);
    if (cast_status < 0) {
      strncpy(mex_errmsgid,"cast_failed",12);
      snprintf(&mex_errmsgtxt[msglen], MAXERRMSGTXTSIZE-msglen, "Unable to cast field %s to cell", field->fieldPath);
      return -1;
    }
    mxDestroyArray(data_old);
  }

  return 0;
}

int my_ual_write_data(struct imas_mex_actionInfo * action, struct imas_mex_fieldInfo * field, const mxArray * data)
{

  int status = 0;
  int cast_status = -1;

  const mxArray * ptime;
  void * array;
  int dims[MAXDIM];

  int i;

  if (data != NULL && !mxIsEmpty(data)) {
#ifndef NO_LOCAL_CONVERSION
    if (!params.convert_whole_ids) {
      if (params.put_int_from_double)
	if (field->datatype == INTEGER_DATA) {
	  if (mxIsNumeric(data) && mxIsDouble(data)) {
	    cast_status = castDoubleToInt32((mxArray **) &data);
	    if (cast_status < 0) {
	      strncpy(mex_errmsgid,"cast_failed",12);
	      snprintf(&mex_errmsgtxt[msglen], MAXERRMSGTXTSIZE-msglen, "Unable to cast field %s to int32", field->fieldPath);
	      return -1;
	    }
	  }
	}

      if (params.put_empty_from_nan)
	if (field->datatype == DOUBLE_DATA) {
	  if (mxIsNumeric(data) && mxIsDouble(data)) {
	    cast_status = castNaNToEmpty((mxArray **) &data);
	    if (cast_status < 0) {
	      strncpy(mex_errmsgid,"cast_failed",12);
	      snprintf(&mex_errmsgtxt[msglen], MAXERRMSGTXTSIZE-msglen, "Unable to replace NaNs by EMPTY_FLOATs for field %s", field->fieldPath);
	      return -1;
	    }
	  }
	}
    }
#endif

    if (field->datatype == CHAR_DATA && field->dim == 2) {
      if (mxIsCell(data)) {
	cast_status = castCellToChar((mxArray **) &data);
	if (cast_status < 0) {
	  strncpy(mex_errmsgid,"cast_failed",12);
	  snprintf(&mex_errmsgtxt[msglen], MAXERRMSGTXTSIZE-msglen, "Unable to cast field %s to char", field->fieldPath);
	  return -1;
	}
      }
    }

    status = data_from_mxArray(field->datatype, field->dim, data, &array, dims);

    status = ual_write_data(action->context, field->fieldPath, field->timebasePath, array, field->datatype, field->dim, &dims[0]);
    
    if (field->datatype == CHAR_DATA)
      if (array != NULL)
	(field->dim == 1) ? mxFree(array) : free(array);

    if (cast_status == 0)
      mxDestroyArray((mxArray *) data);
  }

  return status;
}
