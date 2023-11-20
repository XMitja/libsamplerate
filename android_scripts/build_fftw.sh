#!/bin/bash

# This script will build fftw for Android using the NDK

# Ensure all library sources are within a top-level directory.
# Place and run this script from within that top-level directory.
# It will generate build directories for each ABI/configuration in fftw subdirectory.


# ------- User configuration ------- #

# set to your NDK root location : "path/to/android-ndk-<your_version_number>"
ANDROID_NDK_HOME=""

# Minimum API level supported by the NDK - adjust according to your project min sdk
# ex: API_MIN="android-21"
api_min=""

# Lists of ABIs 
# Adjust as needed from those values:
# abi_list=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")
abi_list=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")

# ------- End of user configuration ------- #

# Check if ANDROID_NDK_HOME and api_min are set
if [ -z "$ANDROID_NDK_HOME" ]; then
	echo "Error: ANDROID_NDK_ROOT must be set"
	exit 1
elif [ -z "$api_min" ]; then
	echo "Error: api_min must be set"
	exit 1
fi

# Setting up environment
export ANDROID_NDK_HOME=${ANDROID_NDK_HOME}

# We should be in the top-level dir where all the libraries are located
ROOT_LOC=$(pwd)

# Set lib root locations
fftw_root=$(echo ${ROOT_LOC}/fftw*)

# Navigate to fftw source directory
cd "${fftw_root}" || exit


# Set build directory
BUILD_DIR=""


# Additional variables

# Set NDK and HOST_TAG variables
export NDK=$ANDROID_NDK_HOME
export HOST_TAG=linux-x86_64
export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/$HOST_TAG
SYSROOT=$NDK/toolchains/llvm/prebuilt/linux-x86_64/sysroot

# Set API to minSdkVersion from numerial value of api_min
export API=$(echo $api_min | grep -o '[0-9]*')


set -e

ARM32_SPECIFIC="--enable-neon --enable-armv7a-pmccntr"
ARM64_SPECIFIC="--enable-neon --enable-armv8-pmccntr-el0"
X86_SPECIFIC="--enable-sse2 --enable-avx2"
X86_64_SPECIFIC="--enable-sse2 --enable-avx2"

# Create a build directory for each ABI and configuration
for abi in "${abi_list[@]}"; do

    # Set TARGET and CPU_SPECIFIC according to ABI
    if [ "$abi" = "armeabi-v7a" ]; then
        TARGET=armv7a-linux-androideabi
        CPU_SPECIFIC=$ARM32_SPECIFIC
    elif [ "$abi" = "arm64-v8a" ]; then
        TARGET=aarch64-linux-android
        CPU_SPECIFIC=$ARM64_SPECIFIC
    elif [ "$abi" = "x86" ]; then
        TARGET=i686-linux-android
        CPU_SPECIFIC=$X86_SPECIFIC
    elif [ "$abi" = "x86_64" ]; then
        TARGET=x86_64-linux-android
        CPU_SPECIFIC=$X86_64_SPECIFIC
    fi

    # Configure options
    CONFIG_OPTIONS="--host=$TARGET \
    --disable-shared \
    --disable-doc \
    --disable-fortran \
    --with-pic \
    --with-sysroot=$SYSROOT"
        
    # Set build directory name       
    BUILD_DIR=$(pwd)/build_${abi}
    CURRENT_CONFIG_OPTIONS="$CONFIG_OPTIONS $CPU_SPECIFIC --prefix=$BUILD_DIR"
    
    # Configure and build
    export AR=$TOOLCHAIN/bin/llvm-ar
    export CC="$TOOLCHAIN/bin/$TARGET$API-clang"
    export AS=$CC
    export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
    export LD=$TOOLCHAIN/bin/ld
    export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
    export STRIP=$TOOLCHAIN/bin/llvm-strip

    # Create build directory
    mkdir -p $BUILD_DIR

    if [ -f Makefile ]; then
        make distclean
    fi


    # Run the configure script and make, and save output to a log file
    ./configure $CURRENT_CONFIG_OPTIONS 2>&1 | tee -a "$BUILD_DIR/configure_and_make_$abi.log"
    make 2>&1 | tee -a "$BUILD_DIR/configure_and_make_$abi.log"
    make install 2>&1 | tee -a "$BUILD_DIR/configure_and_make_$abi.log"
                
done



