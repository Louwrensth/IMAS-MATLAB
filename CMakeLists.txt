# CMake build configuration for the Access Layer C++ HLI
cmake_minimum_required( VERSION 3.16 )

# Configuration options for common assets
################################################################################
option( AL_DOWNLOAD_DEPENDENCIES "Automatically download common assets from the AL git repository" ON )
set( AL_COMMON_GIT_REPOSITORY "ssh://git@git.iter.org/imas/al-common.git" CACHE STRING "Git repository of AL-common" )
set( AL_COMMON_VERSION "develop" CACHE STRING "Git commit/tag/branch of AL-common" )

include(FetchContent)

# Load common assets
################################################################################
if( ${AL_DOWNLOAD_DEPENDENCIES} )
  # Download common assets from the ITER git:
  FetchContent_Declare(
    al-common
    GIT_REPOSITORY "${AL_COMMON_GIT_REPOSITORY}"
    GIT_TAG "${AL_COMMON_VERSION}"
  )
else()
  # Look in $AL_COMMON_PATH or ../al-common for common files
  if( DEFINED ENV{AL_COMMON_PATH} )
    set( AL_COMMON_PATH $ENV{AL_COMMON_PATH} )
  else()
    set( AL_COMMON_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../al-common" )
  endif()
  FetchContent_Declare(
    al-common
    SOURCE_DIR      "${AL_COMMON_PATH}"
  )
endif()
FetchContent_MakeAvailable( al-common )


# Define project
################################################################################

# Set VERSION and FULL_VERSION from `git describe`:
set( GIT_ARCHIVE_DESCRIBE [[$Format:%(describe)$]] )
include( ALDetermineVersion )
project( al-matlab
  VERSION ${VERSION}
  DESCRIPTION "MATLAB High Level Interface of the IMAS Access Layer"
  HOMEPAGE_URL "https://imas.iter.org/"
  LANGUAGES C CXX
)
if( NOT PROJECT_VERSION_TWEAK EQUAL 0 )
  message( "Building a development version of the Access Layer Matlab HLI" )
endif()

# Compiler settings
include( ALSetCompilerFlags )
# Common HLI options
include( ALCommonConfig )
# Data dictionary
include( ALBuildDataDictionary )
# AL lowlevel, plugins and documentation
include( ALLowlevel )

# Stop processing when only building documentation
if( AL_DOCS_ONLY )
  return()
endif()


# Dependencies
################################################################################

find_package( Matlab REQUIRED )
find_package( SaxonHE )


# Utility sources and target
################################################################################

set( MEX_UTIL_SOURCES
  src/imas_mex_casts.c
  src/imas_mex_params.c
  src/imas_mex_rand.c
  src/imas_mex_structs.c
  src/imas_mex_utils.c
)

# This should be built as a shared library with name libal-mex.so
matlab_add_mex( NAME al-mex SRC ${MEX_UTIL_SOURCES} SHARED LINK_TO al )
target_include_directories( al-mex PRIVATE src )
set_target_properties( al-mex PROPERTIES
  # override library suffix to '.so'
  PREFIX "lib" SUFFIX ".so"
  # By default, the mex target created by matlab_add_mex hides all defined
  # symbols, unset the LINK_FLAGS property to expose the symbols required by the
  # other mex targets:
  LINK_FLAGS " -Wl,--as-needed"
)

set( MEX_TARGETS )

# Generate sources and define targets
################################################################################

add_custom_target( al-mex-sources ALL )

# Macro for source generation with Saxon
macro( GENERATE GENERATOR IS_C_GENERATOR OUTPUT_FILES )
  if( ${IS_C_GENERATOR} )
    set( WORK_DIR "${CMAKE_CURRENT_BINARY_DIR}" )
  else()
    set( WORK_DIR "${CMAKE_CURRENT_SOURCE_DIR}" )
  endif()
  set( GENERATED_FILENAMES ${OUTPUT_FILES} )
  list( TRANSFORM GENERATED_FILENAMES PREPEND "${WORK_DIR}/" )

  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${GENERATOR}_dummy.txt
    COMMAND
      java -cp ${SaxonHE_CLASSPATH}
        net.sf.saxon.Transform -t -warnings:fatal
        "-xsl:${CMAKE_CURRENT_SOURCE_DIR}/${GENERATOR}.xsl"
        "-s:${IDSDEF}"
        DD_GIT_DESCRIBE=${DD_VERSION}
        AL_GIT_DESCRIBE=${FULL_VERSION}
    COMMAND ${CMAKE_COMMAND} -E touch ${CMAKE_CURRENT_BINARY_DIR}/${GENERATOR}_dummy.txt
    DEPENDS ${IDSDEF} ${GENERATOR}.xsl
    WORKING_DIRECTORY ${WORK_DIR}
  )
  add_custom_target( al-mex-source-${GENERATOR}
    COMMAND ${CMAKE_COMMAND} -E echo ""
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${GENERATOR}_dummy.txt
    BYPRODUCTS ${GENERATED_FILENAMES}
  )
  add_dependencies( al-mex-sources al-mex-source-${GENERATOR} )
endmacro()

# Macro to generate source name triplets for an ids_<method>
macro( FILES_FROM_METHOD_NAME FILES METHOD_NAME )
  set( ${FILES} "src/ids/ids_${METHOD_NAME}.c;src/ids/ids_${METHOD_NAME}.;src/ids/${METHOD_NAME}_ids.c" )
endmacro()

# Macro to add a mex target
macro( ADD_IMAS_MEX NAME SOURCES )
  matlab_add_mex( NAME "mex-${NAME}" SRC ${SOURCES} LINK_TO al al-mex OUTPUT_NAME "${NAME}" )
  target_include_directories( "mex-${NAME}" PRIVATE src )
  list( APPEND MEX_TARGETS "mex-${NAME}" )
endmacro()

# These XSLs generate files in triplets, which are then compiled into one mex target
foreach( METHOD_NAME allocate delete gen get get_slice init put put_slice rand validate )
  FILES_FROM_METHOD_NAME( OUTPUT_FILES ${METHOD_NAME} )
  GENERATE( "ids_${METHOD_NAME}" 1 "${OUTPUT_FILES}" )
  ADD_IMAS_MEX( "ids_${METHOD_NAME}" "${OUTPUT_FILES}" )
endforeach()

# 'put' and 'put_slice' in addition need these sources:
target_sources( "mex-ids_put" PRIVATE
  src/ids/delete_ids.c
  src/ids/validate_ids.c
)
target_sources( "mex-ids_put_slice" PRIVATE
  src/ids/put_ids.c
  src/ids/delete_ids.c
  src/ids/validate_ids.c
)

# The ids_converter.xsl generates many targets:
set( IDS_CONVERTER_SOURCES )
foreach( CONVERTER_METHOD
  int_to_double
  double_to_int
  empty_to_nan
  nan_to_empty
  cell_to_struct
  struct_to_cell
)
  FILES_FROM_METHOD_NAME( OUTPUT_FILES ${CONVERTER_METHOD} )
  list( APPEND IDS_CONVERTER_SOURCES ${OUTPUT_FILES} )
  ADD_IMAS_MEX( "ids_${CONVERTER_METHOD}" "${OUTPUT_FILES}" )
endforeach()
GENERATE( ids_converter 1 "${IDS_CONVERTER_SOURCES}" )

# imas_versions only generates a single file and target
GENERATE( imas_versions 1 "src/imas_versions.c")
ADD_IMAS_MEX( "imas_versions" "src/imas_versions.c" )

# Only generate, no mex target
GENERATE( IDS_list 0 "matlab/IDS_list.m")

# Targets for other sources
################################################################################

set( TARGETS
  ids_isdefined
  imas_al_bind_plugin
  imas_al_register_plugin
  imas_al_setvalue_parameter_plugin
  imas_al_unbind_plugin
  imas_al_unregister_plugin
  imas_close
  imas_create_env
  imas_create_env_backend
  imas_deserialize
  imas_get_backendID
  imas_get_mex_params
  imas_open
  imas_open_env
  imas_open_env_backend
  imas_serialize
  imas_set_mex_params
)
foreach( TARGET ${TARGETS} )
  ADD_IMAS_MEX( ${TARGET} "src/${TARGET}.c" )
endforeach()

add_custom_target( al-matlab )
add_dependencies( al-matlab al-mex-sources al-mex ${MEX_TARGETS} )

# Install
################################################################################

# Install libal-mex to lib folder
install( TARGETS al-mex DESTINATION lib )
# Install compiled libraries to the mex folder
install( TARGETS ${MEX_TARGETS} DESTINATION mex )
# Install static and generated '.m' files to the mex folder
install( DIRECTORY matlab/ DESTINATION mex )

# Tests
################################################################################

if( AL_TESTS )
  add_subdirectory( tests )
endif()

if( AL_EXAMPLES )
  add_subdirectory( examples )
endif()
