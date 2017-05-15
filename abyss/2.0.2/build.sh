#!/bin/bash
set -o pipefail

##-------------------------------------------------------------------------
## Configure
##-------------------------------------------------------------------------

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

case "$BUILD_ARCH" in
    'ppc64le')
        # Just in case, tell the POWER compiler to assume to the same
        # signedness for plain chars as the x86_64 compiler.
        CFLAGS="${CFLAGS} -fsigned-char"
        ;;
esac

# Favor the AT-provided Boost libraries over the BioBuilds ones
BOOST_PREFIX="${PREFIX}"
if [[ "${CC}" == "/opt/at"*"/bin/gcc" ]]; then
    at_root=$(cd `dirname "$CC"`/.. && pwd)
    BOOST_PREFIX="${at_root}"
fi

# Update autoconf files for ppc64le detection
cp -fv "${PREFIX}/share/autoconf/config.guess" "config.guess"
cp -fv "${PREFIX}/share/autoconf/config.sub" "config.sub"

env CC="${CC}" CFLAGS="${CFLAGS}" \
    CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    ./configure --prefix="${PREFIX}" \
    --without-mpi \
    --with-boost="${BOOST_PREFIX}" \
    --with-sparsehash="${PREFIX}" \
    --with-sqlite="${PREFIX}" \
    2>&1 | tee configure.log

make -j${MAKE_JOBS} AR="${AR}" V=1 2>&1 | tee build.log
env DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib" \
    make check AR="${AR}" 2>&1 | tee check.log

make install

# Fix perl paths
cd "${PREFIX}/bin"
grep -HI -- '^#!.*perl' * | cut -d: -f1 | \
    xargs sed -i.install-bak "s|^#!.*perl|#!${PREFIX}/bin/perl|"
rm -f *.install-bak
