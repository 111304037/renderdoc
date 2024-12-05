cmake_minimum_required(VERSION 3.4.1)

set(LIB_NAME renderdoccmd)
project(${LIB_NAME})

include(renderdoccmd_config.cmake)

set(defs
		# c++98-compat-pedantic
		# zero-as-null-pointer-constant
		# unused-parameter
		# missing-variable-declarations
		# exit-time-destructors
		# missing-prototypes
		# format-nonliteral
		# class-varargs
		# sign-conversion
		# old-style-cast
		# extra-semi-stmt
		format-security
)

foreach(def ${defs})
	add_definitions(-Wno-${def})
endforeach()


set(search_paths
	${CMAKE_CURRENT_LIST_DIR}
)

set(source_cpp_list)
get_source_cpp_list(source_cpp_list ${search_paths})
#message( STATUS " ******===src-files = ${source_cpp_list}")

set(include_dires
	${CMAKE_SOURCE_DIR}
	${CMAKE_CURRENT_LIST_DIR}
	${CMAKE_SOURCE_DIR}/Renderdoc/renderdoc/api
)

#get_include_directories(sub_include_dires ${search_paths})
list(APPEND include_dires ${sub_include_dires})

list(REMOVE_DUPLICATES include_dires)
list(REMOVE_DUPLICATES source_cpp_list)
include_directories(${include_dires})

add_definitions(
	${renderdoccmd_definitions}
)
renderdoccmd_cmake_before()
build_library(
	${LIB_NAME}
	SHARED
	${source_cpp_list}
	${ref_source_list}
)
target_link_libraries(${LIB_NAME} ${renderdoccmd_libraries})
renderdoccmd_cmake_after()