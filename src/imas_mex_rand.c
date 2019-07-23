#include "imas_mex_utils.h"
#include <complex.h>

int powint(int base, unsigned int exp) {
  int result=1;
  int i;
  
  for (i=0;i<exp;i++)
    result=result*base;

  return result;
} 

int rand_integer(void) {
  return (int) random() - RAND_MAX/2;
}

double rand_double(void) {
  return 2*(((double) random())/RAND_MAX)-1;
}

void rand_complex(double * z) {
  z[0] = 2*(((double) random())/RAND_MAX)-1;
  z[1] = 2*(((double) random())/RAND_MAX)-1;
}

mxArray * rand_time(size_t ntime, int slice)
{
  void * array;
  mxArray * data;
  int i;

  if (slice) {
    data = mxCreateDoubleScalar((double) slice);
  } else {
    data = mxCreateNumericMatrix(ntime, 1, mxDOUBLE_CLASS, mxREAL);
    array = mxGetData(data);
    for (i=0;i<ntime;i++)
      ((double *) array)[i] = (double) i+1;
  }

  return data;
}

mxArray * rand_string(void) {
  return mxCreateString("12 34 56 78 90");
}

mxArray * rand_array(int datatype, int dim, int dynamic, size_t ntime, int slice)
{
  mwSize size[MAXDIM];
  mwSize ndims;
  size_t numel = 1;
  double z[2];
  void * array;
  void * array_imag;
  void * array_slice;
  mxArray * data;
  int i;

  /* newLL: string scalar == (dim == 1), string array == (dim == 2) */
  if (datatype == CHAR_DATA)
    dim = dim-1;
  /* Avoid creating empty arrays for scalars */
  ndims = (dim > 0) ? dim : 1;
  size[0] = 1;
  for (i=0;i<dim;i++)
    size[i] = (mwSize) powint(2,random()%5);
  if ( dynamic && dim > 0 )
    size[dim-1] = (mwSize) ntime;

  for (i=0;i<dim;i++)
    numel = numel*size[i];

  if (datatype == INTEGER_DATA) {
    data = mxCreateNumericArray(ndims, size, mxINT32_CLASS, mxREAL);
    array = mxGetData(data);
    for (i=0;i<numel;i++)
      ((int *) array)[i] = rand_integer();
    if (slice && dynamic && dim > 0) {
      array_slice = mxMalloc(numel/ntime*sizeof(int));
      memcpy(array_slice,&((int *) array)[numel/ntime*(slice-1)],numel/ntime*sizeof(int));
      mxFree(array);
      mxSetData(data, array_slice);
      ndims = (dim > 1) ? dim-1 : 1;
      size[dim-1] = 1;
      mxSetDimensions(data, size, ndims);
    }
  }
  else if (datatype == DOUBLE_DATA) {
    data = mxCreateNumericArray(ndims, size, mxDOUBLE_CLASS, mxREAL);
    array = mxGetData(data);
    for (i=0;i<numel;i++)
      ((double *) array)[i] = rand_double();
    if (slice && dynamic && dim > 0) {
      array_slice = mxMalloc(numel/ntime*sizeof(double));
      memcpy(array_slice,&((double *) array)[numel/ntime*(slice-1)],numel/ntime*sizeof(double));
      mxFree(array);
      mxSetData(data, array_slice);
      ndims = (dim > 1) ? dim-1 : 1;
      size[dim-1] = 1;
      mxSetDimensions(data, size, ndims);
    }
  }
  else if (datatype == COMPLEX_DATA) {
    data = mxCreateNumericArray(ndims, size, mxDOUBLE_CLASS, mxCOMPLEX);
    array = mxGetData(data);
    array_imag = mxGetImagData(data);
    for (i=0;i<numel;i++) {
      rand_complex(&z[0]);
      ((double *) array)[i]      = z[0];
      ((double *) array_imag)[i] = z[1];
    }
    if (slice && dynamic && dim > 0) {
      array_slice = mxMalloc(numel/ntime*sizeof(double));
      memcpy(array_slice,&((double *) array)[numel/ntime*(slice-1)],numel/ntime*sizeof(double));
      mxFree(array);
      mxSetData(data, array_slice);
      array_slice = mxMalloc(numel/ntime*sizeof(double));
      memcpy(array_slice,&((double *) array_imag)[numel/ntime*(slice-1)],numel/ntime*sizeof(double));
      mxFree(array_imag);
      mxSetImagData(data, array_slice);
      ndims = (dim > 1) ? dim-1 : 1;
      size[dim-1] = 1;
      mxSetDimensions(data, size, ndims);
    }
  }
  else if (datatype == CHAR_DATA) {
    if (dim == 0) {
      data = rand_string();
    } else {
      array = malloc(numel*sizeof(char *));
      for (i=0;i<numel;i++) {
	((char **) array)[i] = malloc(8*sizeof(char));
	snprintf(((char **) array)[i],8,"label%d",i);
      }
      if (dynamic && slice) {
	data = mxCreateCellMatrix(1,1);
	mxSetCell(data, (mwIndex) 0, mxCreateString(((char **) array)[slice-1]));
      } else {
	data = mxCreateCellMatrix(numel,1);
	for (i=0;i<numel;i++)
	  mxSetCell(data, (mwIndex) i, mxCreateString(((char **) array)[i]));
      }
      for (i=0;i<numel;i++)
	free(((char **) array)[i]);
      free(array);
    }
  }

  return data;
}
