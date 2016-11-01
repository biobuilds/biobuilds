#!/bin/bash
set -o pipefail

# Configure
build_os=$(uname -s)

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} -fsigned-char"

# BUILDNUM define that we'll squash by passing CCFLAGS directly to make
BUILDNUM=`echo "$PKG_VERSION" | cut -d. -f3`
CFLAGS="${CFLAGS} -DBUILDNUM=${BUILDNUM}"

# Squash some messages about asprintf() return values
CFLAGS="${CFLAGS} -Wall -Wno-unused-result"

make CCFLAGS="${CFLAGS}" 2>&1 | tee build.log

mkdir -p "${PREFIX}/bin"
install -m 0755 samblaster "${PREFIX}/bin"
