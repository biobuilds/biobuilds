#!/bin/bash
set -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v


# Array of build configuration options to pass to `make`.
declare -a build_opts

# Build the release (non-debug) version
build_opts+=(DEBUG=0)

# Build 64-bit binaries
build_opts+=(BINARY=64)

# ** NOTE **: _Must_ set INTERFACE64=0 so the assumed int size is 32-bits, and
# *NOT* 64-bits. Done because all our target platforms assume this (i.e., use
# the LP64, not the ILP64, programming model), and letting OpenBLAS assume
# 64-bit ints would break compatibility with lots of other software. (Basically
# we'd have to recompile all FORTRAN programs with "-fdefault-integer-8", and
# getting software that uses a C interface with FORTRAN libraries to work
# correctly would be unbelievably painful.)
build_opts+=(INTERFACE64=0)

# Force build a threaded BLAS library
build_opts+=(USE_THREAD=1)

# Our threaded BLAS should use OpenMP
build_opts+=(USE_OPENMP=1)

# ** NOTE **: _Must_ disable CPU and memory affinity. Enabling CPU affinity
# (i.e., setting NO_AFFINITY=0) breaks compatibility with R and NumPy in a
# very, very bad way. Refer to the OpenBLAS README.md for details.
build_opts+=(NO_AFFINITY=1)

# If any *GEMM arguments m, n or k is less or equal this threshold, *GEMM will
# execute on single thread to avoid the overhead of multi-threading in small
# matrix sizes. The default value is 4.
build_opts+=(GEMM_MULTITHREAD_THRESHOLD=4)

# If uncommented, disable building FORTRAN and C BLAS interfaces
#build_opts+=(ONLY_CBLAS=1)
#build_opts+=(NO_CBLAS=1)

# If uncommented, disable building FORTRAN and C LAPACK interfaces
#build_opts+=(NO_LAPACK=1)
#build_opts+=(NO_LAPACKE=1)

# Build LAPACK functions deprecated since LAPACK 3.6.0
build_opts+=(BUILD_LAPACK_DEPRECATED=1)

# If uncommented, build RecursiveLAPACK on top of LAPACK
#build_opts+=(BUILD_RELAPACK=1)

# Tell BLAS _NOT_ to try and find a high quality buffer before entering the
# main function. This saves a little bit of time.
build_opts+=(NO_WARMUP=1)

# If uncommented, enable experimental support for >16 NUMA nodes or >256 CPUs
#build_opts+=(BIGNUMA=1)

# If uncommented, disable parallel make
#build_opts+=(NO_PARALLEL_MAKE=1)

# If uncommented, enable minute performance reporting for GotoBLAS
#build_opts+=(FUNCTION_PROFILE=1)

# If uncommented, enable experimental support for IEEE quad precision
#build_opts+=(QUAD_PRECISION=1)

# Set the maximum stack allocation; the default value is 2048. "0" disables
# stack allocation a may reduce GER and GEMV performance; for details,
# <https://github.com/xianyi/OpenBLAS/pull/482>.
build_opts+=(MAX_STACK_ALLOC=4096)

# OS- and architecture-specific build options
case "${BUILD_OS}-${BUILD_ARCH}" in
    "linux-ppc64le")
        dylib_ext="so"
        export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH

        # POWER8 is the only POWER architecture conda supports
        build_opts+=(TARGET=POWER8)

        # IBM POWER Linux servers support up to 2 20-core, SMT8-enabled CPUs,
        # for a theoretical maximum of 320 threads. However, the OpenBLAS
        # README.md suggests limiting the number of CPUs/cores (threads) to
        # 256, as more would require still-experimental BIGNUMA support.
        build_opts+=(NUM_THREADS=256)

        # "Dynamic arch" library not built (nor supported) on POWER8
        unset OPENBLAS_CORETYPE
        ;;
    "linux-x86_64")
        dylib_ext="so"
        export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH

        # Build a version of "DYNAMIC_ARCH" library for x86_64 with certain
        # microarchitectures (e.g., 32-bit, low-power mobile/embedded, or older
        # than Nehalem) removed. This lets users benefit from better
        # optimizations if their CPUs support them, while reducing the size of
        # the conda package we produce. For comparison:
        #   - Nehalem-only: 7-MB package, 38-MB installed
        #   - DYNAMIC_ARCH=1, limited: 10-MB package, 52-MB installed (ours)
        #   - DYNAMIC_ARCH=1, all: 15-MB package, 92-MB installed
        #build_opts+=("TARGET=NEHALEM")
        build_opts+=(DYNAMIC_ARCH=1)

        # Do _NOT_ disable optimizations for AVX (Sandy Bridge) and AVX2
        # (Haswell). If we run to problems building these, we will modify the
        # conda recipe to use a different toolchain.
        build_opts+=(NO_AVX=0)
        build_opts+=(NO_AVX2=0)

        # Uncomment below to synchronize FP CSR between threads
        #build_opts+=(CONSISTENT_FPCSR=1)

        # Wide variety of x86_64 Linux systems out there, so it's hard to make
        # a good guess as to what a "reasonable" value should be. For now,
        # assume a mid-range, 2-socket server with 12-core, HT-enabled Xeons.
        # We will probably have to come back soon and reassess this decision as
        # higher core-/thread-count AMD Zen and Intel *Lake SP processors are
        # increasingly adopted.
        build_opts+=(NUM_THREADS=48)
        ;;
    "darwin-x86_64")
        dylib_ext="dylib"
        export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH

        # Build a version of this library that selects the microarchitecture to
        # optimize for at run-time. See the "linux-x86_64" section for details.
        #build_opts+=("TARGET=NEHALEM")
        build_opts+=(DYNAMIC_ARCH=1)

        # Do _NOT_ disable optimizations for AVX (Sandy Bridge) and AVX2
        # (Haswell). If we run to problems building these, we will modify the
        # conda recipe to use a different toolchain.
        build_opts+=(NO_AVX=0)
        build_opts+=(NO_AVX2=0)

        # Uncomment below to synchronize FP CSR between threads
        #build_opts+=(CONSISTENT_FPCSR=1)

        # Theoretical maximum number of threads on Apple hardware is 24
        # (12-core HT-enabled Xeon available on top-end Mac Pros). However,
        # seems reasonable to assume that the *vast* majority of users will be
        # on MacBooks, iMacs, and Mac Minis, and we should limit ourselves to
        # the CPUs present in those systems (2- or 4-core, HT-enabled CPUs).
        build_opts+=(NUM_THREADS=8)
        ;;
    *)
        echo "ERROR: Unsupported OS/architecture ${HOST_OS}-${BUILD_ARCH}" >&2
        exit 1
        ;;
esac

# Unset environment variables provided toolchain (compiler and linker) flags,
# or the OpenBLAS build system will get really confused (duplicates contents of
# the CCOMMON_OPT make variable).
unset CPPFLAGS CFLAGS CXXFLAGS
unset FCFLAGS F77FLAGS
unset LDFLAGS


# NOTE: Explicitly pass CC and FC to make so OpenBLAS doesn't revert to its
# default compiler; this stops its build build system from assuming that we're
# using clang on OS X, even when the "gcc" invoked through $PATH is really GCC.
eval ${LIBRARY_SEARCH_VAR}="${PREFIX}/lib" \
make -j${MAKE_JOBS} \
    CC="${CC}" \
    FC="${FC}" \
    "${build_opts[@]}" \
    2>&1 | tee build.log


# Run the provided tests
eval ${LIBRARY_SEARCH_VAR}="${PREFIX}/lib" \
make tests \
    CC="${CC}" \
    FC="${FC}" \
    "${build_opts[@]}" \
    2>&1 | tee tests.log


# Install into our conda build prefix
make install PREFIX="$PREFIX" \
    "${build_opts[@]}"

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
