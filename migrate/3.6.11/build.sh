#!/bin/bash

#----- RECIPE DEBUGGING -----
test -f src/Makefile && make -C src distclean
: ${PREFIX:=${CONDA_PREFIX}}
: ${VERBOSE_AT:=V=1}
: ${CPU_COUNT=16}
#----- RECIPE DEBUGGING -----


# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

cp -fv "${PREFIX}/share/autoconf/config.guess" src/config.guess
cp -fv "${PREFIX}/share/autoconf/config.sub" src/config.sub

declare -a configure_opts
configure_opts+=(--with-zlib=system)

case "$BUILD_ARCH" in
    'ppc64le')
        # Don't use the source Altivec optimizations for the (P)RNG, which are
        # meant for big-endian POWER systems. Instead, we'll "cheat" and use a
        # patched version of the SSE2 optimizations.
        configure_opts+=(--disable-altivec)
        configure_opts+=(--enable-sse2)

        CFLAGS="${CFLAGS} -I${PREFIX}/include/veclib"
        CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include/veclib"
        ;;
    'x86_64')
        configure_opts+=(--enable-sse2)
        ;;
esac

case "$BUILD_OS" in
    'linux')
        ;;
    'darwin')
        configure_opts+=(--disable-allmac)
        configure_opts+=(--enable-macintel)
        ;;
esac

# Ugly, ugly hack to work around the fact that `migrate-n` is a C application
# trying to interface directly with a C++ library (haru), i.e., without `extern
# "C"` wrappers. The upstream developers suggest linking directly to the C++
# standard library to "fix" undefined symbols link errors.
case "$CXX" in
    *gcc | *icpc) LIBCXX=stdc++ ;;
    *clang++) LIBCXX=c++ ;;
esac

export CC CFLAGS CXX CXXFLAGS LD LDFLAGS

cd src
./configure --prefix="${PREFIX}" \
    "${configure_opts[@]}"

make -j${CPU_COUNT} ${VERBOSE_AT} \
    ZLIBINCL="-I${PREFIX}/include" \
    ZLIBDIR="-L${PREFIX}/lib" \
    LDFLAGS="${LDFLAGS}" \
    STDCPLUS="-l${LIBCXX:-stdc++}" \
    thread

# `make install` will try to install the MPI-enabled binary (`migrate-n-mpi`)
# as well, which we don't want to build and distribute. So, we'll just to
# perform the install step "manually".
mkdir -p "${PREFIX}/bin"
install -m 755 migrate-n "${PREFIX}/bin"
