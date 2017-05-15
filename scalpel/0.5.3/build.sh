#!/bin/bash
set -o pipefail

## Configure

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v
CXXFLAGS="${CXXFLAGS} -fsigned-char"

if [ "$BUILD_OS" == 'darwin' ]; then
    # Needed so we have support for the C++11 <unordered_set> header
    MAC_OSX_MIN_VERSION="10.8"
    CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MAC_OSX_MIN_VERSION}"
    CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
    LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MAC_OSX_MIN_VERSION}"
    LDFLAGS="${LDFLAGS} -stdlib=libc++"
fi

# Make sure compiler and linker can find bamtools and htslib
CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include/bamtools"


## Build
make -C Microassembler -j${MAKE_JOBS} \
    CXX="$CXX" CXXFLAGS_extra="$CXXFLAGS" \
    LDFLAGS="$LDFLAGS" \
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
