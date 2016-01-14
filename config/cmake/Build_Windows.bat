@echo OFF
:: Set the HDF5 install directory
SET HDF5_DIR=/Program Files/HDF_Group/HDF5/1.8.14/cmake/hdf5
:: Run the cmake command
cmake -G "Visual Studio 12 2013 Win64" ^
 -DUSE_SHARED_LIBS:BOOL=OFF ^
 -DBUILD_TESTING:BOOL=ON ^
 -DHDF5_BUILD_TOOLS:BOOL=ON ^
 -DHDF_BUILD_FORTRAN:BOOL=OFF ^
 -DHDF5_BUILD_FORTRAN:BOOL=OFF ^
 -DHDF5_PACKAGE_NAME:STRING="hdf5st" ^
 ..\CGNS
 
cmake --build . --config Release
ctest . -C release
