: '
安装依赖
brew install autoconf
#brew install automake
brew install cmake
brew install qt5
brew install swig
brew install pcre

'

export PATH="/usr/local/opt/qt@5/bin:$PATH"

echo "dirname=$0"
RootDir=$(cd `dirname $0`; pwd)
echo "RootDir=$RootDir"
cd ${RootDir}


mkdir build-mac
cd build-mac
#cmake ..
#生成xcode
cmake -G Xcode .. -DENABLE_METAL=On -DENABLE_VULKAN=Off -DENABLE_GL=Off -DENABLE_GL=Off -DENABLE_GLES=Off -DENABLE_EGL=Off
cmake --build .