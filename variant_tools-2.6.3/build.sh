#!/bin/bash

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

# TODO: Replace and use BioBuilds version of boost and GSL
# (copies included in upstream sources are for obsolete API.)
#rm -rf gsl boost_1_*_0

# Make sure build process can find needed headers and shared libs
CFLAGS="-I${PREFIX}/include ${CFLAGS}"
LDFLAGS="-L${PREFIX}/lib ${LDFLAGS}"

env CFLAGS="${CFLAGS}" CXXFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    "$PYTHON" setup.py install

# Strip shared libs to significantly reduce the package size
cd "${PREFIX}/lib/python2.7/site-packages/${PKG_NAME}"
strip *.so
