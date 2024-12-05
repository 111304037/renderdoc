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

sh /Volumes/Mxq_Share/MyRenderdoc/Renderdoc/qrenderdoc/../util/set_plist_version.sh 1.33330.0 /Volumes/Mxq_Share/MyRenderdoc/Renderdoc/build-mac/bin/qrenderdoc.app/Contents/Info.plist