set(search_paths
	${CMAKE_CURRENT_LIST_DIR}
    #${RDOC_INCLUDES}
)
set(source_cpp_list)
get_source_cpp_list(source_cpp_list ${search_paths})

set(include_dires
    ${CMAKE_CURRENT_LIST_DIR}/../../
    ${CMAKE_CURRENT_LIST_DIR}/../../3rdparty
)
get_include_directories(sub_include_dires ${search_paths})
list(REMOVE_DUPLICATES include_dires)
list(REMOVE_DUPLICATES source_cpp_list)
include_directories(${include_dires})

#使用unicode字符集
add_win32_definitions()
build_library(rdoc_dxgi OBJECT ${source_cpp_list})
target_compile_definitions(rdoc_dxgi ${RDOC_DEFINITIONS})
#添加预编译头
target_precompile_headers(rdoc_dxgi PRIVATE ${CMAKE_CURRENT_LIST_DIR}/precompiled.h)
my_set_target_folder(rdoc_dxgi "DLL/drivers/RHI")
