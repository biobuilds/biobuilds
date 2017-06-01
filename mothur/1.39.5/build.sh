#!/bin/bash
set -e -x -o pipefail

## Configure
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

case "$BUILD_OS" in
    'darwin')
        MACOSX_VERSION_MIN="10.8"
        CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
        LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"

        # Make sure we use the same C++ standard library as boost
        CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
        LDFLAGS="${LDFLAGS} -stdlib=libc++"
        ;;
esac

# Default to using BioBuilds-provided Boost
BOOST_INC_DIR="${PREFIX}/include"
BOOST_LIB_DIR="${PREFIX}/lib"

# Additional tweaks for ICC
if [[ "$CXX" == *"/bin/icpc"* ]]; then
    # Help `icpc` find gcc's libstdc++ include files
    if [ -d "${PREFIX}/gcc" ]; then
        export GXX_INCLUDE="${PREFIX}/gcc/include"
        CXXFLAGS="${CXXFLAGS} -I${GXX_INCLUDE}/c++"
        CXXFLAGS="${CXXFLAGS} -I${GXX_INCLUDE}/c++/${BUILD_ARCH}-unknown-${BUILD_OS}-gnu"
    fi
fi

# Tweaks for Advance Toolchain
if [[ "$CXX" == "/opt/at"*"/bin/g++" ]]; then
    # Use AT-provided, rather than BioBuilds-provided, Boost
    AT_ROOT=$(cd `dirname $CXX`/.. && pwd)
    BOOST_INC_DIR="${AT_ROOT}/include"
    BOOST_LIB_DIR="${AT_ROOT}/lib64"
fi


## Build
rm -f source/makefile
env CC="$CC" CFLAGS="$CFLAGS" \
    CXX="$CXX" CXXFLAGS="$CXXFLAGS" \
    LDFLAGS="$LDFLAGS" \
    make -j${MAKE_JOBS} \
    PREFIX="${PREFIX}" \
    64BIT_VERSION=yes \
    OPTIMIZE=yes \
    USERREADLINE=yes \
    READLINE_LIBS="-lreadline -lncurses" \
    USEBOOST=yes \
    BOOST_INCLUDE_DIR="${PREFIX}/include" \
    BOOST_LIBRARY_DIR="${PREFIX}/lib" \
    2>&1 | tee build.log


## Install
install -m 0755 -d "${PREFIX}/bin"
install -m 0755 mothur uchime "${PREFIX}/bin"
