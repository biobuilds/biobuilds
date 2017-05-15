#!/bin/bash
set -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Update autoconf files for ppc64le and AT detection
cp -fv "${PREFIX}/share/autoconf/config.guess" "config.guess"
cp -fv "${PREFIX}/share/autoconf/config.sub" "config.sub"

env CC="${CC}" CFLAGS="${CFLAGS}" \
    CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    ./configure --prefix="${PREFIX}" \
    --with-boost="${BOOST_PREFIX}" \
    2>&1 | tee configure.log

make -j${MAKE_JOBS} V=1 2>&1 | tee build.log
make check 2>&1 | tee check.log
make install
