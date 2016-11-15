#!/bin/bash
set -o pipefail


##-------------------------------------------------------------------------
## Configure
##-------------------------------------------------------------------------

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
#CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

# Make sure the compiler and linker can find zlib and htslib
CFLAGS="${CFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Platform-specific tweaks
if [ `uname -m` == 'ppc64le' ]; then
    # Force the ppc64le compiler to make the same assumptions about "plain"
    # char declarations (i.e., those w/o explicit sign) as the x86_64 compiler
    CFLAGS="${CFLAGS} -fsigned-char"
fi

env CPPFLAGS="-I${PREFIX}/include" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" --with-htslib=system \
    --without-curses --without-ncursesw \
    2>&1 | tee configure.log


##-------------------------------------------------------------------------
## Build
##-------------------------------------------------------------------------

# Fix perl "#!" lines so conda knows to munge paths on install
pushd "${SRC_DIR}/misc"
for fn in *.pl; do
    echo "#!${PREFIX}/bin/perl -w" > f
    sed -n '2,$p' "$fn" >> f
    mv -f f "$fn"
    chmod 0755 "$fn"
done
popd

# Build and test C components
make -j${BB_MAKE_JOBS} 2>&1 | tee build.log
env LD_LIBRARY_PATH="${PREFIX}/lib" \
    DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib" \
    make test 2>&1 | tee test.log


##-------------------------------------------------------------------------
## Install
##-------------------------------------------------------------------------

make install
