
#include "imas_mex_utils.h"

const char EMPTY_CHAR = '\0';
const int EMPTY_INT = -999999999;
const double EMPTY_DOUBLE = -9.0E40;

char *ual_last_errmsg()
{
    return "ual_last_errmsg_dummy";
}

int get_data_info(int datatype, int dim, mxClassID * classid, mxComplexity * ComplexFlag, size_t * dsize, void ** pdefault)
{
    if (datatype == INTEGER_DATA) {
        *classid = mxINT32_CLASS;
        *ComplexFlag = mxREAL;
        *dsize = sizeof(int);
	if (dim > 0) {
	    *pdefault = NULL;
	} else {
	    *pdefault = malloc(sizeof(int));
	    *(int *)*pdefault = EMPTY_INT;
	}
        return 0;
    }
    if (datatype == DOUBLE_DATA) {
        *classid = mxDOUBLE_CLASS;
        *ComplexFlag = mxREAL;
        *dsize = sizeof(double);
	if (dim > 0) {
	    *pdefault = NULL;
	} else {
	    *pdefault = malloc(sizeof(double));
	    *(double *)*pdefault = EMPTY_DOUBLE;
	}
        return 0;
    }
    if (datatype == CHAR_DATA) {
        *classid = mxCHAR_CLASS;
        *ComplexFlag = mxREAL;
        *dsize = 2*sizeof(char);
	if (dim > 0) {
	    *pdefault = NULL;
	} else {
	    *pdefault = malloc(sizeof(char));
	    *(char *)*pdefault = EMPTY_CHAR;
	}
        return 0;
    }
    /*
    if (datatype == COMPLEX_DATA) {
        *classid = mxDOUBLE_CLASS;
        *ComplexFlag = mxCOMPLEX;
        *dsize = sizeof(double);
        return 0;
	if (dim > 0) {
	    *pdefault = NULL;
	} else {
	    *pdefault = malloc(sizeof(Complex));
	    *(char *)*pdefault = EMPTY_COMPLEX;
	}
    }
    */
    return -1; // TODO: Should we use a unique status ID?
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
    mwSize ndims;
    mwSize dims[MAXDIM];
    mwSize numel = 1;
    int i;

    status = get_data_info(datatype, dim, &classid, &ComplexFlag, &dsize, &array);
    if (status < 0)
        return status;
    status = ual_read_data(ctx, fieldPath, timebasePath, &array, datatype, dim, &retSize[0]);
    if (status < 0)
        return status;
    // Avoid creating emptw arrays for scalars
    ndims = (dim > 0) ? dim : 1;
    dims[0] = 1;
    // Convert array size and compute total number of elements
    for (i = 0; i < dim; i++) {
        dims[i] = (mwSize) retSize[i];
        numel = numel * dims[i];
    }
    *data = mxCreateNumericArray(ndims, dims, classid, ComplexFlag);
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
    // Convert array size and compute total number of elements
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

const mxArray *getSimpleFieldStruct(const mxArray * AosParent, char* path)
{
    /* Extracts field from structure AosParent following '/'-separated path */
    int ifield = -1;
    char *token;
    char *relative_path;
    const mxArray *data = AosParent;
    char *pathcopy = strdup(path);
    // Extract path after last closing bracket
    token = strtok(pathcopy, ")");
    while (token != NULL) {
        relative_path = token;
        token = strtok(NULL, ")");
    }
    // Structure unroll
    token = strtok(relative_path, "/");
    while (token != NULL && data != NULL) {
        if (!mxIsStruct(data) || !mxIsScalar(data)) {
	    data = NULL;
	    break;
	}
        ifield = mxGetFieldNumber(data, token);
        if (ifield < 0) {
	    data = NULL;
	    break;
	}
        data = mxGetFieldByNumber(data, (mwIndex) 0, ifield);
        token = strtok(NULL, "/");
    }
    free(pathcopy);
    return data;
}

int getHomogeneousTime2(const mxArray * ids, int * homogeneousTime)
{
    int cast_status = -1;
    const mxArray *data = NULL;
    data = getSimpleFieldStruct(ids, "ids_properties/homogeneous_time");
    if (data == NULL) {
        puts("ERROR: ids_properties%homogeneous_time is not filled");
        return -1;
    }
    if (!mxIsScalar(data)) {
        puts("ERROR: ids_properties%homogeneous_time is not a scalar");
        return -1;
    }
    if (mxIsDouble(data)) {
      cast_status = castDoubleToInt32(&data);
      if (cast_status < 0)
	return cast_status;
    }
    *homogeneousTime = *(int *) mxGetData(data);
    if (cast_status == 0)
      mxDestroyArray((mxArray *) data);
    return 0;
}

int castDoubleToInt32(const mxArray ** data)
{
    mxArray * doubleData = (mxArray *) *data;
    mxArray * intData = NULL;
    mxArray * exception = NULL;

    if (!mxIsNumeric(*data) || !mxIsDouble(*data))
        return -1;

    exception = mexCallMATLABWithTrap(1, &intData, 1, &doubleData, "int32");

    if(exception != NULL) {
        return -1;
    }

    *data = intData;
    return 0;
}

int castCellToChar(const mxArray ** data)
{
    mxArray * cellData = (mxArray *) *data;
    mxArray * charData = NULL;
    mxArray * exception = NULL;

    if (!mxIsCell(*data))
        return -1;

    exception = mexCallMATLABWithTrap(1, &charData, 1, &cellData, "char");

    if(exception != NULL) {
        return -1;
    }

    *data = charData;
    return 0;
}

