#!/bin/bash
set -o pipefail

build_arch=$(uname -m)
build_os=$(uname -s)


## Expecting the CUDA compiler and toolkit in our PATH
NVCC=$(command -v nvcc 2>/dev/null)
[ "x$NVCC" == "x" ] && \
    { echo "ERROR: Could not find 'nvcc' in \$PATH." >&2; exit 1; }
CUDA_DIR=$(cd `dirname "${NVCC}"`/.. && pwd)
CUDA_RTLIB_DIR=""
for dir in "${CUDA_DIR}/lib64" "${CUDA_DIR}/lib"; do
    if [ -f "${dir}/libcudart.so" ]; then
        CUDA_RTLIB_DIR="${dir}"
        break
    fi
done
[ "x${CUDA_RTLIB_DIR}" == "x" ] && \
    { echo "ERROR: Could not find libcudart.so" >&2; exit 1; }

if [ -f "${CUDA_RTLIB_DIR}/libcuda.so" ]; then
    CUDA_LIB_DIR="${CUDA_RTLIB_DIR}"
else
    # If libcuda.so isn't in "$CUDA_RTLIB_DIR", find a usable stub library
    LIBCUDA=$(find "${CUDA_DIR}/" -path '*/stubs/*' -name 'libcuda.so' | head -n1)
    [[ ! -z "$LIBCUDA"  ]] || \
        { echo "ERROR: Could not find libcuda.so" >&2; exit 1; }
    CUDA_LIB_DIR=$(dirname "${LIBCUDA}")
fi


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

[ -d "$PREFIX/bin" ] || mkdir -p "$PREFIX/bin"


## Build
env CUDAFLAG="-I${PREFIX}/include" \
    LIBCUDA_PATH="${CUDA_LIB_DIR}" LIBCUDART_PATH="${CUDA_RTLIB_DIR}" \
    CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" \
    make -j${BB_MAKE_JOBS}


## Install
mv Sample SOAP3-Sample  # Rename to avoid confusion in a large "bin" directory
install -d "${PREFIX}/bin" "${PREFIX}/share/soap3-dp"
install -m 0755 -t "${PREFIX}/bin" \
    BGS-Build BGS-View BGS-View-PE SOAP3-Sample SOAP3-Builder SOAP3-DP
install -m 0644 soap3-dp-builder.ini soap3-dp.ini "${PREFIX}/share/soap3-dp"

# Link the binaries so they match the names in the documentation
ln -sf "${PREFIX}/bin/SOAP3-DP" "${PREFIX}/bin/soap3-dp"
ln -sf "${PREFIX}/bin/SOAP3-Builder" "${PREFIX}/bin/soap3-dp-builder"
