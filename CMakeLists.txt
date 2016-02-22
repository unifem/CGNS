cmake_minimum_required(VERSION 2.6)
if(COMMAND cmake_policy)
  cmake_policy(SET CMP0003 NEW)
  if (${CMAKE_MAJOR_VERSION} GREATER 2 OR ${CMAKE_MINOR_VERSION} GREATER 7)
    cmake_policy(SET CMP0015 OLD)
  endif (${CMAKE_MAJOR_VERSION} GREATER 2 OR ${CMAKE_MINOR_VERSION} GREATER 7)
endif(COMMAND cmake_policy)

project("cgns" C)

#-----------------------------------------------------------------------------
# Instructions for use : Normal Build
#
# For standard build of CGNS.
#-----------------------------------------------------------------------------

if ("${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")
    MESSAGE(FATAL_ERROR "\nERROR! ${PROJECT_NAME} DOES NOT SUPPORT IN SOURCE BUILDS!\n"
      "CMAKE_CURRENT_SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}"
      " == CMAKE_CURRENT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}\n"
      "NEXT STEPS:\n"
      "(1) Delete the CMakeCache.txt file and the CMakeFiles/ directory\n"
      "     under the source directory for ${PROJECT_NAME}, otherwise you\n"
      "     will not be able to configure ${PROJECT_NAME} correctly!\n"
      "      * For example, on linux machines do:\n"
      "        $ rm -r CMakeCache.txt CMakeFiles/\n"
      "(2) Create a different directory and configure ${PROJECT_NAME} in that directory.\n"
      "      * For example, on linux machines do:\n"
      "        $ mkdir MY_BUILD\n"
      "        $ cd MY_BUILD\n"
      "        $ cmake [OPTIONS] ..\n"
      )
endif ()

#-----------------------------------------------------------------------------
# Allow Visual Studio solution directories
#-----------------------------------------------------------------------------
# Provide a way for Visual Studio Express users to turn OFF the new FOLDER
# organization feature. Default to ON for non-Express users. Express users must
# explicitly turn off this option to build HDF5 in the Express IDE...
#
option (HDF5_USE_FOLDERS "Enable folder grouping of projects in IDEs." ON)
mark_as_advanced (HDF5_USE_FOLDERS)
if (HDF5_USE_FOLDERS)
  set_property (GLOBAL PROPERTY USE_FOLDERS ON)
endif (HDF5_USE_FOLDERS)

# Don't set the hdf5 library files as being imported from system. Fixes issues
# when compiling the CGNS fortran library with cmake >3.0 and not being able
# to find the hdf5 module files. This is because -isystem is used instead of -I
# when specifying the directory containing the hdf5 modules.
#
set ( CMAKE_NO_SYSTEM_FROM_IMPORTED true)

#-----------------------------------------------------------------------------
# Set the core names of all the libraries
#-----------------------------------------------------------------------------
set (CGNS_C_LIB_CORENAME       "cgns")
set (CGNS_Fortran_C_LIB_CORENAME "cgns_fcstub")
set (CGNS_Fortran_LIB_CORENAME "cgns_fortran")

#-----------------------------------------------------------------------------
# Set the true names of all the libraries if customized by external project
#-----------------------------------------------------------------------------
set (CGNS_C_LIB_NAME           "${CGNS_C_LIB_CORENAME}")
set (CGNS_Fortran_C_LIB_NAME     "${CGNS_Fortran_C_LIB_CORENAME}")
set (CGNS_Fortran_LIB_NAME     "${CGNS_Fortran_LIB_CORENAME}")

#-----------------------------------------------------------------------------
# Set the target names of all the libraries
#-----------------------------------------------------------------------------
set (CGNS_C_LIB_TARGET          ${CGNS_C_LIB_CORENAME})
set (CGNS_Fortran_C_LIB_TARGET    ${CGNS_Fortran_C_LIB_CORENAME})
set (CGNS_Fortran_LIB_TARGET    ${CGNS_Fortran_LIB_CORENAME})

#-----------------------------------------------------------------------------
# Define some CMake variables for use later in the project
#-----------------------------------------------------------------------------
set (CGNS_RESOURCES_DIR          ${PROJECT_SOURCE_DIR}/config/cmake)
set (HDF_RESOURCES_DIR           ${PROJECT_SOURCE_DIR}/config/cmake)
set (HDF_RESOURCES_EXT_DIR       ${PROJECT_SOURCE_DIR}/config/cmake_ext_mod)
set (CGNS_SRC_DIR          	 ${PROJECT_SOURCE_DIR}/src)
set (CGNS_Fortran_SRC_DIR    	 ${PROJECT_SOURCE_DIR}/src)
set (CGNS_TEST_DIR          	 ${PROJECT_SOURCE_DIR}/src/tests)
set (CGNS_Fortran_TEST_DIR   	 ${PROJECT_SOURCE_DIR}/src/tests)
set (CGNS_EXAMPLES_DIR       	 ${PROJECT_SOURCE_DIR}/src/examples)
set (CGNS_Fortran_EXAMPLES_DIR   ${PROJECT_SOURCE_DIR}/src/examples)

if (NOT CGNS_INSTALL_BIN_DIR)
  set (CGNS_INSTALL_BIN_DIR bin)
endif (NOT CGNS_INSTALL_BIN_DIR)
if (NOT CGNS_INSTALL_LIB_DIR)
  set (CGNS_INSTALL_LIB_DIR lib)
endif (NOT CGNS_INSTALL_LIB_DIR)
if (NOT CGNS_INSTALL_INCLUDE_DIR)
  set (CGNS_INSTALL_INCLUDE_DIR include)
endif (NOT CGNS_INSTALL_INCLUDE_DIR)
if (NOT CGNS_INSTALL_DATA_DIR)
  if (NOT WIN32)
    set (CGNS_INSTALL_DATA_DIR share)
    set (CGNS_INSTALL_CMAKE_DIR share/cmake)
  else (NOT WIN32)
    set (CGNS_INSTALL_DATA_DIR ".")
    set (CGNS_INSTALL_CMAKE_DIR cmake)
  endif (NOT WIN32)
endif (NOT CGNS_INSTALL_DATA_DIR)

#-----------------------------------------------------------------------------
# parse the full version number from H5public.h and include in H5_VERS_INFO
#-----------------------------------------------------------------------------
file (READ ${CMAKE_CURRENT_SOURCE_DIR}/src/VERSION _version_contents)
string (REGEX REPLACE ".*#define[ \t]+CGNS_VERS_MAJOR[ \t]+([0-9]*).*$"
    "\\1" CGNS_VERS_MAJOR ${_version_contents})
string (REGEX REPLACE ".*#define[ \t]+CGNS_VERS_MINOR[ \t]+([0-9]*).*$"
    "\\1" CGNS_VERS_MINOR ${_version_contents})
string (REGEX REPLACE ".*#define[ \t]+CGNS_VERS_RELEASE[ \t]+([0-9]*).*$"
    "\\1" CGNS_VERS_RELEASE ${_version_contents})
string (REGEX REPLACE ".*#define[ \t]+CGNS_VERS_SUBRELEASE[ \t]+\"([0-9A-Za-z._]*)\".*$"
    "\\1" CGNS_VERS_SUBRELEASE ${_version_contents})
#message (STATUS "VERSION: ${CGNS_VERS_MAJOR}.${CGNS_VERS_MINOR}.${CGNS_VERS_RELEASE}-${CGNS_VERS_SUBRELEASE}")

#-----------------------------------------------------------------------------
# parse the full soversion number from config/lt_vers.am and include in H5_SOVERS_INFO
#-----------------------------------------------------------------------------
set (CGNS_SOVERS_INTERFACE "1")
set (CGNS_SOVERS_MINOR "0")
set (CGNS_SOVERS_RELEASE "0")
#file (READ ${CGNS_PROJECT_DIR}/config/lt_vers.am _lt_vers_am_contents)
#string (REGEX REPLACE ".*LT_VERS_INTERFACE[ \t]+=[ \t]+([0-9]*).*$"
#    "\\1" CGNS_SOVERS_INTERFACE ${_lt_vers_am_contents})
#string (REGEX REPLACE ".*LT_VERS_REVISION[ \t]+=[ \t]+([0-9]*).*$"
#    "\\1" CGNS_SOVERS_MINOR ${_lt_vers_am_contents})
#string (REGEX REPLACE ".*LT_VERS_AGE[ \t]+=[ \t]+([0-9]*).*$"
#    "\\1" CGNS_SOVERS_RELEASE ${_lt_vers_am_contents})
MATH (EXPR CGNS_SOVERS_MAJOR ${CGNS_SOVERS_INTERFACE}-${CGNS_SOVERS_RELEASE})
message (STATUS "SOVERSION: ${CGNS_SOVERS_MAJOR}.${CGNS_SOVERS_RELEASE}.${CGNS_SOVERS_MINOR}")


#-----------------------------------------------------------------------------
# Basic CGNS stuff here
#-----------------------------------------------------------------------------
set (CGNS_PACKAGE "cgns")
set (HLJPSS_PACKAGE_NAME "CGNS")
set (CGNS_PACKAGE_VERSION "${CGNS_VERS_MAJOR}.${CGNS_VERS_MINOR}.${CGNS_VERS_RELEASE}")
set (CGNS_PACKAGE_VERSION_MAJOR "${CGNS_VERS_MAJOR}.${CGNS_VERS_MINOR}")
set (CGNS_PACKAGE_VERSION_MINOR "${CGNS_VERS_RELEASE}")
if (NOT "${CGNS_VERS_SUBRELEASE}" STREQUAL "")
  set (CGNS_PACKAGE_VERSION_STRING "${CGNS_PACKAGE_VERSION}-${CGNS_VERS_SUBRELEASE}")
else (NOT "${CGNS_VERS_SUBRELEASE}" STREQUAL "")
  set (CGNS_PACKAGE_VERSION_STRING "${CGNS_PACKAGE_VERSION}")
endif (NOT "${CGNS_VERS_SUBRELEASE}" STREQUAL "")
set (CGNS_PACKAGE_STRING "${CGNS_PACKAGE_NAME} ${CGNS_PACKAGE_VERSION_STRING}")
set (CGNS_PACKAGE_TARNAME "${CGNS_PACKAGE}${CGNS_PACKAGE_EXT}")
set (CGNS_PACKAGE_URL "http://www.cgns.org")
set (CGNS_PACKAGE_BUGREPORT "https://cgnsorg.atlassian.net")

set(CMAKE_BUILD_TYPE "Release" CACHE STRING
  "one of: Release, Debug, RelWithDebInfo or MinSizeRel")
if (${CMAKE_MAJOR_VERSION} GREATER 2 OR ${CMAKE_MINOR_VERSION} GREATER 7)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Release;Debug;RelWithDebInfo;MinSizeRel")
endif (${CMAKE_MAJOR_VERSION} GREATER 2 OR ${CMAKE_MINOR_VERSION} GREATER 7)

#-----------------------------------------------------------------------------
# Include some macros for reusable code
#-----------------------------------------------------------------------------
include (${HDF_RESOURCES_EXT_DIR}/HDFMacros.cmake)

#-----------------------------------------------------------------------------
# Setup output Directories
#-----------------------------------------------------------------------------
set (CMAKE_RUNTIME_OUTPUT_DIRECTORY
    ${PROJECT_BINARY_DIR}/bin CACHE PATH "Single Directory for all Executables."
)
set (CMAKE_LIBRARY_OUTPUT_DIRECTORY
    ${PROJECT_BINARY_DIR}/bin CACHE PATH "Single Directory for all Libraries"
)
set (CMAKE_ARCHIVE_OUTPUT_DIRECTORY
    ${PROJECT_BINARY_DIR}/bin CACHE PATH "Single Directory for all static libraries."
)
set (CMAKE_Fortran_MODULE_DIRECTORY
    ${PROJECT_BINARY_DIR}/bin CACHE PATH "Single Directory for all fortran modules."
)

#-----------------------------------------------------------------------------
# Targets built within this project are exported at Install time for use
# by other projects using FindCGNS.
#-----------------------------------------------------------------------------
if (NOT CGNS_EXPORTED_TARGETS)
  set (CGNS_EXPORTED_TARGETS "cgns-targets")
endif (NOT CGNS_EXPORTED_TARGETS)

#-----------------------------------------------------------------------------
# To include a library in the list exported by the project AT BUILD TIME,
# add it to this variable. This is NOT used by Make Install, but for projects
# which include CGNS as a sub-project within their build tree
#-----------------------------------------------------------------------------
set_global_variable (CGNS_LIBRARIES_TO_EXPORT "")
set_global_variable (CGNS_APPS_TO_EXPORT "")
set (EXTERNAL_HEADER_LIST "")
set (EXTERNAL_LIBRARY_LIST "")
set (EXTERNAL_LIBRARYDLL_LIST "")

#-----------------------------------------------------------------------------
# Run all the CMake configuration tests for our build environment
#-----------------------------------------------------------------------------
include (${CGNS_RESOURCES_DIR}/ConfigureChecks.cmake)

set (CMAKE_INCLUDE_CURRENT_DIR_IN_INTERFACE ON)

#-----------------------------------------------------------------------------
# Option to build Shared/Static libs, default is static
#-----------------------------------------------------------------------------
option (BUILD_SHARED_LIBS "Build Shared Libraries" OFF)

set (LIB_TYPE STATIC)
if (BUILD_SHARED_LIBS)
  set (LIB_TYPE SHARED)
  add_definitions (-DCGNS_DYNAMIC)
endif (BUILD_SHARED_LIBS)
set (CMAKE_POSITION_INDEPENDENT_CODE ON)

#-----------------------------------------------------------------------------
# Option to Build Static executables
#-----------------------------------------------------------------------------
option (BUILD_STATIC_EXECS "Build Static Executables" OFF)
if (BUILD_STATIC_EXECS)
  if (NOT WIN32)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -static")
  endif (NOT WIN32)
endif (BUILD_STATIC_EXECS)

#-----------------------------------------------------------------------------
# Include the main src and config directories
#-----------------------------------------------------------------------------
set (CGNS_INCLUDE_DIRECTORIES
    ${CGNS_SRC_DIR}
    ${CGNS_BINARY_DIR}
    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
)
INCLUDE_DIRECTORIES (${CGNS_INCLUDE_DIRECTORIES})

#-----------------------------------------------------------------------------
# When building utility executables that generate other (source) files :
# we make use of the following variables defined in the root CMakeLists.
# Certain systems may add /Debug or /Release to output paths
# and we need to call the executable from inside the CMake configuration
#-----------------------------------------------------------------------------
set (EXE_EXT "")
if (WIN32)
  set (EXE_EXT ".exe")
  add_definitions (-D_BIND_TO_CURRENT_VCLIBS_VERSION=1)
  add_definitions (-D_CRT_SECURE_NO_WARNINGS)
  add_definitions (-D_CONSOLE)
endif (WIN32)

if (MSVC)
  set (CMAKE_MFC_FLAG 0)
endif (MSVC)

set (MAKE_SYSTEM)
if (CMAKE_BUILD_TOOL MATCHES "make")
  set (MAKE_SYSTEM 1)
endif (CMAKE_BUILD_TOOL MATCHES "make")

set (CFG_INIT "/${CMAKE_CFG_INTDIR}")
if (MAKE_SYSTEM)
  set (CFG_INIT "")
endif (MAKE_SYSTEM)

#-----------------------------------------------------------------------------
# Compiler specific flags : Shouldn't there be compiler tests for these
#-----------------------------------------------------------------------------
if (CMAKE_COMPILER_IS_GNUCC)
  set (CMAKE_C_FLAGS "${CMAKE_ANSI_CFLAGS} ${CMAKE_C_FLAGS} -std=c99 -fomit-frame-pointer -finline-functions -fno-common")
endif (CMAKE_COMPILER_IS_GNUCC)

##set(CGNS_VERSION "3.3")

# Allow for building a package
##set(CPACK_PACKAGE_VERSION "${CGNS_VERSION}-develop")
##set (CPACK_PACKAGE_INSTALL_DIRECTORY "cgns-${CGNS_VERSION}")
##set(CPACK_GENERATOR "STGZ;TGZ;ZIP")
##set(CPACK_SOURCE_GENERATOR "STGZ;TGZ;ZIP")
include(CPack)

CONFIGURE_FILE(
	"${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
	"${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
	IMMEDIATE @ONLY)

ADD_CUSTOM_TARGET(uninstall
	"${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake")

# if this is cygwin, turn off win32 flag
if (CYGWIN)
  set(WIN32 "NO")
endif (CYGWIN)

set (CMAKE_MODULE_PATH ${CGNS_RESOURCES_DIR} ${CGNS_RESOURCES_EXT_DIR} ${CMAKE_MODULE_PATH})

##############
# build mode #
##############

# get some type sizes
include(CheckTypeSize)
CHECK_TYPE_SIZE(long SIZE_OF_LONG)
CHECK_TYPE_SIZE(off_t SIZE_OF_OFF_T)

if ("${SIZE_OF_OFF_T}" LESS 8)
  option(CGNS_ENABLE_LFS "Enable or disable large file support" "OFF")
endif ("${SIZE_OF_OFF_T}" LESS 8)

if ("${CMAKE_SIZEOF_VOID_P}" GREATER 4)
  option(CGNS_ENABLE_64BIT "Enable or disable 64-bit code building" "OFF")
else ("${CMAKE_SIZEOF_VOID_P}" GREATER 4)
  set(CGNS_ENABLE_64BIT "OFF")
endif ("${CMAKE_SIZEOF_VOID_P}" GREATER 4)

option(CGNS_ENABLE_LEGACY "Enable or disable building legacy code (3.0 compatible)" "OFF")
option(CGNS_ENABLE_SCOPING "Enable or disable scoping of enumeration values" "OFF")
option(CGNS_ENABLE_BASE_SCOPE "Enable or disable base scoped families or connectivities" "OFF")

if (CGNS_ENABLE_LEGACY)
  set(CGNS_ENABLE_64BIT "OFF")
  mark_as_advanced(FORCE CGNS_ENABLE_64BIT)
else (CGNS_ENABLE_LEGACY)
  mark_as_advanced(CLEAR CGNS_ENABLE_64BIT)
endif (CGNS_ENABLE_LEGACY)

if (CGNS_ENABLE_64BIT)
  set(CGNS_ENABLE_LEGACY "OFF")
  mark_as_advanced(FORCE CGNS_ENABLE_LEGACY)
else (CGNS_ENABLE_64BIT)
  mark_as_advanced(CLEAR CGNS_ENABLE_LEGACY)
endif (CGNS_ENABLE_64BIT)

if (CGNS_ENABLE_LFS)
  if (WIN32)
# Are these functions always available on windows that we 
# don't need to check?  
    add_definitions(-DHAVE_OPEN64 -DHAVE_LSEEK64)
  else (WIN32)
    include(CheckFunctionExists)
    CHECK_FUNCTION_EXISTS(open64 HAVE_OPEN64)
    CHECK_FUNCTION_EXISTS(lseek64 HAVE_LSEEK64)
    if (HAVE_OPEN64)
      add_definitions(-DHAVE_OPEN64)
    endif (HAVE_OPEN64)
    if (HAVE_LSEEK64)
      add_definitions(-DHAVE_LSEEK64)
    endif (HAVE_LSEEK64)
  endif (WIN32)
else (CGNS_ENABLE_LFS)
  remove_definitions(-DHAVE_OPEN64 -DHAVE_LSEEK64)
endif (CGNS_ENABLE_LFS)

option(CGNS_ENABLE_TESTS "Enable test programs" "OFF")
if (CGNS_ENABLE_TESTS)
  enable_testing()
endif (CGNS_ENABLE_TESTS)

###########
# Fortran #
###########

# Allow fortran support to be toggled
option(CGNS_ENABLE_FORTRAN "Enable or disable the use of Fortran" "OFF")
if (NOT DEFINED FORTRAN_NAMING)
  set(FORTRAN_NAMING "UNKNOWN")
endif (NOT DEFINED FORTRAN_NAMING)
set(F2CLIST  "LOWERCASE" "LOWERCASE_" "LOWERCASE__" "UPPERCASE" "UPPERCASE_" "UPPERCASE__")
set(FORTRAN_NAMING_HELP
"Configures how to link the Fortran components into the C library.
Options are:
	LOWERCASE
	LOWERCASE_
	LOWERCASE__
	UPPERCASE
	UPPERRCASE_
	UPPERRCASE__
LOWERCASE_ is known to work with gfortran.  If this setting
does not work with your compiler, try the others until one does.
")

# If we are using fortran, enable it and configure the C-Fortran interface
# It would be nice to automatically detect this setting

if(CGNS_ENABLE_FORTRAN)
  mark_as_advanced(CLEAR FORTRAN_NAMING)
  #only do this once
  if (FORTRAN_NAMING STREQUAL "UNKNOWN")
    enable_language("Fortran" OPTIONAL)
    set(HAS_FORTRAN ${CMAKE_Fortran_COMPILER_WORKS} CACHE INTERNAL "")
    # if no Fortran compiler, skip this
    if (CMAKE_Fortran_COMPILER_WORKS)
      foreach(nc ${F2CLIST})
        try_compile(NAMING_TEST_RESULT
	    "${CMAKE_BINARY_DIR}/Fortran_test"
	    "${CMAKE_SOURCE_DIR}/Fortran_test"
	    projectName ${nc})
        if(${NAMING_TEST_RESULT} STREQUAL "TRUE")
          set(FORTRAN_NAMING "${nc}" CACHE STRING ${FORTRAN_NAMING_HELP})
          if (${CMAKE_MAJOR_VERSION} GREATER 2 OR ${CMAKE_MINOR_VERSION} GREATER 7)
            set_property(CACHE FORTRAN_NAMING PROPERTY STRINGS ${F2CLIST})
          endif (${CMAKE_MAJOR_VERSION} GREATER 2 OR ${CMAKE_MINOR_VERSION} GREATER 7)
          message(STATUS "Trying Fortran naming convention ${FORTRAN_NAMING}: success")
          message(STATUS "Setting fortran naming convention to ${FORTRAN_NAMING}")
          break()
        else(${NAMING_TEST_RESULT} STREQUAL "TRUE")
          message(STATUS "Trying Fortran naming convention ${nc}: failure")
        endif(${NAMING_TEST_RESULT} STREQUAL "TRUE")
      endforeach(nc ${F2CLIST})
    endif (CMAKE_Fortran_COMPILER_WORKS)
  endif (FORTRAN_NAMING STREQUAL "UNKNOWN")
else(CGNS_ENABLE_FORTRAN)
  mark_as_advanced(FORCE FORTRAN_NAMING)
endif(CGNS_ENABLE_FORTRAN)

# check that FORTRAN_NAMING is valid
if (CGNS_ENABLE_FORTRAN)
  if (FORTRAN_NAMING STREQUAL "UNKNOWN")
    if (WIN32)
      set(FORTRAN_NAMING "UPPERCASE" CACHE STRING ${FORTRAN_NAMING_HELP})
    else (WIN32)
      set(FORTRAN_NAMING "LOWERCASE_" CACHE STRING ${FORTRAN_NAMING_HELP})
    endif (WIN32)
    if (${CMAKE_MAJOR_VERSION} GREATER 2 OR ${CMAKE_MINOR_VERSION} GREATER 7)
      set_property(CACHE FORTRAN_NAMING PROPERTY STRINGS ${F2CLIST})
    endif (${CMAKE_MAJOR_VERSION} GREATER 2 OR ${CMAKE_MINOR_VERSION} GREATER 7)
  else (FORTRAN_NAMING STREQUAL "UNKNOWN")
    list(FIND F2CLIST "${FORTRAN_NAMING}" ListIndex)
    if (ListIndex LESS 0)
      message(SEND_ERROR "invalid FORTRAN_NAMING value. Must be empty or one of:
        LOWERCASE
        LOWERCASE_
        LOWERCASE__
        UPPERCASE
        UPPERRCASE_
        UPPERRCASE__")
    endif (ListIndex LESS 0)
  endif (FORTRAN_NAMING STREQUAL "UNKNOWN")
endif (CGNS_ENABLE_FORTRAN)

# this forces cmake to set up the required Fortran variables
if (CGNS_ENABLE_FORTRAN AND HAS_FORTRAN)
  enable_language("Fortran")
endif (CGNS_ENABLE_FORTRAN AND HAS_FORTRAN)

################
# HDF5  support#
################

option(CGNS_ENABLE_HDF5 "Enable or disable HDF5 interface" "OFF")
if (CGNS_ENABLE_HDF5)

  if (CGNS_BUILD_SHARED)
    set (FIND_HDF_COMPONENTS C shared)
  else (CGNS_BUILD_SHARED)
    set (FIND_HDF_COMPONENTS C static)
  endif (CGNS_BUILD_SHARED)
  message (STATUS "HDF5 find comps: ${FIND_HDF_COMPONENTS}")

  #set (SEARCH_PACKAGE_NAME ${HDF5_PACKAGE_NAME})
  set (SEARCH_PACKAGE_NAME "hdf5")

  find_package (HDF5 QUIET NAMES ${SEARCH_PACKAGE_NAME} COMPONENTS ${FIND_HDF_COMPONENTS})
  message (STATUS "HDF5 C libs:${HDF5_FOUND} static:${HDF5_static_C_FOUND} and shared:${HDF5_shared_C_FOUND}")
  if (HDF5_FOUND)
    add_executable (h5dump IMPORTED)
    if (NOT HDF5_static_C_FOUND AND NOT HDF5_shared_C_FOUND)
      set (FIND_HDF_COMPONENTS C)

      find_package (HDF5 NAMES ${SEARCH_PACKAGE_NAME} COMPONENTS ${FIND_HDF_COMPONENTS})
      message (STATUS "HDF5 libs:${HDF5_FOUND} C:${HDF5_C_FOUND}")
      set (LINK_LIBS ${LINK_LIBS} ${HDF5_LIBRARIES})
      if (HDF5_BUILD_SHARED_LIBS)
        add_definitions (-DH5_BUILT_AS_DYNAMIC_LIB)
      else (HDF5_BUILD_SHARED_LIBS)
        add_definitions (-DH5_BUILT_AS_STATIC_LIB)
      endif (HDF5_BUILD_SHARED_LIBS)
      if (BUILD_SHARED_LIBS AND WIN32)
        set_property (TARGET h5dump PROPERTY IMPORTED_LOCATION "${HDF5_TOOLS_DIR}/h5dumpdll")
      else (BUILD_SHARED_LIBS AND WIN32)
        set_property (TARGET h5dump PROPERTY IMPORTED_LOCATION "${HDF5_TOOLS_DIR}/h5dump")
      endif (BUILD_SHARED_LIBS AND WIN32)
    else (NOT HDF5_static_C_FOUND AND NOT HDF5_shared_C_FOUND)
      if (BUILD_SHARED_LIBS AND HDF5_shared_C_FOUND)
        set (LINK_LIBS ${LINK_LIBS} ${HDF5_C_SHARED_LIBRARY})
      else (HDF5_static_C_FOUND)
        set (LINK_LIBS ${LINK_LIBS} ${HDF5_C_STATIC_LIBRARY})
      endif (BUILD_SHARED_LIBS AND HDF5_shared_C_FOUND)
      set_property (TARGET h5dump PROPERTY IMPORTED_LOCATION "${HDF5_TOOLS_DIR}/h5dump")
    endif (NOT HDF5_static_C_FOUND AND NOT HDF5_shared_C_FOUND)
    set (HDF5_DUMP_EXECUTABLE $<TARGET_FILE:h5dump>)

    set (HDF5_HAVE_H5PUBCONF_H 1)
    set (HDF5_HAVE_HDF5 1)
    set (HDF5_HDF5_HEADER "h5pubconf.h")
    set (HDF5_INCLUDE_DIR_GEN ${HDF5_INCLUDE_DIR})
    message (STATUS "HDF5-${HDF5_VERSION_STRING} found: INC=${HDF5_INCLUDE_DIR} TOOLS=${HDF5_TOOLS_DIR}")
  else (HDF5_FOUND)
    find_package (HDF5) # Legacy find
#Legacy find_package does not set HDF5_TOOLS_DIR, so we set it here
    set(HDF5_TOOLS_DIR ${HDF5_LIBRARY_DIRS}/../bin)
#Legacy find_package does not set HDF5_BUILD_SHARED_LIBS, so we set it here
    if (CGNS_BUILD_SHARED AND EXISTS "${HDF5_LIBRARY_DIRS}/libhdf5${CMAKE_SHARED_LIBRARY_SUFFIX}")
      set (HDF5_BUILD_SHARED_LIBS 1)
      add_definitions (-DH5_BUILT_AS_DYNAMIC_LIB)
    else ()
      set (HDF5_BUILD_SHARED_LIBS 0)
      add_definitions (-DH5_BUILT_AS_STATIC_LIB)
    endif ()
    set (LINK_LIBS ${LINK_LIBS} ${HDF5_LIBRARIES})

    add_executable (h5dump IMPORTED)
    set_property (TARGET h5dump PROPERTY IMPORTED_LOCATION "${HDF5_TOOLS_DIR}/h5dump")
    set (HDF5_DUMP_EXECUTABLE $<TARGET_FILE:h5dump>)
  endif (HDF5_FOUND)
  set (HDF5_PACKAGE_NAME ${SEARCH_PACKAGE_NAME})

  if (HDF5_FOUND)
    set (HDF5_HAVE_H5PUBCONF_H 1)
    set (HDF5_HAVE_HDF5 1)
    set (HDF5_HDF5_HEADER "h5pubconf.h")
    set (HDF5_INCLUDE_DIR_GEN ${HDF5_INCLUDE_DIR})
    message (STATUS "HDF5-${HDF5_VERSION_STRING} found: INC=${HDF5_INCLUDE_DIR} TOOLS=${HDF5_TOOLS_DIR} HDF5_BUILD_SHARED_LIBS=${HDF5_BUILD_SHARED_LIBS}")
    INCLUDE_DIRECTORIES (${HDF5_INCLUDE_DIR})
    set (HDF5_LIBRARY ${LINK_LIBS})
    message (STATUS "HDF5 link libs: ${LINK_LIBS}")
  else (HDF5_FOUND)
    message (FATAL_ERROR " HDF5 was specified but was not found")
  endif (HDF5_FOUND)

  set(HDF5_NEED_ZLIB "OFF" CACHE BOOL "Does the HDF5 library require linking to zlib?")
  if(HDF5_NEED_ZLIB)
    find_library(ZLIB_LIBRARY z)
    mark_as_advanced(CLEAR ZLIB_LIBRARY)
  else (HDF5_NEED_ZLIB)
    mark_as_advanced(FORCE ZLIB_LIBRARY)
  endif(HDF5_NEED_ZLIB)

  set(HDF5_NEED_SZIP "OFF" CACHE BOOL "Does the HDF5 library require linking to zlib?")
  if (HDF5_NEED_SZIP)
    find_library(SZIP_LIBRARY szip)
    mark_as_advanced(CLEAR SZIP_LIBRARY)
  else (HDF5_NEED_SZIP)
    mark_as_advanced(FORCE SZIP_LIBRARY)
  endif (HDF5_NEED_SZIP)

  set(HDF5_NEED_MPI "OFF" CACHE BOOL "Does the HDF5 library require linking to mpi? (Only true if using parallel HDF5)")
  set(MPI_INC)
  set(MPI_LIBS)
  if (HDF5_NEED_MPI)
    if (NOT MPI_FOUND)
      include(FindMPI)
    endif (NOT MPI_FOUND)
    # MPI variable names changed with cmake 2.8.5
    if (DEFINED MPI_C_COMPILER)
      mark_as_advanced(CLEAR MPI_C_COMPILER MPI_C_INCLUDE_PATH MPI_C_LIBRARIES)
      mark_as_advanced(FORCE MPI_LIBRARY MPI_EXTRA_LIBRARY)
      set(MPI_INC ${MPI_C_INCLUDE_PATH})
      set(MPI_LIBS ${MPI_C_LIBRARIES})
    else (DEFINED MPI_C_COMPILER)
      mark_as_advanced(CLEAR MPI_COMPILER MPI_INCLUDE_PATH MPI_LIBRARY MPI_EXTRA_LIBRARY)
      set(MPI_INC ${MPI_INCLUDE_PATH})
      if (MPI_EXTRA_LIBRARY)
        set(MPI_LIBS ${MPI_LIBRARY} ${MPI_EXTRA_LIBRARY})
      else (MPI_EXTRA_LIBRARY)
        set(MPI_LIBS ${MPI_LIBRARY})
      endif (MPI_EXTRA_LIBRARY)
    endif (DEFINED MPI_C_COMPILER)
    mark_as_advanced(CLEAR MPIEXEC)
  else (HDF5_NEED_MPI)
    mark_as_advanced(FORCE MPI_C_COMPILER MPI_C_INCLUDE_PATH MPI_C_LIBRARIES)
    mark_as_advanced(FORCE MPI_COMPILER MPI_INCLUDE_PATH MPI_LIBRARY MPI_EXTRA_LIBRARY MPIEXEC)
  endif (HDF5_NEED_MPI)
  mark_as_advanced(CLEAR HDF5_NEED_ZLIB HDF5_NEED_SZIP HDF5_NEED_MPI)
else (CGNS_ENABLE_HDF5)
  mark_as_advanced(FORCE HDF5_NEED_ZLIB HDF5_NEED_SZIP HDF5_NEED_MPI)
  mark_as_advanced(FORCE ZLIB_LIBRARY SZIP_LIBRARY)
  mark_as_advanced(FORCE MPI_C_COMPILER MPI_C_INCLUDE_PATH MPI_C_LIBRARIES)
  mark_as_advanced(FORCE MPI_COMPILER MPI_INCLUDE_PATH MPI_LIBRARY MPI_EXTRA_LIBRARY MPIEXEC)
endif (CGNS_ENABLE_HDF5)

#################
# parallel cgns #
#################

if (CGNS_ENABLE_HDF5 AND HDF5_NEED_MPI)
  set(CGNS_ENABLE_PARALLEL "OFF" CACHE BOOL "Enable or disable parallel interface ?")
  mark_as_advanced(CLEAR CGNS_ENABLE_PARALLEL)
  # Check that HDF5 has parallel support
  if (NOT (HDF5_IS_PARALLEL OR HDF5_ENABLE_PARALLEL))
      message(FATAL_ERROR "HDF5 has been found, but is missing parallel support.")
  endif()
else (CGNS_ENABLE_HDF5 AND HDF5_NEED_MPI)
  set(CGNS_ENABLE_PARALLEL "OFF")
  mark_as_advanced(FORCE CGNS_ENABLE_PARALLEL)
endif (CGNS_ENABLE_HDF5 AND HDF5_NEED_MPI)

####################
# RPATH Management #
####################

# use, i.e. don't skip the full RPATH for the build tree
set(CMAKE_SKIP_BUILD_RPATH  FALSE)

# when building, don't use the install RPATH already
# (but later on when installing)
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

# the RPATH to be used when installing
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")

# add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

#-----------------------------------------------------------------------------
# This is in here to help some of the GCC based IDES like Eclipse
# and code blocks parse the compiler errors and warnings better.
#-----------------------------------------------------------------------------
if (CMAKE_COMPILER_IS_GNUCC)
  set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fmessage-length=0")
endif (CMAKE_COMPILER_IS_GNUCC)
if (CMAKE_COMPILER_IS_GNUCXX)
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fmessage-length=0")
endif (CMAKE_COMPILER_IS_GNUCXX)

#-----------------------------------------------------------------------------
# Dashboard and Testing Settings
#-----------------------------------------------------------------------------
option (CGNS_BUILD_TESTING "Build CGNS Testing" OFF)
if (CGNS_BUILD_TESTING)
  set (DART_TESTING_TIMEOUT 1200
      CACHE INTEGER
      "Timeout in seconds for each test (default 1200=20minutes)"
  )
  enable_testing ()
  include (CTest)
  include (${PROJECT_SOURCE_DIR}/CTestConfig.cmake)
  configure_file (${HDF_RESOURCES_EXT_DIR}/CTestCustom.cmake ${PROJECT_BINARY_DIR}/CTestCustom.ctest @ONLY)
endif (CGNS_BUILD_TESTING)


########
# CGNS #
########

# Include the src directory
add_subdirectory(src)

