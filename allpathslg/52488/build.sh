#!/bin/bash
set -o pipefail

# Configure
build_os=$(uname -s)
build_arch=$(uname -m)

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1

# The FASTQ quality score parser in "FastqToFastbQualb" seems to assume that
# "char" w/o any qualifier is signed; assuming this assumption holds throughout
# the code base and tell gcc/g++ to treat "char" as "signed char". Needed b/c
# x86_64 Linux and ppc64le POWER8 have different defaults for char signedness.
CFLAGS="${CFLAGS} -fsigned-char"

# Set up other compiler and linker flags
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
if [ "$build_os" == 'Darwin' ]; then
    echo "ERROR: Cannot build ALLPATHS-LG on OS X." >&2
    exit 1
fi
if [ "$build_arch" == 'x86_64' ]; then
    CFLAGS="${CFLAGS} -mieee-fp"
    CXXFLAGS="${CXXFLAGS} -mieee-fp"
fi

CXXFLAGS="${CFLAGS}"

cp -f "${PREFIX}/share/autoconf/config.guess" "${SRC_DIR}/config.guess"
cp -f "${PREFIX}/share/autoconf/config.sub" "${SRC_DIR}/config.sub"

env CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" \
    --disable-static --enable-shared --enable-openmp \
    2>&1 | tee configure.log


# Build
make -j${BB_MAKE_JOBS} 2>&1 | tee build.log


# Install
make install-strip
