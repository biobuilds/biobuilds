#!/bin/bash

SRC="hello.c"
EXE="hello-world"

mkdir -p "${PREFIX}/bin" "${PREFIX}/share/${PKG_NAME}"

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Record the build environment (for debugging purposes)
env | sort -t= -k1,1 -f | sed "s|${PREFIX}|\$PREFIX|g" \
    > "${PREFIX}/share/${PKG_NAME}/build-env.log"

# Build the executables
${CC} ${CFLAGS} ${LDFLAGS} hello-world.c -o hello-world
${CXX} ${CXXFLAGS} ${LDFLAGS} hello-world.cxx -o hello-world-cxx
${FC} ${FCFLAGS} ${LDFLAGS} hello-world.f95 -o hello-world-f95

# Install the executables
install -m 755 \
    hello-world \
    hello-world-cxx \
    hello-world-f95 \
    ${PREFIX}/bin
