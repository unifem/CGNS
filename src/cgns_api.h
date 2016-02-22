#ifndef cgns_api_H
#define cgns_api_H

#ifdef CGNS_DYNAMIC
 #if defined(cgns_EXPORTS)
  #if defined (_MSC_VER)  /* MSVC Compiler Case */
    #define CGNSDLL __declspec(dllexport)
    #define CGNSDLLVAR extern __declspec(dllexport)
  #elif (__GNUC__ >= 4)  /* GCC 4.x has support for visibility options */
    #define CGNSDLL __attribute__ ((visibility("default")))
    #define CGNSDLLVAR extern __attribute__ ((visibility("default")))
  #endif
 #else
  #if defined (_MSC_VER)  /* MSVC Compiler Case */
    #define CGNSDLL __declspec(dllimport)
    #define CGNSDLLVAR __declspec(dllimport)
  #elif (__GNUC__ >= 4)  /* GCC 4.x has support for visibility options */
    #define CGNSDLL __attribute__ ((visibility("default")))
    #define CGNSDLLVAR extern __attribute__ ((visibility("default")))
  #endif
 #endif
#else
# define CGNSDLL
# define CGNSDLLVAR extern
#endif

#endif /* cgns_api_H */
