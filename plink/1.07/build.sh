#!/bin/bash

# configure
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v
CXXFLAGS="${CXXFLAGS} -Wall -Wno-unused-function"

# Let Intel C++ compiler go wild trying to parallelize/optimize some loops.
# OK...this is bad idea. Takes a huge amount of RAM (> 16-GiB), and
# "conda build" gave up waiting for the process to finish.
#if [[ "${CXX}" == *"icpc" ]]; then
#    CXXFLAGS="${CXXFLAGS} -qoverride-limits"
#fi

case "$BUILD_OS" in
  'darwin') PLATFORM="MAC" ;;
  *) PLATFORM="UNIX" ;;
esac

# build
env CXX_UNIX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    make -j${MAKE_JOBS} FORCE_DYNAMIC=1 SYS=${PLATFORM}

# install
DOC_DIR="${PREFIX}/share/doc/plink"
cp plink "${PREFIX}/bin"
[ -d "${DOC_DIR}/examples" ] || mkdir -p "${DOC_DIR}/examples"
cp -f README.txt "${DOC_DIR}"
cp -f test.map test.ped "${DOC_DIR}/examples"
