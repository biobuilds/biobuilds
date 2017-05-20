#!/bin/bash
set -o pipefail

##-------------------------------------------------------------------------
## Configure
##-------------------------------------------------------------------------

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

case "$BUILD_ARCH" in
    'ppc64le')
        # Just in case, tell the POWER compiler to assume to the same
        # signedness for plain chars as the x86_64 compiler.
        CFLAGS="${CFLAGS} -fsigned-char"
        ;;
esac

CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include/eigen3"
CXXFLAGS="${CXXFLAGS} -fopenmp -DEIGEN_NO_DEBUG"

# Default to using OpenBLAS for the linear algebra libraries
LINALG_LIBS="-llapack -lopenblas"

if [[ "$BUILD_OS" == "darwin" ]]; then
    # macOS linker needs a little extra help in linking
    LINALG_LIBS="${LINALG_LIBS} -lgfortran"
fi

if [[ "${CXX}" == *"/bin/icpc" ]]; then
    MKL_ROOT="/opt/intel/compilers_and_libraries/${BUILD_OS}/mkl"
    CXXFLAGS="${CXXFLAGS} -DUSE_MKL"
    CXXFLAGS="${CXXFLAGS} -I${MKL_ROOT}/include"
    LDFLAGS="${LDFLAGS} -L${MKL_ROOT}/lib/intel64"
    LINALG_LIBS="-lmkl_rt"
fi

#rm -f gcta64
#make clean

make -j${MAKE_JOBS} \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS}" \
    LINALG_LIBS="${LINALG_LIBS}" \
    LDFLAGS="${LDFLAGS}" \
    2>&1 | tee build.log

mkdir -p "${PREFIX}/bin"
install -m 755 gcta64 "${PREFIX}/bin"
