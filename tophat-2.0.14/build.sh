#!/bin/bash
set -o pipefail

# Configure
build_os=$(uname -s)

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} $(pkg-config --cflags zlib)"
CXXFLAGS="${CFLAGS}"
LDFLAGS="${LDFLAGS} $(pkg-config --libs-only-L zlib)"

if [ "$build_os" == 'Darwin' ]; then
    # Give install_name_tool enough space to work its magic; if not set,
    # tweaking "long_spanning_reads" binary fails.
    LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

cp -f "${RECIPE_DIR}/config.guess" "${SRC_DIR}/config.guess"
cp -f "${RECIPE_DIR}/config.sub" "${SRC_DIR}/config.sub"

env CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" \
    CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" --with-boost="${PREFIX}" \
    2>&1 | tee configure.log

# Build. WARNING: Do NOT use "-j" option as it causes cryptic build failures
make 2>&1 | tee build.log

# Install
make install
