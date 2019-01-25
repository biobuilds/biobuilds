#!/bin/bash
set -o pipefail

##-------------------------------------------------------------------------
## "Configure"
##-------------------------------------------------------------------------

# Pull in the common BioBuilds build flags
BUILD_ENV="${BUILD_PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Work around some problematic pointer comparisons in 'oligotm.c' and 'thal.c'.
# (At least until we find time to fix the code and send the patches upstream.)
CFLAGS="${CFLAGS} -fpermissive"
CXXFLAGS="${CXXFLAGS} -fpermissive"

# Restore flags we squash with our `make` invocation below. (Not quite sure the
# define is absolutely necessary, but there seems to be no harm in having it.)
CFLAGS="${CFLAGS} -Wall -D__USE_FIXED_PROTOTYPES__"
CXXFLAGS="${CXXFLAGS} -Wall -D__USE_FIXED_PROTOTYPES__"

# Platform-specific tweaks
if [[ "${HOST_ARCH}" = 'ppc64le' ]]; then
    # Force the ppc64le compiler to make the same assumptions about "plain"
    # char declarations (i.e., those w/o explicit sign) as the x86_64 compiler
    CFLAGS="${CFLAGS} -fsigned-char"
    CXXFLAGS="${CXXFLAGS} -fsigned-char"
fi

if [[ "$toolchain" = "intel-psxe"* ]]; then
    # needed to stop `make test` from failing
    export LD_LIBRARY_PATH="${PSXE_LIB}"
fi

##-------------------------------------------------------------------------
## Build, test, and install
##-------------------------------------------------------------------------

make -C src -j${MAKE_JOBS} \
    CC="${CC}" \
    CFLAGS="${CFLAGS}" \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS}" \
    AR="${AR}" \
    RANLIB="${RANLIB}" \
    LD="${LD}" \
    LDFLAGS="${LDFLAGS}"

make -C test

make -C src install \
    PREFIX="${PREFIX}"
