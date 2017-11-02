#!/bin/bash
set -o pipefail

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CXXFLAGS="${CFLAGS}"

# Without setting these, R goes off and tries to find things on its own, which
# we don't want (we only want it to find stuff in the build environment).
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"
export CFLAGS="${CFLAGS} -I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export FFLAGS="-I$PREFIX/include -L$PREFIX/lib"
export FCFLAGS="-I$PREFIX/include -L$PREFIX/lib"
export OBJCFLAGS="-I$PREFIX/include"
export CXXFLAGS="${CXXFLAGS} -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib -lgfortran"
export LAPACK_LDFLAGS="-L$PREFIX/lib -lgfortran"
export PKG_CPPFLAGS="-I$PREFIX/include"
export PKG_LDFLAGS="-L$PREFIX/lib -lgfortran"
export TCL_CONFIG="$PREFIX/lib/tclConfig.sh"
export TCL_LIBRARY="$PREFIX/lib/tcl8.5"
export TK_CONFIG="$PREFIX/lib/tkConfig.sh"
export TK_LIBRARY="$PREFIX/lib/tk8.5"

build_os=$(uname -s)
build_arch=$(uname -m)

if [[ "$build_os" == "Linux" ]]; then
    # CHL: Removed Java support from original recipe

    mkdir -p "${PREFIX}/lib"

    GUI_OPTS="${GUI_OPTS} --with-x --with-cairo"
    GUI_OPTS="${GUI_OPTS} --with-tk-config='$TK_CONFIG'"
    GUI_OPTS="${GUI_OPTS} --with-tcl-config='$TCL_CONFIG'"
    BLAS_OPTS=
    MISC_OPTS='LIBnn=lib'
elif [ `uname` == Darwin ]; then
    # For maximum portability, make sure we aren't building and linking for too
    # recent a version of OS X; as of Oct. 2015, 10.8 (Mountain Lion) has
    # presumably just reached EOL with the 10.11 (El Capitan) release.
    MAC_OSX_MIN_VERSION="10.8"
    export CFLAGS="${CFLAGS} -mmacosx-version-min=${MAC_OSX_MIN_VERSION}"
    export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MAC_OSX_MIN_VERSION}"
    export LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MAC_OSX_MIN_VERSION}"

    # Without this, it will not find libgfortran. We do not use
    # DYLD_LIBRARY_PATH because that screws up some of the system libraries
    # that have older versions of libjpeg than the one we are using
    # here. DYLD_FALLBACK_LIBRARY_PATH will only come into play if it cannot
    # find the library via normal means. The default comes from 'man dyld'.
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib:/lib:/usr/lib"

    # Prevent configure from finding Fink or Homebrew.
    export PATH="$PREFIX/bin:/usr/bin:/bin:/usr/sbin:/sbin"

    # Default to using using Apple's LLVM compilers for C and C++. Note that
    # when using clang++ to build C++11 code on OS X, make sure we use libc++
    # instead of libstdc++, or we'll running into all sorts of errors (missing
    # headers, missing symbols, wrong namespaces, etc.)
    cat >> config.site <<EOF
CC=clang
CXX=clang++
F77=gfortran
OBJC=clang
CXX1XSTD='-std=c++11 -stdlib=libc++'
SHLIB_CXX1XLDFLAGS='-stdlib=libc++'
EOF

    GUI_OPTS="--without-x --with-aqua"
    BLAS_OPTS="--with-blas='-framework Accelerate' --with-lapack"
    MISC_OPTS="--enable-R-framework=no"

    # --without-internal-tzcode to avoid warnings:
    # unknown timezone 'Europe/London'
    # unknown timezone 'GMT'
    # https://stat.ethz.ch/pipermail/r-devel/2014-April/068745.html
    MISC_OPTS="${MISC_OPTS} --without-internal-tzcode"
fi

# Need to do this odd-looking "echo ... | xargs ./configure" thing so any
# quoted spaces in environment variables (e.g., $BLAS_OPTS on OS X) are
# properly passed to configure. Without it, "./configure $FOO" risks breaking
# up $FOO into multiple strings/options, even with IFS set.
echo ${GUI_OPTS} ${BLAS_OPTS} ${MISC_OPTS} |
    xargs ./configure --prefix="${PREFIX}" \
    --with-pic \
    --enable-R-profiling \
    --enable-memory-profiling \
    --enable-shared \
    --enable-BLAS-shlib \
    --enable-R-shlib \
    --disable-java \
    --with-readline \
    --with-ICU \
    --with-libpng \
    --with-jpeglib \
    --with-libtiff \
    --disable-prebuilt-html \
    --with-recommended-packages=no  \
    2>&1 | tee configure.log

make -j${BB_MAKE_JOBS} 2>&1 | tee build.log
make install
