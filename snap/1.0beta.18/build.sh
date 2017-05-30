#!/bin/bash
set -e -x -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Use older language standard so newer versions of GCC don't get cranky.
CXX="${CXX} -std=gnu++98"

CXXFLAGS="${CXXFLAGS} -fsigned-char"

# Architecture-specific options
case "$BUILD_ARCH" in
    'ppc64le')
        # Should be provided by the "veclib-headers" package
        [ -d "${PREFIX}/include/veclib" ] || \
            { echo "ERROR: could not find veclib headers" >&2; exit 1; }
        CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include/veclib"
        ;;
esac

# Set (DY)LD_LIBRARY_PATH so ./unit_tests works properly
if [[ "$BUILD_OS" == 'darwin' ]]; then
    export DYLD_LIBRARY_PATH="${PREFIX}/lib"
else
    export LD_LIBRARY_PATH="${PREFIX}/lib"
fi

# Tweaks when building using Intel's C++ compiler
if [[ "${CXX}" == *"/bin/icpc"* ]]; then
    # Set LD_LIBRARY_PATH so ./unit_tests doesn't barf
    icc_root=$(cd `dirname "${CXX}"`/.. && pwd)
    export LD_LIBRARY_PATH="${icc_root}/lib/intel64:$LD_LIBRARY_PATH"
fi

# Stop the Makefile from adding "-msse" to CXXFLAGS; prevents overriding of
# architecture-flags when using `icpc` and breaks when building on ppc64le.
sed -i.bak 's/-msse//g;' Makefile

env CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    make -j${MAKE_JOBS:-1} \
    CXX="${CXX}" \
    2>&1 | tee build.log

./unit_tests

mkdir -p "${PREFIX}/bin"
install -m 755 snap-aligner SNAPCommand "${PREFIX}/bin"
