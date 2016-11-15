#!/bin/bash
set -o pipefail

# Using static libhts so a htslib upgrade in the conda environment
# doesn't suddenly break our binaries.
[ -f "${PREFIX}/lib/libhts.a" ] || \
    { echo "ERROR: Could not find static libhts!" >&2; exit 1; }

## Configure
build_arch=$(uname -m)
build_os=$(uname -s)

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CXXFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

if [ "${build_arch}" == "ppc64le" ]; then
    CXXFLAGS="${CXXFLAGS} -fsigned-char"
fi

if [ "${build_os}" == 'Darwin' ]; then
    # See meta.yaml for why we have to disable OpenMP on OS X
    USE_OPENMP=0

    MACOSX_VERSION_MIN="10.8"
    CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"

    # Make sure we use the same C++ standard library as boost
    CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
    LDFLAGS="${LDFLAGS} -stdlib=libc++"
elif [ "${build_os}" == 'Linux' ]; then
    USE_OPENMP=1
else
    echo "ERROR: Unsupported OS '$build_os'!" >&2
    exit 1
fi

# Make sure compiler and linker can find libhts
CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"


## Build
env CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" \
    make -j${BB_MAKE_JOBS} PARALLEL=${USE_OPENMP} \
    LIBHTS="-lhts -lcurl -lcrypto -lssl" \
    2>&1 | tee build.log


## Install
make install 2>&1 | tee install.log
