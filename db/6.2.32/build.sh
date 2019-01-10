#!/bin/bash
set -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${BUILD_PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment  configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

cd build_unix

../dist/configure \
    --prefix="$PREFIX" \
    --enable-shared \
    --disable-static \
    --with-pic \
    --disable-debug \
    --enable-compat185 \
    --enable-dbm \
    --disable-cxx \
    --disable-stl \
    --disable-sql \
    --disable-java \
    --disable-jdbc \
    --disable-tcl \
    --enable-localization \
    --with-cryptography=yes \
    2>&1 | tee configure.log

make -j${MAKE_JOBS}
make install

cd "$PREFIX"
rm -rf docs
