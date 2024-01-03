find_package( Matlab COMPONENTS MAIN_PROGRAM )

set( LIB_FOLDER ${CMAKE_CURRENT_BINARY_DIR}/../ )
set( M_FOLDER ${CMAKE_CURRENT_SOURCE_DIR}/../matlab )

if( IMAS_MDSPLUS )
  get_target_property( MDSPLUS_MODEL_DIR al-mdsplus-model BINARY_DIR )
endif()

add_test( NAME al-mex-test 
  COMMAND
    ${Matlab_MAIN_PROGRAM}
      -nodisplay
      -batch "addpath ${LIB_FOLDER} ${M_FOLDER}; res = runtests('imas_unit_tests');exit(~all([res.Passed]))"
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
set_tests_properties( al-mex-test PROPERTIES
  TIMEOUT 3600
  ENVIRONMENT "IMAS_AL_DISABLE_VALIDATE=1;IMAS_AL_DISABLE_OBSOLESCENT_WARNING=1;ids_path=${MDSPLUS_MODEL_DIR}"
)

# Tests require MDSPLUS and HDF5
if( NOT IMAS_MDSPLUS OR NOT IMAS_HDF5 )
  set_tests_properties( al-mex-test PROPERTIES DISABLED ON )
endif()

