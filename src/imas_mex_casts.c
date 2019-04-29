
#include "imas_mex_utils.h"

int castDoubleToInt32(mxArray ** data)
{
  mxArray * doubleData = (mxArray *) *data;
  mxArray * intData = NULL;
  mxArray * exception = NULL;

  if (!mxIsNumeric(*data) || !mxIsDouble(*data))
    return -1;

  exception = mexCallMATLABWithTrap(1, &intData, 1, &doubleData, "int32");

  if(exception != NULL) {
    my_exceptionGetReport(exception);
    return -1;
  }

  *data = intData;
  return 0;
}

int castInt32ToDouble(mxArray ** data)
{
  mxArray *intData = (mxArray *) * data;
  mxArray *doubleData = NULL;
  mxArray *exception = NULL;

  if (!mxIsNumeric(*data) || !mxIsInt32(*data))
    return -1;

  exception = mexCallMATLABWithTrap(1, &doubleData, 1, &intData, "double");

  if (exception != NULL) {
    my_exceptionGetReport(exception);
    return -1;
  }

  *data = doubleData;
  return 0;
}

int castNaNToEmpty(mxArray ** data)
{
  mxArray *inData = (mxArray *) * data;
  mxArray *outData = NULL;
  mxArray *exception = NULL;

  if (!mxIsNumeric(*data) || !mxIsDouble(*data))
    return -1;

  exception = mexCallMATLABWithTrap(1, &outData, 1, &inData, "nan_to_empty");

  if (exception != NULL) {
    my_exceptionGetReport(exception);
    return -1;
  }

  *data = outData;
  return 0;
}

int castEmptyToNaN(mxArray ** data)
{
  mxArray *inData = (mxArray *) * data;
  mxArray *outData = NULL;
  mxArray *exception = NULL;

  if (!mxIsNumeric(*data) || !mxIsDouble(*data))
    return -1;

  exception = mexCallMATLABWithTrap(1, &outData, 1, &inData, "empty_to_nan");

  if (exception != NULL) {
    my_exceptionGetReport(exception);
    return -1;
  }

  *data = outData;
  return 0;
}

int castCellToChar(mxArray ** data)
{
  mxArray * cellData = (mxArray *) *data;
  mxArray * charData = NULL;
  mxArray * exception = NULL;

  if (!mxIsCell(*data))
    return -1;

  exception = mexCallMATLABWithTrap(1, &charData, 1, &cellData, "char");

  if(exception != NULL) {
    my_exceptionGetReport(exception);
    return -1;
  }

  *data = charData;
  return 0;
}

int castCharToCell(mxArray ** data)
{
  mxArray *charData = (mxArray *) * data;
  mxArray *cellData = NULL;
  mxArray *exception = NULL;

  if (!mxIsChar(*data))
    return -1;

  exception = mexCallMATLABWithTrap(1, &cellData, 1, &charData, "cellstr");

  if (exception != NULL) {
    my_exceptionGetReport(exception);
    return -1;
  }

  *data = cellData;
  return 0;
}

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
