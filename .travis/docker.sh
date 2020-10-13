#!/bin/bash -ex

BRANCH=$TRAVIS_BRANCH

curl -s https://raw.githubusercontent.com/pineappleEA/pineappleEA.github.io/master/index.html > sourcefile.txt
latest=$(cat sourcefile.txt | grep https://anonfiles.com/ | head -n 1)
id=$(echo $latest | cut -d '!' -f 2 | cut -d '-' -f 3)
export title=$(echo $latest | cut -d '>' -f 2 | cut -d '<' -f 1 |grep -Eo '[0-9]{1,4}')

QT_BASE_DIR=/opt/qt514
export QTDIR=$QT_BASE_DIR
export PATH=$QT_BASE_DIR/bin:$PATH
export LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

ln -s /home/yuzu/.conan /root
mkdir -p /tmp/source/
cd /tmp/source
#aria2c $(curl $latest | grep -o 'https://cdn-.*.7z' | head -n 1)
filename="YuzuEA-$title.7z"
curl -c ./cookie -s -L "https://drive.google.com/uc?export=download&id=${id}" > /dev/null
curl -Lb ./cookie -C - "https://drive.google.com/uc?export=download&confirm=`awk '/download/ {print $NF}' ./cookie`&id=${id}" -o ${filename}
7z x Yuzu* yuzu-windows-msvc-early-access/yuzu-windows-msvc-source-*
cd yuzu-windows-msvc-early-access
msvc=$(grep yuzu-windows-msvc-source | cut -d '-' -f 5 | cut -d '.' -f 1 )
tar -xf yuzu-windows-msvc-source-* --directory /tmp/source
cd /tmp/source
mv yuzu-windows-msvc-source-* yuzu/

cd /tmp/source/yuzu/

find -path ./dist -prune -o -type f -exec sed -i 's/\r$//' {} ';'
wget https://raw.githubusercontent.com/PineappleEA/Pineapple-Linux/master/inject-git-info.patch
patch -p1 < inject-git-info.patch
mkdir -p build && cd build

#curl -sL "https://raw.githubusercontent.com/yuzu-emu/yuzu/master/src/web_service/web_backend.cpp" -o /tmp/source/yuzu/src/web_service/web_backend.cpp
#curl -sL "https://raw.githubusercontent.com/yuzu-emu/yuzu/master/src/input_common/sdl/sdl_impl.cpp" -o /tmp/source/yuzu/src/input_common/sdl/sdl_impl.cpp

cmake .. -G Ninja -DYUZU_USE_BUNDLED_UNICORN=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=/usr/lib/ccache/gcc -DCMAKE_CXX_COMPILER=/usr/lib/ccache/g++ -DTITLE_BAR_FORMAT_IDLE="yuzu Early Access $title" -DTITLE_BAR_FORMAT_RUNNING="yuzu Early Access $title | {3}" -DENABLE_COMPATIBILITY_LIST_DOWNLOAD=ON -DGIT_BRANCH="HEAD" -DGIT_DESC="$msvc" -DUSE_DISCORD_PRESENCE=ON

ninja -j $(nproc)

#cat yuzu/build/CMakeFiles/CMakeError.log | curl -F 'f:1=<-' ix.io

cd /tmp
curl -sLO "https://raw.githubusercontent.com/$TRAVIS_REPO_SLUG/$BRANCH/.travis/appimage.sh"
chmod a+x appimage.sh
./appimage.sh
