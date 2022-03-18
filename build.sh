#!/bin/bash

while getopts "a:c:" opt; do
  case $opt in
    a)
  ARCH=$OPTARG ;;
    c)
  FLAVOR=$OPTARG ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [[ -z "${ARCH}" ]] ; then
  echo 'You need to input arch with -a ARCH.'
  echo 'Supported archs are:'
  echo -e '\tarm arm64 mips mips64 x86 x86_64'
  exit 1
fi

source ./setup.sh

LOCAL_PATH=$($READLINK -f .)

if [ ! -d ffmpeg.git ]; then
  #git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg
  #git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg.git --bare --depth=1 -b n4.4.1
  git clone https://github.com/nova-video-player/FFmpeg ffmpeg.git --bare --depth=1 -b nova
  #FIXME: cannot do depth 1 to lock commit
  #git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg.git --bare
fi

FFMPEG_BARE_PATH=$($READLINK -f ffmpeg.git)
ANDROID_API=21

ARCH_CONFIG_OPT=

case "${ARCH}" in
  'arm')
    ARCH_TRIPLET='arm-linux-androideabi'
    CLANG_TRIPLET='armv7a-linux-androideabi'
    ABI='armeabi-v7a'
    ARCH_CFLAGS='-march=armv7-a -mfpu=neon -mfloat-abi=softfp -mthumb'
    ARCH_LDFLAGS='-march=armv7-a -Wl,--fix-cortex-a8' ;;
  'arm64')
    ARCH_TRIPLET='aarch64-linux-android'
    CLANG_TRIPLET=${ARCH_TRIPLET}
    ABI='arm64-v8a' ;;
  'x86')
    ARCH_TRIPLET='i686-linux-android'
    CLANG_TRIPLET=${ARCH_TRIPLET}
    ARCH_CONFIG_OPT='--disable-asm'
    ARCH_CFLAGS='-march=i686 -mtune=i686 -mssse3 -mfpmath=sse -m32'
    ABI='x86' ;;
  'x86_64')
    ARCH_TRIPLET='x86_64-linux-android'
    CLANG_TRIPLET=${ARCH_TRIPLET}
    ABI='x86_64'
    ARCH_CFLAGS='-march=x86-64 -msse4.2 -mpopcnt -m64 -mtune=x86-64' ;;
  *)
    echo "Arch ${ARCH} is not supported."
    exit 1 ;;
esac

FFMPEG_DIR="$(mktemp -d)"
#FFMPEG_DIR="$PWD/ffmpeg-$ABI"
mkdir -p $FFMPEG_DIR
git clone "${FFMPEG_BARE_PATH}" "${FFMPEG_DIR}"

#here we source a file that sets CONFIG_LIBAV string to the config we want
if [ -f "${FLAVOR}" ]; then
  . "${FLAVOR}"
  FLAVOR=$(echo "${FLAVOR}" | $SED -E 's/config_(.+)\.sh/\1/')
else
  FLAVOR='default'
  CONFIG_LIBAV=
fi

DAV1D_DIR=$($READLINK -f ../dav1d-android-builder)
DAV1D_LIB=${DAV1D_DIR}/build-${ABI}/src

OPUS_DIR=$($READLINK -f ../opus-android-builder)
OPUS_LIB=${OPUS_DIR}/lib/${ABI}

OPENSSL_DIR=$($READLINK -f ../openssl-android-builder)
OPENSSL_LIB=${OPENSSL_DIR}/dist-${ABI}/lib

echo "dav1d dir is at ${DAV1D_DIR}"
echo "libopus dir is at ${OPUS_DIR}"
echo "openssl dir is at ${OPENSSL_DIR}"

pushd "${FFMPEG_DIR}"

git clean -fdx
#git checkout 2e2b44baba575a33aa66796bc0a0f93070ab6c53
#git apply "${LOCAL_PATH}/config_opus.patch"
cat "${LOCAL_PATH}/config_opus.patch" | patch -p 1


OS=$(uname -s | tr '[:upper:]' '[:lower:]')
CROSS_DIR=$NDK_PATH/toolchains/llvm/prebuilt/${OS}-x86_64
CROSS_PREFIX="${CROSS_DIR}/bin/${ARCH_TRIPLET}"

mkdir -p "${FFMPEG_DIR}/dist-${FLAVOR}-${ABI}"

export PKG_CONFIG_LIBDIR=${LOCAL_PATH}

./configure --cross-prefix="${CROSS_PREFIX}-" \
            --cc="${CROSS_DIR}/bin/${CLANG_TRIPLET}${ANDROID_API}-clang" \
            --nm="${CROSS_DIR}/bin/llvm-nm" \
            --ar="${CROSS_DIR}/bin/llvm-ar" \
            --ranlib="${CROSS_DIR}/bin/llvm-ranlib" \
            --strip="${CROSS_DIR}/bin/llvm-strip" \
            --pkg-config=pkg-config \
            --yasmexe="${CROSS_DIR}/bin/yasm" \
            --sysroot="${CROSS_DIR}/sysroot" --sysinclude="${CROSS_DIR}/sysroot/usr/include" \
            --enable-cross-compile --target-os=android \
            --prefix="${FFMPEG_DIR}/dist-${FLAVOR}-${ABI}" \
            --arch="${ARCH}" ${ARCH_CONFIG_OPT} \
            --extra-cflags="${ARCH_CFLAGS} -fPIC -fPIE -DPIC -D__ANDROID_API__=${ANDROID_API} -I${DAV1D_DIR}/dav1d/include -I${DAV1D_DIR}/build-${ABI}/include -I${DAV1D_DIR}/build-${ABI}/include/dav1d  -I${OPUS_DIR}/opus/include -I${OPENSSL_DIR}/dist-${ABI}/include" \
            --extra-ldflags="${ARCH_LDFLAGS} -fPIE -pie -L${DAV1D_LIB} -L${OPUS_LIB} -L${OPENSSL_LIB}" \
            --enable-shared --disable-static --disable-symver --disable-doc \
            ${CONFIG_LIBAV} > "${FFMPEG_DIR}/dist-${FLAVOR}-${ABI}/configure.log"
make -j8 install

popd

cp -R "${FFMPEG_DIR}/dist-${FLAVOR}-${ABI}"  "${LOCAL_PATH}/"
rm -Rf "${FFMPEG_DIR}"

