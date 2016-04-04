#!/bin/bash
set -o pipefail

# Configure
build_os=$(uname -s)
build_arch=$(uname -m)

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS="-m64"
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS="-O3"
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} $(pkg-config --cflags zlib)"
LDFLAGS="${LDFLAGS} $(pkg-config --libs zlib)"

if [ "$build_arch" == "ppc64le" ]; then
    makefile="../make/Makefile.ppc64le.gnu"
    # Should be provided by the "veclib-headers" package
    [ -d "${PREFIX}/include/veclib" ] || \
        { echo "ERROR: could not find veclib headers" >&2; exit 1; }
    CFLAGS="$CFLAGS -I${PREFIX}/include/veclib"
elif [ "$build_arch" == "x86_64" ]; then
    makefile="../make/Makefile.linux64_sse2"
else
    echo "ERROR: Unsupported architecture '$build_arch'" >&2
    exit 1
fi

# Build
cd "${SRC_DIR}/src"
env CC="gcc ${BB_ARCH_FLAGS}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    make -j${BB_MAKE_JOBS} -f "$makefile"
cd "${SRC_DIR}/test"

# Install
INSTALL_BIN="${PREFIX}/bin"
INSTALL_SHARE="${PREFIX}/share/fasta-${PKG_VERSION}"
[ -d "${INSTALL_BIN}" ] || mkdir -p "${INSTALL_BIN}"
[ -d "${INSTALL_SHARE}" ] || mkdir -p "${INSTALL_SHARE}"

cd "${SRC_DIR}"
rm -f bin/README
cp -Rfv bin/. "${INSTALL_BIN}/."
#cp -Rfv data/. "${INSTALL_SHARE}/data"
#cp -Rfv conf/. "${INSTALL_SHARE}/conf"
#cp -Rfv seq/. "${INSTALL_SHARE}/seq"
