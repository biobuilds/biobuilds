#!/bin/bash
set -o pipefail

## Configure
build_arch=$(uname -m)
build_os=$(uname -s)

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

# Make sure configure can find zlib and other libraries
CFLAGS="${CFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [ "$build_os" == 'Darwin' ]; then
    # Give install_name_tool enough space to work its magic; if not set,
    # tweaking "long_spanning_reads" binary fails.
    LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

cp -f "${PREFIX}/share/autoconf/config.guess" config.guess
cp -f "${PREFIX}/share/autoconf/config.sub" config.sub

env CFLAGS="${CFLAGS}" CXXFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" --with-boost="${PREFIX}" \
    2>&1 | tee configure.log


## Build. WARNING: Do NOT use "-j" option as it causes cryptic build failures
make 2>&1 | tee build.log


## Install
make install

# Move Python packages to the more standard site-packages directory
mv "${PREFIX}/bin/intervaltree" "${PREFIX}/lib/python${PY_VER}/site-packages"
mv "${PREFIX}/bin/sortedcontainers" "${PREFIX}/lib/python${PY_VER}/site-packages"
