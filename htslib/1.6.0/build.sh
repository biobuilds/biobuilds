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

# Tell the dynamic linker (ld.so) where to find various libraries so
# "./configure" and "make test" below don't get confused and break.
case "$BUILD_OS" in
    "linux")
        export LD_LIBRARY_PATH="${PREFIX}/lib"
        ;;
    "darwin")
        export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
        ;;
esac

# Architecture-specific tweaks
case "$BUILD_ARCH" in
    "x86_64")
        # Don't unroll loops on x86_64 Linux as something in the way gcc 4.4
        # (the system compiler on CentOS 6) does this breaks things for
        # dependent packages in a way that isn't caught by "make test" below.
        #
        # Specifically, it causes "test_vcf_annotate" in bcftools to generate
        # unexpected NaNs in its "annotate4.out" output file. Note that this
        # problem doesn't happen with gcc 4.8 and above.
        if [[ ${CC_IS_GNU} -eq 1 ]]; then
            GCC_VER=`"${CC}" -dumpversion`
            GCC_MAJOR_VER=$(cut -d. -f1 <<<"$GCC_VER")
            GCC_MINOR_VER=$(cut -d. -f2 <<<"$GCC_VER")
            if [[ $GCC_MAJOR_VER -lt 4 || $GCC_MINOR_VER -lt 8 ]]; then
                CFLAGS="${CFLAGS/-funroll-loops/}"
            fi
        fi
        ;;
    "ppc64le")
        # Make the same assumptions about "plain" char declarations (i.e.,
        # those w/o explicit signedness) as the x86_64 compiler.
        CFLAGS="${CFLAGS} -fsigned-char"
        ;;
esac

# Additional tweaks for the Intel compiler
if [[ "${CC}" == *"/bin/icc" ]]; then
    # Tell the dynamic linker where to find libraries like libiomp.so
    icc_root=$(cd `dirname "${CXX}"`/.. && pwd)
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${icc_root}/lib/intel64_lin"

    # Disable inter-procedural optimization (IPO), as it's causing `make
    # test` to fail with "Assertion `sym->x_max != 0' failed" errors.
    #
    # NOTE: If and when we decide to get IPO working again, be sure to pass
    # "AR=${AR}" to the `make` command below; `./configure` ignores the
    # value of "AR" we pass it, and we need to use Intel's `xiar` or the
    # build will fail with undefined symbols. (The system's GNU `ar`
    # doesn't generate the right symbol information for IPO to work.)
    CFLAGS="${CFLAGS/-ip/}"
    CFLAGS="${CFLAGS/-ipo/}"
fi

# Make sure `./configure` can see these environment variables
export CC CFLAGS AR LD LDFLAGS

# Actual ./configure step
./configure --prefix="$PREFIX" \
    --enable-bz2 \
    --enable-lzma \
    --enable-largefile \
    --enable-libcurl \
    --enable-gcs \
    --enable-s3 \
    --enable-plugins \
    --with-plugin-dir="${PREFIX}/libexec/${PKG_NAME}" \
    --with-plugin-path="${PREFIX}/libexec/${PKG_NAME}" \
    2>&1 | tee configure.log


##-------------------------------------------------------------------------
## Build
##-------------------------------------------------------------------------

make -j${MAKE_JOBS} ${VERBOSE_AT} 2>&1 | tee build.log
make test 2>&1 | tee test.log


##-------------------------------------------------------------------------
## Install
##-------------------------------------------------------------------------

make install
