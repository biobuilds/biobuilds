#!/bin/bash
set -o pipefail

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CXXFLAGS="${CXXFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

# Platform-specific tweaks
if [ `uname -m` == 'ppc64le' ]; then
    CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include/veclib"

    # Force the ppc64le compiler to make the same assumptions about "plain"
    # char declarations (i.e., those w/o explicit sign) as the x86_64 compiler
    CXXFLAGS="${CXXFLAGS} -fsigned-char"
fi

# cmake builds have to be run outside the source directory
[ -d "build" ] || mkdir build
cd build

cmake -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET="10.8" \
    .. 2>&1 | tee configure.log
make -j${BB_MAKE_JOBS} VERBOSE=1

mkdir -p "${PREFIX}/bin"
install -m 755 diamond "${PREFIX}/bin"
