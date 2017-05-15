#!/bin/bash
set -o pipefail

## Configure

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Just in case there are unqualified "char" declaractions that could lead to
# different results between the x86_64 and ppc64le version.
CFLAGS="${CFLAGS} -fsigned-char"

CFLAGS="${CFLAGS} -I${PREFIX}/include/samtools"

cp -f "${PREFIX}/share/autoconf/config.guess" config.guess
cp -f "${PREFIX}/share/autoconf/config.sub" config.sub

env CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" \
    SAMTOOLS="${PREFIX}" HTSLIB="${PREFIX}" \
    2>&1 | tee configure.log


## Build
make -j${MAKE_JOBS} 2>&1 | tee build.log


## Install
make install
