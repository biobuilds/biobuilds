#!/bin/bash
set -o pipefail

# Don't allow optimizations that are not value safe with Intel compilers; the
# default "-fp-model fast=1" causes "make check" to fail with precision errors.
FP_MODEL="precise"

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Additional tweaks for Intel compilers
if [[ "${CC}" == *"/icc" ]]; then
    # Don't generate auto-dispatch, alternative code paths, as doing so causes
    # various linear algebra checks (and possibly others) to fail.
    CFLAGS=`sed 's/-ax[^[:space:]]*//' <<< "$CFLAGS"`
    CXXFLAGS=`sed 's/-ax[^[:space:]]*//' <<< "$CXXFLAGS"`
fi

./configure --prefix="${PREFIX}" \
    --enable-shared \
    --enable-static \
    2>&1 | tee configure.log

make -j${MAKE_JOBS} 2>&1 | tee build.log
make -j${MAKE_JOBS} check 2>&1 | tee check.log

make install
rm -rf "${PREFIX}/share/info"
