#!/bin/bash
set -o pipefail

command -v pkg-config >/dev/null || \
    { echo "Could not find 'pkg-config' command" >&2; exit 1; }

build_os=$(uname -s)
build_arch=$(uname -m)

## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} $(pkg-config --cflags zlib)"
LDFLAGS="${LDFLAGS} $(pkg-config --libs zlib)"

# Set (DY)LD_LIBRARY_PATH so ./configure works properly
if [ "$build_os" == "Darwin" ]; then
    export DYLD_LIBRARY_PATH="${PREFIX}/lib"
else
    export LD_LIBRARY_PATH="${PREFIX}/lib"
fi

# Update autoconf files for ppc64le detection
cp -f "${PREFIX}/share/autoconf/config.guess" "./config.guess"
cp -f "${PREFIX}/share/autoconf/config.sub" "./config.sub"

# NOTE: don't use "--with-bin-release" (causes static linking to libstdc++)
env ANT="" JAVA="" JAVAC="" JAR="" \
    CFLAGS="${CFLAGS}" CXXFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" \
    --includedir="${PREFIX}/include/emboss" \
    --enable-shared --disable-static --disable-systemlibs \
    --enable-64 --enable-large \
    --disable-debug --with-optimisation --without-gccprofile \
    --without-x --without-java --without-javaos \
    --without-auth --without-hpdf --without-axis2c \
    --without-mysql --without-postgresql \
    --with-thread --with-pngdriver="${PREFIX}" \
    2>&1 | tee configure.log


## Build
make -j${BB_MAKE_JOBS} 2>&1 | tee build.log
make check 2>&1 | tee check.log


## Install
make install
rm -rf "${PREFIX}/share/EMBOSS/doc"
rm -rf "${PREFIX}/share/EMBOSS/test"
#rm -rf "${PREFIX}"/lib/*.la "${PREFIX}/include/emboss"
