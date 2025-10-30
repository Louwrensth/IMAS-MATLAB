find_package( Matlab COMPONENTS MAIN_PROGRAM )

set( LIB_FOLDER ${CMAKE_CURRENT_BINARY_DIR}/../ )
set( M_FOLDER ${CMAKE_CURRENT_SOURCE_DIR}/../matlab )

if( AL_BACKEND_MDSPLUS )
  get_target_property( MDSPLUS_MODEL_DIR al-mdsplus-model BINARY_DIR )
endif()

add_test( NAME al-mex-test 
  COMMAND
    ${Matlab_MAIN_PROGRAM}
      -nodisplay
      -batch "res = runtests('imas_unit_tests');exit(~all([res.Passed]))"
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

set( MATLAB_ENV "IMAS_AL_DISABLE_OBSOLESCENT_WARNING=1;ids_path=${MDSPLUS_MODEL_DIR}" )
if( AL_BACKEND_HDF5 )
  # The HDF5 library built-in with matlab may conflict with the one that the AL
  # was built against. Preload the AL-linked library:
  find_package( HDF5 COMPONENTS C HL REQUIRED )
  # LD_PRELOAD expects a space-separated list:
  string( REPLACE ";" " " PRELOAD_LIBS "${HDF5_HL_LIBRARIES}" )
  list( APPEND MATLAB_ENV "LD_PRELOAD=${PRELOAD_LIBS}" )
endif()

set_tests_properties( al-mex-test PROPERTIES
  TIMEOUT 3600
  ENVIRONMENT "${MATLAB_ENV}"
)

if( AL_PLUGINS )
  add_test( NAME al-partial-get-test 
    COMMAND
      ${Matlab_MAIN_PROGRAM}
        -nodisplay
        -batch "addpath ${LIB_FOLDER} ${M_FOLDER}; res = runtests('imas_partial_get_tests');exit(~all([res.Passed]))"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )
  get_target_property( PLUGIN_DIR al-plugins BINARY_DIR )
  set( ENVIRONMENT_WITH_PLUGINS 
    ${MATLAB_ENV}
    "IMAS_AL_ENABLE_PLUGINS=TRUE"
    "IMAS_AL_PLUGINS=${PLUGIN_DIR}"
  )

  set_tests_properties( al-partial-get-test PROPERTIES
    TIMEOUT 3600
    ENVIRONMENT "${ENVIRONMENT_WITH_PLUGINS}"
  )
endif()

# Tests require MDSPLUS and HDF5
if( NOT AL_BACKEND_MDSPLUS OR NOT AL_BACKEND_HDF5 )
  set_tests_properties( al-mex-test PROPERTIES DISABLED ON )
  if( AL_PLUGINS )
    set_tests_properties( al-partial-get-test PROPERTIES DISABLED ON )
  endif()
endif()

