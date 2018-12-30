#!/bin/bash
set -o pipefail

## Configure

# Pull in the common BioBuilds build flags
BUILD_ENV="${BUILD_PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

case "$HOST_ARCH" in
    'ppc64le')
        # If veclib headers are present, use those.
        if [[ -d "${BUILD_PREFIX}/include/veclib" ]]; then
            CPPFLAGS="${CPPFLAGS} -I${BUILD_PREFIX}/include/veclib"
            CFLAGS="${CFLAGS} -I${BUILD_PREFIX}/include/veclib"
            CXXFLAGS="${CXXFLAGS} -I${BUILD_PREFIX}/include/veclib"
        # Otherwise, try to use the compiler to translate
        else
            CPPFLAGS="${CPPFLAGS} -DNO_WARN_X86_INTRINSICS"
            CFLAGS="${CFLAGS} -DNO_WARN_X86_INTRINSICS"
            CXXFLAGS="${CXXFLAGS} -DNO_WARN_X86_INTRINSICS"
        fi

        # Just in case, tell the POWER compiler to assume to the same
        # signedness for plain chars as the x86_64 compiler.
        CFLAGS="${CFLAGS} -fsigned-char"
        CXXFLAGS="${CXXFLAGS} -fsigned-char"
        ;;
esac


## Build
make clean
make -j${MAKE_JOBS} V=1 \
    CPP="${CPP}" \
    CC="${CC}" \
    CXX="${CXX}" \
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
