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

# Write Makefile.local
cat >Makefile.local <<EOF
HTSLIB_CPPFLAGS=-I${PREFIX}/include
HTSLIB_LDFLAGS=-L${PREFIX}/lib

THREADS=${MAKE_JOBS}
COLOUSINGBD15_TIME=60
COLOWOBD15_TIME=80
SIM1CHRVS20305_TIME=60
EOF


## Build
env CC="$CC" CFLAGS="$CFLAGS" \
    CXX="$CXX" CXXFLAGS="$CXXFLAGS" \
    make -j${MAKE_JOBS} -C src V=1 pindel \
    2>&1 | tee build.log


# Skipping tests; fails on all target platforms even when we disable all
# optimization & architecture flags here and with htslib 1.2 and 1.3.
# This seems to be a known but unresolved issue, likely caused by out-of-date
# test files; for details, see: <https://github.com/genome/pindel/issues/42>.
#env LD_LIBRARY_PATH="${PREFIX}/lib" \
#    DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib" \
#    make -C test functional-tests \
#    2>&1 | tee test.log


## Install
mkdir -p "${PREFIX}/bin"
install src/pindel src/pindel2vcf src/sam2pindel src/pindel2vcf4tcga \
    "${PREFIX}/bin"
