#!/bin/bash
set -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

case "$BUILD_ARCH" in
    'ppc64le')
        # Should be provided by the "veclib-headers" package
        [ -d "${PREFIX}/include/veclib" ] || \
            { echo "ERROR: could not find veclib headers" >&2; exit 1; }
        CFLAGS="${CFLAGS} -I${PREFIX}/include/veclib"

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
install -m 0755 ${PKG_NAME} "${PREFIX}/bin"
