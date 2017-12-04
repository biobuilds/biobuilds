#!/bin/bash
set -o pipefail

## Configure

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment  configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v
unset ARFLAGS

# Build with pthread support
CFLAGS="${CFLAGS} -pthread"
CXXFLAGS="${CXXFLAGS} -pthread"

# Assume the same signedness for plain "char" declarations on all platforms
# (default for x86_64).
CFLAGS="${CFLAGS} -fsigned-char"
CXXFLAGS="${CXXFLAGS} -fsigned-char"

# Additional architecture-specific tweaks
case "$BUILD_ARCH" in
    'ppc64le')
        [ -d "${PREFIX}/include/veclib" ] || \
            { echo "ERROR: could not find veclib headers" >&2; exit 1; }
        CFLAGS="${CFLAGS} -I${PREFIX}/include/veclib"
        CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include/veclib"

        # Switch the language standard to "gnu++11" rather than "c++0x" (or
        # "c++11"). Due to the inclusion of "altivec.h" (which typedefs "bool"
        # as "__vector(4) __bool"_, using the "c++0x"/"c++11" standard will
        # cause the build to fail with multiple "prototype for ‘__vector(4)
        # __bool <Class::Fn>' does not match any in class <Class>" errors. See
        # <https://gcc.gnu.org/bugzilla/show_bug.cgi?id=58241> for details.
        find . -name Makefile | \
            xargs grep -l -- '-std=c++0x' | \
            xargs sed -i 's/-std=c++0x/-std=gnu++11/g'
        ;;
esac

# Additional OS-specific tweaks
case "$BUILD_OS" in
    'darwin')
        MACOSX_VERSION_MIN=10.8
        CFLAGS="${CFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
        CFLAGS="${CFLAGS} -stdlib=libc++"
        CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
        CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
        LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
        LDFLAGS="${LDFLAGS} -stdlib=libc++"

        # Give install_name_tool enough space to work its magic
        LDFLAGS="${LDFLAGS} -headerpad_max_install_names"

        # No additional flags needed to link to libhts
        HTS_LIB_LDFLAGS=

        DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
        ;;
    'linux')
        # Flags needed to link to libhts
        HTS_LIB_LDFLAGS="-ldl"

        LD_LIBRARY_PATH="${PREFIX}/lib"
        ;;
esac

# Additional tweaks for ICC
if [[ "$CC" == *"/bin/icc"* ]]; then
    LD_LIBRARY_PATH="/opt/intel/lib/intel64:${LD_LIBRARY_PATH}"
fi


## Build

# Clean up previous builds (mostly useful when debugging this recipe)
make clean
find . -name '*.o' -o -name '*.a' | xargs rm -fv
rm -f test/tests/main

# Build binaries and library files
env CC="${CC}" CFLAGS="${CFLAGS}" \
    CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    HTS_LIB="-lhts" \
    HTS_LIB_LDFLAGS="${HTS_LIB_LDFLAGS}" \
    make -j${MAKE_JOBS} \
    LD="${LD}" AR="${AR}" \
    2>&1 | tee build.log

# Run built-in tests
#
# ** NOTE **: For some reason, the dynamic linker *_LIBRARY_PATH environment
# variables aren't being correctly passed through when running "make test",
# which can cause "./test/tests/main" to fail. We can, however, work around
# this by passing them as explicit `make` arugments (hence the slightly weird
# looking command line).
env CC="${CC}" CFLAGS="${CFLAGS}" \
    CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    HTS_LIB="-lhts" \
    HTS_LIB_LDFLAGS="${HTS_LIB_LDFLAGS}" \
    make -C test -j${MAKE_JOBS} \
    LD="${LD}" AR="${AR}" \
    DYLD_FALLBACK_LIBRARY_PATH="${DYLD_FALLBACK_LIBRARY_PATH}" \
    LD_LIBRARY_PATH="${LD_LIBRARY_PATH}" \
    2>&1 | tee test.log


## Tweak scripts before installing them
pushd "${SRC_DIR}/scripts"

# Re-name plot scripts so they don't conflict with other packages
for fn in plot*.{R,r}; do
    mv -fv "${fn}" "${fn/plot/vcf_plot}"
done

# Munge '#!' paths so conda correctly sets them when installing the package.
# Need to loop because, unlike GNU sed, OS X's built-in (BSD) sed doesn't seem
# to properly handle in-place edits (i.e., "-i") with multiple file arguments.
for fn in *; do
    sed -i.bak "s:@@PREFIX_BIN@@:${PREFIX}/bin:g" "$fn"
    rm -f "${fn}.bak"
done

popd


## Install
mkdir -pv "${PREFIX}/bin" "${PREFIX}/lib" "${PREFIX}/include/${PKG_NAME}"
install -m 755 bin/* "${PREFIX}/bin"
install -m 755 scripts/* "${PREFIX}/bin"
install -m 644 lib/*.a "${PREFIX}/lib"
install -m 644 include/*.h* "${PREFIX}/include/${PKG_NAME}"
