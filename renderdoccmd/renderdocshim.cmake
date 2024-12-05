set(MODULE_NAME renderdocshim)



list(APPEND DEFINES 
    # SWIGPYTHON
    # SWIG_GENERATED
    _CRT_SECURE_NO_WARNINGS
)
foreach(def ${DEFINES})
    add_definitions(-D${def})
endforeach()

#使用unicode字符集
add_win32_definitions()


build_library(${MODULE_NAME} SHARED
    ../renderdocshim/renderdocshim.h
    ../renderdocshim/renderdocshim.cpp
)
my_set_target_folder(${MODULE_NAME} "Utility")

# https://blog.csdn.net/SuperFeio/article/details/83584538/
# Release DLLs (/MD ): msvcrt.lib vcruntime.lib ucrt.lib
# Debug DLLs (/MDd): msvcrtd.lib vcruntimed.lib ucrtd.lib
# Release Static (/MT ): libcmt.lib libvcruntime.lib libucrt.lib
# Debug Static (/MTd): libcmtd.lib libvcruntimed.lib libucrtd.lib

#https://blog.csdn.net/frank_liuxing/article/details/74010939
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MDd")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MDd")

set_win32_RuntimeChecks_default()


target_link_libraries(${MODULE_NAME}
    #rdoc
    renderdoc
    rdoc_version
    # kernel32.lib
    # user32.lib
    # msvcrt.lib
    # libcmt.lib
)
target_link_options(${MODULE_NAME} PRIVATE "/ENTRY:dll_entry")
#SET(CMAKE_EXE_LINKER_FLAGS /NODEFAULTLIB:"LIBCMT.lib")	#\;LIBCMT.lib
target_link_options(${MODULE_NAME} PRIVATE /NODEFAULTLIB)

if(CMAKE_CL_64)
    set_target_properties(${MODULE_NAME} PROPERTIES OUTPUT_NAME "renderdocshim64")
else()
    set_target_properties(${MODULE_NAME} PROPERTIES OUTPUT_NAME "renderdocshim32")
endif()

#set_target_properties( ${MODULE_NAME} PROPERTIES COMPILE_FLAGS "/RTCs" ) #堆栈帧检查 
#set_target_properties( ${MODULE_NAME} PROPERTIES COMPILE_FLAGS "/RTCu" ) #未初始化变量 
# set_target_properties( ${MODULE_NAME} PROPERTIES COMPILE_FLAGS "/RTCsu" ) #两者