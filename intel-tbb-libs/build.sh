#!/bin/bash
set -o pipefail

# Match the default compiler used in the x86_64 Linux build container
: ${GCC_VER:=4.4}

BASE_DIR="opt/intel/compilers_and_libraries_${PKG_VERSION}"
LIB_DIR="${BASE_DIR}/linux/tbb/lib/intel64/gcc${GCC_VER}"


for fn in rpm/*.rpm; do
    echo "Extracting `basename "$fn"`"
    rpm2cpio "$fn" | cpio -idm
done
if [ ! -d "${LIB_DIR}" ]; then
    echo "Could not find expected library directory!" >&2
    exit 1
fi

mkdir -p "${PREFIX}/lib"
cd "${LIB_DIR}"
cp -fvp libtbb*.so.* "${PREFIX}/lib"

cd "${PREFIX}/lib"
rm -f *_debug.so.*
for fn in libtbb*.so.*; do
    ln -s "${fn}" "${fn/.so*/.so}"
done
