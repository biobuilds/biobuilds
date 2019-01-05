#!/bin/bash
set -o pipefail

## Configure
BUILD_ENV="${BUILD_PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment  configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

case "$HOST_OS" in
    "darwin")
        #CFLAGS="${CFLAGS} -Wno-deprecated-register -Wno-unused-variable"
        #CXXFLAGS="${CXXFLAGS} -Wno-deprecated-register -Wno-unused-variable"
        ;;
    "linux")
        # Need this, or the build may fail with an "undefined reference to
        # symbol 'clock_gettime@@GLIBC_2.2.5'" error.
        export LIBS="-lrt"
        ;;
    *)
        echo "FATAL: unsupported operating system '$HOST_OS'" >&2
        exit 1
        ;;
esac

# Could do this using `pkg-config`, but that seems excessive...
CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include/eigen3"

# Update so `./configure` knows how to deal with newer systems
cp -fv "${BUILD_PREFIX}/share/autoconf/config.guess" "build-aux/config.guess"
cp -fv "${BUILD_PREFIX}/share/autoconf/config.sub" "build-aux/config.sub"

[ -f Makefile ] && make distclean
./configure --prefix="${PREFIX}" \
    --with-zlib="${PREFIX}" \
    --with-boost="${PREFIX}" \
    --with-eigen="${PREFIX}" \
    --with-bam="${PREFIX}" \
    2>&1 | tee configure.log

# `./configure` above seems very insistent on adding `-I/usr/include` to our
# compiler flags. Unfortunately, this horribly breaks our clang's (and possibly
# gcc's) ability to compile files that use Boost (lots of "no member" errors
# related to math functions), so we need to remove the flag from our Makefiles.
sed -i.bak 's,-I/usr/include, ,g' Makefile src/Makefile

## Build
make -j${MAKE_JOBS} 2>&1 | tee build.log

## Install
make install-strip
