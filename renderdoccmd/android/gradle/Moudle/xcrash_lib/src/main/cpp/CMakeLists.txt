cmake_minimum_required(VERSION 3.4.1)

#######################################
# global
#######################################

add_definitions(
        -Wno-c++98-compat-pedantic
        -Wno-newline-eof
        -Wno-sign-conversion
        -Wno-padded
        -Wno-zero-as-null-pointer-constant
        -Wno-double-promotion
        -Wno-old-style-cast
        -Wno-unused-variable
        -Wno-non-virtual-dtor
        -Wno-unused-parameter
        -Wno-extra-semi
        -Wno-missing-variable-declarations
        -Wno-delete-non-abstract-non-virtual-dtor
        -Wno-missing-prototypes
        -Wno-reserved-id-macro
        -Wno-shadow-field
        -Wno-exit-time-destructors
        -Wno-format-nonliteral
        -Wno-undef
        -Wno-shadow-field-in-constructor
        -Wno-unreachable-code
        -Wno-int-to-pointer-cast
        -Wno-variadic-macros
        -Wno-implicit-int-float-conversion
        -Wno-void-ptr-dereference
        -Wno-reserved-identifier
        -Wno-unused-but-set-variable
        -Wno-switch-enum
        -Wno-shorten-64-to-32
        -Wno-zero-length-array
        -Wno-global-constructors
        -Wno-format
        -Wno-shadow
        -Wno-extra-semi-stmt
        -Wno-sign-compare
        -Wno-unused-macros
        -Wno-format-pedantic
        -Wno-covered-switch-default
        -Wno-suggest-override
        -Wno-unused-function
        -Wno-weak-vtables
        -Wno-expansion-to-defined
        -Wno-macro-redefined
        -Wno-float-conversion
        -Wno-unused-private-field
        -Wno-enum-float-conversion
        -Wno-string-conversion
        -Wno-implicit-fallthrough
        -Wno-cast-qual
        -Wno-implicit-int-conversion
        -Wno-declaration-after-statement
)


add_compile_options(
        -std=c11
        -Weverything
        -Werror)

#######################################
# libxcrash.so
#######################################

file(GLOB XCRASH_SRC
        xcrash/*.c
        common/*.c
        dl/*.c)

build_library(xcrash SHARED
        ${XCRASH_SRC})

target_include_directories(xcrash PUBLIC
        xcrash
        xcrash_dumper
        common
        dl)

target_link_libraries(xcrash
        log
        dl)

if(USEASAN)

target_compile_options(xcrash PUBLIC
        -fsanitize=address
        -fno-omit-frame-pointer)

set_target_properties(xcrash PROPERTIES
        LINK_FLAGS " \
        -fsanitize=address")

else()

target_compile_options(xcrash PUBLIC
        -Oz
        #-flto
        -ffunction-sections
        -fdata-sections)

set_target_properties(xcrash PROPERTIES
        LINK_FLAGS " \
        -O3 \
        -Wl,--exclude-libs,ALL \
        -Wl,--gc-sections \
        -Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/xcrash.exports")

endif()

#######################################
# libxcrash_dumper.so
#######################################

file(GLOB XCRASH_DUMPER_SRC
        xcrash_dumper/*.c
        common/*.c)

set(LZME_SRC
        lzma/7zCrc.c
        lzma/7zCrcOpt.c
        lzma/CpuArch.c
        lzma/Bra.c
        lzma/Bra86.c
        lzma/BraIA64.c
        lzma/Delta.c
        lzma/Lzma2Dec.c
        lzma/LzmaDec.c
        lzma/Sha256.c
        lzma/Xz.c
        lzma/XzCrc64.c
        lzma/XzCrc64Opt.c
        lzma/XzDec.c)

set_source_files_properties(${LZME_SRC} PROPERTIES
        COMPILE_FLAGS " \
        -D_7ZIP_ST \
        -Wno-enum-conversion \
        -Wno-reserved-id-macro \
        -Wno-undef \
        -Wno-missing-prototypes \
        -Wno-missing-variable-declarations \
        -Wno-cast-align \
        -Wno-sign-conversion \
        -Wno-assign-enum \
        -Wno-unused-macros \
        -Wno-padded \
        -Wno-cast-qual \
        -Wno-strict-prototypes \
        -Wno-extra-semi-stmt")

build_executable(xcrash_dumper
        ${XCRASH_DUMPER_SRC}
        ${LZME_SRC})

target_include_directories(xcrash_dumper PUBLIC
        xcrash_dumper
        common
        lzma)

target_link_libraries(xcrash_dumper
        log
        dl)

if(USEASAN)

target_compile_options(xcrash_dumper PUBLIC
        -fsanitize=address
        -fno-omit-frame-pointer)

set_target_properties(xcrash_dumper PROPERTIES
        LINK_FLAGS " \
        -fsanitize=address")

else()

target_compile_options(xcrash_dumper PUBLIC
        -Oz
        #-flto
        -ffunction-sections
        -fdata-sections)

set_target_properties(xcrash_dumper PROPERTIES
        LINK_FLAGS " \
        -O3 \
        -Wl,--exclude-libs,ALL \
        -Wl,--gc-sections")

endif()

set_target_properties(xcrash_dumper PROPERTIES
        PREFIX "lib"
        SUFFIX ".so")
