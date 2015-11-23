#!/bin/bash
set -x -o pipefail

## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CXXFLAGS="${CXXFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CXXFLAGS="${CXXFLAGS} $(pkg-config --cflags zlib)"
LDFLAGS="${LDFLAGS} $(pkg-config --libs-only-L zlib)"

# Favor environment-provided g++ over "system" one
[ -x "${PREFIX}/bin/g++" ] && CXX="${PREFIX}/bin/g++" || CXX="g++"

# Disable certain SHMEM constants when building on OS X
if [ $(uname -s) == "Darwin" ]; then
    CXXFLAGS="${CXXFLAGS} -DCOMPILE_FOR_MAC"
fi

## Build and install
cd "${SRC_DIR}"
rm -rf source/htslib    # Force use of system (conda) htslib
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

make -C source -j${BB_MAKE_JOBS} STAR \
    CXX="$CXX" CFLAGS="$CXXFLAGS" CPPFLAGS="-I${PREFIX}/include" \
    LIBHTS="${PREFIX}/lib/libhts.a" LDFLAGSextra="$LDFLAGS" \
    2>&1 | tee build-star.log
cp -fvp "source/STAR" "${PREFIX}/bin"

make -C source clean
make -C source -j${BB_MAKE_JOBS} STARlong \
    CXX="$CXX" CFLAGS="$CXXFLAGS" CPPFLAGS="-I${PREFIX}/include" \
    LIBHTS="${PREFIX}/lib/libhts.a" LDFLAGSextra="$LDFLAGS" \
    2>&1 | tee build-starlong.log
cp -fvp "source/STARlong" "${PREFIX}/bin"
