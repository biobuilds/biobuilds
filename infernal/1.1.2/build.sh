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

# Assume the same signedess for plain chars across all compilers/platforms
CFLAGS="${CFLAGS} -fsigned-char"

# Update autoconf files for ppc64le support
for d in . easel hmmer; do
    cp -f "${PREFIX}/share/autoconf/config.guess" ${d}/config.guess
    cp -f "${PREFIX}/share/autoconf/config.sub" ${d}/config.sub
done

# Additional OS-specific tweaks
case "$BUILD_OS" in
    'linux')
        export LD_LIBRARY_PATH="${PREFIX}/lib"
        ;;
    'darwin')
        export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
        ;;
esac

# Additional architecture-specific tweaks
case "$BUILD_ARCH" in
    'ppc64le')
        # Should be provided by the "veclib-headers" package
        [ -d "${PREFIX}/include/veclib" ] || \
            { echo "ERROR: could not find veclib headers" >&2; exit 1; }
        CFLAGS="${CFLAGS} -I${PREFIX}/include/veclib"

        # Regenerate ./configure so we can use a modified/patched SSE
        # implementation on ppc64le (rather than the upstream VMX one)
        [ -f Makefile ] && make distclean
        rm -f configure
        autoconf
        ;;
esac

# Additional tweaks for ICC
if [[ "$CC" == *"/bin/icc" ]]; then
    export LD_LIBRARY_PATH="/opt/intel/lib/intel64:${LD_LIBRARY_PATH}"

    # Disable multi-file interprocedural optimization; enabling this causes
    # exercise 255 of hmmer's test suite ("brute-itest") to fail.
    CFLAGS="${CFLAGS/-ipo/}"
fi

env CC="${CC}" CFLAGS="${CFLAGS}" \
    LD="${LD}" LDFLAGS="${LDFLAGS}" \
    MPICC= \
    ./configure --prefix="${PREFIX}" \
    --enable-sse  \
    --disable-vmx \
    --enable-threads \
    --disable-mpi \
    --enable-largefile \
    2>&1 | tee configure.log

make -j${MAKE_JOBS} \
    V=1 2>&1 | tee build.log

make check 2>&1 | tee check.log

make install
