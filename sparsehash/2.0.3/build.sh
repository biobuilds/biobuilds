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

# Target the oldest C++ standard we expect to support; need to do this because
# some of our compilers assume a newer standard (C++11 or C++14), but we want
# to use this library to build software written in older C++ flavors.
CXXFLAGS="-std=c++98 ${CXXFLAGS}"

env CC="${CC}" CFLAGS="${CFLAGS}" \
    CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    ./configure --prefix="${PREFIX}" \
    2>&1 | tee configure.log

make -j${MAKE_JOBS} V=1 2>&1 | tee build.log
make check 2>&1 | tee check.log
make install

# No need to keep the documentation
rm -rf ${PREFIX}/share/doc
