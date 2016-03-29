#!/bin/bash
set -o pipefail

## Configure
build_arch=$(uname -m)
build_os=$(uname -s)

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CXXFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CXXFLAGS="${CXXFLAGS} -fsigned-char"

if [ "$build_os" == 'Darwin' ]; then
    # Needed so we have support for the C++11 <unordered_set> header
    MAC_OSX_MIN_VERSION="10.8"
    CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MAC_OSX_MIN_VERSION}"
    CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
    LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MAC_OSX_MIN_VERSION}"
    LDFLAGS="${LDFLAGS} -stdlib=libc++"
fi

# Make sure compiler and linker can find bamtools and htslib
CXXFLAGS="${CXXFLAGS} -I${PREFIX}/lib"
CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include/bamtools"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"


## Build
make -C Microassembler -j${BB_MAKE_JOBS} \
    CXXFLAGS_extra="$CXXFLAGS" LDFLAGS="$LDFLAGS" \
    2>&1 | tee build.log

SHARE_DIR="${PREFIX}/share/${PKG_NAME}"
for fn in $(egrep -l '@@(prefix|sharedir)' *.pl *.pm scalpel-*); do
    sed -i.0 "s:@@prefix@@:${PREFIX}:g; s:@@sharedir@@:${SHARE_DIR}:g;" $fn
    rm -f "${fn}.0"
done

## Install
mkdir -p "${SHARE_DIR}"
install -m 0755 *.pl *.pm "${SHARE_DIR}"
install -m 0755 Microassembler/Microassembler scalpel-* "${PREFIX}/bin"
