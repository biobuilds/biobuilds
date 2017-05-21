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

case "$BUILD_ARCH" in
    'ppc64le')
        # Should be provided by the "veclib-headers" package
        [ -d "${PREFIX}/include/veclib" ] || \
            { echo "ERROR: could not find veclib headers" >&2; exit 1; }
        CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include/veclib"

        # Just in case, tell the POWER compiler to assume to the same
        # signedness for plain chars as the x86_64 compiler.
        CXXFLAGS="${CXXFLAGS} -fsigned-char"
        ;;
esac


## Build
make clean
make -j${MAKE_JOBS} \
    CC="${CC}" CXX="${CXX}" \
    RELEASE_FLAGS="${CXXFLAGS}" \
    2>&1 | tee build.log


## Install
mkdir -p "${PREFIX}/bin"
sed -ibak "1s|^.*$|#!${PREFIX}/bin/perl|;" hisat2
sed -ibak "1s|^.*$|#!${PREFIX}/bin/python|;" hisat2-build hisat2-inspect
install -m 755 \
    hisat2 hisat2-align-l hisat2-align-s \
    hisat2-build hisat2-build-l hisat2-build-s \
    hisat2-inspect hisat2-inspect-l hisat2-inspect-s \
    "${PREFIX}/bin"
