#-----------------------------------------------------------------------------
# Include all the necessary files for macros
#-----------------------------------------------------------------------------
set (HDF_PREFIX "CGNS")
include (${HDF_RESOURCES_EXT_DIR}/ConfigureChecks.cmake)

if (WINDOWS)
  set (H5_HAVE_WINDOWS 1)
  # ----------------------------------------------------------------------
  # Set the flag to indicate that the machine has window style pathname,
  # that is, "drive-letter:\" (e.g. "C:") or "drive-letter:/" (e.g. "C:/").
  # (This flag should be _unset_ for all machines, except for Windows)
  set (H5_HAVE_WINDOW_PATH 1)
endif (WINDOWS)

if (NOT WINDOWS)
  # Linux Specific flags
  if (CYGWIN)
    set (HDF_EXTRA_FLAGS -D_BSD_SOURCE)
  else (CYGWIN)
    set (HDF_EXTRA_FLAGS -D_POSIX_SOURCE -D_BSD_SOURCE)
  endif (CYGWIN)
endif (NOT WINDOWS)

add_definitions (${HDF_EXTRA_FLAGS})
