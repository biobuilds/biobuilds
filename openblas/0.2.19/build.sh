#!/bin/bash
set -o pipefail

build_arch=$(uname -m)
build_os=$(uname -s)
dylib_ext="so"

[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
OTHER_OPTS=

if [ "$build_arch" == "ppc64le" ]; then
    # POWER8 is the only POWER architecture conda supports
    TARGET="TARGET=POWER8"

    # IBM POWER Linux servers support up to 2 20-core, SMT8-enabled CPUs, for a
    # theoretical maximum of 320 threads. However, the OpenBLAS README.md
    # suggests limiting the number of CPUs/cores (threads) to 256, as more
    # would require still-experimental BIGNUMA support.
    MAX_THREADS=256

    # Needed so "make tests" uses the "correct" libgfortran.so.
    #export LD_LIBRARY_PATH="${PREFIX}/lib"

    # "Dynamic arch" library not built (nor supported) on POWER8
    unset OPENBLAS_CORETYPE
elif [ "$build_arch" == "x86_64" ]; then
    # Build a version of "DYNAMIC_ARCH" library for x86_64 with certain
    # microarchitectures (e.g., 32-bit, low-power mobile/embedded, or older
    # than Nehalem) removed. This lets users benefit from better optimizations
    # if their CPUs support them, while reducing the size of the conda package
    # we produce. For comparison:
    #   - Nehalem-only: 7-MB package, 38-MB installed
    #   - DYNAMIC_ARCH=1, limited: 10-MB package, 52-MB installed (ours)
    #   - DYNAMIC_ARCH=1, all: 15-MB package, 92-MB installed
    #TARGET="TARGET=NEHALEM"
    TARGET="DYNAMIC_ARCH=1"

    if [ "$build_os" == "Darwin" ]; then
        # Theoretical maximum number of threads on Apple hardware is 24
        # (12-core HT-enabled Xeon available on top-end Mac Pros). However,
        # seems reasonable to assume that the *vast* majority of users will be
        # on MacBooks, iMacs, and Mac Minis, and we should limit ourselves to
        # the CPUs present in those systems (2- or 4-core, HT-enabled CPUs).
        MAX_THREADS=8

        dylib_ext="dylib"

        # Needed so "make tests" can find and us the "correct" libgfortran.so.
        export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"

        # Force use of Nehalem kernel if specific microarchitecture is not
        # specified before running "conda build". Without this, architecture
        # detection will likely fail when building in an OS X VM; refer to
        # the comment block in "meta.yaml" for details.
        if [ "$OPENBLAS_CORETYPE" == "<UNDEFINED>" ]; then
            export OPENBLAS_CORETYPE="Nehalem"
        fi

        # Skip building the OS X dynamic library, as there's a bug that causes
        # BLAS tests to fail with "** On entry to <function> parameter number
        # <n> had an illegal value" when using the dynamic library.
        OTHER_OPTS="NO_SHARED=1"
    elif [ "$build_os" == "Linux" ]; then
        # Wide variety of x86_64 Linux systems out there, so it's hard to make
        # a good guess as to what a "reasonable" value should be. For now,
        # assume a mid-range, 2-socket server with 12-core, HT-enabled Xeons.
        MAX_THREADS=48

        # Needed so "make tests" can find and us the "correct" libgfortran.so.
        export LD_LIBRARY_PATH="${PREFIX}/lib"

        # Architecture-detection seems to work on Linux (both native & in VMs),
        # so no need to force a specific one. Doing this instead of assuming
        # Nehalem so we can use "make tests" to ensure arch. detection works.
        if [ "$OPENBLAS_CORETYPE" == "<UNDEFINED>" ]; then
            unset OPENBLAS_CORETYPE
        fi
    else
        echo "ERROR: Unsupported $build_arch OS '$build_os'!" >&2
        exit 1
    fi
else
    echo "ERROR: '$build_arch' is not a supported architecture family!" >&2
    exit 1
fi

# Unset compiler flag environment variables, or the OpenBLAS build system will
# get really confused (duplicates contents of the CCOMMON_OPT make variable).
unset CFLAGS CXXFLAGS FCFLAGS


#
# NOTE: Explicitly pass CC and FC to make so OpenBLAS doesn't revert to its
# default compiler; this stops its build build system from assuming that we're
# using clang on OS X, even when the "gcc" invoked through $PATH is really GCC.
#
# NOTE: Must set INTERFACE64 to 0 so the assumed int size is 32-bits, and *NOT*
# 64-bits. Done because all our target platforms assume this (i.e., use the
# LP64, not the ILP64, programming model), and assuming 64-bit ints would break
# compatibility with lots of other software. (Basically we'd have to recompile
# all FORTRAN programs with "-fdefault-integer-8", and getting software that
# uses a C/FORTRAN interface to work correctly would be unbelievably painful.)
#
# NOTE: Must compile with NO_AFFINITY=1. Enabling CPU affinity (i.e., setting
# NO_AFFINITY=0) breaks compatibility with R and NumPy in a very, very bad way.
# Refer to the OpenBLAS README.md for details.
#
make -j${BB_MAKE_JOBS} \
    CC="$(command -v gcc)" FC="$(command -v gfortran)" \
    "$TARGET" BINARY=64 INTERFACE64=0 NO_AFFINITY=1 \
    USE_OPENMP=1 USE_THREAD=1 NUM_THREADS=$MAX_THREADS $OTHER_OPTS \
    2>&1 | tee build.log

make tests \
    CC="$(command -v gcc)" FC="$(command -v gfortran)" \
    "$TARGET" BINARY=64 INTERFACE64=0 NO_AFFINITY=1 \
    USE_OPENMP=1 USE_THREAD=1 NUM_THREADS=$MAX_THREADS $OTHER_OPTS \
    2>&1 | tee tests.log

make PREFIX="$PREFIX" $OTHER_OPTS install


# OpenBLAS cmake support still experimental, so remove associated files
rm -rf "${PREFIX}/lib/cmake"


# OpenBLAS contains all the BLAS and LAPACK symbols, so we can safely symlink
# its libraries to standard names to make life easier for other developers.
cd "${PREFIX}/lib"
ln -sf libopenblas.a libblas.a
ln -sf libopenblas.a liblapack.a
if [ "$build_os" != "Darwin" ]; then
    ln -sf libopenblas.${dylib_ext} libblas.${dylib_ext}
    ln -sf libopenblas.${dylib_ext} liblapack.${dylib_ext}
fi
