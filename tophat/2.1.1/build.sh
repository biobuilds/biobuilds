#!/bin/bash
set -o pipefail

## Configure
# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment  configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

if [ "$BUILD_OS" == 'Darwin' ]; then
    # Give install_name_tool enough space to work its magic; if not set,
    # tweaking "long_spanning_reads" binary fails.
    LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

if [ "$BUILD_ARCH" == 'ppc64le' ]; then
    # Prevent "template argument deduction/substitution failed"-related errors
    # when building with AT 10.0 (gcc 6.x) by using the old default "g++98"
    # language standard, rather than using the new "g++14" one.
    #
    # NOTE: "./configure" below seems to (incorrectly?) reset "${CXXFLAGS}" to
    # "${CFLAGS}", so we have to force this issue by tweaking "${CXX} instead.
    if [[ "${CXX}" == '/opt/at10.0/bin/g++' ]]; then
        CXX="${CXX} -std=gnu++98"
    fi
fi

cp -f "${PREFIX}/share/autoconf/config.guess" config.guess
cp -f "${PREFIX}/share/autoconf/config.sub" config.sub

env CC="${CC}" CFLAGS="${CFLAGS}" \
    CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    LD="${LD}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" --with-boost="${PREFIX}" \
    2>&1 | tee configure.log


## Build. WARNING: Do NOT use "-j" option as it causes cryptic build failures
make 2>&1 | tee build.log


## Install
make install

# Move Python packages to the more standard site-packages directory
mv "${PREFIX}/bin/intervaltree" "${PREFIX}/lib/python${PY_VER}/site-packages"
mv "${PREFIX}/bin/sortedcontainers" "${PREFIX}/lib/python${PY_VER}/site-packages"
