#!/bin/bash


## Configure

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Additional tweaks for Intel Parallel Studio
if [[ "${CC}" == *"/bin/icc" ]]; then
    # If using conda's gcc, help `icpc` find libstdc++ include files
    if [ -d "${PREFIX}/gcc" ]; then
        export GXX_INCLUDE="${PREFIX}/gcc/include"
        CXXFLAGS="${CXXFLAGS} -I${GXX_INCLUDE}/c++"
        CXXFLAGS="${CXXFLAGS} -I${GXX_INCLUDE}/c++/${BUILD_ARCH}-unknown-${BUILD_OS}-gnu"
    fi
fi

# Update autoconf files for ppc64le detection
cp -f "${PREFIX}/share/autoconf/config.guess" "${SRC_DIR}/config.guess"
cp -f "${PREFIX}/share/autoconf/config.sub" "${SRC_DIR}/config.sub"

env CC="${CC}" CFLAGS="${CFLAGS}" \
    CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" \
    2>&1 | tee config.log


## Build and install
make -j${MAKE_JOBS} install
