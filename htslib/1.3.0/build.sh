#!/bin/bash
set -o pipefail


##-------------------------------------------------------------------------
## Configure
##-------------------------------------------------------------------------

build_arch=$(uname -m)
build_os=$(uname -s)

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

# Make sure the compiler and linker can find zlib
CFLAGS="${CFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Platform-specific tweaks
if [ "$build_arch" == 'ppc64le' ]; then
    # Force the ppc64le compiler to make the same assumptions about "plain"
    # char declarations (i.e., those w/o explicit sign) as the x86_64 compiler
    CFLAGS="${CFLAGS} -fsigned-char"
fi
if [[ "$build_arch" == 'x86_64' && "$build_os" == 'Linux' ]]; then
    # Don't unroll loops on x86_64 Linux as something in the way gcc 4.4 (the
    # system compiler on CentOS 6) does this breaks things for dependent
    # packages in a way that isn't caught by "make test" below. Specifically,
    # it causes "test_vcf_annotate" in bcftools to generate unexpected NaNs in
    # its "annotate4.out" output file. Note that this problem doesn't happen
    # with gcc 4.8, but it seems silly to add a gcc/libgcc dependency to our
    # recipe just for an optimization flag whose benefit hasn't been proved.
    CFLAGS="${CFLAGS/-funroll-loops/}"
fi

# Not enabling plugins as the plugin install paths seem to be hard-coded into
# the binaries and libraries, and that will require some conda path munging
# that we don't have the time/ability to test right now.
env CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" \
    ./configure --prefix="$PREFIX" --enable-libcurl --disable-plugins \
    2>&1 | tee configure.log


##-------------------------------------------------------------------------
## Build
##-------------------------------------------------------------------------

make -j${BB_MAKE_JOBS} 2>&1 | tee build.log
env LD_LIBRARY_PATH="${PREFIX}/lib" \
    DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib" \
    make test 2>&1 | tee test.log


##-------------------------------------------------------------------------
## Install
##-------------------------------------------------------------------------

make install
