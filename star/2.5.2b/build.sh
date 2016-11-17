#!/bin/bash
set -x -o pipefail

## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CXXFLAGS="${CXXFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Favor environment-provided g++ over "system" one
[ -x "${PREFIX}/bin/g++" ] && CXX="${PREFIX}/bin/g++" || CXX="g++"

if [ `uname -s` == "Darwin" ]; then
    # Disable certain SHMEM constants when building on OS X
    CXXFLAGS="${CXXFLAGS} -DCOMPILE_FOR_MAC"

    #--------------------------------------------------------------------------
    # Remove "-rpath" arguments from LDFLAGS; without this, binaries built
    # using the XCode 6.2 toolchain (on OS X 10.9) will segfault or crash with
    # an "Illegal instruction: 4" error. This seems to be caused by a bug in
    # install_name_tool when it's invoked by the conda post-build.sh process.
    # Running "otool -L" on the defective binaries results in:
    #
    #   /path/to/conda/envs/_test/bin/STAR:
    #       <... other libs ...>
    #       @rpath/libgcc_s.1.dylib (compatibility version 1.0.0, current version 1.0.0)
    #   load command 20 size zero (can't advance to other load commands)
    #
    # For more details, see <https://github.com/conda/conda-build/issues/206>
    # and <http://public.kitware.com/pipermail/cmake/2014-October/058860.html>.
    #--------------------------------------------------------------------------
    LDFLAGS=$(sed 's/-Wl,-rpath,[^ ]*//g;' <<< "$LDFLAGS")
fi

# Ensure gcc treats plain char (i.e., those w/o explicit sign) declarations
# uniformly on all platforms; signed char is the x86_64 default, so use that.
CXXFLAGS="${CXXFLAGS} -fsigned-char"


## Build and install
cd "${SRC_DIR}"
rm -rf source/htslib    # Force use of system (conda) htslib
install -m 0755 -d "${PREFIX}/bin"

make -C source -j${BB_MAKE_JOBS} STAR \
    CXX="$CXX" CPPFLAGS="-I${PREFIX}/include" \
    CXXFLAGSextra="$CXXFLAGS" LDFLAGSextra="$LDFLAGS" \
    LIBHTS="-lhts" \
    2>&1 | tee build-star.log
install -m 0755 "source/STAR" "${PREFIX}/bin"

make -C source clean
make -C source -j${BB_MAKE_JOBS} STARlong \
    CXX="$CXX" CPPFLAGS="-I${PREFIX}/include" \
    CXXFLAGSextra="$CXXFLAGS" LDFLAGSextra="$LDFLAGS" \
    LIBHTS="-lhts" \
    2>&1 | tee build-starlong.log
install -m 0755 "source/STARlong" "${PREFIX}/bin"
