#!/bin/sh

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# toolchain flags + bzip flags + fpic
export CFLAGS="${CFLAGS} -Wall -Winline -D_FILE_OFFSET_BITS=64 -fPIC"
USED_CC=${GCC:-${CC}}
make install PREFIX="${PREFIX}" \
    CFLAGS="${CFLAGS}" CC="${USED_CC}" AR="${AR}"

# build shared library
case "$BUILD_OS" in
    "linux")
        make -f Makefile-libbz2_so \
            CFLAGS="${CFLAGS}" CC="${USED_CC}" AR="${AR}"
        ln -s libbz2.so.${PKG_VERSION} libbz2.so
        cp -fv -d libbz2.so* ${PREFIX}/lib/
        ;;
    "darwin")
        ${USED_CC} \
            -shared -Wl,-install_name \
            -Wl,libbz2.dylib \
            -o libbz2.${PKG_VERSION}.dylib \
            blocksort.o huffman.o crctable.o randtable.o compress.o decompress.o bzlib.o
        cp -fv libbz2.${PKG_VERSION}.dylib ${PREFIX}/lib/
        ln -s libbz2.${PKG_VERSION}.dylib ${PREFIX}/lib/libbz2.dylib
        ;;
    *)
        echo "FATAL: unsupported operating system '${BUILD_OS}'" >&2
        exit 1
        ;;
esac
