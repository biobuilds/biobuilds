#!/bin/bash
set -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Regenerate `./configure` to pick up some of the patches we applied
aclocal -I m4
autoconf

# Filter out -std=.* from CXXFLAGS as it disrupts checks for C++ language levels.
re='(.*[[:space:]])\-std\=[^[:space:]]*(.*)'
if [[ "${CXXFLAGS}" =~ $re ]]; then
    export CXXFLAGS="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
fi

IFS="." read -a tk_ver_arr <<<"${tk}"
tk_maj_min="${tk_ver_arr[0]}.${tk_ver_arr[1]}"

# Without setting these, R goes off and tries to find things on its own, which
# we don't want (we only want it to find stuff in the build environment).
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"
#export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
#export CFLAGS="${CFLAGS} -I${PREFIX}/include"
#export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"
export OBJCFLAGS="${OBJCFLAGS} -I${PREFIX}/include"
export FFLAGS="${FFLAGS} -I${PREFIX}/include -L${PREFIX}/lib"
export FCFLAGS="${FCFLAGS} -I${PREFIX}/include -L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -lgfortran"
export LAPACK_LDFLAGS="${LAPACK_LDFLAGS} -L${PREFIX}/lib -lgfortran"
export PKG_CPPFLAGS="${PKG_CPPFLAGS} -I${PREFIX}/include"
export PKG_LDFLAGS="${PKG_LDFLAGS} -L${PREFIX}/lib -lgfortran"
export TCL_CONFIG="${PREFIX}/lib/tclConfig.sh"
export TCL_LIBRARY="${PREFIX}/lib/tcl${tk_maj_min:-8.6}"
export TK_CONFIG="${PREFIX}/lib/tkConfig.sh"
export TK_LIBRARY="${PREFIX}/lib/tk${tk_maj_min:-8.6}"
export F77="${FC}"

BUILD_OS=$(uname -s)
BUILD_ARCH=$(uname -m)


# Options shared by all target platforms
declare -a common_opts
common_opts+=(--with-pic)
common_opts+=(--disable-static)
common_opts+=(--enable-shared)
common_opts+=(--enable-R-shlib)
common_opts+=(--disable-R-static-lib)
common_opts+=(--enable-BLAS-shlib)
common_opts+=(--enable-R-profiling)
common_opts+=(--enable-memory-profiling)
common_opts+=(--disable-prebuilt-html)
common_opts+=(--disable-java)
common_opts+=(--enable-byte-compiled-packages)
common_opts+=(--enable-largefile)
common_opts+=(--enable-long-double)
common_opts+=(--with-readline)
common_opts+=(--with-ICU)
common_opts+=(--with-libpng)
common_opts+=(--with-jpeglib)
common_opts+=(--with-libtiff)
common_opts+=(--with-recommended-packages=no)
common_opts+=(--without-recommended-packages)
common_opts+=(--without-libpth-prefix)
common_opts+=(--enable-nls)
#common_opts+=(--without-included-gettext)
#common_opts+=(--without-libintl-prefix)


# Platform-specific options
declare -a gui_opts
declare -a blas_opts
declare -a misc_opts

case "$BUILD_OS" in
    "Linux")
        # If lib/R/etc/javaconf ends up with anything other than ~autodetect~
        # for any value (except JAVA_HOME) then 'R CMD javareconf' will never
        # change it, so we prevent configure from finding Java.  post-install
        # and activate scripts now call 'R CMD javareconf'.
        unset JAVA_HOME

        # ---- CHL: Removed Java support from original recipe ----

        mkdir -p "${PREFIX}/lib"

        gui_opts+=(--with-x)
        gui_opts+=(--with-cairo)
        gui_opts+=(--with-tcltk)
        gui_opts+=(--with-tk-config="$TK_CONFIG")
        gui_opts+=(--with-tcl-config="$TCL_CONFIG")

        # Use built-in netlib BLAS and LAPACK libraries
        # TODO: Use OpenBLAS for BLAS and LAPACK
        blas_opts+=(--without-blas)
        blas_opts+=(--without-lapack)

        # ** WARNING **: Disabling link-time optimizations (LTO) for now, as
        # it's breaking gcc >= 4.9 and the default set of toolchain flags. The
        # fix seems to involve tweaking the toolchain applications and/or
        # flags, and testing to make sure it doesn't break things for the user
        # will take time we don't have right now. For details on the fix, see:
        # <https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=214785>
        misc_opts+=(--disable-lto)

        misc_opts+=(--enable-openmp)
        misc_opts+=(LIBnn=lib)
        ;;
    "Darwin")
        unset JAVA_HOME

        # For maximum portability, make sure we aren't building and linking for too
        # recent a version of OS X; as of Oct. 2015, 10.8 (Mountain Lion) has
        # presumably just reached EOL with the 10.11 (El Capitan) release.
        export CFLAGS="${CFLAGS} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
        export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
        export LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"

        # Without this, it will not find libgfortran. We do not use
        # DYLD_LIBRARY_PATH because that screws up some of the system libraries
        # that have older versions of libjpeg than the one we are using here.
        # DYLD_FALLBACK_LIBRARY_PATH will only come into play if it cannot find
        # the library via normal means. The default comes from 'man dyld'.
        export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib:/lib:/usr/lib"

        # Prevent configure from finding Fink or Homebrew.
        export PATH="$PREFIX/bin:/usr/bin:/bin:/usr/sbin:/sbin"

        # [*] Since R 3.0, the configure script prevents using any DYLD_* on
        # Darwin, after a certain point, claiming each dylib had an absolute ID
        # path. Patch 008-Darwin-set-DYLD_FALLBACK_LIBRARY_PATH.patch corrects
        # this and uses the same mechanism as Linux (and others) where
        # configure transfers path from LDFLAGS=-L<path> into
        # DYLD_FALLBACK_LIBRARY_PATH. Note we need to use both LDFLAGS and
        # DYLD_FALLBACK_LIBRARY_PATH for different stages of configure.
        export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"

        # Add generic (e.g., "-O<n>") and architecture-specific ("-march=")
        # optimization options to the list of Fortran compiler flags
        export FFLAGS="${ARCH_FLAGS} ${OPT_FLAGS} ${FFLAGS}"
        export FCFLAGS="${ARCH_FLAGS} ${OPT_FLAGS} ${FCFLAGS}"

        # Default to using LLVM compilers for C and C++. Note that when using
        # clang++ to build C++11 code on OS X, make sure we use libc++ instead
        # of libstdc++, or we'll run into all sorts of errors (missing headers,
        # missing symbols, wrong namespaces, etc.)
        echo "CC=${CC}" >> config.site
        echo "CXX=${CXX}" >> config.site
        echo "F77=${F77}" >> config.site
        echo "OBJC=${CC}" >> config.site
        echo "CXX1XSTD='-std=c++11 -stdlib=libc++'" >> config.site
        echo "SHLIB_CXX1XLDFLAGS='-stdlib=libc++'" >> config.site

        gui_opts+=(--with-aqua)
        gui_opts+=(--without-x)
        gui_opts+=(--without-cairo)
        gui_opts+=(--without-tcltk)

        blas_opts+=(--with-blas='-framework Accelerate')
        blas_opts+=(--with-lapack)

        # Disabling link-time optimization (LTO) for now because it's not clear
        # if the version of clang/LLVM we're using supports it.
        misc_opts+=(--disable-lto)

        # The version of clang/LLVM provided by conda _should_ support OpenMP
        # (added in 3.7), so we'll enable it and see what happens.
        misc_opts+=(--enable-openmp)

        misc_opts+=(--enable-R-framework=no)

        # --without-internal-tzcode to avoid warnings:
        # unknown timezone 'Europe/London'
        # unknown timezone 'GMT'
        # https://stat.ethz.ch/pipermail/r-devel/2014-April/068745.html
        misc_opts+=(--without-internal-tzcode)
        ;;
    *)
        echo "FATAL: Unsupported operating system '$BUILD_OS'" >&2
        exit 1
        ;;

esac

./configure --prefix="${PREFIX}" \
    "${common_opts[@]}" \
    "${gui_opts[@]}"  \
    "${blas_opts[@]}" \
    "${misc_opts[@]}" \
    2>&1 | tee configure.log

# Platform-specific checks to Make sure ./configure did its thing correctly
case "${BUILD_OS}" in
    "Linux")
        if grep "undef HAVE_PANGOCAIRO" src/include/config.h; then
            echo "Did not find pangocairo, refusing to continue"
            cat config.log | grep pango
            exit 1
        fi
        ;;
esac

make -j${MAKE_JOBS} ${VERBOSE_AT} 2>&1 | tee build.log

make install

# Platform-specific post-install tweaks
case "${BUILD_OS}" in
    "Linux")
        # Prevent C and C++ extensions from linking to libgfortran.
        sed -i -r 's|(^LDFLAGS = .*)-lgfortran|\1|g' ${PREFIX}/lib/R/etc/Makeconf
        ;;
esac

# Currently don't need this since we've disabled Java support
#mkdir -p ${PREFIX}/etc/conda/activate.d
#cp "${RECIPE_DIR}/activate-${PKG_NAME}.sh" \
#    "${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.sh"
