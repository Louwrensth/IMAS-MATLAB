
#ifndef IMAS_MEX_STRUCTS_H

#define IMAS_MEX_STRUCTS_H

al_status_t init_dataTree_read();

al_status_t init_dataTree_write(mxArray * data);

al_status_t init_dataTree_array_read(int aosArraySize);

al_status_t init_dataTree_array_write(mxArray * data, int * aosArraySize);

al_status_t begin_dataTree_read(char * name);

al_status_t begin_dataTree_write(char * name, int * isEmpty);

al_status_t begin_dataTree_array_read(char * name, int aosArraySize);

al_status_t begin_dataTree_array_write(char * name, int * aosArraySize);

al_status_t end_dataTree_action();

al_status_t end_dataTree_array_action();

al_status_t iterate_dataTree_array(size_t index);

al_status_t get_data_from_dataTree(char * name, mxArray ** data);

al_status_t put_data_in_dataTree(char * name, mxArray * data);

al_status_t replace_data_in_dataTree(char * name, mxArray * data);

al_status_t slice_dataTree_array(char * name, mwSize index);

al_status_t replicate_dataTree_array(char * name, mwSize aosArraySize);

al_status_t getSimpleFieldStruct(char *path, const mxArray ** data);

al_status_t getHomogeneousTime(int *homogeneousTime);

#endif
