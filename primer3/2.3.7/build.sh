#!/bin/bash
set -o pipefail


##-------------------------------------------------------------------------
## "Configure"
##-------------------------------------------------------------------------

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Platform-specific tweaks
if [ `uname -m` == 'ppc64le' ]; then
    # Force the ppc64le compiler to make the same assumptions about "plain"
    # char declarations (i.e., those w/o explicit sign) as the x86_64 compiler
    CFLAGS="${CFLAGS} -fsigned-char"
fi


##-------------------------------------------------------------------------
## Build, test, and install
##-------------------------------------------------------------------------

cd src
make -j${MAKE_JOBS} \
    CC="${CC}" CFLAGS="${CFLAGS} -D__USE_FIXED_PROTOTYPES__" \
    CPP="${CXX}" \
    AR="${AR}" \
    LD="${LD}" LDFLAGS="${LDFLAGS}"

cd ../test
make

cd ../src
make PREFIX="${PREFIX}" install
