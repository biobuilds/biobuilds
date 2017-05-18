#!/bin/bash
set -e -x
set -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Other than architecture hints and include paths, let the libconfigure build
# system determine the compiler and other toolchain flags to use (i.e., don't
# assume the optimization flags we normally do).
env CFLAGS="${ARCH_FLAGS} -I${PREFIX}/include" \
    CXXFLAGS="${ARCH_FLAGS} -I${PREFIX}/include" \
    LDFLAGS="${CONDA_LDFLAGS} -L${PREFIX}/lib" \
    ./configure --prefix="${PREFIX}" \
    2>&1 | tee configure.log

make -j${CPU_COUNT} 2>&1 | tee build.log

make install
