#!/bin/bash
set -e -x -o pipefail


## Configure

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

if [ "$BUILD_OS" == 'darwin' ]; then
    MACOSX_VERSION_MIN="10.8"
    CFLAGS="${CFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"

    # Make sure we use the same C++ standard library as boost
    CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
    LDFLAGS="${LDFLAGS} -stdlib=libc++"
fi

# Squash annoying, Boost-related warnings
#CXXFLAGS="${CXXFLAGS} -Wno-unused-local-typedefs"

# Make sure we don't accidentally build with packaged libraries
rm -rf boost samtools*

# Weirdly, "conda build" doesn't set this for us
R_VER=$(R --version | head -n1 | awk '{print $3;}' | cut -d. -f1-2)


## Build and install
env CC="${CC}" CFLAGS="${CFLAGS}" \
    CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    make -j${MAKE_JOBS} install \
    prefix="${PREFIX}" \
    HTSLIB="-lhts" \
    2>&1 | tee build.log

# Various scripts missed by the top-level Makefile "install" target
install -m 0755 rsem-* ${PREFIX}/bin

env CC="${CC}" CFLAGS="${CFLAGS}" \
    CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    make -C pRSEM filterSam2Bed \
    prefix="${PREFIX}" \
    BAMLIB_CPPFLAGS="-I${PREFIX}/include/samtools" BAMLIB="-lbam" \
    HTSLIB_CPPFLAGS="-I${PREFIX}/include/htslib" HTSLIB="-lhts" \
    2>&1 | tee build-prsem.log

env CC="${CC}" CFLAGS="${CFLAGS}" \
    CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    make -C EBSeq install \
    prefix="${PREFIX}" \
    2>&1 | tee build-ebseq.log


## Move Perl module into shared directory to keep $PREFIX/bin clean
SHARE_DIR="${PREFIX}/libexec/${PKG_NAME}"
install -m 755 -d "${SHARE_DIR}"
mv ${PREFIX}/bin/rsem*.pm "${SHARE_DIR}"


## Install pRSEM
PRSEM_DIR="${SHARE_DIR}/pRSEM"
PRSEM_RLIB="${PRSEM_DIR}/RLib"

install -m 755 -d "${PRSEM_DIR}" \
    "${PRSEM_RLIB}" \
    "${PRSEM_DIR}/idrCode" \
    "${PRSEM_DIR}/phantompeakqualtools"

cd "${SRC_DIR}/pRSEM"
install -m 755 *.py *.R prsem-* "${PRSEM_DIR}"
rm -f "${PRSEM_DIR}/installRLib.R"

install -m 644 idrCode/*.r idrCode/*.txt "${PRSEM_DIR}/idrCode"
install -m 755 idrCode/*.sh "${PRSEM_DIR}/idrCode"

install -m 644 phantompeakqualtools/*.R phantompeakqualtools/*.txt \
    "${PRSEM_DIR}/phantompeakqualtools"

SPP_SRC="${SRC_DIR}/pRSEM/phantompeakqualtools/spp_1.10.1_on_R${R_VER}"
if [ ! -d "${SPP_SRC}" ]; then
    echo "ERROR: Could not find spp source for R ${R_VER}" >&2
    exit 1
fi
cd "${SPP_SRC}"
env R_LIBS="${PRSEM_RLIB}" R CMD INSTALL -l "${PRSEM_RLIB}" .


## Fix shebang lines and library paths
cd "${PREFIX}/bin"
egrep -Il '@@(bin|share)_dir@@' rsem* convert-* extract-* | \
    xargs sed -i.bak "
        s:@@bin_dir@@:${PREFIX}/bin:g;
        s:@@share_dir@@:${SHARE_DIR}:g;
    "
rm -f *.bak

cd "${SHARE_DIR}"
egrep -Ilr '@@[A-Za-z_]*_dir@@' * | \
    xargs sed -i.bak "
        s:@@bin_dir@@:${PREFIX}/bin:g;
        s:@@share_dir@@:${SHARE_DIR}:g;
        s:@@prsem_rlib_dir@@:${PRSEM_RLIB}:g;
    "
find . -type f -name '*.bak' | xargs rm -f
