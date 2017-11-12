#!/bin/bash

set -o pipefail

# As of Mac OS 10.8, X11 is no longer included by default.
# (See https://support.apple.com/en-us/HT201341 for the details).
# Due to this change, we disable building X11 support for cairo on OS X by # default.
if [[ `uname -s` = 'Darwin' ]]; then
    # Raw LDFLAGS get passed via the compile and cause warnings. The linker tests break
    # when there are warnings for some weird reason, (-pie is the cuplrit).
    export LDFLAGS=${LDFLAGS_CC}
fi

# Most other autotools-based build systems add
# prefix/include and prefix/lib automatically!
export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

./configure --prefix="${PREFIX}"  \
    --enable-shared \
    --enable-static \
    --enable-pthread \
    --disable-gtk-doc \
    --enable-ft \
    --enable-fc \
    --enable-png \
    --enable-svg \
    --enable-ps \
    --enable-pdf \
    --disable-directfb \
    --disable-gl \
    --disable-glx \
    --disable-qt \
    $XWIN_ARGS \
    2>&1 | tee configure.log

make -j${CPU_COUNT} ${VERBOSE_AT}
# FAIL: check-link on OS X
# Hangs for > 10 minutes on Linux
# make check
make install
