
#ifndef IMAS_MEX_STRUCTS_H

#define IMAS_MEX_STRUCTS_H

int init_dataTree_read();

int init_dataTree_write(mxArray * data);

int begin_dataTree_read(char * name);

int begin_dataTree_write(char * name, int * isEmpty);

int begin_dataTree_array_read(char * name, int aosArraySize);

int begin_dataTree_array_write(char * name, int * aosArraySize);

int end_dataTree_action();

int end_dataTree_array_action();

int iterate_dataTree_array(size_t index);

int replicate_dataTree_array(char * name, mwSize aosArraySize);

int get_data_from_dataTree(char * name, mxArray ** data);

int put_data_in_dataTree(char * name, mxArray * data);

int replace_data_in_dataTree(char * name, mxArray * data);

int getSimpleFieldStruct(char *path, const mxArray ** data);

int getHomogeneousTime(int *homogeneousTime);

#endif
