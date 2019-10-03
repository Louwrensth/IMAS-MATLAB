/** \addtogroup utils MEX-utils
 *  @{
 */

/**
   \file src/imas_mex_casts.c
   MATLAB type casting

   Functions used to cast MATLAB variables to new types. The default option is to use a call to a MATLAB function via the mexCallMATLABWithTrap C function but if the code is compiled with -DDO_NOT_CALL_MATLAB, then the casting is done manually (except for transformations from cell arrays to structure arrays). This is useful in case one wants to use the MEX HLI outside of a MATLAB session.
   A copy of the original mxArray pointer must be kept in case the data is not needed anymore and one needs to destroy it using mxDestroyArray.
 */

/** @}*/

#include "imas_mex_utils.h"

/**
   Cast a double array to an int32 array.
   @param[inout] data mxArray handle
   @result error code
 */
int castDoubleToInt32(mxArray ** data)
{
  mxArray * doubleData = (mxArray *) *data;
  mxArray * intData = NULL;
#ifndef DO_NOT_CALL_MATLAB
  mxArray * exception = NULL;

  if (!mxIsNumeric(*data) || !mxIsDouble(*data))
    return -1;

  exception = mexCallMATLABWithTrap(1, &intData, 1, &doubleData, "int32");

  if(exception != NULL) {
    my_exceptionGetReport(exception);
    return -1;
  }
#else
  size_t numel;
  mwSize ndims;
  const mwSize * dims;
  int * intArray;
  double * doubleArray;
  int i;
  
  if (!mxIsNumeric(*data) || !mxIsDouble(*data))
    return -1;

  numel = mxGetNumberOfElements(doubleData);
  ndims = mxGetNumberOfDimensions(doubleData);
  dims = mxGetDimensions(doubleData);

  intData = mxCreateNumericArray(ndims, dims, mxINT32_CLASS, mxREAL);
  doubleArray = mxGetData(doubleData);
  intArray = mxGetData(intData);

  for (i = 0; i < numel; i++)
    intArray[i] = (int) doubleArray[i];
#endif

  *data = intData;
  return 0;
}

/**
   Cast an int32 array to a double array.
   @param[inout] data mxArray handle
   @result error code
 */
int castInt32ToDouble(mxArray ** data)
{
  mxArray *intData = (mxArray *) * data;
  mxArray *doubleData = NULL;
#ifndef DO_NOT_CALL_MATLAB
  mxArray *exception = NULL;

  if (!mxIsNumeric(*data) || !mxIsInt32(*data))
    return -1;

  exception = mexCallMATLABWithTrap(1, &doubleData, 1, &intData, "double");

  if (exception != NULL) {
    my_exceptionGetReport(exception);
    return -1;
  }
#else
  size_t numel;
  mwSize ndims;
  const mwSize * dims;
  double * doubleArray;
  int * intArray;
  int i;
  
  if (!mxIsNumeric(*data) || !mxIsInt32(*data))
    return -1;

  numel = mxGetNumberOfElements(intData);
  ndims = mxGetNumberOfDimensions(intData);
  dims = mxGetDimensions(intData);

  doubleData = mxCreateNumericArray(ndims, dims, mxDOUBLE_CLASS, mxREAL);
  intArray = mxGetData(intData);
  doubleArray = mxGetData(doubleData);

  for (i = 0; i < numel; i++)
    doubleArray[i] = (double) intArray[i];
#endif

  *data = doubleData;
  return 0;
}


/**
   Replace NaN values with EMPTY_DOUBLE in double arrays.
   @param[inout] data mxArray handle
   @result error code
 */
int castNaNToEmpty(mxArray ** data)
{
  mxArray *inData = (mxArray *) * data;
  mxArray *outData = NULL;
#ifndef DO_NOT_CALL_MATLAB
  mxArray *exception = NULL;

  if (!mxIsNumeric(*data) || !mxIsDouble(*data))
    return -1;

  exception = mexCallMATLABWithTrap(1, &outData, 1, &inData, "nan_to_empty");

  if (exception != NULL) {
    my_exceptionGetReport(exception);
    return -1;
  }
#else
  size_t numel;
  double * inArray;
  double * outArray;
  int i;
  
  if (!mxIsNumeric(*data) || !mxIsDouble(*data))
    return -1;

  numel = mxGetNumberOfElements(inData);


  outData = mxDuplicateArray(inData);
  inArray = mxGetData(inData);
  outArray = mxGetData(outData);

  for (i = 0; i < numel; i++)
    if (mxIsNaN(inArray[i]))
      outArray[i] = EMPTY_DOUBLE;
#endif

  *data = outData;
  return 0;
}

/**
   Replace EMPTY_DOUBLE values with NaN in double arrays.
   @param[inout] data mxArray handle
   @result error code
 */
int castEmptyToNaN(mxArray ** data)
{
  mxArray *inData = (mxArray *) * data;
  mxArray *outData = NULL;
#ifndef DO_NOT_CALL_MATLAB
  mxArray *exception = NULL;

  if (!mxIsNumeric(*data) || !mxIsDouble(*data))
    return -1;

  exception = mexCallMATLABWithTrap(1, &outData, 1, &inData, "empty_to_nan");

  if (exception != NULL) {
    my_exceptionGetReport(exception);
    return -1;
  }
#else
  size_t numel;
  double * inArray;
  double * outArray;
  int i;
  
  if (!mxIsNumeric(*data) || !mxIsDouble(*data))
    return -1;

  numel = mxGetNumberOfElements(inData);

  outData = mxDuplicateArray(inData);
  inArray = mxGetData(inData);
  outArray = mxGetData(outData);

  for (i = 0; i < numel; i++)
    if (inArray[i] == EMPTY_DOUBLE)
      outArray[i] = mxGetNaN();
#endif

  *data = outData;
  return 0;
}

/**
   Cast a cell array of strings to a char matrix.
   @param[inout] data mxArray handle
   @result error code
 */
int castCellToChar(mxArray ** data)
{
  mxArray * cellData = (mxArray *) *data;
  mxArray * charData = NULL;
#ifndef DO_NOT_CALL_MATLAB
  mxArray * exception = NULL;

  if (!mxIsCell(*data))
    return -1;

  exception = mexCallMATLABWithTrap(1, &charData, 1, &cellData, "char");

  if(exception != NULL) {
    my_exceptionGetReport(exception);
    return -1;
  }
#else
  size_t numel;
  mxArray * cell;
  char ** strings;
  int i;

  if (!mxIsCell(*data))
    return -1;

  numel = mxGetNumberOfElements(cellData);

  strings = malloc(numel*sizeof(char *));
  for (i = 0; i < numel; i++) {
    cell = mxGetCell(*data, (mwIndex) i);
    if (!mxIsChar(cell))
      return -1;
    strings[i] = mxArrayToString(mxGetCell(*data, (mwIndex) i));
  }

  charData = mxCreateCharMatrixFromStrings((mwSize) numel, (const char **) strings);
  for (i = 0; i < numel; i++)
    mxFree(strings[i]);
  free(strings);
#endif

  *data = charData;
  return 0;
}

/**
   Cast a char matrix to a cell array of strings.
   @param[inout] data mxArray handle
   @result error code
 */
int castCharToCell(mxArray ** data)
{
  mxArray *charData = (mxArray *) * data;
  mxArray *cellData = NULL;
#ifndef DO_NOT_CALL_MATLAB
  mxArray *exception = NULL;

  if (!mxIsChar(*data))
    return -1;

  if (mxGetM(*data) == 0)
    cellData = mxCreateCellMatrix(0, 0);
  else
    exception = mexCallMATLABWithTrap(1, &cellData, 1, &charData, "cellstr");

  if (exception != NULL) {
    my_exceptionGetReport(exception);
    return -1;
  }
#else
  size_t numel;
  size_t m, n;
  mxArray * cell;
  mxChar * inChars;
  char * outChars;
  int length;
  int i, j;

  if (!mxIsChar(*data))
    return -1;

  numel = mxGetNumberOfElements(charData);
  m = mxGetM(*data);
  n = mxGetN(*data);
  inChars = mxGetChars(*data);
  outChars = malloc((n+1)*sizeof(char));

  if (m == 0)
    cellData = mxCreateCellMatrix(0, 0);
  else
    cellData = mxCreateCellMatrix(m, 1);
  for (i=0; i<m; i++) {
    for (j=n-1; j>0; j--)
      if (!(inChars[j*m+i] > 8 && inChars[j*m+i] < 14) /* TAB LF VT FF CR */
	  && inChars[j*m+i] != 32 /* SPACE */
/*	  && inChars[j*m+i] != 133 /* ??? */
/*	  && inChars[j*m+i] != 160 /* NO-BREAK SPACE */
	  ) {
	length = j+1;
	break;
      }
    for (j=0; j<length; j++)
      outChars[j] = (char) inChars[j*m+i];
    outChars[length] = '\000';
    cell = mxCreateString(outChars);
    mxSetCell(cellData, (mwIndex) i, cell);
  }
  free(outChars);
#endif

  *data = cellData;
  return 0;
}

/**
   Cast a cell array of structure to a 1D structure array.
   All structures in the cell array must have the same fields, otherwise an error will be triggered.
   @param[inout] data mxArray handle
   @result error code
 */
int castCellToStruct(mxArray ** data)
{
  mxArray *cellData = (mxArray *) * data;
  mxArray *structData = NULL;
  mxArray *exception = NULL;

  if (!mxIsCell(*data))
    return -1;

  exception = mexCallMATLABWithTrap(1, &structData, 1, &cellData, "cell2mat");

  if (exception != NULL) {
    my_exceptionGetReport(exception);
    return -1;
  }

  *data = structData;
  return 0;
}

/**
   Cast 1D structure array to a cell array of structures.
   @param[inout] data mxArray handle
   @result error code
 */
int castStructToCell(mxArray ** data)
{
  mxArray *structData = (mxArray *) * data;
  mxArray *cellData = NULL;
  mxArray *exception = NULL;
  int i,m,n;
  double *ptr;
  mxArray *M = NULL;
  mxArray *N = NULL;
  mxArray * arguments[3];

  if (!mxIsStruct(*data))
    return -1;

  m = mxGetM(*data);
  M = mxCreateDoubleMatrix(1, m, mxREAL);
  ptr = mxGetPr(M);
  for (i=0; i<m; i++)
    ptr[i] = 1;
    
  n = mxGetN(*data);
  N = mxCreateDoubleMatrix(1, n, mxREAL);
  ptr = mxGetPr(N);
  for (i=0; i<n; i++)
    ptr[i] = 1;

  arguments[0] = structData;
  arguments[1] = M;
  arguments[2] = N;
  exception = mexCallMATLABWithTrap(1, &cellData, 3, arguments, "mat2cell");

  if (exception != NULL) {
    my_exceptionGetReport(exception);
    return -1;
  }

  *data = cellData;
  return 0;
}
