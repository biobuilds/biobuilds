#!/bin/bash
set -o pipefail

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

if [ `uname -s` == 'Darwin' ]; then
    # Needed to resolve various symbols in the OpenBLAS LAPACK library
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
    LIBS="-lgfortran -lgomp"
else
    LIBS=
fi

# For some reaons, "./configure" is not enough to properly set these flags
CFLAGS="${CFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

./autogen.sh
env PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig" \
    CFLAGS="${CFLAGS}" CXXFLAGS="${CFLAGS}" \
    LDFLAGS="${LDFLAGS}" LIBS="${LIBS}" \
    ./configure --prefix="${PREFIX}" \
    --with-pmdir="${PREFIX}/lib/perl5/site_perl/${PERL_VER}" \
    --enable-largefile \
    --enable-pca \
    2>&1 | tee configure.log

# Verify configure found a LAPACK library (needed by "--enable-pca")
egrep -qi -- 'checking.*llapack.*yes$' configure.log || \
    { echo "*** ERROR: Could not find LAPACK library" >&2; exit 1; }

make -j${BB_MAKE_JOBS}
make install

# Fix '#!' line to explicitly use the environment's Perl interpreter
cd "${PREFIX}/bin"
for f in vcf-* fill-*; do
    sed -n "1s,^.*\$,#!${PREFIX}/bin/perl -w,p; 2,\$p;" < "$f" > f.new
    mv -v f.new "$f"
    chmod 755 "$f"
done
