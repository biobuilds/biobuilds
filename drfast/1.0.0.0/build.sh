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

make -j${MAKE_JOBS} \
    CC="${CC}" CFLAGS="${CFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    2>&1 | tee build.log

mkdir -p "${PREFIX}/bin"
install -m 0755 drfast "${PREFIX}/bin"
