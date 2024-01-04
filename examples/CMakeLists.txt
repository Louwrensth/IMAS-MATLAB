project( mexinterface-ex )

find_package( Matlab COMPONENTS MAIN_PROGRAM )
include( ALExampleUtilities )

get_target_property( LIB_FOLDER al-mex BINARY_DIR )
get_target_property( M_FOLDER al-mex SOURCE_DIR )
set( M_FOLDER ${M_FOLDER}/matlab )

if( AL_BACKEND_MDSPLUS )
  get_target_property( MDSPLUS_MODEL_DIR al-mdsplus-model BINARY_DIR )
endif()

set( M_FILES
    test_amns_data_validate
    test_distributions_validate
    test_get
    test_isdefined
    test_put
    test_serialize
    test_waves_validate
)

foreach( M_FILE ${M_FILES} )
  add_test( NAME example-mex-${M_FILE}
    COMMAND ${Matlab_MAIN_PROGRAM}
      -nodisplay
      -batch "addpath ${LIB_FOLDER} ${M_FOLDER}; ${M_FILE}; exit()"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )

  set( DISABLED OFF )
  if( NOT AL_BACKEND_MDSPLUS )
    set( DISABLED ON )
  endif()

  set_al_example_properties( example-mex-${M_FILE} ${DISABLED} OFF "ids_path=${MDSPLUS_MODEL_DIR}" )

  if( AL_PLUGINS )
    add_test( NAME example-mex-${M_FILE}-with-plugins
      COMMAND ${Matlab_MAIN_PROGRAM}
        -nodisplay
        -batch "addpath ${LIB_FOLDER} ${M_FOLDER}; ${M_FILE}; exit()"
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
    set_al_example_properties( example-mex-${M_FILE}-with-plugins ${DISABLED} ON "ids_path=${MDSPLUS_MODEL_DIR}" )
  endif()
endforeach()
