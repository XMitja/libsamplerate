
# Building libsamplerate for Android

The `android_scripts` directory contains scripts to build libsamplarate for Android.

## Requirements

* `Android NDK` ["developer.android.com/ndk"](https://developer.android.com/ndk/) Official Android Native Development Kit
* `FFTW3` [https://www.fftw.org/](https://www.fftw.org/) Optional: needed if `build_testing` is enabled
* `libsndfile` [https://github.com/scar20/libsndfile](https://github.com/scar20/libsndfile/tree/android_testing) :: Branch: `android_testing` Optional: needed if `build_testing` is enabled but you will need a full featured build of libsndfile for android for the test program to build.

To use the `build_testing` option, you have first to build libsndfile for Android and you need also FFTW3. Precompiled binaries of FFTW3 is available in the Release section of this site. Alternatively, you can build FFTW3 using the provided `build_fftw.sh` script. Otherwise you dont need FFTW3 and libsndfile at all.

## Building the Library without testing

1. Place libsamplerate source in a top-level directory.
2. Copy `android_scripts/build_libsamplerate.sh` to your top-level directory.
3. Set `ANDROID_NDK_HOME` and `api_min` in the script to match your setup.
4. Run `./build_libsamplerate.sh` from the top-level directory.

This builds by default a static libsamplerate library across four ABIs (Debug/Release). `build_<abi>` and `build_<abi>_d` directories will be created in the libsamplerate root, along with an `AndroidStudio` directory in the top-level directory containing headers and libraries organized for Android Studio.


## Building with testing enabled

Place the precompiled FFTW3 library or or its source along with the libsamplerate source, in a top-level directory having an already build libsndfile for Android. Ensure only one version of each library exists in this directory.

#### With precompiled FFTW3

1. Copy `android_scripts/build_libsamplerate.sh` to the top-level directory.
2. Set `ANDROID_NDK_HOME` and `api_min` in the script to match your setup.
3. Set `build_testing=ON` in the script. Optionally set `test_inline` as you wish.
4. Run `./build_libsamplerate.sh` from the top-level directory.

#### With FFTW3 source

Follow the same steps as with precompiled libraries, but build the FFTW3 libraries first:

1. Copy the files from `android_scripts/` to the top-level directory.
2. Set `ANDROID_NDK_HOME` and `api_min` in both `build_fftw.sh` and `build_libsamplerate.sh`.
3. Set `build_testing=ON` in `build_libsamplerate.sh` script. Optionally set `test_inline` as you wish.
4. Run `./build_fftw.sh` and then `./build_libsndfile.sh` from the top-level directory.

## User Configuration

#### User configurable mandatory or optional variables common to all scripts:
* `ANDROID_NDK_HOME` (mandatory): Your NDK root location (e.g., `"/path/to/android-ndk-<version>"`)
* `api_min` (mandatory): Minimum API level supported by the NDK (e.g., `"android-21"`)
* `abi_list`: Default is `("armeabi-v7a" "arm64-v8a" "x86" "x86_64")`

#### Variables exclusive to `build_libsamplerate.sh`:

* `config_list`: Default is `("Debug" "Release")`
* `shared_lib`: Build shared library when `ON`,
  build static library othervise. This option is `OFF` by default.
* `build_testing`: Will create archives to be uploaded and run on device if `ON`. This option is `OFF` by default. See [Building the testsuite](#building-the-testsuite) for details.
* `test_inline`: Will attempt to run the tests inline during the build. This option is `ON` by default - have no effect if `build_testing=OFF`. See [Building the testsuite](#building-the-testsuite) for details.
* `device_path`: Device path where the testsuite archive will be stored and run. Provided in case of future changes in Android architecture. Currently set to `"/data/local/tmp"`

### Building the testsuite

The `build_testing` option if enabled will produce two archives:

`libsamplerate-testsuite-<triplet>`: the formal 'testsuite' that perform unit tests to validate the library. 

`libsamplerate-benchmark-<triplet>`: a collection of programs performing benchmark tests.

Triplet used for each ABI:
- armeabi-v7a: armv7a-linux-androideabi
- arm64-v8a: aarch64-linux-android
- x86_64: x86_64-linux-android
- x86: i686-linux-android

Only the testsuite archive will be run inline on a device with `test_inline` enabled. The other is left at the disposal of the user.

The libsamplerate testsuite and benchmarks for Android must be installed on a device or emulator. The `test_inline` option runs the testsuite immediately if a device is found. The archives produced can be found in each ABI's build directory and the `AndroidStudio` directory. Use these commands to upload and run the on a device:

    adb push -p <archive_name>.tar.gz /data/local/tmp
    adb shell
    cd /data/local/tmp
    tar xvf <archive_name>.tar.gz
    cd <archive_name>
    sh ./test_wrapper.sh
    cd ..
    rm -r <archive_name>*
    exit

The command are similar for the benchmark archive but for the `sh ./test_wrapper.sh` command. Keep in mind that those programs are designed for a standard unix type of system as as such, can be difficult to use on a device with very limited shell capabilities.

Tests are build and performed only on release versions.