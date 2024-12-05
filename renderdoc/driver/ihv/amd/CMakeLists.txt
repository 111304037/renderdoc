set(sources
    amd_counters.cpp
    amd_counters.h
    amd_isa.cpp
    amd_isa.h
    amd_isa_devices.cpp
    amd_isa_devices.h
    amd_isa_posix.cpp
    amd_rgp.cpp
    amd_rgp.h
    official/RGP/DevDriverAPI.h)

if(BRANCH_DEV AND WIN32)
    list(REMOVE_ITEM sources amd_isa_posix.cpp)
    list(APPEND sources
        ags_wrapper.cpp
        amd_hooks.cpp
        amd_isa_win32.cpp
    )
endif()
set(include_dirs ${RDOC_INCLUDES})

if(BRANCH_DEV)
    build_library(rdoc_amd OBJECT ${sources})
    my_set_target_folder(rdoc_amd "DLL/drivers/RHI")
else()
add_library(rdoc_amd OBJECT ${sources})
endif()
target_compile_definitions(rdoc_amd ${RDOC_DEFINITIONS})
target_include_directories(rdoc_amd ${include_dirs})
