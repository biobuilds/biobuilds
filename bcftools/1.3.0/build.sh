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

# Make sure the compiler and linker can find htslib
CFLAGS="${CFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Platform-specific tweaks
if [ "$build_arch" == "ppc64le" ]; then
    # Force the ppc64le compiler to make the same assumptions about "plain"
    # char declarations (i.e., those w/o explicit sign) as the x86_64 compiler
    CFLAGS="${CFLAGS} -fsigned-char"
fi
if [ "$build_os" == 'Darwin' ]; then
    # Give install_name_tool enough space to work its magic; if not set,
    # tweaking the plugin shared libraries fails.
    LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi


##-------------------------------------------------------------------------
## Build
##-------------------------------------------------------------------------

# Fix perl "#!" lines so conda knows to munge paths on install
for fn in $(grep '^MISC_PROGRAMS =' Makefile | cut -d' ' -f3-); do
    echo "#!${PREFIX}/bin/perl -w" > f
    sed -n '2,$p' "$fn" >> f
    mv -f f "$fn"
    chmod 0755 "$fn"
done

# Build and test C components
env CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    make -j${BB_MAKE_JOBS} HTSDIR="${PREFIX}" prefix="${PREFIX}" all \
    2>&1 | tee build.log
env LD_LIBRARY_PATH="${PREFIX}/lib" \
    DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib" \
    make HTSDIR="${PREFIX}" prefix="${PREFIX}" test \
    2>&1 | tee test.log


##-------------------------------------------------------------------------
## Install
##-------------------------------------------------------------------------

make HTSDIR="${PREFIX}" prefix="${PREFIX}" install
