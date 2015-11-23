#!/bin/bash


## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

# Update autoconf files for ppc64le detection
cp -f "${RECIPE_DIR}/config.guess" "${SRC_DIR}/config.guess"
cp -f "${RECIPE_DIR}/config.sub" "${SRC_DIR}/config.sub"

env CFLAGS="${CFLAGS}" CXXFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}"


## Build and install
make -j${BB_MAKE_JOBS} install
