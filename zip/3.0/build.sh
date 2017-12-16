#!/bin/bash

set -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Copying the needed bzip2 files over seems way easier than trying to convince
# zip's build system to look in ${PREFIX}/include and ${PREFIX}/lib.
cp -fv "${PREFIX}/include/bzlib.h" "${SRC_DIR}/bzip2"
cp -fv "${PREFIX}/lib/libbz2.a" "${SRC_DIR}/bzip2"

# Replace the original CFLAGS we squash by supplying ours to `configure`
CFLAGS="${CFLAGS} -Wall -I. -DUNIX"

# Enable mmap() calls for faster compression (at the cost of more memory used)
#
# ** WARNING **: Do NOT actually enable; doing so causes compilation to fail
# with "'Bytef' undeclared" errors in "zipup.c".
#CFLAGS="${CFLAGS} -DMMAP"

# `configure` should automatically enable support for 64-bit file system calls
# (-DLARGE_FILE_SUPPORT), but we must explicitly enable tell the build system
# we want binaries that support archive operations on large (>4-GiB) files.
CFLAGS="${CFLAGS} -DZIP64_SUPPORT"

# `configure` should automatically enable support for UTF-8 paths since all the
# platforms/compilers we support have a wide character (wchar_t) type.
#CFLAGS="${CFLAGS} -DUNICODE_SUPPORT"

# Store univeral time in an extra field so zip/unzip don't have problems when
# files move across time  zones or when daylight savings time changes.
CFLAGS="${CFLAGS} -DUSE_EF_UT_TIME"

LDFLAGS="${LDFLAGS}" sh unix/configure "${CC}" "${CFLAGS}"

make -f unix/Makefile generic

make -f unix/Makefile install prefix="${PREFIX}"
rm -rf "${PREFIX}/man"
