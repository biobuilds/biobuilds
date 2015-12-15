#!/bin/bash

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CXXFLAGS="${CXXFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

cp -f "${PREFIX}/share/autoconf/config.guess" config/config.guess
cp -f "${PREFIX}/share/autoconf/config.sub" config/config.sub

if [ `uname -s` == 'Darwin' ]; then
    # Needed to ensure libgcc is found when running "make check"
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
fi

env CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" \
    --enable-wall --disable-debug \
    --with-pic --enable-shared --enable-static \
    2>&1 | tee configure.log
make -j${BB_MAKE_JOBS}
make check

make install
rm -rf "${PREFIX}/share"
cd "${PREFIX}/bin"
for f in fastx_barcode_splitter.pl fasta_clipping_histogram.pl; do
    sed -i.bak "s:^#!/usr/bin/perl:#!${PREFIX}/bin/perl:" "$f"
    rm -f "${f}.bak"
done
