#!/bin/bash

set -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Platform-specific tweaks
case "$BUILD_ARCH" in
    'ppc64le')
        # Make the same assumptions about plain char declarations (i.e., those
        # w/o explicit sign) as the x86_64 compiler.
        CFLAGS="${CFLAGS} -fsigned-char"
        ;;
esac

case "$BUILD_OS" in
    'darwin')
#        # Needed to resolve various symbols in the OpenBLAS LAPACK library
#        export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
#        export LIBS="-lgfortran -lgomp"
        export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
        export LIBS=
        ;;
    'linux')
        export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
        export LIBS=
        ;;
    *)
        echo "ERROR: unsupported operating system '$BUILD_OS'" >&2
        exit 1
        ;;
esac

# Make sure ./configure's sub-processes can see these environment variables
#export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"
export CPPFLAGS CC CFLAGS CXX CXXFLAGS
export AR LD LDFLAGS

# "conda build" no longer provides the patch level info in the $PERL_VER
# environment variable, so we'll need to get the information some other way.
#
# TODO: Find a better to determine where to place Perl modules (e.g., by
# processing @INC), rather than assuming the directory structure from our
# original Perl build.
perl_version=`perl -e 'print $^V;' | sed 's/^v//'`

./autogen.sh
eval ${LIBRARY_SEARCH_VAR}="${PREFIX}/lib" \
./configure --prefix="${PREFIX}" \
    --with-pmdir="lib/perl5/site_perl/${perl_version}" \
    --enable-largefile \
    --enable-pca \
    2>&1 | tee configure.log

# Verify configure found a LAPACK library (needed by "--enable-pca")
egrep -qi -- 'checking.*-llapack[[:space:]]*$' configure.log || \
    { echo "*** ERROR: Could not find LAPACK library" >&2; exit 1; }

make -j${MAKE_JOBS} ${VERBOSE_AT}
make install ${VERBOSE_AT}

# Fix '#!' line to explicitly use the environment's Perl interpreter
#
# ** WARNING **: we cannot use the perl "-w" flag in the shebang ("#!") line,
# or conda-build's test step will fail; the test step sets the interpreter to
# "/usr/bin/env perl" (rather than "${PREFIX}/bin/perl"), and the extra "-w"
# flag will trigger a bad/unknown interpreter error.
cd "${PREFIX}/bin"
for f in vcf-* fill-*; do
    sed -i.bak "1s:.*:#!${PREFIX}/bin/perl:" "$f"
    head -n1 "$f" | grep 'env perl' && \
        { echo "*** ERROR: Failed to change #! line in '$f'" >&2; exit 1; }
    rm -f "${f}.bak"
    chmod 755 "$f"
done
