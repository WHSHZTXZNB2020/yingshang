#!/bin/bash

set -e -o pipefail

ANDROID_ABI=$1

# Build RustDesk dependencies for Android using vcpkg.json
# Required:
#   1. set VCPKG_ROOT / ANDROID_NDK path environment variables
#   2. vcpkg initialized
#   3. ndk, version: r25c or newer

if [ -z "$ANDROID_NDK_HOME" ]; then
  echo "Failed! Please set ANDROID_NDK_HOME"
  exit 1
fi

if [ -z "$VCPKG_ROOT" ]; then
  echo "Failed! Please set VCPKG_ROOT"
  exit 1
fi

API_LEVEL="21"

# Get directory of this script

SCRIPTDIR="$(readlink -f "$0")"
SCRIPTDIR="$(dirname "$SCRIPTDIR")"

# Check if vcpkg.json is one level up - in root directory of RD

if [ ! -f "$SCRIPTDIR/../vcpkg.json" ]; then
  echo "Failed! Please check where vcpkg.json is!"
  exit 1
fi

# NDK llvm toolchain

HOST_TAG="linux-x86_64" # current platform, set as `ls $ANDROID_NDK/toolchains/llvm/prebuilt/`
TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/$HOST_TAG

function build {
  ANDROID_ABI=$1

  case "$ANDROID_ABI" in
  arm64-v8a)
     ABI=aarch64-linux-android$API_LEVEL
     VCPKG_TARGET=arm64-android
     ;;
  armeabi-v7a)
     ABI=armv7a-linux-androideabi$API_LEVEL
     VCPKG_TARGET=arm-neon-android
     ;;
  x86_64)
     ABI=x86_64-linux-android$API_LEVEL
     VCPKG_TARGET=x64-android
     ;;
  x86)
     ABI=i686-linux-android$API_LEVEL
     VCPKG_TARGET=x86-android
     ;;
  *)
     echo "ERROR: ANDROID_ABI must be one of: arm64-v8a, armeabi-v7a, x86_64, x86" >&2
     return 1
  esac

  echo "*** [$ANDROID_ABI][Start] Build and install vcpkg dependencies"
  pushd "$SCRIPTDIR/.."
  # 清理可能影响vcpkg行为的环境变量
  unset VCPKG_FEATURE_FLAGS || true
  # 设置环境变量来控制CMake行为
  export VCPKG_CMAKE_CONFIGURE_OPTIONS="-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  export CMAKE_POLICY_VERSION_MINIMUM=3.5
  # 创建临时CMake工具链文件
  TMP_CMAKE_TOOLCHAIN_FILE=$(mktemp)
  echo "set(CMAKE_POLICY_VERSION 3.5)" > $TMP_CMAKE_TOOLCHAIN_FILE
  if [ -f "$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake" ]; then
    echo "include(\"$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake\")" >> $TMP_CMAKE_TOOLCHAIN_FILE
  fi
  # 使用classic模式，明确指定要安装的包
  $VCPKG_ROOT/vcpkg install --triplet $VCPKG_TARGET \
    libjpeg-turbo opus libvpx libyuv \
    --x-cmake-args="-DCMAKE_POLICY_VERSION_MINIMUM=3.5" \
    --classic
  # 如果是Android平台，还需要安装这些包
  if [[ "$VCPKG_TARGET" == *"-android" ]]; then
    # 安装cpu-features
    $VCPKG_ROOT/vcpkg install --triplet $VCPKG_TARGET \
      cpu-features \
      --x-cmake-args="-DCMAKE_POLICY_VERSION_MINIMUM=3.5" \
      --classic
    
    # 只有在SKIP_OBOE不为true时才安装oboe
    if [[ "$SKIP_OBOE" != "true" ]]; then
      echo "Installing oboe library..."
      $VCPKG_ROOT/vcpkg install --triplet $VCPKG_TARGET \
        oboe \
        --x-cmake-args="-DCMAKE_POLICY_VERSION_MINIMUM=3.5;-DCMAKE_TOOLCHAIN_FILE=$TMP_CMAKE_TOOLCHAIN_FILE" \
        --classic
    else
      echo "Skipping oboe library installation as SKIP_OBOE is set."
    fi
  fi
  # 清理临时文件
  rm -f $TMP_CMAKE_TOOLCHAIN_FILE
  popd
  head -n 100 "${VCPKG_ROOT}/buildtrees/ffmpeg/build-$VCPKG_TARGET-rel-out.log" || true
  echo "*** [$ANDROID_ABI][Finished] Build and install vcpkg dependencies"

if [ -d "$VCPKG_ROOT/installed/arm-neon-android" ]; then
  echo "*** [Start] Move arm-neon-android to arm-android"

  mv "$VCPKG_ROOT/installed/arm-neon-android" "$VCPKG_ROOT/installed/arm-android"

  echo "*** [Finished] Move arm-neon-android to arm-android"
fi
}

if [ ! -z "$ANDROID_ABI" ]; then
  build "$ANDROID_ABI"
else
  echo "Usage: build-android-deps.sh <ANDROID-ABI>" >&2
  exit 1
fi
