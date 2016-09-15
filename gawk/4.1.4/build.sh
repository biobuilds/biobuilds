#!/bin/bash
set -o pipefail


##-------------------------------------------------------------------------
## Configure
##-------------------------------------------------------------------------

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

# Make sure the compiler and linker can find zlib and htslib
CFLAGS="${CFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Architecture-specific options
if [ `uname -m` == 'ppc64le' ]; then
    config_mpfr="--without-mpfr"
else
    config_mpfr="--with-mpfr=${PREFIX}"
fi

env CPPFLAGS="-I${PREFIX}/include" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" \
    --enable-largefile \
    --disable-rpath \
    $config_mpfr \
    --without-readline \
    --without-libiconv-prefix \
    --without-libintl-prefix \
    --without-libsigsegv-prefix \
    2>&1 | tee configure.log


##-------------------------------------------------------------------------
## Build and install
##-------------------------------------------------------------------------

make -j${BB_MAKE_JOBS}
make install
make installcheck
