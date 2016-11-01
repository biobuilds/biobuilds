#!/bin/bash
set -o pipefail

# Configure
build_os=$(uname -s)

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} -fsigned-char"

CFLAGS="${CFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    2>&1 | tee build.log

mkdir -p "${PREFIX}/bin"
install -m 0755 seqtk "${PREFIX}/bin"
