#!/bin/bash

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

if [ `uname -m` == "ppc64le" ]; then
    CXXFLAGS="${CXXFLAGS} -fsigned-char"
fi

# make
env CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    AR="${AR}" ARFLAGS="${ARFLAGS}" \
    LD="${CXX}" LDFLAGS="${LDFLAGS}" \
    make -j${MAKE_JOBS}
env CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    AR="${AR}" ARFLAGS="${ARFLAGS}" \
    LD="${CXX}" LDFLAGS="${LDFLAGS}" \
    make test

# install
[ -d "${PREFIX}/bin" ] || mkdir "${PREFIX}/bin"
cp -R "${SRC_DIR}/bin/." "${PREFIX}/bin"
