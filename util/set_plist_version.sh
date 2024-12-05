#!/bin/sh
#sh需要LF结尾
VERSION=$1
PLIST=$2

echo "fuck VERSION $VERSION"
echo "fuck PLIST $PLIST"

# Delete the key if it already exists
# 2>&1 表示将标准错误输出重定向到标准输出

# Now add with the right value
 if /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$PLIST" >/dev/null 2>&1; then 
    #/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString string $VERSION" "$PLIST" || exit 1
    echo "Delete :CFBundleShortVersionString"
    /usr/libexec/PlistBuddy -c "Delete :CFBundleShortVersionString" "$PLIST" >/dev/null 2>&1 || exit 1
 fi 
echo "Add :CFBundleShortVersionString"
/usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string $VERSION" "$PLIST" || exit 1

#echo "3"
# Set identifier
if /usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$PLIST" >/dev/null 2>&1; then 
    echo "Delete :CFBundleIdentifier"
    /usr/libexec/PlistBuddy -c "Delete :CFBundleIdentifier" "$PLIST" >/dev/null 2>&1 || exit 1
fi
echo "Add :CFBundleIdentifier"
/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string org.rdoc.qrenderdoc" "$PLIST" || exit 1
exit 0







VERSION=$1
PLIST=$2

# Delete the key if it already exists
/usr/libexec/PlistBuddy -c "Delete :CFBundleShortVersionString" "$PLIST" >/dev/null 2>&1

# Now add with the right value
/usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string $VERSION" "$PLIST" || exit 1

# Set identifier
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier org.renderdoc.qrenderdoc" "$PLIST" || exit 1
