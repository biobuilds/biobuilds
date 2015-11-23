#!/bin/bash

command -v pkg-config >/dev/null || \
    { echo "Could not find 'pkg-config' command" >&2; exit 1; }


## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

# Update autoconf files for ppc64le detection
cp -f "${RECIPE_DIR}/config.guess" "${SRC_DIR}/config/config.guess"
cp -f "${RECIPE_DIR}/config.sub" "${SRC_DIR}/config/config.sub"

# Force clang to use GNU89 inline semantics; otherwise, we'll end up with a
# bunch of undefined symbols when building.
if [[ $(gcc -v 2>&1 | grep -ci clang) -gt 0 ]]; then
    CFLAGS="${CFLAGS} -std=gnu89"
fi

env CFLAGS="${CFLAGS} $(pkg-config --cflags zlib)" \
    LDFLAGS="${LDFLAGS} $(pkg-config --libs zlib)" \
    ./configure --prefix="${PREFIX}" \
    --enable-intel64 --enable-largefile \
    --disable-bzlib


## Build
make -j${BB_MAKE_JOBS} all


## Install
make install
rm -f "${PREFIX}/bin/bfast.submit.pl" "${PREFIX}/bin/bfast.resubmit.pl"
