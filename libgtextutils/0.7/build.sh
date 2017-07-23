#!/bin/bash

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

cp -f "${PREFIX}/share/autoconf/config.guess" config/config.guess
cp -f "${PREFIX}/share/autoconf/config.sub" config/config.sub

if [ `uname -s` == 'Darwin' ]; then
    # Needed to ensure libgcc is found when running "make check"
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
fi

env CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" \
    --enable-wall --disable-debug \
    --with-pic --enable-shared --enable-static \
    2>&1 | tee configure.log
make -j${MAKE_JOBS}
make check

make install

# Fix issue where headers get installed one level too deep
cd "${PREFIX}/include/gtextutils"
mv gtextutils/*.h gtextutils/*.hpp .
rmdir gtextutils
