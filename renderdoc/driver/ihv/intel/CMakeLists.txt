set(sources
    intel_gl_counters.cpp
    intel_gl_counters.h)

if(BRANCH_DEV AND WIN32)
list(APPEND sources 
    intel_counters.cpp
    intel_counters.h
)
endif()
set(include_dirs ${RDOC_INCLUDES})

if(BRANCH_DEV)
build_library(rdoc_intel OBJECT ${sources})
my_set_target_folder(rdoc_metal "DLL/drivers/RHI")
else()
add_library(rdoc_intel OBJECT ${sources})
endif()
target_compile_definitions(rdoc_intel ${RDOC_DEFINITIONS})
target_include_directories(rdoc_intel ${include_dirs})
