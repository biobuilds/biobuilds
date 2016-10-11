#!/bin/bash

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

set -o pipefail

make -j${BB_MAKE_JOBS} \
    EXT_INCLUDES="-I${PREFIX}/include" \
    EXT_LIBS="-L${PREFIX}/lib" \
    OTHER_CFLAGS="${CFLAGS}" \
    OTHER_CXXFLAGS="${CFLAGS}" \
    SFLAGS="" \
    2>&1 | tee build.log

make install
rm -f bin/*_sge*
install -m 0755 bin/* "${PREFIX}/bin"
