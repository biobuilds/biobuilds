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

# OS-specific tweaks
case "$BUILD_OS" in
    "linux")
        export LD_LIBRARY_PATH="${PREFIX}/lib"
        DYNAMIC_FLAGS='-rdynamic'
        ;;
    "darwin")
        export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
        DYNAMIC_FLAGS='-Wl,-export_dynamic'
        ;;
esac

# Architecture-specific tweaks
case "$BUILD_ARCH" in
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

    # Be more conservative with floating-point optimizations so the results
    # match those produced when building using GCC. Without these, various
    # parts of `make test` fail (test_vcf_stats, test_vcf_merge).
    CFLAGS="${CFLAGS/-no-prec-div/}"
    CFLAGS="${CFLAGS/-fp-model fast=1/-fp-model precise}"
fi

# Make sure `./configure` can see these environment variables
export CPPFLAGS CC CFLAGS AR LD LDFLAGS

rm -rf "htslib-${PKG_VERSION}"

# Actual "./configure" step
./configure --prefix="${PREFIX}" \
    --enable-largefile \
    --disable-configure-htslib \
    --with-htslib="${PREFIX}" \
    --enable-bcftools-plugins \
    --with-plugin-dir="${PREFIX}/libexec/${PKG_NAME}" \
    --with-plugin-path="${PREFIX}/libexec/${PKG_NAME}" \
    2>&1 | tee configure.log


##-------------------------------------------------------------------------
## Build
##-------------------------------------------------------------------------

# Fix perl "#!" lines so conda knows to munge paths on install; do this
# using a for-loop because of inconsistencies in how GNU and BSD sed deal
# with multiple filenames passed while using "-i".
for fn in misc/*.pl misc/plot-vcfstats; do
    sed -i.bak "1s:.*:#!${PREFIX}/bin/perl -w:" "${fn}"
done

# Build and test C components
make -j${MAKE_JOBS} all \
    ${VERBOSE_AT} \
    AR="${AR}" \
    DYNAMIC_FLAGS="${DYNAMIC_FLAGS}" \
    2>&1 | tee build.log

make test \
    AR="${AR}" \
    2>&1 | tee test.log


##-------------------------------------------------------------------------
## Install
##-------------------------------------------------------------------------

make install
