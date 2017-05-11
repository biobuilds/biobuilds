#!/bin/bash

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

cp -f "${PREFIX}/share/autoconf/config.guess" config/config.guess
cp -f "${PREFIX}/share/autoconf/config.sub" config/config.sub

if [ "${BUILD_OS}" == 'Darwin' ]; then
    # Needed to ensure libgcc is found when running "make check"
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
fi

if [[ ${CC_IS_GNU} -eq 1 ]]; then
    GCC_VER=`"${CC}" -dumpversion`
    GCC_MAJOR_VER=$(cut -d. -f1 <<<"$GCC_VER")
    GCC_MINOR_VER=$(cut -d. -f2 <<<"$GCC_VER")

    # Use older, pre-C++11-compliant ABI when building with newer versions of
    # g++ to maintain compatibility with libgtextutils; omitting this will
    # cause std::string-related undefined symbol errors. For details, see:
    #   - https://gcc.gnu.org/onlinedocs/libstdc++/manual/using_dual_abi.html
    #   - https://gcc.gnu.org/onlinedocs/libstdc++/manual/using_macros.html
    if [[ $GCC_MAJOR_VER -ge 5 ]]; then
        CXXFLAGS="${CXXFLAGS} -D_GLIBCXX_USE_CXX11_ABI=0"
    fi
fi

env CC="${CC}" CFLAGS="${CFLAGS}" \
    CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" \
    --enable-wall --disable-debug \
    --with-pic --enable-shared --enable-static \
    2>&1 | tee configure.log
make -j${MAKE_JOBS} V=1 2>&1 | tee build.log
make check

make install
rm -rf "${PREFIX}/share"
cd "${PREFIX}/bin"
for f in fastx_barcode_splitter.pl fasta_clipping_histogram.pl; do
    sed -i.bak "s:^#!/usr/bin/perl:#!${PREFIX}/bin/perl:" "$f"
    rm -f "${f}.bak"
done
