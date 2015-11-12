#!/bin/bash
set -o pipefail

build_arch=$(uname -m)
build_os=$(uname -s)

## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

[ -d "$PREFIX/bin" ] || mkdir -p "$PREFIX/bin"

if [[ "$build_arch" == "x86_64" && "$build_os" == Linux ]]; then
    # Blindly assuming we're using gcc
    CFLAGS="${CFLAGS} -maccumulate-outgoing-args"
fi
if [ "$build_arch" == "ppc64le" ]; then
    # Should be provided by the "veclib-headers" package
    [ -d "${PREFIX}/include/veclib" ] || \
        { echo "ERROR: could not find veclib headers" >&2; exit 1; }
    CFLAGS="-I${PREFIX}/include/veclib ${CFLAGS}"
fi
if [ "$build_os" == "Darwin" ]; then
    # Blindly assuming we're using clang
    # Set flag so clang treats C "inline" like gcc (< 5.0) does
    CFLAGS="${CFLAGS} -std=gnu89"
fi

## Build
env CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    make -j${BB_MAKE_JOBS} PTHREADS=YES

## Install
cp -fvp soap "${PREFIX}/bin"
chmod 0755 "${PREFIX}/bin/soap"
