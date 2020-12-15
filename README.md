README for the MEX interace for the UAL.

Working principles
==================

The basic principle of MEX files will not be discussed here, refer to the MATLAB documentation for more information on MEX files.

The code generation of methods for IDSs has been adapted from the one developed for the CPP interface and is therefore very similar, including the dedicated functions for treating each field of type structure or array of structures.

Since MATLAB uses column-major order for arrays (i.e. as in FORTRAN), no re-ordering of the data in arrays is necessary. However trailing singleton dimensions are never shown for multi-dimensional arrays (at least 3-dimensional), hence ones have to be added if needed when dealing with this type of arrays.


Notes
=====

   - To accomodate compatibility with the present MATLAB interface options have been implemented to convert fields of type INT to double value and to replace NaN values by EMPTY_DOUBLE both in get and put methods.

   - Treatment of strings requires casting from the intrinsic char type in C (8 bits) and the mxChar type used in MATLAB character arrays (16 bits).

   - Additionally, string vectors (STR_1D) are represented using cell array of strings which differs from the AL lowlevel representation using char matrices.

List of functions
=================

The standard functions have been implemented:
    - Functions to open/create/close a pulse file
        + \link imas_open_env.c imas_open_env\endlink
        + \link imas_open_env_backend.c imas_open_env_backend\endlink
        + \link imas_open_public.c imas_open_public\endlink
        + \link imas_create_env.c imas_create_env\endlink
        + \link imas_create_env_backend.c imas_create_env_backend\endlink
        + \link imas_create_public.c imas_create_public\endlink
        + \link imas_close.c imas_close\endlink
    - Function to query the backend in use
        + \link imas_get_backendID.c imas_get_backendID\endlink
    - Functions to read/write IDSs
        + \link ids_delete.c ids_delete\endlink
        + \link ids_get.c ids_get\endlink
        + \link ids_get_slice.c ids_get_slice\endlink
        + \link ids_put.c ids_put\endlink
        + \link ids_put_slice.c ids_put_slice\endlink
    - Function to initialize an IDS structure
        + \link ids_init.c ids_init\endlink            (provides empty arrays of structures, preferred over ids_gen)
        + \link ids_allocate.c ids_allocate\endlink        (for allocating arrays of structures)
        + \link ids_gen.c ids_gen\endlink              (provides scalar arrays of structures, deprecated)

The following additional functions are also provided
    - Functions to query/modify the global parameters for the MEX interface (see next section.)
        + \link imas_get_mex_params.c imas_get_mex_params\endlink
        + \link imas_set_mex_params.c imas_set_mex_params\endlink
    - Converters
        + \link ids_int_to_double.c ids_int_to_double\endlink
        + \link ids_double_to_int.c ids_double_to_int\endlink
        + \link ids_empty_to_nan.c ids_empty_to_nan\endlink
        + \link ids_nan_to_empty.c ids_nan_to_empty\endlink
        + \link ids_cell_to_struct.c ids_cell_to_struct\endlink
        + \link ids_struct_to_cell.c ids_struct_to_cell\endlink
    - Function to generate an IDS structure with random field values (for tests only)
        + \link ids_rand.c ids_rand\endlink

Parameters
==========

Refer to the #imas_mex_params reference page for a list of current valid parameters.

TODO
====

   - Print context info on error
   - Decide on how to assign error codes for local (mexinterface) functions
   - Minimize use of memcpy in get methods (check that no error appears when mex are cleared)
   - Enable/Disable memory backend from MATLAB
