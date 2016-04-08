#!/bin/bash
set -o pipefail

build_arch=$(uname -m)
build_os=$(uname -s)


## Expecting the CUDA compiler and toolkit in our PATH
NVCC=$(command -v nvcc 2>/dev/null)
echo "*** NVCC is ${NVCC}" >&2
[ "x$NVCC" == "x" ] && \
    { echo "ERROR: Could not find 'nvcc' in \$PATH." >&2; exit 1; }
CUDA_DIR=$(cd `dirname "${NVCC}"`/.. && pwd)


## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [ "$build_arch" == "ppc64le" ]; then
    # Should be provided by the "veclib-headers" package
    [ -d "${PREFIX}/include/veclib" ] || \
        { echo "ERROR: could not find veclib headers" >&2; exit 1; }
    CFLAGS="-I${PREFIX}/include/veclib ${CFLAGS}"
fi


## Build and install
make CUDA_INSTALL_PATH="${CUDA_DIR}" \
    CPPFLAGS="-I${PREFIX}/include" LDFLAGS="${LDFLAGS}" \
    CFLAGS_extra="${CFLAGS}" CXXFLAGS_extra="${CXXFLAGS}" \
    V=1 2>&1 | tee build.log

[ -d "$PREFIX/bin" ] || mkdir -p "$PREFIX/bin"
install -d "${PREFIX}/bin"
install -m 0755 bin/barracuda "${PREFIX}/bin"
