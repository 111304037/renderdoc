#string(REPLACE "\\" "/" NDK_PATH "${ANDROID_NDK_ROOT_PATH}")
set(ref_source_list)
set(renderdoccmd_cmake_before)
set(renderdoccmd_cmake_after)
set(renderdoccmd_libraries)
set(renderdoccmd_definitions)
#set(renderdoccmd_includes)


set(sources
    ${CMAKE_CURRENT_SOURCE_DIR}/renderdoccmd.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/renderdoccmd.h
    ${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/cmdline/cmdline.h
    )
set(includes PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/3rdparty ${CMAKE_SOURCE_DIR}/renderdoc/api)
set(libraries renderdoc)

if(PythonLibs_FOUND)
    #add_definitions(-DPYTHON_VERSION_MINOR=${PYTHON_VERSION_MINOR})
    set(renderdoccmd_definitions "${renderdoccmd_definitions} -DPYTHON_VERSION_MINOR=${PYTHON_VERSION_MINOR}\n")
else()
    #add_definitions(-DPYTHON_VERSION_MINOR=0)
    set(renderdoccmd_definitions "${renderdoccmd_definitions} -DPYTHON_VERSION_MINOR=0\n")
endif()

list(APPEND libraries -llog -landroid)
list(APPEND sources ${CMAKE_CURRENT_SOURCE_DIR}/renderdoccmd_android.cpp)

string(REPLACE "\\" "/" GLUE_SOURCE "${ANDROID_NDK_ROOT_PATH}/sources/android/native_app_glue/android_native_app_glue.c")
list(APPEND sources ${CMAKE_CURRENT_SOURCE_DIR}/renderdoccmd_android.cpp "${GLUE_SOURCE}")
set(renderdoccmd_cmake_before "${renderdoccmd_cmake_before} include_directories(\${ANDROID_NDK}/sources/android/native_app_glue)\n")

#set(LINKER_FLAGS "-Wl,--no-as-needed")
# set(renderdoccmd_cmake_after "${renderdoccmd_cmake_after} include_directories(\${ANDROID_NDK}/sources/android/native_app_glue)\n")
# set(renderdoccmd_cmake_after """${renderdoccmd_cmake_after}
#     #android_native_app_glue
#     target_include_directories(\${LIB_NAME} PUBLIC \${ANDROID_NDK}/sources/android/native_app_glue)
#     build_library(native_app_glue STATIC \${ANDROID_NDK}/sources/android/native_app_glue/android_native_app_glue.c)
#     target_link_libraries(\${LIB_NAME} native_app_glue)""")

if(ENABLE_ASAN)
    set(LINKER_FLAGS "${LINKER_FLAGS} -fsanitize=address")
endif()

# set_source_files_properties(renderdoccmd.cpp PROPERTIES COMPILE_FLAGS "-fexceptions -frtti")
# set_source_files_properties(renderdoccmd_android.cpp PROPERTIES COMPILE_FLAGS "-fexceptions")
# if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
#     set_property(SOURCE renderdoccmd_android.cpp APPEND_STRING PROPERTY COMPILE_FLAGS " -Wno-shadow")
# endif()
# if(ANDROID)
#     set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${LINKER_FLAGS}")
#     build_library(renderdoccmd SHARED ${sources})
# endif()
# if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
#     set_property(SOURCE renderdoccmd.cpp APPEND_STRING PROPERTY COMPILE_FLAGS " -Wno-shadow")
# endif()
# target_include_directories(renderdoccmd ${includes})
# target_link_libraries(renderdoccmd ${libraries})
set(renderdoccmd_definitions "${renderdoccmd_definitions} -fexceptions -frtti -Wno-shadow\n")
set(renderdoccmd_libraries "${renderdoccmd_libraries} ${libraries}\n")
set(renderdoccmd_cmake_before "${renderdoccmd_cmake_before} set(CMAKE_SHARED_LINKER_FLAGS \${CMAKE_SHARED_LINKER_FLAGS} ${LINKER_FLAGS})\n")
#string(REPLACE ";" "\n" ref_source_list "${ref_source_list} ${sources}")
string(REPLACE ";" "\n" renderdoccmd_definitions "${renderdoccmd_definitions}")
#string(REPLACE ";" "\n" renderdoccmd_libraries "${renderdoccmd_libraries}")
string(REPLACE ";" "\n" renderdoccmd_cmake_before "${renderdoccmd_cmake_before}")
string(REPLACE ";" "\n" renderdoccmd_cmake_after "${renderdoccmd_cmake_after}")


# install (TARGETS renderdoccmd DESTINATION bin)

if(ANDROID)
    # Android sets this to off becuase Android is always terrible forever.
    # It breaks finding java in the path, so enable it again
    set(CMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH ON)

    #############################
    # We need to check that 'java' in PATH is new enough. Temporarily unset the JAVA_HOME env,
    # then invoke FindJava.cmake which will search just the PATH, then re-set it.
    set(SAVE_JAVA_HOME $ENV{JAVA_HOME})

    set(ENV{JAVA_HOME} "")
    find_package(Java)
    set(ENV{JAVA_HOME} ${SAVE_JAVA_HOME})

    if(NOT ${Java_FOUND})
        message(FATAL_ERROR "Building Android requires the 'java' program in your PATH. It must be at least Java 8 (1.8)")
    endif()

    if(${Java_VERSION} VERSION_LESS 1.8)
        message(FATAL_ERROR "Building Android requires the 'java' program in your PATH to be at least Java 8 (1.8)")
    endif()
    message(STATUS "Using Java of version ${Java_VERSION}")

    # if(STRIP_ANDROID_LIBRARY AND ANDROID_STRIP_TOOL AND RELEASE_MODE)
    #     add_custom_command(TARGET renderdoccmd POST_BUILD
    #         COMMAND echo Stripping $<TARGET_FILE:renderdoccmd>
    #         COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:renderdoccmd> $<TARGET_FILE:renderdoccmd>.dbg
    #         COMMAND ${ANDROID_STRIP_TOOL} --strip-unneeded $<TARGET_FILE:renderdoccmd>)
    # endif()

    set(ANDROID_BUILD_TOOLS_VERSION "" CACHE STRING "Version of Android build-tools to use instead of the default")
    if(ANDROID_BUILD_TOOLS_VERSION STREQUAL "")
        # Enumerate the build tools versions available, and pick the most recent
        file(GLOB __buildTools RELATIVE "${ANDROID_SDK_ROOT_PATH}/build-tools" "${ANDROID_SDK_ROOT_PATH}/build-tools/*")
        list(SORT __buildTools)

        list(GET __buildTools -1 ANDROID_BUILD_TOOLS_VERSION)

        unset(__buildTools)
    endif()
    message(STATUS "Using Android build-tools version ${ANDROID_BUILD_TOOLS_VERSION}")

    set(APK_TARGET_ID "" CACHE STRING "The Target ID to build the APK for like 'android-99', use <android list targets> to choose another one.")
    if(APK_TARGET_ID STREQUAL "")
        # This seems different from the platform we're targetting,
        # default to the latest available that's greater or equal to our target platform
        file(GLOB __platforms RELATIVE "${ANDROID_SDK_ROOT_PATH}/platforms" "${ANDROID_SDK_ROOT_PATH}/platforms/*")
        list(SORT __platforms)

        # In case we don't find one, target the latest platform
        list(GET __platforms -1 APK_TARGET_ID)

        string(REPLACE "android-" "" __targetPlat "${ANDROID_PLATFORM}")

        # We require at least android 23 for Activity.requestPermissions
        if(__targetPlat LESS 23)
            set(__targetPlat 23)
        endif()

        foreach( __plat ${__platforms})
            string(REPLACE "android-" "" __curPlat "${__plat}")

            if(NOT (__curPlat LESS __targetPlat) )
                set(APK_TARGET_ID "android-${__curPlat}")
                break()
            endif()
        endforeach()

        unset(__platforms)
        unset(__targetPlat)
        unset(__curPlat)
    endif()
    message(STATUS "Using android.jar from platform ${APK_TARGET_ID}")

    # Suffix for scripts rather than binaries, which is needed explicitly on windows
    set(TOOL_SCRIPT_EXTENSION "")
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
        set(TOOL_SCRIPT_EXTENSION ".bat")
    endif()

    set(BUILD_TOOLS "${ANDROID_SDK_ROOT_PATH}/build-tools/${ANDROID_BUILD_TOOLS_VERSION}")
    set(RT_JAR "$ENV{JAVA_HOME}/jre/lib/rt.jar")
    set(JAVA_BIN "$ENV{JAVA_HOME}/bin")

    string(REPLACE "\\" "/" ANDROID_JAR "${ANDROID_SDK_ROOT_PATH}/platforms/${APK_TARGET_ID}/android.jar")
    if(CMAKE_HOST_WIN32)
        set(CLASS_PATH "${ANDROID_JAR}\;obj")
    else()
        set(CLASS_PATH "${ANDROID_JAR}:obj")
    endif()
    option(ENABLE_CUSTOM_WRAP_SCRIPT "Enable custom wrap.sh on Android to workaround Android bug" ON)

    #ASAN内存泄漏检测
    if(ENABLE_ASAN)
        message("ASAN内存泄漏检测")
        set(ASAN_ABI_TAG "")
        if(ANDROID_ABI STREQUAL "armeabi-v7a")
            set(ASAN_ABI_TAG "arm")
        elseif(ANDROID_ABI STREQUAL "arm64-v8a")
            set(ASAN_ABI_TAG "aarch64")
        else()
            message(WARNING "Unknown ABI ${ANDROID_ABI}, libasan tag unknown")
        endif()

        file(GLOB ASAN_LIBRARIES "${ANDROID_TOOLCHAIN_ROOT}/lib64/clang/*/lib/linux/libclang_rt.asan-${ASAN_ABI_TAG}-android.so")
        list(SORT ASAN_LIBRARIES)

        list(GET ASAN_LIBRARIES -1 ASAN_LIBRARY)

        set(WRAP_SCRIPT "${ANDROID_NDK_ROOT_PATH}/wrap.sh/asan.sh")

        string(REPLACE "\\" "/" WRAP_SCRIPT "${WRAP_SCRIPT}")
        string(REPLACE "\\" "/" ASAN_LIBRARY "${ASAN_LIBRARY}")

        # Copy in the wrap script and libasan library
        if(${WRAP_SCRIPT} STREQUAL "" OR NOT EXISTS ${WRAP_SCRIPT})
            message(WARNING "Wrap script couldn't be found in NDK, you will need to manually create one and re-generate apk")
        elseif(${ASAN_LIBRARY} STREQUAL "" OR NOT EXISTS ${ASAN_LIBRARY})
            message(WARNING "libasan library couldn't be found in NDK, you will need to manually copy it in and re-generate apk")
        else()
            if(ENABLE_CUSTOM_WRAP_SCRIPT)
                message(STATUS "Chaining to wrap script ${WRAP_SCRIPT} and libasan library ${ASAN_LIBRARY}")
                add_custom_command(OUTPUT ${APK_FILE} APPEND
                    COMMAND ${CMAKE_COMMAND} -E copy ${WRAP_SCRIPT} libs/lib/${ANDROID_ABI}/asan.sh
                    COMMAND ${CMAKE_COMMAND} -E copy ${ASAN_LIBRARY} libs/lib/${ANDROID_ABI}/
                    )
            else()
                message(STATUS "Directly using wrap script ${WRAP_SCRIPT} and libasan library ${ASAN_LIBRARY}")
                add_custom_command(OUTPUT ${APK_FILE} APPEND
                    COMMAND ${CMAKE_COMMAND} -E copy ${WRAP_SCRIPT} libs/lib/${ANDROID_ABI}/wrap.sh
                    COMMAND ${CMAKE_COMMAND} -E copy ${ASAN_LIBRARY} libs/lib/${ANDROID_ABI}/
                    )
            endif()
        endif()
    endif()

    set(D8_SCRIPT "${BUILD_TOOLS}/d8${TOOL_SCRIPT_EXTENSION}")
    if(NOT EXISTS ${D8_SCRIPT})
        set(DEX_COMMAND ${BUILD_TOOLS}/dx${TOOL_SCRIPT_EXTENSION} --dex --output=bin/classes.dex ./obj)
    else()
        set(DEX_COMMAND ${D8_SCRIPT} --output ./bin/ ./obj/org/rdoc/renderdoccmd/${ABI_EXTENSION_NAME}/*.class)
    endif()

    # #使用aapt生成apk
    # add_custom_command(OUTPUT ${APK_FILE} APPEND
    #                    COMMAND ${BUILD_TOOLS}/aapt package -f -m -S res -J src -M AndroidManifest.xml -I ${ANDROID_JAR}
    #                    COMMAND ${JAVA_BIN}/javac -d ./obj -source 1.7 -target 1.7 -bootclasspath ${RT_JAR} -classpath "${CLASS_PATH}" -sourcepath src src/org/rdoc/renderdoccmd/*.java
    #                    COMMAND ${DEX_COMMAND}
    #                    COMMAND ${BUILD_TOOLS}/aapt package -f -M AndroidManifest.xml --version-code ${APK_VERSION_CODE} --version-name ${APK_VERSION_NAME} -S res -I ${ANDROID_JAR} -F RenderDocCmd-unaligned.apk bin libs
    #                    COMMAND ${BUILD_TOOLS}/zipalign -f 4 RenderDocCmd-unaligned.apk RenderDocCmd.apk
    #                    COMMAND ${BUILD_TOOLS}/apksigner${TOOL_SCRIPT_EXTENSION} sign --ks ${KEYSTORE} --ks-pass pass:android --key-pass pass:android --ks-key-alias rdocandroidkey RenderDocCmd.apk
    #                    COMMAND ${CMAKE_COMMAND} -E copy RenderDocCmd.apk ${APK_FILE})



    
    # set(KEYSTORE ${CMAKE_CURRENT_BINARY_DIR}/debug.keystore)
    # add_custom_command(OUTPUT ${KEYSTORE}
    #                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    #                    COMMAND ${JAVA_BIN}/keytool -genkey -keystore ${KEYSTORE} -storepass android -alias rdocandroidkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=, OU=, O=, L=, S=, C=")

    # APK_VERSION_CODE corresponds to android:versionCode, an internal integer value that can be queried. Higher numbers indicate more recent versions.
    # APK_VERSION_NAME corresponds to android:versionName, a string value that is displayed to the user.
    set(APK_VERSION_CODE "${RENDERDOC_VERSION_MAJOR}${RENDERDOC_VERSION_MINOR}")
    set(APK_VERSION_NAME ${GIT_COMMIT_HASH})
    message(STATUS "Building APK versionCode ${APK_VERSION_CODE}, versionName ${APK_VERSION_NAME}")

    # Set the package name based on the ABI
    if(ANDROID_ABI STREQUAL "armeabi-v7a")
        set(ABI_EXTENSION_NAME "arm32")
    elseif(ANDROID_ABI STREQUAL "arm64-v8a")
        set(ABI_EXTENSION_NAME "arm64")
    elseif(ANDROID_ABI STREQUAL "x86")
        set(ABI_EXTENSION_NAME "x86")
    elseif(ANDROID_ABI STREQUAL "x86_64")
        set(ABI_EXTENSION_NAME "x64")
    else()
        message(FATAL_ERROR "ABI ${ANDROID_ABI} is not supported.")
    endif()

    set(RENDERDOC_ANDROID_PACKAGE_NAME "org.rdoc.renderdoccmd.${ABI_EXTENSION_NAME}")
    set(APK_LABEL_NAME "rdoc_${ABI_EXTENSION_NAME}")

    
    # https://www.cnblogs.com/the-capricornus/p/4717566.html
    # configure_file 配置文件，让你可以在代码文件中使用CMake中定义的的变量,如@VAR@ 或 ${VAR}
    # Copy in android package files, replacing the package name with the architecture-specific package name
    set(gradle_root ${CMAKE_CURRENT_BINARY_DIR}/gradle)
    configure_file(android/icon.png ${gradle_root}/app/src/main/res/drawable/icon.png COPYONLY) #只复制，不替换内容
    configure_file(android/Loader.java ${gradle_root}/app/src/main/java/org/rdoc/renderdoccmd/${ABI_EXTENSION_NAME}/Loader.java)
    configure_file(android/AndroidManifest.xml ${gradle_root}/app/src/main/AndroidManifest.xml)
    configure_file(android/build.gradle ${gradle_root}/build.gradle)
    configure_file(android/renderdoccmd_config.cmake ${gradle_root}/app/src/main/cpp/Renderdoc/renderdoccmd/renderdoccmd_config.cmake)
    
    set(VS_INSTALL_PATH "")
    string(REPLACE "\\" "/" VS_INSTALL_PATH "$ENV{env_vs}")
    configure_file(${CMAKE_SOURCE_DIR}/cmake_script/utils.cmake ${gradle_root}/app/src/main/cpp/Renderdoc/cmake_script/utils.cmake)

    
    if(ENABLE_CUSTOM_WRAP_SCRIPT)
        # # use configure_file to ensure unix newlines regardless of how it is in the repository (e.g. CRLF on windows)
        # configure_file(android/wrap.sh ${CMAKE_CURRENT_BINARY_DIR}/libs/lib/${ANDROID_ABI}/wrap.sh @ONLY NEWLINE_STYLE UNIX)

        # message(STATUS "Using custom wrap script for Android bug workaround")
        # add_custom_command(OUTPUT ${APK_FILE} APPEND
        #     COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/libs/lib/${ANDROID_ABI}/wrap.sh libs/lib/${ANDROID_ABI}/wrap.sh
        #     )
    else()
        message(WARNING "Without custom wrap script, some Android versions will break due to Android bug")
    endif()


    # 复制gradle工程模板
    add_custom_command(OUTPUT gradle_project
                       COMMENT "1.创建Gradle工程,${CMAKE_CURRENT_BINARY_DIR}"
                    #    DEPENDS renderdoc
                    #    DEPENDS renderdoccmd
                    #    DEPENDS ${KEYSTORE}
                       WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                       COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/renderdoccmd/android/gradle ${gradle_root}
                       #复制根CMakeLists.txt
                       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/CMakeLists.txt ${gradle_root}/app/src/main/cpp/Renderdoc/
                    #    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/cmake_script ${gradle_root}/app/src/main/cpp/Renderdoc/cmake_script
                       #复制renderdoc工程
                       COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/renderdoc ${gradle_root}/app/src/main/cpp/Renderdoc/renderdoc/
                       #复制renderdoccmd
                       COMMAND ${CMAKE_COMMAND} -E copy ${sources} ${gradle_root}/app/src/main/cpp/Renderdoc/renderdoccmd/
                       COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/renderdoccmd/3rdparty/cmdline ${gradle_root}/app/src/main/cpp/Renderdoc/renderdoccmd/cmdline/
                    )
    #创建签名
    set(KEYSTORE ${CMAKE_CURRENT_BINARY_DIR}/gradle/rdoc.keystore)
    set(KEY_PASS .123456)
    set(KEY_NAME rdoc_key_store)
    add_custom_command(OUTPUT ${KEYSTORE}
                        DEPENDS gradle_project
                        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/gradle
                        COMMENT "2.创建签名,${WORKING_DIRECTORY}"
                        cd gradle
                        COMMAND ${JAVA_BIN}/keytool -genkey -keystore ${KEYSTORE} -storepass ${KEY_PASS} -alias ${KEY_NAME} -keypass ${KEY_PASS} -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=, OU=, O=, L=, S=, C="
    )
    #构建gradle
    add_custom_command(OUTPUT build_gradle
        DEPENDS ${KEYSTORE}
        WORKING_DIRECTORY ${gradle_root}
        COMMENT "3.创建apk,${WORKING_DIRECTORY}"
        #COMMAND ${gradle_root}/gradlew assembleRelease
        COMMAND ${gradle_root}/gradlew assembleDebug
    )

    #增加一个没有输出的目标,make apk
    set(APK_FILE ${CMAKE_BINARY_DIR}/bin/${RENDERDOC_ANDROID_PACKAGE_NAME}.apk)
    add_custom_target(apk ALL
                      DEPENDS ${APK_FILE})
                  
    #add_custom_command需要ninja才会执行
    #创建libs/lib/abi目录，并复制so到改目录
    add_custom_command(OUTPUT ${APK_FILE}
                       #DEPENDS renderdoc
                       #DEPENDS renderdoccmd
                       #WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                       DEPENDS build_gradle
                    #    COMMAND ${CMAKE_COMMAND} -E make_directory libs/lib/${ANDROID_ABI}
                    #    COMMAND ${CMAKE_COMMAND} -E make_directory obj
                    #    COMMAND ${CMAKE_COMMAND} -E make_directory bin
    )
    
endif()
