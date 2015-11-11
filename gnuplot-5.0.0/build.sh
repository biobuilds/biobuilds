#!/bin/bash
set -o pipefail

## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

# Hack to work around missing termcap when building on certain platforms
# (mostly x86_64 Linux); ensures that certain symbols ('tputs', 'tgetstr',
# etc.) are defined when linking to libreadline.so. For details, see:
# https://github.com/ContinuumIO/anaconda-issues/issues/152
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -lncurses"
if [ `uname -s` == 'Darwin' ]; then
    export DYLD_LIBRARY_PATH="${PREFIX}/lib"
else
    export LD_LIBRARY_PATH="${PREFIX}/lib"
fi

env CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" \
    --enable-largefile --enable-plugins \
    --without-tutorial \
    --without-x --disable-x11-mbfonts --disable-x11-external \
    --disable-wxwidgets --without-qt \
    --without-aquaterm --without-linux-vga \
    --without-latex --without-lua \
    --without-bitmap-terminals \
    --without-cairo \
    --without-pdf \
    --with-readline="${PREFIX}" \
    --with-gd="${PREFIX}" \
    2>&1 | tee configure.log


## Build
make -j${BB_MAKE_JOBS} 2>&1 | tee build.log


## Install
make install
