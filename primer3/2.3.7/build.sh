#!/bin/bash
set -o pipefail


##-------------------------------------------------------------------------
## "Configure"
##-------------------------------------------------------------------------

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

# Platform-specific tweaks
if [ `uname -m` == 'ppc64le' ]; then
    # Force the ppc64le compiler to make the same assumptions about "plain"
    # char declarations (i.e., those w/o explicit sign) as the x86_64 compiler
    CFLAGS="${CFLAGS} -fsigned-char"
fi


##-------------------------------------------------------------------------
## Build, test, and install
##-------------------------------------------------------------------------

cd src
make -j${BB_MAKE_JOBS} CFLAGS="${CFLAGS} -D__USE_FIXED_PROTOTYPES__"

cd ../test
make

cd ../src
make PREFIX="${PREFIX}" install
