#!/bin/bash

# Pull in the common BioBuilds build flags
BUILD_ENV="${BUILD_PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

TEST_LDFLAGS="-L. libz.a"

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

    TEST_LDFLAGS="${TEST_LDFLAGS} ${IPP_LIB}/libippdc.a"
    TEST_LDFLAGS="${TEST_LDFLAGS} ${IPP_LIB}/libipps.a"
    TEST_LDFLAGS="${TEST_LDFLAGS} ${IPP_LIB}/libippcore.a"
fi

./configure --prefix="$PREFIX"
make -j${MAKE_JOBS} ${VERBOSE_AT} shared
make check TEST_LDFLAGS="${TEST_LDFLAGS}"
make install

rm -rf $PREFIX/share

# Copy license file to the source directory so conda-build can find it.
cp "${RECIPE_DIR}/license.txt" "${SRC_DIR}/license.txt"
