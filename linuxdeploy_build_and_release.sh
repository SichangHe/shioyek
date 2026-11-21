#!/usr/bin/env bash
set -e

if [ -z ${MAKE_PARALLEL+x} ]; then export MAKE_PARALLEL=$(nproc); else echo "MAKE_PARALLEL defined"; fi
echo "MAKE_PARALLEL set to $MAKE_PARALLEL"

# download linuxdeployqt if not exists
if [[ ! -f ./linuxdeploy-x86_64.AppImage ]]; then
    # the continuous version is not working for some reason
	# wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
	# wget https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage

    wget https://github.com/linuxdeploy/linuxdeploy/releases/download/1-alpha-20240109-1/linuxdeploy-x86_64.AppImage
    wget https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/1-alpha-20240109-1/linuxdeploy-plugin-qt-x86_64.AppImage

	chmod +x linuxdeploy-x86_64.AppImage
    chmod +x linuxdeploy-plugin-qt-x86_64.AppImage
fi

cd mupdf
make USE_SYSTEM_HARFBUZZ=yes -j$MAKE_PARALLEL
cd ..

if [ -z ${QMAKE+x} ]; then
    QMAKE=qmake
fi

if [[ $1 == console ]]; then
	$QMAKE "CONFIG+=linux_app_image console" pdf_viewer_build_config.pro
else
	$QMAKE "CONFIG+=linux_app_image" pdf_viewer_build_config.pro
fi

rm -rf shioyek-release 2> /dev/null
make install INSTALL_ROOT=shioyek-release -j$MAKE_PARALLEL

cp pdf_viewer/prefs.config shioyek-release/usr/bin/prefs.config
cp pdf_viewer/prefs_user.config shioyek-release/usr/share/prefs_user.config
cp pdf_viewer/keys.config shioyek-release/usr/bin/keys.config
cp pdf_viewer/keys_user.config shioyek-release/usr/share/keys_user.config
cp -r pdf_viewer/shaders shioyek-release/usr/bin/shaders
cp tutorial.pdf shioyek-release/usr/bin/tutorial.pdf

QML_SOURCES_PATHS=./pdf_viewer/touchui ./linuxdeploy-x86_64.AppImage --appdir shioyek-release --plugin qt --output appimage
mv Shioyek*.AppImage shioyek-linux-x86_64.AppImage
