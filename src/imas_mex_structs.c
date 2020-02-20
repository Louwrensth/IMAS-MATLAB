/** \addtogroup utils MEX-utils
 *  @{
 */

/**
   \file src/imas_mex_structs.c
   Browsing data structures
 */

/** @}*/

#if defined(CELL_AOS) && defined(STRUCT_AOS)
#error "CELL_AOS and STRUCT_AOS cannot be defined at the same time"
#endif

#include "imas_mex_utils.h"
/**
   Linked list containing information about IDS structure in its MATLAB form.
 */
struct data_struct {
  struct data_struct * parent;    /*!< pointer to parent data object */
  struct data_struct * aosParent; /*!< pointer to closest parent of type 'struct_array' */
  mxArray * data;                 /*!< pointer to the mxArray object containing the data */
  size_t index;                   /*!< For array of structures, indicates which index is currently opened */
  size_t size;                    /*!< For array of structures, indicates the size of the array */
  int isArray;                    /*!< Indicates if current object is an array of structures */
};

/**
   Global variable for the current data_struct object
 */
struct data_struct * dataTree;


/**
   Clears the dataTree variable
 */
void free_dataTree() {

  struct data_struct * dataTree_old;

  while (dataTree != NULL) {
    dataTree_old = dataTree;
    dataTree = dataTree->parent;
    free(dataTree_old);
  }

}

/**
   Initialises dataTree for a reading action.
   The current object in dataTree is freed and then a new empty one is created starting from a scalar structure containing no fields. The fields will be later created and filled, for example from reading the IDS pulse file.
   \returns error flag.
 */
al_status_t init_dataTree_read() {

  al_status_t status;
  mxArray * data;
  
  if (dataTree != NULL)
    free_dataTree();

  data = mxCreateStructMatrix(1, 1, 0, NULL);
  
  dataTree = malloc(sizeof(struct data_struct));
  if (!dataTree) {
    mex_errmsgid = "out_of_memory";
    strncpy(mex_errmsgtxt,"Out of memory in init_dataTree_read",36);
    msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
    status.code = HLI_ERR;
    return status;
  }
    
  dataTree->parent = NULL;
  dataTree->data = data;
  dataTree->index = 0;
  dataTree->size = 1;
  dataTree->aosParent = NULL;
  dataTree->isArray = 0;

  status.code = 0;
  return status;

}

/**
   Initialises dataTree for a writing action.
   The current object in dataTree is freed and then a new empty one is created starting from a given structure. Its fields will be later used, for example to write to an IDS pulse file.
   @param[in] data contains the original structure.
   \returns error flag.
 */
al_status_t init_dataTree_write(mxArray * data) {
  
  al_status_t status;

  if (dataTree != NULL)
    free_dataTree();
  
  dataTree = malloc(sizeof(struct data_struct));
  if (!dataTree) {
    mex_errmsgid = "out_of_memory";
    strncpy(mex_errmsgtxt,"Out of memory in init_dataTree_write",37);
    msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
    status.code = HLI_ERR;
    return status;
  }

  dataTree->parent = NULL;
  dataTree->data = data;
  dataTree->index = 0;
  dataTree->size = 1;
  dataTree->aosParent = NULL;
  dataTree->isArray = 0;

  status.code = 0;
  return status;

} 

/**
   Initialises dataTree with an array for a reading action.
   The current object in dataTree is freed and then a new empty one is created starting from a cell array containing a given number of scalar structures containing no fields.
   \returns error flag.
   \note This is currently used only in the ids_allocate MEX-file.
   \note This seems like a bit of a hack ...
 */
al_status_t init_dataTree_array_read(int aosArraySize) {

  al_status_t status;
  mxArray * data;
  mwIndex i;
  
  if (dataTree != NULL)
    free_dataTree();
  
  dataTree = malloc(sizeof(struct data_struct));
  if (!dataTree) {
    mex_errmsgid = "out_of_memory";
    strncpy(mex_errmsgtxt,"Out of memory in init_dataTree_write",37);
    msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
    status.code = HLI_ERR;
    return status;
  }
  
  if (aosArraySize == 0) {
    /* Special case for empty arrays */
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

  dataTree->parent = NULL;
  dataTree->data = data;
  dataTree->index = 0;
  dataTree->size = aosArraySize;
  dataTree->aosParent = dataTree;
  dataTree->isArray = 1;

  status.code = 0;
  return status;

}

/**
   Initialises dataTree with an array for a writing action.
   The current object in dataTree is freed and then a new empty one is created starting from the input cell array.
   \returns error flag.
   \note This is currently not used and was created only to match the #init_dataTree_array_read function.
 */
al_status_t init_dataTree_array_write(mxArray * data, int * aosArraySize) {
  
  al_status_t status;

  if (dataTree != NULL)
    free_dataTree();
  
  dataTree = malloc(sizeof(struct data_struct));
  if (!dataTree) {
    mex_errmsgid = "out_of_memory";
    strncpy(mex_errmsgtxt,"Out of memory in init_dataTree_write",37);
    msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
    status.code = HLI_ERR;
    return status;
  }

  *aosArraySize = mxGetNumberOfElements(data);

  dataTree->parent = NULL;
  dataTree->data = data;
  dataTree->index = 0;
  dataTree->size = *aosArraySize;
  dataTree->aosParent = dataTree;
  dataTree->isArray = 1;

  status.code = 0;
  return status;

} 

/**
   Adds a new structure to the current dataTree object.
   A new scalar structure is created and added to the current dataTree object under the name given in input. A new data_struct object is created and prepended to the start of the dataTree list.
   \param[in] name String containing the structure's name.
   \returns error flag.
 */
al_status_t begin_dataTree_read(char * name) {

  al_status_t status;
  mxArray * data;
  struct data_struct * child;
  int ifield;

  data = mxCreateStructMatrix(1,1,0,NULL);

  status = put_data_in_dataTree(name, data);
  if (status.code < 0)
    return status;

  child = malloc(sizeof(struct data_struct));
  if (!dataTree) {
    mex_errmsgid = "out_of_memory";
    strncpy(mex_errmsgtxt,"Out of memory in begin_dataTree_read",37);
    msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
    status.code = HLI_ERR;
    return status;
  }

  child->parent = dataTree;
  child->data = data;
  child->index = 0;
  child->size = 1;
  child->aosParent = dataTree->aosParent;
  child->isArray = 0;

  dataTree = child;

  return status;
}

/**
   Recurses into an existing structure from the current dataTree object.
   The field "name" is extracted from the current dataTree object. The mxArray must be a scalar structure. A new data_struct object is created and prepended to the start of the dataTree list.
   \param[in] name String containing the structure's name.
   \param[out] isEmpty Flag indicating if the extracted structure is empty.
   \returns error flag.
 */
al_status_t begin_dataTree_write(char * name, int * isEmpty) {

  al_status_t status;
  mxArray * data;
  int isStruct;
  struct data_struct * child;

  status = get_data_from_dataTree(name, &data);
  if (status.code < 0)
    return status;

  *isEmpty = (data == NULL) || mxIsEmpty(data);
  isStruct = (data != NULL) && mxIsStruct(data) && mxIsScalar(data);

  if (!isStruct && (!*isEmpty || params.error_on_missing_field)) {
    mex_errmsgid = "invalid_structure";
    snprintf(mex_errmsgtxt,MAXERRMSGTXTSIZE,"Value of field %s is invalid",name);
    msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
    status.code = HLI_ERR;
    return status;
  }

  child = malloc(sizeof(struct data_struct));
  if (!dataTree) {
    mex_errmsgid = "out_of_memory";
    strncpy(mex_errmsgtxt,"Out of memory in begin_dataTree_write",38);
    msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
    status.code = HLI_ERR;
    return status;
  }

  child->parent = dataTree;
  child->data = data;
  child->index = 0;
  child->size = 1;
  child->aosParent = dataTree->aosParent;
  child->isArray = 0;

  dataTree = child;

  return status;
}

/**
   Adds a new array of structures to the current dataTree object.
   A new cell/structure array is created and added to the current dataTree object under the name given in input. A new data_struct object is created and prepended to the start of the dataTree list.
   \param[in] name String containing the structure's name.
   \param[in] aosArraySize Size of the array.
   \returns error flag.
 */
al_status_t begin_dataTree_array_read(char * name, int aosArraySize) {

  al_status_t status;
  mxArray * data;
  struct data_struct * child;
  mwIndex i;
  
  if (aosArraySize == 0) {
    /* Special case for empty arrays */
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

  status = put_data_in_dataTree(name, data);
  if (status.code < 0)
    return status;

  child = malloc(sizeof(struct data_struct));
  if (!dataTree) {
    mex_errmsgid = "out_of_memory";
    strncpy(mex_errmsgtxt,"Out of memory in begin_dataTree_array_read",53);
    msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
    status.code = HLI_ERR;
    return status;
  }

  child->parent = dataTree;
  child->data = data;
  child->index = -1;
  child->size = aosArraySize;
  child->aosParent = child;
  child->isArray = 1;

  dataTree = child;

  return status;
}

/**
   Recurses into an existing array of structure from the current dataTree object.
   The field "name" is extracted from the current dataTree object. The mxArray must be a cell/structure array. A new data_struct object is created and prepended to the start of the dataTree list.
   \param[in] name String containing the array's name.
   \param[out] aosArraySize Size of the array.
   \returns error flag.
 */
al_status_t begin_dataTree_array_write(char * name, int * aosArraySize) {

  al_status_t status;
  mxArray * data;
  struct data_struct * child;

  status = get_data_from_dataTree(name, &data);
  if (status.code < 0)
    return status;

  if ((data != NULL && !mxIsEmpty(data)) && 
      ( params.use_cell_array_for_array_of_structures && !mxIsCell(data)) ||
      (!params.use_cell_array_for_array_of_structures && !mxIsStruct(data))) {
    mex_errmsgid = "invalid_struct_array";
    snprintf(mex_errmsgtxt,MAXERRMSGTXTSIZE,"Value of field %s is invalid",name);
    msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
    status.code = HLI_ERR;
    return status;
  }

  *aosArraySize = (data == NULL) ? 0 : mxGetNumberOfElements(data);

  child = malloc(sizeof(struct data_struct));
  if (!dataTree) {
    mex_errmsgid = "out_of_memory";
    strncpy(mex_errmsgtxt,"Out of memory in begin_dataTree_array_write",54);
    msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
    status.code = HLI_ERR;
    return status;
  }

  child->parent = dataTree;
  child->data = data;
  child->index = -1;
  child->size = *aosArraySize;
  child->aosParent = child;
  child->isArray = 1;

  dataTree = child;

  return status;
}

/**
   Ends action on the current structure.
   The first element of the dataTree list is removed (dataTree now points to its parent) and freed.
   \returns error flag.
 */
al_status_t end_dataTree_action() {

  al_status_t status;
  struct data_struct * parent;

  if (dataTree == NULL) {
    mex_errmsgid = "invalid_dataTree";
    strncpy(mex_errmsgtxt,"Invalid dataTree in end_dataTree_action",40);
    msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
    status.code = HLI_ERR;
    return status;
  }
  
  parent = dataTree->parent;
  free(dataTree);
  dataTree = parent;

  status.code = 0;
  return status;
}

/**
   Ends action on the current array of structure.
   The first element of the dataTree list is removed (dataTree now points to its parent) and freed.
   \returns error flag.
 */
al_status_t end_dataTree_array_action() {

  al_status_t status;
  struct data_struct * parent;

  if (dataTree == NULL) {
    mex_errmsgid = "invalid_dataTree";
    strncpy(mex_errmsgtxt,"Invalid dataTree in end_dataTree_array_action",46);
    msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
    status.code = HLI_ERR;
    return status;
  }

  if (params.use_cell_array_for_array_of_structures) {
    if (dataTree->data!=NULL && !mxIsCell(dataTree->data)) { /* We have already iterated on this array */
      parent = dataTree->parent;
      free(dataTree);
      dataTree = parent;
    }
    if (dataTree->data!=NULL && !mxIsCell(dataTree->data)) {
      status.code = HLI_ERR;
      return status;
    }
  }
  parent = dataTree->parent;
  if (parent) {
    free(dataTree);
    dataTree = parent;
  }

  status.code = 0;
  return status;
}

/**
   Selects a given index in the current array of structure.
   
   \returns error flag.
 */
al_status_t iterate_dataTree_array(size_t index) {

  al_status_t status;
  struct data_struct * child;
  struct data_struct * parent;
  mxArray * data;
  
  if (dataTree == NULL) {
    mex_errmsgid = "invalid_dataTree";
    strncpy(mex_errmsgtxt,"Invalid dataTree in iterate_dataTree_array",43);
    msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
    status.code = HLI_ERR;
    return status;
  }

  if (params.use_cell_array_for_array_of_structures) {
    if (!mxIsCell(dataTree->data)) { /* We have already iterated on this array */
      parent = dataTree->parent;
      free(dataTree);
      dataTree = parent;
    }
    if (!mxIsCell(dataTree->data)) {
      mex_errmsgid = "invalid_dataTree";
      strncpy(mex_errmsgtxt,"dataTree is not a cell in iterate_dataTree_array",49);
      msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
      status.code = HLI_ERR;
      return status;
    }

    if (index < 0 || index > dataTree->size-1) {
      mex_errmsgid = "invalid_index";
      strncpy(mex_errmsgtxt,"Invalid index in iterate_dataTree_array",40);
      msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
      status.code = HLI_ERR;
      return status;
    }
      
    data = mxGetCell(dataTree->data, index);
    
    if (data == NULL) {
      mex_errmsgid = "invalid_AoS_element";
      snprintf(mex_errmsgtxt,MAXERRMSGTXTSIZE,"Unable to select element %d in dataTree array",index);
      msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
      status.code = HLI_ERR;
      return status;
    }

    child = malloc(sizeof(struct data_struct));
    if (!dataTree) {
      mex_errmsgid = "out_of_memory";
      strncpy(mex_errmsgtxt,"Out of memory in iterate_dataTree_array",40);
      msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
      status.code = HLI_ERR;
      return status;
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
      mex_errmsgid = "invalid_index";
      strncpy(mex_errmsgtxt,"Invalid index in iterate_dataTree_array",40);
      msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
      status.code = HLI_ERR;
      return status;
    }

    dataTree->index = index;

  }

  status.code = 0;
  return status;
}

/**
   Extracts data from the current dataTree object

   \param[in] name Name of the field to retrieve.
   \param[out] data mxArray containing the data.
   \returns error flag.
 */
al_status_t get_data_from_dataTree(char * name, mxArray ** data) {

  al_status_t status;
  int ifield;

  if (name == NULL)
    *data = dataTree->data;
  else {
    ifield = mxGetFieldNumber(dataTree->data, name);
    *data = mxGetFieldByNumber(dataTree->data, (mwIndex) dataTree->index, ifield);

    if (ifield < 0) {
      if (params.error_on_missing_field) {
	mex_errmsgid = "invalid_field";
	snprintf(mex_errmsgtxt, 43+strnlen(name,MAXERRMSGTXTSIZE-1)+1, "Unable to get field %s from input structure", name);
	msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
	status.code = HLI_ERR;
	return status;
      } else {
	*data = NULL;
      }
    }
  }

  status.code = 0;
  return status;

}

/**
   Puts data in the current dataTree object
   A new field is created if needed and filled with the given data.
   \param[in] name Name of the field to fill.
   \param[in] data mxArray containing the data.
   \returns error flag.
 */
al_status_t put_data_in_dataTree(char * name, mxArray * data) {

  al_status_t status;
  int ifield;

  if (name == NULL)
    dataTree->data = data;
  else {
    if (!dataTree->isArray || dataTree->index == 0) {
      ifield = mxAddField(dataTree->data, name);
      
      if (ifield < 0) {
        mex_errmsgid = "setfield_failed";
        snprintf(mex_errmsgtxt, 34+strnlen(name,MAXERRMSGTXTSIZE-1)+1, "Unable to add field %s to structure", name);
	msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
        status.code = HLI_ERR;
	return status;
      }
    } else {
      ifield = mxGetFieldNumber(dataTree->data, name);
    }

    mxSetFieldByNumber(dataTree->data, dataTree->index, ifield, data);
  }

  status.code = 0;
  return status;

}

/**
   Replaces data in the current dataTree object
   The old data is retrieved using #get_data_from_dataTree and destroyed (freed). The new data is put in its place using #put_data_in_dataTree.
   \param[in] name Name of the field to replace.
   \param[in] data mxArray containing the data.
   \returns error flag.
 */
al_status_t replace_data_in_dataTree(char * name, mxArray * data) {

  al_status_t status;
  int ifield;
  mxArray * data_old;

  status = get_data_from_dataTree(name, &data_old);
  if (status.code < 0)
    return status;

  if (data_old != NULL)
    mxDestroyArray(data_old);

  status = put_data_in_dataTree(name, data);

  return status;

}

/**
   Replaces an array of structures under the current dataTree object by one of its element.
   If name is NULL then it is assumed that dataTree points to the array of structures to modify.
   \param[in] name Name of the array of structures to replace.
   \param[in] index Index of the element to select.
   \returns error flag.

   \note This is currently only used in ids_rand where to generate a type 3 Aos, the full array is created before being replaced by a given slice (the first).
 */
al_status_t slice_dataTree_array(char * name, mwSize index) {

  al_status_t status;
  int aosArraySize;
  mxArray * array_old;
  mxArray * array;
  int nfields;
  int ifield;

  if (dataTree == NULL) {
    mex_errmsgid = "invalid_dataTree";
    strncpy(mex_errmsgtxt,"Invalid dataTree in slice_dataTree_array",41);
    msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
    status.code = HLI_ERR;
    return status;
  }

  status = get_data_from_dataTree(name, &array_old);
  if (status.code < 0)
    return status;
  aosArraySize = (array_old == NULL) ? 0 : mxGetNumberOfElements(array_old);

  if (index < 0 || index > aosArraySize-1) {
    mex_errmsgid = "invalid_index";
    strncpy(mex_errmsgtxt,"Invalid index in slice_dataTree_array",38);
    msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
    status.code = HLI_ERR;
    return status;
  }

  if (params.use_cell_array_for_array_of_structures) {
    array = mxCreateCellMatrix(1, 1);

    mxSetCell(array, 0,
	      mxDuplicateArray(mxGetCell(array_old, index)));
  } else {
    array = mxCreateStructMatrix(1, 1, 0, NULL);

    nfields = mxGetNumberOfFields(array_old);    
    for (ifield=0; ifield<nfields; ifield++) {
      if (mxAddField(array, mxGetFieldNameByNumber(array_old, ifield)) != ifield) {
	mex_errmsgid = "invalid_field";
	strncpy(mex_errmsgtxt,"New and old field numbers do not match in slice_dataTree_array",63);
	msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
	status.code = HLI_ERR;
	return status;
      }
      mxSetFieldByNumber(array, 0, ifield,
			 mxDuplicateArray(mxGetFieldByNumber(array_old, index, ifield)));
    }
  }

  status = replace_data_in_dataTree(name, array);

  return status;
}

/**
   Replicates a scalar array of structures.
   If name is NULL then it is assumed that dataTree points to the array of structures to modify.
   \param[in] name Name of the array of structures to replace.
   \param[in] aosArraySize Number of elements for the resulting array of structures.
   \returns error flag.

   \note This is currently only used in ids_allocate where a single element is generated and is then replicated to obtain the desired size.
 */
al_status_t replicate_dataTree_array(char * name, mwSize aosArraySize) {

  al_status_t status;
  mxArray * array_old;
  mxArray * array;
  mxArray * data;
  int i;
  int nfields;
  int ifield;

  if (dataTree == NULL) {
    mex_errmsgid = "invalid_dataTree";
    strncpy(mex_errmsgtxt,"Invalid dataTree in replicate_dataTree_array",45);
    msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
    status.code = HLI_ERR;
    return status;
  }

  status = get_data_from_dataTree(name, &array_old);
  if (status.code < 0)
    return status;

  if (array_old == NULL || mxGetNumberOfElements(array_old) > 1) {
    mex_errmsgid = "invalid_array";
    strncpy(mex_errmsgtxt,"Invalid original array size in replicate_dataTree_array",56);
    msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
    status.code = HLI_ERR;
    return status;
  }
  
  if (params.use_cell_array_for_array_of_structures) {
    if (aosArraySize > 0)
      array = mxCreateCellMatrix(aosArraySize, 1);
    else
      array = mxCreateCellMatrix(0, 0);

    data = mxGetCell(array_old, 0);
    for (i=0; i<aosArraySize; i++)
      mxSetCell(array, i, mxDuplicateArray(data));
  } else {
    if (aosArraySize > 0)
      array = mxCreateStructMatrix(aosArraySize, 1, 0, NULL);
    else
      array = mxCreateStructMatrix(0, 0, 0, NULL);

    nfields = mxGetNumberOfFields(array_old);
    for (ifield=0; ifield<nfields; ifield++) {
      data = mxGetFieldByNumber(array_old, 0, ifield);
      if (mxAddField(array, mxGetFieldNameByNumber(array_old, ifield)) != ifield) {
	status.code = HLI_ERR;
	return status;
      }
      for (i=0; i<aosArraySize; i++)
	mxSetFieldByNumber(array, i, ifield, mxDuplicateArray(data));
    }
  }

  status = replace_data_in_dataTree(name, array);

  return status;

}

/**
   Extracts data from the current dataTree (multi-level)
   
   \param[in] path Path to the element to be read in doc-style format.
   \param[out] data mxArray containing the data.
   \returns error flag.
 */
al_status_t getSimpleFieldStruct(char *path, const mxArray ** data)
{
  /* Extracts field from structure AosParent following '/'-separated path */

  al_status_t status;
  int ifield = -1;
  char *token;
  char *relative_path;
  char *pathcopy = strdup(path);
  mwIndex index;

  if (!dataTree) {
    status.code = HLI_ERR;
    return status;
  }

  /* Extract path after last closing bracket */
  token = strtok(pathcopy, ")");
  while (token != NULL) {
    relative_path = token;
    token = strtok(NULL, ")");
  }

  /* Structure unroll */
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
      status.code = HLI_ERR;
      *data = NULL;
      break;
    }
    ifield = mxGetFieldNumber(*data, token);
    if (ifield < 0) {
      status.code = HLI_ERR;
      *data = NULL;
      break;
    }
    *data = (const mxArray *) mxGetFieldByNumber(*data, index, ifield);
    token = strtok(NULL, "/");
    index = 0; /* Only the first item can be an array */
  }
  free(pathcopy);
  status.code = 0;
  return status;
}

/**
   Reads ids_properties/homogeneous_time from an IDS in MATLAB format.
   
   \param[out] homogeneousTime Value of ids_properties/homogeneous_time.
   \returns error flag.
 */
al_status_t getHomogeneousTime(int *homogeneousTime)
{
  al_status_t status;
  const mxArray *data = NULL;
  status = getSimpleFieldStruct("ids_properties/homogeneous_time", &data);
  if (status.code < 0 || data == NULL) {
    mex_errmsgid = "homogeneous_time_required";
    strncpy(mex_errmsgtxt,"ids_properties%homogeneous_time is not filled",46);
    msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
    status.code = HLI_ERR;
    return status;
  }
  if (!mxIsNumeric(data) || !mxIsScalar(data)) {
    mex_errmsgid = "invalid_homogeneous_time";
    strncpy(mex_errmsgtxt,"ids_properties%homogeneous_time is not a numeric scalar",56);
    msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
    status.code = HLI_ERR;
    return status;
  }
  if (mxIsInt32(data)) {
    *homogeneousTime = *(int *) mxGetData(data);
  } else {
    *homogeneousTime = (int) mxGetScalar(data);
  }
  return status;
}
