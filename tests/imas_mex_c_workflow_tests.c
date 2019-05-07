#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <dlfcn.h>
#include <sys/time.h>

#include "mex.h"

typedef void (*mexFunction_t)(int nargout, mxArray * pargout [], int nargin, const mxArray * pargin []);


mexFunction_t imas_set_mex_params;
mexFunction_t imas_open_env;
mexFunction_t imas_create_env;
mexFunction_t imas_close;
mexFunction_t ids_put;
mexFunction_t ids_get;


int test_imas_mex(int run)
{
  int i;
  mxArray * ids;
  
  mxArray * m_treename;
  mxArray * m_shot;
  mxArray * m_runr;
  mxArray * m_runw;
  mxArray * m_name;
  mxArray * m_usr;
  mxArray * m_tok;
  mxArray * m_ver;
  mxArray * idx;

  const mxArray *args_open_env[3];
  const mxArray *args_create_env[5];
  const mxArray *args_close[1];
  const mxArray *args_put[3];
  const mxArray *args_get[2];

  struct timeval time_s;
  struct timeval time_e;
  long elapsed;
  double mean;
  
  m_treename = mxCreateString("ids");
  m_shot = mxCreateDoubleScalar(9999);
  m_runr  = mxCreateDoubleScalar(run);
  m_runw  = mxCreateDoubleScalar(run+9700);
  m_name = mxCreateString("magnetics");
  m_usr  = mxCreateString(getenv("USER"));
  m_tok  = mxCreateString("test");
  m_ver  = mxCreateString("3");

  // IMAS_OPEN_ENV
  args_open_env[0] = m_treename;
  args_open_env[1] = m_shot;
  args_open_env[2] = m_runr;
  args_open_env[3] = m_usr;
  args_open_env[4] = m_tok;
  args_open_env[5] = m_ver;
  
  imas_open_env(1, &idx, 6, args_open_env);

  // IDS_GET
  args_get[0] = idx;
  args_get[1] = m_name;

  for (i=0; i<2; i++)
    ids_get(1, &ids, 2, args_get);

  mean = 0;
  for (i=0; i<8; i++) {
    gettimeofday(&time_s, NULL);
    ids_get(1, &ids, 2, args_get);
    gettimeofday(&time_e, NULL);
    elapsed = (long)(time_e.tv_sec - time_s.tv_sec)*1000000 + (long) (time_e.tv_usec - time_s.tv_usec);
    mean = mean + ((double) elapsed)/1000/8;
  }
  printf("Get %s [run = %4d, ntime = %4d] Mean time [ms]: %12.3f\n",mxArrayToString(m_name),run,mxGetNumberOfElements(mxGetField(ids,0,"time")),mean);

  // IMAS_CLOSE
  args_close[0] = idx;

  imas_close(0, NULL, 1, args_close);

  // IMAS_CREATE_ENV
  args_create_env[0] = m_treename;
  args_create_env[1] = m_shot;
  args_create_env[2] = m_runw;
  args_create_env[3] = m_shot;
  args_create_env[4] = m_runw;
  args_create_env[5] = m_usr;
  args_create_env[6] = m_tok;
  args_create_env[7] = m_ver;
  
  imas_create_env(1, &idx, 8, args_create_env);

  // IDS_PUT
  args_put[0] = idx;
  args_put[1] = m_name;
  args_put[2] = ids;

  for (i=0; i<2; i++)
    ids_put(0, NULL, 3, args_put);

  mean = 0;
  for (i=0; i<8; i++) {
    gettimeofday(&time_s, NULL);
    ids_put(0, NULL, 3, args_put);
    gettimeofday(&time_e, NULL);
    elapsed = (long)(time_e.tv_sec - time_s.tv_sec)*1000000 + (long) (time_e.tv_usec - time_s.tv_usec);
    mean = mean + ((double) elapsed)/1000/8;
  }
  printf("Put %s [run = %4d, ntime = %4d] Mean time [ms]: %12.3f\n",mxArrayToString(m_name),run+9700,mxGetNumberOfElements(mxGetField(ids,0,"time")),mean);

  // IMAS_CLOSE
  args_close[0] = idx;

  imas_close(0, NULL, 1, args_close);

}

int getMexFunction(char * name, mexFunction_t * fun_handle) {

  void * handle;

  handle = dlopen(name, RTLD_NOW);
  if (handle == NULL) {
    fprintf(stderr,"\nError loading MEX-file %s: %s\n", name, strerror(errno));
    return -1;
  }
  *fun_handle = (mexFunction_t)dlsym(handle, "mexFunction");
  if (*fun_handle == NULL) {
    fprintf(stderr,"\nMEX-file %s does not contain mexFunction\n", name);
    return -1;
  }

  return 0;

}


int main(int argc, const char *argv[])
{

  int status;
  int run;

  const mxArray *args_set[2];

  if (getMexFunction("imas_set_mex_params.mexa64", &imas_set_mex_params) < 0)
    return -1;

  if (getMexFunction("imas_open_env.mexa64", &imas_open_env) < 0)
    return -1;

  if (getMexFunction("imas_create_env.mexa64", &imas_create_env) < 0)
    return -1;

  if (getMexFunction("ids_get.mexa64", &ids_get) < 0)
    return -1;

  if (getMexFunction("ids_put.mexa64", &ids_put) < 0)
    return -1;

  if (getMexFunction("imas_close.mexa64", &imas_close) < 0)
    return -1;

  args_set[0] = mxCreateString("put_int_from_double");
  args_set[1] = mxCreateDoubleScalar(0);

  imas_set_mex_params(0, NULL, 2, args_set);
  /*
  args_set[0] = mxCreateString("use_cell_array_for_array_of_structures");
  args_set[1] = mxCreateDoubleScalar(0);

  imas_set_mex_params(0, NULL, 2, args_set);
  */
  for (run = 1; run < 4; run++)
    status = test_imas_mex(run);

  return 0;

}
    
