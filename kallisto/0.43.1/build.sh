#!/bin/bash

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v


# Configure
case "${BUILD_ARCH}" in
    "ppc64le")
        CFLAGS="${CFLAGS} -fsigned-char"
        CXXFLAGS="${CXXFLAGS} -fsigned-char"
        ;;
esac

if [[ "${CXX}" == *"/bin/icpc" ]]; then
    # Use conda's updated g++ so `icpc` can find C++11 STL headers and
    # libstdc++ needed to build kallisto. Having `icpc` behave like g++-4.4
    # (our default x86_64 compiler) leads to STL-related build failures.
    CXXFLAGS="${CXXFLAGS} -gcc-name=${CONDA_CC}"
    CXXFLAGS="${CXXFLAGS} -gxx-name=${CONDA_CXX}"
fi

mkdir "${SRC_DIR}/build"
cd "${SRC_DIR}/build"
cmake -G "Unix Makefiles" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -DCMAKE_C_COMPILER="${CC}" \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_AR="${AR}" \
    -DCMAKE_LINKER="${LD}" \
    -DCMAKE_SHARED_LINKER_FLAGS="${LDFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF \
    -DLINK=SHARED \
    "${SRC_DIR}"


# Build
make -j${MAKE_JOBS} ${VERBOSE_CM}

# Install
make install
