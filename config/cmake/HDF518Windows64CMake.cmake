cmake_minimum_required(VERSION 3.1.0 FATAL_ERROR)
set(CTEST_SOURCE_NAME CGNS)
set(CTEST_BINARY_NAME build)
set(CTEST_DASHBOARD_ROOT "${CTEST_SCRIPT_DIRECTORY}")
set(CTEST_SOURCE_DIRECTORY "${CTEST_DASHBOARD_ROOT}\\${CTEST_SOURCE_NAME}")
set(CTEST_BINARY_DIRECTORY "${CTEST_DASHBOARD_ROOT}\\${CTEST_BINARY_NAME}")

###################################################################
### Following Line is one of [Release, RelWithDebInfo, Debug] #####
set(CTEST_BUILD_CONFIGURATION "Release")
###################################################################

###################################################################
#########       Following describes compiler           ############
set(CTEST_CMAKE_GENERATOR "Visual Studio 12 2013 Win64")

###################################################################
#########       Following is for submission to CDash   ############
###################################################################
set(MODEL "Experimental")
#########       Following describes computer           ############
set(SITE_OS_NAME "Windows")
set(SITE_OS_VERSION "WIN764")
set(SITE_OS_BITS "64")
set(SITE_COMPILER_NAME "vs2012")
set(SITE_COMPILER_VERSION "11")
##  Set the following to unique id your computer  ##
set(CTEST_SITE "WIN764-VS2012.XXXX")
## following is optional to describe build ##
set(SITE_BUILDNAME_SUFFIX "SHARED")

##########     Following controls CDash submission      ############
set(LOCAL_SUBMIT "TRUE")
##########     Following controls test process          ############
#set(LOCAL_SKIP_TEST "TRUE")
#set(LOCAL_MEMCHECK_TEST "TRUE")
#set(LOCAL_COVERAGE_TEST "TRUE")
##########    Following controls source update          ############
#set(LOCAL_UPDATE "TRUE")
#set(REPOSITORY_URL "http://svn.hdfgroup.uiuc.edu/hdf5/branches/hdf5_1_8")
#comment to use a uncompressed source folder
#set(CTEST_USE_TAR_SOURCE "hdf5-1.8.13")
###################################################################

###################################################################
####  Change default configuration of options in config/cmake/cacheinit.cmake file ###
####  format: set(ADD_BUILD_OPTIONS "${ADD_BUILD_OPTIONS} -DXXX:YY=ZZZZ")

### uncomment/comment and change the following lines for configuration options

### uncomment the following line to build static libraries
#set(ADD_BUILD_OPTIONS "${ADD_BUILD_OPTIONS} -DBUILD_SHARED_LIBS:BOOL=OFF")

####      ext libraries       ####
### ext libs from tgz
set(ADD_BUILD_OPTIONS "${ADD_BUILD_OPTIONS} -DUSE_SHARED_LIBS:BOOL=OFF ^
 -DHDF5_BUILD_TOOLS:BOOL=ON -DHDF_BUILD_FORTRAN:BOOL=OFF -DHDF5_PACKAGE_NAME:STRING=hdf5st")

####      fortran       ####
### enable Fortran 2003
#set(ADD_BUILD_OPTIONS "${ADD_BUILD_OPTIONS} -DHDF5_ENABLE_F2003:BOOL=ON")
### disable Fortran
#set(ADD_BUILD_OPTIONS "${ADD_BUILD_OPTIONS} -DHDF5_BUILD_FORTRAN:BOOL=OFF")


### disable test program builds
set(ADD_BUILD_OPTIONS "${ADD_BUILD_OPTIONS} -DBUILD_TESTING:BOOL=ON")

### disable packaging
#set(ADD_BUILD_OPTIONS "${ADD_BUILD_OPTIONS} -DHDF5_NO_PACKAGES:BOOL=ON")
###################################################################

set(ENV{HDF5_DIR} "/Program Files/HDF_Group/HDF5/1.8.14/cmake/hdf5")
include(${CTEST_SCRIPT_DIRECTORY}\\CTestScript.cmake)
