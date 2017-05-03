#!/bin/bash

# Common build options (should be provided by the "biobuilds-build" package
source "${PREFIX}/share/biobuilds-build/build.env"

# Update autoconf files for ppc64le detection
cp -f "${RECIPE_DIR}/config.guess" "${SRC_DIR}/config.guess"
cp -f "${RECIPE_DIR}/config.sub" "${SRC_DIR}/config.sub"

env CC="${CC}" CFLAGS="${CFLAGS}" \
    CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    LD="${LD}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}"


## Build and install
make -j${MAKE_JOBS} install
