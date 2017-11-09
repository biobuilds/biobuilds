#!/bin/bash

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

if [[ "${toolchain:-default}" == "intel-"* ]]; then
    IPP_ROOT="${PSXE_ROOT:-/opt/intel}/ipp"
    IPP_INC="${IPP_ROOT}/include"
    IPP_LIB="${IPP_ROOT}/lib/intel64"

    if [ ! -d "${IPP_INC}" ]; then
        echo "FATAL: Could not find Intel IPP include directory" >&2
        exit 1
    fi
    if [ ! -d "${IPP_LIB}" ]; then
        echo "FATAL: Could not find Intel IPP lib directory" >&2
        exit 1
    fi

    CFLAGS="${CFLAGS} -DWITH_IPP -I${IPP_INC}"
    LDFLAGS="${LDFLAGS} ${IPP_LIB}/libippdc.a"
    LDFLAGS="${LDFLAGS} ${IPP_LIB}/libipps.a"
    LDFLAGS="${LDFLAGS} ${IPP_LIB}/libippcore.a"
fi

./configure --prefix="$PREFIX"
make -j${MAKE_JOBS} shared
make install

rm -rf $PREFIX/share
