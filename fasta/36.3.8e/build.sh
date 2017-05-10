#!/bin/bash
set -o pipefail

## Configure

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Architecture-specific tweaks
if [ "$BUILD_ARCH" == "ppc64le" ]; then
    makefile="../make/Makefile.ppc64le.gnu"
    # Should be provided by the "veclib-headers" package
    [ -d "${PREFIX}/include/veclib" ] || \
        { echo "ERROR: could not find veclib headers" >&2; exit 1; }
    CFLAGS="$CFLAGS -I${PREFIX}/include/veclib"
    CFLAGS="$CFLAGS -fsigned-char"
elif [ "$BUILD_ARCH" == "x86_64" ]; then
    makefile="../make/Makefile.linux64_sse2"
else
    echo "ERROR: Unsupported architecture '$build_arch'" >&2
    exit 1
fi

# Tweaks for the Intel compiler
if [[ "${CC}" == *"/bin/icc" ]]; then
    # Be more conservative with floating-point optimizations in an attempt to
    # match the results produced by the GCC-compiled version. Note, we haven't
    # actually _shown_ that this has any meaningful effect, mostly because the
    # binaries use randomization in a way that makes it difficult to reliably
    # reproduce outputs (e.g., we can't set the seed to use).
    CFLAGS="${CFLAGS/-fp-model fast=1/-fp-model precise}"
    CFLAGS="${CFLAGS/-no-prec-div/}"
fi


## Build
cd "${SRC_DIR}/src"
env CC="${CC}" CFLAGS="${CFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    make -j${MAKE_JOBS} -f "$makefile" \
    2>&1 | tee build.log

# Not running supplied tests due to missing $FASTLIBS
#cd "${SRC_DIR}/test"
#./test.sh


## Install
INSTALL_BIN="${PREFIX}/bin"
INSTALL_SHARE="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"

install -m 0755 -d "${INSTALL_BIN}"
install -m 0755 -d "${INSTALL_SHARE}"

cd "${SRC_DIR}"
rm -f bin/README
cp -Rfv bin/. "${INSTALL_BIN}/."
#cp -Rfv data/. "${INSTALL_SHARE}/data"
#cp -Rfv conf/. "${INSTALL_SHARE}/conf"
#cp -Rfv seq/. "${INSTALL_SHARE}/seq"
