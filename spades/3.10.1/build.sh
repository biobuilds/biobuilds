#!/bin/bash
set -e -x -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment  configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Force the ppc64le compiler to make the same assumptions about "plain" char
# declarations (i.e., those w/o explicit sign) as x86_64 Linux gcc/g++.
CFLAGS="${CFLAGS} -fsigned-char"
CXXFLAGS="${CXXFLAGS} -fsigned-char"

# Architecture-specific tweaks
case "$BUILD_ARCH" in
    'ppc64le')
        CFLAGS="${CFLAGS} -I${PREFIX}/include/veclib"
        CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include/veclib"
        ;;
esac

rm -rf build
mkdir -p build
cd "build"
cmake -G "Unix Makefiles" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DCMAKE_C_COMPILER="${CC}" \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_AR="${AR}" \
    -DCMAKE_SHARED_LINKER_FLAGS="${LDFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF \
    -DSPADES_USE_JEMALLOC:BOOL=ON \
    -DSPADES_USE_TCMALLOC:BOOL=OFF \
    "${SRC_DIR}/src" \
    2>&1 | tee configure.log

make -j${MAKE_JOBS} 2>&1 | tee build.log
make install
