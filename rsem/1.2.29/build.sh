#!/bin/bash
set -o pipefail

## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CXXFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Squash annoying, Boost-related warnings
CXXFLAGS="${CXXFLAGS} -Wno-unused-local-typedefs"

# Make sure we don't accidentally build with packaged libraries
rm -rf boost samtools*


## Build and install
env CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" \
    make -j${BB_MAKE_JOBS} \
    install prefix="${PREFIX}" \
    SAMLIBS_extra="-lcurl -lcrypto -lssl" \
    2>&1 | tee build.log

env CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" \
    make -C EBSeq \
    install prefix="${PREFIX}" \
    2>&1 | tee build-ebseq.log

SHARE_DIR="${PREFIX}/share/${PKG_NAME}"

# Move Perl module into shared directory to keep $PREFIX/bin clean
cd "${PREFIX}/bin"
install -d "${SHARE_DIR}"
mv rsem*.pm "${SHARE_DIR}"

# Fix Perl shebang and library paths
for fn in $(grep -Il '^#!.*perl' rsem* convert-* extract-*); do
    sed -i.bak "
        1s:^.*$:#!${PREFIX}/bin/perl:;
        2,\$s:@@share_dir@@:${SHARE_DIR}:;
    " ${fn}
    rm -f ${fn}.bak
done
