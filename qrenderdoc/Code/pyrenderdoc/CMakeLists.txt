# include paths for qrenderdoc, the internal renderdoc API, and Python
set(MODULE_INCLUDES
    PRIVATE ${CMAKE_SOURCE_DIR}/qrenderdoc
    PRIVATE ${CMAKE_SOURCE_DIR}/renderdoc/api/replay
    PRIVATE ${PYTHON_INCLUDE_DIR})
  
# preprocessor definitions for compiling
set(MODULE_DEFINES
    PRIVATE -DRENDERDOC_PLATFORM_LINUX)

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-unknown-warning-option -Wno-unused-private-field -Wno-shadow -Wno-shorten-64-to-32")
endif()

if(CMAKE_COMPILER_IS_GNUCXX)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-cast-function-type -Wno-stringop-truncation")
endif()

if(BRANCH_DEV AND NOT MSVC)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-deprecated-declarations")
endif()

# Set up rpath to find librenderdoc.so
set(CMAKE_SKIP_BUILD_RPATH TRUE)
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
if (APPLE)
    set(CMAKE_MACOSX_RPATH TRUE)
    set(CMAKE_INSTALL_RPATH "@loader_path/../lib")
    set(CMAKE_BUILD_WITH_INSTALL_NAME_DIR TRUE)
else()
    set(CMAKE_INSTALL_RPATH "$ORIGIN/:$ORIGIN/../lib${LIB_SUFFIX}/${LIB_SUBFOLDER_TRAIL_SLASH}")
endif()

# Add python library
if(BRANCH_DEV)
    message("[*]python lib:${PYTHON_LIBRARY}")
endif()
set (CMAKE_SHARED_LINKER_FLAGS "${PYTHON_LIBRARY} ${CMAKE_SHARED_LINKER_FLAGS}")

if(BRANCH_DEV)
    if(WIN32)
        set(warningList
            4127
            4189
            4456
            4459
            4701
            4244
            4706
            4101
        )
        foreach(warning ${warningList})
            add_compile_options(/wd${warning})
        endforeach()
    endif()

    if(WIN32)
        #https://blog.csdn.net/frank_liuxing/article/details/74010939
        set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Md")
        set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /Md")
    endif()

    build_library(_renderdoc STATIC
        ${CMAKE_BINARY_DIR}/qrenderdoc/renderdoc_python.cxx
        #${CMAKE_BINARY_DIR}/qrenderdoc/renderdoc.py
        pyrenderdoc_stub.cpp)

    add_dependencies(_renderdoc
        swig-bindings
    )
else()
add_library(_renderdoc SHARED
    ${CMAKE_BINARY_DIR}/qrenderdoc/renderdoc_python.cxx
    pyrenderdoc_stub.cpp)
endif()

set_source_files_properties(${CMAKE_BINARY_DIR}/qrenderdoc/renderdoc_python.cxx
                            PROPERTIES GENERATED TRUE)

target_compile_definitions(_renderdoc ${MODULE_DEFINES})
target_include_directories(_renderdoc ${MODULE_INCLUDES})
target_link_libraries(_renderdoc PRIVATE renderdoc)

if(BRANCH_DEV)
    build_library(_qrenderdoc STATIC
        ${CMAKE_BINARY_DIR}/qrenderdoc/renderdoc_python.cxx
        ${CMAKE_BINARY_DIR}/qrenderdoc/qrenderdoc_python.cxx
        #${CMAKE_BINARY_DIR}/qrenderdoc/qrenderdoc.py
        pyrenderdoc_stub.cpp
        qrenderdoc_stub.cpp)

    add_dependencies(_qrenderdoc
        swig-bindings
    )
else()
add_library(_qrenderdoc SHARED
    ${CMAKE_BINARY_DIR}/qrenderdoc/renderdoc_python.cxx
    ${CMAKE_BINARY_DIR}/qrenderdoc/qrenderdoc_python.cxx
    pyrenderdoc_stub.cpp
    qrenderdoc_stub.cpp)
endif()

set_source_files_properties(${CMAKE_BINARY_DIR}/qrenderdoc/qrenderdoc_python.cxx
                            PROPERTIES GENERATED TRUE)

target_compile_definitions(_qrenderdoc ${MODULE_DEFINES})
target_include_directories(_qrenderdoc ${MODULE_INCLUDES})
target_link_libraries(_qrenderdoc PRIVATE renderdoc)

# Python expects .so extension when importing shared libraries on non-Windows platform
if(APPLE)
    set_target_properties(_renderdoc PROPERTIES SUFFIX ".so")
    set_target_properties(_qrenderdoc PROPERTIES SUFFIX ".so")
endif()

if(BRANCH_DEV AND WIN32)
    target_link_libraries(_qrenderdoc PRIVATE ${PYTHON_LIBRARY})
endif()

if(NOT BRANCH_DEV OR NOT WIN32)
# Don't prefix with lib, python expects a bare .so.
# Also rename to non-underscore due to this (We couldn't call the
# python library 'renderdoc' since that would clash with the
# prefixed target)
set_target_properties(_renderdoc PROPERTIES PREFIX "")
set_target_properties(_qrenderdoc PROPERTIES PREFIX "")
set_target_properties(_renderdoc PROPERTIES OUTPUT_NAME "renderdoc")
set_target_properties(_qrenderdoc PROPERTIES OUTPUT_NAME "qrenderdoc")
endif()

# Make sure we build after the wrappers are generated
add_dependencies(_renderdoc swig-bindings)
add_dependencies(_qrenderdoc swig-bindings)

if(BRANCH_DEV)
my_set_target_folder(_renderdoc "UI")
my_set_target_folder(_qrenderdoc "UI")
endif()