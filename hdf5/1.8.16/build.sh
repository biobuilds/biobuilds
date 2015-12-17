#!/bin/bash

[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1

# Update autoconf files for ppc64le support
cp -f "${PREFIX}/share/autoconf/config.guess" bin/config.guess
cp -f "${PREFIX}/share/autoconf/config.sub" bin/config.sub

# HDF5's build system expects a "lib64" directory on certain architectures
[ -e "${PREFIX}/lib64" ] || (cd "${PREFIX}"; ln -sfn lib lib64)

if [ `uname -s` == 'Darwin' ]; then
    # Needed so the linker, etc. can find libgfortran.dylib
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
fi

#------------------------------------------------------------------------------
# Notes on configure options:
#
# --disable-parallel: Don't use MPI (world of portability & dependency pain)
#
# --enable-unsupported: Needed to support both the high-level API (hl) library
# alongside the thread-safe library. WARNING: the global lock used for thread
# safety is not raised in hl library, so there could be context switch induced
# bugs when using both; for details, refer to the HDF5 1.8.16 release notes:
# https://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.16-RELEASE.txt
#
# --enable-linux-lfs, --enable-largefile: no longer needed, since HDF5 now
# automatically assumes large file (as of release 1.8.15).
#------------------------------------------------------------------------------
./configure --prefix="$PREFIX" \
    --with-default-plugindir="${PREFIX}/share/hdf5" \
    --with-zlib="${PREFIX}" \
    --disable-static --enable-shared \
    --enable-clear-file-buffers \
    --enable-cxx --enable-fortran --disable-fortran2003 \
    --enable-unsupported --enable-hl --enable-threadsafe \
    --disable-parallel --with-pthread \
    --enable-production --disable-debug \
    2>&1 | tee configure.log

make -j${BB_MAKE_JOBS}

# WARNING: not running "make check" due to known problems with certain type
# conversion tests in the "dt_arith" module, when building on OS X or with
# gcc 4.6+ on Linux. Working around these would require dropping to -O1 or -O0,
# and the performance penalty likely won't be worth it to our users. For now,
# stick with default -O2 or -O3, and deal with this problem once we start
# getting bug reports. For details, refer to the HDF5 "Known Problems" page
# (https://www.hdfgroup.org/HDF5/release/known_problems/).
#make check

make install
rm -rf "${PREFIX}/share" "${PREFIX}/lib64"
