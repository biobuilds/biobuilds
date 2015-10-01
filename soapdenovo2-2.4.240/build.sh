#!/bin/bash

## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

[ -d "${PREFIX}/include/samtools" ] || \
    { echo "ERROR: could not find samtools headers" >&2; exit 1; }
CPPFLAGS="-I${PREFIX}/include/samtools ${CPPFLAGS}"
CFLAGS="-I${PREFIX}/include/samtools ${CFLAGS}"

# Clean out headers and libraries to prevent conflicts with "system" ones
find . \( -name 'zlib.h' -o -name 'zconf.h' -o -name 'libz*' \) \
    -exec rm -f {} \;
find . \( -name 'bgzf.h' -o -name 'bam.h' -o -name 'sam.h' -o -name 'libbam*' \) \
    -exec rm -f {} \;
find . -type f -name '*curses*' -exec rm -f {} \;
find . \( -name '*.a' -o -name '*.so' -o -name '*.dylib' \) \
    -exec rm -f {} \;

## Build
env CFLAGS="${CFLAGS} $(pkg-config --cflags zlib)" \
    LDFLAGS="${LDFLAGS} $(pkg-config --libs-only-L zlib)" \
    make


## Install
[ -d "${PREFIX}/bin" ] || mkdir "${PREFIX}/bin"
cp SOAPdenovo-63mer SOAPdenovo-127mer "${PREFIX}/bin"
