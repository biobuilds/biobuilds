#!/bin/bash
set -o pipefail

command -v pkg-config >/dev/null || \
    { echo "Could not find 'pkg-config' command" >&2; exit 1; }

# Cannot build on OS X due to missing "posix_fadvise" system call and trouble
# getting Conda's gcc, boost, and pthreads working together.
if [ "$(uname -s)" == "Darwin" ]; then
    echo "ERROR: Cannot build iSAAC on OS X." >&2; exit 1;
fi


## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Force configure to use "system" cmake instead of trying to build its own;
# saves us the trouble of having to manage that build as well...
CMAKE=$(command -V cmake 2>/dev/null)
[ "x$CMAKE" == "x" ] && \
    { echo "ERROR: Could not find suitable cmake." >&2; exit 1; }

# Tell the compiler where to find POWER8 veclib headers
if [ "$(uname -m)" == "ppc64le" ]; then
    [ -d "${PREFIX}/include/veclib" ] || \
        { echo "ERROR: could not find veclib headers" >&2; exit 1; }
    CFLAGS="${CFLAGS} -I${PREFIX}/include/veclib"
fi

# Treat all plain chars as signed chars (normal behavior on x86)
# Without this, upstream unit tests will fail on POWER8 LE
CFLAGS="${CFLAGS} -fsigned-char"

# No C++-specific flags, so just copy CFLAGS over to CXXFLAGS
CXXFLAGS="${CFLAGS}"

cd "${SRC_DIR}"
[ -d "build" ] || mkdir "build"
cd "build"
env CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" \
    CMAKE_PREFIX_PATH="${PREFIX}" \
    BOOST_ROOT="${PREFIX}" \
    C_INCLUDE_PATH="${PREFIX}/include" \
    CPLUS_INCLUDE_PATH="${PREFIX}/include" \
    LIBRARY_PATH="${PREFIX}/lib" \
    ../src/configure --prefix="${PREFIX}" \
    --with-cmake="${CMAKE}" \
    --build-type=Release \
    --parallel=${BB_MAKE_JOBS} \
    --without-numa \
    --with-unit-tests \
    2>&1 | tee configure.log


## Build
make -j${BB_MAKE_JOBS} VERBOSE=1 2>&1 | tee build.log


## Install
make install
