#cmake文档
#https://cmake.org/cmake/help/v3.0/manual/cmake-commands.7.html

cmake_minimum_required(VERSION 3.4.1)
project("android_gles")

# 检查c++编译器标志，设置c++11支持变量
#include(CheckCXXCompilerFlag)
#CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
#CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_BUILD_TYPE "Debug")

#[[
# 使用变量设置编译标志
if(COMPILER_SUPPORTS_CXX11)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
elseif(COMPILER_SUPPORTS_CXX0X)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
else()
    message(STATUS "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
endif()
]]

message(STATUS "-------------The compiler:${CMAKE_CXX_FLAGS}")

MESSAGE(STATUS "operation system is ${CMAKE_SYSTEM}")

#set the build output
IF (WIN32)
    MESSAGE(STATUS "Now is windows")
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/build/)
ELSEIF (APPLE)
    MESSAGE(STATUS "Now is Apple systens.")
ELSEIF (UNIX)
    MESSAGE(STATUS "Now is UNIX-like OS's.")
ENDIF ()

IF(CMAKE_CL_64)
    MESSAGE(STATUS "++++++x64")
ELSE(CMAKE_CL_64)
    MESSAGE(STATUS "++++++x86")
ENDIF(CMAKE_CL_64)

include(cmake_script/utils.cmake)

SET(CMAKE_DEBUG_POSTFIX "")#不添加后缀

#add_subdirectory(Temp)
add_subdirectory(Renderdoc)