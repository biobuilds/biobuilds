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

    # Require IEEE-compliant division so results match GCC-built version.
    # Without this, mpileup regression tests 48 through 51 fail due to _very_
    # slight differences in the quality score (basically the last digit).
    CFLAGS="${CFLAGS/-no-prec-div/}"
fi

# Make sure `./configure` can see these environment variables
export CPPFLAGS CC CFLAGS AR LD LDFLAGS

# Actual "./configure" step
./configure --prefix="${PREFIX}" \
    --enable-largefile \
    --with-htslib="${PREFIX}" \
    --without-curses \
    2>&1 | tee configure.log


##-------------------------------------------------------------------------
## Build
##-------------------------------------------------------------------------

# Fix perl "#!" lines so conda knows to munge paths on install; do this
# using a for-loop because of inconsistencies in how GNU and BSD sed deal
# with multiple filenames passed while using "-i".
for fn in misc/*.pl misc/plot-bamstats; do
    sed -i.bak "1s:.*:#!${PREFIX}/bin/perl -w:" "${fn}"
done

# Build and test C components
make -j${MAKE_JOBS} ${VERBOSE_AT} AR="${AR}" 2>&1 | tee build.log
make test AR="${AR}" 2>&1 | tee test.log


##-------------------------------------------------------------------------
## Install
##-------------------------------------------------------------------------

make install

# Some applications still rely on this API instead of using htslib exclusively,
# so install the headers and static library in ${PREFIX}.
#
# WARNING: this package and htslib both provide a "sam.h" that aren't actually
# compatible with each other. Be extra careful about which file you're actually
# #including when using this package for development work.
install -d "${PREFIX}/lib" "${PREFIX}/include/samtools"
install -m 0644 libbam.a "${PREFIX}/lib"
install -m 0644 *.h "${PREFIX}/include/samtools"
