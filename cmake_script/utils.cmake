#[[
设置工程子目录
#add_subdirectory(test)
my_set_target_folder(test "Test")
]]

set(VS_INSTALL_PATH "@VS_INSTALL_PATH@")

# place a target inside of an IDE filter
set_property(GLOBAL PROPERTY USE_FOLDERS OFF)
# can't place those targets in custom folder, so increasing visibility by placing them  in the top level
set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "")

include (CMakeParseArguments)  #必须包含这个cmake文件才能使用cmake_parse_arguments

macro(my_set_target_folder _target _folder)
    # if(MSVC)
		# set_property (TARGET "${_target}" PROPERTY FOLDER "${_folder}")
	# endif()
	set_property(GLOBAL PROPERTY USE_FOLDERS ON)
    if(MSVC AND TARGET ${_target})
		#SET_TARGET_PROPERTIES(${PROJECT_NAME} PROPERTIES FOLDER "OS")
      set_property(TARGET "${_target}" PROPERTY FOLDER "${_folder}")
    endif()
endmacro()

#设置启动工程
macro(my_set_target_startup dir tgt)
	# make the Demo the startup project
	set_property(DIRECTORY ${dir} PROPERTY VS_STARTUP_PROJECT ${tgt})
endmacro()

#保持文件目录
function(assign_source_group)
    foreach(_source IN ITEMS ${ARGN})
        if (IS_ABSOLUTE "${_source}")
            file(RELATIVE_PATH _source_rel "${CMAKE_CURRENT_SOURCE_DIR}" "${_source}")
        else()
            set(_source_rel "${_source}")
        endif()
        get_filename_component(_source_path "${_source_rel}" PATH)
        string(REPLACE "/" "\\" _source_path_msvc "${_source_path}")
        source_group("${_source_path_msvc}" FILES "${_source}")
    endforeach()
endfunction(assign_source_group)
 

macro(add_win32_definitions)
	if(WIN32)
		set(defs
			UNICODE _UNICODE
			_WINDOWS
			WIN32
			WIN64
			RENDERDOC_PLATFORM_WIN32
			SCINTILLA_QT=1
			MAKING_LIBRARY=1
			SCI_LEXER=1
			QT_NO_CAST_FROM_ASCII
			QT_NO_CAST_TO_ASCII
			QT_WIDGETS_LIB
			QT_GUI_LIB
			QT_CORE_LIB
			QT_SVG_LIB
		)
		foreach(def ${defs})
			add_definitions(-D${def})
		endforeach()
	endif()
endmacro()

macro(add_common_definitions)
	if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
		#[[
		出现报[-Werror,-Wformat-security] 的error时，在CMake脚本文件CMakeLists.txt里面添加一行
		add_definitions (-Wno-format-security)即可。这种情况实际是编译器把warining作为error处
		理了，遇到其他类似情况同样处理，报[-Werror,-WXXX] 则add_definitions (-Wno-XXX)。
		]]
		set(defs
				#取消警告当错误
				error
				unused-function
				sometimes-uninitialized
				sign-compare
				int-to-void-pointer-cast
				int-to-pointer-cast
				missing-variable-declarations
				padded
				newline-eof
				comma
				shift-count-overflow
				unreachable-code-break
				#non-pod-varargs
				unknown-argument
				c++98-compat
				c++98-compat-pedantic
				deprecated-literal-operator
				extra-semi
				old-style-cast
				zero-as-null-pointer-constant
				sign-conversion
				reserved-macro-identifier
				shadow-field-in-constructor
				reserved-identifier
				shadow
				switch-enum
				covered-switch-default
				signed-enum-bitfield
				bitfield-enum-conversion
				gnu-zero-variadic-macro-arguments
				switch-default
				unsafe-buffer-usage
				cast-qual
				shadow-field
				cast-qual
				cast-align
				non-virtual-dtor
				missing-prototypes
				undefined-func-template
				float-equal
				extra-semi-stmt
				undef
				unused-macros
			)
		foreach(def ${defs})
			add_definitions(-Wno-${def})
		endforeach()
	endif()
	if(BRANCH_DEV)
		add_definitions(-DBRANCH_DEV=1)
	endif()
	if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
		add_definitions(
			-Wno-unknown-argument
			-Wno-c++98-compat
			-Wno-deprecated-literal-operator
		)
		if(WIN32)
			add_definitions(-Wno-microsoft-enum-forward-reference)
		endif()
	endif()
endmacro()

function(build_executable)
	message( STATUS "----------------------[*]${ARGV0}:build_library[START]!")
	#message("Argument count: ${ARGC}")
    #message("all arguments: ${ARGV}")
    #message("optional arguments: ${ARGN}")
    foreach(_source IN ITEMS ${ARGN})
        assign_source_group(${_source})
    endforeach()
	add_common_definitions()
    add_executable(${ARGV})
	message( STATUS "----------------------[*]${ARGV0}:build_library[END]!")
endfunction(build_executable)

 
function(build_library)
	message( STATUS "----------------------[*]${ARGV0}:build_library[START]!")
    foreach(_source IN ITEMS ${ARGN})
        assign_source_group(${_source})
    endforeach()
	add_common_definitions()
    add_library(${ARGV})
	message( STATUS "----------------------[*]${ARGV0}:build_library[END]!")
endfunction(build_library)
 
MACRO(get_directories result curdir)
	FILE(GLOB children RELATIVE ${curdir} ${curdir}/*)
	SET(dir_list "")
	FOREACH(child ${children})
		IF(IS_DIRECTORY ${curdir}/${child})
			#message(status "[-]${child}")
			LIST(APPEND dir_list ${child})
		ENDIF()
	ENDFOREACH()
	SET(${result} ${dir_list})
ENDMACRO()




function(get_include_directories result_list search_paths)
	SET(dir_list "")
	foreach(search_path ${search_paths})
		#message( STATUS "----------------------search_path:${search_path}")
		set(h_path "")
		file(GLOB_RECURSE h_path ${search_path}/*.h*)
		foreach(filename ${h_path})
			STRING(REGEX REPLACE "/[a-z,A-Z,0-9,_,.]+$" "" dirName ${filename})
			list(APPEND dir_list ${dirName})
			#include_directories(${dirName})
			#message( STATUS "----------------------h_path:${dirName}")
		endforeach()

	#[[
		set(cpp_path '')
		file(GLOB_RECURSE cpp_path ${search_path}/*.c*)
		#list(APPEND src-files ${cpp_path})
		foreach(filename ${cpp_path})
			#(?i)开启不区分大小写
			#https://www.cnblogs.com/gisblogs/p/3955648.html
			set(skip false)
			foreach(sub ${cmake_subs})
				if("${filename}" MATCHES "/${sub}/")
					set(skip true)
					break()
				endif()
			endforeach()
			if(${skip})
				continue()
			endif()

			list(APPEND src-files ${filename})
		endforeach()
	]]
	endforeach()
	set(${result_list} ${dir_list} PARENT_SCOPE)
endfunction()

#带剔除路径
function(get_include_directoriesEx result_list search_paths excluded_dir)
	SET(dir_list "")
	foreach(search_path ${search_paths})
		#message( STATUS "----------------------search_path:${search_path}")
		set(h_path "")
		file(GLOB_RECURSE h_path ${search_path}/*.h*)
		foreach(__h ${h_path})
			string(REGEX REPLACE "/[^\/]+$" "" dirName ${__h})
			set(ret -1)
			foreach(__d ${excluded_dir})
				list(FIND __d ${dirName} RET)  
				if (NOT (${RET} EQUAL -1))
					#message(status "[-]${full_path}")
					#message("【*skip headers: ${__h}\n")
					set(ret 1)
					break()
				endif()	
			endforeach()
			if (NOT (${ret} EQUAL -1))
				#message(status "[-]${full_path}")
				#message("【*skip headers: ${dirName}\n")
				continue()
			endif()	
			#message("【*add headers: ${dirName}\n")
			list(APPEND dir_list ${dirName})
			#include_directories(${dirName})
			#message( STATUS "----------------------h_path:${dirName}")
		endforeach()
	endforeach()
	set(${result_list} ${dir_list} PARENT_SCOPE)
endfunction()

# function(get_directories_recurse result_list current_dir excluded_dir)
# 	#message("[f]include dir: " ${current_dir})
# 	SET(dir_list "")
#     if (IS_DIRECTORY ${current_dir})               # 当前路径是一个目录吗，是的话就加入到包含目录
#         #message("include dir: " ${current_dir})
# 		list(APPEND dir_list ${current_dir})
#     endif()

#     file(GLOB ALL_SUB RELATIVE ${current_dir} ${current_dir}/*) # 获得当前目录下的所有文件，放入ALL_SUB列表中
#     foreach(sub ${ALL_SUB})
#         if (IS_DIRECTORY ${current_dir}/${sub})
# 			list(FIND excluded_dir ${sub} RET)  
# 			if (NOT (${RET} EQUAL -1))
# 				#message(status "[-]${full_path}")
# 				continue()
# 			endif ()		
#             get_directories_recurse(sub_dir_list ${current_dir}/${sub} ${excluded_dir}) # 对子目录递归调用，包含
# 			#message("sub dirs:${sub_dir_list}")
# 			list(APPEND dir_list ${sub_dir_list})
#         endif()
#     endforeach()
# 	set(${result_list} ${dir_list} PARENT_SCOPE)
# endfunction()

function(get_source_cpp_list result_list search_paths)
	message("Argument count: ${ARGC}\n")
    message("all arguments: ${ARGV}\n")
    message("optional arguments: ${ARGN}\n")
	message(get_source_cpp_list: "**************${${result_list}}\n")
	SET(source_cpp_list "")
	SET(source_head_list "")
	message( STATUS "[-search_paths]${search_paths}\n")
	set(list_args ${search_paths} ${ARGN})
    message("list_args: ${list_args}\n")
	FOREACH(subdir ${list_args})
		message( STATUS "[*]${subdir}")
		set(source_cpp "")
		file(GLOB_RECURSE source_cpp ${subdir}/*.c*)
		list(APPEND source_cpp_list ${source_cpp})
		#message(search_path: "**************${source_cpp}\n")
		#source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}" PREFIX "src" FILES ${BOX2D_SOURCE_FILES})
		
		set(source_head "")
		file(GLOB_RECURSE source_head ${subdir}/*.h*)
		list(APPEND source_head_list ${source_head})
		#GLOBAL_SCOPE、FORCE
		set(${result_list} ${${result_list}} ${source_cpp_list} ${source_head_list} PARENT_SCOPE)
		message(result_list: "**************${result_list}\n")
	ENDFOREACH()
	#source_group("Include_Name" FILES ${source_head_list})
endfunction()


function(get_source_cpp_listEx result_list)
	cmake_parse_arguments(IN "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
	set(search_paths, ${IN_search_paths})
	set(excluded_dir, ${IN_excluded_dir})
	message("Argument count: ${ARGC}\n")
    message("all arguments: ${ARGV}\n")
    message("last argument: ${ARGN}\n")
    message("excluded_dir: ${excluded_dir}\n")
	message(get_source_cpp_listEx: "**************${${result_list}}\n")
	SET(source_cpp_list "")
	SET(source_head_list "")
	message(STATUS "[*]search_paths:${search_paths}\n")
	set(list_args ${search_paths} ${ARGN})
    message("list_args: ${list_args}\n")
	FOREACH(subdir ${list_args})
		message(STATUS "[*subdir]${subdir}")
		set(source_cpp "")
		file(GLOB_RECURSE source_cpp ${subdir}/*.c*)
		FOREACH(__cpp ${source_cpp})
			#STRING(REGEX REPLACE "/[a-z,A-Z,0-9,_,.]+$" "" dirName ${__cpp})
			#string(REGEX REPLACE ".*/\(.*\)" "\\1" dirName ${__cpp})#文件名带后缀
			string(REGEX REPLACE "/[^\/]+$" "" dirName ${__cpp})
			set(ret -1)
			foreach(__d ${excluded_dir})
				list(FIND __d ${dirName} RET)  
				if (NOT (${RET} EQUAL -1))
					#message(status "[-]${full_path}")
					message("【*skip cpp: ${__cpp}\n")
					set(ret 1)
					break()
				endif()	
			endforeach()
			if (NOT (${ret} EQUAL -1))
				#message(status "[-]${full_path}")
				#message("【*skip cpp: ${dirName}\n")
				continue()
			endif()	
			list(APPEND source_cpp_list ${__cpp})
			message("【*add cpp: ${__cpp} --- ${dirName}---${excluded_dir}\n")
		ENDFOREACH()
		#message(search_path: "**************${source_cpp}\n")
		#source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}" PREFIX "src" FILES ${BOX2D_SOURCE_FILES})
		
		set(source_head "")
		file(GLOB_RECURSE source_head ${subdir}/*.h*)
		FOREACH(__h ${source_cpp})
			STRING(REGEX REPLACE "/[^\/]+$" "" dirName ${__h})
			set(ret -1)
			foreach(__d ${excluded_dir})
				list(FIND __d ${dirName} RET)  
				if (NOT (${RET} EQUAL -1))
					#message(status "[-]${full_path}")
					#message("【*skip head: ${__h}\n")
					set(ret 1)
					break()
				endif()	
			endforeach()
			if (NOT (${ret} EQUAL -1))
				#message(status "[-]${full_path}")
				#message("【*skip head: ${dirName}\n")
				continue()
			endif()
			list(APPEND source_head_list ${__h})
			#message("【*add head: ${__h}\n")
		ENDFOREACH()
		#GLOBAL_SCOPE、FORCE
		set(${result_list} ${${result_list}} ${source_cpp_list} ${source_head_list} PARENT_SCOPE)
		message(result_list: "**************${result_list}\n")
	ENDFOREACH()
	#source_group("Include_Name" FILES ${source_head_list})
endfunction()

# function(get_source_cpp_recurse result_list current_dir excluded_dir)
# 	SET(source_cpp_list "")
# 	SET(source_head_list "")
# 	FOREACH(subdir ${current_dir})
# 		#message( STATUS "[*]${subdir}")
# 		set(source_cpp "")
# 		file(GLOB source_cpp ${subdir}/*.c*)
# 		list(APPEND source_cpp_list ${source_cpp})
# 		#message(search_path: "**************${source_cpp}\n")
# 		#source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}" PREFIX "src" FILES ${BOX2D_SOURCE_FILES})
		
# 		set(source_head "")
# 		file(GLOB source_head ${subdir}/*.h*)
# 		list(APPEND source_head_list ${source_head})
# 	ENDFOREACH()
	
# 	file(GLOB ALL_SUB RELATIVE ${current_dir} ${current_dir}/*) # 获得当前目录下的所有文件，放入ALL_SUB列表中
#     foreach(sub ${ALL_SUB})
#         if (IS_DIRECTORY ${current_dir}/${sub})
# 			list(FIND excluded_dir ${sub} RET)  
# 			if (NOT (${RET} EQUAL -1))
# 				#message(status "[-]${full_path}")
# 				continue()
# 			endif ()		
#             get_source_cpp_recurse(sub_dir_list ${current_dir}/${sub} ${excluded_dir}) # 对子目录递归调用，包含
# 			#message("sub dirs:${sub_dir_list}")
# 			list(APPEND dir_list ${sub_dir_list})
#         endif()
#     endforeach()
	
# 	set(${result_list} ${source_cpp_list} ${source_head_list} PARENT_SCOPE)
# 	#source_group("Include_Name" FILES ${source_head_list})
# endfunction()

function(get_file_no_ex SRC_FILES)
	#CMake 从文件路径中提取文件名
	FILE(GLOB_RECURSE SRC_FILES "*.c" "*.cc" "*.cpp" "*.h" "*.hpp")
	FOREACH(FILE_PATH ${SRC_FILES})
		MESSAGE(${FILE_PATH})
		STRING(REGEX REPLACE ".+/(.+)\\..*" "\\1" FILE_NAME ${FILE_PATH})
		MESSAGE(${FILE_NAME})
	ENDFOREACH(FILE_PATH)
endfunction()

MACRO(FIND_EXCLUDE_FILES src_files rescure exclude_dir)
	FILE(${rescure} excludefiles  ${exclude_dir})
	FOREACH(excludefile ${excludefiles})
		LIST(REMOVE_ITEM ${src_files} ${excludefile})
	ENDFOREACH(excludefile)
ENDMACRO(FIND_EXCLUDE_FILES)


MACRO(EXCLUDE_FILES src_files rescure exclude_dir)
	FILE(${rescure} excludefiles  ${exclude_dir})
	FOREACH(excludefile ${excludefiles})
        message("EXCLUDE_FILES:${excludefile}")
		LIST(REMOVE_ITEM ${src_files} ${excludefile})
	ENDFOREACH(excludefile)
ENDMACRO(EXCLUDE_FILES)


macro(link_third_lib name path)
add_library(${name} STATIC IMPORTED)
set_target_properties(${name} PROPERTIES IMPORTED_LOCATION 
	${path}
)
target_link_libraries(${LIB_NAME} ${name})
endmacro()


function(get_file_name RESULT_VAR FILE_PATH)
	#STRING(REGEX REPLACE ".+/(.+)\\..*" "\\1" filename ${FILE_PATH})
	get_filename_component(filename ${FILE_PATH} NAME_WE)
  	set(${RESULT_VAR} ${filename} PARENT_SCOPE)
	#message("get_file_name:${FILE_PATH} => ${filename}")
	#set(FILE_NAME ${filename})
endfunction()

macro(set_win32_RuntimeChecks_default)
	macro(RemoveDebugCXXFlag flag)
		string(REPLACE "${flag}" "" CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")
	endmacro()
	message("CMAKE_CXX_FLAGS_DEBUG:${CMAKE_CXX_FLAGS_DEBUG}") # Print Debug Flags Before Change
	RemoveDebugCXXFlag("/RTC1")
	message("CMAKE_CXX_FLAGS_DEBUG:${CMAKE_CXX_FLAGS_DEBUG}") # Print Debug Flags After Change

	macro(RemoveReleaseCXXFlag flag)
		string(REPLACE "${flag}" "" CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
	endmacro()
	message("CMAKE_CXX_FLAGS_RELEASE:${CMAKE_CXX_FLAGS_RELEASE}") # Print Release Flags Before Change
	RemoveReleaseCXXFlag("/RTC1")
	message("CMAKE_CXX_FLAGS_RELEASE:${CMAKE_CXX_FLAGS_RELEASE}") # Print Release Flags After Change
endmacro()


 