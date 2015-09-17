#!/bin/bash

# Set "pipefail" shell option so the build stops on configure or make errors;
# without it, bash only sees the "tee" exit codes (which are almost always 0).
set -o pipefail


## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

# Update autoconf files for ppc64le detection
cp -f "${RECIPE_DIR}/config.guess" "${SRC_DIR}/config/config.guess"
cp -f "${RECIPE_DIR}/config.sub" "${SRC_DIR}/config/config.sub"

env CFLAGS="${CFLAGS} $(pkg-config --cflags zlib)" \
    LDFLAGS="${LDFLAGS} $(pkg-config --libs zlib)" \
    ./configure --prefix="${PREFIX}" \
        --enable-static --enable-shared \
        --without-x --without-xpm --without-vpx \
        --without-fontconfig \
        --with-zlib --with-freetype \
        --with-png --with-jpeg --with-tiff \
        2>&1 | tee libgd-config.log


## Build and install
make -j${BB_MAKE_JOBS} install 2>&1 | tee libgd-build.log
