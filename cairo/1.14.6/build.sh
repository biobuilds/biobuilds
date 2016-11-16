#!/bin/bash

# Since we control what's installed in our build VMs/containers, let
# "./configure" discover the right set of --enable/--disable options for X11
# and OS X Quartz support. Doing this is a lot easier than trying to remember
# how the various X11 packages interact with/depend on each other.

env CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include" \
    LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" \
    ./configure --prefix="${PREFIX}" \
    --enable-shared \
    --disable-static \
    --enable-largefile \
    --disable-gtk-doc \
    --disable-gtk-doc-html \
    --disable-gtk-doc-pdf \
    --enable-ft \
    --enable-fc \
    --enable-png \
    --enable-svg \
    --enable-ps \
    --enable-pdf \
    --disable-drm \
    --disable-directfb \
    --disable-gl \
    --disable-glx \
    --disable-qt \
    2>&1 | tee configure.log

make -j${CPU_COUNT}

make install
rm -rf "${PREFIX}/share"
