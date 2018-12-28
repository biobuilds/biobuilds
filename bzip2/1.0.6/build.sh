#!/bin/sh

# Pull in the common BioBuilds build flags
BUILD_ENV="${BUILD_PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Make sure we generate position independent code so `libbz2.a` can be used by
# other recipes to generate shared libraries (.so/.dylib).
CFLAGS="${CFLAGS} -fPIC"

# Replace the upstream flags we'd squash with ours
CFLAGS="${CFLAGS} -Wall -Winline -D_FILE_OFFSET_BITS=64"

make install V=1 \
    PREFIX="${PREFIX}" \
    CC="${CC}" \
    AR="${AR}" \
    RANLIB="${RANLIB}" \
    CFLAGS="${CFLAGS}" \
    LDFLAGS="${LDFLAGS}"

# build shared library
case "$BUILD_OS" in
    "linux")
        make -f Makefile-libbz2_so V=1 \
            CC="${CC}" \
            AR="${AR}" \
            RANLIB="${RANLIB}" \
            CFLAGS="${CFLAGS}" \
            LDFLAGS="${LDFLAGS}"
        ln -s libbz2.so.${PKG_VERSION} libbz2.so
        cp -fv -d libbz2.so* ${PREFIX}/lib/
        ;;
    "darwin")
        "${CC}" \
            -shared -Wl,-install_name \
            -Wl,libbz2.dylib \
            -o libbz2.${PKG_VERSION}.dylib \
            ${LDFLAGS} \
            blocksort.o huffman.o crctable.o randtable.o compress.o decompress.o bzlib.o
        cp -fv libbz2.${PKG_VERSION}.dylib ${PREFIX}/lib/
        ln -s libbz2.${PKG_VERSION}.dylib ${PREFIX}/lib/libbz2.dylib
        ;;
    *)
        echo "FATAL: unsupported operating system '${BUILD_OS}'" >&2
        exit 1
        ;;
esac
