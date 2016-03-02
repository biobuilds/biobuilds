#!/bin/bash

set -o pipefail
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ]  && BB_MAKE_JOBS=1

cd build_unix

# NOTE: Disabling cryptography since this package will be available for
# download by anyone, and we want to avoid any export control issues.
../dist/configure --prefix="$PREFIX" \
    --enable-shared --enable-static --disable-debug \
    --enable-compat185 --disable-tcl \
    --disable-java --disable-jdbc \
    --disable-cxx --disable-stl \
    --with-cryptography=no \
    2>&1 | tee configure.log

make -j${BB_MAKE_JOBS}
make install

cd "$PREFIX"
rm -rf docs
