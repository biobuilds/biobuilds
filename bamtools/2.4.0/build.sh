#!/bin/bash
set -o pipefail

# Configure
build_os=$(uname -s)

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} $(pkg-config --cflags zlib)"
CXXFLAGS="${CFLAGS}"
LDFLAGS="${LDFLAGS} $(pkg-config --libs zlib)"

if [ "$build_os" == 'Darwin' ]; then
    MACOSX_VERSION_MIN=10.8
    CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    #CXXFLAGS="${CXXFLAGS} -stdlib=libstdc++"
    LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    #LDFLAGS="${LDFLAGS} -stdlib=libstdc++"
fi

[ -d "build" ] || mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET="${MACOSX_VERSION_MIN}" \
    -DCMAKE_C_FLAGS="$CFLAGS" -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
    -DCMAKE_SHARED_LINKER_FLAGS="$LDFLAGS" \
    -DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
    ..

# Build
make -j${BB_MAKE_JOBS} VERBOSE=1

# Install
make install
