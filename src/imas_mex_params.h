
#ifndef IMAS_MEX_PARAMS_H

#define IMAS_MEX_PARAMS_H

struct imas_mex_params {
  int get_int_as_double;
  int put_int_from_double;
  int get_empty_as_nan;
  int put_empty_from_nan;
  int use_cell_array_for_array_of_structures;
  int convert_whole_ids;
  int error_on_missing_field;
  int verbosity;
};

extern struct imas_mex_params params;

int setDefaultParams(void);

#endif
