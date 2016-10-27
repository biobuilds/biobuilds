#!/bin/bash
set -e -x
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

# Treat all plain chars as signed chars (normal behavior on x86_64)
#
# *WARNING*: Now disabled. Previous version (01.15.04.01) needed this compiler
# flag to get upstream unit tests in to pass on little-endian POWER8 (ppc64le).
# However, since that release, something has changed in the upstream code such
# that enabling this compiler flag now causes our test script to break on
# ppc64le with the following errors:
#
#   Dynamic exception type: boost::exception_detail::clone_impl<isaac::common::IoException>
#   std::exception::what: Failed to read neighbor counts from /path/to/neighbors-1-16.16bpb.gz: Success
#
#CFLAGS="${CFLAGS} -fsigned-char"

# No C++-specific flags, so just copy CFLAGS over to CXXFLAGS
CXXFLAGS="${CFLAGS}"

cd "${SRC_DIR}"
rm -rf "build"
mkdir -p "build"
cd "build"

env CFLAGS="${CFLAGS}" \
    CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
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


# Install
make install
