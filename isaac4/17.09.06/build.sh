#!/bin/bash
set -e -x
set -o pipefail

# Cannot build on OS X due to missing "posix_fadvise" system call and trouble
# getting Conda's gcc, boost, and pthreads working together.
if [ "$(uname -s)" == "Darwin" ]; then
    echo "ERROR: Cannot build iSAAC on OS X." >&2; exit 1;
fi


## Configure

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

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
#CXXFLAGS="${CXXFLAGS} -fsigned-char"

# Default to using the BioBuilds-provided Boost package
BOOST_ROOT="${PREFIX}"
BOOST_INCLUDEDIR="${PREFIX}/include"
BOOST_LIBRARYDIR="${PREFIX}/lib"

case "$CXX" in
    # Tweaks for the IBM Advance Toolchain
    /opt/at*/bin/g++)
        # Use AT-provided, rather than BioBuilds-provided, Boost
        AT_ROOT=$(cd "`dirname "${CXX}"`/.." && pwd)
        BOOST_ROOT="${AT_ROOT}"
        BOOST_INCLUDEDIR="${AT_ROOT}/include"
        BOOST_LIBRARYDIR="${AT_ROOT}/lib64"

        LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
        ;;
    # Tweaks for the Intel compiler
    */bin/icpc)
        #CXXFLAGS="${CXXFLAGS} -gcc-name=${CONDA_CC}"
        #CXXFLAGS="${CXXFLAGS} -gxx-name=${CONDA_CXX}"

        # Ensure icpc uses a pre-C++11 ABI compatible with our Boost package.
        CXXFLAGS="${CXXFLAGS} -D_GLIBCXX_USE_CXX11_ABI=0"
        ;;
    # "Stock" GNU compiler (g++)
    *)
        # Ensure g++ uses a pre-C++11 ABI compatible with our Boost package.
        CXXFLAGS="${CXXFLAGS} -D_GLIBCXX_USE_CXX11_ABI=0"
        ;;
esac

cd "${SRC_DIR}"
rm -rf "build"
mkdir -p "build"
cd "build"

export CC CFLAGS CXX CXXFLAGS
export AR LD LDFLAGS
export BOOST_ROOT BOOST_INCLUDEDIR BOOST_LIBRARYDIR
export C_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

chmod 755 ../src/configure
../src/configure --prefix="${PREFIX}" \
    --with-cmake="${CMAKE}" \
    --build-type=Release \
    --parallel=${MAKE_JOBS} \
    --without-numa \
    --with-unit-tests \
    2>&1 | tee configure.log


## Build
make -j${MAKE_JOBS} ${VERBOSE_CM} 2>&1 | tee build.log


# Install
make install
