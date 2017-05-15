#!/bin/bash
set -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment  configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Set (DY)LD_LIBRARY_PATH so ./configure works properly
if [ "$BUILD_OS" == "Darwin" ]; then
    export DYLD_LIBRARY_PATH="${PREFIX}/lib"
    # set this flag so clang treats C "inline" like gcc does
    CFLAGS="${CFLAGS} -std=gnu89"
else
    export LD_LIBRARY_PATH="${PREFIX}/lib"
fi

# Tell the compiler where to find POWER8 veclib headers
if [ "$BUILD_ARCH" == "ppc64le" ]; then
    [ -d "${PREFIX}/include/veclib" ] || \
        { echo "ERROR: could not find veclib headers" >&2; exit 1; }
    CPPFLAGS="-I${PREFIX}/include/veclib ${CPPFLAGS}"
    CFLAGS="-I${PREFIX}/include/veclib ${CFLAGS}"
    CXXFLAGS="-I${PREFIX}/include/veclib ${CXXFLAGS}"
fi

# Prevent undefined symbol errors by using older GNU C "inline" semantics
CFLAGS="${CFLAGS} -fgnu89-inline"

# Tweaks when building using Intel's C++ compiler
if [[ "${CXX}" == *"/bin/icpc" ]]; then
    # Set LD_LIBRARY_PATH so ./configure doesn't barf
    icc_root=$(cd `dirname "${CXX}"`/.. && pwd)
    export LD_LIBRARY_PATH="${icc_root}/lib/intel64_lin:$LD_LIBRARY_PATH"
fi

# Update autoconf files for ppc64le detection
cp -f "${PREFIX}/share/autoconf/config.guess" "config/config.guess"
cp -f "${PREFIX}/share/autoconf/config.sub" "config/config.sub"

env CC="${CC}" CFLAGS="${CFLAGS}" \
    CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    LD="${LD}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" \
    --disable-debug-functions --disable-perftools \
    --disable-intel64 --disable-32bit-support \
    --disable-tcmalloc \
    --disable-coloring \
    --enable-bz2 \
    --enable-adjacent-indels \
    2>&1 | tee configure.log


## Build
make -j${MAKE_JOBS} 2>&1 | tee build.log


## Install
make install
rm -rf "${PREFIX}/share/doc"

# Rename binary to prevent conflict with EMBOSS "tmap" application
mv "${PREFIX}/bin/tmap" "${PREFIX}/bin/tmap-ion"
