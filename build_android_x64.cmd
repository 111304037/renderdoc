@echo off
rem Use this batch file to build box2d for Visual Studio
chcp 936

::set env_vs=E:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\
set env_vs=C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE
set ANDROID_SDK=D:\Android\sdk
if not exist "%ANDROID_SDK%" (
	set ANDROID_SDK=E:\App\Android\sdk
)

set ANDROID_HOME=%ANDROID_SDK%
set ANDROID_NDK=%ANDROID_SDK%\ndk\25.0.8775105
set env_cmake=%ANDROID_SDK%\cmake\3.18.1\bin


set PATH=%env_cmake%;%ANDROID_SDK%/cmdline-tools/latest/bin;%PATH%

::cmd /k
::cmake -G "Visual Studio 15 2017" -S . -B build
::cmake --build build --target all --config Develop
::cmake --build build --target install
::cmake --build build --target cook-installed-resources-EtEngineDemo

::cmake .. -G "Visual Studio 10 2010 Win64" -T "v100"
::cmake .. -G "Visual Studio 16 2019"
::cmake --build .
::start box2d.sln
echo "********************"

ninja --version
@REM ::下载build-tools
@REM call %ANDROID_SDK%/cmdline-tools/latest/bin/sdkmanager.bat --sdk_root=%ANDROID_SDK% "build-tools;29.0.2" "platforms;android-23"




set apk_dir=%~dp0build-win\bin\plugins\android
::rmdir /s /q build
if exist "%apk_dir%" (
	goto END
)
echo "md %apk_dir%"
md %apk_dir%
:END


@REM ::PLT hook
@REM ::-DUSE_INTERCEPTOR_LIB=On -DLLVM_DIR=H:\zip\LLVM 拦截器,http://it.taocms.org/05/69980.htm
set CMAKE_BUILD_CMD=cmake -DBUILD_ANDROID=On -DANDROID_BUILD_TOOLS_VERSION=29.0.2 -DCMAKE_BUILD_TYPE=Debug -DGIT_HASH=1.30 -GNinja -DGEN_GRADLE=On

rem 设置 abi 数组
set abis[0]=x86
set abis[1]=x86_64
set archs[0]=x86
set archs[1]=x86_64

setlocal enabledelayedexpansion
rem 定义函数

rem 遍历数组
for /l %%i in (0,1,3) do (
	set index=%%i
	set abi=!abis[%%i]!
	set arch=!archs[%%i]!
	@REM echo "abi=!abi!,arch=!arch!"
	call:build_apk !abi! !arch!
)

endlocal

goto CMD_END
:build_apk
	set abi=%1
	set arch=%2
	echo "abi=!abi!,arch=!arch!"
	@REM ::arm64-v8a
	set build_dir=%~dp0build-android\%arch%
	::rmdir /s /q build
	if exist "%build_dir%" (
		goto END
	)
	md %build_dir%
	:END
	cd %build_dir%

	%CMAKE_BUILD_CMD% -DANDROID_ABI=%abi% ../../
	ninja
	copy "%~dp0build-android\%arch%\renderdoccmd\gradle\app\build\outputs\apk\debug\app-debug.apk"  "%apk_dir%\org.rdoc.renderdoccmd.%arch%.apk" /y

goto:eof

:CMD_END
cmd /k

