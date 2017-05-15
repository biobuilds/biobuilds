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
if [ `uname -m` == 'ppc64le' ]; then
    # Force the ppc64le compiler to make the same assumptions about "plain"
    # char declarations (i.e., those w/o explicit sign) as the x86_64 compiler
    CFLAGS="${CFLAGS} -fsigned-char"
fi

# Additional tweaks for the Intel compiler
if [[ "${CC}" == *"/bin/icc" ]]; then
    # Tell the dynamic linker where to find libraries like libiomp.so
    icc_root=$(cd `dirname "${CXX}"`/.. && pwd)
    export LD_LIBRARY_PATH="${icc_root}/lib/intel64_lin:${LD_LIBRARY_PATH}"

    # Require IEEE-compliant division so results match GCC-built version.
    # Without this, mpileup regression tests 48 through 51 fail due to _very_
    # slight differences in the quality score (basically the last digit).
    CFLAGS="${CFLAGS/-no-prec-div/}"
fi

# Actual "./configure" step
env CPPFLAGS="-I${PREFIX}/include" \
    CC="${CC}" CFLAGS="${CFLAGS}" \
    AR="$AR" ARFLAGS="$ARFLAGS" \
    LD="$LD" LDFLAGS="$LDFLAGS" \
    ./configure --prefix="${PREFIX}" --with-htslib=system \
    --without-curses --without-ncursesw \
    2>&1 | tee configure.log


##-------------------------------------------------------------------------
## Build
##-------------------------------------------------------------------------

# Fix perl "#!" lines so conda knows to munge paths on install
pushd "${SRC_DIR}/misc"
for fn in *.pl; do
    echo "#!${PREFIX}/bin/perl -w" > f
    sed -n '2,$p' "$fn" >> f
    mv -f f "$fn"
    chmod 0755 "$fn"
done
popd

# Build and test C components
make -j${MAKE_JOBS} V=1 2>&1 | tee build.log
make test 2>&1 | tee test.log


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
