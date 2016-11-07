#!/bin/bash
set -o pipefail

# Configure
build_os=$(uname -s)

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} $(pkg-config --cflags zlib)"
CFLAGS="${CFLAGS} $(pkg-config --cflags eigen)"
CXXFLAGS="${CFLAGS}"
LDFLAGS="${LDFLAGS} $(pkg-config --libs zlib)"

if [ "$build_os" == 'Darwin' ]; then
    CFLAGS="${CFLAGS} -Wno-deprecated-register -Wno-unused-variable"
    CXXFLAGS="${CXXFLAGS} -Wno-deprecated-register -Wno-unused-variable"

    MACOSX_VERSION_MIN="10.8"
    CFLAGS="${CFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"

    # Make sure we use the same C++ standard library as boost
    # NOTE: need to set this CFLAGS as well, as ./configure and the resulting
    # Makefile seem to ignore CXXFLAGS in some cases.
    CFLAGS="${CFLAGS} -stdlib=libc++"
    CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
    LDFLAGS="${LDFLAGS} -stdlib=libc++"
fi

cp -f "${RECIPE_DIR}/config.guess" "${SRC_DIR}/build-aux/config.guess"
cp -f "${RECIPE_DIR}/config.sub" "${SRC_DIR}/build-aux/config.sub"

[ -f Makefile ] && make distclean
env CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" \
    --with-zlib="${PREFIX}" --with-boost="${PREFIX}" \
    --with-eigen="${PREFIX}" --with-bam="${PREFIX}" \
    2>&1 | tee configure.log

# Build
make -j${BB_MAKE_JOBS} 2>&1 | tee build.log

# Install
make install-strip
