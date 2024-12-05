@REM @echo off
chcp 936

::https://bootstrap.pypa.io/get-pip.py
set env_py3_home=C:\Program Files (x86)\Microsoft Visual Studio\Shared\Python39_64
set env_py3_pip=%env_py3_home%\Scripts
set env_py3_dlls=%env_py3_home%\DLLs
set env_py3_libs=%env_py3_home%\Lib\site-packages
set env_py3_path=%env_py3_home%;%env_py3_pip%;%env_py3_libs%;%env_py3_dlls%;
@set PATH=%env_py3_path%;%PATH%

set env_vs=C:\Program Files\Microsoft Visual Studio\2022\Enterprise
set LLVM_VERSION=17
set WIN_SDK_VER=14.36.32532

@REM set env_vs=C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise
@REM set LLVM_VERSION=12.0.0
@REM set WIN_SDK_VER=14.29.30133

set VCINSTALLDIR=%env_vs%\VC
set VCToolsInstallDir=%VCINSTALLDIR%\Tools\MSVC\%WIN_SDK_VER%

set VC_ExecutablePath_x64=%VCToolsInstallDir%\bin\HostX64\x64
@set PATH=%VC_ExecutablePath_x64%;%PATH%

set LLVMInstallDir=%VCINSTALLDIR%\Tools\Llvm\x64
@REM set LLVMInstallDir=E:\MA75\clang+llvm-19.1.4-x86_64-pc-windows-msvc
@REM set LLVM_VERSION=19
set LIBCLANG_PATH=%LLVMInstallDir%\bin;%LLVMInstallDir%\lib\clang\%LLVM_VERSION%\lib\windows
set env_cmake=%env_vs%\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin
@set PATH=%LIBCLANG_PATH%;%env_cmake%;%PATH%


@REM "%LLVMInstallDir%/bin/clang.exe" --version
where clang
clang --version
python -V
@REM cmd /k

@REM ::PLT hook
@REM ::-DUSE_INTERCEPTOR_LIB=On -DLLVM_DIR=H:\zip\LLVM 拦截器,http://it.taocms.org/05/69980.htm
set CMAKE_BUILD_CMD=cmake -DCMAKE_BUILD_TYPE=Debug -DGIT_HASH=1.30 -DBRANCH_DEV=On -T ClangCL -A x64

::armeabi-v7a
set build_dir=%~dp0build-win-llvm
::rmdir /s /q build
if exist "%build_dir%" (
	goto END
)
md %build_dir%
:END
cd %build_dir%

%CMAKE_BUILD_CMD% %~dp0

cmake --build . -j 16
cmd /k
