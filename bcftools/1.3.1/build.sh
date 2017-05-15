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

# Platform-specific tweaks
if [ "$BUILD_ARCH" == "ppc64le" ]; then
    # Force the ppc64le compiler to make the same assumptions about "plain"
    # char declarations (i.e., those w/o explicit sign) as the x86_64 compiler
    CFLAGS="${CFLAGS} -fsigned-char"
fi

if [ "$BUILD_OS" == 'Darwin' ]; then
    # Give install_name_tool enough space to work its magic; if not set,
    # tweaking the plugin shared libraries fails.
    LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

# Additional tweaks for the Intel compiler
if [[ "${CC}" == *"/bin/icc" ]]; then
    # Be more conservative with floating-point optimizations so the results
    # match those produced when building using GCC. Without these, various
    # parts of `make test` fail (test_vcf_stats, test_vcf_merge).
    CFLAGS="${CFLAGS/-no-prec-div/}"
    CFLAGS="${CFLAGS/-fp-model fast=1/-fp-model precise}"
fi


##-------------------------------------------------------------------------
## Build
##-------------------------------------------------------------------------

# Fix perl "#!" lines so conda knows to munge paths on install
for fn in $(grep '^MISC_PROGRAMS =' Makefile | cut -d' ' -f3-); do
    echo "#!${PREFIX}/bin/perl -w" > f
    sed -n '2,$p' "$fn" >> f
    mv -f f "$fn"
    chmod 0755 "$fn"
done

# Build and test C components
make -j${MAKE_JOBS} all \
    prefix="${PREFIX}" \
    CC="${CC}" CFLAGS="${CFLAGS}" \
    LD="${LD}" LDFLAGS="${LDFLAGS}" \
    HTSDIR="${PREFIX}" HTSLIB="-lhts" \
    2>&1 | tee build.log

env LD_LIBRARY_PATH="${PREFIX}/lib" \
    DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib" \
    make test \
    prefix="${PREFIX}" \
    CC="${CC}" CFLAGS="${CFLAGS}" \
    LD="${LD}" LDFLAGS="${LDFLAGS}" \
    HTSDIR="${PREFIX}" HTSLIB="-lhts" \
    2>&1 | tee test.log


##-------------------------------------------------------------------------
## Install
##-------------------------------------------------------------------------

make HTSDIR="${PREFIX}" prefix="${PREFIX}" install
