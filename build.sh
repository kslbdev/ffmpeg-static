#!/bin/sh

set -e
set -u

jflag=
jval=2
rebuild=0
download_only=0
uname -mpi | grep -qE 'x86|i386|i686' && is_x86=1 || is_x86=0

while getopts 'j:Bd' OPTION
do
  case $OPTION in
  j)
      jflag=1
      jval="$OPTARG"
      ;;
  B)
      rebuild=1
      ;;
  d)
      download_only=1
      ;;
  ?)
      printf "Usage: %s: [-j concurrency_level] (hint: your cores + 20%%) [-B] [-d]\n" $(basename $0) >&2
      exit 2
      ;;
  esac
done
shift $(($OPTIND - 1))

if [ "$jflag" ]
then
  if [ "$jval" ]
  then
    printf "Option -j specified (%d)\n" $jval
  fi
fi

[ "$rebuild" -eq 1 ] && echo "Reconfiguring existing packages..."
[ $is_x86 -ne 1 ] && echo "Not using yasm or nasm on non-x86 platform..."

cd `dirname $0`
ENV_ROOT=`pwd`
. ./env.source

# check operating system
OS=`uname`
platform="unknown"

case $OS in
  'Darwin')
    platform='darwin'
    ;;
  'Linux')
    platform='linux'
    ;;
esac

#if you want a rebuild
#rm -rf "$BUILD_DIR" "$TARGET_DIR"
mkdir -p "$BUILD_DIR" "$TARGET_DIR" "$DOWNLOAD_DIR" "$BIN_DIR"

#download and extract package
download(){
  filename="$1"
  if [ ! -z "$2" ];then
    filename="$2"
  fi
  ../download.pl "$DOWNLOAD_DIR" "$1" "$filename" "$3" "$4"
  #disable uncompress
  REPLACE="$rebuild" CACHE_DIR="$DOWNLOAD_DIR" ../fetchurl "http://cache/$filename"
}

echo "#### FFmpeg static build ####"

#this is our working directory
cd $BUILD_DIR

[ $is_x86 -eq 1 ] && download \
  "yasm-1.3.0.tar.gz" \
  "" \
  "fc9e586751ff789b34b1f21d572d96af" \
  "http://www.tortall.net/projects/yasm/releases/"

[ $is_x86 -eq 1 ] && download \
  "nasm-2.15.05.tar.bz2" \
  "" \
  "b8985eddf3a6b08fc246c14f5889147c" \
  "https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/"

download \
  "OpenSSL_1_0_2o.tar.gz" \
  "" \
  "5b5c050f83feaa0c784070637fac3af4" \
  "https://github.com/openssl/openssl/archive/"

download \
  "v1.2.11.tar.gz" \
  "zlib-1.2.11.tar.gz" \
  "0095d2d2d1f3442ce1318336637b695f" \
  "https://github.com/madler/zlib/archive/"

download \
  "v1.5.3.tar.gz" \
  "" \
  "df8213a3669dd846ddaad0fa1e9f417b" \
  "https://github.com/Haivision/srt/archive/refs/tags/"

download \
  "v0.1.6.tar.gz" \
  "fdk-aac.tar.gz" \
  "223d5f579d29fb0d019a775da4e0e061" \
  "https://github.com/mstorsjo/fdk-aac/archive"

# libass dependency
download \
  "harfbuzz-2.6.7.tar.xz" \
  "" \
  "3b884586a09328c5fae76d8c200b0e1c" \
  "https://www.freedesktop.org/software/harfbuzz/release/"

download \
  "fribidi-1.0.2.tar.bz2" \
  "" \
  "bd2eb2f3a01ba11a541153f505005a7b" \
  "https://github.com/fribidi/fribidi/releases/download/v1.0.2/"

download \
  "libass-0.17.0.tar.xz" \
  "" \
  "25f7435779aa28eb7dbd3f76f4d17d15" \
  "https://github.com/libass/libass/releases/download/0.17.0/"

download \
  "lame-3.99.5.tar.gz" \
  "" \
  "84835b313d4a8b68f5349816d33e07ce" \
  "http://downloads.sourceforge.net/project/lame/lame/3.99"

download \
  "opus-1.1.2.tar.gz" \
  "" \
  "1f08a661bc72930187893a07f3741a91" \
  "https://github.com/xiph/opus/releases/download/v1.1.2"

download \
  "v1.14.0.tar.gz" \
  "vpx-1.14.0.tar.gz" \
  "026bc289d916624dabdfd713c1c5b69a" \
  "https://github.com/webmproject/libvpx/archive"

download \
  "rtmpdump-2.3.tgz" \
  "" \
  "eb961f31cd55f0acf5aad1a7b900ef59" \
  "https://rtmpdump.mplayerhq.hu/download/"

download \
  "soxr-0.1.2-Source.tar.xz" \
  "" \
  "0866fc4320e26f47152798ac000de1c0" \
  "https://sourceforge.net/projects/soxr/files/"

download \
  "release-0.98b.tar.gz" \
  "vid.stab-release-0.98b.tar.gz" \
  "299b2f4ccd1b94c274f6d94ed4f1c5b8" \
  "https://github.com/georgmartius/vid.stab/archive/"

download \
  "release-2.7.4.tar.gz" \
  "zimg-release-2.7.4.tar.gz" \
  "1757dcc11590ef3b5a56c701fd286345" \
  "https://github.com/sekrit-twc/zimg/archive/"

download \
  "v2.1.2.tar.gz" \
  "openjpeg-2.1.2.tar.gz" \
  "40a7bfdcc66280b3c1402a0eb1a27624" \
  "https://github.com/uclouvain/openjpeg/archive/"

download \
  "v1.4.0.tar.gz" \
  "libwebp-1.4.0.tar.gz" \
  "9778f9be63f04f16f9ca3a4f36503399" \
  "https://github.com/webmproject/libwebp/archive/"

download \
  "v1.3.6.tar.gz" \
  "vorbis-1.3.6.tar.gz" \
  "03e967efb961f65a313459c5d0f4cbfb" \
  "https://github.com/xiph/vorbis/archive/"

download \
  "v1.3.3.tar.gz" \
  "ogg-1.3.3.tar.gz" \
  "b8da1fe5ed84964834d40855ba7b93c2" \
  "https://github.com/xiph/ogg/archive/"

download \
  "Speex-1.2.0.tar.gz" \
  "Speex-1.2.0.tar.gz" \
  "4bec86331abef56129f9d1c994823f03" \
  "https://github.com/xiph/speex/archive/"

download \
  "n6.0.tar.gz" \
  "ffmpeg6.0.tar.gz" \
  "586ca7cc091d26fd0a4c26308950ca51" \
  "https://github.com/FFmpeg/FFmpeg/archive"

download \
  "SDL2-2.0.22.tar.gz" \
  "SDL2-2.0.22.tar.gz" \
  "40aedb499cb2b6f106d909d9d97f869a" \
  "https://github.com/libsdl-org/SDL/releases/download/release-2.0.22"

download \
  "freetype-2.13.0.tar.gz" \
  "" \
  "98bc3cf234fe88ef3cf24569251fe0a4" \
  "https://download.savannah.gnu.org/releases/freetype/"


download \
  "fontconfig-2.14.2.tar.gz" \
  "" \
  "c5536d897c5d52422a00ecee742ccf47" \
  "https://www.freedesktop.org/software/fontconfig/release/"

download \
  "glib-2.80.1.tar.xz" \
  "" \
  "a136e66c287b4eb1bf10accb03477b6f" \
  "https://download.gnome.org/sources/glib/2.80/"

download \
  "pcre2-10.43.tar.bz2" \
  "" \
  "c8e2043cbc4abb80e76dba323f7c409f" \
  "https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.43/"

download \
  "v1.1.0.tar.gz" \
  "brotli-v1.1.0.tar.gz" \
  "6a3dba82a3604792d3cb0bd41bca60" \
  "https://github.com/google/brotli/archive/refs/tags/"

download \
  "expat-2.6.2.tar.gz" \
  "" \
  "6a3dba82a3604792d3cb0bd41bca60" \
  "https://github.com/libexpat/libexpat/releases/download/R_2_6_2/"

download \
  "bzip2-1.0.8.tar.gz" \
  "" \
  "6a3dba82a3604792d3cb0bd41bca60" \
  "https://sourceware.org/pub/bzip2/"

download \
  "libpng-1.6.43.tar.gz" \
  "" \
  "6a3dba82a3604792d3cb0bd41bca60" \
  "https://sourceforge.net/projects/libpng/files/libpng16/1.6.43/"

download \
  "libtheora-1.1.1.tar.xz" \
  "" \
  "" \
  "https://downloads.xiph.org/releases/theora/"

[ $download_only -eq 1 ] && exit 0

TARGET_DIR_SED=$(echo $TARGET_DIR | awk '{gsub(/\//, "\\/"); print}')

if [ $is_x86 -eq 1 ]; then
    echo "*** Building yasm ***"
    cd $BUILD_DIR/yasm*
    [ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
    [ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --bindir=$BIN_DIR
    make -j $jval
    make install
fi

if [ $is_x86 -eq 1 ]; then
    echo "*** Building nasm ***"
    cd $BUILD_DIR/nasm*
    [ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
    [ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --bindir=$BIN_DIR
    make -j $jval
    make install
fi

echo "*** Building OpenSSL ***"
cd $BUILD_DIR/openssl*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "darwin" ]; then
  PATH="$BIN_DIR:$PATH" ./Configure darwin64-x86_64-cc --prefix=$TARGET_DIR
elif [ "$platform" = "linux" ]; then
  PATH="$BIN_DIR:$PATH" ./config --prefix=$TARGET_DIR
fi
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo "*** Building zlib ***"
cd $BUILD_DIR/zlib*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "linux" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR
elif [ "$platform" = "darwin" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR
fi
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo "*** Building fdk-aac ***"
cd $BUILD_DIR/fdk-aac*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
autoreconf -fiv
[ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building harfbuzz ***"
cd $BUILD_DIR/harfbuzz-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./configure --prefix=$TARGET_DIR --disable-shared --enable-static
make -j $jval
make install

echo "*** Building fribidi ***"
cd $BUILD_DIR/fribidi-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./configure --prefix=$TARGET_DIR --disable-shared --enable-static --disable-docs
make -j $jval
make install

echo "*** Building libass ***"
cd $BUILD_DIR/libass-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building mp3lame ***"
cd $BUILD_DIR/lame*
# The lame build script does not recognize aarch64, so need to set it manually
uname -a | grep -q 'aarch64' && lame_build_target="--build=arm-linux" || lame_build_target=''
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --enable-nasm --disable-shared $lame_build_target
make
make install

echo "*** Building opus ***"
cd $BUILD_DIR/opus*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --disable-shared
make
make install

echo "*** Building libvpx ***"
cd $BUILD_DIR/libvpx*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --disable-examples --disable-unit-tests --enable-pic
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo "*** Building librtmp ***"
cd $BUILD_DIR/rtmpdump-*
cd librtmp
[ $rebuild -eq 1 ] && make distclean || true

# there's no configure, we have to edit Makefile directly
if [ "$platform" = "linux" ]; then
  sed -i "/INC=.*/d" ./Makefile # Remove INC if present from previous run.
  sed -i "s/prefix=.*/prefix=${TARGET_DIR_SED}\nINC=-I\$(prefix)\/include/" ./Makefile
  sed -i "s/SHARED=.*/SHARED=no/" ./Makefile
elif [ "$platform" = "darwin" ]; then
  sed -i "s/prefix=./prefix=${TARGET_DIR_SED}/" ./Makefile
fi
make install_base

echo "*** Building libsoxr ***"
cd $BUILD_DIR/soxr-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
PATH="$BIN_DIR:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DBUILD_SHARED_LIBS:bool=off -DWITH_OPENMP:bool=off -DBUILD_TESTS:bool=off
make -j $jval
make install

echo "*** Building openjpeg ***"
cd $BUILD_DIR/openjpeg-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
PATH="$BIN_DIR:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DBUILD_SHARED_LIBS:bool=off
make -j $jval
make install

echo "*** Building zimg ***"
cd $BUILD_DIR/zimg-release-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --enable-static  --prefix=$TARGET_DIR --disable-shared
sed -i 's/size_t/std::size_t/g' src/zimg/colorspace/matrix3.cpp
make -j $jval
make install

echo "*** Building libwebp ***"
cd $BUILD_DIR/libwebp*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building libvorbis ***"
cd $BUILD_DIR/vorbis*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building libogg ***"
cd $BUILD_DIR/ogg*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building libspeex ***"
cd $BUILD_DIR/speex*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building libsdl ***"
cd $BUILD_DIR/SDL*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building RIST ***"
cd $BUILD_DIR
rm -rf librist
git clone https://code.videolan.org/rist/librist.git
cd $BUILD_DIR/librist*
git checkout v0.2.10
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
mkdir -p build
cd build
meson --default-library=static .. --prefix=$TARGET_DIR --bindir="../bin/" --libdir="$TARGET_DIR/lib"
ninja
ninja install

echo "*** Building SRT ***"
cd $BUILD_DIR/srt*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
mkdir -p build
cd build
cmake -DENABLE_APPS=OFF -DCMAKE_INSTALL_PREFIX=$TARGET_DIR -DENABLE_C_DEPS=ON -DENABLE_SHARED=OFF -DENABLE_STATIC=ON -DOPENSSL_USE_STATIC_LIBS=ON ..
sed -i 's/-lgcc_s/-lgcc_eh/g' haisrt.pc
sed -i 's/-lgcc_s/-lgcc_eh/g' srt.pc
make
make install

echo "*** Building FreeType ***"
cd $BUILD_DIR/freetype*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared
make
make install

echo "*** Building fontconfig ***"
cd $BUILD_DIR/fontconfig*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./configure --prefix=$TARGET_DIR --disable-shared
make
make install

echo "*** Building PCRE2 ***"
cd $BUILD_DIR/pcre2*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./configure --prefix=$TARGET_DIR --disable-shared
make
make install

echo "*** Building brotli ***"
cd $BUILD_DIR/brotli*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
mkdir -p build
cd build
cmake -DENABLE_APPS=OFF -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DBUILD_SHARED_LIBS:bool=off ..
make
make install

echo "*** Building libexpat ***"
cd $BUILD_DIR/expat*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building bzip2 ***"
cd $BUILD_DIR/bzip2*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
make
make install PREFIX="$TARGET_DIR"

echo "*** Building libpng ***"
cd $BUILD_DIR/libpng*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building libtheora ***"
cd $BUILD_DIR/libtheora*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
sed -i 's/png_sizeof/sizeof/g' examples/png2theora.c
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

# FFMpeg
echo "*** Building FFmpeg ***"

cd $BUILD_DIR/FFmpeg*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true

[ ! -f config.status ] && PATH="$BIN_DIR:$PATH" \
  PKG_CONFIG_PATH="$TARGET_DIR/lib/pkgconfig:$TARGET_DIR/lib64/pkgconfig" ./configure \
  --prefix="$TARGET_DIR" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$TARGET_DIR/include" \
  --extra-ldflags="-L$TARGET_DIR/lib -L$TARGET_DIR/lib64 -L/usr/lib/gcc/x86_64-amazon-linux/11/" \
  --extra-libs="-lpthread -lm -lz" \
  --extra-ldexeflags="-static" \
  --bindir="$BIN_DIR" \
  --enable-pic \
  --enable-ffplay \
  --enable-fontconfig \
  --enable-libass \
  --enable-libfribidi \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopenjpeg \
  --enable-libopus \
  --enable-librtmp \
  --enable-libsoxr \
  --enable-libspeex \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libwebp \
  --enable-libzimg \
  --enable-openssl \
  --enable-librist

PATH="$BIN_DIR:$PATH" make -j $jval
make install
make distclean
hash -r
