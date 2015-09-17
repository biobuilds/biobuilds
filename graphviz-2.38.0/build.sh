#!/bin/bash

# Set "pipefail" shell option so the build stops on configure or make errors;
# without it, bash only sees the "tee" exit codes (which are almost always 0).
set -o pipefail

# On OSX, need to set DYLD_LIBRARY_PATH so gd can be found by build process;
# otherwise, "gd" plugin will not be configured in the package's config6 file.
[ `uname -s` == 'Darwin' ] && export DYLD_LIBRARY_PATH="${PREFIX}/lib"


## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

# Update autoconf files for ppc64le detection
cp -f "${RECIPE_DIR}/config.guess" "${SRC_DIR}/config/config.guess"
cp -f "${RECIPE_DIR}/config.sub" "${SRC_DIR}/config/config.sub"
cp -f "${RECIPE_DIR}/config.guess" "${SRC_DIR}/libltdl/config/config.guess"
cp -f "${RECIPE_DIR}/config.sub" "${SRC_DIR}/libltdl/config/config.sub"

env CFLAGS="${CFLAGS}" CXXFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" \
        --enable-static --enable-shared \
        --enable-ltdl --enable-ltdl-install \
        --disable-swig \
        --disable-sharp --disable-go --disable-guile --disable-io \
        --disable-lua --disable-ocaml --disable-tcl \
        --disable-java --disable-r --disable-python \
        --disable-perl --disable-php --disable-ruby \
        --without-gdiplus --without-quartz \
        --without-x --without-qt --without-gtk --without-glade \
        --without-gdk --without-glut \
        --with-gd --with-freetype2 --without-fontconfig \
        --without-expat --without-rsvg \
        --without-devil --without-pangocairo \
        --without-wish --without-ming --without-webp \
        --without-poppler --without-ghostscript \
        --without-visio \
        --without-lasi --without-glitz \
        --without-gts --without-ann \
        --with-sfdp --without-smyrna --with-ortho --with-digcola \
        --without-ipsepcola \
        2>&1 | tee graphviz-config.log


## Build and install
make -j${BB_MAKE_JOBS} V=1 install 2>&1 | tee graphviz-build.log
