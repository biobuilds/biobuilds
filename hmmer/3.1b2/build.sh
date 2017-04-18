#!/bin/bash


## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

cpu=$(uname -m)
if [ "$cpu" == "x86_64" ]; then
    hmmer_gcc="gcc"
    gcc_arch="core2"
elif [ "$cpu" == "ppc64le" ]; then
    hmmer_gcc="gcc -U__APPLE_ALTIVEC__"
    gcc_arch="power8"

    # Should be provided by the "veclib-headers" package
    [ -d "${PREFIX}/include/veclib" ] || \
        { echo "ERROR: could not find veclib headers" >&2; exit 1; }
    CFLAGS="-I${PREFIX}/include/veclib ${CFLAGS}"
else
    echo "Unsupported architecture '$cpu'." >&2
    exit 1
fi

cp -f "${RECIPE_DIR}/config.guess" "config.guess"
cp -f "${RECIPE_DIR}/config.sub" "config.sub"
cp -f "${RECIPE_DIR}/config.guess" "easel/config.guess"
cp -f "${RECIPE_DIR}/config.sub" "easel/config.sub"

env CC="$hmmer_gcc" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" \
        --with-gcc-arch=$gcc_arch --enable-sse \
        --disable-debugging --disable-gcov --disable-gprof \
        --without-gsl --disable-mpi


## Build and install
make -j${BB_MAKE_JOBS} V=1
make check
make install
