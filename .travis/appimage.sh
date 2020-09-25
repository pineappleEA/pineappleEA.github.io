#!/bin/bash -ex

BUILDBIN=/tmp/source/yuzu/build/bin
BINFILE=yuzu-x86_64.AppImage
LOG_FILE=$HOME/curl.log
BRANCH=$TRAVIS_BRANCH

# QT 5.14.2
# source /opt/qt514/bin/qt514-env.sh
QT_BASE_DIR=/opt/qt514
export QTDIR=$QT_BASE_DIR
export PATH=$QT_BASE_DIR/bin:$PATH
export LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

cd /tmp
	curl -sLO "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
	curl -sLO "https://github.com/$TRAVIS_REPO_SLUG/raw/$BRANCH/.travis/update.tar.gz"
	tar -xzf update.tar.gz
	chmod a+x linuxdeployqt*.AppImage
./linuxdeployqt-continuous-x86_64.AppImage --appimage-extract
cd $HOME
mkdir -p squashfs-root/usr/bin
cp -P "$BUILDBIN"/yuzu $HOME/squashfs-root/usr/bin/

curl -sL https://raw.githubusercontent.com/pineappleEA/Pineapple-Linux/master/yuzu.svg -o ./squashfs-root/yuzu.svg
curl -sL https://raw.githubusercontent.com/yuzu-emu/yuzu/master/dist/yuzu.desktop -o ./squashfs-root/yuzu.desktop
curl -sL https://github.com/AppImage/AppImageKit/releases/download/continuous/runtime-x86_64 -o ./squashfs-root/runtime
mkdir -p squashfs-root/usr/share/applications && cp ./squashfs-root/yuzu.desktop ./squashfs-root/usr/share/applications
mkdir -p squashfs-root/usr/share/icons && cp ./squashfs-root/yuzu.svg ./squashfs-root/usr/share/icons
mkdir -p squashfs-root/usr/share/icons/hicolor/scalable/apps && cp ./squashfs-root/yuzu.svg ./squashfs-root/usr/share/icons/hicolor/scalable/apps
mkdir -p squashfs-root/usr/share/pixmaps && cp ./squashfs-root/yuzu.svg ./squashfs-root/usr/share/pixmaps
curl -sL "https://raw.githubusercontent.com/pineappleEA/pineappleEA.github.io/$BRANCH/.travis/update.sh" -o $HOME/squashfs-root/update.sh
curl -sL "https://raw.githubusercontent.com/pineappleEA/pineappleEA.github.io/$BRANCH/.travis/AppRun" -o $HOME/squashfs-root/AppRun
chmod a+x ./squashfs-root/runtime
chmod a+x ./squashfs-root/AppRun
chmod a+x ./squashfs-root/update.sh
cp /tmp/update/libssl.so.47 /tmp/update/libcrypto.so.45 /usr/lib/x86_64-linux-gnu/

echo $TRAVIS_COMMIT > $HOME/squashfs-root/version.txt

unset QT_PLUGIN_PATH
unset LD_LIBRARY_PATH
unset QTDIR

# /tmp/squashfs-root/AppRun $HOME/squashfs-root/usr/bin/yuzu -appimage -unsupported-allow-new-glibc -no-copy-copyright-files -no-translations -bundle-non-qt-libs
/tmp/squashfs-root/AppRun $HOME/squashfs-root/usr/bin/yuzu -unsupported-allow-new-glibc -no-copy-copyright-files -no-translations -bundle-non-qt-libs
export PATH=$(readlink -f /tmp/squashfs-root/usr/bin/):$PATH
mv /tmp/update/AppImageUpdate $HOME/squashfs-root/usr/bin/
mv /tmp/update/* $HOME/squashfs-root/usr/lib/
/tmp/squashfs-root/usr/bin/appimagetool $HOME/squashfs-root -u "gh-releases-zsync|pineappleEA|pineappleEA.github.io|continuous|yuzu-x86_64.AppImage.zsync"

mkdir $HOME/artifacts/
mkdir -p /yuzu/artifacts/
mv yuzu-x86_64.AppImage* $HOME/artifacts
version=$(echo $title | cut -d " " -f 2) 
cp -R $HOME/artifacts/ /yuzu/
cp /yuzu/artifacts/yuzu-x86_64.AppImage /yuzu/artifacts/Yuzu-EA-$version.AppImage
cp "$BUILDBIN"/yuzu /yuzu/artifacts
chmod -R 777 /yuzu/artifacts
cd /yuzu/artifacts
ls -al /yuzu/artifacts/
#curl --upload-file yuzu-x86_64.AppImage https://transfersh.com/yuzu-x86_64.AppImage
