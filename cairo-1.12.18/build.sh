#!/bin/bash

cp -fv "${PREFIX}/share/autoconf/config.guess" build/config.guess
cp -fv "${PREFIX}/share/autoconf/config.sub" build/config.sub

# Re-run autoconf on POWER8 to avoid an "Invalid configuration `make':
# machine `make' not recognized" error.
if [ $(uname -m) == 'ppc64le' ]; then
    autoreconf --install
fi

# Should we disable X11 support?
env CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include" \
    LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" \
    ./configure --prefix="${PREFIX}" \
    --enable-shared --disable-static --enable-largefile \
    --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf \
    --enable-xlib --enable-xlib-xrender --disable-xcb \
    --enable-ft --enable-fc \
    --enable-png --enable-svg \
    --enable-ps --enable-pdf \
    --disable-drm --disable-directfb --disable-gl --disable-glx \
    --disable-qt --disable-quartz

make -j${CPU_COUNT}

make install
rm -rf "${PREFIX}/share"
