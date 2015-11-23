#!/bin/bash

command -v pkg-config >/dev/null || \
    { echo "Could not find 'pkg-config' command" >&2; exit 1; }

# configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CXXFLAGS="${CXXFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CXXFALGS="${CXXFLAGS} -Wall -Wno-unused-function"

PLATFORM=$( [ `uname -s` == 'Darwin' ] && echo "MAC" || echo "UNIX" )

# build
env CXXFLAGS="${CXXFLAGS} $(pkg-config --cflags zlib)" \
    LDFLAGS="${LDFLAGS} $(pkg-config --libs zlib)" \
    make -j${BB_MAKE_JOBS} FORCE_DYNAMIC=1 SYS=${PLATFORM}

# install
DOC_DIR="${PREFIX}/share/doc/plink"
cp plink "${PREFIX}/bin"
[ -d "${DOC_DIR}/examples" ] || mkdir -p "${DOC_DIR}/examples"
cp -f README.txt "${DOC_DIR}"
cp -f test.map test.ped "${DOC_DIR}/examples"
