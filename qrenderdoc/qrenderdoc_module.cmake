set(MODULE_NAME qrenderdoc_module)

set(SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/Code/pyrenderdoc/pyrenderdoc_stub.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/Code/pyrenderdoc/renderdoc.i
    #${CMAKE_CURRENT_BINARY_DIR}/generated/renderdoc_module_python.cxx
    ${CMAKE_CURRENT_SOURCE_DIR}/Code/pyrenderdoc/qrenderdoc_stub.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/Code/Interface/PersistantConfig.h
    ${CMAKE_CURRENT_SOURCE_DIR}/Code/Interface/QRDInterface.h
    ${CMAKE_CURRENT_SOURCE_DIR}/Code/Interface/RemoteHost.h
)

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




# 添加构建前执行的命令
set(swig_output ${CMAKE_CURRENT_BINARY_DIR}/generated/qrenderdoc)
set(SwigInterfaces "${CMAKE_CURRENT_LIST_DIR}/Code/pyrenderdoc/*.i")
set(SwigHeaders "${CMAKE_CURRENT_LIST_DIR}/Code/pyrenderdoc/*.h")
set(QRDHeaders "${CMAKE_CURRENT_LIST_DIR}/Code/Interface/*.h")
set(CoreReplayHeaders "${CMAKE_SOURCE_DIR}/renderdoc/api/replay/*.h")
set(SWIG_FILE_NAME renderdoc_module)
set(SWIG_FILE_INPUT ${CMAKE_CURRENT_LIST_DIR}/Code/pyrenderdoc/renderdoc.i)
#set(swig_includes -I${CMAKE_CURRENT_LIST_DIR}/../renderdoc/api/replay)
set(swig_includes -I${SwigInterfaces} -I${SwigHeaders} -I${QRDHeaders} -I${CMAKE_CURRENT_LIST_DIR} -I${CMAKE_CURRENT_LIST_DIR}/../renderdoc/api/replay)
set(swig_cmd ${CMAKE_CURRENT_LIST_DIR}/3rdparty/swig/swig.exe -v -Wextra -Werror -O -interface ${SWIG_FILE_NAME} -c++ -python -modern -modernargs -enumclass -fastunpack -py3 -builtin ${swig_includes} -outdir ${swig_output} -o ${swig_output}/${SWIG_FILE_NAME}_python.cxx ${SWIG_FILE_INPUT})
message("swig_cmd:${swig_cmd}")
add_custom_command(
    # TARGET ${MODULE_NAME} 
    # PRE_BUILD
    OUTPUT ${swig_output}/${SWIG_FILE_NAME}_python.cxx
    COMMAND ${swig_cmd}
    DEPENDS ${SwigInterfaces} ${SwigHeaders} ${QRDHeaders} ${CMAKE_CURRENT_LIST_DIR}/Code/pyrenderdoc/${SWIG_FILE_NAME}.i
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Compiling SWIG renderdoc:${swig_output}"
)
#add_dependencies(${MODULE_NAME} ${swig_output}/${SWIG_FILE_NAME}_python.cxx)

# 添加构建前执行的命令
set(swig_output ${CMAKE_CURRENT_BINARY_DIR}/generated/qrenderdoc)
set(SwigInterfaces "${CMAKE_CURRENT_LIST_DIR}/Code/pyrenderdoc/*.i")
set(SwigHeaders "${CMAKE_CURRENT_LIST_DIR}/Code/pyrenderdoc/*.h")
set(QRDHeaders "${CMAKE_CURRENT_LIST_DIR}/Code/Interface/*.h")
set(CoreReplayHeaders "${CMAKE_SOURCE_DIR}/renderdoc/api/replay/*.h")
set(SWIG_FILE_NAME qrenderdoc_module)
set(SWIG_FILE_INPUT ${CMAKE_CURRENT_LIST_DIR}/Code/pyrenderdoc/qrenderdoc.i)
#set(swig_includes -I${CMAKE_CURRENT_LIST_DIR}/../renderdoc/api/replay)
set(swig_includes -I${SwigInterfaces} -I${SwigHeaders} -I${QRDHeaders} -I${CMAKE_CURRENT_LIST_DIR} -I${CMAKE_CURRENT_LIST_DIR}/../renderdoc/api/replay)
set(swig_cmd ${CMAKE_CURRENT_LIST_DIR}/3rdparty/swig/swig.exe -v -Wextra -Werror -O -interface ${SWIG_FILE_NAME} -c++ -python -modern -modernargs -enumclass -fastunpack -py3 -builtin ${swig_includes} -outdir ${swig_output} -o ${swig_output}/${SWIG_FILE_NAME}_python.cxx ${SWIG_FILE_INPUT})
message("swig_cmd:${swig_cmd}")
add_custom_command(
    # TARGET ${MODULE_NAME} 
    # PRE_BUILD
    OUTPUT ${swig_output}/${SWIG_FILE_NAME}_python.cxx
    COMMAND ${swig_cmd}
    DEPENDS ${SwigInterfaces} ${SwigHeaders} ${QRDHeaders} ${CMAKE_CURRENT_LIST_DIR}/Code/pyrenderdoc/${SWIG_FILE_NAME}.i
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Compiling SWIG renderdoc:${swig_output}"
)





set(MACHINE_INDEPENDENT_GENERATED_SOURCE_FILES
    ${swig_output}/renderdoc_module_python.cxx
    ${swig_output}/qrenderdoc_module_python.cxx
)

SET_SOURCE_FILES_PROPERTIES(${MACHINE_INDEPENDENT_GENERATED_SOURCE_FILES} PROPERTIES
  GENERATED 1
)

#source_group("Machine Independent\\Generated Source" FILES ${MACHINE_INDEPENDENT_GENERATED_SOURCE_FILES})


build_library(
    ${MODULE_NAME} 
    SHARED
    ${SOURCES}
    ${MACHINE_INDEPENDENT_GENERATED_SOURCE_FILES}
)

my_set_target_folder(${MODULE_NAME} "UI/Python Modules")


target_link_libraries(${MODULE_NAME} 
    renderdoc
    ${PYTHON_LIBRARY}
)





set(SOURCES)