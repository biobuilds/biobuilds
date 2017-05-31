#!/bin/bash
set -o pipefail

## Configure

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v
unset ARFLAGS

CFLAGS="${CFLAGS} -fsigned-char"
CXXFLAGS="${CXXFLAGS} -fsigned-char"

# Includes for external libraries
for dep in bamtools htslib vcflib bwa; do
    CFLAGS="${CFLAGS} -I${PREFIX}/include/${dep}"
    CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include/${dep}"
done

# Additional architecture-specific tweaks
case "$BUILD_ARCH" in
    'ppc64le')
        [ -d "${PREFIX}/include/veclib" ] || \
            { echo "ERROR: could not find veclib headers" >&2; exit 1; }
        CFLAGS="${CFLAGS} -I${PREFIX}/include/veclib"
        CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include/veclib"
        ;;
esac

# Additional OS-specific tweaks
case "$BUILD_OS" in
    'darwin')
        # Need GNU grep or "make test" will fail; assuming the binary follows
        # Homebrew convention for GNU utilities with 'g' prepended before name
        command -v ggrep &>/dev/null || \
            { echo "FATAL: GNU grep (ggrep) required for tests" >&2; exit 1; }

        # Match OS X version and C++ runtime library with what was used to
        # build our dependencies (bamtools and vcflib).
        MACOSX_VERSION_MIN=10.8
        CFLAGS="${CFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
        CFLAGS="${CFLAGS} -stdlib=libc++"
        CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
        CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
        LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
        LDFLAGS="${LDFLAGS} -stdlib=libc++"

        # Give install_name_tool enough space to work its magic
        LDFLAGS="${LDFLAGS} -headerpad_max_install_names"

        LIBS_EXTRA=""

        DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
        ;;
    'linux')
        # Symbols in libdl needed by libhts.a
        LIBS_EXTRA="-ldl"

        LD_LIBRARY_PATH="${PREFIX}/lib"
        ;;
esac

# Additional tweaks for ICC
if [[ "$CC" == *"/bin/icc"* ]]; then
    LD_LIBRARY_PATH="/opt/intel/lib/intel64:${LD_LIBRARY_PATH}"
fi

# Remove external sources we don't want to accidentally build
rm -rf SeqLib/bwa SeqLib/htslib bamtools vcflib


## Build
env CC="$CC" CFLAGS="$CFLAGS" \
    CXX="$CXX" CXXFLAGS="$CFLAGS" \
    LDFLAGS="$LDFLAGS" \
    make -j${MAKE_JOBS} \
    AR="${AR}" LD="${LD}" \
    BAMTOOLS_LIB="${PREFIX}/lib/libbamtools.a" \
    VCFLIB_LIB="${PREFIX}/lib/libvcflib.a" \
    HTSLIB_LIB="${PREFIX}/lib/libhts.a" \
    LIBS_EXTRA="${LIBS_EXTRA}" \
    2>&1 | tee build.log

env CC="$CC" CFLAGS="$CFLAGS" \
    CXX="$CXX" CXXFLAGS="$CFLAGS" \
    LDFLAGS="$LDFLAGS" \
    make -C test -j${MAKE_JOBS} \
    AR="${AR}" LD="${LD}" \
    2>&1 | tee test.log

for fn in `grep -l '@@PREFIX' scripts/*`; do
    sed -i.bak "s:@@PREFIX_BIN@@:${PREFIX}/bin:g" $fn
    rm -f $fn.bak
done

rm -fv scripts/bgziptabix scripts/*.cnv


## Install
mkdir -p "${PREFIX}/bin"
install -m 0755 bin/* scripts/* "${PREFIX}/bin"
