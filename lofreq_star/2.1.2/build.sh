#!/bin/bash
set -o pipefail

## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

# Just in case there are unqualified "char" declaractions that could lead to
# different results between the x86_64 and ppc64le version.
CFLAGS="${CFLAGS} -fsigned-char"

CFLAGS="${CFLAGS} -I${PREFIX}/include -I${PREFIX}/include/samtools"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

cp -f "${PREFIX}/share/autoconf/config.guess" config.guess
cp -f "${PREFIX}/share/autoconf/config.sub" config.sub

env CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" \
    SAMTOOLS="${PREFIX}" HTSLIB="${PREFIX}" \
    2>&1 | tee configure.log


## Build
make -j${BB_MAKE_JOBS} 2>&1 | tee build.log


## Install
make install
