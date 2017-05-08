#!/bin/bash

## Configure

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

CXXFLAGS="${CXXFLAGS} -DNDEBUG -fopenmp -Wall -Wno-deprecated"

if [[ "${CXX}" == */bin/icpc ]]; then
    # Require IEEE-compliant division so results match the GCC-built version.
    # (With our test case, "-no-prec-div" yields the same alignments as the GCC
    # version, but the mapping quality scores differ.)
    CXXFLAGS="${CXXFLAGS/-no-prec-div/}"
fi

if [ "$BUILD_ARCH" == "ppc64le" ]; then
    # Should be provided by the "veclib-headers" package
    [ -d "${PREFIX}/include/veclib" ] || \
        { echo "ERROR: could not find veclib headers" >&2; exit 1; }
    CXXFLAGS="-I${PREFIX}/include/veclib ${CXXFLAGS}"
fi


## Build
env CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    LD="${CXX}" LDFLAGS="${LDFLAGS}" \
    make -j${MAKE_JOBS}


## Install
env PREFIX="${PREFIX}" make install
