#!/usr/bin/env bash
set -e
# prerequisite: brew install qt@5 freeglut mesa harfbuzz

#sys_glut_clfags=`pkg-config --cflags glut gl`
#sys_glut_libs=`pkg-config --libs glut gl`
#sys_harfbuzz_clfags=`pkg-config --cflags harfbuzz`
#sys_harfbuzz_libs=`pkg-config --libs harfbuzz`

if [ -z ${MAKE_PARALLEL+x} ]; then export MAKE_PARALLEL=1; else echo "MAKE_PARALLEL defined"; fi
echo "MAKE_PARALLEL set to $MAKE_PARALLEL"

cd mupdf
#make USE_SYSTEM_HARFBUZZ=yes USE_SYSTEM_GLUT=yes SYS_GLUT_CFLAGS="${sys_glut_clfags}" SYS_GLUT_LIBS="${sys_glut_libs}" SYS_HARFBUZZ_CFLAGS="${sys_harfbuzz_clfags}" SYS_HARFBUZZ_LIBS="${sys_harfbuzz_libs}" -j 4
make HAVE_GLUT=no -j$MAKE_PARALLEL
cd ..


if [[ $1 == portable ]]; then
	qmake pdf_viewer_build_config.pro
else
	qmake "CONFIG+=non_portable" pdf_viewer_build_config.pro
fi

make -j$MAKE_PARALLEL

rm -rf build 2> /dev/null
mkdir build
mv shioyek.app build/
cp -r pdf_viewer/shaders build/shioyek.app/Contents/Resources/shaders

cp pdf_viewer/prefs.config build/shioyek.app/Contents/Resources/prefs.config
cp pdf_viewer/prefs_user.config build/shioyek.app/Contents/Resources/prefs_user.config
cp pdf_viewer/keys.config build/shioyek.app/Contents/Resources/keys.config
cp pdf_viewer/keys_user.config build/shioyek.app/Contents/Resources/keys_user.config
cp tutorial.pdf build/shioyek.app/Contents/Resources/tutorial.pdf

# Give Finder-launched app a PATH that finds TeX/editors for synctex inverse search
INFO_PLIST="build/shioyek.app/Contents/Info.plist"
APP_PATH="/opt/homebrew/bin:/usr/local/bin:/Library/TeX/texbin:/usr/bin:/bin:/usr/sbin:/sbin"
/usr/libexec/PlistBuddy -c "Add :LSEnvironment dict" "$INFO_PLIST" || echo "LSEnvironment already exists"
/usr/libexec/PlistBuddy -c "Add :LSEnvironment:PATH string $APP_PATH" "$INFO_PLIST" || /usr/libexec/PlistBuddy -c "Set :LSEnvironment:PATH $APP_PATH" "$INFO_PLIST"

# Hack is required to avoid race condition in macos in CI
# See https://github.com/actions/runner-images/issues/7522
if [[ -n "$GITHUB_ACTIONS" ]]; then
  echo killing...; sudo pkill -9 XProtect >/dev/null || true;
  echo waiting...; while pgrep XProtect; do sleep 3; done;
fi

sleep 5

# mac deploys with qml currently don't work due to a qt bug
# macdeployqt build/shioyek.app -qmldir=./pdf_viewer/touchui -dmg
macdeployqt build/shioyek.app
codesign --force --deep --sign - build/shioyek.app
hdiutil create -volname Shioyek -srcfolder build/shioyek.app -ov -format UDZO "build/shioyek-mac-${SHIOYEK_ARCH:-$(uname -m)}.dmg"
