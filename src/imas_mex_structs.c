
#include "imas_mex_utils.h"

struct data_struct {
  struct data_struct * parent;
  struct data_struct * aosParent;
  mxArray * data;
  size_t index;
  size_t size;
  int isArray;
};

struct data_struct * dataTree;

void free_dataTree() {

  struct data_struct * dataTree_old;

  while (dataTree != NULL) {
    dataTree_old = dataTree;
    dataTree = dataTree->parent;
    free(dataTree_old);
  }

}  

int init_dataTree_read(mxArray** data) {

  int status;
  
  if (dataTree != NULL)
    free_dataTree();

  *data = mxCreateStructMatrix(1, 1, 0, NULL);
  
  dataTree = malloc(sizeof(struct data_struct));
  if (!dataTree) {
    strncpy(mex_errmsgid,"out_of_memory",14);
    strncpy(mex_errmsgtxt,"Out of memory in init_dataTree_read",36);
    return -1;
  }
    
  dataTree->parent = NULL;
  dataTree->data = *data;
  dataTree->index = 0;
  dataTree->size = 1;
  dataTree->aosParent = NULL;
  dataTree->isArray = 0;

  return 0;

}

int init_dataTree_write(mxArray * data) {

  int status;
  
  if (dataTree != NULL)
    free_dataTree();
  
  dataTree = malloc(sizeof(struct data_struct));
  if (!dataTree) {
    strncpy(mex_errmsgid,"out_of_memory",14);
    strncpy(mex_errmsgtxt,"Out of memory in init_dataTree_write",37);
    return -1;
  }

  dataTree->parent = NULL;
  dataTree->data = data;
  dataTree->index = 0;
  dataTree->size = 1;
  dataTree->aosParent = NULL;
  dataTree->isArray = 0;

  return 0;

} 

int begin_dataTree_read(char * name) {

  mxArray * data;
  struct data_struct * child;
  int ifield;

  data = mxCreateStructMatrix(1,1,0,NULL);

  if (put_data_in_dataTree(name, data) < 0)
    return -1;

  child = malloc(sizeof(struct data_struct));
  if (!dataTree) {
    strncpy(mex_errmsgid,"out_of_memory",14);
    strncpy(mex_errmsgtxt,"Out of memory in begin_dataTree_read",37);
    return -1;
  }

  child->parent = dataTree;
  child->data = data;
  child->index = 0;
  child->size = 1;
  child->aosParent = dataTree->aosParent;
  child->isArray = 0;

  dataTree = child;

  return 0;
}

int begin_dataTree_write(char * name, int * isEmpty) {

  mxArray * data;
  struct data_struct * child;

  if (get_data_from_dataTree(name, &data) < 0)
    return -1;

  if (!mxIsStruct(data) || 
      ( mxIsEmpty(data) && params.error_on_missing_field) || 
      (!mxIsEmpty(data) && !mxIsScalar(data))) {
    strncpy(mex_errmsgid,"invalid_structure",18);
    snprintf(mex_errmsgtxt,MAXERRMSGTXTSIZE,"Value of field %s is invalid",name);
    return -1;
  }

  *isEmpty = mxIsEmpty(data);

  child = malloc(sizeof(struct data_struct));
  if (!dataTree) {
    strncpy(mex_errmsgid,"out_of_memory",14);
    strncpy(mex_errmsgtxt,"Out of memory in begin_dataTree_write",38);
    return -1;
  }

  child->parent = dataTree;
  child->data = data;
  child->index = 0;
  child->size = 1;
  child->aosParent = dataTree->aosParent;
  child->isArray = 0;

  dataTree = child;

  return 0;
}

int begin_dataTree_array_read(char * name, int aosArraySize) {

  mxArray * data;
  struct data_struct * child;
  mwIndex i;
  
  if (aosArraySize == 0) {
    // Special case for empty arrays
    if (params.use_cell_array_for_array_of_structures) {
      data = mxCreateCellMatrix(0, 0);
    } else {
      data = mxCreateStructMatrix(0, 0, 0, NULL);
    }
  } else {
    if (params.use_cell_array_for_array_of_structures) {
      data = mxCreateCellMatrix(aosArraySize, 1);
      for (i = 0; i < aosArraySize; i++)
	mxSetCell(data, i, mxCreateStructMatrix(1, 1, 0, NULL));
    } else
      data = mxCreateStructMatrix(aosArraySize, 1, 0, NULL);
  }  

  if (put_data_in_dataTree(name, data) < 0)
    return -1;

  child = malloc(sizeof(struct data_struct));
  if (!dataTree) {
    strncpy(mex_errmsgid,"out_of_memory",14);
    strncpy(mex_errmsgtxt,"Out of memory in begin_dataTree_array_read",53);
    return -1;
  }

  child->parent = dataTree;
  child->data = data;
  child->index = 0;
  child->size = aosArraySize;
  child->aosParent = child;
  child->isArray = 1;

  dataTree = child;

  return 0;
}

int begin_dataTree_array_write(char * name, int * aosArraySize) {

  mxArray * data;
  struct data_struct * child;

  if (get_data_from_dataTree(name, &data) < 0)
    return -1;

  if (!mxIsEmpty(data) && 
      ( params.use_cell_array_for_array_of_structures && !mxIsCell(data)) ||
      (!params.use_cell_array_for_array_of_structures && !mxIsStruct(data))) {
    strncpy(mex_errmsgid,"invalid_struct_array",21);
    snprintf(mex_errmsgtxt,MAXERRMSGTXTSIZE,"Value of field %s is invalid",name);
    return -1;
  }

  *aosArraySize = mxGetNumberOfElements(data);

  child = malloc(sizeof(struct data_struct));
  if (!dataTree) {
    strncpy(mex_errmsgid,"out_of_memory",14);
    strncpy(mex_errmsgtxt,"Out of memory in begin_dataTree_array_write",54);
    return -1;
  }

  child->parent = dataTree;
  child->data = data;
  child->index = 0;
  child->size = *aosArraySize;
  child->aosParent = child;
  child->isArray = 1;

  dataTree = child;

  return 0;
}

int end_dataTree_action() {

  struct data_struct * parent;

  if (dataTree == NULL) {
    strncpy(mex_errmsgid,"invalid_dataTree",14);
    strncpy(mex_errmsgtxt,"Invalid dataTree in end_dataTree_action",40);
    return -1;
  }
  
  parent = dataTree->parent;
  free(dataTree);
  dataTree = parent;

  return 0;
}

int end_dataTree_array_action() {

  struct data_struct * parent;

  if (dataTree == NULL) {
    strncpy(mex_errmsgid,"invalid_dataTree",14);
    strncpy(mex_errmsgtxt,"Invalid dataTree in end_dataTree_array_action",46);
    return -1;
  }
  
  if (params.use_cell_array_for_array_of_structures) {
    if (!mxIsCell(dataTree->data)) { // We have already iterated on this array
      parent = dataTree->parent;
      free(dataTree);
      dataTree = parent;
    }
    if (!mxIsCell(dataTree->data))
      return -1;
  }
  parent = dataTree->parent;
  free(dataTree);
  dataTree = parent;

  return 0;
}

int iterate_dataTree_array(size_t index) {

  struct data_struct * child;
  struct data_struct * parent;
  mxArray * data;
  
  if (dataTree == NULL) {
    strncpy(mex_errmsgid,"invalid_dataTree",14);
    strncpy(mex_errmsgtxt,"Invalid dataTree in iterate_dataTree_array",43);
    return -1;
  }

  if (params.use_cell_array_for_array_of_structures) {
    if (!mxIsCell(dataTree->data)) { // We have already iterated on this array
      parent = dataTree->parent;
      free(dataTree);
      dataTree = parent;
    }
    if (!mxIsCell(dataTree->data)) {
      strncpy(mex_errmsgid,"invalid_dataTree",14);
      strncpy(mex_errmsgtxt,"dataTree is not a cell in iterate_dataTree_array",49);
      return -1;
    }

    if (index < 0 || index > dataTree->size-1) {
      strncpy(mex_errmsgid,"invalid_index",14);
      strncpy(mex_errmsgtxt,"Invalid index in iterate_dataTree_array",40);
      return -1;
    }
      
    data = mxGetCell(dataTree->data, index);
    
    if (data == NULL) {
      strncpy(mex_errmsgid,"invalid_AoS_element",20);
      snprintf(mex_errmsgtxt,MAXERRMSGTXTSIZE,"Unable to retrieve element %d in data AoS",index);
      return -1;
    }

    child = malloc(sizeof(struct data_struct));
    if (!dataTree) {
      strncpy(mex_errmsgid,"out_of_memory",14);
      strncpy(mex_errmsgtxt,"Out of memory in iterate_dataTree_array",40);
      return -1;
    }

    child->parent = dataTree;
    child->aosParent = child;
    child->data = data;
    child->index = 0;
    child->size = 1;
    child->isArray = 0;

    dataTree = child;
    
  } else {

    if (index < 0 || index > dataTree->size-1) {
      strncpy(mex_errmsgid,"invalid_index",14);
      strncpy(mex_errmsgtxt,"Invalid index in iterate_dataTree_array",40);
      return -1;
    }

    dataTree->index = index;

  }

  return 0;
}

int get_data_from_dataTree(char * name, mxArray ** data) {

  int ifield;

  ifield = mxGetFieldNumber(dataTree->data, name);
  *data = mxGetFieldByNumber(dataTree->data, (mwIndex) dataTree->index, ifield);

  if (ifield < 0) {
    if (params.error_on_missing_field) {
      strncpy(mex_errmsgid,"invalid_field",14);
      snprintf(mex_errmsgtxt, 26+strnlen(name,MAXERRMSGTXTSIZE-1)+1, "Unable to retrieve field %s", name);
      return -1;
    } else {
      *data = NULL;
    }
  }

  return 0;

}

int put_data_in_dataTree(char * name, mxArray * data) {

  int ifield;

  ifield = mxAddField(dataTree->data, name);

  if (ifield < 0) {
    strncpy(mex_errmsgid,"setfield_failed",14);
    snprintf(mex_errmsgtxt, 34+strnlen(name,MAXERRMSGTXTSIZE-1)+1, "Unable to add field %s to structure", name);
    return -1;
  }

  mxSetFieldByNumber(dataTree->data, dataTree->index, ifield, data);

  return 0;

}

int replace_data_in_dataTree(char * name, mxArray * data) {

  int ifield;
  mxArray * data_old;

  if (get_data_from_dataTree(name, &data_old) < 0)
    return -1;

  if (data_old != NULL)
    mxDestroyArray(data_old);

  ifield = mxGetFieldNumber(dataTree->data, name);
  mxSetFieldByNumber(dataTree->data, dataTree->index, ifield, data);

  return 0;

}

int getSimpleFieldStruct(char *path, const mxArray ** data)
{
  /* Extracts field from structure AosParent following '/'-separated path */

  int ifield = -1;
  char *token;
  char *relative_path;
  char *pathcopy = strdup(path);
  int status = 0;
  mwIndex index;

  if (!dataTree)
    return -1;

  // Extract path after last closing bracket
  token = strtok(pathcopy, ")");
  while (token != NULL) {
    relative_path = token;
    token = strtok(NULL, ")");
  }

  // Structure unroll
  token = strtok(relative_path, "/");
  if (dataTree->aosParent) {
    *data = (const mxArray *) dataTree->aosParent->data;
    index = dataTree->aosParent->index;
  } else {
    *data = (const mxArray *) dataTree->data;
    index = dataTree->index;
  }
  while (token != NULL && *data != NULL) {
    if (!mxIsStruct(*data) || 
	(params.use_cell_array_for_array_of_structures && !mxIsScalar(*data))) {
      status = -1;
      *data = NULL;
      break;
    }
    ifield = mxGetFieldNumber(*data, token);
    if (ifield < 0) {
      status = -1;
      *data = NULL;
      break;
    }
    *data = (const mxArray *) mxGetFieldByNumber(*data, index, ifield);
    token = strtok(NULL, "/");
    index = 0; // Only the first item can be an array
  }
  free(pathcopy);
  return status;
}

int getHomogeneousTime(int *homogeneousTime)
{
  int status = -1;
  const mxArray *data = NULL;
  status = getSimpleFieldStruct("ids_properties/homogeneous_time", &data);
  if (status < 0 || data == NULL) {
    strncpy(mex_errmsgid,"homogeneous_time_required",26);
    strncpy(mex_errmsgtxt,"ids_properties%homogeneous_time is not filled",46);
    return -1;
  }
  if (!mxIsNumeric(data) || !mxIsScalar(data)) {
    strncpy(mex_errmsgid,"invalid_homogeneous_time",26);
    strncpy(mex_errmsgtxt,"ids_properties%homogeneous_time is not a numeric scalar",56);
    return -1;
  }
  if (mxIsInt32(data)) {
    *homogeneousTime = *(int *) mxGetData(data);
  } else {
    *homogeneousTime = (int) mxGetScalar(data);
  }
  return 0;
}
