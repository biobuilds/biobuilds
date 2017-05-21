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
        # Just in case, tell the POWER compiler to assume to the same
        # signedness for plain chars as the x86_64 compiler.
        CXXFLAGS="${CXXFLAGS} -fsigned-char"
        ;;
esac

LIBS="-lpthread -lz"

make -j${MAKE_JOBS} \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS}" \
    LINKFLAGS="${LDFLAGS} ${LIBS}" \
    2>&1 | tee build.sh

mkdir -p "${PREFIX}/bin"
install -m 755 lighter "${PREFIX}/bin"
