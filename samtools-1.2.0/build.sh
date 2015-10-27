#!/bin/bash

set -o pipefail

HTSDIR="${PREFIX}"
HTSLIB="${HTSDIR}/lib/libhts.a"

command -v pkg-config >/dev/null || \
    { echo "Could not find 'pkg-config' command" >&2; exit 1; }
[ -f "${HTSLIB}" ] || { echo "Could not find htslib" >&2; exit 1; }

# If available, pull in BioBuilds optimization flags
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} $(pkg-config --cflags zlib)"
LDFLAGS="${LDFLAGS} $(pkg-config --libs-only-L zlib)"

make HTSDIR="${PREFIX}" CFLAGS="${CFLAGS} -Wall" LDFLAGS="${LDFLAGS}"
make HTSDIR="${PREFIX}" check 2>&1 | tee samtools-tests.log
make HTSDIR="${PREFIX}" prefix="${PREFIX}" install
