#!/bin/bash
set -o pipefail

## Configure

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

if [ "${BUILD_ARCH}" == "ppc64le" ]; then
    CXXFLAGS="${CXXFLAGS} -fsigned-char"
fi

if [ "${BUILD_OS}" == 'darwin' ]; then
    USE_OPENMP=1

    MACOSX_VERSION_MIN="10.8"
    CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"

    # Make sure we use the same C++ standard library as boost
    CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
    LDFLAGS="${LDFLAGS} -stdlib=libc++"
elif [ "${BUILD_OS}" == 'linux' ]; then
    USE_OPENMP=1
else
    echo "ERROR: Unsupported OS '$build_os'!" >&2
    exit 1
fi

# Make sure compiler and linker can find libhts
CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Make sure g++ knows that our Boost libraries were built with a pre-C++11 ABI.
#
# NOTE: we don't have a conditional here to check for g++ because conda's
# linux-64 C++ compiler package sets $CXX to the binary named "*-c++", and we
# don't want to put the additional effort into determining if said "c++" binary
# is _really_ the GNU compiler.
CXXFLAGS="${CXXFLAGS} -D_GLIBCXX_USE_CXX11_ABI=0"


## Build
env CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    LD="${LD}" LDFLAGS="${LDFLAGS}" \
    make -j${MAKE_JOBS} PARALLEL=${USE_OPENMP} \
    LIBHTS="-lhts -lcurl -lcrypto -lssl" \
    2>&1 | tee build.log


## Install
make install 2>&1 | tee install.log
