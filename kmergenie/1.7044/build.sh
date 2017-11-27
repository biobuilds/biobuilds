#!/bin/bash

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v


## Configure
case "${BUILD_ARCH}" in
    "ppc64le")
        CFLAGS="${CFLAGS} -fsigned-char"
        CXXFLAGS="${CXXFLAGS} -fsigned-char"
        ;;
    "x86_64")
        ;;
esac

case "${BUILD_OS}" in
    "linux")
        ;;
    "darwin")
        ;;
esac

# Stop clang/llvm with -Werror from barfing on unimplemented gcc arguments
if [[ "$CC" == *clang ]]; then
    CFLAGS="${CFLAGS} -Wno-ignored-optimization-argument"
    CFLAGS="${CFLAGS} -Wno-unused-command-line-argument"
fi
if [[ "$CXX" == *clang++ ]]; then
    CXXFLAGS="${CXXFLAGS} -Wno-ignored-optimization-argument"
    CXXFLAGS="${CXXFLAGS} -Wno-unused-command-line-argument"
fi

export CPP CPPFLAGS CC CFLAGS CXX CXXFLAGS
export AR LD LDFLAGS


## Build

# corresponds to `make ntcard`
pushd ntCard
./configure --prefix="${PREFIX}" --enable-openmp
make -j${MAKE_JOBS} ${VERBOSE_AT}
popd

# corresponds to `make specialk`
progname=$(grep 'PROGNAME[[:space:]]*=' makefile | head -n1 | \
           awk -F'[ =]+' '{print $2;}')
make -j${MAKE_JOBS} ${VERBOSE_AT} $progname


## Install
"${PYTHON}" setup.py install
