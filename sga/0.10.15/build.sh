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

# Architecture-specific tweaks
case "${BUILD_ARCH}" in
    "ppc64le")
        CFLAGS="${CFLAGS} -fsigned-char"
        CXXFLAGS="${CXXFLAGS} -fsigned-char"
        ;;
esac

# OS-specific tweaks

# Compiler-/toolchain-specific tweaks
case "${CXX}" in
    */bin/icpc)
        CXXFLAGS="${CXXFLAGS} -gcc-name=${CONDA_CC}"
        CXXFLAGS="${CXXFLAGS} -gxx-name=${CONDA_CXX}"

        # bamtools was built with a pre-C++11 API, so be sure to tell the
        # compiler that, or we'll get a bunch of std::-related link failures.
        CXXFLAGS="${CXXFLAGS} -D_GLIBCXX_USE_CXX11_ABI=0"
        ;;
    *g++ | *c++)
        # bamtools was built with a pre-C++11 API, so be sure to tell the
        # compiler that, or we'll get a bunch of std::-related link failures.
        CXXFLAGS="${CXXFLAGS} -D_GLIBCXX_USE_CXX11_ABI=0"
        ;;
    *clang++)
        ;;
esac

export CC CFLAGS
export CXX CXXFLAGS CPPFLAGS="${CXXFLAGS}"
export AR LD LDFLAGS

cd src
./autogen.sh
./configure --prefix="${PREFIX}" \
    --with-sparsehash="${PREFIX}" \
    --with-bamtools="${PREFIX}" \
    --with-jemalloc="${PREFIX}" \
    --without-tcmalloc \
    --without-hoard \
    2>&1 | tee configure.log


## Build
make -j${MAKE_JOBS} ${VERBOSE_AT} \
    LD="${LD}" AR="${AR}"


## Install
make install
