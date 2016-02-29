#!/bin/bash

command -v pkg-config >/dev/null || \
    { echo "Could not find 'pkg-config' command" >&2; exit 1; }

# If available, pull in BioBuilds optimization flags
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

# Emit position-independent code so libbam.a is usable for dynamic linking
# (e.g., when creating shared libraries)
CFLAGS="-fPIC ${CFLAGS}"

env CFLAGS="${CFLAGS} $(pkg-config --cflags zlib)" \
    LDFLAGS="${LDFLAGS} $(pkg-config --libs zlib)" \
    make

install -d "${PREFIX}/include/${PKG_NAME}"
install -d "${PREFIX}/lib"
install bam.h sam.h bgzf.h khash.h faidx.h \
    "${PREFIX}/include/${PKG_NAME}"
install libbam.a "${PREFIX}/lib"
