#!/bin/bash
set -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Additional tweaks for the Intel compiler
if [[ "${CC}" == *"/bin/icc" ]]; then
    # Help `icpc` find include files when using conda's `gcc`
    export GXX_INCLUDE="${PREFIX}/gcc/include"
    CXXFLAGS="${CXXFLAGS} -I${GXX_INCLUDE}/c++"
    CXXFLAGS="${CXXFLAGS} -I${GXX_INCLUDE}/c++/${BUILD_ARCH}-unknown-${BUILD_OS}-gnu"
fi

unset ARFLAGS
make -C src -j${MAKE_JOBS} \
    BUILDOPTIMIZED=1 \
    AR="${AR}" LD="${LD}" \
    2>&1 | tee build.log

# Sub-directory of "${PREFIX}" where CANU installed itself
case "$BUILD_ARCH" in
    'x86_64') CANU_DIR="`uname -s`-amd64" ;;
    *)        CANU_DIR="`uname -s`-${BUILD_ARCH}" ;;
esac

BASE_LIB_DIR="${PREFIX}/lib"
CANU_LIB_DIR="${BASE_LIB_DIR}/${PKG_NAME}"

# Clean up install
pushd "${PREFIX}"
mkdir -p "${PREFIX}/bin" "${CANU_LIB_DIR}"
if [[ ! -d "$CANU_DIR" ]]; then
    echo "FATAL: Could not find ${PKG_NAME} directory" >&2
    exit 1
fi
rm -rf ${CANU_DIR}/obj ${CANU_DIR}/bin/*.a
mv -f ${CANU_DIR}/bin/*.jar "${CANU_LIB_DIR}"
mv -f ${CANU_DIR}/bin/lib/canu/*.pm "${CANU_LIB_DIR}"
rmdir ${CANU_DIR}/bin/lib/canu ${CANU_DIR}/bin/lib
mv -f ${CANU_DIR}/bin/* bin
rmdir ${CANU_DIR}/bin ${CANU_DIR}

sed -i.bak "
    1s|^.*$|#!${PREFIX}/bin/perl|;
    2,\$s|@@conda_prefix@@|${PREFIX}|;
    2,\$s|@@base_lib_dir@@|${BASE_LIB_DIR}|;
    2,\$s|@@canu_lib_dir@@|${CANU_LIB_DIR}|;
" bin/canu
sed -i.bak "
    s|@@conda_prefix@@|${PREFIX}|;
    s|@@base_lib_dir@@|${BASE_LIB_DIR}|;
    s|@@canu_lib_dir@@|${CANU_LIB_DIR}|;
" ${CANU_LIB_DIR}/*.pm
rm -f bin/canu.bak ${CANU_LIB_DIR}/*.bak
