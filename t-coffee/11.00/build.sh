#!/bin/bash

# Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="-Wall ${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

if [ `uname -m` == 'ppc64le' ]; then
    CFLAGS="${CFLAGS} -fsigned-char"
fi

# Squash "deprecated conversion from string constant to 'char*'" warnings
CFLAGS="-Wno-write-strings ${CFLAGS}"

# Make sure all perl scripts are executable; needed since files from the GitHub
# tarballs don't always have the right permissions, and the build process needs
# some of these scripts to run correctly.
find . -name '*.pl' | xargs chmod 0755

# Build
cd compile
make VERSION="${PKG_VERSION}" OPENMP=1 CFLAGS="${CFLAGS}" t_coffee

# Install
install -d "${PREFIX}/bin"
install -m 0755 t_coffee "${PREFIX}/bin"
