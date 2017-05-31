#!/bin/bash
set -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Additional tweaks for Intel Parallel Studio
if [[ "${CXX}" == *"/bin/icpc" ]]; then
    # When using conda's g++, help `icpc` find libstdc++ include files
    #
    # NOTE: We need gcc 4.8 (or later) to build bedops using `icpc` to get
    # proper C++11 support. Using g++ 4.4 causes `icpc` to choke with a
    # "conv_class_prvalue_operand_to_lvalue: couldn't convert to ptr" error
    # when compiling the "std::make_pair" statements in Bedops.cpp:L1098.
    if [ -d "${PREFIX}/gcc" ]; then
        export GXX_INCLUDE="${PREFIX}/gcc/include"
        CXXFLAGS="${CXXFLAGS} -I${GXX_INCLUDE}/c++"
        CXXFLAGS="${CXXFLAGS} -I${GXX_INCLUDE}/c++/${BUILD_ARCH}-unknown-${BUILD_OS}-gnu"
    fi

    # Disable multi-file interprocedural optimizations (IPO) for now, as it's
    # causing the compiler to segfault in our Docker build container.
    CFLAGS="${CFLAGS/-ipo/}"
    CXXFLAGS="${CXXFLAGS/-ipo/}"
fi

make -j${MAKE_JOBS} \
    CC="$CC" CXX="$CXX" AR="$AR" \
    EXT_INCLUDES="-I${PREFIX}/include" \
    EXT_LIBS="-L${PREFIX}/lib" \
    OTHER_CFLAGS="${CFLAGS}" \
    OTHER_CXXFLAGS="${CXXFLAGS}" \
    SFLAGS="" \
    2>&1 | tee build.log

make install
rm -fv bin/*_sge* bin/*_slurm* bin/*-sge* bin/*-slurm*
install -m 0755 bin/* "${PREFIX}/bin"
