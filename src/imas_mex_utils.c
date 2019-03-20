
#include "imas_mex_utils.h"

const int EMPTY_INT = -999999999;
const float EMPTY_FLOAT = -9.0E35;
const double EMPTY_DOUBLE = -9.0E40;

char *ual_last_errmsg()
{
    return "ual_last_errmsg_dummy";
}

int get_data_info(int datatype, mxClassID * classid, mxComplexity * ComplexFlag, size_t * dsize)
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
    return -1; // Should we use a unique status ID?
}

int read_data_to_mxArray(int ctx, const char *fieldPath, const char *timebasePath, int datatype, int dim, mxArray ** data)
{
    int status;
    int retSize[MAXDIM];
    void *array;
    mxChar *chararray;
    mxClassID classid;
    mxComplexity ComplexFlag;
    size_t dsize;
    mwSize size[dim];
    mwSize numel = 1;
    int i;

    status = ual_read_data(ctx, fieldPath, timebasePath, &array, datatype, dim, &retSize[0]);
    if (status < 0)
        return status;
    status = get_data_info(datatype, &classid, &ComplexFlag, &dsize);
    if (status < 0)
        return status;
    // Convert array size and compute total number of elements
    for (i = 0; i < dim; i++) {
        size[i] = (mwSize) retSize[i];
        numel = numel * size[i];
    }
    *data = mxCreateNumericArray((mwSize) dim, size, classid, ComplexFlag);
    if (datatype != CHAR_DATA) {
      // integer and double data map directly to MATLAB types
      memcpy(mxGetData(*data), array, numel * dsize);
    } else {
      // MATLAB uses mxChar (uint16) to represent char arrays
      chararray = mxGetData(*data);
      for (i = 0; i < numel; i++) 
        chararray[i] = (mxChar) ((char *) array)[i];
    }
    free(array);
    return status;
}

int write_data_from_mxArray(int ctx, const char *fieldPath, const char *timebasePath, int datatype, int dim, const mxArray *data)
{
    int status;
    void *array;
    mxChar *chararray;
    int ndims;
    const mwSize *dims;
    mwSize numel = 1;
    int size[MAXDIM];
    int i;

    ndims = mxGetNumberOfDimensions(data);
    dims = mxGetDimensions(data);
    // cases with ndims=0 (empty array) should not land here
    for (i = 0; i < dim; i++) {
      size[i] = ndims > i ? (int) dims[i] : 1;
      numel = numel * size[i];
    }
    if (datatype != CHAR_DATA) {
      // integer and double data map directly to MATLAB types
      array = mxGetData(data);
    } else {
      // MATLAB uses mxChar (uint16) to represent char arrays
      chararray = (mxChar *) mxGetChars(data);
      array = malloc(numel*sizeof(char));
      for (i = 0; i < numel; i++)
	((char *)array)[i] = (char) chararray[i];
    }
    status = ual_write_data(ctx, fieldPath, timebasePath, array, datatype, dim, size);
    return status;
}

int getHomogeneousTime(int ctx, int *homogeneousTime)
{
    int status = 0;
    char *fieldPath = "ids_properties/homogeneous_time";
    char *timebasePath = "";

    status = getInt(ctx, fieldPath, timebasePath, homogeneousTime);

    return status;
}
