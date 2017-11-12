#!/bin/bash

set -e -o pipefail

BUILD_ARCH=`uname -m`
BUILD_OS=`uname -s`

case "${BUILD_OS}" in
    Darwin)
        export CC=clang
        export CXX=clang++
        export MACOSX_DEPLOYMENT_TARGET
        export CXXFLAGS="-stdlib=libc++ $CXXFLAGS"
        export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"
        export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
        ;;
    Linux)
        export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
        ;;
    *)
        echo "Unsupported operating system '${BUILD_OS}'" >&2
        exit 1
        ;;
esac


# CircleCI seems to have some weird issue with harfbuzz tarballs. The files
# come out with modification times such that the build scripts want to rerun
# automake, etc.; we need to run it ourselves since we don't have the precise
# version that the build scripts embed. And the 'configure' script comes out
# without its execute bit set. In a Docker container running locally, these
# problems don't occur.

#autoreconf --force --install
#chmod +x configure

./configure --prefix=${PREFIX} \
            --enable-shared \
            --enable-static \
            --disable-gtk-doc \
            --disable-gtk-doc-html \
            --disable-gtk-doc-pdf \
            --with-glib=yes \
            --with-cairo=yes \
            --with-fontconfig=yes \
            --with-icu=yes \
            --with-graphite2=yes \
            --with-freetype=yes \
            --with-gobject=yes \
            2>&1 | tee configure.log

make -j${CPU_COUNT} ${VERBOSE_AT}
# FIXME
# OS X:
# FAIL: test-ot-tag
# Linux (all the tests pass when using the docker image :-/)
# FAIL: check-c-linkage-decls.sh
# FAIL: check-defs.sh
# FAIL: check-header-guards.sh
# FAIL: check-includes.sh
# FAIL: check-libstdc++.sh
# FAIL: check-static-inits.sh
# FAIL: check-symbols.sh
# PASS: test-ot-tag
#eval ${LIBRARY_SEARCH_VAR}="${PREFIX}/lib" make check
make install

rm -rf "${PREFIX}/gtk-doc"
