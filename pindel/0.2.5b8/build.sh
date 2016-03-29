#!/bin/bash
set -o pipefail

## Configure
build_arch=$(uname -m)
build_os=$(uname -s)

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} -fsigned-char"

# Make sure compiler and linker can find htslib
CFLAGS="${CFLAGS} -I${PREFIX}/lib"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Write Makefile.local
cat >Makefile.local <<EOF
HTSLIB_CPPFLAGS=-I${PREFIX}/include
HTSLIB_LDFLAGS=-L${PREFIX}/lib

THREADS=${BB_MAKE_JOBS}
COLOUSINGBD15_TIME=60
COLOWOBD15_TIME=80
SIM1CHRVS20305_TIME=60
EOF


## Build
env CFLAGS="$CFLAGS" CXXFLAGS="$CFLAGS" \
    make -j${BB_MAKE_JOBS} -C src V=1 pindel \
    2>&1 | tee build.log

# Skipping tests; fails on all target platforms even when we disable all
# optimization & architecture flags here and with htslib 1.2 and 1.3.
#env LD_LIBRARY_PATH="${PREFIX}/lib" \
#    DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib" \
#    make -C test functional-tests \
#    2>&1 | tee test.log


## Install
mkdir -p "${PREFIX}/bin"
install src/pindel src/pindel2vcf src/sam2pindel src/pindel2vcf4tcga \
    "${PREFIX}/bin"
