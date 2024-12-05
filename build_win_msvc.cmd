@echo off
rem Use this batch file to build box2d for Visual Studio
chcp 936


set PythonLocation=E:\MyFiles\Python\Python38
set PY_PIP=%PY_ROOT%\Scripts
set PY_DLLs=%PY_ROOT%\DLLs
set PY_LIBS=%PY_ROOT%\Lib\site-packages
set PYTHONPATH=%PythonLocation%;%PY_PIP%;%PY_LIBS%;%PY_DLLs%;
set PATH=%PYTHONPATH%;%PATH%

::set env_vs=E:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\
set env_vs=C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE
set env_cmake=%env_vs%\CommonExtensions\Microsoft\CMake\CMake\bin
if not exist "%env_cmake%" (
	set env_cmake=D:\Program Files\cmake-3.20.3-windows-x86_64\bin
)

@REM set env_qt=D:\Program Files\Side Effects Software\Houdini 19.0.498\bin\Qt

set PATH=%env_qt%;%env_cmake%;%PATH%


@REM ::PLT hook
@REM ::-DUSE_INTERCEPTOR_LIB=On -DLLVM_DIR=H:\zip\LLVM 拦截器,http://it.taocms.org/05/69980.htm
set CMAKE_BUILD_CMD=cmake -DCMAKE_BUILD_TYPE=Debug -DGIT_HASH=1.36 -DBRANCH_DEV=On

::armeabi-v7a
set build_dir=%~dp0build-win-msvc
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
