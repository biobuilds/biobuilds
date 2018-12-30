#!/bin/bash

command -v pkg-config >/dev/null || \
    { echo "Could not find 'pkg-config' command" >&2; exit 1; }

# Pull in the common BioBuilds build flags
BUILD_ENV="${BUILD_PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment  configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Configure
if [ "$BUILD_ARCH" == "ppc64le" ]; then
    # If veclib headers are present, use those.
    if [[ -d "${BUILD_PREFIX}/include/veclib" ]]; then
        CPPFLAGS="${CPPFLAGS} -I${BUILD_PREFIX}/include/veclib"
        CFLAGS="${CFLAGS} -I${BUILD_PREFIX}/include/veclib"
    # Otherwise, try to use the compiler to translate
    else
        CPPFLAGS="${CPPFLAGS} -DNO_WARN_X86_INTRINSICS"
        CFLAGS="${CFLAGS} -DNO_WARN_X86_INTRINSICS"
    fi

    CFLAGS="${CFLAGS} -fsigned-char"
elif [ "$BUILD_ARCH" != "x86_64" ]; then
    echo "ERROR: Unsupported architecture '$build_arch'" >&2
    exit 1
fi

# Build
env CC="${CC}" CFLAGS="${CFLAGS}" \
    LD="${LD}" LDFLAGS="${LDFLAGS}" \
    make -j${MAKE_JOBS} all

# Install
mkdir -p "${PREFIX}/bin" "${PREFIX}/lib" "${PREFIX}/include/${PKG_NAME}"
install -m 755 ${PKG_NAME} "${PREFIX}/bin"
install -m 644 lib${PKG_NAME}.a "${PREFIX}/lib"
install -m 644 *.h "${PREFIX}/include/${PKG_NAME}"
